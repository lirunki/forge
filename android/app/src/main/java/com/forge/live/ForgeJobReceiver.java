package com.forge.live;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

import org.json.JSONObject;

/**
 * Fires scheduled Forge jobs (alarms). Logic restored from v2.6.1 APK behavior.
 */
public class ForgeJobReceiver extends BroadcastReceiver {
    public static final String ACTION_JOB = "com.forge.live.JOB_FIRE";
    public static final String PENDING_PREFS = "forge_jobs_pending_v1";
    public static final String PREFS = "forge_jobs_v1";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (context == null || intent == null) return;
        try {
            if (intent.getAction() != null
                    && !ACTION_JOB.equals(intent.getAction())
                    && !Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
                // still allow explicit job extras without action match
            }

            // Boot: reschedule all
            if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
                try {
                    JobBridgePlugin.rescheduleAll(context);
                } catch (Exception ignored) {
                }
                return;
            }

            String jobId = intent.getStringExtra("jobId");
            if (jobId == null || jobId.isEmpty()) {
                jobId = intent.getStringExtra("id");
            }
            if (jobId == null || jobId.isEmpty()) return;

            SharedPreferences prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
            String raw = prefs.getString(jobId, null);
            if (raw == null || raw.isEmpty()) return;

            JSONObject job = new JSONObject(raw);
            String appId = job.optString("appId", "");
            String appTitle = job.optString("appTitle", job.optString("title", "Forge"));
            String title = job.optString("title", "Job");
            String text = job.optString("text", job.optString("message", "Job fired"));
            String payload = job.optString("payload", job.optString("data", ""));
            String channel = job.optString("channel", NotifyBridgePlugin.CHANNEL_JOBS);
            boolean notify = job.optBoolean("notify", true);
            String type = job.optString("type", "once");

            if (notify) {
                try {
                    int nid = Math.abs(jobId.hashCode());
                    NotifyBridgePlugin.showNotification(
                            context,
                            appId,
                            appTitle,
                            title,
                            text,
                            channel,
                            "job:" + jobId,
                            payload,
                            (nid % 10000) + 53000
                    );
                } catch (Exception ignored) {
                }
            }

            // Stash pending event for JS layer
            try {
                SharedPreferences pending = context.getSharedPreferences(PENDING_PREFS, Context.MODE_PRIVATE);
                JSONObject pend = new JSONObject();
                pend.put("jobId", jobId);
                pend.put("appId", appId);
                pend.put("payload", payload);
                pend.put("title", title);
                pend.put("text", text);
                pend.put("firedAt", System.currentTimeMillis());
                pending.edit().putString(appId + "::" + jobId, pend.toString()).apply();
            } catch (Exception ignored) {
            }

            if ("once".equals(type)) {
                prefs.edit().remove(jobId).apply();
            } else if ("interval".equals(type)) {
                long intervalMs = job.optLong("intervalMs", 0L);
                if (intervalMs >= 60_000L) {
                    long next = System.currentTimeMillis() + intervalMs;
                    job.put("atMs", next);
                    prefs.edit().putString(jobId, job.toString()).apply();
                    JobBridgePlugin.scheduleAlarm(context, jobId, next);
                } else {
                    prefs.edit().remove(jobId).apply();
                }
            }
        } catch (Exception ignored) {
        }
    }
}
