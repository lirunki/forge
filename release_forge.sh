#!/data/data/com.termux/files/usr/bin/bash
# Release Forge — builds BOTH distribution flavors from the same source.
#
#   full  -> APK  (all permissions)  → website / F-Droid / sideload  [Forge-full-release.apk]
#   play  -> AAB  (perms stripped)   → Google Play upload            [Forge-play-release.aab]
#
# Both are signed with the official release keystore (android/keystore.properties + android/.keystore/).
# Does NOT delete any folders. Bumps nothing automatically — set versionCode/versionName in app/build.gradle first.
#
# Run from Termux:   bash forge/release_forge.sh
# Requires: proot-distro ubuntu with android-sdk + java-17 (same env as build_forge.sh).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
ANDROID="$ROOT/android"
KEYSTORE_PROPS="$ANDROID/keystore.properties"
KEYSTORE_FILE="$ANDROID/.keystore/forge-upload.jks"
OUT_DIR="$ROOT/release-out"
SD_DIR="/sdcard/Download"

echo "== Forge release build =="
echo "  root: $ROOT"
echo "  versionCode/Name from app/build.gradle"

# Guard: release keystore must exist for an official release.
if [ ! -f "$KEYSTORE_PROPS" ] || [ ! -f "$KEYSTORE_FILE" ]; then
  echo "FATAL: release keystore missing."
  echo "  expected: $KEYSTORE_PROPS"
  echo "  expected: $KEYSTORE_FILE"
  echo "  These are gitignored release secrets. Restore them from your offline backup."
  echo "  (Forks: create your own keystore + keystore.properties to build releases.)"
  exit 1
fi

mkdir -p "$OUT_DIR"

# Read version for stamping + output naming.
VERSION_NAME=$(grep -m1 'versionName' "$ANDROID/app/build.gradle" | sed -E 's/.*"([^"]+)".*/\1/')
VERSION_CODE=$(grep -m1 'versionCode' "$ANDROID/app/build.gradle" | grep -oE '[0-9]+')
GIT_SHA="dev"
if command -v git >/dev/null 2>&1 && [ -d "$ROOT/.git" ]; then
  GIT_SHA="$(cd "$ROOT" && git rev-parse --short HEAD 2>/dev/null || echo dev)"
fi
echo "  version=$VERSION_NAME code=$VERSION_CODE sha=$GIT_SHA"

# Stamp forge-build.json into www + assets (same as build_forge.sh).
WWW="$ROOT/www"
ASSETS="$ANDROID/app/src/main/assets/public"
STAMP_JSON=$(printf '{"version":"%s","versionCode":%s,"sha":"%s","builtAt":%s}' \
  "$VERSION_NAME" "$VERSION_CODE" "$GIT_SHA" "$(date -u +%s)000")
printf '%s' "$STAMP_JSON" > "$WWW/forge-build.json"
printf '%s' "$STAMP_JSON" > "$ASSETS/forge-build.json"
echo "  stamped forge-build.json"

# Ensure www/index.html parity with assets (guarantee before build).
cp -f "$WWW/index.html" "$ASSETS/index.html"
# Turn-key config ships as an asset (host fetches it locally + remote git URL).
[ -f "$WWW/turnkey-config.json" ] && cp -f "$WWW/turnkey-config.json" "$ASSETS/turnkey-config.json"
for f in cordova.js cordova_plugins.js; do
  [ -f "$WWW/$f" ] && cp -f "$WWW/$f" "$ASSETS/$f"
done

echo "== Gradle: assembleFullRelease + bundlePlayRelease =="
proot-distro login ubuntu -- bash -lc "
set -e
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=\$JAVA_HOME/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH
cd '$ANDROID'
echo 'sdk.dir=/opt/android-sdk' > local.properties
if [ ! -f gradlew ]; then
  if ! command -v gradle >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y -qq gradle >/dev/null
  fi
  gradle wrapper --gradle-version 8.2
fi
chmod +x gradlew
./gradlew --no-daemon clean assembleFullRelease bundlePlayRelease

FULL_APK=\$(ls -1 app/build/outputs/apk/full/release/*.apk | head -1)
PLAY_AAB=\$(ls -1 app/build/outputs/bundle/playRelease/*.aab | head -1)
cp -f \"\$FULL_APK\" '$OUT_DIR/Forge-full-release.apk'
cp -f \"\$PLAY_AAB\" '$OUT_DIR/Forge-play-release.aab'
cp -f \"\$FULL_APK\" '$SD_DIR/Forge-full-release.apk'
cp -f \"\$PLAY_AAB\" '$SD_DIR/Forge-play-release.aab'
echo '== Artifacts =='
ls -la '$OUT_DIR/Forge-full-release.apk' '$OUT_DIR/Forge-play-release.aab'
echo OK
"

echo
echo "== Done =="
echo "  Full APK  : $OUT_DIR/Forge-full-release.apk  (also /sdcard/Download/)"
echo "  Play AAB  : $OUT_DIR/Forge-play-release.aab  (also /sdcard/Download/)"
echo
echo "Next steps:"
echo "  - Play: upload Forge-play-release.aab in Play Console → Production → Create release"
echo "  - Website/F-Droid: ship Forge-full-release.apk"