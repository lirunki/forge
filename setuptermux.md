# Building Android APK and AAB Files from Termux on Android

This guide reproduces the working ARM64 Android build environment used for the Forge and AAForge projects.

It is written for another coding agent: commands, paths, environment variables, project-specific requirements, known failures, and release procedures are included. No API keys, passwords, personal access tokens, or signing-key material belong in this file.

## 0. Architecture of the working environment

The final setup is deliberately split into two layers:

```text
Android phone
└── Termux (native ARM64 host)
    ├── source files under ~/downloads
    ├── Node/npm host utilities
    ├── adb, git, helper scripts
    ├── proot-distro
    └── ~/sdk-tools-aarch64/build-tools/aapt2

        Ubuntu ARM64 container, entered with proot-distro
        ├── OpenJDK 17
        ├── Node.js 22
        ├── Android SDK at /opt/android-sdk
        └── Gradle wrapper builds
```

Use native Termux for file management, `adb`, Git, and the wrapper scripts. Run Android SDK, Capacitor bootstrap, and Gradle tasks inside Ubuntu proot.

### Why Ubuntu proot is required

The initial attempt used Google Android command-line tools directly in native Termux. Native `sdkmanager` aborted with:

```text
Native registration unable to find class
'com/android/internal/dev/perfetto/sdk/PerfettoTrace'
```

This is a JVM/Android-runtime compatibility problem. Do not depend on native Termux `sdkmanager` or native Termux Gradle for the final build. The working solution is Ubuntu ARM64 under `proot-distro`.

## 1. Prerequisites

- ARM64/aarch64 Android device.
- Current Termux installation from F-Droid or the Termux GitHub releases. Avoid the obsolete Play Store package.
- Network access.
- Several GB of free internal storage for the Ubuntu rootfs, SDK, Gradle caches, npm modules, and build outputs.
- Optional USB debugging or Android wireless debugging for installing APKs.

Start Termux and grant storage access if required:

```bash
termux-setup-storage
```

The working source directory is:

```text
/data/data/com.termux/files/home/downloads
```

In shell commands this is:

```bash
~/downloads
```

Do not place the project under shared external storage if avoidable. Gradle and Git behave more reliably in Termux's private home directory.

## 2. Install the native Termux host packages

Update the package database and install the host tools:

```bash
pkg update -y
pkg upgrade -y
pkg install -y \
  nodejs npm \
  openjdk-21 \
  android-tools \
  aapt aapt2 apksigner d8 \
  wget curl unzip which tar \
  proot-distro
```

These native packages are useful for host operations and diagnostics. The final Gradle build uses Ubuntu's JDK 17 and SDK instead of the native JDK.

Verify the basic host:

```bash
node --version
npm --version
adb version
proot-distro --version
uname -m
```

Expected architecture is `aarch64` or `arm64`.

## 3. Install Ubuntu ARM64 with proot-distro

Install the Ubuntu container:

```bash
proot-distro install ubuntu
```

Confirm that it is installed:

```bash
proot-distro list
```

Enter it once to confirm the architecture and filesystem:

```bash
proot-distro login ubuntu -- uname -m
proot-distro login ubuntu -- bash -lc 'ls -la /; echo HOME=$HOME'
```

The Termux home directory is visible inside proot at the same absolute path:

```text
/data/data/com.termux/files/home
```

Consequently, a project at `~/downloads/forge` in Termux is also accessible inside Ubuntu as:

```text
/data/data/com.termux/files/home/downloads/forge
```

## 4. Install the Ubuntu build dependencies

Install JDK 17 and basic utilities inside Ubuntu:

```bash
proot-distro login ubuntu -- bash -lc '
  set -e
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y \
    openjdk-17-jdk-headless \
    wget unzip curl ca-certificates gnupg git
'
```

The working Java path is:

```text
/usr/lib/jvm/java-17-openjdk-arm64
```

Install Node.js inside Ubuntu. The original setup used NodeSource; Node 22 was installed as a result:

```bash
proot-distro login ubuntu -- bash -lc '
  set -e
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
  node --version
  npm --version
'
```

The setup script installs system Gradle only as a fallback when a project has no Gradle wrapper. It is safe to install it now:

