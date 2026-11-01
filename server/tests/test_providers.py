from __future__ import annotations

import asyncio
import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from forgechat.config import ConfigError, Provider, Settings, _load_providers
from forgechat.providers import UpstreamError, call_image_generation, call_upstream_stream, normalize_image_request, normalize_request, prepare_request


class ProviderAdapterTests(unittest.TestCase):
    def setUp(self):
        self.openai = Provider("openai", "OpenAI", "openai", "https://api.openai.com/v1", "sk-private", "gpt-4o-mini", ("gpt-4o-mini",))
        self.gemini = Provider("gemini", "Gemini", "gemini", "https://generativelanguage.googleapis.com/v1beta", "AIza-private", "gemini-2.5-flash", ("gemini-2.5-flash",))
        self.settings = Settings(
            username="owner",
            password_hash="pbkdf2_sha256$100000$" + ("ab" * 16) + "$" + ("cd" * 32),
            session_secret="s" * 48,
            public_origin="https://forge.example.test",
            base_path="/forgechat",
            providers=(self.openai, self.gemini),
        )

    def test_openai_key_is_only_in_authorization_header(self):
        url, headers, body = prepare_request(self.openai, "gpt-4o-mini", [{"role": "user", "content": "hello"}], temperature=0.4)
        self.assertEqual(url, "https://api.openai.com/v1/chat/completions")
        self.assertEqual(headers["Authorization"], "Bearer sk-private")
        self.assertNotIn("sk-private", url)
        self.assertEqual(body["stream"], False)

    def test_gemini_key_uses_header_not_query_string(self):
        url, headers, _ = prepare_request(self.gemini, "gemini-2.5-flash", [{"role": "user", "content": "hello"}], temperature=0.4)
        self.assertTrue(url.endswith("/models/gemini-2.5-flash:generateContent"))
        self.assertEqual(headers["x-goog-api-key"], "AIza-private")
        self.assertNotIn("AIza-private", url)
        self.assertNotIn("?key=", url)

    def test_stream_request_uses_provider_specific_sse_endpoint(self):
        openai_url, _, openai_body = prepare_request(self.openai, "gpt-4o-mini", [{"role":"user","content":"hi"}], temperature=0.4, stream=True)
        self.assertTrue(openai_url.endswith("/chat/completions"))
        self.assertTrue(openai_body["stream"])
        gemini_url, _, _ = prepare_request(self.gemini, "gemini-2.5-flash", [{"role":"user","content":"hi"}], temperature=0.4, stream=True)
        self.assertTrue(gemini_url.endswith(":streamGenerateContent?alt=sse"))

    def test_models_are_server_allowlisted(self):
        provider, model, *_ = normalize_request({"messages": [{"role": "user", "content": "hi"}]}, self.settings)
        self.assertEqual((provider.id, model), ("openai", "gpt-4o-mini"))
        with self.assertRaises(ValueError):
            normalize_request({"providerId": "openai", "model": "unlisted", "messages": [{"role": "user", "content": "hi"}]}, self.settings)

    def test_loopback_ollama_can_be_used_without_an_api_key(self):
        local = Provider("ollama", "Local Ollama", "openai", "http://127.0.0.1:11434/v1", "", "qwen3:0.6b", ("qwen3:0.6b",), auth_optional=True)
        settings = Settings(
            username="owner",
            password_hash="pbkdf2_sha256$100000$" + ("ab" * 16) + "$" + ("cd" * 32),
            session_secret="s" * 48,
            public_origin="https://forge.example.test",
            base_path="/forgechat",
            providers=(local,),
        )
        provider, model, *_ = normalize_request({"messages": [{"role": "user", "content": "hi"}]}, settings)
        self.assertEqual((provider.id, model), ("ollama", "qwen3:0.6b"))
        _, headers, _ = prepare_request(local, model, [{"role": "user", "content": "hi"}], temperature=0.4)
        self.assertNotIn("Authorization", headers)

    def test_config_only_allows_missing_credentials_on_loopback_openai(self):
        with tempfile.TemporaryDirectory() as temp:
            config = Path(temp) / "providers.json"
            config.write_text(json.dumps([{
                "id": "ollama", "kind": "openai", "base_url": "http://127.0.0.1:11434/v1",
                "default_model": "qwen3:0.6b", "models": ["qwen3:0.6b"]
            }]), encoding="utf-8")
            providers = _load_providers(str(config))
            self.assertTrue(providers[0].auth_optional)
            config.write_text(json.dumps([{
                "id": "remote", "kind": "openai", "base_url": "https://api.example/v1",
                "default_model": "model", "models": ["model"]
            }]), encoding="utf-8")
            with self.assertRaises(ConfigError):
                _load_providers(str(config))

    def test_caller_cannot_supply_an_upstream_url_or_extra_header(self):
        with self.assertRaises(ValueError):
            normalize_request({"endpoint": "https://attacker.invalid", "messages": [{"role": "user", "content": "hi"}]}, self.settings)
        with self.assertRaises(ValueError):
            normalize_request({"headers": {"Authorization": "attacker"}, "messages": [{"role": "user", "content": "hi"}]}, self.settings)

    def test_image_generation_requires_confirm_and_allowlisted_provider_model(self):
        xai = Provider("xai", "xAI", "openai", "https://api.x.ai/v1", "server-key", "grok-3", ("grok-3",), image_models=("grok-imagine-image",))
        settings = Settings(
            username="owner", password_hash=self.settings.password_hash, session_secret=self.settings.session_secret,
            public_origin=self.settings.public_origin, base_path=self.settings.base_path, providers=(xai,),
        )
        payload = {"providerId": "xai", "model": "grok-imagine-image", "prompt": "fox", "n": 2, "confirm": True, "images": ["data:image/jpeg;base64,QUJD"]}
        result = normalize_image_request(payload, settings)
        self.assertEqual(result[0].id, "xai")
        self.assertEqual(result[1:], ("grok-imagine-image", "fox", 2, ["data:image/jpeg;base64,QUJD"]))
        with self.assertRaises(ValueError):
            normalize_image_request(dict(payload, model="unlisted"), settings)
        with self.assertRaises(ValueError):
            normalize_image_request(dict(payload, confirm=False), settings)
        with self.assertRaises(ValueError):
            normalize_image_request(dict(payload, images=["https://attacker.invalid/image.png"]), settings)

    def test_xai_provider_gets_server_owned_image_model_defaults(self):
        with tempfile.TemporaryDirectory() as temp, patch.dict("os.environ", {"FORGECHAT_XAI_TEST_KEY": "server-key"}):
            config = Path(temp) / "providers.json"
            config.write_text(json.dumps([{
                "id": "xai", "kind": "openai", "base_url": "https://api.x.ai/v1",
                "default_model": "grok-3", "models": ["grok-3"], "api_key_env": "FORGECHAT_XAI_TEST_KEY"
            }]), encoding="utf-8")
            provider = _load_providers(str(config))[0]
            self.assertIn("grok-imagine-image", provider.image_models)
            self.assertEqual(provider.public_dict()["imageModels"], list(provider.image_models))


