package com.forge.live;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.speech.tts.Voice;
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
                        TtsBridgePlugin.this.completeSpeaking(true, null);
                    }

                    @Override // android.speech.tts.UtteranceProgressListener
                    public void onError(String utteranceId) {
                        TtsBridgePlugin.this.completeSpeaking(false, "TTS utterance error");
                    }

                    @Override // android.speech.tts.UtteranceProgressListener
                    public void onError(String utteranceId, int errorCode) {
                        TtsBridgePlugin.this.completeSpeaking(false, "TTS error code " + errorCode);
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
        if (ok) {
            JSObject ret = new JSObject();
            ret.put("spoken", true);
            c.resolve(ret);
            return;
        }
        c.reject(err != null ? err : "TTS failed");
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
            enqueueWhenReady(call, new Runnable() {
                @Override // java.lang.Runnable
                public final void run() {
                    TtsBridgePlugin.this.lambda$speak$8(lang, voiceName, rateD, pitchD, queue, call, wait, text2);
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
    public /* synthetic */ void lambda$speak$8(String str, String str2, double d, double d2, boolean z, PluginCall pluginCall, boolean z2, String str3) {
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
                    pluginCall.reject("TTS speak() returned ERROR");
                } else if (!z2) {
                    JSObject jSObject2 = new JSObject();
                    jSObject2.put("started", true);
                    pluginCall.resolve(jSObject2);
                }
            } catch (Exception e5) {                this.speakingCall = null;
                pluginCall.reject("speak failed: " + e5.getMessage(), e5);
            }
        } catch (Exception e6) {            this.speakingCall = null;
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
            JSObject ret = new JSObject();
            ret.put("stopped", true);
            call.resolve(ret);
        } catch (Exception e) {
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
