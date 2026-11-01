"""Allowlisted server-side provider adapters for non-streaming ForgeHost chat."""

from __future__ import annotations

import base64
import json
import re
from collections.abc import AsyncIterator
from typing import Any
from urllib.parse import quote

from .config import Provider, Settings


class UpstreamError(RuntimeError):
    def __init__(self, status_code: int | None = None):
        super().__init__("The configured AI provider could not complete the request.")
        self.status_code = status_code


def prepare_request(
    provider: Provider,
    model: str,
    messages: list[dict[str, Any]],
    *,
    temperature: float,
    max_tokens: int | None = None,
    response_format: dict[str, Any] | None = None,
    stream: bool = False,
) -> tuple[str, dict[str, str], dict[str, Any]]:
    """Build a provider request using only server-owned endpoint/key settings."""
    if provider.kind == "openai":
        base = provider.base_url.rstrip("/")
        url = base if base.lower().endswith("/chat/completions") else base + "/chat/completions"
        headers = {"Content-Type": "application/json"}
        if provider.api_key:
            headers["Authorization"] = "Bearer " + provider.api_key
        body: dict[str, Any] = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "stream": bool(stream),
        }
        if max_tokens is not None:
            body["max_tokens"] = max_tokens
        if response_format is not None:
            body["response_format"] = response_format
        return url, headers, body

    if provider.kind == "gemini":
        method = ":streamGenerateContent?alt=sse" if stream else ":generateContent"
        url = provider.base_url.rstrip("/") + "/models/" + quote(model, safe="") + method
        headers = {"x-goog-api-key": provider.api_key, "Content-Type": "application/json"}
        contents: list[dict[str, Any]] = []
        system_parts: list[str] = []
        for message in messages:
            role = message["role"]
            parts = _gemini_content_parts(message["content"])
            if role == "system":
                system_parts.extend(part["text"] for part in parts if "text" in part)
            else:
                contents.append({"role": "model" if role == "assistant" else "user", "parts": parts})
        body = {"contents": contents, "generationConfig": {"temperature": temperature}}
        if system_parts:
            body["systemInstruction"] = {"parts": [{"text": "\n".join(system_parts)}]}
        if max_tokens is not None:
            body["generationConfig"]["maxOutputTokens"] = max_tokens
        return url, headers, body

    raise ValueError("Unsupported configured provider kind.")


