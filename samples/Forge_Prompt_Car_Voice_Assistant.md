# Forge prompt — Car Voice Assistant (Listen toggle · TTS · full tool loop)

Paste **everything inside the fenced block below** into Forge as the user message.  
Use **car / AA mode** if Forge offers it (must set `carCompatible: true`).  
Works best on **phone Forge** (full mic); on **AAForge** degrade gracefully where mic is limited.

---

```
Build a polished Forge mini-app titled "Car Assist" — a driver-safe voice + text AI assistant for the car.

Mark the app carCompatible / AAForge-ready (⚓). Voice and text only — NO camera, QR, file picker, gallery, or rich HTML cards.

## Product goal
Hands-free loop assistant:
1. One huge **Listen** toggle button (primary control).
2. First press → session ON: keep listening → transcribe my speech → send as user query to the LLM → show answer as text AND speak it → immediately listen again, until I press Listen again (session OFF).
3. While ON: mic capture + STT + model + tools + TTS in a tight loop; cancel in-flight work cleanly when turning OFF.
4. Settings: choose **LLM provider** and **voice** (cloud LLM voice when available; else Android/native TTS).
5. The mini-app **owns the full tool-calling loop** (bind tools, execute, feed results, re-call). Expose **as much of the AAForge / car ForgeHost surface as exists** to the model — especially **list/launch apps & activities**.
6. Tool format resilience: support native tool_calls AND text-protocol tools (`<tool>`, ```tool, JSON tool blocks, etc.) for LLMs without native tooling.

## UX (driver-safe)

### Layout
- Dark high-contrast; huge tap targets; readable at a glance (min ~18–22px body).
- Top bar: title "Car Assist" + provider subtitle. Top-right: one compact ⚙️ Settings button only.
- Center status pill: Idle | Listening… | Heard: "…" | Thinking… | 🔧 list_apps… | Speaking… | Error
- Large transcript area (scroll):
  - User lines (right): final recognized text
  - Assistant lines (left): spoken answer text (plain text only; escape HTML)
  - Optional muted one-liner under assistant: "Used: list_apps, launch_app" (no huge JSON dumps)
- Optional live partial transcript line while listening (if host supports partials).
- Bottom: ONE dominant button:
  - OFF state: big green/blue "🎤 Listen" 
  - ON state: big red/orange "⏹ Stop" (same button, toggles)
- Small secondary "Type instead" expands a single-line text field + Send (parked / passenger use). Hide by default to reduce clutter.
- No multi-step menus while driving. No confirm modals that require reading long text while session is ON — for launch_app while listening, use a short spoken confirm: "Opening WhatsApp. Say cancel to stop." with 1.2s window OR settings.autoLaunch when ON (see Settings).

### Settings (modal)
- LLM provider `<select>` from ForgeHost.ai.listProviders() / ai.menu() — labels only, never keys.
- Voice `<select>` from listVoices (see TTS section). Show engine badge cloud/native.
- Speak answers: ON (default) / OFF (text only).
- Language / locale for STT+TTS (e.g. en-US) text field or select.
- Enable tools: ON default.
- Auto-launch apps without confirm: OFF default. When OFF and session listening, speak "Launch {label}?" and treat next short utterance yes/no/cancel; when parked/type mode, simple Yes/No buttons OK.
- Max tool rounds: 1–6 default 4.
- Continuous gap: after speaking, auto-restart listen (default ON when session ON).
- Save via ForgeHost.storage (not localStorage).

### Empty / first run
- If no AI profiles: clear message "Import AI settings from Forge into AAForge" / "Configure AI in Forge Settings".
- Request mic permission on first Listen.

## Hard constraints
- ONLY window.ForgeHost / window.forge. Async + try/catch everywhere.
- NO API keys in HTML.
- NO camera/files/QR/html.inline rich cards.
- carCompatible: true. Prefer short spoken answers (1–3 sentences) unless user asks for detail.
- Discover capabilities at runtime: `const caps = await ForgeHost.getCapabilities()` (or ai.isAvailable + feature probes). Never assume phone-only APIs on AAForge.
- Host differences:
  - **Phone Forge:** mic.listen / mic.record + ai.transcribe, full ai.chat tools, ai.tts / tts.speak, apps.*, phone/sms/contacts may exist.
  - **AAForge:** platform android-auto; mic.listen may be stubbed; still has ai.chat, tts, apps list/launch, phone/sms/contacts, http, storage. If mic.listen fails, show "Voice input limited on Android Auto — use Type instead or phone Forge" and keep text path working.

