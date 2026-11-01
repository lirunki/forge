"""Server-side TTS adapters for configured OpenAI-compatible and xAI providers."""
from __future__ import annotations

import asyncio
import base64
import io
import json
import math
import re
import shutil
import subprocess
import tempfile
import wave
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import Any

from .config import Provider
from .providers import UpstreamError

OPENAI_VOICES = (
    ("alloy", "neutral"), ("ash", "male"), ("ballad", "male"),
    ("coral", "female"), ("echo", "male"), ("fable", "neutral"),
    ("nova", "female"), ("onyx", "male"), ("sage", "neutral"),
    ("shimmer", "female"),
)
XAI_VOICES = (
    ("eve", "Energetic & upbeat", "female"), ("ara", "Warm & friendly", "female"),
    ("leo", "Authoritative & strong", "male"), ("rex", "Confident & clear", "male"),
    ("sal", "Smooth & balanced", "neutral"), ("carina", "Soft, empathetic", "female"),
    ("zagan", "Powerful, dramatic", "male"), ("helix", "Bold, dynamic", "neutral"),
    ("orion", "Rich, cinematic", "male"), ("luna", "Gentle, nurturing", "female"),
    ("iris", "Friendly, upbeat", "female"), ("altair", "Elegant, premium", "neutral"),
    ("zenith", "Sharp, focused", "neutral"), ("perseus", "Strong, confident", "male"),
    ("helios", "Upbeat, energetic", "male"), ("lux", "Grounded, calm", "neutral"),
    ("kepler", "Inventive, charismatic", "male"), ("rigel", "Precise, professional", "male"),
    ("cosmo", "Bright, curious", "neutral"), ("celeste", "Compassionate", "female"),
    ("ursa", "Friendly, warm", "neutral"), ("sirius", "Quick-witted, playful", "neutral"),
    ("lumen", "Warm, engaging", "neutral"), ("castor", "Charismatic, easygoing", "male"),
    ("naksh", "Warm, thoughtful", "neutral"), ("atlas", "Confident, commanding", "male"),
)
_FORMAT_MIME = {
    "mp3": "audio/mpeg", "wav": "audio/wav", "opus": "audio/opus",
    "aac": "audio/aac", "flac": "audio/flac", "pcm": "audio/pcm",
}
OPENAI_TTS_MODELS = {"tts-1", "tts-1-hd", "gpt-4o-mini-tts"}
LOCAL_ENGINE_ID = "local"
LOCAL_PROVIDER_ID = "vm-local"
LOCAL_DEFAULT_VOICE = "en-us"

class LocalTtsUnavailable(RuntimeError):
    """The local speech engine is not installed or has no voices."""

class LocalTtsError(RuntimeError):
    """Local speech generation failed or exceeded a safety limit."""


@dataclass(frozen=True)
class TtsAudio:
    data: bytes
    mime: str
    engine: str
    voice: str
    model: str
    provider_id: str


def tts_engine(provider: Provider) -> str | None:
    if provider.kind != "openai":
        return None
    if provider.id.lower() == "xai" or "api.x.ai" in provider.base_url.lower():
        return "xai"
    return "openai"


def _espeak_binary() -> str | None:
    return shutil.which("espeak-ng", path="/usr/bin:/bin")

@lru_cache(maxsize=1)
def local_voice_catalog() -> dict[str, Any]:
    binary = _espeak_binary()
    if not binary:
        return {"available": False, "voices": [], "providerId": LOCAL_PROVIDER_ID, "engine": LOCAL_ENGINE_ID, "note": "Install espeak-ng on the ForgeChat VM to enable local TTS."}
    try:
        result = subprocess.run(
            [binary, "--voices"], check=True, capture_output=True, text=True,
            encoding="utf-8", errors="replace", timeout=5,
            env={"PATH": "/usr/bin:/bin", "LANG": "C.UTF-8"},
        )
    except (OSError, subprocess.SubprocessError):
        return {"available": False, "voices": [], "providerId": LOCAL_PROVIDER_ID, "engine": LOCAL_ENGINE_ID, "note": "The local eSpeak NG voice catalog could not be loaded."}
    voices = []
    seen = set()
    for line in result.stdout.splitlines()[1:]:
        fields = line.split()
        if len(fields) < 5 or not fields[0].isdigit():
            continue
        voice_id = fields[1].strip()
        if not voice_id or voice_id in seen:
            continue
        seen.add(voice_id)
        gender = fields[2].split("/", 1)[-1].upper()
        voice_name = fields[3].replace("_", " ")
        voices.append({
            "id": voice_id, "value": voice_id, "name": voice_name,
            "label": f"{voice_name} ({voice_id})", "locale": voice_id,
            "gender": gender if gender in {"M", "F"} else "neutral",
            "source": "local", "via": "local", "engine": LOCAL_ENGINE_ID,
        })
    default_voice = LOCAL_DEFAULT_VOICE if LOCAL_DEFAULT_VOICE in seen else ("en" if "en" in seen else (voices[0]["id"] if voices else ""))
    return {
        "available": bool(voices), "voices": voices, "providerId": LOCAL_PROVIDER_ID,
        "provider": "ForgeChat VM (offline)", "engine": LOCAL_ENGINE_ID,
        "defaultVoice": default_voice, "autoVoice": default_voice,
        "source": "local", "note": "Speech is synthesized locally on the ForgeChat VM with eSpeak NG; no third-party TTS provider is called.",
    }

