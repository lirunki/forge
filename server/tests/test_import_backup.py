import io
import json
import os
import tempfile
import unittest
import zipfile
from contextlib import redirect_stdout
from pathlib import Path

from forgechat.import_backup import (
    ImportErrorSafe,
    _print_preview,
    _render_env_file,
    apply_import,
    discover_candidates,
    read_forge_settings,
)


class ForgeBackupImportTests(unittest.TestCase):
    def setUp(self):
        self.settings = {
            "format": "forge-drive-settings-v1",
            "activeProviderId": "openai",
            "profiles": {
                "openai": {"key": "openai-test-key-123", "base": "https://api.openai.com/v1", "model": "gpt-4o-mini"},
                "gemini": {"base": "https://generativelanguage.googleapis.com/v1beta", "model": "gemini-2.5-flash"},
                "localmodel": {"base": "http://127.0.0.1:11434/v1", "model": "phi4-mini:latest"},
                "azure": {"base": "https://example.openai.azure.com", "model": "gpt-4o"},
                "missingkey": {"base": "https://api.example.test/v1", "model": "test-model"},
            },
            "knownKeys": [
                {"key": "gemini-test-key-456", "providers": ["gemini"], "lastUsedAt": 10},
            ],
            "customProviders": [
                {"id": "localmodel", "label": "Local Model", "base": "http://127.0.0.1:11434/v1", "models": ["phi4-mini:latest"]},
                {"id": "missingkey", "label": "Remote Custom", "base": "https://api.example.test/v1", "models": ["test-model"]},
            ],
        }

    def archive(self, *, extra=None):
        out = io.BytesIO()
        with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_STORED) as zf:
            zf.writestr("ForgeLibrary/manifest.json", json.dumps({"apps": [{"id": "private-app"}]}))
            zf.writestr("ForgeLibrary/apps/private-app/app.html", "<html>must not be imported</html>")
            zf.writestr("ForgeLibrary/settings.json", json.dumps(self.settings))
            if extra:
                for name, value in extra:
                    zf.writestr(name, value)
        return out.getvalue()

    def write_archive(self, root, data):
        path = Path(root) / "ForgeLibrary-test.zip"
        path.write_bytes(data)
        os.chmod(path, 0o600)
        return path

    def test_reads_only_settings_and_discovers_supported_providers_without_key_leaks(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = self.write_archive(tmp, self.archive())
            settings = read_forge_settings(path)
        candidates = discover_candidates(settings)
        by_id = {candidate.id: candidate for candidate in candidates}
        self.assertEqual(by_id["openai"].kind, "openai")
        self.assertEqual(by_id["openai"].key, "openai-test-key-123")
        self.assertEqual(by_id["gemini"].kind, "gemini")
        self.assertEqual(by_id["gemini"].key, "gemini-test-key-456")
        self.assertEqual(by_id["localmodel"].issue, "")
        self.assertEqual(by_id["localmodel"].key, "")
        self.assertIn("not supported", by_id["azure"].issue)
        self.assertIn("no saved API key", by_id["missingkey"].issue)
        self.assertNotIn("openai-test-key-123", json.dumps(by_id["openai"].preview()))
        self.assertNotIn("openai-test-key-123", repr(by_id["openai"]))
        output = io.StringIO()
        with redirect_stdout(output):
            _print_preview(candidates)
        self.assertNotIn("openai-test-key-123", output.getvalue())
        self.assertIn("saved key present", output.getvalue())

    def test_archive_must_be_owner_only(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = self.write_archive(tmp, self.archive())
            os.chmod(path, 0o644)
            with self.assertRaisesRegex(ImportErrorSafe, "owner-only"):
                read_forge_settings(path)

    def test_rejects_wrong_format_and_duplicate_settings_entries(self):
        wrong = dict(self.settings, format="not-a-forge-backup")
        with tempfile.TemporaryDirectory() as tmp:
            path = self.write_archive(tmp, self.archive())
            wrong_zip = io.BytesIO()
            with zipfile.ZipFile(wrong_zip, "w") as zf:
                zf.writestr("ForgeLibrary/settings.json", json.dumps(wrong))
            path.write_bytes(wrong_zip.getvalue())
            with self.assertRaises(ImportErrorSafe):
                read_forge_settings(path)

            duplicate = io.BytesIO()
            with zipfile.ZipFile(duplicate, "w") as zf:
                zf.writestr("ForgeLibrary/settings.json", json.dumps(self.settings))
                zf.writestr("other/ForgeLibrary/settings.json", json.dumps(self.settings))
            path.write_bytes(duplicate.getvalue())
            os.chmod(path, 0o600)
            with self.assertRaises(ImportErrorSafe):
                read_forge_settings(path)

    def test_apply_merges_provider_and_env_files_without_putting_keys_in_json(self):
        candidates = discover_candidates(self.settings)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            providers = root / "providers.json"
            env = root / "forgechat.env"
            providers.write_text(json.dumps([{"id": "ollama", "kind": "openai", "base_url": "http://127.0.0.1:11434/v1", "default_model": "phi4-mini:latest", "models": ["phi4-mini:latest"]}]))
            env.write_text("FORGECHAT_USERNAME=owner\nFORGECHAT_OPENAI_API_KEY=old-key-123\n")
            os.chmod(providers, 0o640)
            os.chmod(env, 0o640)

            imported, backups = apply_import(candidates, ["openai", "gemini"], providers, env)
            self.assertEqual(imported, ["openai", "gemini"])
            self.assertEqual(len(backups), 2)
            catalog = json.loads(providers.read_text())
            by_id = {item["id"]: item for item in catalog}
            self.assertIn("ollama", by_id)
            self.assertEqual(by_id["openai"]["api_key_env"], "FORGECHAT_OPENAI_API_KEY")
            self.assertNotIn("api_key", by_id["openai"])
            self.assertNotIn("openai-test-key-123", providers.read_text())
            env_text = env.read_text()
            self.assertIn("FORGECHAT_OPENAI_API_KEY=openai-test-key-123", env_text)
            self.assertIn("FORGECHAT_GEMINI_API_KEY=gemini-test-key-456", env_text)
            self.assertEqual(os.stat(env).st_mode & 0o777, 0o640)

    def test_keyless_loopback_import_has_no_api_key_env(self):
        candidates = discover_candidates(self.settings)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            providers = root / "providers.json"
            env = root / "forgechat.env"
            imported, _ = apply_import(candidates, ["localmodel"], providers, env)
            self.assertEqual(imported, ["localmodel"])
            item = json.loads(providers.read_text())[0]
            self.assertNotIn("api_key_env", item)
            self.assertEqual(env.read_text(), "\n")

    def test_remote_provider_without_backup_key_can_keep_existing_server_key(self):
        candidates = discover_candidates(self.settings)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            providers = root / "providers.json"
            env = root / "forgechat.env"
            providers.write_text(json.dumps([{
                "id": "missingkey", "kind": "openai", "api_key_env": "FORGECHAT_REMOTE_KEY",
                "base_url": "https://api.example.test/v1", "default_model": "old-model", "models": ["old-model"],
            }]))
            env.write_text("FORGECHAT_REMOTE_KEY=existing-secret-123\n")
            os.chmod(providers, 0o640)
            os.chmod(env, 0o640)
            imported, _ = apply_import(candidates, ["missingkey"], providers, env)
            self.assertEqual(imported, ["missingkey"])
            item = json.loads(providers.read_text())[0]
            self.assertEqual(item["api_key_env"], "FORGECHAT_REMOTE_KEY")
            self.assertEqual(item["default_model"], "test-model")
            self.assertEqual(env.read_text(), "FORGECHAT_REMOTE_KEY=existing-secret-123\n")

    def test_rejects_unsafe_systemd_secret_without_partial_write(self):
        self.settings["profiles"]["openai"]["key"] = "key\nFORGECHAT_USERNAME=attacker"
        candidates = discover_candidates(self.settings)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            providers = root / "providers.json"
            env = root / "forgechat.env"
            providers.write_text("[]\n")
            env.write_text("FORGECHAT_USERNAME=owner\n")
            with self.assertRaises(ImportErrorSafe):
                apply_import(candidates, ["openai"], providers, env)
            self.assertEqual(json.loads(providers.read_text()), [])
            self.assertEqual(env.read_text(), "FORGECHAT_USERNAME=owner\n")

    def test_env_file_duplicate_secret_assignment_uses_imported_value(self):
        rendered = _render_env_file(
            "# keep me\nFORGECHAT_OPENAI_API_KEY=old-one\nFORGECHAT_OPENAI_API_KEY=old-two\n",
            {"FORGECHAT_OPENAI_API_KEY": "new-key-123"},
        )
        self.assertEqual(rendered.count("FORGECHAT_OPENAI_API_KEY="), 1)
        self.assertIn("FORGECHAT_OPENAI_API_KEY=new-key-123", rendered)
        self.assertIn("# keep me", rendered)


if __name__ == "__main__":
    unittest.main()
