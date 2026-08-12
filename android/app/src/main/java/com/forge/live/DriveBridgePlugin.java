package com.forge.live;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.UriPermission;
import android.database.Cursor;
import android.net.Uri;
import android.provider.DocumentsContract;
import android.util.Log;
import androidx.activity.result.ActivityResult;
import androidx.documentfile.provider.DocumentFile;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * Folder-based library backup via Storage Access Framework.
 * User picks a folder (Google Drive, Downloads, etc.); Forge stores
 * library/manifest + apps under a ForgeLibrary/ child.
 */
@CapacitorPlugin(name = "DriveBridge")
public class DriveBridgePlugin extends Plugin {
    private static final String TAG = "DriveBridge";
    private static final String PREFS = "forge_drive_bridge_v1";
    private static final String KEY_TREE_URI = "treeUri";
    private static final String KEY_DISPLAY = "displayName";
    private static final String ROOT_DIR = "ForgeLibrary";
    private static final int MAX_TEXT_BYTES = 12 * 1024 * 1024;

    private SharedPreferences prefs() {
        return getContext().getApplicationContext().getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject o = new JSObject();
        o.put("available", true);
        o.put("native", true);
        o.put("mode", "saf");
        o.put("note", "Pick a Google Drive (or any) folder for library backup/sync");
        call.resolve(o);
    }

    @PluginMethod
    public void status(PluginCall call) {
        call.resolve(statusObj());
    }

