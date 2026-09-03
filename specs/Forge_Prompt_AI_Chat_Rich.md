# Forge prompt — Rich AI Chat (providers · attachments · HTML · app tools)

Paste **everything inside the fenced block below** into Forge as the user message  
(normal generate / kitchen-sink mini-app — not car mode).

---

```
Build a polished Forge mini-app titled "Forge Chat" — a full-screen AI chat client that uses the user's already-configured Forge AI providers (NO API keys in the HTML).

## Product goal
A beautiful mobile chat where I can:
1. Pick which LLM provider/model to use (from host-configured providers).
2. Attach files (PDF, audio, images/JPG/PNG/WebP) via the system picker.
3. Attach images from the camera roll (gallery).
4. Take a camera photo and attach it.
5. Ask questions in a multi-turn conversation.
6. Receive answers as plain text OR rich HTML when useful (tables, cards, diagrams, formatted guides).
7. When the model returns HTML, embed/render it inside the chat bubble (sandboxed), with a Settings control for HTML scale/zoom.
8. Defeat CORS for images inside that HTML: rewrite remote <img> / CSS url() / srcset to inlined data URLs via the host HTTP helper BEFORE injecting into the bubble.
9. **Tool calling (REQUIRED):** the model can discover and launch apps/activities installed on this phone via ForgeHost.apps.*. The **mini-app owns the full tool loop** (call → execute → feed results → call again until final text/HTML). Host only normalizes provider wire formats into a unified `tool_calls[]` on `ai.chat` results — the mini-app must still run the loop and handle format diversity defensively.

## UI layout (match exactly)

### Top bar
- Left: app title "Forge Chat" + small subtitle showing active provider label (e.g. "GPT-4o · OpenAI").
- Top-right, two compact icon mini-buttons (circle or 36–40px), in this order:
  1) ⚙️ Settings
  2) ✨ New chat  (confirm if history non-empty)
- Thin status line under the bar: Ready / Thinking… / Sending 2 attachments… / Running tool list_apps… / Launching WhatsApp… / Error text (never alert()).
- Optional tiny chip when a tool runs: "🔧 list_apps" that fades after the hop (do not dump huge JSON into the main transcript).

### Main
- Scrollable message list (flex column). User bubbles right (accent), assistant left (surface).
- User bubbles: text + attachment chips/thumbnails above the text.
- Assistant bubbles:
  - If plain text → render safely as text (preserve newlines; light markdown optional: **bold**, `code`, lists — NO raw HTML injection from plain text).
  - If HTML reply → a framed "rich card" with a sandboxed iframe (or srcdoc) showing the HTML, scaled by settings.htmlScale. Show a small "HTML" badge + optional "Open full" expand toggle.
- Streaming not required; show a typing/thinking row while awaiting ai.chat.
- Empty state: short welcome + 3 tappable suggestion chips (e.g. "Summarize this PDF", "What's in this photo?", "Make a nice comparison table").

### Bottom composer (fixed)
- Full-width row, safe-area aware.
- Growing textarea (1–5 lines) on the left.
- Bottom-right cluster (small, tight gap):
  1) 📎 clip / attach button (opens attach sheet)
  2) ➤ Send button (primary, disabled while empty+no attachments or while loading)
- Above the composer when attachments pending: horizontal chip strip with remove (×) on each chip (thumb for images, mime/icon + name for PDF/audio).

### Attach sheet (action sheet / bottom menu from 📎)
- 📷 Take photo
- 🖼️ Camera roll / gallery
- 📄 Files (PDF, audio, images — multi if host allows)
- Cancel

### Settings modal (from ⚙️)
- AI Provider: <select> filled from ForgeHost.ai.listProviders() / ai.menu() — labels only, NEVER keys.
- Default system prompt (textarea, optional; persisted).
- HTML scale: range 0.5–2.0 step 0.1 with live % label (default 1.0). Applies to all HTML bubbles (CSS zoom/transform on the embed wrapper).
- "Inline remote images in HTML" toggle (default ON) — uses host CORS bypass.
- "Prefer HTML replies when useful" toggle (default ON) — steers system prompt.
- **"Enable app tools"** toggle (default ON) — when off, omit `tools` from ai.chat.
- **"Confirm before launch_app"** toggle (default ON) — before executing launch_app, show a compact confirm sheet (app label/package/activity). list_apps / list_activities never need confirm.
- Max tool rounds slider 1–8 (default 5).
- Temperature optional 0–1 (default 0.7) if you pass it through; ignore if host rejects unknown fields.
- Save / Cancel. Persist via ForgeHost.storage (NOT localStorage — unreliable in srcdoc).

Dark, modern, system-ui font. Large tap targets. No alert(); use status line + soft toasts via ForgeHost.toast when available.

## Hard constraints (do not invent APIs)
Use ONLY window.ForgeHost (or window.forge). Every call async + try/catch.
Never embed API keys. Never use <input type="file"> inside the mini-app iframe (broken in sandbox) — always ForgeHost.files / camera.
Never use fetch() to the user's LLM. Always ForgeHost.ai.chat.
Prefer ForgeHost.storage / ForgeHost.state over localStorage.

### Required host APIs

Providers:
- await ForgeHost.ai.isAvailable()
- const menu = await ForgeHost.ai.listProviders()  // alias: ai.menu()
  // menu.providers[] = { id, label/name, model?, ... } — no secrets
- await ForgeHost.ai.getProvider()
- await ForgeHost.ai.setProvider(id)  // or { providerId }
- On send, pass providerId when user picked a non-default provider.

Chat (CRITICAL attachment + tools contract):
```js
const r = await ForgeHost.ai.chat({
  messages,           // system|user|assistant|tool rows — see tool loop
  providerId,         // optional
  temperature,        // optional
  tools: APP_TOOLS,   // OpenAI-shaped; host maps to Gemini functionDeclarations etc.
  tool_choice: 'auto', // optional; omit if provider rejects
  // FIRST hop of this user turn ONLY (not on tool-followup hops):
  attachments: [
    { type: 'image', dataUrl, mime: 'image/jpeg', name?: 'photo.jpg' },
    { type: 'file', dataUrl, mime, name },
  ],
});
// r.content = string | null
// r.tool_calls = [] | [{ id, type:'function', function:{ name, arguments: string|object } }, ...]
// Host already unifies many backends; STILL normalize defensively (see below).
```
Rules:
- Build `messages` as clean history. Do NOT put multi-MB base64 inside messages[].content.
- Pass binary ONLY via `attachments` on the **first** ai.chat hop of that user turn (never on tool-result hops).
- Cap images: max 4–6 per turn; camera maxWidth ~1280–1600, quality ~80–85.
- If attach fails, toast and continue with the rest.
- When tools enabled, ALWAYS pass the same `tools: APP_TOOLS` on every hop of the loop so the model can chain calls.

### Apps bridge (tool backends)
```js
// Discovery / launch — aliases exist (open, startActivity, openApp) but prefer these:
const { apps, options } = await ForgeHost.apps.list({ query: 'maps', limit: 80 })
// apps[] ≈ { packageName|package, label|name, ... }
const { activities, options: acts } = await ForgeHost.apps.listActivities('com.whatsapp')
// or listActivities({ packageName: 'com.whatsapp' })
await ForgeHost.apps.launch({ packageName: 'com.whatsapp' })
await ForgeHost.apps.launch({ packageName, activity })          // specific activity class
await ForgeHost.apps.launch({ component: 'pkg/com.example.Act' })
await ForgeHost.apps.launch({ data: 'https://wa.me/15551212?text=' + encodeURIComponent('Hi') })
await ForgeHost.apps.launch({ data: 'geo:0,0?q=' + encodeURIComponent(addr) })
await ForgeHost.apps.launch({ data: url, chooser: true, chooserTitle: 'Open with' })
```

### Tool definitions (pass exactly this OpenAI tools[] shape — host adapts per provider)
```js
const APP_TOOLS = [
  {
    type: 'function',
    function: {
      name: 'list_apps',
      description: 'Search installed Android apps on the phone. Use before launching when the user names an app vaguely.',
      parameters: {
        type: 'object',
        properties: {
          query: { type: 'string', description: 'Optional case-insensitive filter (label or package substring)' },
          limit: { type: 'number', description: 'Max results (default 40, max 200)' }
        }
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'list_activities',
      description: 'List exported/launchable activities for one package. Use when user wants a specific screen or list_apps is ambiguous.',
      parameters: {
        type: 'object',
        properties: {
          packageName: { type: 'string', description: 'Application id, e.g. com.whatsapp' }
        },
        required: ['packageName']
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'launch_app',
      description: 'Launch an installed app, a specific activity, a deep link, or an intent. Prefer packageName from list_apps. For web/geo/tel/wa.me links use data=. Requires user confirmation in the UI when enabled.',
      parameters: {
        type: 'object',
        properties: {
          packageName: { type: 'string' },
          activity: { type: 'string', description: 'Fully-qualified activity class if known' },
          component: { type: 'string', description: 'pkg/class shorthand' },
          data: { type: 'string', description: 'URI: https:, geo:, tel:, google.navigation:, wa.me, etc.' },
          action: { type: 'string', description: 'Optional intent action' },
          mimeType: { type: 'string' },
          extras: { type: 'object', description: 'Optional string extras map' },
          chooser: { type: 'boolean' },
          chooserTitle: { type: 'string' }
        }
      }
    }
  }
];
```

### executeTool (mini-app side)
```js
async function executeTool(name, args) {
  args = args && typeof args === 'object' ? args : {};
  try {
    if (name === 'list_apps') {
      const limit = Math.min(200, Math.max(1, Number(args.limit) || 40));
      const r = await ForgeHost.apps.list({ query: args.query || undefined, limit });
      // Return a compact summary for the model (avoid huge payloads)
      const apps = (r && (r.apps || r.options || r)) || [];
      const list = (Array.isArray(apps) ? apps : []).slice(0, limit).map(a => ({
        packageName: a.packageName || a.package || a.id,
        label: a.label || a.name || a.title || a.packageName
      }));
      return { ok: true, count: list.length, apps: list };
    }
    if (name === 'list_activities') {
      const pkg = args.packageName || args.package || args.pkg;
      if (!pkg) return { ok: false, error: 'packageName required' };
      const r = await ForgeHost.apps.listActivities(pkg);
      const acts = (r && (r.activities || r.options || r)) || [];
      const list = (Array.isArray(acts) ? acts : []).slice(0, 80).map(x => ({
        name: x.name || x.activity || x.className || x.label,
        label: x.label || x.name
      }));
      return { ok: true, packageName: pkg, count: list.length, activities: list };
    }
    if (name === 'launch_app') {
      if (settings.confirmLaunch !== false) {
        const ok = await confirmLaunchSheet(args); // UI promise true/false
        if (!ok) return { ok: false, cancelled: true, error: 'User declined launch' };
      }
      const r = await ForgeHost.apps.launch({
        packageName: args.packageName || args.package,
        activity: args.activity,
        component: args.component,
        data: args.data || args.uri || args.url,
        action: args.action,
        type: args.mimeType || args.type,
        extras: args.extras,
        chooser: args.chooser,
        chooserTitle: args.chooserTitle
      });
      return { ok: true, launched: true, result: r || null };
    }
    return { ok: false, error: 'Unknown tool: ' + name };
  } catch (e) {
    return { ok: false, error: e.message || String(e) };
  }
}
```

## Tool-calling loop (MINI-APP MANAGED — mandatory)

The host does **not** execute tools. Your send() must loop:

```js
async function runChatTurn({ historyMessages, attachments, providerId }) {
  // working copy includes prior turns; may grow with assistant.tool_calls + role:tool rows
  let messages = historyMessages.map(m => ({ ...m })); // shallow copy
  const maxRounds = settings.maxToolRounds || 5;
  let finalContent = '';
  let lastAssistantWithTools = null;

  for (let round = 0; round < maxRounds; round++) {
    setStatus(round === 0 ? 'Thinking…' : ('Tool round ' + (round + 1) + '…'));
    const payload = {
      messages,
      providerId: providerId || undefined,
      temperature: settings.temperature
    };
    if (settings.enableTools !== false) {
      payload.tools = APP_TOOLS;
      payload.tool_choice = 'auto';
    }
    // attachments ONLY on round 0
    if (round === 0 && attachments && attachments.length) {
      payload.attachments = attachments;
    }

    const raw = await ForgeHost.ai.chat(payload);
    const normalized = normalizeChatResult(raw);

    if (normalized.tool_calls.length) {
      // 1) Keep assistant tool-call message EXACTLY as protocol needs
      const assistantMsg = {
        role: 'assistant',
        content: normalized.content || null,
        tool_calls: normalized.tool_calls
      };
      messages.push(assistantMsg);
      lastAssistantWithTools = assistantMsg;

      // 2) Execute each call (sequential is safer for launch confirm)
      for (const tc of normalized.tool_calls) {
        setStatus('🔧 ' + tc.name + '…');
        showToolChip(tc.name, tc.args);
        const result = await executeTool(tc.name, tc.args);
        messages.push({
          role: 'tool',
          tool_call_id: tc.id,
          name: tc.name,           // required for Gemini path on host
          content: stringifyToolResult(result)
        });
      }
      continue; // model continues with tool outputs
    }

    // No tool calls → final answer
    finalContent = normalized.content || '';
    messages.push({ role: 'assistant', content: finalContent });
    break;
  }

  if (!finalContent && lastAssistantWithTools) {
    finalContent = '(Stopped after max tool rounds without a final answer.)';
    messages.push({ role: 'assistant', content: finalContent });
  }

  return { finalContent, messages };
}

function stringifyToolResult(result) {
  try {
    const s = JSON.stringify(result);
    // keep context small for weak models
    return s.length > 12000 ? s.slice(0, 12000) + '…' : s;
  } catch (_) {
    return String(result);
  }
}
```

### Persist vs display history
- **UI transcript:** show user text + final assistant text/HTML only. Optionally collapse tool rows into a single muted “Used list_apps, launch_app” line under the assistant bubble.
- **Model history for the next user turn:** prefer storing a *compact* history:
  - Either: system + user/assistant final texts only (drop tool rows after the turn completes) — simpler, fewer provider bugs.
  - Or: keep tool rows for multi-step memory (more accurate, more fragile). **Default = drop tool protocol rows after the turn**, keep finals only.
- Never persist multi-MB attachments in storage; only text history.

## Normalize the wild diversity of tool-call formats (REQUIRED)

Providers differ. ForgeHost usually returns OpenAI-like `tool_calls`, but the mini-app must accept all of these shapes from `ai.chat`:

| Source shape | How it may appear |
|--------------|-------------------|
| OpenAI Chat Completions | `tool_calls: [{ id, type:'function', function:{ name, arguments: '<json string>' } }]` |
| OpenAI legacy | `function_call: { name, arguments }` (single) |
| Host already mapped Gemini | same as OpenAI tool_calls (id often `call_gem_…`) |
| Anthropic-ish / other | `content` parts array with `{ type:'tool_use', id, name, input }` |
| Some proxies | `toolCalls` camelCase; `arguments` already an object; `name` at top level |
| Text-only models | no tool_calls — may emit fake XML/JSON in content (optional best-effort parse) |

Implement `normalizeChatResult(raw)`:

```js
function normalizeChatResult(raw) {
  // raw may be string or object
  if (raw == null) return { content: '', tool_calls: [] };
  if (typeof raw === 'string') return { content: raw, tool_calls: [] };

  let content = raw.content ?? raw.text ?? raw.message ?? '';
  if (content && typeof content !== 'string') {
    // rare: content parts array
    if (Array.isArray(content)) {
      content = content.map(p => {
        if (typeof p === 'string') return p;
        if (p && (p.type === 'text' || p.text)) return p.text || '';
        return '';
      }).filter(Boolean).join('\n');
    } else {
      content = String(content);
    }
  }
  content = content || '';

  const out = [];
  const push = (id, name, args) => {
    if (!name) return;
    let parsed = args;
    if (typeof args === 'string') {
      try { parsed = args.trim() ? JSON.parse(args) : {}; }
      catch { parsed = { _raw: args }; }
    } else if (args && typeof args === 'object') {
      parsed = args;
    } else {
      parsed = {};
    }
    out.push({
      id: id || ('call_' + name + '_' + Math.random().toString(36).slice(2, 9)),
      type: 'function',
      name,
      args: parsed,
      // OpenAI wire form for re-send:
      function: { name, arguments: typeof args === 'string' ? args : JSON.stringify(parsed || {}) },
      // keep original bits if present
      _rawArgs: args
    });
  };

  // 1) OpenAI / host unified
  const tcs = raw.tool_calls || raw.toolCalls || raw.functions || [];
  if (Array.isArray(tcs)) {
    for (const tc of tcs) {
      if (!tc) continue;
      const name = tc.function?.name || tc.name || tc.tool_name || tc.toolName;
      const args = tc.function?.arguments ?? tc.arguments ?? tc.args ?? tc.input ?? tc.parameters ?? '{}';
      const id = tc.id || tc.tool_call_id || tc.toolCallId;
      push(id, name, args);
    }
  }

  // 2) Legacy single function_call
  if (!out.length && raw.function_call) {
    push(raw.function_call.id, raw.function_call.name, raw.function_call.arguments);
  }

  // 3) Anthropic-style content tool_use parts (if host ever forwards them)
  const parts = raw.content_parts || raw.parts || (Array.isArray(raw.message?.content) ? raw.message.content : null);
  if (!out.length && Array.isArray(parts)) {
    for (const p of parts) {
      if (!p) continue;
      if (p.type === 'tool_use' || p.type === 'function_call' || p.type === 'toolCall') {
        push(p.id, p.name || p.function?.name, p.input ?? p.arguments ?? p.function?.arguments);
      }
      if (p.type === 'text' && p.text && !content) content += p.text;
    }
  }

  // 4) Nested choices[0].message (if someone returned full OpenAI response by mistake)
  const msg = raw.choices?.[0]?.message;
  if (!out.length && msg) {
    const inner = normalizeChatResult(msg);
    if (inner.tool_calls.length) return inner;
    if (!content && inner.content) content = inner.content;
  }

  // 5) Best-effort: model dumped tools as text (only if tools enabled and no structured calls)
  if (!out.length && settings.enableTools !== false && content) {
    const scraped = scrapeToolsFromText(content);
    if (scraped.calls.length) {
      content = scraped.cleanedText;
      for (const c of scraped.calls) push(c.id, c.name, c.args);
    }
  }

  // Canonical tool_calls for messages.push (OpenAI shape host expects on the way back)
  const tool_calls = out.map(tc => ({
    id: tc.id,
    type: 'function',
    function: {
      name: tc.name,
      arguments: typeof tc._rawArgs === 'string' ? tc._rawArgs : JSON.stringify(tc.args || {})
    }
  }));

  return { content, tool_calls, parsed: out };
}

function scrapeToolsFromText(text) {
  // Optional safety net for non-tool models — keep conservative.
  const calls = [];
  let cleaned = text;
  // ```tool\n{"name":"list_apps","arguments":{...}}\n```
  cleaned = cleaned.replace(/```(?:tool|function|json)\s*([\s\S]*?)```/gi, (_, body) => {
    try {
      const j = JSON.parse(body.trim());
      const name = j.name || j.function?.name;
      const args = j.arguments || j.parameters || j.input || j;
      if (name && APP_TOOLS.some(t => t.function.name === name)) {
        calls.push({ name, args, id: 'call_txt_' + calls.length });
        return '';
      }
    } catch (_) {}
    return _;
  });
  // <tool_call name="list_apps">{"query":"maps"}</tool_call>
  cleaned = cleaned.replace(/<tool_call\s+name=["']([^"']+)["']\s*>([\s\S]*?)<\/tool_call>/gi, (_, name, body) => {
    if (!APP_TOOLS.some(t => t.function.name === name)) return _;
    let args = {};
    try { args = JSON.parse(body.trim() || '{}'); } catch { args = { _raw: body.trim() }; }
    calls.push({ name, args, id: 'call_xml_' + calls.length });
    return '';
  });
  return { calls, cleanedText: cleaned.trim() };
}
```

### Re-send rules (provider hygiene)
When pushing back into `messages` for the next hop:
1. **assistant** row with `tool_calls` must use OpenAI shape (`function.arguments` as **string**). Include `name` on each tool result row for Gemini.
2. **tool** rows: `{ role:'tool', tool_call_id, name, content: string }`.
3. Do **not** coerce tool/assistant.tool_calls rows into `role:'user'`.
4. Do **not** strip `tool_calls` from the assistant message before the tool results are sent.
5. If `ai.chat` throws because the provider rejects tools, retry **once** without `tools`/`tool_choice` and surface status "Provider has no tools — plain chat".
6. Parallel tool_calls from one assistant message: execute all, then one follow-up chat (OpenAI parallel tools style).

### System prompt additions for tools
Merge into system message when enableTools:
"""
You can call tools to control this Android phone's apps:
- list_apps(query?, limit?) — find installed apps
- list_activities(packageName) — activities for a package
- launch_app({ packageName?, activity?, component?, data?, ... }) — open app or deep link
Use tools when the user wants to open/find apps, navigate, message links, etc.
Prefer list_apps before launch when the package name is unknown.
For deep links (WhatsApp, maps, tel), prefer launch_app with data= URI.
After tools run, give a short confirmation in plain text or forge-html.
Never invent package names; use list_apps results.
"""

Camera / gallery:
```js
await ForgeHost.permissions.request('camera')
const shot = await ForgeHost.camera.takePhoto({ quality: 82, maxWidth: 1600, facing: 'back' })
// shot: { dataUrl, base64, mime:'image/jpeg', width, height, bytes }
const gal = await ForgeHost.camera.pickPhoto({ quality: 85, maxWidth: 1600 })
```
Display pending thumbs with dataUrl; if paint fails, blob: from base64 then fallback (srcdoc quirks).

Files (PDF / audio / images):
```js
const picked = await ForgeHost.files.pick({
  accept: 'image/*,application/pdf,audio/*,.pdf,.png,.jpg,.jpeg,.webp,.gif,.mp3,.wav,.m4a,.aac,.ogg',
  multiple: true,
  // if host ignores unknown opts, still works single
})
// Normalize whatever shape host returns into { name, mime, dataUrl?, base64?, bytes?, type:'image'|'file' }
```
- Images → attachment type 'image'
- PDF / audio / other → type 'file' with mime + name
- If result is huge and only has path, prefer host-provided dataUrl/base64; don't invent fs hacks unless ForgeHost.files.readStaged / fs.readBase64 exists and is needed.

HTTP / CORS inline for HTML replies (REQUIRED when settings.inlineImages):
```js
// Prefer host rewriter if present:
const inlined = await ForgeHost.http.inlineHtml(htmlString, {
  // timeoutMs, maxBytes, etc. if supported — safe to omit
})
// inlined may be string or { html / data }
// Fallback if inlineHtml missing:
//   parse img src + css url(), for each http(s) URL:
//   const r = await ForgeHost.http.get(url) or ForgeHost.http.request(...)
//   replace with data: mime;base64,...
```
Only then put HTML into the bubble iframe/srcdoc.
Sandbox iframe: sandbox="allow-scripts allow-same-origin" is NOT required; prefer sandbox="allow-scripts allow-modals" WITHOUT allow-same-origin if parent is host — actually for srcdoc mini-apps embedding child HTML, use:
  <iframe sandbox="allow-scripts allow-forms allow-modals" referrerpolicy="no-referrer"></iframe>
  and set srcdoc = inlinedHtml (with a small base CSS for dark/light readability).
Do not execute assistant HTML in the parent document (XSS). Always iframe/srcdoc.

Permissions UX:
- Request camera before takePhoto; on deny, status + ForgeHost.device.openSettings() button if available.
- Gallery/files: let the pick UI fail softly.

Lifecycle:
- Persist: providerId, htmlScale, inlineImages, preferHtml, systemPrompt, temperature via ForgeHost.storage.
- New chat clears messages + pending attachments; keep settings.
- on pause/destroy: nothing critical; abort in-flight flag so late results don't append twice.

## Reply format contract (teach the model)

Always include a system message (merge with user system prompt) roughly:

"""
You are Forge Chat on a phone. Be concise unless asked for depth.
You may answer in plain text OR, when richer layout helps (tables, step cards, comparison grids, simple SVG/HTML diagrams, styled checklists), reply with a SINGLE HTML fragment.

HTML rules when you choose HTML:
- Return ONLY an HTML fragment wrapped exactly as:
  <!--forge-html-->
  ...fragment...
  <!--/forge-html-->
- No markdown fences around it. No <html>/<body> wrappers.
- Inline CSS only; no external stylesheets or scripts.
- Prefer relative units; target mobile width ~360px.
- Images: use absolute https URLs when needed (the client will inline them). Avoid huge base64 in the model output.
- Accessible contrast on dark background (#0f172a page; cards #1e2937; text #e2e8f0).

When plain text is enough, do not use the forge-html wrapper.
"""

If settings.preferHtml is OFF, change system line to "Reply in plain text only. No HTML."

### Detecting HTML replies
```js
function splitAssistantContent(content) {
  const s = String(content || '');
  const m = s.match(/<!--forge-html-->([\s\S]*?)<!--\/forge-html-->/i);
  if (m) return { kind: 'html', html: m[1].trim(), textAround: s.replace(m[0], '').trim() };
  // Heuristic fallback: starts with < and has a tag pair, not a short "<3"
  if (/^\s*<[a-z][\s\S]*>/i.test(s) && /<\/[a-z]+>\s*$/i.test(s)) return { kind: 'html', html: s.trim(), textAround: '' };
  return { kind: 'text', text: s };
}
```
For kind==='html': run inlineHtml → render in scaled iframe; also show textAround if any.
For kind==='text': render text bubble (escape HTML entities).

HTML scale implementation:
- Wrapper around iframe: style={`transform: scale(htmlScale); transform-origin: top left; width: calc(100% / htmlScale)`} OR css zoom: htmlScale where supported.
- Re-apply when settings change (update all .html-frame elements).

## Attachment → ai.chat mapping helper
```js
function toChatAttachment(item) {
  const mime = item.mime || item.contentType || 'application/octet-stream';
  const name = item.name || 'file';
  const dataUrl = item.dataUrl || item.dataURL ||
    (item.base64 ? `data:${mime};base64,${String(item.base64).replace(/\s/g,'')}` : '');
  const base64 = item.base64 || (dataUrl.includes('base64,') ? dataUrl.split('base64,').pop() : '');
  const isImg = /^image\//i.test(mime) || item.type === 'image';
  if (isImg) return { type: 'image', mime, name, dataUrl, base64 };
  return { type: 'file', mime, name, dataUrl, base64 };
}
```
Pass array of these as `attachments` on the first ai.chat call for that send. Clear pending strip after successful send (keep on failure).

## Send flow
1. If loading return.
2. Snapshot text + pending attachments; require at least one of text/attachments.
3. Push user bubble to UI (text + local previews only).
4. Clear composer + pending attachments.
5. Build `historyMessages` = [system (with tools+HTML instructions), ...prior finals, new user text row].
6. `const { finalContent, messages } = await runChatTurn({ historyMessages, attachments, providerId })`.
7. Append assistant bubble via splitAssistantContent(finalContent); if html → inlineHtml → scaled iframe.
8. Persist compact history (finals only by default) via ForgeHost.storage.
9. Errors: status + toast; keep failed attachments optional re-queue.
10. Abort flag: if user hits New chat mid-loop, ignore further appends.

## Nice extras (include if space)
- Long-press assistant bubble → copy text / "Copy HTML source".
- Retry last failed send.
- Show token-ish size warning if >4 images.
- Provider refresh button in settings.
- Soft haptic via ForgeHost.device.vibrate(20) on send if available.
- Tool log drawer (last turn's tool names + ok/error) for debugging.
- Suggestion chip: "Open WhatsApp" / "Find Maps" to exercise tools.

## Out of scope
- Do not implement provider API keys UI (host Settings does that).
- Do not use continuous mic / liveTranslate.
- Do not call random native plugins beyond ai.*, apps.*, camera.*, files.*, http.*, storage/state, toast, permissions, device.
- Do not auto-launch apps without the confirm setting path when confirm is ON.
- Do not put secrets or SMS/contacts tools in this app.

## Deliverable
Single self-contained HTML mini-app (inline CSS + JS). No external CDN scripts.
Title/metadata suitable for Forge Library import.
Works inside Forge's sandboxed srcdoc WebView on Android.

### Acceptance tests (mental / on device)
1. take photo → "what is this?" → text answer (vision provider).
2. attach PDF → summarize.
3. "make a comparison table of X vs Y as pretty cards" → HTML card + scale 100% and 150%.
4. "what map apps do I have?" → tool list_apps → readable list (no raw mega-JSON dump).
5. "open WhatsApp" → list_apps and/or launch_app → confirm sheet → app opens → short confirmation text.
6. Provider without tools → soft fallback plain chat, no crash.
7. Parallel/multiple tool_calls in one round still works; max rounds stops infinite loops.
8. New chat clears transcript; settings (provider, html scale, tools toggles) remain.
```

---

### After generate
1. Library → open the app → ⚙️ pick a provider that supports **tools** (and vision if you want photo Q&A).  
2. PDF text extraction quality depends on host/provider; images need a vision-capable model.  
3. If HTML images stay broken, confirm host has `http.inlineHtml` (Forge 2.6.x+) and Settings → Inline remote images = ON.  
4. If tools never fire: provider may not support tools — try OpenAI/Groq/xAI/Claude-compatible; Gemini works via host `functionDeclarations` mapping.  
5. Re-import if you iterate: Export → refine prompt → generate again, or edit HTML in place.
