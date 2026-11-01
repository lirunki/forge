from __future__ import annotations

import base64
import hashlib
import http.client
import json
import os
import tempfile
import threading
import time
import unittest
from pathlib import Path
from urllib.parse import quote
from urllib.request import HTTPBasicAuthHandler, Request, build_opener

from forgechat import linux_agent


class LinuxAgentTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="forge-linux-agent-")
        root = Path(self.temp.name)
        linux_agent.WORKSPACE = root
        linux_agent.FSROOT = root / "fs"
        linux_agent.HOME = root / "home"
        linux_agent.TEMP_DIR = Path(tempfile.gettempdir())
        linux_agent.FSROOT.mkdir()
        linux_agent.HOME.mkdir()
        linux_agent.USERNAME = "test-agent"
        linux_agent.PASSWORD = "test-agent-secret"
        self.server = linux_agent.ThreadingHTTPServer(("127.0.0.1", 0), linux_agent.Handler)
        self.server.daemon_threads = True
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base_url = f"http://127.0.0.1:{self.server.server_port}"
        self.opener = build_opener(HTTPBasicAuthHandler())

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)
        self.temp.cleanup()

    def request(self, path: str, *, method: str = "GET", body: bytes | None = None, headers: dict[str, str] | None = None, auth: bool = True):
        request_headers = dict(headers or {})
        if auth:
            token = base64.b64encode(f"{linux_agent.USERNAME}:{linux_agent.PASSWORD}".encode()).decode()
            request_headers["Authorization"] = "Basic " + token
        request = Request(self.base_url + path, data=body, headers=request_headers, method=method)
        try:
            with self.opener.open(request, timeout=5) as response:
                return response.status, response.headers, response.read()
        except Exception as exc:
            if isinstance(exc, http.client.HTTPException):
                raise
            if hasattr(exc, "code"):
                return exc.code, exc.headers, exc.read()
            raise

    def test_auth_status_and_unprivileged_command_environment(self):
        status, _, body = self.request("/status", auth=False)
        self.assertEqual(status, 401)
        status, _, body = self.request("/status")
        payload = json.loads(body)
        self.assertEqual(status, 200)
        self.assertEqual(payload["root"], str(linux_agent.WORKSPACE))
        self.assertNotIn(linux_agent.PASSWORD, body.decode())

        job = {"script": "printf '%s|%s' \"$FORGE_AGENT_PASSWORD\" \"$PWD\"", "timeoutMs": 5000}
        status, _, body = self.request("/exec", method="POST", body=json.dumps(job).encode(), headers={"Content-Type": "application/json"})
        result = json.loads(body)
        self.assertEqual(status, 200)
        self.assertTrue(result["ok"])
        self.assertTrue(result["stdout"].endswith(str(linux_agent.FSROOT)))
        self.assertNotIn(linux_agent.PASSWORD, result["stdout"])

    def test_execution_validates_workspace_and_enforces_timeout(self):
        outside = {"script": "pwd", "cwd": "/etc", "timeoutMs": 5000}
        status, _, body = self.request("/exec", method="POST", body=json.dumps(outside).encode())
        self.assertEqual(status, 400)
        self.assertIn("under the agent fs root", json.loads(body)["errmsg"])

        slow = {"script": "sleep 3", "timeoutMs": 1000}
        status, _, body = self.request("/exec", method="POST", body=json.dumps(slow).encode())
        result = json.loads(body)
        self.assertEqual(status, 200)
        self.assertFalse(result["ok"])
        self.assertEqual(result["exitCode"], 124)

    def test_file_get_put_and_path_sandbox(self):
        source = linux_agent.FSROOT / "hello.txt"
        source.write_bytes(b"hello agent")
        status, headers, body = self.request("/files?path=hello.txt&mime=text%2Fplain")
        self.assertEqual((status, body, headers.get_content_type()), (200, b"hello agent", "text/plain"))

        data = b"written safely"
        digest = hashlib.sha256(data).hexdigest()
        destination = quote("nested/file.txt", safe="")
        status, _, body = self.request(
            "/files?destination=" + destination,
            method="PUT",
            body=data,
            headers={"Content-Length": str(len(data)), "X-Forge-Mkdirs": "true", "X-Forge-Sha256": digest},
        )
        result = json.loads(body)
        self.assertEqual(status, 200)
        self.assertEqual(result["sha256"], digest)
        self.assertEqual((linux_agent.FSROOT / "nested/file.txt").read_bytes(), data)

        status, _, body = self.request("/files?path=%2Fetc%2Fpasswd")
        self.assertEqual(status, 400)
        self.assertIn("under the agent", json.loads(body)["errmsg"])

    def test_job_shell_honors_controlled_path_and_prefix(self):
        job = {"script": "printf '%s' \"$PATH\"", "timeoutMs": 5000}
        status, _, body = self.request("/exec", method="POST", body=json.dumps(job).encode(), headers={"Content-Type": "application/json"})
        result = json.loads(body)
        self.assertEqual(status, 200)
        self.assertTrue(result["ok"])
        path = result["stdout"]
        # Non-login shell: the per-user prefix must stay first on PATH so a
        # Termux-style `pkg` can install tools that jobs find by name.
        self.assertTrue(path.startswith(str(linux_agent.HOME) + "/.local/bin:"), path)
        self.assertNotIn("/usr/local/games", path)
        # _command must not request a login shell (which would reset PATH).
        self.assertEqual(linux_agent._command({"script": "echo hi"}), ["/bin/bash", "-c", "echo hi"])

    def test_output_limit_and_background_response(self):
        job = {"script": "head -c 3000000 /dev/zero", "timeoutMs": 10000}
        status, _, body = self.request("/exec", method="POST", body=json.dumps(job).encode())
        result = json.loads(body)
        self.assertEqual(status, 200)
        self.assertEqual(result["exitCode"], 122)
        self.assertLessEqual(len(result["stdout"].encode()), linux_agent.MAX_OUTPUT_BYTES)
        self.assertIn("output limit exceeded", result["stderr"])

        background = {"script": "sleep 0.1", "background": True, "timeoutMs": 5000}
        status, _, body = self.request("/exec", method="POST", body=json.dumps(background).encode())
        result = json.loads(body)
        self.assertEqual(status, 200)
        self.assertTrue(result["ok"])
        self.assertIn("pid", result)
        time.sleep(0.2)


if __name__ == "__main__":
    unittest.main()
