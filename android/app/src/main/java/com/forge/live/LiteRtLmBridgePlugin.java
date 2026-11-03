package com.forge.live;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.StatFs;
import android.util.Base64;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.MessageDigest;
import java.util.Locale;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.json.JSONArray;
import org.json.JSONObject;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/** Native storage/download boundary for verified LiteRT-LM model artifacts. */
@CapacitorPlugin(name = "LiteRtLm")
public final class LiteRtLmBridgePlugin extends Plugin {
    private static final String PREFS = "forge_litert_models_v1";
    private static final String ACTIVE_KEY = "active_model_id";
    private static final String CATALOG_JSON_KEY = "remote_catalog_json_v1";
    private static final String CATALOG_REFRESH_KEY = "remote_catalog_checked_at_v1";
    private static final long CATALOG_REFRESH_INTERVAL_MS = 24L * 60L * 60L * 1000L;
    private static final String CATALOG_URL = "https://raw.githubusercontent.com/lirunki/forge/main/www/litertlm-models.json";
    private static final int MAX_CATALOG_BYTES = 128 * 1024;
    private static final ExecutorService IO = Executors.newCachedThreadPool();
    private static final ExecutorService INFERENCE_IO = Executors.newCachedThreadPool();
    private static final ConcurrentHashMap<String, DownloadTask> DOWNLOADS = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, PluginCall> INFERENCE_CALLS = new ConcurrentHashMap<>();
    private static final Object DOWNLOAD_LOCK = new Object();
    private static final Object CATALOG_LOCK = new Object();
    private static volatile Model[] cachedModels;

