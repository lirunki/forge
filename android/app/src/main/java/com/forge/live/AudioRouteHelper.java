package com.forge.live;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.os.Build;
import android.speech.tts.TextToSpeech;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import java.util.Locale;

/**
 * Shared audio output routing for TTS + native playback.
 *
 * Routes:
 *   auto|default – system default (clear overrides)
 *   speaker      – force loudspeaker
 *   earpiece     – force earpiece / handset
 *   headset|wired – wired headset/headphones when present
 *   bluetooth|bt – Bluetooth SCO/A2DP communication device when present
 *   communication – voice-communication usage, device left to system
 */
public final class AudioRouteHelper {
    public static final String ROUTE_AUTO = "auto";
    public static final String ROUTE_DEFAULT = "default";
    public static final String ROUTE_SPEAKER = "speaker";
    public static final String ROUTE_EARPIECE = "earpiece";
    public static final String ROUTE_WIRED = "wired";
    public static final String ROUTE_BLUETOOTH = "bluetooth";
    public static final String ROUTE_COMMUNICATION = "communication";

    private static String stickyRoute = ROUTE_AUTO;
    private static String lastApplied = ROUTE_AUTO;
    private static String lastError = null;
    private static int savedMode = AudioManager.MODE_NORMAL;
    private static boolean savedSpeakerphone = false;
    private static boolean held = false;

    private AudioRouteHelper() {}

    public static synchronized String normalize(String raw) {
        if (raw == null) return ROUTE_AUTO;
        String r = raw.trim().toLowerCase(Locale.US);
        if (r.isEmpty() || "auto".equals(r) || "system".equals(r) || "none".equals(r)) return ROUTE_AUTO;
        if ("default".equals(r) || "media".equals(r) || "normal".equals(r)) return ROUTE_DEFAULT;
        if ("speaker".equals(r) || "loudspeaker".equals(r) || "speakerphone".equals(r) || "phone_speaker".equals(r)) {
            return ROUTE_SPEAKER;
        }
        if ("earpiece".equals(r) || "ear".equals(r) || "handset".equals(r) || "receiver".equals(r) || "phone".equals(r)) {
            return ROUTE_EARPIECE;
        }
        if ("wired".equals(r) || "headset".equals(r) || "headphones".equals(r) || "wired_headset".equals(r)
                || "wired_headphones".equals(r) || "headphone".equals(r)) {
            return ROUTE_WIRED;
        }
        if ("bluetooth".equals(r) || "bt".equals(r) || "sco".equals(r) || "a2dp".equals(r)
                || "bluetooth_sco".equals(r) || "bluetooth_a2dp".equals(r)) {
            return ROUTE_BLUETOOTH;
        }
        if ("communication".equals(r) || "voice".equals(r) || "call".equals(r)) {
            return ROUTE_COMMUNICATION;
        }
        return r;
    }

    public static synchronized String getStickyRoute() {
        return stickyRoute;
    }

    public static synchronized String getLastApplied() {
        return lastApplied;
    }

    public static synchronized String getLastError() {
        return lastError;
    }

    public static synchronized void setSticky(String route) {
        stickyRoute = normalize(route);
    }

    public static synchronized void clearSticky(Context ctx) {
        stickyRoute = ROUTE_AUTO;
        apply(ctx, ROUTE_AUTO);
    }

    /** Effective route for a call: explicit override, else sticky. */
    public static synchronized String resolve(String explicit) {
        if (explicit != null && !explicit.trim().isEmpty()) {
            return normalize(explicit);
        }
        return stickyRoute;
    }

    public static JSObject statusObject(Context ctx) {
        JSObject o = new JSObject();
        synchronized (AudioRouteHelper.class) {
            o.put("route", stickyRoute);
            o.put("sticky", stickyRoute);
            o.put("applied", lastApplied);
            if (lastError != null) o.put("error", lastError);
        }
        try {
            AudioManager am = am(ctx);
            if (am != null) {
                o.put("mode", modeName(am.getMode()));
                o.put("speakerphoneOn", am.isSpeakerphoneOn());
                try {
                    o.put("musicActive", am.isMusicActive());
                } catch (Exception ignored) {}
                if (Build.VERSION.SDK_INT >= 31) {
                    try {
                        AudioDeviceInfo cur = am.getCommunicationDevice();
                        if (cur != null) {
                            o.put("communicationDevice", deviceObject(cur));
                        }
                    } catch (Exception ignored) {}
                }
            }
        } catch (Exception e) {
            o.put("statusError", e.getMessage());
        }
        o.put("outputs", listOutputDevices(ctx));
        o.put("supportedRoutes", supportedRoutesArray());
        return o;
    }