def normalize_request(raw: Any, settings: Settings) -> tuple[Provider, str, list[dict[str, Any]], float, int | None, dict[str, Any] | None]:
    if not isinstance(raw, dict):
        raise ValueError("Request must be a JSON object.")
    allowed = {"messages", "providerId", "provider", "model", "temperature", "max_tokens", "response_format"}
    unexpected = set(raw) - allowed
    if unexpected:
        raise ValueError("Unsupported request field: " + sorted(unexpected)[0])

    provider_id = raw.get("providerId", raw.get("provider"))
    if provider_id is None:
        provider = next((item for item in settings.providers if (item.api_key or item.auth_optional) and item.default_model), None)
    else:
        provider = next((item for item in settings.providers if item.id == provider_id), None)
    if provider is None or not (provider.api_key or provider.auth_optional):
        raise LookupError("No configured provider is available for this request.")

    requested_model = raw.get("model")
    model = str(requested_model or provider.default_model)
    if model not in provider.models:
        raise ValueError("Requested model is not allowed for this provider.")

    messages_raw = raw.get("messages")
    if not isinstance(messages_raw, list) or not messages_raw or len(messages_raw) > settings.max_messages:
        raise ValueError(f"messages must contain between 1 and {settings.max_messages} entries.")
    messages: list[dict[str, Any]] = []
    total_chars = 0
    image_count = 0
    for item in messages_raw:
        if not isinstance(item, dict) or set(item) - {"role", "content"}:
            raise ValueError("Each message must contain only role and content.")
        role = item.get("role")
        content = item.get("content")
        if role not in {"system", "user", "assistant"} or not isinstance(content, (str, list)):
            raise ValueError("Messages must use system/user/assistant roles and text or image content.")
        if isinstance(content, str):
            total_chars += len(content)
            normalized = content
        else:
            if len(content) > 32:
                raise ValueError("A message may contain at most 32 content parts.")
            normalized = []
            for part in content:
                if not isinstance(part, dict):
                    raise ValueError("Message content parts must be objects.")
                if part.get("type") == "text" and set(part) <= {"type", "text"} and isinstance(part.get("text"), str):
                    text = part["text"]
                    total_chars += len(text)
                    normalized.append({"type": "text", "text": text})
                elif part.get("type") == "image_url" and set(part) <= {"type", "image_url"}:
                    image = part.get("image_url")
                    if not isinstance(image, dict) or set(image) - {"url"} or not isinstance(image.get("url"), str):
                        raise ValueError("Only data-URL image attachments are supported.")
                    mime, encoded = _parse_image_data_url(image["url"])
                    decoded = base64.b64decode(encoded, validate=True)
                    if len(decoded) > 5 * 1024 * 1024:
                        raise ValueError("Each image attachment must be no larger than 5 MB.")
                    image_count += 1
                    if image_count > 8:
                        raise ValueError("At most 8 image attachments are supported per request.")
                    normalized.append({"type": "image_url", "image_url": {"url": "data:" + mime + ";base64," + encoded}})
                else:
                    raise ValueError("Supported content parts are text and local image data URLs.")
        if total_chars > settings.max_message_chars:
            raise ValueError("Combined message text is too large.")
        messages.append({"role": role, "content": normalized})
    if not any(message["role"] == "user" for message in messages):
        raise ValueError("At least one user message is required.")

    try:
        temperature = float(raw.get("temperature", 0.4))
    except (TypeError, ValueError) as exc:
        raise ValueError("temperature must be a number between 0 and 2.") from exc
    if not 0 <= temperature <= 2:
        raise ValueError("temperature must be a number between 0 and 2.")

    max_tokens = raw.get("max_tokens")
    if max_tokens is not None:
        if isinstance(max_tokens, bool) or not isinstance(max_tokens, int) or not 1 <= max_tokens <= 65536:
            raise ValueError("max_tokens must be an integer between 1 and 65536.")

    response_format = raw.get("response_format")
    if response_format is not None and (not isinstance(response_format, dict) or len(json.dumps(response_format)) > 4096):
        raise ValueError("response_format must be a small JSON object.")
    return provider, model, messages, temperature, max_tokens, response_format


def normalize_image_request(raw: Any, settings: Settings) -> tuple[Provider, str, str, int, list[str]]:
    if not isinstance(raw, dict):
        raise ValueError("Request must be a JSON object.")
    allowed = {"providerId", "provider", "model", "prompt", "n", "images", "confirm"}
    unexpected = set(raw) - allowed
    if unexpected:
        raise ValueError("Unsupported request field: " + sorted(unexpected)[0])
    provider_id = raw.get("providerId", raw.get("provider"))
    if provider_id is None:
        provider = next((item for item in settings.providers if item.image_models and (item.api_key or item.auth_optional)), None)
    else:
        provider = next((item for item in settings.providers if item.id == provider_id), None)
    if provider is None or provider.kind != "openai" or not provider.image_models or not (provider.api_key or provider.auth_optional):
        raise LookupError("No configured image-generation provider is available.")
    prompt = raw.get("prompt")
    if not isinstance(prompt, str) or not prompt.strip() or len(prompt) > 4000:
        raise ValueError("prompt must contain between 1 and 4000 characters.")
    if raw.get("confirm") is not True:
        raise ValueError("Confirm image generation before sending the request.")
    model = str(raw.get("model") or provider.image_models[0]).strip()
    if model not in provider.image_models:
        raise ValueError("Requested image model is not allowed for this provider.")
    count = raw.get("n", 1)
    if isinstance(count, bool) or not isinstance(count, int) or not 1 <= count <= 4:
        raise ValueError("n must be an integer between 1 and 4.")
    source_images = raw.get("images", [])
    if not isinstance(source_images, list) or len(source_images) > 4:
        raise ValueError("images must be an array of at most 4 data URLs.")
    images: list[str] = []
    total_bytes = 0
    for value in source_images:
        if not isinstance(value, str):
            raise ValueError("Image inputs must be data URLs.")
        mime, encoded = _parse_image_data_url(value)
        decoded = base64.b64decode(encoded, validate=True)
        if len(decoded) > 5 * 1024 * 1024:
            raise ValueError("Each input image must be no larger than 5 MB.")
        total_bytes += len(decoded)
        if total_bytes > 12 * 1024 * 1024:
            raise ValueError("Combined input images are too large.")
        images.append("data:" + mime + ";base64," + encoded)
    return provider, model, prompt.strip(), count, images


