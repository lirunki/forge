import asyncio
import io
import json
import os
import tempfile
import unittest
import zipfile
from pathlib import Path
from typing import Any

from forgechat.app import create_app
from forgechat.config import Provider, Settings
from forgechat.auth import hash_password


def build_settings():
    return {
        "format": "forge-drive-settings-v1",
        "activeProviderId": "openai",
        "profiles": {
            "openai": {"key": "openai-test-key-123", "base": "https://api.openai.com/v1", "model": "gpt-4o-mini"},
            "gemini": {"base": "https://generativelanguage.googleapis.com/v1beta", "model": "gemini-2.5-flash"},
            "azure": {"base": "https://example.openai.azure.com", "model": "gpt-4o"},
            "missingkey": {"base": "https://api.example.test/v1", "model": "test-model"},
        },
        "knownKeys": [{"key": "gemini-test-key-456", "providers": ["gemini"], "lastUsedAt": 10}],
        "customProviders": [
            {"id": "missingkey", "label": "Remote Custom", "base": "https://api.example.test/v1", "models": ["test-model"]},
        ],
    }


def build_zip(settings: dict[str, Any]) -> bytes:
    out = io.BytesIO()
    with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_STORED) as zf:
        zf.writestr("ForgeLibrary/manifest.json", "{}")
        zf.writestr("ForgeLibrary/apps/private/app.html", "<html>ignored</html>")
        zf.writestr("ForgeLibrary/settings.json", json.dumps(settings))
    return out.getvalue()


async def asgi(app, method, path, *, body=None, headers=None):
    if body is None:
        raw = b""
    elif isinstance(body, bytes):
        raw = body
    elif isinstance(body, str):
        raw = body.encode("utf-8")
    else:
        raw = json.dumps(body).encode("utf-8")
    all_headers = {"host": "forge.example.test", "origin": "https://forge.example.test"}
    all_headers.update(headers or {})
    lower = {k.lower() for k in all_headers}
    if body is not None and "content-type" not in lower:
        all_headers["content-type"] = "application/zip" if isinstance(body, bytes) else "application/json"
    if body is not None and "content-length" not in lower:
        all_headers["content-length"] = str(len(raw))
    encoded = [(k.lower().encode("latin1"), v.encode("latin1")) for k, v in all_headers.items()]
    sent: list[dict[str, Any]] = []
    done = asyncio.Event()

    async def receive():
        await asyncio.sleep(0)
        return {"type": "http.request", "body": raw, "more_body": False}

    async def send(message):
        sent.append(message)
        if message.get("type") == "http.response.body" and not message.get("more_body", False):
            done.set()

    from urllib.parse import urlsplit
    parsed = urlsplit(path)
    scope = {
        "type": "http", "asgi": {"version": "3.0", "spec_version": "2.3"},
        "http_version": "1.1", "method": method, "scheme": "https",
        "path": parsed.path, "raw_path": parsed.path.encode("ascii"),
        "query_string": parsed.query.encode("ascii"),
        "headers": encoded, "client": ("127.0.0.1", 45678), "server": ("forge.example.test", 443),
    }
    await app(scope, receive, send)
    start = next(m for m in sent if m["type"] == "http.response.start")
    payload = b"".join(m.get("body", b"") for m in sent if m["type"] == "http.response.body")
    try:
        decoded = json.loads(payload) if payload else None
    except json.JSONDecodeError:
        decoded = payload.decode("utf-8", "replace")
    return start["status"], dict(start.get("headers", [])), decoded


