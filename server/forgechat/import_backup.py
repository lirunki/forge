"""Import selected provider settings from a ForgeLibrary backup ZIP.

This is an offline, root-run administrative utility. It reads only
ForgeLibrary/settings.json; app HTML and all other archive entries are ignored.
Secret values are never printed or written to providers.json.
"""
from __future__ import annotations

import argparse
import grp
import json
import os
import re
import shutil
import stat
import sys
import tempfile
import time
import zipfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from .config import ConfigError, _is_loopback_http_url, _validate_provider_url

SETTINGS_ENTRY = "ForgeLibrary/settings.json"
SETTINGS_FORMAT = "forge-drive-settings-v1"
MAX_ARCHIVE_BYTES = 128 * 1024 * 1024
MAX_SETTINGS_BYTES = 2 * 1024 * 1024
_PROVIDER_ID = re.compile(r"^[a-z][a-z0-9_-]{0,31}$")
_ENV_NAME = re.compile(r"^[A-Z][A-Z0-9_]{2,127}$")
_ENV_VALUE = re.compile(r"^[A-Za-z0-9._~+/=:-]+$")
_ENV_ASSIGNMENT = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=")
_RESERVED_ENV_NAMES = {
    "FORGECHAT_USERNAME", "FORGECHAT_PASSWORD_HASH", "FORGECHAT_SESSION_SECRET",
    "FORGECHAT_PUBLIC_ORIGIN", "FORGECHAT_BASE_PATH", "FORGECHAT_APP_DIR",
    "FORGECHAT_PROVIDERS_FILE", "FORGECHAT_SESSION_SECONDS",
    "FORGECHAT_REMEMBER_SESSION_SECONDS", "FORGECHAT_MAX_REQUEST_BYTES",
    "FORGECHAT_MAX_APP_BYTES", "FORGECHAT_MAX_RESPONSE_BYTES",
    "FORGECHAT_MAX_MESSAGES", "FORGECHAT_MAX_MESSAGE_CHARS",
    "FORGECHAT_UPSTREAM_TIMEOUT_SECONDS", "FORGECHAT_LOGIN_WINDOW_SECONDS",
    "FORGECHAT_LOGIN_MAX_ATTEMPTS", "FORGECHAT_AI_RATE_WINDOW_SECONDS",
    "FORGECHAT_AI_RATE_MAX_REQUESTS", "FORGECHAT_AI_MAX_CONCURRENT_REQUESTS",
}

# Forge's built-in providers that use the OpenAI Chat Completions API, plus its
# native Gemini provider. Azure is intentionally excluded: the server adapter
# does not implement Azure deployment/version/auth semantics.
_BUILTINS: dict[str, tuple[str, str, str]] = {
    "gemini": ("gemini", "Google Gemini", "https://generativelanguage.googleapis.com/v1beta"),
    "cheaperinference": ("openai", "Cheaper Inference", "https://api.cheaperinference.com/v1"),
    "xai": ("openai", "xAI", "https://api.x.ai/v1"),
    "openai": ("openai", "OpenAI", "https://api.openai.com/v1"),
    "huggingface": ("openai", "Hugging Face", "https://router.huggingface.co/v1"),
}
_UNSUPPORTED_BUILTINS = {"azure"}


class ImportErrorSafe(ValueError):
    """A user-facing import error that never includes secret values."""


@dataclass(frozen=True)
class ProviderCandidate:
    id: str
    label: str
    kind: str
    base_url: str
    default_model: str
    models: tuple[str, ...]
    key: str = field(default="", repr=False)
    issue: str = ""

    def preview(self) -> dict[str, Any]:
        """Return terminal-safe metadata; deliberately omit the key itself."""
        clean = lambda value: "".join(char if char.isprintable() else "?" for char in str(value))[:200]
        return {
            "id": clean(self.id),
            "label": clean(self.label),
            "kind": clean(self.kind),
            "base_url": clean(self.base_url),
            "default_model": clean(self.default_model),
            "models": [clean(value) for value in self.models],
            "key_saved": bool(self.key),
            "issue": clean(self.issue),
        }