    private static final class DownloadTask {
        volatile boolean cancelled;
        volatile HttpURLConnection connection;
    }
    private static final Model[] DEFAULT_MODELS = new Model[] {
        new Model(
            "qwen3-06b-int4-nothink",
            "Qwen3 0.6B · INT4 · no-think",
            "litert-community/Qwen3-0.6B-int4",
            "256f33043931947c173d7f3cc1d84ee7a8538cc2",
            "qwen3_0.6b_nothink_q4_block32_ekv1280.litertlm",
            347251840L,
            "2df6821ec12702dafd33915e7a1a1adc7c4b053f3672fd9555dfaf3a114c4139",
            "Apache-2.0",
            "Text chat · English/Chinese · CPU/GPU runtime"
        ),
        new Model(
            "qwen3-06b-int4-thinking",
            "Qwen3 0.6B · INT4 · thinking",
            "litert-community/Qwen3-0.6B-int4",
            "256f33043931947c173d7f3cc1d84ee7a8538cc2",
            "qwen3_0.6b_q4_block32_ekv1280.litertlm",
            347251840L,
            "312ce4e6bc0816edf844b9b7e66542648a89440b54822c3581e48a19e9ff5715",
            "Apache-2.0",
            "Text chat · base model · thinking enabled"
        ),
        new Model(
            "smollm2-360m-instruct",
            "SmolLM2 360M · Instruct",
            "litert-community/SmolLM2-360M-Instruct",
            "507c99cfe6541ba2bcd84818786f7b025935e5e1",
            "SmolLM2_360M_instruct.litertlm",
            373719040L,
            "8e2834da211b439751af968ed650febdde5a8cb8d88bc6c1a3059f049caa5c2e",
            "Apache-2.0",
            "Text chat · CPU/GPU runtime"
        ),
        new Model(
            "qwen25-15b-q8",
            "Qwen2.5 1.5B · Q8 · 4K context",
            "litert-community/Qwen2.5-1.5B-Instruct",
            "2f23bacf8ec78b83dfcd7271c5cb25777b1be5e0",
            "Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv4096.litertlm",
            1597922856L,
            "c4a9b7289365ab80fe599b844b77ad253eb3c53fb0e5d963d699146a6f01255e",
            "Apache-2.0",
            "Text chat · CPU/GPU · function-call metadata present (device behavior untested)"
        ),
        new Model(
            "qwen3-17b-int4",
            "Qwen3 1.7B · INT4 dynamic",
            "litert-community/Qwen3-1.7B",
            "ebb4eef4c07c0ecf019fa3cf7b501771d44ca21f",
            "Qwen3-1.7B_dynamic_wi4b32_afp32.litertlm",
            977184032L,
            "2a72330b504a6596d53a2c00923c57173b10f1b83e6a541213ffec08d1fc5de8",
            "Apache-2.0",
            "Text chat · CPU/GPU runtime"
        ),
        new Model(
            "qwen3-4b-int4",
            "Qwen3 4B · mixed INT4",
            "litert-community/Qwen3-4B",
            "965e091f07b566834b6af1dfe92b143dc92f46e7",
            "qwen3_4b_mixed_int4.litertlm",
            2272935936L,
            "4877b236f09c0b519958612afeb3c6fc6575c7ce56080d0d3a5406150e0ff9ce",
            "Apache-2.0",
            "Text chat · CPU/GPU · high RAM required · Qwen3 thinking on by default (runtime requests no-think)"
        ),
        new Model(
            "phi4-mini-q8",
            "Phi-4 mini · Q8 · 4K context",
            "litert-community/Phi-4-mini-instruct",
            "edafb1440931b748aeb7d0ae767109903d3d6d8d",
            "Phi-4-mini-instruct_multi-prefill-seq_q8_ekv4096.litertlm",
            3910090752L,
            "7764d4deb53800578307be33039476b38a6c370fff71bedb3c0552563e23ab02",
            "MIT",
            "Text chat · CPU/GPU · high RAM required"
        ),
        new Model(
            "phi3-mini-int8",
            "Phi-3 mini · INT8 · 4K context",
            "litert-community/Phi-3-mini-4k-instruct",
            "f69f3c22251cc2459a3b57a439cec61fcbe9b89c",
            "phi3_mini_4k_instruct_int8.litertlm",
            3848159232L,
            "f997586cf635d3dbadde8aa46109e2c50cab530eecea9feb507abb60891cf4c6",
            "MIT",
            "Text chat · CPU/GPU · high RAM required"
        ),
        new Model(
            "qwen35-08b-int8",
            "Qwen3.5 0.8B · INT8",
            "litert-community/Qwen3.5-0.8B",
            "0edf7e8cac6bbd035b4516c4303e2c0518391e4b",
            "Qwen3.5-0.8B_int8.litertlm",
            964566992L,
            "25447e2550082aed6145bbc755ec4da5d535f98f6a0c386865fdae2ccb88aed1",
            "Apache-2.0",
            "Text chat · instruction-tuned · CPU/GPU"
        ),
        new Model(
            "qwen35-08b-vl-int8",
            "Qwen3.5 0.8B VL · INT8",
            "litert-community/Qwen3.5-0.8B",
            "0edf7e8cac6bbd035b4516c4303e2c0518391e4b",
            "Qwen3.5-0.8B-VL_int8.litertlm",
            1303671472L,
            "1ab56460263fe94fde5fec160363d3aacbae9c5ee3638121c11feb51e483e29d",
            "Apache-2.0",
            "Text + image input · 512×512 vision · CPU/GPU"
        ),
        new Model(
            "mage-vl-47b-int4",
            "Mage-VL 4.7B · INT4",
            "litert-community/Mage-VL",
            "97e8e2b27b98d9cb3fec2f9f6ffde36d3829c0e7",
            "Mage-VL.litertlm",
            2811977104L,
            "4231ea9f88ef2bd3aca92fd4554531f17717225418c4527ac858a8a9184dad72",
            "Apache-2.0",
            "Image input at 448×448 · image question-answering/chat · measured 1.5 GiB peak on iPhone 17 Pro"
        ),
        new Model(
            "qwen2-vl-2b-int4",
            "Qwen2-VL 2B · INT4",
            "litert-community/Qwen2-VL-2B",
            "26697042bf691381177ebea3b4633cb6322168b6",
            "Qwen2-VL-2B.litertlm",
            1783424544L,
            "cf481776bcb16fe539a38c924a67fc213bb5ee55e6fa600729f060e64849066b",
            "Apache-2.0",
            "Image input at 672×672 · image question-answering/chat · measured 775 MiB peak on Galaxy S26 text path"
        ),
        new Model(
            "lfm3-audio-2b-int4",
            "LFM3 Audio 2B · INT4",
            "litert-community/LFM3-Audio-2B-LiteRT",
            "8e14ffaac0c75cc4cc806ba6085071ee018d4fef",
            "lfm3-audio-2b_int4_b128_c2048_h30.litertlm",
            1531232624L,
            "5168b79a795d1737e789f22a84f5830e808f45a3ba2d3a02099b4d291bda4f02",
            "LFM Open License v1.0 (custom; commercial-use threshold applies)",
            "Instruct audio-language · 16 kHz mono WAV input · text response; speech output requires extra models and is not included"
        ),
        new Model(
            "qwen25-coder-7b-wi4",
            "Qwen2.5 Coder 7B · INT4",
            "Uranos8685/qwen2.5-coder-7b-it-dynamic_wi4_afp32",
            "317d402916a61b358f0e52f4eed83d5010c1d9e7",
            "qwen2.5-coder-7b-it-dynamic_wi4_afp32.litertlm",
            3852009456L,
            "bbdac339ebea084d7533930a1f1456ff9b5505e7ed1d1f25c6cebc857c88c165",
            "Apache-2.0",
            "Text + code generation · CPU/GPU · 4K context; device RAM not measured",
            true, false, false, 4096
        ),
        new Model(
            "gemma4-e4b-litert",
            "Gemma 4 E4B · LiteRT-LM",
            "litert-community/gemma-4-E4B-it-litert-lm",
            "e6a3892a8c22cf87ff99583996149cf3cb32452b",
            "gemma-4-E4B-it.litertlm",
            3659530240L,
            "0b2a8980ce155fd97673d8e820b4d29d9c7d99b8fa6806f425d969b145bd52e0",
            "Apache-2.0",
            "Text + image + audio · 32K supported (2K benchmark context) · Android S26 Ultra tested",
            true, true, true, 32768
        ),
        new Model(
            "gemma4-e2b-litert",
            "Gemma 4 E2B · LiteRT-LM",
            "litert-community/gemma-4-E2B-it-litert-lm",
            "cbb97a3e73fd566bd089ca762461458c78ed4761",
            "gemma-4-E2B-it.litertlm",
            2588147712L,
            "181938105e0eefd105961417e8da75903eacda102c4fce9ce90f50b97139a63c",
            "Apache-2.0",
            "Text + image + audio · 32K supported (2K benchmark context) · Android S26 Ultra tested",
            true, true, true, 32768
        ),
    };

