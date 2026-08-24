# Graph Report - forge  (2026-08-23)

## Corpus Check
- 53 files · ~294,310 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1033 nodes · 2318 edges · 74 communities (58 shown, 16 thin omitted)
- Extraction: 96% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 81 edges (avg confidence: 0.81)
- Token cost: 56,531 input · 42,989 output

## Community Hubs (Navigation)
- Native Media & Phone Bridges
- Permission-Gated Bridges
- Audio Routing & TTS
- Jobs & Termux Scheduling
- ForgeHost API Surface (docs)
- Apps Bridge Discovery
- CameraX & QR Activities
- Build & Release Runbook
- Drive Backup Bridge
- MainActivity & Runner Intents
- Notify & Shortcuts
- Background FGS Service
- Capacitor Dependencies
- Camera Media Normalize Chain
- Host Web App & i18n Assets
- Open-With HTML Bridge
- LLM Tools Registry
- Mini-App Voice & Mic APIs
- SMS Conversation Copy App
- Version & Gate Tooling
- AI Networking & FGS Refcount
- Forge-it Chat & Reforge
- Live Translate Pipeline
- Mini-App Tool Exec
- Bridge Docs Crosslinks
- takePhoto Reliability Chain
- Chat Attachments
- Chat Turn Engine
- Generation Watchdog
- Contacts/Radio/Tools Docs
- Permissions Bridge Patterns
- Legacy APP_TOOLS Loop
- AAForge & Car Assist Links
- Streaming & Agent Loop
- Capacitor Native Bridge JS
- AI Providers & Catalog
- Chat UI Components
- Termux Agent Script
- i18n Salvage Artifacts
- Car Assist Storage
- Gradle Wrapper
- Edge-to-Edge Insets Fix
- AI Call Timeouts
- Mini-App Console Hook
- SMS Permission Auto-Request
- i18n Runtime Lookup
- Termux install.sh
- Capabilities Surface
- Drive Tombstones & AA Scan
- Project Meta-Docs
- Live Translate Auto-Detect
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 61
- Community 62
- Community 63
- Community 64
- Community 65
- Community 70
- Community 71

## God Nodes (most connected - your core abstractions)
1. `TermuxBridgePlugin` - 48 edges
2. `PhoneBridgePlugin` - 47 edges
3. `MicBridgePlugin` - 40 edges
4. `AppsBridgePlugin` - 39 edges
5. `TtsBridgePlugin` - 31 edges
6. `DriveBridgePlugin` - 30 edges
7. `CameraBridgePlugin` - 25 edges
8. `AudioRouteHelper` - 24 edges
9. `window.ForgeHost bridge (alias window.forge)` - 23 edges
10. `AudioRouteBridgePlugin` - 20 edges

## Surprising Connections (you probably didn't know these)
- `Forge Prompt — Reforge Chat (CameraX)` --semantically_similar_to--> `Chat View (#view-chat)`  [INFERRED] [semantically similar]
  samples/Forge_Prompt_Reforge_Chat_CameraX.md → www/index.html
- `Chat View (#view-chat)` --references--> `ForgeHost.ai.chat (Reforge Chat)`  [AMBIGUOUS]
  www/index.html → samples/Forge_Prompt_Reforge_Chat_CameraX.md
- `Preview View (#view-preview)` --conceptually_related_to--> `Forge Chat Mini-App (specified)`  [AMBIGUOUS]
  www/index.html → samples/Forge_Prompt_Reforge_Chat_CameraX.md
- `Forge Host LLM Tools Registry (docs/tools.md)` --references--> `HOST_TOOL_REGISTRY`  [INFERRED]
  docs/tools.md → session.md
- `Forge Host API Reference` --references--> `ForgeHost — Host JS Bridge API`  [INFERRED]
  docs/api.md → session.md

## Import Cycles
- None detected.

## Communities (74 total, 16 thin omitted)

### Community 0 - "Native Media & Phone Bridges"
Cohesion: 0.05
Nodes (15): AudioRouteBridgePlugin, JSObject, Override, MicBridgePlugin, JSObject, PhoneBridgePlugin, android.bluetooth.BluetoothAdapter, android.database.Cursor (+7 more)

