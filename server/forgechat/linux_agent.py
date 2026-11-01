#!/usr/bin/env python3
"""Private Linux command/file agent for the ForgeChat Docker worker.

The HTTP control process authenticates the backend. Job processes run as a
separate unprivileged UID and only receive a sanitized environment. The Docker
container, not this module, is the host isolation boundary.
"""
from __future__ import annotations

import base64
import hashlib
import hmac
import json
import mimetypes
import os
import re
import selectors
import signal
import subprocess
import tempfile
import threading
import time
import uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlsplit

VERSION = "1.0.3"
HOST = os.environ.get("FORGE_AGENT_HOST", "0.0.0.0")
PORT = int(os.environ.get("FORGE_AGENT_PORT", "8787"))
USERNAME = os.environ.get("FORGE_AGENT_USERNAME", "")
PASSWORD = os.environ.get("FORGE_AGENT_PASSWORD", "")
WORKSPACE = Path(os.environ.get("FORGE_AGENT_WORKSPACE", "/workspace")).resolve()
HOME = Path(os.environ.get("FORGE_AGENT_HOME", str(WORKSPACE / "home"))).resolve()
FSROOT = Path(os.environ.get("FORGE_AGENT_FSROOT", str(WORKSPACE / "fs"))).resolve()
TEMP_DIR = Path(os.environ.get("FORGE_AGENT_TMPDIR", "/tmp")).resolve()
JOB_UID = int(os.environ.get("FORGE_AGENT_JOB_UID", "10000"))
JOB_GID = int(os.environ.get("FORGE_AGENT_JOB_GID", "10000"))
MAX_JSON_BYTES = 1 * 1024 * 1024
MAX_STREAM_BYTES = 512 * 1024 * 1024
MAX_READ_BYTES = 64 * 1024 * 1024
MAX_JOB_SECONDS = 1800
MAX_OUTPUT_BYTES = 2 * 1024 * 1024
MAX_BACKGROUND_JOBS = 32
CONCURRENT_JOBS = threading.BoundedSemaphore(2)
_BACKGROUND: dict[str, subprocess.Popen] = {}
_BACKGROUND_LOCK = threading.Lock()

PATH = f"{HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"


def _safe_path(raw: str) -> Path:
    value = unquote(str(raw or "").strip())
    if not value:
        raise ValueError("path required")
    if value in {"$FS", "fs", "."}:
        value = str(FSROOT)
    elif value.startswith("$FS/"):
        value = str(FSROOT / value[4:])
    elif value == "$HOME":
        value = str(HOME)
    elif value.startswith("$HOME/"):
        value = str(HOME / value[6:])
    elif value == "~":
        value = str(HOME)
    elif value.startswith("~/"):
        value = str(HOME / value[2:])
    elif not value.startswith("/"):
        value = str(FSROOT / value)
    target = Path(os.path.abspath(value)).resolve(strict=False)
    bases = (FSROOT, HOME)
    if not any(target == base or base in target.parents for base in bases):
        raise ValueError("path must be under the agent fs root or home")
    return target


def _ensure_job_directories(path: Path) -> None:
    pending: list[Path] = []
    current = path
    while not current.exists():
        pending.append(current)
        current = current.parent
    for directory in reversed(pending):
        directory.mkdir(mode=0o777)
        if os.geteuid() == 0:
            # Only the single shared unprivileged job UID uses this workspace.
            # Docker's user-namespace/mount combination may deny chown, so make
            # root-created directories writable to that UID without ownership changes.
            os.chmod(directory, 0o777)


def _safe_cwd(raw: object) -> Path:
    if raw is None or raw == "":
        return FSROOT
    if not isinstance(raw, str) or len(raw) > 4096:
        raise ValueError("cwd must be a path under the agent workspace")
    target = _safe_path(raw)
    if not target.is_dir():
        raise ValueError("cwd is not a directory")
    return target


def _auth_value(headers) -> tuple[str, str] | None:
    raw = headers.get("Authorization", "")
    scheme, _, value = raw.partition(" ")
    if scheme.lower() != "basic" or not value:
        return None
    try:
        decoded = base64.b64decode(value, validate=True).decode("utf-8")
        user, separator, password = decoded.partition(":")
        if not separator:
            return None
        return user, password
    except (ValueError, UnicodeDecodeError):
        return None


def _authenticated(headers) -> bool:
    supplied = _auth_value(headers)
    if supplied is None:
        return False
    return hmac.compare_digest(supplied[0], USERNAME) and hmac.compare_digest(supplied[1], PASSWORD)


def _job_env() -> dict[str, str]:
    return {
        "HOME": str(HOME),
        "PREFIX": "/usr/local",
        "PATH": f"{HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        "LANG": "C.UTF-8",
        "LC_ALL": "C.UTF-8",
        "TMPDIR": "/tmp",
        "TERM": "dumb",
    }