    private static final class Model {
        final String id, name, repo, revision, file, sha256, license, capabilities;
        final long bytes;
        final boolean instruct, image, audio;
        final int contextTokens;
        Model(String id, String name, String repo, String revision, String file, long bytes,
              String sha256, String license, String capabilities) {
            this(id, name, repo, revision, file, bytes, sha256, license, capabilities,
                !id.startsWith("qwen3-06b-"),
                id.equals("qwen35-08b-vl-int8") || id.equals("mage-vl-47b-int4") || id.equals("qwen2-vl-2b-int4") || id.equals("gemma4-e4b-litert"),
                id.equals("lfm3-audio-2b-int4") || id.equals("gemma4-e4b-litert"), contextWindowFor(id));
        }
        Model(String id, String name, String repo, String revision, String file, long bytes,
              String sha256, String license, String capabilities, boolean instruct, boolean image, boolean audio) {
            this(id, name, repo, revision, file, bytes, sha256, license, capabilities, instruct, image, audio, contextWindowFor(id));
        }
        Model(String id, String name, String repo, String revision, String file, long bytes,
              String sha256, String license, String capabilities, boolean instruct, boolean image, boolean audio, int contextTokens) {
            this.id = id; this.name = name; this.repo = repo; this.revision = revision;
            this.file = file; this.bytes = bytes; this.sha256 = sha256; this.license = license;
            this.capabilities = capabilities; this.instruct = instruct; this.image = image; this.audio = audio;
            this.contextTokens = contextTokens;
        }
        private static int contextWindowFor(String id) {
            if (id.startsWith("qwen3-06b-")) return 1280;
            if (id.equals("smollm2-360m-instruct")) return 0; // Bundle card does not publish the LiteRT cache limit.
            if (id.equals("mage-vl-47b-int4") || id.equals("lfm3-audio-2b-int4")) return 2048;
            if (id.equals("qwen25-coder-7b-wi4")) return 4096;
            if (id.equals("gemma4-e4b-litert")) return 32768;
            if (id.equals("qwen25-15b-q8") || id.equals("qwen3-17b-int4") || id.equals("qwen3-4b-int4")
                || id.equals("phi4-mini-q8") || id.equals("phi3-mini-int8") || id.startsWith("qwen35-08b-")
                || id.equals("qwen2-vl-2b-int4")) return 4096;
            return 0;
        }
        String url() {
            return "https://huggingface.co/" + repo + "/resolve/" + revision + "/" + file + "?download=true";
        }
        boolean supportsToolCalling() { return id.equals("qwen25-15b-q8") || id.startsWith("qwen3-") || id.equals("gemma4-e4b-litert") || id.equals("gemma4-e2b-litert"); }
        boolean supportsInstruct() { return instruct; }
        boolean supportsImageInput() { return image; }
        boolean supportsAudioInput() { return audio; }
        JSObject json(boolean installed, boolean active) {
            JSObject o = new JSObject();
            o.put("id", id); o.put("name", name); o.put("repo", repo); o.put("filename", file);
            o.put("bytes", bytes); o.put("license", license); o.put("capabilities", capabilities);
            o.put("contextTokens", contextTokens);
            o.put("toolCallingSupported", supportsToolCalling());
            o.put("instructSupported", supportsInstruct());
            o.put("imageInputSupported", supportsImageInput());
            o.put("audioInputSupported", supportsAudioInput());
            o.put("installed", installed); o.put("active", active);
            return o;
        }
    }