def read_forge_settings(archive_path: str | Path) -> dict[str, Any]:
    path = Path(archive_path)
    try:
        if path.is_symlink() or not path.is_file():
            raise ImportErrorSafe("Backup path must be a regular, non-symlink ZIP file.")
        info_stat = path.stat()
        if stat.S_IMODE(info_stat.st_mode) & 0o077:
            raise ImportErrorSafe("Backup ZIP must be private (owner-only permissions, such as mode 0600).")
        if info_stat.st_size > MAX_ARCHIVE_BYTES:
            raise ImportErrorSafe("Backup ZIP exceeds the 128 MiB size limit.")
    except ImportErrorSafe:
        raise
    except OSError as exc:
        raise ImportErrorSafe("Could not read a valid Forge backup ZIP.") from exc
    return _parse_forge_settings(path)


def read_forge_settings_bytes(data: bytes | bytearray) -> dict[str, Any]:
    """Parse an uploaded archive in memory; callers must enforce their upload cap."""
    if not isinstance(data, (bytes, bytearray)) or len(data) > MAX_ARCHIVE_BYTES:
        raise ImportErrorSafe("Backup ZIP exceeds the 128 MiB size limit.")
    import io
    return _parse_forge_settings(io.BytesIO(data))


def _parse_forge_settings(source: Any) -> dict[str, Any]:
    try:
        with zipfile.ZipFile(source, "r") as archive:
            entries = archive.infolist()
            if len(entries) > 10_000:
                raise ImportErrorSafe("Backup ZIP contains too many entries.")
            matches = [i for i in entries if i.filename == SETTINGS_ENTRY or i.filename.endswith("/" + SETTINGS_ENTRY)]
            if len(matches) != 1:
                raise ImportErrorSafe("ZIP must contain exactly one ForgeLibrary/settings.json file.")
            info = matches[0]
            if info.flag_bits & 0x1:
                raise ImportErrorSafe("Encrypted backup ZIPs are not supported; use Forge's standard backup export.")
            if info.file_size > MAX_SETTINGS_BYTES or info.compress_size > MAX_SETTINGS_BYTES:
                raise ImportErrorSafe("Forge settings.json exceeds the 2 MiB size limit.")
            if info.compress_size and info.file_size / info.compress_size > 200:
                raise ImportErrorSafe("Forge settings.json has an unsafe compression ratio.")
            with archive.open(info, "r") as stream:
                raw = stream.read(MAX_SETTINGS_BYTES + 1)
            if len(raw) > MAX_SETTINGS_BYTES:
                raise ImportErrorSafe("Forge settings.json exceeds the 2 MiB size limit.")
    except ImportErrorSafe:
        raise
    except (OSError, EOFError, zipfile.BadZipFile, RuntimeError, NotImplementedError) as exc:
        raise ImportErrorSafe("Could not read a valid Forge backup ZIP.") from exc
    try:
        settings = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError, RecursionError) as exc:
        raise ImportErrorSafe("ForgeLibrary/settings.json is not valid UTF-8 JSON.") from exc
    if not isinstance(settings, dict) or settings.get("format") != SETTINGS_FORMAT:
        raise ImportErrorSafe("ZIP does not contain a supported Forge provider-settings backup.")
    return settings


def _provider_key(settings: dict[str, Any], provider_id: str) -> str:
    profiles = settings.get("profiles") if isinstance(settings.get("profiles"), dict) else {}
    profile = profiles.get(provider_id) if isinstance(profiles.get(provider_id), dict) else {}
    direct = profile.get("key")
    if isinstance(direct, str) and direct.strip():
        return direct.strip()

    matches: list[tuple[int, str]] = []
    known = settings.get("knownKeys") if isinstance(settings.get("knownKeys"), list) else []
    for item in known:
        if not isinstance(item, dict) or not isinstance(item.get("key"), str) or not item["key"].strip():
            continue
        bindings = item.get("providers") or item.get("providerIds") or []
        if isinstance(bindings, str):
            bindings = [bindings]
        if not isinstance(bindings, list):
            bindings = []
        bindings = [value for value in bindings if isinstance(value, str)]
        if isinstance(item.get("providerId"), str):
            bindings.append(item["providerId"])
        if provider_id in bindings:
            try:
                used = int(item.get("lastUsedAt", 0))
            except (TypeError, ValueError):
                used = 0
            matches.append((used, item["key"].strip()))
    if matches:
        return max(matches, key=lambda pair: pair[0])[1]

    # Older Forge backups may still have a single active-provider key slot.
    legacy = settings.get("legacy") if isinstance(settings.get("legacy"), dict) else {}
    if settings.get("activeProviderId") == provider_id and isinstance(legacy.get("key"), str):
        return legacy["key"].strip()
    return ""


