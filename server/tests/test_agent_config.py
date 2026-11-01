from __future__ import annotations

import os
import unittest
from unittest.mock import patch

from forgechat.auth import hash_password
from forgechat.config import ConfigError, Settings


class AgentConfigTests(unittest.TestCase):
    def setUp(self):
        self.env = {
            "FORGECHAT_USERNAME": "owner",
            "FORGECHAT_PASSWORD_HASH": hash_password("correct horse battery", rounds=100_000, salt=b"c" * 16),
            "FORGECHAT_SESSION_SECRET": "s" * 48,
            "FORGECHAT_PUBLIC_ORIGIN": "https://forge.example.test",
            "FORGECHAT_PROVIDERS_FILE": "",
        }

    def test_agent_is_disabled_without_credentials_and_enabled_with_pair(self):
        with patch.dict(os.environ, self.env, clear=True):
            settings = Settings.from_env()
        self.assertFalse(settings.agent_enabled)
        self.assertEqual(settings.agent_url, "http://127.0.0.1:8788")
        self.assertEqual(settings.agent_timeout_seconds, 150.0)

        configured = dict(self.env, FORGECHAT_AGENT_USERNAME="forge_worker", FORGECHAT_AGENT_PASSWORD="separate-generated-secret")
        with patch.dict(os.environ, configured, clear=True):
            settings = Settings.from_env()
        self.assertTrue(settings.agent_enabled)
        self.assertEqual(settings.agent_username, "forge_worker")
        self.assertEqual(settings.agent_password, "separate-generated-secret")

    def test_partial_credentials_public_url_and_invalid_timeout_are_rejected(self):
        with patch.dict(os.environ, dict(self.env, FORGECHAT_AGENT_USERNAME="forge_worker"), clear=True):
            with self.assertRaisesRegex(ConfigError, "must be set together"):
                Settings.from_env()
        with patch.dict(os.environ, dict(self.env, FORGECHAT_AGENT_URL="http://example.com:8788"), clear=True):
            with self.assertRaisesRegex(ConfigError, "loopback HTTP"):
                Settings.from_env()
        with patch.dict(os.environ, dict(self.env, FORGECHAT_AGENT_TIMEOUT_SECONDS="1801"), clear=True):
            with self.assertRaisesRegex(ConfigError, "no more than 1800"):
                Settings.from_env()


if __name__ == "__main__":
    unittest.main()
