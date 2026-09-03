# Forge prompt — Menu Translator (CameraX · vision AI · thin mini-app)

Paste **everything inside the fenced block below** into Forge Chat / **Forge it**  
(normal phone mini-app — **not** car / AA mode).

Use this to generate a **fresh** Menu Translator mini-app that captures menu photos correctly
on current Forge host (CameraX, host media normalize, vision `ai.chat` attachments).

---

```
Build a polished full-screen Forge mini-app titled "Menu Translator".

Single HTML file. Mobile-first dark UI (zinc/emerald). Tailwind via CDN is fine.
Use ForgeHost only — NO API keys in HTML, NO getUserMedia, NO <input type=file capture>,
NO Capacitor Camera, NO FileProvider/OEM workarounds. Keep the mini-app THIN; trust the host.

================================================================================
PRODUCT
================================================================================

Photograph foreign restaurant menus and translate dishes with the user's configured AI
(vision). Tap a translated item to see original text + optional romanization and hear it
via AI TTS. Copy / share the translation. Multi-photo supported.

Features:
1. Language pair: FROM (French, Italian, Spanish, German, Japanese, Chinese, Korean, …)
   and TO (English default + common targets). Plain <select> only — no custom dropdown hacks.
2. AI provider picker from ForgeHost.ai.listProviders() — only available providers.
   Optional; if empty show "No AI providers configured".
3. MENU PHOTOS section:
   - Button "Take Photo" → ForgeHost.camera.takePhoto
   - Button "From Gallery" → ForgeHost.camera.pickPhoto
   - 2-column thumbnail grid; each thumb has a ALWAYS-VISIBLE remove × (not hover-only)
   - Empty state dashed box when no photos
4. Primary "Translate Menu" + secondary "Clear All"
5. Output panel after translate:
   - HTML menu items (Tailwind) returned by the model
   - Actions: Copy, Share (image of text via canvas + ForgeHost.share.file), Voice (pick TTS voice)
6. Item tap → modal with ORIGINAL (+ ROMAJI when relevant) and "Sound it" (ai.tts)
7. Persist selected voice with ForgeHost.storage if available (fallback memory).
8. No alert(); use ForgeHost.toast + inline status/errors only.

================================================================================
CAMERA / MEDIA CONTRACT (REQUIRED — do not freestyle)
================================================================================

Host owns CameraX in-process capture. Defaults quality≈85, maxWidth≈1280.
Result shape (defensive):
{ base64, dataUrl, mime, width, height, bytes, path?, engine?,
  previewUrl?, blobUrl?, displayUrl?, rawDataUrl? }

MUST implement helpers equivalent to:

```js
function cleanB64(b){
  return String(b||'').replace(/\s+/g,'').replace(/^data:[^;]+;base64,/i,'');
}

function b64ToBlobUrl(b64, mime){
  mime = mime || 'image/jpeg';
  const bin = atob(cleanB64(b64));
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return URL.createObjectURL(new Blob([bytes], { type: mime }));
}

/** Normalize camera/gallery result. Host may already normalize — still be defensive. */
function normalizeMedia(raw, fallbackName){
  if (!raw || raw.cancelled) return null;
  let item = Array.isArray(raw) ? raw[0] : (raw.files && raw.files[0]) || raw;
  if (!item || item.cancelled) return null;
  try {
    if (ForgeHost.camera && ForgeHost.camera.normalize)
      item = ForgeHost.camera.normalize(item) || item;
  } catch (_) {}

  let mime = String(item.mime || item.type || item.contentType || '').toLowerCase();
  let b64 = cleanB64(item.base64 || '');
  let du = item.rawDataUrl || item.dataUrl || item.dataURL || '';
  if (du && String(du).startsWith('blob:')) du = '';
  if (!b64 && du && /base64,/i.test(du)) b64 = cleanB64(du.split(/base64,/i).pop() || '');
  if ((!mime || mime === 'application/octet-stream') &&
      (item.width || item.height || item.format === 'jpeg' || (b64 && b64.indexOf('/9j/') === 0)))
    mime = 'image/jpeg';
  if (!mime) mime = 'image/jpeg';
  if (!du && b64) du = 'data:' + mime + ';base64,' + b64;
  if (!b64 && !du && !item.path && !item.uri) return null;

  let preview = item.previewUrl || item.blobUrl || item.displayUrl || '';
  if ((!preview || !String(preview).startsWith('blob:')) && b64 && mime.indexOf('image/') === 0) {
    try { preview = b64ToBlobUrl(b64, mime); } catch (_) { preview = ''; }
  }
  if (!preview) preview = du || '';

  return {
    name: item.name || fallbackName || 'menu.jpg',
    type: 'image',
    mime, base64: b64 || null, dataUrl: du || null, rawDataUrl: du || null,
    previewUrl: preview || null,
    width: item.width, height: item.height,
    bytes: item.bytes || item.size || (b64 ? Math.floor(b64.length * 0.75) : null),
  };
}