class ProviderStreamTests(unittest.IsolatedAsyncioTestCase):
    def setUp(self):
        self.openai = Provider("openai", "OpenAI", "openai", "https://api.openai.com/v1", "sk-private", "gpt-4o-mini", ("gpt-4o-mini",))
        self.gemini = Provider("gemini", "Gemini", "gemini", "https://generativelanguage.googleapis.com/v1beta", "AIza-private", "gemini-2.5-flash", ("gemini-2.5-flash",))

    async def collect(self, provider, lines):
        captured = {}
        class FakeResponse:
            status_code = 200
            async def __aenter__(self): return self
            async def __aexit__(self, *args): return False
            async def aiter_lines(self):
                for line in lines: yield line
        class FakeClient:
            def __init__(self, **options): captured["client"] = options
            async def __aenter__(self): return self
            async def __aexit__(self, *args): return False
            def stream(self, method, url, **options):
                captured.update(method=method,url=url,options=options)
                return FakeResponse()
        with patch.dict("sys.modules", {"httpx": SimpleNamespace(AsyncClient=FakeClient)}):
            output = [part async for part in call_upstream_stream(provider, provider.default_model, [{"role":"user","content":"hello"}], temperature=0.4, max_tokens=None, response_format=None, timeout_seconds=30, max_response_bytes=10000)]
        return output, captured

    async def test_server_image_request_uses_configured_key_and_normalizes_result(self):
        captured = {}
        result_json = json.dumps({"data": [{"url": "https://cdn.example.test/image.png", "revised_prompt": "night sky"}]}).encode()
        class FakeResponse:
            status_code = 200
            async def __aenter__(self): return self
            async def __aexit__(self, *args): return False
            async def aiter_bytes(self): yield result_json
        class FakeClient:
            def __init__(self, **options): captured["client"] = options
            async def __aenter__(self): return self
            async def __aexit__(self, *args): return False
            def stream(self, method, url, **options):
                captured.update(method=method, url=url, options=options)
                return FakeResponse()
        xai = Provider("xai", "xAI", "openai", "https://api.x.ai/v1", "server-image-secret", "grok-3", ("grok-3",), image_models=("grok-imagine-image",))
        with patch.dict("sys.modules", {"httpx": SimpleNamespace(AsyncClient=FakeClient)}):
            result = await call_image_generation(xai, "grok-imagine-image", "a small fox", count=1, images=[], timeout_seconds=45, max_response_bytes=1024)
        self.assertEqual(captured["url"], "https://api.x.ai/v1/images/generations")
        self.assertEqual(captured["options"]["headers"]["Authorization"], "Bearer server-image-secret")
        self.assertNotIn("server-image-secret", json.dumps(captured["options"]["json"]))
        self.assertFalse(captured["client"]["trust_env"])
        self.assertEqual(result["images"][0]["url"], "https://cdn.example.test/image.png")
        self.assertNotIn("server-image-secret", json.dumps(result))

    async def test_openai_sse_stream_yields_deltas_with_server_auth(self):
        output, captured = await self.collect(self.openai, [
            'data: {"choices":[{"delta":{"content":"Hello "}}]}',
            'data: {"choices":[{"delta":{"content":"world"}}]}',
            'data: [DONE]',
        ])
        self.assertEqual(output, ["Hello ", "world"])
        self.assertEqual(captured["method"], "POST")
        self.assertTrue(captured["options"]["json"]["stream"])
        self.assertFalse(captured["client"]["trust_env"])
        self.assertEqual(captured["options"]["headers"]["Authorization"], "Bearer sk-private")

    async def test_gemini_sse_stream_yields_candidate_text(self):
        output, captured = await self.collect(self.gemini, [
            'data: {"candidates":[{"content":{"parts":[{"text":"Gemini "}]}}]}',
            'data: {"candidates":[{"content":{"parts":[{"text":"delta"}]}}]}',
        ])
        self.assertEqual(output, ["Gemini ", "delta"])
        self.assertTrue(captured["url"].endswith(":streamGenerateContent?alt=sse"))
        self.assertEqual(captured["options"]["headers"]["x-goog-api-key"], "AIza-private")

    async def test_cancelling_stream_closes_the_upstream_response(self):
        started = asyncio.Event()
        closed = asyncio.Event()
        class SlowResponse:
            status_code = 200
            async def __aenter__(self): return self
            async def __aexit__(self, *args): closed.set(); return False
            async def aiter_lines(self):
                yield 'data: {"choices":[{"delta":{"content":"first"}}]}'
                started.set()
                await asyncio.Event().wait()
        class FakeClient:
            def __init__(self, **options): pass
            async def __aenter__(self): return self
            async def __aexit__(self, *args): return False
            def stream(self, *args, **kwargs): return SlowResponse()
        async def consume():
            return [part async for part in call_upstream_stream(self.openai, self.openai.default_model, [{"role":"user","content":"hi"}], temperature=0.4, max_tokens=None, response_format=None, timeout_seconds=30, max_response_bytes=10000)]
        with patch.dict("sys.modules", {"httpx": SimpleNamespace(AsyncClient=FakeClient)}):
            task = asyncio.create_task(consume())
            await started.wait()
            task.cancel()
            with self.assertRaises(asyncio.CancelledError):
                await task
        self.assertTrue(closed.is_set())

    async def test_upstream_stream_failure_is_sanitized(self):
        class FailedResponse:
            status_code = 429
            async def __aenter__(self): return self
            async def __aexit__(self, *args): return False
            async def aiter_lines(self):
                if False: yield ""
        class FakeClient:
            def __init__(self, **options): pass
            async def __aenter__(self): return self
            async def __aexit__(self, *args): return False
            def stream(self, *args, **kwargs): return FailedResponse()
        with patch.dict("sys.modules", {"httpx": SimpleNamespace(AsyncClient=FakeClient)}):
            with self.assertRaises(UpstreamError) as caught:
                _ = [part async for part in call_upstream_stream(self.openai, self.openai.default_model, [{"role":"user","content":"hi"}], temperature=0.4, max_tokens=None, response_format=None, timeout_seconds=30, max_response_bytes=10000)]
        self.assertEqual(caught.exception.status_code, 429)
        self.assertNotIn("sk-private", str(caught.exception))

if __name__ == "__main__":
    unittest.main()