def voice_catalog(provider: Provider) -> dict[str, Any]:
    engine = tts_engine(provider)
    if engine == "xai":
        voices = [
            {"id": voice, "name": voice, "value": voice, "label": f"{voice} — {label}", "locale": "", "gender": gender, "source": "cloud", "via": "cloud", "engine": "xai"}
            for voice, label, gender in XAI_VOICES
        ]
        default_voice = "eve"
    elif engine == "openai":
        voices = [
            {"id": voice, "name": voice, "value": voice, "label": voice, "locale": "", "gender": gender, "source": "cloud", "via": "cloud", "engine": "openai"}
            for voice, gender in OPENAI_VOICES
        ]
        default_voice = "alloy"
    else:
        return {"available": False, "voices": [], "providerId": provider.id, "engine": None}
    return {
        "available": True, "voices": voices, "providerId": provider.id,
        "provider": provider.label, "engine": engine,
        "defaultVoice": default_voice, "autoVoice": default_voice,
        "source": "cloud", "note": "Speech is synthesized by the configured ForgeChat provider; provider credentials remain on the server.",
    }


def normalize_tts_request(raw: Any, providers: list[Provider]) -> dict[str, Any]:
    if not isinstance(raw, dict):
        raise ValueError("Request must be a JSON object.")
    allowed = {"text", "engine", "providerId", "provider", "model", "ttsModel", "speechModel", "voice", "voice_id", "voiceId", "language", "lang", "format", "response_format", "codec", "speed", "rate", "pitch", "sampleRate", "sample_rate", "bitRate", "bit_rate", "destination"}
    unexpected = set(raw) - allowed
    if unexpected:
        raise ValueError("Unsupported TTS field: " + sorted(unexpected)[0])
    text = raw.get("text")
    if not isinstance(text, str):
        raise ValueError("text is required.")
    text = text.strip()
    if not text:
        raise ValueError("text is required.")
    requested_engine = raw.get("engine")
    if requested_engine is not None and (not isinstance(requested_engine, str) or requested_engine.lower() not in {"local", "cloud", "openai", "xai"}):
        raise ValueError("Unsupported TTS engine.")
    if isinstance(requested_engine, str) and requested_engine.lower() == LOCAL_ENGINE_ID:
        catalog = local_voice_catalog()
        if not catalog.get("available"):
            raise LookupError("VM-local TTS is unavailable; install espeak-ng on the ForgeChat VM.")
        if raw.get("providerId") is not None or raw.get("provider") is not None:
            raise ValueError("providerId cannot be used with VM-local TTS.")
        if len(text) > 4096:
            raise ValueError("text exceeds the 4096-character VM-local TTS limit.")
        voices = {voice["id"] for voice in catalog["voices"]}
        language = raw.get("language", raw.get("lang", "en"))
        if not isinstance(language, str) or not re.fullmatch(r"[A-Za-z]{2,3}(?:[-_][A-Za-z]{2,4})?", language.strip()):
            raise ValueError("language is invalid.")
        language = language.strip().replace("_", "-")
        language_voice = language.lower()
        if language_voice not in voices:
            language_voice = language_voice.split("-", 1)[0]
        voice = raw.get("voice", raw.get("voice_id", raw.get("voiceId", language_voice if language_voice in voices else catalog["defaultVoice"])))
        if not isinstance(voice, str) or voice.strip() not in voices:
            raise ValueError("voice is not in the VM-local voice catalog.")
        voice = voice.strip()
        output_format = str(raw.get("format", raw.get("response_format", raw.get("codec", "wav")))).lower()
        if output_format != "wav":
            raise ValueError("VM-local TTS currently supports WAV output only.")
        try:
            speed = float(raw.get("speed", raw.get("rate", 1)))
            pitch = float(raw.get("pitch", 1))
        except (TypeError, ValueError) as exc:
            raise ValueError("speed or pitch is invalid.") from exc
        if not math.isfinite(speed) or not 0.25 <= speed <= 4:
            raise ValueError("speed must be a number between 0.25 and 4.")
        if not math.isfinite(pitch) or not 0.5 <= pitch <= 2:
            raise ValueError("pitch must be a number between 0.5 and 2.")
        return {
            "provider": None, "engine": LOCAL_ENGINE_ID, "model": "espeak-ng",
            "text": text, "voice": voice, "language": language,
            "format": "wav", "speed": speed, "pitch": pitch, "mime": "audio/wav",
        }
    provider_id = raw.get("providerId", raw.get("provider"))
    if provider_id is not None and (not isinstance(provider_id, str) or len(provider_id) > 80):
        raise ValueError("providerId is invalid.")
    provider = next((item for item in providers if provider_id and item.id == provider_id), None)
    if provider_id and provider is None:
        raise LookupError("The requested TTS provider is not enabled on the ForgeChat server.")
    if provider is None:
        provider = next((item for item in providers if tts_engine(item)), None)
    if provider is None or not tts_engine(provider):
        raise LookupError("Cloud TTS requires a configured xAI or OpenAI-compatible provider.")
    engine = tts_engine(provider)
    max_chars = 12000 if engine == "xai" else 4096
    if len(text) > max_chars:
        raise ValueError(f"text exceeds the {max_chars}-character TTS limit.")
    voices = {item[0] for item in XAI_VOICES} if engine == "xai" else {item[0] for item in OPENAI_VOICES}
    default_voice = "eve" if engine == "xai" else "alloy"
    voice = raw.get("voice", raw.get("voice_id", raw.get("voiceId", default_voice)))
    if not isinstance(voice, str) or len(voice) > 80:
        raise ValueError("voice is invalid.")
    voice = voice.strip().lower()
    if voice not in voices:
        raise ValueError("voice is not in the configured provider's voice allow-list.")
    output_format = str(raw.get("format", raw.get("response_format", raw.get("codec", "mp3")))).lower()
    if output_format not in _FORMAT_MIME:
        raise ValueError("Unsupported TTS audio format.")
    language = raw.get("language", raw.get("lang", "en"))
    if not isinstance(language, str) or not re.fullmatch(r"[A-Za-z]{2,3}(?:[-_][A-Za-z]{2,4})?", language.strip()):
        raise ValueError("language is invalid.")
    language = language.strip().replace("_", "-")
    model_raw = raw.get("ttsModel", raw.get("speechModel", raw.get("model")))
    if engine == "xai":
        model = "xai-tts"
        speed = 1.0
    else:
        model = model_raw.strip() if isinstance(model_raw, str) and model_raw.strip() else "tts-1"
        if model not in OPENAI_TTS_MODELS:
            raise ValueError("TTS model is not in the server allow-list.")
        speed_raw = raw.get("speed", raw.get("rate", 1))
        try:
            speed = float(speed_raw)
        except (TypeError, ValueError) as exc:
            raise ValueError("speed must be a number between 0.25 and 4.") from exc
        if not 0.25 <= speed <= 4:
            raise ValueError("speed must be a number between 0.25 and 4.")
    return {
        "provider": provider, "engine": engine, "model": model, "text": text,
        "voice": voice, "language": language, "format": output_format,
        "speed": speed, "pitch": 1.0, "mime": _FORMAT_MIME[output_format],
    }


