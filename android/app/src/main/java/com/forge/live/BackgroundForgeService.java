package com.forge.live;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.os.PowerManager;
import androidx.core.app.NotificationCompat;
import androidx.core.view.accessibility.AccessibilityEventCompat;

public class BackgroundForgeService extends Service {
    public static final String ACTION_START = "com.forge.live.bg.START";
    public static final String ACTION_STOP = "com.forge.live.bg.STOP";
    public static final String ACTION_UPDATE = "com.forge.live.bg.UPDATE";
    public static final String CHANNEL_ID = "forge_bg";
    public static final String EXTRA_TEXT = "text";
    public static final String EXTRA_TITLE = "title";
    public static final int NOTIFICATION_ID = 43001;
    private PowerManager.WakeLock wakeLock;
    private String title = "Forge";
    private String text = "Working in the background…";

    @Override // android.app.Service
    public void onCreate() {
        super.onCreate();
        createChannel();
        acquireWakeLock();
    }

    @Override // android.app.Service
    public int onStartCommand(Intent intent, int flags, int startId) {
        String t;
        String t2;
        if (intent != null) {
            String action = intent.getAction();
            if (ACTION_STOP.equals(action)) {
                stopForegroundSafe();
                stopSelf();
                return 2;
            }
            if (intent.hasExtra("title") && (t2 = intent.getStringExtra("title")) != null && !t2.isEmpty()) {
                this.title = t2;
            }
            if (intent.hasExtra("text") && (t = intent.getStringExtra("text")) != null && !t.isEmpty()) {
                this.text = t;
            }
        }
        startAsForeground();
        return 1;
    }

    private void startAsForeground() {
        Notification notification = buildNotification(this.title, this.text);
        try {
            if (Build.VERSION.SDK_INT >= 29) {
                startForeground(NOTIFICATION_ID, notification, 1);
            } else {
                startForeground(NOTIFICATION_ID, notification);
            }
        } catch (Exception e) {
            try {
                startForeground(NOTIFICATION_ID, notification);
            } catch (Exception e2) {
            }
        }
    }

    private Notification buildNotification(String title, String text) {
        Intent launch = getPackageManager().getLaunchIntentForPackage(getPackageName());
        if (launch == null) {
            launch = new Intent(this, (Class<?>) MainActivity.class);
        }
        launch.addFlags(603979776);
        int piFlags = Build.VERSION.SDK_INT >= 23 ? 134217728 | AccessibilityEventCompat.TYPE_VIEW_TARGETED_BY_SCROLL : 134217728;
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0, launch, piFlags);
        return new NotificationCompat.Builder(this, CHANNEL_ID).setContentTitle(title != null ? title : "Forge").setContentText(text != null ? text : "Working…").setSmallIcon(android.R.drawable.ic_menu_edit).setContentIntent(contentIntent).setOngoing(true).setOnlyAlertOnce(true).setForegroundServiceBehavior(1).setCategory(NotificationCompat.CATEGORY_SERVICE).setPriority(-1).setVisibility(1).build();
    }

    private void createChannel() {
        NotificationManager nm;
        if (Build.VERSION.SDK_INT >= 26 && (nm = (NotificationManager) getSystemService("notification")) != null) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "Forge background", 2);
            channel.setDescription("Keeps app generation running in the background");
            channel.setShowBadge(false);
            nm.createNotificationChannel(channel);
        }
    }

    private void acquireWakeLock() {
        PowerManager pm;
        PowerManager.WakeLock wakeLock = this.wakeLock;
        if ((wakeLock == null || !wakeLock.isHeld()) && (pm = (PowerManager) getSystemService("power")) != null) {
            PowerManager.WakeLock newWakeLock = pm.newWakeLock(1, "forge:bg");
            this.wakeLock = newWakeLock;
            newWakeLock.setReferenceCounted(false);
            this.wakeLock.acquire(7200000L);
        }
    }

    private void releaseWakeLock() {
        PowerManager.WakeLock wakeLock = this.wakeLock;
        if (wakeLock != null && wakeLock.isHeld()) {
            try {
                this.wakeLock.release();
            } catch (Exception e) {
            }
        }
        this.wakeLock = null;
    }

    private void stopForegroundSafe() {
        try {
            if (Build.VERSION.SDK_INT >= 24) {
                stopForeground(1);
            } else {
                stopForeground(true);
            }
        } catch (Exception e) {
        }
    }

    @Override // android.app.Service
    public void onDestroy() {
        stopForegroundSafe();
        releaseWakeLock();
        super.onDestroy();
    }

    @Override // android.app.Service
    public IBinder onBind(Intent intent) {
        return null;
    }

    public static void start(Context context, String title, String text) {
        Intent i = new Intent(context, (Class<?>) BackgroundForgeService.class);
        i.setAction(ACTION_START);
        if (title != null) {
            i.putExtra("title", title);
        }
        if (text != null) {
            i.putExtra("text", text);
        }
        if (Build.VERSION.SDK_INT < 26) {
            context.startService(i);
        } else {
            context.startForegroundService(i);
        }
    }

    public static void update(Context context, String title, String text) {
        Intent i = new Intent(context, (Class<?>) BackgroundForgeService.class);
        i.setAction(ACTION_UPDATE);
        if (title != null) {
            i.putExtra("title", title);
        }
        if (text != null) {
            i.putExtra("text", text);
        }
        if (Build.VERSION.SDK_INT < 26) {
            context.startService(i);
        } else {
            context.startForegroundService(i);
        }
    }

    public static void stop(Context context) {
        Intent i = new Intent(context, (Class<?>) BackgroundForgeService.class);
        i.setAction(ACTION_STOP);
        try {
            context.startService(i);
        } catch (Exception e) {
            context.stopService(new Intent(context, (Class<?>) BackgroundForgeService.class));
        }
    }
}
