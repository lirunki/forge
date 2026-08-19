package com.forge.live;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.WebView;
import com.getcapacitor.BridgeActivity;
import com.getcapacitor.PluginHandle;

/* loaded from: classes4.dex */
public class MainActivity extends BridgeActivity {
    protected boolean isRunnerInstance() {
        return false;
    }

    @Override // com.getcapacitor.BridgeActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    public void onCreate(Bundle savedInstanceState) {
        registerPlugin(BackgroundForgePlugin.class);
        registerPlugin(PhoneBridgePlugin.class);
        registerPlugin(AppsBridgePlugin.class);
        registerPlugin(TtsBridgePlugin.class);
        registerPlugin(AudioRouteBridgePlugin.class);
        registerPlugin(MicBridgePlugin.class);
        registerPlugin(CameraBridgePlugin.class);
        registerPlugin(FilesBridgePlugin.class);
        registerPlugin(TermuxBridgePlugin.class);
        registerPlugin(ShortcutBridgePlugin.class);
        registerPlugin(NotifyBridgePlugin.class);
        registerPlugin(JobBridgePlugin.class);
        registerPlugin(QrBridgePlugin.class);
        registerPlugin(DriveBridgePlugin.class);
        registerPlugin(OpenHtmlBridgePlugin.class);
        super.onCreate(savedInstanceState);

        // Android 15 (targetSdk 35) enforces edge-to-edge: without this the
        // WebView draws behind the status bar / nav bar and mini-app UI overlaps
        // them. Capacitor wraps the WebView in a CoordinatorLayout which does NOT
        // forward insets to children unless fitsSystemWindows=true, so a listener
        // on the WebView alone never fires — listen on the DECOR view (root of
        // insets dispatch) and pad the WebView from there. Covers RunActivity too
        // (subclass). onResume() forces a re-dispatch via requestApplyInsets.
        try {
            final android.view.View decor = getWindow().getDecorView();
            androidx.core.view.ViewCompat.setOnApplyWindowInsetsListener(decor, (v, insets) -> {
                androidx.core.graphics.Insets bars = insets.getInsets(
                    androidx.core.view.WindowInsetsCompat.Type.systemBars()
                    | androidx.core.view.WindowInsetsCompat.Type.displayCutout());
                android.view.View wv = (getBridge() != null) ? getBridge().getWebView() : null;
                if (wv != null) {
                    wv.setPadding(bars.left, bars.top, bars.right, bars.bottom);
                    android.util.Log.d("ForgeInsets", "decor pass: top=" + bars.top + " bottom=" + bars.bottom + " left=" + bars.left + " right=" + bars.right);
                }
                return androidx.core.view.WindowInsetsCompat.CONSUMED;
            });
            android.view.View wv = (getBridge() != null) ? getBridge().getWebView() : null;
            if (wv != null) {
                androidx.core.view.ViewCompat.setOnApplyWindowInsetsListener(wv, (v, insets) -> {
                    androidx.core.graphics.Insets bars = insets.getInsets(
                        androidx.core.view.WindowInsetsCompat.Type.systemBars()
                        | androidx.core.view.WindowInsetsCompat.Type.displayCutout());
                    v.setPadding(bars.left, bars.top, bars.right, bars.bottom);
                    return androidx.core.view.WindowInsetsCompat.CONSUMED;
                });
                getWindow().setBackgroundDrawable(new android.graphics.drawable.ColorDrawable(0xFF09090F));
                // Dark strip → light (white) status/nav icons for contrast.
                androidx.core.view.WindowCompat.getInsetsController(getWindow(), wv)
                    .setAppearanceLightStatusBars(false);
                androidx.core.view.WindowCompat.getInsetsController(getWindow(), wv)
                    .setAppearanceLightNavigationBars(false);
            }
        } catch (Throwable t) {
            android.util.Log.w("ForgeInsets", "insets setup failed", t);
        }

