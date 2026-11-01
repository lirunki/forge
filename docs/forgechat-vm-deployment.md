# ForgeChat VM deployment runbook

> **Deployment status: installed and smoke-tested (26 October 2026).** The live
> certificate is valid through **24 January 2027**. The ForgeChat service is
> active on loopback, and Apache proxies only `/forgechat/` over HTTPS. The
> multi-user upgrade is deployed; its private SQLite account database is active,
> and all six previously published HTML apps were preserved.

## Host and TLS

- VM: Ubuntu 24.04.4 LTS, Apache 2.4.58, Python 3.12.3, document root
  `/var/www/html`.
- Certbot HTTP-01 originally timed out to `52.156.154.146:80`. After the
  inbound cloud network rule was corrected, both the staging renewal test and
  production renewal succeeded. `apache2ctl configtest` passed, Apache was
  restarted for the new proxy modules, and a normal-verifying HTTPS client
  confirms the hostname and certificate chain. The existing Certbot timer is
  active; a final dry run also succeeded after the ForgeChat proxy was added.
- Apache still emits its pre-existing overlapping `ScriptAlias` warning. It
  was not changed. The existing site-wide BasicAuth and unrelated routes remain
  unchanged; `/forgechat/` is handled by ForgeChat's own login form and does
  not trigger the existing BasicAuth challenge.
- The user enabled the cloud inbound TCP/80 rule. The VM's UFW is inactive and
  its INPUT firewall policy accepts traffic. Keep port 80 available for the
  configured HTTP-01 renewal; Certbot's `/.well-known/acme-challenge/` path is
  left alone.

## Installed service

- Source: `/opt/forgechat/server` (root-owned); virtual environment:
  `/opt/forgechat/server/.venv`.
- Service: `forgechat.service`, enabled and active, one Uvicorn worker, user
  `forgechat`, bound only to `127.0.0.1:8765`.
- Private published app directory: `/var/lib/forgechat/apps`, outside Apache's
  document root.
- Private account and per-app allow-list database: `/var/lib/forgechat/apps/.access.sqlite3`
  (created by the service with mode `0600`; back it up privately with the app data).
- Root-only config: `/etc/forgechat/forgechat.env` (mode `0640`, group
  `forgechat`) and `/etc/forgechat/providers.json` (same permissions). The
  configured provider is the loopback Ollama endpoint at
  `http://127.0.0.1:11434/v1`, with `phi4-mini:latest` as the only enabled
  model. This provider has no API key. No remote provider keys are configured.
- Apache modules `proxy` and `proxy_http` are enabled. A private Apache backup
  from before the route change is in
  `/var/backups/forgechat/apache-before-proxy/`.

## Login bootstrap

The ForgeChat username is `owner`. A random initial password was generated on
the VM; the app stores only its PBKDF2 hash. On the first start after the
multi-user upgrade, the configured owner username/hash seed the private SQLite
account database. This happens only when the owner record is missing: password
changes in the UI persist across restarts. The one-time bootstrap file is
root-only at `/etc/forgechat/bootstrap-password.txt`; its contents were not
sent to chat or written into the export. Retrieve it directly in a VM shell,
then delete it after saving the password in a password manager:

```sh
sudo cat /etc/forgechat/bootstrap-password.txt
sudo rm /etc/forgechat/bootstrap-password.txt
```

Sign in at `https://achilipuvm.lirunki.com/forgechat/login`. The login form
uses browser password-manager autocomplete, and its “Remember me” checkbox
uses a 30-day Secure, HttpOnly, SameSite=Strict cookie. The owner can create,
disable, remove, or reset global app-user accounts at `/forgechat/users`, then
allowlist each enabled user per app from `/forgechat/apps/`. New users have no
app access until explicitly assigned; an empty allow-list is owner-only. All
accounts can change their own password at `/forgechat/account`; changing a
password or disabling an account invalidates prior sessions. For owner-password
recovery, run the following on the VM as an administrator; it prompts in the
terminal and does not print the password:

```sh
sudo -u forgechat env PYTHONPATH=/opt/forgechat/server \
  /opt/forgechat/server/.venv/bin/python -m forgechat.credentials set-owner-password
```

The HTTP site retains its existing BasicAuth behavior; ForgeChat
itself is protected by the separate login at the HTTPS `/forgechat/` path.

## Apache route scope

Only these path-specific rules were added. The redirects are in the existing
`*:80` vhost; the proxy is in the existing `*:443` vhost. Existing site routes,
BasicAuth configuration, document roots, and ACME challenge handling were not
changed.

```apache
# Existing *:80 vhost: send only ForgeChat URLs to HTTPS
RedirectMatch 308 ^/forgechat/?$ https://achilipuvm.lirunki.com/forgechat/
RedirectMatch 308 ^/forgechat/(.*)$ https://achilipuvm.lirunki.com/forgechat/$1

# Existing *:443 vhost for achilipuvm.lirunki.com
ProxyRequests Off
ProxyPreserveHost On
ProxyPass        /forgechat/ http://127.0.0.1:8765/ connectiontimeout=5 timeout=180
ProxyPassReverse /forgechat/ http://127.0.0.1:8765/
```

The trailing-slash mapping strips `/forgechat/` before the ASGI routes. Keep
Uvicorn bound to loopback; never expose port 8765 or the private app directory
to the public network/document root. Preserve the incoming `Host` and `Origin`.

## Provider import via the web UI

In addition to the offline CLI below, the deployed service exposes the
authenticated `/forgechat/provider-import` page. Upload is bounded to 32 MiB,
parsed only in memory, and never persisted; preview and apply require the
same login session and pass the strict origin check. Applying submits a
validated provider list to a root-owned helper service — the web app itself
never gains write access to root config.

Deploy/update the helper (root-owned module plus unit). To deploy the
multi-user app upgrade, install the updated `access.py`, `auth.py`,
`credentials.py`, `config.py`, `app.py`, and `transcription.py` into `/opt/forgechat/server/forgechat`
with owner `root:root`, then restart `forgechat.service`. The authenticated
`POST /api/v1/transcribe` route is implemented in `app.py` and uses the new
`transcription.py` adapter; install both together before restarting. Per-app
provider selections/defaults are implemented in `access.py` and `app.py` and
persist in the existing private SQLite database; update both modules together.
The Providers page includes the app provider controls. The database defaults to `.access.sqlite3` inside `/var/lib/forgechat/apps`,
which is writable by the service account. The service's existing
`ReadWritePaths=/var/lib/forgechat` permits this; no additional write
permissions are needed. Do not
remove the app directory or database during upgrades: all existing HTML remains
in place and is owner-only until explicitly allowlisted.

```sh
scp server/forgechat/access.py server/forgechat/auth.py \
  server/forgechat/config.py server/forgechat/credentials.py \
  server/forgechat/import_helper.py server/forgechat/import_backup.py \
  server/forgechat/app.py server/forgechat/transcription.py SSH_USER@achilipuvm.lirunki.com:/tmp/
ssh SSH_USER@achilipuvm.lirunki.com '
  for module in access.py auth.py config.py credentials.py import_helper.py import_backup.py app.py transcription.py; do
    sudo install -o root -g root -m 0644 /tmp/$module /opt/forgechat/server/forgechat/$module;
    rm -f /tmp/$module;
  done'
scp server/deploy/forgechat-import.service server/deploy/forgechat.service \
  SSH_USER@achilipuvm.lirunki.com:/tmp/
ssh SSH_USER@achilipuvm.lirunki.com '
  sudo install -o root -g root -m 0644 /tmp/forgechat-import.service /etc/systemd/system/forgechat-import.service;
  sudo install -o root -g root -m 0644 /tmp/forgechat.service /etc/systemd/system/forgechat.service;
  rm -f /tmp/forgechat-import.service /tmp/forgechat.service;
  sudo systemctl daemon-reload;
  sudo systemctl enable --now forgechat-import.service;
  sudo systemctl restart forgechat.service'
```

Verify locally on the VM:

```sh
sudo systemctl status forgechat-import.service --no-pager
sudo ls -l /run/forgechat-import/daemon.sock   # root:forgechat, mode 0660
```

After an import, an admin restart of `forgechat.service` is still required
(the page will say so). Backups of the previous config are written next to the
files with a `.backup-<timestamp>` suffix.

## One-time provider import from a Forge Share Backup (offline CLI)

The repository contains `forgechat.import_backup`, a local admin CLI that adds
no web route and does not require a service restart when installed/updated. It
reads only `ForgeLibrary/settings.json` from the ZIP and ignores every
app/workspace entry. Forge Share Backup can contain saved API keys in
**unencrypted plaintext**. Never send the ZIP to chat or upload it through
ForgeChat publishing. Transfer it directly to the VM over SSH/a private channel
and keep the VM copy root-only.

If updating the installed CLI from a checked-out repository on the admin machine,
copy only the module and install it root-owned (no Python packages or service
restart are needed):

```sh
scp server/forgechat/import_backup.py SSH_USER@achilipuvm.lirunki.com:/tmp/forgechat-import_backup.py
ssh SSH_USER@achilipuvm.lirunki.com 'sudo install -o root -g root -m 0644 /tmp/forgechat-import_backup.py /opt/forgechat/server/forgechat/import_backup.py && rm -f /tmp/forgechat-import_backup.py'
```

Transfer the ZIP directly to the VM, then create a root-only copy. For example,
run the `install` command in the VM shell using the actual private transfer path:

```sh
sudo install -o root -g root -m 0600 /path/to/transferred/ForgeLibrary-backup.zip /root/ForgeLibrary-backup.zip
```

Preview without changing server configuration; the preview reports provider IDs,
models, and only whether a key is saved—never the key value:

```sh
sudo env PYTHONPATH=/opt/forgechat/server /opt/forgechat/server/.venv/bin/python \
  -m forgechat.import_backup --zip /root/ForgeLibrary-backup.zip
```

After checking the preview, explicitly import only the provider IDs wanted on the
server (repeat `--provider` for more than one). This merges them with the existing
catalog and environment file, creates private timestamped backups, and does not
restart ForgeChat automatically:

```sh
sudo env PYTHONPATH=/opt/forgechat/server /opt/forgechat/server/.venv/bin/python \
  -m forgechat.import_backup --zip /root/ForgeLibrary-backup.zip \
  --provider openai --provider gemini --apply
sudo systemctl restart forgechat.service
sudo systemctl status forgechat.service --no-pager
```

The current server supports Gemini and OpenAI-compatible providers, including
custom HTTPS providers from the backup. Azure-specific deployments are not
supported. An unknown custom provider can be mapped with `--kind ID=openai` only
if it really implements the OpenAI-compatible API. HTTP is accepted only for a
loopback OpenAI-compatible endpoint; all remote providers need a key. Unsafe
provider IDs/URLs or keys the systemd environment file cannot represent safely
are refused before writes. Existing unselected provider entries and unrelated
environment variables are preserved; selected saved keys go only to
`/etc/forgechat/forgechat.env`, not to the provider JSON or CLI output. The
importer never restarts the service. After confirming provider discovery/chat,
remove the plaintext ZIP copy; deleting it is not a guaranteed secure erase on
flash/SSD storage. The generated `forgechat.env.backup-*` files also contain
previous secrets and must remain restricted to root and the `forgechat` group.

## Verification completed

- Web provider import deployed and verified: `forgechat-import.service` is
  `active`; `/run/forgechat-import/daemon.sock` exists as `root:forgechat` mode
  `0660`; `forgechat.service` restarted clean; VM Python imports of
  `forgechat.app`, `forgechat.import_helper`, `forgechat.import_backup` OK.
  External HTTPS: `GET /forgechat/provider-import` returns `303` to
  `/forgechat/login?next=%2Fforgechat%2Fprovider-import`; same-origin unauthenticated
  `POST /api/v1/provider-import/preview` and `/apply` return `401`, while requests
  without a trusted Origin remain `403`; `GET /forgechat/healthz` returns `401`;
  `GET /forgechat/apps/` returns `303` to login. The rendered inline import-page
  JavaScript passes `node --check`.