### Community 1 - "Permission-Gated Bridges"
Cohesion: 0.07
Nodes (17): BackgroundForgePlugin, CameraBridgePlugin, JSObject, FilesBridgePlugin, JSObject, QrBridgePlugin, android.content.SharedPreferences, android.graphics.Bitmap (+9 more)

### Community 2 - "Audio Routing & TTS"
Cohesion: 0.07
Nodes (15): Override, AudioRouteHelper, JSArray, JSObject, JSObject, Override, TextToSpeech, TtsBridgePlugin (+7 more)

### Community 3 - "Jobs & Termux Scheduling"
Cohesion: 0.08
Nodes (13): android.app.PendingIntent, ForgeJobReceiver, Override, JobBridgePlugin, CommandSpec, BroadcastReceiver, Intent, JSObject (+5 more)

### Community 4 - "ForgeHost API Surface (docs)"
Cohesion: 0.05
Nodes (44): ForgeHost.ai.listProviders(), ForgeHost.camera.pickPhoto(), ForgeHost.camera.takePhoto(), ForgeHost.permissions.request(), ForgeHost.storage.get(), ForgeHost.toast(), ForgeHost.tools.hint(), Car Assist appendBubble() (+36 more)

### Community 5 - "Apps Bridge Discovery"
Cohesion: 0.12
Nodes (12): AppsBridgePlugin, Intent, JSArray, JSObject, android.content.ComponentName, android.content.Intent, android.content.pm.ApplicationInfo, android.content.pm.PackageInfo (+4 more)

### Community 6 - "CameraX & QR Activities"
Cohesion: 0.08
Nodes (22): android.app.Activity, CameraXCaptureActivity, Override, Override, QrScanActivity, android.graphics.SurfaceTexture, android.hardware.Camera, android.view.TextureView (+14 more)

### Community 7 - "Build & Release Runbook"
Cohesion: 0.08
Nodes (42): android/app/build.gradle — Version & Build Config, src/play/AndroidManifest.xml — Play Flavor Manifest, build_forge.sh — Debug Build Script, forge_bump.py — Version Bumper, forge_check.sh — Pre-Build Gate, Forge-debug.apk — Original User APK (never modify), Forge-debug-rebuilt.apk — Canonical Debug APK, forge_docs_check.sh — Docs Drift Guard (+34 more)

### Community 8 - "Drive Backup Bridge"
Cohesion: 0.20
Nodes (3): DriveBridgePlugin, JSObject, androidx.documentfile.provider.DocumentFile

### Community 9 - "MainActivity & Runner Intents"
Cohesion: 0.15
Nodes (8): Override, View, MainActivity, Override, RunActivity, android.os.Bundle, com.getcapacitor.BridgeActivity, Insets

### Community 10 - "Notify & Shortcuts"
Cohesion: 0.15
Nodes (6): JSArray, Override, NotifyBridgePlugin, Intent, Override, ShortcutBridgePlugin

### Community 11 - "Background FGS Service"
Cohesion: 0.17
Nodes (7): android.app.Notification, android.app.Service, BackgroundForgeService, Intent, Override, android.os.IBinder, WakeLock

### Community 12 - "Capacitor Dependencies"
Cohesion: 0.10
Nodes (20): @capacitor/android, @capacitor/app, @capacitor/core, @capacitor/filesystem, @capacitor/keyboard, @capacitor/preferences, @capacitor/share, @capacitor/status-bar (+12 more)

### Community 13 - "Camera Media Normalize Chain"
Cohesion: 0.15
Nodes (21): CameraX In-Process Capture, ForgeHost.ai Bridge (chat/listProviders), ForgeHost.apps Bridge (list_apps/list_activities/launch_app), ForgeHost.camera Bridge (takePhoto/pickPhoto/setImg/normalize/requestPermission), ForgeHost.camera.pickPhoto, ForgeHost.camera.takePhoto, ForgeHost.files.pick, ForgeHost.http.inlineHtml (+13 more)

### Community 14 - "Host Web App & i18n Assets"
Cohesion: 0.14
Nodes (19): assets/public/index.html — Android Assets Host Copy, FORGE_I18N — Inline Host Localization Dict, forge-upload.jks — Release Upload Keystore, release_forge.sh — Release Build Script, www/index.html.with-live-backup — WIP Live-Translate Host Dump, Forge Web App (index.html), Immersive Run Mode Exit Button (.app-exit), Forge Host Web App (www/index.html) (+11 more)

