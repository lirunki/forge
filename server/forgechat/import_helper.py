"""Root-owned, narrow Unix-socket writer for web-initiated provider imports.

The unprivileged ForgeChat app can submit only a validated provider list. This
helper has fixed config destinations, no network access, and no shell interface.
"""
from __future__ import annotations

import grp
import json
import os
import re
import socketserver
import stat
import threading
from pathlib import Path
from typing import Any

from .config import ConfigError, _is_loopback_http_url, _validate_provider_url
from .import_backup import (
    ImportErrorSafe,
    ProviderCandidate,
    _ENV_VALUE,
    _PROVIDER_ID,
    apply_import,
)

SOCKET_PATH = Path("/run/forgechat-import/daemon.sock")
PROVIDERS_PATH = Path("/etc/forgechat/providers.json")
ENV_PATH = Path("/etc/forgechat/forgechat.env")
MAX_HELPER_REQUEST_BYTES = 2 * 1024 * 1024
_NO_KEY_ISSUE = "no saved API key (only loopback OpenAI-compatible providers may be keyless)"
_CONTROL = re.compile(r"[\x00-\x1f\x7f]")


def _validate_request(raw: bytes) -> list[ProviderCandidate]:
    if len(raw) > MAX_HELPER_REQUEST_BYTES:
        raise ImportErrorSafe("Provider import request is too large.")
    try:
        payload = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError, RecursionError) as exc:
        raise ImportErrorSafe("Provider import request is invalid.") from exc
    if not isinstance(payload, dict) or set(payload) != {"version", "providers"} or payload.get("version") != 1:
        raise ImportErrorSafe("Provider import request has an unsupported format.")
    records = payload.get("providers")
    if not isinstance(records, list) or not records or len(records) > 32:
        raise ImportErrorSafe("Select between one and 32 providers.")
    candidates: list[ProviderCandidate] = []
    seen: set[str] = set()
    for record in records:
        if not isinstance(record, dict) or set(record) != {
            "id", "label", "kind", "base_url", "default_model", "models", "key", "issue"
        }:
            raise ImportErrorSafe("Provider import record has an invalid shape.")
        provider_id = record["id"]
        label = record["label"]
        kind = record["kind"]
        base_url = record["base_url"]
        default_model = record["default_model"]
        models = record["models"]
        key = record["key"]
        issue = record["issue"]
        if not isinstance(provider_id, str) or not _PROVIDER_ID.fullmatch(provider_id) or provider_id in seen:
            raise ImportErrorSafe("Provider import contains an invalid or duplicate ID.")
        seen.add(provider_id)
        if not isinstance(label, str) or not label or len(label) > 100 or _CONTROL.search(label):
            raise ImportErrorSafe(f"Provider {provider_id} has an invalid label.")
        if kind not in {"openai", "gemini"}:
            raise ImportErrorSafe(f"Provider {provider_id} uses an unsupported protocol.")
        if not isinstance(base_url, str) or not base_url or len(base_url) > 2048 or _CONTROL.search(base_url):
            raise ImportErrorSafe(f"Provider {provider_id} has an invalid base URL.")
        try:
            _validate_provider_url(base_url)
        except ConfigError as exc:
            raise ImportErrorSafe(f"Provider {provider_id} has a disallowed base URL.") from exc
        if not isinstance(models, list) or not models or len(models) > 100:
            raise ImportErrorSafe(f"Provider {provider_id} has an invalid model list.")
        if any(not isinstance(model, str) or not model or len(model) > 200 or _CONTROL.search(model) for model in models):
            raise ImportErrorSafe(f"Provider {provider_id} has an invalid model list.")
        if len(set(models)) != len(models):
            raise ImportErrorSafe(f"Provider {provider_id} has duplicate model names.")
        if not isinstance(default_model, str) or default_model not in models:
            raise ImportErrorSafe(f"Provider {provider_id} has an invalid default model.")
        if not isinstance(key, str) or len(key) > 8192 or (key and not _ENV_VALUE.fullmatch(key)):
            raise ImportErrorSafe(f"Provider {provider_id} has an unsafe saved key.")
        if issue not in {"", _NO_KEY_ISSUE}:
            raise ImportErrorSafe(f"Provider {provider_id} is not importable.")
        if not key and not (kind == "openai" and _is_loopback_http_url(base_url)) and issue != _NO_KEY_ISSUE:
            raise ImportErrorSafe(f"Provider {provider_id} requires a saved server-side key.")
        candidates.append(ProviderCandidate(
            id=provider_id,
            label=label,
            kind=kind,
            base_url=base_url,
            default_model=default_model,
            models=tuple(models),
            key=key,
            issue=issue,
        ))
    return candidates


def _response(payload: dict[str, Any]) -> bytes:
    return (json.dumps(payload, separators=(",", ":"), ensure_ascii=True) + "\n").encode("utf-8")


class _ImportRequestHandler(socketserver.StreamRequestHandler):
    def handle(self) -> None:
        self.connection.settimeout(10)
        line = self.rfile.readline(MAX_HELPER_REQUEST_BYTES + 1)
        if not line.endswith(b"\n") or len(line) > MAX_HELPER_REQUEST_BYTES:
            self.wfile.write(_response({"ok": False, "detail": "Provider import request is too large or incomplete."}))
            return
        try:
            candidates = _validate_request(line[:-1])
            ids = [candidate.id for candidate in candidates]
            server = self.server
            with server.apply_lock:
                imported, _backups = apply_import(candidates, ids, PROVIDERS_PATH, ENV_PATH)
            self.wfile.write(_response({"ok": True, "imported": imported}))
        except ImportErrorSafe as exc:
            self.wfile.write(_response({"ok": False, "detail": str(exc)}))
        except Exception:
            # Never log request data, keys, or exception values.
            self.wfile.write(_response({"ok": False, "detail": "Provider import failed safely; check the VM service logs."}))


class _ImportServer(socketserver.UnixStreamServer):
    allow_reuse_address = False
    request_queue_size = 8

    def __init__(self, address: str):
        self.apply_lock = threading.Lock()
        super().__init__(address, _ImportRequestHandler)


def serve() -> None:
    if os.geteuid() != 0:
        raise SystemExit("provider import helper must run as root")
    socket_dir = SOCKET_PATH.parent
    if not socket_dir.is_dir() or socket_dir.stat().st_uid != 0:
        raise SystemExit("provider import socket directory must be root-owned")
    try:
        existing = SOCKET_PATH.lstat()
    except FileNotFoundError:
        existing = None
    if existing is not None:
        if not stat.S_ISSOCK(existing.st_mode) or existing.st_uid != 0:
            raise SystemExit("refusing to replace an unexpected provider import socket path")
        SOCKET_PATH.unlink()
    with _ImportServer(str(SOCKET_PATH)) as server:
        group = grp.getgrnam("forgechat").gr_gid
        os.chown(SOCKET_PATH, 0, group)
        os.chmod(SOCKET_PATH, 0o660)
        server.serve_forever(poll_interval=0.5)


if __name__ == "__main__":
    serve()
