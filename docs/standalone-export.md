# Standalone HTML exports

This guide describes the optional **Export HTML** output and its browser-only
compatibility runtime. It is separate from the ForgeHost API reference, which
defines the APIs available to mini-apps running inside Forge.

The preview toolbar and Library action **Export standalone HTML** create a
single-file browser export with separate direct-provider, ForgeChat-server, and
explicit key-embedding choices. The separate **Share** action remains the
original Forge/AAForge mini-app share. The standalone runtime is a limited
compatibility layer; it does not change ForgeHost behavior inside Forge.

The Google Play `play` flavor hides the ForgeChat-specific HTML export choice
and its explanatory text; ordinary standalone HTML export remains available.
The `full` flavor, including the debug APK, keeps the ForgeChat export choice.

## API keys

Exports do not embed Forge-saved AI keys by default. Recipients can provide a
key when needed; the standalone runtime keeps it in the tab's memory. To embed
credentials, explicitly select provider/key pairs and acknowledge the warning.
Embedded keys are recoverable from the HTML source and browser memory, can be
copied by recipients, and may incur provider charges. Do not publish or send
key-embedded files to untrusted recipients. Export does not remove secrets
already hard-coded in the mini-app HTML.

### ForgeChat server export

The **Export for ForgeChat · no keys** option creates the same kind of single
HTML file but removes all provider configuration and keys from the output. Its
AI calls use same-origin `/forgechat/api/v1/` endpoints. The file is not meant
to be opened from `file://` or hosted as an ordinary public HTML file: upload
it through the authenticated `/forgechat/publish` page so the service can
protect both the app page and its APIs. A signed-in session is required, and
provider credentials are configured and kept only on the server. The hosting
site must have a valid HTTPS certificate.

This option requires the ForgeChat service and the Apache `/forgechat/` proxy
to be installed separately; exporting locally does not deploy or publish the
file. Do not use this mode until the server's HTTPS login and protected routes
have been verified. Server-backed `chatStream` uses SSE and can be canceled;
text and image attachments are supported. `ForgeHost.tools.run('image_generate')`
uses the authenticated server endpoint when an image-capable provider is
configured. Provider keys stay server-side, and the browser asks for confirmation
before a potentially billable request. The server allowlists each provider's
image models (`xai` has its supported defaults; other OpenAI-compatible providers
can set `image_models` in the server catalog). Binary documents and other
host-managed tool loops are not enabled. The server-backed `ai.agent()`
compatibility method falls back to one chat-only streamed response and marks
`toolsUnavailable`; it never runs tools. The direct
browser-provider export remains separate and does not use server SSE.

### ForgeChat server TTS

ForgeChat-hosted exports can use `ForgeHost.ai.transcribe({dataUrl, language, timestamps, prompt})` for audio-to-text; it posts up to 12 MiB to the authenticated same-origin `/api/v1/transcribe` route after an in-page confirmation. Only operator-configured OpenAI-compatible STT providers are used and provider keys stay server-side. A successful result includes `text`, timestamp `segments` when requested, and the provider ID. This is cloud/provider transcription, not local VM Whisper.

ForgeChat-hosted exports can use `ForgeHost.ai.tts`, `ForgeHost.ai.listVoices`,
`ForgeHost.ai.ttsToFile`, and `ForgeHost.tts.getVoices()` /
`synthesizeToFile()`. Cloud TTS calls a configured xAI or OpenAI-compatible
endpoint with server-held credentials; the browser cannot provide an upstream
URL or key. Select `engine: 'local'` for offline VM-local synthesis instead; it
uses the VM's eSpeak NG installation and does not call a TTS provider. The
browser confirms the selected synthesis mode. Audio playback is browser-side.

File synthesis in this hosted mode writes to a generated `tts/` path in the
private backend-agent workspace and returns `agentPath`; it requires both app
access and the separate Backend agent access grant. Local VM mode currently
outputs WAV. It does not write to Android `/sdcard` or invoke Android's local
TTS engine. `ForgeHost.tts` stays
unsupported in ordinary browser-only standalone HTML exports.

