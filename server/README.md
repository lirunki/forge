# ForgeChat server

This Python ASGI service is a private, server-side AI proxy for Forge standalone
HTML exports. It is designed to run behind the existing HTTPS site and must not
be exposed directly to the public network. It does not run submitted Python,
shell commands, Termux commands, or phone-app launches.

> **Current state:** the keyless exporter/runtime integration, protected
> publishing, non-streaming and SSE chat, cancellation, and bounded text/image
> attachments are implemented and locally tested. The service is deployed on
> `achilipuvm.lirunki.com`, protected by its own login, and routed only through
> the HTTPS `/forgechat/` Apache proxy. Certificate and public-path smoke tests
> passed; see the deployment runbook for the current provider and bootstrap
> login retrieval instructions.

## Development

```sh
cd server
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

Create a password hash and a session-signing secret interactively:

```sh
PYTHONPATH=. python -m forgechat.credentials hash-password
PYTHONPATH=. python -m forgechat.credentials session-secret
```

Set the generated values and provider settings in the process environment (or
an owner-only environment file); copy `providers.example.json` and choose only
the providers/models you intend to make available. Put provider keys in the
named environment variables, not in the JSON catalog. The configured owner
credentials bootstrap the first owner account in the private SQLite access
store; later password changes persist there.

Required settings:

- `FORGECHAT_USERNAME`
- `FORGECHAT_PASSWORD_HASH` — PBKDF2-SHA256 output from the command above; do
  not store the plaintext password.
- `FORGECHAT_SESSION_SECRET` — independently generated random secret.
- `FORGECHAT_PUBLIC_ORIGIN` — origin only, e.g. `https://forge.example.net`.
- `FORGECHAT_BASE_PATH` — public mount, default `/forgechat`.
- `FORGECHAT_APP_DIR` — private directory containing hosted `<app-id>.html` files; default `/var/lib/forgechat/apps`, outside Apache's public document root.
- `FORGECHAT_ACCESS_DB` — private SQLite user/app allow-list database; defaults to `.access.sqlite3` inside the private app directory.
- `FORGECHAT_REMEMBER_SESSION_SECONDS` — “Remember me” session lifetime; default 30 days (maximum 90 days).
- `FORGECHAT_PROVIDERS_FILE` — absolute path to an operator-owned provider
  catalog; use `providers.example.json` as a template.
- The API-key environment variables referenced by that catalog.

Run locally only on loopback:

```sh
PYTHONPATH=. uvicorn forgechat.main:app --host 127.0.0.1 --port 8765
```

The reverse proxy must preserve the public `Host` and `Origin`; the API enforces
an exact `Origin` match on POST requests and sets a `Secure`, `HttpOnly`,
`SameSite=Strict` cookie scoped to the ForgeChat path. Streaming responses use
SSE with proxy buffering disabled, and client disconnects cancel the upstream
request. The login and AI-call throttles/session-revocation list are in-memory
and intended only as a first layer. Run a single service worker in v1 and add
reverse-proxy rate limiting before any public deployment; multiple workers
would not share these controls.

## Existing VM integration

The intended deployment is additive: the current server keeps serving its
existing public site and files. A path-scoped reverse-proxy rule sends only
`/forgechat/` to `127.0.0.1:8765`; the ASGI app then gates login, hosted HTML,
and API routes with signed cookie sessions backed by the private account store. Unrelated paths must remain unchanged.
Keep exported HTML under `FORGECHAT_APP_DIR` outside Apache's public document
root, or a direct static-file URL could bypass the login gate. The ASGI process
runs under a dedicated unprivileged account and listens only on loopback (or a
private Unix socket). Firewall rules must not expose port 8765 publicly.

The deployed service, Apache path rules, certificate status, and smoke-test
results are documented in [`docs/forgechat-vm-deployment.md`](../docs/forgechat-vm-deployment.md).
The existing HTTPS certificate was renewed and validated; the Certbot timer
remains active. Never send SSH passwords, private keys, provider keys, or the
ForgeChat password in chat; retrieve the root-only bootstrap password directly
on the VM and delete that file after saving it securely.

## API currently available

