# Forge (phone) session log — LOCKED

## ⛔ INVARIANT
**Never delete folders without explicit user permission.** See [`INVARIANTS.md`](INVARIANTS.md).

---

## Status (LOCKED baseline 2026-08-07 · host restored 2026-08-10)

| Field | Value |
|--------|--------|
| Package | `com.forge.live` |
| Version | **2.6.1 / versionCode 33** |
| **Original APK (preserved, untouched)** | `~/downloads/Forge-debug.apk` |
| **Canonical Gradle APK** | **`~/downloads/Forge-debug-rebuilt.apk`** |
| Also | `/sdcard/Download/Forge-debug-rebuilt.apk` |
| Source | Reconstructed from APK (JADX + assets + Capacitor 6) |
| Build | `bash ~/downloads/build_forge.sh` → `assembleDebug` |
| Install | `adb install -r ~/downloads/Forge-debug-rebuilt.apk` |
| **Host `www/index.html`** | **Restored** to pre–live-translate size (**~418605 bytes**); AI tools/attachments **kept** |
| **Last rebuild** | 2026-08-10 — UI fix rebuild after live-translate host regression |

### Locked product baseline

| Area | Locked state | Do not regress |
|------|----------------|----------------|
| **Selects / menus / theme** | Original APK behavior | No `FORGE_SELECT_FIX`, no `appearance:none` select hacks, no `FORCE_DARK`, no custom HTML dropdown, no always-dark AppTheme experiment |
| **`MainActivity.java`** | Original JADX (plugins + intent forward + keepWebViewAlive only) | No `configureWebViewChrome` / `AppCompatDelegate` night force |
| **`styles.xml` / `colors.xml`** | APK-shaped themes (`Light.DarkActionBar` + `DayNight.NoActionBar` + splash) | No `ForgeAlertDialog` overlay theme |
| **`index.html` (shell + ForgeHost)** | APK UI/selects **+** AI tools/attachments host fix | Do not wipe AI fix when touching UI; do not reintroduce select “fixes”; **do not bulk-inject large WIP features into host without isolated landing** |
| **AI Chat samples** | `~/downloads/Forge_AI_Chat.*.html` pass `attachments` + correct tool bind | Re-import on device if old mini-app HTML still installed |
| **Original binary** | `Forge-debug.apk` never modified | Prefer for absolute binary identity |
| **`recovered/`** | JADX / APKEditor reference | **Never delete** without explicit user OK naming the folder |

---

## What Forge is

Phone kitchen sink for mini-apps:

- Capacitor WebView shell (`assets/public/index.html` ← keep in sync with `www/index.html`)
- Native bridges: Phone, Apps, TTS, Mic, Camera, Files, QR, Termux, Shortcuts, Notify, Jobs, Background
- Share AI / mini-apps to **AAForge**
- `carCompatible` when generating AA-oriented mini-apps

**MainActivity plugins:** BackgroundForge, PhoneBridge, AppsBridge, TtsBridge, MicBridge, CameraBridge, FilesBridge, TermuxBridge, ShortcutBridge, NotifyBridge, JobBridge, QrBridge

---

## Layout

```
forge/
  INVARIANTS.md
  session.md                 ← this file
  README.md
  package.json + node_modules/@capacitor/…
  www/index.html             ← CANONICAL host UI + ForgeHost (restored baseline)
  www/index.html.with-live-backup  ← WIP host dump (live-translate attempt; DO NOT ship)
  android/                   ← Gradle app
    app/src/main/assets/public/index.html  ← must match www/ before build
    …/MicBridgePlugin.java   ← has startStream/stopStream (native only; host not wired)
  recovered/                 ← DO NOT DELETE
~/downloads/build_forge.sh
~/downloads/Forge-debug.apk
~/downloads/Forge-debug-rebuilt.apk
~/downloads/Forge_AI_Chat.fixeddropdown.html
~/downloads/Forge_AI_Chat.brokendropdown.html
~/downloads/Forge_Live_Translate.html   ← mini-app draft (needs host APIs; not live yet)
```

---

## Fidelity

