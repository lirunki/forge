# Forge Host LLM tools registry

> Canonical source: `HOST_TOOL_REGISTRY` + `HOST_BRIDGE_ALLOW` in `forge/www/index.html`.
> This file is a human-readable mirror — regenerate when the registry changes.
> Version baseline: `2.6.70 / versionCode 100` (27 tools).

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

| Tier | Meaning | Default in `tools.list` |
|------|---------|--------------------------|
| `safe` | Read-only, no PII, no side effects | included |
| `sensitive` | Reads personal data (contacts/SMS/location/clipboard) | included |
| `confirm` | Side effect the user sees (launch app, compose, open URL, write clipboard, notify) | included |
| `danger` | Silent irreversible action (sms_send, phone_call) | excluded unless `riskMax:'danger'` |

Filter: `tools.list({ riskMax:'confirm' })` returns everything up to and including `confirm`.

## Tools

### web
| name | risk | description |
|------|------|-------------|
| `web_search` | safe | Search the public web (Wikipedia + DuckDuckGo). Returns titles, urls, snippets. No API key. `query` (req), `limit` 1–10 (def 5). |
| `web_fetch` | safe | Fetch an http(s) URL and return text (HTML stripped by default). `url` (req), `maxChars` (def 12000), `as` text\|html\|json\|raw. |

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

```js
const { tools } = await ForgeHost.tools.list({ riskMax: settings.allowDangerousTools ? 'danger' : 'confirm' })
const r = await ForgeHost.ai.chat({ messages, tools })
if (r.tool_calls?.length) {
  for (const tc of r.tool_calls) {
    const args = JSON.parse(tc.function.arguments || '{}')
    const out = await ForgeHost.tools.run({ name: tc.function.name, args, riskMax })
    messages.push({ role:'tool', tool_call_id: tc.id, name: tc.function.name, content: JSON.stringify(out) })
  }
  const r2 = await ForgeHost.ai.chat({ messages, tools })
}
```
Or use the host loop: `ForgeHost.ai.agent({ messages, tools, riskMax, onToolCall, onToken })`.