    @PluginMethod
    public void connect(PluginCall call) {
        call.setKeepAlive(true);
        try {
            Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION
                    | Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    | Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
                    | Intent.FLAG_GRANT_PREFIX_URI_PERMISSION);
            startActivityForResult(call, intent, "connectResult");
        } catch (Exception e) {
            call.reject("drive.connect failed: " + e.getMessage(), e);
        }
    }

    @ActivityCallback
    private void connectResult(PluginCall call, ActivityResult result) {
        if (call == null) {
            Log.e(TAG, "connectResult with null call");
            return;
        }
        try {
            if (result.getResultCode() != Activity.RESULT_OK || result.getData() == null) {
                JSObject o = statusObj();
                o.put("cancelled", true);
                call.resolve(o);
                return;
            }
            Uri tree = result.getData().getData();
            if (tree == null) {
                call.reject("No folder selected");
                return;
            }
            final int takeFlags = result.getData().getFlags()
                    & (Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            try {
                getContext().getContentResolver().takePersistableUriPermission(tree,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            } catch (Exception e) {
                try {
                    getContext().getContentResolver().takePersistableUriPermission(tree, takeFlags);
                } catch (Exception e2) {
                    Log.w(TAG, "takePersistableUriPermission: " + e2.getMessage());
                }
            }

            DocumentFile picked = DocumentFile.fromTreeUri(getContext(), tree);
            if (picked == null || !picked.canRead()) {
                call.reject("Cannot access selected folder");
                return;
            }
            String display = picked.getName();
            if (display == null || display.isEmpty()) {
                display = queryTreeLabel(tree);
            }
            if (display == null || display.isEmpty()) {
                display = "Backup folder";
            }

            // Ensure working root exists
            DocumentFile work = ensureChildDir(picked, ROOT_DIR);
            if (work == null) {
                call.reject("Could not create " + ROOT_DIR + " in selected folder");
                return;
            }

            prefs().edit()
                    .putString(KEY_TREE_URI, tree.toString())
                    .putString(KEY_DISPLAY, display)
                    .apply();

            JSObject o = statusObj();
            o.put("connected", true);
            o.put("cancelled", false);
            call.resolve(o);
        } catch (Exception e) {
            call.reject("drive.connect failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void disconnect(PluginCall call) {
        try {
            String uriStr = prefs().getString(KEY_TREE_URI, null);
            if (uriStr != null) {
                try {
                    Uri tree = Uri.parse(uriStr);
                    getContext().getContentResolver().releasePersistableUriPermission(tree,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                } catch (Exception e) {
                    Log.w(TAG, "releasePersistableUriPermission: " + e.getMessage());
                }
            }
            prefs().edit().remove(KEY_TREE_URI).remove(KEY_DISPLAY).apply();
            call.resolve(statusObj());
        } catch (Exception e) {
            call.reject("drive.disconnect failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void ensureDir(PluginCall call) {
        try {
            String path = normalizeRelPath(call.getString("path", ""));
            DocumentFile dir = resolveDir(path, true);
            if (dir == null) {
                call.reject("Could not create directory: " + path);
                return;
            }
            JSObject o = new JSObject();
            o.put("ok", true);
            o.put("path", path);
            o.put("name", dir.getName());
            call.resolve(o);
        } catch (Exception e) {
            call.reject("drive.ensureDir failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void list(PluginCall call) {
        try {
            String path = normalizeRelPath(call.getString("path", ""));
            DocumentFile dir = path.isEmpty() ? workRoot(false) : resolveDir(path, false);
            JSArray arr = new JSArray();
            if (dir != null && dir.isDirectory()) {
                DocumentFile[] kids = dir.listFiles();
                if (kids != null) {
                    for (DocumentFile f : kids) {
                        if (f == null) continue;
                        JSObject row = new JSObject();
                        String name = f.getName();
                        row.put("name", name != null ? name : "");
                        row.put("isDirectory", f.isDirectory());
                        row.put("isFile", f.isFile());
                        row.put("size", f.length());
                        row.put("lastModified", f.lastModified());
                        row.put("mime", f.getType());
                        arr.put(row);
                    }
                }
            }
            JSObject o = new JSObject();
            o.put("path", path);
            o.put("entries", arr);
            call.resolve(o);
        } catch (Exception e) {
            call.reject("drive.list failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void readText(PluginCall call) {
        try {
            String path = normalizeRelPath(call.getString("path", ""));
            if (path.isEmpty()) {
                call.reject("path required");
                return;
            }
            DocumentFile file = resolveFile(path, false);
            if (file == null || !file.isFile()) {
                call.reject("File not found: " + path);
                return;
            }
            if (file.length() > MAX_TEXT_BYTES) {
                call.reject("File too large (" + file.length() + " bytes)");
                return;
            }
            byte[] bytes = readAll(file);
            String text = new String(bytes, StandardCharsets.UTF_8);
            JSObject o = new JSObject();
            o.put("path", path);
            o.put("data", text);
            o.put("size", bytes.length);
            call.resolve(o);
        } catch (Exception e) {
            call.reject("drive.readText failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void writeText(PluginCall call) {
        try {
            String path = normalizeRelPath(call.getString("path", ""));
            String data = call.getString("data", null);
            if (path.isEmpty()) {
                call.reject("path required");
                return;
            }
            if (data == null) {
                call.reject("data required");
                return;
            }
            byte[] bytes = data.getBytes(StandardCharsets.UTF_8);
            if (bytes.length > MAX_TEXT_BYTES) {
                call.reject("Payload too large (" + bytes.length + " bytes)");
                return;
            }

            int slash = path.lastIndexOf('/');
            String dirPath = slash >= 0 ? path.substring(0, slash) : "";
            String fileName = slash >= 0 ? path.substring(slash + 1) : path;
            if (fileName.isEmpty()) {
                call.reject("invalid path");
                return;
            }

            DocumentFile dir = dirPath.isEmpty() ? workRoot(true) : resolveDir(dirPath, true);
            if (dir == null) {
                call.reject("Could not create parent dir for " + path);
                return;
            }

            String mime = mimeForName(fileName);
            DocumentFile file = findChild(dir, fileName);
            if (file != null && file.isDirectory()) {
                call.reject("Path is a directory: " + path);
                return;
            }
            if (file == null) {
                file = dir.createFile(mime, fileName);
            }
            if (file == null) {
                call.reject("Could not create file: " + path);
                return;
            }

            // Prefer truncate write; some providers need delete+recreate
            boolean wrote = writeBytes(file, bytes);
            if (!wrote) {
                try {
                    file.delete();
                } catch (Exception ignored) {
                }
                file = dir.createFile(mime, fileName);
                if (file == null || !writeBytes(file, bytes)) {
                    call.reject("Write failed: " + path);
                    return;
                }
            }

            JSObject o = new JSObject();
            o.put("ok", true);
            o.put("path", path);
            o.put("size", bytes.length);
            call.resolve(o);
        } catch (Exception e) {
            call.reject("drive.writeText failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void remove(PluginCall call) {
        try {
            String path = normalizeRelPath(call.getString("path", ""));
            if (path.isEmpty()) {
                call.reject("path required (refusing to delete backup root)");
                return;
            }
            DocumentFile target = resolveAny(path);
            if (target == null) {
                JSObject o = new JSObject();
                o.put("ok", true);
                o.put("removed", false);
                o.put("path", path);
                call.resolve(o);
                return;
            }
            boolean ok = deleteRecursive(target);
            JSObject o = new JSObject();
            o.put("ok", ok);
            o.put("removed", ok);
            o.put("path", path);
            call.resolve(o);
        } catch (Exception e) {
            call.reject("drive.remove failed: " + e.getMessage(), e);
        }
    }

    // ——— helpers ———

    private JSObject statusObj() {
        JSObject o = new JSObject();
        String uriStr = prefs().getString(KEY_TREE_URI, null);
        String display = prefs().getString(KEY_DISPLAY, null);
        boolean connected = false;
        if (uriStr != null && !uriStr.isEmpty()) {
            try {
                Uri tree = Uri.parse(uriStr);
                if (hasPersistedPermission(tree)) {
                    DocumentFile picked = DocumentFile.fromTreeUri(getContext(), tree);
                    if (picked != null && picked.canRead()) {
                        DocumentFile work = ensureChildDir(picked, ROOT_DIR);
                        connected = work != null && work.canRead();
                    }
                }
            } catch (Exception e) {
                connected = false;
            }
        }
        if (!connected && uriStr != null) {
            // Stale — clear quietly so UI can reconnect
            prefs().edit().remove(KEY_TREE_URI).remove(KEY_DISPLAY).apply();
            uriStr = null;
            display = null;
        }
        o.put("available", true);
        o.put("connected", connected);
        o.put("mode", "saf");
        o.put("displayName", connected ? (display != null ? display : "Backup folder") : "");
        o.put("rootDir", ROOT_DIR);
        o.put("treeUri", connected && uriStr != null ? uriStr : "");
        return o;
    }

    private boolean hasPersistedPermission(Uri tree) {
        try {
            List<UriPermission> perms = getContext().getContentResolver().getPersistedUriPermissions();
            for (UriPermission p : perms) {
                if (p.getUri() != null && p.getUri().equals(tree) && p.isReadPermission()) {
                    return true;
                }
            }
        } catch (Exception e) {
        }
        // Some devices still allow access even if list is empty after reboot briefly
        return true;
    }

    private Uri treeUriOrThrow() {
        String uriStr = prefs().getString(KEY_TREE_URI, null);
        if (uriStr == null || uriStr.isEmpty()) {
            throw new IllegalStateException("Not connected — pick a backup folder first");
        }
        return Uri.parse(uriStr);
    }

    private DocumentFile pickedRoot() {
        Uri tree = treeUriOrThrow();
        DocumentFile picked = DocumentFile.fromTreeUri(getContext(), tree);
        if (picked == null) {
            throw new IllegalStateException("Backup folder unavailable");
        }
        return picked;
    }

    private DocumentFile workRoot(boolean create) {
        DocumentFile picked = pickedRoot();
        DocumentFile work = findChild(picked, ROOT_DIR);
        if (work == null && create) {
            work = picked.createDirectory(ROOT_DIR);
        }
        if (work == null || !work.isDirectory()) {
            if (create) {
                throw new IllegalStateException("Could not open " + ROOT_DIR);
            }
            return null;
        }
        return work;
    }

    private DocumentFile ensureChildDir(DocumentFile parent, String name) {
        if (parent == null || name == null || name.isEmpty()) return null;
        DocumentFile existing = findChild(parent, name);
        if (existing != null) {
            if (existing.isDirectory()) return existing;
            return null;
        }
        return parent.createDirectory(name);
    }

    private DocumentFile findChild(DocumentFile parent, String name) {
        if (parent == null || name == null) return null;
        // Prefer direct findFile
        try {
            DocumentFile f = parent.findFile(name);
            if (f != null) return f;
        } catch (Exception e) {
        }
        try {
            DocumentFile[] kids = parent.listFiles();
            if (kids != null) {
                for (DocumentFile k : kids) {
                    if (k != null && name.equals(k.getName())) return k;
                }
            }
        } catch (Exception e) {
        }
        return null;
    }

    private String normalizeRelPath(String path) {
        if (path == null) return "";
        String p = path.trim().replace('\\', '/');
        while (p.startsWith("/")) p = p.substring(1);
        if (p.equals(".") || p.isEmpty()) return "";
        String[] parts = p.split("/");
        List<String> out = new ArrayList<>();
        for (String part : parts) {
            if (part == null || part.isEmpty() || ".".equals(part)) continue;
            if ("..".equals(part)) {
                throw new IllegalArgumentException("Path must not contain ..");
            }
            out.add(part);
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < out.size(); i++) {
            if (i > 0) sb.append('/');
            sb.append(out.get(i));
        }
        return sb.toString();
    }

    private DocumentFile resolveDir(String relPath, boolean create) {
        DocumentFile cur = workRoot(create);
        if (cur == null) return null;
        if (relPath == null || relPath.isEmpty()) return cur;
        String[] parts = relPath.split("/");
        for (String part : parts) {
            if (part.isEmpty()) continue;
            DocumentFile next = findChild(cur, part);
            if (next == null) {
                if (!create) return null;
                next = cur.createDirectory(part);
                if (next == null) return null;
            } else if (!next.isDirectory()) {
                return null;
            }
            cur = next;
        }
        return cur;
    }

    private DocumentFile resolveFile(String relPath, boolean create) {
        if (relPath == null || relPath.isEmpty()) return null;
        int slash = relPath.lastIndexOf('/');
        String dirPath = slash >= 0 ? relPath.substring(0, slash) : "";
        String name = slash >= 0 ? relPath.substring(slash + 1) : relPath;
        DocumentFile dir = dirPath.isEmpty() ? workRoot(create) : resolveDir(dirPath, create);
        if (dir == null) return null;
        DocumentFile f = findChild(dir, name);
        if (f != null && f.isFile()) return f;
        if (!create) return f;
        return null;
    }

    private DocumentFile resolveAny(String relPath) {
        if (relPath == null || relPath.isEmpty()) return workRoot(false);
        int slash = relPath.lastIndexOf('/');
        String dirPath = slash >= 0 ? relPath.substring(0, slash) : "";
        String name = slash >= 0 ? relPath.substring(slash + 1) : relPath;
        DocumentFile dir = dirPath.isEmpty() ? workRoot(false) : resolveDir(dirPath, false);
        if (dir == null) return null;
        return findChild(dir, name);
    }

    private byte[] readAll(DocumentFile file) throws Exception {
        try (InputStream in = getContext().getContentResolver().openInputStream(file.getUri())) {
            if (in == null) throw new IllegalStateException("openInputStream returned null");
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            int total = 0;
            while ((n = in.read(buf)) >= 0) {
                total += n;
                if (total > MAX_TEXT_BYTES) {
                    throw new IllegalStateException("File exceeds max size");
                }
                bos.write(buf, 0, n);
            }
            return bos.toByteArray();
        }
    }

    private boolean writeBytes(DocumentFile file, byte[] bytes) {
        try (OutputStream out = getContext().getContentResolver().openOutputStream(file.getUri(), "wt")) {
            if (out == null) {
                // fallback mode
                try (OutputStream out2 = getContext().getContentResolver().openOutputStream(file.getUri())) {
                    if (out2 == null) return false;
                    out2.write(bytes);
                    out2.flush();
                    return true;
                }
            }
            out.write(bytes);
            out.flush();
            return true;
        } catch (Exception e) {
            Log.w(TAG, "writeBytes: " + e.getMessage());
            return false;
        }
    }

    private boolean deleteRecursive(DocumentFile f) {
        if (f == null) return false;
        if (f.isDirectory()) {
            DocumentFile[] kids = f.listFiles();
            if (kids != null) {
                for (DocumentFile k : kids) {
                    deleteRecursive(k);
                }
            }
        }
        try {
            return f.delete();
        } catch (Exception e) {
            return false;
        }
    }

    private static String mimeForName(String name) {
        String n = name != null ? name.toLowerCase() : "";
        if (n.endsWith(".html") || n.endsWith(".htm")) return "text/html";
        if (n.endsWith(".json")) return "application/json";
        if (n.endsWith(".txt") || n.endsWith(".md")) return "text/plain";
        if (n.endsWith(".js")) return "text/javascript";
        if (n.endsWith(".css")) return "text/css";
        return "application/octet-stream";
    }

    private String queryTreeLabel(Uri tree) {
        try {
            // Best-effort label from documents contract
            String docId = DocumentsContract.getTreeDocumentId(tree);
            Uri docUri = DocumentsContract.buildDocumentUriUsingTree(tree, docId);
            try (Cursor c = getContext().getContentResolver().query(docUri,
                    new String[]{DocumentsContract.Document.COLUMN_DISPLAY_NAME}, null, null, null)) {
                if (c != null && c.moveToFirst()) {
                    return c.getString(0);
                }
            }
        } catch (Exception e) {
        }
        return null;
    }
}