### Community 15 - "Open-With HTML Bridge"
Cohesion: 0.21
Nodes (4): JSObject, Override, OpenHtmlBridgePlugin, PendingHtml

### Community 16 - "LLM Tools Registry"
Cohesion: 0.11
Nodes (19): BYO-AI provider model, Optional Google Drive / folder backup, Forge app (com.forge.live), xAI (Grok) provider, ForgeHost.ai.agent() host loop, ForgeHost.ai.chat(), bridge_call tool, ForgeHost bridge (+11 more)

### Community 17 - "Mini-App Voice & Mic APIs"
Cohesion: 0.15
Nodes (14): captureUtterance(), ForgeHost.ai (chat, transcribe, tts, listVoices), ForgeHost.ai.listVoices, ForgeHost.ai.transcribe, ForgeHost.ai.tts, ForgeHost.mic (listen/record/stop), ForgeHost.mic.listen, ForgeHost.tts (native speak/stop/listVoices) (+6 more)

### Community 18 - "SMS Conversation Copy App"
Cohesion: 0.18
Nodes (17): ForgeHost.clipboard.write, ForgeHost.share, ForgeHost.sms.read, ForgeHost.toast, SMS Conversation Copy mini-app, copyOut, digits, direction (+9 more)

### Community 19 - "Version & Gate Tooling"
Cohesion: 0.15
Nodes (17): Settings → About Forge, android/app/build.gradle, build_forge.sh, full/play distribution flavors, forge-build.json build stamp, forge_bump.py version bumper, forge_check.sh validation gate, Forge-debug.apk (original, untouched) (+9 more)

### Community 20 - "AI Networking & FGS Refcount"
Cohesion: 0.12
Nodes (14): Forge_Chat.html (mini-app chat surface), BackgroundForgeService (dataSync foreground service), aiFgsAcquire (unified FGS refcount), bgStart/bgStop (Forge-it / Reforge), chatCompletions(), chatCompletionsStream, fetchUrlAsDataUrl, isTransientNetworkError (+6 more)

### Community 21 - "Forge-it Chat & Reforge"
Cohesion: 0.15
Nodes (13): buildReforgeUserPrompt — Reforge Prompt Builder, chatCompletionsStream, extractJson, FORGE_PROGRESS_LINES (28 entries), forgeApp chat host, forgeFailMessage, geminiStreamGenerateContent, onSend() (+5 more)

### Community 22 - "Live Translate Pipeline"
Cohesion: 0.15
Nodes (11): Forge_AI_Chat sample HTMLs, Forge_Live_Translate.html (mini-app draft), ForgeHost.ai.chat, ForgeHost.ai.liveTranslate, ForgeHost.ai.transcribe / ai.stt, ForgeHost.mic.startStream/stopStream, Kitchen sink lab (app_kitchensink), Live Translate bidirectional conversation mode (+3 more)

### Community 23 - "Mini-App Tool Exec"
Cohesion: 0.15
Nodes (12): executeTool(), ForgeHost.apps (list/listActivities/launch), ForgeHost.apps.launch, ForgeHost.apps.list, ForgeHost.apps.listActivities, ForgeHost.contacts (list/search), ForgeHost.contacts.list, ForgeHost.http (GET) (+4 more)

### Community 24 - "Bridge Docs Crosslinks"
Cohesion: 0.18
Nodes (13): AudioRouteBridge + AudioRouteHelper, CameraBridgePlugin (takePhoto), DriveBridge (SAF library backup), Forge_Chat.html — Chat Mini-App with Host Tools, ForgeHost — Host JS Bridge API, ForgeHost.audio route API, MainActivity.java, Menu_Translator.html — Menu Vision Mini-App (+5 more)

### Community 25 - "takePhoto Reliability Chain"
Cohesion: 0.17
Nodes (12): b64ToBlobUrl, CameraBridgePlugin — Camera Native Bridge, CameraBridge.takePhoto, CameraXCaptureActivity, cleanupTempPhotos, extractAppId, __forgeNormalizeMediaResult, Menu_Translator.html + prompt (+4 more)