/** AI attachment — NEVER blob: URLs */
function toAiImagePart(shot, index){
  const mime = (shot && shot.mime) || 'image/jpeg';
  let b64 = cleanB64(shot && shot.base64);
  let du = (shot && (shot.rawDataUrl || shot.dataUrl)) || '';
  if (du && String(du).startsWith('blob:')) du = '';
  if (!b64 && du && /base64,/i.test(du)) b64 = cleanB64(du.split(/base64,/i).pop() || '');
  if (!du && b64) du = 'data:' + mime + ';base64,' + b64;
  if (!du && !b64) return null;
  return {
    type: 'image',
    mime,
    name: (shot && shot.name) || ('menu-' + (index + 1) + '.jpg'),
    dataUrl: du || null,
    base64: b64 || null,
  };
}

/** Thumbnail display — prefer host helper; never put huge data: into innerHTML attributes */
function setImgWithFallback(img, shot){
  if (!img || !shot) return false;
  try {
    if (ForgeHost.camera && ForgeHost.camera.setImg && ForgeHost.camera.setImg(img, shot))
      return true;
  } catch (_) {}
  const tryList = [];
  if (shot.previewUrl) tryList.push(shot.previewUrl);
  if (shot.blobUrl) tryList.push(shot.blobUrl);
  if (shot.displayUrl) tryList.push(shot.displayUrl);
  if (shot.dataUrl && /^data:/i.test(shot.dataUrl)) tryList.push(shot.dataUrl);
  if (shot.base64) {
    try { tryList.push(b64ToBlobUrl(shot.base64, shot.mime || 'image/jpeg')); } catch (_) {}
    try { tryList.push('data:' + (shot.mime || 'image/jpeg') + ';base64,' + cleanB64(shot.base64)); } catch (_) {}
  }
  if (!tryList.length) return false;
  let ti = 0;
  img.onerror = function(){ ti++; if (ti < tryList.length) img.src = tryList[ti]; };
  img.src = tryList[0];
  return true;
}
```

Capture flow (REQUIRED):
```js
async function takePhoto(){
  try {
    try { await ForgeHost.permissions.requestPack('media'); } catch (_) {}
    try { await ForgeHost.permissions.request('camera'); } catch (_) {}
    const shot = await ForgeHost.camera.takePhoto({ quality: 85, maxWidth: 1280, facing: 'back' });
    if (!shot) { ForgeHost.toast('Camera returned nothing'); return; }
    const media = normalizeMedia(shot, 'camera.jpg');
    if (!media || (!media.base64 && !media.dataUrl)) {
      ForgeHost.toast('No image data from camera'); return;
    }
    photos.push(media);
    renderPhotos();
  } catch (e) {
    ForgeHost.toast('Camera error: ' + (e.message || e));
  }
}

async function pickFromGallery(){
  try {
    try { await ForgeHost.permissions.requestPack('media'); } catch (_) {}
    const shot = await ForgeHost.camera.pickPhoto({ quality: 85, maxWidth: 1280 });
    if (!shot) { ForgeHost.toast('No photo selected'); return; }
    const media = normalizeMedia(shot, 'gallery.jpg');
    if (!media || (!media.base64 && !media.dataUrl)) {
      ForgeHost.toast('No image data from gallery'); return;
    }
    photos.push(media);
    renderPhotos();
  } catch (e) {
    ForgeHost.toast('Gallery error: ' + (e.message || e));
  }
}
```

renderPhotos rules:
- Create <img> with document.createElement — DO NOT inject multi-MB data URLs via innerHTML src="…".
- Call setImgWithFallback(img, photo) after append.
- Remove button always visible (bg-black/80 circle), touch-friendly ≥32px.
- Clear All revokes any object URLs you created.

================================================================================
AI TRANSLATE CONTRACT (REQUIRED)
================================================================================

```js
const attachments = photos
  .map((p, i) => toAiImagePart(p, i))
  .filter(a => a && (a.dataUrl || a.base64));
