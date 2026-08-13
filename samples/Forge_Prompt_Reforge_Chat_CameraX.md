# Forge prompt — Reforge Chat (CameraX · thin mini-app · host-owned media)

Paste **everything inside the fenced block below** into Forge Chat / **Forge it**  
(normal phone mini-app — not car mode).

Use this to **rebuild or replace** an existing Forge Chat / AI Chat mini-app so camera works
reliably on current Forge host (**CameraX in-process capture**, host normalizes media).

---

```
Rebuild my Forge mini-app as a polished full-screen AI chat titled "Forge Chat".

IMPORTANT CONTEXT (Forge host already does the hard parts — do NOT reimplement them):
- Camera is CameraX inside Forge (in-app shutter UI). Call ForgeHost.camera.takePhoto only.
- Do NOT use getUserMedia, <input capture>, navigator.mediaDevices, or Capacitor Camera plugins.
- Do NOT invent FileProvider / MediaStore / OEM camera workarounds.
- Host already: requests defaults (quality~85, maxWidth~1280), returns clean JPEG fields, normalizes base64+dataUrl, and makes large data: URLs safe for <img> in srcdoc (blob rewrite). Trust the host.
- Keep the mini-app THIN. Prefer host helpers when present.

## Back-compat camera / media contract (REQUIRED)

```js
// Permission (best-effort)
try { await ForgeHost.permissions.request('camera'); } catch (_) {}
try { await ForgeHost.camera.requestPermission('camera'); } catch (_) {}

// Capture — opts optional; host fills defaults
const shot = await ForgeHost.camera.takePhoto({ quality: 85, maxWidth: 1280, facing: 'back' });
// shot always treated as:
// { base64, dataUrl, mime:'image/jpeg', width, height, bytes, path?, engine?, previewUrl?, blobUrl?, displayUrl?, rawDataUrl? }

// Gallery
const gal = await ForgeHost.camera.pickPhoto({ quality: 85, maxWidth: 1280 });

// Display thumbnail (prefer host helper if available)
if (ForgeHost.camera.setImg) {
  ForgeHost.camera.setImg(imgEl, shot);
} else {
  imgEl.src = shot.previewUrl || shot.blobUrl || shot.displayUrl || shot.dataUrl || '';
}

