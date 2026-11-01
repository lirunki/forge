from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from forgechat.access import AccessError, AccessStore
from forgechat.auth import hash_password


class AccessStoreTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name) / "private" / "access.sqlite3"
        self.store = AccessStore(self.path)
        self.owner_hash = hash_password("initial owner password", rounds=100_000)
        self.store.ensure_owner("Owner", self.owner_hash)

    def test_bootstraps_owner_once_and_keeps_ui_password_changes(self):
        self.assertEqual(self.store.get_user("owner")["role"], "owner")
        updated_hash = hash_password("updated owner password", rounds=100_000)
        self.store.set_password("OWNER", updated_hash)
        restarted = AccessStore(self.path)
        restarted.ensure_owner("owner", self.owner_hash)
        owner = restarted.get_user("owner")
        self.assertEqual(owner["password_hash"], updated_hash)
        self.assertEqual(owner["session_version"], 1)
        self.assertEqual(self.path.stat().st_mode & 0o777, 0o600)

    def test_agent_access_is_independent_and_owner_is_always_allowed(self):
        self.store.create_user("alice", "hash")
        self.assertFalse(self.store.user_can_access_agent("alice"))
        self.assertTrue(self.store.set_agent_access("alice", True))
        self.assertTrue(self.store.user_can_access_agent("alice"))
        alice = next(user for user in self.store.list_users() if user["username"] == "alice")
        self.assertTrue(alice["agent_access"])
        self.assertFalse(self.store.set_agent_access("alice", False))
        self.assertFalse(self.store.user_can_access_agent("alice"))
        with self.assertRaises(AccessError):
            self.store.set_agent_access("owner", True)
        with self.assertRaises(AccessError):
            self.store.set_agent_access("missing", True)

    def test_apps_are_owner_only_until_explicitly_allowlisted(self):
        self.store.create_user("alice", hash_password("alice account password", rounds=100_000))
        self.assertFalse(self.store.user_can_access("alice", "demo"))
        self.assertEqual(self.store.set_app_users("demo", ["Alice", "ALICE"]), ["alice"])
        self.assertTrue(self.store.user_can_access("alice", "demo"))
        self.assertEqual(self.store.allowed_usernames("demo"), ["alice"])
        self.store.set_app_users("demo", [])
        self.assertFalse(self.store.user_can_access("alice", "demo"))

    def test_per_app_provider_allowlist_and_default_persist_and_delete(self):
        self.assertIsNone(self.store.app_provider_settings("demo"))
        saved = self.store.set_app_providers("demo", ["groq", "openai", "groq"], "openai")
        self.assertEqual(saved, {"providerIds": ["groq", "openai"], "defaultProviderId": "openai"})
        restarted = AccessStore(self.path)
        self.assertEqual(restarted.app_provider_settings("demo"), saved)
        with self.assertRaises(AccessError):
            self.store.set_app_providers("demo", ["groq"], "openai")
        with self.assertRaises(AccessError):
            self.store.set_app_providers("demo", [], "")
        self.store.forget_app("demo")
        self.assertIsNone(self.store.app_provider_settings("demo"))

    def test_user_deletion_cascades_app_permissions_and_owner_is_protected(self):
        self.store.create_user("alice", hash_password("alice account password", rounds=100_000))
        self.store.set_app_users("demo", ["alice"])
        self.assertFalse(self.store.delete_user("owner"))
        self.assertTrue(self.store.delete_user("alice"))
        self.assertEqual(self.store.allowed_usernames("demo"), [])

    def test_app_allowlist_rejects_unknown_and_owner_names(self):
        with self.assertRaises(AccessError):
            self.store.set_app_users("demo", ["missing"])
        with self.assertRaises(AccessError):
            self.store.set_app_users("demo", ["Owner"])
        with self.assertRaises(AccessError):
            self.store.set_app_users("../outside", [])


if __name__ == "__main__":
    unittest.main()
