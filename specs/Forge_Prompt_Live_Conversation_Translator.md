# Forge prompt — Live Conversation Translator

Paste **everything inside the block below** into Forge as the user message (normal generate, not car mode unless you want AA later).

---

```
Build a polished Forge mini-app titled "Live Talk" — a real-time conversation translator for two people sharing one phone.

## Product goal
I speak language A; the other person speaks language B.
- Continuous open-mic live translation when running (use host live session).
- I can choose how *I* receive their words:
  1) **Text mode** — scrolling captions of the translation into MY language (default, safest).
  2) **Audio mode** — speak the translation to me (prefer earpiece/headset route).
  3) **Both** — captions + audio to me.
- I can choose how *THEY* receive my words:
  1) **Speaker** — TTS of translation into THEIR language on phone loudspeaker (default when split audio on).
  2) **Off** — only show my side as text (no speaker).
- Optional **Split audio** toggle:
  - ON: my playback route = earpiece/bluetooth headset; their playback route = speaker.
  - OFF: use default system route for any TTS (still honor Text vs Audio for me).
- Big clear UI for face-to-face use outdoors; one-hand operable; works in full-screen app mode.

## Hard constraints (do not invent APIs)
Use ONLY window.ForgeHost / window.forge. All calls async with try/catch.
Prefer host live pipeline — do NOT roll your own mic→Whisper loop unless liveTranslate is unavailable.

### Required host APIs
Discovery:
- await ForgeHost.getCapabilities()
- await ForgeHost.ai.isAvailable()  // need .stt / providers; show friendly setup if missing
- await ForgeHost.permissions.request('mic') or requestPack('media')

Providers (NO API keys in HTML):
- const menu = await ForgeHost.ai.listProviders()  // or ai.menu()
- await ForgeHost.ai.setProvider(id)  // persist per-app
- await ForgeHost.ai.getProvider()
- Filter menu.providers to available ones; <select> with label + model; never show keys.

Voices:
- const vs = await ForgeHost.ai.listVoices() // or ai.voices({ source:'all' })
- Fill selects from vs.options (value/label strings). NEVER option.textContent = object.
- Separate selects: "My voice" (TTS into my language) and "Their voice" (TTS into their language).
- Prefer cloud voices when ttsCloud; allow mode auto. Store chosen voice ids in ForgeHost.storage.

Live translation session (primary engine):
- ForgeHost.on('live.status'|'live.level'|'live.partialSource'|'live.finalSource'|'live.partialTarget'|'live.finalTarget'|'live.error', handler)
- await ForgeHost.ai.liveTranslate.start({
    sourceLang, targetLang, speak, route, chunkMs:250, windowMs:1400, providerId?
  })
- await ForgeHost.ai.liveTranslate.configure({ speak, sourceLang, targetLang, ... })
- await ForgeHost.ai.liveTranslate.status()
- await ForgeHost.ai.liveTranslate.stop()

Audio routing (when Split audio or explicit routes):
- await ForgeHost.audio.setRoute('speaker'|'earpiece'|'bluetooth'|'auto')
- await ForgeHost.audio.clearRoute()
- Per-utterance also: ForgeHost.ai.tts({ text, voice, language, mode:'auto', play:true, route })
  and/or ForgeHost.tts.speak(text, { lang, route })

Fallback if !caps.liveTranslate:
- PTT: mic.record / mic.listen → ai.transcribe → ai.chat translate → show/speak
- Keep same UI modes.

Keep awake while session running:
- ForgeHost.keepAwake.start({ title:'Live Talk', text:'Translating…' }) / stop on end.

Persist settings via ForgeHost.storage (not localStorage):
myLang, theirLang, providerId, myVoice, theirVoice, myOutputMode ('text'|'audio'|'both'), theirOutputMode ('speaker'|'off'), splitAudio (bool), autoStart false.

Lifecycle:
- on pause/destroy → stop live session + keepAwake + clearRoute
- on resume → restore settings UI; do not auto-restart mic without user tap

## Conversation model (critical — one active direction at a time)
The host supports one active direction per session, and also exposes Patch 4 conversation mode. This prompt intentionally implements explicit I talk / They talk switching so each direction can have its own output routing and voice settings; stop the current session before changing direction. Implement bidirectional UX in the mini-app:

**Talk mode control (huge segmented control):**
- **I talk** — I'm speaking myLang → translate to theirLang.
  - liveTranslate: sourceLang=myLang (or 'auto'), targetLang=theirLang
  - speak = (theirOutputMode === 'speaker')
  - route = splitAudio ? 'speaker' : 'auto'   // for THEM
  - Show partial/final SOURCE as "You" (optional muted style)
  - Show partial/final TARGET as "Them · hear" and if speak, host TTS already via liveTranslate.speak
  - If liveTranslate.speak is true, do NOT double-speak the same finalTarget unless speak failed

- **They talk** — they speak theirLang → translate to myLang.
  - liveTranslate: sourceLang=theirLang (or 'auto'), targetLang=myLang
  - If myOutputMode is 'text' only: start with speak:false; render scrolling captions from partialTarget/finalTarget
  - If myOutputMode is 'audio' or 'both': speak:true with route = splitAudio ? 'earpiece' : 'auto'
    (if earpiece fails, try 'bluetooth' then 'auto')
  - Large caption area for MY language when they talk (primary focus)

**Swap languages** button swaps myLang/theirLang and labels.

Changing talk mode while running: stop → reconfigure → start again cleanly (await stop before start).

## UI / UX
Mobile-first, dark modern glass UI, safe-area padding, 16–18px+ body, 48px min tap targets.

Layout:
1. Top bar: title "Live Talk", status pill (Idle / Listening / Translating / Error), tiny RMS level meter from live.level
2. Language row: [My language ▼] ⇄ [Their language ▼]  (common langs + free-text BCP-47 input advanced)
3. Mode row: huge toggle **I talk | They talk**
4. Output card:
   - Me receive: Text | Audio | Both
   - Them receive: Speaker | Off
   - Split audio: switch + short help text
5. Brain card (collapsible “Settings”):
   - Provider <select> from listProviders
   - My voice <select>, Their voice <select> (refresh button calling listVoices)
   - Test voice buttons
6. Main stage — dual transcript:
   - Left/top: "You" stream (source when I talk / target when they talk — label dynamically)
   - Right/bottom: "Them" stream
   - Auto-scroll; newest final lines pinned; partials in lighter opacity
   - Long-press line to copy
7. Bottom dock:
   - Giant START / STOP button
   - Secondary: Clear transcripts
   - Optional: Hold-to-talk fallback button if live unavailable

Empty/help state before first start: 3 bullets explaining I talk vs They talk and Text vs Split audio.

Errors:
- Show toast + status pill from live.error
- If STT/provider missing: card “Open Forge AI settings and add OpenAI, Groq, or xAI (Whisper/STT). Gemini chat-only won’t work for live mic.”

## Translation quality extras
- When applying finalTarget TTS yourself (fallback path), strip quotes; don’t speak empty/duplicate strings.
- Debounce identical finals.
- For manual fallback translate via ai.chat, system prompt: output ONLY the translation, no preamble.
- Language codes: use BCP-47 where TTS needs it (e-US, es-ES, he-IL, ar-SA, fr-FR, de-DE, pt-BR, zh-CN, ja-JP, ko-KR, …). Map short codes when calling tts.

## Voices + provider wiring
- On provider change: setProvider, reload voices, keep prior voice id if still present.
- When speaking “to them”, pass theirVoice + target lang; when “to me”, myVoice + my lang.
- Prefer: await ForgeHost.ai.tts({ text, voice, language, mode:'auto', play:true, route })
  If liveTranslate.speak already handles speech, set speak true and still pass route in start/configure; also set sticky route via audio.setRoute before start when splitAudio.

Recommended start sequence:
1. request mic permission
2. keepAwake.start
3. if splitAudio: audio.setRoute(routeForCurrentTalkMode)
4. liveTranslate.start({ sourceLang, targetLang, speak, route, providerId: selected })
5. wire events → UI

Stop sequence:
1. liveTranslate.stop
2. audio.clearRoute
3. keepAwake.stop

## Languages to include in selects
English, Spanish, French, German, Italian, Portuguese, Hebrew, Arabic, Russian, Chinese (Simplified), Japanese, Korean, Hindi, Turkish, Dutch, Polish + “Custom…” text field.

## Quality bar
- No external CSS/JS CDNs.
- No fake bridges, no API keys, no localhost assumptions.
- Graceful if audioRoute capability false (hide split audio detail, still offer text mode).
- Beautiful typography; transcript bubbles; subtle pulse on listening.
- App summary: "Face-to-face live translator with captions or split-audio."

Return the usual Forge JSON with complete html.
```

---

## Why this prompt matches current Forge (2.7.54 / versionCode 184)

| Need | Host support |
|---|---|
| Open mic live STT + translate | `ai.liveTranslate.*` + `live.*` events |
| Captions for you | `speak:false` + `live.partialTarget` / `finalTarget` |
| Speaker for them / earpiece for you | `route` + `audio.setRoute` |
| Provider picker | `ai.listProviders` / `setProvider` |
| Voices | `ai.listVoices` + `ai.tts` |
| Bidirectional talk | Mini-app **I talk / They talk** with explicit stop/restart switching; host also exposes Patch 4 conversation mode |

## After it generates

1. Install current Forge **2.7.54 / versionCode 184** (or any later build) with live translate if you haven’t.  
2. Configure an STT-capable provider in Forge AI (OpenAI / Groq / xAI).  
3. Generate from the prompt → Run → allow mic.  
4. Prefer **They talk + Text** first (simplest). Then try **Split audio**.

## Optional follow-ups you can send Forge as refine messages

- “Add a single ‘Auto’ mode that language-detects with short ai.chat on finalSource and flips talk direction.”  
- “Add landscape two-column mode for table laying between us.”  
- “Add large them-facing screen flip (rotate 180°) when I talk + speaker.”