## Audio pipeline (Listen session)

### Session state machine
```
IDLE --tap--> LISTENING --> (transcript) --> THINKING/TOOLS --> SPEAKING --> LISTENING --> …
                ^                                              |
                |-------------------- tap Stop ----------------|
Any state + Stop => IDLE (abort flags, mic.stop, tts.stop if available)
```

### STT strategy (try in order, first that works)
```js
async function captureUtterance(opts) {
  // 1) Native speech recognition (fast, on-device) — preferred for car loop
  try {
    if (ForgeHost.mic?.listen) {
      const r = await ForgeHost.mic.listen({
        lang: settings.lang || 'en-US',
        language: settings.lang || 'en-US',
        partial: true,
        maxResults: 3,
        // if host supports: timeoutMs / silenceMs
      });
      const text = (r && (r.transcript || r.text || r.result)) || '';
      if (r && r.error && !text) throw new Error(r.error);
      if (text && String(text).trim()) return { text: String(text).trim(), via: 'mic.listen' };
    }
  } catch (e) { /* fall through */ }

  // 2) Record short clip + cloud STT (when ai.transcribe / stt available)
  try {
    const avail = await ForgeHost.ai.isAvailable().catch(() => ({}));
    if (avail && (avail.stt || avail.transcribe) && ForgeHost.mic?.record) {
      const wav = await ForgeHost.mic.record({ durationMs: 4000, sampleRate: 16000 });
      const stt = await ForgeHost.ai.transcribe({
        dataUrl: wav.dataUrl || wav.dataURL,
        base64: wav.base64,
        mime: wav.mime || 'audio/wav',
        language: (settings.lang || 'en').slice(0, 2),
        providerId: settings.providerId
      });
      const text = (stt && (stt.text || stt.transcript)) || '';
      if (text.trim()) return { text: text.trim(), via: 'ai.transcribe' };
    }
  } catch (e) { /* fall through */ }

  // 3) startRecord/stopRecord if listen/record missing
  // …
  return { text: '', via: 'none' };
}
```

### Main listen loop
```js
let sessionOn = false;
let abortGen = 0;

async function toggleListen() {
  if (sessionOn) {
    sessionOn = false;
    abortGen++;
    try { await ForgeHost.mic?.stop?.(); } catch(_){}
    try { await ForgeHost.tts?.stop?.(); } catch(_){}
    try { await ForgeHost.ai?.tts?.({ text:'', play:false }); } catch(_){} // ignore
    setStatus('Idle');
    updateListenButton();
    return;
  }
  sessionOn = true;
  const myGen = ++abortGen;
  updateListenButton();
  await ForgeHost.permissions?.request?.('mic').catch(()=>{});
  try { await ForgeHost.keepAwake?.start?.({ title:'Car Assist', text:'Listening' }); } catch(_){}

  while (sessionOn && myGen === abortGen) {
    setStatus('Listening…');
    const utt = await captureUtterance();
    if (!sessionOn || myGen !== abortGen) break;
    if (!utt.text) { setStatus('Listening…'); continue; } // silence — keep looping

    appendUser(utt.text);
    setStatus('Thinking…');
    let answer = '';
    try {
      answer = await runAssistantTurn(utt.text, myGen);
    } catch (e) {
      answer = 'Sorry, something went wrong.';
      setStatus(e.message || 'Error');
    }
    if (!sessionOn || myGen !== abortGen) break;
    if (answer) {
      appendAssistant(answer);
      if (settings.speak !== false) {
        setStatus('Speaking…');
        await speakAnswer(answer);
      }
    }
    // loop continues → listen again
  }
  try { await ForgeHost.keepAwake?.stop?.(); } catch(_){}
  setStatus('Idle');
  updateListenButton();
}
```

Ignore empty transcripts; debounce duplicate identical transcripts within 1.5s.
While SPEAKING, do not start the next listen until TTS finishes (or timeout 30s) so the assistant does not hear itself (barge-in optional later).

## TTS (cloud voice with native fallback)