    @PluginMethod
    public void getCatalog(PluginCall call) {
        call.setKeepAlive(true);
        IO.execute(() -> {
            refreshRemoteCatalogIfDue();
            Model[] models = currentModels();
            JSArray items = new JSArray();
            for (Model model : models) items.put(model.json(findModelFile(model) != null, isActive(model.id)));
            JSObject result = new JSObject();
            result.put("models", items);
            result.put("storageLocationChosen", false);
            result.put("activeModelId", preferences().getString(ACTIVE_KEY, ""));
            result.put("catalogSource", preferences().contains(CATALOG_JSON_KEY) ? "forge-github" : "built-in-default");
            result.put("catalogCheckedAt", preferences().getLong(CATALOG_REFRESH_KEY, 0L));
            call.resolve(result);
        });
    }

    private void refreshRemoteCatalogIfDue() {
        SharedPreferences prefs = preferences();
        synchronized (CATALOG_LOCK) {
            long now = System.currentTimeMillis();
            if (now - prefs.getLong(CATALOG_REFRESH_KEY, 0L) < CATALOG_REFRESH_INTERVAL_MS) return;
            // Commit the attempt time before network I/O, so failures/restarts still obey the daily limit.
            if (!prefs.edit().putLong(CATALOG_REFRESH_KEY, now).commit()) return;
            try {
                String json = fetchRemoteCatalog();
                Model[] parsed = parseRemoteCatalog(json);
                if (parsed.length > 0 && prefs.edit().putString(CATALOG_JSON_KEY, json).commit()) cachedModels = parsed;
            } catch (Exception ignored) {
                // Keep the last-known-good catalog, or the hardcoded defaults on first launch.
            }
        }
    }

    private Model[] currentModels() {
        SharedPreferences prefs = preferences();
        Model[] snapshot = cachedModels;
        if (snapshot != null) return snapshot;
        synchronized (CATALOG_LOCK) {
            if (cachedModels != null) return cachedModels;
            String cached = prefs.getString(CATALOG_JSON_KEY, "");
            if (!cached.isEmpty()) {
                try { cachedModels = parseRemoteCatalog(cached); return cachedModels; }
                catch (Exception ignored) { prefs.edit().remove(CATALOG_JSON_KEY).apply(); }
            }
            return DEFAULT_MODELS;
        }
    }

    private String fetchRemoteCatalog() throws Exception {
        HttpURLConnection connection = (HttpURLConnection) new URL(CATALOG_URL).openConnection();
        connection.setInstanceFollowRedirects(false);
        connection.setConnectTimeout(8000);
        connection.setReadTimeout(10000);
        connection.setRequestProperty("Accept", "application/json");
        connection.setRequestProperty("User-Agent", "Forge-Android-LiteRTLM/1");
        try {
            if (!"raw.githubusercontent.com".equals(connection.getURL().getHost())) throw new Exception("Unexpected model catalog host");
            int status = connection.getResponseCode();
            if (status != HttpURLConnection.HTTP_OK) throw new Exception("Model catalog HTTP " + status);
            int length = connection.getContentLength();
            if (length > MAX_CATALOG_BYTES) throw new Exception("Model catalog exceeds size limit");
            try (InputStream in = new BufferedInputStream(connection.getInputStream());
                 java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream()) {
                byte[] buffer = new byte[4096]; int n;
                while ((n = in.read(buffer)) >= 0) {
                    if (out.size() + n > MAX_CATALOG_BYTES) throw new Exception("Model catalog exceeds size limit");
                    out.write(buffer, 0, n);
                }
                return out.toString("UTF-8");
            }
        } finally { connection.disconnect(); }
    }

