# Forge Host API reference

> Canonical source: `forge/www/index.html` (the `SYSTEM_PROMPT` + `ForgeHost` bridge).
> This file is a human-readable mirror — regenerate from the host when the bridge changes.
> Version baseline: `2.6.66 / versionCode 96`.

`window.ForgeHost` (alias `window.forge`) is injected into every mini-app
iframe by the host before `ready`. **All host APIs are async (Promises).
Always `await` + `try/catch`.** Never invent other native bridges.

## Discovery

```js
ForgeHost.getAppInfo()                       // { id, title, summary }
ForgeHost.getCapabilities()                  // capability flags (see below)
ForgeHost.permissions.get()                  // current grant map
ForgeHost.permissions.request(alias)         // 'sms'|'contacts'|'phone'|'location'|'mic'|'camera'|'photos'|'notifications'
// One-shot permission packs (recommended UX):
await ForgeHost.permissions.requestPack('phone')   // sms+phone+contacts+location
await ForgeHost.permissions.requestPack('media')   // camera+photos+mic
await ForgeHost.permissions.requestPack('notify')  // notifications
await ForgeHost.permissions.requestPack('all')
await ForgeHost.permissions.requestPack({ features:['sms','mic','notifications'] })
// -> { ok, features, granted, denied, permissions, note }
await ForgeHost.permissions.packs()          // list pack ids
```

### Capability flags (`getCapabilities`)
`platform, native, appId, smsCompose, smsSend, smsRead, dial, call, contacts,
location, vibrate, maps, email, apps, listApps, listActivities, launch,
intents, tts, audioRoute, mic, micStream, liveTranslate, camera, fs, termux,
termuxExec, storage, secrets, events, files, share, shareFiles, tools,
webSearch, webFetch, ai, aiMultimodal, aiAttachments, aiProviderMenu,
aiProviders, aiProvider, aiProviderId, aiModel, aiProviderCount,
aiAvailableCount, keepAwake, permissions:{}`

## Lifecycle events (host → mini-app)

```js
ForgeHost.on('ready'|'resume'|'pause'|'destroy'|'notify'|'job'|'restored', (data) => { ... })
ForgeHost.off(event, fn)
```

State is preserved automatically on background:
- `pause` includes `{ preserve:true, statePreserved:true, automatic:true }`
- Host snapshots forms + optional `window.__forgePersist()`
- On next `ready`/`resume`, DOM inputs restore; `restored` event fires

```js
ForgeHost.state.get/set/remove/clear/getAll/save/restore
// Mark inputs: <input id="name" data-forge-persist> (or id/name). Skip passwords.
// Optional hooks: window.__forgePersist = () => ({...}); window.__forgeRestore = (data) => {}
// Prefer ForgeHost.state / storage over window.localStorage (unreliable in sandbox srcdoc).
```

## Storage & secrets

```js
// Per-app key/value storage (namespaced by library id — prefer over localStorage)
ForgeHost.storage.get/set/remove/list/clear/getAll
ForgeHost.app.storage.*                   // alias

// Secrets (per-app, separate from storage.list, lightly obfuscated at rest — NOT a hardware vault)
ForgeHost.secrets.get/set/remove/list/clear
// Use for API tokens the mini-app needs; never put host AI keys in HTML.
```

## Host AI (user's configured providers/keys — NEVER embed API keys in HTML)

