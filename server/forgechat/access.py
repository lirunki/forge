"""SQLite-backed ForgeChat accounts and per-app allow-lists."""
from __future__ import annotations

import json
import os
import re
import sqlite3
import threading
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Iterable

_USERNAME = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$")
_APP_ID = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_-]{0,79}$")


class AccessError(ValueError):
    """A safe user/account/access operation error."""


class AccessStore:
    """Persistent user accounts and app allow-lists, stored outside the web root."""

    def __init__(self, path: str | Path):
        self.path = Path(path)
        self._lock = threading.RLock()
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._initialize()

    def _connect(self) -> sqlite3.Connection:
        connection = sqlite3.connect(self.path, timeout=10, isolation_level=None)
        connection.row_factory = sqlite3.Row
        connection.execute("PRAGMA foreign_keys = ON")
        connection.execute("PRAGMA busy_timeout = 10000")
        return connection

    @contextmanager
    def _db(self):
        connection = self._connect()
        try:
            yield connection
        finally:
            connection.close()

    def _initialize(self) -> None:
        with self._lock, self._db() as connection:
            connection.executescript(
                """
                CREATE TABLE IF NOT EXISTS users (
                    username TEXT COLLATE NOCASE PRIMARY KEY,
                    password_hash TEXT NOT NULL,
                    role TEXT NOT NULL CHECK (role IN ('owner','user')),
                    enabled INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0,1)),
                    session_version INTEGER NOT NULL DEFAULT 0,
                    created_at REAL NOT NULL,
                    updated_at REAL NOT NULL
                );
                CREATE TABLE IF NOT EXISTS app_access (
                    app_id TEXT NOT NULL,
                    username TEXT COLLATE NOCASE NOT NULL REFERENCES users(username) ON DELETE CASCADE,
                    created_at REAL NOT NULL,
                    PRIMARY KEY (app_id, username)
                );
                CREATE INDEX IF NOT EXISTS app_access_user_idx ON app_access(username);
                CREATE TABLE IF NOT EXISTS agent_access (
                    username TEXT COLLATE NOCASE PRIMARY KEY REFERENCES users(username) ON DELETE CASCADE,
                    created_at REAL NOT NULL
                );
                CREATE TABLE IF NOT EXISTS app_provider_settings (
                    app_id TEXT PRIMARY KEY,
                    provider_ids TEXT NOT NULL,
                    default_provider_id TEXT NOT NULL,
                    updated_at REAL NOT NULL
                );
                """
            )
        try:
            os.chmod(self.path, 0o600)
        except OSError:
            pass

    @staticmethod
    def validate_username(username: str) -> str:
        value = username.strip() if isinstance(username, str) else ""
        if not _USERNAME.fullmatch(value):
            raise AccessError("Username must be 1–64 characters using letters, numbers, dot, underscore, or hyphen.")
        return value

    @staticmethod
    def validate_app_id(app_id: str) -> str:
        if not isinstance(app_id, str) or not _APP_ID.fullmatch(app_id):
            raise AccessError("Invalid app ID.")
        return app_id

    def ensure_owner(self, username: str, password_hash: str) -> None:
        username = self.validate_username(username)
        now = time.time()
        with self._lock, self._db() as connection:
            connection.execute("BEGIN IMMEDIATE")
            row = connection.execute("SELECT username FROM users WHERE username = ?", (username,)).fetchone()
            if row is None:
                connection.execute(
                    "INSERT INTO users(username,password_hash,role,enabled,session_version,created_at,updated_at) VALUES(?,?, 'owner',1,0,?,?)",
                    (username, password_hash, now, now),
                )
            else:
                # Env configuration seeds the owner only once. Password changes made
                # later through the UI persist across restarts and are not overwritten.
                connection.execute("UPDATE users SET role='owner', updated_at=? WHERE username=?", (now, username))
            connection.execute("UPDATE users SET role='user' WHERE role='owner' AND username != ?", (username,))
            connection.commit()

    def get_user(self, username: str) -> dict[str, Any] | None:
        if not isinstance(username, str):
            return None
        with self._lock, self._db() as connection:
            row = connection.execute(
                "SELECT username,password_hash,role,enabled,session_version,created_at,updated_at FROM users WHERE username=?",
                (username,),
            ).fetchone()
        return dict(row) if row else None

    def list_users(self) -> list[dict[str, Any]]:
        with self._lock, self._db() as connection:
            rows = connection.execute(
                "SELECT u.username,u.role,u.enabled,u.created_at,u.updated_at,"
                "CASE WHEN u.role='owner' THEN 1 ELSE EXISTS(SELECT 1 FROM agent_access a WHERE a.username=u.username) END AS agent_access "
                "FROM users u ORDER BY CASE u.role WHEN 'owner' THEN 0 ELSE 1 END, u.username COLLATE NOCASE"
            ).fetchall()
        return [dict(row) for row in rows]

    def create_user(self, username: str, password_hash: str) -> dict[str, Any]:
        username = self.validate_username(username)
        now = time.time()
        try:
            with self._lock, self._db() as connection:
                connection.execute(
                    "INSERT INTO users(username,password_hash,role,enabled,session_version,created_at,updated_at) VALUES(?,?,'user',1,0,?,?)",
                    (username, password_hash, now, now),
                )
        except sqlite3.IntegrityError as exc:
            raise AccessError("That username already exists.") from exc
        return self.get_user(username) or {}

    def set_password(self, username: str, password_hash: str) -> dict[str, Any] | None:
        with self._lock, self._db() as connection:
            connection.execute("BEGIN IMMEDIATE")
            cursor = connection.execute(
                "UPDATE users SET password_hash=?,session_version=session_version+1,updated_at=? WHERE username=?",
                (password_hash, time.time(), username),
            )
            connection.commit()
        return self.get_user(username) if cursor.rowcount else None

    def set_enabled(self, username: str, enabled: bool) -> dict[str, Any] | None:
        with self._lock, self._db() as connection:
            connection.execute("BEGIN IMMEDIATE")
            cursor = connection.execute(
                "UPDATE users SET enabled=?,session_version=session_version+CASE WHEN enabled != ? THEN 1 ELSE 0 END,updated_at=? WHERE username=? AND role='user'",
                (int(enabled), int(enabled), time.time(), username),
            )
            connection.commit()
        return self.get_user(username) if cursor.rowcount else None

    def delete_user(self, username: str) -> bool:
        with self._lock, self._db() as connection:
            cursor = connection.execute("DELETE FROM users WHERE username=? AND role='user'", (username,))
        return bool(cursor.rowcount)

    def allowed_usernames(self, app_id: str) -> list[str]:
        self.validate_app_id(app_id)
        with self._lock, self._db() as connection:
            rows = connection.execute(
                "SELECT u.username FROM app_access a JOIN users u ON u.username=a.username WHERE a.app_id=? AND u.enabled=1 ORDER BY u.username COLLATE NOCASE",
                (app_id,),
            ).fetchall()
        return [str(row[0]) for row in rows]

    def set_app_users(self, app_id: str, usernames: Iterable[str]) -> list[str]:
        self.validate_app_id(app_id)
        normalized: list[str] = []
        seen: set[str] = set()
        for name in usernames:
            valid_name = self.validate_username(name)
            key = valid_name.casefold()
            if key not in seen:
                seen.add(key)
                normalized.append(valid_name)
        with self._lock, self._db() as connection:
            connection.execute("BEGIN IMMEDIATE")
            if normalized:
                placeholders = ",".join("?" for _ in normalized)
                rows = connection.execute(
                    f"SELECT username FROM users WHERE role='user' AND enabled=1 AND username IN ({placeholders})",
                    normalized,
                ).fetchall()
                canonical = {str(row[0]).casefold(): str(row[0]) for row in rows}
                missing = [name for name in normalized if name.casefold() not in canonical]
                if missing:
                    connection.rollback()
                    raise AccessError("Select only existing, enabled app users.")
                normalized = [canonical[name.casefold()] for name in normalized]
            connection.execute("DELETE FROM app_access WHERE app_id=?", (app_id,))
            now = time.time()
            connection.executemany(
                "INSERT INTO app_access(app_id,username,created_at) VALUES(?,?,?)",
                [(app_id, username, now) for username in normalized],
            )
            connection.commit()
        return normalized

    def user_can_access(self, username: str, app_id: str) -> bool:
        self.validate_app_id(app_id)
        with self._lock, self._db() as connection:
            row = connection.execute(
                "SELECT 1 FROM app_access a JOIN users u ON u.username=a.username WHERE a.app_id=? AND u.username=? AND u.enabled=1 AND u.role='user'",
                (app_id, username),
            ).fetchone()
        return row is not None

    def user_app_ids(self, username: str) -> list[str]:
        with self._lock, self._db() as connection:
            rows = connection.execute(
                "SELECT a.app_id FROM app_access a JOIN users u ON u.username=a.username WHERE u.username=? AND u.enabled=1 AND u.role='user' ORDER BY a.app_id",
                (username,),
            ).fetchall()
        return [str(row[0]) for row in rows]

    def user_can_access_agent(self, username: str) -> bool:
        if not isinstance(username, str):
            return False
        with self._lock, self._db() as connection:
            row = connection.execute(
                "SELECT 1 FROM users u JOIN agent_access a ON a.username=u.username "
                "WHERE u.username=? AND u.role='user' AND u.enabled=1",
                (username,),
            ).fetchone()
        return row is not None

    def set_agent_access(self, username: str, allowed: bool) -> bool:
        username = self.validate_username(username)
        with self._lock, self._db() as connection:
            connection.execute("BEGIN IMMEDIATE")
            row = connection.execute(
                "SELECT role,enabled FROM users WHERE username=?", (username,)
            ).fetchone()
            if row is None or row["role"] != "user" or not row["enabled"]:
                connection.rollback()
                raise AccessError("Select an existing, enabled app user.")
            if allowed:
                connection.execute(
                    "INSERT OR IGNORE INTO agent_access(username,created_at) VALUES(?,?)",
                    (username, time.time()),
                )
            else:
                connection.execute("DELETE FROM agent_access WHERE username=?", (username,))
            connection.commit()
        return bool(allowed)

    def app_provider_settings(self, app_id: str) -> dict[str, Any] | None:
        app_id = self.validate_app_id(app_id)
        with self._lock, self._db() as connection:
            row = connection.execute(
                "SELECT provider_ids,default_provider_id FROM app_provider_settings WHERE app_id=?", (app_id,)
            ).fetchone()
        if row is None:
            return None
        try:
            provider_ids = json.loads(row["provider_ids"])
        except (TypeError, json.JSONDecodeError):
            return None
        if not isinstance(provider_ids, list) or not all(isinstance(value, str) for value in provider_ids):
            return None
        return {"providerIds": provider_ids, "defaultProviderId": str(row["default_provider_id"])}

    def set_app_providers(self, app_id: str, provider_ids: Iterable[str], default_provider_id: str) -> dict[str, Any]:
        app_id = self.validate_app_id(app_id)
        if isinstance(provider_ids, (str, bytes)):
            raise AccessError("Select at least one provider.")
        normalized: list[str] = []
        seen: set[str] = set()
        for provider_id in provider_ids:
            if not isinstance(provider_id, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,79}", provider_id):
                raise AccessError("Provider IDs must be valid provider identifiers.")
            if provider_id not in seen:
                normalized.append(provider_id)
                seen.add(provider_id)
        if not normalized or len(normalized) > 32:
            raise AccessError("Select between 1 and 32 providers.")
        if not isinstance(default_provider_id, str) or default_provider_id not in seen:
            raise AccessError("The default provider must be one of the selected providers.")
        with self._lock, self._db() as connection:
            connection.execute(
                "INSERT INTO app_provider_settings(app_id,provider_ids,default_provider_id,updated_at) VALUES(?,?,?,?) "
                "ON CONFLICT(app_id) DO UPDATE SET provider_ids=excluded.provider_ids,default_provider_id=excluded.default_provider_id,updated_at=excluded.updated_at",
                (app_id, json.dumps(normalized, separators=(",", ":")), default_provider_id, time.time()),
            )
        return {"providerIds": normalized, "defaultProviderId": default_provider_id}

    def forget_app(self, app_id: str) -> None:
        self.validate_app_id(app_id)
        with self._lock, self._db() as connection:
            connection.execute("DELETE FROM app_access WHERE app_id=?", (app_id,))
            connection.execute("DELETE FROM app_provider_settings WHERE app_id=?", (app_id,))