    private Model[] parseRemoteCatalog(String raw) throws Exception {
        JSONObject root = new JSONObject(raw);
        if (root.optInt("schema", -1) != 1) throw new Exception("Unsupported model catalog schema");
        JSONArray array = root.getJSONArray("models");
        if (array.length() == 0 || array.length() > 100) throw new Exception("Invalid model catalog count");
        List<Model> result = new ArrayList<>();
        Set<String> ids = new HashSet<>(), files = new HashSet<>();
        for (int i = 0; i < array.length(); i++) {
            JSONObject item = array.getJSONObject(i);
            String id = item.getString("id"), name = item.getString("name"), repo = item.getString("repo");
            String revision = item.getString("revision"), file = item.getString("file"), hash = item.getString("sha256");
            long bytes = item.getLong("bytes");
            if (!id.matches("[a-z0-9][a-z0-9-]{1,63}") || !ids.add(id)) throw new Exception("Invalid or duplicate model id");
            if (name.length() > 100 || repo.length() > 160 || !repo.matches("[A-Za-z0-9._-]+/[A-Za-z0-9._-]+")) throw new Exception("Invalid model name or repository");
            if (!revision.matches("[A-Fa-f0-9]{7,64}") || !file.matches("[A-Za-z0-9._-]+\\.litertlm") || !files.add(file)) throw new Exception("Invalid model artifact pin");
            if (bytes <= 0 || bytes > 12L * 1024L * 1024L * 1024L || !hash.matches("[A-Fa-f0-9]{64}")) throw new Exception("Invalid model size or SHA-256");
            String license = item.getString("license"), capabilities = item.optString("capabilities", "");
            if (license.length() > 120 || capabilities.length() > 300) throw new Exception("Model metadata exceeds size limits");
            int contextTokens = item.optInt("contextTokens", -1);
            if (contextTokens < 0 || contextTokens > 131072) throw new Exception("Invalid context window metadata");
            result.add(new Model(id, name, repo, revision, file, bytes, hash.toLowerCase(Locale.ROOT), license, capabilities,
                item.optBoolean("instruct", false), item.optBoolean("image", false), item.optBoolean("audio", false), contextTokens));
        }
        return result.toArray(new Model[0]);
    }

    @PluginMethod
    public void getDeviceInfo(PluginCall call) {
        JSObject out = new JSObject();
        ActivityManager.MemoryInfo memory = new ActivityManager.MemoryInfo();
        ActivityManager manager = (ActivityManager) getContext().getSystemService(Activity.ACTIVITY_SERVICE);
        if (manager != null) manager.getMemoryInfo(memory);
        out.put("totalRamBytes", memory.totalMem);
        out.put("availableRamBytes", memory.availMem);
        StatFs fs = new StatFs(getContext().getFilesDir().getAbsolutePath());
        out.put("appStorageAvailableBytes", fs.getAvailableBytes());
        out.put("modelStorageLocation", "Forge app-private files/litert-models");
        out.put("androidApi", android.os.Build.VERSION.SDK_INT);
        out.put("device", android.os.Build.MANUFACTURER + " " + android.os.Build.MODEL);
        JSArray abis = new JSArray();
        for (String abi : android.os.Build.SUPPORTED_ABIS) abis.put(abi);
        out.put("abis", abis);
        out.put("runtimeSupported", isRuntimeAbiSupported());
        out.put("runtime", "LiteRT-LM Android 0.19.0 (arm64-v8a, x86_64 native runtime)");
        out.put("backendPolicy", "LiteRT-LM GPU; optional CPU fallback");
        call.resolve(out);
    }


    @PluginMethod
    public void downloadModel(PluginCall call) {
        final Model model = findModel(call.getString("modelId"));
        if (model == null) { call.reject("Unknown model in verified catalog"); return; }
        DownloadTask task = new DownloadTask();
        synchronized (DOWNLOAD_LOCK) {
            if (!DOWNLOADS.isEmpty()) { call.reject("Another model download is already active"); return; }
            DOWNLOADS.put(model.id, task);
        }
        call.setKeepAlive(true);
        try {
            LiteRtModelDownloadService.start(getContext(), model.name);
        } catch (RuntimeException error) {
            DOWNLOADS.remove(model.id, task);
            LiteRtModelDownloadService.stop(getContext());
            call.reject("Could not start the background model-download notification: " + safeMessage(error), error);
            return;
        }
        IO.execute(() -> {
            try {
                LiteRtModelDownloadService.update(getContext(), model.name, "Preparing secure download…", 0);
                notifyListeners("modelDownload", new JSObject().put("modelId", model.id).put("status", "Downloading in background; notification stays active until verification finishes."));
                download(model, call, task);
                notifyListeners("modelDownload", new JSObject().put("modelId", model.id).put("progress", 1.0).put("done", true));
                call.resolve(new JSObject().put("ok", true).put("modelId", model.id));
            } catch (Exception e) {
                boolean cancelled = task.cancelled;
                String message = cancelled ? "Model download cancelled" : safeMessage(e);
                notifyListeners("modelDownload", new JSObject().put("modelId", model.id).put(cancelled ? "cancelled" : "error", message));
                call.reject(message, e);
            } finally {
                DOWNLOADS.remove(model.id, task);
                LiteRtModelDownloadService.stop(getContext());
            }
        });
    }

    static boolean hasActiveDownloads() { return !DOWNLOADS.isEmpty(); }