```js
await ForgeHost.ai.isAvailable()           // { available, multimodal, provider, providerId, model, backend, providers, ... }
const menu = await ForgeHost.ai.listProviders()   // alias: ai.menu()
// menu = { providers:[{ id, label, model, available, backend, isDefault, isSelected }], selectedId, defaultId }
await ForgeHost.ai.getProvider()           // current selection for THIS mini-app
await ForgeHost.ai.setProvider('xai')      // persist per-app choice
await ForgeHost.ai.setProvider('default')  // reset to host default

// One-shot override (no setProvider needed):
await ForgeHost.ai.chat({ prompt:'…', providerId:'openai', model:'gpt-4o-mini' })
const { content } = await ForgeHost.ai.chat({ prompt: 'Summarize this' })

// Multimodal (OpenAI-style content parts):
await ForgeHost.ai.chat({
  messages: [{ role:'user', content:[
    { type:'text', text:'What is in this photo?' },
    { type:'image_url', image_url:{ url: shot.dataUrl } },
  ]}],
})

// Attachments helper — pass pick/camera results through; host classifies by MIME:
await ForgeHost.ai.chat({
  prompt:'Describe these',
  attachments:[
    { type:'image', dataUrl: shot.dataUrl, mime:'image/jpeg' },
    { type:'file', name:'notes.txt', mime:'text/plain', base64: f.base64, dataUrl: f.dataUrl },
    f,  // full files.pick / camera result is OK
  ],
})

// Token streaming (2.6.52): resolves to the full ai.chat result; onToken fires per delta
// Cancellable (2.6.54): pass an `id` and call ForgeHost.ai.cancel(id) to abort.
await ForgeHost.ai.chatStream({
  messages, tools,
  id: 'my-stream',           // optional; returned as r.id if omitted
  onToken: (delta, meta) => render(delta),     // optional
  onToolCall: (tool_calls, meta) => {},          // optional
  providerId, model,
})
// r.id is the stream id (use it to cancel if you did not pass one)
await ForgeHost.ai.cancel(r.id)   // aborts a running stream / agent

// Agent loop (2.6.52): host runs chat + tool-call loop + risk sheet
// onToolCall veto (2.6.54): returning false (or a Promise resolving to false)
//   denies that tool call and the loop continues (a denied `role:'tool'` row is pushed).
//   This is IN ADDITION to the host risk sheet; either gate can deny.
const r = await ForgeHost.ai.agent({
  messages, tools,           // or omit tools to auto-load via tools.list
  maxRounds: 6,
  riskMax: 'confirm',        // safe|sensitive|confirm|danger
  id: 'my-agent',            // optional; cancellable via ai.cancel(id)
  onToken: t => render(t),   // optional (uses chatStream when provided)
  onToolCall: ({name,args}) => true,  // return false to veto this tool call
  onRound: ({round, toolCalls}) => {},
})
```

### Tool calling
```js
// const r = await ForgeHost.ai.chat({ messages, tools, providerId })
// if (r.tool_calls?.length) { run tools, push role:'tool', call ai.chat again }
```
- Gemini: `functionDeclarations` + `functionCall`/`functionResponse`
- OpenAI-compatible + xAI: `tools[]`/`tool_choice`; response includes `tool_calls`
- No Responses-API fallback on tool-calling turns

### TTS
```js
await ForgeHost.ai.tts({ text, voice:'eve', language:'en', mode:'cloud', play:true, route:'speaker' })
const audio = await ForgeHost.ai.tts({ text:'Hi', mode:'cloud', play:false }) // { dataUrl, base64, mime, engine }
await ForgeHost.ai.tts({ text:'Hi', mode:'native', lang:'en-US' })            // device TTS
const vs = await ForgeHost.ai.listVoices()   // alias ai.voices({ source:'cloud'|'native'|'all' })
// vs.options = [{value:'eve', label:'eve — Energetic & upbeat'}, …]  ← use for <select>
// vs.ids / vs.labels / vs.list = string arrays (never objects)
```
Voices — xAI: `eve|ara|leo|rex|sal|luna…` (default `eve`); OpenAI-compat: `alloy|nova…` (default `alloy`).

### STT (Patch 2)
```js
await ForgeHost.ai.transcribe({ dataUrl: wav.dataUrl, language:'en' })
// -> { ok, text, transcript, provider, providerId, model, language }
// needs .stt true (OpenAI/Groq/xAI). NOT Gemini.
const wav = await ForgeHost.mic.record({ durationMs:2500, sampleRate:16000 })
await ForgeHost.ai.transcribe({ base64: chunk.base64, encoding:'pcm_s16le', sampleRate:16000, language:'en' })
// alias: ForgeHost.ai.stt(...)
```