### Community 26 - "Chat Attachments"
Cohesion: 0.20
Nodes (11): Forge Prompt — Rich AI Chat (Forge Chat), Forge Chat mini-app, ForgeHost.ai.chat, ForgeHost.ai.listProviders, ForgeHost.camera.pickPhoto, ForgeHost.camera.takePhoto, ForgeHost.files.pick, ForgeHost.http.inlineHtml (+3 more)

### Community 27 - "Chat Turn Engine"
Cohesion: 0.18
Nodes (6): buildToolList(), fn() tool schema helper, ForgeHost.getCapabilities, normalizeChatResult(), runAssistantTurn(), Text-Protocol Tool Formats

### Community 28 - "Generation Watchdog"
Cohesion: 0.20
Nodes (11): android/.../assets/public/index.html, genLog, getGenTimeoutSecs, www/index.html.with-live-backup, loadPrefs, Locked product baseline (2.6.72/102), pushMiniConsole, savePrefs (+3 more)

### Community 29 - "Contacts/Radio/Tools Docs"
Cohesion: 0.24
Nodes (11): buildReforgeUserPrompt, docs/api.md ForgeHost bridge reference, docs/tools.md LLM tool catalog, Forge Chat Mini-app, forge_docs_check.sh docs drift guard, ForgeHost.contacts API, ForgeHost.radio API, ForgeHost.tools.list (+3 more)

### Community 30 - "Permissions Bridge Patterns"
Cohesion: 0.22
Nodes (9): ForgeHost JS Bridge (window.ForgeHost), ForgeHost.device.openSettings / openAppSettings, ForgeHost.permissions Bridge (request/get/check), ForgeHost.permissions.request, SMS Conversation Copy (mini-app), ensurePerm, ForgeHost Bridge (SMS Copy app), ForgeHost.permissions (+1 more)

### Community 31 - "Legacy APP_TOOLS Loop"
Cohesion: 0.25
Nodes (9): APP_TOOLS (OpenAI tool definitions), executeTool, ForgeHost.apps.launch, ForgeHost.apps.list, ForgeHost.apps.listActivities, normalizeChatResult, runChatTurn, scrapeToolsFromText (+1 more)

### Community 32 - "AAForge & Car Assist Links"
Cohesion: 0.31
Nodes (9): Forge Prompt — Car Voice Assistant (Car Assist), AAForge (Android Auto host), Car Assist Mini-App, window.ForgeHost API, ForgeHost.ai.chat, ForgeHost.ai.listProviders, ForgeHost.storage, Phone Forge host (+1 more)

### Community 33 - "Streaming & Agent Loop"
Cohesion: 0.33
Nodes (7): agentAskMiniAppToolCall() mini-app veto gate, agentConfirmTool() risk sheet modal, chatCompletionsStream() OAI SSE, ForgeHost.ai.agent tool-call loop, ForgeHost.ai.cancel, ForgeHost.ai.chatStream token streaming, geminiStreamGenerateContent() Gemini SSE

### Community 34 - "Capacitor Native Bridge JS"
Cohesion: 0.33
Nodes (3): CapacitorException, TODO: export as Cap function, TODO: export as Cap function

### Community 35 - "AI Providers & Catalog"
Cohesion: 0.33
Nodes (6): btnRefreshModels, Cheaper Inference Provider, forge_model_catalog_cache_v1, Gemini Provider (native), Host www/index.html, Turn-key Free AI Setup

