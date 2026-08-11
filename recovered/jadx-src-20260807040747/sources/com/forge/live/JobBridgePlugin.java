package com.forge.live;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.view.accessibility.AccessibilityEventCompat;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.json.JSONObject;

@CapacitorPlugin(name = "JobBridge")
/* loaded from: classes4.dex */
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

    /* JADX WARN: Removed duplicated region for block: B:113:0x00f6  */
    /* JADX WARN: Removed duplicated region for block: B:12:0x0084  */
    /* JADX WARN: Removed duplicated region for block: B:27:0x00ca A[Catch: Exception -> 0x02a7, TryCatch #2 {Exception -> 0x02a7, blocks: (B:3:0x0024, B:6:0x0034, B:10:0x007a, B:13:0x0085, B:15:0x0098, B:17:0x00a0, B:20:0x00ac, B:22:0x00b4, B:24:0x00bc, B:27:0x00ca, B:29:0x00d2, B:31:0x00da, B:34:0x00fc, B:37:0x0102, B:40:0x0117, B:43:0x011f, B:45:0x012d, B:46:0x0133, B:50:0x0148, B:52:0x014e, B:55:0x0189, B:76:0x02a3, B:114:0x0048), top: B:2:0x0024 }] */
    /* JADX WARN: Removed duplicated region for block: B:34:0x00fc A[Catch: Exception -> 0x02a7, TryCatch #2 {Exception -> 0x02a7, blocks: (B:3:0x0024, B:6:0x0034, B:10:0x007a, B:13:0x0085, B:15:0x0098, B:17:0x00a0, B:20:0x00ac, B:22:0x00b4, B:24:0x00bc, B:27:0x00ca, B:29:0x00d2, B:31:0x00da, B:34:0x00fc, B:37:0x0102, B:40:0x0117, B:43:0x011f, B:45:0x012d, B:46:0x0133, B:50:0x0148, B:52:0x014e, B:55:0x0189, B:76:0x02a3, B:114:0x0048), top: B:2:0x0024 }] */
    /* JADX WARN: Removed duplicated region for block: B:37:0x0102 A[Catch: Exception -> 0x02a7, TryCatch #2 {Exception -> 0x02a7, blocks: (B:3:0x0024, B:6:0x0034, B:10:0x007a, B:13:0x0085, B:15:0x0098, B:17:0x00a0, B:20:0x00ac, B:22:0x00b4, B:24:0x00bc, B:27:0x00ca, B:29:0x00d2, B:31:0x00da, B:34:0x00fc, B:37:0x0102, B:40:0x0117, B:43:0x011f, B:45:0x012d, B:46:0x0133, B:50:0x0148, B:52:0x014e, B:55:0x0189, B:76:0x02a3, B:114:0x0048), top: B:2:0x0024 }] */
    /* JADX WARN: Removed duplicated region for block: B:61:0x01eb A[Catch: Exception -> 0x01de, TRY_ENTER, TryCatch #0 {Exception -> 0x01de, blocks: (B:89:0x0197, B:91:0x019d, B:61:0x01eb, B:62:0x0203, B:65:0x0216, B:68:0x021f, B:71:0x0229, B:74:0x0233), top: B:88:0x0197 }] */
    /* JADX WARN: Removed duplicated region for block: B:64:0x0212  */
    /* JADX WARN: Removed duplicated region for block: B:67:0x021b  */
    /* JADX WARN: Removed duplicated region for block: B:70:0x0224  */
    /* JADX WARN: Removed duplicated region for block: B:73:0x022e  */
    /* JADX WARN: Removed duplicated region for block: B:83:0x0231  */
    /* JADX WARN: Removed duplicated region for block: B:84:0x0227  */
    /* JADX WARN: Removed duplicated region for block: B:85:0x021d  */
    /* JADX WARN: Removed duplicated region for block: B:86:0x0214  */
    /* JADX WARN: Removed duplicated region for block: B:87:0x0201  */
    @PluginMethod
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    public void schedule(PluginCall call) {
        String str;
        String str2;
        String str3;
        String str4;
        String appId;
        long atMs;
        Double at;
        String str5;
        String str6;
        boolean notify;
        String appId2;
        String payload;
        Double inMs;
        PluginCall pluginCall = call;
        try {
            Context ctx = getContext();
            String id = pluginCall.getString("id");
            if (id != null && !id.trim().isEmpty()) {
                str = "payload";
                str2 = "notify";
                str3 = NotifyBridgePlugin.CHANNEL_JOBS;
                str4 = "channel";
                String id2 = sanitize(id);
                appId = pluginCall.getString("appId", "");
                if (appId == null) {
                    appId = "";
                }
                String appId3 = appId.trim();
                String appTitle = pluginCall.getString("appTitle", "Forge app");
                atMs = 0;
                at = pluginCall.getDouble("atMs");
                if (at != null && at.doubleValue() > 0.0d) {
                    atMs = at.longValue();
                }
                if (atMs <= 0 && (inMs = pluginCall.getDouble("inMs")) != null && inMs.doubleValue() > 0.0d) {
                    atMs = System.currentTimeMillis() + inMs.longValue();
                }
                if (atMs <= 0) {
                    str5 = "atMs";
                } else {
                    Double inSec = pluginCall.getDouble("inSeconds");
                    if (inSec == null || inSec.doubleValue() <= 0.0d) {
                        str5 = "atMs";
                    } else {
                        str5 = "atMs";
                        atMs = System.currentTimeMillis() + ((long) (inSec.doubleValue() * 1000.0d));
                    }
                }
                if (atMs > 0) {
                    pluginCall.reject("Provide atMs, inMs, or inSeconds");
                    return;
                }
                long atMs2 = System.currentTimeMillis() + 5000;
                if (atMs >= atMs2) {
                    atMs2 = atMs;
                }
                String type = pluginCall.getString("type", "once");
                if (type == null) {
                    type = "once";
                }
                String type2 = type;
                Double interval = pluginCall.getDouble("intervalMs");
                long atMs3 = atMs2;
                long intervalMs = interval != null ? interval.longValue() : 0L;
                if ("interval".equals(type2) && intervalMs < 60000) {
                    pluginCall.reject("intervalMs minimum is 60000 (1 minute)");
                    return;
                }
                String title = pluginCall.getString("title", appTitle);
                String text = pluginCall.getString("text", pluginCall.getString("message", "Reminder"));
                String str7 = str4;
                String str8 = str3;
                String channel = pluginCall.getString(str7, str8);
                String str9 = str2;
                boolean notify2 = !Boolean.FALSE.equals(pluginCall.getBoolean(str9, true));
                String str10 = str;
                String payload2 = pluginCall.getString(str10, null);
                if (payload2 == null) {
                    try {
                        if (call.getData() != null) {
                            str6 = str10;
                            if (call.getData().has("data")) {
                                try {
                                    Object data = call.getData().get("data");
                                    JSONObject p = new JSONObject();
                                    notify = notify2;
                                    try {
                                        p.put("jobId", id2);
                                        appId2 = str9;
                                        try {
                                            p.put("type", "job");
                                            p.put("data", data);
                                            payload2 = p.toString();
                                        } catch (Exception e) {
                                        }
                                    } catch (Exception e2) {
                                        appId2 = str9;
                                    }
                                } catch (Exception e3) {
                                    notify = notify2;
                                    appId2 = str9;
                                }
                                if (payload2 != null) {
                                    payload = payload2;
                                } else {
                                    JSONObject p2 = new JSONObject();
                                    p2.put("jobId", id2);
                                    p2.put("type", "job");
                                    payload = p2.toString();
                                }
                                JSONObject job = new JSONObject();
                                job.put("id", id2);
                                job.put("appId", appId3);
                                job.put("appTitle", appTitle != null ? appTitle : "Forge app");
                                job.put("title", title != null ? title : "Forge");
                                job.put("text", text != null ? text : "Reminder");
                                job.put(str7, channel != null ? channel : str8);
                                String str11 = str5;
                                job.put(str11, atMs3);
                                job.put("type", type2);
                                job.put("intervalMs", intervalMs);
                                job.put(appId2, notify);
                                job.put(str6, payload);
                                job.put("createdAt", System.currentTimeMillis());
                                SharedPreferences prefs = ctx.getSharedPreferences("forge_jobs_v1", 0);
                                prefs.edit().putString(id2, job.toString()).apply();
                                scheduleAlarm(ctx, id2, atMs3);
                                JSObject ret = new JSObject();
                                ret.put("ok", true);
                                ret.put("id", id2);
                                ret.put(str11, atMs3);
                                ret.put("type", type2);
                                ret.put("intervalMs", intervalMs);
                                ret.put("exact", canScheduleExact(ctx));
                                call.resolve(ret);
                                return;
                            }
                            notify = notify2;
                            appId2 = str9;
                            if (payload2 != null) {
                            }
                            JSONObject job2 = new JSONObject();
                            job2.put("id", id2);
                            job2.put("appId", appId3);
                            job2.put("appTitle", appTitle != null ? appTitle : "Forge app");
                            job2.put("title", title != null ? title : "Forge");
                            job2.put("text", text != null ? text : "Reminder");
                            job2.put(str7, channel != null ? channel : str8);
                            String str112 = str5;
                            job2.put(str112, atMs3);
                            job2.put("type", type2);
                            job2.put("intervalMs", intervalMs);
                            job2.put(appId2, notify);
                            job2.put(str6, payload);
                            job2.put("createdAt", System.currentTimeMillis());
                            SharedPreferences prefs2 = ctx.getSharedPreferences("forge_jobs_v1", 0);
                            prefs2.edit().putString(id2, job2.toString()).apply();
                            scheduleAlarm(ctx, id2, atMs3);
                            JSObject ret2 = new JSObject();
                            ret2.put("ok", true);
                            ret2.put("id", id2);
                            ret2.put(str112, atMs3);
                            ret2.put("type", type2);
                            ret2.put("intervalMs", intervalMs);
                            ret2.put("exact", canScheduleExact(ctx));
                            call.resolve(ret2);
                            return;
                        }
                    } catch (Exception e4) {
                        e = e4;
                        pluginCall = call;
                        pluginCall.reject("schedule failed: " + e.getMessage(), e);
                        return;
                    }
                }
                str6 = str10;
                notify = notify2;
                appId2 = str9;
                if (payload2 != null) {
                }
                JSONObject job22 = new JSONObject();
                job22.put("id", id2);
                job22.put("appId", appId3);
                job22.put("appTitle", appTitle != null ? appTitle : "Forge app");
                job22.put("title", title != null ? title : "Forge");
                job22.put("text", text != null ? text : "Reminder");
                job22.put(str7, channel != null ? channel : str8);
                String str1122 = str5;
                job22.put(str1122, atMs3);
                job22.put("type", type2);
                job22.put("intervalMs", intervalMs);
                job22.put(appId2, notify);
                job22.put(str6, payload);
                job22.put("createdAt", System.currentTimeMillis());
                SharedPreferences prefs22 = ctx.getSharedPreferences("forge_jobs_v1", 0);
                prefs22.edit().putString(id2, job22.toString()).apply();
                scheduleAlarm(ctx, id2, atMs3);
                JSObject ret22 = new JSObject();
                ret22.put("ok", true);
                ret22.put("id", id2);
                ret22.put(str1122, atMs3);
                ret22.put("type", type2);
                ret22.put("intervalMs", intervalMs);
                ret22.put("exact", canScheduleExact(ctx));
                call.resolve(ret22);
                return;
            }
            str = "payload";
            str2 = "notify";
            StringBuilder append = new StringBuilder().append("job_");
            String uuid = UUID.randomUUID().toString();
            str3 = NotifyBridgePlugin.CHANNEL_JOBS;
            str4 = "channel";
            id = append.append(uuid.replace("-", "").substring(0, 12)).toString();
            String id22 = sanitize(id);
            appId = pluginCall.getString("appId", "");
            if (appId == null) {
            }
            String appId32 = appId.trim();
            String appTitle2 = pluginCall.getString("appTitle", "Forge app");
            atMs = 0;
            at = pluginCall.getDouble("atMs");
            if (at != null) {
                atMs = at.longValue();
            }
            if (atMs <= 0) {
                atMs = System.currentTimeMillis() + inMs.longValue();
            }
            if (atMs <= 0) {
            }
            if (atMs > 0) {
            }
        } catch (Exception e5) {
            e = e5;
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
        getContext().getSharedPreferences("forge_jobs_v1", 0).edit().remove(id2).apply();
        JSObject o = new JSObject();
        o.put("ok", true);
        o.put("id", id2);
        call.resolve(o);
    }

    @PluginMethod
    public void cancelAll(PluginCall call) {
        Context ctx = getContext();
        SharedPreferences prefs = ctx.getSharedPreferences("forge_jobs_v1", 0);
        String appId = call.getString("appId", null);
        Map<String, ?> all = prefs.getAll();
        List<String> removed = new ArrayList<>();
        for (String key : all.keySet()) {
            try {
                JSONObject job = new JSONObject(String.valueOf(all.get(key)));
                if (appId == null || appId.isEmpty() || appId.equals(job.optString("appId"))) {
                    cancelAlarm(ctx, key);
                    removed.add(key);
                }
            } catch (Exception e) {
                removed.add(key);
            }
        }
        SharedPreferences.Editor ed = prefs.edit();
        for (String k : removed) {
            ed.remove(k);
        }
        ed.apply();
        JSObject o = new JSObject();
        o.put("ok", true);
        o.put("cancelled", removed.size());
        call.resolve(o);
    }

    /* JADX WARN: Can't wrap try/catch for region: R(14:4|(2:5|6)|(3:8|9|(2:29|23))(1:34)|14|15|16|17|18|19|20|21|22|23|2) */
    /* JADX WARN: Code restructure failed: missing block: B:28:0x00bd, code lost:
    
        r9 = r6;
        r16 = r7;
     */
    @PluginMethod
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    public void list(PluginCall pluginCall) {
        String str;
        SharedPreferences prefs;
        String str2;
        JSONObject job;
        String str3 = "text";
        String str4 = "title";
        SharedPreferences prefs2 = getContext().getSharedPreferences("forge_jobs_v1", 0);
        String appId = pluginCall.getString("appId", null);
        JSArray arr = new JSArray();
        for (Map.Entry<String, ?> e : prefs2.getAll().entrySet()) {
            try {
                job = new JSONObject(String.valueOf(e.getValue()));
            } catch (Exception e2) {
                str = str4;
                prefs = prefs2;
                str2 = str3;
            }
            if (appId != null) {
                try {
                } catch (Exception e3) {
                    str = str4;
                    prefs = prefs2;
                    str2 = str3;
                }
                if (!appId.isEmpty() && !appId.equals(job.optString("appId"))) {
                }
            }
            JSObject o = new JSObject();
            prefs = prefs2;
            o.put("id", job.optString("id", e.getKey()));
            o.put("appId", job.optString("appId"));
            o.put(str4, job.optString(str4));
            o.put(str3, job.optString(str3));
            str2 = str3;
            str = str4;
            o.put("atMs", job.optLong("atMs"));
            o.put("type", job.optString("type", "once"));
            o.put("intervalMs", job.optLong("intervalMs"));
            o.put("notify", job.optBoolean("notify", true));
            arr.put(o);
            str3 = str2;
            str4 = str;
            prefs2 = prefs;
        }
        JSObject ret = new JSObject();
        ret.put("jobs", (Object) arr);
        pluginCall.resolve(ret);
    }

    /* JADX WARN: Can't wrap try/catch for region: R(15:4|(1:37)(2:8|(4:33|34|35|22))|10|11|12|13|14|15|16|17|(1:19)|20|21|22|2) */
    /* JADX WARN: Code restructure failed: missing block: B:25:0x00db, code lost:
    
        if (r0 != false) goto L28;
     */
    /* JADX WARN: Code restructure failed: missing block: B:26:0x00dd, code lost:
    
        r12.remove(r15);
     */
    /* JADX WARN: Code restructure failed: missing block: B:29:0x00d1, code lost:
    
        r9 = r3;
        r18 = r4;
     */
    /* JADX WARN: Code restructure failed: missing block: B:32:0x00d6, code lost:
    
        r18 = r4;
        r17 = r9;
        r9 = r3;
     */
    @PluginMethod
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    public void listPending(PluginCall pluginCall) {
        SharedPreferences pending;
        String str = "text";
        String str2 = "title";
        SharedPreferences pending2 = getContext().getSharedPreferences("forge_jobs_pending_v1", 0);
        String appId = pluginCall.getString("appId", "");
        boolean consume = !Boolean.FALSE.equals(pluginCall.getBoolean("consume", true));
        JSArray arr = new JSArray();
        SharedPreferences.Editor ed = pending2.edit();
        for (Map.Entry<String, ?> e : pending2.getAll().entrySet()) {
            String key = e.getKey();
            if (appId == null || appId.isEmpty()) {
                pending = pending2;
            } else {
                pending = pending2;
                if (!key.startsWith(appId + "::")) {
                    pending2 = pending;
                }
            }
            JSONObject p = new JSONObject(String.valueOf(e.getValue()));
            JSObject o = new JSObject();
            String appId2 = appId;
            String appId3 = p.optString("jobId");
            o.put("jobId", appId3);
            o.put("appId", p.optString("appId"));
            o.put("payload", p.optString("payload"));
            o.put(str2, p.optString(str2));
            o.put(str, p.optString(str));
            String appId4 = str;
            String str3 = str2;
            o.put("firedAt", p.optLong("firedAt"));
            arr.put(o);
            if (consume) {
                ed.remove(key);
            }
            str = appId4;
            pending2 = pending;
            appId = appId2;
            str2 = str3;
        }
        if (consume) {
            ed.apply();
        }
        JSObject ret = new JSObject();
        ret.put("pending", (Object) arr);
        pluginCall.resolve(ret);
    }

    public static void scheduleAlarm(Context ctx, String jobId, long atMs) {
        AlarmManager am = (AlarmManager) ctx.getSystemService(NotificationCompat.CATEGORY_ALARM);
        if (am == null) {
            return;
        }
        PendingIntent pi = jobPendingIntent(ctx, jobId);
        try {
            if (Build.VERSION.SDK_INT >= 23) {
                if (canScheduleExact(ctx)) {
                    am.setExactAndAllowWhileIdle(0, atMs, pi);
                } else {
                    am.setAndAllowWhileIdle(0, atMs, pi);
                }
            } else {
                am.setExact(0, atMs, pi);
            }
        } catch (SecurityException e) {
            try {
                am.setAndAllowWhileIdle(0, atMs, pi);
            } catch (Exception e2) {
                try {
                    am.set(0, atMs, pi);
                } catch (Exception e3) {
                }
            }
        } catch (Exception e4) {
            try {
                am.set(0, atMs, pi);
            } catch (Exception e5) {
            }
        }
    }

    public static void cancelAlarm(Context ctx, String jobId) {
        AlarmManager am = (AlarmManager) ctx.getSystemService(NotificationCompat.CATEGORY_ALARM);
        if (am == null) {
            return;
        }
        try {
            am.cancel(jobPendingIntent(ctx, jobId));
        } catch (Exception e) {
        }
    }

    public static void rescheduleAll(Context ctx) {
        JSONObject job;
        long at;
        String type;
        SharedPreferences prefs = ctx.getSharedPreferences("forge_jobs_v1", 0);
        long now = System.currentTimeMillis();
        for (Map.Entry<String, ?> e : prefs.getAll().entrySet()) {
            try {
                job = new JSONObject(String.valueOf(e.getValue()));
                at = job.optLong("atMs", 0L);
                type = job.optString("type", "once");
            } catch (Exception e2) {
            }
            if (at <= now) {
                if ("interval".equals(type)) {
                    long interval = job.optLong("intervalMs", 0L);
                    if (interval >= 60000) {
                        at = now + interval;
                        job.put("atMs", at);
                        prefs.edit().putString(e.getKey(), job.toString()).apply();
                    }
                } else {
                    at = now + 5000;
                }
            }
            scheduleAlarm(ctx, e.getKey(), at);
        }
    }

    private static PendingIntent jobPendingIntent(Context ctx, String jobId) {
        Intent i = new Intent(ctx, (Class<?>) ForgeJobReceiver.class);
        i.setAction(ForgeJobReceiver.ACTION_JOB);
        i.putExtra(EXTRA_JOB_ID, jobId);
        int flags = Build.VERSION.SDK_INT >= 23 ? 134217728 | AccessibilityEventCompat.TYPE_VIEW_TARGETED_BY_SCROLL : 134217728;
        int req = Math.abs(jobId.hashCode());
        return PendingIntent.getBroadcast(ctx, req, i, flags);
    }

    private static boolean canScheduleExact(Context ctx) {
        if (Build.VERSION.SDK_INT < 31) {
            return true;
        }
        AlarmManager am = (AlarmManager) ctx.getSystemService(NotificationCompat.CATEGORY_ALARM);
        return am != null && am.canScheduleExactAlarms();
    }

    private static String sanitize(String id) {
        return id.trim().replaceAll("[^a-zA-Z0-9._-]", "_");
    }
}
