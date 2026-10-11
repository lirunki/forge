# Standalone HTML exports

This guide describes the optional **Export HTML** output and its browser-only
compatibility runtime. It is separate from the ForgeHost API reference, which
defines the APIs available to mini-apps running inside Forge.

The preview toolbar and Library action **Export HTML** create a single-file
browser export. The separate **Share** action remains the original Forge/AAForge
mini-app share. The standalone runtime is a limited compatibility layer; it
does not change ForgeHost behavior inside Forge.

## API keys

Exports do not embed Forge-saved AI keys by default. Recipients can provide a
key when needed; the standalone runtime keeps it in the tab's memory. To embed
credentials, explicitly select provider/key pairs and acknowledge the warning.
Embedded keys are recoverable from the HTML source and browser memory, can be
copied by recipients, and may incur provider charges. Do not publish or send
key-embedded files to untrusted recipients. Export does not remove secrets
already hard-coded in the mini-app HTML.

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
  uses the browser's `capture` hint; the browser or OS may ignore that hint or
  show a picker instead. There is no Forge CameraX preview or continuous camera
  stream. Permission prompts and actual camera availability are controlled by
  the browser and operating system.
- Provider calls use browser `fetch`. The provider must allow the browser
  origin through CORS. A `file://` origin is especially likely to be blocked;
  try serving the export from localhost/HTTPS and use a provider that allows
  browser-origin requests.
- Native phone/device APIs and host-managed `ForgeHost.ai.agent()` /
  `ForgeHost.ai.runTask()` are unavailable in standalone exports and reject
  with explanatory errors. The standalone runtime does not create a second
  Forge agent runtime.

Test a standalone export in the target browser and on the target device; a
successful Forge build does not validate those browser/device capabilities.
