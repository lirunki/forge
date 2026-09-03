# Forge — Build & Release Runbook

> **Read this first** for any build, release, install, or push. Kept in the repo
> (version-controlled, on GitHub) so it survives device resets. The phone session
> log lives in `session.md`; this is the stable how-to.

Package: `com.forge.live` · repo root: `~/downloads/forge` · remote: `https://github.com/lirunki/forge.git`

---

## 0. Layout (where things live)

```
~/downloads/forge/                     ← git repo (canonical source)
  BUILD.md                             ← THIS file
  session.md                           ← session log (read at session start)
  INVARIANTS.md                        ← never delete folders; locked baselines
  README.md  docs/  www/index.html
  android/
    app/build.gradle                   ← versionCode / versionName
    app/src/main/assets/public/index.html   ← MUST == www/index.html before build
    app/src/play/AndroidManifest.xml   ← flavor: tools:node="remove" restricted perms
    .keystore/forge-upload.jks         ← RELEASE KEY (gitignored; back up offline forever)
    keystore.properties                ← gitignored; store/key passwords
  release_out/                         ← release artifacts land here
~/downloads/
  build_forge.sh                       ← debug build (+ optional --bump)
  forge_check.sh                       ← pre-build gate (JS/parity/backtick/version)
  forge_docs_check.sh                  ← docs drift guard (wired as step 8 of forge_check.sh)
  forge_smoke.sh                       ← on-device smoke (adb)
  forge_bump.py                        ← versionCode +2 / versionName patch +2
  forge-git-push.sh                    ← commit + PAT-authenticated push to origin
  Forge-debug-rebuilt.apk              ← canonical debug APK (full flavor)
  Forge-debug.apk                      ← ORIGINAL user APK (never modify)
  i18n_salvage/ ← i18n regen: surgery.py + dict_*.py (uses current forge/www/index.html)
~/sdk-tools-aarch64/                   ← arm64 SDK (build-tools, platform-tools, others)
```

---

## 1. Debug build (the everyday loop)

```bash
cd ~/downloads/forge
bash ~/downloads/build_forge.sh          # assembleDebug (full flavor) → Forge-debug-rebuilt.apk
# with a version bump (versionCode +2, versionName patch +2):
bash ~/downloads/build_forge.sh --bump
adb install -r ~/downloads/Forge-debug-rebuilt.apk
```

`build_forge.sh` runs `forge_check.sh` **first** (`set -e` aborts on failure), so a broken
host never ships. It also copies `Forge-play-debug.apk` alongside.

**`--bump` gotcha:** it bumps *every* run. If you run it while diagnosing, gradle
advances (e.g. 105 → 107 → 109). Settle the version by updating `docs/api.md` +
`docs/tools.md` baselines to match `build.gradle`, then build **without** `--bump`.
`forge_docs_check.sh` fails the gate if docs version ≠ gradle version.

---

## 2. The build gate (`forge_check.sh`)

Must be green before any build. Steps:
1. `node --check` on the extracted host `<script>` (catches JS syntax errors)
2. `www/index.html` ≡ `android/.../assets/public/index.html` (parity)
3. `forge-build.json` parity (www ≡ assets)
4. bridge `String.raw\`...\`` backtick-count sanity (the `i is not defined` class of bug)
5. exactly **1** raw `</script>` (host module only — the pre-paint language-gate script
   was removed at 2.6.74; if you re-add a top-level script, bump this count)
6. version stamp parity (build.gradle vs host `window.__FORGE_BUILD`)
7. git tree clean enough to stamp the sha
8. `forge_docs_check.sh` — `docs/` mirrors host tool registry + version baselines

```bash
bash ~/downloads/forge_check.sh          # standalone
```

If it fails on step 5 ("expected exactly N raw </script>"): you added/removed a
top-level `<script>` block — update the expected count in `forge_check.sh` step 5.

---

## 3. Release build (F-Droid APK + Play AAB)

**Prereq:** `android/.keystore/forge-upload.jks` + `android/keystore.properties`
present (gitignored). The script **aborts** if the keystore is missing. Losing the
keystore = can never update Forge on Play. **Back it up offline forever.**

