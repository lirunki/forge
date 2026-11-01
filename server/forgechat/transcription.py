"""Server-side speech-to-text adapters for configured providers."""
from __future__ import annotations

import base64
import binascii
import json
import re
from typing import Any

import httpx

from .config import Provider
from .providers import UpstreamError

MAX_AUDIO_BYTES = 12 * 1024 * 1024
MAX_TRANSCRIPTION_RESPONSE_BYTES = 2 * 1024 * 1024
_AUDIO_MIME_TYPES = {
    "audio/aac", "audio/flac", "audio/mp3", "audio/mp4", "audio/m4a",
    "audio/mpeg", "audio/ogg", "audio/wav", "audio/wave", "audio/webm",
    "audio/x-m4a", "audio/x-wav",
}
_LANGUAGE = re.compile(r"^[A-Za-z]{2,3}(?:-[A-Za-z]{2,4})?$")
_FILENAME = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_.-]{0,99}$")


def normalize_transcription_request(raw: Any, providers: list[Provider]) -> dict[str, Any]:
    if not isinstance(raw, dict):
        raise ValueError("Request must be a JSON object.")
    allowed = {"dataUrl", "language", "lang", "timestamps", "prompt", "providerId", "provider", "filename", "name"}
    unexpected = set(raw) - allowed
    if unexpected:
        raise ValueError("Unsupported transcription field: " + sorted(unexpected)[0])
    data_url = raw.get("dataUrl")
    if not isinstance(data_url, str) or len(data_url) > ((MAX_AUDIO_BYTES + 2) // 3) * 4 + 256:
        raise ValueError("dataUrl must contain a local audio data URL within the 12 MiB limit.")
    match = re.fullmatch(r"data:([^;,]+);base64,([A-Za-z0-9+/=\r\n]+)", data_url.strip(), re.IGNORECASE)
    if not match:
        raise ValueError("dataUrl must be a base64-encoded audio data URL.")
    mime = match.group(1).lower()
    if mime not in _AUDIO_MIME_TYPES:
        raise ValueError("Unsupported audio MIME type.")
    encoded = re.sub(r"\s+", "", match.group(2))
    try:
        audio = base64.b64decode(encoded, validate=True)
    except (binascii.Error, ValueError) as exc:
        raise ValueError("Audio data is not valid base64.") from exc
    if not audio or len(audio) > MAX_AUDIO_BYTES:
        raise ValueError("Audio must be non-empty and no larger than 12 MiB.")

    language = raw.get("language", raw.get("lang"))
    if language is not None:
        if not isinstance(language, str):
            raise ValueError("language must be a language code or auto.")
        language = language.strip()
        if language.lower() == "auto":
            language = None
        elif not _LANGUAGE.fullmatch(language):
            raise ValueError("language must be a language code or auto.")
    prompt = raw.get("prompt", "")
    if not isinstance(prompt, str) or len(prompt) > 2000:
        raise ValueError("prompt must be a string no longer than 2000 characters.")
    timestamps = raw.get("timestamps", False)
    if not isinstance(timestamps, bool):
        raise ValueError("timestamps must be a boolean.")
    filename = raw.get("filename", raw.get("name", "audio"))
    if not isinstance(filename, str):
        raise ValueError("filename must be a string.")
    filename = filename.replace("\\", "/").rsplit("/", 1)[-1].strip()
    if not filename:
        filename = "audio"
    if not _FILENAME.fullmatch(filename):
        filename = "audio"
    if "." not in filename:
        extension = {"audio/mpeg": ".mp3", "audio/mp3": ".mp3", "audio/wav": ".wav", "audio/wave": ".wav", "audio/x-wav": ".wav", "audio/mp4": ".m4a", "audio/m4a": ".m4a", "audio/x-m4a": ".m4a", "audio/webm": ".webm", "audio/ogg": ".ogg", "audio/flac": ".flac", "audio/aac": ".aac"}.get(mime, ".audio")
        filename += extension

    requested_provider = raw.get("providerId", raw.get("provider"))
    if requested_provider is not None and (not isinstance(requested_provider, str) or len(requested_provider) > 80):
        raise ValueError("providerId is invalid.")
    providers_by_id = {provider.id: provider for provider in providers if provider.api_key or provider.auth_optional}
    if requested_provider and requested_provider not in providers_by_id:
        raise LookupError("The requested transcription provider is not enabled on the ForgeChat server.")
    requested = providers_by_id.get(requested_provider) if requested_provider else None
    candidates = [
        provider for provider in providers
        if provider.kind == "openai" and not provider.auth_optional and provider.api_key
    ]

    def rank(provider: Provider) -> tuple[int, int]:
        identity = (provider.id + " " + provider.label + " " + provider.base_url).lower()
        if "groq" in identity:
            priority = 0
        elif "api.openai.com" in provider.base_url.lower() or provider.id.lower() == "openai":
            priority = 1
        elif "x.ai" in identity or provider.id.lower() == "xai":
            priority = 2
        else:
            priority = 3
        return priority, providers.index(provider)

    ordered = sorted(candidates, key=rank)
    if requested in ordered:
        ordered.remove(requested)
        ordered.insert(0, requested)
    if not ordered:
        raise LookupError("No configured speech-to-text provider is available on the ForgeChat server.")
    return {
        "audio": audio,
        "mime": mime,
        "filename": filename,
        "language": language,
        "prompt": prompt.strip(),
        "timestamps": timestamps,
        "providers": ordered,
    }


def _is_xai(provider: Provider) -> bool:
    return provider.id.lower() == "xai" or "api.x.ai" in provider.base_url.lower()


def _is_groq(provider: Provider) -> bool:
    return provider.id.lower() == "groq" or "groq" in (provider.id + " " + provider.label + " " + provider.base_url).lower()


def _segments(value: Any) -> list[dict[str, Any]]:
    if not isinstance(value, list):
        return []
    result: list[dict[str, Any]] = []
    for item in value:
        if not isinstance(item, dict):
            continue
        timestamp = item.get("timestamp")
        if isinstance(timestamp, (list, tuple)):
            start = timestamp[0] if timestamp else 0
            end = timestamp[1] if len(timestamp) > 1 else start
        else:
            start = item.get("start", item.get("start_time", item.get("startTime", 0)))
            end = item.get("end", item.get("end_time", item.get("endTime", 0)))
        text = item.get("text", item.get("transcript", item.get("content", "")))
        text = str(text or "").strip()
        if not text:
            continue
        try:
            start_value, end_value = max(0.0, float(start or 0)), max(0.0, float(end or 0))
        except (TypeError, ValueError):
            start_value, end_value = 0.0, 0.0
        result.append({"start": start_value, "end": max(start_value, end_value), "text": text})
    return result


def _normalize_response(body: bytes, provider_id: str) -> dict[str, Any]:
    try:
        value = json.loads(body)
    except (UnicodeDecodeError, json.JSONDecodeError):
        text = body.decode("utf-8", errors="replace").strip()
        if not text:
            raise UpstreamError()
        return {"text": text, "segments": [], "providerId": provider_id}
    if not isinstance(value, dict):
        raise UpstreamError()
    segments = _segments(value.get("segments", value.get("chunks", [])))
    if not segments and isinstance(value.get("words"), list) and value["words"]:
        words = value["words"]
        normalized_words = _segments(words)
        if normalized_words:
            segments = [{"start": normalized_words[0]["start"], "end": normalized_words[-1]["end"], "text": " ".join(item["text"] for item in normalized_words)}]
    text = value.get("text") or value.get("transcript") or value.get("result")
    if not text and segments:
        text = " ".join(item["text"] for item in segments)
    if not isinstance(text, str) or not text.strip():
        raise UpstreamError()
    return {"text": text.strip(), "segments": segments, "providerId": provider_id}


async def call_transcription(
    request: dict[str, Any],
    *,
    timeout_seconds: float,
    max_response_bytes: int = MAX_TRANSCRIPTION_RESPONSE_BYTES,
    transport: httpx.AsyncBaseTransport | None = None,
) -> dict[str, Any]:
    """Try configured STT providers in order, never accepting client URLs or credentials."""
    last_error: UpstreamError | None = None
    for provider in request["providers"]:
        base = provider.base_url.rstrip("/")
        is_xai = _is_xai(provider)
        url = base + ("/stt" if is_xai else "/audio/transcriptions")
        data: dict[str, str] = {}
        if is_xai:
            if request["language"] or request["timestamps"]:
                data["language"] = request["language"] or "en"
            if request["prompt"]:
                data["prompt"] = request["prompt"]
            if request["timestamps"]:
                data["format"] = "true"
        else:
            data["model"] = "whisper-large-v3" if _is_groq(provider) else "whisper-1"
            if request["language"]:
                data["language"] = request["language"]
            if request["prompt"]:
                data["prompt"] = request["prompt"]
            data["response_format"] = "verbose_json" if request["timestamps"] else "json"
        headers = {"Authorization": "Bearer " + provider.api_key}
        chunks: list[bytes] = []
        size = 0
        try:
            async with httpx.AsyncClient(timeout=timeout_seconds, follow_redirects=False, trust_env=False, transport=transport) as client:
                async with client.stream(
                    "POST", url, headers=headers, data=data,
                    files={"file": (request["filename"], request["audio"], request["mime"])},
                ) as response:
                    if response.status_code < 200 or response.status_code >= 300:
                        raise UpstreamError(response.status_code)
                    async for chunk in response.aiter_bytes():
                        size += len(chunk)
                        if size > max_response_bytes:
                            raise UpstreamError(response.status_code)
                        chunks.append(chunk)
            return _normalize_response(b"".join(chunks), provider.id)
        except UpstreamError as exc:
            last_error = exc
        except Exception as exc:
            last_error = UpstreamError()
            last_error.__cause__ = exc
    raise last_error or UpstreamError()