// For AI upload / share: ONLY real data: or base64 — NEVER blob:
function toAiImagePart(shot) {
  const mime = shot.mime || 'image/jpeg';
  let b64 = (shot.base64 || '').replace(/\s+/g, '');
  let du = shot.rawDataUrl || shot.dataUrl || '';
  if (du && String(du).startsWith('blob:')) du = '';
  if (!b64 && du.includes('base64,')) b64 = du.split('base64,').pop();
  if (!du && b64) du = `data:${mime};base64,${b64}`;
  return { type: 'image', mime, name: shot.name || 'photo.jpg', dataUrl: du, base64: b64 };
}
```

Normalize any camera/gallery/files.pick result defensively (host may already have done this):

```js
function normalizeMedia(raw, fallbackName = 'file') {
  if (!raw || raw.cancelled) return null;
  let item = Array.isArray(raw) ? raw[0] : (raw.files && raw.files[0]) || raw;
  if (!item || item.cancelled) return null;
  if (ForgeHost.camera?.normalize) {
    item = ForgeHost.camera.normalize(item);
  }
  let mime = (item.mime || item.type || '').toLowerCase() || 'application/octet-stream';
  let b64 = (item.base64 || '').replace(/\s+/g, '');
  let du = item.rawDataUrl || item.dataUrl || item.dataURL || '';
  if (String(du).startsWith('blob:')) du = '';
  if (!b64 && du.includes('base64,')) b64 = du.split('base64,').pop().replace(/\s+/g,'');
  if ((!mime || mime === 'application/octet-stream') && (item.width || item.height || item.format === 'jpeg' || (b64 && b64.startsWith('/9j/')))) mime = 'image/jpeg';
  if (!du && b64) du = `data:${mime};base64,${b64}`;
  if (!b64 && !du && !item.path && !item.uri) return null;
  return {
    type: mime.startsWith('image/') ? 'image' : 'file',
    name: item.name || fallbackName,
    mime, base64: b64 || null, dataUrl: du || null,
    previewUrl: item.previewUrl || item.blobUrl || item.displayUrl || du || null,
    width: item.width, height: item.height, bytes: item.bytes || item.size || null,
    path: item.path || null, uri: item.uri || null,
  };
}
```

On every capture/pick: try/catch, status line (never alert), show thumbnail chip, reject empty results with a clear status message.

## Product features

1. Use host-configured AI providers only — NO API keys in HTML.
2. Multi-turn chat with ForgeHost.ai.chat / listProviders.
3. Attach: (a) Take photo (b) Camera roll / pickPhoto (c) Files (image/pdf/audio) via ForgeHost.files.pick.
4. Send attachments on the first hop of a turn via `attachments: [...]` using toAiImagePart / equivalent (dataUrl+base64, never blob).
5. Tool calling loop OWNED by the mini-app: list_apps, list_activities, launch_app via ForgeHost.apps.* (defensive tool_calls parsing; JSON-parse string arguments).
6. Assistant can return plain text OR HTML between <!--forge-html--> ... <!--/forge-html-->; render HTML in sandboxed iframe; optional ForgeHost.http.inlineHtml for remote images when available.
7. Settings: provider select, system prompt, HTML scale, inline images, enable tools, confirm launch, max tool rounds. Persist with ForgeHost.storage.
8. New chat clears history (confirm if non-empty).

## UI (mobile-first, dark)

- Top bar: title "Forge Chat", subtitle = active provider, buttons ⚙️ Settings + ✨ New chat.
- Status line under bar: Ready / Opening camera… / Attached photo.jpg (120 KB) / Thinking… / tool chips / errors.
- Scrollable messages: user right, assistant left.
- Pending attach strip above composer: image thumbs (40–48px) + remove ×; file chips for non-images.
- Composer: textarea, 📎 attach menu (Take photo / Camera roll / Files), send.
- Settings bottom sheet/modal: provider, system prompt, HTML scale slider, toggles, max tool rounds, Save/Cancel.
- No alert(); use status + optional ForgeHost.toast.

## AI call shape

```js
const raw = await ForgeHost.ai.chat({
  messages: history,           // system + turns; include tool results as role:'tool'
  providerId: settings.providerId || undefined,
  temperature: settings.temperature ?? 0.7,
  tools: settings.enableTools ? APP_TOOLS : undefined,
  tool_choice: settings.enableTools ? 'auto' : undefined,
  attachments: firstHop ? pending.map(toAiImagePart).filter(a => a.dataUrl || a.base64) : undefined,
});
// Normalize: content/text, tool_calls[] with {id,name,args}
// Do NOT push the user message twice into history.
```

## Hard rules

- Single HTML file, no build step, no external frameworks (vanilla JS/CSS).
- Only ForgeHost bridges (ai, camera, files, apps, storage, permissions, toast, http.inlineHtml if present).
- Camera path must be the thin contract above — host owns CameraX + normalization.
- Works offline for UI; AI needs host providers.
- Accessible tap targets ≥40px; safe-area friendly.
- If a ForgeHost method is missing, degrade gracefully with status text.

## Deliverable

One complete self-contained HTML document I can Import / Open with Forge and run immediately.
```

---

### Shorter variant (camera-only reforge of an existing chat)

If you only want the model to **patch camera/attachments** in an app you paste:

```
You are refactoring an existing Forge mini-app HTML I will paste next.

Goal: make camera/gallery/file attach reliable on current Forge host (CameraX + host-owned media normalize). Keep UI/branding/features otherwise.

Rules:
1. Use ONLY ForgeHost.camera.takePhoto / pickPhoto / requestPermission and ForgeHost.permissions.request('camera').
2. Remove getUserMedia, input[capture], Capacitor Camera, and any OEM-camera hacks.
3. After takePhoto/pickPhoto, normalize with ForgeHost.camera.normalize if present; else ensure base64 + real dataUrl (mime image/jpeg when JPEG magic /9j/).
4. Thumbnails: ForgeHost.camera.setImg(img, shot) if present; else img.src = previewUrl||blobUrl||dataUrl.
5. AI attachments must send dataUrl (data:…) and/or base64 — NEVER blob: URLs.
6. try/catch + status line for Opening camera… / errors / Attached name (KB).
7. Defaults quality:85, maxWidth:1280; facing optional.
8. Do not duplicate user turns in ai.chat history; parse tool arguments if string JSON.
9. Return the FULL updated HTML file only.
```

Then paste your current mini-app HTML in the next message.