async def call_image_generation(
    provider: Provider,
    model: str,
    prompt: str,
    *,
    count: int,
    images: list[str],
    timeout_seconds: float,
    max_response_bytes: int,
) -> dict[str, Any]:
    """Call an explicitly configured OpenAI-compatible image endpoint."""
    try:
        import httpx
    except ImportError as exc:
        raise RuntimeError("httpx is required by the ForgeChat server.") from exc

    base = provider.base_url.rstrip("/")
    url = base if base.lower().endswith("/images/generations") else base + "/images/generations"
    headers = {"Content-Type": "application/json"}
    if provider.api_key:
        headers["Authorization"] = "Bearer " + provider.api_key
    body: dict[str, Any] = {"model": model, "prompt": prompt, "n": count}
    if images:
        body["image_url"] = [{"url": image} for image in images]

    chunks: list[bytes] = []
    size = 0
    try:
        async with httpx.AsyncClient(timeout=timeout_seconds, follow_redirects=False, trust_env=False) as client:
            async with client.stream("POST", url, headers=headers, json=body) as response:
                if response.status_code < 200 or response.status_code >= 300:
                    raise UpstreamError(response.status_code)
                async for chunk in response.aiter_bytes():
                    size += len(chunk)
                    if size > max_response_bytes:
                        raise UpstreamError(response.status_code)
                    chunks.append(chunk)
    except UpstreamError:
        raise
    except Exception as exc:
        raise UpstreamError() from exc

    try:
        result = json.loads(b"".join(chunks))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise UpstreamError() from exc
    raw_images = result.get("data") if isinstance(result, dict) else None
    if not isinstance(raw_images, list):
        raise UpstreamError()
    images_out: list[dict[str, str]] = []
    for item in raw_images[:count]:
        if not isinstance(item, dict):
            continue
        image_url = item.get("url") or item.get("image_url")
        if not image_url and isinstance(item.get("b64_json"), str):
            encoded = item["b64_json"]
            try:
                base64.b64decode(encoded, validate=True)
            except (ValueError, base64.binascii.Error):
                continue
            image_url = "data:image/png;base64," + encoded
        if not isinstance(image_url, str):
            continue
        if image_url.startswith("data:"):
            try:
                mime, encoded = _parse_image_data_url(image_url)
                base64.b64decode(encoded, validate=True)
                image_url = "data:" + mime + ";base64," + encoded
            except (ValueError, base64.binascii.Error):
                continue
        elif not image_url.startswith("https://"):
            continue
        images_out.append({"url": image_url, "revised_prompt": str(item.get("revised_prompt") or "")[:4000]})
    if not images_out:
        raise UpstreamError()
    return {"ok": True, "images": images_out, "count": len(images_out), "providerId": provider.id, "model": model}


def _parse_image_data_url(value: str) -> tuple[str, str]:
    match = re.fullmatch(r"data:(image/(?:png|jpeg|webp|gif));base64,([A-Za-z0-9+/]*={0,2})", value, flags=re.IGNORECASE)
    if not match:
        raise ValueError("Image attachments must be supported image data URLs.")
    mime, encoded = match.group(1).lower(), match.group(2)
    try:
        base64.b64decode(encoded, validate=True)
    except (ValueError, base64.binascii.Error) as exc:
        raise ValueError("Image attachment data is not valid base64.") from exc
    return mime, encoded


def _gemini_content_parts(content: Any) -> list[dict[str, Any]]:
    parts = content if isinstance(content, list) else [{"type": "text", "text": content}]
    output: list[dict[str, Any]] = []
    for part in parts:
        if part.get("type") == "text":
            output.append({"text": part["text"]})
        elif part.get("type") == "image_url":
            mime, encoded = _parse_image_data_url(part["image_url"]["url"])
            output.append({"inline_data": {"mime_type": mime, "data": encoded}})
    return output


