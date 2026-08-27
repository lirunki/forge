# Forge (phone) session log — LOCKED

## ⛔ INVARIANT
**Never delete folders without explicit user permission.** See [`INVARIANTS.md`](INVARIANTS.md).

## 🔧 BUILD & RELEASE RUNBOOK — READ FIRST
For any build, release, install, version bump, push, or i18n regen, see
[`BUILD.md`](BUILD.md) (committed in the repo + on GitHub; survives device reset).
Don't rediscover the tooling limits / script paths / keystore cert each session —
it's all there.

---

## Status (LOCKED baseline 2026-08-07 · host restored 2026-08-10 · refreshed 2026-08-19 @ 2.6.72/102 — session closed)

| Field | Value |
|--------|--------|
| Package | `com.forge.live` |
| Version | **2.7.38 / versionCode 168** (agentic Reforge + session-persistent workspace + agenticLoop in Drive backup; prior 2.7.36/166 idempotent Termux agent, 2.7.34/164 web_fetch readability, 2.7.32/162 remote turnkey config, 2.7.30/160 Stop confirm+abandon, 2.7.28/158 fs_edit, 2.7.8/138 agentic builder loop, 2.7.0/130 reasoning separation, 2.6.72/102 insets fix)
| **Original APK (preserved, untouched)** | `~/downloads/Forge-debug.apk` |
| **Canonical Gradle APK** | **`~/downloads/Forge-debug-rebuilt.apk`** |
| Also | `/sdcard/Download/Forge-debug-rebuilt.apk` |
| Source | Reconstructed from APK (JADX + assets + Capacitor 6) |
| Build | `bash ~/downloads/build_forge.sh` → `assembleDebug` |
| Install | `adb install -r ~/downloads/Forge-debug-rebuilt.apk` |
| **Host `www/index.html`** | Canonical host (+ AI tools/attachments + liveTranslate + **Drive backup**) — keep in sync with assets |
| **Last rebuild** | **2026-08-26 — 2.7.38/168 agentic Reforge + session workspace + agenticLoop backup** (pre-commit sha `61ef99e`; rebuild after commit re-stamps) · 2026-08-26 — 2.7.36/166 idempotent Termux agent (`61ef99e`) · 2.7.34/164 web_fetch readability (`21207ca`) · 2.7.32/162 remote turnkey config (`b090660`)
| **Release artifacts** | `release-out/Forge-full-release.apk` + `Forge-play-release.aab` (also `/sdcard/Download/`) · GPL-3.0 · upload-key signed

### Locked product baseline

| Area | Locked state | Do not regress |
|------|----------------|----------------|
| **Selects / menus / theme** | Original APK behavior | No `FORGE_SELECT_FIX`, no `appearance:none` select hacks, no `FORCE_DARK`, no custom HTML dropdown, no always-dark AppTheme experiment |
| **`MainActivity.java`** | Original JADX (plugins + intent forward + keepWebViewAlive only) | No `configureWebViewChrome` / `AppCompatDelegate` night force |
| **`styles.xml` / `colors.xml`** | APK-shaped themes (`Light.DarkActionBar` + `DayNight.NoActionBar` + splash) | No `ForgeAlertDialog` overlay theme |
| **`index.html` (shell + ForgeHost)** | APK UI/selects **+** AI tools/attachments host fix | Do not wipe AI fix when touching UI; do not reintroduce select “fixes”; **do not bulk-inject large WIP features into host without isolated landing** |
| **AI Chat samples** | `~/downloads/Forge_AI_Chat.*.html` pass `attachments` + correct tool bind | Re-import on device if old mini-app HTML still installed |
| **Menu Translator sample** | `~/downloads/Menu_Translator.html` + prompt `Forge_Prompt_Menu_Translator.md` | Camera thumbs via setImg/fallback; AI attachments never blob:; re-import if device HTML stale |
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
~/downloads/Menu_Translator.html        ← menu vision mini-app (camera/gallery fixed 2026-08-14)
~/downloads/Forge_Prompt_Menu_Translator.md  ← Forge-it prompt (fresh generate)
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

## Mic PCM stream host wire (2026-08-11)

Shipped in host **2.6.3 / versionCode 35** (Patch 1 of live-translate re-land):

- `ForgeHost.mic.startStream / stopStream / isStreaming`
- Events to mini-app: `mic.pcm`, `mic.streamStop`, `mic.streamError`
- Native `MicBridge` listeners forwarded via `postToMiniApp`
- Auto `stopStream` on exit app mode / preview reload
- Caps: `micStream`, `micPcm`
- **Not included:** `ai.transcribe`, `ai.liveTranslate`, STT windows

Smoke:
```js
await ForgeHost.permissions.request('mic')
ForgeHost.on('mic.pcm', d => console.log(d.seq, d.rms, d.bytes))
await ForgeHost.mic.startStream({ sampleRate:16000, chunkMs:250 })
// ... speak ...
await ForgeHost.mic.stopStream()
```

Next: Patch 2 `ai.transcribe`.

## ai.transcribe (2026-08-11)

Shipped in host **2.6.4 / versionCode 36** (Patch 2 of live-translate re-land):

- `ForgeHost.ai.transcribe` / `ai.stt`
- Accepts dataUrl/base64; raw `pcm_s16le` auto-wrapped as WAV
- language/lang + model; providerId via withAiRuntime
- Rejects Gemini with clear error
- Uses existing Whisper / xAI `/stt` path

```js
const wav = await ForgeHost.mic.record({ durationMs:2000 })
const { text } = await ForgeHost.ai.transcribe({ dataUrl: wav.dataUrl, language:'en' })
```

Next: Patch 3 `ai.liveTranslate` session.

## ai.liveTranslate (2026-08-11)

Shipped in host **2.6.5 / versionCode 37** (Patch 3):

- `ForgeHost.ai.liveTranslate.start/stop/status/configure`
- Events: `live.status|level|partialSource|finalSource|partialTarget|finalTarget|error`
- Pipeline: mic PCM → windowed STT → chat translate → optional TTS (`route` supported)
- Auto-stop on app exit/reload
- One-direction A→B only

Next: Patch 4 conversation mini-app / bidirectional UX.

## Library backup — Google Drive / folder (2026-08-12)

Shipped in host **2.6.6 / versionCode 38**:

- Native `DriveBridge` (Storage Access Framework — **not** OAuth Drive API)
- User picks a folder (Google Drive in the system picker works); Forge uses `ForgeLibrary/` inside it
- Host: Settings → **Library backup** (Choose folder / Backup / Restore / Disconnect)
- Library tab: **Backup** / **Restore**
- Layout: `manifest.json` + `apps/<id>/{meta.json,app.html}`
- Merge restore by `app.id` + `updatedAt` / content hash; local tombstones on delete sync to remote on backup
- **Also** backs up AI settings: providers, custom OAI endpoints, API key vault (`settings.json`)
- **Private folder** — keys are included; do not share the backup folder
- **no** Drive share-links for apps (use Export → WhatsApp)
- Dep: `androidx.documentfile:documentfile:1.0.1`

Smoke:
```text
[ ] Settings → Choose folder → pick Google Drive / ForgeBackup
[ ] Library has ≥1 app → Backup → see ForgeLibrary/manifest.json in Drive
[ ] Clear app data or second device → same folder → Restore → apps return
[ ] Delete app locally → Backup → Restore on other device drops it
[ ] Export still shares .html via WhatsApp
```


## Kitchen sink HTML lab (2026-08-12)

Shipped in host **2.6.7 / versionCode 39**:

- Library button **Kitchen sink** installs/replaces `app_kitchensink`
- Full ForgeHost lab tabs: Home/Perms/State/AI/Media/Device/Apps/Notify
- Covers AI chat/TTS/STT/liveTranslate, mic WAV+PCM, camera/QR, audio routes,
  phone/SMS/contacts/location, apps/intents, share/clipboard/files/http,
  notify/jobs, termux, fs, state/storage/secrets, keepAwake
- Positioning: Forge = kitchen sink runtime for arbitrary HTML mini-apps
- Import any `.html` or Forge-it with AI; Demo lab documents the surface

Smoke:
```text
[ ] Library → Kitchen sink → opens lab
[ ] Home shows capability chips
[ ] AI chat ping / Media record / Share text work on device
```


## Open with / Share HTML (2026-08-12)

Shipped in host **2.6.8 / versionCode 40**:

- Android intent-filters on MainActivity: VIEW text/html + .html pathPattern, SEND/SEND_MULTIPLE
- Label: **Open in Forge**
- Native `OpenHtmlBridge` captures WhatsApp/Files/Drive shares and cold-start VIEW intents
- Host `wireOpenHtmlBridge` / `consumeOpenHtmlIntent` → import to library and open immersive

Smoke:
```text
[ ] Export a mini-app → WhatsApp to yourself → Open with / Share → Forge appears
[ ] Forge imports HTML into Library and runs it
[ ] Files app → open .html → Forge in list
```

Note: earlier “kitchen sink” work = API lab demo only; this is the real open-with feature.

## Kitchen sink camera preview (2026-08-12)

Shipped in host **2.6.9 / versionCode 41**:

**Bug:** Media → Camera photo captured OK but image did not appear in the lab.

**Causes addressed:**
1. Long `data:` URLs often fail to paint on `<img>` inside sandboxed `srcdoc` WebViews
2. Host posted **both** `base64` + `dataUrl` (2× payload) to the iframe via `postMessage`
3. Gallery path logged the full shot (multi‑MB base64) into the fixed log panel

**Fix:**
- Kitchen sink displays via **blob: Object URL** from base64 (fallback dataUrl)
- Host slims large media results (single copy); mini-app bridge rehydrates `dataUrl` ↔ `base64`
- Lab uses `maxWidth: 1280`; never dumps full base64 into the log
- Camera encode includes `mime: image/jpeg`

**Device:** after install, Library → **Kitchen sink** again (reinstalls lab HTML), then Media → Camera photo.

Smoke:
```text
[ ] Kitchen sink → Media → Camera photo → image appears above log
[ ] Log shows w/h/bytes/via:blob (not a multi‑MB base64 dump)
[ ] Gallery pick also previews
```

## takePhoto reliability (2026-08-12)

Shipped in host **2.6.10 / versionCode 42**:

**Bug:** `camera.takePhoto` often “succeeded” with meta (`w/h/bytes`) but kitchen sink logged
`img failed to decode` (e.g. `bytes≈8KB`, `via:blob`). Common on Samsung Fold.

**Causes addressed:**
1. Camera app not granted FileProvider URI write → empty/partial JPEG at EXTRA_OUTPUT
2. RESULT_OK before file fully flushed; tiny non-JPEG files still encoded
3. RESULT_CANCELED even when file was written (OEM quirk)
4. Kitchen sink used blob only — no `onerror` fallback to `dataUrl`
5. No JPEG magic validation on capture file or re-encoded output

**Fix (native `CameraBridgePlugin`):**
- `createNewFile()` before launch; grant URI to all IMAGE_CAPTURE handlers
- Wait/retry (~1s) for file ≥2KB + JPEG SOI (`FF D8`)
- Accept written file even if result code cancelled
- Re-encode clean baseline JPEG; reject invalid compress output
- Clearer reject: `No image returned… (fileBytes=…, attempts=…)`

**Fix (kitchen sink + ForgeCam.html):**
- Display chain: blob → dataUrl → forced `image/jpeg` dataUrl on `img.onerror`
- Log `b64Prefix` (`/9j/` = JPEG) for diagnosis

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk
[ ] Library → Kitchen sink (reinstall lab) → Media → Camera photo ×5
[ ] Image paints; log shows shown:true and b64Prefix /9j/
[ ] bytes typically >> 20KB for real photos (not ~8KB garbage)
[ ] Cancel camera → clean "Camera cancelled" (or still OK if OEM wrote file)
```

## Drive backup includes AI settings (2026-08-13)

Shipped in host **2.6.11 / versionCode 43**:

Backup / Restore now also writes/reads `ForgeLibrary/settings.json`:
- active provider + remember-key flag
- per-provider profiles (models, bases, **API keys**)
- custom OpenAI-compatible providers
- known-key vault
- easy-setup flags

Merge restore overlays remote onto local (keeps local keys if remote empty).
`mode: 'drive'` (if used) prefers remote wholesale for settings.

Smoke:
```text
[ ] Configure provider + API key → Backup
[ ] Clear app data / other device → same folder → Restore
[ ] Settings show same provider; Test connection works
[ ] Library apps still restore
```

## CameraX in-process capture (2026-08-13)

Shipped in host **2.6.16 / versionCode 48**:

**Native:** `CameraXCaptureActivity` + CameraX Preview/ImageCapture (no OEM `ACTION_IMAGE_CAPTURE`).
- `CameraBridge.takePhoto` → in-app shutter UI → JPEG under app `Pictures/ForgeCam/camerax_*.jpg`
- Encode/scale/EXIF in plugin; result still `{base64,dataUrl,mime,width,height,bytes,…}`
- `cleanupTempPhotos` on mini-app exit
- `pickPhoto` unchanged (system gallery)

**Host (injected bridge — mini-apps stay thin):**
- Default `quality:85`, `maxWidth:1280` (cap 2048)
- 180s timeout for `camera.*`
- `__forgeNormalizeMediaResult` → always `base64` + real `dataUrl` + `previewUrl`/`blobUrl`
- Transparent `img.src = large data:image…` → blob rewrite
- Optional `ForgeHost.camera.setImg(img, shot)` / `.normalize(shot)`
- Back-compat: same method names and core result fields

## Library AAForge readiness light (2026-08-13)

Shipped in host **2.6.23 / versionCode 55**, refined **2.6.24 / 56**:

Library 🚗 button is **green** or **red** from stored `aaScan` / `carCompatible`.

**Green** = no hard phone-only APIs (AAForge reduced host can call everything used).  
**Red** = uses camera / qr / files / termux / liveTranslate / mic stream / audio route / etc.

Also parses `<!-- aaforge-car: {…} -->` for a richer tooltip when present.  
Does **not** invent a fake car contract.

**HTML scan runs only on Drive/folder Restore** (not library load / import / save / share):
- Sets `app.carCompatible` + `app.aaScan` (content-hash cached)
- If green and missing boolean marker, injects `<!-- carCompatible: true -->`

### Delete → tombstones (unchanged product path)

Library 🗑️ uses simple confirm; always `addDriveTombstone(id)` so the next **Backup** purges `apps/<id>/` from the folder. No per-delete backup checkbox.

Smoke:
```text
[ ] Restore backup → apps get aaScan; 🚗 green/red updates
[ ] Open Library without restore → no rescan / no HTML rewrite
[ ] Delete app → local gone + tombstone; next Backup drops remote copy
```

## Fix AI tab buttons dead after App-bar trim (2026-08-14)

Shipped in host **2.6.26 / versionCode 58**:

**Bug:** App tab chrome was reduced to Reload/Save only (2.6.22), but boot still did
`el.btnHome.addEventListener(...)` / `el.btnExport.addEventListener(...)` without `?.`.
Those nodes are gone → throw mid-wiring → **all later listeners never attached**, including
AI settings (Test, Forget key, Add provider, Drive, Termux, Easy setup, …).

**Fix:** optional-chain App/Library/AI control wiring; null-safe provider/status helpers.

Smoke:
```text
[ ] AI tab → Easy setup / Save & test / Test connection / Add OpenAI provider respond
[ ] Library Import / Refresh still work
[ ] App tab Reload + Save still work
```

## Reforge mode picker (2026-08-14)

Shipped in host **2.6.27 / versionCode 59**:

Library ⚒️ **Reforge** opens a sheet before calling the model:
- **Standard** — full Forge phone UI (default if app is not AA)
- **AA-compat** — injects the same CAR-COMPATIBLE contract rules as Chat 🚗 (default if app is AA / `aaScan.ready` / `carCompatible`)
- **Cancel** — abort, no API call

Result `carCompatible` follows the chosen mode (not the global header 🚗 toggle).

Smoke:
```text
[ ] Reforge non-AA app → sheet defaults Standard → Cancel leaves library unchanged
[ ] Choose AA-compat → preview carCompatible; HTML aims for aaforge-car
[ ] Reforge AA app → defaults AA-compat; can switch to Standard
```

## Camera takePhoto “i is not defined” (2026-08-14)

Shipped in host **2.6.28 / versionCode 60**:

Mini-apps (e.g. Forge AI Chat) surface `Camera error: i is not defined` when the
post-capture media normalize path throws while building a blob preview from base64.

**Host fix (all mini-apps):**
- `b64ToBlobUrl` uses a `while` loop (no `i` binding) + full try/catch
- `camera.takePhoto` / `pickPhoto` wrappers never reject on normalize failure — return raw shot
- host-result normalize already non-fatal; kept defensive

Smoke:
```text
[ ] Kitchen Sink Media → Take Photo → image shows, no Camera error
[ ] Forge AI Chat / ForgeCam → Take Photo attaches/previews
[ ] Cancel camera still cancels cleanly
```

## Mini-app console in AI settings (2026-08-14)

Shipped in host **2.6.31 / versionCode 63** (console; clean re-land after 2.6.29 UI break):

**AI tab → Mini-app console** card:
- **Show console** — sheet with live log (newest at bottom)
- **Clear** / **Copy** (inline on card + inside sheet)
- Unread badge on Show console

**Capture sources:**
1. Mini-app bridge wraps `console.log|info|warn|error|debug` → `postMessage` `host-console`
2. `window.onerror` + `unhandledrejection` in mini-app iframe
3. Failed `ForgeHost` / host-call errors (method + message)
4. Markers on preview load + mini-app `host-ready`

Ring buffer 500 lines; lines capped ~8KB (avoids base64 dumps). Host `www/index.html` ≡ assets.

Smoke:
```text
[ ] bash ~/downloads/build_forge.sh && adb install -r ~/downloads/Forge-debug-rebuilt.apk
[ ] Run a mini-app that console.log / throws → AI tab → Show console sees lines
[ ] Copy puts plain text on clipboard; Clear empties + badge resets
[ ] Host call failure (e.g. bad AI key from mini-app) appears as error line
```

## Menu Translator mini-app — camera/gallery + vision attach (2026-08-14)

**Mini-app only** (host was **2.6.28 / 60** at fix; console is separate host bump). Locked samples:

| File | Role |
|------|------|
| `~/downloads/Menu_Translator.html` | Fixed mini-app |
| `~/downloads/Forge_Prompt_Menu_Translator.md` | Fresh **Forge it** prompt (phone mode, not AA) |

**Bugs in prior HTML:**
1. Thumbs via `innerHTML` + single `previewUrl \|\| dataUrl` — blank in srcdoc; no `setImg` / onerror chain
2. AI `attachments` used `rawDataUrl \|\| dataUrl` without rebuilding from `base64` (host may slim to base64-only) and could pass weak vision input
3. Remove × was `opacity-0 group-hover` — invisible on touch
4. No empty-payload reject after capture

**Fix (mini-app contract — match AI Chat / ForgeCam / host docs):**
- `normalizeMedia` + optional `ForgeHost.camera.normalize`
- `setImgWithFallback`: host `setImg` → preview/blob/dataUrl → blob-from-base64 → dataUrl-from-base64; `createElement('img')` + `.src` (never huge data: in innerHTML attrs)
- `toAiImagePart`: real `data:` and/or `base64` only — **never `blob:`**
- Always-visible remove ×; toast on empty capture; revoke object URLs on Clear All
- Translate: filter attachments with bytes; `result.content \|\| result.text`

**Not a host regression:** camera take/pick APIs were fine; display + attach packaging were wrong.

Smoke:
```text
[ ] Re-import Menu_Translator.html into Library (replace stale device copy)
[ ] Take Photo → thumbnail paints; toast size; × removes on tap
[ ] From Gallery → same
[ ] Translate Menu (vision provider) → item cards; tap → original + Sound it
[ ] Copy / Share / Clear All
[ ] Optional: paste Forge_Prompt_Menu_Translator.md fenced block → Forge it → same behavior
```

## Host UI restore — roll back mini-app console (2026-08-14)

**2.6.40 / versionCode 70** was a pure git HEAD restore after 2.6.29–2.6.31 console attempts broke shell/UI.
Confirmed good by user, then console re-landed safely in **2.6.41**.

## Mini-app console (safe re-land) (2026-08-14)

**2.6.41 / versionCode 71**

**Design rule that keeps mini-apps alive:** do **not** edit the `const bridge = \`...\`` template body.
Console capture is a **separate** `consoleHook` string concatenated after `bridge` in `wrapGeneratedHtml`.

