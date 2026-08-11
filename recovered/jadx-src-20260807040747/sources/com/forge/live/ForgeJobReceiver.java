package com.forge.live;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import org.json.JSONObject;

/* loaded from: classes4.dex */
public class ForgeJobReceiver extends BroadcastReceiver {
    public static final String ACTION_JOB = "com.forge.live.JOB_FIRE";
    public static final String PENDING_PREFS = "forge_jobs_pending_v1";
    public static final String PREFS = "forge_jobs_v1";

    /* JADX WARN: Removed duplicated region for block: B:39:0x015d  */
    /* JADX WARN: Removed duplicated region for block: B:46:0x01d3 A[Catch: Exception -> 0x0226, TryCatch #3 {Exception -> 0x0226, blocks: (B:44:0x017d, B:46:0x01d3, B:50:0x01df, B:52:0x01e7, B:54:0x01f6, B:55:0x0215), top: B:43:0x017d }] */
    /* JADX WARN: Removed duplicated region for block: B:50:0x01df A[Catch: Exception -> 0x0226, TryCatch #3 {Exception -> 0x0226, blocks: (B:44:0x017d, B:46:0x01d3, B:50:0x01df, B:52:0x01e7, B:54:0x01f6, B:55:0x0215), top: B:43:0x017d }] */
    /* JADX WARN: Removed duplicated region for block: B:63:0x0101 A[EXC_TOP_SPLITTER, SYNTHETIC] */
    @Override // android.content.BroadcastReceiver
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    public void onReceive(Context context, Intent intent) {
        String jobId;
        SharedPreferences prefs;
        String raw;
        String payload;
        String title;
        boolean notify;
        JSONObject job;
        String str;
        String appId;
        SharedPreferences prefs2;
        String str2;
        int i;
        String jobId2;
        String str3;
        String type;
        if (context == null || intent == null) {
            return;
        }
        if (!ACTION_JOB.equals(intent.getAction())) {
            "android.intent.action.BOOT_COMPLETED".equals(intent.getAction());
        }
        if ("android.intent.action.BOOT_COMPLETED".equals(intent.getAction())) {
            JobBridgePlugin.rescheduleAll(context);
            return;
        }
        if (!ACTION_JOB.equals(intent.getAction()) || (jobId = intent.getStringExtra(JobBridgePlugin.EXTRA_JOB_ID)) == null || jobId.isEmpty() || (raw = (prefs = context.getSharedPreferences(PREFS, 0)).getString(jobId, null)) == null) {
            return;
        }
        try {
            JSONObject job2 = new JSONObject(raw);
            String appId2 = job2.optString("appId", "");
            String appTitle = job2.optString("appTitle", "Forge app");
            String title2 = job2.optString("title", appTitle);
            String text = job2.optString("text", job2.optString("message", "Reminder"));
            String channel = job2.optString("channel", NotifyBridgePlugin.CHANNEL_JOBS);
            String payload2 = job2.optString("payload", null);
            try {
                try {
                    if (payload2 != null) {
                        try {
                            if (!payload2.isEmpty()) {
                                try {
                                    JSONObject p = new JSONObject(payload2);
                                    if (!p.has("jobId")) {
                                        p.put("jobId", jobId);
                                    }
                                    payload2 = p.toString();
                                } catch (Exception e) {
                                }
                                payload = payload2;
                                title = title2;
                                notify = job2.optBoolean("notify", true);
                                if (notify) {
                                    job = job2;
                                    prefs2 = prefs;
                                    jobId2 = jobId;
                                    str3 = "appId";
                                    str = "type";
                                    str2 = "text";
                                    appId = appId2;
                                    i = 0;
                                } else {
                                    try {
                                        int nid = Math.abs(jobId.hashCode());
                                        job = job2;
                                        str = "type";
                                        appId = appId2;
                                        prefs2 = prefs;
                                        str2 = "text";
                                        i = 0;
                                        jobId2 = jobId;
                                        str3 = "appId";
                                        try {
                                            NotifyBridgePlugin.showNotification(context, appId2, appTitle, title, text, channel, "job:" + jobId, payload, (nid % 10000) + 53000);
                                        } catch (Exception e2) {
                                            return;
                                        }
                                    } catch (Exception e3) {
                                        return;
                                    }
                                }
                                SharedPreferences pending = context.getSharedPreferences(PENDING_PREFS, i);
                                JSONObject pend = new JSONObject();
                                String jobId3 = jobId2;
                                pend.put("jobId", jobId3);
                                pend.put(str3, appId);
                                pend.put("payload", payload);
                                pend.put("title", title);
                                pend.put(str2, text);
                                pend.put("firedAt", System.currentTimeMillis());
                                pending.edit().putString(appId + "::" + jobId3, pend.toString()).apply();
                                JSONObject job3 = job;
                                type = job3.optString(str, "once");
                                if (!"once".equals(type)) {
                                    prefs2.edit().remove(jobId3).apply();
                                } else if ("interval".equals(type)) {
                                    long intervalMs = job3.optLong("intervalMs", 0L);
                                    if (intervalMs >= 60000) {
                                        long next = System.currentTimeMillis() + intervalMs;
                                        job3.put("atMs", next);
                                        prefs2.edit().putString(jobId3, job3.toString()).apply();
                                        JobBridgePlugin.scheduleAlarm(context, jobId3, next);
                                    } else {
                                        prefs2.edit().remove(jobId3).apply();
                                    }
                                }
                                return;
                            }
                        } catch (Exception e4) {
                            return;
                        }
                    }
                    pend.put("jobId", jobId3);
                    pend.put(str3, appId);
                    pend.put("payload", payload);
                    pend.put("title", title);
                    pend.put(str2, text);
                    pend.put("firedAt", System.currentTimeMillis());
                    pending.edit().putString(appId + "::" + jobId3, pend.toString()).apply();
                    JSONObject job32 = job;
                    type = job32.optString(str, "once");
                    if (!"once".equals(type)) {
                    }
                    return;
                } catch (Exception e5) {
                    return;
                }
                SharedPreferences pending2 = context.getSharedPreferences(PENDING_PREFS, i);
                JSONObject pend2 = new JSONObject();
                String jobId32 = jobId2;
            } catch (Exception e6) {
                return;
            }
            JSONObject p2 = new JSONObject();
            p2.put("jobId", jobId);
            title = title2;
            p2.put("type", "job");
            if (job2.has("data")) {
                p2.put("data", job2.get("data"));
            }
            payload = p2.toString();
            notify = job2.optBoolean("notify", true);
            if (notify) {
            }
        } catch (Exception e7) {
        }
    }
}