```bash
cd ~/downloads/forge
# 1. Ensure tree is clean + committed (so the sha stamp is the real HEAD):
git status --short                       # must be empty
# 2. Set version in build.gradle FIRST (release_forge.sh does NOT auto-bump):
grep -E "versionCode|versionName" android/app/build.gradle | head -2
# 3. Build both flavors from one source:
bash release_forge.sh
```

`release_forge.sh`:
- stamps `forge-build.json` (`{version, versionCode, sha, builtAt}`) into `www/` + `assets/`
- syncs `www/index.html` → `assets/public/index.html`
- `./gradlew clean assembleFullRelease bundlePlayRelease`
- outputs → `release-out/Forge-full-release.apk` + `Forge-play-release.aab`
  (also copied to `/sdcard/Download/`)
- aborts if the release keystore is missing

### Artifacts

| File | Flavor | Perms | For |
|---|---|---|---|
| `Forge-full-release.apk` | `full` | all (SMS/Call/Contacts/QUERY_ALL_PACKAGES/legacy storage) | F-Droid / website / sideload |
| `Forge-play-release.aab` | `play` | restricted perms stripped via `src/play/AndroidManifest.xml` `tools:node="remove"` | Google Play Console |

Both signed with the **same** upload key → cross-store update preserves data if
F-Droid reproducible builds ship the upstream-signed APK.

### Signer cert (upload key)

- Keystore: `android/.keystore/forge-upload.jks`, alias `forge-upload`, RSA 2048, validity 10000d
- Cert SHA-256: `d4678afb6f294e340342896b12d330a1e9bdca6c10ec9230006401996f409f0c`
- **When enrolling in Play App Signing: upload THIS keystore** (do NOT let Google
  generate the key), so the F-Droid build can match.

### Verification (local tooling limits on this Termux — read before wasting time)

