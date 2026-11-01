from __future__ import annotations

import asyncio
import json
import tempfile
import unittest
from pathlib import Path
from typing import Any
from unittest.mock import patch
from urllib.parse import urlencode, urlsplit

import httpx

from forgechat.app import create_app
from forgechat.auth import create_session, hash_password, read_session, verify_password
from forgechat.config import Provider, Settings
from forgechat.providers import UpstreamError
from forgechat.tts import TtsAudio


class FakeImageGeneration:
    def __init__(self):
        self.calls: list[dict[str, Any]] = []

    async def __call__(self, provider, model, prompt, **options):
        self.calls.append({"provider": provider, "model": model, "prompt": prompt, "options": options})
        return {"ok": True, "providerId": provider.id, "model": model, "count": 1, "images": [{"url": "https://cdn.example.test/generated.png", "revised_prompt": "safe"}]}


class FakeTts:
    def __init__(self):
        self.calls: list[dict[str, Any]] = []

    async def __call__(self, provider, **options):
        self.calls.append({"provider": provider, "options": options})
        mime = {"mp3": "audio/mpeg", "wav": "audio/wav", "opus": "audio/opus", "aac": "audio/aac", "flac": "audio/flac", "pcm": "audio/pcm"}[options["output_format"]]
        return TtsAudio(b"FAKE-AUDIO", mime, options["engine"], options["voice"], options["model"], provider.id)


class FakeLocalTts:
    def __init__(self):
        self.calls: list[dict[str, Any]] = []

    async def __call__(self, **options):
        self.calls.append(options)
        return TtsAudio(b"FAKE-WAV", "audio/wav", "local", options["voice"], "espeak-ng", "vm-local")

class FakeTranscription:
    def __init__(self):
        self.calls: list[dict[str, Any]] = []

    async def __call__(self, request, **options):
        self.calls.append({"request": request, "options": options})
        return {"text": "recognized words", "segments": [{"start": 0.0, "end": 1.0, "text": "recognized words"}], "providerId": "openai"}

class FakeUpstream:
    def __init__(self):
        self.calls: list[dict[str, Any]] = []

    async def __call__(self, provider, model, messages, **options):
        self.calls.append({"provider": provider, "model": model, "messages": messages, "options": options})
        return {
            "ok": True,
            "content": "server response",
            "text": "server response",
            "provider": provider.label,
            "providerId": provider.id,
            "model": model,
            "usage": None,
        }


async def asgi_request(app, method: str, path: str, *, body: Any = None, headers: dict[str, str] | None = None):
    if body is None:
        raw_body = b""
    elif isinstance(body, bytes):
        raw_body = body
    elif isinstance(body, str):
        raw_body = body.encode("utf-8")
    else:
        raw_body = json.dumps(body).encode("utf-8")
    all_headers = {"host": "forge.example.test", "origin": "https://forge.example.test"}
    all_headers.update(headers or {})
    lower_headers = {key.lower() for key in all_headers}
    if body is not None and "content-type" not in lower_headers:
        all_headers["content-type"] = "application/json"
    if body is not None and "content-length" not in lower_headers:
        all_headers["content-length"] = str(len(raw_body))
    encoded_headers = [(key.lower().encode("latin1"), value.encode("latin1")) for key, value in all_headers.items()]
    received = False
    sent: list[dict[str, Any]] = []
    response_done = asyncio.Event()

    async def receive():
        nonlocal received
        if not received:
            received = True
            return {"type": "http.request", "body": raw_body, "more_body": False}
        await response_done.wait()
        return {"type": "http.disconnect"}

    async def send(message):
        sent.append(message)
        if message.get("type") == "http.response.body" and not message.get("more_body", False):
            response_done.set()

    parsed_path = urlsplit(path)
    route_path = parsed_path.path
    scope = {
        "type": "http",
        "asgi": {"version": "3.0", "spec_version": "2.3"},
        "http_version": "1.1",
        "method": method,
        "scheme": "https",
        "path": route_path,
        "raw_path": route_path.encode("ascii"),
        "query_string": parsed_path.query.encode("ascii"),
        "headers": encoded_headers,
        "client": ("127.0.0.1", 45678),
        "server": ("forge.example.test", 443),
    }
    await app(scope, receive, send)
    start = next(message for message in sent if message["type"] == "http.response.start")
    payload = b"".join(message.get("body", b"") for message in sent if message["type"] == "http.response.body")
    if not payload:
        decoded = None
    else:
        try:
            decoded = json.loads(payload)
        except json.JSONDecodeError:
            decoded = payload.decode("utf-8", errors="replace")
    return start["status"], dict(start.get("headers", [])), decoded


class AuthHelperTests(unittest.TestCase):
    def test_password_hash_and_signed_session_expiry(self):
        with self.assertRaisesRegex(ValueError, "9 and 1024"):
            hash_password("12345678", rounds=100_000)
        minimum_password = hash_password("123456789", rounds=100_000)
        self.assertTrue(verify_password("123456789", minimum_password))
        encoded = hash_password("correct horse battery", rounds=100_000, salt=b"s" * 16)
        self.assertTrue(verify_password("correct horse battery", encoded))
        self.assertFalse(verify_password("wrong password", encoded))
        token = create_session("owner", "secret" * 8, expires_at=200)
        self.assertEqual(read_session(token, "secret" * 8, now=100), "owner")
        self.assertIsNone(read_session(token, "wrong-secret" * 4, now=100))
        self.assertIsNone(read_session(token, "secret" * 8, now=200))


