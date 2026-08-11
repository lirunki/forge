package com.capacitorjs.plugins.filesystem;

import android.content.Context;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;
import androidx.core.app.NotificationCompat;
import com.capacitorjs.plugins.filesystem.Filesystem;
import com.capacitorjs.plugins.filesystem.exceptions.CopyFailedException;
import com.capacitorjs.plugins.filesystem.exceptions.DirectoryExistsException;
import com.capacitorjs.plugins.filesystem.exceptions.DirectoryNotFoundException;
import com.getcapacitor.Bridge;
import com.getcapacitor.JSObject;
import com.getcapacitor.PluginCall;
import com.getcapacitor.plugin.util.CapacitorHttpUrlConnection;
import com.getcapacitor.plugin.util.HttpRequestHandler;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import org.json.JSONException;

/* loaded from: classes2.dex */
public class Filesystem {
    private Context context;

    public interface FilesystemDownloadCallback {
        void onError(Exception exc);

        void onSuccess(JSObject jSObject);
    }

    Filesystem(Context context) {
        this.context = context;
    }

    public String readFile(String path, String directory, Charset charset) throws IOException {
        InputStream is = getInputStream(path, directory);
        if (charset != null) {
            String dataStr = readFileAsString(is, charset.name());
            return dataStr;
        }
        String dataStr2 = readFileAsBase64EncodedData(is);
        return dataStr2;
    }

