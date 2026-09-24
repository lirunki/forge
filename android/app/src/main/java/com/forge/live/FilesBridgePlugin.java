package com.forge.live;

import androidx.core.content.FileProvider;

import android.app.Activity;
import android.content.ClipData;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.util.Base64;
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
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@CapacitorPlugin(
        name = "FilesBridge",
        permissions = {
            @com.getcapacitor.annotation.Permission(alias = "audio", strings = {"android.permission.READ_MEDIA_AUDIO"})
        })
public class FilesBridgePlugin extends Plugin {
    private static final long DEFAULT_MAX_BYTES = 26214400;
    // Large media files are streamed to the private staging cache and then
    // to Termux; keep a generous ceiling without changing the default pick limit.
    private static final long HARD_MAX_BYTES = 268435456;
    private static final long INLINE_BASE64_MAX = 1433600;
    private boolean pendingMultiple = false;
    private long pendingMaxBytes = DEFAULT_MAX_BYTES;
    private boolean pendingAllowInline = true;
    private static final String STAGING_PREFS = "forge_staging_v1";
    private static final String STAGING_TREE_URI = "treeUri";
    private static final String STAGING_DISPLAY = "displayName";
    private static final String STAGING_INTERNAL = "internal";
    private static final String STAGING_CHILD = "ForgeStaging";

    private SharedPreferences stagingPrefs() {
        return getContext().getApplicationContext().getSharedPreferences(STAGING_PREFS, android.content.Context.MODE_PRIVATE);
    }

    private File internalStagingDir() {
        return new File(getContext().getCacheDir(), "forge_staging");
    }

    private File pickerCacheDir() {
        return new File(getContext().getCacheDir(), "forge_picks");
    }