async def synthesize_local_tts(
    *, text: str, voice: str, speed: float, pitch: float,
    timeout_seconds: float, max_response_bytes: int,
) -> TtsAudio:
    """Render speech with the VM's offline eSpeak NG engine; never opens a network connection."""
    catalog = local_voice_catalog()
    allowed_voices = {item["id"] for item in catalog.get("voices", [])}
    binary = _espeak_binary()
    if not binary or voice not in allowed_voices:
        raise LocalTtsUnavailable("VM-local TTS is unavailable or the selected voice is not installed.")
    words_per_minute = max(80, min(450, int(round(175 * speed))))
    pitch_value = max(0, min(99, int(round(50 * pitch))))
    with tempfile.TemporaryDirectory(prefix="forgechat-local-tts-") as temp_dir:
        output_path = Path(temp_dir) / "speech.wav"
        env = {"PATH": "/usr/bin:/bin", "LANG": "C.UTF-8"}
        try:
            process = await asyncio.create_subprocess_exec(
                binary, "-v", voice, "-s", str(words_per_minute), "-p", str(pitch_value),
                "-a", "170", "-w", str(output_path), "--stdin",
                stdin=asyncio.subprocess.PIPE, stdout=asyncio.subprocess.DEVNULL,
                stderr=asyncio.subprocess.PIPE, env=env,
            )
            try:
                await asyncio.wait_for(
                    process.communicate(text.encode("utf-8")), timeout=max(1.0, timeout_seconds),
                )
            except (asyncio.TimeoutError, asyncio.CancelledError):
                process.kill()
                await process.communicate()
                raise
        except asyncio.TimeoutError as exc:
            raise LocalTtsError("VM-local TTS exceeded its time limit.") from exc
        except asyncio.CancelledError:
            raise
        except LocalTtsError:
            raise
        except Exception as exc:
            raise LocalTtsError("VM-local TTS could not start.") from exc
        if process.returncode != 0 or not output_path.is_file():
            raise LocalTtsError("VM-local TTS synthesis failed.")
        if output_path.stat().st_size > max_response_bytes:
            raise LocalTtsError("VM-local TTS output exceeded the audio size limit.")
        data = output_path.read_bytes()
        try:
            with wave.open(io.BytesIO(data), "rb") as wav_file:
                if wav_file.getnframes() <= 0 or wav_file.getframerate() <= 0:
                    raise ValueError("empty wave")
        except (wave.Error, ValueError) as exc:
            raise LocalTtsError("VM-local TTS returned invalid WAV audio.") from exc
    return TtsAudio(data, "audio/wav", LOCAL_ENGINE_ID, voice, "espeak-ng", LOCAL_PROVIDER_ID)