```bash
proot-distro login ubuntu -- bash -lc '
  set -e
  apt-get update
  apt-get install -y gradle
  gradle --version
'
```

The checked-in Gradle wrapper is preferred over the system Gradle version.

## 5. Install the Android SDK inside Ubuntu

Use `/opt/android-sdk` as the SDK root. The original working command-line tools archive was:

```text
commandlinetools-linux-11076708_latest.zip
```

Install it and the required SDK packages:

```bash
proot-distro login ubuntu -- bash -lc '
  set -e
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
  export ANDROID_HOME=/opt/android-sdk
  export ANDROID_SDK_ROOT=/opt/android-sdk
  export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

  mkdir -p "$ANDROID_HOME/cmdline-tools"
  cd /tmp
  wget -q \
    https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
    -O commandlinetools.zip

  rm -rf "$ANDROID_HOME/cmdline-tools/latest"
  unzip -q commandlinetools.zip -d "$ANDROID_HOME/cmdline-tools"
  mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" \
     "$ANDROID_HOME/cmdline-tools/latest"

  yes | sdkmanager --sdk_root="$ANDROID_HOME" --licenses || true
  sdkmanager --sdk_root="$ANDROID_HOME" \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0"
'
```

The important SDK directories must exist afterward:

```text
/opt/android-sdk/cmdline-tools/latest
/opt/android-sdk/platform-tools
/opt/android-sdk/platforms/android-34
/opt/android-sdk/build-tools/34.0.0
```

Check them:

```bash
proot-distro login ubuntu -- bash -lc '
  ls -ld /opt/android-sdk/cmdline-tools/latest
  ls -ld /opt/android-sdk/platform-tools
  ls -ld /opt/android-sdk/platforms/android-34
  ls -ld /opt/android-sdk/build-tools/34.0.0
'
```

## 6. Install the ARM64 AAPT2 workaround

On this ARM64 phone, the Android Gradle plugin's Maven-provided `aapt2` was not usable. A native ARM64 copy is required.

Create the directory in the Termux home:

```bash
mkdir -p ~/sdk-tools-aarch64/build-tools
```

Obtain an ARM64 Android SDK-tools archive from a trusted source that supplies ARM64 binaries, such as the `lzhiyong/android-sdk-tools` release used by the original setup. The archive was named:

```text
android-sdk-tools-static-aarch64.zip
```

Extract it so this exact executable exists:

```text
~/sdk-tools-aarch64/build-tools/aapt2
```

Then make it executable:

```bash
chmod +x ~/sdk-tools-aarch64/build-tools/aapt2
```

Do not substitute the x86 Linux `aapt2` binary. It will not run on the ARM64 Android phone.

Both Android projects require this property in `gradle.properties`:

```properties
android.aapt2FromMavenOverride=/data/data/com.termux/files/home/sdk-tools-aarch64/build-tools/aapt2
```

The path works inside Ubuntu because the Termux home is visible inside proot.

Verify the file from both layers:

```bash
ls -l ~/sdk-tools-aarch64/build-tools/aapt2
proot-distro login ubuntu -- ls -l /data/data/com.termux/files/home/sdk-tools-aarch64/build-tools/aapt2
```

## 7. Configure the Ubuntu build environment

Every build invocation must use these values:

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
```

For a diagnostic shell:

```bash
proot-distro login ubuntu -- bash -lc '
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
  export ANDROID_HOME=/opt/android-sdk
  export ANDROID_SDK_ROOT=/opt/android-sdk
  export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
  java -version
  node --version
  npm --version
  sdkmanager --version
  adb version
'
```

Each project should contain this generated local SDK pointer:

```text
android/local.properties
```

with:

```properties
sdk.dir=/opt/android-sdk
```

`local.properties` is machine-specific and should generally remain uncommitted.

## 8. Prepare an existing project checkout

The existing projects used here are:

```text
~/downloads/forge
~/downloads/aaforgehost
```

For a fresh checkout:

```bash
cd ~/downloads
# Clone or copy the project here using your normal source-control method.
```

For Forge, install JavaScript dependencies inside Ubuntu rather than native Termux:

```bash
proot-distro login ubuntu -- bash -lc '
  set -e
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
  export ANDROID_HOME=/opt/android-sdk
  export ANDROID_SDK_ROOT=/opt/android-sdk
  export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
  cd /data/data/com.termux/files/home/downloads/forge
  npm install
