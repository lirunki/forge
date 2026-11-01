# Server-backed ForgeChat for standalone HTML — plan

> **Status: exporter/runtime/backend integration and multi-user access are deployed and smoke-tested on the VM.** The service keeps provider keys server-side, protects apps with per-user allow-lists, supports server-backed image generation for configured models, and deliberately excludes running Python and launching phone apps. Existing public routes remain unchanged.

## Goal

A standalone HTML export, hosted over HTTPS, can call the same useful Forge AI/chat surface through a Linux VM backend. Provider credentials remain on the VM. The exported page contains no provider key and does not call provider APIs directly in server-backed mode.

Keep the existing `ForgeHost` async API as the app-facing contract where practical. Add a server-backed mode to the existing standalone compatibility runtime rather than creating a second app API or changing behavior inside Forge.

## Current baseline

- `www/index.html` injects `standaloneRuntimeBootstrap(config)` into one-file HTML exports.
- Direct-provider exports still call providers from the browser and may prompt for a recipient-owned key. ForgeChat server exports call same-origin chat/image-generation endpoints; server-owned provider keys are never embedded.
- The export flow can explicitly embed selected saved keys after a warning; that remains an unsafe legacy option and is not the server-backed design.
- Browser file picking, photo picking, local storage, and browser share are available. Camera capture is browser/OS-controlled.
- `ForgeHost.ai.agent()` and `ForgeHost.ai.runTask()` currently reject in standalone mode. Native/device methods reject or are limited browser fallbacks.
- The local Python ASGI service, authenticated publishing page, keyless ForgeChat export option, server-backed chat runtime, SSE streaming/cancellation, and bounded image/text attachments now exist under `server/`. `docs/standalone-export.md`, `docs/api.md`, and the server/frontend test suites describe and exercise the current implementation.

## Scope and exclusions

### In scope, phased

- Server-backed `ForgeHost.ai.isAvailable`, provider discovery/selection, `ai.chat`, streaming chat, and cancellation.
- Browser image/text attachments through the server, subject to explicit payload limits.
- Server-side image generation through explicitly allowlisted provider/model entries, with per-call confirmation, rate limits, and bounded inputs/outputs.
- Browser-native camera/file/microphone capture where secure-context browser APIs support it; provider-backed transcription/TTS can be added behind explicit routes.

### Explicitly out of scope

- Running Python, arbitrary shell commands, `Termux.exec`, or a general-purpose remote code runner.
- `ForgeHost.apps.launch` or launching Android/iOS/desktop phone apps. Do not translate Android intents into server actions.
- Reimplementing the entire Android `ForgeHost` API on the VM. Device permissions, SMS/contacts, notifications, Android audio routing, and other native-only features remain unsupported unless separately designed as browser-native features.
- Exposing provider credentials to exported HTML, browser JavaScript, URLs, logs, or client-controlled provider endpoints.
- Persisting prompts/attachments/chat histories by default.

## Recommended architecture

```text
Existing HTTPS origin (leave current public site/routes intact)
  /forgechat/login              password-manager-friendly login form
  /forgechat/apps/<app-id>       exported HTML (requires a valid session)
  /forgechat/api/v1/auth/login   username/password -> session cookie
  /forgechat/api/v1/auth/logout  revoke browser session
  /forgechat/api/v1/session      session + capability information
  /forgechat/api/v1/providers    server-approved provider/model choices
  /forgechat/api/v1/chat         non-stream chat
  /forgechat/api/v1/chat/stream  SSE token stream; abort on client disconnect
  /forgechat/api/v1/images/generate  confirmed, allowlisted server-side image generation

Browser standalone runtime
  ForgeHost-compatible adapter -> same-origin API
  browser APIs                 -> camera/file/mic/playback where supported

Linux VM
  Existing HTTPS server continues serving all current public HTML/static routes
  path-scoped reverse proxy for /forgechat/* -> loopback ASGI service
  Python ASGI service protects login, exported-app files, and AI APIs together
  exported HTML read only from a dedicated configured app directory
  Python ASGI service (FastAPI/Starlette + Uvicorn) bound to 127.0.0.1 only
  owner and app-user accounts in a private database; provider credentials in protected server configuration
```

Use an ASGI service rather than CGI for the target implementation: ForgeChat needs long-running and streaming requests, cancellation, concurrent sessions, consistent auth, and bounded request handling. A tiny CGI proof-of-concept could validate a single non-stream request, but it should not become the production architecture or run submitted programs.

Serve the app and API from the same HTTPS origin where possible. HTTPS is also needed for browser camera/microphone APIs. Direct `file://` execution is not the supported server-backed deployment path; it complicates secure-context permissions, session cookies, and cross-origin policy.