### Live translate session (Patches 3–4)
```js
ForgeHost.on('live.partialTarget', d => console.log(d.text))
// events: live.status | live.level | live.partialSource | live.finalSource
//         live.partialTarget | live.finalTarget | live.error
//         live.flip | live.pause | live.resume   (Patch 4)
await ForgeHost.ai.liveTranslate.start({
  sourceLang:'auto', targetLang:'en', speak:true,
  chunkMs:250, windowMs:1400, route:'speaker',
  mode:'oneWay',          // 'oneWay' (default) | 'conversation'
  langA:'en', langB:'es',  // conversation mode: the two languages to flip between
  autoDetect:false,        // conversation: auto-detect spoken lang per segment (script heuristic)
})
await ForgeHost.ai.liveTranslate.status()
await ForgeHost.ai.liveTranslate.configure({ speak:false })
await ForgeHost.ai.liveTranslate.flip()      // swap source/target (conversation) or reverse (oneWay)
await ForgeHost.ai.liveTranslate.pause()     // suspend STT, keep mic warm
await ForgeHost.ai.liveTranslate.resume()
await ForgeHost.ai.liveTranslate.stop()
```
Needs STT provider (OpenAI/Groq/xAI). Caps: `getCapabilities().liveTranslate`.

**Conversation mode (Patch 4):** `mode:'conversation'` with `langA`/`langB` enables
bidirectional A↔B. `flip()` swaps direction; `autoDetect:true` auto-flips via
Unicode-script detection (works for distinct-script pairs like en↔zh, en↔ja, en↔ar,
en↔ru, en↔he, en↔hi, en↔ko; same-script pairs like en↔es use manual `flip()`).
`pause()`/`resume()` suspend STT while keeping the mic stream warm. `live.flip`
events carry `{ direction:'a2b'|'b2a', sourceLang, targetLang, auto, seq }`.

## Files (ALWAYS use ForgeHost — never `<input type=file>` in the iframe)

```js
await ForgeHost.files.isAvailable()
const f = await ForgeHost.files.pick({ accept:'image/*,application/pdf', multiple:false })
// single: { name, type, mime, size, base64, dataUrl, uri? } or null if cancelled
const many = await ForgeHost.files.pick({ accept:'*/*', multiple:true })  // array (maybe empty)
// Photos only (gallery): ForgeHost.camera.pickPhoto({ quality:85 })
```

## HTTP (native — bypasses WebView/iframe CORS)
```js
ForgeHost.http.get(url, headers?), ForgeHost.http.post(url, body, headers?)
const { dataUrl, mime, bytes } = await ForgeHost.http.getDataUrl(url, { maxBytes: 8*1024*1024 })
const { html, inlined, failed } = await ForgeHost.http.inlineHtml(llmHtml, { maxAssets: 16 })
// ALWAYS inlineHtml before putting LLM HTML with external images into an iframe/srcdoc.
```

## Clipboard / share / UI
```js
ForgeHost.clipboard.read() / write(text)
ForgeHost.contacts.list/find({query,regex,flags,limit})
ForgeHost.radio.getStatus()/set({wifi,bluetooth,gps,hotspot})/openSettings(which)
await ForgeHost.share.isAvailable()
await ForgeHost.share({ title:'Note', text:'Hello' })
await ForgeHost.share({ json: obj, name:'data.json' })
await ForgeHost.share.file({ name:'shot.jpg', mime:'image/jpeg', dataUrl })
```

## Notifications (channels + tap re-opens THIS mini-app with payload)
```js
await ForgeHost.notifications.requestPermission()
await ForgeHost.notify('Hello', { title:'Hi', channel:'alerts', data:{ orderId:1 } })
// channels: 'default' | 'alerts' | 'jobs'
await ForgeHost.notifications.show({ title, message, channel:'jobs', tag:'x', data })
await ForgeHost.notifications.cancel({ id }) / cancelAll()
ForgeHost.on('notify', (e) => { /* e.payload, e.tag */ })
```

## Background jobs / reminders (AlarmManager)
```js
await ForgeHost.jobs.isAvailable()            // { available, exact, minIntervalMs }
await ForgeHost.jobs.schedule({ inSeconds:3600, title:'Hydrate', text:'Drink water', data:{c:1} })
await ForgeHost.jobs.schedule({ atMs:Date.now()+60000, id:'once1', channel:'jobs' })
await ForgeHost.jobs.schedule({ type:'interval', intervalMs:3600000, title:'Hourly' }) // min 1 min
await ForgeHost.jobs.cancel('once1') / cancelAll() / list()
ForgeHost.on('job', (e) => { /* e.jobId, e.payload */ })
await ForgeHost.jobs.listPending()
```

