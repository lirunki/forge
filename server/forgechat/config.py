"""Configuration for the ForgeChat ASGI service.

Secrets are read from the process environment. Provider endpoints are operator
configuration only; request data can never choose an upstream URL.
"""

from __future__ import annotations

import json
import os
import re
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit


class ConfigError(ValueError):
    """Raised when required or unsafe server configuration is found."""


@dataclass(frozen=True)
class Provider:
    id: str
    label: str
    kind: str
    base_url: str
    api_key: str
    default_model: str
    models: tuple[str, ...]
    auth_optional: bool = False
    image_models: tuple[str, ...] = ()

    def public_dict(self) -> dict[str, object]:
        return {
            "id": self.id,
            "label": self.label,
            "kind": self.kind,
            "models": list(self.models),
            "model": self.default_model,
            "available": bool((self.api_key or self.auth_optional) and self.default_model),
            "imageModels": list(self.image_models) if (self.api_key or self.auth_optional) else [],
        }


@dataclass(frozen=True)
class Settings:
    username: str
    password_hash: str
    session_secret: str
    public_origin: str
    base_path: str
    providers: tuple[Provider, ...]
    app_dir: Path = Path("/var/lib/forgechat/apps")
    access_db: Path | None = None
    session_seconds: int = 28800
    remember_session_seconds: int = 30 * 86400
    cookie_name: str = "forgechat_session"
    max_request_bytes: int = 12 * 1024 * 1024
    max_app_bytes: int = 10 * 1024 * 1024
    max_response_bytes: int = 2 * 1024 * 1024
    max_messages: int = 64
    max_message_chars: int = 100_000
    upstream_timeout_seconds: float = 90.0
    login_window_seconds: int = 900
    login_max_attempts: int = 10
    ai_rate_window_seconds: int = 60
    ai_rate_max_requests: int = 30
    ai_max_concurrent_requests: int = 2
    agent_url: str = "http://127.0.0.1:8788"
    agent_username: str = ""
    agent_password: str = ""
    agent_timeout_seconds: float = 150.0

    @property
    def agent_enabled(self) -> bool:
        return bool(self.agent_username and self.agent_password)

    @classmethod
    def from_env(cls) -> "Settings":
        username = os.environ.get("FORGECHAT_USERNAME", "").strip()
        password_hash = os.environ.get("FORGECHAT_PASSWORD_HASH", "").strip()
        session_secret = os.environ.get("FORGECHAT_SESSION_SECRET", "")
        public_origin = os.environ.get("FORGECHAT_PUBLIC_ORIGIN", "").rstrip("/")
        base_path = _normalize_base_path(os.environ.get("FORGECHAT_BASE_PATH", "/forgechat"))
        if not username or len(username) > 128:
            raise ConfigError("FORGECHAT_USERNAME must be set (max 128 characters).")
        if not _valid_password_hash(password_hash):
            raise ConfigError("FORGECHAT_PASSWORD_HASH must be a generated pbkdf2_sha256 hash.")
        if len(session_secret) < 32:
            raise ConfigError("FORGECHAT_SESSION_SECRET must be at least 32 characters of random data.")
        _validate_origin(public_origin)
        providers = _load_providers(os.environ.get("FORGECHAT_PROVIDERS_FILE", ""))
        agent_url = os.environ.get("FORGECHAT_AGENT_URL", "http://127.0.0.1:8788").rstrip("/")
        _validate_agent_url(agent_url)
        agent_username = os.environ.get("FORGECHAT_AGENT_USERNAME", "").strip()
        agent_password = os.environ.get("FORGECHAT_AGENT_PASSWORD", "")
        if bool(agent_username) != bool(agent_password):
            raise ConfigError("FORGECHAT_AGENT_USERNAME and FORGECHAT_AGENT_PASSWORD must be set together.")
        if len(agent_username) > 128 or len(agent_password) > 512:
            raise ConfigError("ForgeChat agent credentials exceed the configured length limits.")
        app_dir = Path(os.environ.get("FORGECHAT_APP_DIR", "/var/lib/forgechat/apps")).expanduser()
        access_db_raw = os.environ.get("FORGECHAT_ACCESS_DB", "").strip()
        access_db = Path(access_db_raw).expanduser() if access_db_raw else app_dir / ".access.sqlite3"
        return cls(
            username=username,
            password_hash=password_hash,
            session_secret=session_secret,
            public_origin=public_origin,
            base_path=base_path,
            providers=tuple(providers),
            app_dir=app_dir,
            access_db=access_db,
            session_seconds=_positive_int("FORGECHAT_SESSION_SECONDS", 28800, maximum=7 * 86400),
            remember_session_seconds=_positive_int("FORGECHAT_REMEMBER_SESSION_SECONDS", 30 * 86400, maximum=90 * 86400),
            max_request_bytes=_positive_int("FORGECHAT_MAX_REQUEST_BYTES", 12 * 1024 * 1024, maximum=24 * 1024 * 1024),
            max_app_bytes=_positive_int("FORGECHAT_MAX_APP_BYTES", 10 * 1024 * 1024, maximum=20 * 1024 * 1024),
            max_response_bytes=_positive_int("FORGECHAT_MAX_RESPONSE_BYTES", 2 * 1024 * 1024, maximum=10 * 1024 * 1024),
            max_messages=_positive_int("FORGECHAT_MAX_MESSAGES", 64, maximum=256),
            max_message_chars=_positive_int("FORGECHAT_MAX_MESSAGE_CHARS", 100_000, maximum=500_000),
            upstream_timeout_seconds=_positive_float("FORGECHAT_UPSTREAM_TIMEOUT_SECONDS", 90.0, maximum=300.0),
            ai_rate_window_seconds=_positive_int("FORGECHAT_AI_RATE_WINDOW_SECONDS", 60, maximum=3600),
            ai_rate_max_requests=_positive_int("FORGECHAT_AI_RATE_MAX_REQUESTS", 30, maximum=1000),
            ai_max_concurrent_requests=_positive_int("FORGECHAT_AI_MAX_CONCURRENT_REQUESTS", 2, maximum=32),
            agent_url=agent_url,
            agent_username=agent_username,
            agent_password=agent_password,
            agent_timeout_seconds=_positive_float("FORGECHAT_AGENT_TIMEOUT_SECONDS", 150.0, maximum=1800.0),
        )