'
```

Forge already contains a generated Android project. For a new Capacitor project, bootstrap Android inside Ubuntu:

```bash
proot-distro login ubuntu -- bash -lc '
  set -e
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
  export ANDROID_HOME=/opt/android-sdk
  export ANDROID_SDK_ROOT=/opt/android-sdk
  export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
  cd /data/data/com.termux/files/home/downloads/your-project
  npm install
  npx cap add android
  npx cap sync android
  printf "sdk.dir=/opt/android-sdk\n" > android/local.properties
'
```

Do not run `npm install` in one environment and then assume native modules or generated tools are interchangeable with another environment. Use Ubuntu consistently for Capacitor bootstrap and Gradle builds.

## 9. Forge project configuration and debug APK

Forge is the phone application:

```text
Package: com.forge.live
Source:  ~/downloads/forge
Android: ~/downloads/forge/android
```

Important project facts:

- Android Gradle plugin in the later checkout: 8.9.2.
- Later checkout's Gradle wrapper: 8.11.1.
- Android SDK level: 34.
- Capacitor Android libraries are local project dependencies under `node_modules/@capacitor`.
- Canonical web source: `www/index.html`.
- It must equal:
  `android/app/src/main/assets/public/index.html`.
- `gradle.properties` includes AndroidX settings and the ARM64 AAPT2 override.

The repository includes the host-side build wrapper:

```text
~/downloads/build_forge.sh
```

Run the normal debug build from native Termux:

```bash
bash ~/downloads/build_forge.sh
```

The script:

1. Optionally bumps the version if called with `--bump`.
2. Runs `forge_check.sh` before building.
3. Synchronizes `www/` into Android assets.
4. Writes `forge-build.json` into both copies.
5. Enters Ubuntu proot.
6. Sets JDK 17 and `/opt/android-sdk`.
7. Writes `android/local.properties`.
8. Runs the Gradle debug task.
9. Copies the full-flavor APK to the host and shared Download directory.

Output files:

```text
~/downloads/Forge-debug-rebuilt.apk
/sdcard/Download/Forge-debug-rebuilt.apk
~/downloads/Forge-play-debug.apk
```

Install the debug APK:

```bash
adb devices
adb install -r ~/downloads/Forge-debug-rebuilt.apk
```

The original binary is intentionally preserved separately as:

```text
~/downloads/Forge-debug.apk
```

Do not overwrite or modify that file.

### Forge pre-build gate

Run it independently when debugging:

```bash
bash ~/downloads/forge_check.sh
```

The gate checks, among other things:

- JavaScript syntax using Node.
- Equality of `www/index.html` and Android asset HTML.
- `forge-build.json` parity.
- Template-literal/backtick safety in the embedded bridge.
- Expected raw `</script>` count.
- Version stamp parity.
- Documentation/tool-registry drift.

A build must not be considered valid if this gate fails.

## 10. AAForge project configuration and release APK

AAForge is the Android Auto application:

```text
Package: com.forge.aaforgehost
Source:  ~/downloads/aaforgehost
Android: ~/downloads/aaforgehost/android
```

Important project facts:

- Android Gradle plugin: 8.2.2.
- Gradle wrapper: 8.2.
- `minSdk`: 28.
- Android SDK level: 34.
- Release must be non-debuggable for Android Auto visibility.
- Android Auto discovery relies on the project manifest, `MediaBrowserService`, and automotive media metadata; these are project requirements rather than generic Termux requirements.

Build the release APK from native Termux:

```bash
bash ~/downloads/build_aaforge.sh
```

The script enters Ubuntu proot, sets JDK 17 and `/opt/android-sdk`, writes `local.properties`, and runs:

```text
./gradlew --no-daemon clean assembleRelease
```

Output files:

```text
~/downloads/AAForge-release.apk
/sdcard/Download/AAForge-release.apk
```

Install it with the flags that worked for Android Auto:

```bash
adb devices
adb install -r -t -g -i com.android.vending \
  ~/downloads/AAForge-release.apk
