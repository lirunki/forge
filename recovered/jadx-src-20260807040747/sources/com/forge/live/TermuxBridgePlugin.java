package com.forge.live;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import androidx.core.os.EnvironmentCompat;
import androidx.vectordrawable.graphics.drawable.PathInterpolatorCompat;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;
import org.json.JSONArray;
import org.json.JSONObject;

@CapacitorPlugin(name = "TermuxBridge")
/* loaded from: classes4.dex */
public class TermuxBridgePlugin extends Plugin {
    private static final String ACTION_EXEC_RESULT = "com.forge.live.TERMUX_EXEC_RESULT";
    private static final String ACTION_RUN_COMMAND = "com.termux.RUN_COMMAND";
    private static final String BRIDGE_DIR_NAME = "ForgeBridge";
    private static final int DEFAULT_AGENT_PORT = 8787;
    private static final String EXTRA_ARGUMENTS = "com.termux.RUN_COMMAND_ARGUMENTS";
    private static final String EXTRA_BACKGROUND = "com.termux.RUN_COMMAND_BACKGROUND";
    private static final String EXTRA_COMMAND_DESCRIPTION = "com.termux.RUN_COMMAND_DESCRIPTION";
    private static final String EXTRA_COMMAND_LABEL = "com.termux.RUN_COMMAND_LABEL";
    private static final String EXTRA_COMMAND_PATH = "com.termux.RUN_COMMAND_PATH";
    private static final String EXTRA_EXEC_TOKEN = "forge_exec_token";
    private static final String EXTRA_PENDING_INTENT = "com.termux.RUN_COMMAND_PENDING_INTENT";
    private static final String EXTRA_SESSION_ACTION = "com.termux.RUN_COMMAND_SESSION_ACTION";
    private static final String EXTRA_WORKDIR = "com.termux.RUN_COMMAND_WORKDIR";
    private static final String RESULT_BUNDLE = "result";
    private static final String RESULT_ERR = "err";
    private static final String RESULT_ERRMSG = "errmsg";
    private static final String RESULT_EXIT_CODE = "exitCode";
    private static final String RESULT_STDERR = "stderr";
    private static final String RESULT_STDERR_ORIG_LEN = "stderr_original_length";
    private static final String RESULT_STDOUT = "stdout";
    private static final String RESULT_STDOUT_ORIG_LEN = "stdout_original_length";
    private static final String RUN_COMMAND_SERVICE = "com.termux.app.RunCommandService";
    private static final String TERMUX_HOME = "/data/data/com.termux/files/home";
    private static final String TERMUX_PACKAGE = "com.termux";
    private static final String TERMUX_PREFIX = "/data/data/com.termux/files/usr";
    private BroadcastReceiver execReceiver;
    private final AtomicInteger tokenSeq = new AtomicInteger(1);
    private final Map<Integer, PluginCall> pendingExec = new ConcurrentHashMap();
    private final ExecutorService ioPool = Executors.newCachedThreadPool();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private boolean receiverRegistered = false;