### Community 36 - "Chat UI Components"
Cohesion: 0.40
Nodes (6): Attachment Strip (.attach-strip), Chat Message Bubble, Progress Bubble (.bubble.progress), Chat Composer (.composer), Progress Bubble, Chat View (#view-chat)

### Community 37 - "Termux Agent Script"
Cohesion: 0.40
Nodes (4): forge-termux-agent script, FORGE_AGENT_PORT, FORGE_AGENT_VERSION, FORGE_BRIDGE_ROOT

### Community 38 - "i18n Salvage Artifacts"
Cohesion: 0.40
Nodes (5): dict_en.py — Canonical English i18n Dict, dict_ja_fix.py — Japanese Re-translation Overlay, dict_ko.py — Korean i18n Dict, stashed.html — WIP Host with Gate Machinery, surgery.py — i18n Regeneration Script

### Community 40 - "Gradle Wrapper"
Cohesion: 0.83
Nodes (3): gradlew script, die(), warn()

### Community 41 - "Edge-to-Edge Insets Fix"
Cohesion: 0.67
Nodes (4): Capacitor BridgeActivity, CoordinatorLayout (bridge_layout_main.xml), MainActivity (insets listener), RunActivity

### Community 42 - "AI Call Timeouts"
Cohesion: 0.50
Nodes (4): aiReadTimeoutMs, chatCompletions, geminiGenerateContent, responsesApiCompletion

### Community 43 - "Mini-App Console Hook"
Cohesion: 0.50
Nodes (4): Bridge String.raw Template Fix, consoleHook, Mini-app Console, wrapGeneratedHtml

### Community 44 - "SMS Permission Auto-Request"
Cohesion: 0.50
Nodes (4): ensureSmsPermission, ForgeHost.sms API, PhoneBridge.readSms, Sms_Conversation_Copy.html Sample

### Community 45 - "i18n Runtime Lookup"
Cohesion: 0.67
Nodes (4): applyI18nDom, FORGE_I18N dictionary (en/es/fr/pt/ja), t(id, vars) lookup, tf(id, fallback, vars)

### Community 48 - "Drive Tombstones & AA Scan"
Cohesion: 0.67
Nodes (3): Library AAForge Readiness Light, addDriveTombstone, Drive Backup AI Settings

### Community 49 - "Project Meta-Docs"
Cohesion: 0.67
Nodes (3): BUILD.md runbook, INVARIANTS.md, Forge phone session log (session.md)

## Ambiguous Edges - Review These
- `www/index.html (canonical host)` → `forge_check.sh validation gate`  [AMBIGUOUS]
  session.md · relation: references
- `ForgeHost.ai.liveTranslate` → `Forge_Live_Translate.html (mini-app draft)`  [AMBIGUOUS]
  session.md · relation: references
- `Forge_Live_Translate.html (mini-app draft)` → `ForgeHost — Host JS Bridge API`  [AMBIGUOUS]
  session.md · relation: references
- `sms_send tool (danger)` → `Forge app (com.forge.live)`  [AMBIGUOUS]
  docs/privacy-policy.html · relation: conceptually_related_to
- `phone_call tool (danger)` → `Forge app (com.forge.live)`  [AMBIGUOUS]
  docs/privacy-policy.html · relation: conceptually_related_to
- `Chat View (#view-chat)` → `ForgeHost.ai.chat (Reforge Chat)`  [AMBIGUOUS]
  www/index.html · relation: references
- `Preview View (#view-preview)` → `Forge Chat Mini-App (specified)`  [AMBIGUOUS]
  www/index.html · relation: conceptually_related_to
- `Forge Chat runChatTurn()` → `Forge Chat buildSystemPrompt() (definition not in visible source)`  [AMBIGUOUS]
  samples/Forge_Chat.html · relation: calls
- `Forge Chat runChatTurn()` → `Forge Chat normalizeChatResult() (definition not in visible source)`  [AMBIGUOUS]
  samples/Forge_Chat.html · relation: calls
- `Forge Chat runChatTurn()` → `Forge Chat toChatAttachment() (definition not in visible source)`  [AMBIGUOUS]
  samples/Forge_Chat.html · relation: calls

## Knowledge Gaps
- **165 isolated node(s):** `install.sh script`, `PATH`, `name`, `private`, `version` (+160 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `www/index.html (canonical host)` and `forge_check.sh validation gate`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **What is the exact relationship between `ForgeHost.ai.liveTranslate` and `Forge_Live_Translate.html (mini-app draft)`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **What is the exact relationship between `Forge_Live_Translate.html (mini-app draft)` and `ForgeHost — Host JS Bridge API`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **What is the exact relationship between `sms_send tool (danger)` and `Forge app (com.forge.live)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `phone_call tool (danger)` and `Forge app (com.forge.live)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Chat View (#view-chat)` and `ForgeHost.ai.chat (Reforge Chat)`?**
  _Edge tagged AMBIGUOUS (relation: references) - confidence is low._
- **What is the exact relationship between `Preview View (#view-preview)` and `Forge Chat Mini-App (specified)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._