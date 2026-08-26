# Forge workspace builder protocol

You are now in **workspace mode**: instead of emitting one giant JSON payload, you
build the mini-app as files in a build workspace. The host assembles the final
self-contained app when you call `finish`. Read this whole document once, then build.

## When to use this mode

You called `read_loop_md` because the app is too large or complex for a single
response. Commit to workspace mode now: do **not** also return the classic JSON
payload — `finish` is the only way to deliver the app.

## Workflow

1. **Plan briefly** (one short sentence in your head, no file needed).
2. **Write files** with `fs_write` — keep each write focused (one module per call).
   Revise an existing file in place with `fs_edit` (exact unique oldText→newText
   pairs) instead of rewriting it whole. Typical layout:
   - `index.html` — small entry document (see "Assembly rules")
   - `src/main.js`, `src/ui.js`, … — JS modules
   - `assets/style.css` — styles
   - `data/*.json` — generated/computed data (prefer `run_js` for big files)
   - `images/gen_N.png` — created by `gen_image`
3. **Compute data with `run_js`** — never hand-type large data tables. Generate
   them (levels, puzzles, lookups) or validate them in the runner.
4. **Generate art with `gen_image`** (if the provider supports it; errors are
   returned to you — fall back to CSS/SVG/emoji if it fails).
5. **Call `finish`** with `{ "title", "summary", "message" }`.

## Assembly rules (what `finish` does)

The host takes `index.html` (or the `entry` you name) and:

- Inlines `<script src="X">…</script>` when `X` is a text file in the workspace
  → becomes an inline script with the file's content.
- Inlines `<link rel="stylesheet" href="X">` when `X` is a text file
  → becomes an inline `<style>` block.
- Replaces `@asset("X")` tokens **anywhere in the HTML** (attributes, CSS, JS
  string literals) with a data URL of file `X`. Large images are auto-downscaled
  to ≤768px JPEG to keep the app small.

So `index.html` must reference workspace files exactly like this:

```html
<link rel="stylesheet" href="assets/style.css" />
<script src="src/main.js"></script>
<img src="@asset('images/gen_1.png')" alt="hero" />
```

References to files that don't exist in the workspace are left as-is (broken).
Never reference external CDNs/URLs — the final app must be fully self-contained.

## Tool reference

- `fs_write({ path, content, mime?, encoding? })` — `encoding:"base64"` for
  binary. Paths are relative and normalized (`../` is stripped).
- `fs_edit({ path, edits: [{ oldText, newText }, …] })` — apply targeted
  in-place edits to an existing text file. Each `oldText` must match exactly
  once in the ORIGINAL file and not overlap any other edit's match. Fails
  (no change) if a match is missing, non-unique, or overlaps. Prefer this
  over rewriting a whole file when only a few spots change.
- `fs_read({ path })` — text content (truncated at 100k chars); binary files
  return metadata + a 200-char head.
- `fs_list()` — all files with bytes/mime.
- `fs_delete({ path })`
- `run_js({ code })` — your `code` runs in a sandboxed worker with:
  - `api.list()` → array of paths
  - `api.readText(path)` → string (text files)
  - `api.readBase64(path)` → base64 string (binary files)
  - `api.write(path, data, mime?, isBase64?)` — writes land back in the workspace
  - `api.print(...)` — debug output, returned to you
  - Offline only (no fetch, no DOM). 10 second hard limit. Returned: `{ ok,
    result, printed, wrote, writeErrors?, error? }`.
- `gen_image({ prompt })` → `{ path }` (e.g. `images/gen_1.png`). Use it as
  `@asset('images/gen_1.png')`. Max 6 per build.
- `finish({ title, summary, message, entry? })` — assembles + delivers.

## App rules (unchanged from the system prompt)

- Final app uses only `window.ForgeHost` APIs (async, `await` + try/catch).
  No invented bridges, no external CDNs, no API keys in the HTML.
- Mobile-first, polished UI, large tap targets, no `alert()` spam.
- JSON/data files you write must be loaded by the app via `fetch()`-free means:
  the assembler only inlines `script`/`link`/`@asset()` — for JSON data, embed
  it as a JS module (`window.APP_DATA = {...}`) or generate it in `run_js` into
  a `.js` file, not a raw `.json` file.

## Limits

200 files · 10 MB/file · 64 MB total · 6 images/build · 10 s per `run_js` ·
24 rounds total · per-round output budget = the host's max-tokens setting.

If you hit a limit, simplify: fewer/smaller files, generate data instead of
typing it, fewer images.

## Failure recovery

- Tool errors come back as `{ ok:false, error }` — read them and adapt; do not
  repeat the identical failing call.
- If you cannot complete the app, call `finish` with the best working version
  rather than looping forever.