    public static JSArray supportedRoutesArray() {
        JSArray a = new JSArray();
        a.put(ROUTE_AUTO);
        a.put(ROUTE_DEFAULT);
        a.put(ROUTE_SPEAKER);
        a.put(ROUTE_EARPIECE);
        a.put(ROUTE_WIRED);
        a.put(ROUTE_BLUETOOTH);
        a.put(ROUTE_COMMUNICATION);
        return a;
    }

    public static JSArray listOutputDevices(Context ctx) {
        JSArray out = new JSArray();
        try {
            AudioManager am = am(ctx);
            if (am == null || Build.VERSION.SDK_INT < 23) return out;
            AudioDeviceInfo[] devices = am.getDevices(AudioManager.GET_DEVICES_OUTPUTS);
            if (devices == null) return out;
            for (AudioDeviceInfo d : devices) {
                if (d != null) out.put(deviceObject(d));
            }
        } catch (Exception ignored) {}
        return out;
    }

    public static JSObject deviceObject(AudioDeviceInfo d) {
        JSObject o = new JSObject();
        o.put("id", d.getId());
        o.put("type", deviceTypeName(d.getType()));
        o.put("typeId", d.getType());
        try {
            CharSequence p = d.getProductName();
            if (p != null) o.put("name", p.toString());
        } catch (Exception ignored) {}
        if (Build.VERSION.SDK_INT >= 28) {
            try { o.put("address", d.getAddress()); } catch (Exception ignored) {}
        }
        o.put("isSink", d.isSink());
        o.put("isSource", d.isSource());
        o.put("routeHint", routeHintForType(d.getType()));
        return o;
    }

    public static String routeHintForType(int type) {
        switch (type) {
            case AudioDeviceInfo.TYPE_BUILTIN_SPEAKER:
            case AudioDeviceInfo.TYPE_BUILTIN_SPEAKER_SAFE:
                return ROUTE_SPEAKER;
            case AudioDeviceInfo.TYPE_BUILTIN_EARPIECE:
                return ROUTE_EARPIECE;
            case AudioDeviceInfo.TYPE_WIRED_HEADSET:
            case AudioDeviceInfo.TYPE_WIRED_HEADPHONES:
            case AudioDeviceInfo.TYPE_USB_HEADSET:
            case AudioDeviceInfo.TYPE_USB_DEVICE:
                return ROUTE_WIRED;
            case AudioDeviceInfo.TYPE_BLUETOOTH_SCO:
            case AudioDeviceInfo.TYPE_BLUETOOTH_A2DP:
            case AudioDeviceInfo.TYPE_BLE_HEADSET:
            case AudioDeviceInfo.TYPE_HEARING_AID:
                return ROUTE_BLUETOOTH;
            default:
                return ROUTE_DEFAULT;
        }
    }

    public static String deviceTypeName(int type) {
        switch (type) {
            case AudioDeviceInfo.TYPE_BUILTIN_EARPIECE: return "builtin_earpiece";
            case AudioDeviceInfo.TYPE_BUILTIN_SPEAKER: return "builtin_speaker";
            case AudioDeviceInfo.TYPE_BUILTIN_SPEAKER_SAFE: return "builtin_speaker_safe";
            case AudioDeviceInfo.TYPE_WIRED_HEADSET: return "wired_headset";
            case AudioDeviceInfo.TYPE_WIRED_HEADPHONES: return "wired_headphones";
            case AudioDeviceInfo.TYPE_BLUETOOTH_SCO: return "bluetooth_sco";
            case AudioDeviceInfo.TYPE_BLUETOOTH_A2DP: return "bluetooth_a2dp";
            case AudioDeviceInfo.TYPE_USB_DEVICE: return "usb_device";
            case AudioDeviceInfo.TYPE_USB_HEADSET: return "usb_headset";
            case AudioDeviceInfo.TYPE_HDMI: return "hdmi";
            case AudioDeviceInfo.TYPE_BLE_HEADSET: return "ble_headset";
            case AudioDeviceInfo.TYPE_HEARING_AID: return "hearing_aid";
            case AudioDeviceInfo.TYPE_REMOTE_SUBMIX: return "remote_submix";
            default: return "type_" + type;
        }
    }

    public static String modeName(int mode) {
        switch (mode) {
            case AudioManager.MODE_NORMAL: return "normal";
            case AudioManager.MODE_RINGTONE: return "ringtone";
            case AudioManager.MODE_IN_CALL: return "in_call";
            case AudioManager.MODE_IN_COMMUNICATION: return "in_communication";
            default: return "mode_" + mode;
        }
    }