async def call_upstream_stream(
    provider: Provider,
    model: str,
    messages: list[dict[str, Any]],
    *,
    temperature: float,
    max_tokens: int | None,
    response_format: dict[str, Any] | None,
    timeout_seconds: float,
    max_response_bytes: int,
) -> AsyncIterator[str]:
    """Yield text deltas from a provider SSE stream; cancellation closes upstream."""
    try:
        import httpx
    except ImportError as exc:
        raise RuntimeError("httpx is required by the ForgeChat server.") from exc

    url, headers, body = prepare_request(
        provider, model, messages,
        temperature=temperature,
        max_tokens=max_tokens,
        response_format=response_format,
        stream=True,
    )
    size = 0
    try:
        async with httpx.AsyncClient(timeout=timeout_seconds, follow_redirects=False, trust_env=False) as client:
            async with client.stream("POST", url, headers=headers, json=body) as response:
                if response.status_code < 200 or response.status_code >= 300:
                    raise UpstreamError(response.status_code)
                async for line in response.aiter_lines():
                    size += len(line.encode("utf-8")) + 1
                    if size > max_response_bytes:
                        raise UpstreamError(response.status_code)
                    if not line.startswith("data:"):
                        continue
                    data = line[5:].strip()
                    if not data:
                        continue
                    if provider.kind == "openai" and data == "[DONE]":
                        break
                    try:
                        payload = json.loads(data)
                    except json.JSONDecodeError as exc:
                        raise UpstreamError(response.status_code) from exc
                    if provider.kind == "gemini":
                        candidates = payload.get("candidates") or []
                        parts = (((candidates[0] or {}).get("content") or {}).get("parts") or []) if candidates else []
                        text = "".join(str(part.get("text", "")) for part in parts if isinstance(part, dict))
                    else:
                        choices = payload.get("choices") or []
                        delta = (choices[0] or {}).get("delta") if choices else None
                        content = delta.get("content") if isinstance(delta, dict) else None
                        if isinstance(content, list):
                            text = "".join(str(part.get("text", "")) for part in content if isinstance(part, dict))
                        else:
                            text = str(content or "")
                    if text:
                        yield text
    except UpstreamError:
        raise
    except Exception as exc:
        raise UpstreamError() from exc

async def call_upstream(
    provider: Provider,
    model: str,
    messages: list[dict[str, Any]],
    *,
    temperature: float,
    max_tokens: int | None,
    response_format: dict[str, Any] | None,
    timeout_seconds: float,
    max_response_bytes: int,
) -> dict[str, Any]:
    try:
        import httpx
    except ImportError as exc:  # pragma: no cover - exercised only in a broken deployment
        raise RuntimeError("httpx is required by the ForgeChat server.") from exc

    url, headers, body = prepare_request(
        provider, model, messages,
        temperature=temperature,
        max_tokens=max_tokens,
        response_format=response_format,
    )
    try:
        async with httpx.AsyncClient(timeout=timeout_seconds, follow_redirects=False, trust_env=False) as client:
            async with client.stream("POST", url, headers=headers, json=body) as response:
                chunks: list[bytes] = []
                size = 0
                async for chunk in response.aiter_bytes():
                    size += len(chunk)
                    if size > max_response_bytes:
                        raise UpstreamError(response.status_code)
                    chunks.append(chunk)
                if response.status_code < 200 or response.status_code >= 300:
                    raise UpstreamError(response.status_code)
    except UpstreamError:
        raise
    except Exception as exc:
        raise UpstreamError() from exc

    try:
        payload = json.loads(b"".join(chunks))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise UpstreamError(response.status_code) from exc
    if provider.kind == "gemini":
        candidates = payload.get("candidates") or []
        parts = (((candidates[0] or {}).get("content") or {}).get("parts") or []) if candidates else []
        content = "".join(str(part.get("text", "")) for part in parts if isinstance(part, dict))
        usage_raw = payload.get("usageMetadata") or {}
        usage = {
            key: usage_raw[key]
            for key in ("promptTokenCount", "candidatesTokenCount", "totalTokenCount")
            if isinstance(usage_raw.get(key), int)
        }
        returned_model = model
    else:
        choices = payload.get("choices") or []
        message = (choices[0] or {}).get("message") if choices else None
        content_raw = message.get("content") if isinstance(message, dict) else ""
        if isinstance(content_raw, list):
            content = "".join(str(part.get("text", "")) for part in content_raw if isinstance(part, dict))
        else:
            content = str(content_raw or "")
        usage_raw = payload.get("usage") or {}
        usage = {key: usage_raw[key] for key in ("prompt_tokens", "completion_tokens", "total_tokens") if isinstance(usage_raw.get(key), int)}
        returned_model = str(payload.get("model") or model)[:200]
    return {
        "ok": True,
        "content": content,
        "text": content,
        "provider": provider.label,
        "providerId": provider.id,
        "model": returned_model,
        "usage": usage or None,
    }
