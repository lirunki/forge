# Workspace folder — design plan (future work, NOT implemented)

> **Status: future work.** This is a locked design plan, not an implementation.
> Decisions are finalized below; the feature is not yet built. When picked up,
> implement against this plan and bump the version (see §7).

## Goal

Add a "Workspace folder" configuration under **Builder capabilities** that lets
the user choose where the agentic-loop / code-mode builder writes its scratch
files during a build. The default is app-private internal storage; the user may
instead pick an arbitrary on-device folder via the Android SAF (Storage Access
Framework) tree picker. Builder scratch files become real, browsable files
(e.g. `index.html`, `src/main.js`, `assets/gen_1.jpg`) that the user can open
from a file manager.

## Decisions (locked)

| decision | choice |
|---|---|
| **Folder scope** | Arbitrary SAF tree — real `ACTION_OPEN_DOCUMENT_TREE` folder picker + `DocumentFile` ops. Requires new native code. |
| **Role** | Builder scratch — live `fs_write` / `run_js` / `gen_image` writes go to the real folder *during* the build (hot path), not just on export. |
| **Internal default** | App-private `Directory.Data` (not user-browsable, wiped on uninstall). |
| **Isolation** | Reuse one folder, **clear on each new build** (not per-app subfolders, not accumulate). |
| **Binary files** | Stored as the **actual file** with its real extension (`.jpg`, `.png`, `.css`, …) — **not base64**. Decoded bytes written directly via the SAF output stream so the user can browse/open the files from a file manager. |
| **Cross-restart resume** | v1 keeps the Resume-button snapshot in memory (messages JSON not persisted to the folder). The benefit is "files survive restart + are browsable," not "Resume works after a cold restart." Cross-restart resume is a separate follow-up. |
| **Revocation fallback** | If the SAF URI permission is revoked mid-build, the next `treeWrite` errors → the loop surfaces the error. We do **not** silently fall back to memory mid-build (a disappearing folder mid-build is a hard fault). |

## What it requires

### 1. Native Java — new bridge plugin (`WorkspaceBridgePlugin.java`, ~200 lines)

A new Capacitor plugin registered in `MainActivity`. Methods:

- `pickTree()` → `ACTION_OPEN_DOCUMENT_TREE` + `startActivityForResult`,
  `takePersistableUriPermission(uri, FLAG_GRANT_READ_URI_PERMISSION |
  FLAG_GRANT_WRITE_URI_PERMISSION)`. Returns `{ uri }`.
- `treeWrite({ uri, path, data, mime, encoding })` → resolve the `DocumentFile`
  tree at `uri`, walk/create the relative path segments (parents as needed),
  open an `OutputStream`, write `data` decoded from base64 when
  `encoding==='base64'` (binary files) or as UTF-8 otherwise. Return
  `{ ok, path, bytes }`.
- `treeRead({ uri, path })` → resolve the child, open `InputStream`, read all
  bytes, return `{ ok, bytes (base64), mime }`.
- `treeList({ uri })` → recursive walk of all files under the tree, return
  `{ ok, files: [{ path, mime, bytes, updatedAt }] }`.