- `GET /healthz` (login-required)
- `GET /api/v1/session` (login-required; reports session status)
- `GET /login` (standard form fields support browser password managers)
- `GET /apps/` and `GET /apps/{app_id}` (login-required; per-app allow-list enforced)
- `GET /account` and `POST /api/v1/account/password` (any signed-in account may change its password)
- `GET /users`, `POST /api/v1/admin/users`, `PATCH /api/v1/admin/users/{username}`, `POST /api/v1/admin/users/{username}/password`, and `DELETE /api/v1/admin/users/{username}` (owner-only global account management)
- `PUT /api/v1/admin/apps/{app_id}/access` and `DELETE /api/v1/admin/apps/{app_id}` (owner-only app allow-list and deletion)
- `GET /publish` and `POST /api/v1/apps` (owner-only; publish bounded, slug-named HTML into the private app directory)
- `GET /provider-import`, `POST /api/v1/provider-import/preview`, and `POST /api/v1/provider-import/apply` (owner-only; upload a Forge Share Backup ZIP, preview provider candidates without exposing keys, and merge selected providers into server config via the root-owned local import helper)
- `POST /api/v1/auth/login` (JSON or URL-encoded form; optional remember-me)
- `POST /api/v1/auth/logout`
- `GET /api/v1/providers` (returns the app's allowed providers and app-specific default when `X-ForgeChat-App` is present)
- `GET /api/v1/admin/apps/providers` and `PUT /api/v1/admin/apps/{app_id}/providers` (owner-only provider allow-list/default controls for hosted apps; selections are persisted in the private access database)
- `POST /api/v1/chat` (OpenAI-compatible or Gemini; text and bounded image attachments)
- `POST /api/v1/chat/stream` (SSE deltas; upstream work is canceled when the client disconnects)
- `POST /api/v1/images/generate` (owner/user app-access required; server-side image provider/model allow-list, explicit confirmation, bounded prompt/image inputs, and no provider keys in the response)
- `POST /api/v1/transcribe` (app-access required; explicit browser confirmation, 12 MiB audio cap, same-origin session, operator-configured OpenAI-compatible STT providers only, sanitized response, no provider keys returned)
- `GET /api/v1/tts/voices` and `POST /api/v1/tts/synthesize` (app-access required; `?engine=local` / `{"engine":"local"}` selects offline VM-local eSpeak NG, while cloud mode uses only configured xAI/OpenAI-compatible providers; fixed voice/model/format allow-lists and bounded audio output)
- `POST /api/v1/tts/synthesize-to-agent` (app + agent access required; server synthesizes through the configured provider and stages audio only under the agent workspace `tts/` folder)
- Optional isolated-agent routes: `GET /api/v1/agent/status`, `POST /api/v1/agent/exec`, `GET /api/v1/agent/files`, and `PUT /api/v1/agent/files` (available only when the separate Docker agent is provisioned; owner or an explicitly allowlisted agent user; same-origin session; server-held Basic Auth credentials; no caller-controlled environment or upstream URL)

No command-execution route is enabled by default. The optional Docker agent runs jobs as a separate unprivileged container UID and is provisioned with `server/deploy/linux-agent/setup.sh`; see its README before enabling it. It is not an Android/Termux service and does not expose the Docker socket. The owner is bootstrapped once from `FORGECHAT_USERNAME` and `FORGECHAT_PASSWORD_HASH`. App users are global accounts, start with no app access, and must be allowlisted separately for each app. The owner always retains access; an empty allow-list is owner-only. Owners can create, disable, delete, and reset app-user accounts; all accounts can change their own passwords. Agent access is a separate high-trust grant managed from `/users`; it is independent of app access and grants arbitrary command execution inside the isolated Linux container. Password resets and account disabling invalidate prior signed sessions. New ForgeChat standalone exports send `X-ForgeChat-App` with the hosted app ID, and the API checks that exact allow-list entry. Owners can set each hosted app's provider allow-list and default on the Providers page; chat, image generation, TTS, and transcription requests are constrained to the selected server-configured providers. Apps without a saved selection retain the legacy behavior of using all available providers. For compatibility, older exports without that header continue to work only when the account has at least one existing app assignment; users with no app grants cannot use provider/chat APIs. To recover a forgotten owner password, run `python -m forgechat.credentials set-owner-password` as the `forgechat` service account on the VM; the command prompts locally and updates the SQLite account without exposing the password. Back up the access database privately alongside the app data.

The API never returns provider keys. Provider selection is server-configured; requests cannot supply an upstream URL or upstream headers. Speech-to-text sends bounded audio to a configured OpenAI-compatible provider only after browser confirmation; requests cannot select provider endpoints or submit credentials. Cloud TTS sends text to the selected server-configured provider after browser confirmation; VM-local TTS runs `espeak-ng` on the ForgeChat VM and makes no provider request. TTS-to-agent requires the separate high-trust agent grant and writes output only inside its workspace. Install the host package `espeak-ng` to enable offline VM-local voices; local synthesis currently returns WAV. eSpeak NG is a lightweight formant synthesizer, not a neural voice model. OpenAI-compatible providers may specify a bounded `image_models` list in the private catalog; the `xai` provider receives the known Grok Imagine model defaults when the setting is omitted. A no-key provider is allowed
only for an OpenAI-compatible HTTP endpoint on loopback (e.g. an Ollama instance
bound to `127.0.0.1`); remote providers require a server-side key environment
variable. Passwords are not stored in
HTML, JavaScript, or localStorage; browser password managers can save the
standard login form, while “Remember me” extends the protected HttpOnly cookie.
The Forge exporter offers a distinct **Export for ForgeChat · no keys** mode.
It emits no provider list, endpoint, or provider key; it calls only the
same-origin `/forgechat/api/v1/` API. Publish the export through the protected
`/forgechat/publish` page so both its HTML and API require login. Direct
browser-provider exports remain a separate, unchanged option.

## Provider backup import

Forge Share Backup ZIPs can contain saved API keys in unencrypted
plaintext. Two import paths exist; both read only `ForgeLibrary/settings.json`
and never return key values to the browser:

- **Web UI (`/forgechat/provider-import`):** sign in, choose the ZIP, preview
  provider candidates, explicitly select providers, confirm, and apply. The
  upload is bounded to 32 MiB and parsed only in memory; no ZIP is retained.
  Applying merges selected providers into `/etc/forgechat/providers.json` and
  stores keys only in `/etc/forgechat/forgechat.env` through the root-owned
  `forgechat-import.service` Unix-socket helper. The web app never gains write
  access to root config; it submits a validated provider list and the helper
  performs the restricted, atomic, backed-up write as root. Restart the service
  for changes to take effect.
- **Offline CLI (`python -m forgechat.import_backup`):** for larger backups or
  VM-only workflows; see the one-time CLI section below.

Deploy the import helper alongside the web service:

```sh
sudo install -o root -g root -m 0644 server/deploy/forgechat-import.service /etc/systemd/system/forgechat-import.service
sudo systemctl daemon-reload
sudo systemctl enable --now forgechat-import.service
```

The socket lives at `/run/forgechat-import/daemon.sock` (group `forgechat`, mode
`0660`). `forgechat.service` is ordered after and wants it. Azure providers are
not supported; OpenAI-compatible and Gemini providers (including custom HTTPS
gateways) are. A remote provider needs a saved key or an existing server-side
key with the same provider id; a loopback OpenAI-compatible provider may be
keyless.

## One-time Forge provider backup import (offline CLI)

`python -m forgechat.import_backup` remains an offline VM-admin CLI for large
backups or VM-only workflows. It reads only `ForgeLibrary/settings.json` and
never extracts app HTML. For browser uploads, use the dedicated authenticated
`/forgechat/provider-import` page—not `/forgechat/publish`. Forge backups may
contain saved API keys in unencrypted plaintext, so transfer them only to the
protected importer and never send them in chat.

Preview the provider IDs/models and whether a saved key exists; the key values
are never displayed:

```sh
sudo env PYTHONPATH=/opt/forgechat/server /opt/forgechat/server/.venv/bin/python \
  -m forgechat.import_backup --zip /root/ForgeLibrary-backup.zip
```

Then explicitly select each provider to import (repeat `--provider` as needed):

```sh
sudo env PYTHONPATH=/opt/forgechat/server /opt/forgechat/server/.venv/bin/python \
  -m forgechat.import_backup --zip /root/ForgeLibrary-backup.zip \
  --provider openai --provider gemini --apply
```

The importer merges selected providers into `/etc/forgechat/providers.json`,
stores any saved keys in `/etc/forgechat/forgechat.env`, and creates private
backups of both files. Existing unselected provider entries and unrelated
environment settings are preserved. It does not restart ForgeChat; after
reviewing the output, restart it with `sudo systemctl restart forgechat.service`.
Supported server adapters are OpenAI-compatible and Gemini; Azure's deployment
semantics are not supported. Custom OpenAI-compatible providers from the backup
are recognized. Use `--kind PROVIDER_ID=openai` only when the custom endpoint is
known to implement that protocol. Only HTTPS endpoints (or loopback HTTP for a
keyless local OpenAI-compatible provider) are allowed. The importer refuses
unsafe keys/configuration without writing either file.

## Tests

From the repository root:

```sh
PYTHONPATH=server python3 -m unittest discover -s server/tests -v
```