def _process_identity() -> dict[str, int]:
    if os.geteuid() == 0:
        return {"user": JOB_UID, "group": JOB_GID, "extra_groups": []}
    return {}


def _command(job: dict) -> list[str]:
    script = job.get("script")
    if isinstance(script, str) and script.strip():
        if len(script.encode("utf-8")) > MAX_JSON_BYTES // 2:
            raise ValueError("script is too large")
        # Non-login shell so the sanitized job environment (not /etc/profile)
        # controls PATH; this keeps the per-user prefix ($HOME/.local/bin) first
        # so a Termux-style `pkg` can install tools that jobs find on PATH.
        return ["/bin/bash", "-c", script]
    command_path = job.get("cmdPath")
    args = job.get("args", [])
    if not isinstance(command_path, str) or not command_path.strip() or len(command_path) > 4096:
        raise ValueError("Provide script or cmdPath with optional args")
    if not isinstance(args, list) or len(args) > 128 or any(not isinstance(arg, str) or len(arg) > 8192 for arg in args):
        raise ValueError("args must be an array of at most 128 strings")
    return [command_path] + args


def _terminate(process: subprocess.Popen) -> None:
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except (ProcessLookupError, PermissionError):
        try:
            process.terminate()
        except ProcessLookupError:
            pass
    try:
        process.wait(timeout=1.5)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except (ProcessLookupError, PermissionError):
            process.kill()
        process.wait(timeout=2)


def _capture_process(process: subprocess.Popen, started: float, timeout: float) -> tuple[str, str, int, bool, bool]:
    selector = selectors.DefaultSelector()
    streams = {"stdout": process.stdout, "stderr": process.stderr}
    output = {"stdout": bytearray(), "stderr": bytearray()}
    for name, stream in streams.items():
        os.set_blocking(stream.fileno(), False)
        selector.register(stream, selectors.EVENT_READ, name)
    total = 0
    timed_out = False
    output_limited = False
    terminated = False
    try:
        while selector.get_map() or process.poll() is None:
            if not terminated and time.monotonic() - started >= timeout:
                timed_out = True
                terminated = True
                _terminate(process)
            events = selector.select(0.05)
            for key, _ in events:
                while True:
                    try:
                        chunk = os.read(key.fileobj.fileno(), 65536)
                    except BlockingIOError:
                        break
                    if not chunk:
                        selector.unregister(key.fileobj)
                        key.fileobj.close()
                        break
                    remaining = MAX_OUTPUT_BYTES - total
                    accepted = chunk[:max(0, remaining)]
                    output[key.data].extend(accepted)
                    total += len(accepted)
                    if len(accepted) < len(chunk):
                        output_limited = True
                        if not terminated:
                            terminated = True
                            _terminate(process)
                        break
                    if len(chunk) < 65536:
                        break
            if process.poll() is not None and not selector.get_map():
                break
    finally:
        selector.close()
        for stream in streams.values():
            if stream and not stream.closed:
                stream.close()
    exit_code = process.wait()
    return (
        output["stdout"].decode("utf-8", "replace"),
        output["stderr"].decode("utf-8", "replace"),
        exit_code,
        timed_out,
        output_limited,
    )