    @Override // com.getcapacitor.Plugin
    public void load() {
        super.load();
        ensureReceiver();
        this.ioPool.execute(new Runnable() { // from class: com.forge.live.TermuxBridgePlugin$$ExternalSyntheticLambda3
            @Override // java.lang.Runnable
            public final void run() {
                TermuxBridgePlugin.this.lambda$load$0();
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$load$0() {
        try {
            exportAgentFiles(false);
        } catch (Exception e) {
        }
    }

    private void ensureReceiver() {
        if (this.receiverRegistered) {
            return;
        }
        this.execReceiver = new BroadcastReceiver() { // from class: com.forge.live.TermuxBridgePlugin.1
            @Override // android.content.BroadcastReceiver
            public void onReceive(Context context, Intent intent) {
                if (intent == null) {
                    return;
                }
                int token = intent.getIntExtra(TermuxBridgePlugin.EXTRA_EXEC_TOKEN, -1);
                PluginCall call = (PluginCall) TermuxBridgePlugin.this.pendingExec.remove(Integer.valueOf(token));
                if (call == null) {
                    return;
                }
                try {
                    Bundle result = intent.getBundleExtra(TermuxBridgePlugin.RESULT_BUNDLE);
                    if (result == null) {
                        result = intent.getExtras();
                    }
                    JSObject ret = new JSObject();
                    ret.put("ok", true);
                    ret.put("bridge", "run_command");
                    if (result != null) {
                        ret.put(TermuxBridgePlugin.RESULT_STDOUT, TermuxBridgePlugin.nz(result.getString(TermuxBridgePlugin.RESULT_STDOUT)));
                        ret.put(TermuxBridgePlugin.RESULT_STDERR, TermuxBridgePlugin.nz(result.getString(TermuxBridgePlugin.RESULT_STDERR)));
                        if (result.containsKey(TermuxBridgePlugin.RESULT_EXIT_CODE)) {
                            ret.put(TermuxBridgePlugin.RESULT_EXIT_CODE, result.getInt(TermuxBridgePlugin.RESULT_EXIT_CODE));
                        } else {
                            ret.put(TermuxBridgePlugin.RESULT_EXIT_CODE, JSONObject.NULL);
                        }
                        if (result.containsKey("err")) {
                            ret.put("err", result.getInt("err"));
                        }
                        String errmsg = result.getString(TermuxBridgePlugin.RESULT_ERRMSG, null);
                        if (errmsg != null) {
                            ret.put(TermuxBridgePlugin.RESULT_ERRMSG, errmsg);
                        }
                        String sol = result.getString(TermuxBridgePlugin.RESULT_STDOUT_ORIG_LEN, null);
                        if (sol != null) {
                            ret.put("stdoutOriginalLength", sol);
                        }
                        String sel = result.getString(TermuxBridgePlugin.RESULT_STDERR_ORIG_LEN, null);
                        if (sel != null) {
                            ret.put("stderrOriginalLength", sel);
                        }
                    } else {
                        ret.put(TermuxBridgePlugin.RESULT_STDOUT, "");
                        ret.put(TermuxBridgePlugin.RESULT_STDERR, "");
                        ret.put(TermuxBridgePlugin.RESULT_EXIT_CODE, JSONObject.NULL);
                        ret.put("note", "Result bundle missing — Termux may be outdated or RUN_COMMAND blocked.");
                    }
                    call.resolve(ret);
                } catch (Exception e) {
                    call.reject("Termux exec result parse failed: " + e.getMessage(), e);
                }
            }
        };
        IntentFilter filter = new IntentFilter(ACTION_EXEC_RESULT);
        try {
            if (Build.VERSION.SDK_INT >= 33) {
                getContext().registerReceiver(this.execReceiver, filter, 4);
            } else {
                getContext().registerReceiver(this.execReceiver, filter);
            }
            this.receiverRegistered = true;
        } catch (Exception e) {
        }
    }

    @PluginMethod
    public void isAvailable(final PluginCall call) {
        this.ioPool.execute(new Runnable() { // from class: com.forge.live.TermuxBridgePlugin$$ExternalSyntheticLambda2
            @Override // java.lang.Runnable
            public final void run() {
                TermuxBridgePlugin.this.lambda$isAvailable$1(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$isAvailable$1(PluginCall call) {
        try {
            call.resolve(probeStatus());
        } catch (Exception e) {
            call.reject("isAvailable failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void open(PluginCall call) {
        if (!isTermuxInstalled()) {
            call.reject("Termux is not installed");
            return;
        }
        try {
            Intent launch = getContext().getPackageManager().getLaunchIntentForPackage(TERMUX_PACKAGE);
            if (launch == null) {
                call.reject("Cannot launch Termux");
                return;
            }
            launch.addFlags(268435456);
            getContext().startActivity(launch);
            JSObject o = new JSObject();
            o.put("opened", true);
            call.resolve(o);
        } catch (Exception e) {
            call.reject("open failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void installAgent(final PluginCall call) {
        this.ioPool.execute(new Runnable() { // from class: com.forge.live.TermuxBridgePlugin$$ExternalSyntheticLambda1
            @Override // java.lang.Runnable
            public final void run() {
                TermuxBridgePlugin.this.lambda$installAgent$2(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$installAgent$2(PluginCall call) {
        try {
            File dir = exportAgentFiles(true);
            JSObject o = new JSObject();
            o.put("ok", true);
            o.put("bridgeDir", dir.getAbsolutePath());
            o.put("agentPath", new File(dir, "forge-termux-agent").getAbsolutePath());
            o.put("installPath", new File(dir, "install.sh").getAbsolutePath());
            o.put("port", DEFAULT_AGENT_PORT);
            o.put("command", "bash \"/storage/emulated/0/Download/ForgeBridge/install.sh\" && forge-termux-agent");
            o.put("note", "In Termux run the command above (needs termux-setup-storage once). Keep the agent running.");
            call.resolve(o);
        } catch (Exception e) {
            call.reject("installAgent failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void run(final PluginCall call) {
        if (!isTermuxInstalled()) {
            call.reject("Termux is not installed");
        } else {
            this.ioPool.execute(new Runnable() { // from class: com.forge.live.TermuxBridgePlugin$$ExternalSyntheticLambda6
                @Override // java.lang.Runnable
                public final void run() {
                    TermuxBridgePlugin.this.lambda$run$3(call);
                }
            });
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$run$3(PluginCall call) {
        try {
            CommandSpec spec = parseCommand(call);
            String bridge = pickBridge();
            if ("run_command".equals(bridge)) {
                Intent intent = buildRunIntent(spec, null);
                startTermuxService(intent);
                JSObject ret = baseStarted(spec);
                ret.put("bridge", "run_command");
                ret.put("note", "Command dispatched via RUN_COMMAND. Stdout is NOT captured — use termux.exec().");
                call.resolve(ret);
                return;
            }
            if ("agent".equals(bridge)) {
                JSONObject job = jobFromSpec(spec, 120000, true);
                job.put("wait", false);
                agentHttpExec(job, 15000);
                JSObject ret2 = baseStarted(spec);
                ret2.put("bridge", "agent");
                ret2.put("note", "Command accepted by forge-termux-agent. Stdout not returned — use termux.exec().");
                call.resolve(ret2);
                return;
            }
            call.reject(noBridgeMessage());
        } catch (IllegalArgumentException iae) {
            call.reject(iae.getMessage());
        } catch (SecurityException se) {
            call.reject("Termux blocked RUN_COMMAND. " + se.getMessage() + " — " + noBridgeMessage(), se);
        } catch (Exception e) {
            call.reject("Termux run failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void exec(final PluginCall call) {
        if (!isTermuxInstalled()) {
            call.reject("Termux is not installed");
        } else {
            this.ioPool.execute(new Runnable() { // from class: com.forge.live.TermuxBridgePlugin$$ExternalSyntheticLambda7
                @Override // java.lang.Runnable
                public final void run() {
                    TermuxBridgePlugin.this.lambda$exec$5(call);
                }
            });
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$exec$5(final PluginCall call) {
        try {
            try {
                final CommandSpec spec = parseCommand(call);
                if (call.getBoolean("background", null) == null) {
                    spec.background = true;
                }
                int tMs = call.getInt("timeoutMs", 120000).intValue();
                if (tMs < 3000) {
                    tMs = PathInterpolatorCompat.MAX_NUM_POINTS;
                }
                if (tMs > 600000) {
                    tMs = 600000;
                }
                final int timeoutMs = tMs;
                String bridge = pickBridge();
                if (!"agent".equals(bridge) && (!PluginMethod.RETURN_NONE.equals(bridge) || !agentPortOpen(DEFAULT_AGENT_PORT))) {
                    if ("run_command".equals(bridge)) {
                        this.mainHandler.post(new Runnable() { // from class: com.forge.live.TermuxBridgePlugin$$ExternalSyntheticLambda0
                            @Override // java.lang.Runnable
                            public final void run() {
                                TermuxBridgePlugin.this.lambda$exec$4(call, spec, timeoutMs);
                            }
                        });
                        return;
                    }
                    try {
                        JSONObject job = jobFromSpec(spec, timeoutMs, false);
                        JSONObject result = agentFileExec(job, timeoutMs);
                        call.resolve(jsFromAgentResult(result, "file"));
                        return;
                    } catch (Exception fileEx) {
                        call.reject(noBridgeMessage() + " Detail: " + fileEx.getMessage());
                        return;
                    }
                }
                JSONObject job2 = jobFromSpec(spec, timeoutMs, false);
                JSONObject result2 = agentHttpExec(job2, timeoutMs + 5000);
                call.resolve(jsFromAgentResult(result2, "agent"));
            } catch (IllegalArgumentException iae) {
                call.reject(iae.getMessage());
            }
        } catch (Exception e) {
            call.reject("Termux exec failed: " + e.getMessage() + "\n" + noBridgeMessage(), e);
        }
    }

    @PluginMethod
    public void openUrl(PluginCall call) {
        String url = call.getString("url", "");
        if (url == null || url.isEmpty()) {
            call.reject("url required");
            return;
        }
        try {
            Intent intent = new Intent("android.intent.action.VIEW", Uri.parse(url));
            intent.setPackage(TERMUX_PACKAGE);
            intent.addFlags(268435456);
            getContext().startActivity(intent);
            JSObject o = new JSObject();
            o.put("opened", true);
            call.resolve(o);
        } catch (Exception e) {
            call.reject("Termux openUrl failed: " + e.getMessage(), e);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* renamed from: execViaRunCommand, reason: merged with bridge method [inline-methods] */
    public void lambda$exec$4(final PluginCall call, final CommandSpec spec, final int timeoutMs) {
        ensureReceiver();
        if (!this.receiverRegistered) {
            this.ioPool.execute(new Runnable() { // from class: com.forge.live.TermuxBridgePlugin$$ExternalSyntheticLambda4
                @Override // java.lang.Runnable
                public final void run() {
                    TermuxBridgePlugin.this.lambda$execViaRunCommand$6(spec, timeoutMs, call);
                }
            });
            return;
        }
        try {
            final int token = this.tokenSeq.getAndIncrement();
            call.setKeepAlive(true);
            this.pendingExec.put(Integer.valueOf(token), call);
            Intent resultIntent = new Intent(ACTION_EXEC_RESULT);
            resultIntent.setPackage(getContext().getPackageName());
            resultIntent.putExtra(EXTRA_EXEC_TOKEN, token);
            int flags = Build.VERSION.SDK_INT >= 31 ? 134217728 | 33554432 : 134217728;
            PendingIntent pi = PendingIntent.getBroadcast(getContext(), token, resultIntent, flags);
            Intent intent = buildRunIntent(spec, pi);
            startTermuxService(intent);
            this.mainHandler.postDelayed(new Runnable() { // from class: com.forge.live.TermuxBridgePlugin$$ExternalSyntheticLambda5
                @Override // java.lang.Runnable
                public final void run() {
                    TermuxBridgePlugin.this.lambda$execViaRunCommand$7(token, timeoutMs);
                }
            }, timeoutMs);
        } catch (SecurityException se) {
            call.reject("Termux blocked RUN_COMMAND. " + se.getMessage(), se);
        } catch (Exception e) {
            call.reject("Termux RUN_COMMAND exec failed: " + e.getMessage(), e);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$execViaRunCommand$6(CommandSpec spec, int timeoutMs, PluginCall call) {
        try {
            JSONObject job = jobFromSpec(spec, timeoutMs, false);
            JSONObject result = agentHttpExec(job, timeoutMs + 5000);
            call.resolve(jsFromAgentResult(result, "agent"));
        } catch (Exception e) {
            call.reject("Cannot register Termux result receiver and agent unavailable: " + e.getMessage());
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$execViaRunCommand$7(int token, int t) {
        PluginCall c = this.pendingExec.remove(Integer.valueOf(token));
        if (c != null) {
            c.reject("Termux RUN_COMMAND exec timed out after " + t + "ms. If you use Google Play Termux, RUN_COMMAND is not available — start forge-termux-agent instead.");
        }
    }

    private void startTermuxService(Intent intent) {
        if (Build.VERSION.SDK_INT >= 26) {
            getContext().startForegroundService(intent);
        } else {
            getContext().startService(intent);
        }
    }

    private JSObject probeStatus() {
        PackageInfo pi;
        String note;
        JSObject o = new JSObject();
        boolean installed = isTermuxInstalled();
        o.put("installed", installed);
        o.put("package", TERMUX_PACKAGE);
        o.put("home", TERMUX_HOME);
        o.put("prefix", TERMUX_PREFIX);
        o.put("runCommandAction", ACTION_RUN_COMMAND);
        o.put("agentPort", DEFAULT_AGENT_PORT);
        String versionName = null;
        long versionCode = -1;
        if (installed) {
            try {
                if (Build.VERSION.SDK_INT < 33) {
                    pi = getContext().getPackageManager().getPackageInfo(TERMUX_PACKAGE, 0);
                } else {
                    pi = getContext().getPackageManager().getPackageInfo(TERMUX_PACKAGE, PackageManager.PackageInfoFlags.of(0L));
                }
                versionName = pi.versionName;
                versionCode = Build.VERSION.SDK_INT >= 28 ? pi.getLongVersionCode() : pi.versionCode;
            } catch (Exception e) {
            }
        }
        o.put("versionName", versionName != null ? versionName : JSONObject.NULL);
        o.put("versionCode", versionCode);
        String flavor = EnvironmentCompat.MEDIA_UNKNOWN;
        if (versionName != null) {
            String vn = versionName.toLowerCase();
            if (vn.contains("googleplay") || vn.contains("play")) {
                flavor = "googleplay";
            } else if (vn.matches("0\\.\\d+.*") || vn.contains("fdroid") || vn.contains("github")) {
                flavor = "github";
            }
        }
        o.put("flavor", flavor);
        boolean runCmd = installed && isRunCommandSupported();
        o.put("runCommandSupported", runCmd);
        boolean agent = false;
        JSObject agentInfo = null;
        if (installed) {
            agentInfo = probeAgent();
            agent = agentInfo != null && agentInfo.getBool("running").booleanValue();
        }
        o.put("agentRunning", agent);
        if (agentInfo != null) {
            o.put("agent", (Object) agentInfo);
        }
        String bridge = PluginMethod.RETURN_NONE;
        if (runCmd) {
            bridge = "run_command";
        } else if (agent) {
            bridge = "agent";
        }
        o.put("bridge", bridge);
        boolean execSupported = runCmd || agent;
        o.put("execSupported", execSupported);
        File bridgeDir = getBridgeDir();
        o.put("bridgeDir", bridgeDir.getAbsolutePath());
        if (!installed) {
            note = "Termux is not installed.";
        } else if (execSupported) {
            note = "Termux ready via " + bridge + ".";
        } else if ("googleplay".equals(flavor)) {
            note = "Google Play Termux has NO RUN_COMMAND API. Install and run the Forge agent in Termux: bash /storage/emulated/0/Download/ForgeBridge/install.sh && forge-termux-agent";
        } else {
            note = "Termux found but no bridge. Enable allow-external-apps=true (F-Droid Termux) OR run forge-termux-agent. Settings → Device bridges → Install agent.";
        }
        o.put("note", note);
        o.put("setupCommand", "bash /storage/emulated/0/Download/ForgeBridge/install.sh && forge-termux-agent");
        return o;
    }

    private String pickBridge() {
        if (isRunCommandSupported()) {
            return "run_command";
        }
        if (agentPortOpen(DEFAULT_AGENT_PORT)) {
            return "agent";
        }
        JSObject a = probeAgent();
        return (a == null || !a.getBool("running").booleanValue()) ? PluginMethod.RETURN_NONE : "agent";
    }

    private String noBridgeMessage() {
        return "No Termux bridge available. This device has Google Play Termux (no RUN_COMMAND). In Termux run:\n  bash /storage/emulated/0/Download/ForgeBridge/install.sh\n  forge-termux-agent\nLeave the agent running, then retry. Or install F-Droid/GitHub Termux which supports RUN_COMMAND + allow-external-apps=true.";
    }

    private boolean isTermuxInstalled() {
        try {
            getContext().getPackageManager().getPackageInfo(TERMUX_PACKAGE, 0);
            return true;
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
    }

    private boolean isRunCommandSupported() {
        List<ResolveInfo> list;
        try {
            PackageManager pm = getContext().getPackageManager();
            Intent intent = new Intent(ACTION_RUN_COMMAND);
            intent.setClassName(TERMUX_PACKAGE, RUN_COMMAND_SERVICE);
            if (Build.VERSION.SDK_INT >= 33) {
                list = pm.queryIntentServices(intent, PackageManager.ResolveInfoFlags.of(0L));
            } else {
                list = pm.queryIntentServices(intent, 0);
            }
            if (list != null && !list.isEmpty()) {
                return true;
            }
            Intent intent2 = new Intent();
            intent2.setClassName(TERMUX_PACKAGE, RUN_COMMAND_SERVICE);
            ResolveInfo ri = pm.resolveService(intent2, 0);
            return ri != null;
        } catch (Exception e) {
            return false;
        }
    }

    private JSObject probeAgent() {
        JSObject o = new JSObject();
        o.put("running", false);
        o.put("port", DEFAULT_AGENT_PORT);
        if (!agentPortOpen(DEFAULT_AGENT_PORT)) {
            File hb = new File(getBridgeDir(), "agent.json");
            if (hb.isFile() && System.currentTimeMillis() - hb.lastModified() < 8000) {
                String raw = readFile(hb);
                JSONObject j = new JSONObject(raw);
                o.put("running", true);
                o.put("via", "file");
                if (j.has("pid")) {
                    o.put("pid", j.optInt("pid"));
                }
                if (j.has("version")) {
                    o.put("version", j.optString("version"));
                }
                return o;
            }
            return o;
        }
        URL url = new URL("http://127.0.0.1:8787/status");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setConnectTimeout(600);
        conn.setReadTimeout(800);
        conn.setRequestMethod("GET");
        int code = conn.getResponseCode();
        String body = readStream(code >= 400 ? conn.getErrorStream() : conn.getInputStream());
        conn.disconnect();
        if (code == 200 && body != null) {
            JSONObject j2 = new JSONObject(body);
            o.put("running", true);
            o.put("via", "http");
            if (j2.has("pid")) {
                o.put("pid", j2.optInt("pid"));
            }
            if (j2.has("version")) {
                o.put("version", j2.optString("version"));
            }
            if (j2.has("home")) {
                o.put("home", j2.optString("home"));
            }
            if (j2.has("prefix")) {
                o.put("prefix", j2.optString("prefix"));
            }
        }
        return o;
    }

    private boolean agentPortOpen(int port) {
        try {
            Socket s = new Socket();
            try {
                s.connect(new InetSocketAddress("127.0.0.1", port), 400);
                s.close();
                return true;
            } finally {
            }
        } catch (Exception e) {
            return false;
        }
    }

    private JSONObject agentHttpExec(JSONObject job, int timeoutMs) throws Exception {
        if (agentPortOpen(DEFAULT_AGENT_PORT)) {
            URL url = new URL("http://127.0.0.1:8787/exec");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(2000);
            conn.setReadTimeout(Math.max(timeoutMs, 5000));
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json; charset=utf-8");
            byte[] payload = job.toString().getBytes(StandardCharsets.UTF_8);
            conn.setFixedLengthStreamingMode(payload.length);
            OutputStream os = conn.getOutputStream();
            try {
                os.write(payload);
                if (os != null) {
                    os.close();
                }
                int code = conn.getResponseCode();
                String body = readStream(code >= 400 ? conn.getErrorStream() : conn.getInputStream());
                conn.disconnect();
                if (body == null || body.isEmpty()) {
                    throw new Exception("Agent returned empty body (HTTP " + code + ")");
                }
                JSONObject result = new JSONObject(body);
                if (code >= 400 && !result.has(RESULT_STDOUT)) {
                    throw new Exception("Agent HTTP " + code + ": " + body);
                }
                return result;
            } catch (Throwable th) {
                if (os != null) {
                    try {
                        os.close();
                    } catch (Throwable th2) {
                        th.addSuppressed(th2);
                    }
                }
                throw th;
            }
        }
        return agentFileExec(job, timeoutMs);
    }

    private JSONObject agentFileExec(JSONObject job, int timeoutMs) throws Exception {
        boolean alive = false;
        File root = exportAgentFiles(false);
        File inbox = new File(root, "inbox");
        File outbox = new File(root, "outbox");
        if (!inbox.exists() && !inbox.mkdirs()) {
            throw new Exception("Cannot create inbox at " + inbox.getAbsolutePath());
        }
        if (!outbox.exists() && !outbox.mkdirs()) {
            throw new Exception("Cannot create outbox at " + outbox.getAbsolutePath());
        }
        File hb = new File(root, "agent.json");
        if (hb.isFile() && System.currentTimeMillis() - hb.lastModified() < 10000) {
            alive = true;
        }
        if (!alive && !agentPortOpen(DEFAULT_AGENT_PORT)) {
            throw new Exception("forge-termux-agent is not running (no heartbeat in " + hb.getAbsolutePath() + ")");
        }
        String id = job.optString("id", UUID.randomUUID().toString());
        job.put("id", id);
        File inFile = new File(inbox, id + ".json");
        File outFile = new File(outbox, id + ".json");
        if (outFile.exists()) {
            outFile.delete();
        }
        writeFile(inFile, job.toString());
        long deadline = System.currentTimeMillis() + timeoutMs;
        while (System.currentTimeMillis() < deadline) {
            if (outFile.isFile() && outFile.length() > 0) {
                Thread.sleep(30L);
                String raw = readFile(outFile);
                outFile.delete();
                inFile.delete();
                return new JSONObject(raw);
            }
            Thread.sleep(150L);
        }
        inFile.delete();
        throw new Exception("Timed out waiting for agent file result (" + timeoutMs + "ms)");
    }

    private JSObject jsFromAgentResult(JSONObject result, String bridge) {
        JSObject ret = new JSObject();
        ret.put("ok", result.optBoolean("ok", result.optInt(RESULT_EXIT_CODE, 1) == 0));
        ret.put("bridge", bridge);
        ret.put(RESULT_STDOUT, result.optString(RESULT_STDOUT, ""));
        ret.put(RESULT_STDERR, result.optString(RESULT_STDERR, ""));
        if (!result.has(RESULT_EXIT_CODE) || result.isNull(RESULT_EXIT_CODE)) {
            ret.put(RESULT_EXIT_CODE, JSONObject.NULL);
        } else {
            ret.put(RESULT_EXIT_CODE, result.optInt(RESULT_EXIT_CODE));
        }
        if (result.has("err") && !result.isNull("err")) {
            ret.put("err", result.optInt("err"));
        }
        if (result.has(RESULT_ERRMSG) && !result.isNull(RESULT_ERRMSG)) {
            ret.put(RESULT_ERRMSG, result.optString(RESULT_ERRMSG));
        }
        if (result.has("note")) {
            ret.put("note", result.optString("note"));
        }
        return ret;
    }

    private JSONObject jobFromSpec(CommandSpec spec, int timeoutMs, boolean background) throws Exception {
        JSONObject job = new JSONObject();
        job.put("id", UUID.randomUUID().toString());
        job.put("cmdPath", spec.cmdPath);
        JSONArray args = new JSONArray();
        Iterator<String> it = spec.argsList.iterator();
        while (it.hasNext()) {
            String a = it.next();
            args.put(a);
        }
        job.put("args", args);
        job.put("cwd", spec.cwd != null ? spec.cwd : TERMUX_HOME);
        job.put("timeoutMs", timeoutMs);
        job.put("background", background);
        job.put("label", spec.label);
        if (spec.argsList.size() == 2 && "-lc".equals(spec.argsList.get(0))) {
            job.put("script", spec.argsList.get(1));
        }
        return job;
    }

    private File getBridgeDir() {
        File ext;
        File dl = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        File dir = new File(dl, BRIDGE_DIR_NAME);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        if ((!dir.exists() || !dir.canWrite()) && (ext = getContext().getExternalFilesDir(null)) != null) {
            File dir2 = new File(ext, BRIDGE_DIR_NAME);
            dir2.mkdirs();
            return dir2;
        }
        return dir;
    }

    private File exportAgentFiles(boolean force) throws Exception {
        File dir = getBridgeDir();
        if (!dir.exists() && !dir.mkdirs()) {
            throw new Exception("Cannot create " + dir.getAbsolutePath());
        }
        File inbox = new File(dir, "inbox");
        File outbox = new File(dir, "outbox");
        inbox.mkdirs();
        outbox.mkdirs();
        writeAssetOrBuiltin(dir, "forge-termux-agent", force);
        writeAssetOrBuiltin(dir, "install.sh", force);
        File readme = new File(dir, "README.txt");
        if (force || !readme.exists()) {
            writeFile(readme, "Forge ↔ Termux bridge (Google Play Termux compatible)\n=====================================================\nPlay Store Termux does NOT include RUN_COMMAND.\nRun this once in Termux (after termux-setup-storage):\n\n  bash /storage/emulated/0/Download/ForgeBridge/install.sh\n  forge-termux-agent\n\nKeep the agent session open (or run: forge-termux-agent --daemon).\nThen use Forge → AI → Device bridges → Test Termux.\n");
        }
        return dir;
    }

    private void writeAssetOrBuiltin(File dir, String name, boolean force) throws Exception {
        File out = new File(dir, name);
        if (!out.exists() || force) {
            String content = null;
            try {
                InputStream in = getContext().getAssets().open("termux-agent/" + name);
                content = readStream(in);
            } catch (Exception e) {
            }
            if (content == null || content.isEmpty()) {
                content = builtinAgentFile(name);
            }
            writeFile(out, content);
            out.setReadable(true, false);
            out.setExecutable(true, false);
        }
    }

    private String builtinAgentFile(String name) {
        if ("install.sh".equals(name)) {
            return "#!/data/data/com.termux/files/usr/bin/bash\nset -euo pipefail\nPREFIX=\"${PREFIX:-/data/data/com.termux/files/usr}\"\nHOME=\"${HOME:-/data/data/com.termux/files/home}\"\nBIN=\"$HOME/bin\"\nSRC_DIR=\"/storage/emulated/0/Download/ForgeBridge\"\nmkdir -p \"$BIN\" \"$SRC_DIR/inbox\" \"$SRC_DIR/outbox\"\nif [[ ! -f \"$SRC_DIR/forge-termux-agent\" ]]; then\n  echo \"Missing $SRC_DIR/forge-termux-agent — open Forge once to export it.\" >&2\n  exit 1\nfi\ncp -f \"$SRC_DIR/forge-termux-agent\" \"$BIN/forge-termux-agent\"\nchmod +x \"$BIN/forge-termux-agent\"\nif ! grep -q 'home/bin' \"$HOME/.bashrc\" 2>/dev/null; then\n  echo 'export PATH=\"$HOME/bin:$PATH\"' >> \"$HOME/.bashrc\"\nfi\nexport PATH=\"$BIN:$PATH\"\necho \"Installed: $BIN/forge-termux-agent\"\necho \"Start with: forge-termux-agent\"\necho \"Daemonize:  forge-termux-agent --daemon\"\n";
        }
        return "#!/data/data/com.termux/files/usr/bin/bash\n# Forge Termux agent — HTTP + file-queue bridge for apps (Play Termux OK)\nset -euo pipefail\nPORT=\"${FORGE_AGENT_PORT:-8787}\"\nROOT=\"${FORGE_BRIDGE_DIR:-/storage/emulated/0/Download/ForgeBridge}\"\nVERSION=\"1.0.0\"\nPREFIX=\"${PREFIX:-/data/data/com.termux/files/usr}\"\nHOME=\"${HOME:-/data/data/com.termux/files/home}\"\nINBOX=\"$ROOT/inbox\"\nOUTBOX=\"$ROOT/outbox\"\nmkdir -p \"$INBOX\" \"$OUTBOX\"\n\nif [[ \"${1:-}\" == \"--daemon\" ]]; then\n  shift\n  nohup \"$0\" \"$@\" >/dev/null 2>&1 &\n  echo \"forge-termux-agent daemon pid $! port $PORT\"\n  exit 0\nfi\n\ncommand -v python >/dev/null || command -v python3 >/dev/null || {\n  echo \"python required: pkg install python\" >&2\n  exit 1\n}\nPY=$(command -v python3 || command -v python)\n\nexport FORGE_AGENT_PORT=\"$PORT\" FORGE_BRIDGE_ROOT=\"$ROOT\" FORGE_AGENT_VERSION=\"$VERSION\"\nexport PREFIX HOME\nexec \"$PY\" - <<'PY'\nimport json, os, socketserver, subprocess, threading, time, traceback\nfrom http.server import BaseHTTPRequestHandler\nfrom pathlib import Path\n\nPORT = int(os.environ.get('FORGE_AGENT_PORT', '8787'))\nROOT = Path(os.environ.get('FORGE_BRIDGE_ROOT', '/storage/emulated/0/Download/ForgeBridge'))\nINBOX, OUTBOX = ROOT / 'inbox', ROOT / 'outbox'\nINBOX.mkdir(parents=True, exist_ok=True); OUTBOX.mkdir(parents=True, exist_ok=True)\nVERSION = os.environ.get('FORGE_AGENT_VERSION', '1.0.0')\nHOME = os.environ.get('HOME', '/data/data/com.termux/files/home')\nPREFIX = os.environ.get('PREFIX', '/data/data/com.termux/files/usr')\nPID = os.getpid()\n\ndef status():\n    return {'ok': True, 'pid': PID, 'version': VERSION, 'home': HOME, 'prefix': PREFIX,\n            'port': PORT, 'root': str(ROOT), 'ts': int(time.time())}\n\ndef write_heartbeat():\n    try:\n        (ROOT / 'agent.json').write_text(json.dumps(status()), encoding='utf-8')\n    except Exception:\n        pass\n\ndef run_job(job):\n    t0 = time.time()\n    cwd = job.get('cwd') or HOME\n    timeout = max(1, min(int(job.get('timeoutMs') or 120000) / 1000.0, 600))\n    env = os.environ.copy()\n    env['HOME'] = HOME\n    env['PREFIX'] = PREFIX\n    env['PATH'] = f\"{PREFIX}/bin:\" + env.get('PATH', '')\n    try:\n        if job.get('script'):\n            cmd = [f'{PREFIX}/bin/bash', '-lc', job['script']]\n        else:\n            cmd_path = job.get('cmdPath') or f'{PREFIX}/bin/bash'\n            args = job.get('args') or []\n            if not isinstance(args, list): args = []\n            cmd = [cmd_path] + [str(a) for a in args]\n        if job.get('background') and not job.get('wait', True):\n            subprocess.Popen(cmd, cwd=cwd, env=env, start_new_session=True)\n            return {'ok': True, 'stdout': '', 'stderr': '', 'exitCode': 0,\n                    'note': 'started background', 'id': job.get('id')}\n        p = subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True,\n                           timeout=timeout, errors='replace')\n        return {'ok': p.returncode == 0, 'stdout': p.stdout or '', 'stderr': p.stderr or '',\n                'exitCode': p.returncode, 'id': job.get('id'),\n                'ms': int((time.time() - t0) * 1000)}\n    except subprocess.TimeoutExpired as e:\n        out = (e.stdout or '') if isinstance(e.stdout, str) else ''\n        err = (e.stderr or '') if isinstance(e.stderr, str) else ''\n        return {'ok': False, 'stdout': out, 'stderr': err or 'timeout',\n                'exitCode': 124, 'errmsg': f'timeout after {timeout}s', 'id': job.get('id')}\n    except Exception as e:\n        return {'ok': False, 'stdout': '', 'stderr': traceback.format_exc(),\n                'exitCode': 1, 'errmsg': str(e), 'id': job.get('id')}\n\nclass H(BaseHTTPRequestHandler):\n    def log_message(self, *a): pass\n    def _send(self, code, obj):\n        b = json.dumps(obj).encode('utf-8')\n        self.send_response(code)\n        self.send_header('Content-Type', 'application/json')\n        self.send_header('Content-Length', str(len(b)))\n        self.end_headers(); self.wfile.write(b)\n    def do_GET(self):\n        if self.path.startswith('/status') or self.path == '/':\n            self._send(200, status())\n        else:\n            self._send(404, {'ok': False, 'errmsg': 'not found'})\n    def do_POST(self):\n        n = int(self.headers.get('Content-Length') or 0)\n        raw = self.rfile.read(n).decode('utf-8', 'replace') if n else '{}'\n        try: job = json.loads(raw or '{}')\n        except Exception as e:\n            self._send(400, {'ok': False, 'errmsg': f'bad json: {e}'}); return\n        if self.path.startswith('/exec') or self.path.startswith('/run'):\n            self._send(200, run_job(job))\n        else:\n            self._send(404, {'ok': False, 'errmsg': 'not found'})\n\ndef file_worker():\n    while True:\n        try:\n            write_heartbeat()\n            for f in sorted(INBOX.glob('*.json')):\n                try:\n                    job = json.loads(f.read_text(encoding='utf-8'))\n                except Exception:\n                    f.unlink(missing_ok=True); continue\n                res = run_job(job)\n                out = OUTBOX / f.name\n                out.write_text(json.dumps(res), encoding='utf-8')\n                try: f.unlink()\n                except Exception: pass\n        except Exception:\n            pass\n        time.sleep(0.25)\n\nthreading.Thread(target=file_worker, daemon=True).start()\nwrite_heartbeat()\nclass ReusableTCPServer(socketserver.TCPServer):\n    allow_reuse_address = True\nprint(f'forge-termux-agent v{VERSION} on 127.0.0.1:{PORT} root={ROOT}', flush=True)\nwith ReusableTCPServer(('127.0.0.1', PORT), H) as httpd:\n    httpd.serve_forever()\nPY\n";
    }

    /* JADX INFO: Access modifiers changed from: private */
    static class CommandSpec {
        ArrayList<String> argsList;
        boolean background;
        String cmdPath;
        String cwd;
        String description;
        String label;

        private CommandSpec() {
            this.argsList = new ArrayList<>();
            this.cwd = TermuxBridgePlugin.TERMUX_HOME;
            this.background = true;
            this.label = "Forge";
            this.description = "Command from Forge";
        }
    }

    private CommandSpec parseCommand(PluginCall call) {
        String script = call.getString("script", null);
        String command = call.getString("command", null);
        String str = TERMUX_HOME;
        String cwd = call.getString("cwd", TERMUX_HOME);
        boolean background = !Boolean.FALSE.equals(call.getBoolean("background", true));
        String label = call.getString("label", "Forge");
        String description = call.getString("description", "Command from Forge");
        CommandSpec spec = new CommandSpec();
        if (cwd != null) {
            str = cwd;
        }
        spec.cwd = str;
        spec.background = background;
        spec.label = label != null ? label : "Forge";
        spec.description = description != null ? description : "";
        if (script != null && !script.trim().isEmpty()) {
            spec.cmdPath = "/data/data/com.termux/files/usr/bin/bash";
            spec.argsList.add("-lc");
            spec.argsList.add(script);
        } else if (command != null && !command.trim().isEmpty()) {
            spec.cmdPath = resolveCommandPath(command.trim());
            JSArray args = call.getArray("args", new JSArray());
            if (args != null) {
                for (int i = 0; i < args.length(); i++) {
                    try {
                        spec.argsList.add(args.getString(i));
                    } catch (Exception e) {
                    }
                }
            }
        } else {
            throw new IllegalArgumentException("Provide 'script' (bash -lc) or 'command' + optional 'args'");
        }
        return spec;
    }

    private Intent buildRunIntent(CommandSpec spec, PendingIntent resultPi) {
        Intent intent = new Intent();
        intent.setClassName(TERMUX_PACKAGE, RUN_COMMAND_SERVICE);
        intent.setAction(ACTION_RUN_COMMAND);
        intent.putExtra(EXTRA_COMMAND_PATH, spec.cmdPath);
        intent.putExtra(EXTRA_ARGUMENTS, (String[]) spec.argsList.toArray(new String[0]));
        intent.putExtra(EXTRA_WORKDIR, spec.cwd != null ? spec.cwd : TERMUX_HOME);
        intent.putExtra(EXTRA_BACKGROUND, spec.background);
        intent.putExtra(EXTRA_SESSION_ACTION, 0);
        intent.putExtra(EXTRA_COMMAND_LABEL, spec.label != null ? spec.label : "Forge");
        intent.putExtra(EXTRA_COMMAND_DESCRIPTION, spec.description != null ? spec.description : "");
        if (resultPi != null) {
            intent.putExtra(EXTRA_PENDING_INTENT, resultPi);
        }
        return intent;
    }

    private JSObject baseStarted(CommandSpec spec) {
        JSArray argsOut = new JSArray();
        Iterator<String> it = spec.argsList.iterator();
        while (it.hasNext()) {
            String a = it.next();
            argsOut.put(a);
        }
        JSObject ret = new JSObject();
        ret.put("started", true);
        ret.put("commandPath", spec.cmdPath);
        ret.put("args", (Object) argsOut);
        ret.put("cwd", spec.cwd);
        ret.put("background", spec.background);
        return ret;
    }

    private String resolveCommandPath(String command) {
        return command.startsWith("/") ? command : "/data/data/com.termux/files/usr/bin/" + command;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static String nz(String s) {
        return s != null ? s : "";
    }

    private static String readStream(InputStream in) throws Exception {
        if (in == null) {
            return "";
        }
        BufferedReader br = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
        try {
            StringBuilder sb = new StringBuilder();
            char[] buf = new char[4096];
            while (true) {
                int n = br.read(buf);
                if (n < 0) {
                    String sb2 = sb.toString();
                    br.close();
                    return sb2;
                }
                sb.append(buf, 0, n);
            }
        } catch (Throwable th) {
            try {
                br.close();
            } catch (Throwable th2) {
                th.addSuppressed(th2);
            }
            throw th;
        }
    }

    private static String readFile(File f) throws Exception {
        FileInputStream in = new FileInputStream(f);
        try {
            String readStream = readStream(in);
            in.close();
            return readStream;
        } catch (Throwable th) {
            try {
                in.close();
            } catch (Throwable th2) {
                th.addSuppressed(th2);
            }
            throw th;
        }
    }

    private static void writeFile(File f, String content) throws Exception {
        File parent = f.getParentFile();
        if (parent != null && !parent.exists()) {
            parent.mkdirs();
        }
        FileOutputStream out = new FileOutputStream(f);
        try {
            out.write(content.getBytes(StandardCharsets.UTF_8));
            out.close();
        } catch (Throwable th) {
            try {
                out.close();
            } catch (Throwable th2) {
                th.addSuppressed(th2);
            }
            throw th;
        }
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnDestroy() {
        if (this.receiverRegistered && this.execReceiver != null) {
            try {
                getContext().unregisterReceiver(this.execReceiver);
            } catch (Exception e) {
            }
            this.receiverRegistered = false;
        }
        for (PluginCall c : this.pendingExec.values()) {
            try {
                c.reject("Termux bridge destroyed");
            } catch (Exception e2) {
            }
        }
        this.pendingExec.clear();
        this.ioPool.shutdownNow();
        super.handleOnDestroy();
    }
}
