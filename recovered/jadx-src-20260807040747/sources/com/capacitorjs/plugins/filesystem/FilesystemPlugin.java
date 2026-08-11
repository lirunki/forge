package com.capacitorjs.plugins.filesystem;

import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import androidx.core.app.NotificationCompat;
import com.capacitorjs.plugins.filesystem.Filesystem;
import com.capacitorjs.plugins.filesystem.exceptions.CopyFailedException;
import com.capacitorjs.plugins.filesystem.exceptions.DirectoryExistsException;
import com.capacitorjs.plugins.filesystem.exceptions.DirectoryNotFoundException;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Logger;
import com.getcapacitor.PermissionState;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import com.getcapacitor.plugin.util.HttpRequestHandler;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.attribute.BasicFileAttributes;
import org.json.JSONException;

@CapacitorPlugin(name = "Filesystem", permissions = {@Permission(alias = FilesystemPlugin.PUBLIC_STORAGE, strings = {"android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE"})})
/* loaded from: classes2.dex */
public class FilesystemPlugin extends Plugin {
    private static final String PERMISSION_DENIED_ERROR = "Unable to do file operation, user denied permission request";
    static final String PUBLIC_STORAGE = "publicStorage";
    private Filesystem implementation;

    @Override // com.getcapacitor.Plugin
    public void load() {
        this.implementation = new Filesystem(getContext());
    }

    @PluginMethod
    public void readFile(PluginCall call) {
        String path = call.getString("path");
        String directory = getDirectoryParameter(call);
        String encoding = call.getString("encoding");
        Charset charset = this.implementation.getEncoding(encoding);
        if (encoding != null && charset == null) {
            call.reject("Unsupported encoding provided: " + encoding);
            return;
        }
        if (isPublicDirectory(directory) && !isStoragePermissionGranted()) {
            requestAllPermissions(call, "permissionCallback");
            return;
        }
        try {
            String dataStr = this.implementation.readFile(path, directory, charset);
            JSObject ret = new JSObject();
            ret.putOpt("data", dataStr);
            call.resolve(ret);
        } catch (FileNotFoundException ex) {
            call.reject("File does not exist", ex);
        } catch (IOException ex2) {
            call.reject("Unable to read file", ex2);
        } catch (JSONException ex3) {
            call.reject("Unable to return value for reading file", ex3);
        }
    }

    @PluginMethod
    public void writeFile(PluginCall call) {
        String path = call.getString("path");
        String data = call.getString("data");
        Boolean recursive = call.getBoolean("recursive", false);
        if (path == null) {
            Logger.error(getLogTag(), "No path or filename retrieved from call", null);
            call.reject("NO_PATH");
            return;
        }
        if (data == null) {
            Logger.error(getLogTag(), "No data retrieved from call", null);
            call.reject("NO_DATA");
            return;
        }
        String directory = getDirectoryParameter(call);
        if (directory != null) {
            if (isPublicDirectory(directory) && !isStoragePermissionGranted()) {
                requestAllPermissions(call, "permissionCallback");
                return;
            }
            File androidDir = this.implementation.getDirectory(directory);
            if (androidDir == null) {
                Logger.error(getLogTag(), "Directory ID '" + directory + "' is not supported by plugin", null);
                call.reject("INVALID_DIR");
                return;
            }
            if (!androidDir.exists() && !androidDir.mkdirs()) {
                Logger.error(getLogTag(), "Not able to create '" + directory + "'!", null);
                call.reject("NOT_CREATED_DIR");
                return;
            }
            File fileObject = new File(androidDir, path);
            if (fileObject.getParentFile().exists() || (recursive.booleanValue() && fileObject.getParentFile().mkdirs())) {
                saveFile(call, fileObject, data);
                return;
            } else {
                call.reject("Parent folder doesn't exist");
                return;
            }
        }
        Uri u = Uri.parse(path);
        if (u.getScheme() == null || u.getScheme().equals("file")) {
            File fileObject2 = new File(u.getPath());
            if (!isStoragePermissionGranted()) {
                requestAllPermissions(call, "permissionCallback");
                return;
            }
            if (fileObject2.getParentFile() == null || fileObject2.getParentFile().exists() || (recursive.booleanValue() && fileObject2.getParentFile().mkdirs())) {
                saveFile(call, fileObject2, data);
                return;
            } else {
                call.reject("Parent folder doesn't exist");
                return;
            }
        }
        call.reject(u.getScheme() + " scheme not supported");
    }

