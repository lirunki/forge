# Forge (`com.forge.live`)

Phone host for mini-apps + AI — reconstructed from **`Forge-debug.apk`** (original binary preserved).

Current version: **2.6.54 / versionCode 84** (see `session.md`).

## ⛔ Never delete folders without explicit permission
See [`INVARIANTS.md`](INVARIANTS.md).

## Build
```bash
bash ~/downloads/build_forge.sh
```

## Install
```bash
# Rebuilt from sources
adb install -r ~/downloads/Forge-debug-rebuilt.apk

# Original APK (preserved, max binary fidelity)
adb install -r ~/downloads/Forge-debug.apk
```

## Structure
- `android/` — Gradle + native plugins  
- `www/` / `android/app/src/main/assets/public/` — UI from APK  
- `docs/` — `api.md` (ForgeHost bridge), `tools.md` (LLM tool registry)  
- `recovered/` — JADX / APKEditor archives (do not delete)  
- `node_modules/@capacitor` — Capacitor 6 Android libraries  

Details: [`session.md`](session.md)