    static void cancelActiveDownloads(String reason) {
        for (DownloadTask task : DOWNLOADS.values()) {
            task.cancelled = true;
            HttpURLConnection connection = task.connection;
            if (connection != null) connection.disconnect();
        }
    }

    @PluginMethod
    public void cancelDownload(PluginCall call) {
        String modelId = call.getString("modelId", "");
        DownloadTask task = DOWNLOADS.get(modelId);
        if (task != null) {
            task.cancelled = true;
            HttpURLConnection connection = task.connection;
            if (connection != null) connection.disconnect();
        }
        call.resolve(new JSObject().put("ok", true).put("cancelling", task != null));
    }

    static void rejectInferenceCall(String requestId, String error) {
        PluginCall call = INFERENCE_CALLS.remove(requestId);
        if (call != null) call.reject(error);
    }

    @PluginMethod
    public void generateText(PluginCall call) {
        String modelId = call.getString("modelId");
        String prompt = call.getString("prompt", "");
        String promptRole = call.getString("promptRole", "user");
        String systemPrompt = call.getString("systemPrompt", "");
        JSArray toolsInput = call.getArray("tools");
        String toolsJson = toolsInput == null ? "[]" : toolsInput.toString();
        String promptContentJson = call.getString("promptContent", "");
        if ((prompt.trim().isEmpty() && promptContentJson.isEmpty()) || prompt.length() > 120000 || promptContentJson.length() > 40 * 1024 * 1024) { call.reject("Prompt is empty or too long"); return; }
        JSArray historyInput = call.getArray("history");
        String historyJson = historyInput == null ? "[]" : historyInput.toString();
        Model model = findModel(modelId);
        if (!isRuntimeAbiSupported()) { call.reject("LiteRT-LM runtime requires arm64-v8a or x86_64; this device ABI is unsupported"); return; }
        if (model == null || !isActive(model.id)) { call.reject("Select an installed offline model first"); return; }
        call.setKeepAlive(true);
        boolean allowFallback = call.getBoolean("allowCpuFallback", true);
        String streamId = call.getString("streamId", "");
        if (streamId.isEmpty()) streamId = java.util.UUID.randomUUID().toString();
        final String requestId = streamId;
        PluginCall previous = INFERENCE_CALLS.putIfAbsent(requestId, call);
        if (previous != null) { call.reject("A local AI request with this ID is already active"); return; }
        try {
            INFERENCE_IO.execute(() -> {
            try {
                File file = requireVerifiedModel(model);
                LiteRtEngineFacade.generate(requestId, file.getAbsolutePath(), systemPrompt, historyJson, prompt,
                    promptRole, promptContentJson, toolsJson, model.supportsToolCalling(), model.supportsImageInput(), model.supportsAudioInput(), model.contextTokens,
                    new File(getContext().getCacheDir(), "litertlm-cache").getAbsolutePath(), allowFallback,
                    status -> {
                        JSObject event = new JSObject(); event.put("streamId", requestId); event.put("status", status);
                        notifyListeners("localChatProgress", event);
                        return kotlin.Unit.INSTANCE;
                    },
                    delta -> {
                        JSObject event = new JSObject(); event.put("streamId", requestId); event.put("delta", delta);
                        notifyListeners("localChatDelta", event);
                        return kotlin.Unit.INSTANCE;
                    },
                    (content, error, backend, toolCallsJson) -> {
                        PluginCall activeCall = INFERENCE_CALLS.remove(requestId);
                        if (activeCall == null) return kotlin.Unit.INSTANCE;
                        if (error != null) { activeCall.reject(error); return kotlin.Unit.INSTANCE; }
                        JSObject response = new JSObject(); response.put("content", content == null ? "" : content);
                        response.put("modelId", model.id); response.put("backend", backend); response.put("streamId", requestId);
                        if (toolCallsJson != null) {
                            response.put("finish_reason", "tool_calls");
                            try { response.put("tool_calls", new JSArray(toolCallsJson)); }
                            catch (org.json.JSONException ignored) {}
                        }
                        activeCall.resolve(response);
                        return kotlin.Unit.INSTANCE;
                    });
            } catch (Exception e) {
                PluginCall activeCall = INFERENCE_CALLS.remove(requestId);
                if (activeCall != null) activeCall.reject(safeMessage(e), e);
            }
            });
        } catch (RuntimeException e) {
            INFERENCE_CALLS.remove(requestId);
            call.reject("Could not queue local inference: " + safeMessage(e), e);
        }
    }

    @PluginMethod
    public void cancelText(PluginCall call) {
        String streamId = call.getString("streamId", "");
        if (!streamId.isEmpty()) {
            LiteRtEngineFacade.cancel(streamId);
            rejectInferenceCall(streamId, "LiteRT-LM request cancelled");
        }
        call.resolve(new JSObject().put("ok", true));
    }

