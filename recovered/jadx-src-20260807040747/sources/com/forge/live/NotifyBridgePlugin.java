package com.forge.live;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.content.ContextCompat;
import androidx.core.view.accessibility.AccessibilityEventCompat;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import org.json.JSONObject;

@CapacitorPlugin(name = "NotifyBridge", permissions = {@Permission(alias = "notifications", strings = {"android.permission.POST_NOTIFICATIONS"})})
/* loaded from: classes4.dex */
public class NotifyBridgePlugin extends Plugin {
    public static final String ACTION_OPEN_FROM_NOTIFY = "com.forge.live.OPEN_FROM_NOTIFY";
    private static final int BASE_NOTIFY_ID = 52000;
    public static final String CHANNEL_ALERTS = "forge_alerts";
    public static final String CHANNEL_DEFAULT = "forge_default";
    public static final String CHANNEL_JOBS = "forge_jobs";
    public static final String EXTRA_NOTIFY_ID = "forge_notify_id";
    public static final String EXTRA_PAYLOAD = "forge_notify_payload";
    public static final String EXTRA_TAG = "forge_notify_tag";

    @Override // com.getcapacitor.Plugin
    public void load() {
        super.load();
        ensureChannels(getContext());
    }

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject o = new JSObject();
        o.put("available", true);
        o.put("permission", hasNotificationPermission());
        o.put("channels", true);
        o.put("tapOpen", true);
        call.resolve(o);
    }

    @PluginMethod
    public void requestPermission(PluginCall call) {
        if (Build.VERSION.SDK_INT < 33) {
            JSObject ret = new JSObject();
            ret.put("granted", true);
            ret.put("permission", true);
            call.resolve(ret);
            return;
        }
        if (hasNotificationPermission()) {
            JSObject ret2 = new JSObject();
            ret2.put("granted", true);
            ret2.put("permission", true);
            call.resolve(ret2);
            return;
        }
        requestPermissionForAlias("notifications", call, "notifyPermCallback");
    }

    @PermissionCallback
    private void notifyPermCallback(PluginCall call) {
        JSObject ret = new JSObject();
        boolean g = hasNotificationPermission();
        ret.put("granted", g);
        ret.put("permission", g);
        call.resolve(ret);
    }

    @PluginMethod
    public void ensureChannels(PluginCall call) {
        ensureChannels(getContext());
        JSObject o = new JSObject();
        o.put("ok", true);
        o.put("channels", (Object) defaultChannelList());
        call.resolve(o);
    }

    @PluginMethod
    public void listChannels(PluginCall call) {
        ensureChannels(getContext());
        JSObject o = new JSObject();
        o.put("channels", (Object) defaultChannelList());
        call.resolve(o);
    }

    @PluginMethod
    public void show(PluginCall call) {
        ensureChannels(getContext());
        if (Build.VERSION.SDK_INT >= 33 && !hasNotificationPermission()) {
            try {
                requestPermissionForAlias("notifications", call, "showAfterPerm");
                return;
            } catch (Exception e) {
            }
        }
        showInternal(call);
    }

    @PermissionCallback
    private void showAfterPerm(PluginCall call) {
        showInternal(call);
    }

    /* JADX WARN: Can't wrap try/catch for region: R(45:0|1|(1:142)|5|(1:141)(2:9|(1:140)(2:13|(1:139)(1:17)))|18|(4:24|25|(1:27)(1:(2:31|32))|28)|34|(3:36|(1:38)(1:137)|39)(1:138)|40|(6:(3:42|43|(37:45|(1:47)|(1:49)|50|(1:52)|54|55|56|(1:58)|59|60|(1:62)|63|(1:65)|66|(1:68)(1:127)|69|(1:71)(1:126)|72|(1:74)(1:124)|75|76|(2:120|121)|78|(1:82)|89|(3:107|108|(10:110|111|112|94|95|96|97|(1:99)|100|102))|91|92|93|94|95|96|97|(0)|100|102))|96|97|(0)|100|102)|135|136|(0)|(0)|50|(0)|54|55|56|(0)|59|60|(0)|63|(0)|66|(0)(0)|69|(0)(0)|72|(0)(0)|75|76|(0)|78|(2:80|82)|89|(0)|91|92|93|94|95|(1:(0))) */
    /* JADX WARN: Code restructure failed: missing block: B:105:0x0276, code lost:
    
        r0 = e;
     */
    /* JADX WARN: Code restructure failed: missing block: B:122:0x027a, code lost:
    
        r0 = e;
     */
    /* JADX WARN: Code restructure failed: missing block: B:128:0x0280, code lost:
    
        r0 = e;
     */
    /* JADX WARN: Code restructure failed: missing block: B:131:0x0288, code lost:
    
        r0 = e;
     */
    /* JADX WARN: Removed duplicated region for block: B:107:0x0224 A[EXC_TOP_SPLITTER, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:120:0x0201 A[EXC_TOP_SPLITTER, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:124:0x01cc  */
    /* JADX WARN: Removed duplicated region for block: B:126:0x01bb  */
    /* JADX WARN: Removed duplicated region for block: B:127:0x01b1  */
    /* JADX WARN: Removed duplicated region for block: B:47:0x016c A[Catch: Exception -> 0x0150, TRY_ENTER, TryCatch #1 {Exception -> 0x0150, blocks: (B:43:0x013a, B:45:0x0144, B:47:0x016c, B:49:0x0173, B:52:0x017f), top: B:42:0x013a }] */
    /* JADX WARN: Removed duplicated region for block: B:49:0x0173 A[Catch: Exception -> 0x0150, TRY_LEAVE, TryCatch #1 {Exception -> 0x0150, blocks: (B:43:0x013a, B:45:0x0144, B:47:0x016c, B:49:0x0173, B:52:0x017f), top: B:42:0x013a }] */
    /* JADX WARN: Removed duplicated region for block: B:52:0x017f A[Catch: Exception -> 0x0150, TRY_ENTER, TRY_LEAVE, TryCatch #1 {Exception -> 0x0150, blocks: (B:43:0x013a, B:45:0x0144, B:47:0x016c, B:49:0x0173, B:52:0x017f), top: B:42:0x013a }] */
    /* JADX WARN: Removed duplicated region for block: B:58:0x018e  */
    /* JADX WARN: Removed duplicated region for block: B:62:0x01a0  */
    /* JADX WARN: Removed duplicated region for block: B:65:0x01a7  */
    /* JADX WARN: Removed duplicated region for block: B:68:0x01af  */
    /* JADX WARN: Removed duplicated region for block: B:71:0x01b9  */
    /* JADX WARN: Removed duplicated region for block: B:74:0x01c8  */
    /* JADX WARN: Removed duplicated region for block: B:99:0x025d A[Catch: Exception -> 0x0274, TryCatch #8 {Exception -> 0x0274, blocks: (B:97:0x0253, B:99:0x025d, B:100:0x0262), top: B:96:0x0253 }] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    private void showInternal(PluginCall call) {
        String str;
        Intent launch;
        NotificationCompat.Builder b;
        String group;
        Context ctx = getContext();
        String title = call.getString("title", "Forge");
        String message = call.getString("message", call.getString("body", ""));
        String channelId = call.getString("channel", CHANNEL_DEFAULT);
        if (channelId == null || channelId.isEmpty()) {
            channelId = CHANNEL_DEFAULT;
        }
        String channelId2 = ("alerts".equalsIgnoreCase(channelId) || "high".equalsIgnoreCase(channelId)) ? CHANNEL_ALERTS : ("jobs".equalsIgnoreCase(channelId) || NotificationCompat.CATEGORY_REMINDER.equalsIgnoreCase(channelId)) ? CHANNEL_JOBS : ("default".equalsIgnoreCase(channelId) || "low".equalsIgnoreCase(channelId)) ? CHANNEL_DEFAULT : channelId;
        String appId = call.getString("appId", "");
        String appTitle = call.getString("appTitle", title);
        String tag = call.getString("tag", null);
        String payload = call.getString("payload", null);
        if (payload == null && call.getData() != null && call.getData().has("data")) {
            try {
                Object data = call.getData().get("data");
                if (data instanceof JSONObject) {
                    payload = data.toString();
                } else if (data != null) {
                    payload = String.valueOf(data);
                }
            } catch (Exception e) {
            }
        }
        int id = call.getInt("id", 0).intValue();
        if (id == 0) {
            str = "Forge";
            id = Math.abs((tag != null ? tag : appId + title + message).hashCode() % 100000) + BASE_NOTIFY_ID;
        } else {
            str = "Forge";
        }
        boolean ongoing = Boolean.TRUE.equals(call.getBoolean("ongoing", false));
        boolean silent = Boolean.TRUE.equals(call.getBoolean(NotificationCompat.GROUP_KEY_SILENT, false));
        boolean autoCancel = !Boolean.FALSE.equals(call.getBoolean("autoCancel", true));
        try {
            if (appId != null) {
                try {
                    if (!appId.trim().isEmpty()) {
                        launch = ShortcutBridgePlugin.buildRunIntent(ctx, appId.trim(), appTitle);
                        launch.setAction(ACTION_OPEN_FROM_NOTIFY);
                        if (payload != null) {
                            launch.putExtra(EXTRA_PAYLOAD, payload);
                        }
                        if (tag != null) {
                            launch.putExtra(EXTRA_TAG, tag);
                        }
                        launch.putExtra(EXTRA_NOTIFY_ID, id);
                        if (appId != null) {
                            launch.putExtra(ShortcutBridgePlugin.EXTRA_APP_ID, appId);
                        }
                        int piFlags = Build.VERSION.SDK_INT >= 23 ? 134217728 | AccessibilityEventCompat.TYPE_VIEW_TARGETED_BY_SCROLL : 134217728;
                        PendingIntent contentIntent = PendingIntent.getActivity(ctx, id, launch, piFlags);
                        int priority = CHANNEL_ALERTS.equals(channelId2) ? 1 : 0;
                        if (CHANNEL_DEFAULT.equals(channelId2)) {
                            priority = -1;
                        }
                        b = new NotificationCompat.Builder(ctx, channelId2).setContentTitle(title == null ? title : str).setContentText(message == null ? message : "").setStyle(new NotificationCompat.BigTextStyle().bigText(message == null ? message : "")).setSmallIcon(android.R.drawable.ic_dialog_info).setContentIntent(contentIntent).setAutoCancel(autoCancel).setOngoing(ongoing).setOnlyAlertOnce(true).setPriority(priority).setCategory(NotificationCompat.CATEGORY_MESSAGE).setVisibility(1);
                        if (silent) {
                            try {
                                b.setSilent(true);
                            } catch (Exception e2) {
                                e = e2;
                                call.reject("notify failed: " + e.getMessage(), e);
                                return;
                            }
                        }
                        group = call.getString("group", null);
                        if (group != null && !group.isEmpty()) {
                            b.setGroup(group);
                        }
                        NotificationManagerCompat nm = NotificationManagerCompat.from(ctx);
                        if (tag != null) {
                            try {
                                if (!tag.isEmpty()) {
                                    try {
                                        nm.notify(tag, id, b.build());
                                        JSObject ret = new JSObject();
                                        ret.put("ok", true);
                                        ret.put("id", id);
                                        if (tag != null) {
                                            ret.put("tag", tag);
                                        }
                                        ret.put("channel", channelId2);
                                        ret.put("permission", hasNotificationPermission());
                                        call.resolve(ret);
                                        return;
                                    } catch (Exception e3) {
                                        e = e3;
                                        call.reject("notify failed: " + e.getMessage(), e);
                                        return;
                                    }
                                }
                            } catch (Exception e4) {
                                e = e4;
                            }
                        }
                        nm.notify(id, b.build());
                        JSObject ret2 = new JSObject();
                        ret2.put("ok", true);
                        ret2.put("id", id);
                        if (tag != null) {
                        }
                        ret2.put("channel", channelId2);
                        ret2.put("permission", hasNotificationPermission());
                        call.resolve(ret2);
                        return;
                    }
                } catch (Exception e5) {
                    e = e5;
                    call.reject("notify failed: " + e.getMessage(), e);
                    return;
                }
            }
            ret2.put("ok", true);
            ret2.put("id", id);
            if (tag != null) {
            }
            ret2.put("channel", channelId2);
            ret2.put("permission", hasNotificationPermission());
            call.resolve(ret2);
            return;
        } catch (Exception e6) {
            e = e6;
            call.reject("notify failed: " + e.getMessage(), e);
            return;
        }
        launch = new Intent(ctx, (Class<?>) MainActivity.class);
        launch.setAction(ACTION_OPEN_FROM_NOTIFY);
        launch.addFlags(872415232);
        if (payload != null) {
        }
        if (tag != null) {
        }
        launch.putExtra(EXTRA_NOTIFY_ID, id);
        if (appId != null) {
        }
        if (Build.VERSION.SDK_INT >= 23) {
        }
        PendingIntent contentIntent2 = PendingIntent.getActivity(ctx, id, launch, piFlags);
        if (CHANNEL_ALERTS.equals(channelId2)) {
        }
        if (CHANNEL_DEFAULT.equals(channelId2)) {
        }
        b = new NotificationCompat.Builder(ctx, channelId2).setContentTitle(title == null ? title : str).setContentText(message == null ? message : "").setStyle(new NotificationCompat.BigTextStyle().bigText(message == null ? message : "")).setSmallIcon(android.R.drawable.ic_dialog_info).setContentIntent(contentIntent2).setAutoCancel(autoCancel).setOngoing(ongoing).setOnlyAlertOnce(true).setPriority(priority).setCategory(NotificationCompat.CATEGORY_MESSAGE).setVisibility(1);
        if (silent) {
        }
        group = call.getString("group", null);
        if (group != null) {
            b.setGroup(group);
        }
        NotificationManagerCompat nm2 = NotificationManagerCompat.from(ctx);
        if (tag != null) {
        }
        nm2.notify(id, b.build());
        JSObject ret22 = new JSObject();
    }

    @PluginMethod
    public void cancel(PluginCall call) {
        try {
            NotificationManagerCompat nm = NotificationManagerCompat.from(getContext());
            String tag = call.getString("tag", null);
            Integer idObj = call.getInt("id");
            if (idObj == null && (tag == null || tag.isEmpty())) {
                call.reject("id or tag required");
                return;
            }
            int id = idObj != null ? idObj.intValue() : 0;
            if (tag != null && !tag.isEmpty()) {
                nm.cancel(tag, id);
            } else {
                nm.cancel(id);
            }
            JSObject o = new JSObject();
            o.put("ok", true);
            call.resolve(o);
        } catch (Exception e) {
            call.reject("cancel failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void cancelAll(PluginCall call) {
        try {
            NotificationManagerCompat.from(getContext()).cancelAll();
            call.resolve(new JSObject().put("ok", true));
        } catch (Exception e) {
            call.reject("cancelAll failed: " + e.getMessage(), e);
        }
    }

    public static void showNotification(Context ctx, String appId, String appTitle, String title, String message, String channelId, String tag, String payloadJson, int id) {
        Intent launch;
        ensureChannels(ctx);
        if (channelId == null || channelId.isEmpty()) {
            channelId = CHANNEL_JOBS;
        }
        if (id == 0) {
            id = Math.abs((tag != null ? tag : appId + title).hashCode() % 100000) + BASE_NOTIFY_ID;
        }
        if (appId != null && !appId.trim().isEmpty()) {
            launch = ShortcutBridgePlugin.buildRunIntent(ctx, appId.trim(), appTitle != null ? appTitle : title);
            launch.setAction(ACTION_OPEN_FROM_NOTIFY);
        } else {
            launch = new Intent(ctx, (Class<?>) MainActivity.class);
            launch.setAction(ACTION_OPEN_FROM_NOTIFY);
            launch.addFlags(805306368);
        }
        if (payloadJson != null) {
            launch.putExtra(EXTRA_PAYLOAD, payloadJson);
        }
        if (tag != null) {
            launch.putExtra(EXTRA_TAG, tag);
        }
        launch.putExtra(EXTRA_NOTIFY_ID, id);
        if (appId != null) {
            launch.putExtra(ShortcutBridgePlugin.EXTRA_APP_ID, appId);
        }
        int piFlags = Build.VERSION.SDK_INT >= 23 ? 134217728 | AccessibilityEventCompat.TYPE_VIEW_TARGETED_BY_SCROLL : 134217728;
        PendingIntent contentIntent = PendingIntent.getActivity(ctx, id, launch, piFlags);
        NotificationCompat.Builder b = new NotificationCompat.Builder(ctx, channelId).setContentTitle(title != null ? title : "Forge").setContentText(message != null ? message : "").setStyle(new NotificationCompat.BigTextStyle().bigText(message != null ? message : "")).setSmallIcon(android.R.drawable.ic_popup_reminder).setContentIntent(contentIntent).setAutoCancel(true).setPriority(0).setCategory(NotificationCompat.CATEGORY_REMINDER);
        NotificationManagerCompat nm = NotificationManagerCompat.from(ctx);
        if (tag != null) {
            try {
                if (!tag.isEmpty()) {
                    nm.notify(tag, id, b.build());
                }
            } catch (SecurityException e) {
                return;
            }
        }
        nm.notify(id, b.build());
    }

    public static void ensureChannels(Context ctx) {
        NotificationManager nm;
        if (Build.VERSION.SDK_INT >= 26 && (nm = (NotificationManager) ctx.getSystemService("notification")) != null) {
            NotificationChannel def = new NotificationChannel(CHANNEL_DEFAULT, "Forge", 2);
            def.setDescription("General mini-app notifications");
            def.setShowBadge(true);
            nm.createNotificationChannel(def);
            NotificationChannel alerts = new NotificationChannel(CHANNEL_ALERTS, "Forge alerts", 4);
            alerts.setDescription("Important alerts from mini-apps");
            alerts.enableVibration(true);
            nm.createNotificationChannel(alerts);
            NotificationChannel jobs = new NotificationChannel(CHANNEL_JOBS, "Forge reminders", 3);
            jobs.setDescription("Scheduled jobs and reminders");
            nm.createNotificationChannel(jobs);
        }
    }

    private JSArray defaultChannelList() {
        JSArray arr = new JSArray();
        try {
            arr.put(new JSObject().put("id", CHANNEL_DEFAULT).put("name", "Forge").put("importance", "low"));
            arr.put(new JSObject().put("id", CHANNEL_ALERTS).put("name", "Forge alerts").put("importance", "high"));
            arr.put(new JSObject().put("id", CHANNEL_JOBS).put("name", "Forge reminders").put("importance", "default"));
        } catch (Exception e) {
        }
        return arr;
    }

    private boolean hasNotificationPermission() {
        return Build.VERSION.SDK_INT < 33 || ContextCompat.checkSelfPermission(getContext(), "android.permission.POST_NOTIFICATIONS") == 0;
    }
}
