package com.forge.live;

import android.media.AudioAttributes;
import android.media.AudioDeviceInfo;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.File;
import java.io.FileOutputStream;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * ForgeHost audio output routing + routed native playback.
 *
 * Mini-app surface (via host):
 *   audio.getRoute / setRoute / clearRoute / listOutputs / play
 */
@CapacitorPlugin(name = "AudioRouteBridge")
public class AudioRouteBridgePlugin extends Plugin {
    private final Handler main = new Handler(Looper.getMainLooper());
    private MediaPlayer player;
    private PluginCall playCall;
    private File playTemp;
    private final AtomicBoolean playing = new AtomicBoolean(false);

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject o = AudioRouteHelper.statusObject(getContext());
        o.put("available", true);
        o.put("routing", true);
        o.put("play", true);
        o.put("api31CommunicationDevice", Build.VERSION.SDK_INT >= 31);
        call.resolve(o);
    }

    @PluginMethod
    public void getRoute(PluginCall call) {
        call.resolve(AudioRouteHelper.statusObject(getContext()));
    }

    @PluginMethod
    public void getStatus(PluginCall call) {
        call.resolve(AudioRouteHelper.statusObject(getContext()));
    }

    @PluginMethod
    public void listOutputs(PluginCall call) {
        JSObject o = new JSObject();
        o.put("outputs", AudioRouteHelper.listOutputDevices(getContext()));
        o.put("supportedRoutes", AudioRouteHelper.supportedRoutesArray());
        o.put("route", AudioRouteHelper.getStickyRoute());
        o.put("applied", AudioRouteHelper.getLastApplied());
        call.resolve(o);
    }

    /**
     * setRoute({ route, sticky?: true })
     * sticky default true — remains until clearRoute / setRoute(auto).
     */
    @PluginMethod
    public void setRoute(PluginCall call) {
        String route = call.getString("route", null);
        if (route == null) route = call.getString("output", null);
        if (route == null) route = call.getString("device", null);
        if (route == null || route.trim().isEmpty()) {
            call.reject("route is required (auto|default|speaker|earpiece|wired|bluetooth|communication)");
            return;
        }
        boolean sticky = !Boolean.FALSE.equals(call.getBoolean("sticky", true));
        String normalized = AudioRouteHelper.normalize(route);
        if (sticky) {
            AudioRouteHelper.setSticky(normalized);
        }
        String applied = AudioRouteHelper.apply(getContext(), normalized);
        JSObject o = AudioRouteHelper.statusObject(getContext());
        o.put("ok", true);
        o.put("requested", normalized);
        o.put("applied", applied);
        o.put("stickySet", sticky);
        if (AudioRouteHelper.getLastError() != null) {
            o.put("warning", AudioRouteHelper.getLastError());
        }
        call.resolve(o);
    }

    @PluginMethod
    public void clearRoute(PluginCall call) {
        AudioRouteHelper.clearSticky(getContext());
        JSObject o = AudioRouteHelper.statusObject(getContext());
        o.put("ok", true);
        o.put("cleared", true);
        call.resolve(o);
    }

    /**
     * play({ dataUrl|base64, mime?, route?, wait?:true, usage? })
     * Plays audio through native MediaPlayer with optional forced route.
     */
    @PluginMethod
    public void play(final PluginCall call) {
        final String dataUrl = call.getString("dataUrl", call.getString("dataURL", null));
        String base64 = call.getString("base64", null);
        String mime = call.getString("mime", null);
        final String routeExplicit = call.getString("route", call.getString("output", null));
        final boolean wait = !Boolean.FALSE.equals(call.getBoolean("wait", true));
        final String route = AudioRouteHelper.resolve(routeExplicit);

        if ((base64 == null || base64.isEmpty()) && dataUrl != null && dataUrl.contains("base64,")) {
            int idx = dataUrl.indexOf("base64,");
            base64 = dataUrl.substring(idx + 7);
            if (mime == null || mime.isEmpty()) {
                try {
                    int c = dataUrl.indexOf(':');
                    int s = dataUrl.indexOf(';');
                    if (c >= 0 && s > c) mime = dataUrl.substring(c + 1, s);
                } catch (Exception ignored) {}
            }
        }
        if (base64 == null || base64.isEmpty()) {
            call.reject("play requires dataUrl or base64 audio");
            return;
        }
        // strip whitespace/newlines
        base64 = base64.replaceAll("\\s", "");
        final byte[] bytes;
        try {
            bytes = Base64.decode(base64, Base64.DEFAULT);
        } catch (Exception e) {
            call.reject("Invalid base64 audio: " + e.getMessage(), e);
            return;
        }
        if (bytes == null || bytes.length == 0) {
            call.reject("Empty audio payload");
            return;
        }
        if (mime == null || mime.isEmpty()) mime = "audio/mpeg";
        final String ext = extForMime(mime);

        main.post(new Runnable() {
            @Override
            public void run() {
                try {
                    stopPlayerInternal(false);
                    AudioRouteHelper.apply(getContext(), route);

                    playTemp = File.createTempFile("forge_audio_", ext, getContext().getCacheDir());
                    FileOutputStream fos = new FileOutputStream(playTemp);
                    fos.write(bytes);
                    fos.close();

                    MediaPlayer mp = new MediaPlayer();
                    player = mp;
                    AudioAttributes attrs = AudioRouteHelper.attributesForRoute(route);
                    mp.setAudioAttributes(attrs);
                    if (Build.VERSION.SDK_INT >= 28) {
                        AudioDeviceInfo pref = AudioRouteHelper.findPreferredDevice(getContext(), route);
                        if (pref != null) {
                            try { mp.setPreferredDevice(pref); } catch (Exception ignored) {}
                        }
                    }
                    mp.setDataSource(playTemp.getAbsolutePath());
                    mp.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                        @Override
                        public void onCompletion(MediaPlayer mediaPlayer) {
                            finishPlay(true, null, route);
                        }
                    });
                    mp.setOnErrorListener(new MediaPlayer.OnErrorListener() {
                        @Override
                        public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
                            finishPlay(false, "MediaPlayer error what=" + what + " extra=" + extra, route);
                            return true;
                        }
                    });
                    mp.prepare();
                    playing.set(true);
                    if (wait) {
                        call.setKeepAlive(true);
                        playCall = call;
                    }
                    mp.start();
                    if (!wait) {
                        JSObject o = new JSObject();
                        o.put("ok", true);
                        o.put("started", true);
                        o.put("route", route);
                        o.put("bytes", bytes.length);
                        o.put("async", true);
                        call.resolve(o);
                    }
                } catch (Exception e) {
                    playing.set(false);
                    cleanupTemp();
                    call.reject("audio.play failed: " + e.getMessage(), e);
                }
            }
        });
    }

    @PluginMethod
    public void stop(PluginCall call) {
        main.post(new Runnable() {
            @Override
            public void run() {
                stopPlayerInternal(true);
                JSObject o = new JSObject();
                o.put("stopped", true);
                call.resolve(o);
            }
        });
    }

    @PluginMethod
    public void isPlaying(PluginCall call) {
        JSObject o = new JSObject();
        o.put("playing", playing.get());
        call.resolve(o);
    }

    private void finishPlay(final boolean ok, final String err, final String route) {
        main.post(new Runnable() {
            @Override
            public void run() {
                PluginCall c = playCall;
                playCall = null;
                playing.set(false);
                try {
                    if (player != null) {
                        try { player.reset(); } catch (Exception ignored) {}
                        try { player.release(); } catch (Exception ignored) {}
                        player = null;
                    }
                } catch (Exception ignored) {}
                cleanupTemp();
                // Restore sticky route after one-shot play
                try { AudioRouteHelper.restore(getContext()); } catch (Exception ignored) {}
                if (c != null) {
                    if (ok) {
                        JSObject o = new JSObject();
                        o.put("ok", true);
                        o.put("played", true);
                        o.put("route", route);
                        if (AudioRouteHelper.getLastError() != null) {
                            o.put("warning", AudioRouteHelper.getLastError());
                        }
                        c.resolve(o);
                    } else {
                        c.reject(err != null ? err : "Playback failed");
                    }
                }
            }
        });
    }

    private void stopPlayerInternal(boolean resolvePlay) {
        playing.set(false);
        try {
            if (player != null) {
                try { if (player.isPlaying()) player.stop(); } catch (Exception ignored) {}
                try { player.reset(); } catch (Exception ignored) {}
                try { player.release(); } catch (Exception ignored) {}
                player = null;
            }
        } catch (Exception ignored) {}
        cleanupTemp();
        if (resolvePlay && playCall != null) {
            PluginCall c = playCall;
            playCall = null;
            JSObject o = new JSObject();
            o.put("ok", true);
            o.put("played", false);
            o.put("stopped", true);
            c.resolve(o);
        }
        try { AudioRouteHelper.restore(getContext()); } catch (Exception ignored) {}
    }

    private void cleanupTemp() {
        if (playTemp != null) {
            try { //noinspection ResultOfMethodCallIgnored
                playTemp.delete(); } catch (Exception ignored) {}
            playTemp = null;
        }
    }

    private static String extForMime(String mime) {
        if (mime == null) return ".bin";
        String m = mime.toLowerCase();
        if (m.contains("wav")) return ".wav";
        if (m.contains("mpeg") || m.contains("mp3")) return ".mp3";
        if (m.contains("mp4") || m.contains("m4a") || m.contains("aac")) return ".m4a";
        if (m.contains("ogg") || m.contains("opus")) return ".ogg";
        if (m.contains("webm")) return ".webm";
        return ".bin";
    }

    @Override
    protected void handleOnDestroy() {
        stopPlayerInternal(true);
        try { AudioRouteHelper.clearSticky(getContext()); } catch (Exception ignored) {}
        super.handleOnDestroy();
    }
}
