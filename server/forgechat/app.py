"""HTTP API for authenticated, server-side ForgeHost chat calls."""

from __future__ import annotations

import asyncio
import html
import json
import os
import re
import secrets
import tempfile
import time
from collections import defaultdict, deque
from dataclasses import replace
from pathlib import Path
from collections.abc import AsyncIterator
from typing import Any, Awaitable, Callable
from urllib.parse import parse_qs, unquote, urlencode, urlsplit

from fastapi import FastAPI, HTTPException, Request, Response
from fastapi.responses import FileResponse, HTMLResponse, JSONResponse, RedirectResponse, StreamingResponse
import httpx

from .access import AccessError, AccessStore
from .auth import create_session, hash_password, read_session_claims, verify_password
from .config import Provider, Settings
from .import_backup import (
    ImportErrorSafe,
    ProviderCandidate,
    _PROVIDER_ID,
    discover_candidates,
    read_forge_settings_bytes,
)
from .providers import UpstreamError, call_image_generation, call_upstream, call_upstream_stream, normalize_image_request, normalize_request
from .tts import LocalTtsError, LocalTtsUnavailable, TtsAudio, call_tts, local_voice_catalog, normalize_tts_request, synthesize_local_tts, tts_engine, voice_catalog
from .transcription import MAX_AUDIO_BYTES, call_transcription, normalize_transcription_request

UpstreamCall = Callable[..., Awaitable[dict[str, Any]]]
UpstreamStreamCall = Callable[..., AsyncIterator[str]]
ImageGenerationCall = Callable[..., Awaitable[dict[str, Any]]]
TtsCall = Callable[..., Awaitable[TtsAudio]]
LocalTtsCall = Callable[..., Awaitable[TtsAudio]]
TranscriptionCall = Callable[..., Awaitable[dict[str, Any]]]
ProviderImportApply = Callable[[list[ProviderCandidate]], Awaitable[list[str]]]
MAX_WEB_IMPORT_BYTES = 32 * 1024 * 1024
MAX_PENDING_IMPORTS = 8
PENDING_IMPORT_SECONDS = 600
_IMPORT_SOCKET_PATH = "/run/forgechat-import/daemon.sock"
_NO_KEY_ISSUE_PREFIX = "no saved API key"


class ImportApplyError(Exception):
    """A safe, user-facing error returned by the provider import helper."""


def _normalize_agent_job(payload: Any) -> dict[str, Any]:
    if not isinstance(payload, dict):
        raise ValueError("Agent job must be an object.")
    allowed = {"id", "script", "cmdPath", "args", "cwd", "timeoutMs", "background", "wait", "label", "description"}
    if set(payload) - allowed:
        raise ValueError("Agent job contains unsupported fields.")
    script = payload.get("script")
    command = payload.get("cmdPath")
    if script is not None:
        if not isinstance(script, str) or not script.strip():
            raise ValueError("script must be a non-empty string no larger than 512 KiB.")
        try:
            script_size = len(script.encode("utf-8"))
        except UnicodeEncodeError as exc:
            raise ValueError("script must be valid UTF-8.") from exc
        if script_size > 512 * 1024:
            raise ValueError("script must be a non-empty string no larger than 512 KiB.")
    elif not isinstance(command, str) or not command.strip() or len(command) > 4096:
        raise ValueError("Provide a script or cmdPath with optional args.")
    args = payload.get("args", [])
    if not isinstance(args, list) or len(args) > 128 or any(not isinstance(arg, str) or len(arg) > 8192 for arg in args):
        raise ValueError("args must be an array of at most 128 strings.")
    cwd = payload.get("cwd")
    if cwd is not None and (not isinstance(cwd, str) or len(cwd) > 4096):
        raise ValueError("cwd must be a path string under the agent workspace.")
    timeout_ms = payload.get("timeoutMs", 120000)
    if not isinstance(timeout_ms, int) or isinstance(timeout_ms, bool) or not 1000 <= timeout_ms <= 1_800_000:
        raise ValueError("timeoutMs must be between 1000 and 1800000.")
    for name in ("background", "wait"):
        if name in payload and not isinstance(payload[name], bool):
            raise ValueError(f"{name} must be a boolean.")
    normalized = dict(payload)
    normalized["id"] = payload.get("id") if isinstance(payload.get("id"), str) and len(payload["id"]) <= 128 else secrets.token_urlsafe(18)
    normalized["timeoutMs"] = timeout_ms
    if normalized.get("background") is True:
        normalized["wait"] = False
    for name, limit in (("label", 200), ("description", 500)):
        value = normalized.get(name)
        if value is not None and (not isinstance(value, str) or len(value) > limit):
            raise ValueError(f"{name} is too long or invalid.")
    return normalized


def _provider_records(candidates: list[ProviderCandidate]) -> list[dict[str, Any]]:
    return [
        {
            "id": candidate.id,
            "label": candidate.label,
            "kind": candidate.kind,
            "base_url": candidate.base_url,
            "default_model": candidate.default_model,
            "models": list(candidate.models),
            "key": candidate.key,
            "issue": candidate.issue,
        }
        for candidate in candidates
    ]