if (!attachments.length) { ForgeHost.toast('Photos have no image bytes for AI'); return; }

const needsRomaji = /Japanese|Chinese|Korean/i.test(fromLang);

const prompt = `Translate this restaurant menu from ${fromLang} to ${toLang}.
Return ONLY a clean HTML snippet using Tailwind classes (page already has Tailwind).
- Outer: <div class="space-y-3">
- Each item: <div class="menu-item p-4 bg-zinc-950 border border-zinc-800 rounded-2xl cursor-pointer"
  data-original="EXACT ORIGINAL DISH TEXT"${needsRomaji ? ' data-romaji="ROMANIZATION"' : ''}>
- Visible text = ${toLang} only: name, short description if any, price unchanged
- Original script ONLY in data-original / data-romaji — not visible in the card
- Concise, mobile-friendly. No markdown fences.`;

const result = await ForgeHost.ai.chat({
  prompt,                    // host also accepts messages[] — prompt is fine
  attachments,               // top-level vision attachments
  providerId: providerId || undefined,
});
const html = (result && (result.content || result.text)) || '';
// inject html into #output, then wire .menu-item clicks from data-original / data-romaji
```

Provider list on boot:
```js
const menu = await ForgeHost.ai.listProviders();
const providers = (menu.providers || []).filter(p => p.available);
// fill <select id="provider">
```

TTS:
```js
// voices
const v = await ForgeHost.ai.listVoices(); // use v.options = [{value,label},…]
await ForgeHost.ai.tts({ text: cleanOriginal, voice: selectedVoice, mode: 'auto' });
// strip trailing prices from spoken text
```

Share translation as image:
- Draw title + text lines on canvas (dark bg), canvas.toDataURL('image/jpeg', 0.92)
- await ForgeHost.share.file({ name:'translated-menu.jpg', mime:'image/jpeg', dataUrl })

Copy:
- Build plain text lines from translated item text + (original / romaji)
- ForgeHost.clipboard.write(text)

================================================================================
UI LAYOUT
================================================================================

max-w-md centered column, min-h-screen, bg-zinc-950 text-zinc-200.

Header (bg-zinc-900): emoji 🍽️ in emerald rounded square + title "Menu Translator"
+ subtitle "AI-powered menu translations".

Body padding:
- 2-col language selects (FROM / TO) — native <select>, zinc-900, rounded-2xl
- AI PROVIDER select
- MENU PHOTOS label + Take Photo (emerald) / From Gallery (zinc) row
- #photoGrid grid-cols-2 gap-3; #photoEmpty dashed empty state
- Translate Menu (white pill) + Clear All (zinc) row
- #outputSection hidden until first translate: label + Copy/Share/Voice + #output card

Modals (fixed inset black/70):
- Item detail: original, optional romaji, Sound it / Close
- Voice picker: <select> of voices, Save / Cancel
Modal panels stopPropagation on click so backdrop closes only.

================================================================================
HARD RULES (fail the build if violated)
================================================================================

1. ONLY ForgeHost.camera.takePhoto / pickPhoto for images.
2. NEVER send blob: URLs in ai.chat attachments — only data: and/or base64.
3. NEVER set large data: image URLs via innerHTML attributes — use element.src or setImg.
4. Reject empty camera/gallery results with toast (check base64 || dataUrl after normalize).
5. Remove × always visible on touch (no group-hover-only opacity).
6. No API keys, no fake providers, no custom HTML <select> replacements.
7. Prefer optional chaining / try/catch around every ForgeHost call.
8. One self-contained HTML file; boot init() on load.

================================================================================
SMOKE (must work after import)
================================================================================

- Take Photo → thumbnail paints (not blank), toast confirms size
- From Gallery → same
- Remove × works on first tap
- Translate Menu → vision call with real image bytes → item cards
- Tap card → original + Sound it TTS
- Copy / Share work
- Clear All resets photos + output
```

---

## After import

1. Forge → Library → import / open the generated HTML (or paste prompt into Chat → Forge it).  
2. AI Settings: configure a **vision-capable** provider (GPT-4o, Gemini, Claude, etc.).  
3. Open Menu Translator → Take Photo ×1 → confirm thumb → Translate Menu.  
4. If thumbs are blank on an old host build, install the current `Forge-debug-rebuilt.apk`. The historical minimums were CameraX/media normalization ≥ 2.6.16 and the takePhoto hardening from 2.6.28; current Forge is 2.7.54 / versionCode 184.