    @PluginMethod
    public void deleteModel(PluginCall call) {
        Model model = findModel(call.getString("modelId"));
        if (model == null) { call.reject("Unknown model"); return; }
        try {
            File local = new File(modelDirectory(), model.file);
            if (local.exists() && !local.delete()) throw new Exception("Unable to delete local model file");
            if (isActive(model.id)) preferences().edit().remove(ACTIVE_KEY).apply();
            call.resolve(new JSObject().put("ok", true));
        } catch (Exception e) { call.reject(safeMessage(e), e); }
    }

    @PluginMethod
    public void selectModel(PluginCall call) {
        final Model model = findModel(call.getString("modelId"));
        if (model == null) { call.reject("Unknown model"); return; }
        if (!isRuntimeAbiSupported()) { call.reject("LiteRT-LM requires arm64-v8a or x86_64; this device ABI is unsupported"); return; }
        call.setKeepAlive(true);
        IO.execute(() -> {
            try {
                File file = requireVerifiedModel(model);
                preferences().edit().remove(ACTIVE_KEY).apply();
                notifyListeners("localModelProgress", new JSObject().put("modelId", model.id).put("status", "Loading model into memory…"));
                LiteRtEngineFacade.warmModel(file.getAbsolutePath(), model.supportsImageInput(), model.supportsAudioInput(), model.supportsToolCalling(), model.contextTokens,
                    new File(getContext().getCacheDir(), "litertlm-cache").getAbsolutePath(), true,
                    status -> {
                        notifyListeners("localModelProgress", new JSObject().put("modelId", model.id).put("status", status));
                        return kotlin.Unit.INSTANCE;
                    },
                    (backend, error) -> {
                        if (error != null) {
                            call.reject("Could not load model: " + error);
                        } else {
                            preferences().edit().putString(ACTIVE_KEY, model.id).apply();
                            call.resolve(new JSObject().put("ok", true).put("modelId", model.id).put("path", file.getAbsolutePath()).put("backend", backend).put("loaded", true));
                        }
                        return kotlin.Unit.INSTANCE;
                    });
            } catch (Exception e) { call.reject(safeMessage(e), e); }
        });
    }

    @PluginMethod
    public void deselectModel(PluginCall call) {
        call.setKeepAlive(true);
        LiteRtEngineFacade.stopModel(error -> {
            if (error != null) {
                call.reject("Could not stop offline model: " + error);
            } else {
                preferences().edit().remove(ACTIVE_KEY).apply();
                call.resolve(new JSObject().put("ok", true).put("stopped", true));
            }
            return kotlin.Unit.INSTANCE;
        });
    }

