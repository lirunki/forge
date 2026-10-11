# Forge Host LLM tools registry

> Canonical source: `HOST_TOOL_REGISTRY` + `HOST_BRIDGE_ALLOW` in `forge/www/index.html`.
> This file is a human-readable mirror — regenerate when the registry changes.
> Version baseline: `2.7.107 / versionCode 257` (28 host tools + app-registered tools).

The host exposes a tool catalog over `ForgeHost` bridges so chat/agent mini-apps
gain power as the host grows. Mini-apps call `ForgeHost.tools.list()` to get
OpenAI `tools[]` for `ai.chat`, and `ForgeHost.tools.run(name, args)` to execute.

```js
const { tools, catalog, bridgeMethods } = await ForgeHost.tools.list({ riskMax:'confirm' })
await ForgeHost.ai.chat({ messages, tools, tool_choice:'auto' })
// on tool_calls:
await ForgeHost.tools.run('web_search', { query:'…' })
await ForgeHost.tools.call('apps.list', { query:'maps' })   // allowlisted bridge method
const { hint } = await ForgeHost.tools.hint({ riskMax:'confirm' })  // system-prompt text
// aliases: ForgeHost.ai.tools.* · ForgeHost.web.search/fetch
```

## Risk tiers

| Tier | Meaning | Availability |
|------|---------|--------------------------|
| `safe` | Read-only, no PII, no side effects | included by the safe default |
| `sensitive` | Reads personal data (contacts/SMS/location/clipboard) | agent schemas need a per-run host grant; execution still needs platform permission |
| `confirm` | Side effect the user sees (launch app, compose, open URL, write clipboard, notify) | explicitly requested schemas still get host confirmation per call |
| `danger` | Silent irreversible action (sms_send, phone_call) | agent schemas need a per-run host grant and each call gets host confirmation |

`tools.list()` and `tools.run()` default to `riskMax:'safe'`. Explicitly request a
higher tier; host-side authorization and permissions still apply. `riskMax` is a
ceiling, not a grant or a way to suppress host confirmation.

## Task-agent tool selection and safety

`ForgeHost.ai.agent()` and `ForgeHost.ai.runTask()` build OpenAI-shaped schemas
from the live `HOST_TOOL_REGISTRY` and current app-registered tools. Caller-supplied
schemas are reduced to tool names and replaced with canonical host definitions;
unknown names/groups are rejected. Task runs default to `tools:{preset:'safe'}`
(and `riskMax:'safe'`). Supported presets are `safe`, `web-research`, `selected`,
and `all`. `selected` accepts `names` and/or `groups`; if both are provided they
intersect. Capability-unavailable tools are omitted. If the app has an existing
per-app “Always allow” setting for a tool, Forge honors it; otherwise sensitive and
danger tools require an explicit host-owned per-run opt-in before their schemas
are exposed. Confirm/danger calls still go through the host risk sheet, and native
permission prompts remain in force. A mini-app's `onToolCall` can veto but cannot
grant tools or raise the risk ceiling. In an agent run, `bridge_call` blocks every
non-safe nested method; mapped safe methods also require the corresponding
registered tool to be selected. Use the specialized registered tool for any
sensitive or side-effecting operation.

Agent model-facing tool results are bounded (56,000 JSON characters). Sensitive
and danger tool arguments/results are redacted from mini-app event/history payloads;
the model receives the bounded result needed to finish the task. Cancellation also
closes a pending host tool-access prompt.

## Task-agent virtual workspace tools

These are not device capabilities and are not added to `HOST_TOOL_REGISTRY` or
`ForgeHost.tools.list()`. They are injected only into the existing `ai.agent`
loop when a mini-app explicitly opts in with `ForgeHost.ai.runTask({ workspace })`:

- `task_workspace_list`, `task_workspace_read`, `task_workspace_write`,
  `task_workspace_edit`, and `task_workspace_delete`.
- Paths are relative to an in-memory workspace scoped by the host to the current
  mini-app ID and workspace ID. Absolute paths and `..` traversal are rejected;
  no arbitrary device path is exposed.
- Workspace tools are virtual/local and low risk, but the mini-app's existing
  `onToolCall` callback can still veto them. Host tool/risk controls remain
  authoritative for all registered device tools in the same agent run.
- Limits: 200 files, 10 MiB/file, 64 MiB/workspace; session cap 32 workspaces /
  128 MiB. Tool reads are chunked (≤50,000 characters). Data is in-memory only
  and is lost when the Forge process exits; apps can explicitly clear a workspace.

## Tools

### web
| name | risk | description |
|------|------|-------------|
| `web_search` | safe | Search the public web (Wikipedia + DuckDuckGo). Returns titles, urls, snippets. No API key. `query` (req), `limit` 1–10 (def 5). |
| `web_fetch` | safe | Fetch an http(s) URL and return readable text (article/main-content extraction with fallback to plain HTML strip). `url` (req), `maxChars` (def 12000), `as` text\|html\|json\|raw. Result also includes `extracted:true` when the readability path ran. |

### device
| name | risk | description |
|------|------|-------------|
| `get_time` | safe | Current device date/time ISO + locale + timezone. |
| `device_info` | safe | Device / app info snapshot. |
| `clipboard_read` | sensitive | Read text from the clipboard (clamped to 8000 chars). |
| `clipboard_write` | confirm | Write text to the clipboard. `text` (req). |
| `toast` | safe | Show a short Android toast. `message` (req), `long`. |
| `open_url` | confirm | Open a URL in the browser/handler app. `url` (req). |