**AI tab (top of AI settings):** Console · Clear · Copy (+ sheet with same actions)

**Captures:**
1. Mini-app `console.log|info|warn|error|debug` via postMessage `host-console`
2. Mini-app `error` + `unhandledrejection`
3. Failed host-calls (`Host method: message`)
4. Load / ready markers

**Validated before ship:** node --check; bridge backticks == 2; unique IDs; overlay hidden CSS present.
APK: `/sdcard/Download/Forge-2.6.41-console.apk`

Smoke:
```text
[ ] Tabs + mini-apps still work (regression)
[ ] AI tab → Console opens sheet
[ ] Run mini-app with console.log / throw → lines appear; badge updates
[ ] Failed ForgeHost call shows as error line
[ ] Clear / Copy work
```



## Gemini key + free-path corrections (2026-08-15)

**2.6.46 / versionCode 76**

### User reports
1. Gemini API key did not work; key **prefix ≠ AIza** (UI was too strict / misleading)
2. xAI/Grok API key fails — console requires **payment/credits** (free Grok chat ≠ free API)

### Fixes
- Built-in **`gemini`** provider (native `generateContent`, not broken `/v1beta/chat/completions`)
- `chatCompletions` + setup **Save & test** route through Gemini native API
- Key paste: accept full key any prefix; strip `API_KEY=` / quotes; no AIza requirement in copy
- Model fallbacks: `gemini-2.5-flash` → `2.0-flash` → lite → 1.5-flash on 404
- Auth: query `key=` + header `x-goog-api-key`
- Friendlier Google 400/403/429 errors
- Stop mis-detecting long keys as Azure
- **xAI removed from free turn-key** (badge paid); turn-key = Gemini + Groq + OpenRouter free
- Default provider → `gemini`

Smoke:
```text
[x] Turn-key → Gemini → paste full AI Studio key (any prefix) → Save & test OK (user verified)
[ ] Turn-key → Groq → gsk_ key works
[ ] xAI not shown on free turn-key cards; all-providers lists it as paid
[ ] Forge it with Gemini produces an app
```

## Turn-key free AI setup (2026-08-15)

**2.6.45 / versionCode 75**

Lower-complexity onboarding for non-technical users. Provider selection was the main wall.

### What changed
- First-run / AI tab wizard leads with **Turn-key setup (free AI)** — plain language, no CS jargon
- **Recommended path: Google Gemini** (free AI Studio key via Google account already on Android)
- Also turn-key: **xAI Grok** (free account + small API quota) and **Groq** (fast free tier)
- One-tap cards open a guided key page (open site → copy key → paste → Save & test)
- Full provider list moved behind **Browse all providers** / **More options**
- Default first-run pick: `gemini` (was `groq`)

### Not changed
- Advanced provider/model/endpoint controls stay collapsed under AI settings
- Quick paste key still auto-detects provider from key shape
- Paid OpenAI remains available but not pushed on the turn-key screen

Smoke:
```text
[ ] Fresh install / clear setup flag → wizard offers Turn-key setup
[ ] Pick Google Gemini → Open AI Studio → paste AIza key → Save & test → Done
[ ] Pick xAI Grok / Groq same flow
[ ] AI tab → Turn-key setup (free AI) reopens wizard
[ ] Browse all providers still lists OpenRouter/HF/local/OpenAI
[ ] Existing keys / advanced settings still work
```

## Homescreen shortcut: takePhoto loses result (2026-08-15)

**2.6.44 / versionCode 74**

**Bug:** Library → open mini-app → Take photo OK. Same app via **Home shortcut** → photo does not
attach; console shows repeated `— loaded … —` (including right after capture). No JS error.

**Cause:** Shortcut opens `RunActivity` with `forge://app/<id>`. `ShortcutBridge.captureLaunchIntent`
cleared extras but **left intent data**. `extractAppId` still reads the URI, so every `onStart`
(return from CameraX) re-emits `appLaunch` → host `openAppById` → `loadPreview` wipes srcdoc and
in-flight `camera.takePhoto` promise/state. Cold start also multi-fired (pending + retained listener).

**Fix:**
1. Native: after capture, `setData(null)` + `ACTION_MAIN` so resume cannot re-extract app id
2. Host: `openAppById` idempotent — same live app does not `loadPreview` again (2.5s dedupe)

Smoke:
```text
[ ] Install 2.6.44 → Home shortcut → Forge Chat → Take photo → thumb in attachment bar
[ ] Console: one loaded/ready pair at open; **no** reload after camera
[ ] Library open path still works; pin shortcut still opens runner
```

## Bridge media normalize `i is not defined` (2026-08-15)

**2.6.43 / versionCode 73**

**Bug:** Mini-app console WARN `[ForgeHost] media normalize failed ReferenceError: i is not defined`
at `__forgeNormalizeMediaResult` after `camera.takePhoto` (Forge Chat and any vision app).
Photo still often worked because `safeNormalizeMedia` swallowed the error and returned raw shot.

**Cause:** Mini-app bridge is built from a JS **template literal**. Escapes inside it are cooked:
- `/^image\//i` → `/^image//i` → parsed as `(/^image/) / i.test(mime)` → **`i is not defined`**
- `/\s+/g` → `/s+/g` (whitespace strip broken)
- `ai\.` → `ai.` (dot matches any char)

**Fix:** `const bridge = String.raw\`...\` + '</scr' + 'ipt>'` so regex backslashes reach srcdoc intact.
Do **not** put `</script>` raw inside host `index.html` script (breaks HTML parse).

Smoke:
```text
[ ] bash ~/downloads/build_forge.sh && adb install -r ~/downloads/Forge-debug-rebuilt.apk
[ ] Open Forge Chat → Take photo → no `i is not defined` in Mini-app console
[ ] Thumbnail / attach still works; Translate/vision path OK
```

## Contacts find + radio controls (2026-08-14)

**2.6.42 / versionCode 72**

### Mini-app APIs
- `ForgeHost.contacts.list({ query, limit, regex, flags })`
- `ForgeHost.contacts.find({ regex, flags, query, limit, scanLimit })` (alias `search`)
- `ForgeHost.radio.getStatus()` → `{ wifi, bluetooth, gps, hotspot, ... }`
- `ForgeHost.radio.set({ wifi?, bluetooth?, gps?, hotspot? })` → may set `needsUser` and open Settings
- `ForgeHost.radio.openSettings({ which: 'wifi'|'bluetooth'|'gps'|'hotspot'|'wireless' })`

### LLM tools (Forge_Chat.html)
`list_contacts`, `find_contact`, `radio_status`, `radio_set`, `radio_open_settings`

### Notes
- GPS/hotspot almost always need system UI (Android restriction).
- Wi-Fi/BT direct toggle best-effort; falls back to panel.
- Re-import Forge_Chat.html after host install.


## SMS read permission auto-request (2026-08-15)

**2.6.47 / versionCode 77**

**Bug:** Mini-apps that call `ForgeHost.sms.read` (conversation copy, etc.) fail with
`READ_SMS permission not granted` / failed permissions — often because they never call
`permissions.request('sms')`, or the user denied once and gets no second dialog.

**Fix:**
1. Native `PhoneBridge.readSms` / `sendSms` auto-`requestPermissionForAlias("sms")` then continue
2. Host `ensureSmsPermission` before `sms.read` / `sms.send` with clear Settings guidance
3. Sample: `~/downloads/Sms_Conversation_Copy.html` (+ `forge/samples/`)

**Mini-app contract (still recommended):**
```js
await ForgeHost.permissions.request('sms')
const { messages } = await ForgeHost.sms.read({ limit: 200, box: 'all', address: '555' })
await ForgeHost.clipboard.write(text)
// permanent deny:
await ForgeHost.device.openSettings()  // Permissions → SMS
```

Smoke:
```text
[ ] Install 2.6.47 → import Sms_Conversation_Copy.html
[ ] Grant SMS → Load threads → pick thread → Copy conversation
[ ] Deny once → error mentions Settings; App settings opens Forge details
[ ] After manual allow in Settings → Load works
```


## Generic LLM tools registry (2026-08-15)

**2.6.48 / versionCode 78**

Host exposes a growing tool catalog over ForgeHost bridges so chat/agents gain power as the host grows.

### API
```js
const { tools, catalog, bridgeMethods } = await ForgeHost.tools.list({ riskMax: 'confirm' })
await ForgeHost.ai.chat({ messages, tools, tool_choice: 'auto' })
// on tool_calls:
await ForgeHost.tools.run('web_search', { query: '...' })
await ForgeHost.tools.run('web_fetch', { url })
await ForgeHost.tools.run('get_location')
await ForgeHost.tools.run('sms_list', { box: 'all', limit: 30 })
await ForgeHost.tools.call('apps.list', { query: 'maps' })  // allowlisted bridge_call
const { hint } = await ForgeHost.tools.hint()
// aliases: ForgeHost.ai.tools.* , ForgeHost.web.search/fetch
```

### Included tools (initial registry)
web_search, web_fetch, get_time, device_info, clipboard_read/write, toast, open_url, notify,
get_location, open_maps, sms_list, sms_compose, sms_send, phone_dial, phone_call,
list_contacts, find_contact, list_apps, list_activities, launch_app,
radio_status/set/open_settings, tts_speak, get_capabilities, bridge_call

Risk tiers: `safe | sensitive | confirm | danger` (danger off by default in Forge Chat).

### Extend later
1. Implement ForgeHost / handleCall method  
2. Append `HOST_TOOL_REGISTRY` entry (+ `HOST_BRIDGE_ALLOW` if using bridge_call)  
3. Mini-apps using `tools.list` pick it up automatically  

### Forge Chat
Uses `ForgeHost.tools.list/run` instead of a hardcoded 8-tool list. Settings: enable tools, confirm side effects, allow dangerous.

Smoke:
```text
[ ] Install 2.6.48 → re-import Forge_Chat.html
[ ] "Search the web for …" → web_search tool runs, cites links
[ ] "Fetch this url …" → web_fetch returns text
[ ] "Where am I?" → get_location (GPS perm)
[ ] "Show recent SMS from …" → sms_list (SMS perm)
[ ] launch still confirms when setting on
```


## Reforge tool settings + tools migration (host)

**2.6.49 / versionCode 79**

Reforge sheet now includes **LLM tools** controls so chat/agent apps are rewritten onto `ForgeHost.tools`:

- Enable host tools
- Max risk: safe | sensitive | confirm | danger
- Confirm side effects
- Force migrate legacy tool lists
- Add in-app tool settings UI
- Group presets (Essential / Phone / All) + per-tool checklist
- Prefs remembered in `localStorage.forge_reforge_tools_v1`

`buildReforgeUserPrompt` / `reforgeAppWithAi` inject the live host catalog and mandate:
- `tools.list` / `run` / `hint` instead of hardcoded `APP_TOOLS`
- Settings UI for tool selection inside the mini-app
- Preserve chat UX + app-specific tools

SYSTEM_PROMPT also documents `ForgeHost.tools` for fresh **Forge it** apps.

Smoke:
```text
[ ] Library → ⚒️ Reforge on Forge Chat → sheet shows tool groups
[ ] Essential preset → Reforge → preview uses ForgeHost.tools.list/run
[ ] Settings inside app: risk + tool toggles
[ ] web_search / get_location work after re-import save
[ ] Discard reforge restores original
```

## Cheaper Inference provider + live model catalog (2026-08-16)

**2.6.50 / versionCode 80** (prior 2.6.49/79)

New wallet-backed OpenAI-compatible gateway alongside the free turn-key path.

### Provider
- **`cheaperinference`** — `https://api.cheaperinference.com/v1`, key `ir_live_…`
- One key → many models (GLM, DeepSeek, GPT, Claude…) often below list price
- **Not a free tier** — wallet-funded; auto-detected from key shape
- Default model `glm-5.2`; live catalog pulled via `/public/models`
- Added to turn-key cards + all-providers list (badge: paid/wallet)

### Live model catalog
- **Refresh models** button (`btnRefreshModels`) + `modelCatalogStatus` hint
- `forge_model_catalog_cache_v1` localStorage cache
- Quick-key hint copy updated: Gemini keys may not start with `AIza`; Cheaper Inference `ir_live_` is wallet/paid and auto-detected; xAI usually paid

### Files
- `android/app/build.gradle` (version bump), `www/index.html` + assets (+352 lines, identical)
- `session.md` status table bumped to 2.6.50/80

Smoke:
```text
[ ] AI tab → turn-key → Cheaper Inference card (paid badge)
[ ] Paste ir_live_ key → Save & test OK
[ ] Refresh models → live catalog loads (glm-5.2 + others)
[ ] Forge it / chat with glm-5.2
[ ] Free turn-key (Gemini/Groq/OpenRouter) still listed separately
```

## Improvement batch #1–#6: docs, build gate, chatStream, ai.agent, live Patch 4 (2026-08-16)

**2.6.52 / versionCode 82** (from 2.6.50/80). No native Java touched. Gate green.

Six-task improvement batch (plan given prior session, reconstructed from commit `4a3d2e7`).

### #1 — `forge_check.sh` validation gate
Pre-build gate wired as **first step** of `build_forge.sh` (`set -e` aborts on failure). Catches the recurring single-file host breakage modes (2.6.29/31/43/44):
- JS syntax (`node --check` on extracted script)
- `www/index.html` ≡ `android/.../assets/public/index.html` parity (incl. `forge-build.json`)
- bridge `String.raw\`...\`` backtick-count sanity (the 2.6.43 `i is not defined` class)
- stray raw `</script>` inside a script block
- version stamp drift between `build.gradle` and the host
Re-runs after stamping. `~/downloads/forge_check.sh`.

### #2 — `docs/api.md` + `docs/tools.md`
Filled the empty `docs/` dir with citable references extracted from the inline `SYSTEM_PROMPT` / `HOST_TOOL_REGISTRY`:
- `forge/docs/api.md` (17.7 KB) — ForgeHost bridge reference
- `forge/docs/tools.md` (6.9 KB) — LLM tool catalog

### #3 — `forge_bump.py` + build stamp + About Forge
- `~/downloads/forge_bump.py`: `versionCode +2` / `versionName patch +2`; wired to `build_forge.sh --bump`
- `forge-build.json` `{version, versionCode, sha, builtAt}` written into **both** `www/` and `assets/` on every build
- `window.__FORGE_BUILD` populated at runtime from Capacitor `App.getInfo()` + `forge-build.json`
- Surfaced in **Settings → About Forge** (version · code · sha)