A ForgeChat instance can optionally expose a separate Linux command agent after
an administrator provisions `server/deploy/linux-agent/setup.sh`. Without that
one-time deployment, the agent endpoints remain disabled. The account owner is
always allowed; other shared accounts need the owner to grant the distinct
**Backend agent access** permission at `/forgechat/users`. This is a high-trust
granted capability, independent of per-app access: a permitted account can run
arbitrary commands in the isolated Docker container and use its persistent
workspace. Commands execute as unprivileged UID 10000, not on the VM or Android
phone. The container has no Docker socket or provider credentials. The generated
worker credentials remain server-side.

In this hosted server mode only, `ForgeHost.termux` exposes `isAvailable`,
`status`, `exec`, `run`, `readFile`, `writeFile`, and `streamFile` (with browser
`File`/`Blob` sources). An in-page approval dialog confirms command execution and uploads (it does not rely on suppressible browser-native `confirm()` dialogs);
file paths are confined to the container workspace. In browser mode,
`ForgeHost.files.pick({inline:false})` returns a browser `File` for streaming to
`ForgeHost.termux.writeFile`; native Android picks continue to use their content
URI. The hosted agent cannot open Android Termux, access Android content URIs,
install the container, or run commands on the VM. The normal browser-only
standalone export still has no `termux` API.

The Linux agent container ships a Termux-compatible `pkg` command: a hosted
app that runs `pkg install -y ffmpeg` (or other Debian packages) in an agent
`exec` job will download and extract the packages into a per-user writable
prefix and make them available on the job `PATH` for that and later jobs,
without system-root writes — the same self-install model Termux apps already
use. It does not make Android device APIs, Android TTS, or `/sdcard` paths
available; those still require running the app on-device in Forge with Termux.

## Browser capabilities and limits

The compatibility runtime supports browser storage, file picking, sharing,
basic `ForgeHost.ai.chat`/`chatStream`, and `ForgeHost.tools.run('image_generate')`
for compatible exported/session provider keys. Image generation asks for
confirmation before sending a potentially billable request. `ai.chat({attachments})`
normalizes browser image data into OpenAI-compatible `image_url` parts and
Gemini `inline_data`; text files are included as text. Binary documents such as
PDFs require a Gemini provider or the full Forge host; they are not supported
by the standalone OpenAI-compatible chat path.

- `ForgeHost.files.pick()` uses a browser file input and must be called from a
  user action.
- `ForgeHost.camera.pickPhoto()` opens an image picker. `camera.takePhoto()`
  opens a live camera preview and shutter using `getUserMedia` when available,
  then returns a JPEG attachment that can be passed to `ForgeHost.ai.chat()`.
  If the live stream is unavailable, it falls back to the browser/OS camera file
  picker. Permission prompts and actual camera availability are controlled by
  the browser and operating system.
- Provider calls use browser `fetch`. The provider must allow the browser
  origin through CORS. A `file://` origin is especially likely to be blocked;
  try serving the export from localhost/HTTPS and use a provider that allows
  browser-origin requests.
- Native phone/device APIs and host-managed tool loops remain unavailable in
  standalone exports. The optional server-backed Linux command API described
  above is a separate allow-listed capability, not Android Termux or a Forge
  host tool. `ForgeHost.ai.agent()` falls back to one normal chat response
  (streamed through the browser/server chat path) and returns
  `toolMode: "chat-only"` plus `toolsUnavailable: true`. Requested Forge tool
  presets/schemas are not sent and no AI-driven tool actions are executed.
  `ForgeHost.ai.runTask()` still rejects with an explanatory error. Full
  host-managed agents remain available inside Forge, where host permissions
  and tool confirmations can be enforced.

Test a standalone export in the target browser and on the target device; a
successful Forge build does not validate those browser/device capabilities.
