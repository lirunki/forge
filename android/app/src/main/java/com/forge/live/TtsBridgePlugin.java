package com.forge.live;

import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.speech.tts.Voice;
import androidx.documentfile.provider.DocumentFile;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@CapacitorPlugin(name = "TtsBridge")
public class TtsBridgePlugin extends Plugin implements TextToSpeech.OnInitListener {
    private TextToSpeech tts;
    private final Handler main = new Handler(Looper.getMainLooper());
    private boolean ready = false;
    private boolean initStarted = false;
    private String lastError = null;
    private final List<Runnable> whenReadyQueue = new ArrayList();
    private PluginCall speakingCall = null;
    private PluginCall synthesisCall = null;
    private File synthesisFile = null;
    private File synthesisTempFile = null;
    private String synthesisFolderTreeUri = null;

    private void enqueueWhenReady(final PluginCall call, final Runnable action) {
        if (this.ready && this.tts != null) {
            this.main.post(action);
        } else {
            this.whenReadyQueue.add(new Runnable() {
                @Override // java.lang.Runnable
                public final void run() {
                    TtsBridgePlugin.this.lambda$enqueueWhenReady$0(call, action);
                }
            });
            startInitIfNeeded();
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$enqueueWhenReady$0(PluginCall call, Runnable action) {
        if (!this.ready || this.tts == null) {
            String str = this.lastError;
            if (str == null) {
                str = "TTS not available";
            }
            call.reject(str);
            return;
        }
        action.run();
    }

    private void startInitIfNeeded() {
        if (this.initStarted) {
            return;
        }
        this.initStarted = true;
        this.main.post(new Runnable() {
            @Override // java.lang.Runnable
            public final void run() {
                TtsBridgePlugin.this.lambda$startInitIfNeeded$1();
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$startInitIfNeeded$1() {
        try {
            this.tts = new TextToSpeech(getContext().getApplicationContext(), this);
        } catch (Exception e) {
            this.lastError = "TTS init failed: " + e.getMessage();
            this.ready = false;
            flushQueue();
        }
    }

    @Override // android.speech.tts.TextToSpeech.OnInitListener
    public void onInit(int status) {
        TextToSpeech textToSpeech;
        if (status == 0 && (textToSpeech = this.tts) != null) {
            this.ready = true;
            this.lastError = null;
            try {
                textToSpeech.setOnUtteranceProgressListener(new UtteranceProgressListener() {
                    @Override // android.speech.tts.UtteranceProgressListener
                    public void onStart(String utteranceId) {
                    }

                    @Override // android.speech.tts.UtteranceProgressListener
                    public void onDone(String utteranceId) {
                        if (TtsBridgePlugin.this.synthesisCall != null) {
                            TtsBridgePlugin.this.completeSynthesis(true, null);
                        } else {
                            TtsBridgePlugin.this.completeSpeaking(true, null);
                        }
                    }

                    @Override // android.speech.tts.UtteranceProgressListener
                    public void onError(String utteranceId) {
                        if (TtsBridgePlugin.this.synthesisCall != null) {
                            TtsBridgePlugin.this.completeSynthesis(false, "TTS utterance error");
                        } else {
                            TtsBridgePlugin.this.completeSpeaking(false, "TTS utterance error");
                        }
                    }

                    @Override // android.speech.tts.UtteranceProgressListener
                    public void onError(String utteranceId, int errorCode) {
                        if (TtsBridgePlugin.this.synthesisCall != null) {
                            TtsBridgePlugin.this.completeSynthesis(false, "TTS error code " + errorCode);
                        } else {
                            TtsBridgePlugin.this.completeSpeaking(false, "TTS error code " + errorCode);
                        }
                    }
                });
            } catch (Exception e) {
            }
            try {
                int r = this.tts.setLanguage(Locale.getDefault());
                if (r == -1 || r == -2) {
                    this.tts.setLanguage(Locale.US);
                }
            } catch (Exception e2) {
            }
        } else {
            this.ready = false;
            this.lastError = "TTS engine failed to initialize (status=" + status + "). Install a TTS engine in system settings.";
        }
        flushQueue();
    }

    private void flushQueue() {
        List<Runnable> copy = new ArrayList<>(this.whenReadyQueue);
        this.whenReadyQueue.clear();
        for (Runnable r : copy) {
            try {
                this.main.post(r);
            } catch (Exception e) {
            }
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void completeSpeaking(final boolean ok, final String err) {
        this.main.post(new Runnable() {
            @Override // java.lang.Runnable
            public final void run() {
                TtsBridgePlugin.this.lambda$completeSpeaking$2(ok, err);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$completeSpeaking$2(boolean ok, String err) {
        if (this.speakingCall == null) {
            return;
        }
        PluginCall c = this.speakingCall;
        this.speakingCall = null;
        try {
            AudioRouteHelper.restore(getContext());
        } catch (Exception ignored) {
        }
        if (ok) {
            JSObject ret = new JSObject();
            ret.put("spoken", true);
            ret.put("route", AudioRouteHelper.getLastApplied());
            c.resolve(ret);
            return;
        }
        c.reject(err != null ? err : "TTS failed");
    }

    private void completeSynthesis(final boolean ok, final String err) {
        this.main.post(new Runnable() {
            @Override public void run() {
                PluginCall c = synthesisCall;
                synthesisCall = null;
                File f = synthesisFile;
                File tmp = synthesisTempFile;
                String folderTree = synthesisFolderTreeUri;
                synthesisFile = null;
                synthesisTempFile = null;
                synthesisFolderTreeUri = null;
                if (!ok) { if (tmp != null) try { tmp.delete(); } catch (Exception ignored) {} if (c != null) c.reject(err != null ? err : "TTS synthesis failed"); return; }
                try {
                    if (tmp == null || !tmp.isFile() || tmp.length() == 0) throw new Exception("TTS produced no audio file");
                    if (f == null || f.getParentFile() == null || (!f.getParentFile().exists() && !f.getParentFile().mkdirs())) throw new Exception("Cannot create TTS destination");
                    try (FileInputStream in = new FileInputStream(tmp); FileOutputStream out = new FileOutputStream(f)) {
                        byte[] buf = new byte[32768]; int n; while ((n = in.read(buf)) >= 0) if (n > 0) out.write(buf, 0, n);
                    }
                    tmp.delete();
                    if (!f.isFile() || f.length() == 0) throw new Exception("TTS destination is empty");
                    if (folderTree != null && !folderTree.isEmpty()) {
                        DocumentFile root = DocumentFile.fromTreeUri(getContext(), Uri.parse(folderTree));
                        if (root == null || !root.canWrite()) throw new Exception("selected staging folder is no longer available");
                        DocumentFile dir = "ForgeStaging".equals(root.getName()) ? root : root.findFile("ForgeStaging");
                        if (dir != null && !dir.isDirectory()) dir = null;
                        if (dir == null) dir = root.createDirectory("ForgeStaging");
                        if (dir == null || !dir.canWrite()) throw new Exception("Could not open ForgeStaging inside selected folder");
                        DocumentFile dest = dir.createFile("audio/wav", f.getName());
                        if (dest == null) throw new Exception("cannot create TTS staging file");
                        try (FileInputStream in = new FileInputStream(f); OutputStream out = getContext().getContentResolver().openOutputStream(dest.getUri(), "w")) {
                            if (out == null) throw new Exception("cannot open TTS staging file");
                            byte[] buf = new byte[32768]; int n; while ((n = in.read(buf)) >= 0) if (n > 0) out.write(buf, 0, n);
                        }
                        try { f.delete(); } catch (Exception ignored) {}
                        if (c == null) return;
                        JSObject o = new JSObject(); o.put("ok", true); o.put("path", dest.getUri().toString()); o.put("uri", dest.getUri().toString()); o.put("size", dest.length()); c.resolve(o); return;
                    }
                } catch (Exception e) { if (tmp != null) try { tmp.delete(); } catch (Exception ignored) {} if (c != null) c.reject("TTS file export failed: " + e.getMessage(), e); return; }
                if (c == null) return;
                JSObject o = new JSObject(); o.put("ok", true); o.put("path", f.getAbsolutePath()); o.put("size", f.length()); c.resolve(o);
            }
        });
    }

    @PluginMethod
    public void synthesizeToFile(final PluginCall call) {
        final String text = call.getString("text", "");
        final String rawPath = call.getString("path", "");
        if (text == null || text.trim().isEmpty()) { call.reject("text is required"); return; }
        try {
            File cache = new File(getContext().getCacheDir(), "forge_staging").getCanonicalFile();
            if (!cache.exists() && !cache.mkdirs()) throw new Exception("cannot create internal staging cache");
            String treeUri = getContext().getApplicationContext().getSharedPreferences("forge_staging_v1", android.content.Context.MODE_PRIVATE).getString("treeUri", null);
            final String exportTree = (rawPath == null || rawPath.isEmpty()) && treeUri != null && !treeUri.isEmpty() ? treeUri : null;
            File target = rawPath == null || rawPath.isEmpty()
                    ? new File(cache, "tts_" + System.currentTimeMillis() + ".wav").getCanonicalFile()
                    : new File(rawPath).getCanonicalFile();
            File legacyCache = new File(getContext().getCacheDir(), "forge_picks").getCanonicalFile();
            if (!(target.getPath().startsWith(cache.getPath() + File.separator) || target.getPath().startsWith(legacyCache.getPath() + File.separator))) { call.reject("path not allowed"); return; }
            File parent = target.getParentFile(); if (parent != null && !parent.exists()) parent.mkdirs();
            final File tempTarget = new File(getContext().getCacheDir(), "forge_tts_" + UUID.randomUUID().toString() + ".wav");
            final String lang = call.getString("lang", null), voiceName = call.getString("voice", null);
            final float rate = Math.max(0.1f, Math.min(3.0f, call.getDouble("rate", Double.valueOf(1.0)).floatValue()));
            final float pitch = Math.max(0.1f, Math.min(2.0f, call.getDouble("pitch", Double.valueOf(1.0)).floatValue()));
            enqueueWhenReady(call, new Runnable() { @Override public void run() {
                try {
                    if (lang != null && !lang.isEmpty()) tts.setLanguage(Locale.forLanguageTag(lang));
                    if (voiceName != null && !voiceName.isEmpty()) for (Voice v : tts.getVoices()) if (voiceName.equals(v.getName())) { tts.setVoice(v); break; }
                    tts.setSpeechRate(rate); tts.setPitch(pitch); synthesisCall = call; synthesisFile = target; synthesisTempFile = tempTarget; synthesisFolderTreeUri = exportTree;
                    Bundle b = new Bundle(); String id = UUID.randomUUID().toString();
                    if (tts.synthesizeToFile(text, b, tempTarget, id) == -1) { synthesisCall = null; synthesisFile = null; synthesisTempFile = null; synthesisFolderTreeUri = null; call.reject("TTS synthesis failed to start"); }
                } catch (Exception e) { synthesisCall = null; synthesisFile = null; synthesisTempFile = null; synthesisFolderTreeUri = null; call.reject("TTS synthesis failed: " + e.getMessage(), e); }
            }});
        } catch (Exception e) { call.reject("invalid output path: " + e.getMessage(), e); }
    }

    private JSObject statusObject() {
        JSObject o = new JSObject();
        o.put("ready", this.ready);
        o.put("available", this.ready);
        String str = this.lastError;
        if (str != null) {
            o.put("error", str);
        }
        TextToSpeech textToSpeech = this.tts;
        if (textToSpeech != null && this.ready) {
            try {
                Locale lang = textToSpeech.getLanguage();
                if (lang != null) {
                    o.put("language", lang.toLanguageTag());
                }
            } catch (Exception e) {
            }
            try {
                o.put("speaking", this.tts.isSpeaking());
            } catch (Exception e2) {
                o.put("speaking", false);
            }
        } else {
            o.put("speaking", false);
        }
        try {
            o.put("route", AudioRouteHelper.getStickyRoute());
            o.put("routeApplied", AudioRouteHelper.getLastApplied());
            o.put("supportedRoutes", AudioRouteHelper.supportedRoutesArray());
        } catch (Exception ignored) {
        }
        return o;
    }

    @PluginMethod
    public void isAvailable(final PluginCall call) {
        if (this.ready) {
            call.resolve(statusObject());
        } else {
            enqueueWhenReady(call, new Runnable() {
                @Override // java.lang.Runnable
                public final void run() {
                    TtsBridgePlugin.this.lambda$isAvailable$3(call);
                }
            });
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$isAvailable$3(PluginCall call) {
        call.resolve(statusObject());
    }

    @PluginMethod
    public void getStatus(final PluginCall call) {
        if (this.ready) {
            call.resolve(statusObject());
        } else {
            enqueueWhenReady(call, new Runnable() {
                @Override // java.lang.Runnable
                public final void run() {
                    TtsBridgePlugin.this.lambda$getStatus$4(call);
                }
            });
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$getStatus$4(PluginCall call) {
        call.resolve(statusObject());
    }

    @PluginMethod
    public void getLanguages(final PluginCall call) {
        enqueueWhenReady(call, new Runnable() {
            @Override // java.lang.Runnable
            public final void run() {
                TtsBridgePlugin.this.lambda$getLanguages$5(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$getLanguages$5(PluginCall call) {
        JSArray langs = new JSArray();
        try {
            Set<Locale> set = this.tts.getAvailableLanguages();
            if (set != null) {
                for (Locale l : set) {
                    if (l != null) {
                        langs.put(l.toLanguageTag());
                    }
                }
            }
        } catch (Exception e) {
            langs.put(Locale.getDefault().toLanguageTag());
            langs.put("en-US");
        }
        JSObject ret = new JSObject();
        ret.put("languages", (Object) langs);
        call.resolve(ret);
    }

    @PluginMethod
    public void getVoices(final PluginCall call) {
        enqueueWhenReady(call, new Runnable() {
            @Override // java.lang.Runnable
            public final void run() {
                TtsBridgePlugin.this.lambda$getVoices$6(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$getVoices$6(PluginCall pluginCall) {
        JSArray voices = new JSArray();
        try {
            Set<Voice> set = this.tts.getVoices();
            if (set != null) {
                for (Voice v : set) {
                    if (v != null) {
                        JSObject o = new JSObject();
                        o.put("name", v.getName());
                        o.put("locale", v.getLocale() != null ? v.getLocale().toLanguageTag() : "");
                        o.put("quality", v.getQuality());
                        o.put("latency", v.getLatency());
                        o.put("networkConnectionRequired", v.isNetworkConnectionRequired());
                        voices.put(o);
                    }
                }
            }
            JSObject ret = new JSObject();
            ret.put("voices", (Object) voices);
            pluginCall.resolve(ret);
        } catch (Exception e) {
            pluginCall.reject("getVoices failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void setLanguage(final PluginCall call) {
        final String lang = call.getString("lang", "");
        if (lang == null || lang.isEmpty()) {
            call.reject("lang required (e.g. en-US)");
        } else {
            enqueueWhenReady(call, new Runnable() {
                @Override // java.lang.Runnable
                public final void run() {
                    TtsBridgePlugin.this.lambda$setLanguage$7(lang, call);
                }
            });
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$setLanguage$7(String lang, PluginCall call) {
        try {
            int r = this.tts.setLanguage(Locale.forLanguageTag(lang));
            boolean ok = (r == -1 || r == -2) ? false : true;
            JSObject ret = new JSObject();
            ret.put("ok", ok);
            ret.put("code", r);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("setLanguage failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void speak(final PluginCall call) {
        String text = call.getString("text", "");
        if (text != null && !text.trim().isEmpty()) {
            if (text.length() > 4000) {
                text = text.substring(0, 4000);
            }
            final String text2 = text;
            final String lang = call.getString("lang", null);
            final String voiceName = call.getString("voice", null);
            final double rateD = call.getDouble("rate", Double.valueOf(1.0d)).doubleValue();
            final double pitchD = call.getDouble("pitch", Double.valueOf(1.0d)).doubleValue();
            final boolean queue = Boolean.TRUE.equals(call.getBoolean("queue", false));
            final boolean wait = !Boolean.FALSE.equals(call.getBoolean("wait", true));
            String routeRaw = call.getString("route", null);
            if (routeRaw == null) {
                routeRaw = call.getString("output", null);
            }
            final String route = AudioRouteHelper.resolve(routeRaw);
            enqueueWhenReady(call, new Runnable() {
                @Override // java.lang.Runnable
                public final void run() {
                    TtsBridgePlugin.this.lambda$speak$8(lang, voiceName, rateD, pitchD, queue, call, wait, text2, route);
                }
            });
            return;
        }
        call.reject("text is required");
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* JADX WARN: Code restructure failed: missing block: B:18:0x0050, code lost:
    
        r16.tts.setVoice(r6);
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    public /* synthetic */ void lambda$speak$8(String str, String str2, double d, double d2, boolean z, PluginCall pluginCall, boolean z2, String str3, String route) {
        try {
            String r = route != null ? route : AudioRouteHelper.ROUTE_AUTO;
            AudioRouteHelper.apply(getContext(), r);
            AudioRouteHelper.applyToTts(this.tts, r);
        } catch (Exception ignored) {
        }
        Exception e;
        PluginCall pluginCall2;
        if (str != null) {
            try {
                if (!str.isEmpty()) {
                    try {
                        this.tts.setLanguage(Locale.forLanguageTag(str));
                    } catch (Exception e2) {
                    }
                }
            } catch (Exception e3) {                this.speakingCall = null;
                pluginCall.reject("speak failed: " + e3.getMessage(), e3);
            }
        }
        if (str2 != null) {
            if (!str2.isEmpty()) {
                try {
                    Set<Voice> voices = this.tts.getVoices();
                    if (voices != null) {
                        Iterator<Voice> it = voices.iterator();
                        while (true) {
                            if (!it.hasNext()) {
                                break;
                            }
                            Voice next = it.next();
                            if (next != null && str2.equals(next.getName())) {
                                break;
                            }
                        }
                    }
                } catch (Exception e4) {
                }
            }
        }
        float f = (float) d;
        if (f < 0.1f) {
            f = 0.1f;
        }
        if (f > 3.0f) {
            f = 3.0f;
        }
        float f2 = (float) d2;
        if (f2 < 0.1f) {
            f2 = 0.1f;
        }
        if (f2 > 2.0f) {
            f2 = 2.0f;
        }
        try {
            this.tts.setSpeechRate(f);
            this.tts.setPitch(f2);
            if (!z && (pluginCall2 = this.speakingCall) != null && pluginCall2 != pluginCall) {
                this.speakingCall = null;
                JSObject jSObject = new JSObject();
                jSObject.put("spoken", false);
                jSObject.put("interrupted", true);
                pluginCall2.resolve(jSObject);
            }
            String uuid = UUID.randomUUID().toString();
            if (z2) {
                this.speakingCall = pluginCall;
            }
            try {
                if (this.tts.speak(str3, z ? 1 : 0, new Bundle(), uuid) == -1) {
                    this.speakingCall = null;
                    try { AudioRouteHelper.restore(getContext()); } catch (Exception ignored) {}
                    pluginCall.reject("TTS speak() returned ERROR");
                } else if (!z2) {
                    JSObject jSObject2 = new JSObject();
                    jSObject2.put("started", true);
                    jSObject2.put("route", AudioRouteHelper.getLastApplied());
                    pluginCall.resolve(jSObject2);
                    try { AudioRouteHelper.restore(getContext()); } catch (Exception ignored) {}
                }
            } catch (Exception e5) {
                this.speakingCall = null;
                try { AudioRouteHelper.restore(getContext()); } catch (Exception ignored) {}
                pluginCall.reject("speak failed: " + e5.getMessage(), e5);
            }
        } catch (Exception e6) {
            this.speakingCall = null;
            try { AudioRouteHelper.restore(getContext()); } catch (Exception ignored) {}
            pluginCall.reject("speak failed: " + e6.getMessage(), e6);
        }
    }

    @PluginMethod
    public void stop(final PluginCall call) {
        enqueueWhenReady(call, new Runnable() {
            @Override // java.lang.Runnable
            public final void run() {
                TtsBridgePlugin.this.lambda$stop$9(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$stop$9(PluginCall call) {
        try {
            this.tts.stop();
            PluginCall c = this.speakingCall;
            if (c != null) {
                this.speakingCall = null;
                JSObject r = new JSObject();
                r.put("spoken", false);
                r.put("stopped", true);
                c.resolve(r);
            }
            try { AudioRouteHelper.restore(getContext()); } catch (Exception ignored) {}
            JSObject ret = new JSObject();
            ret.put("stopped", true);
            call.resolve(ret);
        } catch (Exception e) {
            try { AudioRouteHelper.restore(getContext()); } catch (Exception ignored) {}
            call.reject("stop failed: " + e.getMessage(), e);
        }
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnDestroy() {
        TextToSpeech textToSpeech = this.tts;
        if (textToSpeech != null) {
            try {
                textToSpeech.stop();
            } catch (Exception e) {
            }
            try {
                this.tts.shutdown();
            } catch (Exception e2) {
            }
            this.tts = null;
        }
        this.ready = false;
        this.initStarted = false;
        this.speakingCall = null;
        this.whenReadyQueue.clear();
        super.handleOnDestroy();
    }
}