### #4 — Live Translate Patch 4: bidirectional conversation mode
- State: `mode / langA / langB / autoDetect / currentDirection / paused`
- `liveDetectScript()` + `liveAutoDetectDirection()`: Unicode-script heuristic (latn/cyrl/arab/hebr/hani/hira/kana/hang/deva/thai/grek) → maps to langA/langB; auto-flips on recent speech tail
- `liveChatTranslate()` derives source/target from `currentDirection`
- `liveTranslateSegment()` auto-detects + emits `live.flip`
- `liveProcessWindow()` / `onLiveMicPcm()` skip when `paused` (mic stays warm)
- New actions: `flip()`, `pause()`, `resume()`
- New events: `live.flip | live.pause | live.resume`
- Bridge: `ForgeHost.ai.liveTranslate.flip / pause / resume`
- `~/downloads/Forge_Live_Translate.html` rewritten: One-way/Conversation toggle, langA/langB selects, Flip, Auto-detect checkbox, Pause/Resume, direction badges. JS syntax validated standalone.

### #5 — `ForgeHost.ai.chatStream` (token streaming)
- OAI SSE + Gemini `streamGenerateContent?alt=sse`
- `chatCompletionsStream()` + `geminiStreamGenerateContent()` with `ReadableStream` reader
- tool_call accumulation across deltas
- `response_format` / tools retry fallback
- CapacitorHttp non-stream fallback on CORS/offline
- Emits `ai.stream.delta { callId, delta, done, tool_calls? }`; `onToken/onDelta/onToolCall` stripped before `postMessage`
- `ai.chatStream` host handler mirrors `ai.chat` (rich attachments, provider/model override, tools, fullResponse)

### #6 — `ForgeHost.ai.agent` (centralized chat + tool-call loop)
- Auto-loads tools via `tools.list` if omitted; `maxRounds` 1–12; `systemHint` injection
- Streams tokens via `chatStream` when `onToken` provided
- Host-level risk sheet: `agentConfirmTool()` modal (Deny / Allow / Always) for `confirm`/`danger` tools, persisted per-app in `localStorage`; 60 s auto-deny; `safe`/`sensitive` auto-allow
- Events: `ai.agent.event { type: round | chat | token | toolCall | toolResult | toolDenied | maxrounds | error }`
- Returns `{ content, rounds, tools[], provider, model, backend, riskMax }`

### Gaps closed in this edit pass
- **session.md backfill**: 2.6.50 + 2.6.52 sections were missing from the log (only in the git commit message) — appended above.
- **stale build-stamp sha**: `forge-build.json` reported `sha: 9616460` (parent) because the last build ran before commit `4a3d2e7`. Rebuild re-stamps with the current HEAD sha so **About Forge** shows the right commit.

Smoke (batch):
```text
[ ] bash ~/downloads/build_forge.sh && adb install -r ~/downloads/Forge-debug-rebuilt.apk
[ ] Settings → About Forge shows v2.6.52 (82) · 4a3d2e7
[ ] forge_check.sh aborts a deliberately broken host (parity/syntax/backtick)
[ ] docs/api.md + docs/tools.md present and citable
[ ] ai.chatStream streams tokens in a mini-app (OAI + Gemini)
[ ] ai.agent runs a 2-round tool loop; confirm-tool sheet appears for `confirm` tools
[ ] Live Translate → Conversation mode → Auto-detect flips direction; Pause/Resume hold mic warm
[ ] Re-import Forge_Live_Translate.html after install
```

## Improvement batch #7–#13 (minus #10): agent veto, stream cancel, mic AEC, docs gate, smoke (2026-08-16)

**2.6.54 / versionCode 84** (from 2.6.52/82). Native Java touched (`MicBridgePlugin` only — AEC/NS).

Seven-item batch from the improvement audit. #10 (web_fetch readability) **deferred** — see follow-up note below.

### #1–#5 — doc/version drift closed
- `session.md` status table: 2.6.50/80 → 2.6.54/84; rebuild date 2026-08-16
- `docs/api.md` baseline → `2.6.54/84`; `chatStream`/`agent` labels `2.6.51` → `2.6.52`
- `docs/tools.md` → `27 tools` (was stale `24 tools, 2.6.48`)
- `README.md` → current version (was `v2.6.1 (33)`)
- `package.json` `version` → `2.6.54` (was `2.6.1`)

### #6 + #9 — `ai.agent` onToolCall veto (contract made real)
The api.md contract claimed `onToolCall: ({name,args}) => true  // return false to abort a tool`;
the host did **not** honor the return value. Now it does.
- Bridge `agent()`: sets `o.__hasOnToolCall = !!onToolCall`; accepts caller `id` (cancellable).
- On `toolCallRequest` event, bridge runs the mini-app callback; `false` (or Promise→false)
  sends `ai.agent.toolCallRespond({callId, toolCallId, allow:false})`.
- Host: **gate 2** after the host risk sheet — `agentAskMiniAppToolCall()` emits the request,
  awaits the response (30s timeout → deny for safety). Denied calls push a `role:'tool'`
  row so the model can react; emits `toolDenied { source:'miniapp' }`.
- `api.md` updated to document the veto + `id` + cancel.

### #8 — stream / agent cancellation
- `ai.chatStream` accepts `opts.id` (or mints one); returns `r.id`. Host stores an
  `AbortController` keyed by stream id and passes `signal` to `chatCompletionsStream` /
  `geminiStreamGenerateContent`.
- `ai.agent` accepts `opts.id`; host stores a cancel flag checked each round + an
  `AbortController` wired into the in-flight streaming round.
- New bridge: `ForgeHost.ai.cancel(id)` → host `ai.cancel` aborts the stream controller and
  sets the agent cancel flag. Returns `{ ok, id, aborted }`.
- Agent result gains `cancelled: boolean`; emits `ai.agent.event { type:'cancelled' }`.

### #11 — mic AEC + NoiseSuppressor (native)
`MicBridgePlugin.startStream` now applies `AcousticEchoCanceler` + `NoiseSuppressor` on the
`AudioRecord` session id (both default **on**; mini-app can disable via
`mic.startStream({ aec:false, noiseSuppressor:false })`). Released in `releaseAudioRecord`.
- Fixes the live-translate TTS→mic echo noted in the 2.6.2 audio-routing section.
- `isAvailable()` reports `aec` / `noiseSuppressor` capability flags.
- Host `mic.startStream` forwards `aec`/`noiseSuppressor`; live-translate start forces both on.

### #12 — `forge_docs_check.sh` (docs drift guard)
New script asserts `docs/` mirrors the host:
- `HOST_TOOL_REGISTRY` names (line-based awk range) ≡ `docs/tools.md` tool tables
  (excludes the reserved risk-tier words `safe|sensitive|confirm|danger`).
- `tools.md` + `api.md` version baselines ≡ `build.gradle`.
- `api.md` documents `ai.chatStream/agent/cancel/transcribe` + `liveTranslate.flip/pause/resume`.
Wired as **step 8** of `forge_check.sh` (aborts build on drift). Caught the 24-vs-27 drift on
first run; now green (27 tools, 2.6.54/84).

### #13 — `forge_smoke.sh` (on-device smoke harness)
New script drives the installed app via adb: cold start, process-up, crash check via logcat,
foreground check, version stamp, + manual smoke reminders (kitchen-sink AI ping, camera,
console). Complements `forge_check.sh` (syntax/parity) with runtime checks. Non-fatal by
default; exits non-zero only on hard failure.

### Follow-up note — #10 deferred
**#10 (web_fetch JS-render / readability fallback)** is **not** in this batch. `toolsWebFetch`
still does raw HTTP get + HTML strip (`www/index.html:7918`). Many JS-rendered pages return
near-empty. Next batch: add a Mozilla-Readability-style extraction or `<article>`/`<main>`
selector before stripping. Track here when landing.

### Build note — String.raw backtick lesson
The `chatStream`/`agent`/`cancel` bridge methods live **inside** the `const bridge = String.raw\`...\``
mini-app bridge template (`www/index.html:4810..5681`). Raw backticks cannot appear inside that
template — they close it early (the 2.6.43 class of bug, in a new guise). First attempt added
backtick-quoted words in `//` comments inside those methods and broke the host. `forge_check.sh`
step 4 (backtick sanity) caught it. Fix: no backticks in any string/comment inside the template.

Smoke:
```text
[ ] bash ~/downloads/build_forge.sh --bump && adb install -r ~/downloads/Forge-debug-rebuilt.apk
[ ] Settings → About Forge shows v2.6.54 (84) · 528b822
[ ] forge_check.sh + forge_docs_check.sh PASS; forge_smoke.sh cold-start ok
[ ] ai.chatStream({ id:'x', onToken }) → ai.cancel('x') stops mid-stream
[ ] ai.agent({ id:'a', onToolCall:({name})=>name==='sms_send'?false:true }) vetoes sms_send
[ ] ai.agent({ id:'a' }) → ai.cancel('a') stops after current round
[ ] mic.startStream() → result.aec === true; live-translate TTS no longer echoes back
[ ] mic.startStream({ aec:false }) → result.aec === false
[ ] Docs: tools.md lists 27 tools; api.md version says 2.6.54/84
```

## Forge progress story (rotating mumbo-jumbo) (2026-08-16)

**2.6.56 / versionCode 86** (from 2.6.54/84). Host-only, no native.

The chat dialog felt silent while the LLM was forging. Added a transient rotating
progress line: while `forgeApp` is awaiting the LLM, a slim gray assistant-side
bubble appears below the user's request, cycling through a circular buffer of funny,
pseudoscientific mumbo-jumbo (e.g. `exploring the forge-fermi paradox`,
`recombobulating the discombobulator`, `herding schrödinger's cats`). Each line
replaces the previous every ~3.8s (2.6.58: doubled from 1.9s on user feedback). When the real reply lands, `addMessage('assistant',…)`
triggers `renderChat` which rebuilds `el.messages` and wipes the transient node;
`finally` clears the interval.

- `FORGE_PROGRESS_LINES` (28 entries) + `startForgeProgress()` near `addMessage`.
- CSS `.bubble.progress` (dashed border, muted italic, nowrap ellipsis) + pulsing dot keyframe.
- Wired in `onSend`: started after `abortController = new AbortController()`, stopped in `finally`.
- Stop button (abort) → catch → `addMessage('assistant','Stopped.')` → renderChat wipes node.

Smoke:
```text
[ ] bash ~/downloads/build_forge.sh && adb install -r ~/downloads/Forge-debug-rebuilt.apk
[ ] Chat: type an app, tap Forge it → gray rotating line appears below request, cycles ~every 2s
[ ] Lines are single-line, italic, dashed bubble; replaced by the real reply when it lands
[ ] Tap Stop → rotating line replaced by “Stopped.”
[ ] No rotating line leaks after the reply (renderChat rebuilds messages)
```

## Slim SYSTEM_PROMPT — 70% reduction for cheaper-model instruction-following (2026-08-17)

**2.6.60 / versionCode 90** (from 2.6.58/88). Host-only, no native.

### Problem
Non-Grok models (GLM-5.2, Groq Llama-class, OpenRouter routes) were finding it harder
to forge mini-apps in recent versions. Root cause: the `SYSTEM_PROMPT` had grown to
**2,751 words / 24.3 KB / 393 lines** — 95% exhaustive API reference, only 5% task
instruction. The critical "Return ONLY valid JSON" rule was buried under 2,400 words of
live-translate, termux, and tools-registry docs — classic lost-in-the-middle attention
dilution. The regression window (2.6.46 → 2.6.52) added +284 words of API-reference
dumps (chatStream/agent, Live Translate Patch 4, tools registry) that most mini-apps
never touch.

### Fix
Replaced the exhaustive per-method API dump with a **condensed quick reference** —
one line per API group with the key method signatures + the critical gotchas that
models get wrong (JSON-escape, no alert spam, no native bridges, data-forge-persist,
attachment MIME classification, deep-link preference). The full reference already
lives in `docs/api.md` and is pointed to inline.

- **Before:** 393 lines, 2,751 words, 24,328 chars
- **After:** 103 lines, ~811 words, ~7,414 chars
- **Reduction:** ~70% in word count and char count

### What stayed (essential)
- Task + output JSON shape (top — most prominent)
- Rules for html (condensed, +JSON-escape, +refine=full new html)
- Most common APIs inline: ai.chat (text + multimodal), permissions, files, camera, http, sms/phone/contacts, apps.launch, notifications, jobs, storage/secrets, state/persist
- Critical gotchas: non-image attachments must stay type:'file'; deep-link data URIs over activity class names; never embed API keys; never <input type=file> in iframe
- Safety UX: request perms before sensitive APIs; never SMS/call/launch without a user tap

### What was condensed to one-liners
- Lifecycle events, state auto-preservation, data-forge-persist
- Host AI streaming/agent/tools (signatures only — full examples in api.md)
- TTS/STT/liveTranslate (one line each)
- Mic/audio/qr/fs/termux (one line each)
- Apps/intents (kept deep-link examples — most common launch pattern)

### What was removed
- Redundant per-method return-shape comments (`// { name, type, mime, size, base64, ... }`)
- Verbose code examples for streaming/agent/tools (kept signature only; api.md has full examples)
- TTS voice-list fill-select tutorial (a frequent gotcha but rare in practice; in api.md if needed)
- Termux flavor/bridge detail (condensed to one line + "needs F-Droid Termux or agent")
- Audio routing route list detail (condensed to one line)
- Repeated permission-request reminders (consolidated into the Permission & safety UX section)

Smoke:
```text
[ ] bash ~/downloads/build_forge.sh && adb install -r ~/downloads/Forge-debug-rebuilt.apk
[ ] Forge a basic app (tip calculator) with GLM-5.2 → valid JSON, complete html, renders
[ ] Forge with an attached sketch → matches layout
[ ] Reforge an existing app → full new html (not a patch)
[ ] Forge an app using sms/contacts → correct API calls in generated html
[ ] Forge a chat app using ai.chat + tools.list → correct tool-loop pattern
[ ] No JSON parse errors / empty html / truncated output on cheaper models
```

## Release build — Play Store (paid) + F-Droid/website (free) (2026-08-17)

**2.6.61 / versionCode 91** (first Play-flavored release; from 2.6.60/90). Source-only gradle changes; no host/native touched.

### Decision (locked with user)
- **Path B**: one-time **$2.55** Play build (clean perms, auto-updates) + **free** full build (all perms) for website / F-Droid / sideload. No subscriptions, no AI-key monetization, no license gate, no account-ID collection. F-Droid eligible because the app is genuinely free + FOSS-licensed.
- A newsletter/registration **gate** on the F-Droid build was explicitly rejected: violates F-Droid anti-features (NonFreeNet / license-check DRM) + is trivially fork-stripped on FOSS + Play Data Safety misdeclaration risk. Do not reintroduce.

### Two distribution flavors (one source tree)
Gradle `flavorDimensions = ["distribution"]` in `android/app/build.gradle`:
- **`full`** → all permissions (main manifest) → APK → website / F-Droid / sideload
- **`play`** → restricted perms stripped via `src/play/AndroidManifest.xml` (`tools:node="remove"`) → AAB → Google Play

Stripped in `play` flavor only:
`SEND_SMS` `READ_SMS` `RECEIVE_SMS` `CALL_PHONE` `READ_PHONE_STATE` `READ_CONTACTS` `QUERY_ALL_PACKAGES` `READ_EXTERNAL_STORAGE` `WRITE_EXTERNAL_STORAGE`
Kept in both: INTERNET, CAMERA, RECORD_AUDIO, ACCESS_FINE/COARSE_LOCATION, POST_NOTIFICATIONS, BLUETOOTH_CONNECT, FOREGROUND_SERVICE(_DATA_SYNC), WAKE_LOCK, VIBRATE, RECEIVE_BOOT_COMPLETED, READ_MEDIA_IMAGES, MODIFY_AUDIO_SETTINGS, ACCESS_NETWORK_STATE, ACCESS_WIFI_STATE, CHANGE_WIFI_STATE, NEARBY_WIFI_DEVICES, SCHEDULE/USE_EXACT_ALARM, BLUETOOTH(_ADMIN ≤30), com.termux.permission.RUN_COMMAND.
`<queries>` (specific packages + intents) stays in both — allowed on Play without QUERY_ALL_PACKAGES.

### Release signing
- **`android/.keystore/forge-upload.jks`** (gitignored) — RSA 2048, alias `forge-upload`, validity 10000d. **Back this up offline forever.** Losing it = can never update Forge on Play.
- **`android/keystore.properties`** (gitignored) — storeFile/storePassword/keyAlias/keyPassword.
- `build.gradle` reads `keystore.properties`; `signingConfigs.release` used by the `release` buildType. If the file is absent (fresh clone / fork), release builds fall back to debug signing so forks still build.
- **Both flavors signed with the same key** → cross-store update preserves data if F-Droid reproducible builds ship the upstream-signed APK (default F-Droid re-signs → store switch needs reinstall).
- When enrolling in Play App Signing: **upload this same keystore** (do NOT let Google generate the key), so the F-Droid build can match.
- Keystore cert SHA-256: `d4678afb6f294e340342896b12d330a1e9bdca6c10ec9230006401996f409f0c`

### License
- **GPL-3.0** (`forge/LICENSE`) — copyleft, F-Droid-eligible. Chosen over Apache-2.0 (permissive) and over a custom non-commercial license: GPL forces modified/distributed versions to stay open-source (stops closed-source commercial ripoffs) while keeping F-Droid. A non-commercial license would forbid monetization but is non-free → F-Droid rejects. Note: no license protects against AI-assisted functional cloning (idea/expression dichotomy); real protection is distribution + brand + update velocity, not the license.

