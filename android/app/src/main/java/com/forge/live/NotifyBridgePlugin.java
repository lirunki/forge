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
        try {
            Context ctx = getContext();
            ensureChannels(ctx);
            String title = call.getString("title", "Forge");
            String message = call.getString("message", call.getString("body", ""));
            String channelId = call.getString("channel", CHANNEL_DEFAULT);
            if (channelId == null || channelId.isEmpty()) channelId = CHANNEL_DEFAULT;
            Integer idObj = call.getInt("id");
            int id = idObj != null ? idObj.intValue() : (int) (System.currentTimeMillis() % 100000);
            String tag = call.getString("tag", null);
            String appId = call.getString("appId", null);
            String payload = call.getString("payload", null);
            boolean autoCancel = call.getBoolean("autoCancel", true);
            boolean ongoing = call.getBoolean("ongoing", false);
            boolean silent = call.getBoolean("silent", false);
            String str = title != null ? title : "Forge";

            Intent launch = new Intent(ctx, MainActivity.class);
            launch.setAction(ACTION_OPEN_FROM_NOTIFY);
            launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            if (payload != null) launch.putExtra(EXTRA_PAYLOAD, payload);
            if (tag != null) launch.putExtra(EXTRA_TAG, tag);
            launch.putExtra(EXTRA_NOTIFY_ID, id);
            if (appId != null) launch.putExtra(ShortcutBridgePlugin.EXTRA_APP_ID, appId);

            int piFlags = Build.VERSION.SDK_INT >= 23
                    ? PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                    : PendingIntent.FLAG_UPDATE_CURRENT;
            PendingIntent contentIntent = PendingIntent.getActivity(ctx, id, launch, piFlags);

            int priority = CHANNEL_ALERTS.equals(channelId) ? NotificationCompat.PRIORITY_HIGH
                    : CHANNEL_DEFAULT.equals(channelId) ? NotificationCompat.PRIORITY_LOW
                    : NotificationCompat.PRIORITY_DEFAULT;

            NotificationCompat.Builder b = new NotificationCompat.Builder(ctx, channelId)
                    .setContentTitle(str)
                    .setContentText(message != null ? message : "")
                    .setStyle(new NotificationCompat.BigTextStyle().bigText(message != null ? message : ""))
                    .setSmallIcon(android.R.drawable.ic_dialog_info)
                    .setContentIntent(contentIntent)
                    .setAutoCancel(autoCancel)
                    .setOngoing(ongoing)
                    .setOnlyAlertOnce(true)
                    .setPriority(priority)
                    .setCategory(NotificationCompat.CATEGORY_MESSAGE)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC);
            if (silent) {
                try { b.setSilent(true); } catch (Exception ignored) {}
            }
            String group = call.getString("group", null);
            if (group != null && !group.isEmpty()) b.setGroup(group);

            NotificationManagerCompat nm = NotificationManagerCompat.from(ctx);
            if (tag != null && !tag.isEmpty()) nm.notify(tag, id, b.build());
            else nm.notify(id, b.build());

            JSObject ret = new JSObject();
            ret.put("ok", true);
            ret.put("id", id);
            if (tag != null) ret.put("tag", tag);
            ret.put("channel", channelId);
            ret.put("permission", hasNotificationPermission());
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("notify failed: " + e.getMessage(), e);
        }
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