        Intent intent = getIntent();
        try { OpenHtmlBridgePlugin.captureHtmlIntent(intent); } catch (Exception ignored) {}
        if (!isRunnerInstance() && forwardOpenAppToRunner(intent)) {
            return;
        }
        dispatchForgeIntent(intent);
    }

    @Override // com.getcapacitor.BridgeActivity, androidx.activity.ComponentActivity, android.app.Activity
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        try { OpenHtmlBridgePlugin.captureHtmlIntent(intent); } catch (Exception ignored) {}
        if (!isRunnerInstance() && forwardOpenAppToRunner(intent)) {
            return;
        }
        dispatchForgeIntent(intent);
    }

    private boolean forwardOpenAppToRunner(Intent intent) {
        String id;
        if (intent == null || (id = extractAppId(intent)) == null) {
            return false;
        }
        try {
            String title = intent.getStringExtra(ShortcutBridgePlugin.EXTRA_APP_TITLE);
            Intent run = ShortcutBridgePlugin.buildRunIntent(this, id, title);
            startActivity(run);
            try {
                intent.removeExtra(ShortcutBridgePlugin.EXTRA_APP_ID);
                intent.removeExtra(ShortcutBridgePlugin.EXTRA_APP_TITLE);
                intent.setData(null);
                if (ShortcutBridgePlugin.ACTION_OPEN_APP.equals(intent.getAction())) {
                    intent.setAction("android.intent.action.MAIN");
                    return true;
                }
                return true;
            } catch (Exception e) {
                return true;
            }
        } catch (Exception e2) {
            return false;
        }
    }

    static String extractAppId(Intent intent) {
        String id;
        if (intent == null) {
            return null;
        }
        String id2 = intent.getStringExtra(ShortcutBridgePlugin.EXTRA_APP_ID);
        if (id2 != null && !id2.trim().isEmpty()) {
            return id2.trim();
        }
        Uri data = intent.getData();
        if (data == null) {
            return null;
        }
        String host = data.getHost();
        String path = data.getPath();
        if ("app".equals(host) && path != null && path.length() > 1) {
            String id3 = path.startsWith("/") ? path.substring(1) : path;
            int slash = id3.indexOf(47);
            if (slash > 0) {
                id3 = id3.substring(0, slash);
            }
            if (id3.trim().isEmpty()) {
                return null;
            }
            return id3.trim();
        }
        if (data.getQueryParameter("id") == null || (id = data.getQueryParameter("id")) == null || id.trim().isEmpty()) {
            return null;
        }
        return id.trim();
    }

    private void dispatchForgeIntent(Intent intent) {
        PluginHandle handle;
        try {
            if (getBridge() != null && intent != null && (handle = getBridge().getPlugin("ShortcutBridge")) != null && (handle.getInstance() instanceof ShortcutBridgePlugin)) {
                ((ShortcutBridgePlugin) handle.getInstance()).captureLaunchIntent(intent);
            }
        } catch (Exception e) {
        }
        try {
            if (getBridge() != null && (handle = getBridge().getPlugin("OpenHtmlBridge")) != null
                    && (handle.getInstance() instanceof OpenHtmlBridgePlugin)) {
                ((OpenHtmlBridgePlugin) handle.getInstance()).notifyPendingIfAny();
            }
        } catch (Exception e) {
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        // Force a window-insets pass (covers any dispatch that happened before our
        // decor listener was registered, and OEM edge cases after re-layout).
        try {
            androidx.core.view.ViewCompat.requestApplyInsets(getWindow().getDecorView());
        } catch (Throwable ignored) {}
    }

    @Override // com.getcapacitor.BridgeActivity, androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onPause() {
        super.onPause();
        keepWebViewAlive();
    }

    @Override // com.getcapacitor.BridgeActivity, androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onStop() {
        super.onStop();
        keepWebViewAlive();
    }

    @Override // android.app.Activity, android.view.Window.Callback
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (!hasFocus) {
            keepWebViewAlive();
        }
    }

    private void keepWebViewAlive() {
        WebView webView;
        try {
            if (getBridge() == null || (webView = getBridge().getWebView()) == null) {
                return;
            }
            webView.resumeTimers();
            webView.onResume();
        } catch (Exception e) {
        }
    }
}
