#!/usr/bin/env python3
"""One-shot Forge project reconstruction helpers. Does not delete existing trees."""
from pathlib import Path
import re
import shutil
import os

ROOT = Path("/data/data/com.termux/files/home/downloads/forge")
LOG = ROOT / "recovered" / "setup_log.txt"


def log(msg: str) -> None:
    LOG.parent.mkdir(parents=True, exist_ok=True)
    with LOG.open("a") as f:
        f.write(msg + "\n")


def main() -> None:
    if LOG.exists():
        # append only — do not delete log file content by truncation without need
        log("--- run ---")
    else:
        log("--- start ---")

    aes = sorted(ROOT.glob("recovered/apkeditor-*/decoded"))
    if not aes:
        log("NO_APKEDITOR_DECODE")
        return
    ae = aes[-1]
    log(f"AE={ae}")

    app_res = ROOT / "android/app/src/main/res"
    app_res.mkdir(parents=True, exist_ok=True)
    src_res = ae / "resources/package_1/res"

    # layouts
    lay = app_res / "layout"
    lay.mkdir(exist_ok=True)
    skip_pref = (
        "abc_",
        "notification_",
        "select_dialog",
        "support_",
        "ime_",
        "custom_dialog",
        "m3_",
        "material_",
        "design_",
    )
    if (src_res / "layout").exists():
        for f in (src_res / "layout").iterdir():
            if f.name.startswith(skip_pref):
                continue
            shutil.copy2(f, lay / f.name)
            log(f"layout {f.name}")

    # xml
    xml = app_res / "xml"
    xml.mkdir(exist_ok=True)
    if (src_res / "xml").exists():
        for f in (src_res / "xml").iterdir():
            if f.is_file():
                shutil.copy2(f, xml / f.name)
                log(f"xml {f.name}")

    # icons / splash drawables & mipmaps
    for sub in src_res.iterdir() if src_res.exists() else []:
        if not sub.is_dir():
            continue
        if not (sub.name.startswith("drawable") or sub.name.startswith("mipmap")):
            continue
        for f in sub.rglob("*"):
            if not f.is_file():
                continue
            if not any(k in f.name for k in ("ic_launcher", "splash", "ic_", "forge")):
                continue
            rel = f.relative_to(src_res)
            dest = app_res / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            if not dest.exists():
                shutil.copy2(f, dest)
                log(f"res {rel}")

    # values
    values = app_res / "values"
    values.mkdir(exist_ok=True)
    app_name = "Forge"
    sfile = src_res / "values/strings.xml"
    if sfile.exists():
        m = re.search(
            r'<string name="app_name"[^>]*>(.*?)</string>',
            sfile.read_text(errors="ignore"),
        )
        if m:
            app_name = m.group(1)
    (values / "strings.xml").write_text(
        f"""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">{app_name}</string>
    <string name="title_activity_main">{app_name}</string>
    <string name="package_name">com.forge.live</string>
    <string name="custom_url_scheme">com.forge.live</string>
</resources>
"""
    )
    (values / "colors.xml").write_text(
        """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="colorPrimary">#111827</color>
    <color name="colorPrimaryDark">#000000</color>
    <color name="colorAccent">#3DDC84</color>
    <color name="ic_launcher_background">#0B1F33</color>
</resources>
"""
    )
    (values / "styles.xml").write_text(
        """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="AppTheme" parent="Theme.AppCompat.DayNight.NoActionBar">
        <item name="colorPrimary">@color/colorPrimary</item>
        <item name="colorPrimaryDark">@color/colorPrimaryDark</item>
        <item name="colorAccent">@color/colorAccent</item>
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:navigationBarColor">@android:color/black</item>
        <item name="android:windowBackground">@android:color/black</item>
    </style>
    <style name="AppTheme.NoActionBar" parent="AppTheme">
        <item name="windowActionBar">false</item>
        <item name="windowNoTitle">true</item>
    </style>
    <style name="AppTheme.NoActionBarLaunch" parent="Theme.SplashScreen">
        <item name="android:background">@drawable/splash</item>
        <item name="postSplashScreenTheme">@style/AppTheme</item>
    </style>
</resources>
"""
    )

    # splash fallback
    drawable = app_res / "drawable"
    drawable.mkdir(exist_ok=True)
    if not any(app_res.glob("drawable*/splash*")):
        copied = False
        for cand in app_res.rglob("ic_launcher.xml"):
            shutil.copy2(cand, drawable / "splash.xml")
            copied = True
            break
        if not copied:
            (drawable / "splash.xml").write_text(
                """<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#000000"/>
</shape>
"""
            )

    # manifest cleanup for AGP
    man = (ae / "AndroidManifest.xml").read_text()
    man2 = re.sub(r'\s+android:versionCode="[^"]*"', "", man)
    man2 = re.sub(r'\s+android:versionName="[^"]*"', "", man2)
    man2 = re.sub(r'\s+android:compileSdkVersion="[^"]*"', "", man2)
    man2 = re.sub(r'\s+android:compileSdkVersionCodename="[^"]*"', "", man2)
    man2 = re.sub(r'\s+platformBuildVersionCode="[^"]*"', "", man2)
    man2 = re.sub(r'\s+platformBuildVersionName="[^"]*"', "", man2)
    man2 = re.sub(r'\s+package="[^"]*"', "", man2, count=1)
    man2 = re.sub(r"\s*<uses-sdk[^/]*/>", "", man2)
    man2 = re.sub(r"\s*<uses-sdk[\s\S]*?</uses-sdk>", "", man2)
    man2 = man2.replace('android:debuggable="true"', "")
    # remove self permission noise if present — keep for parity
    out_man = ROOT / "android/app/src/main/AndroidManifest.xml"
    out_man.parent.mkdir(parents=True, exist_ok=True)
    out_man.write_text(man2)
    log(f"manifest bytes={out_man.stat().st_size}")

    # ensure java sources present
    java_src = sorted(ROOT.glob("recovered/jadx-src-*/sources/com/forge/live"))[-1]
    java_dst = ROOT / "android/app/src/main/java/com/forge/live"
    java_dst.mkdir(parents=True, exist_ok=True)
    for f in java_src.glob("*.java"):
        if f.name == "R.java":
            continue
        dest = java_dst / f.name
        shutil.copy2(f, dest)
        log(f"java {f.name}")

    # strip loaded-from comments only
    for f in java_dst.glob("*.java"):
        t = f.read_text()
        t2 = re.sub(r"/\* loaded from:.*?\*/\n", "", t)
        t2 = re.sub(r" // from class: [^\n]+", "", t2)
        if t2 != t:
            f.write_text(t2)

    res_count = sum(1 for p in app_res.rglob("*") if p.is_file())
    java_count = sum(1 for p in java_dst.glob("*.java"))
    log(f"DONE res_files={res_count} java={java_count}")


if __name__ == "__main__":
    main()
