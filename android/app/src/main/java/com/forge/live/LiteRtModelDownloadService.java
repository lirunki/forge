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
import android.os.Handler;
import android.os.Looper;
import android.net.wifi.WifiManager;
import androidx.core.app.NotificationCompat;

/** User-visible foreground lifetime for long, verified LiteRT-LM model downloads. */
public final class LiteRtModelDownloadService extends Service {
    public static final String ACTION_START = "com.forge.live.litert.download.START";
    public static final String ACTION_STOP = "com.forge.live.litert.download.STOP";
    public static final String ACTION_UPDATE = "com.forge.live.litert.download.UPDATE";
    private static final String EXTRA_BYTES = "bytes";
    private static final String EXTRA_PROGRESS = "progress";
    private static final String CHANNEL_ID = "forge_model_downloads";
    private static final int NOTIFICATION_ID = 43021;
    private PowerManager.WakeLock wakeLock;
    private WifiManager.WifiLock wifiLock;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private Runnable wifiLockTimeout;
    private String modelName = "offline model";
    private String progressText = "Preparing download…";
    private int progress = -1;
    private boolean foregroundStarted;

    @Override public void onCreate() {
        super.onCreate();
        createChannel();
    }

    @Override public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent == null || ACTION_STOP.equals(intent.getAction())) {
            stopForegroundCompat();
            stopSelf();
            return START_NOT_STICKY;
        }
        String action = intent.getAction();
        if (ACTION_UPDATE.equals(action) && !foregroundStarted) {
            acquireWakeLock();
            startForegroundCompat(buildNotification());
        }
        if (intent.hasExtra("modelName")) modelName = intent.getStringExtra("modelName");
        if (modelName == null || modelName.isEmpty()) modelName = "offline model";
        if (ACTION_UPDATE.equals(action)) {
            if (intent.hasExtra(EXTRA_BYTES)) progressText = intent.getStringExtra(EXTRA_BYTES);
            if (intent.hasExtra(EXTRA_PROGRESS)) progress = intent.getIntExtra(EXTRA_PROGRESS, -1);
        }
        if (ACTION_UPDATE.equals(action)) {
            NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            if (manager != null) manager.notify(NOTIFICATION_ID, buildNotification());
            return START_NOT_STICKY;
        }
        acquireWakeLock();
        startForegroundCompat(buildNotification());
        return START_NOT_STICKY;
    }

    @Override public void onDestroy() {
        releaseWakeLock();
        releaseWifiLock();
        super.onDestroy();
    }

    @Override public void onTimeout(int startId, int foregroundServiceType) {
        LiteRtLmBridgePlugin.cancelActiveDownloads("Android data-sync foreground-service limit reached");
        stopForegroundCompat();
        stopSelf(startId);
    }

    @Override public IBinder onBind(Intent intent) { return null; }

    private Notification buildNotification() {
        Intent launch = getPackageManager().getLaunchIntentForPackage(getPackageName());
        if (launch == null) launch = new Intent(this, MainActivity.class);
        launch.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent open = PendingIntent.getActivity(this, 43021, launch,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        return new NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle("Downloading Forge offline model")
            .setContentText(modelName + " · " + progressText)
            .setSubText("Forge model download")
            .setContentIntent(open)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setProgress(100, Math.max(0, progress), progress < 0)
            .build();
    }

    private void startForegroundCompat(Notification notification) {
        if (Build.VERSION.SDK_INT >= 29) {
            startForeground(NOTIFICATION_ID, notification, android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);
        } else {
            startForeground(NOTIFICATION_ID, notification);
        }
        foregroundStarted = true;
    }

    private void stopForegroundCompat() {
        if (Build.VERSION.SDK_INT >= 24) stopForeground(STOP_FOREGROUND_REMOVE);
        else stopForeground(true);
    }

    private void createChannel() {
        if (Build.VERSION.SDK_INT < 26) return;
        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (manager == null) return;
        NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "Offline model downloads", NotificationManager.IMPORTANCE_LOW);
        channel.setDescription("Shows long offline model downloads that continue while Forge is in the background");
        channel.setShowBadge(false);
        manager.createNotificationChannel(channel);
    }

    private void acquireWakeLock() {
        PowerManager power = (PowerManager) getSystemService(Context.POWER_SERVICE);
        if (power == null || (wakeLock != null && wakeLock.isHeld())) return;
        wakeLock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Forge:LiteRTModelDownloadService");
        wakeLock.setReferenceCounted(false);
        wakeLock.acquire(6L * 60L * 60L * 1000L);
        WifiManager wifi = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        if (wifi != null) {
            int mode = Build.VERSION.SDK_INT >= 29 ? WifiManager.WIFI_MODE_FULL_LOW_LATENCY : WifiManager.WIFI_MODE_FULL_HIGH_PERF;
            wifiLock = wifi.createWifiLock(mode, "Forge:LiteRTModelDownloadWifi");
            wifiLock.setReferenceCounted(false);
            wifiLock.acquire();
            final WifiManager.WifiLock acquiredLock = wifiLock;
            wifiLockTimeout = () -> { if (acquiredLock.isHeld()) acquiredLock.release(); };
            handler.postDelayed(wifiLockTimeout, 6L * 60L * 60L * 1000L);
        }
    }

    private void releaseWakeLock() {
        if (wakeLock != null && wakeLock.isHeld()) wakeLock.release();
        wakeLock = null;
    }

    private void releaseWifiLock() {
        if (wifiLockTimeout != null) handler.removeCallbacks(wifiLockTimeout);
        wifiLockTimeout = null;
        if (wifiLock != null && wifiLock.isHeld()) wifiLock.release();
        wifiLock = null;
    }

    public static void start(Context context, String modelName) {
        Intent intent = new Intent(context, LiteRtModelDownloadService.class).setAction(ACTION_START).putExtra("modelName", modelName);
        if (Build.VERSION.SDK_INT >= 26) context.startForegroundService(intent);
        else context.startService(intent);
    }

    public static void update(Context context, String modelName, String bytes, int progress) {
        Intent intent = new Intent(context, LiteRtModelDownloadService.class).setAction(ACTION_UPDATE)
            .putExtra("modelName", modelName).putExtra(EXTRA_BYTES, bytes).putExtra(EXTRA_PROGRESS, progress);
        try { context.startService(intent); } catch (RuntimeException ignored) {}
    }

    public static void stop(Context context) {
        context.stopService(new Intent(context, LiteRtModelDownloadService.class));
    }
}