- `treeDelete({ uri, path })` → delete a single child file.
- `treeClear({ uri })` → delete all immediate children (the "clear on new
  build" requirement). Keeps the picked root folder itself.
- `treeStat({ uri })` → verify the persisted URI permission is still held and
  the tree still exists. Return `{ ok, exists }`. Used at boot + before a build.
- Register in `MainActivity` next to the other bridge plugins.

### 2. JS workspace-fs adapter (~120 lines, in `www/index.html`)

`builderWorkspaceFs(backend)` returns the same interface as `builderNewFs()`
(`write / read / list / count / totalBytes / has / get / delete / norm`) but
backed by one of three implementations, selected by `backend`:

- `'memory'` — current in-memory `Map` (the fallback when no folder is picked
  or the persisted permission was revoked at boot).
- `'internal'` — Capacitor `Filesystem` `Directory.Data` (the default).
- `'tree'` — SAF tree URI via the new native bridge (`WorkspaceBridgePlugin`).

All three enforce the existing `BUILDER_FS_MAX_FILES` / `BUILDER_FS_MAX_FILE_BYTES`
/ `BUILDER_FS_MAX_TOTAL_BYTES` limits **before** the write hits disk.

`activeBuilderFs` becomes `builderWorkspaceFs(currentBackend())` instead of
`builderNewFs()`. `builderNewFs()` stays as the memory implementation.

**Binary files (locked decision):** when `b64 === true` (e.g. `gen_image`
output), the tree/internal adapter decodes the base64 and writes the **actual
bytes** with the file's real extension (`.jpg`, `.png`, …) derived from the
mime type. The in-memory map keeps the base64 string (no change), so all three
backends share the same interface while the on-disk file is a browsable real
file.

### 3. Settings UI — "Builder capabilities" folder row (~50 lines + i18n)

Under "Builder capabilities," a folder row:

- Default state: "Internal storage (app-private)" with a button
  "Choose a folder…" → `pickTree()`, stores the returned URI.
- When a folder is chosen: show the truncated URI + a "Reset to internal"
  button (clears the URI, reverts to `Directory.Data`).
- Persist in `LS.workspaceBackend = 'internal'` (default) | `'tree:<uri>'`.
- Drive backup/restore the `workspaceBackend` field (same pattern as
  `codeMode` / `agenticLoop`).
- New i18n keys: `ai.workspaceFolder`, `ai.workspaceFolderHint`,
  `ai.workspaceFolderChoose`, `ai.workspaceFolderReset`,
  `ai.workspaceFolderInternal`, `ai.workspaceFolderChosen`,
  `ai.workspaceFolderRevoked` (boot warning).

### 4. Boot resolution (~30 lines)

On boot (before any build), if `LS.workspaceBackend` starts with `'tree:'`,
call `treeStat` to verify the persisted permission still exists. If revoked or
the tree is gone, fall back to `'internal'` in `LS` and warn the user once via
a toast / status line (`ai.workspaceFolderRevoked`).

### 5. Clear-on-new-build hook (~10 lines)

In `runBuilderLoop` and `runCodeMode`, before the first write of a **fresh**
build (not a resume — resume must not wipe the scratch), if the backend is
`'internal'` or `'tree'`, call the backend's `clear()` (`treeClear` /
`Filesystem.rmdir` of the workspace dir). The memory Map is replaced wholesale
by `builderNewFs()` as today, so no `clear` needed there.

### 6. Parity + gate + version bump

- `android/app/src/main/assets/public/index.html` stays in sync with
  `www/index.html` (the locked invariant — the sync is a build step).
- `bash ~/downloads/forge_check.sh` gate must pass (block #1 module check +
  docs mirror + version baselines).
- `docs/api.md` + `docs/tools.md` + `package.json` + `android/app/build.gradle`
  version bump (e.g. `2.7.61/191 → 2.7.62/192`) and the new `WorkspaceBridgePlugin`
  methods documented in `docs/api.md` + `docs/tools.md` host registry.

## Hot-path note (worth flagging before implementation)

Because this is **scratch** (live writes during a build), every `fs_write` /
`run_js` / `gen_image` call round-trips to native + disk:

| backend | latency per write |
|---|---|
| memory (`Map`) | ~0 (instant) |
| internal (`Directory.Data`) | ~1–5 ms (Capacitor Filesystem) |
| tree (SAF `DocumentFile`) | ~10–50 ms (stream open + write) |

For a 24-round agentic loop with many `fs_write`s this is fine. For code mode
with up to 40 parallel `forge.tools.run` calls hitting the fs, the concurrency
queue (already in `runCodeModeProgram`) keeps it bounded.

**v2 optimization (not v1):** a write-back cache — write to memory, flush to
the folder on `finish()` — gives instant writes + browsable files at the cost
of losing partial files on a mid-build crash. Only worth it if the tree
backend ever feels slow in practice; measure first.

## Open questions (to resolve when implementing)

1. **Mime → extension map**: the tree adapter derives the on-disk extension
   from the file's mime (`image/jpeg` → `.jpg`, `image/png` → `.png`,
   `text/css` → `.css`, …). Hardcode a small map or use a lookup? (Default:
   small hardcoded map + fallback to no extension for unknown mimes.)
2. **`treeClear` permission edge**: if the user picked a folder but the app
   lost write permission between builds, `treeClear` fails → surface the error
   rather than silently keeping stale files. (Already implied by the
   revocation-fallback decision; just confirming the clear path errors loud.)
3. **Drive backup of the URI**: back up just the URI string, or also a
   `treeStat` result snapshot? (Default: just the URI string; verify on
   restore via `treeStat`.)