- `apache2ctl configtest`: `Syntax OK` (aside from the unchanged ScriptAlias
  warning); Apache and the Certbot timer are active.
- Certbot production renewal and subsequent staging dry run both succeeded;
  current certificate expiry is 24 January 2027.
- External HTTPS verification succeeded. `/forgechat/login` returns the app
  login form; logged-out app/publish routes redirect to login; providers and
  health API return 401. HTTP ForgeChat paths redirect to HTTPS.
- Authenticated public-path smoke test passed: login cookie, keyless Ollama
  provider discovery, publish page and upload API, login-protected app serving,
  non-stream chat, SSE chat, logout, and post-logout API rejection. The temporary
  smoke HTML was deleted afterward.
- Multi-user upgrade deployed and smoke-tested: `forgechat.service` is active;
  `/var/lib/forgechat/apps/.access.sqlite3` is mode `0600`, owned by
  `forgechat:forgechat`; all six pre-existing hosted HTML files remain in place.
  Public requests returned expected auth boundaries: `/forgechat/login` 200,
  `/forgechat/apps/` 303 to login, `/forgechat/provider-import` 303 to login,
  and unauthenticated `/forgechat/api/v1/providers` and `/forgechat/healthz` 401.
  Local tests cover account creation/reset, password change, app allow-lists,
  default-deny, session invalidation, app deletion, and preservation of existing
  apps. New keyless exports send their hosted app ID in `X-ForgeChat-App` for
  exact API allow-list checks. Older exports without the header remain usable
  only for accounts with at least one live app assignment; users with no app
  grant cannot use provider/chat APIs.
- VM-local TTS is deployed through the Python backend using the VM's existing
  `espeak-ng` package (eSpeak NG 1.51, 130 voices); a direct offline synthesis
  smoke test produced valid 22.05 kHz WAV audio without calling a TTS provider.
  ForgeChat-hosted VideoLingo now offers `ForgeChat VM (offline)` alongside
  Android/cloud choices. Local TTS voice/synthesis/staging endpoints retain the
  normal authentication gates (`401` unauthenticated); the app route redirects
  to login (`303`).
- `phi4-mini:latest` returned a non-empty answer through both chat routes.
  `qwen3:0.6b` returned an upstream failure in the same test, so it is not in
  the enabled catalog. The configured endpoint remains local Ollama; no provider
  API key is set.

To check later:

```sh
sudo systemctl status forgechat.service
sudo journalctl -u forgechat.service --no-pager
sudo apache2ctl configtest
sudo certbot renew --dry-run --cert-name achilipuvm.lirunki.com
```

The login cookie and password-manager fields were verified at the HTTP/API
level; browser-specific password-manager autofill has not yet been manually
checked. The exporter can now create the **Export for ForgeChat · no keys**
file; upload it from the protected `/forgechat/publish` page. Server-backed
image generation is available for configured image models; binary documents
and Forge host-managed AI tool loops remain unsupported in this integration.

## Optional Linux Docker agent

The VM's Docker installation was verified, but the private agent has **not**
been provisioned by this runbook. The optional package is
`server/deploy/linux-agent/`; review its README and deploy the backend routes
before enabling it. To deploy, build the credential-free archive with
`server/deploy/linux-agent/package.sh`, transfer and extract it on the VM while
preserving its `server/` paths, then run `sudo ./setup.sh` from the extracted
`server/deploy/linux-agent/` directory. The script generates a separate
credential pair, stores it
in `/etc/forgechat/linux-agent.env` with restrictive permissions, adds a
ForgeChat systemd drop-in, binds the worker only to `127.0.0.1:8788`, and
restarts the service. It does not overwrite published apps or provider data.
It does not print the credentials. The owner must separately grant trusted
users **Backend agent access** at `/forgechat/users`; this grant enables
arbitrary commands inside the Docker container. Do not expose the Docker socket
or publish the agent port.
