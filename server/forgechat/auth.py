"""Password hashing and signed-cookie session helpers (stdlib only)."""

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import secrets
import time
from typing import Any


PBKDF2_ROUNDS = 310_000


def hash_password(password: str, *, salt: bytes | None = None, rounds: int = PBKDF2_ROUNDS) -> str:
    if not isinstance(password, str) or len(password) < 9 or len(password) > 1024:
        raise ValueError("Password must be between 9 and 1024 characters.")
    salt = salt or secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, rounds, dklen=32)
    return f"pbkdf2_sha256${rounds}${salt.hex()}${digest.hex()}"


def verify_password(password: str, encoded: str) -> bool:
    try:
        algorithm, raw_rounds, raw_salt, raw_digest = encoded.split("$")
        if algorithm != "pbkdf2_sha256":
            return False
        rounds = int(raw_rounds)
        salt = bytes.fromhex(raw_salt)
        expected = bytes.fromhex(raw_digest)
        if not 100_000 <= rounds <= 2_000_000 or len(salt) < 16 or len(expected) != 32:
            return False
    except (AttributeError, ValueError):
        return False
    actual = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, rounds, dklen=32)
    return hmac.compare_digest(actual, expected)


def create_session(username: str, secret: str, expires_at: int, *, session_version: int = 0) -> str:
    payload = _b64url(json.dumps({"sub": username, "exp": expires_at, "jti": secrets.token_urlsafe(18), "ver": int(session_version)}, separators=(",", ":")).encode("utf-8"))
    signature = _b64url(hmac.new(secret.encode("utf-8"), payload.encode("ascii"), hashlib.sha256).digest())
    return payload + "." + signature


def read_session_claims(token: str | None, secret: str, *, now: int | None = None) -> dict[str, Any] | None:
    if not token or len(token) > 2048 or token.count(".") != 1:
        return None
    payload, signature = token.split(".", 1)
    expected = _b64url(hmac.new(secret.encode("utf-8"), payload.encode("ascii"), hashlib.sha256).digest())
    if not hmac.compare_digest(signature, expected):
        return None
    try:
        data: Any = json.loads(_unb64url(payload))
        expires_at = int(data["exp"])
        username = data["sub"]
        session_id = data["jti"]
        session_version = data.get("ver", 0)
    except (ValueError, TypeError, KeyError, UnicodeDecodeError):
        return None
    current = int(time.time()) if now is None else now
    if (not isinstance(username, str) or not username or not isinstance(session_id, str) or not session_id
            or not isinstance(session_version, int) or session_version < 0 or expires_at <= current):
        return None
    return {"username": username, "expires_at": expires_at, "session_id": session_id, "session_version": session_version}


def read_session(token: str | None, secret: str, *, now: int | None = None) -> str | None:
    claims = read_session_claims(token, secret, now=now)
    return claims["username"] if claims else None


def random_session_secret() -> str:
    return secrets.token_urlsafe(48)


def _b64url(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


def _unb64url(value: str) -> bytes:
    return base64.urlsafe_b64decode(value + "=" * (-len(value) % 4))
