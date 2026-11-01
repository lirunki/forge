from __future__ import annotations

import asyncio
import base64
import json
import unittest
from unittest.mock import patch

import httpx

from forgechat.config import Provider
from forgechat.providers import UpstreamError
from forgechat.transcription import MAX_AUDIO_BYTES, call_transcription, normalize_transcription_request


class TranscriptionTests(unittest.TestCase):
    def setUp(self):
        self.openai = Provider(
            id="openai", label="OpenAI", kind="openai", base_url="https://api.openai.com/v1",
            api_key="openai-server-secret", default_model="gpt-4o-mini", models=("gpt-4o-mini",),
        )
        self.groq = Provider(
            id="groq", label="Groq", kind="openai", base_url="https://api.groq.com/openai/v1",
            api_key="groq-server-secret", default_model="llama-3.3-70b-versatile", models=("llama-3.3-70b-versatile",),
        )
        self.xai = Provider(
            id="xai", label="xAI", kind="openai", base_url="https://api.x.ai/v1",
            api_key="xai-server-secret", default_model="grok-3", models=("grok-3",),
        )

    def payload(self, **changes):
        value = {"dataUrl": "data:audio/mpeg;base64," + base64.b64encode(b"audio-bytes").decode(), "language": "en", "timestamps": True}
        value.update(changes)
        return value

    def test_normalization_bounds_audio_and_selects_server_owned_stt_providers(self):
        normalized = normalize_transcription_request(self.payload(providerId="openai", filename="/tmp/take one.mp3"), [self.openai, self.xai])
        self.assertEqual(normalized["audio"], b"audio-bytes")
        self.assertEqual(normalized["filename"], "audio.mp3")
        self.assertEqual([provider.id for provider in normalized["providers"]], ["openai", "xai"])
        self.assertEqual(normalized["language"], "en")
        self.assertTrue(normalized["timestamps"])

    def test_invalid_fields_mime_base64_and_audio_size_are_rejected(self):
        for payload in (
            self.payload(url="https://attacker.test/audio.mp3"),
            self.payload(dataUrl="data:text/plain;base64,YQ=="),
            self.payload(dataUrl="data:audio/mpeg;base64,%%%"),
            self.payload(language="../../etc/passwd"),
            self.payload(timestamps="yes"),
            self.payload(providerId="unknown"),
        ):
            with self.subTest(payload=payload):
                with self.assertRaises((ValueError, LookupError)):
                    normalize_transcription_request(payload, [self.openai])
        with patch("forgechat.transcription.base64.b64decode", return_value=b"x" * (MAX_AUDIO_BYTES + 1)):
            with self.assertRaisesRegex(ValueError, "12 MiB"):
                normalize_transcription_request(self.payload(), [self.openai])

    def test_provider_aliases_prioritize_groq_and_choose_groq_model(self):
        groq_alias = Provider(
            id="oai_groq_fujl", label="Groq", kind="openai", base_url="https://api.groq.com/openai/v1",
            api_key="groq-server-secret", default_model="llama-3.3-70b-versatile", models=("llama-3.3-70b-versatile",),
        )
        normalized = normalize_transcription_request(self.payload(), [self.openai, groq_alias])
        self.assertEqual([provider.id for provider in normalized["providers"]], ["oai_groq_fujl", "openai"])
        requests = []

        async def handler(request):
            requests.append(request)
            return httpx.Response(200, json={"text": "groq transcript"})

        result = asyncio.run(call_transcription(normalized, timeout_seconds=2, transport=httpx.MockTransport(handler)))
        self.assertEqual(result["providerId"], "oai_groq_fujl")
        self.assertIn(b"whisper-large-v3", requests[0].content)

    def test_groq_failure_falls_back_to_openai_with_server_auth(self):
        requests = []

        async def handler(request):
            requests.append(request)
            if request.url.host == "api.groq.com":
                return httpx.Response(404, text="provider implementation details")
            return httpx.Response(200, json={"text": "hello world", "segments": [{"start": 0.2, "end": 1.4, "text": "hello world"}]})

        normalized = normalize_transcription_request(self.payload(providerId="groq", prompt="names"), [self.groq, self.openai])
        result = asyncio.run(call_transcription(normalized, timeout_seconds=2, transport=httpx.MockTransport(handler)))
        self.assertEqual(result, {"text": "hello world", "segments": [{"start": 0.2, "end": 1.4, "text": "hello world"}], "providerId": "openai"})
        self.assertEqual([request.url.path for request in requests], ["/openai/v1/audio/transcriptions", "/v1/audio/transcriptions"])
        self.assertEqual(requests[0].headers["authorization"], "Bearer groq-server-secret")
        self.assertEqual(requests[1].headers["authorization"], "Bearer openai-server-secret")
        self.assertIn(b"whisper-large-v3", requests[0].content)
        self.assertIn(b"whisper-1", requests[1].content)
        self.assertIn(b"verbose_json", requests[1].content)
        self.assertNotIn("server-secret", json.dumps(result))

    def test_xai_stt_uses_configured_endpoint_and_normalizes_segments(self):
        requests = []

        async def handler(request):
            requests.append(request)
            return httpx.Response(200, json={"text": "a phrase", "segments": [{"timestamp": [0, 1.25], "text": "a phrase"}]})

        normalized = normalize_transcription_request(self.payload(providerId="xai"), [self.xai])
        result = asyncio.run(call_transcription(normalized, timeout_seconds=2, transport=httpx.MockTransport(handler)))
        self.assertEqual(requests[0].url.path, "/v1/stt")
        self.assertEqual(requests[0].headers["authorization"], "Bearer xai-server-secret")
        self.assertIn(b'name="format"\r\n\r\ntrue', requests[0].content)
        self.assertEqual(result["segments"], [{"start": 0.0, "end": 1.25, "text": "a phrase"}])

    def test_all_upstream_failures_are_sanitized(self):
        async def handler(_request):
            return httpx.Response(429, text="private provider detail")

        normalized = normalize_transcription_request(self.payload(), [self.openai])
        with self.assertRaises(UpstreamError):
            asyncio.run(call_transcription(normalized, timeout_seconds=2, transport=httpx.MockTransport(handler)))


if __name__ == "__main__":
    unittest.main()