def _run_job(job: dict) -> dict:
    started = time.monotonic()
    job_id = job.get("id") if isinstance(job.get("id"), str) and len(job["id"]) <= 128 else str(uuid.uuid4())
    timeout_ms = job.get("timeoutMs", 120000)
    if not isinstance(timeout_ms, int) or isinstance(timeout_ms, bool):
        raise ValueError("timeoutMs must be an integer")
    timeout = max(1.0, min(timeout_ms / 1000.0, MAX_JOB_SECONDS))
    cwd = _safe_cwd(job.get("cwd"))
    command = _command(job)
    background = job.get("wait") is False or job.get("background") is True

    if background:
        with _BACKGROUND_LOCK:
            for old_id, process in list(_BACKGROUND.items()):
                if process.poll() is not None:
                    _BACKGROUND.pop(old_id, None)
            if len(_BACKGROUND) >= MAX_BACKGROUND_JOBS:
                return {"ok": False, "stdout": "", "stderr": "", "exitCode": 429, "errmsg": "background job limit reached", "id": job_id}
            if not CONCURRENT_JOBS.acquire(blocking=False):
                return {"ok": False, "stdout": "", "stderr": "", "exitCode": 429, "errmsg": "agent is busy", "id": job_id}
            try:
                process = subprocess.Popen(
                    command,
                    cwd=str(cwd),
                    env=_job_env(),
                    stdin=subprocess.DEVNULL,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    start_new_session=True,
                    **_process_identity(),
                )
            except Exception:
                CONCURRENT_JOBS.release()
                raise
            _BACKGROUND[job_id] = process

        def reap() -> None:
            try:
                try:
                    process.wait(timeout=MAX_JOB_SECONDS)
                except subprocess.TimeoutExpired:
                    _terminate(process)
            finally:
                with _BACKGROUND_LOCK:
                    _BACKGROUND.pop(job_id, None)
                CONCURRENT_JOBS.release()

        threading.Thread(target=reap, name="agent-job-reaper", daemon=True).start()
        return {"ok": True, "stdout": "", "stderr": "", "exitCode": 0, "note": "started background", "id": job_id, "pid": process.pid}

    if not CONCURRENT_JOBS.acquire(blocking=False):
        return {"ok": False, "stdout": "", "stderr": "agent is busy", "exitCode": 429, "errmsg": "agent is busy", "id": job_id}
    try:
        process = subprocess.Popen(
            command,
            cwd=str(cwd),
            env=_job_env(),
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            start_new_session=True,
            **_process_identity(),
        )
        stdout, stderr, exit_code, timed_out, output_limited = _capture_process(process, started, timeout)
        if timed_out:
            return {"ok": False, "stdout": stdout, "stderr": stderr or "timeout", "exitCode": 124, "errmsg": f"timeout after {timeout:g}s", "id": job_id, "ms": int((time.monotonic() - started) * 1000)}
        if output_limited:
            return {"ok": False, "stdout": stdout, "stderr": (stderr + "\noutput limit exceeded").strip(), "exitCode": 122, "errmsg": "output limit exceeded", "id": job_id, "ms": int((time.monotonic() - started) * 1000)}
        return {"ok": exit_code == 0, "stdout": stdout, "stderr": stderr, "exitCode": exit_code, "id": job_id, "ms": int((time.monotonic() - started) * 1000)}
    finally:
        CONCURRENT_JOBS.release()


