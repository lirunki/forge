from __future__ import annotations

import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


DEPLOY = Path(__file__).parents[1] / "deploy" / "linux-agent"


class LinuxAgentDeploymentTests(unittest.TestCase):
    def test_compose_is_private_and_does_not_mount_docker_socket(self):
        compose = (DEPLOY / "docker-compose.yml").read_text(encoding="utf-8")
        self.assertIn('"127.0.0.1:8788:8787/tcp"', compose)
        self.assertIn("read_only: true", compose)
        self.assertIn("cap_drop:\n      - ALL", compose)
        self.assertIn("pids_limit: 128", compose)
        self.assertIn("mem_limit: 2g", compose)
        self.assertNotIn("- CHOWN", compose)
        self.assertNotIn("/var/run/docker.sock", compose)
        self.assertNotIn("privileged: true", compose)

    def test_dockerfile_bakes_pkg_and_keeps_isolation(self):
        dockerfile = (DEPLOY / "Dockerfile").read_text(encoding="utf-8")
        self.assertIn("COPY pkg /usr/local/bin/pkg", dockerfile)
        self.assertIn("read-only root filesystem", dockerfile)
        self.assertTrue((DEPLOY / "pkg").exists())
        # pkg must be executable shell and must not require system-root writes.
        pkg = (DEPLOY / "pkg").read_text(encoding="utf-8")
        self.assertIn("PREFIX=\"${PKG_PREFIX:-$HOME/.local}\"", pkg)
        self.assertIn("dpkg-deb -x", pkg)
        self.assertIn("LD_LIBRARY_PATH", pkg)

    def test_compose_image_tag_matches_agent_version(self):
        compose = (DEPLOY / "docker-compose.yml").read_text(encoding="utf-8")
        self.assertIn("forgechat-linux-agent:1.0.3", compose)
        import importlib
        agent = importlib.import_module("forgechat.linux_agent")
        self.assertEqual(agent.VERSION, "1.0.3")

    @unittest.skipUnless(shutil.which("bash"), "bash is required")
    def test_pkg_script_parses(self):
        subprocess.run(["bash", "-n", str(DEPLOY / "pkg")], check=True)

    def test_setup_generates_private_credentials_without_displaying_them(self):
        setup = (DEPLOY / "setup.sh").read_text(encoding="utf-8")
        self.assertIn('openssl rand -hex 10', setup)
        self.assertIn('openssl rand -hex 32', setup)
        self.assertIn('chmod 0640 "$temp_env"', setup)
        self.assertIn("systemctl restart forgechat.service", setup)
        self.assertIn("127.0.0.1:8788/status", setup)
        self.assertNotIn('printf "$agent_password"', setup)
        self.assertNotIn("docker.sock", setup)
        self.assertNotIn("rm -rf", setup)

    @unittest.skipUnless(shutil.which("bash"), "bash is required")
    def test_setup_and_package_scripts_parse(self):
        subprocess.run(["bash", "-n", str(DEPLOY / "setup.sh")], check=True)
        subprocess.run(["bash", "-n", str(DEPLOY / "package.sh")], check=True)

    @unittest.skipUnless(shutil.which("tar"), "tar is required")
    def test_package_contains_only_deployment_source_and_no_secrets(self):
        with tempfile.TemporaryDirectory(prefix="forge-agent-package-test-") as directory:
            archive = Path(directory) / "agent.tar.gz"
            subprocess.run([str(DEPLOY / "package.sh"), str(archive)], check=True, capture_output=True, text=True)
            listing = subprocess.run(["tar", "-tzf", str(archive)], check=True, capture_output=True, text=True).stdout.splitlines()
        self.assertIn("server/deploy/linux-agent/setup.sh", listing)
        self.assertIn("server/deploy/linux-agent/docker-compose.yml", listing)
        self.assertIn("server/deploy/linux-agent/pkg", listing)
        self.assertIn("server/forgechat/linux_agent.py", listing)
        self.assertFalse(any(".env" in item or "apps/" in item for item in listing))


if __name__ == "__main__":
    unittest.main()
