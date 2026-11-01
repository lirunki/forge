from __future__ import annotations

import asyncio
import io
import unittest
import wave
from unittest.mock import patch
from pathlib import Path

import httpx

from forgechat.config import Provider
from forgechat.providers import UpstreamError
from forgechat.tts import call_tts, local_voice_catalog, normalize_tts_request, synthesize_local_tts, voice_catalog


class TtsTests(unittest.TestCase):
    def setUp(self):
        self.openai = Provider(
            id="openai", label="OpenAI", kind="openai", base_url="https://api.openai.com/v1",
            api_key="server-secret", default_model="gpt-4o-mini", models=("gpt-4o-mini",),
        )
        self.xai = Provider(
            id="xai", label="xAI", kind="openai", base_url="https://api.x.ai/v1",
            api_key="xai-secret", default_model="grok-3", models=("grok-3",),
        )

    def test_normalization_uses_server_provider_allowlist(self):
        request = normalize_tts_request({"text": " hello ", "voice": "NOVA", "speed": 1.5}, [self.openai])
        self.assertEqual(request["text"], "hello")
        self.assertEqual(request["voice"], "nova")
        self.assertEqual(request["model"], "tts-1")
        self.assertEqual(request["speed"], 1.5)
        with self.assertRaises(ValueError):
            normalize_tts_request({"text": "x", "url": "https://attacker.test"}, [self.openai])
        with self.assertRaises(ValueError):
            normalize_tts_request({"text": "x", "voice": "../../etc/passwd"}, [self.openai])
        with self.assertRaises(ValueError):
            normalize_tts_request({"text": "x", "model": "untrusted-model"}, [self.openai])
        with self.assertRaises(LookupError):
            normalize_tts_request({"text": "x", "providerId": "not-configured"}, [self.openai])

    def test_xai_voice_catalog(self):
        catalog = voice_catalog(self.xai)
        self.assertTrue(catalog["available"])
        self.assertEqual(catalog["engine"], "xai")
        self.assertEqual(catalog["defaultVoice"], "eve")
        self.assertIn("perseus", [v["id"] for v in catalog["voices"]])
        self.assertIsNone(voice_catalog(Provider(
            id="gemini", label="Gemini", kind="gemini", base_url="https://generativelanguage.googleapis.com/v1beta",
            api_key="gemini-key", default_model="gemini-2.5-flash", models=("gemini-2.5-flash",),
        )).get("engine"))

    def test_local_voice_catalog_parses_espeak_voice_ids(self):
        output = "Pty Language Age/Gender VoiceName File Other Languages\n 5 en-us --/M English_US gmw/en-us\n 5 es --/M Spanish es\n"
        local_voice_catalog.cache_clear()
        try:
            with patch("forgechat.tts._espeak_binary", return_value="/usr/bin/espeak-ng"), patch("forgechat.tts.subprocess.run", return_value=type("Result", (), {"stdout": output})()):
                catalog = local_voice_catalog()
            self.assertTrue(catalog["available"])
            self.assertEqual(catalog["defaultVoice"], "en-us")
            self.assertEqual([voice["id"] for voice in catalog["voices"]], ["en-us", "es"])
            self.assertEqual(catalog["engine"], "local")
        finally:
            local_voice_catalog.cache_clear()

    def test_local_request_uses_vm_voice_and_wav_without_provider(self):
        catalog = {"available": True, "defaultVoice": "en-us", "voices": [{"id": "en-us"}, {"id": "es"}]}
        with patch("forgechat.tts.local_voice_catalog", return_value=catalog):
            request = normalize_tts_request({"engine": "local", "text": "hola", "lang": "es", "rate": 1.2, "pitch": 0.9}, [])
            self.assertIsNone(request["provider"])
            self.assertEqual(request["engine"], "local")
            self.assertEqual(request["voice"], "es")
            self.assertEqual(request["format"], "wav")
            self.assertEqual(request["speed"], 1.2)
            self.assertEqual(request["pitch"], 0.9)
            with self.assertRaises(ValueError):
                normalize_tts_request({"engine": "local", "providerId": "xai", "text": "x"}, [])
            with self.assertRaises(ValueError):
                normalize_tts_request({"engine": "local", "text": "x", "format": "mp3"}, [])

    def test_local_synthesis_runs_offline_engine_and_returns_valid_wav(self):
        catalog = {"available": True, "defaultVoice": "en-us", "voices": [{"id": "en-us"}]}
        calls = []
        class FakeProcess:
            returncode = 0
            async def communicate(self, data):
                calls.append(data)
                output = Path(command[command.index("-w") + 1])
                with wave.open(str(output), "wb") as handle:
                    handle.setnchannels(1)
                    handle.setsampwidth(2)
                    handle.setframerate(22050)
                    handle.writeframes(bytes(4410))
                return b"", b""
            def kill(self):
                return None
        async def create_process(*command_args, **kwargs):
            command[:] = command_args
            self.assertEqual(kwargs["env"], {"PATH": "/usr/bin:/bin", "LANG": "C.UTF-8"})
            return FakeProcess()
        command = []
        with patch("forgechat.tts.local_voice_catalog", return_value=catalog), patch("forgechat.tts._espeak_binary", return_value="/usr/bin/espeak-ng"), patch("forgechat.tts.asyncio.create_subprocess_exec", side_effect=create_process):
            audio = asyncio.run(synthesize_local_tts(text="offline hello", voice="en-us", speed=1, pitch=1, timeout_seconds=2, max_response_bytes=8192))
        self.assertEqual(calls, [b"offline hello"])
        self.assertIn("--stdin", command)
        self.assertEqual(audio.engine, "local")
        self.assertEqual(audio.mime, "audio/wav")
        with wave.open(io.BytesIO(audio.data), "rb") as handle:
            self.assertEqual(handle.getframerate(), 22050)
            self.assertGreater(handle.getnframes(), 0)

    def test_openai_call_is_server_auth_only_and_bounded(self):
        requests = []
        async def handler(request):
            requests.append(request)
            return httpx.Response(200, headers={"content-type": "audio/mpeg"}, content=b"MP3-DATA")
        transport = httpx.MockTransport(handler)
        request = normalize_tts_request({"text": "hello", "voice": "alloy"}, [self.openai])

        async def run():
            return await call_tts(
                request["provider"], engine=request["engine"], model=request["model"], text=request["text"],
                voice=request["voice"], language=request["language"], output_format=request["format"],
                speed=request["speed"], timeout_seconds=2, max_response_bytes=100, transport=transport,
            )
        import asyncio
        audio = asyncio.run(run())
        self.assertEqual(audio.data, b"MP3-DATA")
        self.assertEqual(audio.mime, "audio/mpeg")
        self.assertEqual(requests[0].url.path, "/v1/audio/speech")
        self.assertEqual(requests[0].headers["authorization"], "Bearer server-secret")
        self.assertNotIn("server-secret", repr(audio))

    def test_xai_call_uses_fixed_endpoint_and_safe_voice_payload(self):
        requests = []
        async def handler(request):
            requests.append(request)
            return httpx.Response(200, headers={"content-type": "audio/mpeg"}, content=b"XAI-AUDIO")
        transport = httpx.MockTransport(handler)
        request = normalize_tts_request({"text": "hello", "providerId": "xai", "voice": "eve", "lang": "en"}, [self.xai])

        async def run():
            return await call_tts(
                request["provider"], engine=request["engine"], model=request["model"], text=request["text"],
                voice=request["voice"], language=request["language"], output_format=request["format"],
                speed=request["speed"], timeout_seconds=2, max_response_bytes=100, transport=transport,
            )
        import asyncio
        audio = asyncio.run(run())
        self.assertEqual(audio.data, b"XAI-AUDIO")
        self.assertEqual(requests[0].url.path, "/v1/tts")
        self.assertEqual(requests[0].headers["authorization"], "Bearer xai-secret")
        import json
        body = json.loads(requests[0].content)
        self.assertEqual(body["voice_id"], "eve")
        self.assertEqual(body["output_format"]["codec"], "mp3")

    def test_upstream_error_and_response_limit_are_sanitized(self):
        async def error_handler(_request):
            return httpx.Response(429, text="private provider details")
        request = normalize_tts_request({"text": "hello"}, [self.openai])
        async def call(transport, maximum):
            return await call_tts(
                request["provider"], engine=request["engine"], model=request["model"], text=request["text"],
                voice=request["voice"], language=request["language"], output_format=request["format"],
                speed=request["speed"], timeout_seconds=2, max_response_bytes=maximum, transport=transport,
            )
        import asyncio
        with self.assertRaises(UpstreamError) as ctx:
            asyncio.run(call(httpx.MockTransport(error_handler), 100))
        self.assertEqual(ctx.exception.status_code, 429)
        async def large_handler(_request):
            return httpx.Response(200, headers={"content-type": "audio/mpeg"}, content=b"x" * 101)
        with self.assertRaises(UpstreamError):
            asyncio.run(call(httpx.MockTransport(large_handler), 100))


if __name__ == "__main__":
    unittest.main()