```js
async function loadVoices() {
  // Prefer ai.listVoices / ai.voices; also tts.listVoices
  let vs = null;
  try { vs = await ForgeHost.ai.listVoices({ source: 'all' }); } catch(_){}
  if (!vs) try { vs = await ForgeHost.ai.voices?.({ source: 'all' }); } catch(_){}
  if (!vs) try { vs = await ForgeHost.tts?.listVoices?.({}); } catch(_){}
  // Normalize: never put objects in <option> text
  // vs.options = [{value,label}] OR vs.voices = [{id,name,label,engine}]
  return normalizeVoices(vs);
}

async function speakAnswer(text) {
  const t = String(text || '').replace(/\s+/g, ' ').trim();
  if (!t) return;
  // Prefer short speech: strip markdown-ish
  const spoken = t.replace(/[*_`#]/g, '').slice(0, 800);
  const voice = settings.voiceId || undefined;
  const lang = settings.lang || 'en-US';

  // 1) Host AI TTS auto (cloud if voice/provider supports, else native)
  try {
    if (ForgeHost.ai?.tts) {
      const r = await ForgeHost.ai.tts({
        text: spoken,
        voice,
        language: lang,
        lang,
        mode: 'auto',          // critical: auto falls back to Android TTS
        play: true,
        route: 'speaker'       // car / phone speaker if supported
      });
      if (r && r.ok !== false) return r;
    }
  } catch (_) {}

  // 2) Explicit native
  try {
    if (ForgeHost.tts?.speak) {
      await ForgeHost.tts.speak(spoken, { lang, language: lang, rate: 1.0 });
      return;
    }
  } catch (_) {}
  try {
    await ForgeHost.ai.tts({ text: spoken, mode: 'native', lang, play: true });
  } catch (_) {}
}
```

Settings voice select:
- If cloud voices exist (xAI eve/ara/…, OpenAI alloy/…), list them first under "Cloud".
- Always include "System default (Android TTS)" value `native:default`.
- If selected cloud voice fails at speak time → catch and retry mode:'native' once; toast once "Cloud voice unavailable — using Android TTS".

## LLM chat + tool loop (mini-app managed)

### System prompt (short, car-oriented)
You are Car Assist on Android Auto / a phone in the car. Keep answers brief and spoken-friendly.
You may call tools to help the driver: find/open apps, dial, SMS compose, contacts lookup, http get for quick facts if needed.
Prefer tools over guessing package names. After tools, confirm in one short sentence.
Never ask the user to type long forms. Never mention JSON or tool names unless asked.

### Expose AAForge-capable tools (define OpenAI tools[] shape; host may remap)

Include all that capability-detect as available. **Always include apps tools.**

```js
function buildToolList(caps) {
  const t = [];
  // —— Apps (REQUIRED focus) ——
  t.push(fn('list_apps', 'Search installed apps on the phone/car host.', {
    query: { type:'string' }, limit: { type:'number' }
  }));
  t.push(fn('list_activities', 'List activities for a packageName.', {
    packageName: { type:'string' }
  }, ['packageName']));
  t.push(fn('launch_app', 'Launch app, activity, or data URI (maps, tel, https, wa.me, geo).', {
    packageName:{type:'string'}, activity:{type:'string'}, component:{type:'string'},
    data:{type:'string'}, action:{type:'string'}, chooser:{type:'boolean'}, chooserTitle:{type:'string'}
  }));

  // —— Phone / SMS / contacts (if caps) ——
  if (caps.phone !== false) {
    t.push(fn('phone_dial', 'Open dialer with number (safe).', { number:{type:'string'} }, ['number']));
    if (caps.call) t.push(fn('phone_call', 'Place a call only if user clearly asked to call.', { number:{type:'string'} }, ['number']));
  }
  if (caps.contacts) t.push(fn('contacts_search', 'Search contacts by name.', { query:{type:'string'}, limit:{type:'number'} }, ['query']));
  if (caps.smsCompose || caps.sms) {
    t.push(fn('sms_compose', 'Open SMS composer.', { number:{type:'string'}, body:{type:'string'} }));
  }
  if (caps.smsSend) {
    t.push(fn('sms_send', 'Send SMS ONLY if user explicitly asked to send.', { number:{type:'string'}, body:{type:'string'} }, ['number','body']));
  }
  if (caps.smsRead) t.push(fn('sms_read', 'Read recent SMS (summarize; do not dump sensitive junk).', { limit:{type:'number'} }));

  // —— HTTP (quick facts; keep small) ——
  if (caps.http !== false) {
    t.push(fn('http_get', 'GET a simple https URL and return truncated text/json.', {
      url:{type:'string'}, maxChars:{type:'number'}
    }, ['url']));
  }

  // —— Device-ish ——
  t.push(fn('get_time', 'Return current local time ISO and human string.', {}));
  t.push(fn('notify', 'Show a quick notification/toast on the phone.', { message:{type:'string'} }, ['message']));

  return t;
}
function fn(name, description, properties, required) {
  return {
    type: 'function',
    function: {
      name, description,
      parameters: { type:'object', properties: properties || {}, required: required || [] }
    }
  };
}
```

### executeTool → ForgeHost / AAForgeHost mappings
```js
async function executeTool(name, args) {
  args = args || {};
  try {
    switch (name) {
      case 'list_apps': {
        const r = await ForgeHost.apps.list({ query: args.query, limit: Math.min(100, args.limit||30) });
        const apps = (r.apps || r.options || []).map(a => ({
          packageName: a.packageName || a.package,
          label: a.label || a.name
        }));
        return { ok:true, count: apps.length, apps: apps.slice(0, 40) };
      }
      case 'list_activities': {
        const pkg = args.packageName || args.package;
        const r = await ForgeHost.apps.listActivities(pkg);
        const activities = (r.activities || r.options || []).slice(0, 40);
        return { ok:true, packageName: pkg, activities };
      }
      case 'launch_app': {
        if (!(await maybeConfirmLaunch(args))) return { ok:false, cancelled:true };
        const r = await ForgeHost.apps.launch({
          packageName: args.packageName || args.package,
          activity: args.activity,
          component: args.component,
          data: args.data || args.uri || args.url,
          action: args.action,
          chooser: args.chooser,
          chooserTitle: args.chooserTitle
        });
        return { ok:true, result: r||null };
      }
      case 'phone_dial':
        return { ok:true, result: await ForgeHost.phone.dial(args.number) };
      case 'phone_call':
        return { ok:true, result: await ForgeHost.phone.call(args.number) };
      case 'contacts_search':
        return { ok:true, result: await ForgeHost.contacts.list({ query: args.query, limit: args.limit||10 }) };
      case 'sms_compose':
        return { ok:true, result: await ForgeHost.sms.compose(args.number, args.body||'') };
      case 'sms_send':
        return { ok:true, result: await ForgeHost.sms.send({ number: args.number, body: args.body }) };
      case 'sms_read':
        return { ok:true, result: await ForgeHost.sms.read({ limit: args.limit||10 }) };
      case 'http_get': {
        const r = await ForgeHost.http.get(args.url);
        let body = typeof r === 'string' ? r : (r.body || r.text || r.data || JSON.stringify(r));
        body = String(body).slice(0, Math.min(8000, args.maxChars || 4000));
        return { ok:true, body };
      }
      case 'get_time': {
        const d = new Date();
        return { ok:true, iso: d.toISOString(), human: d.toLocaleString() };
      }
      case 'notify': {
        try { await ForgeHost.toast?.(args.message); } catch(_){}
        try { await ForgeHost.notify?.(args.message); } catch(_){}
        return { ok:true };
      }
      default:
        return { ok:false, error: 'Unknown tool '+name };
    }
  } catch (e) {
    return { ok:false, error: e.message || String(e) };
  }
}
```
Probe optional APIs with try/catch; if missing, tool returns `{ok:false,error:'unsupported on this host'}`.

### runAssistantTurn — tool loop + multi-format binding
```js
async function runAssistantTurn(userText, gen) {
  const caps = cachedCaps || await ForgeHost.getCapabilities().catch(()=>({}));
  const tools = settings.enableTools === false ? null : buildToolList(caps);
  const messages = [
    { role:'system', content: buildSystemPrompt(!!tools) },
    // last few turns only (memory window ~6 messages) from uiHistory finals
    ...getRecentHistoryMessages(6),
    { role:'user', content: userText }
  ];

  let finalText = '';
  const maxRounds = settings.maxToolRounds || 4;
  const used = [];

  for (let round = 0; round < maxRounds; round++) {
    if (gen !== abortGen || !sessionOn && /* allow type-mode */ false) {
      /* for voice session, stop if aborted; type-mode uses gen only */
    }
    if (gen !== abortGen) throw new Error('cancelled');

    const payload = {
      messages,
      providerId: settings.providerId || undefined
    };
    if (tools) {
      payload.tools = tools;
      payload.tool_choice = 'auto';
    }

    setStatus(round ? ('🔧 tools round '+(round+1)) : 'Thinking…');
    const raw = await ForgeHost.ai.chat(payload);
    const n = normalizeChatResult(raw, tools);

    if (n.tool_calls.length) {
      messages.push({
        role: 'assistant',
        content: n.content || null,
        tool_calls: n.tool_calls // OpenAI wire shape
      });
      for (const tc of n.parsed) {
        used.push(tc.name);
        setStatus('🔧 ' + tc.name);
        const result = await executeTool(tc.name, tc.args);
        messages.push({
          role: 'tool',
          tool_call_id: tc.id,
          name: tc.name,
          content: safeJson(result, 10000)
        });
      }
      continue;
    }

    finalText = (n.content || '').trim();
    break;
  }

  if (!finalText) finalText = used.length ? 'Done.' : 'I did not get a response.';
  // Store compact history: user + assistant final only (drop tool rows)
  pushHistoryFinal(userText, finalText, used);
  return finalText;
}
```

## normalizeChatResult — diverse LLM tool formats (REQUIRED)

Handle all of the following from `ai.chat` return values:

1. **OpenAI / host-unified:** `tool_calls: [{ id, type:'function', function:{ name, arguments: string|object } }]`
2. **Legacy OpenAI:** `function_call: { name, arguments }`
3. **camelCase proxies:** `toolCalls`, `toolCallId`
4. **Args as object** already parsed
5. **Top-level name** on the call object
6. **Gemini-via-host:** same as OpenAI (ids like `call_gem_…`); always send `name` on tool result rows
7. **Anthropic-like parts:** `content: [{type:'tool_use', id, name, input}]`
8. **Full response passthrough:** `choices[0].message`
9. **Text-protocol tools** (models with NO native tools) — scrape then strip from visible answer:
   - ` ```tool\n{"name":"list_apps","arguments":{...}}\n``` `
   - ` ```json\n{"tool":"launch_app", ...}\n``` ` when name/tool is known
   - `<tool name="list_apps">{"query":"maps"}</tool>`
   - `<tool_call name="launch_app">...</tool_call>`
   - `call tool list_apps with {..}` light regex (conservative)
   - Only accept names in the active tool list (prevents arbitrary code fantasies)

```js
function normalizeChatResult(raw, tools) {
  // returns { content, tool_calls /*wire*/, parsed:[{id,name,args}] }
  // implement full normalizer + scrapeToolsFromText as in production chat apps
  // arguments MUST be re-stringified for assistant.tool_calls when re-sending
}
```

If provider errors on `tools` parameter: retry once without tools and rely on text-protocol scrape only; setStatus('Provider has no native tools — using text tools').

## Type-instead path
Same `runAssistantTurn` without mic loop; still speak answer if Speak ON.

## Lifecycle
- pause/destroy / visibility hidden: stop session (same as Stop), keepAwake stop, mic.stop, cancel TTS if possible.
- resume: restore settings; do NOT auto-start Listen.
- Persist settings + last ~20 transcript lines (text only).

## AAForge car template extras (if generating car UI manifest)
If Forge injects AAForge manifest / template actions, expose:
- Primary action: Listen / Stop toggle
- Secondary: Settings
- Voice pane shows last user + last assistant lines
Keep HTML usable both as phone WebView mini-app and carCompatible import.

## Out of scope
- Camera, attachments, HTML embeds, liveTranslate continuous PCM (unless you use it only as STT backend feature-detect).
- API key UI.
- Unconfirmed mass SMS or silent calls — require clear user intent; prefer dial/compose.

## Deliverable
Single self-contained HTML mini-app (inline CSS/JS), carCompatible.
No CDN. Works in Forge srcdoc and imports into AAForge.

### Acceptance
1. Tap Listen → speak "what time is it?" → text + voice answer → auto listens again.
2. Tap Stop → silence; no further STT/TTS.
3. "What navigation apps do I have?" → list_apps tool → short spoken list.
4. "Open Spotify" → list_apps/launch_app → app opens → "Opening Spotify".
5. Settings: switch provider; pick cloud voice; turn off cloud (or broken voice) → Android TTS still speaks.
6. Provider without native tools still runs ```tool / <tool> protocols.
7. On AAForge with stub mic: Type path + TTS still work; Listen shows clear limitation message.
8. No crash if contacts/sms APIs missing.
```

---

### After generate
1. Configure AI in **phone Forge** → Share AI settings to **AAForge** if using the car host.  
2. Share/import this mini-app (carCompatible).  
3. On phone first: verify Listen loop + app launch.  
4. On AA: verify text + TTS; voice only if host mic path exists.  
5. Prefer providers with tools + STT (OpenAI/Groq/xAI) for best car loop; Gemini may chat+tools via host mapping but STT may be unavailable — then rely on `mic.listen` on-device recognition.
