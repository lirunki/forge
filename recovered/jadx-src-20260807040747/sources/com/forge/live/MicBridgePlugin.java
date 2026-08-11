package com.forge.live;

import android.content.Intent;
import android.media.AudioRecord;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.speech.RecognitionListener;
import android.speech.SpeechRecognizer;
import android.util.Base64;
import androidx.core.content.ContextCompat;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicBoolean;

@CapacitorPlugin(name = "MicBridge", permissions = {@Permission(alias = "mic", strings = {"android.permission.RECORD_AUDIO"})})
/* loaded from: classes4.dex */
public class MicBridgePlugin extends Plugin {
    private PluginCall activeCall;
    private AudioRecord audioRecord;
    private SpeechRecognizer recognizer;
    private Thread recordThread;
    private File wavFile;
    private final Handler main = new Handler(Looper.getMainLooper());
    private boolean listening = false;
    private final AtomicBoolean recording = new AtomicBoolean(false);
    private int recordSampleRate = 16000;
    private long recordStartedAt = 0;
    private int maxRecordMs = 60000;

    private boolean hasMicPermission() {
        return ContextCompat.checkSelfPermission(getContext(), "android.permission.RECORD_AUDIO") == 0;
    }

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject o = new JSObject();
        boolean speech = false;
        try {
            speech = SpeechRecognizer.isRecognitionAvailable(getContext());
        } catch (Exception e) {
        }
        o.put("speechRecognition", speech);
        o.put("permission", hasMicPermission());
        o.put("listening", this.listening);
        o.put("recording", this.recording.get());
        o.put("wav", true);
        o.put("record", true);
        o.put("maxRecordMs", 120000);
        o.put("formats", (Object) new JSArray().put("wav"));
        call.resolve(o);
    }

    @PluginMethod
    public void requestPermission(PluginCall call) {
        if (hasMicPermission()) {
            JSObject o = new JSObject();
            o.put("granted", true);
            call.resolve(o);
            return;
        }
        requestPermissionForAlias("mic", call, "micPermCallback");
    }

    @PermissionCallback
    private void micPermCallback(PluginCall call) {
        JSObject o = new JSObject();
        o.put("granted", hasMicPermission());
        call.resolve(o);
    }

    @PluginMethod
    public void listen(final PluginCall call) {
        if (!hasMicPermission()) {
            call.reject("RECORD_AUDIO permission not granted. Call requestPermission first.");
            return;
        }
        if (!SpeechRecognizer.isRecognitionAvailable(getContext())) {
            call.reject("Speech recognition not available on this device.");
            return;
        }
        final String lang = call.getString("lang", Locale.getDefault().toLanguageTag());
        final boolean partial = Boolean.TRUE.equals(call.getBoolean("partial", false));
        int maxResults = call.getInt("maxResults", 3).intValue();
        if (maxResults < 1) {
            maxResults = 1;
        }
        if (maxResults > 5) {
            maxResults = 5;
        }
        final int maxResults2 = maxResults;
        call.setKeepAlive(true);
        this.main.post(new Runnable() { // from class: com.forge.live.MicBridgePlugin$$ExternalSyntheticLambda2
            @Override // java.lang.Runnable
            public final void run() {
                MicBridgePlugin.this.lambda$listen$0(call, partial, lang, maxResults2);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$listen$0(PluginCall call, final boolean wantPartial, String lang, int maxR) {
        try {
            stopInternal();
            this.activeCall = call;
            this.listening = true;
            SpeechRecognizer createSpeechRecognizer = SpeechRecognizer.createSpeechRecognizer(getContext());
            this.recognizer = createSpeechRecognizer;
            createSpeechRecognizer.setRecognitionListener(new RecognitionListener() { // from class: com.forge.live.MicBridgePlugin.1
                @Override // android.speech.RecognitionListener
                public void onReadyForSpeech(Bundle params) {
                }

                @Override // android.speech.RecognitionListener
                public void onBeginningOfSpeech() {
                }

                @Override // android.speech.RecognitionListener
                public void onRmsChanged(float rmsdB) {
                }

                @Override // android.speech.RecognitionListener
                public void onBufferReceived(byte[] buffer) {
                }

                @Override // android.speech.RecognitionListener
                public void onEndOfSpeech() {
                }

                @Override // android.speech.RecognitionListener
                public void onError(int error) {
                    MicBridgePlugin.this.listening = false;
                    PluginCall c = MicBridgePlugin.this.activeCall;
                    MicBridgePlugin.this.activeCall = null;
                    MicBridgePlugin.this.destroyRecognizer();
                    if (c != null) {
                        c.reject("Speech error code " + error + " (" + MicBridgePlugin.errorName(error) + ")");
                    }
                }

                @Override // android.speech.RecognitionListener
                public void onResults(Bundle results) {
                    ArrayList<String> list;
                    MicBridgePlugin.this.listening = false;
                    PluginCall pluginCall = MicBridgePlugin.this.activeCall;
                    MicBridgePlugin.this.activeCall = null;
                    MicBridgePlugin.this.destroyRecognizer();
                    if (pluginCall == null) {
                        return;
                    }
                    if (results != null) {
                        list = results.getStringArrayList("results_recognition");
                    } else {
                        list = null;
                    }
                    float[] scores = results != null ? results.getFloatArray("confidence_scores") : null;
                    JSArray alts = new JSArray();
                    String best = "";
                    if (list != null) {
                        for (int i = 0; i < list.size(); i++) {
                            JSObject a = new JSObject();
                            a.put("transcript", list.get(i));
                            if (scores != null && i < scores.length) {
                                a.put("confidence", scores[i]);
                            }
                            alts.put(a);
                            if (i == 0) {
                                best = list.get(i);
                            }
                        }
                    }
                    JSObject ret = new JSObject();
                    ret.put("transcript", best);
                    ret.put("alternatives", (Object) alts);
                    pluginCall.resolve(ret);
                }

                @Override // android.speech.RecognitionListener
                public void onPartialResults(Bundle partialResults) {
                    ArrayList<String> list;
                    if (!wantPartial || MicBridgePlugin.this.activeCall == null || partialResults == null || (list = partialResults.getStringArrayList("results_recognition")) == null || list.isEmpty()) {
                        return;
                    }
                    JSObject ev = new JSObject();
                    ev.put("transcript", list.get(0));
                    MicBridgePlugin.this.notifyListeners("partial", ev);
                }

                @Override // android.speech.RecognitionListener
                public void onEvent(int eventType, Bundle params) {
                }
            });
            Intent intent = new Intent("android.speech.action.RECOGNIZE_SPEECH");
            intent.putExtra("android.speech.extra.LANGUAGE_MODEL", "free_form");
            intent.putExtra("android.speech.extra.LANGUAGE", lang != null ? lang : Locale.getDefault().toLanguageTag());
            intent.putExtra("android.speech.extra.MAX_RESULTS", maxR);
            intent.putExtra("android.speech.extra.PARTIAL_RESULTS", wantPartial);
            intent.putExtra("calling_package", getContext().getPackageName());
            this.recognizer.startListening(intent);
        } catch (Exception e) {
            this.listening = false;
            this.activeCall = null;
            destroyRecognizer();
            call.reject("listen failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void stop(final PluginCall call) {
        this.main.post(new Runnable() { // from class: com.forge.live.MicBridgePlugin$$ExternalSyntheticLambda1
            @Override // java.lang.Runnable
            public final void run() {
                MicBridgePlugin.this.lambda$stop$1(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$stop$1(PluginCall call) {
        try {
            SpeechRecognizer speechRecognizer = this.recognizer;
            if (speechRecognizer != null) {
                speechRecognizer.stopListening();
            }
        } catch (Exception e) {
        }
        JSObject ret = new JSObject();
        ret.put("stopping", this.listening);
        call.resolve(ret);
    }

    @PluginMethod
    public void cancel(final PluginCall call) {
        this.main.post(new Runnable() { // from class: com.forge.live.MicBridgePlugin$$ExternalSyntheticLambda0
            @Override // java.lang.Runnable
            public final void run() {
                MicBridgePlugin.this.lambda$cancel$2(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$cancel$2(PluginCall call) {
        PluginCall c = this.activeCall;
        this.activeCall = null;
        this.listening = false;
        destroyRecognizer();
        if (c != null) {
            c.reject("cancelled");
        }
        JSObject ret = new JSObject();
        ret.put("cancelled", true);
        call.resolve(ret);
    }

    @PluginMethod
    public void startRecord(PluginCall call) {
        if (!hasMicPermission()) {
            call.reject("RECORD_AUDIO permission not granted. Call requestPermission first.");
            return;
        }
        if (this.recording.get()) {
            call.reject("Already recording. Call stopRecord first.");
            return;
        }
        stopInternal();
        int sampleRate = call.getInt("sampleRate", 16000).intValue();
        if (sampleRate < 8000) {
            sampleRate = 8000;
        }
        if (sampleRate > 48000) {
            sampleRate = 48000;
        }
        final int sampleRate2 = sampleRate;
        this.recordSampleRate = sampleRate2;
        int maxMs = call.getInt("maxMs", 60000).intValue();
        if (maxMs < 1000) {
            maxMs = 1000;
        }
        if (maxMs > 120000) {
            maxMs = 120000;
        }
        this.maxRecordMs = maxMs;
        try {
            int minBuf = AudioRecord.getMinBufferSize(sampleRate2, 16, 2);
            if (minBuf <= 0) {
                minBuf = sampleRate2 * 2;
            }
            final int bufSize = Math.max(minBuf * 2, 4096);
            AudioRecord audioRecord = new AudioRecord(1, sampleRate2, 16, 2, bufSize);
            this.audioRecord = audioRecord;
            if (audioRecord.getState() != 1) {
                releaseAudioRecord();
                call.reject("AudioRecord failed to initialize");
                return;
            }
            File dir = new File(getContext().getCacheDir(), "mic");
            if (!dir.exists()) {
                dir.mkdirs();
            }
            this.wavFile = new File(dir, "rec_" + System.currentTimeMillis() + ".wav");
            this.recording.set(true);
            this.recordStartedAt = System.currentTimeMillis();
            Thread thread = new Thread(new Runnable() { // from class: com.forge.live.MicBridgePlugin$$ExternalSyntheticLambda3
                @Override // java.lang.Runnable
                public final void run() {
                    MicBridgePlugin.this.lambda$startRecord$3(sampleRate2, bufSize);
                }
            }, "forge-mic-wav");
            this.recordThread = thread;
            thread.start();
            this.main.postDelayed(new Runnable() { // from class: com.forge.live.MicBridgePlugin$$ExternalSyntheticLambda4
                @Override // java.lang.Runnable
                public final void run() {
                    MicBridgePlugin.this.lambda$startRecord$4();
                }
            }, this.maxRecordMs + 200);
            JSObject ret = new JSObject();
            ret.put("recording", true);
            ret.put("sampleRate", sampleRate2);
            ret.put("maxMs", this.maxRecordMs);
            ret.put(QrScanActivity.EXTRA_FORMAT, "wav");
            call.resolve(ret);
        } catch (Exception e) {
            this.recording.set(false);
            releaseAudioRecord();
            call.reject("startRecord failed: " + e.getMessage(), e);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$startRecord$4() {
        if (this.recording.get()) {
            this.recording.set(false);
        }
    }

    @PluginMethod
    public void stopRecord(PluginCall call) {
        Thread thread;
        if (!this.recording.get() && ((thread = this.recordThread) == null || !thread.isAlive())) {
            File file = this.wavFile;
            if (file != null && file.exists() && this.wavFile.length() > 44) {
                try {
                    call.resolve(fileToResult(this.wavFile, this.recordSampleRate));
                    return;
                } catch (Exception e) {
                    call.reject("stopRecord failed: " + e.getMessage(), e);
                    return;
                }
            }
            call.reject("Not recording");
            return;
        }
        this.recording.set(false);
        try {
            Thread thread2 = this.recordThread;
            if (thread2 != null) {
                thread2.join(3000L);
            }
        } catch (Exception e2) {
        }
        this.recordThread = null;
        releaseAudioRecord();
        try {
            File file2 = this.wavFile;
            if (file2 != null && file2.exists()) {
                call.resolve(fileToResult(this.wavFile, this.recordSampleRate));
                return;
            }
            call.reject("No recording file");
        } catch (Exception e3) {
            call.reject("stopRecord failed: " + e3.getMessage(), e3);
        }
    }

    @PluginMethod
    public void cancelRecord(PluginCall call) {
        this.recording.set(false);
        try {
            Thread thread = this.recordThread;
            if (thread != null) {
                thread.join(1500L);
            }
        } catch (Exception e) {
        }
        this.recordThread = null;
        releaseAudioRecord();
        File file = this.wavFile;
        if (file != null) {
            try {
                file.delete();
            } catch (Exception e2) {
            }
            this.wavFile = null;
        }
        JSObject o = new JSObject();
        o.put("cancelled", true);
        call.resolve(o);
    }

    @PluginMethod
    public void isRecording(PluginCall call) {
        JSObject o = new JSObject();
        o.put("recording", this.recording.get());
        if (this.recording.get()) {
            o.put("elapsedMs", System.currentTimeMillis() - this.recordStartedAt);
            o.put("sampleRate", this.recordSampleRate);
        }
        call.resolve(o);
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* renamed from: writeWavLoop, reason: merged with bridge method [inline-methods] */
    public void lambda$startRecord$3(int sampleRate, int bufferSize) {
        long written;
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(this.wavFile);
            byte[] header = new byte[44];
            fos.write(header);
        } catch (Exception e) {
            e = e;
        } catch (Throwable th) {
            th = th;
        }
        try {
            byte[] buf = new byte[bufferSize];
            this.audioRecord.startRecording();
            try {
                try {
                    long maxBytes = sampleRate * 2 * ((this.maxRecordMs / 1000) + 1);
                    long written2 = 0;
                    while (this.recording.get()) {
                        int n = this.audioRecord.read(buf, 0, buf.length);
                        if (n > 0) {
                            fos.write(buf, 0, n);
                            written2 += n;
                            if (written2 >= maxBytes) {
                                written = written2;
                                break;
                            }
                        } else if (n < 0) {
                            break;
                        }
                    }
                    written = written2;
                    try {
                        this.audioRecord.stop();
                    } catch (Exception e2) {
                    }
                    fos.flush();
                    fos.close();
                    fos = null;
                    writeWavHeader(this.wavFile, sampleRate, 1, 16, written);
                } catch (Exception e3) {
                    e = e3;
                    if (fos != null) {
                        try {
                            fos.close();
                        } catch (Exception e4) {
                        }
                    }
                    this.recording.set(false);
                    releaseAudioRecord();
                }
            } catch (Throwable th2) {
                th = th2;
                this.recording.set(false);
                releaseAudioRecord();
                throw th;
            }
        } catch (Exception e5) {
            e = e5;
        } catch (Throwable th3) {
            th = th3;
            this.recording.set(false);
            releaseAudioRecord();
            throw th;
        }
        this.recording.set(false);
        releaseAudioRecord();
    }

    private void releaseAudioRecord() {
        AudioRecord audioRecord = this.audioRecord;
        if (audioRecord != null) {
            try {
                audioRecord.release();
            } catch (Exception e) {
            }
            this.audioRecord = null;
        }
    }

    private JSObject fileToResult(File file, int sampleRate) throws IOException {
        long bytes = file.length();
        byte[] data = readAll(file);
        String b64 = Base64.encodeToString(data, 2);
        double durationSec = Math.max(0.0d, (bytes - 44) / (sampleRate * 2));
        JSObject ret = new JSObject();
        ret.put(QrScanActivity.EXTRA_FORMAT, "wav");
        ret.put("mime", "audio/wav");
        ret.put("sampleRate", sampleRate);
        ret.put("channels", 1);
        ret.put("bitsPerSample", 16);
        ret.put("bytes", bytes);
        ret.put("durationMs", Math.round(1000.0d * durationSec));
        ret.put("base64", b64);
        ret.put("dataUrl", "data:audio/wav;base64," + b64);
        ret.put("path", file.getAbsolutePath());
        ret.put("name", file.getName());
        return ret;
    }

    private static byte[] readAll(File f) throws IOException {
        int n;
        byte[] data = new byte[(int) f.length()];
        FileInputStream in = new FileInputStream(f);
        int off = 0;
        while (off < data.length && (n = in.read(data, off, data.length - off)) >= 0) {
            try {
                off += n;
            } catch (Throwable th) {
                try {
                    in.close();
                } catch (Throwable th2) {
                    th.addSuppressed(th2);
                }
                throw th;
            }
        }
        in.close();
        return data;
    }

    private static void writeWavHeader(File file, int sampleRate, int channels, int bitsPerSample, long pcmBytes) throws IOException {
        long byteRate = ((sampleRate * channels) * bitsPerSample) / 8;
        int blockAlign = (channels * bitsPerSample) / 8;
        long totalDataLen = 36 + pcmBytes;
        byte[] header = new byte[44];
        header[0] = 82;
        header[1] = 73;
        header[2] = 70;
        header[3] = 70;
        writeIntLE(header, 4, (int) totalDataLen);
        header[8] = 87;
        header[9] = 65;
        header[10] = 86;
        header[11] = 69;
        header[12] = 102;
        header[13] = 109;
        header[14] = 116;
        header[15] = 32;
        writeIntLE(header, 16, 16);
        writeShortLE(header, 20, (short) 1);
        writeShortLE(header, 22, (short) channels);
        writeIntLE(header, 24, sampleRate);
        writeIntLE(header, 28, (int) byteRate);
        writeShortLE(header, 32, (short) blockAlign);
        writeShortLE(header, 34, (short) bitsPerSample);
        header[36] = 100;
        header[37] = 97;
        header[38] = 116;
        header[39] = 97;
        writeIntLE(header, 40, (int) pcmBytes);
        RandomAccessFile raf = new RandomAccessFile(file, "rw");
        try {
            raf.seek(0L);
            raf.write(header);
            raf.close();
        } catch (Throwable th) {
            try {
                raf.close();
            } catch (Throwable th2) {
                th.addSuppressed(th2);
            }
            throw th;
        }
    }

    private static void writeIntLE(byte[] b, int off, int v) {
        b[off] = (byte) (v & 255);
        b[off + 1] = (byte) ((v >> 8) & 255);
        b[off + 2] = (byte) ((v >> 16) & 255);
        b[off + 3] = (byte) ((v >> 24) & 255);
    }

    private static void writeShortLE(byte[] b, int off, short v) {
        b[off] = (byte) (v & 255);
        b[off + 1] = (byte) ((v >> 8) & 255);
    }

    private void stopInternal() {
        this.listening = false;
        destroyRecognizer();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void destroyRecognizer() {
        SpeechRecognizer speechRecognizer = this.recognizer;
        if (speechRecognizer != null) {
            try {
                speechRecognizer.cancel();
            } catch (Exception e) {
            }
            try {
                this.recognizer.destroy();
            } catch (Exception e2) {
            }
            this.recognizer = null;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static String errorName(int code) {
        switch (code) {
            case 1:
                return "ERROR_NETWORK_TIMEOUT";
            case 2:
                return "ERROR_NETWORK";
            case 3:
                return "ERROR_AUDIO";
            case 4:
                return "ERROR_SERVER";
            case 5:
                return "ERROR_CLIENT";
            case 6:
                return "ERROR_SPEECH_TIMEOUT";
            case 7:
                return "ERROR_NO_MATCH";
            case 8:
                return "ERROR_RECOGNIZER_BUSY";
            case 9:
                return "ERROR_INSUFFICIENT_PERMISSIONS";
            default:
                return "UNKNOWN";
        }
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnDestroy() {
        this.recording.set(false);
        releaseAudioRecord();
        destroyRecognizer();
        this.activeCall = null;
        super.handleOnDestroy();
    }
}