adb shell am force-stop com.google.android.projection.gearhead
adb shell am start -n com.forge.aaforgehost/.MainActivity
```

Then check on the phone:

1. Open AAForge.
2. Confirm its Android Auto visibility diagnostics.
3. Open Android Auto settings.
4. Go to **Customize launcher**.
5. Enable AAForge.

The `-i com.android.vending` installer identity was important on modern Android Auto. A plain sideload or debug APK may install successfully but remain hidden from Customize launcher.

## 11. Forge release APK and Play AAB

Forge has two release flavors:

| Flavor | Artifact | Intended distribution |
|---|---|---|
| `full` | `Forge-full-release.apk` | Website, F-Droid, or sideload; full permissions |
| `play` | `Forge-play-release.aab` | Google Play; restricted permissions |

The release script is:

```text
~/downloads/forge/release_forge.sh
```

Before running it:

```bash
cd ~/downloads/forge
git status --short
```

The source tree should be clean and committed so the embedded Git SHA identifies the actual source revision.

Set the version explicitly in:

```text
android/app/build.gradle
```

The release script does not automatically bump the version.

### Signing prerequisites

The existing Forge release build expects these files:

```text
android/.keystore/forge-upload.jks
android/keystore.properties
```

They are intentionally gitignored and must be supplied privately. Never place their contents in this guide, source control, logs, or a public archive.

A fork or new application must create its own release key and matching `keystore.properties`. For an existing Play application, preserve and back up the original upload key offline. Replacing it can prevent future updates.

Build both artifacts:

```bash
cd ~/downloads/forge
bash release_forge.sh
```

The script performs the following:

1. Refuses to continue if the keystore files are missing.
2. Reads `versionName` and `versionCode` from Gradle.
3. Stamps `forge-build.json` with version, version code, Git SHA, and build time.
4. Synchronizes the canonical web HTML into Android assets.
5. Enters Ubuntu proot.
6. Sets JDK 17 and `/opt/android-sdk`.
7. Runs:

```text
./gradlew --no-daemon clean assembleFullRelease bundlePlayRelease
```

8. Copies the results to:

```text
~/downloads/forge/release-out/Forge-full-release.apk
~/downloads/forge/release-out/Forge-play-release.aab
/sdcard/Download/Forge-full-release.apk
/sdcard/Download/Forge-play-release.aab
```

Upload only the Play AAB to Google Play Console. Distribute the full APK through the intended non-Play channel.

## 12. Version bumping

Forge's helper increments `versionCode` by 2 and advances the patch version:

```bash
python3 ~/downloads/forge_bump.py
```

or:

```bash
bash ~/downloads/build_forge.sh --bump
```

The bump affects every invocation. Do not use it casually while diagnosing a build. After a bump, update the documented version baselines in:

```text
~/downloads/forge/docs/api.md
~/downloads/forge/docs/tools.md
```

Then run the pre-build gate.

## 13. ADB installation and device testing

ADB runs in native Termux, not necessarily inside Ubuntu:

```bash
adb devices
```

For wireless debugging, enable **Developer options → Wireless debugging** and pair/connect as required by the phone. For USB, connect the device and authorize the debugging prompt.

Forge debug install:

```bash
adb install -r ~/downloads/Forge-debug-rebuilt.apk
```

AAForge release install:

```bash
adb install -r -t -g -i com.android.vending \
  ~/downloads/AAForge-release.apk
```

If AAForge reports `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, the installed APK was signed with a different key. The replacement procedure is:

```bash
adb uninstall com.forge.aaforgehost
adb install -r -t -g -i com.android.vending \
  ~/downloads/AAForge-release.apk
```

Uninstalling deletes AAForge application data, including imported AI settings and mini-apps. Re-share them afterward.

Forge's smoke harness is:

```bash
bash ~/downloads/forge_smoke.sh
```

It checks that the installed process starts, does not immediately crash, is foregrounded, and reports its build stamp. Manual checks are still required for camera, AI, mini-apps, and other device features.

## 14. Troubleshooting

### `sdkmanager` crashes with `PerfettoTrace`