### notify
| name | risk | description |
|------|------|-------------|
| `notify` | confirm | Show a local notification (requests permission). `title` (req), `body`, `id`. |

### location
| name | risk | perms | description |
|------|------|-------|-------------|
| `get_location` | sensitive | location | GPS/network coordinates (lat/lng/accuracy). |
| `open_maps` | confirm | — | Open maps at coordinates or query. `latitude`, `longitude`, `query`, `label`. |

### sms
| name | risk | perms | description |
|------|------|-------|-------------|
| `sms_list` | sensitive | sms | List recent SMS (inbox/sent/all). `limit` (def 30, max 100), `box`, `address`. Contents slimmed. |
| `sms_compose` | confirm | — | Open SMS composer (user sends). `to`, `body`. |
| `sms_send` | danger | sms | SEND an SMS silently. `to`+`body` (req). Only when user explicitly asked. |

### phone
| name | risk | perms | description |
|------|------|-------|-------------|
| `phone_dial` | confirm | — | Open dialer with a number. `number` (req). |
| `phone_call` | danger | phone | Place a phone call. `number` (req). Only when user explicitly asked. |

### contacts
| name | risk | perms | description |
|------|------|-------|-------------|
| `list_contacts` | sensitive | contacts | List contacts with optional query. `query`, `limit`. |
| `find_contact` | sensitive | contacts | Find contacts by JS regex over name + numbers. `regex` (req), `flags`, `query`, `limit`. Returns `contact` (first) + `contacts[]`. |

### apps
| name | risk | description |
|------|------|-------------|
| `list_apps` | safe | Search installed apps by name/package. `query`, `limit`. |
| `list_activities` | safe | List activities for a package. `packageName` (req). |
| `launch_app` | confirm | Launch app/activity/deep-link. `packageName`, `activity`, `data`, `chooser`. |

### radio
| name | risk | description |
|------|------|-------------|
| `radio_status` | safe | Wi-Fi/Bluetooth/GPS/hotspot status. |
| `radio_set` | confirm | Toggle wifi/bluetooth/gps/hotspot (OS may require Settings UI). |
| `radio_open_settings` | confirm | Open system settings panel. `which` wifi\|bluetooth\|gps\|hotspot\|wireless. |

### media
| name | risk | description |
|------|------|-------------|
| `tts_speak` | confirm | Speak text with on-device TTS. `text` (req), `lang`, `rate`, `route`. |
| `image_generate` | confirm | Generate an image from a text prompt, optionally seeded with reference images. Uses the selected AI provider when it supports image generation, then the configured xAI provider as fallback. `prompt` (req), `images` (optional array of data URLs/base64/URLs for image-to-image), `n` (1-4), `model` (optional requested model). Agent runs may set `imageGeneration.models` to an ordered, validated model fallback list. Returns `{ ok, images:[{url, revised_prompt}], count, model, backend }`. |

### meta
| name | risk | description |
|------|------|-------------|
| `get_capabilities` | safe | List ForgeHost capability flags for this session. |
| `bridge_call` | confirm | Escape hatch: call a low-level host method by dotted name when no specialized tool fits. `method` (req), `args`. Prefer named tools. Allowed methods listed by `tools.catalog` → `bridgeMethods`. |

## `bridge_call` allowlist (`HOST_BRIDGE_ALLOW`)

`getAppInfo, getCapabilities,
permissions.get/request/requestPack,
sms.compose/send/read,
phone.dial/call,
contacts.list/find/search,
location.get/openMaps,
apps.list/find/get/listActivities/resolve/launch,
radio.getStatus/set/openSettings,
device.info/vibrate/openSettings,
http.get/post,
clipboard.read/write,
share, toast, openUrl, notify,
tts.speak/stop/getVoices,
audio.getRoute/setRoute/clearRoute/listOutputs,
email.compose,
fs.readdir/stat/read,
termux.isAvailable/open`

> `termux.run` / `termux.exec` are intentionally **omitted** from the default
> allowlist — they are `danger`-tier and not exposed via `bridge_call`. Wire a
> dedicated `danger` tool if a mini-app needs Termux exec.

## Extending the registry

1. Implement the ForgeHost bridge method / `handleCall` path.
2. Append a `HOST_TOOL_REGISTRY` entry (+ `HOST_BRIDGE_ALLOW` row if using `bridge_call`).
3. Mini-apps using `tools.list` pick it up automatically — no per-app changes.
4. Update this file (`docs/tools.md`) and `docs/api.md`.

## Mini-app contract

Prefer the existing host-managed loop rather than creating another runtime:

```js
const result = await ForgeHost.ai.runTask({
  task: 'Research this topic',
  tools: { preset: 'web-research' },
  riskMax: 'safe',
  onToken: delta => render(delta),
})
```

For a custom interaction, `ForgeHost.ai.agent()` accepts the same presets, or
`{preset:'selected', names:[...], groups:[...]}`. Omit `tools` for safe-only
access. If an app intentionally uses a manual `ai.chat` tool loop, it must still
obtain schemas from `ForgeHost.tools.list({riskMax})` and execute through
`ForgeHost.tools.run({name, args, riskMax})`; never execute model-provided
function schemas. Direct `tools.run` calls default to safe and retain the host
risk sheet and native permission checks regardless of app UI.