class ServiceTests(unittest.IsolatedAsyncioTestCase):
    @classmethod
    def setUpClass(cls):
        cls.password_hash = hash_password("correct horse battery", rounds=100_000, salt=b"t" * 16)

    def make_app(self, fake=None, stream_fake=None, image_fake=None, tts_fake=None, local_tts_fake=None, transcription_fake=None, agent_transport=None, **changes):
        provider = Provider(
            id="openai",
            label="OpenAI",
            kind="openai",
            base_url="https://api.openai.com/v1",
            api_key="server-only-provider-secret",
            default_model="gpt-4o-mini",
            models=("gpt-4o-mini", "gpt-4o"),
        )
        values = dict(
            username="owner",
            password_hash=self.password_hash,
            session_secret="s" * 48,
            public_origin="https://forge.example.test",
            base_path="/forgechat",
            app_dir=Path(tempfile.mkdtemp(prefix="forgechat-test-apps-")),
            providers=(provider,),
        )
        values.update(changes)
        application = create_app(Settings(**values), upstream_call=fake, upstream_stream_call=stream_fake, image_generation_call=image_fake, tts_call=tts_fake, local_tts_call=local_tts_fake, transcription_call=transcription_fake, agent_transport=agent_transport)
        application.state.test_app_dir = values["app_dir"]
        return application, provider

    async def login(self, app, **headers):
        return await self.login_as(app, "owner", "correct horse battery", **headers)

    async def login_as(self, app, username, password, **headers):
        status, response_headers, payload = await asgi_request(
            app,
            "POST",
            "/api/v1/auth/login",
            body={"username": username, "password": password},
            headers=headers,
        )
        self.assertEqual(status, 200, payload)
        set_cookie = response_headers[b"set-cookie"].decode("latin1")
        return set_cookie.split(";", 1)[0], set_cookie

    async def test_login_cookie_and_provider_discovery_never_expose_keys(self):
        app, _ = self.make_app()
        status, _, _ = await asgi_request(app, "GET", "/api/v1/providers")
        self.assertEqual(status, 401)
        status, _, _ = await asgi_request(app, "GET", "/api/v1/session")
        self.assertEqual(status, 401)
        status, _, _ = await asgi_request(app, "GET", "/healthz")
        self.assertEqual(status, 401)

        cookie, set_cookie = await self.login(app)
        self.assertIn("HttpOnly", set_cookie)
        self.assertIn("Secure", set_cookie)
        self.assertIn("SameSite=strict", set_cookie)
        self.assertIn("Path=/forgechat", set_cookie)

        status, _, session = await asgi_request(app, "GET", "/api/v1/session", headers={"cookie": cookie})
        self.assertEqual(status, 200)
        self.assertTrue(session["authenticated"])
        status, _, health = await asgi_request(app, "GET", "/healthz", headers={"cookie": cookie})
        self.assertEqual((status, health), (200, {"ok": True}))

        status, _, providers = await asgi_request(app, "GET", "/api/v1/providers", headers={"cookie": cookie})
        self.assertEqual(status, 200)
        serialized = json.dumps(providers)
        self.assertIn("gpt-4o-mini", serialized)
        self.assertNotIn("server-only-provider-secret", serialized)

    async def test_login_rejects_bad_origin_and_throttles_failures(self):
        app, _ = self.make_app(login_max_attempts=2)
        status, _, _ = await asgi_request(
            app,
            "POST",
            "/api/v1/auth/login",
            body={"username": "owner", "password": "correct horse battery"},
            headers={"origin": "https://attacker.example"},
        )
        self.assertEqual(status, 403)
        for _ in range(2):
            status, _, _ = await asgi_request(app, "POST", "/api/v1/auth/login", body={"username": "owner", "password": "bad"})
            self.assertEqual(status, 401)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/auth/login", body={"username": "owner", "password": "correct horse battery"})
        self.assertEqual(status, 429)

    async def test_login_accepts_canonical_origin_and_same_origin_fetch_metadata(self):
        app, _ = self.make_app()
        status, _, _ = await asgi_request(
            app,
            "POST",
            "/api/v1/auth/login",
            body={"username": "owner", "password": "correct horse battery"},
            headers={"origin": "https://forge.example.test:443"},
        )
        self.assertEqual(status, 200)

        app, _ = self.make_app()
        form = urlencode({"username": "owner", "password": "correct horse battery", "next": "/forgechat/publish"})
        status, headers, _ = await asgi_request(
            app,
            "POST",
            "/api/v1/auth/login",
            body=form,
            headers={
                "content-type": "application/x-www-form-urlencoded",
                "origin": "",
                "sec-fetch-site": "same-origin",
            },
        )
        self.assertEqual(status, 303)
        self.assertEqual(headers[b"location"], b"/forgechat/publish")
        self.assertIn(b"forgechat_session=", headers[b"set-cookie"])

        app, _ = self.make_app()
        status, _, _ = await asgi_request(
            app,
            "POST",
            "/api/v1/auth/logout",
            headers={"origin": "null", "sec-fetch-site": "same-origin"},
        )
        self.assertEqual(status, 401)
        status, _, _ = await asgi_request(
            app,
            "POST",
            "/api/v1/auth/logout",
            headers={"origin": "https://attacker.example", "sec-fetch-site": "same-origin"},
        )
        self.assertEqual(status, 403)

    async def test_chat_uses_only_configured_provider_and_returns_normalized_result(self):
        fake = FakeUpstream()
        app, provider = self.make_app(fake)
        cookie, _ = await self.login(app)
        status, _, result = await asgi_request(
            app,
            "POST",
            "/api/v1/chat",
            body={
                "providerId": "openai",
                "model": "gpt-4o-mini",
                "messages": [{"role": "user", "content": "Hi Forge"}],
            },
            headers={"cookie": cookie},
        )
        self.assertEqual(status, 200, result)
        self.assertEqual(result["content"], "server response")
        self.assertEqual(fake.calls[0]["provider"], provider)
        self.assertEqual(fake.calls[0]["messages"][0]["content"], "Hi Forge")

    async def test_streaming_chat_is_authenticated_origin_checked_and_emits_sse_deltas(self):
        calls = []
        async def fake_stream(provider, model, messages, **options):
            calls.append((provider.id, model, messages, options))
            yield "Hello "
            yield "stream"
        app, _ = self.make_app(stream_fake=fake_stream)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/chat/stream", body={"messages":[{"role":"user","content":"Hi"}]})
        self.assertEqual(status, 401)
        cookie, _ = await self.login(app)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/chat/stream", body={"messages":[{"role":"user","content":"Hi"}]}, headers={"cookie":cookie,"origin":"https://attacker.example"})
        self.assertEqual(status, 403)
        self.assertEqual(calls, [])
        status, headers, body = await asgi_request(app, "POST", "/api/v1/chat/stream", body={"providerId":"openai","messages":[{"role":"user","content":"Hi"}]}, headers={"cookie":cookie})
        self.assertEqual(status, 200)
        self.assertIn(b"text/event-stream", headers[b"content-type"])
        self.assertEqual(headers[b"x-accel-buffering"], b"no")
        self.assertIn('"type": "delta", "content": "Hello "', body)
        self.assertIn('"type": "delta", "content": "stream"', body)
        self.assertIn('data: {"type":"done"}', body)
        self.assertEqual(calls[0][1], "gpt-4o-mini")

    async def test_streaming_provider_failure_is_generic_and_rate_limited(self):
        async def broken_stream(provider, model, messages, **options):
            yield "partial"
            raise UpstreamError(504)
        app, _ = self.make_app(stream_fake=broken_stream, ai_rate_max_requests=1)
        cookie, _ = await self.login(app)
        status, _, body = await asgi_request(app, "POST", "/api/v1/chat/stream", body={"messages":[{"role":"user","content":"Hi"}]}, headers={"cookie":cookie})
        self.assertEqual(status, 200)
        self.assertIn('"type": "error", "status": 504', body)
        self.assertNotIn("server-only-provider-secret", body)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/chat/stream", body={"messages":[{"role":"user","content":"Hi"}]}, headers={"cookie":cookie})
        self.assertEqual(status, 429)

    async def test_chat_rejects_cross_origin_and_untrusted_provider_url(self):
        fake = FakeUpstream()
        app, _ = self.make_app(fake)
        cookie, _ = await self.login(app)
        payload = {"messages": [{"role": "user", "content": "Hi"}], "endpoint": "https://attacker.example"}
        status, _, _ = await asgi_request(app, "POST", "/api/v1/chat", body=payload, headers={"cookie": cookie})
        self.assertEqual(status, 400)
        self.assertEqual(fake.calls, [])
        status, _, _ = await asgi_request(
            app,
            "POST",
            "/api/v1/chat",
            body={"messages": [{"role": "user", "content": "Hi"}]},
            headers={"cookie": cookie, "origin": "https://attacker.example"},
        )
        self.assertEqual(status, 403)
        self.assertEqual(fake.calls, [])

    async def test_chat_rejects_disallowed_models_and_oversized_body(self):
        fake = FakeUpstream()
        app, _ = self.make_app(fake, max_request_bytes=256)
        cookie, _ = await self.login(app)
        status, _, _ = await asgi_request(
            app,
            "POST",
            "/api/v1/chat",
            body={"providerId": "openai", "model": "not-allowed", "messages": [{"role": "user", "content": "Hi"}]},
            headers={"cookie": cookie},
        )
        self.assertEqual(status, 400)
        status, _, _ = await asgi_request(
            app,
            "POST",
            "/api/v1/chat",
            body={"messages": [{"role": "user", "content": "x" * 1000}]},
            headers={"cookie": cookie},
        )
        self.assertEqual(status, 413)
        self.assertEqual(fake.calls, [])

    async def test_exported_pages_are_private_and_browser_can_remember_login(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "apps"
            root.mkdir()
            (root / "demo.html").write_text("<!doctype html><title>private app</title>", encoding="utf-8")
            outside = Path(temp) / "outside.html"
            outside.write_text("should not escape app root", encoding="utf-8")
            (root / "escape.html").symlink_to(outside)
            app, _ = self.make_app(app_dir=root, session_seconds=3600, remember_session_seconds=86400)

            status, redirect_headers, _ = await asgi_request(app, "GET", "/apps/demo")
            self.assertEqual(status, 303)
            self.assertIn(b"/forgechat/login", redirect_headers[b"location"])
            self.assertNotIn(b"private app", redirect_headers.get(b"body", b""))
            status, publish_redirect, _ = await asgi_request(app, "GET", "/publish")
            self.assertEqual(status, 303)
            self.assertIn(b"next=%2Fforgechat%2Fpublish", publish_redirect[b"location"])

            status, login_headers, page = await asgi_request(app, "GET", "/login?next=%2Fforgechat%2Fapps%2Fdemo")
            self.assertEqual(status, 200)
            self.assertIn(b"frame-ancestors 'none'", login_headers[b"content-security-policy"])
            self.assertEqual(login_headers[b"x-frame-options"], b"DENY")
            self.assertEqual(login_headers[b"referrer-policy"], b"same-origin")
            self.assertIn('autocomplete="username"', page)
            self.assertIn('autocomplete="current-password"', page)
            self.assertIn('action="/forgechat/api/v1/auth/login"', page)
            self.assertIn('name="next" value="/forgechat/apps/demo"', page)
            self.assertIn("Remember me on this device", page)
            self.assertNotIn("correct horse battery", page)

            form = urlencode({"username": "owner", "password": "correct horse battery", "remember": "1", "next": "/forgechat/apps/demo"})
            status, headers, _ = await asgi_request(
                app,
                "POST",
                "/api/v1/auth/login",
                body=form,
                headers={"content-type": "application/x-www-form-urlencoded", "accept": "text/html"},
            )
            self.assertEqual(status, 303)
            self.assertEqual(headers[b"location"], b"/forgechat/apps/demo")
            cookie_header = headers[b"set-cookie"].decode("latin1")
            self.assertIn("Max-Age=86400", cookie_header)
            cookie = cookie_header.split(";", 1)[0]

            status, _, page = await asgi_request(app, "GET", "/apps/demo", headers={"cookie": cookie})
            self.assertEqual(status, 200)
            self.assertIn("private app", page)
            status, _, _ = await asgi_request(app, "GET", "/apps/escape", headers={"cookie": cookie})
            self.assertEqual(status, 404)
            status, _, listing = await asgi_request(app, "GET", "/apps/", headers={"cookie": cookie})
            self.assertEqual(status, 200)
            self.assertIn("demo", listing)
            self.assertNotIn("escape", listing)

    async def test_publish_page_uploads_only_slugged_html_into_private_root(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "private-apps"
            root.mkdir()
            app, _ = self.make_app(app_dir=root)
            status, _, _ = await asgi_request(app, "GET", "/publish")
            self.assertEqual(status, 303)
            cookie, _ = await self.login(app)
            status, publish_headers, page = await asgi_request(app, "GET", "/publish", headers={"cookie": cookie})
            self.assertEqual(status, 200)
            self.assertIn('type="file"', page)
            self.assertIn("Export for ForgeChat · no keys", page)
            self.assertIn(b"form-action 'self'", publish_headers[b"content-security-policy"])
            self.assertEqual(publish_headers[b"x-frame-options"], b"DENY")
            self.assertIn("credentials:'same-origin'", page)

            source = "<!doctype html><html><head><title>Hosted</title></head><body>private app</body></html>"
            status, _, result = await asgi_request(
                app,
                "POST",
                "/api/v1/apps",
                body={"id": "my_app-1", "html": source},
                headers={"cookie": cookie},
            )
            self.assertEqual(status, 200, result)
            self.assertEqual(result["url"], "/forgechat/apps/my_app-1")
            self.assertEqual((root / "my_app-1.html").read_text(encoding="utf-8"), source)
            status, _, hosted = await asgi_request(app, "GET", "/apps/my_app-1", headers={"cookie": cookie})
            self.assertEqual(status, 200)
            self.assertIn("private app", hosted)

            for invalid_id in ("../escape", "contains/slash", "bad id"):
                status, _, _ = await asgi_request(
                    app,
                    "POST",
                    "/api/v1/apps",
                    body={"id": invalid_id, "html": source},
                    headers={"cookie": cookie},
                )
                self.assertEqual(status, 400)
            self.assertEqual(sorted(path.name for path in root.iterdir()), ["my_app-1.html"])

    async def test_upload_size_limit_and_origin_are_enforced(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "apps"
            root.mkdir()
            app, _ = self.make_app(app_dir=root, max_request_bytes=4096, max_app_bytes=256)
            cookie, _ = await self.login(app)
            source = "<!doctype html><html>" + ("x" * 400) + "</html>"
            status, _, _ = await asgi_request(app, "POST", "/api/v1/apps", body={"id": "big", "html": source}, headers={"cookie": cookie})
            self.assertEqual(status, 413)
            status, _, _ = await asgi_request(
                app,
                "POST",
                "/api/v1/apps",
                body={"id": "safe", "html": "<!doctype html><html></html>"},
                headers={"cookie": cookie, "origin": "https://attacker.example"},
            )
            self.assertEqual(status, 403)
            self.assertEqual(list(root.iterdir()), [])

    async def test_remember_me_controls_session_lifetime(self):
        app, _ = self.make_app(session_seconds=3600, remember_session_seconds=86400)
        _, cookie = await self.login(app)
        self.assertIn("Max-Age=3600", cookie)
        app, _ = self.make_app(session_seconds=3600, remember_session_seconds=86400)
        status, headers, payload = await asgi_request(
            app,
            "POST",
            "/api/v1/auth/login",
            body={"username": "owner", "password": "correct horse battery", "remember": True},
        )
        self.assertEqual(status, 200)
        self.assertEqual(payload["expiresIn"], 86400)
        self.assertIn(b"Max-Age=86400", headers[b"set-cookie"])

    async def test_user_accounts_app_allowlists_and_owner_controls(self):
        fake = FakeUpstream()
        app, _ = self.make_app(fake)
        owner_cookie, _ = await self.login(app)
        # Publish through the owner API; the app root is isolated per test.
        status, _, _ = await asgi_request(app, "POST", "/api/v1/apps", body={"id": "demo", "html": "<!doctype html><html><body>demo</body></html>"}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/admin/users", body={"username": "alice", "password": "correct alice password"}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 201)
        user_cookie, _ = await self.login_as(app, "alice", "correct alice password")
        status, _, _ = await asgi_request(app, "GET", "/apps/demo", headers={"cookie": user_cookie})
        self.assertEqual(status, 404, "apps are owner-only until explicitly allowlisted")
        status, _, _ = await asgi_request(app, "GET", "/api/v1/providers", headers={"cookie": user_cookie, "x-forgechat-app": "demo"})
        self.assertEqual(status, 403)
        status, _, _ = await asgi_request(app, "GET", "/api/v1/providers", headers={"cookie": user_cookie})
        self.assertEqual(status, 403, "accounts without any app grant cannot use provider APIs")
        status, _, page = await asgi_request(app, "GET", "/apps/", headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        self.assertIn("App access", page)
        status, _, _ = await asgi_request(app, "PUT", "/api/v1/admin/apps/demo/access", body={"users": ["alice"]}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        status, _, body = await asgi_request(app, "GET", "/apps/", headers={"cookie": user_cookie})
        self.assertEqual(status, 200)
        self.assertIn("demo", body)
        status, _, source = await asgi_request(app, "GET", "/apps/demo", headers={"cookie": user_cookie})
        self.assertEqual(status, 200)
        self.assertIn("demo", source)
        status, _, providers = await asgi_request(app, "GET", "/api/v1/providers", headers={"cookie": user_cookie, "x-forgechat-app": "demo"})
        self.assertEqual(status, 200)
        self.assertNotIn("server-only-provider-secret", json.dumps(providers))
        status, _, chat_result = await asgi_request(app, "POST", "/api/v1/chat", body={"messages": [{"role": "user", "content": "hello"}]}, headers={"cookie": user_cookie, "x-forgechat-app": "demo"})
        self.assertEqual(status, 200)
        self.assertEqual(chat_result["content"], "server response")
        status, _, legacy_providers = await asgi_request(app, "GET", "/api/v1/providers", headers={"cookie": user_cookie})
        self.assertEqual(status, 200, "older ForgeChat exports remain usable with at least one live app assignment")
        self.assertEqual(len(legacy_providers["providers"]), 1)
        status, _, legacy_chat = await asgi_request(app, "POST", "/api/v1/chat", body={"messages": [{"role": "user", "content": "hello"}]}, headers={"cookie": user_cookie})
        self.assertEqual(status, 200)
        self.assertEqual(legacy_chat["content"], "server response")
        status, _, _ = await asgi_request(app, "GET", "/users", headers={"cookie": user_cookie})
        self.assertEqual(status, 403)
        status, _, _ = await asgi_request(app, "GET", "/provider-import", headers={"cookie": user_cookie})
        self.assertEqual(status, 403)
        status, _, _ = await asgi_request(app, "GET", "/api/v1/admin/apps/providers", headers={"cookie": user_cookie})
        self.assertEqual(status, 403)
        status, _, _ = await asgi_request(app, "PUT", "/api/v1/admin/apps/demo/providers", body={"providerIds": ["openai"], "defaultProviderId": "openai"}, headers={"cookie": user_cookie})
        self.assertEqual(status, 403)
        status, _, _ = await asgi_request(app, "PUT", "/api/v1/admin/apps/demo/access", body={"users": []}, headers={"cookie": user_cookie})
        self.assertEqual(status, 403)
        status, _, _ = await asgi_request(app, "PATCH", "/api/v1/admin/users/alice", body={"enabled": False}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        status, _, _ = await asgi_request(app, "GET", "/api/v1/session", headers={"cookie": user_cookie})
        self.assertEqual(status, 401)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/auth/login", body={"username": "alice", "password": "correct alice password"})
        self.assertEqual(status, 401)
        status, _, _ = await asgi_request(app, "PATCH", "/api/v1/admin/users/owner", body={"enabled": False}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 404, "the owner cannot be disabled")
        status, _, _ = await asgi_request(app, "DELETE", "/api/v1/admin/users/owner", headers={"cookie": owner_cookie})
        self.assertEqual(status, 404, "the owner cannot be deleted")
        status, _, _ = await asgi_request(app, "DELETE", "/api/v1/admin/apps/demo", headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        status, _, _ = await asgi_request(app, "GET", "/apps/demo", headers={"cookie": owner_cookie})
        self.assertEqual(status, 404)

    async def test_owner_can_configure_per_app_providers_and_defaults(self):
        fake = FakeUpstream()
        provider = Provider(
            id="openai", label="OpenAI", kind="openai", base_url="https://api.openai.com/v1",
            api_key="server-only-provider-secret", default_model="gpt-4o-mini", models=("gpt-4o-mini", "gpt-4o"),
        )
        second = Provider(
            id="groq", label="Groq", kind="openai", base_url="https://api.groq.com/openai/v1",
            api_key="groq-server-secret", default_model="llama-3.3-70b-versatile", models=("llama-3.3-70b-versatile",),
        )
        app, _ = self.make_app(fake, providers=(provider, second))
        owner_cookie, _ = await self.login(app)
        status, _, published = await asgi_request(app, "POST", "/api/v1/apps", body={"id": "demo", "html": "<!doctype html><html><body>demo</body></html>"}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        status, _, catalog = await asgi_request(app, "GET", "/api/v1/admin/apps/providers", headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        self.assertEqual([item["id"] for item in catalog["providers"]], ["openai", "groq"])
        self.assertEqual(catalog["apps"][0]["providerIds"], ["openai", "groq"])
        status, _, saved = await asgi_request(app, "PUT", "/api/v1/admin/apps/demo/providers", body={"providerIds": ["groq"], "defaultProviderId": "groq"}, headers={"cookie": owner_cookie})
        self.assertEqual((status, saved["defaultProviderId"], saved["providerIds"]), (200, "groq", ["groq"]))
        status, _, public_catalog = await asgi_request(app, "GET", "/api/v1/providers", headers={"cookie": owner_cookie, "x-forgechat-app": "demo"})
        self.assertEqual((status, public_catalog["defaultId"], [p["id"] for p in public_catalog["providers"]]), (200, "groq", ["groq"]))
        status, _, result = await asgi_request(app, "POST", "/api/v1/chat", body={"messages": [{"role": "user", "content": "hi"}]}, headers={"cookie": owner_cookie, "x-forgechat-app": "demo"})
        self.assertEqual((status, result["providerId"]), (200, "groq"))
        status, _, _ = await asgi_request(app, "POST", "/api/v1/chat", body={"providerId": "openai", "messages": [{"role": "user", "content": "hi"}]}, headers={"cookie": owner_cookie, "x-forgechat-app": "demo"})
        self.assertEqual(status, 503)
        status, _, _ = await asgi_request(app, "PUT", "/api/v1/admin/apps/demo/providers", body={"providerIds": ["missing"], "defaultProviderId": "missing"}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 400)
        status, _, forbidden = await asgi_request(app, "PUT", "/api/v1/admin/apps/demo/providers", body={"providerIds": ["groq"], "defaultProviderId": "groq"}, headers={"cookie": owner_cookie, "origin": "https://attacker.example"})
        self.assertEqual(status, 403)

    async def test_backend_agent_routes_stay_disabled_without_separate_credentials(self):
        app, _ = self.make_app()
        owner_cookie, _ = await self.login(app)
        status, _, result = await asgi_request(app, "GET", "/api/v1/agent/status", headers={"cookie": owner_cookie})
        self.assertEqual(status, 503)
        self.assertIn("not configured", result["detail"])

    async def test_backend_agent_is_owner_or_explicit_agent_allowlist_only(self):
        expected_auth = "Basic " + __import__("base64").b64encode(b"worker-user:worker-pass").decode("ascii")
        requests: list[httpx.Request] = []

        async def worker(request: httpx.Request) -> httpx.Response:
            if request.headers.get("authorization") != expected_auth:
                return httpx.Response(401, json={"ok": False, "errmsg": "unauthorized"})
            requests.append(request)
            if request.url.path == "/status":
                return httpx.Response(200, json={"ok": True, "version": "1.0.0", "root": "/workspace"})
            if request.url.path == "/exec":
                job = json.loads(await request.aread())
                return httpx.Response(200, json={"ok": True, "stdout": job.get("script", ""), "exitCode": 0, "id": job["id"]})
            if request.url.path == "/files" and request.method == "GET":
                return httpx.Response(200, content=b"agent file", headers={"content-type": "text/plain", "content-length": "10"})
            if request.url.path == "/files" and request.method == "PUT":
                data = await request.aread()
                return httpx.Response(200, json={"ok": True, "path": request.url.params.get("destination"), "bytes": len(data), "sha256": "test"})
            return httpx.Response(404, json={"ok": False, "errmsg": "not found"})

        app, _ = self.make_app(
            agent_transport=httpx.MockTransport(worker),
            agent_username="worker-user",
            agent_password="worker-pass",
        )
        owner_cookie, _ = await self.login(app)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/admin/users", body={"username": "alice", "password": "correct alice password"}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 201)
        alice_cookie, _ = await self.login_as(app, "alice", "correct alice password")

        status, _, _ = await asgi_request(app, "GET", "/api/v1/agent/status")
        self.assertEqual(status, 401)
        status, _, _ = await asgi_request(app, "GET", "/api/v1/agent/status", headers={"cookie": alice_cookie})
        self.assertEqual(status, 403, "app access alone never grants command execution")
        status, _, owner_status = await asgi_request(app, "GET", "/api/v1/agent/status", headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        self.assertEqual(owner_status["version"], "1.0.0")
        status, _, owner_exec = await asgi_request(app, "POST", "/api/v1/agent/exec", body={"script": "printf owner"}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        self.assertEqual(owner_exec["stdout"], "printf owner")
        status, _, _ = await asgi_request(app, "POST", "/api/v1/agent/exec", body={"script": "echo no", "env": {"secret": "bad"}}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 400, "arbitrary environment variables are never forwarded")

        status, _, grant = await asgi_request(app, "PUT", "/api/v1/admin/users/alice/agent-access", body={"allowed": True}, headers={"cookie": owner_cookie})
        self.assertEqual((status, grant["allowed"]), (200, True))
        status, _, users_page = await asgi_request(app, "GET", "/users", headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        self.assertIn("Revoke agent access", users_page)
        self.assertIn("alice", users_page)
        status, _, user_status = await asgi_request(app, "GET", "/api/v1/agent/status", headers={"cookie": alice_cookie})
        self.assertEqual((status, user_status["ok"]), (200, True))
        status, _, user_exec = await asgi_request(app, "POST", "/api/v1/agent/exec", body={"script": "printf alice", "timeoutMs": 5000}, headers={"cookie": alice_cookie})
        self.assertEqual((status, user_exec["ok"]), (200, True))
        self.assertEqual(requests[-1].headers["authorization"], expected_auth)
        status, headers, file_data = await asgi_request(app, "GET", "/api/v1/agent/files?path=fs%2Fnotes.txt", headers={"cookie": alice_cookie})
        self.assertEqual((status, file_data, headers[b"content-type"]), (200, "agent file", b"text/plain"))
        status, _, uploaded = await asgi_request(app, "PUT", "/api/v1/agent/files?destination=fs%2Fnotes.txt", body=b"abc", headers={"cookie": alice_cookie, "content-type": "text/plain"})
        self.assertEqual((status, uploaded["ok"], uploaded["bytes"]), (200, True, 3))

        status, _, _ = await asgi_request(app, "PUT", "/api/v1/admin/users/alice/agent-access", body={"allowed": False}, headers={"cookie": owner_cookie})
        self.assertEqual(status, 200)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/agent/exec", body={"script": "echo no"}, headers={"cookie": alice_cookie})
        self.assertEqual(status, 403)
        status, _, _ = await asgi_request(app, "PUT", "/api/v1/admin/users/alice/agent-access", body={"allowed": True}, headers={"cookie": alice_cookie})
        self.assertEqual(status, 403)

    async def test_password_change_revokes_old_cookie_and_keeps_new_session(self):
        app, _ = self.make_app()
        old_cookie, _ = await self.login(app)
        status, headers, payload = await asgi_request(app, "POST", "/api/v1/account/password", body={"currentPassword": "correct horse battery", "newPassword": "new secure owner password"}, headers={"cookie": old_cookie})
        self.assertEqual((status, payload), (200, {"ok": True}))
        new_cookie = headers[b"set-cookie"].decode("latin1").split(";", 1)[0]
        status, _, _ = await asgi_request(app, "GET", "/api/v1/session", headers={"cookie": old_cookie})
        self.assertEqual(status, 401)
        status, _, _ = await asgi_request(app, "GET", "/api/v1/session", headers={"cookie": new_cookie})
        self.assertEqual(status, 200)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/auth/login", body={"username": "owner", "password": "new secure owner password"})
        self.assertEqual(status, 200)

    async def test_python_execution_and_phone_app_launch_routes_do_not_exist(self):
        app, _ = self.make_app()
        for path in ("/api/v1/python/run", "/api/v1/termux/exec", "/api/v1/apps/launch"):
            status, _, _ = await asgi_request(app, "POST", path, body={"script": "print('no')"})
            self.assertEqual(status, 404, path)

    async def test_server_transcription_is_authenticated_bounded_and_server_key_only(self):
        fake = FakeTranscription()
        app, provider = self.make_app(transcription_fake=fake)
        payload = {"dataUrl": "data:audio/mpeg;base64,YXVkaW8=", "language": "en", "timestamps": True, "prompt": "names"}
        status, _, _ = await asgi_request(app, "POST", "/api/v1/transcribe", body=payload)
        self.assertEqual(status, 401)
        cookie, _ = await self.login(app)
        status, headers, result = await asgi_request(app, "POST", "/api/v1/transcribe", body=payload, headers={"cookie": cookie})
        self.assertEqual(status, 200, result)
        self.assertEqual(headers[b"cache-control"], b"no-store")
        self.assertEqual(result["text"], "recognized words")
        self.assertEqual(result["segments"][0]["end"], 1.0)
        self.assertNotIn("server-only-provider-secret", json.dumps(result))
        normalized = fake.calls[0]["request"]
        self.assertEqual(normalized["audio"], b"audio")
        self.assertEqual([item.id for item in normalized["providers"]], [provider.id])
        self.assertEqual(normalized["prompt"], "names")
        self.assertTrue(normalized["timestamps"])
        self.assertEqual(fake.calls[0]["options"]["max_response_bytes"], 2 * 1024 * 1024)
        bad_status, _, _ = await asgi_request(app, "POST", "/api/v1/transcribe", body={"url": "https://attacker.test/audio.mp3"}, headers={"cookie": cookie})
        self.assertEqual(bad_status, 400)

    async def test_server_tts_uses_configured_provider_and_voice_catalog(self):
        fake = FakeTts()
        app, _ = self.make_app(tts_fake=fake)
        status, _, _ = await asgi_request(app, "GET", "/api/v1/tts/voices")
        self.assertEqual(status, 401)
        cookie, _ = await self.login(app)
        status, _, catalog = await asgi_request(app, "GET", "/api/v1/tts/voices", headers={"cookie": cookie})
        self.assertEqual(status, 200)
        self.assertTrue(catalog["available"])
        self.assertEqual(catalog["engine"], "openai")
        self.assertEqual(catalog["defaultVoice"], "alloy")
        self.assertNotIn("server-only-provider-secret", json.dumps(catalog))

        payload = {"text": "Hello from VideoLingo", "providerId": "openai", "voice": "nova", "format": "mp3", "rate": 1.1}
        status, headers, audio = await asgi_request(app, "POST", "/api/v1/tts/synthesize", body=payload, headers={"cookie": cookie})
        self.assertEqual((status, headers[b"content-type"], audio), (200, b"audio/mpeg", "FAKE-AUDIO"))
        self.assertEqual(fake.calls[0]["provider"].id, "openai")
        self.assertEqual(fake.calls[0]["options"]["voice"], "nova")
        self.assertEqual(fake.calls[0]["options"]["speed"], 1.1)
        bad_voice = dict(payload, voice="../../etc/passwd")
        status, _, _ = await asgi_request(app, "POST", "/api/v1/tts/synthesize", body=bad_voice, headers={"cookie": cookie})
        self.assertEqual(status, 400)
        arbitrary = dict(payload, url="https://attacker.example/tts")
        status, _, _ = await asgi_request(app, "POST", "/api/v1/tts/synthesize", body=arbitrary, headers={"cookie": cookie})
        self.assertEqual(status, 400)
        self.assertEqual(len(fake.calls), 1)

    async def test_vm_local_tts_uses_offline_engine_without_provider_call(self):
        cloud = FakeTts()
        local = FakeLocalTts()
        app, _ = self.make_app(tts_fake=cloud, local_tts_fake=local, providers=())
        cookie, _ = await self.login(app)
        catalog = {"available": True, "engine": "local", "providerId": "vm-local", "defaultVoice": "en-us", "voices": [{"id": "en-us", "label": "English (en-us)"}]}
        with patch("forgechat.app.local_voice_catalog", return_value=catalog), patch("forgechat.tts.local_voice_catalog", return_value=catalog):
            status, _, voice_result = await asgi_request(app, "GET", "/api/v1/tts/voices?engine=local", headers={"cookie": cookie})
            self.assertEqual(status, 200)
            self.assertEqual(voice_result["engine"], "local")
            status, headers, audio = await asgi_request(
                app, "POST", "/api/v1/tts/synthesize",
                body={"engine": "local", "text": "Offline test", "voice": "en-us", "lang": "en-US", "rate": 1.2, "pitch": 0.9},
                headers={"cookie": cookie},
            )
        self.assertEqual((status, headers[b"content-type"], headers[b"x-forge-tts-engine"], audio), (200, b"audio/wav", b"local", "FAKE-WAV"))
        self.assertEqual(local.calls[0]["voice"], "en-us")
        self.assertEqual(local.calls[0]["speed"], 1.2)
        self.assertEqual(local.calls[0]["pitch"], 0.9)
        self.assertEqual(cloud.calls, [], "local mode must not call a configured provider")

    async def test_vm_local_tts_can_stage_to_agent_without_provider(self):
        local = FakeLocalTts()
        cloud = FakeTts()
        uploaded = []
        async def worker(request):
            if request.method == "GET" and request.url.path == "/status":
                return httpx.Response(200, json={"ok": True})
            uploaded.append(request)
            return httpx.Response(200, json={"ok": True})
        app, _ = self.make_app(
            tts_fake=cloud, local_tts_fake=local, providers=(),
            agent_transport=httpx.MockTransport(worker),
            agent_username="worker-user", agent_password="worker-pass",
        )
        cookie, _ = await self.login(app)
        catalog = {"available": True, "engine": "local", "providerId": "vm-local", "defaultVoice": "en-us", "voices": [{"id": "en-us"}]}
        with patch("forgechat.app.local_voice_catalog", return_value=catalog), patch("forgechat.tts.local_voice_catalog", return_value=catalog):
            status, _, result = await asgi_request(
                app, "POST", "/api/v1/tts/synthesize-to-agent",
                body={"engine": "local", "text": "offline subtitle", "voice": "en-us", "format": "wav", "destination": "tts/local.wav"},
                headers={"cookie": cookie},
            )
        self.assertEqual(status, 200, result)
        self.assertEqual(result["engine"], "local")
        self.assertEqual(result["agentPath"], "tts/local.wav")
        self.assertEqual(uploaded[0].content, b"FAKE-WAV")
        self.assertEqual(len(local.calls), 1)
        self.assertEqual(cloud.calls, [])

    async def test_server_tts_can_stage_audio_only_in_private_agent_workspace(self):
        fake = FakeTts()
        uploaded = []
        async def worker(request):
            if request.method == "GET" and request.url.path == "/status":
                return httpx.Response(200, json={"ok": True, "version": "test"})
            uploaded.append(request)
            self.assertEqual(request.method, "PUT")
            self.assertEqual(request.url.path, "/files")
            self.assertEqual(request.url.params["destination"], "tts/vl_1.wav")
            self.assertEqual(request.headers["content-type"], "audio/wav")
            self.assertIn("Basic ", request.headers["authorization"])
            return httpx.Response(200, json={"ok": True, "bytes": 8})
        app, _ = self.make_app(
            tts_fake=fake,
            agent_transport=httpx.MockTransport(worker),
            agent_username="worker-user", agent_password="worker-pass",
        )
        cookie, _ = await self.login(app)
        payload = {"text": "A subtitle", "voice": "alloy", "format": "wav", "destination": "tts/vl_1.wav"}
        status, _, result = await asgi_request(app, "POST", "/api/v1/tts/synthesize-to-agent", body=payload, headers={"cookie": cookie})
        self.assertEqual(status, 200, result)
        self.assertEqual(result["agentPath"], "tts/vl_1.wav")
        self.assertEqual(result["mime"], "audio/wav")
        self.assertEqual(len(uploaded), 1)
        self.assertNotIn("worker-pass", json.dumps(result))
        status, _, _ = await asgi_request(app, "POST", "/api/v1/tts/synthesize-to-agent", body=dict(payload, destination="../../outside.wav"), headers={"cookie": cookie})
        self.assertEqual(status, 400)

    async def test_tts_to_agent_fails_before_billing_when_agent_is_disabled(self):
        fake = FakeTts()
        app, _ = self.make_app(tts_fake=fake)
        cookie, _ = await self.login(app)
        status, _, result = await asgi_request(
            app, "POST", "/api/v1/tts/synthesize-to-agent",
            body={"text": "hello", "destination": "tts/hello.mp3"}, headers={"cookie": cookie},
        )
        self.assertEqual(status, 503)
        self.assertIn("backend agent is not configured", result["detail"])
        self.assertEqual(fake.calls, [], "do not call a billable provider before confirming the agent is ready")

    async def test_server_image_generation_uses_only_configured_provider(self):
        image_fake = FakeImageGeneration()
        xai = Provider(
            id="xai", label="xAI", kind="openai", base_url="https://api.x.ai/v1",
            api_key="server-image-secret", default_model="grok-3", models=("grok-3",),
            image_models=("grok-imagine-image",),
        )
        app, _ = self.make_app(image_fake=image_fake, providers=(xai,))
        cookie, _ = await self.login(app)
        payload = {"providerId": "xai", "model": "grok-imagine-image", "prompt": "A blue fox", "n": 2, "images": ["data:image/jpeg;base64,QUJD"], "confirm": True}
        status, _, result = await asgi_request(app, "POST", "/api/v1/images/generate", body=payload, headers={"cookie": cookie})
        self.assertEqual(status, 200)
        self.assertEqual(result["providerId"], "xai")
        self.assertNotIn("server-image-secret", json.dumps(result))
        self.assertEqual(image_fake.calls[0]["options"]["count"], 2)
        self.assertEqual(image_fake.calls[0]["options"]["images"], ["data:image/jpeg;base64,QUJD"])
        bad_model = dict(payload, model="unconfigured-model")
        status, _, _ = await asgi_request(app, "POST", "/api/v1/images/generate", body=bad_model, headers={"cookie": cookie})
        self.assertEqual(status, 400)
        unconfirmed = dict(payload, confirm=False)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/images/generate", body=unconfirmed, headers={"cookie": cookie})
        self.assertEqual(status, 400)
        unsafe_image = dict(payload, images=["https://attacker.example/image.png"])
        status, _, _ = await asgi_request(app, "POST", "/api/v1/images/generate", body=unsafe_image, headers={"cookie": cookie})
        self.assertEqual(status, 400)
        self.assertEqual(len(image_fake.calls), 1)

    async def test_chat_rate_limit_is_enforced_per_shared_account(self):
        fake = FakeUpstream()
        app, _ = self.make_app(fake, ai_rate_max_requests=1)
        cookie, _ = await self.login(app)
        payload = {"messages": [{"role": "user", "content": "Hi"}]}
        status, _, _ = await asgi_request(app, "POST", "/api/v1/chat", body=payload, headers={"cookie": cookie})
        self.assertEqual(status, 200)
        status, _, _ = await asgi_request(app, "POST", "/api/v1/chat", body=payload, headers={"cookie": cookie})
        self.assertEqual(status, 429)
        self.assertEqual(len(fake.calls), 1)

    async def test_logout_clears_session_cookie(self):
        app, _ = self.make_app()
        cookie, _ = await self.login(app)
        status, headers, payload = await asgi_request(app, "POST", "/api/v1/auth/logout", headers={"cookie": cookie})
        self.assertEqual(status, 200, payload)
        self.assertIn(b"Max-Age=0", headers[b"set-cookie"])
        status, _, _ = await asgi_request(app, "GET", "/api/v1/providers")
        self.assertEqual(status, 401)
        status, _, _ = await asgi_request(app, "GET", "/api/v1/providers", headers={"cookie": cookie})
        self.assertEqual(status, 401)  # logout revokes a copied session as well as clearing the browser cookie


if __name__ == "__main__":
    unittest.main()
