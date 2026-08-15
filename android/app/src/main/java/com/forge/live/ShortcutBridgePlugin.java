package com.forge.live;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ShortcutInfo;
import android.content.pm.ShortcutManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.Icon;
import android.net.Uri;
import android.os.Build;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.Collections;

@CapacitorPlugin(name = "ShortcutBridge")
public class ShortcutBridgePlugin extends Plugin {
    public static final String ACTION_OPEN_APP = "com.forge.live.OPEN_APP";
    public static final String EXTRA_APP_ID = "forge_app_id";
    public static final String EXTRA_APP_TITLE = "forge_app_title";
    private String pendingAppId = null;
    private String pendingAppTitle = null;
    private String pendingPayload = null;
    private String pendingNotifyTag = null;
    private Integer pendingNotifyId = null;
    private String pendingLaunchSource = null;

    public static Intent buildRunIntent(Context context, String id, String title) {
        if (id == null) {
            id = "";
        }
        String id2 = id.trim();
        if (title == null || title.trim().isEmpty()) {
            title = "Forge app";
        }
        String title2 = title.trim();
        Intent launch = new Intent(context, (Class<?>) RunActivity.class);
        launch.setAction(ACTION_OPEN_APP);
        launch.setData(Uri.parse("forge://app/" + Uri.encode(id2)));
        launch.putExtra(EXTRA_APP_ID, id2);
        launch.putExtra(EXTRA_APP_TITLE, title2);
        launch.addFlags(403177472);
        return launch;
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnNewIntent(Intent intent) {
        super.handleOnNewIntent(intent);
        captureLaunchIntent(intent);
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnStart() {
        super.handleOnStart();
        if (getActivity() != null) {
            captureLaunchIntent(getActivity().getIntent());
        }
    }

    public void captureLaunchIntent(Intent intent) {
        String q;
        if (intent == null) {
            return;
        }
        String id = MainActivity.extractAppId(intent);
        String payload = null;
        try {
            payload = intent.getStringExtra(NotifyBridgePlugin.EXTRA_PAYLOAD);
        } catch (Exception e) {
        }
        String notifyTag = null;
        try {
            notifyTag = intent.getStringExtra(NotifyBridgePlugin.EXTRA_TAG);
        } catch (Exception e2) {
        }
        Integer notifyId = null;
        boolean fromNotify = false;
        try {
            if (intent.hasExtra(NotifyBridgePlugin.EXTRA_NOTIFY_ID)) {
                notifyId = Integer.valueOf(intent.getIntExtra(NotifyBridgePlugin.EXTRA_NOTIFY_ID, 0));
            }
        } catch (Exception e3) {
        }
        String action = intent.getAction();
        if (NotifyBridgePlugin.ACTION_OPEN_FROM_NOTIFY.equals(action) || (payload != null && !payload.isEmpty())) {
            fromNotify = true;
        }
        if (id == null || id.isEmpty()) {
            if (!fromNotify) {
                return;
            } else {
                id = "";
            }
        }
        this.pendingAppId = id;
        String stringExtra = intent.getStringExtra(EXTRA_APP_TITLE);
        this.pendingAppTitle = stringExtra;
        if ((stringExtra == null || stringExtra.trim().isEmpty()) && intent.getData() != null && (q = intent.getData().getQueryParameter("title")) != null && !q.trim().isEmpty()) {
            this.pendingAppTitle = q.trim();
        }
        this.pendingPayload = payload;
        this.pendingNotifyTag = notifyTag;
        this.pendingNotifyId = notifyId;
        if (fromNotify) {
            this.pendingLaunchSource = "notify";
        } else if (ACTION_OPEN_APP.equals(action)) {
            this.pendingLaunchSource = "shortcut";
        } else {
            this.pendingLaunchSource = "link";
        }
        JSObject data = new JSObject();
        data.put("id", this.pendingAppId);
        String str = this.pendingAppTitle;
        if (str != null) {
            data.put("title", str);
        }
        String str2 = this.pendingPayload;
        if (str2 != null) {
            data.put("payload", str2);
        }
        String str3 = this.pendingNotifyTag;
        if (str3 != null) {
            data.put("tag", str3);
        }
        Integer num = this.pendingNotifyId;
        if (num != null) {
            data.put("notifyId", (Object) num);
        }
        data.put("source", this.pendingLaunchSource);
        notifyListeners("appLaunch", data, true);
        // Consume launch markers on the Activity intent. Extras alone are not enough:
        // extractAppId() also reads forge://app/<id> (and ?id=). If data stays set,
        // every onStart (e.g. return from CameraX) re-captures and the host reloads
        // the mini-app — dropping in-flight takePhoto / attachments.
        try {
            intent.removeExtra(EXTRA_APP_ID);
            intent.removeExtra(EXTRA_APP_TITLE);
            intent.removeExtra(NotifyBridgePlugin.EXTRA_PAYLOAD);
            intent.removeExtra(NotifyBridgePlugin.EXTRA_TAG);
            intent.removeExtra(NotifyBridgePlugin.EXTRA_NOTIFY_ID);
            try {
                Uri dataUri = intent.getData();
                if (dataUri != null) {
                    String host = dataUri.getHost();
                    boolean forgeApp = "app".equals(host)
                            || (dataUri.getQueryParameter("id") != null
                                && !dataUri.getQueryParameter("id").trim().isEmpty());
                    if (forgeApp || ACTION_OPEN_APP.equals(intent.getAction())) {
                        intent.setData(null);
                    }
                } else if (ACTION_OPEN_APP.equals(intent.getAction())) {
                    // no-op data; still normalize action below
                }
            } catch (Exception ignored) {
            }
            if (ACTION_OPEN_APP.equals(intent.getAction())
                    || NotifyBridgePlugin.ACTION_OPEN_FROM_NOTIFY.equals(intent.getAction())) {
                intent.setAction(Intent.ACTION_MAIN);
            }
        } catch (Exception e4) {
        }
    }

    @PluginMethod
    public void isSupported(PluginCall call) {
        JSObject o = new JSObject();
        boolean supported = true;
        if (Build.VERSION.SDK_INT >= 26) {
            ShortcutManager sm = (ShortcutManager) getContext().getSystemService(ShortcutManager.class);
            supported = sm != null && sm.isRequestPinShortcutSupported();
        }
        o.put("supported", supported);
        o.put("api", Build.VERSION.SDK_INT);
        call.resolve(o);
    }

    @PluginMethod
    public void getPendingLaunch(PluginCall call) {
        JSObject o = new JSObject();
        String str = this.pendingAppId;
        if (str != null || this.pendingPayload != null) {
            if (str != null) {
                o.put("id", str);
            }
            String str2 = this.pendingAppTitle;
            if (str2 != null) {
                o.put("title", str2);
            }
            String str3 = this.pendingPayload;
            if (str3 != null) {
                o.put("payload", str3);
            }
            String str4 = this.pendingNotifyTag;
            if (str4 != null) {
                o.put("tag", str4);
            }
            Integer num = this.pendingNotifyId;
            if (num != null) {
                o.put("notifyId", num.intValue());
            }
            String str5 = this.pendingLaunchSource;
            if (str5 != null) {
                o.put("source", str5);
            }
            o.put("pending", true);
            this.pendingAppId = null;
            this.pendingAppTitle = null;
            this.pendingPayload = null;
            this.pendingNotifyTag = null;
            this.pendingNotifyId = null;
            this.pendingLaunchSource = null;
        } else {
            o.put("pending", false);
        }
        call.resolve(o);
    }

    @PluginMethod
    public void openRunner(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.trim().isEmpty()) {
            call.reject("id required");
            return;
        }
        String id2 = id.trim();
        String title = call.getString("title", "Forge app");
        if (title == null || title.trim().isEmpty()) {
            title = "Forge app";
        }
        try {
            Intent launch = buildRunIntent(getContext(), id2, title.trim());
            if (getActivity() != null) {
                getActivity().startActivity(launch);
            } else {
                getContext().startActivity(launch);
            }
            JSObject o = new JSObject();
            o.put("launched", true);
            o.put("id", id2);
            call.resolve(o);
        } catch (Exception e) {
            call.reject("openRunner failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void pinApp(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.trim().isEmpty()) {
            call.reject("id required");
            return;
        }
        String id2 = id.trim();
        String title = call.getString("title", "Forge app");
        if (title == null || title.trim().isEmpty()) {
            title = "Forge app";
        }
        String title2 = title.trim();
        String shortLabel = call.getString("shortLabel", title2);
        if (shortLabel == null || shortLabel.trim().isEmpty()) {
            shortLabel = title2;
        }
        String shortLabel2 = shortLabel.trim();
        if (shortLabel2.length() > 20) {
            shortLabel2 = shortLabel2.substring(0, 20);
        }
        String shortLabel3 = shortLabel2;
        String longLabel = call.getString("longLabel", title2);
        if (longLabel == null || longLabel.trim().isEmpty()) {
            longLabel = title2;
        }
        String longLabel2 = longLabel;
        Intent launch = buildRunIntent(getContext(), id2, title2);
        String iconEmoji = call.getString("iconEmoji", call.getString("emoji", null));
        String iconColor = call.getString("iconColor", call.getString("color", null));
        try {
            try {
                if (Build.VERSION.SDK_INT >= 26) {
                    ShortcutManager sm = (ShortcutManager) getContext().getSystemService(ShortcutManager.class);
                    if (sm != null && sm.isRequestPinShortcutSupported()) {
                        String shortcutId = "forge_app_" + sanitizeId(id2);
                        Icon icon = Icon.createWithResource(getContext(), R.mipmap.ic_launcher);
                        try {
                            Bitmap bmp = renderAppIconBitmap(iconEmoji, iconColor);
                            if (bmp != null) {
                                icon = Icon.createWithBitmap(bmp);
                            }
                        } catch (Exception e) {
                        }
                        try {
                            ShortcutInfo.Builder builder = new ShortcutInfo.Builder(getContext(), shortcutId).setShortLabel(shortLabel3).setLongLabel(longLabel2.length() > 50 ? longLabel2.substring(0, 50) : longLabel2).setIcon(icon).setIntent(launch);
                            boolean ok = sm.requestPinShortcut(builder.build(), null);
                            JSObject o = new JSObject();
                            o.put("requested", ok);
                            o.put("id", id2);
                            o.put("shortcutId", shortcutId);
                            o.put("mode", "pin");
                            o.put("runner", true);
                            call.resolve(o);
                            return;
                        } catch (Exception e2) {                            call.reject("pin failed: " + e2.getMessage(), e2);
                            return;
                        }
                    }
                    call.reject("Launcher does not support pinned shortcuts");
                    return;
                }
                Intent add = new Intent("com.android.launcher.action.INSTALL_SHORTCUT");
                add.putExtra("android.intent.extra.shortcut.INTENT", launch);
                add.putExtra("android.intent.extra.shortcut.NAME", shortLabel3);
                add.putExtra("android.intent.extra.shortcut.ICON_RESOURCE", Intent.ShortcutIconResource.fromContext(getContext(), R.mipmap.ic_launcher));
                add.putExtra("duplicate", false);
                getContext().sendBroadcast(add);
                JSObject o2 = new JSObject();
                o2.put("requested", true);
                o2.put("id", id2);
                o2.put("mode", "legacy");
                o2.put("runner", true);
                call.resolve(o2);
            } catch (Exception e3) {            }
        } catch (Exception e4) {        }
    }

    @PluginMethod
    public void updatePinned(PluginCall call) {
        if (Build.VERSION.SDK_INT < 25) {
            call.resolve(new JSObject().put("updated", false));
            return;
        }
        String id = call.getString("id");
        if (id == null || id.trim().isEmpty()) {
            call.reject("id required");
            return;
        }
        String id2 = id.trim();
        String title = call.getString("title", "Forge app");
        if (title == null || title.trim().isEmpty()) {
            title = "Forge app";
        }
        try {
            ShortcutManager sm = (ShortcutManager) getContext().getSystemService(ShortcutManager.class);
            if (sm == null) {
                call.resolve(new JSObject().put("updated", false));
                return;
            }
            String shortcutId = "forge_app_" + sanitizeId(id2);
            Intent launch = buildRunIntent(getContext(), id2, title);
            String shortLabel = title.length() > 20 ? title.substring(0, 20) : title;
            ShortcutInfo info = new ShortcutInfo.Builder(getContext(), shortcutId).setShortLabel(shortLabel).setLongLabel(title.length() > 50 ? title.substring(0, 50) : title).setIcon(Icon.createWithResource(getContext(), R.mipmap.ic_launcher)).setIntent(launch).build();
            sm.updateShortcuts(Collections.singletonList(info));
            call.resolve(new JSObject().put("updated", true).put("shortcutId", shortcutId).put("runner", true));
        } catch (Exception e) {
            call.reject("update failed: " + e.getMessage(), e);
        }
    }

    private static String sanitizeId(String id) {
        return id.replaceAll("[^a-zA-Z0-9._-]", "_");
    }

    static Bitmap renderAppIconBitmap(String emoji, String colorHex) {
        Bitmap bmp = Bitmap.createBitmap(192, 192, Bitmap.Config.ARGB_8888);
        Canvas c = new Canvas(bmp);
        int bg = Color.parseColor("#6D28D9");
        if (colorHex != null) {
            try {
                if (colorHex.trim().startsWith("#") && colorHex.trim().length() >= 4) {
                    bg = Color.parseColor(colorHex.trim());
                }
            } catch (Exception e) {
            }
        }
        Paint p = new Paint(1);
        p.setColor(bg);
        c.drawCircle(192 / 2.0f, 192 / 2.0f, 192 / 2.0f, p);
        String em = emoji != null ? emoji.trim() : "";
        if (em.isEmpty()) {
            em = "⚡";
        }
        if (em.length() > 8) {
            em = em.substring(0, 8);
        }
        p.setColor(-1);
        p.setTextAlign(Paint.Align.CENTER);
        p.setTypeface(Typeface.DEFAULT);
        float textSize = 192 * 0.48f;
        p.setTextSize(textSize);
        Rect bounds = new Rect();
        p.getTextBounds(em, 0, em.length(), bounds);
        float x = 192 / 2.0f;
        float y = (192 / 2.0f) - bounds.exactCenterY();
        c.drawText(em, x, y, p);
        return bmp;
    }
}