    public static AudioAttributes attributesForRoute(String route) {
        String r = normalize(route);
        int usage;
        int content = AudioAttributes.CONTENT_TYPE_SPEECH;
        if (ROUTE_SPEAKER.equals(r) || ROUTE_EARPIECE.equals(r) || ROUTE_BLUETOOTH.equals(r)
                || ROUTE_COMMUNICATION.equals(r) || ROUTE_WIRED.equals(r)) {
            usage = AudioAttributes.USAGE_VOICE_COMMUNICATION;
        } else {
            // default / auto — behave like normal media/accessibility speech
            usage = AudioAttributes.USAGE_ASSISTANCE_ACCESSIBILITY;
            content = AudioAttributes.CONTENT_TYPE_SPEECH;
        }
        return new AudioAttributes.Builder()
                .setUsage(usage)
                .setContentType(content)
                .build();
    }

    /** Apply sticky or explicit route. Returns applied route name. */
    public static synchronized String apply(Context ctx, String route) {
        String r = normalize(route);
        lastError = null;
        AudioManager am = am(ctx);
        if (am == null) {
            lastError = "AudioManager unavailable";
            lastApplied = r;
            return r;
        }
        try {
            if (!held) {
                savedMode = am.getMode();
                savedSpeakerphone = am.isSpeakerphoneOn();
                held = true;
            }

            // Always clear previous communication device / sco first when changing
            clearCommunicationOverrides(am);

            if (ROUTE_AUTO.equals(r) || ROUTE_DEFAULT.equals(r)) {
                am.setMode(AudioManager.MODE_NORMAL);
                try { am.setSpeakerphoneOn(false); } catch (Exception ignored) {}
                lastApplied = r;
                return r;
            }

            if (ROUTE_COMMUNICATION.equals(r)) {
                am.setMode(AudioManager.MODE_IN_COMMUNICATION);
                lastApplied = r;
                return r;
            }

            if (ROUTE_SPEAKER.equals(r)) {
                am.setMode(AudioManager.MODE_IN_COMMUNICATION);
                if (Build.VERSION.SDK_INT >= 31) {
                    AudioDeviceInfo dev = findDevice(am, AudioDeviceInfo.TYPE_BUILTIN_SPEAKER,
                            AudioDeviceInfo.TYPE_BUILTIN_SPEAKER_SAFE);
                    if (dev != null && am.setCommunicationDevice(dev)) {
                        lastApplied = r;
                        return r;
                    }
                }
                am.setSpeakerphoneOn(true);
                lastApplied = r;
                return r;
            }

            if (ROUTE_EARPIECE.equals(r)) {
                am.setMode(AudioManager.MODE_IN_COMMUNICATION);
                try { am.setSpeakerphoneOn(false); } catch (Exception ignored) {}
                if (Build.VERSION.SDK_INT >= 31) {
                    AudioDeviceInfo dev = findDevice(am, AudioDeviceInfo.TYPE_BUILTIN_EARPIECE);
                    if (dev != null) {
                        am.setCommunicationDevice(dev);
                    }
                }
                lastApplied = r;
                return r;
            }

            if (ROUTE_WIRED.equals(r)) {
                am.setMode(AudioManager.MODE_IN_COMMUNICATION);
                try { am.setSpeakerphoneOn(false); } catch (Exception ignored) {}
                if (Build.VERSION.SDK_INT >= 31) {
                    AudioDeviceInfo dev = findDevice(am,
                            AudioDeviceInfo.TYPE_WIRED_HEADSET,
                            AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
                            AudioDeviceInfo.TYPE_USB_HEADSET,
                            AudioDeviceInfo.TYPE_USB_DEVICE);
                    if (dev != null && am.setCommunicationDevice(dev)) {
                        lastApplied = r;
                        return r;
                    }
                    lastError = "No wired headset device found; using earpiece-like route";
                } else {
                    lastError = "Wired route best-effort on API < 31";
                }
                lastApplied = r;
                return r;
            }

            if (ROUTE_BLUETOOTH.equals(r)) {
                am.setMode(AudioManager.MODE_IN_COMMUNICATION);
                try { am.setSpeakerphoneOn(false); } catch (Exception ignored) {}
                boolean ok = false;
                if (Build.VERSION.SDK_INT >= 31) {
                    AudioDeviceInfo dev = findDevice(am,
                            AudioDeviceInfo.TYPE_BLUETOOTH_SCO,
                            AudioDeviceInfo.TYPE_BLE_HEADSET,
                            AudioDeviceInfo.TYPE_BLUETOOTH_A2DP,
                            AudioDeviceInfo.TYPE_HEARING_AID);
                    if (dev != null && am.setCommunicationDevice(dev)) {
                        ok = true;
                    }
                }
                if (!ok) {
                    try {
                        am.startBluetoothSco();
                        am.setBluetoothScoOn(true);
                        ok = true;
                    } catch (Exception e) {
                        lastError = "Bluetooth SCO failed: " + e.getMessage();
                    }
                }
                if (!ok && lastError == null) {
                    lastError = "No Bluetooth audio device available";
                }
                lastApplied = r;
                return r;
            }

            // Unknown → treat as default
            am.setMode(AudioManager.MODE_NORMAL);
            lastApplied = ROUTE_DEFAULT;
            lastError = "Unknown route '" + r + "', using default";
            return ROUTE_DEFAULT;
        } catch (Exception e) {
            lastError = e.getMessage();
            lastApplied = r;
            return r;
        }
    }