    private void download(Model model, PluginCall call, DownloadTask task) throws Exception {
        HttpURLConnection connection = null;
        File localTemp = null;
        try {
            URL url = new URL(model.url());
            for (int redirects = 0; redirects <= 6; redirects++) {
                if (!"https".equalsIgnoreCase(url.getProtocol())) throw new Exception("Refusing non-HTTPS model URL");
                checkDownloadCancelled(task);
                connection = (HttpURLConnection) url.openConnection();
                task.connection = connection;
                connection.setConnectTimeout(20000); connection.setReadTimeout(60000);
                connection.setInstanceFollowRedirects(false);
                connection.setRequestProperty("User-Agent", "Forge-LiteRT-LM/1.0");
                int code = connection.getResponseCode();
                if (code >= 300 && code < 400) {
                    String location = connection.getHeaderField("Location"); connection.disconnect(); connection = null; task.connection = null;
                    if (location == null || redirects == 6) throw new Exception("Model host returned an invalid redirect");
                    url = new URL(url, location);
                    String host = url.getHost().toLowerCase(Locale.ROOT);
                    if (!allowedDownloadHost(host)) throw new Exception("Refusing redirect to an untrusted model host");
                    continue;
                }
                if (code != HttpURLConnection.HTTP_OK) throw new Exception("Model download failed (HTTP " + code + ")");
                String host = connection.getURL().getHost().toLowerCase(Locale.ROOT);
                if (!allowedDownloadHost(host)) throw new Exception("Refusing untrusted model host");
                long length = connection.getContentLengthLong();
                if (length > 0 && length != model.bytes) throw new Exception("Model size does not match the catalog");
                MessageDigest digest = MessageDigest.getInstance("SHA-256");
                InputStream in = new BufferedInputStream(connection.getInputStream());
                File dir = modelDirectory();
                if (!dir.exists() && !dir.mkdirs()) throw new Exception("Cannot create private model directory");
                localTemp = new File(dir, model.file + ".part");
                OutputStream out = new BufferedOutputStream(new FileOutputStream(localTemp));
                if (out == null) throw new Exception("Cannot open model destination");
                byte[] buffer = new byte[1024 * 1024]; long done = 0; long lastNotify = 0; long lastNotificationUpdate = 0;
                try (InputStream source = in; OutputStream sink = out) {
                    int n;
                    while ((n = source.read(buffer)) >= 0) {
                        checkDownloadCancelled(task);
                        if (call.isReleased()) throw new Exception("Model download was cancelled");
                        sink.write(buffer, 0, n); digest.update(buffer, 0, n); done += n;
                        long now = System.currentTimeMillis();
                        if (now - lastNotify > 300) {
                            double progress = Math.min(0.999, (double) done / model.bytes);
                            JSObject event = new JSObject(); event.put("modelId", model.id); event.put("progress", progress); event.put("bytesReceived", done); event.put("totalBytes", model.bytes);
                            notifyListeners("modelDownload", event); lastNotify = now;
                            if (now - lastNotificationUpdate > 2500) {
                                int percent = (int) Math.min(99, (done * 100L) / model.bytes);
                                LiteRtModelDownloadService.update(getContext(), model.name,
                                    android.text.format.Formatter.formatShortFileSize(getContext(), done) + " of " + android.text.format.Formatter.formatShortFileSize(getContext(), model.bytes), percent);
                                lastNotificationUpdate = now;
                            }
                        }
                        if (done > model.bytes) throw new Exception("Downloaded model exceeds catalog size");
                    }
                }
                checkDownloadCancelled(task);
                if (done != model.bytes) throw new Exception("Incomplete model download (" + done + " bytes)");
                String hash = hex(digest.digest());
                if (!model.sha256.equals(hash)) throw new Exception("Model SHA-256 verification failed");
                File target = new File(localTemp.getParentFile(), model.file);
                if (target.exists() && !target.delete()) throw new Exception("Cannot replace existing model");
                if (!localTemp.renameTo(target)) throw new Exception("Cannot finalize downloaded model");
                localTemp = null;
                return;
            }
            throw new Exception("Too many redirects while downloading model");
        } finally {
            task.connection = null;
            if (connection != null) connection.disconnect();
            if (localTemp != null) localTemp.delete();

        }
    }

    private void checkDownloadCancelled(DownloadTask task) throws Exception {
        if (task.cancelled) throw new Exception("Model download cancelled");
    }

    private boolean isRuntimeAbiSupported() {
        for (String abi : android.os.Build.SUPPORTED_ABIS) {
            if ("arm64-v8a".equals(abi) || "x86_64".equals(abi)) return true;
        }
        return false;
    }
    private boolean allowedDownloadHost(String host) {
        return host.equals("huggingface.co") || host.equals("hf.co")
            || host.equals("cdn-lfs.huggingface.co") || host.equals("cdn.hf.co")
            || host.endsWith(".cdn.hf.co") || host.equals("xethub.hf.co")
            || host.endsWith(".xethub.hf.co");
    }
    private SharedPreferences preferences() { return getContext().getSharedPreferences(PREFS, 0); }
    private boolean isActive(String id) { return id.equals(preferences().getString(ACTIVE_KEY, "")); }
    private Model findModel(String id) {
        if (id == null) return null;
        for (Model model : currentModels()) if (model.id.equals(id)) return model;
        return null;
    }
    private File modelDirectory() { return new File(getContext().getFilesDir(), "litert-models"); }
    private File findModelFile(Model model) {
        File local = new File(modelDirectory(), model.file);
        return local.isFile() && local.length() == model.bytes ? local : null;
    }
    private File requireVerifiedModel(Model model) throws Exception {
        File target = new File(modelDirectory(), model.file);
        if (target.isFile() && target.length() == model.bytes && model.sha256.equals(sha256(target))) return target;
        throw new Exception("Verified model is not installed in Forge app-private storage");
    }
    private String sha256(File file) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        try (InputStream in = new BufferedInputStream(new FileInputStream(file))) {
            byte[] buffer = new byte[1024 * 1024]; int n;
            while ((n = in.read(buffer)) >= 0) digest.update(buffer, 0, n);
        }
        return hex(digest.digest());
    }
    private static String hex(byte[] data) {
        StringBuilder out = new StringBuilder(data.length * 2);
        for (byte b : data) out.append(String.format(Locale.ROOT, "%02x", b & 0xff));
        return out.toString();
    }
    private static String safeMessage(Exception e) {
        String value = e.getMessage();
        return value == null || value.isEmpty() ? "Model operation failed" : value;
    }
}