def _model_list(value: Any) -> tuple[str, ...]:
    if isinstance(value, str):
        values = [part.strip() for part in value.split(",")]
    elif isinstance(value, list):
        values = [part.strip() for part in value if isinstance(part, str)]
    else:
        values = []
    return tuple(dict.fromkeys(part[:200] for part in values if part))[:100]


def _kind_overrides(items: list[str] | None) -> dict[str, str]:
    result: dict[str, str] = {}
    for item in items or []:
        provider_id, sep, kind = item.partition("=")
        provider_id, kind = provider_id.strip(), kind.strip()
        if not sep or not _PROVIDER_ID.fullmatch(provider_id) or kind not in {"openai", "gemini"}:
            raise ImportErrorSafe("Provider kind overrides must use ID=openai or ID=gemini.")
        result[provider_id] = kind
    return result


def discover_candidates(settings: dict[str, Any], kind_overrides: dict[str, str] | None = None) -> list[ProviderCandidate]:
    profiles = settings.get("profiles") if isinstance(settings.get("profiles"), dict) else {}
    custom_values = settings.get("customProviders") if isinstance(settings.get("customProviders"), list) else []
    customs = {str(x.get("id")): x for x in custom_values if isinstance(x, dict) and x.get("id")}
    overrides = kind_overrides or {}
    ids = set(str(x) for x in profiles if isinstance(x, str)) | set(customs)

    # Include provider IDs represented only by the saved key vault.
    for item in settings.get("knownKeys", []) if isinstance(settings.get("knownKeys"), list) else []:
        if not isinstance(item, dict):
            continue
        bindings = item.get("providers") or item.get("providerIds") or []
        if isinstance(bindings, str):
            ids.add(bindings)
        elif isinstance(bindings, list):
            ids.update(str(x) for x in bindings if isinstance(x, str))
        if isinstance(item.get("providerId"), str):
            ids.add(item["providerId"])
    legacy = settings.get("legacy") if isinstance(settings.get("legacy"), dict) else {}
    if legacy.get("key") and isinstance(settings.get("activeProviderId"), str):
        ids.add(settings["activeProviderId"])

    if len(ids) > 128:
        raise ImportErrorSafe("Backup contains too many provider records to preview safely.")

    result: list[ProviderCandidate] = []
    for provider_id in sorted(ids):
        if not _PROVIDER_ID.fullmatch(provider_id):
            result.append(ProviderCandidate(provider_id[:80], provider_id[:100], "", "", "", (), issue="invalid provider ID"))
            continue
        profile = profiles.get(provider_id) if isinstance(profiles.get(provider_id), dict) else {}
        custom = customs.get(provider_id, {})
        builtin = _BUILTINS.get(provider_id)
        if provider_id in _UNSUPPORTED_BUILTINS and provider_id not in overrides:
            kind, label, base = "", str(custom.get("label") or provider_id), ""
            issue = "Forge Azure is not supported by the server adapter; use an OpenAI-compatible gateway."
        elif provider_id in overrides:
            kind, label, base = overrides[provider_id], str(custom.get("label") or (builtin[1] if builtin else provider_id)), ""
            issue = ""
        elif builtin:
            kind, label, base = builtin
            issue = ""
        elif custom:
            kind, label, base = "openai", str(custom.get("label") or provider_id), ""
            issue = ""
        else:
            kind, label, base = "", provider_id, ""
            issue = "unsupported provider; specify --kind ID=openai or ID=gemini only if its API is compatible"

        base_url = str(profile.get("base") or custom.get("base") or base).strip().rstrip("/")
        custom_models = custom.get("models", custom.get("modelsText", []))
        models = _model_list(custom_models)
        default_model = str(profile.get("model") or custom.get("defaultModel") or "").strip()[:200]
        if not models and default_model:
            models = (default_model,)
        if not default_model and models:
            default_model = str(custom.get("defaultModel") or models[0]).strip()[:200]
        if default_model and default_model not in models:
            models = (default_model, *models)[:100]
        key = _provider_key(settings, provider_id)

        if not issue and kind not in {"openai", "gemini"}:
            issue = "unsupported provider protocol"
        if not issue and not base_url:
            issue = "missing provider base URL"
        if not issue and len(base_url) > 2048:
            issue = "provider base URL is too long"
        if not issue and any(ord(char) < 0x20 or ord(char) == 0x7f for char in base_url):
            issue = "provider base URL contains control characters"
        if not issue:
            try:
                _validate_provider_url(base_url)
            except ConfigError:
                issue = "provider base URL is not allowed (use HTTPS, or loopback HTTP only)"
        if not issue and not default_model:
            issue = "no model was saved for this provider"
        if not issue and any(ord(char) < 0x20 or ord(char) == 0x7f for char in default_model):
            issue = "provider model contains control characters"
        if not issue and any(any(ord(char) < 0x20 or ord(char) == 0x7f for char in model) for model in models):
            issue = "provider model list contains control characters"
        if not issue and not key and not (kind == "openai" and _is_loopback_http_url(base_url)):
            issue = "no saved API key (only loopback OpenAI-compatible providers may be keyless)"
        result.append(ProviderCandidate(
            id=provider_id,
            label=label[:100],
            kind=kind,
            base_url=base_url,
            default_model=default_model,
            models=models,
            key=key,
            issue=issue,
        ))
    return result