    private void saveFile(PluginCall call, File file, String data) {
        String encoding = call.getString("encoding");
        boolean append = call.getBoolean("append", false).booleanValue();
        Charset charset = this.implementation.getEncoding(encoding);
        if (encoding != null && charset == null) {
            call.reject("Unsupported encoding provided: " + encoding);
            return;
        }
        try {
            this.implementation.saveFile(file, data, charset, Boolean.valueOf(append));
            if (isPublicDirectory(getDirectoryParameter(call))) {
                MediaScannerConnection.scanFile(getContext(), new String[]{file.getAbsolutePath()}, null, null);
            }
            Logger.debug(getLogTag(), "File '" + file.getAbsolutePath() + "' saved!");
            JSObject result = new JSObject();
            result.put("uri", Uri.fromFile(file).toString());
            call.resolve(result);
        } catch (IOException ex) {
            Logger.error(getLogTag(), "Creating file '" + file.getPath() + "' with charset '" + charset + "' failed. Error: " + ex.getMessage(), ex);
            call.reject("FILE_NOTCREATED");
        } catch (IllegalArgumentException e) {
            call.reject("The supplied data is not valid base64 content.");
        }
    }

    @PluginMethod
    public void appendFile(PluginCall call) {
        try {
            call.getData().putOpt("append", true);
        } catch (JSONException e) {
        }
        writeFile(call);
    }

    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:16:0x002f -> B:12:0x0036). Please report as a decompilation issue!!! */
    @PluginMethod
    public void deleteFile(PluginCall call) {
        String file = call.getString("path");
        String directory = getDirectoryParameter(call);
        if (isPublicDirectory(directory) && !isStoragePermissionGranted()) {
            requestAllPermissions(call, "permissionCallback");
            return;
        }
        try {
            boolean deleted = this.implementation.deleteFile(file, directory);
            if (!deleted) {
                call.reject("Unable to delete file");
            } else {
                call.resolve();
            }
        } catch (FileNotFoundException ex) {
            call.reject(ex.getMessage());
        }
    }

    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:16:0x0042 -> B:12:0x0049). Please report as a decompilation issue!!! */
    @PluginMethod
    public void mkdir(PluginCall call) {
        String path = call.getString("path");
        String directory = getDirectoryParameter(call);
        boolean recursive = call.getBoolean("recursive", false).booleanValue();
        if (isPublicDirectory(directory) && !isStoragePermissionGranted()) {
            requestAllPermissions(call, "permissionCallback");
            return;
        }
        try {
            boolean created = this.implementation.mkdir(path, directory, Boolean.valueOf(recursive));
            if (!created) {
                call.reject("Unable to create directory, unknown reason");
            } else {
                call.resolve();
            }
        } catch (DirectoryExistsException ex) {
            call.reject(ex.getMessage());
        }
    }

    @PluginMethod
    public void rmdir(PluginCall call) {
        String path = call.getString("path");
        String directory = getDirectoryParameter(call);
        Boolean recursive = call.getBoolean("recursive", false);
        File fileObject = this.implementation.getFileObject(path, directory);
        if (isPublicDirectory(directory) && !isStoragePermissionGranted()) {
            requestAllPermissions(call, "permissionCallback");
            return;
        }
        if (!fileObject.exists()) {
            call.reject("Directory does not exist");
            return;
        }
        if (fileObject.isDirectory() && fileObject.listFiles().length != 0 && !recursive.booleanValue()) {
            call.reject("Directory is not empty");
            return;
        }
        boolean deleted = false;
        try {
            this.implementation.deleteRecursively(fileObject);
            deleted = true;
        } catch (IOException e) {
        }
        if (!deleted) {
            call.reject("Unable to delete directory, unknown reason");
        } else {
            call.resolve();
        }
    }

    @PluginMethod
    public void readdir(PluginCall pluginCall) {
        String path = pluginCall.getString("path");
        String directory = getDirectoryParameter(pluginCall);
        if (isPublicDirectory(directory) && !isStoragePermissionGranted()) {
            requestAllPermissions(pluginCall, "permissionCallback");
            return;
        }
        try {
            File[] files = this.implementation.readdir(path, directory);
            JSArray filesArray = new JSArray();
            if (files != null) {
                for (File fileObject : files) {
                    JSObject data = new JSObject();
                    data.put("name", fileObject.getName());
                    data.put("type", fileObject.isDirectory() ? "directory" : "file");
                    data.put("size", fileObject.length());
                    data.put("mtime", fileObject.lastModified());
                    data.put("uri", Uri.fromFile(fileObject).toString());
                    if (Build.VERSION.SDK_INT >= 26) {
                        try {
                            BasicFileAttributes attr = Files.readAttributes(fileObject.toPath(), (Class<BasicFileAttributes>) BasicFileAttributes.class, new LinkOption[0]);
                            if (attr.creationTime().toMillis() < attr.lastAccessTime().toMillis()) {
                                data.put("ctime", attr.creationTime().toMillis());
                            } else {
                                data.put("ctime", attr.lastAccessTime().toMillis());
                            }
                        } catch (Exception e) {
                        }
                    } else {
                        data.put("ctime", (String) null);
                    }
                    filesArray.put(data);
                }
                JSObject ret = new JSObject();
                ret.put("files", (Object) filesArray);
                pluginCall.resolve(ret);
                return;
            }
            pluginCall.reject("Unable to read directory");
        } catch (DirectoryNotFoundException ex) {
            pluginCall.reject(ex.getMessage());
        }
    }

    @PluginMethod
    public void getUri(PluginCall call) {
        String path = call.getString("path");
        String directory = getDirectoryParameter(call);
        File fileObject = this.implementation.getFileObject(path, directory);
        if (isPublicDirectory(directory) && !isStoragePermissionGranted()) {
            requestAllPermissions(call, "permissionCallback");
            return;
        }
        JSObject data = new JSObject();
        data.put("uri", Uri.fromFile(fileObject).toString());
        call.resolve(data);
    }

    @PluginMethod
    public void stat(PluginCall call) {
        String path = call.getString("path");
        String directory = getDirectoryParameter(call);
        File fileObject = this.implementation.getFileObject(path, directory);
        if (isPublicDirectory(directory) && !isStoragePermissionGranted()) {
            requestAllPermissions(call, "permissionCallback");
            return;
        }
        if (!fileObject.exists()) {
            call.reject("File does not exist");
            return;
        }
        JSObject data = new JSObject();
        data.put("type", fileObject.isDirectory() ? "directory" : "file");
        data.put("size", fileObject.length());
        data.put("mtime", fileObject.lastModified());
        data.put("uri", Uri.fromFile(fileObject).toString());
        if (Build.VERSION.SDK_INT >= 26) {
            try {
                BasicFileAttributes attr = Files.readAttributes(fileObject.toPath(), (Class<BasicFileAttributes>) BasicFileAttributes.class, new LinkOption[0]);
                if (attr.creationTime().toMillis() < attr.lastAccessTime().toMillis()) {
                    data.put("ctime", attr.creationTime().toMillis());
                } else {
                    data.put("ctime", attr.lastAccessTime().toMillis());
                }
            } catch (Exception e) {
            }
        } else {
            data.put("ctime", (String) null);
        }
        call.resolve(data);
    }

    @PluginMethod
    public void rename(PluginCall call) {
        _copy(call, true);
    }

    @PluginMethod
    public void copy(PluginCall call) {
        _copy(call, false);
    }

    @PluginMethod
    public void downloadFile(final PluginCall call) {
        try {
            final String directory = call.getString("directory", Environment.DIRECTORY_DOWNLOADS);
            if (isPublicDirectory(directory) && !isStoragePermissionGranted()) {
                requestAllPermissions(call, "permissionCallback");
            } else {
                HttpRequestHandler.ProgressEmitter emitter = new HttpRequestHandler.ProgressEmitter() { // from class: com.capacitorjs.plugins.filesystem.FilesystemPlugin$$ExternalSyntheticLambda0
                    @Override // com.getcapacitor.plugin.util.HttpRequestHandler.ProgressEmitter
                    public final void emit(Integer num, Integer num2) {
                        FilesystemPlugin.this.lambda$downloadFile$0(call, num, num2);
                    }
                };
                this.implementation.downloadFile(call, this.bridge, emitter, new Filesystem.FilesystemDownloadCallback() { // from class: com.capacitorjs.plugins.filesystem.FilesystemPlugin.1
                    @Override // com.capacitorjs.plugins.filesystem.Filesystem.FilesystemDownloadCallback
                    public void onSuccess(JSObject response) {
                        if (FilesystemPlugin.this.isPublicDirectory(directory)) {
                            MediaScannerConnection.scanFile(FilesystemPlugin.this.getContext(), new String[]{response.getString("path")}, null, null);
                        }
                        call.resolve(response);
                    }

                    @Override // com.capacitorjs.plugins.filesystem.Filesystem.FilesystemDownloadCallback
                    public void onError(Exception error) {
                        call.reject("Error downloading file: " + error.getLocalizedMessage(), error);
                    }
                });
            }
        } catch (Exception ex) {
            call.reject("Error downloading file: " + ex.getLocalizedMessage(), ex);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$downloadFile$0(PluginCall call, Integer bytes, Integer contentLength) {
        JSObject ret = new JSObject();
        ret.put("url", call.getString("url"));
        ret.put("bytes", (Object) bytes);
        ret.put("contentLength", (Object) contentLength);
        notifyListeners(NotificationCompat.CATEGORY_PROGRESS, ret);
    }

    private void _copy(PluginCall call, Boolean doRename) {
        String from = call.getString("from");
        String to = call.getString("to");
        String directory = call.getString("directory");
        String toDirectory = call.getString("toDirectory");
        if (from == null || from.isEmpty() || to == null || to.isEmpty()) {
            call.reject("Both to and from must be provided");
            return;
        }
        if ((isPublicDirectory(directory) || isPublicDirectory(toDirectory)) && !isStoragePermissionGranted()) {
            requestAllPermissions(call, "permissionCallback");
            return;
        }
        try {
            File file = this.implementation.copy(from, directory, to, toDirectory, doRename.booleanValue());
            if (!doRename.booleanValue()) {
                JSObject result = new JSObject();
                result.put("uri", Uri.fromFile(file).toString());
                call.resolve(result);
                return;
            }
            call.resolve();
        } catch (CopyFailedException ex) {
            call.reject(ex.getMessage());
        } catch (IOException ex2) {
            call.reject("Unable to perform action: " + ex2.getLocalizedMessage());
        }
    }

    @Override // com.getcapacitor.Plugin
    @PluginMethod
    public void checkPermissions(PluginCall call) {
        if (isStoragePermissionGranted()) {
            JSObject permissionsResultJSON = new JSObject();
            permissionsResultJSON.put(PUBLIC_STORAGE, "granted");
            call.resolve(permissionsResultJSON);
            return;
        }
        super.checkPermissions(call);
    }

    @Override // com.getcapacitor.Plugin
    @PluginMethod
    public void requestPermissions(PluginCall call) {
        if (isStoragePermissionGranted()) {
            JSObject permissionsResultJSON = new JSObject();
            permissionsResultJSON.put(PUBLIC_STORAGE, "granted");
            call.resolve(permissionsResultJSON);
            return;
        }
        super.requestPermissions(call);
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    @PermissionCallback
    private void permissionCallback(PluginCall call) {
        char c;
        if (!isStoragePermissionGranted()) {
            Logger.debug(getLogTag(), "User denied storage permission");
            call.reject(PERMISSION_DENIED_ERROR);
        }
        String methodName = call.getMethodName();
        switch (methodName.hashCode()) {
            case -2139808842:
                if (methodName.equals("appendFile")) {
                    c = 0;
                    break;
                }
                c = 65535;
                break;
            case -1406748165:
                if (methodName.equals("writeFile")) {
                    c = 1;
                    break;
                }
                c = 65535;
                break;
            case -1249348042:
                if (methodName.equals("getUri")) {
                    c = '\t';
                    break;
                }
                c = 65535;
                break;
            case -934594754:
                if (methodName.equals("rename")) {
                    c = 5;
                    break;
                }
                c = 65535;
                break;
            case -867956686:
                if (methodName.equals("readFile")) {
                    c = 7;
                    break;
                }
                c = 65535;
                break;
            case 3059573:
                if (methodName.equals("copy")) {
                    c = 6;
                    break;
                }
                c = 65535;
                break;
            case 3540564:
                if (methodName.equals("stat")) {
                    c = '\n';
                    break;
                }
                c = 65535;
                break;
            case 103950895:
                if (methodName.equals("mkdir")) {
                    c = 3;
                    break;
                }
                c = 65535;
                break;
            case 108628082:
                if (methodName.equals("rmdir")) {
                    c = 4;
                    break;
                }
                c = 65535;
                break;
            case 1080408887:
                if (methodName.equals("readdir")) {
                    c = '\b';
                    break;
                }
                c = 65535;
                break;
            case 1108651556:
                if (methodName.equals("downloadFile")) {
                    c = 11;
                    break;
                }
                c = 65535;
                break;
            case 1764172231:
                if (methodName.equals("deleteFile")) {
                    c = 2;
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
            case 1:
                writeFile(call);
                break;
            case 2:
                deleteFile(call);
                break;
            case 3:
                mkdir(call);
                break;
            case 4:
                rmdir(call);
                break;
            case 5:
                rename(call);
                break;
            case 6:
                copy(call);
                break;
            case 7:
                readFile(call);
                break;
            case '\b':
                readdir(call);
                break;
            case '\t':
                getUri(call);
                break;
            case '\n':
                stat(call);
                break;
            case 11:
                downloadFile(call);
                break;
        }
    }

    private boolean isStoragePermissionGranted() {
        return Build.VERSION.SDK_INT >= 30 || getPermissionState(PUBLIC_STORAGE) == PermissionState.GRANTED;
    }

    private String getDirectoryParameter(PluginCall call) {
        return call.getString("directory");
    }

    /* JADX INFO: Access modifiers changed from: private */
    public boolean isPublicDirectory(String directory) {
        return "DOCUMENTS".equals(directory) || "EXTERNAL_STORAGE".equals(directory);
    }
}