### Release script (checked in)
- **`forge/release_forge.sh`** — builds both flavors from one source:
  - stamps `forge-build.json` (sha + version + builtAt) into `www/` + `assets/`
  - syncs `www/index.html` → `assets/`
  - `./gradlew clean assembleFullRelease bundlePlayRelease`
  - outputs → `forge/release-out/Forge-full-release.apk` + `Forge-play-release.aab` (also `/sdcard/Download/`)
  - aborts if the release keystore is missing (gitignored secret)
  - does NOT bump versions automatically — set `versionCode`/`versionName` in `app/build.gradle` first

### First build (verified)
- `bash release_forge.sh` → BUILD SUCCESSFUL (1m 46s)
- Full APK (6.25 MB): has all restricted perms; signature verifies (v1+v2); signer cert SHA-256 matches keystore ✅
- Play AAB (5.59 MB): restricted perms stripped (verified absent); kept perms present ✅

Smoke:
```text
[ ] bash forge/release_forge.sh → both artifacts in release-out/
[ ] apksigner verify -v Forge-full-release.apk → Verifies
[ ] Play AAB manifest has no SMS/Call/Contacts/QUERY_ALL_PACKAGES/legacy-storage
[ ] Full APK manifest still has them
[ ] android/keystore.properties + android/.keystore/ are gitignored (secrets not committed)
[ ] Play Console upload of Forge-play-release.aab accepted; enroll App Signing with THIS keystore
```

### Play Console steps (user does)
1. Create app (com.forge.live, Paid, $2.55 — nearest tier to 2.55)
2. App integrity → App signing → **upload the forge-upload.jks key** (do not let Google generate)
3. Store listing (icon 512, feature graphic 1024×500, screenshots, description, privacy policy URL)
4. Pricing → Paid → 2.55 USD (accept nearest tier per country)
5. Data Safety form: declare Camera/Mic/Location/Notifications (NO SMS/Call/Contacts in play build)
6. Content rating + target audience + ads declaration + app access
7. Production → Create release → upload Forge-play-release.aab → Start rollout (review 1–7d)

## Backgrounded-network retry for AI calls (2026-08-18)

**2.6.65 / versionCode 95** (from 2.6.63/93). Host-only, no native Java touched.

### Problem (user report, Play build)
On the **Google Play installed version**, switching away from Forge mid-AI-call (e.g. into another app) surfaces:
`Error: Unable to resolve host "api.cheaperinference.com": No address associated with hostname`

Cause: Android cuts network for backgrounded apps (Doze / Data Saver / Samsung sleeping-apps), so the in-flight or next-round native `CapacitorHttp` call dies with `UnknownHostException`. The host had **zero retry** for transient network errors — chat/agent rounds hard-failed and the mini-app showed `Error: …` (surface: `Forge_Chat.html` `'Error: ' + msg`).

### Fix (`www/index.html`)
New helpers near `chatCompletionsWithFiles`:
- `isTransientNetworkError(e)` — matches unable-to-resolve / no-address / unknownhost / network-unreachable / failed-to-fetch / connection-reset|timed-out / ERR_NAME_NOT_RESOLVED / ERR_INTERNET_DISCONNECTED / ERR_NETWORK_CHANGED etc.
- `waitForVisible(maxMs)` — resolves on `visibilitychange` → visible (OS restores network on resume)
- `nativeHttpPost(opts)` — CapacitorHttp POST wrapper: up to **3 attempts** with backoff (1.2s, 2.4s); if the app is hidden, waits (≤30s) for foreground before retrying; honors `signal` (AbortError passthrough); rethrows non-transient errors immediately (4xx/5xx statuses are resolved values, never retried)

Wired into:
- `chatCompletions()` — primary + both response_format/tools-drop retries
- `geminiGenerateContent()` native branch
- Streaming path benefits transitively: `chatCompletionsStream` WebView-fetch failure falls back to `chatCompletions` (now retry-backed)
- Not yet wrapped (deliberate, small patch): `toolsHttpRequest` (web_search/web_fetch GETs), model-catalog GET, cloud TTS — follow-up if backgrounded tool rounds still error

### Also
- `build_forge.sh` fixed for flavors: canonical `Forge-debug-rebuilt.apk` = **full** debug; `Forge-play-debug.apk` copied alongside (path was still pre-flavor `apk/debug/` → build "succeeded" but copy step failed)
- Docs baselines re-synced (`docs/api.md`, `docs/tools.md` → 2.6.65/95; were stale at 2.6.60/90 vs gradle 2.6.63/93)
- Gate: `forge_check.sh` + `forge_docs_check` PASS; both flavor debug APKs verified to contain `nativeHttpPost` + stamp `2.6.65/95`

### Deploying to the Play-installed app
The user's phone runs the **Play build** (release-signed via Play App Signing) — a debug APK **cannot** install over it. Ship path:
1. Verify on a debug build (full or play flavor) first
2. Commit fix (release stamp then records the right sha; current test APKs stamp HEAD `91b6670` without the fix commit)
3. `bash forge/release_forge.sh` → upload `Forge-play-release.aab` to Play Console → rollout → Play updates users

OS-level mitigation (works on the current Play version today): Settings → Apps → Forge → Battery → **Unrestricted** — reduces the background network cut.

Smoke:
```text
[ ] adb install -r Forge-play-debug.apk (or full debug) → About Forge shows 2.6.65 (95)
[ ] Forge Chat with cheaperinference (glm-5.2): send a message → switch away mid-reply → return → reply completes (no Unable-to-resolve error)
[ ] Same with Gemini provider
[ ] ai.agent multi-round: background during round 2 → return → loop continues
[ ] Tap Stop (abort) mid-retry → aborts promptly (no zombie retries)
[ ] Foreground behavior unchanged (single attempt when network is healthy)
```

## FGS network keep-alive for all AI calls + full retry coverage (2026-08-18)

**2.6.66 / versionCode 96** (from 2.6.65/95). Host-only, no native Java touched.

### Diagnosis (why 2.6.65 retry alone wasn't the whole story)
2.6.65 recovered *after* the user returns (retry + wait-for-visible). But most mini-app AI
calls had **no retry at all** and no network protection while backgrounded:

- `CapacitorHttp.enabled:true` patches `window.fetch` — several AI paths (`/responses`,
  cloud TTS, STT multipart, `http.get/post`, `toolsHttpRequest`, `fetchUrlAsDataUrl`)
  used raw `CapacitorHttp.request` or patched `fetch` with **zero** transient handling
- The **dataSync foreground service** (`BackgroundForgeService`, FOREGROUND_SERVICE_DATA_SYNC
  in both flavors) was already proven to keep network + JS alive in background by
  **live-translate**, but was only started by Forge-it/Reforge (`bgStart`) and live-translate

### Fix 1 — unified FGS refcount (`aiFgsAcquire`)
One service, many owners (token `Set` + 1.2 s grace before stop; `BackgroundForge.start`
on first token, `stop` when empty — no start/stop churn between agent rounds; label on
the first acquire wins):
- `ai.chat` / `ai.chatStream` / `ai.agent` / `ai.transcribe` / `ai.tts` acquire for the
  whole handler (tts holds through speech playback)
- `bgStart`/`bgStop` (Forge-it / Reforge) now acquire/release through the same refcount
- `liveTranslateStart/Stop` swapped direct `BackgroundForge.start/stop` for a held
  `liveTranslateFgsRelease` token (fixes: a finishing ai.chat would have killed the
  live-translate service)
- `keepAwake.start/stop` mini-app API joins the refcount (stack of releases) — a
  concurrent AI call finishing can no longer stop a mini-app's requested keep-awake
- FGS start failure is non-fatal (`.catch(()=>{})`) — e.g. call begun while already
  backgrounded on Android 12+ (start-from-background restricted); retry layer covers it

### Fix 2 — retry coverage completed
- `nativeHttpPost` generalized to `nativeHttp({method, responseType, …})` (POST alias kept)
- Wrapped: `/responses` API, cloud TTS (arraybuffer), `http.get/post` bridge,
  `toolsHttpRequest` (web_search/web_fetch), `fetchUrlAsDataUrl` (remote attachments)
- New `fetchWithTransientRetry()` for patched-fetch one-shots — used by STT multipart
- Not retried (by design): SSE streams (OAI/Gemini) — their fetch failure falls back to
  the retry-backed non-stream path; model-catalog GETs (settings UI, foreground)

### Housekeeping
- Version 2.6.66/96 (gradle + docs baselines + package.json), gate green, both flavor
  debug APKs + `release_forge.sh` release artifacts rebuilt
- `release-out/Forge-full-release.apk` + `Forge-play-release.aab` stamped `2.6.66/96`
  (sha `91b6670` pre-commit; rebuild after commit re-stamps)

Smoke:
```text
[ ] adb install -r Forge-debug-rebuilt.apk → About Forge shows 2.6.66 (96)
[ ] Forge Chat (cheaperinference): send → background mid-reply → "Forge / AI working…" FGS
    notification appears → return → reply completed (or completed while backgrounded)
[ ] Same with Gemini + ai.agent multi-round
[ ] Live Translate: start (FGS) → run an ai.chat in another mini-app → chat finishes →
    translate FGS notification still alive until stop
[ ] Kitchen sink: keepAwake.start → ai.chat → keepAwake.stop still stops service after
[ ] Background → foreground unchanged when network healthy (no retry latency)
[ ] Deploy: upload release-out/Forge-play-release.aab to Play Console → Production release
```

## Mini-apps overlapping Android status bar — edge-to-edge on targetSdk 35 (2026-08-18)

**2.6.68 / versionCode 98** (from 2.6.67/97). Native Java only.

### User report
Mini-apps lost top buffer space and overlapped the Android status bar.

### Cause
The **compileSdk/targetSdk 34→35 bump** (commit `49f87bc`, Play requirement). Android 15
**enforces edge-to-edge** for SDK-35 apps: the window ignores `fitSystemWindows` legacy
behavior at the decor level and content draws behind status/nav bars. Capacitor's
`BridgeActivity` does no inset handling of its own (`setContentView(bridge_layout_main)`),
so the WebView filled the entire screen — host + every mini-app (RunActivity).

### Fix (`MainActivity.onCreate`, after `super.onCreate`)
- `ViewCompat.setOnApplyWindowInsetsListener(webView, …)`: pads the WebView by
  `systemBars() | displayCutout()` insets; returns CONSUMED. Covers **RunActivity**
  (subclass of MainActivity) and any bridge-hosted window — one fix, all windows.
- Window background → `#09090F` (host `--bg`) so the padded bar strips look like app chrome.
- Forced **light status/nav icons** (`setAppearanceLightStatusBars(false)`) for contrast
  on the dark strip.
- All via fully-qualified androidx.core names inside try/catch — no new imports/deps
  (androidx.core ships with appcompat 1.6.1).

Watch-item: QrScanActivity / CameraXCaptureActivity use their own layouts and may now
also draw under bars — check on device; same one-liner applies if needed.

Smoke:
```text
[ ] adb install -r Forge-debug-rebuilt.apk → About Forge v2.6.68 (98)
[ ] Host: top tab bar sits below status bar; dark strip behind status bar; white icons
[ ] Mini-app (Chess_vs_LLM): title row visible below status bar, no overlap
[ ] Rotate + gesture-nav vs 3-button nav: bottom padding correct, no overlap
[ ] Camera capture / QR scan flows still usable (watch-item above)
```

## Target SDK 36 / Android 16 — toolchain migration (2026-08-18)

**2.6.69 / versionCode 99** (from 2.6.68/98). Native build system; no host JS changes.

### Why
Google Play: new apps/updates must target API 36 (Android 16).

### What changed
| Item | Before | After |
|---|---|---|
| compileSdk / targetSdk | 35 | **36** (app/build.gradle + variables.gradle; Capacitor module follows ext) |
| AGP | 8.2.2 | **8.9.2** (first AGP officially supporting compileSdk 36) |
| Gradle wrapper | 8.2 | **8.11.1** (AGP 8.9 min) |
| CameraX | 1.3.4 | **1.4.2** — .so 16 KB-page aligned |
| proot SDK | platforms 34/35 | + android-36 (build-tools 35.0.0 already present) |

### Verification
- `zipalign -c -P 16 -v 4` on built APK → **exit 0** (16 KB alignment = Play hard req for 36)
- `apkanalyzer manifest print` → `targetSdkVersion="36"`, `compileSdkVersion="36"`, minSdk 22
- assembleDebug + release (AAB/APK) green on new toolchain (first build 7m32s cold)

### Behavioral notes (target 36)
- **Predictive back** default-on: AppCompat 1.6.1's OnBackPressedDispatcher copes; legacy
  back paths still dispatched at commit. Watch on device (mini-app back, dialogs).
- **16 KB page size**: devices with 16 KB pages (Pixel 2025+ A/B) now load our .so cleanly.
- dataSync FGS 6 h/day cap, edge-to-edge — unchanged vs 35 (2.6.68 insets fix already in).
- Remaining on Capacitor 6.1.2 (7/8 migration NOT required for 36 — avoided this release;
  revisit when Capacitor 6 hits EOL or a feature demands it).

Smoke:
```text
[ ] adb install -r Forge-debug-rebuilt.apk → About Forge v2.6.69 (99)
[ ] Host boots, mini-apps run, camera capture + QR scan OK (CameraX 1.4.x)
[ ] Back gesture/button: mini-app closes as before (predictive back watch-item)
[ ] Status-bar insets still correct (2.6.68 fix under 36)
[ ] Upload release-out/Forge-play-release.aab → Play accepts targetSdk 36
```

## Status-bar overlap fix v2 — listen on decor, not the WebView (2026-08-18)

**2.6.70 / versionCode 100** (from 2.6.69/99). Native Java only.

### Why 2.6.68 didn't work (user: "didn't fix the regression")
2.6.68 registered `ViewCompat.setOnApplyWindowInsetsListener` on the bridge
**WebView**. It never fired. Root cause: Capacitor's `bridge_layout_main.xml`
wraps the WebView in a **`CoordinatorLayout`**, whose `onApplyWindowInsets`
dispatches insets to children **only when `fitsSystemWindows=true`**. The
WebView isn't marked, so the listener was starved and the WebView stayed
edge-to-edge behind the status bar.

### Fix (MainActivity.onCreate, inherited by RunActivity)
- Listen on **`getWindow().getDecorView()`** — the root of the window-insets
  dispatch, guaranteed to receive every pass regardless of intermediate groups.
  Pad the bridge WebView from there (absolute padding, idempotent).
- Keep a redundant listener on the WebView itself as belt-and-braces (harmless
  duplicate of the same absolute padding for parents that do propagate).
- `onResume` → `ViewCompat.requestApplyInsets(decor)` to force a pass for any
  dispatch that happened before registration (or after re-layout/rotation).
- `Log.d("ForgeInsets", "applied top=… bottom=…")` for on-device diagnosis via
  `adb logcat | grep ForgeInsets` — confirms the listener fires + the real bar
  heights.

### Verified
- assembleDebug + release green (2.6.70/100); `apkanalyzer` still targetSdk 36.
- On-device smoke needed (no adb here): expect `ForgeInsets` log line + no
  overlap on host and mini-apps; rotate + 3-button/gesture nav both padded.

Smoke:
```text
[ ] adb install -r Forge-debug-rebuilt.apk → About Forge v2.6.70 (100)
[ ] adb logcat | grep ForgeInsets  → "applied top=<n> bottom=<n>" (n>0)
[ ] Host + mini-apps: top row below status bar; dark strip; white icons
[ ] Rotate + gesture/3-button nav: bottom padding correct
```

## 2.6.71/101 — the fix that 2.6.70 claimed but didn't contain (2026-08-19)

**Root cause of the continued overlap:** the 2.6.70 "decor view" commit was
missing its main hunk. The edit call that replaces the WebView-only listener
with the decor-view listener failed atomically (its second anchor didn't match
the file), and only the onResume half got retried. Net: 2.6.70 shipped with
NO listener registration — just the onResume nudge — so nothing ever padded
the WebView. Detected when user's logcat showed no ForgeInsets lines and a
grep of MainActivity confirmed no getDecorView listener.

**2.6.71/101 contains:**
- `setOnApplyWindowInsetsListener(decor)` → pads bridge WebView (absolute,
  idempotent). Decor = root of insets dispatch; CoordinatorLayout can't starve it.
- Redundant WebView listener kept (harmless).
- `onResume` → `requestApplyInsets(decor)` forces a pass after registration.
- Logs: `adb logcat -s ForgeInsets` → "decor pass: top=… bottom=…".

Smoke (replaces 2.6.70 checklist):
```text
[ ] adb install -r Forge-debug-rebuilt.apk → About v2.6.71 (101)
[ ] adb logcat -s ForgeInsets → "decor pass: top=<n> …" (n>0) while Forge foregrounded
[ ] Host + mini-apps clear of status bar; dark strip + white icons
[ ] Rotation + gesture/3-button nav correct
```

## 2.6.72/102 — margins not padding (2026-08-19)