def _positive_int(name: str, default: int, maximum: int) -> int:
    raw = os.environ.get(name, str(default))
    try:
        value = int(raw)
    except ValueError as exc:
        raise ConfigError(f"{name} must be a positive integer.") from exc
    if not 1 <= value <= maximum:
        raise ConfigError(f"{name} must be between 1 and {maximum}.")
    return value


def _positive_float(name: str, default: float, maximum: float) -> float:
    raw = os.environ.get(name, str(default))
    try:
        value = float(raw)
    except ValueError as exc:
        raise ConfigError(f"{name} must be a positive number.") from exc
    if not 0 < value <= maximum:
        raise ConfigError(f"{name} must be greater than zero and no more than {maximum}.")
    return value


def _valid_password_hash(value: str) -> bool:
    parts = value.split("$")
    if len(parts) != 4 or parts[0] != "pbkdf2_sha256":
        return False
    try:
        rounds = int(parts[1])
        salt = bytes.fromhex(parts[2])
        digest = bytes.fromhex(parts[3])
    except ValueError:
        return False
    return 100_000 <= rounds <= 2_000_000 and len(salt) >= 16 and len(digest) == 32


def _normalize_base_path(value: str) -> str:
    path = "/" + value.strip("/") if value.strip("/") else ""
    if path and not re.fullmatch(r"/[A-Za-z0-9/_-]+", path):
        raise ConfigError("FORGECHAT_BASE_PATH may contain only letters, digits, slash, underscore, and hyphen.")
    if path.endswith("/"):
        path = path[:-1]
    return path


def _validate_origin(value: str) -> None:
    try:
        parsed = urlsplit(value)
        port = parsed.port
    except ValueError as exc:
        raise ConfigError("FORGECHAT_PUBLIC_ORIGIN is not a valid origin.") from exc
    local_http = parsed.scheme == "http" and parsed.hostname in {"localhost", "127.0.0.1", "::1"}
    if (parsed.scheme != "https" and not local_http) or not parsed.hostname or parsed.path not in {"", "/"} or parsed.query or parsed.fragment or parsed.username or parsed.password:
        raise ConfigError("FORGECHAT_PUBLIC_ORIGIN must be an HTTPS origin (HTTP is allowed only for localhost development).")
    if port is not None and not 1 <= port <= 65535:
        raise ConfigError("FORGECHAT_PUBLIC_ORIGIN has an invalid port.")