    public void saveFile(File file, String data, Charset charset, Boolean append) throws IOException {
        if (charset != null) {
            BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file, append.booleanValue()), charset));
            writer.write(data);
            writer.close();
        } else {
            if (data.contains(",")) {
                data = data.split(",")[1];
            }
            FileOutputStream fos = new FileOutputStream(file, append.booleanValue());
            fos.write(Base64.decode(data, 2));
            fos.close();
        }
    }

    public boolean deleteFile(String file, String directory) throws FileNotFoundException {
        File fileObject = getFileObject(file, directory);
        if (!fileObject.exists()) {
            throw new FileNotFoundException("File does not exist");
        }
        return fileObject.delete();
    }

    public boolean mkdir(String path, String directory, Boolean recursive) throws DirectoryExistsException {
        File fileObject = getFileObject(path, directory);
        if (fileObject.exists()) {
            throw new DirectoryExistsException("Directory exists");
        }
        if (recursive.booleanValue()) {
            boolean created = fileObject.mkdirs();
            return created;
        }
        boolean created2 = fileObject.mkdir();
        return created2;
    }

    public File[] readdir(String path, String directory) throws DirectoryNotFoundException {
        File fileObject = getFileObject(path, directory);
        if (fileObject != null && fileObject.exists()) {
            File[] files = fileObject.listFiles();
            return files;
        }
        throw new DirectoryNotFoundException("Directory does not exist");
    }

    public File copy(String from, String directory, String to, String toDirectory, boolean doRename) throws IOException, CopyFailedException {
        if (toDirectory == null) {
            toDirectory = directory;
        }
        File fromObject = getFileObject(from, directory);
        File toObject = getFileObject(to, toDirectory);
        if (fromObject == null) {
            throw new CopyFailedException("from file is null");
        }
        if (toObject == null) {
            throw new CopyFailedException("to file is null");
        }
        if (toObject.equals(fromObject)) {
            return toObject;
        }
        if (!fromObject.exists()) {
            throw new CopyFailedException("The source object does not exist");
        }
        if (toObject.getParentFile().isFile()) {
            throw new CopyFailedException("The parent object of the destination is a file");
        }
        if (!toObject.getParentFile().exists()) {
            throw new CopyFailedException("The parent object of the destination does not exist");
        }
        if (toObject.isDirectory()) {
            throw new CopyFailedException("Cannot overwrite a directory");
        }
        toObject.delete();
        if (doRename) {
            boolean modified = fromObject.renameTo(toObject);
            if (!modified) {
                throw new CopyFailedException("Unable to rename, unknown reason");
            }
        } else {
            copyRecursively(fromObject, toObject);
        }
        return toObject;
    }

    public InputStream getInputStream(String path, String directory) throws IOException {
        if (directory == null) {
            Uri u = Uri.parse(path);
            if (u.getScheme().equals("content")) {
                return this.context.getContentResolver().openInputStream(u);
            }
            return new FileInputStream(new File(u.getPath()));
        }
        File androidDirectory = getDirectory(directory);
        if (androidDirectory == null) {
            throw new IOException("Directory not found");
        }
        return new FileInputStream(new File(androidDirectory, path));
    }

    public String readFileAsString(InputStream is, String encoding) throws IOException {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        while (true) {
            int length = is.read(buffer);
            if (length != -1) {
                outputStream.write(buffer, 0, length);
            } else {
                return outputStream.toString(encoding);
            }
        }
    }

    public String readFileAsBase64EncodedData(InputStream is) throws IOException {
        FileInputStream fileInputStreamReader = (FileInputStream) is;
        ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        while (true) {
            int c = fileInputStreamReader.read(buffer);
            if (c != -1) {
                byteStream.write(buffer, 0, c);
            } else {
                fileInputStreamReader.close();
                return Base64.encodeToString(byteStream.toByteArray(), 2);
            }
        }
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    public File getDirectory(String directory) {
        char c;
        Context c2 = this.context;
        switch (directory.hashCode()) {
            case -1038134325:
                if (directory.equals("EXTERNAL")) {
                    c = 4;
                    break;
                }
                c = 65535;
                break;
            case -564829544:
                if (directory.equals("DOCUMENTS")) {
                    c = 0;
                    break;
                }
                c = 65535;
                break;
            case 2090922:
                if (directory.equals("DATA")) {
                    c = 1;
                    break;
                }
                c = 65535;
                break;
            case 63879010:
                if (directory.equals("CACHE")) {
                    c = 3;
                    break;
                }
                c = 65535;
                break;
            case 884191387:
                if (directory.equals("LIBRARY")) {
                    c = 2;
                    break;
                }
                c = 65535;
                break;
            case 1013698023:
                if (directory.equals("EXTERNAL_STORAGE")) {
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
                return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS);
            case 1:
            case 2:
                return c2.getFilesDir();
            case 3:
                return c2.getCacheDir();
            case 4:
                return c2.getExternalFilesDir(null);
            case 5:
                return Environment.getExternalStorageDirectory();
            default:
                return null;
        }
    }

    public File getFileObject(String path, String directory) {
        if (directory == null) {
            Uri u = Uri.parse(path);
            if (u.getScheme() == null || u.getScheme().equals("file")) {
                return new File(u.getPath());
            }
        }
        File androidDirectory = getDirectory(directory);
        if (androidDirectory == null) {
            return null;
        }
        if (!androidDirectory.exists()) {
            androidDirectory.mkdir();
        }
        return new File(androidDirectory, path);
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    public Charset getEncoding(String encoding) {
        char c;
        if (encoding == null) {
            return null;
        }
        switch (encoding.hashCode()) {
            case 3600241:
                if (encoding.equals("utf8")) {
                    c = 0;
                    break;
                }
                c = 65535;
                break;
            case 93106001:
                if (encoding.equals("ascii")) {
                    c = 2;
                    break;
                }
                c = 65535;
                break;
            case 111607308:
                if (encoding.equals("utf16")) {
                    c = 1;
                    break;
                }
                c = 65535;
                break;
            default:
                c = 65535;
                break;
        }
        switch (c) {
        }
        return null;
    }

    public void deleteRecursively(File file) throws IOException {
        if (file.isFile()) {
            file.delete();
            return;
        }
        for (File f : file.listFiles()) {
            deleteRecursively(f);
        }
        file.delete();
    }

    public void copyRecursively(File src, File dst) throws IOException {
        if (src.isDirectory()) {
            dst.mkdir();
            for (String file : src.list()) {
                copyRecursively(new File(src, file), new File(dst, file));
            }
            return;
        }
        if (!dst.getParentFile().exists()) {
            dst.getParentFile().mkdirs();
        }
        if (!dst.exists()) {
            dst.createNewFile();
        }
        FileChannel source = new FileInputStream(src).getChannel();
        try {
            FileChannel destination = new FileOutputStream(dst).getChannel();
            try {
                destination.transferFrom(source, 0L, source.size());
                if (destination != null) {
                    destination.close();
                }
                if (source != null) {
                    source.close();
                }
            } finally {
            }
        } catch (Throwable th) {
            if (source != null) {
                try {
                    source.close();
                } catch (Throwable th2) {
                    th.addSuppressed(th2);
                }
            }
            throw th;
        }
    }

    public void downloadFile(final PluginCall call, final Bridge bridge, final HttpRequestHandler.ProgressEmitter emitter, final FilesystemDownloadCallback callback) {
        final String urlString = call.getString("url", "");
        final ExecutorService executor = Executors.newSingleThreadExecutor();
        final Handler handler = new Handler(Looper.getMainLooper());
        executor.execute(new Runnable() { // from class: com.capacitorjs.plugins.filesystem.Filesystem$$ExternalSyntheticLambda2
            @Override // java.lang.Runnable
            public final void run() {
                Filesystem.this.lambda$downloadFile$2(urlString, call, bridge, emitter, handler, callback, executor);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$downloadFile$2(String urlString, PluginCall call, Bridge bridge, HttpRequestHandler.ProgressEmitter emitter, Handler handler, final FilesystemDownloadCallback callback, ExecutorService executor) {
        try {
            try {
                final JSObject result = doDownloadInBackground(urlString, call, bridge, emitter);
                handler.post(new Runnable() { // from class: com.capacitorjs.plugins.filesystem.Filesystem$$ExternalSyntheticLambda0
                    @Override // java.lang.Runnable
                    public final void run() {
                        Filesystem.FilesystemDownloadCallback.this.onSuccess(result);
                    }
                });
            } catch (Exception error) {
                handler.post(new Runnable() { // from class: com.capacitorjs.plugins.filesystem.Filesystem$$ExternalSyntheticLambda1
                    @Override // java.lang.Runnable
                    public final void run() {
                        Filesystem.FilesystemDownloadCallback.this.onError(error);
                    }
                });
            }
        } finally {
            executor.shutdown();
        }
    }

    private JSObject doDownloadInBackground(String urlString, PluginCall call, Bridge bridge, HttpRequestHandler.ProgressEmitter emitter) throws IOException, URISyntaxException, JSONException {
        int parseInt;
        byte[] buffer;
        JSObject headers = call.getObject("headers", new JSObject());
        JSObject params = call.getObject("params", new JSObject());
        Integer connectTimeout = call.getInt("connectTimeout");
        Integer readTimeout = call.getInt("readTimeout");
        Boolean disableRedirects = call.getBoolean("disableRedirects");
        Boolean shouldEncode = call.getBoolean("shouldEncodeUrlParams", true);
        Boolean progress = call.getBoolean(NotificationCompat.CATEGORY_PROGRESS, false);
        String method = call.getString("method", "GET").toUpperCase(Locale.ROOT);
        String path = call.getString("path");
        String directory = call.getString("directory", Environment.DIRECTORY_DOWNLOADS);
        URL url = new URL(urlString);
        File file = getFileObject(path, directory);
        HttpRequestHandler.HttpURLConnectionBuilder connectionBuilder = new HttpRequestHandler.HttpURLConnectionBuilder().setUrl(url).setMethod(method).setHeaders(headers).setUrlParams(params, shouldEncode.booleanValue()).setConnectTimeout(connectTimeout).setReadTimeout(readTimeout).setDisableRedirects(disableRedirects).openConnection();
        CapacitorHttpUrlConnection connection = connectionBuilder.build();
        connection.setSSLSocketFactory(bridge);
        InputStream connectionInputStream = connection.getInputStream();
        FileOutputStream fileOutputStream = new FileOutputStream(file, false);
        String contentLength = connection.getHeaderField("content-length");
        int bytes = 0;
        int maxBytes = 0;
        if (contentLength != null) {
            try {
                parseInt = Integer.parseInt(contentLength);
            } catch (NumberFormatException e) {
            }
        } else {
            parseInt = 0;
        }
        maxBytes = parseInt;
        byte[] buffer2 = new byte[1024];
        long lastEmitTime = System.currentTimeMillis();
        while (true) {
            int len = connectionInputStream.read(buffer2);
            if (len <= 0) {
                break;
            }
            CapacitorHttpUrlConnection connection2 = connection;
            Integer readTimeout2 = readTimeout;
            fileOutputStream.write(buffer2, 0, len);
            bytes += len;
            if (!progress.booleanValue() || emitter == null) {
                readTimeout = readTimeout2;
                connection = connection2;
                buffer2 = buffer2;
            } else {
                long currentTime = System.currentTimeMillis();
                if (currentTime - lastEmitTime <= 100) {
                    buffer = buffer2;
                } else {
                    buffer = buffer2;
                    emitter.emit(Integer.valueOf(bytes), Integer.valueOf(maxBytes));
                    lastEmitTime = currentTime;
                }
                readTimeout = readTimeout2;
                connection = connection2;
                buffer2 = buffer;
            }
        }
        if (progress.booleanValue() && emitter != null) {
            emitter.emit(Integer.valueOf(bytes), Integer.valueOf(maxBytes));
        }
        connectionInputStream.close();
        fileOutputStream.close();
        JSObject ret = new JSObject();
        ret.put("path", file.getAbsolutePath());
        return ret;
    }
}