Logcat confirmed the decor listener fires with real heights
(`ForgeInsets: decor pass: top=95 bottom=39 left=0 right=0`) yet overlap
persisted. Cause: Android WebView (Chromium) is unreliable about shifting its
rendered content for `setPadding` — the page can keep painting at the top of the
view bounds. Switched to layout **margins** on the WebView (`MarginLayoutParams
.setMargins` + `requestLayout`), honored natively by the parent
CoordinatorLayout — physically shrinks the view bounds so content cannot reach
the bars. This is the approach Capacitor 7 settled on. Idempotent absolute
margins per pass.

Smoke:
```text
[x] adb install -r Forge-debug-rebuilt.apk → About v2.6.72 (102)
[x] adb logcat -s ForgeInsets → "decor pass: top=95 bottom=39 …"
[x] Host + mini-apps: content starts below status bar; dark strip + white icons  (user-verified 2026-08-19: "wonderful")
[ ] Rotation + gesture/3-button nav: bottom margin correct  (spot-check next use)
```

**STATUS: FIXED & DEVICE-VERIFIED at 2.6.72/102 (e2b77a2).** The full fix
chain: decor-view listener (2.6.71) + margins-not-padding (2.6.72).

## Session close — 2026-08-19 (LOCKED @ 2.6.72/102)

**All work device-verified and locked. State at close:**

| Item | State |
|------|-------|
| App version | **2.6.72 / versionCode 102** (HEAD `e2b77a2`, SDK 36, AGP 8.9.2, Gradle 8.11.1, CameraX 1.4.2, 16 KB-aligned) |
| Status-bar overlap | **FIXED & VERIFIED** — decor-view insets listener (2.6.71) + margins-not-padding (2.6.72); `adb logcat -s ForgeInsets` shows `top=95 bottom=39` |
| FGS network keep-alive | 2.6.66/96 — refcounted dataSync service for all AI HTTP; shipped |
| AI timeouts | 2.6.67/97 — 600 s read timeouts + friendly message; shipped |
| SDK-36 migration | 2.6.69/99 — target/compile 36, zipalign 16 KB pass; shipped |
| Release artifacts | `release-out/Forge-full-release.apk` + `Forge-play-release.aab` @ 2.6.72/102 (also `/sdcard/Download/`) |
| Play closed test | **Track live** (`play.google.com/apps/testing/com.forge.live`), AAB 2.6.72 published. Gate: personal account → need **12 testers opted-in + 14 days**, then Dashboard → Apply for production access. NOT yet done — pending testers. |
| Play App content | Pending: data-safety form, content rating, privacy-policy URL (not drafted) |
| Icon | Current = original. Where: APK `res/mipmap-*/ic_launcher*` + Play listing 512×512 upload; swap not done (option A `@capacitor/assets` recommended) |

**Next session pickup points:** (1) 12-tester closed test + production-access application; (2) privacy.html + data-safety cheat sheet; (3) optional icon swap via `@capacitor/assets`; (4) optional: chatStream Forge-it, chess-as-Black, web_fetch readability fallback, Capacitor 7/8 migration (no pressure).

## Donate button in AI menu (2026-08-19 · 2.6.73/103)

User claimed `paypal.me/forgedevthanksyou`. Added `☕ Support development`
button at the bottom of the AI settings card (`www/index.html` + assets sync,
host-only, no native change). Opens PayPal **in the system browser** via
existing `openExternalUrl` (anchor target=_blank → external on Capacitor).

**Compliance posture (why this is safe):**
- Play: donation link-out with **no in-app benefit** → outside Google Play
  Billing scope; standard "buy me a coffee" pattern.
- F-Droid: donations allowed; can later add `Donate:` metadata. No anti-feature.
- Button hint explicitly says "donating unlocks nothing".

```text
[ ] Smoke: AI tab → bottom → '☕ Support development' → PayPal page opens in browser
[ ] Play closed-test track: optionally roll 2.6.73 to testers (same versionCode progression 103 > 102)
```

## Host UI i18n — 5 languages, About-tab selector, restart-to-apply (2026-08-20)

**2.6.77 / versionCode 107** (from 2.6.73/103; interim bumps 2.6.75/105 while
diagnosing docs-baseline gate — monotonic, harmless). Host-only, no native.

### Design (locked with user — after 3 failed over-engineered attempts)
The earlier attempts failed by bolting on: dual translation mechanisms,
a Python splice/validate toolchain, a first-run language gate, and a live
re-render orchestrator (`reApplyI18nUI`). User directive: "it shouldn't be that
complex — dictionary, N copies, selector." **This land is the minimal shape:**

| Piece | State |
|---|---|
| `FORGE_I18N` dict | **en / es / fr / pt / ja** (ko dropped — never translated), inline between `/*__I18N_START__*/` markers, ~425 en keys |
| Lookup | `t(id, vars)` + `tf(id, fallback, vars)` with `{var}` interpolation + **en fallback** |
| Boot | `FORGE_LANG` = `localStorage.forge_lang_v1` → else `navigator.languages` auto-detect |
| Static HTML | `data-i18n/-html/-ph/-title/-aria` attributes applied **once at boot** (`applyI18nDom`) — no live re-render |
| Dynamic strings | 369 `t()` + 9 `tf()` call sites (tab labels, toasts, statuses, wizard) |
| Selector | `Language` select in **AI tab → About Forge** card; change → saves + shows persistent `Saved — restart Forge to apply` hint (`about.langRestart`); **restart applies** |
| Not present (by design) | No first-run gate, no `reApplyI18nUI`, no build toolchain, no auto-reload |

### Salvage notes (from the WIP stash `stash@{0}`, then dropped)
- Dict sources `.i18ntmp/dict_*.py` were **double-encoded UTF-8** (latin-1 view).
  Repair = `encode('latin-1').decode('utf-8')` round trip with mojibake-pair
  discriminator (proper `·`/`é` singles kept; `Ã©`-style pairs repaired).
- **93 ja strings had dropped bytes** (C1 byte stripped in old pipeline — lossy,
  unrecoverable): dropped keys → `t()` falls back to English for those.
  ja ≈ 414/507 keys translated; es/fr/pt full.
- Salvage scripts kept in `~/downloads/i18n_salvage/` (surgery.py + dicts + stashed.html).
- The old **stash still exists** (`stash@{0}`) — kept per INVARIANTS; ask user
  before dropping now that salvage is committed.

### Gate change
`forge_check.sh` step 5: expected raw `</script>` count **2 → 1** (the pre-paint
language-gate script was removed; only the host module block remains).