def _load_providers(filename: str) -> list[Provider]:
    if not filename:
        return []
    try:
        source = json.loads(Path(filename).read_text(encoding="utf-8"))
    except OSError as exc:
        raise ConfigError("Could not read FORGECHAT_PROVIDERS_FILE.") from exc
    except json.JSONDecodeError as exc:
        raise ConfigError("FORGECHAT_PROVIDERS_FILE must contain valid JSON.") from exc
    if not isinstance(source, list) or len(source) > 32:
        raise ConfigError("Provider configuration must be a JSON array with at most 32 entries.")
    result: list[Provider] = []
    seen: set[str] = set()
    for item in source:
        if not isinstance(item, dict):
            raise ConfigError("Every provider entry must be an object.")
        provider_id = str(item.get("id", ""))
        if not re.fullmatch(r"[a-z][a-z0-9_-]{0,31}", provider_id) or provider_id in seen:
            raise ConfigError("Provider IDs must be unique lowercase identifiers.")
        seen.add(provider_id)
        kind = str(item.get("kind", ""))
        if kind not in {"openai", "gemini"}:
            raise ConfigError(f"Provider {provider_id} has unsupported kind; use openai or gemini.")
        label = str(item.get("label", provider_id))[:100]
        base_url = str(item.get("base_url", "")).rstrip("/")
        _validate_provider_url(base_url)
        model = str(item.get("default_model", ""))
        models_raw = item.get("models", [model] if model else [])
        if not isinstance(models_raw, list) or len(models_raw) > 100:
            raise ConfigError(f"Provider {provider_id} models must be an array of at most 100 strings.")
        models = tuple(dict.fromkeys(str(value)[:200] for value in models_raw if isinstance(value, str) and value.strip()))
        if model and model not in models:
            models = (model,) + models
        image_models_raw = item.get("image_models")
        if image_models_raw is None:
            image_models = ("grok-imagine-image", "grok-imagine-image-2.0", "grok-2-image") if provider_id == "xai" and kind == "openai" else ()
        else:
            if kind != "openai" or not isinstance(image_models_raw, list) or len(image_models_raw) > 8:
                raise ConfigError(f"Provider {provider_id} image_models must be an array of at most 8 OpenAI-compatible model IDs.")
            if any(not isinstance(value, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._:/-]{0,199}", value.strip()) for value in image_models_raw):
                raise ConfigError(f"Provider {provider_id} image_models contains an invalid model ID.")
            image_models = tuple(dict.fromkeys(value.strip() for value in image_models_raw))
        api_key_env = str(item.get("api_key_env", ""))
        auth_optional = not api_key_env
        if auth_optional and (kind != "openai" or not _is_loopback_http_url(base_url)):
            raise ConfigError(f"Provider {provider_id} may omit api_key_env only for a loopback OpenAI-compatible endpoint.")
        if api_key_env and not re.fullmatch(r"[A-Z][A-Z0-9_]{2,127}", api_key_env):
            raise ConfigError(f"Provider {provider_id} api_key_env must name an uppercase environment variable.")
        result.append(Provider(
            id=provider_id,
            label=label,
            kind=kind,
            base_url=base_url,
            api_key=os.environ.get(api_key_env, "").strip() if api_key_env else "",
            default_model=model,
            models=models,
            auth_optional=auth_optional,
            image_models=image_models,
        ))
    return result


def _is_loopback_http_url(value: str) -> bool:
    parsed = urlsplit(value)
    return parsed.scheme == "http" and parsed.hostname in {"localhost", "127.0.0.1", "::1"}


def _validate_agent_url(value: str) -> None:
    try:
        parsed = urlsplit(value)
        _ = parsed.port
    except ValueError as exc:
        raise ConfigError("FORGECHAT_AGENT_URL is invalid.") from exc
    if (not _is_loopback_http_url(value) or not parsed.hostname or parsed.username or parsed.password
            or parsed.query or parsed.fragment or (parsed.path and not parsed.path.startswith("/")) or ".." in parsed.path.split("/")):
        raise ConfigError("FORGECHAT_AGENT_URL must be a loopback HTTP URL without credentials, query, or fragment.")


def _validate_provider_url(value: str) -> None:
    try:
        parsed = urlsplit(value)
        _ = parsed.port
    except ValueError as exc:
        raise ConfigError("Provider base_url is invalid.") from exc
    local_http = parsed.scheme == "http" and parsed.hostname in {"localhost", "127.0.0.1", "::1"}
    if (parsed.scheme != "https" and not local_http) or not parsed.hostname or parsed.username or parsed.password or parsed.query or parsed.fragment:
        raise ConfigError("Provider base_url must be HTTPS (HTTP is allowed only for localhost) and contain no credentials/query.")
    if not parsed.path.startswith("/") or ".." in parsed.path.split("/"):
        raise ConfigError("Provider base_url path is invalid.")