| Layer | State |
|--------|--------|
| Selects / theme / MainActivity chrome | Match original APK behavior |
| ForgeHost `ai.chat` tools + attachments | **Fixed beyond APK** (intentional) — **kept after 2026-08-10 restore** |
| Host live-translate / stream session APIs | **Not in shipped host** (rolled back) |
| Capacitor config / termux-agent assets | From APK |
| Native Java bridges | JADX restore; MicBridge **also** has PCM stream methods (unused by host UI) |
| `Forge-debug.apk` | Untouched user binary |

---

## Locked AI host behavior (`ForgeHost.ai.chat`)

**Works as of this lock:**

1. **`tools` / `tool_choice`** forwarded (OpenAI-compatible); response includes **`tool_calls`**
2. Message roles preserved: `assistant.tool_calls`, `role:'tool'` (+ `name` for Gemini)
3. **`attachments` / multimodal parts** normalized (images → `image_url`; files → rich/Gemini path)
4. Gemini: `functionDeclarations` + `functionCall` / `functionResponse`
5. No Responses-API fallback on tool-calling turns

**Mini-app contract:**

```js
const r = await ForgeHost.ai.chat({
  messages,
  tools: [ { type:'function', function:{ name, description, parameters } } ],
  attachments: [ { type:'image', dataUrl, mime } ],  // first turn
  providerId, // optional
});
// r.content, r.tool_calls[]
// execute tools → push { role:'tool', tool_call_id, name, content } → ai.chat again
```

**Sample fix:** old AI Chat built `attachments` but never sent them; tools could not bind because host ignored `tools`. Fixed samples on disk; **re-import mini-app on device** if still on old HTML.

---

## Live streaming translation (WIP — do not treat as shipped)

### Goal
Mic stays open → audio to AI backend continuously → translated text streams back (near real-time).

### What landed / what didn’t (2026-08-10)

| Piece | State | Notes |
|--------|--------|--------|
| **Plan** | Written in chat | Chunked STT windows + stream translate; optional Realtime later |
| **Native `MicBridge`** | **In tree** | `startStream` / `stopStream` / `isStreaming`; events `micPcm`, `micStreamStop`, `micStreamError` |
| **Host `ai.liveTranslate.*` + `mic.startStream` + SSE** | **Rolled back** | Large inject into `www/index.html` **broke Forge host UI**; restored baseline |
| **Host backup** | Keep | `www/index.html.with-live-backup` (reference only — **do not copy to assets/ship**) |
| **Mini-app draft** | On disk | `~/downloads/Forge_Live_Translate.html` expects host events/APIs that are **not** in current host |
| **Shipped APK host** | Restored | No `liveTranslate` / `startStream` in ForgeHost bridge |

### Intended architecture (when re-landing)

```
MicBridge PCM chunks → host live session → STT windows → stream chat translate → host-event → mini-app UI
```

Proposed host API (not live yet):

```js
await ForgeHost.ai.liveTranslate.start({ sourceLang:'auto', targetLang:'en', speak:false })
// events: live.partialSource | finalSource | partialTarget | finalTarget | level | status | error
await ForgeHost.ai.liveTranslate.stop()
// also: mic.startStream / stopStream, ai.transcribe
```

### Re-land rules (mandatory)

1. **Confirm host UI healthy** after install of restored APK before any new host edits  
2. Land in **small patches**: (a) mic stream host wire + events only → rebuild/test UI (b) `ai.transcribe` (c) `liveTranslate` session (d) mini-app  
3. **Never** drop a 500+ line block into `index.html` without a syntax + cold-start check  
4. Keep `www/index.html` and `android/.../assets/public/index.html` **identical** before `build_forge.sh`  
5. Preserve **AI tools/attachments** and **select/theme** baseline while adding features  
6. Prefer optional feature flags / late init so boot cannot TDZ-crash on new `const`s  
7. Needs STT-capable provider (OpenAI / Groq Whisper / xAI `/stt`) — not chat-only Gemini  

### Requires

- Rebuild + `adb install -r` of restored APK if device still on broken build  
- User OK before deleting `index.html.with-live-backup` or any folder  

---

## Failed experiments (DO NOT REPEAT)

