# Optional ForgeChat Linux Docker agent

This package provides the Linux counterpart to the Termux HTTP agent contract
(`/status`, `/exec`, and `/files`). It is **optional** and is not enabled until
an administrator runs `setup.sh` with root privileges. It does not add Docker
access to the ForgeChat service, expose the Docker socket, or reuse the ForgeChat
WebUI password.

The worker runs in a Docker container with a read-only root filesystem, no
network-published port except `127.0.0.1:8788`, a persistent private workspace,
2 GiB memory / 2 CPU / 128 process limits, and a dropped capability set. The
HTTP control process runs as container root only so it can start job processes
as UID/GID 10000. Commands run as that unprivileged UID with a sanitized
environment; the WebUI owner password, provider keys, and Docker socket are not mounted into
the container. The only host mount is the dedicated persistent workspace; other
host filesystem paths are not mounted. The worker image includes Bash,
Python, Node/npm, Git, curl, and jq. A Termux-compatible `pkg` command is
baked into the image so self-installing apps can add runtime tools (for example
`pkg install -y ffmpeg`) without system-root writes, mirroring Termux's
user-space package model: `pkg` resolves Debian packages with `apt`, downloads
them, and extracts them into the per-user writable prefix `$HOME/.local`, then
creates `PATH` wrappers (with the right `LD_LIBRARY_PATH`) in `$HOME/.local/bin`,
which is first on the job `PATH`. Installed tools persist across jobs in the
workspace and are found by `command -v` in later scripts. The read-only root
and unprivileged UID are unaffected. User-installed files and packages may be
stored under `/workspace/home` and `/workspace/fs`; this persistent workspace
is not automatically size-limited.

This is a command-execution service, not a safe sandbox for untrusted people.
An account granted access can run arbitrary commands in the isolated container,
consume its bounded CPU/memory/process resources, and read or modify its
persistent workspace. All users with agent access share that workspace and the
same unprivileged worker identity, so grant access only to users trusted with
one another's files and commands. Docker/container
isolation depends on the host kernel and Docker configuration; do not treat it
as a substitute for reviewing the scripts users submit.

## One-time provisioning

1. Deploy the ForgeChat backend changes, then build the credential-free
   deployment archive locally:

   ```sh
   server/deploy/linux-agent/package.sh /tmp/forgechat-linux-agent.tar.gz
   ```

   Transfer this archive privately to the VM and extract it into a staging
   directory, preserving the `server/` paths. It contains only the installer,
   Compose/Docker build files, docs, and agent source; it contains no credentials
   or application data.
2. Confirm Docker Engine and the Compose v2 plugin are installed, and that the
   existing `forgechat.service` is active. From the extracted staging tree run:

   ```sh
   cd /path/to/staging/server/deploy/linux-agent
   sudo ./setup.sh
   ```

3. The script builds the image, creates `/var/lib/forgechat/linux-agent/workspace`,
   generates a separate random username/password, stores them in
   `/etc/forgechat/linux-agent.env` (`root:forgechat`, mode `0640`), adds a
   systemd drop-in for ForgeChat, starts the container, and restarts ForgeChat.
   It does not print the generated credentials. The only published listener is
   bound to host loopback at `127.0.0.1:8788`.
4. Verify without printing credentials:

   ```sh
   sudo systemctl is-active forgechat.service
   sudo docker compose --env-file /etc/forgechat/linux-agent.env \
     -f /opt/forgechat/linux-agent/docker-compose.yml ps
   ```

   The backend default timeout is 150 seconds to fit the current Apache proxy
   timeout. Increase `FORGECHAT_AGENT_TIMEOUT_SECONDS` only when the matching
   Apache `/forgechat/` proxy timeout is raised too. The Linux worker itself
   accepts at most 30-minute jobs; background `termux.run()` calls return
   immediately and are stopped after 30 minutes.

The setup script is idempotent: it preserves valid generated credentials and
refuses symlink or malformed credential files. It installs only under
`/opt/forgechat/linux-agent`, `/etc/forgechat/linux-agent.env`, the dedicated
`forgechat.service.d/40-linux-agent.conf` drop-in, and
`/var/lib/forgechat/linux-agent`; it does not overwrite ForgeChat apps or
provider files. To disable the agent, stop/remove its Compose service, remove the
systemd drop-in and private environment file, then restart ForgeChat. Keep the
workspace if its user files are needed.

## Granting access

The owner always has access. In ForgeChat, the owner can grant/revoke the
separate **Backend agent access** flag for enabled user accounts at
`/forgechat/users`. This grant is independent of per-app access. Disabled users
are blocked immediately. ForgeChat checks the signed session and allow-list on
every status, command, and file request; the private worker credentials are
never returned to a browser. A user may also be denied with HTTP 403 when agent
access has not been granted.

A hosted **Export for ForgeChat · no keys** can use the server-backed subset of
`ForgeHost.termux`: `isAvailable`, `status`, `exec`, `run`, `readFile`,
`writeFile`, and `streamFile` (with a browser `File`/`Blob`). Command and upload
calls show a browser confirmation first. Browser exports cannot open Android
Termux, access Android app URIs, install/update the container, or access the
host. Shell commands run in the container, not on the VM.

## Request limits and diagnostics

- `/exec` accepts a script (512 KiB max) or a command plus bounded string args;
  it does not accept caller-provided environment variables, URLs, or headers.
  Jobs run with a non-login shell so the sanitized `PATH` (with the per-user
  `$HOME/.local/bin` prefix first) is honored — a Termux-style `pkg install`
  makes the new tool available to `command -v` in the same script. Job output
  is capped at 2 MiB, concurrent jobs at two, and synchronous execution at the
  requested timeout (maximum 30 minutes).
- `/files` reads at most 64 MiB and streams uploads at most 512 MiB. Paths are
  restricted to `/workspace/fs` and `/workspace/home`; uploads are atomic and
  do not overwrite an existing file unless requested.
- The ForgeChat backend calls the worker over loopback HTTP with generated
  Basic Auth credentials. The worker does not have a public TLS listener; never
  change the port binding to `0.0.0.0` or forward port 8788 through Apache.
- Inspect service state with `systemctl status forgechat.service` and Compose
  state with `docker compose ... ps`. Avoid commands that print the private env
  file, and do not paste credentials, environment dumps, or private logs into
  chat. The container's `docker logs` does not include its password.