This arm64 Termux SDK is minimal. Known-broken for crypto verification:
- `apksigner` — **not present** in `~/sdk-tools-aarch64/build-tools/`
- `openssl` — **not installed**
- `aapt` — wrong ELF type (can't execute)
- `keytool` — Termux OpenJDK 21 perfetto-trace quirk (`Native registration unable to
  find class 'com/android/internal/dev/perfetto/sdk/PerfettoTrace'`)

So local signature/perm re-verification often can't run here. What IS authoritative:
- gradle's `assembleFullRelease` + `bundlePlayRelease` **signed** the artifacts with the
  release `signingConfig` (the script aborts if the keystore is missing/bad).
- `unzip -l <apk>` confirms structure: `classes.dex` + `META-INF/CERT.RSA` + `MANIFEST.MF` (v1 signed).
- `unzip -l <aab>` confirms bundle format: `BundleConfig.pb` + `base/manifest/AndroidManifest.xml`.
- The flavor split is enforced by gradle product flavors + `src/play/AndroidManifest.xml`
  `tools:node="remove"` — verified working at the 2.6.61 first release, unchanged since.
- **Play Console displays the signer cert SHA-256 on upload** — that's the authoritative
  confirmation it matches `d4678afb…`.

If you need real local crypto verification, install `apksigner` (full build-tools) or
`openssl`, or run on a different machine.

---

## 4. Install to device (adb)

Wireless debugging must be active on the phone (or plug in USB).

```bash
adb devices                               # must list a device
adb install -r ~/downloads/Forge-debug-rebuilt.apk
# About: Settings → About Forge shows vX.Y (code) · <sha>
```

If `adb: no devices/emulators found`: wireless debugging is off. Enable it in
Developer options, then `adb connect <ip>:<port>` (or pair). On-device Termux adb
often needs the phone's own wireless-debugging endpoint.

On-device smoke harness:
```bash
bash ~/downloads/forge_smoke.sh           # cold start, crash check, version stamp
```

---

## 5. Version bumping

```bash
python3 ~/downloads/forge_bump.py        # versionCode +2, versionName patch +2
# or via build:
bash ~/downloads/build_forge.sh --bump
```

After bumping, **update docs baselines** or the gate fails:
```bash
# docs/api.md line 5:  > Version baseline: `X.Y / versionCode N`.
# docs/tools.md line 5: > Version baseline: `X.Y / versionCode N` (27 tools).
```

---

## 6. Commit & push (PAT-authenticated)

No `gh` CLI, no credential helper, no SSH key on this device. Use the script:

```bash
bash ~/downloads/forge-git-push.sh       # commits staged changes + pushes main → origin
```

It uses a stored PAT (do not print it). If it fails on auth, the PAT may be
expired — ask the user.

Manual one-off (no stored token):
```bash
git push https://<PAT>@github.com/lirunki/forge.git main
```

---

## 7. i18n (host UI translations)

Host UI is localized via an inline `FORGE_I18N` dict in `www/index.html` between
`/*__I18N_START__*/` / `/*__I18N_END__*/` markers. 6 languages: en, es, fr, pt, ja, ko.

- Lookup: `t(id, vars)` / `tf(id, fallback, vars)` with `{var}` interpolation + en fallback.
- Boot: `FORGE_LANG` = `localStorage.forge_lang_v1` → else `navigator.languages` auto-detect.
- Static HTML: `data-i18n/-html/-ph/-title/-aria` attributes applied **once at boot**
  (`applyI18nDom`) — no live re-render machinery, no language gate.
- Selector: `Language` `<select>` in AI tab → About Forge card. On change → saves +
  shows `Saved — restart Forge to apply` hint. **Restart applies** the new language.

### Regenerating / adding a language

Source dicts + the regeneration script live in `~/downloads/forge/i18n_salvage/`:
```
surgery.py ← reads current forge/www/index.html + dict_*.py, replaces only the i18n block
dict_en.py            ← canonical English (426 keys incl. gate.*)
dict_es.py dict_fr.py dict_pt.py dict_ja.py   ← original (double-encoded UTF-8; surgery repairs)
dict_ko.py            ← Korean (proper UTF-8, 508 keys)
dict_ja.py            ← includes the 93 Japanese repairs; no separate overlay file is required
```

```bash
cd ~/downloads/forge/i18n_salvage && python3 surgery.py
# then sync + gate + build:
cp ~/downloads/forge/www/index.html ~/downloads/forge/android/app/src/main/assets/public/index.html
cd ~/downloads/forge && bash ~/downloads/forge_check.sh
```

`surgery.py` mojibake rule: `encode('latin-1').decode('utf-8')` round trip; proper
text with non-latin1 chars (CJK, …, —) fails the encode → kept; lossy strings
(dropped C1 bytes) with mojibake lead-pairs → dropped key → `t()` falls back to en.
The merged `dict_ja.py` entries preserve the 93 recovered Japanese translations as proper UTF-8.

To add a new language: write `dict_<lang>.py` (full 425 common + 81 ns keys, proper
UTF-8), add the lang to `LANGS` + `FORGE_LANGS` + `RESTART_HINT` in `surgery.py`,
re-run, sync, gate, build.

---

## 8. Invariants (do not regress)

From `INVARIANTS.md` + `session.md`:
- **Never delete folders** without explicit user permission naming the folder.
- **Original APK** `~/downloads/Forge-debug.apk` never modified.
- **`recovered/`** (JADX/APKEditor reference) never delete.
- **Selects / theme / MainActivity** match original APK behavior — no
  `FORGE_SELECT_FIX`, no `appearance:none` hacks, no `FORCE_DARK`, no custom
  HTML dropdown, no `configureWebViewChrome`/`AppCompatDelegate` night force.
- **`www/index.html` ≡ `assets/public/index.html`** before every build (gate enforces).
- **AI tools/attachments** host fix is intentional — keep it when touching UI.
- **Release keystore** — back up offline forever; upload THIS key to Play App Signing.
- New host features → land incrementally + rebuild/verify; never drop a 500+ line
  block into `index.html` without a syntax + cold-start check.

---

## 9. Quick reference — the full release loop

```bash
cd ~/downloads/forge
git status --short                        # clean?
bash ~/downloads/forge_check.sh           # gate green?
bash release_forge.sh                     # → release-out/Forge-full-release.apk + Forge-play-release.aab
# Play:  upload release-out/Forge-play-release.aab  → Production → Create release
# F-Droid: ship release-out/Forge-full-release.apk
```