def _read_json_file(path: Path, expected_type: type, empty: Any) -> Any:
    if not path.exists():
        return empty
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ImportErrorSafe(f"Could not read valid JSON from {path}.") from exc
    if not isinstance(value, expected_type):
        raise ImportErrorSafe(f"Unexpected JSON structure in {path}.")
    return value


def _render_env_file(existing: str, updates: dict[str, str]) -> str:
    lines = existing.splitlines()
    for name, value in updates.items():
        if not _ENV_NAME.fullmatch(name) or not _ENV_VALUE.fullmatch(value):
            raise ImportErrorSafe("An API key cannot be represented safely in the systemd environment file.")
        rendered = f"{name}={value}"
        indices = [i for i, line in enumerate(lines) if (m := _ENV_ASSIGNMENT.match(line)) and m.group(1) == name]
        if indices:
            first = indices[0]
            lines[first] = rendered
            for index in reversed(indices[1:]):
                del lines[index]
        else:
            lines.append(rendered)
    return "\n".join(lines).rstrip("\n") + "\n"


def _target_env_name(candidate: ProviderCandidate, existing: dict[str, dict[str, Any]]) -> str:
    used_elsewhere = {
        str(entry.get("api_key_env"))
        for provider_id, entry in existing.items()
        if provider_id != candidate.id and entry.get("api_key_env")
    }
    configured = str(existing.get(candidate.id, {}).get("api_key_env") or "")
    if configured and _ENV_NAME.fullmatch(configured) and configured not in used_elsewhere and configured not in _RESERVED_ENV_NAMES:
        return configured
    env_name = "FORGECHAT_" + re.sub(r"[^A-Z0-9_]", "_", candidate.id.upper()) + "_API_KEY"
    if env_name in used_elsewhere or env_name in _RESERVED_ENV_NAMES:
        env_name = "FORGECHAT_IMPORTED_" + re.sub(r"[^A-Z0-9_]", "_", candidate.id.upper()) + "_API_KEY"
    if env_name in used_elsewhere or env_name in _RESERVED_ENV_NAMES or not _ENV_NAME.fullmatch(env_name):
        raise ImportErrorSafe(f"Could not allocate a unique API-key environment variable for {candidate.id}.")
    return env_name


def _mode_owner(path: Path, default_mode: int) -> tuple[int, int, int]:
    if path.exists():
        info = path.stat()
        return stat.S_IMODE(info.st_mode), info.st_uid, info.st_gid
    gid = os.getegid()
    try:
        gid = grp.getgrnam("forgechat").gr_gid
    except KeyError:
        pass
    return default_mode, os.geteuid(), gid


