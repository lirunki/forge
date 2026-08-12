package com.forge.live;

import android.content.ContentResolver;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.OpenableColumns;
import android.util.Base64;
import android.util.Log;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Locale;

/**
 * Receives ACTION_VIEW / ACTION_SEND for HTML mini-apps (e.g. open/share from WhatsApp)
 * and exposes them to the Forge host for library import + run.
 */
@CapacitorPlugin(name = "OpenHtmlBridge")
public class OpenHtmlBridgePlugin extends Plugin {
    private static final String TAG = "OpenHtmlBridge";
    private static final long MAX_BYTES = 12L * 1024L * 1024L;

    private static final Object LOCK = new Object();
    private static PendingHtml pending;

    static final class PendingHtml {
        final String uri;
        final String name;
        final String mime;
        final String action;
        final String textExtra;
        final long receivedAt;

        PendingHtml(String uri, String name, String mime, String action, String textExtra) {
            this.uri = uri;
            this.name = name != null ? name : "";
            this.mime = mime != null ? mime : "";
            this.action = action != null ? action : "";
            this.textExtra = textExtra;
            this.receivedAt = System.currentTimeMillis();
        }
    }

    /** Called from MainActivity when a VIEW/SEND intent arrives. */
    public static boolean captureHtmlIntent(Intent intent) {
        if (intent == null) return false;
        String action = intent.getAction();
        if (action == null) return false;

        boolean isView = Intent.ACTION_VIEW.equals(action);
        boolean isSend = Intent.ACTION_SEND.equals(action);
        boolean isSendMultiple = Intent.ACTION_SEND_MULTIPLE.equals(action);
        if (!isView && !isSend && !isSendMultiple) return false;

        // Don't steal shortcut / forge://app deep links
        Uri data = intent.getData();
        if (data != null && "forge".equalsIgnoreCase(data.getScheme())) {
            return false;
        }
        if (Intent.ACTION_MAIN.equals(action)) return false;

        String mime = intent.getType();
        Uri stream = null;
        String textExtra = null;

        if (isView) {
            stream = data;
        } else if (isSend) {
            try {
                if (Build.VERSION.SDK_INT >= 33) {
                    stream = intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri.class);
                } else {
                    Object o = intent.getParcelableExtra(Intent.EXTRA_STREAM);
                    if (o instanceof Uri) stream = (Uri) o;
                }
            } catch (Exception e) {
                Log.w(TAG, "EXTRA_STREAM: " + e.getMessage());
            }
            try {
                textExtra = intent.getStringExtra(Intent.EXTRA_TEXT);
            } catch (Exception ignored) {
            }
        } else if (isSendMultiple) {
            try {
                java.util.ArrayList<Uri> list;
                if (Build.VERSION.SDK_INT >= 33) {
                    list = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri.class);
                } else {
                    list = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
                }
                if (list != null && !list.isEmpty()) stream = list.get(0);
            } catch (Exception e) {
                Log.w(TAG, "SEND_MULTIPLE: " + e.getMessage());
            }
        }

        if (stream == null && (textExtra == null || textExtra.trim().isEmpty())) {
            // VIEW without data
            if (data != null) stream = data;
        }
        if (stream == null && (textExtra == null || textExtra.trim().isEmpty())) {
            return false;
        }

        String name = "";
        String resolvedMime = mime != null ? mime : "";
        if (stream != null) {
            // name/mime resolved later with ContentResolver if possible; store uri now
            name = stream.getLastPathSegment() != null ? stream.getLastPathSegment() : "shared.html";
        } else {
            name = "shared.html";
            if (resolvedMime.isEmpty()) resolvedMime = "text/html";
        }

        // Soft filter: accept likely HTML; host will validate content
        if (!looksLikeHtmlCandidate(name, resolvedMime, textExtra, stream)) {
            Log.d(TAG, "Ignoring non-html intent mime=" + resolvedMime + " name=" + name);
            return false;
        }

        PendingHtml p = new PendingHtml(
                stream != null ? stream.toString() : null,
                name,
                resolvedMime,
                action,
                textExtra
        );
        synchronized (LOCK) {
            pending = p;
        }
        Log.d(TAG, "Captured html intent action=" + action + " uri=" + p.uri + " mime=" + p.mime);
        return true;
    }

    private static boolean looksLikeHtmlCandidate(String name, String mime, String text, Uri stream) {
        String m = mime != null ? mime.toLowerCase(Locale.US) : "";
        String n = name != null ? name.toLowerCase(Locale.US) : "";
        // Hard reject obvious non-HTML media so we do not steal photo/video shares
        if (m.startsWith("image/") || m.startsWith("video/") || m.startsWith("audio/")) return false;
        if (n.matches(".*\\.(png|jpe?g|gif|webp|mp4|mkv|mov|mp3|wav|pdf|apk)$")) return false;

        if (m.contains("html") || m.contains("xhtml")) return true;
        if (n.endsWith(".html") || n.endsWith(".htm") || n.contains(".html") || n.contains(".htm")) return true;

        if (text != null) {
            String tx = text.trim().toLowerCase(Locale.US);
            if (tx.contains("<html") || tx.contains("<!doctype html") || tx.contains("<script")) return true;
        }

        // WhatsApp / Files often use octet-stream, text/plain, or */* for documents
        if (m.equals("application/octet-stream") || m.equals("*/*") || m.isEmpty()
                || m.equals("text/plain") || m.equals("application/download")
                || m.startsWith("text/") || m.equals("application/xml")) {
            if (stream != null) {
                String s = stream.toString().toLowerCase(Locale.US);
                if (s.contains(".html") || s.contains(".htm")) return true;
            }
            // Generic document share: accept; host import rejects non-HTML content
            return true;
        }
        return false;
    }

    public void notifyPendingIfAny() {
        PendingHtml p;
        synchronized (LOCK) {
            p = pending;
        }
        if (p == null) return;
        try {
            JSObject o = new JSObject();
            o.put("pending", true);
            o.put("name", p.name);
            o.put("mime", p.mime);
            o.put("action", p.action);
            o.put("uri", p.uri != null ? p.uri : "");
            o.put("receivedAt", p.receivedAt);
            notifyListeners("htmlOpen", o, true);
        } catch (Exception e) {
            Log.w(TAG, "notify: " + e.getMessage());
        }
    }

    @Override
    protected void handleOnNewIntent(Intent intent) {
        super.handleOnNewIntent(intent);
        if (captureHtmlIntent(intent)) {
            notifyPendingIfAny();
        }
    }

    @Override
    protected void handleOnStart() {
        super.handleOnStart();
        try {
            if (getActivity() != null && captureHtmlIntent(getActivity().getIntent())) {
                notifyPendingIfAny();
            }
        } catch (Exception ignored) {
        }
    }

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject o = new JSObject();
        o.put("available", true);
        o.put("native", true);
        call.resolve(o);
    }

    @PluginMethod
    public void hasPending(PluginCall call) {
        JSObject o = new JSObject();
        synchronized (LOCK) {
            o.put("pending", pending != null);
            if (pending != null) {
                o.put("name", pending.name);
                o.put("mime", pending.mime);
                o.put("action", pending.action);
                o.put("uri", pending.uri != null ? pending.uri : "");
                o.put("receivedAt", pending.receivedAt);
            }
        }
        call.resolve(o);
    }

    /**
     * Consume pending open/share: read HTML text and clear pending.
     * Returns { cancelled, name, mime, html, source, size }
     */
    @PluginMethod
    public void consume(PluginCall call) {
        call.setKeepAlive(true);
        PendingHtml p;
        synchronized (LOCK) {
            p = pending;
            pending = null;
        }
        if (p == null) {
            JSObject o = new JSObject();
            o.put("cancelled", true);
            o.put("pending", false);
            call.resolve(o);
            return;
        }

        new Thread(() -> {
            try {
                JSObject o = readPending(p);
                o.put("cancelled", false);
                o.put("pending", false);
                getActivity().runOnUiThread(() -> call.resolve(o));
            } catch (Exception e) {
                Log.e(TAG, "consume failed", e);
                getActivity().runOnUiThread(() -> call.reject("open html failed: " + e.getMessage(), e));
            }
        }, "forge-open-html").start();
    }

    @PluginMethod
    public void clear(PluginCall call) {
        synchronized (LOCK) {
            pending = null;
        }
        JSObject o = new JSObject();
        o.put("ok", true);
        call.resolve(o);
    }

    private JSObject readPending(PendingHtml p) throws Exception {
        String name = p.name;
        String mime = p.mime;
        String html = null;

        if (p.uri != null && !p.uri.isEmpty()) {
            Uri uri = Uri.parse(p.uri);
            // Take read permission if granted on the intent (best-effort)
            try {
                getContext().getContentResolver().takePersistableUriPermission(
                        uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            } catch (Exception ignored) {
            }

            String qName = queryDisplayName(uri);
            if (qName != null && !qName.isEmpty()) name = qName;
            String qMime = getContext().getContentResolver().getType(uri);
            if (qMime != null && !qMime.isEmpty()) mime = qMime;
            if (mime == null || mime.isEmpty()) mime = guessMime(name);

            byte[] bytes = readAll(uri, MAX_BYTES);
            html = new String(bytes, StandardCharsets.UTF_8);
            // strip BOM
            if (!html.isEmpty() && html.charAt(0) == '\uFEFF') {
                html = html.substring(1);
            }
        } else if (p.textExtra != null) {
            html = p.textExtra;
            if (name == null || name.isEmpty()) name = "shared.html";
            if (mime == null || mime.isEmpty()) mime = "text/html";
        }

        if (html == null) {
            throw new IllegalStateException("No HTML content in share/open intent");
        }

        // If name lacks extension but content is html, fix name
        String nl = name != null ? name.toLowerCase(Locale.US) : "";
        if (!nl.endsWith(".html") && !nl.endsWith(".htm")) {
            String low = html.length() > 200 ? html.substring(0, 200).toLowerCase(Locale.US) : html.toLowerCase(Locale.US);
            if (low.contains("<html") || low.contains("<!doctype") || low.contains("<script")) {
                if (name == null || name.isEmpty() || "file".equals(name) || name.contains(":")) {
                    name = "shared.html";
                } else if (!name.contains(".")) {
                    name = name + ".html";
                }
                if (mime == null || mime.isEmpty() || "application/octet-stream".equals(mime) || "*/*".equals(mime)) {
                    mime = "text/html";
                }
            }
        }

        JSObject o = new JSObject();
        o.put("name", sanitizeName(name));
        o.put("mime", mime != null ? mime : "text/html");
        o.put("type", mime != null ? mime : "text/html");
        o.put("html", html);
        o.put("size", html.getBytes(StandardCharsets.UTF_8).length);
        o.put("source", p.action != null ? p.action : "intent");
        o.put("uri", p.uri != null ? p.uri : "");
        // also provide base64 for importHtmlFile path compatibility
        try {
            String b64 = Base64.encodeToString(html.getBytes(StandardCharsets.UTF_8), Base64.NO_WRAP);
            o.put("base64", b64);
            o.put("dataUrl", "data:text/html;charset=utf-8;base64," + b64);
        } catch (Exception ignored) {
        }
        return o;
    }

    private byte[] readAll(Uri uri, long maxBytes) throws Exception {
        ContentResolver cr = getContext().getContentResolver();
        try (InputStream in = cr.openInputStream(uri)) {
            if (in == null) throw new IllegalStateException("Cannot open " + uri);
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            byte[] buf = new byte[16384];
            long total = 0;
            int n;
            while ((n = in.read(buf)) >= 0) {
                total += n;
                if (total > maxBytes) {
                    throw new IllegalStateException("File too large (max " + maxBytes + " bytes)");
                }
                bos.write(buf, 0, n);
            }
            return bos.toByteArray();
        }
    }

    private String queryDisplayName(Uri uri) {
        Cursor c = null;
        try {
            c = getContext().getContentResolver().query(uri,
                    new String[]{OpenableColumns.DISPLAY_NAME}, null, null, null);
            if (c != null && c.moveToFirst()) {
                int idx = c.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                if (idx >= 0) return c.getString(idx);
            }
        } catch (Exception ignored) {
        } finally {
            if (c != null) try { c.close(); } catch (Exception ignored) {}
        }
        try {
            String last = uri.getLastPathSegment();
            if (last != null) {
                // content providers often use "raw:/.../file.html" or encoded names
                int slash = Math.max(last.lastIndexOf('/'), last.lastIndexOf(':'));
                if (slash >= 0 && slash + 1 < last.length()) last = last.substring(slash + 1);
                return Uri.decode(last);
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    private static String guessMime(String name) {
        String n = name != null ? name.toLowerCase(Locale.US) : "";
        if (n.endsWith(".html") || n.endsWith(".htm")) return "text/html";
        if (n.endsWith(".txt")) return "text/plain";
        return "application/octet-stream";
    }

    private static String sanitizeName(String name) {
        if (name == null || name.isEmpty()) return "shared.html";
        String n = name.replaceAll("[\\\\/:*?\"<>|]", "_").trim();
        if (n.isEmpty()) return "shared.html";
        // strip crazy long provider paths
        if (n.length() > 120) n = n.substring(n.length() - 120);
        return n;
    }
}