def _chunks(handler):
    transfer = (handler.headers.get("Transfer-Encoding") or "").lower()
    if "chunked" in transfer:
        total = 0
        while True:
            line = handler.rfile.readline(128).decode("ascii", "replace").strip()
            if not line:
                continue
            try:
                size = int(line.split(";", 1)[0], 16)
            except ValueError as exc:
                raise ValueError("invalid chunked body") from exc
            if size == 0:
                while handler.rfile.readline(4096).strip():
                    pass
                return
            total += size
            if total > MAX_STREAM_BYTES:
                raise ValueError("file exceeds 512 MiB streaming limit")
            remaining = size
            while remaining:
                block = handler.rfile.read(min(65536, remaining))
                if not block:
                    raise ValueError("unexpected end of request body")
                yield block
                remaining -= len(block)
            if handler.rfile.read(2) != b"\r\n":
                raise ValueError("invalid chunk terminator")
    else:
        try:
            length = int(handler.headers.get("Content-Length") or 0)
        except ValueError as exc:
            raise ValueError("invalid Content-Length") from exc
        if length < 0 or length > MAX_STREAM_BYTES:
            raise ValueError("invalid or oversized Content-Length")
        remaining = length
        while remaining:
            block = handler.rfile.read(min(65536, remaining))
            if not block:
                raise ValueError("unexpected end of request body")
            yield block
            remaining -= len(block)


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "ForgeLinuxAgent/" + VERSION
    sys_version = ""

    def log_message(self, *_args):
        pass

    def _send_json(self, status: int, payload: dict) -> None:
        raw = json.dumps(payload, separators=(",", ":")).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        try:
            self.wfile.write(raw)
        except (BrokenPipeError, ConnectionError, OSError):
            self.close_connection = True

    def _send_error_json(self, status: int, message: str) -> None:
        self._send_json(status, {"ok": False, "errmsg": message})

    def _authorize(self) -> bool:
        if _authenticated(self.headers):
            return True
        self.send_response(401)
        self.send_header("WWW-Authenticate", 'Basic realm="Forge agent", charset="UTF-8"')
        self.send_header("Content-Length", "0")
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        return False

    def _read_job(self) -> dict:
        try:
            length = int(self.headers.get("Content-Length") or 0)
        except ValueError as exc:
            raise ValueError("invalid Content-Length") from exc
        if length <= 0 or length > MAX_JSON_BYTES:
            raise ValueError("missing or oversized job JSON")
        try:
            value = json.loads(self.rfile.read(length).decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise ValueError("invalid job JSON") from exc
        if not isinstance(value, dict):
            raise ValueError("job must be an object")
        return value

    def _serve_file(self, query: dict[str, list[str]]) -> None:
        try:
            target = _safe_path((query.get("path") or [""])[0])
            max_bytes_raw = (query.get("maxBytes") or [str(MAX_READ_BYTES)])[0]
            max_bytes = max(1, min(int(max_bytes_raw), MAX_READ_BYTES))
            if not target.is_file():
                self._send_error_json(404, "file not found")
                return
            size = target.stat().st_size
            if size > max_bytes:
                self._send_error_json(413, f"file too large ({size} > {max_bytes})")
                return
            mime = (query.get("mime") or [mimetypes.guess_type(target.name)[0] or "application/octet-stream"])[0]
            if len(mime) > 200 or not re.fullmatch(r"[A-Za-z0-9!#$&^_.+-]+/[A-Za-z0-9!#$&^_.+-]+", mime):
                self._send_error_json(400, "invalid MIME type")
                return
            self.send_response(200)
            self.send_header("Content-Type", mime[:200])
            self.send_header("Content-Length", str(size))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            try:
                remaining = size
                with target.open("rb") as source:
                    while remaining > 0:
                        block = source.read(min(65536, remaining))
                        if not block:
                            break
                        self.wfile.write(block)
                        remaining -= len(block)
            except (BrokenPipeError, ConnectionError, OSError):
                self.close_connection = True
        except (ValueError, OSError) as exc:
            self._send_error_json(400, str(exc)[:300])

    def do_GET(self):
        if not self._authorize():
            return
        parsed = urlsplit(self.path)
        query = parse_qs(parsed.query, keep_blank_values=True)
        if parsed.path in {"/", "/status"}:
            self._send_json(200, {
                "ok": True,
                "pid": os.getpid(),
                "version": VERSION,
                "home": str(HOME),
                "fsRoot": str(FSROOT),
                "prefix": "/usr/local",
                "port": PORT,
                "root": str(WORKSPACE),
                "ts": int(time.time()),
            })
        elif parsed.path == "/files":
            self._serve_file(query)
        else:
            self._send_error_json(404, "not found")

    def do_POST(self):
        if not self._authorize():
            return
        if urlsplit(self.path).path not in {"/exec", "/run"}:
            self._send_error_json(404, "not found")
            return
        try:
            job = self._read_job()
            result = _run_job(job)
            self._send_json(200, result)
        except ValueError as exc:
            self._send_error_json(400, str(exc)[:300])
        except Exception:
            self._send_error_json(500, "agent execution failed")

    def do_PUT(self):
        if not self._authorize():
            return
        parsed = urlsplit(self.path)
        if parsed.path != "/files":
            self._send_error_json(404, "not found")
            return
        temp_path: Path | None = None
        try:
            query = parse_qs(parsed.query, keep_blank_values=True)
            destination = _safe_path((query.get("destination") or [""])[0])
            parent = destination.parent
            if (self.headers.get("X-Forge-Mkdirs") or "").lower() == "true" and not parent.exists():
                _ensure_job_directories(parent)
                destination = _safe_path(str(destination))
                parent = destination.parent
            if not parent.is_dir():
                raise ValueError("destination parent is not a directory")
            if destination.exists() and (self.headers.get("X-Forge-Overwrite") or "false").lower() != "true":
                self._send_error_json(409, "destination already exists")
                return
            expected = (self.headers.get("X-Forge-Sha256") or "").strip().lower()
            digest = hashlib.sha256()
            count = 0
            with tempfile.NamedTemporaryFile(prefix=".forge-upload-", dir=str(parent), delete=False) as target:
                temp_path = Path(target.name)
                for block in _chunks(self):
                    count += len(block)
                    digest.update(block)
                    target.write(block)
            if expected and not hmac.compare_digest(expected, digest.hexdigest()):
                raise ValueError("sha256 mismatch")
            if destination.exists() and destination.is_symlink():
                raise ValueError("destination cannot be a symlink")
            # The worker runs as one shared unprivileged UID. Make its uploaded
            # file writable without requiring CAP_CHOWN in the container.
            os.chmod(temp_path, 0o666)
            os.replace(temp_path, destination)
            temp_path = None
            self._send_json(200, {"ok": True, "path": str(destination), "bytes": count, "sha256": digest.hexdigest()})
        except FileExistsError:
            self._send_error_json(409, "destination already exists")
        except (ValueError, OSError) as exc:
            if temp_path is not None:
                try:
                    temp_path.unlink(missing_ok=True)
                except OSError:
                    pass
            self._send_error_json(400, str(exc)[:300])
        except Exception:
            if temp_path is not None:
                try:
                    temp_path.unlink(missing_ok=True)
                except OSError:
                    pass
            self._send_error_json(500, "file upload failed")


def main() -> None:
    if not USERNAME or not PASSWORD:
        raise SystemExit("FORGE_AGENT_USERNAME and FORGE_AGENT_PASSWORD are required")
    for directory in (HOME, FSROOT):
        directory.mkdir(parents=True, exist_ok=True)
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    server.daemon_threads = True
    print(f"Forge Linux agent {VERSION} listening on {HOST}:{PORT}", flush=True)
    try:
        server.serve_forever(poll_interval=0.5)
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