class ProviderImportTests(unittest.IsolatedAsyncioTestCase):
    @classmethod
    def setUpClass(cls):
        cls.password_hash = hash_password("correct horse battery", rounds=100_000, salt=b"t" * 16)

    def make_app(self, *, apply_fake=None, providers=None):
        provider = Provider(
            id="openai",
            label="OpenAI",
            kind="openai",
            base_url="https://api.openai.com/v1",
            api_key="server-only-secret",
            default_model="gpt-4o-mini",
            models=("gpt-4o-mini",),
        )
        return create_app(
            Settings(
                username="owner",
                password_hash=self.password_hash,
                session_secret="s" * 48,
                public_origin="https://forge.example.test",
                base_path="/forgechat",
                providers=tuple(providers if providers is not None else (provider,)),
            ),
            provider_import_apply=apply_fake,
        )

    async def login(self, app):
        status, headers, _ = await asgi(
            app, "POST", "/api/v1/auth/login",
            body={"username": "owner", "password": "correct horse battery"},
        )
        self.assertEqual(status, 200)
        return headers[b"set-cookie"].decode("latin1").split(";", 1)[0]

    async def test_import_page_has_quoted_js_urls_and_login_redirect(self):
        app = self.make_app()
        status, headers, _ = await asgi(app, "GET", "/provider-import")
        self.assertEqual(status, 303)
        self.assertIn(b"next=%2Fforgechat%2Fprovider-import", headers[b"location"])
        cookie = await self.login(app)
        status, headers, page = await asgi(app, "GET", "/provider-import", headers={"cookie": cookie})
        self.assertEqual(status, 200)
        self.assertIn('location.href="/forgechat/apps/"', page)
        self.assertIn('fetch("/forgechat/api/v1/provider-import/preview"', page)
        self.assertIn("Preview providers", page)
        self.assertIn("Only ForgeLibrary/settings.json is read", page)
        self.assertIn("Providers available to apps", page)
        self.assertLess(page.index("Providers available to apps"), page.index("</main></body></html>"), "provider controls must be inside the rendered page body")
        self.assertIn("/api/v1/admin/apps/providers", page)
        self.assertIn("Save provider access", page)
        self.assertIn('saveApi+"/"+encodeURIComponent(app.id)+"/providers"', page)
        self.assertIn('request(api).then(render)', page)

    async def test_unauthenticated_preview_and_apply_require_login(self):
        app = self.make_app()
        status, _, _ = await asgi(app, "POST", "/api/v1/provider-import/preview", body=build_zip(build_settings()))
        self.assertEqual(status, 401)
        status, _, _ = await asgi(app, "POST", "/api/v1/provider-import/apply", body={"previewId": "x", "providers": ["openai"], "confirm": True})
        self.assertEqual(status, 401)

    async def test_preview_lists_importable_providers_without_key_leak(self):
        app = self.make_app()
        cookie = await self.login(app)
        status, _, payload = await asgi(
            app, "POST", "/api/v1/provider-import/preview",
            body=build_zip(build_settings()), headers={"cookie": cookie, "content-type": "application/zip"},
        )
        self.assertEqual(status, 200, payload)
        self.assertIn("previewId", payload)
        by_id = {p["id"]: p for p in payload["providers"]}
        self.assertTrue(by_id["openai"]["importable"])
        self.assertTrue(by_id["gemini"]["importable"])
        self.assertFalse(by_id["azure"]["importable"])
        # openai has a saved key and an existing server key; missingkey lacks both
        self.assertFalse(by_id["missingkey"]["importable"])
        self.assertNotIn("openai-test-key-123", json.dumps(payload))

    async def test_apply_runs_helper_and_requires_restart(self):
        captured: list[list[str]] = []

        async def fake_apply(candidates):
            captured.append([c.id for c in candidates])
            return [c.id for c in candidates]

        app = self.make_app(apply_fake=fake_apply)
        cookie = await self.login(app)
        status, _, payload = await asgi(
            app, "POST", "/api/v1/provider-import/preview",
            body=build_zip(build_settings()), headers={"cookie": cookie, "content-type": "application/zip"},
        )
        self.assertEqual(status, 200, payload)
        status, _, result = await asgi(
            app, "POST", "/api/v1/provider-import/apply",
            body={"previewId": payload["previewId"], "providers": ["openai", "gemini"], "confirm": True},
            headers={"cookie": cookie},
        )
        self.assertEqual(status, 200, result)
        self.assertEqual(result["imported"], ["openai", "gemini"])
        self.assertTrue(result["restartRequired"])
        self.assertEqual(captured, [["openai", "gemini"]])
        status, _, replay = await asgi(
            app, "POST", "/api/v1/provider-import/apply",
            body={"previewId": payload["previewId"], "providers": ["openai"], "confirm": True},
            headers={"cookie": cookie},
        )
        self.assertEqual(status, 404)
        self.assertIn("expired", replay["detail"].lower())

    async def test_apply_rejects_unknown_preview_and_missing_confirm(self):
        app = self.make_app()
        cookie = await self.login(app)
        status, _, _ = await asgi(
            app, "POST", "/api/v1/provider-import/apply",
            body={"previewId": "unknown-token", "providers": ["openai"], "confirm": True},
            headers={"cookie": cookie},
        )
        self.assertEqual(status, 404)
        status, _, payload = await asgi(
            app, "POST", "/api/v1/provider-import/preview",
            body=build_zip(build_settings()), headers={"cookie": cookie, "content-type": "application/zip"},
        )
        self.assertEqual(status, 200, payload)
        status, _, _ = await asgi(
            app, "POST", "/api/v1/provider-import/apply",
            body={"previewId": payload["previewId"], "providers": ["openai"], "confirm": False},
            headers={"cookie": cookie},
        )
        self.assertEqual(status, 400)

    async def test_existing_server_key_marks_missing_key_importable(self):
        # Server already has a key for "missingkey" under a different config; the
        # backup omits the key but import should still be allowed by reusing it.
        existing = Provider(
            id="missingkey", label="Remote", kind="openai",
            base_url="https://api.example.test/v1", api_key="existing-server-secret",
            default_model="old-model", models=("old-model",),
        )
        app = self.make_app(apply_fake=None, providers=(existing,))
        cookie = await self.login(app)
        status, _, payload = await asgi(
            app, "POST", "/api/v1/provider-import/preview",
            body=build_zip(build_settings()), headers={"cookie": cookie, "content-type": "application/zip"},
        )
        self.assertEqual(status, 200, payload)
        by_id = {p["id"]: p for p in payload["providers"]}
        self.assertTrue(by_id["missingkey"]["importable"])
        self.assertNotIn("existing-server-secret", json.dumps(payload))

    async def test_cross_origin_apply_is_rejected(self):
        app = self.make_app()
        cookie = await self.login(app)
        status, _, payload = await asgi(
            app, "POST", "/api/v1/provider-import/preview",
            body=build_zip(build_settings()), headers={"cookie": cookie, "content-type": "application/zip"},
        )
        self.assertEqual(status, 200, payload)
        status, _, _ = await asgi(
            app, "POST", "/api/v1/provider-import/apply",
            body={"previewId": payload["previewId"], "providers": ["openai"], "confirm": True},
            headers={"cookie": cookie, "origin": "https://attacker.example"},
        )
        self.assertEqual(status, 403)

    async def test_oversized_upload_is_rejected(self):
        app = self.make_app()
        cookie = await self.login(app)
        status, _, _ = await asgi(
            app, "POST", "/api/v1/provider-import/preview",
            body=b"x" * (33 * 1024 * 1024),
            headers={"cookie": cookie, "content-type": "application/zip", "content-length": str(33 * 1024 * 1024)},
        )
        self.assertEqual(status, 413)


