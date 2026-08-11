package com.forge.live;

import android.content.ClipData;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.util.Base64;
import android.util.Log;
import androidx.activity.result.ActivityResult;
import androidx.webkit.internal.AssetHelper;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@CapacitorPlugin(name = "FilesBridge")
/* loaded from: classes4.dex */
public class FilesBridgePlugin extends Plugin {
    private static final long DEFAULT_MAX_BYTES = 26214400;
    private static final long HARD_MAX_BYTES = 41943040;
    private static final long INLINE_BASE64_MAX = 1433600;
    private boolean pendingMultiple = false;
    private long pendingMaxBytes = DEFAULT_MAX_BYTES;

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject o = new JSObject();
        o.put("available", true);
        o.put("native", true);
        o.put("maxBytes", DEFAULT_MAX_BYTES);
        o.put("inlineMaxBytes", INLINE_BASE64_MAX);
        o.put("note", "System document picker; large files returned via cache path");
        call.resolve(o);
    }

    @PluginMethod
    public void readStaged(PluginCall call) {
        call.setKeepAlive(true);
        try {
            String path = call.getString("path", "");
            if (path != null && !path.isEmpty()) {
                File f = new File(path);
                File cacheRoot = new File(getContext().getCacheDir(), "forge_picks");
                String root = cacheRoot.getCanonicalPath();
                String target = f.getCanonicalPath();
                if (!target.startsWith(root + File.separator) && !target.equals(root)) {
                    call.reject("path not allowed");
                    return;
                }
                if (!f.isFile()) {
                    call.reject("file not found");
                    return;
                }
                long max = 28672000;
                try {
                    if (call.getData() != null && call.getData().has("maxBytes")) {
                        max = (long) call.getData().getDouble("maxBytes");
                    }
                } catch (Exception e) {
                }
                if (f.length() > max) {
                    call.reject("File too large to read (" + f.length() + " > " + max + ")");
                    return;
                }
                byte[] bytes = readFileBytes(f, max);
                String mime = call.getString("mime", "application/octet-stream");
                if (mime == null || mime.isEmpty()) {
                    mime = "application/octet-stream";
                }
                String b64 = Base64.encodeToString(bytes, 2);
                JSObject o = new JSObject();
                o.put("name", f.getName());
                o.put("path", f.getAbsolutePath());
                o.put("size", bytes.length);
                o.put("mime", mime);
                o.put("type", mime);
                o.put("base64", b64);
                o.put("dataUrl", "data:" + mime + ";base64," + b64);
                call.resolve(o);
                return;
            }
            call.reject("path required");
        } catch (Exception e2) {
            call.reject("readStaged failed: " + e2.getMessage(), e2);
        }
    }

    @PluginMethod
    public void pick(PluginCall call) {
        call.setKeepAlive(true);
        boolean multiple = Boolean.TRUE.equals(call.getBoolean("multiple", false));
        this.pendingMultiple = multiple;
        long max = DEFAULT_MAX_BYTES;
        try {
            if (call.getData() != null && call.getData().has("maxBytes")) {
                max = (long) call.getData().getDouble("maxBytes");
            }
        } catch (Exception e) {
        }
        if (max <= 0) {
            max = DEFAULT_MAX_BYTES;
        }
        if (max > HARD_MAX_BYTES) {
            max = HARD_MAX_BYTES;
        }
        this.pendingMaxBytes = max;
        try {
            if (call.getData() != null) {
                call.getData().put("_forgeMultiple", multiple);
                call.getData().put("_forgeMaxBytes", max);
            }
        } catch (Exception e2) {
        }
        String accept = call.getString("accept", "*/*");
        try {
            Intent intent = new Intent("android.intent.action.OPEN_DOCUMENT");
            intent.addCategory("android.intent.category.OPENABLE");
            intent.addFlags(1);
            intent.addFlags(64);
            if (1 != 0) {
                intent.setType("*/*");
            } else {
                String[] mimes = parseAccept(accept);
                if (mimes.length == 1) {
                    intent.setType(mimes[0]);
                } else {
                    intent.setType("*/*");
                    intent.putExtra("android.intent.extra.MIME_TYPES", mimes);
                }
            }
            if (multiple) {
                intent.putExtra("android.intent.extra.ALLOW_MULTIPLE", true);
            }
            startActivityForResult(call, intent, "pickResult");
        } catch (Exception e3) {
            try {
                Intent intent2 = new Intent("android.intent.action.GET_CONTENT");
                intent2.addCategory("android.intent.category.OPENABLE");
                intent2.setType("*/*");
                intent2.addFlags(1);
                if (multiple) {
                    intent2.putExtra("android.intent.extra.ALLOW_MULTIPLE", true);
                }
                startActivityForResult(call, Intent.createChooser(intent2, "Choose file"), "pickResult");
            } catch (Exception e22) {
                call.reject("files.pick failed: " + e22.getMessage(), e22);
            }
        }
    }

    private boolean callMultiple(PluginCall call) {
        try {
            if (call.getData() != null && call.getData().has("_forgeMultiple")) {
                Object v = call.getData().get("_forgeMultiple");
                if (v instanceof Boolean) {
                    return ((Boolean) v).booleanValue();
                }
                if (v != null) {
                    return Boolean.parseBoolean(String.valueOf(v));
                }
            }
        } catch (Exception e) {
        }
        return this.pendingMultiple;
    }

    private long callMaxBytes(PluginCall call) {
        try {
            if (call.getData() != null && call.getData().has("_forgeMaxBytes")) {
                Object v = call.getData().get("_forgeMaxBytes");
                if (v instanceof Number) {
                    return ((Number) v).longValue();
                }
                if (v != null) {
                    return (long) Double.parseDouble(String.valueOf(v));
                }
            }
        } catch (Exception e) {
        }
        long j = this.pendingMaxBytes;
        return j > 0 ? j : DEFAULT_MAX_BYTES;
    }

    @ActivityCallback
    private void pickResult(PluginCall call, ActivityResult result) {
        if (call == null) {
            Log.e("FilesBridge", "pickResult called with null call (keepAlive probably failed)");
            return;
        }
        Log.d("FilesBridge", "pickResult received, resultCode=" + result.getResultCode() + " data=" + (result.getData() != null ? "yes" : "no"));
        if (result.getData() != null) {
            Log.d("FilesBridge", "  uri=" + result.getData().getData() + " clipCount=" + (result.getData().getClipData() != null ? result.getData().getClipData().getItemCount() : 0));
        }
        boolean multiple = callMultiple(call);
        long maxBytes = callMaxBytes(call);
        try {
            if (result.getResultCode() != -1) {
                Log.d("FilesBridge", "user cancelled or no selection");
                call.resolve(cancelObj());
                return;
            }
            Intent data = result.getData();
            List<Uri> uris = new ArrayList<>();
            if (data != null) {
                ClipData clip = data.getClipData();
                if (clip != null && clip.getItemCount() > 0) {
                    for (int i = 0; i < clip.getItemCount(); i++) {
                        Uri u = clip.getItemAt(i).getUri();
                        if (u != null) {
                            uris.add(u);
                        }
                    }
                } else if (data.getData() != null) {
                    uris.add(data.getData());
                }
            }
            if (uris.isEmpty()) {
                call.resolve(cancelObj());
                return;
            }
            JSArray okFiles = new JSArray();
            String lastErr = null;
            JSObject first = null;
            for (Uri uri : uris) {
                try {
                    getContext().getContentResolver().takePersistableUriPermission(uri, 1);
                } catch (Exception e) {
                }
                try {
                    JSObject file = readUri(uri, maxBytes);
                    if (first == null) {
                        first = file;
                    }
                    okFiles.put(file);
                } catch (Exception ex) {
                    try {
                        lastErr = ex.getMessage();
                    } catch (Exception e2) {
                        e = e2;
                        call.reject("pickResult failed: " + e.getMessage(), e);
                        return;
                    }
                }
            }
            if (okFiles.length() == 0) {
                Log.w("FilesBridge", "No readable files after processing URIs, lastErr=" + lastErr);
                call.reject(lastErr != null ? lastErr : "Could not read selected file(s)");
                return;
            }
            if (multiple) {
                JSObject o = new JSObject();
                o.put("files", (Object) okFiles);
                o.put("cancelled", false);
                o.put("count", okFiles.length());
                Log.d("FilesBridge", "resolving multiple, count=" + okFiles.length());
                call.resolve(o);
                return;
            }
            if (first == null) {
                call.reject("Failed to read file");
                return;
            }
            first.put("cancelled", false);
            Log.d("FilesBridge", "resolving single file: " + first.getString("name") + " size=" + first.get("size") + " inline=" + first.get("inline"));
            call.resolve(first);
        } catch (Exception e3) {
            e = e3;
        }
    }

    private static JSObject cancelObj() {
        JSObject o = new JSObject();
        o.put("cancelled", true);
        o.put("files", (Object) new JSArray());
        o.put("count", 0);
        return o;
    }

    /* JADX WARN: Code restructure failed: missing block: B:64:0x00e9, code lost:
    
        r7 = r16;
     */
    /* JADX WARN: Code restructure failed: missing block: B:66:0x00eb, code lost:
    
        r0.delete();
     */
    /* JADX WARN: Code restructure failed: missing block: B:73:0x0111, code lost:
    
        r7 = r16;
     */
    /* JADX WARN: Code restructure failed: missing block: B:75:0x0117, code lost:
    
        r7.flush();
     */
    /* JADX WARN: Code restructure failed: missing block: B:77:0x011a, code lost:
    
        r7.close();
     */
    /* JADX WARN: Code restructure failed: missing block: B:78:0x011d, code lost:
    
        if (r9 == null) goto L54;
     */
    /* JADX WARN: Code restructure failed: missing block: B:79:0x011f, code lost:
    
        r9.close();
     */
    /* JADX WARN: Code restructure failed: missing block: B:80:0x0122, code lost:
    
        r0 = new com.getcapacitor.JSObject();
        r0.put("name", r4);
        r0.put("type", r6);
        r0.put("mime", r6);
        r0.put("size", r14);
        r0.put("path", r0.getAbsolutePath());
        r0.put("uri", r21.toString());
     */
    /* JADX WARN: Code restructure failed: missing block: B:82:0x014f, code lost:
    
        r0 = androidx.core.content.FileProvider.getUriForFile(getContext(), getContext().getPackageName() + ".fileprovider", r0);
        r0.put("contentUri", r0.toString());
     */
    /* JADX WARN: Code restructure failed: missing block: B:93:0x01d9, code lost:
    
        r0 = move-exception;
     */
    /* JADX WARN: Code restructure failed: missing block: B:94:0x01da, code lost:
    
        r1 = r0;
     */
    /* JADX WARN: Code restructure failed: missing block: B:96:0x01de, code lost:
    
        r0 = move-exception;
     */
    /* JADX WARN: Code restructure failed: missing block: B:97:0x01df, code lost:
    
        r1 = r0;
     */
    /* JADX WARN: Removed duplicated region for block: B:50:0x0200 A[EXC_TOP_SPLITTER, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:57:? A[SYNTHETIC] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    private JSObject readUri(Uri uri, long maxBytes) throws Exception {
        File out;
        long total;
        Throwable th;
        FileOutputStream fos;
        Throwable th2;
        byte[] buf;
        JSObject o;
        String name = queryDisplayName(uri);
        if (name == null || name.isEmpty()) {
            name = "file";
        }
        String name2 = name.replaceAll("[\\\\/:*?\"<>|]", "_");
        String mime = getContext().getContentResolver().getType(uri);
        String mime2 = (mime == null || mime.isEmpty()) ? guessMimeFromName(name2) : mime;
        long declared = querySize(uri);
        if (declared > maxBytes) {
            throw new Exception("File too large (" + declared + " bytes). Max " + maxBytes);
        }
        InputStream in = getContext().getContentResolver().openInputStream(uri);
        if (in == null) {
            throw new Exception("Cannot open file");
        }
        File dir = new File(getContext().getCacheDir(), "forge_picks");
        if (!dir.exists() && !dir.mkdirs() && !dir.exists()) {
            dir.mkdirs();
        }
        if (!dir.exists() || !dir.isDirectory()) {
            in.close();
            throw new Exception("Cannot create forge_picks cache dir");
        }
        String safe = UUID.randomUUID().toString().replace("-", "").substring(0, 12) + "_" + name2;
        out = new File(dir, safe);
        total = 0;
        try {
            FileOutputStream fos2 = new FileOutputStream(out);
            try {
                buf = new byte[16384];
            } catch (Throwable th3) {
                fos = fos2;
                th2 = th3;
            }
            while (true) {
                byte[] buf2 = buf;
                int n = in.read(buf2);
                if (n < 0) {
                    break;
                }
                long declared2 = declared;
                total += n;
                if (total > maxBytes) {
                    break;
                }
                fos = fos2;
                try {
                    fos.write(buf2, 0, n);
                    fos2 = fos;
                    buf = buf2;
                    declared = declared2;
                } catch (Throwable th4) {
                    th2 = th4;
                }
                th2 = th4;
                try {
                    try {
                        fos.close();
                        throw th2;
                    } catch (Throwable th5) {
                        th = th5;
                        if (in != null) {
                            throw th;
                        }
                        try {
                            in.close();
                            throw th;
                        } catch (Throwable th6) {
                            th.addSuppressed(th6);
                            throw th;
                        }
                    }
                } catch (Throwable th7) {
                    th2.addSuppressed(th7);
                    throw th2;
                }
            }
        } catch (Throwable th8) {
            th = th8;
        }
        throw new Exception("File too large while reading. Max " + maxBytes + " bytes");
        if (total > 0 && total <= INLINE_BASE64_MAX) {
            byte[] bytes = readFileBytes(out, INLINE_BASE64_MAX);
            String b64 = Base64.encodeToString(bytes, 2);
            o.put("base64", b64);
            o.put("dataUrl", "data:" + mime2 + ";base64," + b64);
            o.put("inline", true);
        } else {
            o.put("inline", false);
            o.put("base64", (String) null);
            o.put("dataUrl", (String) null);
            o.put("note", "File staged on disk; use path/readStaged for content");
        }
        return o;
    }

    private static byte[] readFileBytes(File f, long max) throws Exception {
        int n;
        long len = f.length();
        if (len > max) {
            throw new Exception("File too large");
        }
        byte[] data = new byte[(int) len];
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

    private static String guessMimeFromName(String name) {
        String n = name.toLowerCase();
        if (n.endsWith(".html") || n.endsWith(".htm")) {
            return "text/html";
        }
        if (n.endsWith(".json")) {
            return "application/json";
        }
        if (n.endsWith(".txt")) {
            return AssetHelper.DEFAULT_MIME_TYPE;
        }
        if (n.endsWith(".pdf")) {
            return "application/pdf";
        }
        if (n.endsWith(".png")) {
            return "image/png";
        }
        if (n.endsWith(".jpg") || n.endsWith(".jpeg")) {
            return "image/jpeg";
        }
        return n.endsWith(".gif") ? "image/gif" : n.endsWith(".webp") ? "image/webp" : n.endsWith(".svg") ? "image/svg+xml" : n.endsWith(".wav") ? "audio/wav" : n.endsWith(".mp3") ? "audio/mpeg" : "application/octet-stream";
    }

    private String queryDisplayName(Uri uri) {
        int idx;
        try {
            Cursor c = getContext().getContentResolver().query(uri, null, null, null, null);
            if (c != null) {
                try {
                    if (c.moveToFirst() && (idx = c.getColumnIndex("_display_name")) >= 0) {
                        String string = c.getString(idx);
                        if (c != null) {
                            c.close();
                        }
                        return string;
                    }
                } finally {
                }
            }
            if (c != null) {
                c.close();
            }
        } catch (Exception e) {
        }
        String last = uri.getLastPathSegment();
        return last != null ? last : "file";
    }

    private long querySize(Uri uri) {
        int idx;
        try {
            Cursor c = getContext().getContentResolver().query(uri, null, null, null, null);
            if (c != null) {
                try {
                    if (c.moveToFirst() && (idx = c.getColumnIndex("_size")) >= 0 && !c.isNull(idx)) {
                        long j = c.getLong(idx);
                        if (c != null) {
                            c.close();
                        }
                        return j;
                    }
                } finally {
                }
            }
            if (c != null) {
                c.close();
                return -1L;
            }
            return -1L;
        } catch (Exception e) {
            return -1L;
        }
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    /* JADX WARN: Code restructure failed: missing block: B:51:0x0083, code lost:
    
        if (r9.equals("png") != false) goto L51;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    private static String[] parseAccept(String accept) {
        if (accept == null || accept.trim().isEmpty()) {
            return new String[]{"*/*"};
        }
        String[] parts = accept.split(",");
        ArrayList<String> out = new ArrayList<>();
        for (String p : parts) {
            String t = p.trim();
            if (!t.isEmpty()) {
                if (t.startsWith(".")) {
                    char c = 1;
                    String ext = t.substring(1).toLowerCase();
                    switch (ext.hashCode()) {
                        case 98822:
                            if (ext.equals("csv")) {
                                c = 7;
                                break;
                            }
                            c = 65535;
                            break;
                        case 102340:
                            if (ext.equals("gif")) {
                                c = 4;
                                break;
                            }
                            c = 65535;
                            break;
                        case 103649:
                            if (ext.equals("htm")) {
                                c = '\n';
                                break;
                            }
                            c = 65535;
                            break;
                        case 105441:
                            if (ext.equals("jpg")) {
                                c = 2;
                                break;
                            }
                            c = 65535;
                            break;
                        case 110834:
                            if (ext.equals("pdf")) {
                                c = 0;
                                break;
                            }
                            c = 65535;
                            break;
                        case 111145:
                            break;
                        case 115312:
                            if (ext.equals("txt")) {
                                c = 6;
                                break;
                            }
                            c = 65535;
                            break;
                        case 3213227:
                            if (ext.equals("html")) {
                                c = '\t';
                                break;
                            }
                            c = 65535;
                            break;
                        case 3268712:
                            if (ext.equals("jpeg")) {
                                c = 3;
                                break;
                            }
                            c = 65535;
                            break;
                        case 3271912:
                            if (ext.equals("json")) {
                                c = '\b';
                                break;
                            }
                            c = 65535;
                            break;
                        case 3645340:
                            if (ext.equals("webp")) {
                                c = 5;
                                break;
                            }
                            c = 65535;
                            break;
                        default:
                            c = 65535;
                            break;
                    }
                    switch (c) {
                        case 0:
                            out.add("application/pdf");
                            break;
                        case 1:
                            out.add("image/png");
                            break;
                        case 2:
                        case 3:
                            out.add("image/jpeg");
                            break;
                        case 4:
                            out.add("image/gif");
                            break;
                        case 5:
                            out.add("image/webp");
                            break;
                        case 6:
                            out.add(AssetHelper.DEFAULT_MIME_TYPE);
                            break;
                        case 7:
                            out.add("text/csv");
                            break;
                        case '\b':
                            out.add("application/json");
                            break;
                        case '\t':
                        case '\n':
                            out.add("text/html");
                            break;
                        default:
                            out.add("*/*");
                            break;
                    }
                } else {
                    out.add(t);
                }
            }
        }
        if (out.isEmpty()) {
            out.add("*/*");
        }
        return (String[]) out.toArray(new String[0]);
    }
}