## Phone / SMS / contacts / location
```js
ForgeHost.sms.compose(to, body)              // no perm — opens SMS app
await ForgeHost.permissions.request('sms')
ForgeHost.sms.send(to, body)                 // sms.read/send auto-request once if missing
ForgeHost.sms.read({limit, box, address})    // box: inbox|sent|all
ForgeHost.phone.dial(number)                 // no perm
ForgeHost.phone.call(number)
ForgeHost.contacts.list({limit, query})
ForgeHost.location.get()
ForgeHost.location.openMaps({latitude,longitude,query,label})
ForgeHost.email.compose({to,subject,body})
ForgeHost.device.info() / vibrate(ms) / openSettings()
```

## Apps / activities / intents
```js
const { apps, options } = await ForgeHost.apps.list({ query:'whatsapp', limit:100 })
await ForgeHost.apps.find('maps')
await ForgeHost.apps.get('com.whatsapp')
const { activities, options: acts } = await ForgeHost.apps.listActivities('com.whatsapp')
await ForgeHost.apps.resolve({ action:'android.intent.action.VIEW', data:'https://maps.google.com' })
await ForgeHost.apps.launch({ packageName:'com.whatsapp' })
await ForgeHost.apps.launch({ data:'https://wa.me/15551212?text=' + encodeURIComponent('Hi') })
await ForgeHost.apps.launch({ data:'geo:0,0?q=' + encodeURIComponent(addr) })
await ForgeHost.apps.launch({ data:'google.navigation:q=' + encodeURIComponent(addr) })
await ForgeHost.apps.launch({ action:'android.intent.action.SEND', type:'text/plain',
  packageName:'com.whatsapp', extras:{ 'android.intent.extra.TEXT':'Hello' } })
await ForgeHost.apps.launch({ data:url, chooser:true, chooserTitle:'Open with' })
// Aliases: apps.open / apps.startActivity / apps.openApp(pkg) / intent.launch(opts)
```
Prefer deep-link data URIs (wa.me, geo:, google.navigation:) over guessing activity class names. Never launch without a user gesture.

## Text-to-speech (on-device)
```js
await ForgeHost.tts.isAvailable()
await ForgeHost.tts.speak(text, { lang:'en-US', rate:1, pitch:1, wait:true, voice, route })
await ForgeHost.tts.stop()
await ForgeHost.tts.getVoices() / getLanguages() / setLanguage(lang)
```

## Microphone / WAV / PCM stream
```js
await ForgeHost.permissions.request('mic')
await ForgeHost.mic.listen({ lang:'en-US' })   // -> { transcript, alternatives }
await ForgeHost.mic.stop() / cancel()
await ForgeHost.mic.startRecord({ sampleRate:16000, maxMs:60000 })
const wav = await ForgeHost.mic.stopRecord()   // { format:'wav', mime, base64, dataUrl, durationMs, … }
await ForgeHost.mic.record({ durationMs:3000, sampleRate:16000 })  // convenience
// Continuous PCM stream:
ForgeHost.on('mic.pcm', ({ base64, sampleRate, channels, encoding, rms, seq, bytes, ts }) => { … })
ForgeHost.on('mic.streamStop', …) / ForgeHost.on('mic.streamError', …)
await ForgeHost.mic.startStream({ sampleRate:16000, chunkMs:250 })
await ForgeHost.mic.isStreaming()
await ForgeHost.mic.stopStream()
```

## Camera / QR
```js
await ForgeHost.permissions.request('camera')
const shot = await ForgeHost.camera.takePhoto({ quality:85, maxWidth:1920, facing:'back' })
// shot = { base64, dataUrl, format:'jpeg', width, height, bytes, path? }
const picked = await ForgeHost.camera.pickPhoto({ quality:85, maxWidth:1920 })
await ForgeHost.camera.isAvailable()
await ForgeHost.qr.requestPermission()
const r = await ForgeHost.qr.scan({ title:'Scan QR' })     // { text, format, cancelled? }
const r2 = await ForgeHost.qr.decodeImage({ dataUrl: shot.dataUrl })
await ForgeHost.barcode.scan()
```