## API and compatibility direction

The server-backed export should embed only a public service base URL (prefer same-origin relative paths), app identifier, and non-secret feature configuration. It must not embed an upstream key or arbitrary provider base URL.

Initial API surface:

- `GET /api/v1/session` → authenticated user/session and allowed capabilities; no provider credentials.
- `GET /api/v1/providers` → provider IDs, labels, allowed model choices, and selected/default provider; no keys or secret-bearing profile fields.
- `POST /api/v1/chat` → accepts ForgeHost-compatible messages/options and returns normalized `{ok, content, text, providerId, model, usage}` fields.
- `POST /api/v1/chat/stream` → SSE events for token deltas, completion, and normalized errors. Closing/aborting the browser request cancels upstream work when supported.
- `POST /api/v1/images/generate` backs `tools.run('image_generate')`; it requires a configured provider/model allow-list, explicit UI confirmation, rate limits, and bounded output.

All upstream provider selection is resolved by the server from an allowlist. Reject caller-supplied URLs, arbitrary auth headers, and unknown provider IDs to prevent SSRF and credential forwarding. Validate model IDs, message structure, roles, request size, attachments, and supported options. Return normalized, size-capped errors without upstream secrets.

In server-backed browser runtime mode:

- `ai.chat` and `ai.chatStream` call the VM API, never a provider URL.
- `isAvailable`, `listProviders`, `getProvider`, and `setProvider` reflect only server-approved choices. `configure({apiKey})` must not store or transmit provider keys; reject it clearly in this mode.
- Use one same-origin authenticated session for API requests. Do not put bearer/session tokens in the HTML or query string.
- `ai.cancel(id)` aborts the matching request. Streaming should be genuinely incremental, not the current standalone shim that only emits the full response after completion.
- Preserve the existing browser-only/direct-provider export as a separate option during migration. Keep the unsafe “embed keys” choice clearly identified; do not silently convert old exports or change Forge-internal behavior.

Host-managed agents and `runTask` are not in the first milestone. Decide their remote contract only after basic chat is working. Any later remote tool registry must be server-owned and explicitly allowlisted; `apps.launch`, Termux/Python execution, arbitrary shell, and unrestricted code-execution tools must never be registered.

## Authentication and key management

- Private/authenticated access is the recommended default. Static app sharing and paid model access are separate controls; public visibility must not automatically authorize unlimited access to the VM's provider keys.
- The configured owner is bootstrapped once; the owner defines global app-user accounts and per-app allow-lists. New users have no app access until assigned. The VM owner administers provider keys. Exported app pages and AI APIs require a valid session and an app grant; existing public pages remain unchanged.
- The login form uses standard username/current-password autocomplete so the browser's password manager can offer to save credentials. A “Remember me” choice controls a longer-lived signed session cookie. The Forge app must never save the plaintext password to `localStorage`, embed it in HTML, or place it in a URL; browser-managed credential storage is the supported password caching mechanism.
- The login endpoint verifies the configured password hash and issues an expiring cookie; store a salted password hash (not plaintext) and a separate random session-signing secret in protected VM configuration. Provide a way to rotate both and invalidate old sessions.
- Cookies are `Secure`, `HttpOnly`, and `SameSite=Strict` (with a path scoped to the ForgeChat subpath). Require HTTPS, validate same-origin requests/CSRF for state changes, expire/revoke sessions, and rate-limit failed logins and paid AI calls. Keep auth on the ForgeChat route/API only; do not enable site-wide auth in the existing web server.
- Store provider keys only in protected VM configuration or a dedicated secret store; never check real values into Git. Restrict VM file permissions, rotate/revoke keys, and redact request/error logs.
- If public/guest access is later allowed, make it an explicit deployment/app policy with per-user or per-app quotas, concurrency limits, abuse controls, and spend ceilings. Do not rely on CORS or a hidden URL as authentication.
- Default to no prompt/attachment retention. If observability requires logs, redact content and credentials and document retention.

## Browser capability boundary

Camera, microphone, files, and playback stay on the client. The browser asks for permission and sends only the content needed for the requested AI operation. The VM never receives ambient device access. Browser speech/audio behavior is not equivalent to Android TTS routing; report capabilities honestly.

`getCapabilities()` in server-backed mode must describe the current browser/server combination. It must not claim `native`, Termux, app-launch, Android route, SMS, or contacts support. Unsupported host calls should reject with stable, documented errors rather than silently no-op.

## Phased milestones and acceptance checks

### 0. Lock the first-use contract — accepted