    private File legacySharedStagingDir() {
        return new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "Forge/Staging");
    }

    private boolean hasSelectedFolder() {
        String uri = stagingPrefs().getString(STAGING_TREE_URI, null);
        return uri != null && !uri.isEmpty();
    }

    private String internalDisplayName() {
        try { return internalStagingDir().getCanonicalPath(); }
        catch (Exception e) { return internalStagingDir().getAbsolutePath(); }
    }

    private String stagingDisplay() {
        if (!hasSelectedFolder()) return internalDisplayName();
        String saved = stagingPrefs().getString(STAGING_DISPLAY, null);
        if (saved != null && !saved.isEmpty()) return saved;
        DocumentFile root = DocumentFile.fromTreeUri(getContext(), Uri.parse(stagingPrefs().getString(STAGING_TREE_URI, "")));
        String name = root == null ? null : root.getName();
        if (name == null || name.isEmpty()) return stagingPrefs().getString(STAGING_TREE_URI, "selected folder");
        return STAGING_CHILD.equals(name) ? name : name + "/" + STAGING_CHILD;
    }

    private JSObject stagingInfo(boolean ok) {
        JSObject o = new JSObject();
        if (ok) o.put("ok", true);
        String uri = stagingPrefs().getString(STAGING_TREE_URI, null);
        boolean folder = uri != null && !uri.isEmpty();
        o.put("mode", folder ? "folder" : STAGING_INTERNAL);
        o.put("displayName", stagingDisplay());
        if (folder) o.put("uri", uri);
        o.put("internalPath", internalDisplayName());
        return o;
    }

    private DocumentFile managedStagingFolder(boolean create) throws Exception {
        String uri = stagingPrefs().getString(STAGING_TREE_URI, null);
        if (uri == null || uri.isEmpty()) return null;
        DocumentFile root = DocumentFile.fromTreeUri(getContext(), Uri.parse(uri));
        if (root == null || !root.exists() || !root.canRead()) throw new Exception("selected staging folder is no longer available");
        if (create && !root.canWrite()) throw new Exception("selected staging folder is no longer available");
        if (STAGING_CHILD.equals(root.getName())) return root;
        DocumentFile child = root.findFile(STAGING_CHILD);
        if (child != null && !child.isDirectory()) child = null;
        if (child == null && create) child = root.createDirectory(STAGING_CHILD);
        if (child == null || !child.isDirectory()) {
            if (!create) return null;
            throw new Exception("Could not open " + STAGING_CHILD + " inside selected folder");
        }
        if (create && !child.canWrite()) throw new Exception("selected staging folder is no longer available");
        return child;
    }

    private boolean isUnder(File file, File root) {
        if (file == null || root == null) return false;
        try {
            String path = file.getCanonicalPath();
            String base = root.getCanonicalPath();
            return path.equals(base) || path.startsWith(base + File.separator);
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isAllowedStagingFile(File file) {
        return isUnder(file, internalStagingDir())
                || isUnder(file, pickerCacheDir())
                || isUnder(file, legacySharedStagingDir());
    }

    @PluginMethod
    public void stagingStatus(PluginCall call) {
        call.resolve(stagingInfo(true));
    }

    @PluginMethod
    public void useInternalStaging(PluginCall call) {
        stagingPrefs().edit()
                .remove(STAGING_TREE_URI)
                .putString("mode", STAGING_INTERNAL)
                .putString(STAGING_DISPLAY, internalDisplayName())
                .apply();
        call.resolve(stagingInfo(true));
    }

    @PluginMethod
    public void pickStagingFolder(PluginCall call) {
        call.setKeepAlive(true);
        try {
            Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    | Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION | Intent.FLAG_GRANT_PREFIX_URI_PERMISSION);
            startActivityForResult(call, intent, "stagingFolderResult");
        } catch (Exception e) { call.reject("files.pickStagingFolder failed: " + e.getMessage(), e); }
    }

    @ActivityCallback
    private void stagingFolderResult(PluginCall call, ActivityResult result) {
        if (call == null) return;
        try {
            if (result.getResultCode() != Activity.RESULT_OK || result.getData() == null || result.getData().getData() == null) {
                call.resolve(new JSObject().put("cancelled", true)); return;
            }
            Uri tree = result.getData().getData();
            final int readWrite = Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION;
            int flags = result.getData().getFlags() & readWrite;
            if (flags == 0) flags = readWrite;
            boolean persisted = false;
            try {
                getContext().getContentResolver().takePersistableUriPermission(tree, flags);
                persisted = true;
            } catch (Exception first) {
                try {
                    getContext().getContentResolver().takePersistableUriPermission(tree, readWrite);
                    persisted = true;
                } catch (Exception ignored) {
                }
            }
            if (!persisted) { call.reject("Could not retain permission for selected staging folder"); return; }
            DocumentFile picked = DocumentFile.fromTreeUri(getContext(), tree);
            if (picked == null || !picked.canRead() || !picked.canWrite()) { call.reject("Cannot write selected staging folder"); return; }
            DocumentFile folder = STAGING_CHILD.equals(picked.getName()) ? picked : picked.findFile(STAGING_CHILD);
            if (folder != null && !folder.isDirectory()) folder = null;
            if (folder == null) folder = picked.createDirectory(STAGING_CHILD);
            if (folder == null || !folder.isDirectory() || !folder.canRead() || !folder.canWrite()) { call.reject("Could not create ForgeStaging inside selected folder"); return; }
            String name = picked.getName();
            String display = STAGING_CHILD.equals(name) ? name : ((name == null || name.isEmpty() ? "Selected folder" : name) + "/" + STAGING_CHILD);
            stagingPrefs().edit()
                    .putString(STAGING_TREE_URI, tree.toString())
                    .putString("mode", "folder")
                    .putString(STAGING_DISPLAY, display)
                    .apply();
            call.resolve(stagingInfo(true));
        } catch (Exception e) { call.reject("files.pickStagingFolder failed: " + e.getMessage(), e); }
    }

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

    /** Host-internal cleanup for stale picker copies. Not exposed through ForgeHost. */
    @PluginMethod
    public void cleanup(PluginCall call) {
        File dir = new File(getContext().getCacheDir(), "forge_picks");
        long olderThan = System.currentTimeMillis();
        try {
            if (call.getData() != null && call.getData().has("olderThan")) {
                olderThan = (long) call.getData().getDouble("olderThan");
            }
        } catch (Exception ignored) {}
        if (olderThan <= 0) olderThan = System.currentTimeMillis();
        int deleted = 0;
        long bytes = 0;
        try {
            File[] files = dir.listFiles();
            if (files != null) {
                for (File f : files) {
                    if (f == null || !f.isFile() || f.lastModified() > olderThan) continue;
                    long size = f.length();
                    if (f.delete()) {
                        deleted++;
                        bytes += size;
                    }
                }
            }
        } catch (Exception e) {
            call.reject("files.cleanup failed: " + e.getMessage(), e);
            return;
        }
        JSObject o = new JSObject();
        o.put("ok", true);
        o.put("olderThan", olderThan);
        o.put("deleted", deleted);
        o.put("bytes", bytes);
        call.resolve(o);
    }

    /** Host-only bridge: copy a provider URI to shared Download/Forge for Termux. */
    @PluginMethod
    public void exportShared(PluginCall call) {
        call.setKeepAlive(true);
        Uri uri = null;
        File target = null;
        try {
            String rawUri = call.getString("uri", "");
            String name = call.getString("name", "file");
            if (rawUri == null || rawUri.isEmpty()) throw new Exception("uri required");
            uri = Uri.parse(rawUri);
            String safe = (name == null ? "file" : name).replaceAll("[\\\\/:*?\\\"<>|]", "_");
            if (hasSelectedFolder()) {
                DocumentFile folder = managedStagingFolder(true);
                if (folder == null || !folder.canWrite()) throw new Exception("selected staging folder is no longer available");
                String mime = getContext().getContentResolver().getType(uri);
                if (mime == null || mime.isEmpty()) mime = "application/octet-stream";
                DocumentFile targetDoc = folder.createFile(mime, System.currentTimeMillis() + "_" + safe);
                if (targetDoc == null) throw new Exception("could not create staged file");
                try (InputStream input = getContext().getContentResolver().openInputStream(uri);
                     OutputStream out = getContext().getContentResolver().openOutputStream(targetDoc.getUri(), "w")) {
                    if (input == null || out == null) throw new Exception("could not open staged file");
                    byte[] buf = new byte[32768]; int n; while ((n = input.read(buf)) >= 0) if (n > 0) out.write(buf, 0, n);
                }
                JSObject result = new JSObject(); result.put("ok", true); result.put("path", targetDoc.getUri().toString()); result.put("uri", targetDoc.getUri().toString()); result.put("name", safe); result.put("size", targetDoc.length());
                call.resolve(result); return;
            }
            File dir = internalStagingDir();
            if (!dir.exists() && !dir.mkdirs()) throw new Exception("cannot create internal staging cache");
            target = new File(dir, System.currentTimeMillis() + "_" + safe);
            InputStream in = getContext().getContentResolver().openInputStream(uri);
            if (in == null) throw new Exception("cannot open content URI");
            try (InputStream input = in; FileOutputStream out = new FileOutputStream(target)) {
                byte[] buf = new byte[32768];
                int n;
                while ((n = input.read(buf)) >= 0) if (n > 0) out.write(buf, 0, n);
            }
            JSObject result = new JSObject();
            result.put("ok", true);
            result.put("path", target.getAbsolutePath());
            result.put("name", safe);
            call.resolve(result);
        } catch (Exception e) {
            if (target != null) try { target.delete(); } catch (Exception ignored) {}
            call.reject("files.exportShared failed: " + e.getMessage(), e);
        }
    }

    /** Return a FileProvider URI for an existing shared output without reading it into WebView memory. */
    @PluginMethod
    public void shareUri(PluginCall call) {
        try {
            String raw = call.getString("path", "");
            if (raw != null && raw.startsWith("content://")) {
                Uri content = Uri.parse(raw);
                if (getContext().getContentResolver().openAssetFileDescriptor(content, "r") == null) { call.reject("file missing or unreadable"); return; }
                JSObject result = new JSObject(); result.put("ok", true); result.put("uri", raw); result.put("size", querySize(content)); result.put("name", queryDisplayName(content));
                call.resolve(result); return;
            }
            File target = new File(raw).getCanonicalFile();
            if (!isAllowedStagingFile(target)) { call.reject("path not allowed"); return; }
            if (!target.isFile() || target.length() <= 0) { call.reject("file missing or empty"); return; }
            Uri uri = FileProvider.getUriForFile(getContext(), getContext().getPackageName() + ".fileprovider", target);
            JSObject result = new JSObject(); result.put("ok", true); result.put("uri", uri.toString()); result.put("size", target.length()); result.put("name", target.getName());
            call.resolve(result);
        } catch (Exception e) { call.reject("files.shareUri failed: " + e.getMessage(), e); }
    }

    /** Write a small generated binary into shared staging (for TTS/audio chunks). */
    @PluginMethod
    public void writeShared(PluginCall call) {
        try {
            String raw = call.getString("path", "");
            String b64 = call.getString("base64", "");
            byte[] data = Base64.decode(b64, Base64.DEFAULT);
            if (data.length > 32 * 1024 * 1024) { call.reject("file too large"); return; }
            if (raw != null && raw.startsWith("content://")) {
                Uri target = Uri.parse(raw);
                try (OutputStream out = getContext().getContentResolver().openOutputStream(target, "w")) {
                    if (out == null) { call.reject("selected staging file is not writable"); return; }
                    out.write(data);
                }
                JSObject result = new JSObject(); result.put("ok", true); result.put("path", raw); result.put("uri", raw); result.put("size", data.length); call.resolve(result); return;
            }
            if ((raw == null || raw.isEmpty()) && hasSelectedFolder()) {
                DocumentFile folder = managedStagingFolder(true);
                String mime = call.getString("mime", "application/octet-stream");
                DocumentFile targetDoc = folder.createFile(mime, System.currentTimeMillis() + "_staged.bin");
                if (targetDoc == null) { call.reject("cannot create staging file"); return; }
                try (OutputStream out = getContext().getContentResolver().openOutputStream(targetDoc.getUri(), "w")) {
                    if (out == null) { call.reject("cannot open staging file"); return; }
                    out.write(data);
                }
                JSObject result = new JSObject(); result.put("ok", true); result.put("path", targetDoc.getUri().toString()); result.put("uri", targetDoc.getUri().toString()); result.put("size", data.length); call.resolve(result); return;
            }
            File target = (raw == null || raw.isEmpty())
                    ? new File(internalStagingDir(), System.currentTimeMillis() + "_staged.bin").getCanonicalFile()
                    : new File(raw).getCanonicalFile();
            if (!isAllowedStagingFile(target)) { call.reject("path not allowed"); return; }
            File parent = target.getParentFile(); if (parent != null) parent.mkdirs();
            try (FileOutputStream out = new FileOutputStream(target)) { out.write(data); }
            JSObject result = new JSObject(); result.put("ok", true); result.put("path", target.getAbsolutePath()); result.put("size", target.length()); call.resolve(result);
        } catch (Exception e) { call.reject("files.writeShared failed: " + e.getMessage(), e); }
    }

    /** Write an automatically named Forge-owned file into the selected staging location. */
    @PluginMethod
    public void writeStaging(PluginCall call) {
        try {
            String name = call.getString("name", "staged_file").replaceAll("[\\\\/:*?\\\"<>|]", "_");
            String b64 = call.getString("base64", "");
            byte[] data = Base64.decode(b64, Base64.DEFAULT);
            if (data.length > 32 * 1024 * 1024) { call.reject("file too large"); return; }
            if (!hasSelectedFolder()) {
                File dir = internalStagingDir();
                if (!dir.exists() && !dir.mkdirs()) throw new Exception("cannot create internal staging cache");
                File target = new File(dir, System.currentTimeMillis() + "_" + name).getCanonicalFile();
                if (!target.getPath().startsWith(dir.getCanonicalPath() + File.separator)) throw new Exception("invalid staging filename");
                try (FileOutputStream out = new FileOutputStream(target)) { out.write(data); }
                call.resolve(stagingInfo(true).put("path", target.getAbsolutePath()).put("size", target.length()));
                return;
            }
            DocumentFile dir = managedStagingFolder(true);
            if (dir == null || !dir.canWrite()) throw new Exception("selected staging folder is no longer available");
            String mime = call.getString("mime", "application/octet-stream");
            DocumentFile target = dir.createFile(mime, System.currentTimeMillis() + "_" + name);
            if (target == null) throw new Exception("cannot create staging file");
            try (OutputStream out = getContext().getContentResolver().openOutputStream(target.getUri(), "w")) {
                if (out == null) throw new Exception("cannot open staging file");
                out.write(data);
            }
            call.resolve(new JSObject().put("ok", true).put("path", target.getUri().toString()).put("uri", target.getUri().toString()).put("size", data.length).put("mode", "folder"));
        } catch (Exception e) { call.reject("files.writeStaging failed: " + e.getMessage(), e); }
    }

    /** User-requested cleanup for the currently selected staging location. */
    @PluginMethod
    public void cleanupStaging(PluginCall call) {
        long olderThan = Long.MAX_VALUE;
        try {
            if (call.getData() != null && call.getData().has("olderThan")) {
                olderThan = (long) call.getData().getDouble("olderThan");
            }
        } catch (Exception ignored) {}
        int deleted = 0;
        long bytes = 0;
        try {
            if (!hasSelectedFolder()) {
                for (File dir : new File[] { internalStagingDir(), pickerCacheDir() }) {
                    File[] files = dir.listFiles();
                    if (files == null) continue;
                    for (File f : files) {
                        if (f == null || !f.isFile() || f.lastModified() > olderThan) continue;
                        long size = f.length();
                        if (f.delete()) { deleted++; bytes += size; }
                    }
                }
            } else {
                DocumentFile dir = managedStagingFolder(false);
                if (dir == null) throw new Exception("selected staging folder is no longer available");
                if (!dir.canRead() || !dir.canWrite()) throw new Exception("selected staging folder is no longer available");
                DocumentFile[] files = dir.listFiles();
                if (files != null) {
                    for (DocumentFile f : files) {
                        if (f == null || !f.isFile()) continue;
                        // SAF does not expose a reliable last-modified value on every provider;
                        // cleanup with the default MAX removes all files, while age-limited cleanup
                        // skips files whose provider timestamp is newer than the requested cutoff.
                        long modified = f.lastModified();
                        if (modified > 0 && modified > olderThan) continue;
                        long size = f.length();
                        if (f.delete()) { deleted++; bytes += size; }
                    }
                }
            }
            JSObject result = stagingInfo(true);
            result.put("deleted", deleted);
            result.put("bytes", bytes);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("files.cleanupStaging failed: " + e.getMessage(), e);
        }
    }

    /** Host-only cleanup for a temporary shared Download/Forge transfer. */
    @PluginMethod
    public void deleteShared(PluginCall call) {
        try {
            String raw = call.getString("path", "");
            File root = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "Forge").getCanonicalFile();
            File target = new File(raw).getCanonicalFile();
            if (!target.getPath().startsWith(root.getPath() + File.separator)) {
                call.reject("path not allowed");
                return;
            }
            JSObject result = new JSObject();
            result.put("ok", !target.exists() || target.delete());
            call.resolve(result);
        } catch (Exception e) {
            call.reject("files.deleteShared failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void readStaged(PluginCall call) {
        call.setKeepAlive(true);
        try {
            String path = call.getString("path", "");
            if (path != null && !path.isEmpty() && path.startsWith("content://")) {
                Uri stagedUri = Uri.parse(path);
                long max = 28672000;
                try { if (call.getData() != null && call.getData().has("maxBytes")) max = (long) call.getData().getDouble("maxBytes"); } catch (Exception ignored) {}
                byte[] bytes = readUriBytes(stagedUri, max);
                String mime = call.getString("mime", "application/octet-stream");
                if (mime == null || mime.isEmpty()) mime = "application/octet-stream";
                String name = queryDisplayName(stagedUri);
                if (name == null || name.isEmpty()) name = "staged-file";
                String b64 = Base64.encodeToString(bytes, Base64.NO_WRAP);
                JSObject o = new JSObject();
                o.put("name", name); o.put("path", path); o.put("uri", path); o.put("contentUri", path);
                o.put("size", bytes.length); o.put("mime", mime); o.put("type", mime);
                o.put("base64", b64); o.put("dataUrl", "data:" + mime + ";base64," + b64);
                call.resolve(o);
                return;
            }
            if (path != null && !path.isEmpty()) {
                File f = new File(path);
                if (!isAllowedStagingFile(f.getCanonicalFile())) {
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
    public void readShared(PluginCall call) {
        if (Build.VERSION.SDK_INT >= 33
                && getContext().checkSelfPermission("android.permission.READ_MEDIA_AUDIO") != 0) {
            requestPermissionForAlias("audio", call, "audioPermCallback");
            return;
        }
        try {
            String path = call.getString("path", "");
            File root = new File(Environment.getExternalStorageDirectory(), "Download");
            File target = new File(path == null ? "" : path);
            String rootPath = root.getCanonicalPath();
            String targetPath = target.getCanonicalPath();
            if (!targetPath.startsWith(rootPath + File.separator) || !target.isFile()) {
                call.reject("file not found");
                return;
            }
            long max = HARD_MAX_BYTES;
            if (target.length() > max) {
                call.reject("File too large to read (" + target.length() + " > " + max + ")");
                return;
            }
            String mime = call.getString("mime", "application/octet-stream");
            byte[] bytes = readFileBytes(target, max);
            String b64 = Base64.encodeToString(bytes, Base64.NO_WRAP);
            JSObject result = new JSObject();
            result.put("name", target.getName());
            result.put("path", target.getAbsolutePath());
            result.put("size", bytes.length);
            result.put("mime", mime);
            result.put("base64", b64);
            result.put("dataUrl", "data:" + mime + ";base64," + b64);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("files.readShared failed: " + e.getMessage(), e);
        }
    }

    @com.getcapacitor.annotation.PermissionCallback
    private void audioPermCallback(PluginCall call) {
        if (Build.VERSION.SDK_INT >= 33
                && getContext().checkSelfPermission("android.permission.READ_MEDIA_AUDIO") != 0) {
            call.reject("Audio storage permission is required to read the extracted file");
            return;
        }
        readShared(call);
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
        this.pendingAllowInline = true;
        try {
            if (call.getData() != null && call.getData().has("inline")) {
                this.pendingAllowInline = call.getBoolean("inline", true);
            }
        } catch (Exception ignored) {}
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
                    } catch (Exception e2) {                        call.reject("pickResult failed: " + e2.getMessage(), e2);
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
        } catch (Exception e3) {        }
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
        String name = queryDisplayName(uri);
        if (name == null || name.isEmpty()) name = "file";
        name = name.replaceAll("[\\/:*?\"<>|]", "_");
        String mime = getContext().getContentResolver().getType(uri);
        if (mime == null || mime.isEmpty()) mime = guessMimeFromName(name);
        long declared = querySize(uri);
        if (declared > maxBytes) {
            throw new Exception("File too large (" + declared + " bytes). Max " + maxBytes);
        }
        String safe = UUID.randomUUID().toString().replace("-", "").substring(0, 12) + "_" + name;
        if (hasSelectedFolder()) {
            DocumentFile folder = managedStagingFolder(true);
            if (folder == null || !folder.canRead() || !folder.canWrite()) throw new Exception("selected staging folder is no longer available");
            DocumentFile staged = folder.createFile(mime, safe);
            if (staged == null) throw new Exception("could not create staged file in selected folder");
            long written = 0;
            try (InputStream input = getContext().getContentResolver().openInputStream(uri);
                 OutputStream output = getContext().getContentResolver().openOutputStream(staged.getUri(), "w")) {
                if (input == null || output == null) throw new Exception("could not open selected staging folder");
                byte[] buf = new byte[16384];
                int n;
                while ((n = input.read(buf)) >= 0) {
                    if (n == 0) continue;
                    written += n;
                    if (written > maxBytes) throw new Exception("File too large while reading. Max " + maxBytes + " bytes");
                    output.write(buf, 0, n);
                }
            } catch (Exception e) {
                try { staged.delete(); } catch (Exception ignored) {}
                throw e;
            }
            JSObject o = new JSObject();
            o.put("name", name); o.put("type", mime); o.put("mime", mime); o.put("size", written);
            o.put("path", staged.getUri().toString()); o.put("uri", uri.toString());
            o.put("contentUri", staged.getUri().toString()); o.put("inline", false);
            if (pendingAllowInline && written > 0 && written <= INLINE_BASE64_MAX) {
                byte[] bytes = readUriBytes(staged.getUri(), INLINE_BASE64_MAX);
                String b64 = Base64.encodeToString(bytes, Base64.NO_WRAP);
                o.put("base64", b64); o.put("dataUrl", "data:" + mime + ";base64," + b64); o.put("inline", true);
            } else {
                o.put("base64", (String) null); o.put("dataUrl", (String) null);
                o.put("note", "File staged in selected folder; use path/readStaged for content");
            }
            return o;
        }
        File sharedDir = internalStagingDir();
        File privateDir = new File(getContext().getCacheDir(), "forge_picks");
        File out = null;
        long total = 0;
        Exception lastError = null;
        // Prefer shared staging so Termux can consume the path; fall back to the
        // historical private cache when scoped storage denies the direct write.
        for (File dir : new File[] { sharedDir, privateDir }) {
            File candidate = new File(dir, safe);
            try {
                if (!dir.exists() && !dir.mkdirs()) throw new Exception("cannot create " + dir);
                if (!dir.isDirectory()) throw new Exception("not a directory: " + dir);
                InputStream in = getContext().getContentResolver().openInputStream(uri);
                if (in == null) throw new Exception("Cannot open file");
                long written = 0;
                try (InputStream input = in; FileOutputStream fos = new FileOutputStream(candidate)) {
                    byte[] buf = new byte[16384];
                    while (true) {
                        int n = input.read(buf);
                        if (n < 0) break;
                        written += n;
                        if (written > maxBytes) throw new Exception("File too large while reading. Max " + maxBytes + " bytes");
                        fos.write(buf, 0, n);
                    }
                }
                out = candidate;
                total = written;
                break;
            } catch (Exception e) {
                lastError = e;
                try { candidate.delete(); } catch (Exception ignored) {}
            }
        }
        if (out == null) throw new Exception("Unable to stage file: " + (lastError == null ? "unknown error" : lastError.getMessage()));
        JSObject o = new JSObject();
        o.put("name", name);
        o.put("type", mime);
        o.put("mime", mime);
        o.put("size", total);
        o.put("path", out.getAbsolutePath());
        o.put("uri", uri.toString());
        try {
            Uri contentUri = FileProvider.getUriForFile(
                    getContext(),
                    getContext().getPackageName() + ".fileprovider",
                    out);
            o.put("contentUri", contentUri.toString());
        } catch (Exception ignored) {
        }
        if (pendingAllowInline && total > 0 && total <= INLINE_BASE64_MAX) {
            byte[] bytes = readFileBytes(out, INLINE_BASE64_MAX);
            String b64 = Base64.encodeToString(bytes, Base64.NO_WRAP);
            o.put("base64", b64);
            o.put("dataUrl", "data:" + mime + ";base64," + b64);
            o.put("inline", true);
        } else {
            o.put("inline", false);
            o.put("base64", (String) null);
            o.put("dataUrl", (String) null);
            o.put("note", "File staged on disk; use path/readStaged for content");
        }
        return o;
    }

    private byte[] readUriBytes(Uri uri, long max) throws Exception {
        try (InputStream in = getContext().getContentResolver().openInputStream(uri)) {
            if (in == null) throw new Exception("file not readable");
            java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
            byte[] buf = new byte[16384];
            long total = 0;
            int n;
            while ((n = in.read(buf)) >= 0) {
                if (n == 0) continue;
                total += n;
                if (total > max) throw new Exception("File too large");
                out.write(buf, 0, n);
            }
            return out.toByteArray();
        }
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
            return "text/plain";
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
                            out.add("text/plain");
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
