# Forge (phone) session log — LOCKED

## ⛔ INVARIANT
**Never delete folders without explicit user permission.** See [`INVARIANTS.md`](INVARIANTS.md).

---

## Status (LOCKED baseline 2026-08-07 · host restored 2026-08-10 · refreshed 2026-08-19 @ 2.6.72/102 — session closed)

| Field | Value |
|--------|--------|
| Package | `com.forge.live` |
| Version | **2.6.72 / versionCode 102** (edge-to-edge insets fix, device-verified 2026-08-19; prior 2.6.71/101 decor-listener, 2.6.70/100 attempt, 2.6.69/99 SDK-36 migration, 2.6.68/98 insets v1, 2.6.67/97 timeouts, 2.6.66/96 FGS keep-alive, 2.6.61/91 Play split, 2.6.60/90 slim SYSTEM_PROMPT)
| **Original APK (preserved, untouched)** | `~/downloads/Forge-debug.apk` |
| **Canonical Gradle APK** | **`~/downloads/Forge-debug-rebuilt.apk`** |
| Also | `/sdcard/Download/Forge-debug-rebuilt.apk` |
| Source | Reconstructed from APK (JADX + assets + Capacitor 6) |
| Build | `bash ~/downloads/build_forge.sh` → `assembleDebug` |
| Install | `adb install -r ~/downloads/Forge-debug-rebuilt.apk` |
| **Host `www/index.html`** | Canonical host (+ AI tools/attachments + liveTranslate + **Drive backup**) — keep in sync with assets |
| **Last rebuild** | **2026-08-19 — 2.6.72/102 edge-to-edge insets fix (margins not padding), DEVICE-VERIFIED** (commit `e2b77a2`) · 2026-08-18 — 2.6.69/99 SDK-36 migration (`5293411`) · 2026-08-18 — 2.6.66/96 FGS keep-alive
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