| Attempt | Result |
|---------|--------|
| Select CSS hacks / `FORGE_SELECT_FIX` inject | Broke menus (JS parse) and/or still bad native pickers |
| `WebSettings.FORCE_DARK_*` | Washed already-dark UI |
| Always-dark AppTheme + ForgeAlertDialog | Still bad select lists |
| Custom HTML `<select>` | Not in original; not required once selects reverted |
| Revert selects to APK plain `<select>` | **SUCCESS** — keep |
| **Bulk live-translate host pipeline in `index.html` (2026-08-10)** | **Broke Forge host UI** — rolled back; keep native stream only; re-land incrementally |

**Rule:** UI/select regressions → restore APK select/theme/MainActivity behavior. AI regressions → keep tools/attachments host fix; do not delete it while “reverting UI.”  
**Rule:** New host features → incremental land + rebuild/verify; don’t ship from `*.with-live-backup` until verified.

---

## Open follow-ups

1. **Install restored APK** and confirm host UI (tabs, AI settings, library, preview)  
2. User retest AI tools + attachments (re-import AI Chat sample if needed)  
3. Optional bridge smoke tests (phone, camera, QR, termux, AA share)  
4. **Re-land live translate** per “Re-land rules” above  
5. Optional JADX polish / full `cap sync` scaffold — not required for lock  

---

## Checklists

### Selects / menus break
```text
[ ] No folder deletes
[ ] No FORGE_SELECT_FIX / appearance:none select hacks
[ ] MainActivity has no FORCE_DARK / configureWebViewChrome
[ ] styles.xml = Light.DarkActionBar + DayNight.NoActionBar (+ splash)
[ ] Keep AI tools/attachments code when restoring UI
[ ] www/index.html == android/.../assets/public/index.html
[ ] bash ~/downloads/build_forge.sh && adb install -r ~/downloads/Forge-debug-rebuilt.apk
[ ] Compare with original Forge-debug.apk if project drift suspected
```

### AI tools / attachments break
```text
[ ] Host ai.chat returns tool_calls when tools[] passed
[ ] role tool / assistant.tool_calls not coerced to user
[ ] Mini-app actually passes attachments: to ai.chat (not only local preview)
[ ] Re-import Forge_AI_Chat fixed sample if device HTML is stale
[ ] Provider must support tools (or host returns text-only after rejected tools)
```

### Host UI broken after a feature land
```text
[ ] Do NOT delete folders
[ ] Restore www/index.html from last known good (or strip WIP); keep AI tools/attachments
[ ] Remove WIP from assets/public/index.html too
[ ] bash ~/downloads/build_forge.sh && adb install -r ~/downloads/Forge-debug-rebuilt.apk
[ ] Confirm tabs/settings/library before retrying feature
[ ] Next attempt: smaller patch, rebuild after each step
```

### Live translate (when re-landing)
```text
[ ] Host UI confirmed good on device
[ ] Patch 1: mic.startStream host + mic.pcm events only → rebuild/test
[ ] Patch 2: ai.transcribe → rebuild/test
[ ] Patch 3: ai.liveTranslate session + events → rebuild/test
[ ] Patch 4: import Forge_Live_Translate.html
[ ] Provider has STT (OpenAI/Groq/xAI)
[ ] Never ship index.html.with-live-backup without diff review
```

## Audio output routing (2026-08-11)

Shipped in host **2.6.2 / versionCode 34**:

- Native `AudioRouteBridge` + `AudioRouteHelper`
- ForgeHost: `audio.getRoute/setRoute/clearRoute/listOutputs/play/stop`
- `tts.speak` + `ai.tts` accept `route` / `output`
- Routes: `auto|default|speaker|earpiece|wired|bluetooth|communication`
- Permissions: `MODIFY_AUDIO_SETTINGS`, `BLUETOOTH` (≤30), `BLUETOOTH_CONNECT`
- Best-effort; API 31+ communication device. No AEC yet.

Smoke:
```js
await ForgeHost.audio.setRoute('speaker')
await ForgeHost.tts.speak('hello speaker', { route:'speaker' })
await ForgeHost.audio.clearRoute()
```

