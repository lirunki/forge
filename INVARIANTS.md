# Forge agent INVARIANTS

## ⛔ NEVER DELETE FOLDERS WITHOUT EXPLICIT USER PERMISSION

```
╔══════════════════════════════════════════════════════════════════╗
║  DO NOT delete, rm -rf, wipe, or empty ANY folder                ║
║  (forge/, android/, www/, node_modules/, backups)    ║
║                                                                  ║
║  ONLY with EXPLICIT user permission naming that path.            ║
║  “clean up / rebuild / recover / reorganize” ≠ permission.       ║
║  When in doubt: DO NOT DELETE. Ask first.                        ║
╚══════════════════════════════════════════════════════════════════╝
```

### Allowed without asking
- Edit/create files
- Build APKs; `adb install` when user asks
- Copy/backup into **new** paths
- npm install into existing tree

### Not allowed without explicit consent
- Deleting whole `forge/`, `android/`, original APKs
- Wiping trees to “start fresh”