async def call_tts(
    provider: Provider,
    *,
    engine: str,
    model: str,
    text: str,
    voice: str,
    language: str,
    output_format: str,
    speed: float,
    timeout_seconds: float,
    max_response_bytes: int,
    transport: Any = None,
) -> TtsAudio:
    """Call a server-configured provider's TTS endpoint; never accept client URLs/keys."""
    import httpx

    base = provider.base_url.rstrip("/")
    headers = {"Content-Type": "application/json", "Accept": _FORMAT_MIME[output_format] + ", application/json, */*"}
    if provider.api_key:
        headers["Authorization"] = "Bearer " + provider.api_key
    if engine == "xai":
        url = base + "/tts"
        body: dict[str, Any] = {
            "text": text,
            "voice_id": voice,
            "language": language,
            "output_format": {
                "codec": output_format,
                "sample_rate": 24000,
                "bit_rate": 128000,
            },
        }
    else:
        url = base + "/audio/speech"
        body = {"model": model, "input": text, "voice": voice, "response_format": output_format}
        if speed != 1:
            body["speed"] = speed
    chunks: list[bytes] = []
    size = 0
    try:
        async with httpx.AsyncClient(timeout=timeout_seconds, follow_redirects=False, trust_env=False, transport=transport) as client:
            async with client.stream("POST", url, headers=headers, json=body) as response:
                if response.status_code < 200 or response.status_code >= 300:
                    raise UpstreamError(response.status_code)
                async for chunk in response.aiter_bytes():
                    size += len(chunk)
                    if size > max_response_bytes:
                        raise UpstreamError(response.status_code)
                    chunks.append(chunk)
                content_type = response.headers.get("content-type", "").split(";", 1)[0].strip().lower()
    except UpstreamError:
        raise
    except Exception as exc:
        raise UpstreamError() from exc
    data = b"".join(chunks)
    if content_type in {"application/json", "text/json"} or content_type.endswith("+json"):
        try:
            payload = json.loads(data)
            encoded = next((payload.get(key) for key in ("audio", "data", "audio_base64", "base64") if isinstance(payload.get(key), str)), "")
            if encoded.startswith("data:"):
                encoded = encoded.split(",", 1)[-1]
            data = base64.b64decode(encoded, validate=True)
        except Exception as exc:
            raise UpstreamError() from exc
    if not data or len(data) > max_response_bytes:
        raise UpstreamError()
    return TtsAudio(data=data, mime=_FORMAT_MIME[output_format], engine=engine, voice=voice, model=model, provider_id=provider.id)