    public static synchronized void restore(Context ctx) {
        AudioManager am = am(ctx);
        if (am == null) return;
        try {
            clearCommunicationOverrides(am);
            if (held) {
                try { am.setMode(savedMode); } catch (Exception ignored) {}
                try { am.setSpeakerphoneOn(savedSpeakerphone); } catch (Exception ignored) {}
            } else {
                try { am.setMode(AudioManager.MODE_NORMAL); } catch (Exception ignored) {}
                try { am.setSpeakerphoneOn(false); } catch (Exception ignored) {}
            }
        } catch (Exception ignored) {
        } finally {
            held = false;
            lastApplied = stickyRoute;
        }
        // Re-apply sticky if not auto
        if (!ROUTE_AUTO.equals(stickyRoute) && !ROUTE_DEFAULT.equals(stickyRoute)) {
            apply(ctx, stickyRoute);
        } else {
            lastApplied = stickyRoute;
        }
    }

    /** Apply TTS audio attributes for route (API 21+). */
    public static void applyToTts(TextToSpeech tts, String route) {
        if (tts == null) return;
        try {
            if (Build.VERSION.SDK_INT >= 21) {
                tts.setAudioAttributes(attributesForRoute(route));
            }
        } catch (Exception ignored) {}
    }

    public static AudioDeviceInfo findPreferredDevice(Context ctx, String route) {
        AudioManager am = am(ctx);
        if (am == null || Build.VERSION.SDK_INT < 23) return null;
        String r = normalize(route);
        if (ROUTE_SPEAKER.equals(r)) {
            return findDevice(am, AudioDeviceInfo.TYPE_BUILTIN_SPEAKER, AudioDeviceInfo.TYPE_BUILTIN_SPEAKER_SAFE);
        }
        if (ROUTE_EARPIECE.equals(r)) {
            return findDevice(am, AudioDeviceInfo.TYPE_BUILTIN_EARPIECE);
        }
        if (ROUTE_WIRED.equals(r)) {
            return findDevice(am,
                    AudioDeviceInfo.TYPE_WIRED_HEADSET,
                    AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
                    AudioDeviceInfo.TYPE_USB_HEADSET,
                    AudioDeviceInfo.TYPE_USB_DEVICE);
        }
        if (ROUTE_BLUETOOTH.equals(r)) {
            return findDevice(am,
                    AudioDeviceInfo.TYPE_BLUETOOTH_A2DP,
                    AudioDeviceInfo.TYPE_BLUETOOTH_SCO,
                    AudioDeviceInfo.TYPE_BLE_HEADSET,
                    AudioDeviceInfo.TYPE_HEARING_AID);
        }
        return null;
    }

    private static void clearCommunicationOverrides(AudioManager am) {
        try {
            if (Build.VERSION.SDK_INT >= 31) {
                am.clearCommunicationDevice();
            }
        } catch (Exception ignored) {}
        try {
            if (am.isBluetoothScoOn()) {
                am.setBluetoothScoOn(false);
                am.stopBluetoothSco();
            }
        } catch (Exception ignored) {}
    }

    private static AudioDeviceInfo findDevice(AudioManager am, int... types) {
        if (am == null || Build.VERSION.SDK_INT < 23 || types == null) return null;
        try {
            AudioDeviceInfo[] devices = am.getDevices(AudioManager.GET_DEVICES_OUTPUTS);
            if (devices == null) return null;
            for (int type : types) {
                for (AudioDeviceInfo d : devices) {
                    if (d != null && d.isSink() && d.getType() == type) return d;
                }
            }
        } catch (Exception ignored) {}
        return null;
    }

    private static AudioManager am(Context ctx) {
        if (ctx == null) return null;
        try {
            return (AudioManager) ctx.getApplicationContext().getSystemService(Context.AUDIO_SERVICE);
        } catch (Exception e) {
            return null;
        }
    }
}
