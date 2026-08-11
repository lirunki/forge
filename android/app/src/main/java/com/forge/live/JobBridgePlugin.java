package com.forge.live;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;

import androidx.core.app.NotificationCompat;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Scheduled jobs / alarms for Forge mini-apps (restored from v2.6.1 behavior).
 */
@CapacitorPlugin(name = "JobBridge")
public class JobBridgePlugin extends Plugin {
    public static final String EXTRA_JOB_ID = "forge_job_id";
    private static final String PENDING_PREFS = "forge_jobs_pending_v1";
    private static final String PREFS = "forge_jobs_v1";

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject o = new JSObject();
        o.put("available", true);
        o.put("exact", canScheduleExact(getContext()));
        o.put("minIntervalMs", 60000);
        call.resolve(o);
    }

    @PluginMethod
    public void schedule(PluginCall call) {
        try {
            Context ctx = getContext();
            String id = call.getString("id");
            if (id == null || id.trim().isEmpty()) {
                id = "job_" + UUID.randomUUID().toString().replace("-", "").substring(0, 12);
            }
            id = sanitize(id);

            String appId = call.getString("appId", "");
            if (appId == null) appId = "";
            appId = appId.trim();
            String appTitle = call.getString("appTitle", "Forge app");
            String title = call.getString("title", "Forge");
            String text = call.getString("text", call.getString("message", "Reminder"));
            String channel = call.getString("channel", NotifyBridgePlugin.CHANNEL_JOBS);
            String payload = call.getString("payload", null);
            boolean notify = !Boolean.FALSE.equals(call.getBoolean("notify", true));
            String type = call.getString("type", "once");
            if (type == null || type.isEmpty()) type = "once";

            long atMs = 0L;
            Double at = call.getDouble("atMs");
            if (at != null) atMs = at.longValue();
            if (atMs <= 0) {
                Double inMs = call.getDouble("inMs");
                if (inMs != null && inMs.longValue() > 0) {
                    atMs = System.currentTimeMillis() + inMs.longValue();
                }
            }
            if (atMs <= 0) {
                call.reject("atMs or inMs required");
                return;
            }

            long intervalMs = 0L;
            Double interval = call.getDouble("intervalMs");
            if (interval != null) intervalMs = interval.longValue();
            if ("interval".equals(type) && intervalMs < 60_000L) {
                call.reject("intervalMs must be >= 60000");
                return;
            }

            JSONObject job = new JSONObject();
            job.put("id", id);
            job.put("appId", appId);
            job.put("appTitle", appTitle != null ? appTitle : "Forge app");
            job.put("title", title != null ? title : "Forge");
            job.put("text", text != null ? text : "Reminder");
            job.put("channel", channel != null ? channel : NotifyBridgePlugin.CHANNEL_JOBS);
            job.put("atMs", atMs);
            job.put("type", type);
            job.put("intervalMs", intervalMs);
            job.put("notify", notify);
            if (payload != null) job.put("payload", payload);
            job.put("createdAt", System.currentTimeMillis());

            ctx.getSharedPreferences(PREFS, 0).edit().putString(id, job.toString()).apply();
            scheduleAlarm(ctx, id, atMs);

            JSObject ret = new JSObject();
            ret.put("ok", true);
            ret.put("id", id);
            ret.put("atMs", atMs);
            ret.put("type", type);
            ret.put("intervalMs", intervalMs);
            ret.put("exact", canScheduleExact(ctx));
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("schedule failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void cancel(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.trim().isEmpty()) {
            call.reject("id required");
            return;
        }
        String id2 = sanitize(id);
        cancelAlarm(getContext(), id2);
        getContext().getSharedPreferences(PREFS, 0).edit().remove(id2).apply();
        JSObject o = new JSObject();
        o.put("ok", true);
        o.put("id", id2);
        call.resolve(o);
    }

    @PluginMethod
    public void cancelAll(PluginCall call) {
        try {
            Context ctx = getContext();
            SharedPreferences prefs = ctx.getSharedPreferences(PREFS, 0);
            String appId = call.getString("appId", null);
            List<String> removed = new ArrayList<>();
            for (Map.Entry<String, ?> e : prefs.getAll().entrySet()) {
                try {
                    JSONObject job = new JSONObject(String.valueOf(e.getValue()));
                    if (appId == null || appId.isEmpty() || appId.equals(job.optString("appId"))) {
                        cancelAlarm(ctx, e.getKey());
                        removed.add(e.getKey());
                    }
                } catch (Exception ignored) {
                }
            }
            SharedPreferences.Editor ed = prefs.edit();
            for (String k : removed) ed.remove(k);
            ed.apply();
            JSObject o = new JSObject();
            o.put("ok", true);
            o.put("removed", removed.size());
            call.resolve(o);
        } catch (Exception e) {
            call.reject("cancelAll failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void list(PluginCall call) {
        try {
            SharedPreferences prefs = getContext().getSharedPreferences(PREFS, 0);
            String appId = call.getString("appId", null);
            JSArray arr = new JSArray();
            for (Map.Entry<String, ?> e : prefs.getAll().entrySet()) {
                try {
                    JSONObject job = new JSONObject(String.valueOf(e.getValue()));
                    if (appId != null && !appId.isEmpty() && !appId.equals(job.optString("appId"))) {
                        continue;
                    }
                    JSObject o = new JSObject();
                    o.put("id", job.optString("id", e.getKey()));
                    o.put("appId", job.optString("appId"));
                    o.put("title", job.optString("title"));
                    o.put("text", job.optString("text"));
                    o.put("atMs", job.optLong("atMs"));
                    o.put("type", job.optString("type", "once"));
                    o.put("intervalMs", job.optLong("intervalMs"));
                    o.put("notify", job.optBoolean("notify", true));
                    o.put("payload", job.optString("payload", null));
                    arr.put(o);
                } catch (Exception ignored) {
                }
            }
            JSObject ret = new JSObject();
            ret.put("jobs", arr);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("list failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void listPending(PluginCall call) {
        try {
            SharedPreferences pending = getContext().getSharedPreferences(PENDING_PREFS, 0);
            String appId = call.getString("appId", "");
            if (appId == null) appId = "";
            boolean consume = !Boolean.FALSE.equals(call.getBoolean("consume", true));
            JSArray arr = new JSArray();
            SharedPreferences.Editor ed = pending.edit();
            for (Map.Entry<String, ?> e : pending.getAll().entrySet()) {
                String key = e.getKey();
                if (appId != null && !appId.isEmpty() && !key.startsWith(appId + "::")) {
                    continue;
                }
                try {
                    JSONObject p = new JSONObject(String.valueOf(e.getValue()));
                    JSObject o = new JSObject();
                    o.put("jobId", p.optString("jobId"));
                    o.put("appId", p.optString("appId"));
                    o.put("payload", p.optString("payload"));
                    o.put("title", p.optString("title"));
                    o.put("text", p.optString("text"));
                    o.put("firedAt", p.optLong("firedAt"));
                    arr.put(o);
                    if (consume) ed.remove(key);
                } catch (Exception ignored) {
                }
            }
            if (consume) ed.apply();
            JSObject ret = new JSObject();
            ret.put("pending", arr);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("listPending failed: " + e.getMessage(), e);
        }
    }

    public static void scheduleAlarm(Context ctx, String jobId, long atMs) {
        AlarmManager am = (AlarmManager) ctx.getSystemService(Context.ALARM_SERVICE);
        if (am == null) return;
        PendingIntent pi = jobPendingIntent(ctx, jobId);
        try {
            if (Build.VERSION.SDK_INT >= 23) {
                if (canScheduleExact(ctx)) {
                    am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMs, pi);
                } else {
                    am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMs, pi);
                }
            } else {
                am.setExact(AlarmManager.RTC_WAKEUP, atMs, pi);
            }
        } catch (SecurityException e) {
            try {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMs, pi);
            } catch (Exception e2) {
                try {
                    am.set(AlarmManager.RTC_WAKEUP, atMs, pi);
                } catch (Exception ignored) {
                }
            }
        } catch (Exception e) {
            try {
                am.set(AlarmManager.RTC_WAKEUP, atMs, pi);
            } catch (Exception ignored) {
            }
        }
    }

    public static void cancelAlarm(Context ctx, String jobId) {
        AlarmManager am = (AlarmManager) ctx.getSystemService(Context.ALARM_SERVICE);
        if (am == null) return;
        try {
            am.cancel(jobPendingIntent(ctx, jobId));
        } catch (Exception ignored) {
        }
    }

    public static void rescheduleAll(Context ctx) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS, 0);
        long now = System.currentTimeMillis();
        for (Map.Entry<String, ?> e : prefs.getAll().entrySet()) {
            try {
                JSONObject job = new JSONObject(String.valueOf(e.getValue()));
                long at = job.optLong("atMs", 0L);
                String type = job.optString("type", "once");
                if (at <= now) {
                    if ("interval".equals(type)) {
                        long interval = job.optLong("intervalMs", 0L);
                        if (interval >= 60_000L) {
                            at = now + interval;
                            job.put("atMs", at);
                            prefs.edit().putString(e.getKey(), job.toString()).apply();
                        } else {
                            continue;
                        }
                    } else {
                        at = now + 5000L;
                    }
                }
                scheduleAlarm(ctx, e.getKey(), at);
            } catch (Exception ignored) {
            }
        }
    }

    private static PendingIntent jobPendingIntent(Context ctx, String jobId) {
        Intent i = new Intent(ctx, ForgeJobReceiver.class);
        i.setAction(ForgeJobReceiver.ACTION_JOB);
        i.putExtra(EXTRA_JOB_ID, jobId);
        i.putExtra("jobId", jobId);
        int flags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= 23) {
            flags |= PendingIntent.FLAG_IMMUTABLE;
        }
        int req = Math.abs(jobId.hashCode());
        return PendingIntent.getBroadcast(ctx, req, i, flags);
    }

    private static boolean canScheduleExact(Context ctx) {
        if (Build.VERSION.SDK_INT < 31) return true;
        AlarmManager am = (AlarmManager) ctx.getSystemService(Context.ALARM_SERVICE);
        return am != null && am.canScheduleExactAlarms();
    }

    private static String sanitize(String id) {
        return id.trim().replaceAll("[^a-zA-Z0-9._-]", "_");
    }
}