class HelperPayloadValidationTests(unittest.TestCase):
    def setUp(self):
        self.record = {
            "id": "openai", "label": "OpenAI", "kind": "openai",
            "base_url": "https://api.openai.com/v1", "default_model": "gpt-4o-mini",
            "models": ["gpt-4o-mini"], "key": "sk-safe-key-123", "issue": "",
        }

    def request(self, record=None):
        import json
        return json.dumps({"version": 1, "providers": [record or self.record]}).encode()

    def test_root_helper_revalidates_protocol_url_and_key(self):
        from forgechat.import_helper import ImportErrorSafe, _validate_request
        good = _validate_request(self.request())
        self.assertEqual([c.id for c in good], ["openai"])
        for changes in (
            {"issue": "forged"},
            {"base_url": "http://attacker.example/v1"},
            {"key": "unsafe key with spaces"},
            {"kind": "arbitrary"},
        ):
            with self.subTest(changes=changes), self.assertRaises(ImportErrorSafe):
                _validate_request(self.request({**self.record, **changes}))

    def test_keyless_remote_must_use_checked_existing_key_path(self):
        from forgechat.import_helper import _NO_KEY_ISSUE, ImportErrorSafe, _validate_request
        record = {**self.record, "key": "", "issue": ""}
        with self.assertRaises(ImportErrorSafe):
            _validate_request(self.request(record))
        record["issue"] = _NO_KEY_ISSUE
        # The root-side apply_import call rechecks whether this ID has a populated
        # api_key_env in /etc/forgechat before retaining an existing key.
        self.assertEqual(_validate_request(self.request(record))[0].issue, _NO_KEY_ISSUE)


class HelperWireProtocolTests(unittest.IsolatedAsyncioTestCase):
    async def test_client_and_helper_roundtrip_over_real_socket(self):
        import forgechat.import_helper as helper
        from forgechat.app import _configured_provider_import_apply
        from forgechat.import_backup import ProviderCandidate, discover_candidates

        settings = {
            "format": "forge-drive-settings-v1",
            "profiles": {"openai": {"key": "sk-wire-123", "base": "https://api.openai.com/v1", "model": "gpt-4o-mini"}},
            "customProviders": [], "knownKeys": [],
        }
        candidates = [c for c in discover_candidates(settings) if not c.issue]
        with tempfile.TemporaryDirectory() as tmp:
            providers_path = Path(tmp) / "providers.json"
            env_path = Path(tmp) / "forgechat.env"
            providers_path.write_text("[]\n")
            env_path.write_text("")
            original_paths = helper.PROVIDERS_PATH, helper.ENV_PATH
            helper.PROVIDERS_PATH, helper.ENV_PATH = providers_path, env_path
            socket_path = Path(tmp) / "daemon.sock"
            original_socket = helper.SOCKET_PATH
            helper.SOCKET_PATH = socket_path
            import forgechat.app as app_module
            original_app_socket = app_module._IMPORT_SOCKET_PATH
            app_module._IMPORT_SOCKET_PATH = str(socket_path)
            # The handler reads module constants at call time, so patching works.
            server = helper._ImportServer(str(socket_path))
            try:
                serve_task = asyncio.get_running_loop().run_in_executor(None, server.handle_request)
                await asyncio.sleep(0.1)
                imported = await _configured_provider_import_apply(candidates)
                await asyncio.wait_for(serve_task, timeout=10)
            finally:
                server.server_close()
                helper.PROVIDERS_PATH, helper.ENV_PATH = original_paths
                helper.SOCKET_PATH = original_socket
                app_module._IMPORT_SOCKET_PATH = original_app_socket
            self.assertEqual(imported, ["openai"])
            catalog = json.loads(providers_path.read_text())
            self.assertEqual(catalog[0]["id"], "openai")
            self.assertEqual(catalog[0]["api_key_env"], "FORGECHAT_OPENAI_API_KEY")
            self.assertIn("FORGECHAT_OPENAI_API_KEY=sk-wire-123", env_path.read_text())


if __name__ == "__main__":
    unittest.main()