You are using the native Termux JDK/toolchain. Use:

```bash
proot-distro login ubuntu
```

and run SDK commands there with JDK 17.

### Gradle cannot find the SDK

Check all three values:

```bash
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
cat android/local.properties
```

`local.properties` must contain:

```properties
sdk.dir=/opt/android-sdk
```

### Resource processing or AAPT2 failure on ARM64

Check:

```bash
ls -l ~/sdk-tools-aarch64/build-tools/aapt2
cat ~/downloads/forge/android/gradle.properties
cat ~/downloads/aaforgehost/android/gradle.properties
```

Both projects need:

```properties
android.aapt2FromMavenOverride=/data/data/com.termux/files/home/sdk-tools-aarch64/build-tools/aapt2
```

The binary must be ARM64 and executable.

### Gradle is killed or the phone runs out of memory

The known working setting was:

```properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
```

Close other applications, ensure sufficient free storage, and avoid running multiple Gradle daemons. The wrapper scripts use `--no-daemon` for the Android build.

### Forge gate reports HTML parity failure

The canonical file is:

```text
~/downloads/forge/www/index.html
```

Synchronize it:

```bash
cp ~/downloads/forge/www/index.html \
  ~/downloads/forge/android/app/src/main/assets/public/index.html
```

Then run:

```bash
bash ~/downloads/forge/forge_check.sh
```

Do not build while the two copies differ.

### AAForge installs but is not visible in Android Auto

Use a release APK, not a debug APK, and install with:

```bash
adb install -r -t -g -i com.android.vending \
  ~/downloads/AAForge-release.apk
```

Then force-stop Gearhead and check **Customize launcher on the phone**, not only the car head unit:

```bash
adb shell am force-stop com.google.android.projection.gearhead
```

The application also needs the AAForge manifest/media discovery implementation from the source project.

### APK/AAB signature inspection is unavailable

The original Termux environment had limitations with some crypto tools. Gradle's signed release task and the presence of the expected archive structure are useful local checks, but Play Console is authoritative for Play signer identity. For independent local cryptographic verification, use a complete Android build-tools installation on another Linux machine or install a compatible `apksigner`/OpenSSL environment.

## 15. Security and reproducibility rules

Never put any of these in this guide or a public repository:

- API keys.
- GitHub PATs or other access tokens.
- AI provider credentials.
- `keystore.properties` contents.
- Release keystore files.
- Private backup data.

Use placeholders in private deployment notes, for example:

```properties
storeFile=.keystore/your-upload-key.jks
storePassword=REPLACE privately
keyAlias=your-upload-alias
keyPassword=REPLACE privately
```

Do not print secrets in shell logs. Avoid committing `local.properties`, signing files, generated credentials, or copied environment files.

Preserve these project directories unless the owner explicitly authorizes deletion:

```text
~/downloads/forge
~/downloads/aaforgehost
~/downloads/forge/recovered
~/downloads/aaforgehost/recovered
```

The former recovery trees were historical APK/JADX/APKEditor reference material and have been removed; canonical project sources remain in Git.

## 16. Fast operational checklist

### One-time environment

```bash
pkg update -y
pkg upgrade -y
pkg install -y nodejs npm android-tools proot-distro unzip curl wget
proot-distro install ubuntu
```

Inside Ubuntu: install JDK 17, Node.js, command-line tools, SDK platform 34, build-tools 34.0.0, and platform-tools. Install the ARM64 AAPT2 binary in:

```text
~/sdk-tools-aarch64/build-tools/aapt2
```

### Forge debug APK

```bash
bash ~/downloads/build_forge.sh
adb install -r ~/downloads/Forge-debug-rebuilt.apk
```

### AAForge release APK

```bash
bash ~/downloads/build_aaforge.sh
adb install -r -t -g -i com.android.vending \
  ~/downloads/AAForge-release.apk
```

### Forge release APK and Play AAB

```bash
cd ~/downloads/forge
# Restore private signing files first.
bash release_forge.sh
```

Expected results:

```text
release-out/Forge-full-release.apk
release-out/Forge-play-release.aab
```

If all three workflows succeed, the Termux/Ubuntu build environment has been reproduced.
