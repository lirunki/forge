# Forge (`com.forge.live`)

Phone host for mini-apps + AI — reconstructed from **`Forge-debug.apk` v2.6.1 (33)**.

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
- `recovered/` — JADX / APKEditor archives (do not delete)  
- `node_modules/@capacitor` — Capacitor 6 Android libraries  

Details: [`session.md`](session.md)