async def _configured_provider_import_apply(candidates: list[ProviderCandidate]) -> list[str]:
    payload = (json.dumps({"version": 1, "providers": _provider_records(candidates)}, separators=(",", ":")) + "\n").encode("utf-8")
    try:
        reader, writer = await asyncio.wait_for(asyncio.open_unix_connection(_IMPORT_SOCKET_PATH), timeout=5)
    except (OSError, asyncio.TimeoutError) as exc:
        raise ImportApplyError("Provider import helper is unavailable.") from exc
    try:
        writer.write(payload)
        await writer.drain()
        line = await asyncio.wait_for(reader.readline(), timeout=30)
    except (OSError, asyncio.TimeoutError) as exc:
        raise ImportApplyError("Provider import helper is unavailable.") from exc
    finally:
        writer.close()
        try:
            await writer.wait_closed()
        except OSError:
            pass
    if not line:
        raise ImportApplyError("Provider import helper returned no response.")
    try:
        response = json.loads(line.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ImportApplyError("Provider import helper returned an invalid response.") from exc
    if not isinstance(response, dict):
        raise ImportApplyError("Provider import helper returned an invalid response.")
    if not response.get("ok"):
        raise ImportApplyError(str(response.get("detail") or "Provider import failed."))
    imported = response.get("imported")
    expected = [candidate.id for candidate in candidates]
    if not isinstance(imported, list) or imported != expected:
        raise ImportApplyError("Provider import helper returned an invalid response.")
    return expected


class LoginLimiter:
    """Small single-process login throttle; reverse-proxy limits are also needed."""

    def __init__(self, window_seconds: int = 900, max_attempts: int = 10):
        self.window_seconds = window_seconds
        self.max_attempts = max_attempts
        self._failures: dict[str, deque[float]] = defaultdict(deque)

    def blocked(self, address: str, now: float | None = None) -> bool:
        current = time.monotonic() if now is None else now
        failures = self._failures[address]
        self._prune(failures, current)
        return len(failures) >= self.max_attempts

    def fail(self, address: str, now: float | None = None) -> None:
        current = time.monotonic() if now is None else now
        failures = self._failures[address]
        self._prune(failures, current)
        failures.append(current)

    def success(self, address: str) -> None:
        self._failures.pop(address, None)

    def _prune(self, failures: deque[float], now: float) -> None:
        while failures and now - failures[0] >= self.window_seconds:
            failures.popleft()


def create_app(
    settings: Settings,
    *,
    upstream_call: UpstreamCall | None = None,
    upstream_stream_call: UpstreamStreamCall | None = None,
    image_generation_call: ImageGenerationCall | None = None,
    tts_call: TtsCall | None = None,
    local_tts_call: LocalTtsCall | None = None,
    transcription_call: TranscriptionCall | None = None,
    provider_import_apply: ProviderImportApply | None = None,
    agent_transport: httpx.AsyncBaseTransport | None = None,
) -> FastAPI:
    app = FastAPI(title="ForgeChat API", docs_url=None, redoc_url=None, openapi_url=None)
    provider_call = upstream_call or _configured_upstream_call
    provider_stream_call = upstream_stream_call or _configured_upstream_stream_call
    image_call = image_generation_call or _configured_image_generation_call
    tts_synthesize = tts_call or _configured_tts_call
    local_tts_synthesize = local_tts_call or synthesize_local_tts
    transcribe_audio = transcription_call or _configured_transcription_call
    import_apply = provider_import_apply or _configured_provider_import_apply
    limiter = LoginLimiter(settings.login_window_seconds, settings.login_max_attempts)
    import_limiter = LoginLimiter(settings.login_window_seconds, 6)
    pending_provider_imports: dict[str, dict[str, Any]] = {}
    ai_limiter = LoginLimiter(settings.ai_rate_window_seconds, settings.ai_rate_max_requests)
    agent_limiter = LoginLimiter(settings.ai_rate_window_seconds, 30)
    agent_slots = asyncio.Semaphore(2)
    upstream_slots = asyncio.Semaphore(settings.ai_max_concurrent_requests)
    local_tts_slots = asyncio.Semaphore(1)
    revoked_sessions: dict[str, int] = {}
    access_tempdir = None
    access_path = settings.access_db
    if access_path is None:
        access_tempdir = tempfile.TemporaryDirectory(prefix="forgechat-access-")
        access_path = Path(access_tempdir.name) / "access.sqlite3"
        app.state.access_tempdir = access_tempdir
    accounts = AccessStore(access_path)
    accounts.ensure_owner(settings.username, settings.password_hash)
    app.state.access_store = accounts

    @app.middleware("http")
    async def no_store_and_errors(request: Request, call_next):
        response = await call_next(request)
        response.headers["Cache-Control"] = "no-store"
        response.headers["X-Content-Type-Options"] = "nosniff"
        if "Referrer-Policy" not in response.headers:
            response.headers["Referrer-Policy"] = "no-referrer"
        return response

    def origin_matches(value: str, *, is_referer: bool = False) -> bool:
        try:
            candidate = urlsplit(value)
            expected = urlsplit(settings.public_origin)
            if (
                candidate.scheme.lower() != expected.scheme.lower()
                or not candidate.hostname
                or not expected.hostname
                or candidate.hostname.lower() != expected.hostname.lower()
                or candidate.username is not None
                or candidate.password is not None
                or (not is_referer and (candidate.path not in {"", "/"} or candidate.query or candidate.fragment))
            ):
                return False
            candidate_port = candidate.port or (443 if candidate.scheme.lower() == "https" else 80)
            expected_port = expected.port or (443 if expected.scheme.lower() == "https" else 80)
            return candidate_port == expected_port
        except ValueError:
            return False

    def check_origin(request: Request) -> None:
        origin = request.headers.get("origin", "").strip()
        same_origin_site = request.headers.get("sec-fetch-site", "").lower() == "same-origin"
        referer_matches = origin_matches(request.headers.get("referer", ""), is_referer=True)
        if origin and origin_matches(origin):
            return
        if (not origin or origin.lower() == "null") and (referer_matches or same_origin_site):
            return
        raise HTTPException(status_code=403, detail="Request origin is not allowed.")

    def current_session(request: Request) -> dict[str, Any] | None:
        now = int(time.time())
        for session_id, expires_at in list(revoked_sessions.items()):
            if expires_at <= now:
                revoked_sessions.pop(session_id, None)
        claims = read_session_claims(request.cookies.get(settings.cookie_name), settings.session_secret, now=now)
        if claims is None or claims["session_id"] in revoked_sessions:
            return None
        account = accounts.get_user(claims["username"])
        if (account is None or not account["enabled"]
                or claims["session_version"] != account["session_version"]):
            return None
        return claims

    def current_user(request: Request) -> str | None:
        claims = current_session(request)
        return claims["username"] if claims else None

    def require_owner(request: Request) -> str:
        username = require_user(request)
        account = accounts.get_user(username)
        if account is None or account["role"] != "owner":
            raise HTTPException(status_code=403, detail="Owner permission required.")
        return username

    def require_app_access(request: Request) -> str:
        username = require_user(request)
        account = accounts.get_user(username)
        if account and account["role"] == "owner":
            return username
        app_id = request.headers.get("x-forgechat-app", "").strip()
        root = settings.app_dir.resolve()
        if not app_id:
            # Older ForgeChat exports predate the app-ID header. Preserve them for
            # users with at least one live app assignment, while new exports get
            # exact per-app checks below.
            for allowed_id in accounts.user_app_ids(username):
                candidate = root / (allowed_id + ".html")
                if not candidate.is_symlink() and candidate.is_file():
                    return username
            raise HTTPException(status_code=403, detail="This app is not enabled for your account.")
        try:
            accounts.validate_app_id(app_id)
        except AccessError:
            raise HTTPException(status_code=403, detail="This app is not enabled for your account.") from None
        if not accounts.user_can_access(username, app_id):
            raise HTTPException(status_code=403, detail="This app is not enabled for your account.")
        target = root / (app_id + ".html")
        if target.is_symlink() or not target.is_file():
            raise HTTPException(status_code=403, detail="This app is not enabled for your account.")
        return username

    def app_provider_settings(request: Request) -> tuple[Provider, ...]:
        app_id = request.headers.get("x-forgechat-app", "").strip()
        available = _available_providers(settings.providers)
        if not app_id:
            username = current_user(request)
            account = accounts.get_user(username) if username else None
            if account is None or account.get("role") == "owner":
                return tuple(available)
            app_ids = accounts.user_app_ids(username)
            if not app_ids:
                return tuple(available)
            available_by_id = {provider.id: provider for provider in available}
            allowed_sets = []
            preferred_defaults = []
            for allowed_app_id in app_ids:
                saved = accounts.app_provider_settings(allowed_app_id)
                allowed_sets.append(set(saved["providerIds"]) if saved else set(available_by_id))
                if saved:
                    preferred_defaults.append(saved["defaultProviderId"])
            allowed_ids = set.intersection(*allowed_sets) if allowed_sets else set(available_by_id)
            selected = [provider for provider in available if provider.id in allowed_ids]
            if not selected:
                raise HTTPException(status_code=503, detail="No common providers are available for this account's app access.")
            preferred = next((provider_id for provider_id in preferred_defaults if provider_id in allowed_ids), "")
            if preferred:
                selected.sort(key=lambda provider: provider.id != preferred)
            return tuple(selected)
        try:
            accounts.validate_app_id(app_id)
        except AccessError:
            raise HTTPException(status_code=403, detail="This app is not enabled for your account.") from None
        configured = accounts.app_provider_settings(app_id)
        if configured is None:
            return tuple(available)
        by_id = {provider.id: provider for provider in available}
        selected = [by_id[provider_id] for provider_id in configured["providerIds"] if provider_id in by_id]
        if not selected:
            raise HTTPException(status_code=503, detail="No providers selected for this app are currently available on the ForgeChat server.")
        default_id = configured["defaultProviderId"]
        if default_id in {provider.id for provider in selected}:
            selected.sort(key=lambda provider: provider.id != default_id)
        return tuple(selected)

    def settings_for_app(request: Request) -> Settings:
        return replace(settings, providers=app_provider_settings(request))

    def require_agent_access(request: Request) -> str:
        username = require_user(request)
        account = accounts.get_user(username)
        if account and account["role"] == "owner":
            return username
        if accounts.user_can_access_agent(username):
            return username
        raise HTTPException(status_code=403, detail="Backend agent access is not enabled for this account.")

    async def call_agent_json(method: str, path: str, *, payload: dict[str, Any] | None = None) -> tuple[int, dict[str, Any]]:
        if not settings.agent_enabled:
            raise HTTPException(status_code=503, detail="The backend agent is not configured.")
        timeout = httpx.Timeout(settings.agent_timeout_seconds, connect=4.0)
        try:
            async with httpx.AsyncClient(
                auth=httpx.BasicAuth(settings.agent_username, settings.agent_password),
                timeout=timeout,
                transport=agent_transport,
            ) as client:
                response = await client.request(method, settings.agent_url + path, json=payload)
        except httpx.TimeoutException as exc:
            raise HTTPException(status_code=504, detail="The backend agent timed out.") from exc
        except httpx.HTTPError as exc:
            raise HTTPException(status_code=503, detail="The backend agent is unavailable.") from exc
        if response.status_code == 401:
            raise HTTPException(status_code=502, detail="Backend agent authentication failed.")
        try:
            result = response.json()
        except (ValueError, UnicodeDecodeError) as exc:
            raise HTTPException(status_code=502, detail="The backend agent returned an invalid response.") from exc
        if not isinstance(result, dict):
            raise HTTPException(status_code=502, detail="The backend agent returned an invalid response.")
        return response.status_code, result

    async def open_agent_stream(method: str, path: str, *, params: dict[str, str] | None = None, headers: dict[str, str] | None = None, content=None):
        if not settings.agent_enabled:
            raise HTTPException(status_code=503, detail="The backend agent is not configured.")
        client = httpx.AsyncClient(
            auth=httpx.BasicAuth(settings.agent_username, settings.agent_password),
            timeout=httpx.Timeout(settings.agent_timeout_seconds, connect=4.0),
            transport=agent_transport,
        )
        try:
            request_to_agent = client.build_request(
                method,
                settings.agent_url + path,
                params=params,
                headers=headers,
                content=content,
            )
            response = await client.send(request_to_agent, stream=True)
        except httpx.TimeoutException as exc:
            await client.aclose()
            raise HTTPException(status_code=504, detail="The backend agent timed out.") from exc
        except httpx.HTTPError as exc:
            await client.aclose()
            raise HTTPException(status_code=503, detail="The backend agent is unavailable.") from exc
        if response.status_code == 401:
            await response.aclose()
            await client.aclose()
            raise HTTPException(status_code=502, detail="Backend agent authentication failed.")
        return client, response

    def set_session_cookie(target: Response, username: str, session_version: int, lifetime: int) -> None:
        expires_at = int(time.time()) + lifetime
        token = create_session(username, settings.session_secret, expires_at, session_version=session_version)
        target.set_cookie(
            key=settings.cookie_name,
            value=token,
            max_age=lifetime,
            expires=expires_at,
            path=settings.base_path or "/",
            secure=settings.public_origin.startswith("https://"),
            httponly=True,
            samesite="strict",
        )

    def require_user(request: Request) -> str:
        username = current_user(request)
        if username is None:
            raise HTTPException(status_code=401, detail="Login required.")
        return username

    def require_session(request: Request) -> dict[str, Any]:
        claims = current_session(request)
        if claims is None:
            raise HTTPException(status_code=401, detail="Login required.")
        return claims

    async def read_bytes_limited(request: Request, maximum: int) -> bytes:
        length = request.headers.get("content-length")
        if length:
            try:
                parsed_length = int(length)
                if parsed_length < 0:
                    raise ValueError
                if parsed_length > maximum:
                    raise HTTPException(status_code=413, detail="Backup ZIP exceeds the upload size limit.")
            except ValueError as exc:
                raise HTTPException(status_code=400, detail="Invalid Content-Length.") from exc
        data = bytearray()
        async for chunk in request.stream():
            data.extend(chunk)
            if len(data) > maximum:
                raise HTTPException(status_code=413, detail="Backup ZIP exceeds the upload size limit.")
        return bytes(data)

    def expire_pending_import(token: str) -> None:
        pending = pending_provider_imports.get(token)
        if pending is not None and pending["expires_at"] <= time.monotonic():
            pending_provider_imports.pop(token, None)

    def prune_pending_imports(now: float | None = None) -> None:
        current = time.monotonic() if now is None else now
        for token, pending in list(pending_provider_imports.items()):
            if pending["expires_at"] <= current:
                pending_provider_imports.pop(token, None)

    async def read_json_limited(request: Request, maximum: int | None = None) -> Any:
        max_bytes = settings.max_request_bytes if maximum is None else maximum
        length = request.headers.get("content-length")
        if length:
            try:
                if int(length) > max_bytes:
                    raise HTTPException(status_code=413, detail="Request body is too large.")
            except ValueError as exc:
                raise HTTPException(status_code=400, detail="Invalid Content-Length.") from exc
        data = bytearray()
        async for chunk in request.stream():
            data.extend(chunk)
            if len(data) > max_bytes:
                raise HTTPException(status_code=413, detail="Request body is too large.")
        try:
            content_type = request.headers.get("content-type", "").split(";", 1)[0].strip().lower()
            if content_type == "application/x-www-form-urlencoded":
                fields = parse_qs(data.decode("utf-8"), keep_blank_values=True, max_num_fields=10)
                return {key: values[-1] for key, values in fields.items()}
            return json.loads(data)
        except (json.JSONDecodeError, UnicodeDecodeError, ValueError) as exc:
            raise HTTPException(status_code=400, detail="Request body must be valid JSON or form data.") from exc

    @app.get("/healthz")
    async def healthz(request: Request):
        require_user(request)
        return {"ok": True}

    def default_app_path() -> str:
        return settings.base_path + "/apps/" if settings.base_path else "/apps/"

    def safe_next(value: str | None) -> str:
        fallback = default_app_path()
        if not value or len(value) > 1024 or "\\" in value or any(ord(ch) < 32 for ch in value):
            return fallback
        parsed = urlsplit(unquote(value))
        prefix = (settings.base_path or "") + "/apps"
        allowed_app = re.fullmatch(re.escape(prefix) + r"/[A-Za-z0-9][A-Za-z0-9_-]{0,79}(?:\.html)?", parsed.path)
        allowed_pages = {prefix + "/", (settings.base_path or "") + "/publish", (settings.base_path or "") + "/provider-import"}
        if parsed.scheme or parsed.netloc or (parsed.path not in allowed_pages and not allowed_app):
            return fallback
        return parsed.path

    def login_url(next_path: str, *, invalid: bool = False) -> str:
        path = settings.base_path + "/login" if settings.base_path else "/login"
        params = {"next": safe_next(next_path)}
        if invalid:
            params["error"] = "1"
        return path + "?" + urlencode(params)

    def login_page(next_path: str, *, invalid: bool = False) -> str:
        action = (settings.base_path + "/api/v1/auth/login" if settings.base_path else "/api/v1/auth/login")
        message = '<p class="error">Login failed. Check your username and password.</p>' if invalid else ""
        page = """<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>ForgeChat sign in</title><style>body{margin:0;min-height:100vh;display:grid;place-items:center;background:#10131a;color:#f3f4f6;font:16px system-ui,sans-serif}.card{width:min(22rem,calc(100% - 2rem));padding:1.5rem;border:1px solid #303746;border-radius:1rem;background:#191e28;box-shadow:0 1rem 3rem #0005}h1{font-size:1.35rem;margin:0 0 1rem}label{display:block;margin:.8rem 0 .35rem}input[type=text],input[type=password]{box-sizing:border-box;width:100%;padding:.75rem;border:1px solid #475267;border-radius:.5rem;background:#0e1219;color:inherit;font:inherit}button{width:100%;padding:.8rem;margin-top:1rem;border:0;border-radius:.5rem;background:#6d8cff;color:#07101f;font:inherit;font-weight:700}.remember{display:flex;gap:.5rem;align-items:center;margin-top:1rem}.error{color:#ff9c9c}</style></head><body><main class="card"><h1>Sign in to ForgeChat</h1>""" + message + """<form method="post" action="__ACTION__" autocomplete="on"><input type="hidden" name="next" value="__NEXT__"><label for="username">Username</label><input id="username" name="username" type="text" autocomplete="username" autocapitalize="none" required autofocus><label for="password">Password</label><input id="password" name="password" type="password" autocomplete="current-password" required><label class="remember"><input name="remember" type="checkbox" value="1"> Remember me on this device</label><button type="submit">Sign in</button></form></main></body></html>"""
        return page.replace("__ACTION__", html.escape(action, quote=True)).replace("__NEXT__", html.escape(next_path, quote=True))

    def page_login_redirect(request: Request):
        public_path = settings.base_path + request.url.path if settings.base_path else request.url.path
        if request.url.query:
            public_path += "?" + request.url.query
        return RedirectResponse(login_url(public_path), status_code=303)

    @app.get("/")
    async def home(request: Request):
        if current_user(request) is None:
            return RedirectResponse(login_url(default_app_path()), status_code=303)
        return RedirectResponse(default_app_path(), status_code=303)

    @app.get("/login", response_class=HTMLResponse)
    async def login_form(request: Request):
        destination = safe_next(request.query_params.get("next"))
        if current_user(request) is not None:
            return RedirectResponse(destination, status_code=303)
        page = login_page(destination, invalid=request.query_params.get("error") == "1")
        return HTMLResponse(page, headers={
            "Cache-Control": "no-store",
            "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'",
            "X-Frame-Options": "DENY",
            "Referrer-Policy": "same-origin",
        })

    @app.get("/apps/", response_class=HTMLResponse)
    async def app_index(request: Request):
        username = current_user(request)
        if username is None:
            return page_login_redirect(request)
        account = accounts.get_user(username) or {}
        is_owner = account.get("role") == "owner"
        prefix = settings.base_path or ""
        root = settings.app_dir.resolve()
        users = [user for user in accounts.list_users() if user["role"] == "user" and user["enabled"]] if is_owner else []
        cards: list[str] = []
        if root.is_dir():
            for candidate in sorted(root.glob("*.html"), key=lambda path: path.name.casefold()):
                try:
                    if candidate.is_symlink():
                        continue
                    resolved = candidate.resolve(strict=True)
                    if not resolved.is_relative_to(root) or not resolved.is_file() or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]{0,79}\.html", candidate.name):
                        continue
                    app_id = candidate.stem
                    if not is_owner and not accounts.user_can_access(username, app_id):
                        continue
                    info = resolved.stat()
                    allowed = accounts.allowed_usernames(app_id) if is_owner else []
                    href = html.escape(prefix + "/apps/" + app_id, quote=True)
                    access = ""
                    if is_owner:
                        checks = "".join(
                            '<label class="user-check"><input type="checkbox" value="' + html.escape(user["username"], quote=True) + '"' + (" checked" if user["username"].casefold() in {name.casefold() for name in allowed} else "") + '><span>' + html.escape(user["username"]) + '</span></label>'
                            for user in users
                        )
                        if not checks:
                            checks = '<p class="muted">Create an app user first. With no users selected, this app remains owner-only.</p>'
                        access = '<details class="access-panel"><summary>App access <span>' + str(len(allowed)) + ' user' + ('' if len(allowed) == 1 else 's') + '</span></summary><div class="access-body"><p>Only allowlisted users can open this app. The owner always retains access.</p><div class="user-checks">' + checks + '</div><button class="save-access" data-app="' + html.escape(app_id, quote=True) + '">Save access</button><span class="inline-status" aria-live="polite"></span></div></details><button class="delete-app" data-app="' + html.escape(app_id, quote=True) + '" data-title="' + html.escape(app_id, quote=True) + '">Delete app</button>'
                    cards.append('<article class="app-card" data-card="' + html.escape(app_id, quote=True) + '"><div class="app-card-top"><div class="app-icon">' + html.escape(app_id[:1].upper()) + '</div><div class="app-heading"><span class="eyebrow">PRIVATE APP</span><h2>' + html.escape(app_id) + '</h2><p>' + format(info.st_size, ',') + ' bytes · updated ' + time.strftime('%b %d, %Y', time.localtime(info.st_mtime)) + '</p></div><a class="open-app" href="' + href + '">Open app <span aria-hidden="true">↗</span></a></div>' + access + '</article>')
                except OSError:
                    continue
        if cards:
            app_content = '<section class="app-grid" id="app-grid">' + "".join(cards) + '</section>'
        elif is_owner:
            app_content = '<section class="empty"><div class="empty-icon">✦</div><h2>Your private app space is ready</h2><p>Publish a ForgeChat export to make it available here. Apps start owner-only; grant access to selected users when you are ready.</p><a class="primary" href="' + html.escape(prefix + "/publish", quote=True) + '">Publish your first app</a></section>'
        else:
            app_content = '<section class="empty"><div class="empty-icon">⌂</div><h2>No apps assigned yet</h2><p>Ask the ForgeChat owner to add your account to an app’s allow-list.</p></section>'
        owner_links = ('<a class="nav-link" href="' + html.escape(prefix + "/publish", quote=True) + '">Publish app</a><a class="nav-link" href="' + html.escape(prefix + "/provider-import", quote=True) + '">Providers</a><a class="nav-link" href="' + html.escape(prefix + "/users", quote=True) + '">Users &amp; passwords</a>') if is_owner else ''
        total_label = str(len(cards)) + (' private app' if len(cards) == 1 else ' private apps')
        logout = html.escape(prefix + "/api/v1/auth/logout", quote=True)
        page = '''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>ForgeChat · Apps</title><style>:root{color-scheme:dark;--bg:#0b1020;--panel:#121a2c;--line:#26334b;--text:#edf2ff;--muted:#9aa8bf;--accent:#8b9cff;--mint:#72e0c0}*{box-sizing:border-box}body{margin:0;background:radial-gradient(ellipse at 20% -10%,#26366a 0,transparent 44%),linear-gradient(160deg,#0b1020,#111827 55%,#0a1420);color:var(--text);font:15px/1.5 system-ui,-apple-system,Segoe UI,sans-serif;min-height:100vh}.shell{width:min(1120px,calc(100% - 36px));margin:0 auto;padding:24px 0 64px}.topbar{display:flex;align-items:center;justify-content:space-between;gap:16px;padding:8px 0 32px}.brand{display:flex;align-items:center;gap:11px;color:var(--text);text-decoration:none;font-weight:750;letter-spacing:.02em}.brand-mark{display:grid;place-items:center;width:38px;height:38px;border:1px solid #45558b;border-radius:13px;background:linear-gradient(135deg,#596deb,#8a6bfa);box-shadow:0 8px 24px #5366eb44;font-size:18px}.account-nav{display:flex;align-items:center;justify-content:flex-end;flex-wrap:wrap;gap:8px}.nav-link,.logout{border:1px solid #34415a;border-radius:999px;padding:8px 13px;background:#10182a;color:#dce5ff;text-decoration:none;font:inherit}.nav-link:hover,.logout:hover{border-color:#7587ca;background:#1a2540}.logout{cursor:pointer}.hero{display:flex;align-items:flex-end;justify-content:space-between;gap:24px;margin:10px 0 24px}.eyebrow{color:var(--mint);font-size:11px;font-weight:800;letter-spacing:.16em}.hero h1{font-size:clamp(32px,5vw,52px);line-height:1.05;letter-spacing:-.04em;margin:7px 0 8px}.hero p{color:var(--muted);margin:0}.hero-stat{padding:12px 16px;border:1px solid #34415a;background:#10182a;border-radius:14px;color:#c8d4ef;white-space:nowrap}.app-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,440px),1fr));gap:16px}.app-card,.empty{border:1px solid var(--line);border-radius:20px;background:linear-gradient(145deg,#141e32ee,#101727f5);box-shadow:0 18px 50px #0003}.app-card{padding:20px}.app-card-top{display:flex;align-items:center;gap:14px;min-width:0}.app-icon{flex:none;width:52px;height:52px;display:grid;place-items:center;border-radius:17px;background:linear-gradient(145deg,#253b70,#392f65);border:1px solid #4e6091;color:#dce7ff;font-size:23px;font-weight:800}.app-heading{min-width:0;flex:1}.app-heading .eyebrow{font-size:10px}.app-heading h2{margin:1px 0 1px;font-size:21px;overflow-wrap:anywhere}.app-heading p{margin:0;color:var(--muted);font-size:12px}.open-app,.primary,.save-access{display:inline-flex;align-items:center;justify-content:center;gap:8px;border:0;border-radius:11px;padding:10px 14px;background:linear-gradient(135deg,#8295ff,#9c7dff);color:#0c1020;text-decoration:none;font-weight:750;white-space:nowrap}.open-app:hover,.primary:hover,.save-access:hover{filter:brightness(1.08)}.access-panel{margin-top:18px;border-top:1px solid #293650;padding-top:13px}.access-panel summary{cursor:pointer;display:flex;justify-content:space-between;align-items:center;font-weight:700}.access-panel summary span{font-size:12px;color:#a9b8d3;font-weight:500}.access-body p,.muted{font-size:13px;color:var(--muted)}.user-checks{display:flex;flex-wrap:wrap;gap:8px;margin:12px 0}.user-check{display:flex;align-items:center;gap:7px;padding:7px 10px;border:1px solid #33415d;border-radius:999px;background:#0e1627;color:#d9e2f6;font-size:13px}.user-check input{accent-color:#8b9cff}.save-access{padding:8px 11px;font-size:13px;cursor:pointer}.inline-status{margin-left:9px;color:var(--mint);font-size:12px}.delete-app{margin-top:14px;background:transparent;color:#ffa5ae;border:1px solid #69404e;border-radius:10px;padding:8px 11px;font:inherit;font-size:13px;cursor:pointer}.delete-app:hover{background:#3b202c;border-color:#b6556b}.empty{padding:48px 24px;text-align:center}.empty-icon{display:grid;place-items:center;width:58px;height:58px;margin:0 auto 14px;border-radius:20px;background:#1d2a4b;color:#9fb0ff;font-size:28px}.empty h2{margin:0 0 7px}.empty p{max-width:580px;margin:0 auto 18px;color:var(--muted)}.primary{font-size:14px}.footer-note{margin-top:28px;color:#74829b;font-size:12px;text-align:center}.toast{position:fixed;bottom:18px;left:50%;transform:translateX(-50%);padding:10px 16px;border:1px solid #435576;border-radius:12px;background:#172238;color:#e6edff;box-shadow:0 10px 30px #0006;display:none}.toast.show{display:block}@media(max-width:680px){.shell{width:min(100% - 24px,560px);padding-top:14px}.topbar{align-items:flex-start;padding-bottom:22px}.account-nav{gap:6px}.nav-link,.logout{font-size:12px;padding:7px 10px}.hero{display:block}.hero-stat{display:inline-block;margin-top:14px}.app-card{padding:16px}.app-card-top{flex-wrap:wrap}.open-app{margin-left:auto}.empty{padding:36px 18px}}@media(max-width:420px){.brand span:last-child{display:none}.open-app{width:100%}.app-heading h2{font-size:19px}}</style></head><body><main class="shell"><header class="topbar"><a class="brand" href="__APPS__"><span class="brand-mark">F</span><span>ForgeChat</span></a><nav class="account-nav">__OWNER_LINKS__<a class="nav-link" href="__ACCOUNT__">Account</a><form method="post" action="__LOGOUT__"><button class="logout" type="submit">Sign out</button></form></nav></header><section class="hero"><div><span class="eyebrow">PRIVATE WORKSPACE · __ROLE__</span><h1>Your apps</h1><p>Open the apps shared with your account. Every page remains behind sign-in.</p></div><div class="hero-stat">__APP_COUNT__</div></section>__APP_CONTENT__<p class="footer-note">Signed in as __USERNAME__ · app access is controlled by the workspace owner.</p></main><div id="toast" class="toast" role="status" aria-live="polite"></div><script>(function(){var toast=document.getElementById('toast'),timer;function note(text){toast.textContent=text;toast.classList.add('show');clearTimeout(timer);timer=setTimeout(function(){toast.classList.remove('show');},2600);}var deleteApi=__DELETE_API__,accessApi=__ACCESS_API__;document.querySelectorAll('.delete-app').forEach(function(button){button.addEventListener('click',async function(){var id=button.dataset.app;if(!window.confirm('Delete “'+button.dataset.title+'”? This permanently removes the hosted HTML and its app access list.'))return;button.disabled=true;try{var response=await fetch(deleteApi+'/'+encodeURIComponent(id),{method:'DELETE',credentials:'same-origin',headers:{'Content-Type':'application/json'}}),data=await response.json().catch(function(){return {};});if(!response.ok)throw new Error(data.detail||'Could not delete app.');var card=button.closest('[data-card]');if(card)card.remove();note('App deleted.');if(!document.querySelector('[data-card]'))location.reload();}catch(error){button.disabled=false;note(String(error&&error.message||error));}});});document.querySelectorAll('.save-access').forEach(function(button){button.addEventListener('click',async function(){var card=button.closest('.app-card'),checks=card.querySelectorAll('.user-checks input:checked'),users=Array.prototype.map.call(checks,function(input){return input.value;}),status=button.parentElement.querySelector('.inline-status');button.disabled=true;status.textContent='Saving…';try{var response=await fetch(accessApi+'/'+encodeURIComponent(button.dataset.app)+'/access',{method:'PUT',credentials:'same-origin',headers:{'Content-Type':'application/json'},body:JSON.stringify({users:users})}),data=await response.json().catch(function(){return {};});if(!response.ok)throw new Error(data.detail||'Could not save app access.');status.textContent='Saved';note(users.length?'Access list updated.':'App is owner-only.');}catch(error){status.textContent='';note(String(error&&error.message||error));}finally{button.disabled=false;}});});})();</script></body></html>'''
        page = page.replace("__APPS__", html.escape(prefix + "/apps/", quote=True))
        page = page.replace("__OWNER_LINKS__", owner_links).replace("__ACCOUNT__", html.escape(prefix + "/account", quote=True))
        page = page.replace("__LOGOUT__", logout).replace("__ROLE__", "OWNER" if is_owner else "APP USER")
        page = page.replace("__APP_COUNT__", html.escape(total_label)).replace("__USERNAME__", html.escape(username))
        page = page.replace("__APP_CONTENT__", app_content)
        page = page.replace("__DELETE_API__", json.dumps(prefix + "/api/v1/admin/apps")).replace("__ACCESS_API__", json.dumps(prefix + "/api/v1/admin/apps"))
        return HTMLResponse(page, headers={
            "Cache-Control": "no-store",
            "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'self'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'",
            "X-Frame-Options": "DENY",
            "X-Content-Type-Options": "nosniff",
            "Referrer-Policy": "same-origin",
        })

    @app.get("/users", response_class=HTMLResponse)
    async def users_page(request: Request):
        if current_user(request) is None:
            return page_login_redirect(request)
        require_owner(request)
        prefix = settings.base_path or ""
        rows = []
        for user in accounts.list_users():
            name = html.escape(user["username"])
            if user["role"] == "owner":
                actions = '<span class="owner-note">Owner · manage password in Account</span>'
            else:
                state = "Enabled" if user["enabled"] else "Disabled"
                toggle_text = "Disable" if user["enabled"] else "Enable"
                agent_allowed = bool(user.get("agent_access"))
                agent_action = '<button class="agent-access" data-user="' + html.escape(user["username"], quote=True) + '" data-allowed="' + ("true" if agent_allowed else "false") + '">' + ("Revoke agent access" if agent_allowed else "Allow backend agent") + '</button>'
                actions = '<span class="status ' + ("enabled" if user["enabled"] else "disabled") + '">' + state + '</span><button class="toggle" data-user="' + html.escape(user["username"], quote=True) + '" data-enabled="' + ("false" if user["enabled"] else "true") + '">' + toggle_text + '</button>' + agent_action + '<details class="reset"><summary>Set password</summary><form class="reset-form" data-user="' + html.escape(user["username"], quote=True) + '"><input type="password" name="password" autocomplete="new-password" minlength="9" placeholder="New password (9+ chars)" required><button>Update</button></form></details><button class="remove" data-user="' + html.escape(user["username"], quote=True) + '">Delete</button>'
            rows.append('<tr><td><strong>' + name + '</strong><small>' + ("Owner account" if user["role"] == "owner" else "App user") + '</small></td><td>' + actions + '</td></tr>')
        page = '''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>ForgeChat · Users</title><style>:root{color-scheme:dark;--bg:#0b1020;--line:#26334b;--text:#edf2ff;--muted:#9aa8bf;--mint:#72e0c0}*{box-sizing:border-box}body{margin:0;min-height:100vh;background:radial-gradient(ellipse at 20% -10%,#26366a,transparent 42%),#0b1020;color:var(--text);font:15px/1.5 system-ui,sans-serif}.shell{width:min(940px,calc(100% - 28px));margin:auto;padding:28px 0 60px}.top{display:flex;justify-content:space-between;align-items:center;gap:12px;margin-bottom:30px}.brand{color:var(--text);font-weight:800;text-decoration:none}.top a:last-child{color:#b9c6ff}.hero h1{font-size:clamp(30px,5vw,44px);letter-spacing:-.04em;margin:4px 0}.hero p{color:var(--muted);margin-top:0}.panel{margin-top:22px;padding:22px;border:1px solid var(--line);border-radius:18px;background:#121a2ceb;box-shadow:0 16px 45px #0003}.panel h2{margin:0 0 4px}.sub{color:var(--muted);font-size:13px}.create{display:grid;grid-template-columns:1fr 1fr auto;gap:10px;margin-top:16px}.create input,.reset input{min-width:0;padding:11px;border:1px solid #3a4965;border-radius:10px;background:#0c1424;color:var(--text);font:inherit}.create button,.reset button,.toggle,.agent-access,.remove{padding:9px 13px;border-radius:10px;border:1px solid #485a84;background:#29385c;color:#eef2ff;font:inherit;cursor:pointer}.create button{background:linear-gradient(135deg,#8295ff,#9c7dff);border:0;color:#0c1020;font-weight:750}.table-wrap{overflow:auto;margin-top:18px}table{width:100%;border-collapse:collapse;min-width:600px}th,td{text-align:left;padding:13px 10px;border-bottom:1px solid #26334b;vertical-align:middle}th{font-size:11px;color:#a9b8d3;text-transform:uppercase;letter-spacing:.12em}td:first-child{width:28%}td small{display:block;color:var(--muted);font-size:12px}.status{display:inline-block;padding:3px 9px;border-radius:999px;font-size:12px;margin-right:8px}.enabled{background:#143b36;color:#88e9ca}.disabled{background:#432532;color:#ffabb4}.owner-note{color:#b7c5e1;font-size:13px}.toggle{margin-right:7px;font-size:12px}.remove{background:transparent;border-color:#69404e;color:#ffa5ae;font-size:12px}.reset{display:inline-block;margin-right:7px}.reset summary{display:inline-block;cursor:pointer;color:#dbe3f5;border:1px solid #3c4b68;border-radius:9px;padding:7px 10px;font-size:12px}.reset-form{display:flex;gap:7px;margin-top:8px}.reset input{width:210px;font-size:12px}.reset button{font-size:12px;padding:7px 10px}.status-line{min-height:20px;color:var(--mint);font-size:13px;margin-top:12px}.toast{position:fixed;bottom:18px;left:50%;transform:translateX(-50%);background:#1b2840;border:1px solid #415675;border-radius:12px;padding:10px 16px;display:none}.toast.show{display:block}@media(max-width:680px){.create{grid-template-columns:1fr}.panel{padding:17px}.top{align-items:flex-start}}</style></head><body><main class="shell"><header class="top"><a class="brand" href="__APPS__">← ForgeChat workspace</a><a href="__ACCOUNT__">Account settings</a></header><section class="hero"><span style="color:var(--mint);font-size:11px;font-weight:800;letter-spacing:.16em">OWNER CONTROLS</span><h1>Users &amp; passwords</h1><p>Create accounts once, then grant access to individual apps from the apps page. New users start with no app access.</p></section><section class="panel"><h2>Add an app user</h2><p class="sub">Use a unique username and a strong temporary password (at least 9 characters). Share it privately, never through this page.</p><form class="create" id="create-user"><input name="username" autocomplete="off" autocapitalize="none" minlength="1" maxlength="64" pattern="[A-Za-z0-9][A-Za-z0-9_.-]{0,63}" placeholder="Username" required><input name="password" type="password" autocomplete="new-password" minlength="9" placeholder="Initial password" required><button>Create user</button></form><div id="status" class="status-line" role="status" aria-live="polite"></div></section><section class="panel"><h2>Global accounts</h2><p class="sub">Password resets invalidate existing sessions. Disabling an account blocks sign-in, app access, and agent commands. Backend-agent access is a separate grant for trusted users who may execute commands in the isolated Linux container.</p><div class="table-wrap"><table><thead><tr><th>Account</th><th>Permissions &amp; actions</th></tr></thead><tbody>__ROWS__</tbody></table></div></section></main><div class="toast" id="toast" role="status" aria-live="polite"></div><script>(function(){var api=__API__,status=document.getElementById('status'),toast=document.getElementById('toast');function notify(s){toast.textContent=s;toast.classList.add('show');setTimeout(function(){toast.classList.remove('show');},2400);}async function send(url,method,body){var response=await fetch(url,{method:method,credentials:'same-origin',headers:{'Content-Type':'application/json'},body:body?JSON.stringify(body):undefined}),data=await response.json().catch(function(){return {};});if(!response.ok)throw new Error(data.detail||'Request failed.');return data;}document.getElementById('create-user').addEventListener('submit',async function(e){e.preventDefault();var form=e.currentTarget;status.textContent='Creating account…';try{await send(api,'POST',{username:form.elements.username.value.trim(),password:form.elements.password.value});status.textContent='Account created. Add the user to specific apps from the Apps page.';form.reset();setTimeout(function(){location.reload();},650);}catch(error){status.textContent=String(error&&error.message||error);}});document.querySelectorAll('.toggle').forEach(function(button){button.addEventListener('click',async function(){button.disabled=true;try{await send(api+'/'+encodeURIComponent(button.dataset.user),'PATCH',{enabled:button.dataset.enabled==='true'});notify('Account status updated.');location.reload();}catch(error){button.disabled=false;notify(String(error&&error.message||error));}});});document.querySelectorAll('.reset-form').forEach(function(form){form.addEventListener('submit',async function(e){e.preventDefault();var password=form.elements.password.value;if(!window.confirm('Reset the password for '+form.dataset.user+'? Their current sessions will end.'))return;try{await send(api+'/'+encodeURIComponent(form.dataset.user)+'/password','POST',{password:password});form.reset();notify('Password updated; existing sessions were revoked.');}catch(error){notify(String(error&&error.message||error));}});});document.querySelectorAll('.agent-access').forEach(function(button){button.addEventListener('click',async function(){var allowed=button.dataset.allowed!=='true';if(allowed&&!window.confirm('Allow '+button.dataset.user+' to run commands in the isolated backend agent?'))return;button.disabled=true;try{await send(api+'/'+encodeURIComponent(button.dataset.user)+'/agent-access','PUT',{allowed:allowed});notify(allowed?'Backend agent access granted.':'Backend agent access revoked.');location.reload();}catch(error){button.disabled=false;notify(String(error&&error.message||error));}});});document.querySelectorAll('.remove').forEach(function(button){button.addEventListener('click',async function(){if(!window.confirm('Delete user '+button.dataset.user+'? This also removes all of their app access.'))return;try{await send(api+'/'+encodeURIComponent(button.dataset.user),'DELETE');notify('User deleted.');location.reload();}catch(error){notify(String(error&&error.message||error));}});});})();</script></body></html>'''
        page = page.replace("__APPS__", html.escape(prefix + "/apps/", quote=True)).replace("__ACCOUNT__", html.escape(prefix + "/account", quote=True))
        page = page.replace("__ROWS__", "".join(rows)).replace("__API__", json.dumps(prefix + "/api/v1/admin/users"))
        return HTMLResponse(page, headers={"Cache-Control": "no-store", "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'self'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'", "X-Frame-Options": "DENY", "X-Content-Type-Options": "nosniff", "Referrer-Policy": "same-origin"})

    @app.get("/account", response_class=HTMLResponse)
    async def account_page(request: Request):
        username = current_user(request)
        if username is None:
            return page_login_redirect(request)
        prefix = settings.base_path or ""
        page = '''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>ForgeChat · Account</title><style>:root{color-scheme:dark}body{margin:0;min-height:100vh;display:grid;place-items:center;background:radial-gradient(ellipse at 15% 0,#27366a,transparent 44%),#0b1020;color:#edf2ff;font:15px/1.5 system-ui,sans-serif}.card{width:min(520px,calc(100% - 28px));padding:28px;border:1px solid #26334b;border-radius:20px;background:#121a2ceb;box-shadow:0 18px 50px #0005}a{color:#b9c6ff}.eyebrow{color:#72e0c0;font-size:11px;font-weight:800;letter-spacing:.16em}h1{margin:5px 0 3px;font-size:32px;letter-spacing:-.04em}.muted{color:#9aa8bf}.user{display:inline-block;padding:5px 10px;border:1px solid #34415a;border-radius:999px;margin:12px 0 2px}.form{display:grid;gap:11px;margin-top:20px}label{display:grid;gap:6px;color:#cbd6ec;font-size:13px}input{padding:12px;border:1px solid #3a4965;border-radius:10px;background:#0c1424;color:#edf2ff;font:inherit}button{padding:12px;border:0;border-radius:11px;background:linear-gradient(135deg,#8295ff,#9c7dff);color:#0c1020;font:inherit;font-weight:750;cursor:pointer}.status{min-height:22px;color:#72e0c0;font-size:13px}.back{display:inline-block;margin-top:14px}</style></head><body><main class="card"><a href="__APPS__">← Workspace</a><p class="eyebrow">ACCOUNT SECURITY</p><h1>Change password</h1><p class="muted">Changing your password ends other active sessions. Your current session will remain open.</p><span class="user">__USERNAME__</span><form id="password-form" class="form"><label>Current password<input type="password" name="currentPassword" autocomplete="current-password" required></label><label>New password<input type="password" name="newPassword" autocomplete="new-password" minlength="9" required></label><label>Confirm new password<input type="password" name="confirmPassword" autocomplete="new-password" minlength="9" required></label><button>Update password</button></form><p id="status" class="status" role="status" aria-live="polite"></p></main><script>(function(){var form=document.getElementById('password-form'),status=document.getElementById('status');form.addEventListener('submit',async function(e){e.preventDefault();var current=form.elements.currentPassword.value,next=form.elements.newPassword.value;if(next!==form.elements.confirmPassword.value){status.textContent='The new password entries do not match.';return;}if(next.length<9){status.textContent='Use a password with at least 9 characters.';return;}status.textContent='Updating…';try{var response=await fetch('__API__',{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/json'},body:JSON.stringify({currentPassword:current,newPassword:next})}),data=await response.json().catch(function(){return {};});if(!response.ok)throw new Error(data.detail||'Could not update password.');form.reset();status.textContent='Password updated. Other sessions have been signed out.';}catch(error){status.textContent=String(error&&error.message||error);}});})();</script></body></html>'''
        page = page.replace("__APPS__", html.escape(prefix + "/apps/", quote=True)).replace("__USERNAME__", html.escape(username))
        page = page.replace("__API__", html.escape(prefix + "/api/v1/account/password", quote=True))
        return HTMLResponse(page, headers={"Cache-Control": "no-store", "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'self'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'", "X-Frame-Options": "DENY", "X-Content-Type-Options": "nosniff", "Referrer-Policy": "same-origin"})

    @app.get("/publish", response_class=HTMLResponse)
    async def publish_page(request: Request):
        if current_user(request) is None:
            return page_login_redirect(request)
        require_owner(request)
        prefix = (settings.base_path or "")
        publish_html = """<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>Publish ForgeChat app</title><style>:root{color-scheme:dark}body{font:16px system-ui,sans-serif;margin:0;background:#111827;color:#eef2ff}main{max-width:760px;margin:8vh auto;padding:clamp(1.2rem,4vw,2.2rem);background:#1f2937;border:1px solid #374151;border-radius:16px}label{display:grid;gap:.5rem;margin:1.2rem 0}input{max-width:100%;padding:.7rem;border:1px solid #6b7280;border-radius:8px;background:#111827;color:inherit}button{padding:.75rem 1.2rem;border:0;border-radius:8px;background:#7c3aed;color:white;font:inherit;font-weight:700;cursor:pointer}a{color:#c4b5fd}#status{min-height:1.5em}@media(max-width:700px){main{margin:0;border-radius:0;min-height:100vh;box-sizing:border-box}}</style></head><body><main><h1>Publish ForgeChat app</h1><p>Choose the single-file HTML export created with <strong>Export for ForgeChat · no keys</strong>. The hosted page will be private and require sign-in.</p><form id="publish"><label>App ID <input name="id" required pattern="[A-Za-z0-9][A-Za-z0-9_-]{0,79}" maxlength="80"></label><label>HTML file <input name="file" type="file" accept=".html,text/html" required></label><button>Publish</button></form><p id="status" aria-live="polite"></p><p><a href=""" + html.escape(prefix + "/apps/", quote=True) + """">Back to apps</a></p><script>(function(){var form=document.getElementById('publish'),status=document.getElementById('status');var api=""" + json.dumps(prefix + "/api/v1/apps") + """;form.elements.file.addEventListener('change',function(){var f=this.files&&this.files[0];if(f&&!form.elements.id.value)form.elements.id.value=f.name.replace(/\\.html?$/i,'').replace(/[^A-Za-z0-9_-]/g,'_').slice(0,80);});form.addEventListener('submit',async function(e){e.preventDefault();var file=form.elements.file.files[0],id=form.elements.id.value.trim();if(!file)return;if(file.size>""" + str(settings.max_app_bytes) + """){status.textContent='HTML file is too large.';return;}status.textContent='Publishing…';try{var response=await fetch(api,{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/json'},body:JSON.stringify({id:id,html:await file.text()})});var result=await response.json().catch(function(){return {};});if(response.status===401){location.href=""" + json.dumps(prefix + "/login?next=" + default_app_path()) + """;return;}if(!response.ok)throw new Error(result.detail||'Upload failed');status.textContent='Published. ';var link=document.createElement('a');link.href=result.url;link.textContent='Open '+id;status.appendChild(link);}catch(error){status.textContent=String(error&&error.message||error);}});})();</script></main></body></html>"""
        return HTMLResponse(publish_html, headers={"Cache-Control": "no-store", "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'self'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'", "X-Frame-Options": "DENY", "X-Content-Type-Options": "nosniff"})

    @app.post("/api/v1/apps")
    async def publish_app(request: Request):
        check_origin(request)
        require_owner(request)
        payload = await read_json_limited(request)
        if not isinstance(payload, dict) or set(payload) != {"id", "html"}:
            raise HTTPException(status_code=400, detail="Provide app id and HTML source.")
        app_id = payload.get("id")
        source = payload.get("html")
        if not isinstance(app_id, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]{0,79}", app_id):
            raise HTTPException(status_code=400, detail="App id must be a simple identifier.")
        if not isinstance(source, str) or "<html" not in source[:4096].lower():
            raise HTTPException(status_code=400, detail="Upload must contain a complete HTML document.")
        encoded = source.encode("utf-8")
        if len(encoded) > settings.max_app_bytes:
            raise HTTPException(status_code=413, detail="HTML app exceeds the configured size limit.")
        root = settings.app_dir.resolve()
        if not root.is_dir():
            raise HTTPException(status_code=503, detail="The private app directory is not configured.")
        target = root / (app_id + ".html")
        if not target.parent.resolve().is_relative_to(root):
            raise HTTPException(status_code=400, detail="Invalid app path.")
        temp_path = None
        try:
            fd, temp_name = tempfile.mkstemp(prefix=".forgechat-", suffix=".tmp", dir=root)
            temp_path = Path(temp_name)
            with os.fdopen(fd, "wb") as handle:
                handle.write(encoded)
            os.replace(temp_path, target)
        except OSError as exc:
            if temp_path is not None:
                temp_path.unlink(missing_ok=True)
            raise HTTPException(status_code=503, detail="Could not publish the app.") from exc
        return {"ok": True, "id": app_id, "url": (settings.base_path or "") + "/apps/" + app_id}

    @app.get("/apps/{app_id}")
    async def hosted_app(request: Request, app_id: str):
        username = current_user(request)
        if username is None:
            return page_login_redirect(request)
        name = app_id[:-5] if app_id.endswith(".html") else app_id
        if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]{0,79}", name):
            raise HTTPException(status_code=404, detail="App not found.")
        root = settings.app_dir.resolve()
        candidate = root / (name + ".html")
        if candidate.is_symlink() or not candidate.is_file():
            raise HTTPException(status_code=404, detail="App not found.")
        target = candidate.resolve()
        if not target.is_relative_to(root) or not target.is_file():
            raise HTTPException(status_code=404, detail="App not found.")
        account = accounts.get_user(username)
        if account is None or (account["role"] != "owner" and not accounts.user_can_access(username, name)):
            raise HTTPException(status_code=404, detail="App not found.")
        return FileResponse(target, media_type="text/html", headers={"Cache-Control": "no-store"})

    @app.get("/provider-import", response_class=HTMLResponse)
    async def provider_import_page(request: Request):
        if current_user(request) is None:
            return page_login_redirect(request)
        require_owner(request)
        prefix = settings.base_path or ""
        preview_api = json.dumps(prefix + "/api/v1/provider-import/preview")
        apply_api = json.dumps(prefix + "/api/v1/provider-import/apply")
        apps_link = html.escape(prefix + "/apps/", quote=True)
        apps_link_js = json.dumps(prefix + "/apps/")
        page = '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>Import Forge provider backup</title><style>:root{color-scheme:dark}body{font:16px system-ui,sans-serif;margin:0;background:#111827;color:#eef2ff}main{max-width:820px;margin:8vh auto;padding:clamp(1.2rem,4vw,2.2rem);background:#1f2937;border:1px solid #374151;border-radius:16px}h1{margin:0 0 .4rem}p.note{color:#9ca3ff;margin:0 0 1rem}label{display:grid;gap:.5rem;margin:1.2rem 0}input{max-width:100%;padding:.7rem;border:1px solid #6b7280;border-radius:8px;background:#111827;color:inherit}button{padding:.75rem 1.2rem;border:0;border-radius:8px;background:#7c3aed;color:#fff;font:inherit;font-weight:700;cursor:pointer}button:disabled{opacity:.5;cursor:not-allowed}a{color:#c4b5fd}#results{list-style:none;margin:1rem 0;padding:0}#results li{display:grid;gap:.2rem;padding:.6rem .8rem;border:1px solid #334155;border-radius:8px;margin:.4rem 0}#results .meta{color:#c7d2fe;font-size:.9rem}#results .issue{color:#fbbf24;font-size:.85rem}#status{min-height:1.5em;color:#9ca3ff}.confirmed{display:flex;gap:.5rem;align-items:center;margin:1rem 0}@media(max-width:700px){main{margin:0;border-radius:0;min-height:100vh;box-sizing:border-box}}</style></head><body><main><h1>Import provider backup</h1><p class="note">Choose a Forge Share Backup ZIP. Only ForgeLibrary/settings.json is read; provider keys stay on the server and are never returned to the browser.</p><label>Backup ZIP <input id="file" type="file" accept=".zip,application/zip,application/x-zip-compressed" required></label><button id="preview">Preview providers</button><ul id="results" aria-live="polite"></ul><label class="confirmed"><input id="confirm" type="checkbox" required> I understand this merges selected providers into the server config and an admin must restart the service for them to take effect.</label><button id="apply" disabled>Apply selected providers</button><p id="status" aria-live="polite"></p><p><a href="__APPS_LINK__">Back to apps</a></p><script>(function(){var file=document.getElementById(\'file\'),previewBtn=document.getElementById(\'preview\'),resultsEl=document.getElementById(\'results\'),confirmEl=document.getElementById(\'confirm\'),applyBtn=document.getElementById(\'apply\'),status=document.getElementById(\'status\');var previewId=null;function disableApply(){applyBtn.disabled=!confirmEl.checked||!previewId||!resultsEl.querySelector(\'input:checked\');}confirmEl.addEventListener(\'change\',disableApply);resultsEl.addEventListener(\'change\',disableApply);var MAX_BYTES=__MAX_BYTES__;previewBtn.addEventListener(\'click\',async function(){var f=file.files&&file.files[0];if(!f){status.textContent=\'Choose a Forge backup ZIP first.\';return;}if(f.size>MAX_BYTES){status.textContent=\'Backup ZIP exceeds the upload size limit.\';return;}status.textContent=\'Reading backup…\';resultsEl.textContent=\'\';previewId=null;disableApply();try{var buf=await f.arrayBuffer();var resp=await fetch(__PREVIEW_API__,{method:\'POST\',credentials:\'same-origin\',headers:{\'Content-Type\':\'application/zip\'},body:new Uint8Array(buf)});var data=await resp.json().catch(function(){return {};});if(resp.status===401){location.href=__APPS_LINK_JS__;return;}if(!resp.ok)throw new Error(data.detail||\'Preview failed\');previewId=data.previewId;status.textContent=\'Preview ready. Select providers below.\';data.providers.forEach(function(p){var li=document.createElement(\'li\');var lbl=document.createElement(\'label\');var cb=document.createElement(\'input\');cb.type=\'checkbox\';cb.value=p.id;cb.dataset.importable=p.importable?\'1\':\'0\';if(!p.importable)cb.disabled=true;lbl.appendChild(cb);var name=document.createElement(\'span\');name.textContent=p.id+\' — \'+p.label;li.appendChild(lbl);li.appendChild(name);var meta=document.createElement(\'div\');meta.className=\'meta\';meta.textContent=\'kind: \'+(p.kind||\'?\')+\'; model: \'+(p.default_model||\'(none)\')+\'; \'+(p.key_saved?\'saved key present\':\'no saved key\')+\'; models: \'+(p.models||[]).join(\', \');li.appendChild(meta);if(p.issue){var issue=document.createElement(\'div\');issue.className=\'issue\';issue.textContent=p.issue;li.appendChild(issue);}resultsEl.appendChild(li);});disableApply();}catch(error){status.textContent=String(error&&error.message||error);}});applyBtn.addEventListener(\'click\',async function(){if(!previewId)return;var ids=Array.prototype.map.call(resultsEl.querySelectorAll(\'input:checked\'),function(cb){return cb.value;});if(!ids.length){status.textContent=\'Select at least one provider.\';return;}if(!confirmEl.checked){status.textContent=\'Confirm the merge before applying.\';return;}status.textContent=\'Applying…\';applyBtn.disabled=true;try{var resp=await fetch(__APPLY_API__,{method:\'POST\',credentials:\'same-origin\',headers:{\'Content-Type\':\'application/json\'},body:JSON.stringify({previewId:previewId,providers:ids,confirm:true})});var data=await resp.json().catch(function(){return {};});if(resp.status===401){location.href=__APPS_LINK_JS__;return;}if(!resp.ok)throw new Error(data.detail||\'Apply failed\');status.textContent=\'Imported: \'+(data.imported||[]).join(\', \')+\'. Restart the service for changes to take effect.\';previewId=null;resultsEl.textContent=\'\';file.value=\'\';confirmEl.checked=false;disableApply();}catch(error){status.textContent=String(error&&error.message||error)+\' — upload and preview the ZIP again before retrying.\';previewId=null;applyBtn.disabled=true;}});})();</script></main></body></html>'
        page = page.replace("__APPS_LINK__", apps_link).replace("__APPS_LINK_JS__", apps_link_js).replace("__PREVIEW_API__", preview_api).replace("__APPLY_API__", apply_api).replace("__MAX_BYTES__", str(MAX_WEB_IMPORT_BYTES))
        page = page.replace("</main></body></html>", '<section class="provider-apps" style="max-width:900px;margin:24px auto;padding:20px;background:#1f2937;border:1px solid #374151;border-radius:14px"><h2>Providers available to apps</h2><p>Choose which configured providers each hosted app can use and set its default. Provider credentials remain on the server. Users can switch only among providers enabled for their app.</p><div id="app-provider-list">Loading apps and providers…</div><p id="app-provider-status" aria-live="polite"></p></section><script>(function(){var root=document.getElementById("app-provider-list"),status=document.getElementById("app-provider-status"),api=' + json.dumps(prefix + "/api/v1/admin/apps/providers") + ',saveApi=' + json.dumps(prefix + "/api/v1/admin/apps") + ';function request(url,options){return fetch(url,Object.assign({credentials:"same-origin",cache:"no-store",headers:{"Content-Type":"application/json"}},options||{})).then(async function(response){var data=await response.json().catch(function(){return {}});if(response.status===401){location.href=' + json.dumps(prefix + "/login") + ';throw new Error("Login required.")}if(!response.ok)throw new Error(data.detail||("HTTP "+response.status));return data})}function render(data){root.textContent="";if(!data.providers.length){root.textContent="No configured providers are currently available. Import providers above and restart ForgeChat.";return}if(!data.apps.length){root.textContent="Publish an app before assigning providers.";return}data.apps.forEach(function(app){var card=document.createElement("article"),title=document.createElement("h3"),help=document.createElement("p"),checks=document.createElement("div"),defaultLabel=document.createElement("label"),select=document.createElement("select"),save=document.createElement("button"),msg=document.createElement("span"),allowed=new Set(app.providerIds);card.style.cssText="border-top:1px solid #374151;padding:12px 0";title.textContent=app.title+" ("+app.id+")";help.textContent=app.configured?"Configured selection. Select at least one provider and choose a default.":"No per-app selection saved yet; current behavior allows all available providers.";checks.style.cssText="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:8px;margin:12px 0";data.providers.forEach(function(provider){var label=document.createElement("label"),box=document.createElement("input"),name=document.createElement("span");box.type="checkbox";box.value=provider.id;box.checked=allowed.has(provider.id);box.addEventListener("change",refreshDefault);name.textContent=" "+provider.label+" — "+provider.model;label.appendChild(box);label.appendChild(name);checks.appendChild(label)});defaultLabel.textContent="Default provider: ";defaultLabel.appendChild(select);function refreshDefault(){var prior=select.value,checked=Array.from(checks.querySelectorAll("input:checked")).map(function(box){return box.value});select.textContent="";checked.forEach(function(id){var provider=data.providers.find(function(item){return item.id===id}),option=document.createElement("option");option.value=id;option.textContent=provider?provider.label+" ("+id+")":id;select.appendChild(option)});select.value=checked.indexOf(prior)>=0?prior:(checked.indexOf(app.defaultProviderId)>=0?app.defaultProviderId:(checked[0]||""))}refreshDefault();save.type="button";save.textContent="Save provider access";save.addEventListener("click",async function(){var ids=Array.from(checks.querySelectorAll("input:checked")).map(function(box){return box.value});if(!ids.length){msg.textContent=" Select at least one provider.";return}msg.textContent=" Saving…";try{await request(saveApi+"/"+encodeURIComponent(app.id)+"/providers",{method:"PUT",body:JSON.stringify({providerIds:ids,defaultProviderId:select.value})});app.providerIds=ids;app.defaultProviderId=select.value;app.configured=true;help.textContent="Saved. This app can use only the selected providers.";msg.textContent=" Saved."}catch(error){msg.textContent=" "+String(error&&error.message||error)}});card.appendChild(title);card.appendChild(help);card.appendChild(checks);card.appendChild(defaultLabel);card.appendChild(document.createElement("br"));card.appendChild(save);card.appendChild(msg);root.appendChild(card)})}request(api).then(render).catch(function(error){root.textContent=String(error&&error.message||error)})})();</script></main></body></html>')
        return HTMLResponse(page, headers={
            "Cache-Control": "no-store",
            "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'self'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'",
            "X-Frame-Options": "DENY",
            "X-Content-Type-Options": "nosniff",
            "Referrer-Policy": "same-origin",
        })

    @app.post("/api/v1/provider-import/preview")
    async def provider_import_preview(request: Request):
        check_origin(request)
        require_owner(request)
        claims = require_session(request)
        if import_limiter.blocked(claims["session_id"]):
            raise HTTPException(status_code=429, detail="Too many import attempts. Try again later.")
        import_limiter.fail(claims["session_id"])
        content_type = request.headers.get("content-type", "").split(";", 1)[0].strip().lower()
        if content_type not in {"application/zip", "application/x-zip-compressed", "application/octet-stream"}:
            raise HTTPException(status_code=415, detail="Upload a ZIP backup file.")
        data = await read_bytes_limited(request, MAX_WEB_IMPORT_BYTES)
        try:
            settings_data = read_forge_settings_bytes(data)
            candidates = discover_candidates(settings_data)
        except ImportErrorSafe as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        existing_key_ids = {provider.id for provider in settings.providers if provider.api_key}
        providers = []
        for candidate in candidates:
            view = candidate.preview()
            importable = not candidate.issue or candidate.issue.startswith(_NO_KEY_ISSUE_PREFIX) and candidate.id in existing_key_ids
            issue = candidate.issue if candidate.issue and not importable else ""
            if candidate.issue.startswith(_NO_KEY_ISSUE_PREFIX) and candidate.id in existing_key_ids:
                issue = "an existing server key will be reused; re-export with the key to change it"
            providers.append({
                "id": view["id"],
                "label": view["label"],
                "kind": view["kind"],
                "default_model": view["default_model"],
                "models": view["models"][:8],
                "key_saved": view["key_saved"],
                "importable": importable,
                "issue": issue,
            })
        prune_pending_imports()
        for token, pending in list(pending_provider_imports.items()):
            if pending["session_id"] == claims["session_id"]:
                pending_provider_imports.pop(token, None)
        while len(pending_provider_imports) >= MAX_PENDING_IMPORTS:
            oldest = min(pending_provider_imports, key=lambda key: pending_provider_imports[key]["expires_at"])
            pending_provider_imports.pop(oldest, None)
        token = secrets.token_urlsafe(24)
        pending_provider_imports[token] = {
            "session_id": claims["session_id"],
            "expires_at": time.monotonic() + PENDING_IMPORT_SECONDS,
            "candidates": candidates,
        }
        asyncio.get_running_loop().call_later(PENDING_IMPORT_SECONDS, expire_pending_import, token)
        return {"previewId": token, "expiresInSeconds": PENDING_IMPORT_SECONDS, "providers": providers}

    @app.post("/api/v1/provider-import/apply")
    async def provider_import_apply(request: Request):
        check_origin(request)
        require_owner(request)
        claims = require_session(request)
        if import_limiter.blocked(claims["session_id"]):
            raise HTTPException(status_code=429, detail="Too many import attempts. Try again later.")
        payload = await read_json_limited(request)
        if not isinstance(payload, dict) or set(payload) != {"previewId", "providers", "confirm"} or payload.get("confirm") is not True:
            raise HTTPException(status_code=400, detail="Confirm the provider import before applying.")
        token = payload.get("previewId")
        if not isinstance(token, str) or len(token) > 128 or not re.fullmatch(r"[A-Za-z0-9_-]{8,128}", token):
            raise HTTPException(status_code=400, detail="Invalid import session.")
        selected = payload.get("providers")
        if not isinstance(selected, list) or not selected or len(selected) > 32 or any(not isinstance(x, str) or not _PROVIDER_ID.fullmatch(x) for x in selected) or len(set(selected)) != len(selected):
            raise HTTPException(status_code=400, detail="Select valid provider IDs.")
        prune_pending_imports()
        pending = pending_provider_imports.pop(token, None)
        if pending is None or pending["session_id"] != claims["session_id"]:
            raise HTTPException(status_code=404, detail="Import session expired. Upload the backup again.")
        by_id = {candidate.id: candidate for candidate in pending["candidates"]}
        existing_key_ids = {provider.id for provider in settings.providers if provider.api_key}
        chosen: list[ProviderCandidate] = []
        for provider_id in selected:
            candidate = by_id.get(provider_id)
            if candidate is None:
                raise HTTPException(status_code=400, detail="Selected provider is not in this backup.")
            importable = not candidate.issue or candidate.issue.startswith(_NO_KEY_ISSUE_PREFIX) and candidate.id in existing_key_ids
            if not importable:
                raise HTTPException(status_code=400, detail=f"Provider {provider_id} cannot be imported.")
            chosen.append(candidate)
        try:
            imported = await import_apply(chosen)
        except ImportApplyError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        except Exception:
            raise HTTPException(status_code=503, detail="Provider import helper is unavailable.") from None
        return {"ok": True, "imported": imported, "restartRequired": True}

    def app_target(app_id: str) -> Path:
        try:
            accounts.validate_app_id(app_id)
        except AccessError:
            raise HTTPException(status_code=404, detail="App not found.") from None
        root = settings.app_dir.resolve()
        candidate = root / (app_id + ".html")
        if candidate.is_symlink() or not candidate.is_file():
            raise HTTPException(status_code=404, detail="App not found.")
        target = candidate.resolve()
        if not target.is_relative_to(root) or not target.is_file():
            raise HTTPException(status_code=404, detail="App not found.")
        return target

    @app.post("/api/v1/admin/users")
    async def create_user(request: Request):
        check_origin(request)
        require_owner(request)
        payload = await read_json_limited(request)
        if not isinstance(payload, dict) or set(payload) != {"username", "password"}:
            raise HTTPException(status_code=400, detail="Provide a username and password.")
        try:
            username = accounts.validate_username(payload["username"])
            password_hash = hash_password(payload["password"])
            user = accounts.create_user(username, password_hash)
        except (AccessError, ValueError) as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        return JSONResponse({"ok": True, "username": user["username"], "role": user["role"]}, status_code=201)

    @app.post("/api/v1/admin/users/{username}/password")
    async def reset_user_password(request: Request, username: str):
        check_origin(request)
        require_owner(request)
        try:
            target = accounts.validate_username(username)
        except AccessError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        account = accounts.get_user(target)
        if account is None or account["role"] == "owner":
            raise HTTPException(status_code=404, detail="App user not found.")
        payload = await read_json_limited(request)
        if not isinstance(payload, dict) or set(payload) != {"password"}:
            raise HTTPException(status_code=400, detail="Provide a new password.")
        try:
            password_hash = hash_password(payload["password"])
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        accounts.set_password(account["username"], password_hash)
        return {"ok": True}

    @app.patch("/api/v1/admin/users/{username}")
    async def set_user_enabled(request: Request, username: str):
        check_origin(request)
        require_owner(request)
        try:
            target = accounts.validate_username(username)
        except AccessError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        payload = await read_json_limited(request)
        if not isinstance(payload, dict) or set(payload) != {"enabled"} or not isinstance(payload["enabled"], bool):
            raise HTTPException(status_code=400, detail="Provide an enabled boolean.")
        account = accounts.set_enabled(target, payload["enabled"])
        if account is None:
            raise HTTPException(status_code=404, detail="App user not found or cannot be disabled.")
        return {"ok": True, "username": account["username"], "enabled": bool(account["enabled"])}

    @app.delete("/api/v1/admin/users/{username}")
    async def delete_user(request: Request, username: str):
        check_origin(request)
        require_owner(request)
        try:
            target = accounts.validate_username(username)
        except AccessError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        if not accounts.delete_user(target):
            raise HTTPException(status_code=404, detail="App user not found or cannot be deleted.")
        return {"ok": True}

    @app.put("/api/v1/admin/users/{username}/agent-access")
    async def set_user_agent_access(request: Request, username: str):
        check_origin(request)
        require_owner(request)
        try:
            target = accounts.validate_username(username)
        except AccessError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        payload = await read_json_limited(request)
        if not isinstance(payload, dict) or set(payload) != {"allowed"} or not isinstance(payload["allowed"], bool):
            raise HTTPException(status_code=400, detail="Provide an allowed boolean.")
        try:
            allowed = accounts.set_agent_access(target, payload["allowed"])
        except AccessError as exc:
            raise HTTPException(status_code=404, detail=str(exc)) from exc
        return {"ok": True, "username": target, "allowed": allowed}

    @app.get("/api/v1/admin/apps/providers")
    async def admin_app_providers(request: Request):
        require_owner(request)
        root = settings.app_dir.resolve()
        apps = []
        if root.is_dir():
            for candidate in sorted(root.glob("*.html"), key=lambda path: path.name.casefold()):
                if candidate.is_symlink() or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]{0,79}\.html", candidate.name):
                    continue
                try:
                    if not candidate.resolve(strict=True).is_relative_to(root):
                        continue
                except OSError:
                    continue
                app_id = candidate.stem
                configured = accounts.app_provider_settings(app_id)
                apps.append({
                    "id": app_id,
                    "title": app_id,
                    "configured": configured is not None,
                    "providerIds": configured["providerIds"] if configured else [provider.id for provider in _available_providers(settings.providers)],
                    "defaultProviderId": configured["defaultProviderId"] if configured else (next((provider.id for provider in settings.providers if provider.api_key or provider.auth_optional), "")),
                })
        available = _available_providers(settings.providers)
        return JSONResponse({
            "apps": apps,
            "providers": [{"id": provider.id, "label": provider.label, "model": provider.default_model} for provider in available],
        }, headers={"Cache-Control": "no-store"})

    @app.put("/api/v1/admin/apps/{app_id}/providers")
    async def set_app_providers(request: Request, app_id: str):
        check_origin(request)
        require_owner(request)
        app_target(app_id)
        payload = await read_json_limited(request)
        if not isinstance(payload, dict) or set(payload) != {"providerIds", "defaultProviderId"}:
            raise HTTPException(status_code=400, detail="Provide providerIds and defaultProviderId.")
        provider_ids = payload.get("providerIds")
        default_provider_id = payload.get("defaultProviderId")
        available_ids = {provider.id for provider in _available_providers(settings.providers)}
        if not isinstance(provider_ids, list) or len(provider_ids) > 32 or any(not isinstance(item, str) for item in provider_ids):
            raise HTTPException(status_code=400, detail="providerIds must be an array of available provider IDs.")
        if any(provider_id not in available_ids for provider_id in provider_ids):
            raise HTTPException(status_code=400, detail="Select only providers currently available on the ForgeChat server.")
        try:
            result = accounts.set_app_providers(app_id, provider_ids, default_provider_id)
        except AccessError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        return JSONResponse({"ok": True, "appId": app_id, **result}, headers={"Cache-Control": "no-store"})

    @app.put("/api/v1/admin/apps/{app_id}/access")
    async def set_app_access(request: Request, app_id: str):
        check_origin(request)
        require_owner(request)
        app_target(app_id)
        payload = await read_json_limited(request)
        if not isinstance(payload, dict) or set(payload) != {"users"} or not isinstance(payload["users"], list) or len(payload["users"]) > 256 or any(not isinstance(name, str) for name in payload["users"]):
            raise HTTPException(status_code=400, detail="Provide an array of app usernames.")
        try:
            users = accounts.set_app_users(app_id, payload["users"])
        except AccessError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        return {"ok": True, "appId": app_id, "users": users}

    @app.delete("/api/v1/admin/apps/{app_id}")
    async def delete_app(request: Request, app_id: str):
        check_origin(request)
        require_owner(request)
        target = app_target(app_id)
        try:
            target.unlink()
        except OSError as exc:
            raise HTTPException(status_code=503, detail="Could not delete the app.") from exc
        accounts.forget_app(app_id)
        return {"ok": True, "id": app_id}

    @app.post("/api/v1/account/password")
    async def change_own_password(request: Request, response: Response):
        check_origin(request)
        claims = require_session(request)
        payload = await read_json_limited(request)
        if not isinstance(payload, dict) or set(payload) != {"currentPassword", "newPassword"}:
            raise HTTPException(status_code=400, detail="Provide your current and new password.")
        account = accounts.get_user(claims["username"])
        if account is None or not isinstance(payload["currentPassword"], str) or not verify_password(payload["currentPassword"], account["password_hash"]):
            raise HTTPException(status_code=400, detail="Current password is incorrect.")
        try:
            new_hash = hash_password(payload["newPassword"])
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        changed = accounts.set_password(account["username"], new_hash)
        if changed is None:
            raise HTTPException(status_code=401, detail="Login required.")
        remaining = claims["expires_at"] - int(time.time())
        if remaining <= 0:
            raise HTTPException(status_code=401, detail="Login required.")
        revoked_sessions[claims["session_id"]] = claims["expires_at"]
        set_session_cookie(response, changed["username"], changed["session_version"], remaining)
        return {"ok": True}

    @app.get("/api/v1/session")
    async def session(request: Request):
        require_user(request)
        return {"authenticated": True, "capabilities": {"chat": bool(_available_providers(settings.providers)), "streaming": bool(_available_providers(settings.providers))}}

    @app.post("/api/v1/auth/login")
    async def login(request: Request, response: Response):
        check_origin(request)
        client_host = request.client.host if request.client else "unknown"
        if limiter.blocked(client_host):
            raise HTTPException(status_code=429, detail="Too many login attempts. Try again later.")
        payload = await read_json_limited(request)
        content_type = request.headers.get("content-type", "").split(";", 1)[0].strip().lower()
        is_form = content_type == "application/x-www-form-urlencoded"
        allowed = {"username", "password", "remember", "next"}
        if not isinstance(payload, dict) or set(payload) - allowed or not {"username", "password"}.issubset(payload):
            limiter.fail(client_host)
            if is_form:
                return RedirectResponse(login_url(safe_next(request.query_params.get("next")), invalid=True), status_code=303)
            raise HTTPException(status_code=400, detail="Provide username and password.")
        supplied_user = payload.get("username")
        supplied_password = payload.get("password")
        account = accounts.get_user(supplied_user) if isinstance(supplied_user, str) else None
        encoded_hash = account["password_hash"] if account is not None else settings.password_hash
        valid_password = (isinstance(supplied_password, str) and len(supplied_password) <= 1024
                          and verify_password(supplied_password, encoded_hash))
        if account is None or not account["enabled"] or not valid_password:
            limiter.fail(client_host)
            if is_form:
                target = safe_next(str(payload.get("next") or request.query_params.get("next") or ""))
                return RedirectResponse(login_url(target, invalid=True), status_code=303)
            raise HTTPException(status_code=401, detail="Invalid username or password.")

        limiter.success(client_host)
        remember_value = payload.get("remember", False)
        remember = remember_value is True or str(remember_value).lower() in {"1", "true", "on", "yes"}
        lifetime = settings.remember_session_seconds if remember else settings.session_seconds
        if is_form:
            redirect = RedirectResponse(safe_next(str(payload.get("next") or request.query_params.get("next") or "")), status_code=303)
            set_session_cookie(redirect, account["username"], account["session_version"], lifetime)
            return redirect
        set_session_cookie(response, account["username"], account["session_version"], lifetime)
        return {"ok": True, "expiresIn": lifetime, "remembered": remember}

    @app.post("/api/v1/auth/logout")
    async def logout(request: Request, response: Response):
        check_origin(request)
        require_user(request)
        claims = current_session(request)
        if claims:
            revoked_sessions[claims["session_id"]] = claims["expires_at"]
            for token, pending in list(pending_provider_imports.items()):
                if pending["session_id"] == claims["session_id"]:
                    pending_provider_imports.pop(token, None)
        response.delete_cookie(
            key=settings.cookie_name,
            path=settings.base_path or "/",
            secure=settings.public_origin.startswith("https://"),
            httponly=True,
            samesite="strict",
        )
        return {"ok": True}

    @app.get("/api/v1/providers")
    async def providers(request: Request):
        require_app_access(request)
        available = app_provider_settings(request)
        app_id = request.headers.get("x-forgechat-app", "").strip()
        configured = accounts.app_provider_settings(app_id) if app_id else None
        default_id = configured["defaultProviderId"] if configured else (available[0].id if available else None)
        if default_id not in {provider.id for provider in available}:
            default_id = available[0].id if available else None
        return {
            "providers": [provider.public_dict() for provider in available],
            "selectedId": default_id,
            "defaultId": default_id,
        }

    @app.get("/api/v1/agent/status")
    async def backend_agent_status(request: Request):
        username = require_agent_access(request)
        if agent_limiter.blocked(username):
            raise HTTPException(status_code=429, detail="Backend agent request limit reached.")
        agent_limiter.fail(username)
        async with agent_slots:
            status_code, result = await call_agent_json("GET", "/status")
        if status_code >= 400:
            detail = str(result.get("errmsg") or "Backend agent request failed.")[:300]
            raise HTTPException(status_code=status_code, detail=detail)
        return JSONResponse(result, headers={"Cache-Control": "no-store"})

    @app.post("/api/v1/agent/exec")
    async def backend_agent_exec(request: Request):
        check_origin(request)
        username = require_agent_access(request)
        if agent_limiter.blocked(username):
            raise HTTPException(status_code=429, detail="Backend agent request limit reached.")
        agent_limiter.fail(username)
        raw = await read_json_limited(request)
        try:
            job = _normalize_agent_job(raw)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        async with agent_slots:
            status_code, result = await call_agent_json("POST", "/exec", payload=job)
        if status_code >= 400:
            detail = str(result.get("errmsg") or "Backend agent request failed.")[:300]
            raise HTTPException(status_code=status_code, detail=detail)
        return JSONResponse(result, headers={"Cache-Control": "no-store"})

    @app.get("/api/v1/agent/files")
    async def backend_agent_read_file(request: Request):
        username = require_agent_access(request)
        if agent_limiter.blocked(username):
            raise HTTPException(status_code=429, detail="Backend agent request limit reached.")
        agent_limiter.fail(username)
        path = request.query_params.get("path", "")
        if not path or len(path) > 4096:
            raise HTTPException(status_code=400, detail="Provide a valid agent file path.")
        try:
            max_bytes = int(request.query_params.get("maxBytes", str(64 * 1024 * 1024)))
        except ValueError as exc:
            raise HTTPException(status_code=400, detail="maxBytes must be an integer.") from exc
        if not 1 <= max_bytes <= 64 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="maxBytes must be between 1 and 67108864.")
        params = {"path": path, "maxBytes": str(max_bytes)}
        mime = request.query_params.get("mime", "")
        if mime:
            if len(mime) > 200 or not re.fullmatch(r"[A-Za-z0-9!#$&^_.+-]+/[A-Za-z0-9!#$&^_.+-]+", mime):
                raise HTTPException(status_code=400, detail="Invalid MIME type.")
            params["mime"] = mime
        await agent_slots.acquire()
        try:
            client, upstream = await open_agent_stream("GET", "/files", params=params)
        except Exception:
            agent_slots.release()
            raise

        async def file_body():
            try:
                async for chunk in upstream.aiter_bytes():
                    yield chunk
            finally:
                await upstream.aclose()
                await client.aclose()
                agent_slots.release()

        response_headers = {"Cache-Control": "no-store"}
        if upstream.headers.get("content-type"):
            response_headers["Content-Type"] = upstream.headers["content-type"]
        if upstream.headers.get("content-length"):
            response_headers["Content-Length"] = upstream.headers["content-length"]
        return StreamingResponse(file_body(), status_code=upstream.status_code, headers=response_headers)

    @app.put("/api/v1/agent/files")
    async def backend_agent_write_file(request: Request):
        check_origin(request)
        username = require_agent_access(request)
        if agent_limiter.blocked(username):
            raise HTTPException(status_code=429, detail="Backend agent request limit reached.")
        agent_limiter.fail(username)
        destination = request.query_params.get("destination", "")
        if not destination or len(destination) > 4096:
            raise HTTPException(status_code=400, detail="Provide a valid agent destination.")
        content_length = request.headers.get("content-length")
        if content_length:
            try:
                if int(content_length) < 0 or int(content_length) > 512 * 1024 * 1024:
                    raise HTTPException(status_code=413, detail="Agent upload exceeds 512 MiB.")
            except ValueError as exc:
                raise HTTPException(status_code=400, detail="Invalid Content-Length.") from exc

        async def upload_body():
            total = 0
            async for chunk in request.stream():
                total += len(chunk)
                if total > 512 * 1024 * 1024:
                    raise HTTPException(status_code=413, detail="Agent upload exceeds 512 MiB.")
                yield chunk

        upstream_headers = {}
        content_type = request.headers.get("content-type")
        if content_type and len(content_type) <= 200:
            upstream_headers["Content-Type"] = content_type
        for name in ("X-Forge-Overwrite", "X-Forge-Mkdirs", "X-Forge-Sha256"):
            value = request.headers.get(name)
            if value and len(value) <= 128:
                upstream_headers[name] = value
        await agent_slots.acquire()
        client = None
        upstream = None
        try:
            client, upstream = await open_agent_stream(
                "PUT", "/files", params={"destination": destination}, headers=upstream_headers, content=upload_body()
            )
            body = await upstream.aread()
            try:
                result = json.loads(body.decode("utf-8")) if body else {"ok": False, "errmsg": "empty backend-agent response"}
            except (UnicodeDecodeError, json.JSONDecodeError):
                result = {"ok": False, "errmsg": "invalid backend-agent response"}
            if not isinstance(result, dict):
                result = {"ok": False, "errmsg": "invalid backend-agent response"}
            return JSONResponse(result, status_code=upstream.status_code, headers={"Cache-Control": "no-store"})
        finally:
            if upstream is not None:
                await upstream.aclose()
            if client is not None:
                await client.aclose()
            agent_slots.release()

    async def synthesize_tts_audio(normalized: dict[str, Any]) -> TtsAudio:
        if normalized["engine"] == "local":
            async with local_tts_slots:
                return await local_tts_synthesize(
                    text=normalized["text"], voice=normalized["voice"],
                    speed=normalized["speed"], pitch=normalized["pitch"],
                    timeout_seconds=settings.upstream_timeout_seconds,
                    max_response_bytes=settings.max_response_bytes,
                )
        async with upstream_slots:
            return await tts_synthesize(
                normalized["provider"], engine=normalized["engine"], model=normalized["model"],
                text=normalized["text"], voice=normalized["voice"],
                language=normalized["language"], output_format=normalized["format"],
                speed=normalized["speed"], timeout_seconds=settings.upstream_timeout_seconds,
                max_response_bytes=settings.max_response_bytes,
            )

    @app.get("/api/v1/tts/voices")
    async def tts_voices(request: Request):
        require_app_access(request)
        requested_engine = request.query_params.get("engine", "").strip().lower()
        if requested_engine == "local":
            if request.query_params.get("providerId"):
                raise HTTPException(status_code=400, detail="providerId cannot be used with VM-local TTS.")
            catalog = local_voice_catalog()
            if not catalog.get("available"):
                raise HTTPException(status_code=503, detail=catalog.get("note", "VM-local TTS is unavailable."))
            return JSONResponse(catalog, headers={"Cache-Control": "no-store"})
        if requested_engine and requested_engine not in {"cloud", "openai", "xai"}:
            raise HTTPException(status_code=400, detail="Unsupported TTS engine.")
        available = list(app_provider_settings(request))
        provider_id = request.query_params.get("providerId", "")
        provider = next((item for item in available if provider_id and item.id == provider_id), None)
        if provider_id and provider is None:
            raise HTTPException(status_code=503, detail="The requested TTS provider is not enabled on the ForgeChat server.")
        if provider is None:
            provider = next((item for item in available if tts_engine(item)), None)
        if provider is None:
            raise HTTPException(status_code=503, detail="Cloud TTS requires a configured xAI or OpenAI-compatible provider.")
        catalog = voice_catalog(provider)
        if not catalog.get("available"):
            raise HTTPException(status_code=503, detail="Cloud TTS is unavailable for this provider.")
        return JSONResponse(catalog, headers={"Cache-Control": "no-store"})

    @app.post("/api/v1/transcribe")
    async def transcribe_audio_route(request: Request):
        check_origin(request)
        username = require_app_access(request)
        if ai_limiter.blocked(username):
            raise HTTPException(status_code=429, detail="AI request limit reached. Try again shortly.")
        ai_limiter.fail(username)
        raw = await read_json_limited(request, maximum=((MAX_AUDIO_BYTES + 2) // 3) * 4 + 64 * 1024)
        try:
            normalized = normalize_transcription_request(raw, list(app_provider_settings(request)))
        except LookupError as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        try:
            async with upstream_slots:
                result = await transcribe_audio(
                    normalized,
                    timeout_seconds=settings.upstream_timeout_seconds,
                    max_response_bytes=settings.max_response_bytes,
                )
        except UpstreamError as exc:
            status = 504 if exc.status_code in {408, 504} else 502
            raise HTTPException(status_code=status, detail="The configured speech-to-text provider request failed.") from exc
        except Exception as exc:
            raise HTTPException(status_code=502, detail="The configured speech-to-text provider request failed.") from exc
        if not isinstance(result, dict) or not isinstance(result.get("text"), str) or not result["text"].strip():
            raise HTTPException(status_code=502, detail="The speech-to-text provider returned an invalid transcript.")
        return JSONResponse(result, headers={"Cache-Control": "no-store"})

    @app.post("/api/v1/tts/synthesize")
    async def tts_synthesize_route(request: Request):
        check_origin(request)
        username = require_app_access(request)
        if ai_limiter.blocked(username):
            raise HTTPException(status_code=429, detail="AI request limit reached. Try again shortly.")
        ai_limiter.fail(username)
        raw = await read_json_limited(request)
        try:
            normalized = normalize_tts_request(raw, list(app_provider_settings(request)))
        except LookupError as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        try:
            audio = await synthesize_tts_audio(normalized)
        except LocalTtsUnavailable as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        except LocalTtsError as exc:
            raise HTTPException(status_code=502, detail=str(exc)) from exc
        except UpstreamError as exc:
            status = 504 if exc.status_code in {408, 504} else 502
            raise HTTPException(status_code=status, detail="The configured TTS provider request failed.") from exc
        except Exception as exc:
            raise HTTPException(status_code=502, detail="The TTS request failed.") from exc
        if not isinstance(audio, TtsAudio) or not audio.data or len(audio.data) > settings.max_response_bytes:
            raise HTTPException(status_code=502, detail="The TTS engine returned invalid audio.")
        return Response(
            content=audio.data,
            media_type=audio.mime,
            headers={"Cache-Control": "no-store", "X-Forge-TTS-Engine": audio.engine, "X-Forge-TTS-Voice": audio.voice},
        )

    @app.post("/api/v1/tts/synthesize-to-agent")
    async def tts_synthesize_to_agent(request: Request):
        check_origin(request)
        username = require_app_access(request)
        require_agent_access(request)
        if not settings.agent_enabled:
            raise HTTPException(status_code=503, detail="The backend agent is not configured.")
        if ai_limiter.blocked(username) or agent_limiter.blocked(username):
            raise HTTPException(status_code=429, detail="TTS or backend agent request limit reached.")
        ai_limiter.fail(username)
        agent_limiter.fail(username)
        raw = await read_json_limited(request)
        try:
            normalized = normalize_tts_request(raw, list(app_provider_settings(request)))
        except LookupError as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        destination = raw.get("destination")
        if not isinstance(destination, str) or not re.fullmatch(r"tts/[A-Za-z0-9][A-Za-z0-9_.-]{0,159}\.(?:mp3|wav|opus|aac|flac|pcm)", destination):
            raise HTTPException(status_code=400, detail="destination must be a filename under the agent tts/ workspace folder.")
        if destination.rsplit(".", 1)[-1].lower() != normalized["format"]:
            raise HTTPException(status_code=400, detail="destination extension must match the requested audio format.")
        async with agent_slots:
            agent_status, _agent_payload = await call_agent_json("GET", "/status")
        if agent_status >= 400:
            raise HTTPException(status_code=503, detail="The backend agent is not ready to store TTS output.")
        try:
            audio = await synthesize_tts_audio(normalized)
        except LocalTtsUnavailable as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        except LocalTtsError as exc:
            raise HTTPException(status_code=502, detail=str(exc)) from exc
        except UpstreamError as exc:
            status = 504 if exc.status_code in {408, 504} else 502
            raise HTTPException(status_code=status, detail="The configured TTS provider request failed.") from exc
        except Exception as exc:
            raise HTTPException(status_code=502, detail="The TTS request failed.") from exc
        if not isinstance(audio, TtsAudio) or not audio.data or len(audio.data) > settings.max_response_bytes:
            raise HTTPException(status_code=502, detail="The TTS engine returned invalid audio.")
        await agent_slots.acquire()
        try:
            client, upstream = await open_agent_stream(
                "PUT", "/files", params={"destination": destination},
                headers={"Content-Type": audio.mime, "X-Forge-Mkdirs": "true", "X-Forge-Overwrite": "false"},
                content=audio.data,
            )
        finally:
            agent_slots.release()
        try:
            await upstream.aread()
            if upstream.status_code >= 400:
                if upstream.status_code == 409:
                    raise HTTPException(status_code=409, detail="The TTS output file already exists in the agent workspace.")
                raise HTTPException(status_code=502, detail="Could not save TTS output to the backend agent workspace.")
        finally:
            await upstream.aclose()
            await client.aclose()
        return JSONResponse({
            "ok": True, "via": "forgechat-server", "agentPath": destination,
            "size": len(audio.data), "mime": audio.mime, "engine": audio.engine,
            "voice": audio.voice, "providerId": audio.provider_id,
        }, headers={"Cache-Control": "no-store"})

    @app.post("/api/v1/images/generate")
    async def generate_image(request: Request):
        check_origin(request)
        username = require_app_access(request)
        if ai_limiter.blocked(username):
            raise HTTPException(status_code=429, detail="AI request limit reached. Try again shortly.")
        ai_limiter.fail(username)
        raw = await read_json_limited(request)
        try:
            provider, model, prompt, count, images = normalize_image_request(raw, settings_for_app(request))
        except LookupError as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        try:
            async with upstream_slots:
                result = await image_call(
                    provider,
                    model,
                    prompt,
                    count=count,
                    images=images,
                    timeout_seconds=settings.upstream_timeout_seconds,
                    max_response_bytes=settings.max_response_bytes,
                )
        except UpstreamError as exc:
            status = 504 if exc.status_code in {408, 504} else 502
            raise HTTPException(status_code=status, detail="The configured image provider request failed.") from exc
        except Exception as exc:
            raise HTTPException(status_code=502, detail="The configured image provider request failed.") from exc
        return JSONResponse(result, headers={"Cache-Control": "no-store"})

    @app.post("/api/v1/chat")
    async def chat(request: Request):
        check_origin(request)
        username = require_app_access(request)
        if ai_limiter.blocked(username):
            raise HTTPException(status_code=429, detail="AI request limit reached. Try again shortly.")
        ai_limiter.fail(username)
        raw = await read_json_limited(request)
        try:
            provider, model, messages, temperature, max_tokens, response_format = normalize_request(raw, settings_for_app(request))
        except LookupError as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc

        try:
            async with upstream_slots:
                result = await provider_call(
                    provider,
                    model,
                    messages,
                    temperature=temperature,
                    max_tokens=max_tokens,
                    response_format=response_format,
                    timeout_seconds=settings.upstream_timeout_seconds,
                    max_response_bytes=settings.max_response_bytes,
                )
        except UpstreamError as exc:
            # Do not forward upstream error bodies, URLs, or credentials.
            status = 504 if exc.status_code in {408, 504} else 502
            raise HTTPException(status_code=status, detail="The configured AI provider request failed.") from exc
        except Exception as exc:
            raise HTTPException(status_code=502, detail="The configured AI provider request failed.") from exc
        return JSONResponse(result, headers={"Cache-Control": "no-store"})

    @app.post("/api/v1/chat/stream")
    async def chat_stream(request: Request):
        check_origin(request)
        username = require_app_access(request)
        if ai_limiter.blocked(username):
            raise HTTPException(status_code=429, detail="AI request limit reached. Try again shortly.")
        ai_limiter.fail(username)
        raw = await read_json_limited(request)
        try:
            provider, model, messages, temperature, max_tokens, response_format = normalize_request(raw, settings_for_app(request))
        except LookupError as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc

        async def events():
            try:
                async with upstream_slots:
                    async for text in provider_stream_call(
                        provider,
                        model,
                        messages,
                        temperature=temperature,
                        max_tokens=max_tokens,
                        response_format=response_format,
                        timeout_seconds=settings.upstream_timeout_seconds,
                        max_response_bytes=settings.max_response_bytes,
                    ):
                        if text:
                            event = json.dumps({"type": "delta", "content": text}, ensure_ascii=False)
                            yield "data: " + event + "\n\n"
                yield 'data: {"type":"done"}\n\n'
            except asyncio.CancelledError:
                raise
            except UpstreamError as exc:
                status = 504 if exc.status_code in {408, 504} else 502
                event = json.dumps({"type": "error", "status": status, "detail": "The configured AI provider request failed."})
                yield "data: " + event + "\n\n"
            except Exception:
                yield 'data: {"type":"error","status":502,"detail":"The configured AI provider request failed."}\n\n'

        return StreamingResponse(
            events(),
            media_type="text/event-stream",
            headers={"Cache-Control": "no-store", "X-Accel-Buffering": "no"},
        )

    return app


def _available_providers(providers: tuple[Provider, ...]) -> list[Provider]:
    return [provider for provider in providers if (provider.api_key or provider.auth_optional) and provider.default_model]


async def _configured_upstream_stream_call(
    provider: Provider,
    model: str,
    messages: list[dict[str, Any]],
    **options: Any,
) -> AsyncIterator[str]:
    async for text in call_upstream_stream(provider, model, messages, **options):
        yield text

async def _configured_image_generation_call(
    provider: Provider,
    model: str,
    prompt: str,
    **options: Any,
) -> dict[str, Any]:
    return await call_image_generation(provider, model, prompt, **options)

async def _configured_tts_call(provider: Provider, **options: Any) -> TtsAudio:
    return await call_tts(provider, **options)

async def _configured_transcription_call(request: dict[str, Any], **options: Any) -> dict[str, Any]:
    return await call_transcription(request, **options)

async def _configured_upstream_call(
    provider: Provider,
    model: str,
    messages: list[dict[str, str]],
    **options: Any,
) -> dict[str, Any]:
    return await call_upstream(provider, model, messages, **options)