## Filesystem
```js
// directory: 'documents' | 'data' | 'cache' | 'external' | 'externalStorage' (default documents)
await ForgeHost.fs.dirs()
await ForgeHost.fs.write(path, data, { directory, recursive, encoding? })
await ForgeHost.fs.read(path, { directory, encoding? })            // -> { data }
await ForgeHost.fs.writeBase64(path, b64, { directory })
await ForgeHost.fs.readBase64(path, { directory })
await ForgeHost.fs.append / mkdir / readdir / rm / stat / rename / uri
```

## Termux (if installed)
```js
await ForgeHost.termux.isAvailable()   // { installed, execSupported, bridge, flavor, agentRunning, home, prefix }
await ForgeHost.termux.open()
await ForgeHost.termux.run({ script:'echo hi > ~/forge_out.txt' })           // fire-and-forget
const r = await ForgeHost.termux.exec({ script:'python hello.py', timeoutMs:60000 })
// r = { ok, stdout, stderr, exitCode, bridge, err?, errmsg? }
```
Google Play Termux has NO RUN_COMMAND; needs `forge-termux-agent` (localhost:8787). F-Droid/GitHub Termux: `allow-external-apps=true`. Prefer `termux.exec` when output is needed. Never run destructive scripts without an explicit user tap.

## Keep awake / background
```js
await ForgeHost.keepAwake.start({ title, text })
await ForgeHost.keepAwake.stop()
```

## Audio output routing
```js
// Routes: auto|default|speaker|earpiece|wired|bluetooth|communication
await ForgeHost.audio.listOutputs()
await ForgeHost.audio.getRoute()
await ForgeHost.audio.setRoute('speaker')          // sticky
await ForgeHost.audio.clearRoute()
await ForgeHost.audio.play({ dataUrl, route:'speaker', wait:true })
await ForgeHost.audio.stop()
// per-utterance: ForgeHost.tts.speak(text, { route:'speaker' }) / ForgeHost.ai.tts({ …, route })
```

## Host LLM tools registry
See [`tools.md`](tools.md) for the full catalog. Summary:
```js
const { tools, catalog } = await ForgeHost.tools.list({ riskMax:'confirm', names?: string[] })
await ForgeHost.tools.run('web_search', { query:'…', limit:5 })
await ForgeHost.tools.run('web_fetch', { url, maxChars:12000 })
await ForgeHost.tools.run('get_location')
await ForgeHost.tools.call('apps.list', { query:'maps' })   // allowlisted bridge methods
const { hint } = await ForgeHost.tools.hint({ riskMax:'confirm' })  // system-prompt text
// aliases: ForgeHost.ai.tools.* · ForgeHost.web.search/fetch
```
Chat/agent mini-apps MUST use `tools.list/run` (not a hardcoded `APP_TOOLS`).
Include Settings: enable tools, riskMax, confirm side effects, optional tool multi-select; persist via `ForgeHost.storage`. Danger tools (`sms_send`, `phone_call`) only if user enables danger risk and explicitly asks.

## Permission UX rules
- Request before sensitive APIs; on deny, show UI + button calling `device.openSettings()`.
- Prefer `sms.compose` / `phone.dial` over silent send/call unless user wants automation.
- Never SMS/call/Termux-run without an explicit user tap.
- Do not exfiltrate contacts/SMS/mic transcripts unless user asked.

## Mini-app contract recap
- One self-contained HTML document (inline CSS + JS). No external scripts/styles except if absolutely necessary.
- Beautiful, mobile-first UI. Large tap targets.
- `window.ForgeHost` (alias `window.forge`) is injected. NEVER invent other native bridges.
- No `alert()` spam; polished empty states; refine = full new html.
- No stealing host LLM API keys. If the mini-app needs AI, use `ForgeHost.ai.*` and offer a provider menu via `listProviders`/`setProvider`.
- JSON-escape the html string properly when returning from Forge-it.