def _atomic_write(path: Path, data: bytes, mode: int, uid: int, gid: int) -> None:
    if not path.parent.is_dir():
        raise ImportErrorSafe(f"Configuration directory does not exist: {path.parent}")
    fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    temp_path = Path(temporary)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temp_path, mode)
        if os.geteuid() == 0:
            os.chown(temp_path, uid, gid)
        os.replace(temp_path, path)
        directory_fd = os.open(path.parent, os.O_RDONLY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
    finally:
        try:
            temp_path.unlink()
        except FileNotFoundError:
            pass


def _backup_file(path: Path, mode: int, uid: int, gid: int) -> Path | None:
    if not path.exists():
        return None
    backup = path.with_name(path.name + ".backup-" + str(int(time.time())))
    if backup.exists():
        raise ImportErrorSafe(f"Refusing to overwrite existing backup: {backup.name}")
    _atomic_write(backup, path.read_bytes(), mode, uid, gid)
    return backup


def apply_import(
    candidates: list[ProviderCandidate],
    provider_ids: list[str],
    providers_path: str | Path,
    env_path: str | Path,
) -> tuple[list[str], list[Path]]:
    """Merge selected provider records and key env values without printing secrets."""
    if not provider_ids:
        raise ImportErrorSafe("Select at least one provider with --provider.")
    by_id = {candidate.id: candidate for candidate in candidates}
    if len(set(provider_ids)) != len(provider_ids):
        raise ImportErrorSafe("A provider ID was selected more than once.")
    missing = [provider_id for provider_id in provider_ids if provider_id not in by_id]
    if missing:
        raise ImportErrorSafe("Selected provider ID is not present in the ZIP: " + ", ".join(missing))
    selected = [by_id[provider_id] for provider_id in provider_ids]
    providers_file = Path(providers_path)
    env_file = Path(env_path)
    if providers_file.is_symlink() or env_file.is_symlink():
        raise ImportErrorSafe("Refusing to replace symlinked provider configuration files.")
    current = _read_json_file(providers_file, list, [])
    if any(not isinstance(item, dict) or not isinstance(item.get("id"), str) or not _PROVIDER_ID.fullmatch(item["id"]) for item in current):
        raise ImportErrorSafe(f"Existing provider catalog has invalid entries: {providers_file}")
    by_existing_id = {item["id"]: dict(item) for item in current}
    if len(by_existing_id) != len(current):
        raise ImportErrorSafe(f"Existing provider catalog contains duplicate IDs: {providers_file}")
    env_text = env_file.read_text(encoding="utf-8") if env_file.exists() else ""
    env_values = {
        match.group(1): line[match.end():].strip()
        for line in env_text.splitlines()
        if (match := _ENV_ASSIGNMENT.match(line))
    }

    unsupported = []
    for candidate in selected:
        old = by_existing_id.get(candidate.id, {})
        configured_key = str(old.get("api_key_env") or "")
        configured_value = env_values.get(configured_key, "").strip().strip("\"'")
        if candidate.issue and not (
            candidate.issue.startswith("no saved API key")
            and _ENV_NAME.fullmatch(configured_key)
            and configured_value
        ):
            unsupported.append(candidate)
    if unsupported:
        reasons = "; ".join(f"{item.id}: {item.issue}" for item in unsupported)
        raise ImportErrorSafe("Cannot import selected provider(s): " + reasons)

    updates: dict[str, str] = {}
    for candidate in selected:
        old = by_existing_id.get(candidate.id, {})
        entry: dict[str, Any] = {
            "id": candidate.id,
            "label": candidate.label,
            "kind": candidate.kind,
            "base_url": candidate.base_url,
            "default_model": candidate.default_model,
            "models": list(candidate.models),
        }
        if candidate.key:
            env_name = _target_env_name(candidate, by_existing_id)
            if not _ENV_NAME.fullmatch(env_name) or not _ENV_VALUE.fullmatch(candidate.key):
                raise ImportErrorSafe(f"The saved API key for {candidate.id} is not a safe systemd environment value.")
            entry["api_key_env"] = env_name
            updates[env_name] = candidate.key
        elif old.get("api_key_env"):
            # Preserve an existing server-side secret reference when a backup was
            # exported without its key; never replace a configured key with blank.
            entry["api_key_env"] = old["api_key_env"]
        by_existing_id[candidate.id] = entry

    merged = list(by_existing_id.values())
    if len(merged) > 32:
        raise ImportErrorSafe("The merged provider catalog would exceed the 32-provider limit.")
    rendered_env = _render_env_file(env_text, updates)
    providers_bytes = (json.dumps(merged, indent=2, ensure_ascii=False) + "\n").encode("utf-8")
    env_bytes = rendered_env.encode("utf-8")
    providers_mode, providers_uid, providers_gid = _mode_owner(providers_file, 0o640)
    env_mode, env_uid, env_gid = _mode_owner(env_file, 0o640)
    if providers_mode & 0o007 or env_mode & 0o007:
        raise ImportErrorSafe("Refusing to write provider config that is accessible to other users; tighten its permissions first.")

    backups: list[Path] = []
    for path, mode, uid, gid in (
        (providers_file, providers_mode, providers_uid, providers_gid),
        (env_file, env_mode, env_uid, env_gid),
    ):
        backup = _backup_file(path, mode, uid, gid)
        if backup:
            backups.append(backup)

    try:
        # The temporary is created private (mkstemp mode 0600); atomic replacement
        # applies the service-readable mode only after the bytes are fully written.
        _atomic_write(env_file, env_bytes, env_mode, env_uid, env_gid)
        _atomic_write(providers_file, providers_bytes, providers_mode, providers_uid, providers_gid)
    except Exception:
        # Best-effort rollback from the private backups if the second write fails.
        for path, mode, uid, gid in (
            (providers_file, providers_mode, providers_uid, providers_gid),
            (env_file, env_mode, env_uid, env_gid),
        ):
            backup = next((b for b in backups if b.name.startswith(path.name + ".backup-")), None)
            if backup:
                _atomic_write(path, backup.read_bytes(), mode, uid, gid)
            elif path.exists():
                path.unlink()
        raise
    return [candidate.id for candidate in selected], backups


def _print_preview(candidates: list[ProviderCandidate]) -> None:
    if not candidates:
        print("No provider settings were found in the Forge backup.")
        return
    print("Provider candidates (API-key values are never displayed):")
    for candidate in candidates:
        state = "saved key present" if candidate.key else "no saved key"
        safe = candidate.preview()
        line = f"- {safe['id']}: {safe['label']} [{safe['kind'] or 'unsupported'}], model={safe['default_model'] or '(none)'}, {state}"
        if candidate.issue:
            line += f"; skipped: {safe['issue']}"
        print(line)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Import selected provider settings from a ForgeLibrary backup ZIP. Reads only ForgeLibrary/settings.json."
    )
    parser.add_argument("--zip", required=True, dest="archive", help="private ForgeLibrary-YYYY-MM-DD.zip file on this VM")
    parser.add_argument("--provider", action="append", dest="providers", help="provider ID to import; repeat for multiple")
    parser.add_argument("--kind", action="append", dest="kinds", metavar="ID=openai|gemini", help="override protocol only when you know the provider is compatible")
    parser.add_argument("--apply", action="store_true", help="write selected providers and keys to server config (root required)")
    args = parser.parse_args(argv)
    try:
        settings = read_forge_settings(args.archive)
        candidates = discover_candidates(settings, _kind_overrides(args.kinds))
        _print_preview(candidates)
        if not args.apply:
            print("Preview only; no files were changed. Re-run with --provider ID --apply to import.")
            return 0
        if os.geteuid() != 0:
            raise ImportErrorSafe("Run --apply as root (for example, with sudo); preview does not require root.")
        imported, backups = apply_import(candidates, args.providers or [], "/etc/forgechat/providers.json", "/etc/forgechat/forgechat.env")
        print("Imported provider IDs: " + ", ".join(imported))
        if backups:
            print("Private backups created: " + ", ".join(str(path) for path in backups))
        print("No API-key values were printed. Restart the service to load the imported settings:")
        print("  sudo systemctl restart forgechat.service")
        return 0
    except ImportErrorSafe as exc:
        print(f"Import failed: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