Smoke (device pending — adb offline at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.6.77 (107) · 19be579
[ ] Host UI unchanged in English (default) — tabs, chat, AI settings, library
[ ] AI tab → About Forge → Language → Español → hint "reinicia Forge" appears
[ ] Restart Forge → UI in Spanish (tabs, placeholders, hints, wizard)
[ ] Same for Français / Português / 日本語 (ja: ~93 strings stay English)
[ ] Auto (device language) option works after restart
[ ] Mini-apps unaffected; console capture still works; no regressions in selects/theme
```

## i18n: add Korean, fix Japanese lossy strings (2026-08-20)

**2.6.79 / versionCode 109** (from 2.6.77/107). Host-only, no native.

### Korean (ko) — new
- Full translation: **425 common + 81 provider-namespace keys = 506 total**,
  proper UTF-8 (no mojibake).
- `ko` row restored in `FORGE_LANGS` (was dropped at 2.6.77 because the old
  pipeline never translated it). Now a real option in the Language select.
- `about.langRestart` (ko): "저장됨 — 적용하려면 Forge를 다시 시작하세요."

### Japanese (ja) — fix the 93 lossy strings
- The 2.6.77 salvage dropped 93 ja keys whose source bytes were lossy (a C1
  byte stripped in the old pipeline — unrecoverable by round-trip). Those
  keys fell back to English via `t()`.
- This land **re-translates all 93** (75 common + 18 ns) into proper UTF-8
  Japanese, overlaid onto the repaired ja dict. **ja now full 506 keys** —
  no more English fallbacks for the lossy set.

### Verification
- All 6 langs: en 425 common, es/fr/pt/ja/ko 506 (425 + 81 ns).
- `{var}` token parity checked across every key in every language.
- `forge_check.sh` + `forge_docs_check` PASS; both flavor debug APKs build.

### Salvage artifacts (kept in `~/downloads/i18n_salvage/`)
- `dict_ko.py` (full Korean, 508 incl. gate.* + langRestart)
- `dict_ja_fix.py` (93 re-translations)
- `surgery.py` (regeneration script; ko row kept, ja-fix overlay added)
- `dict_en.py` / `dict_es/fr/pt/ja.py` (originals, mojibake-repaired at gen)

Smoke (device pending — adb offline at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.6.79 (109) · 1615187
[ ] AI tab → About Forge → Language → 한국어 → restart → UI in Korean (full)
[ ] Language → 日本語 → restart → UI in Japanese (full, incl. the 93 fixed strings)
[ ] Spot-check: ja lib.confirmDel, drive.backupDone, txs.playNeedsAgent show proper 日本語
[ ] es/fr/pt still full; en default unchanged
```

## Generation watchdog: max-time setting, extend-or-fail popup, console turn log (2026-08-21)

**2.6.95 / versionCode 125** (from 2.6.93/123). Host-only, no native Java.

### Problem
The generation timeout was a hardcoded **600s per-HTTP-call** `readTimeout`
scattered across the AI call sites. When a slow model exceeded it the call hard-failed
with the friendly “Provider took longer than 600s…” error and the user had no recourse —
no way to wait longer, no record of what was happening. The user asked for:
1. a **setting** for max generation time (was hardcoded 600s);
2. on timeout, a **popup** (not a hard fail) offering **Fail now** or **Extend +Ns**;
3. **console turn details** appended to the AI-tab console as generation happens;
4. the popup must **not block** the AI tab / console while visible.

User insight that shaped the design: *if the 600s is on a single LLM call, a better
(complementary) fix is to use the streaming API* — a streaming connection keeps
receiving bytes so it rarely trips a socket read timeout (read timeout is gap-between-
packets, not total duration). So streaming removes the whole class of single-call
cliffs, and the watchdog becomes the right mechanism for streams (which otherwise
stall silently forever).

### What landed

| Piece | State |
|---|---|
| **Setting** | AI settings card: *Max generation time (s)* — input `#genTimeoutSecs`, 30–1800, default 600, `LS.genTimeout = 'forge_gen_timeout_v1'`; loaded in `loadPrefs`, saved in `savePrefs`, change/blur wired. |
| **Watchdog** | `startGenWatchdog(label)` wraps the whole `forgeApp` / `reforgeAppWithAi` await (1s tick). Budget = `getGenTimeoutSecs()*1000`. On elapse → **non-blocking** floating card (`#genTimeoutWrap`, `pointer-events:none` wrapper, card only, z-index 150 — below the console sheet so opening Console covers it) with **Fail now** / **Extend +Ns** (N editable, default = setting). Auto-hides when the generation settles. Tabs + console stay usable while it is up (`setBusy` only gates the send button). |
| **Console turn log** | `genLog(level, text)` → `pushMiniConsole(level, text, 'forge-gen')`. Logs: start (provider · model · prompt chars · history · attachments), receiving progress (~20s throttle so the 500-line ring isn't flooded), received+parse, done (title · html size), timeout event + user choice (extend/fail), aborts, failures. Badge counts unread as before. |
| **readTimeout plumbing** | The 5 AI call sites (`responsesApiCompletion`, `geminiGenerateContent`, `chatCompletions` ×3) now use `aiReadTimeoutMs() = max(600000, settingMs)` so the socket never dies before the watchdog popup can extend (lets “Extend” actually work on non-stream fallbacks). Image-gen (`xAI /images`, 300s) and cloud TTS (300s) untouched. |
| **Reforge → streaming** | `reforgeAppWithAi` now uses `chatCompletionsStream` / `geminiStreamGenerateContent` (both auto-fall-back to non-streaming internally) instead of the non-stream variants. Tokens keep the connection alive → no 600s single-call cliff for slow models; also gives live receive progress. Forge-it already streamed. |
| **i18n** | en keys added: `ai.genTimeout`, `ai.genTimeoutHint`, `gen.title/body/extendBy/extend/fail`, `chat.genTimeoutMsg`. Other langs fall back to en via `t()`. |
| **Version** | 2.6.95 / 125; docs baselines + package.json synced; gate green; both flavor debug APKs built. |

### Non-blocking popup — why it satisfies “still explore the console”
The card is `position:fixed; inset:0; pointer-events:none` (only the inner card
captures clicks), z-index 150 — **below** the console sheet (`.setup-overlay` z-200).
So while the card is visible the user can tap the AI tab and open Console; the console
sheet renders above the card. Closing the sheet reveals the still-present card. The
watchdog keeps running (it only stops on generation settle / Fail now / Stop).

### Files
`www/index.html` + assets sync (CSS, popup HTML, AI-settings input, i18n en keys,
LS key, el map, loadPrefs/savePrefs, listener array, watchdog+genLog helpers,
forgeApp milestones, onSend watchdog, reforge streaming+watchdog, 5× readTimeout
swap), `android/app/build.gradle`, `docs/api.md` + `docs/tools.md` baselines,
`package.json`.

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.6.95 (125) · 4891e32
[ ] AI tab → Advanced → 'Max generation time (s)' = 600 (editable, persists)
[ ] Forge it a big app with a slow model → AI tab → Console shows forge-gen lines:
    start · provider/model · receiving… Nk · received · parsing · done · html Nk
[ ] Set max-gen-time to 30s, Forge it → after 30s the floating card appears;
    switch to AI tab → open Console (sheet covers card, still readable); close sheet
[ ] Card: Extend +120s → card hides, generation continues; reaches 120s again → card returns
[ ] Card: Fail now → generation stops, chat shows 'Generation stopped — time limit reached.'
    console line 'forge aborted (time limit)'
[ ] Stop button mid-generation → card hides, 'Stopped.' (not the time-limit message)
[ ] Reforge a big app → console shows 'reforge start / receiving… / reforge done';
    no 600s hard fail on a slow model (streaming keeps connection alive)
[ ] Tabs / selects / theme unchanged (regression)
```

## extractJson: triple-backtick fence hijack fix (2026-08-21)

**2.6.96 / versionCode 126** (from 2.6.95/125). Host-only.

### Symptom
The Chat Pro prompt (and any prompt whose generated app embeds triple-backtick
sequences — e.g. a markdown renderer with `/```...```/g` regexes) failed Forge-it
**every time** with `Model did not return valid JSON app payload`.

### Root cause
`extractJson` matched the FIRST ```` ```...``` ```` pair anywhere in the model
reply and replaced the whole payload with the captured text. The model returns
valid raw JSON whose `html` string value contains literal ```` ``` ```` sequences
(backticks aren't JSON-escaped); the extractor then grabbed the text between two
INNER fences (garbage), so every parse path failed. Deterministic for those
prompts; harmless for simple apps whose HTML has no fences.

### Fix
Parse the full text first. Strip fences only when a single fence spans the
whole reply (anchored `^\s*```(?:json)?\s*([\s\S]*?)```\s*$`). Keep the
first`{`…last`}` slice + trailing-comma repair fallbacks. On failure, `genLog`
a head/tail preview (len + 200 chars each) to the AI-tab console so future
parse failures are debuggable instead of a bare 'invalid JSON'.

### Verified
Node unit test: old extractor fails the killer payload; new one passes
raw-JSON-with-inner-fences / whole-```json-fence-wrap / prose+JSON / trailing-
comma cases.

### Files
`www/index.html` (+ assets sync), `android/app/build.gradle`, `docs/api.md` +
`docs/tools.md` baselines, `package.json`.

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.6.96 (126) · 68f7e1a
[ ] Paste the Chat Pro prompt → Forge it → builds (no 'invalid JSON' error)
[ ] Simpler prompts still build (regression)
[ ] AI tab → Console: on any parse failure shows 'JSON parse failed · len N · head/tail'
```

## Forge-it max_tokens + truncation detect (2026-08-21)

**2.6.97 / versionCode 127** (from 2.6.96/126). Host-only.

### Symptom
Tic-tac-toe builds; the long Chat Pro prompt still failed with invalid JSON
even after the 2.6.96 fence-hijack fix.

### Root cause
No `max_tokens` / `maxOutputTokens` was ever set on factory LLM calls. Providers
default to a small completion budget (often 4k–8k tokens). Complex mini-app HTML
exceeds that → stream ends with `finish_reason: length` → incomplete JSON →
`extractJson` fails. Simple apps fit; Chat Pro does not.

### Fix
- `maxTokens: 32768` on forgeApp + reforge (stream + non-stream fallbacks)
- OpenAI-compat `max_tokens`; Gemini `generationConfig.maxOutputTokens`
- Retry once without the param if the provider 4xx-rejects it
- Detect `finish_reason === 'length'` (and Gemini MAX_TOKENS) → throw clear
  truncated error with `err.truncated`; `forgeFailMessage` → `chat.failTruncated`
- Console: genLog on truncation

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.6.97 (127)
[ ] Paste Chat Pro prompt → Forge it → should complete (or clear truncation msg)
[ ] Tic-tac-toe still builds (regression)
[ ] Console shows receiving… Nk growing past previous ~default cutoff
```

## Stream parser: non-standard content fields (2026-08-21)

**2.6.98 / versionCode 128** (from 2.6.97/127). Host-only.

### Symptom
GLM 5.3 returned 0 chars → `JSON parse failed · len 0`. Chunks arrived but no
content was extracted.

### Root cause
`chatCompletionsStream` flushEvent only checked `choice.delta.content`. GLM
(Zhipu) uses a different field name for the text piece.

### Fix
- Accept `delta.content | delta.text | delta.reasoning | delta.output`
- Accept top-level `ev.content | ev.text | ev.output | ev.response` (no choices)
- Also check `choice.message` (some providers send full message in stream)
- Log the first SSE chunk (400 chars) when no delta.content yet → console

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.6.98 (128)
[ ] GLM 5.3 + Chat Pro prompt → console shows first chunk shape → builds or
    clear error
[ ] Opus/Grok still work (regression)
```

## extractJson: thinking-in-content brace scan (2026-08-21)

**2.6.99 / versionCode 129** (from 2.6.98/128). Host-only.

### Symptom
GLM 5.3 received 97,462 chars but `JSON parse failed · len 97461`. Head was
prose ('Build a complete single-file HTML app...'), tail ended with
`</html>" }` (valid JSON end). The 2.6.98 stream-field fix worked (content
arrived); the failure was in extraction.

### Root cause
GLM 'thinks out loud' in the content stream before emitting the payload,
echoing prompt fragments that contain braces
(`ForgeHost.state.save({ chats, activeChatId, settings })`). The old
first-`{`-to-last-`}` slice started at the prose brace → unparseable.

### Fix
- Fast path: anchor on `{"title":` and parse to last `}`
- Scan every `{` left→right (cap 400), accept first parse with an html string
- Keep legacy first-brace slice as last resort
- Skip first-chunk warning for role-only headers (standard OpenAI stream start)

### Verified
Thinking-prose + payload, inner-fence killer (2.6.96), and fence-wrap (2.6.96)
all parse.

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.6.99 (129)
[ ] GLM 5.3 + Chat Pro → builds (no 'invalid JSON')
[ ] Opus/Grok still build (regression)
```

## Stream: reasoning vs content separation (2.7.0, 2026-08-21)

**2.7.0 / versionCode 130** (from 2.6.99/129). Host-only.

### Symptom
GLM 5.3 run 2: received 93,825 chars, JSON parse failed. Tail ended
mid-regex (no closing brace) — the model produced ONLY thinking text and
never emitted the JSON payload.

### Root cause (two parts)
1. 2.6.98 wrongly treated `delta.reasoning` as content (my bug — reasoning is
   the scratchpad, not the answer). It polluted contentAcc.
2. GLM reasoning models can burn the entire output budget on thinking when the
   prompt is complex. No error existed for 'reasoning but no answer'.

### Fix
- `reasoning`/`reasoning_content`/`thinking` accumulate into reasoningAcc,
  excluded from contentAcc/onDelta/extractJson
- reasoning-only stream → `err.reasoningOnly` → `chat.failReasoningOnly`
  message with actionable advice
- brace-scan cap 400→2000 (thinking-echo produces 300+ prose braces)

### Verdict on GLM for Forge-it
GLM 5.3 is fundamentally poorly suited to Forge-it with complex prompts: it
emits reasoning as content and can exhaust the budget before the payload.
Opus produced the best result; Grok also works.

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.0 (130)
[ ] GLM 5.3 + Chat Pro → either builds (if it emits content) or shows the
    clear 'spent its entire output budget thinking' message
[ ] Opus/Grok unchanged (regression)
```


## Termux agent: python auto-install precondition (2026-08-23)

**2.7.2 / versionCode 132** (from 2.7.0/130). Native assets + Java builtins; no host JS.

### Problem
The Termux agent needed python but only **errored out** when missing — on a fresh
Termux the documented one-liner
(`bash install.sh && forge-termux-agent --daemon`) died with
"python required: pkg install python". Worse, in the agent the check ran
**after** the `--daemon` branch, so `--daemon` printed its "daemon pid" line and
then the child failed **silently** (`nohup >/dev/null`).

### Fix (all copies kept in sync)
| Copy | Change |
|---|---|
| `assets/termux-agent/forge-termux-agent` (APK asset, canonical) | ensure-python block moved **before** `--daemon`; auto-installs |
| `TermuxBridgePlugin.builtinAgentFile("forge-termux-agent")` (fallback) | same change |
| `TermuxBridgePlugin.builtinAgentFile("install.sh")` | **new** ensure-python precondition (previously had none) |
| exported `README.txt` text | notes "Python is installed automatically if missing (needs internet once)" |

### Ensure-python logic
- `python3`/`python` on PATH → no-op
- missing → `pkg install -y python`; on failure retry (`pkg update -y` then install once more — covers stale apt lists)
- no `pkg` (not Termux) → clear manual-install error, exit 1
- install still failing → clear error, exit 1 (install.sh failing stops the `&& forge-termux-agent` chain — correct)

Why **before** `--daemon`: the daemon child's output is discarded, so the install
must run in the foreground where the user sees progress; the child re-check is a no-op.

### Verified
- `bash -n` clean on the asset + both decoded Java builtin strings
- Built APK's `assets/termux-agent/forge-termux-agent` contains `pkg install -y python` and parses

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.2 (132)
[ ] Fresh Termux (no python): AI → Device bridges → Install agent → in Termux run
    bash /storage/emulated/0/Download/ForgeBridge/install.sh && forge-termux-agent --daemon
    → "python not found — installing…" prints → agent daemonizes → Test Termux OK
[ ] Termux with python already installed → no install output, starts instantly
[ ] Re-export agent files after install (Settings → Device bridges) so old on-disk
    copy at /storage/emulated/0/Download/ForgeBridge is replaced
```

## Termux agent: full-path command + idempotent install (2026-08-23)

**2.7.4 / versionCode 134** (from 2.7.2/132). Java strings + host i18n; agent v1.1.0.

### Changes
1. **Full-path invocation** — every user-facing command now calls the agent by
   its installed path instead of relying on `~/bin` being on PATH:
   `bash /storage/emulated/0/Download/ForgeBridge/install.sh && $HOME/bin/forge-termux-agent [--daemon]`
   (Reason: install.sh's `export PATH` only affects its own child shell — the
   bare `forge-termux-agent` after `&&` ran in the *parent* Termux shell, which
   hasn't re-sourced `.bashrc` → "command not found" on first install.)
   Updated: Java `command`/`setupCommand`/notes/reject/help/README, host
   `txCmdBox` + `TERMUX_AGENT_CMD` + reboot hint, i18n keys
   `tx.fdroidC2` / `tx.pathAgent` / `tx.stayHint` / `txs.failedStartAgent`
   in **all 6 languages**. Host `--daemon`-append regex still works (matches tail).
2. **Idempotent install.sh** — re-running is now a clean success:
   - `rm -f` before `cp` (replaces cleanly even if the agent binary is running — ETXTBSY)
   - `ALREADY` flag → "Already installed — updated: …" (exit 0 both paths)
   - **Fixed pre-existing bug:** `.bashrc` guard grepped `home/bin` (lowercase)
     but the appended line contains `$HOME/bin` → **every run appended a
     duplicate PATH line**. Guard now matches `HOME/bin`.
   - install.sh + agent echos print full `$BIN/forge-termux-agent` paths
3. Agent `VERSION` 1.0.0 → **1.1.0** (asset + Java builtin; heartbeat/status).

### Verified
- `bash -n` clean on asset + both decoded Java builtins
- Functional: 3× install.sh runs → exit 0, exactly ONE `.bashrc` PATH line,
  "Already installed — updated" on re-runs (HOME overridden to temp dir)
- APK contains agent v1.1.0 asset; host shows full-path command ×2; www ≡ assets

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.4 (134)
[ ] AI → Device bridges → Install agent → copy command → paste in fresh Termux:
    bash /storage/emulated/0/Download/ForgeBridge/install.sh && $HOME/bin/forge-termux-agent --daemon
    → works even on FIRST install (no PATH re-source needed)
[ ] Run install.sh again → "Already installed — updated: …" exit 0; ~/.bashrc has ONE PATH line
[ ] Test Termux → agent live (status version 1.1.0)
```

## Graphify knowledge graph (2026-08-23)

`forge/graphify-out/` — queryable knowledge graph of the project (1033 nodes / 2318 edges / 74 labeled communities; AST for Java/JS + LLM semantic layer for session.md/docs/samples; resource icons + duplicate assets host copy excluded by design; `recovered/` excluded by detect). Query with `graphify query "..."` from the project root. Provider: cheaperinference glm-5.3 via `~/.graphify/providers.json` — **no `extra_body`** (the gateway chokes on top-level `thinking` key: finish=length, empty content). Large-file extraction wedges at 600s read timeout → use `token_budget=6000` slices. Nested `graphify-out/graphify-out/` is a pipeline checkpoint artifact — harmless, don't ship.

## Release artifacts @ 2.7.4/134 (2026-08-23)

`release_forge.sh` from clean tree @ `e1f4931` — BUILD SUCCESSFUL (1m20s):

- `release-out/Forge-full-release.apk` (6.47 MB, F-Droid/website/sideload)
- `release-out/Forge-play-release.aab` (5.81 MB, Play Console)
- both copied to `/sdcard/Download/`; stamp `2.7.4/134 · e1f4931` in both
  (built after commit → sha is the real HEAD); APK v1-signed (CERT.RSA+MANIFEST);
  agent v1.1.0 asset inside; 3 dex.

Includes: termux agent python auto-install (2.7.2) + full-path command &
idempotent install.sh (2.7.4).

## Forge chat progress feed for agentic builds (2026-08-24)

**2.7.10 / versionCode 140** (from 2.7.8/138). Host-only, no native Java.

### What the user asked for
Mini status messages in the chat while forging — like the mumbo-jumbo line,
but **persistent/accumulating** (turns, tool calls), all removed when the
result lands.

### What landed
- `.forge-progress-feed` container + `.progress-item` rows (CSS after the
  `.bubble.progress` rules): compact muted lines, left accent bar, fade-in,
  level variants `warn`/`ok`/`err`, per-event glyph icons
  (⚙ offered · 📄 write · 👁 read · 🗑 delete · ⚡ js · 🖼 image · 🧩 finish ·
  ✓ done · ↪ classic · ⚠ warn).
- `genProgress(text, level, icon)` — DOM-only feed (`forgeProgressItems` array,
  cap 80 with oldest-trim; never persisted into `chat`/draft).
  `clearForgeProgress()` removes all rows. `loopStatus()` = chat feed +
  AI-tab console (`loop · …`) in one call.
- Feed renders **above** the cycling ticker (inserted before
  `.bubble.progress`); re-appended by `renderChat` after rebuilds (hook at
  function end).
- Wired events: workspace offered · model chose single-shot · model chose
  workspace (LOOP.md) · fs_write/fs_delete · run_js ok/FAILED · gen_image ·
  finish assembled · done (rounds/files/html) · prose-reply nudge (warn).
- Cleared in `onSend` `finally` (success, error, Stop, watchdog-fail — all
  paths).

### Verified
- Gate PASS (`node --check`, parity, backticks, LOOP.md, docs baselines)
- DOM-shim unit test with real `querySelector('.a.b')` semantics: feed before
  ticker · 3 items → 3 rows (innerHTML reset) · level classes · clear removes
  feed but keeps ticker · 80-item cap
- Both flavor debug APKs built

Smoke (device pending):
```text
[ ] Flag ON → forge a big app → chat shows: ticker line + accumulating
    ⚙/📄/⚡/🧩 rows above it, one per loop event
[ ] Result lands (or Stop / error) → all progress rows disappear; ticker gone;
    chat shows only user + assistant bubbles
[ ] Flag OFF or model declines → '↪ model chose single-shot' row appears,
    cleared at settle — no other change
[ ] Flag ON + fail (e.g. run_js error) → ⚠ warn rows visible during build
```

## Agentic builder loop — workspace mode (2026-08-24)

**2.7.8 / versionCode 138** (from 2.7.6/136). Host-only, no native Java.

### Design (locked with user)
Mini-apps kept outgrowing the single-shot JSON payload (truncation class:
2.6.97 max_tokens, 2.6.96/99 extractJson rewrites, 2.7.0 reasoning
separation). Instead of a global mode switch, the builder framework is gated
by a **per-provider flag** and the **model decides per build** whether to use
it via a two-stage tool opt-in. Protocol lives in **LOOP.md**, an editable
asset — not baked into the system prompt.

### What landed
| Piece | Detail |
|---|---|
| Flag | AI settings: **Allow agentic builder loop** checkbox under the generation row (per-provider, `LS.agenticLoop = forge_agentic_loop_v1` map keyed by provider id; synced on provider switch; default **off**) |
| Opt-in | Flag on → system prompt gains ONE short BUILD OPTION paragraph + round 1 registers exactly ONE tool: `read_loop_md`. Model ignores it → round-1 content flows through the **classic path unchanged** (no extra API call). Model calls it → `LOOP.md` returned as tool result + full toolset registered (max 24 rounds) |
| LOOP.md | `www/LOOP.md` ≡ asset (synced by build_forge.sh; parity-checked by forge_check step 2; inline fallback constant if fetch fails). Protocol: workflow, assembly rules, tool reference, limits |
| Scratch FS | `fs_write/fs_read/fs_list/fs_delete` — ephemeral per-build Map, path-normalized (`..` stripped), caps 200 files / 10 MB per file / 64 MB total |
| JS runner | `run_js` — throwaway Web Worker (offline: fetch/XHR neutered; no DOM; 10 s hard cap + terminate; 256 KB code cap). Worker API: `api.list/readText/readBase64/write/print`; writes merge back into the workspace (caps enforced host-side) |
| Image gen | `gen_image` — wraps existing xAI `/images/generations` path; result stored as `images/gen_N.png` in the workspace (≤ 6 per build); remote URLs fetched via `fetchUrlAsDataUrl` |
| Assembly | `finish({title,summary,message,entry?})` → host-side assembly: inlines `<script src>`/`<link rel=stylesheet>` from workspace files, replaces `@asset("path")` tokens with data URLs (images >300 KB downscaled ≤768px JPEG). Library/backup/AA-share runtime contract **unchanged** — final app is still one self-contained html |
| Loop driver | `runBuilderLoop` — accumulates OpenAI-shaped messages (assistant.tool_calls + role:tool preserved by `normalizeChatMessages`; Gemini native converts to functionCall/functionResponse). Per-round `maxTokens = getGenMaxTokens()`, `jsonMode:'off'`, abort-signal honored. Prose-when-armed → one nudge; rounds exhausted → clear error telling user to simplify or flip the flag off |
| Console | `genLog` lines: `agentic loop armed`, `model opted in · LOOP.md N chars`, `loop · fs_write path · Nk`, `loop · run_js ok/FAILED`, `loop · gen_image …`, `loop · finish · assembled html Nk`, `agentic loop finished in N rounds · N files` |
| Watchdog | Loop runs inside `forgeApp` → existing generation watchdog (extend/fail popup) + FGS keep-alive + retry layer apply unchanged |
| i18n | en keys `ai.agenticLoop`, `ai.agenticLoopHint` (other langs fall back to en) |

### Safety / containment
- Worker: offline-only, no DOM, no ForgeHost, 10 s terminate — an infinite loop
cannot freeze the host UI.
- Classic fallback is structural: flag off (or model disinterest) → byte-for-byte
  the pre-2.7.8 code path.
- Assembly regexes built via `new RegExp` + `'</scr' + 'ipt>'` splices — no raw
closing-script-tag literal anywhere in host source (the gate enforces 1).

### Verified
- `forge_check.sh` + `forge_docs_check` PASS (incl. new LOOP.md parity check;
the gate caught two stray closing-tag literals in my own comments — fixed)
- `node --check` clean (951 KB module block)
- `builderAssemble` unit-tested from the real file source: script/style inline,
  remote CDN left as-is, `@asset` → data URL, missing-entry throws
- `BUILDER_WORKER_SRC` simulated in a VM: read/write/print/result, error stack,
  fetch neutered
- APK contains `assets/public/LOOP.md` (4377 B) + all builder refs

### Files
`www/index.html` + `www/LOOP.md` (+ assets sync), `android/app/build.gradle`
(2.7.8/138), `docs/api.md` (builder section + baseline), `docs/tools.md`
(baseline), `package.json`, `~/downloads/build_forge.sh` (LOOP.md sync),
`~/downloads/forge_check.sh` (LOOP.md parity step).

### Not in v1 (follow-ups)
- Reforge in workspace mode (seed FS with current app.html as reference)
- agenticLoop flag not yet in provider profiles → not in Drive settings backup
  (localStorage-only, like other gen settings)
- OPFS persistence across refine turns (workspace is per-build)

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.8 (138)
[ ] Flag OFF → Forge it tic-tac-toe → classic path, identical behavior
[ ] Flag ON (capable provider) → simple prompt → model skips read_loop_md →
    console 'model skipped read_loop_md · classic path' → builds classic
[ ] Flag ON → big prompt (Chat Pro) → console: opted in · LOOP.md · fs_write
    rounds · finish assembled html → app runs like any mini-app
[ ] Export/share/library-save of a workspace-built app works (single html)
[ ] Stop button aborts mid-loop; watchdog extend/fail popup works mid-loop
[ ] run_js infinite loop (ask model to compute while(true)) → tool errors at
    10 s, host UI stays responsive
```

## Max output tokens setting (2026-08-24)

**2.7.6 / versionCode 136** (from 2.7.4/134). Host-only, no native Java.

### Problem
Mini-app generation often failed on token output. 2.6.97 had hardcoded
`maxTokens: 32768` on the Forge-it/Reforge calls with no way to tune it:
- providers whose models cap below 32k can 4xx the param → auto retry drops
  it entirely → provider default (4k–8k) → `finish_reason: length` truncation
- models that support more never got the room. Either way the payload JSON
  gets cut mid-html and Forge-it fails.

### What landed
| Piece | Detail |
|---|---|
| Setting | **Max output tokens** input (`#genMaxTokens`) in the second cell of the generation row, directly beside *Max generation time (s)* |
| Range | default **32768**, clamped 1024–262144, step 1024 |
| Persistence | `LS.genMaxTokens = forge_gen_max_tokens_v1`; loaded in `loadPrefs`, saved in `savePrefs`, wired into the change/blur listener list |
| Helper | `getGenMaxTokens()` beside `getGenTimeoutSecs()` |
| Call sites | all 5 factory paths use it (forgeApp: gemini stream + OAI stream; reforge: gemini stream + non-stream fallback + OAI stream) — was hardcoded 32768 |
| Errors | truncation messages (stream `finish_reason=length`, non-stream twin, Gemini `MAX_TOKENS`, i18n `chat.failTruncated`) now say **“Raise Max output tokens (AI settings)…”** |
| Console | `forge start` / `reforge start` genLog lines append `· budget N tok` |
| i18n | en keys `ai.maxTokens`, `ai.maxTokensHint` (other langs fall back to en — same pattern as the 2.6.95 gen-timeout keys) |

### Files
`www/index.html` (+ assets sync), `android/app/build.gradle` (2.7.6/136),
`docs/api.md` + `docs/tools.md` baselines, `package.json`.

### Verified
- `forge_check.sh` + `forge_docs_check` PASS (syntax/parity/backticks/docs 2.7.6/136)
- Both flavor debug APKs built; APK assets contain the input, LS key, label
  (19 `genMaxTokens` refs)

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.6 (136)
[ ] AI tab → generation row: 'Max output tokens' 32768 beside 'Max generation time (s)'
[ ] Change to 65536 → persists across restart; hint line under the row explains it
[ ] Console: forge/reforge start shows 'budget 65536 tok'
[ ] Big app (Chat Pro prompt) builds; if truncated, error mentions Max output tokens
[ ] Provider that rejects large max_tokens still builds (auto retry without param)
```

## Ox Alpha (free) turn-key option (2026-08-25)

**2.7.12 / versionCode 142** (from 2.7.10/140). Host-only, no native Java.

### What the user asked for
Add **stealth/ox-alpha** (on cheaperinference) as a new **free** option on the Turn-key setup wizard.

- Model verified free beforehand: live chat test through the gateway returned `cost: 0.0`
  (`is_free: true`, discount 100%, vision/reasoning/streaming flags on).
- New `SETUP_PROVIDERS` entry `id: 'oxalpha'`, `providerId: 'cheaperinference'`,
  `turnkey: true`, badge **free**, positioned between the paid Cheaper Inference card and xAI.
  Reuses the builtin provider (same ir_live_ key flow) — no custom provider needed.
- `setupSaveAndTest`: new per-entry **`setupDefaultModel`** override — after Save & test the
  model field is set to `stealth/ox-alpha` (takes precedence over the builtin default glm-5.2;
  custom.defaultModel still first). The post-test refresh block doesn't clobber it (model not empty/grok).
- Other languages fall back to the English blurb/steps via `tf()` (established pattern).

### Not changed
Provider model seed lists (the earlier ox-alpha model-refresh was reverted at user request),
AAForge, visibility recipe, i18n marketing copy (turnkey note still lists "Google / Grok /
Groq" in prose — optional follow-up to mention Ox Alpha per language).

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.12 (142)
[ ] AI tab → Turn-key setup → 'Ox Alpha (free)' card with Free badge present
[ ] Pick it → guide steps show; paste ir_live_ key → Save & test → connected,
    brain = stealth/ox-alpha
[ ] Chat / Forge it works on the free model ($0 usage)
[ ] Existing paid Cheaper Inference card unchanged; other cards unaffected
```

## Turn-key Ox Alpha copy — all 6 languages (2026-08-25)

**2.7.14 / versionCode 144** (from 2.7.12/142). Host-only, no native Java.

Follow-up to the 2.7.12 turn-key card: the wizard prose that lists the free options now
mentions **Ox Alpha** in **en / es / fr / pt / ja / ko**:

| Key | Change |
|---|---|
| `setup.turnkeyNote` | pick list becomes "Google / Grok / Groq / Ox Alpha" (ko also fixes a pre-existing "Google / Groq / Groq" typo) |
| `ai.turnkeyHint` | free list adds "Ox Alpha (free model on Cheaper Inference)" (en HTML default + dict both updated) |
| `boot.aiTip` | boot tip adds Ox Alpha to the free options |
| `hints.i8` | tour line adds "Ox Alpha (free)" (en HTML default + dict) |

All 24 string replacements validated with exact-match counts before write (two strings exist
both as HTML defaults and dict values — both copies updated). Gate PASS; both flavor debug
APKs built @ 2.7.14/144.

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.14 (144)
[ ] Switch Language to es/fr/pt/日本語/한국어 → restart → wizard note, AI hint,
    boot tip and tour line each mention Ox Alpha
[ ] English unchanged except the added mentions (regression)
```

## Library folders — accordion tree, long-press menus, move picker (2026-08-25)

**2.7.16 / versionCode 146** (from 2.7.14/144). Host-only, no native Java.

Library redesigned per locked decisions: single **accordion tree** with a readonly
"Library" root; items are **single-line rows (icon + title + AA dot)** — tap opens,
long-press opens an action sheet. **No drag-and-drop**; a "Move…" sheet item opens a
folder picker instead.

Data model:
| Piece | Detail |
|---|---|
| `forge_lib_folders_v1` | `[{id, name, parentId}]`; apps get `folderId` (`null` = root) |
| `forge_lib_expanded_v1` | expanded folder ids; defaults to root expanded |
| Depth cap | 3 levels below root (`LIB_MAX_DEPTH`); enforced on create/move, violations re-parent to root on restore |
| Tombstones | app deletes via folder-delete reuse `addDriveTombstone`; folder ids also tombstoned |

Menus:
- App row: Change icon · Rename · **Summary** · Move · Pin to Home · Share · Reforge · Delete. Plain .html Export dropped from the library row (exportApp kept for preview).
- Folder row: Rename · Create subfolder · Move · Delete.
- Root row (long-press): Create subfolder only. Plus visible "＋ New folder" button in the lib-bar.

Folder delete with contents offers **A) delete everything** (confirm dialog, all descendant apps tombstoned) vs **B) move contents up one level**.

Backup compatibility: Drive manifest + ZIP backup now carry `folders:[{id,name,parentId}]` and per-app `folderId` in meta.json/manifest entries. Old backups restore flat to root unchanged; restores merge folders and sanitize (unknown parent → root, cycles broken, depth >3 re-parented).

i18n: 24 new `lib.*` keys × en/es/fr/pt/ja/ko. Gate PASS (28 host tools, docs baselines bumped); both flavor debug APKs built @ 2.7.16/146.

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.16 (146)
[ ] Library → readonly "Library" root row with total count; ＋ New folder creates level-1 folder
[ ] Long-press app → menu order icon/rename/summary/move/pin/share/reforge/delete; Summary shows blurb
[ ] Move → folder sheet lists tree indented incl. "Library (root)"; app relocates
[ ] Folder at depth 3 → Create subfolder disabled ("Depth limit reached")
[ ] Delete non-empty folder → sheet offers delete-all vs keep-contents-up; both work
[ ] Collapse root → everything hidden but root row persists
[ ] Drive backup+restore round-trips folders; old pre-folder backup restores flat
```

## Library tab slim-down — backup/restore live in AI tab, Kitchen sink in root menu (2026-08-25)

**2.7.18 / versionCode 148** (from 2.7.16/146). Host-only, no native Java.

| Change | Detail |
|---|---|
| Lib-bar | Removed "New folder", "Backup", "Restore", "Kitchen sink" buttons → bar is now Import + Refresh only |
| Root folder menu | Long-press "Library" = **Create subfolder · Kitchen sink** (reuses `installKitchenSink()`) |
| Backup/Restore | Full functionality (apps + settings + LLM profiles) lives in the AI tab's "Library backup" blade — its existing "Backup now" / "Restore…" buttons were already wired to the same `backupLibraryToDrive()` / `restoreLibraryFromDrive()`; status reports to the AI tab's driveStatusLine |
| i18n prune | Removed 6 unused keys × 6 languages (`lib.backup`, `lib.backupTitle`, `lib.restore`, `lib.restoreTitle`, `lib.kitchenTitle`, `lib.newFolder`); `lib.kitchen` kept for the root menu item |

Gate PASS; both flavor debug APKs built @ 2.7.18/148.

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.18 (148)
[ ] Library bar shows only Import + Refresh; no stray buttons
[ ] Long-press "Library" root → Create subfolder first, then Kitchen sink; both work
[ ] AI tab → Library backup → Backup now / Restore… still perform full backup/restore, messages appear on the AI tab status line
[ ] All languages: no missing-key fallbacks visible in library or AI tab after prune
```

## AI backup status shows apps + keys counts (2026-08-25)

**2.7.20 / versionCode 150** (from 2.7.18/148). Host-only, no native Java.

- `backupLibraryToDrive()` now persists `lastSettingsKeys` / `lastSettingsProfiles` into drive meta (hoisted out of the settings-try block).
- Persistent AI-tab status line (`driveStatusLine`) after connect/backup now reads:
  "Connected · {folder}/{root} · last backup: {when} · **{apps} apps · {keys} keys**" ("—" when never backed up).
  Localized in all 6 languages.
- The transient completion toast already reported "{up} uploaded, {same} unchanged, {total} in folder, settings ✓ (N profiles, M keys)" — unchanged.

Gate PASS; both flavor debug APKs built @ 2.7.20/150.

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.20 (150)
[ ] AI tab → Library backup → Backup now → done toast lists uploaded/unchanged + profiles/keys
[ ] After backup, status line shows "… · N apps · M keys" with real counts
[ ] Fresh install (never backed up): status line shows "— —" placeholders
[ ] Language switch: counts phrased per locale
```

## Chat button morphs to Stop; car icon beside Forge; donate hint trimmed (2026-08-25)

**2.7.22 / versionCode 152** (from 2.7.20/150). Host-only, no native Java.

| Change | Detail |
|---|---|
| "Forge is free" | Sentence removed from `ai.donateHint` (en HTML default + all 6 dict values); hint now just says the PayPal tip opens in your browser |
| 🚗 car icon | Moved from header top-right into the chat composer, directly left of the blue "Forge it" button (same id/handlers/`header.carTitle`) |
| Stop button | Removed entirely. `setBusy(true)` morphs the Forge button: grey `.btn.stop` style + spinner + localized "Stop"; click aborts (`abortController.abort()`). On finish/cancel `setBusy(false)` restores blue "Forge it" |

Gate PASS; both flavor debug APKs built @ 2.7.22/152.

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.22 (152)
[ ] Header top-right shows only 💡 and ＋; 🚗 sits next to the Forge button in the composer
[ ] Send a prompt → Forge button turns grey with spinner + "Stop"; tapping it aborts generation
[ ] After abort or natural finish → button back to blue "Forge it"
[ ] AI tab → donate line no longer claims "Forge is free" in any language
```

## Tour car-mode step + Stop aborts every LLM query (2026-08-25)

**2.7.24 / versionCode 154** (from 2.7.22/152). Host-only, no native Java.

| Change | Detail |
|---|---|
| Tour | New step 3 of 6 "Car mode 🚗" (chat tab) between Sketches and Run-the-App: explains the 🚗 toggle next to Forge it → car-ready app (Android Auto via AAForge), green/red readiness dot in library. Keys `tour.s2bTitle`/`tour.s2bBody` × en/es/fr/pt/ja/ko |
| Stop scope | New `abortAllLlmQueries()`: aborts `abortController` (chat/reforge generation) **plus** every controller in `streamAbortControllers` (mini-app ai.chat/ai.chatStream/agent rounds) plus `liveTranslate.translateAbort`. Wired to the morphed Stop button |

Gate PASS; both flavor debug APKs built @ 2.7.24/154.

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.24 (154)
[ ] Tour (or 💡 → Tour) shows 6 dots; step 3 = "Car mode 🚗" in each language
[ ] While a chat build runs, tap grey Stop → generation aborts
[ ] With a mini-app streaming AI + chat build at once, Stop kills both
```

## AI tab reorganization — 5 blades, model pills → combobox (2026-08-25)

**2.7.26 / versionCode 156** (from 2.7.24/154). Host-only, no native Java.

AI tab blade order is now:
1. **About Forge** — build info, description, **Language** selector, **☕ Support development** (moved here from AI settings card)
2. **AI settings** — unchanged structure minus console buttons/hint and donate block
3. **Console** — own blade: Console · Clear · Copy buttons + hint (overlay itself unchanged)
4. **Library backup** — as-is
5. **Device bridges** — as-is

Model picker: the pill row (`#modelPills`) is removed; all models (provider suggestions + fetched catalog after Refresh models) appear as datalist entries of the free-text model combobox.

Styling fix: `input[type="number"]` added to the themed input selector — Max generation time / Max output tokens now render white-on-dark like every other field.

Gate PASS; both flavor debug APKs built @ 2.7.26/156.

Smoke:
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.26 (156)
[ ] AI tab order: About Forge → AI settings → Console → Library backup → Device bridges
[ ] About Forge has Language select + ☕ Support development at bottom
[ ] Console blade opens the same mini-console overlay; badge still updates
[ ] Advanced: no pill row under Model; typing filters combobox entries; custom ids still accepted
[ ] Max generation time / Max output tokens fields are white text on dark background
```

## Agentic builder: fs_edit tool — in-place text edits (2026-08-26)

**2.7.28 / versionCode 158** (from 2.7.26/156). Host-only, no native Java.

### Why
The agentic builder loop could only *write whole files* (`fs_write`) — revising a
module meant resending the entire file, wasting tokens and risking truncation on
big files. `fs_edit` lets the model patch exact regions of an existing workspace
file with a handful of small `oldText→newText` replacements.

### Signature
```js
fs_edit({
  path: string,                  // existing workspace file (text only)
  edits: Array<{
    oldText: string,             // exact text to match in the ORIGINAL file
                                 //   (must be unique; no overlaps with other edits)
    newText: string,             // replacement text
  }>,
})
// → { ok:true, path, bytes, editsApplied, delta }
//   { ok:false, error } on any failure (missing match / non-unique / overlap /
//    binary file / missing file / empty edits) — no mutation on failure
```

### Semantics (made robust)
- All edits are validated against the **ORIGINAL** text before any change. A
  failure on edit `i` aborts the whole call with **no mutation** (atomic).
- `oldText` must match **exactly once** in the original file (non-unique →
  rejected with the match count).
- Match ranges must **not overlap** (sorted by start, checked pairwise).
- Edits apply by **position order** (descending), not array order, so the
  model can hand them in any order and indices stay valid.
- Binary files (base64 workspace entries) are refused with a clear error.
- `newText: ""` is a valid deletion (removes the matched span).
- Enforces the same per-file (10 MB) and workspace-total (64 MB) caps as
  `fs_write`; `updatedAt` refreshed.

### Where it landed
| File | Change |
|---|---|
| `www/index.html` (+ assets sync) | `edit(p, edits)` method on `builderNewFs()`; `fs_edit` entry in `BUILDER_TOOLS`; `case 'fs_edit'` in `builderExecTool` (logs `fs_edit path · N edits · Xk` via `loopStatus` 'write'/📄) |
| `www/LOOP.md` (+ assets sync) | Tool reference: `fs_edit` documented; workflow note “revise in place with fs_edit instead of rewriting whole” |
| `docs/api.md` | Builder section lists `fs_write / fs_edit / fs_read / fs_list / fs_delete` with one-line semantics; baseline bumped |
| `android/app/build.gradle`, `package.json`, `docs/tools.md` | version 2.7.26/156 → **2.7.28/158** |

### Verified
- `forge_check.sh` + `forge_docs_check` PASS (syntax, www≡assets parity incl.
  LOOP.md, backtick sanity, 1 raw `</script>`, 28 host tools, docs baselines
  2.7.28/158)
- 11-case functional unit test of the extracted `edit()` method: multi-edit,
  missing match, non-unique, overlap, binary refusal, empty edits, missing
  file, deletion span, enlarging edit, no-mutation-on-failure, out-of-order
  edits — all correct
- Both flavor debug APKs built; APK contains `fs_edit` in `LOOP.md` (2×) and
  `index.html` (10×: tool def, handler, workspace method, loopStatus, docs)

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.28 (158) · cb164ba
[ ] Flag agenticLoop ON (capable provider) → forge a multi-file app → console
    shows fs_edit path · N edits · Xk rows between fs_write rounds
[ ] Ask the model (in a follow-up refine) to tweak one function via fs_edit →
    only the targeted region changes; file size delta reported
[ ] Bad oldText (missing/non-unique/overlap) → console shows the clear error,
    file unchanged — model adapts on next round
[ ] Classic path (flag OFF or model skips read_loop_md) unchanged
```

## Aggressive Stop: abort every ongoing LLM query (2026-08-26)

**2.7.30 / versionCode 160** (from 2.7.28/158). Host-only, no native Java.

### Problem
The Stop button (2.7.24) aborted the signal but didn't actually take effect
promptly in several paths — Stop felt "not aggressive enough":

1. **Retry-layer sleeps ignored the abort signal.** `waitForVisible(30000)`
   and the backoff `setTimeout(1200*(i+1))` in `nativeHttp` / `fetchWithTransientRetry`
   blocked for up to ~30s when the app was backgrounded or in a transient-error
   retry cycle. The abort only took effect at the next loop iteration's guard,
   after the full sleep elapsed.
2. **Agent cancel flags were never set by Stop.** Mini-app `ai.agent` loops only
   check `agentCancelFlags` at round boundaries; between-round awaits (tool
   execution, host risk sheet `agentConfirmTool`, mini-app `onToolCall` veto)
   have no signal. Stop aborted the in-flight stream but the agent kept looping
   at the next round.
3. **Generation watchdog kept ticking.** The Extend/Fail card + 1s tick could
   linger during the abort unwind.

### Fix (`www/index.html`)

| Piece | Change |
|---|---|
| `waitForVisible(maxMs, signal)` | Now abortable: attaches an `abort` listener so it resolves early (`false`) when the signal fires — Stop no longer waits up to 30s on a backgrounded retry. |
| `abortableSleep(ms, signal)` | New helper. Backoff sleep that resolves EARLY (without throwing) when the signal aborts, so the retry loop's own `if (signal.aborted) throw AbortError` guard fires immediately instead of after the full 1.2s–2.4s backoff. |
| `nativeHttp` retry loop | Backoff + `waitForVisible` now pass `opts.signal` → Stop propagates through the non-stream fallback (`chatCompletions`, Gemini non-stream, `/responses`, cloud TTS) instantly. |
| `fetchWithTransientRetry` | Same — passes `init && init.signal` to both sleeps (STT multipart). |
| `abortAllLlmQueries` | Now aborts ALL five surfaces: (1) `abortController` (chat/reforge), (2) every `streamAbortControllers` entry (mini-app ai.chatStream/agent streams), (3) every `agentCancelFlags` entry → breaks the agent loop at the next round boundary, (4) `liveTranslate.translateAbort`, (5) `genWatchdog.stop()` → kills the Extend/Fail card + tick immediately. Logs `stop requested — aborting all LLM queries` to the AI-tab console. |

### Net effect
Stop now takes effect within ~tens of ms through the retry layer (was up to
~30s), and through the agent loop at the next round boundary (was: next round
after in-flight stream finished). The watchdog card + tick stop immediately.
The existing catch blocks (`'Stopped.'` / `t('reforge.cancelled')`) still drive
the UI as before.

### Caveat (unfixable at host level)
A native `CapacitorHttp.request` already in flight cannot be cancelled from
JS — the abort only prevents the JS layer from *waiting/retrying*. The in-flight
native call runs to its `readTimeout` (≥600s by design so the watchdog Extend
popup can work). The streaming path (`fetch(url, {signal})` + `reader.read()`)
is unaffected — its abort fires through the fetch signal. The retry-layer fix
above closes the post-native-call window; the during-native-call window remains
for non-stream fallbacks only.

### Verified
- `forge_check.sh` + `forge_docs_check` PASS (2.7.30/160, parity, 28 tools)
- Unit test of `waitForVisible`/`abortableSleep`: 6/6 — early-resolve on abort
  (~50ms vs 10–30s), normal resolve, already-aborted instant, no-signal
  backcompat, not-hidden fast-path
- End-to-end retry-loop simulation: abort during a backoff sleep throws
  `AbortError` in ~65ms (was ~1.2–30s); full backoff path still exercised
  when no abort
- Both flavor debug APKs built; APK contains `abortableSleep` + agent-flag loop
  + `genWatchdog.stop()` in `abortAllLlmQueries`

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.30 (160) · b585ade
[ ] Forge it a big app → mid-generation tap grey Stop → generation stops within
    ~1s; chat shows 'Stopped.' (not a long hang then stop)
[ ] Background the app mid-generation → return → tap Stop fast (no 30s wait)
[ ] Mini-app running ai.agent multi-round + chat Forge-it at once → Stop kills
    both; agent breaks at next round boundary
[ ] Extend/Fail popup, if visible, hides immediately on Stop
[ ] Reforge Stop → 'Reforge cancelled' fast
```

## Stop confirmation + abandon (discard late in-flight results) (2026-08-26)

**2.7.30 / versionCode 160** (same versionCode; host-only refinement of the
Stop path above). Host-only, no native Java.

### What the user asked for
1. **Confirmation dialog on the Stop button** so the user can change their mind
   (a stray tap no longer kills a 2-minute build).
2. **Abandon the current LLM query the moment Stop is confirmed.** The native
   HTTP may continue (a `CapacitorHttp.request` in flight can't be cancelled
   from JS), but if we abandon it + clean up all the trigger events, it's as
   good as aborted for the user experience.

### What landed (`www/index.html` + assets sync)

| Piece | Detail |
|---|---|
| `forgeConfirmDialog({title,body,okLabel,okClass})` | New promise-returning confirm sheet (Cancel / Ok), reuses the `.tour-overlay`/`.tour-card` pattern. Ok button styled `.btn small danger` for the destructive action. |
| Stop button | Tapping grey Stop while busy now opens the confirm (`chat.stopTitle` / `chat.stopBody` / `chat.stopOk`); Cancel returns to the busy state unchanged, confirming calls `abandonCurrentGeneration()`. |
| `abandonCurrentGeneration()` | The "abandon" primitive. Sets `genAbandoned=true`, calls `abortAllLlmQueries()` (the 5-surface abort from the prior land), stops the cycling ticker (`activeForgeProgress.stop()`), clears the progress feed, restores the Forge button to idle (`setBusy(false)`), and does **mode-specific** user-facing cleanup: **forge** → `addMessage('assistant','Stopped.')`; **reforge** → restore the pre-reforge preview snapshot + `setPreviewStatus('Reforge cancelled')`. The UI is fully detached from the in-flight task immediately. |
| **Late-result discard** (`genAbandoned` gate) | `onSend`/reforge `try`/`catch` now gate on `const stale = genAbandoned \|\| myToken !== genToken`. A stale generation's late-arriving result (native HTTP that finally completed) is **discarded** — never `loadPreview`/`addMessage`/`showTab`, never a duplicate "Stopped." message (the catch only logs). |
| **Generation token** (`genToken`) | Monotonically incremented at the start of each forge/reforge. The `finally` only mutates shared state (`setBusy`/`abortController`/`bgStop`/`clearForgeProgress`/`genMode`) when `myToken === genToken` — a **stale** finally (Stop → immediately send a new prompt) skips the reset so it cannot clobber the newer generation's `busy=true`. Local-safe cleanup (`watchdog.stop()` idempotent, the local `forgeProgress.stop()`) still runs. |
| Watchdog "Fail now" | Routed through `abandonCurrentGeneration()` (the popup is itself the confirm); gains the full 5-surface abort + UI detach (previously only aborted `abortController`). `genFailedByTimeout=true` first so the mode message reads as the time-limit variant. |
| i18n | en keys `chat.stopTitle`/`stopBody`/`stopOk` added; other langs fall back to en via `tf()` (established pattern). |

### The race this guards
Naïve "abandon" has a classic late-arrival race: user stops gen A → UI resets →
user sends a new prompt (gen B starts, `busy=true`) → gen A's native HTTP
finally resolves → A's `finally` runs `setBusy(false)` + `loadPreview(A)` and
clobbers B. The `genToken` guard (A's finally skips the reset because
`myToken !== genToken`) + the `stale` gate (A's try discards because
`myToken !== genToken`) close it: A's late result is ignored and B's state is
untouched.

### Caveat (unchanged from prior land)
A native `CapacitorHttp.request` already in flight runs to its readTimeout —
that's irreducible from JS. The abandon makes the *user experience* instant
(button idle, "Stopped." shown, progress cleared) and guarantees the late
response is discarded; it does not kill the native socket. The streaming path
(`fetch(url,{signal})` + `reader.read()`, which Forge-it uses) aborts promptly
as before.

### Verified
- `forge_check.sh` + `forge_docs_check` PASS (2.7.30/160, parity, 28 tools)
- 10/10 race-discard unit tests pass: normal load, stream-abort msg, abandon+
late-resolve discard, abandon+late-reject no-dup-msg, **Stop→new-prompt race**
(A discarded, B owns state, A finally skipped), **in-flight B keeps busy=true**
when A finally runs, consecutive normals both load
- Both flavor debug APKs built; APK contains `forgeConfirmDialog`,
  `abandonCurrentGeneration`, `let genToken`, the `stale` gate, `chat.stopTitle`

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.30 (160) · f980a04
[ ] Forge it a big app → tap grey Stop → confirm dialog (Stop generation?) →
    Cancel → generation CONTINUES (button back to grey Stop, build proceeds)
[ ] Same → confirm Stop → UI resets to idle immediately, chat shows 'Stopped.';
    the in-flight request, when it eventually completes, does NOT load a preview
    or switch tabs (discarded)
[ ] Stop → immediately type a new prompt → Forge it → new build runs; the OLD
    build's late result is discarded (no clobber: new build's preview is what lands)
[ ] Reforge → Stop confirm → preview restored to original, 'Reforge cancelled'
[ ] Watchdog Extend/Fail popup → Fail now → same abandon behavior (no extra confirm)
[ ] Console: 'generation abandoned — UI detached from in-flight request'
```

## Remote-updatable turn-key config; remove Ox Alpha (no longer free) (2026-08-26)

**2.7.32 / versionCode 162** (from 2.7.30/160). Host-only, no native Java.

### What changed
- **`SETUP_PROVIDERS` catalog → `www/turnkey-config.json`** (canonical, git-served; also shipped as an Android asset). The compiled-in `SETUP_PROVIDERS_BUILTIN` JS array in `index.html` is kept byte-deep-equal to the JSON by `forge_check.sh` (new parity step, like `LOOP.md`).
- **Boot resolution** (`initSetupProviders`): compiled-in → localStorage cache from a prior remote fetch → fresh `GET` of the git raw URL. An open setup wizard re-renders when a newer remote list lands. Malformed/hostile payloads are rejected by `validateSetupConfigPayload` (≤50 entries, kind/field checks); cache/compiled-in is used instead so the wizard never breaks.
- **Ox Alpha removed** — `stealth/ox-alpha` on cheaperinference is no longer free, so its turn-key card is gone. Stripped from `ai.turnkeyHint` / `boot.aiTip` / `hints.i8` / `setup.turnkeyNote` across en/es/fr/pt/ja/ko.
- `build_forge.sh` + `release_forge.sh`: sync `turnkey-config.json` to assets.
- `docs/api.md`: easy-setup remote-config section; baselines → 2.7.32/162.

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.32 (162) · b090660
[ ] AI tab → Turn-key setup → no Ox Alpha card (Gemini / Groq / Groq + paid Cheaper Inference)
[ ] Wizard still renders if git fetch fails (falls back to compiled-in/cache)
[ ] forge_check.sh turnkey-config.json www==assets step PASS
```

## web_fetch readability extraction (deferred #10) (2026-08-26)

**2.7.34 / versionCode 164** (from 2.7.32/162). Host-only, no native Java.

Closes deferred item #10 from the 2.6.54 improvement batch (`toolsWebFetch` did raw HTTP get + HTML strip → near-empty on JS-rendered pages).

### What landed
- `toolsExtractReadable()` — DOMParser-based (safe: detached docs don't run scripts) Readability-style extraction. Strips boilerplate (nav/footer/aside/header/forms/sidebars/ads/`aria-hidden`); prefers an explicit `<article>`/`<main>`/`[role=main]`/`#content`/`.post-content`/`.entry-content` container; falls back to text-density scoring of div/section candidates (`text length * (1 - link ratio)`, rejects >50%-link blocks so nav lists don't win). Walks the chosen root preserving block structure (`p/div/li/h1-6/blockquote/pre`) as newlines; prepends `<title>` + meta/og description if not already in the body.
- Wired into `web_fetch` `'text'` path: try readability first, fall back to the existing `toolsStripHtml` stripper when the page isn't an article (returns `null` on SPA shells / short non-content). New `'extracted:true'` flag on the result tells callers which path ran. Tool description updated.
- No regression for non-article pages (stripper path unchanged).

### Verified
- 16/16 unit tests pass (jsdom): article extraction, SPA-shell rejection, div-soup scoring picks main + excludes sidebar/ads, link-list rejection, short-article acceptance, clamp respected, stripHtml unchanged.
- `docs/tools.md` + `api.md` baselines → 2.7.34/164.

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.34 (164) · 21207ca
[ ] Forge Chat: "Fetch this url: <news article>" → web_fetch returns clean article
    text (extracted:true), not a nav-link soup
[ ] "Fetch this url: <SPA shell>" → falls back to stripHtml (no extracted flag), no crash
```

## Idempotent Termux agent startup (2026-08-26)

**2.7.36 / versionCode 166** (from 2.7.34/164). Native assets + Java builtins; no host JS.

### Problem
The agent (2.7.4) started a fresh daemon on every `.bashrc` auto-start + manual launch — restart churn, and two shells launching at once could race. Re-running install.sh also `cp -f` over a running agent binary (ETXTBSY).

### What landed
- **Agent v1.1.0 → v1.2.0**; new `FORGE_AGENT_VERSION` env tag identifies the running version.
- **`ensure_single_agent`** — idempotent startup. A **same-version** live agent for this root/port is a no-op ("already running"); only **older-version** agents are stopped. Three lookup strategies, all guarded by `agent_process_matches` (matches `FORGE_BRIDGE_ROOT` + `FORGE_AGENT_PORT` + python cmdline — **never kills unrelated Python processes**): (1) `agent.json` recorded pid, (2) `/proc` scan for matching env, (3) port-listener scan via `/proc/net/tcp` + fd-inode match (last-resort when `agent.json` is stale).
- **`acquire_start_lock`** — `mkdir`-based lock serializes concurrent launches (.bashrc auto-start + manual); recovers only demonstrably-stale locks (dead pid). Makes `.bashrc` auto-start safe and cheap.
- **`install.sh`** — `copy_if_changed` (skip copy when identical → avoids ETXTBSY on a running agent); eager python install moved into `install.sh` too (was agent-only); idempotent `.bashrc` PATH line.
- Java `TermuxBridgePlugin` builtin strings kept in sync.

### Verified
- `bash -n` clean on asset + decoded Java builtins; APK contains agent v1.2.0 asset.
- Gate PASS; both flavor debug APKs built @ 2.7.36/166.

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.36 (166) · 61ef99e
[ ] Fresh Termux: install.sh + forge-termux-agent --daemon → "already running" on a
    second launch (same version) — no restart churn
[ ] Older agent running → launch detects version mismatch → stops old → starts new
[ ] Two shells launch at once → start lock serializes → one agent wins
[ ] install.sh re-run while agent live → no ETXTBSY (copy_if_changed skips)
```

## Agentic Reforge + session-persistent workspace + agenticLoop in Drive backup (2026-08-26)

**2.7.38 / versionCode 168** (from 2.7.36/166). Host-only, no native Java.

Lands the three follow-ups listed under "Not in v1 (follow-ups)" in the 2.7.8 agentic-builder section.

### 1 — Reforge in workspace mode
`reforgeAppWithAi` calls `runBuilderLoop` when `isAgenticLoopEnabled()`, seeding the workspace with the existing `app.html`. The reforge system prompt gains a `BUILD OPTION (agentic reforge)` paragraph directing the model to `read_loop_md` + use the workspace tools, preserve behavior, then `finish`. The classic fallback (`built.classicRaw`, when the model never opts in) flows into the existing streaming parse path — the Gemini/OAI stream branches now guard on `raw == null` so a builder-produced `classicRaw` is reused rather than re-fetched.

### 2 — Session-persistent workspace
`activeBuilderFs` / `activeBuilderOwner` (keyed by `currentApp?.id || '__new__'`) replace the per-build ephemeral `Map`. The workspace now **survives refine/Reforge turns for the same app** and is cleared only when **`+`** starts a new Forge environment (`newChat` resets both). `runBuilderLoop` reuses the live fs for the owner and seeds only on a fresh workspace (`!fs.count()`), so a second reforge turn reuses the accumulated files instead of re-seeding.

### 3 — `agenticLoop` flag in Drive settings backup
`getAgenticLoopMap()` is added to the backup bundle; the restore-merge path persists `remoteAgenticLoop` to `localStorage` + calls `syncAgenticLoopCheckbox()`. Older backups without the field leave local preferences intact. The flag now round-trips through Drive like the other gen settings (was localStorage-only).

### Verified
- `forge_check.sh` + `forge_docs_check` PASS (syntax, www≡assets incl. LOOP.md/turnkey-config.json, backtick sanity, 1 raw `</script>`, 28 host tools, docs baselines 2.7.38/168).
- `docs/api.md` builder section updated (session-persistent wording + Reforge note); `docs/tools.md` + `api.md` baselines + `package.json` → 2.7.38/168.

Smoke (device pending — no adb at build time):
```text
[ ] adb install -r ~/downloads/Forge-debug-rebuilt.apk → About v2.7.38 (168)
[ ] Flag agenticLoop ON → Reforge an existing app → console: "agentic loop armed" ·
    workspace seeded with index.html · fs_write/fs_edit rounds · finish assembled
[ ] Reforge the SAME app again (turn 2) → workspace reused (no re-seed); only deltas
    written
[ ] + (new chat) → workspace cleared; next forge/reforge starts fresh
[ ] Backup → restore on a second device → agenticLoop flag survives (checkbox state
    restored per provider)
[ ] Flag OFF → Reforge classic path unchanged (raw == null → streaming parse as before)
[ ] Classic fallback: model skips read_loop_md → built.classicRaw → existing parse path
```