- “ForgeChat support” means exported ForgeHost mini-apps use the VM for AI, not a second hosted copy of Forge's entire Android app UI.
- Access uses one bootstrapped owner plus owner-managed global app users and per-app allow-lists; provider credentials remain owned/administered by the VM owner.
- The user's VM already serves HTTPS and public HTML. Preserve those routes; proxy the dedicated ForgeChat subpath to the loopback ASGI service so it can apply the same login session to exported app pages and AI APIs.

**Exit:** decisions recorded; no keys, passwords, session secrets, ports, or host-specific proxy configuration hard-coded into exported HTML or committed to Git.

### 1. Server foundation and non-streaming chat

- Add a separate `server/` Python ASGI service with config validation, health/readiness, session/auth boundary, provider registry, and one normalized non-streaming chat route.
- Keep API keys in server config. Add a mock provider for deterministic tests.
- Define a versioned API schema and request/response limits.

**Exit (local):** authenticated requests succeed in service tests; unauthenticated calls are rejected; client-supplied URL/provider injection cannot redirect credentials; responses contain no provider key. The implementation is local and has not been deployed to the VM.

### 2. Standalone runtime integration and streaming

- Add a third export choice for server-backed HTML. Embed only the configured API base URL and app metadata.
- Route the existing ForgeHost chat functions through the server adapter; retain the direct browser/BYOK export path.
- Implement true SSE streaming, abort/cancel behavior, auth-expiry errors, provider selection, and supported text/image attachments.
- Use same-origin deployment and explicit errors when opened from an unsupported `file://` context.

**Exit:** exported HTML source and runtime config contain no provider config/key; mocked server-backed `ai.chatStream` emits SSE deltas and client abort is tested; existing browser-only export behavior remains green. Authenticated publishing, chat, and SSE routes were smoke-tested through the live HTTPS Apache proxy.

### 3. Safe ForgeChat capabilities

- Add selected server-backed tools one at a time (image generation first if needed, then explicitly approved read-only web tools).
- Keep tool schemas, risk classes, execution, and cost ceilings server-owned. Require user confirmation for billable image operations.
- Continue to exclude Python execution, Termux execution, app launching, and any caller-authored arbitrary tool endpoint.

**Exit:** allowlisted operations work; excluded calls are not advertised and reject deterministically; tests verify quota and risk controls.

### 4. Browser voice and deployment hardening

- Assess browser mic capture, provider-backed transcription/TTS, and supported browsers/devices.
- Maintain the VM runbook, renewal monitoring, backup/update procedures, health checks, and redacted logs.
- Manually verify password-manager autofill on a target mobile browser; the cookie/form behavior is implemented and the login flow was tested through HTTPS, but browser-specific autofill has not been visually exercised.

**Exit (deployment):** service is active as an unprivileged single-worker systemd unit on loopback; only `/forgechat/` is reverse proxied, existing site auth/routes remain unchanged, certificate and post-proxy Certbot dry run pass, and authenticated publish/chat/SSE smoke tests passed. Browser autofill and additional media capabilities remain follow-up checks.

## Verification strategy

- Unit-test server provider routing, input validation, auth/session/CSRF, limits, upstream errors, cancellation, and log redaction with mocked upstreams.
- Extend `tests/standalone-miniapp-export.test.js` to cover server-backed export configuration, no-secret output, provider listing, chat request shape, SSE deltas, abort, and unsupported APIs.
- Add negative tests proving exported HTML cannot select an arbitrary endpoint, retrieve server secrets, execute Python/shell, or launch a phone app.
- Run existing `node --check`, standalone export tests, and the project's `forge_check.sh`/docs checks after implementation. Test supported browsers over HTTPS; Forge APK build alone does not validate server-backed web behavior.

## Open decisions / deployment inputs

1. **Observed host:** Ubuntu 24.04.4 LTS, Apache 2.4.58, Python 3.12.3, document root `/var/www/html`; `/forgechat/` is live as a path-scoped proxy. Preserve the existing site and Apache authentication/configuration.
2. **TLS:** the certificate expired on 21 September 2026 after repeated HTTP-01 timeouts to `52.156.154.146:80`. The user corrected cloud ingress; the dry run and production renewal then succeeded. Apache is listening on `*:80`, UFW is inactive, and Certbot's timer remains active. The renewed certificate was verified through a normal HTTPS client and expires 24 January 2027.
3. **Deployment state:** the non-root service is enabled on loopback; proxy modules and path-only HTTP redirect/HTTPS proxy are installed. Public auth, publish, chat, SSE, logout, and unauthenticated-denial checks passed. The runbook is `docs/forgechat-vm-deployment.md`; the app owner must retrieve and remove the root-only bootstrap password file before first use.
4. **Remote agent parity:** image generation, agent loops, Python/shell, and phone-app launching are not included in this implementation; the execution and app-launch exclusions remain permanent for this scope.
