package com.forge.live;

import android.content.ClipData;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import androidx.activity.result.ActivityResult;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

@CapacitorPlugin(name = "CameraBridge", permissions = {@Permission(alias = "camera", strings = {"android.permission.CAMERA"}), @Permission(alias = "photos", strings = {"android.permission.READ_EXTERNAL_STORAGE"})})
public class CameraBridgePlugin extends Plugin {
    private static final String TAG = "CameraBridge";
    private static final int URI_GRANT_FLAGS =
            Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION;
    /** Samsung/Fold often returns before the JPEG is fully flushed. */
    private static final long MIN_CAPTURE_BYTES = 2048L;
    private static final int FILE_WAIT_ATTEMPTS = 8;
    private static final long FILE_WAIT_MS = 120L;

    private File pendingCaptureFile;
    private Uri pendingCaptureUri;
    private int pendingQuality = 85;
    private int pendingMaxWidth = 1920;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private boolean hasCameraPermission() {
        return ContextCompat.checkSelfPermission(getContext(), "android.permission.CAMERA") == 0;
    }

    private boolean hasGalleryPermission() {
        return Build.VERSION.SDK_INT >= 33 ? ContextCompat.checkSelfPermission(getContext(), "android.permission.READ_MEDIA_IMAGES") == 0 || ContextCompat.checkSelfPermission(getContext(), "android.permission.READ_EXTERNAL_STORAGE") == 0 : Build.VERSION.SDK_INT >= 29 || ContextCompat.checkSelfPermission(getContext(), "android.permission.READ_EXTERNAL_STORAGE") == 0;
    }

    private boolean deviceHasCamera() {
        PackageManager pm = getContext().getPackageManager();
        return pm.hasSystemFeature("android.hardware.camera.any") || pm.hasSystemFeature("android.hardware.camera");
    }

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject o = new JSObject();
        o.put("camera", deviceHasCamera());
        o.put("permission", hasCameraPermission());
        o.put("galleryPermission", hasGalleryPermission());
        o.put("facingModes", deviceHasCamera());
        call.resolve(o);
    }

    @PluginMethod
    public void requestPermission(PluginCall call) {
        String which = call.getString("alias", "camera");
        if ("photos".equals(which) || "gallery".equals(which)) {
            if (Build.VERSION.SDK_INT >= 33 && hasGalleryPermission()) {
                JSObject o = new JSObject();
                o.put("granted", true);
                o.put("alias", "photos");
                call.resolve(o);
                return;
            }
            if (!hasGalleryPermission()) {
                requestPermissionForAlias("photos", call, "photosPermCallback");
                return;
            }
            JSObject o2 = new JSObject();
            o2.put("granted", true);
            o2.put("alias", "photos");
            call.resolve(o2);
            return;
        }
        if (hasCameraPermission()) {
            JSObject o3 = new JSObject();
            o3.put("granted", true);
            o3.put("alias", "camera");
            call.resolve(o3);
            return;
        }
        requestPermissionForAlias("camera", call, "cameraPermCallback");
    }

    @PermissionCallback
    private void cameraPermCallback(PluginCall call) {
        JSObject o = new JSObject();
        o.put("granted", hasCameraPermission());
        o.put("alias", "camera");
        call.resolve(o);
    }

    @PermissionCallback
    private void photosPermCallback(PluginCall call) {
        JSObject o = new JSObject();
        o.put("granted", hasGalleryPermission());
        o.put("alias", "photos");
        call.resolve(o);
    }

    @PluginMethod
    public void takePhoto(PluginCall call) {
        if (!deviceHasCamera()) {
            call.reject("No camera on this device");
            return;
        }
        if (!hasCameraPermission()) {
            call.reject("CAMERA permission not granted. Call requestPermission first.");
            return;
        }
        this.pendingQuality = clamp(call.getInt("quality", 85).intValue(), 1, 100);
        this.pendingMaxWidth = Math.max(0, call.getInt("maxWidth", 1920).intValue());
        String facing = call.getString("facing", "back");
        try {
            File dir = new File(getContext().getCacheDir(), "camera");
            if (!dir.exists() && !dir.mkdirs()) {
                call.reject("Cannot create camera cache dir");
                return;
            }
            String name = "forge_" + new SimpleDateFormat("yyyyMMdd_HHmmss_SSS", Locale.US).format(new Date()) + ".jpg";
            File out = new File(dir, name);
            // Many camera apps require the target file to already exist.
            if (!out.exists() && !out.createNewFile()) {
                call.reject("Cannot create capture file");
                return;
            }
            this.pendingCaptureFile = out;
            this.pendingCaptureUri = FileProvider.getUriForFile(
                    getContext(),
                    getContext().getPackageName() + ".fileprovider",
                    out);
            Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            intent.putExtra(MediaStore.EXTRA_OUTPUT, this.pendingCaptureUri);
            intent.addFlags(URI_GRANT_FLAGS);
            intent.setClipData(ClipData.newRawUri("output", this.pendingCaptureUri));
            grantUriToCameraApps(intent, this.pendingCaptureUri);
            if ("front".equalsIgnoreCase(facing)) {
                intent.putExtra("android.intent.extras.CAMERA_FACING", 1);
                intent.putExtra("android.intent.extra.USE_FRONT_CAMERA", true);
                intent.putExtra("camerafacing", "front");
                intent.putExtra("previous_mode", "front");
            } else {
                intent.putExtra("android.intent.extras.CAMERA_FACING", 0);
            }
            if (intent.resolveActivity(getContext().getPackageManager()) == null) {
                cleanupPending();
                call.reject("No camera app available");
            } else {
                startActivityForResult(call, intent, "captureResult");
            }
        } catch (Exception e) {
            cleanupPending();
            call.reject("takePhoto failed: " + e.getMessage(), e);
        }
    }

    private void grantUriToCameraApps(Intent intent, Uri uri) {
        try {
            PackageManager pm = getContext().getPackageManager();
            List<ResolveInfo> resList = pm.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
            if (resList == null) return;
            for (ResolveInfo ri : resList) {
                if (ri.activityInfo == null) continue;
                String pkg = ri.activityInfo.packageName;
                try {
                    getContext().grantUriPermission(pkg, uri, URI_GRANT_FLAGS);
                } catch (Exception e) {
                    Log.w(TAG, "grantUriPermission failed for " + pkg + ": " + e.getMessage());
                }
            }
        } catch (Exception e) {
            Log.w(TAG, "grantUriToCameraApps: " + e.getMessage());
        }
    }

    @ActivityCallback
    private void captureResult(PluginCall call, ActivityResult result) {
        if (call == null) {
            cleanupPending();
            return;
        }
        final int code = result != null ? result.getResultCode() : 0;
        final Intent data = result != null ? result.getData() : null;
        // Wait briefly: OEMs (esp. Samsung) often RESULT_OK before the JPEG is fully written.
        finishCaptureWithRetry(call, data, code, 0);
    }

    private void finishCaptureWithRetry(final PluginCall call, final Intent data, final int resultCode, final int attempt) {
        try {
            File file = this.pendingCaptureFile;
            boolean fileLooksReady = file != null
                    && file.exists()
                    && file.length() >= MIN_CAPTURE_BYTES
                    && hasJpegMagic(file);

            if (!fileLooksReady && file != null && file.exists() && file.length() > 0 && attempt < FILE_WAIT_ATTEMPTS) {
                mainHandler.postDelayed(new Runnable() {
                    @Override public void run() {
                        finishCaptureWithRetry(call, data, resultCode, attempt + 1);
                    }
                }, FILE_WAIT_MS);
                return;
            }

            // Samsung quirk: RESULT_CANCELED but full image still written to EXTRA_OUTPUT.
            if (fileLooksReady) {
                resolveFromFile(call, file);
                return;
            }

            if (resultCode != -1 /* RESULT_OK */) {
                cleanupPending();
                call.reject("Camera cancelled");
                return;
            }

            // File missing/too small — try URI or thumbnail extras.
            if (data != null && data.getData() != null) {
                JSObject o2 = encodeUri(data.getData(), this.pendingQuality, this.pendingMaxWidth);
                cleanupPending();
                call.resolve(o2);
                return;
            }
            if (data != null && data.getExtras() != null && (data.getExtras().get("data") instanceof Bitmap)) {
                Bitmap thumb = (Bitmap) data.getExtras().get("data");
                JSObject o3 = encodeBitmap(thumb, this.pendingQuality, this.pendingMaxWidth, null);
                cleanupPending();
                call.resolve(o3);
                return;
            }

            // Last chance: tiny non-magic file that still decodes
            if (file != null && file.exists() && file.length() > 0) {
                try {
                    resolveFromFile(call, file);
                    return;
                } catch (Exception ignore) {
                    Log.w(TAG, "encode small capture failed: " + ignore.getMessage());
                }
            }

            long len = file != null && file.exists() ? file.length() : -1L;
            cleanupPending();
            call.reject("No image returned from camera (fileBytes=" + len + ", attempts=" + attempt + ")");
        } catch (Exception e2) {
            cleanupPending();
            call.reject("captureResult failed: " + e2.getMessage(), e2);
        }
    }

    private void resolveFromFile(PluginCall call, File file) throws Exception {
        JSObject o = encodeFile(file, this.pendingQuality, this.pendingMaxWidth);
        boolean saveToGallery = Boolean.TRUE.equals(call.getBoolean("saveToGallery", false));
        if (saveToGallery) {
            try {
                MediaStore.Images.Media.insertImage(
                        getContext().getContentResolver(),
                        file.getAbsolutePath(),
                        file.getName(),
                        "Forge capture");
                o.put("savedToGallery", true);
            } catch (Exception e) {
                o.put("savedToGallery", false);
            }
        }
        o.put("path", file.getAbsolutePath());
        cleanupPendingKeepFile();
        call.resolve(o);
    }

    private static boolean hasJpegMagic(File file) {
        FileInputStream in = null;
        try {
            in = new FileInputStream(file);
            byte[] magic = new byte[3];
            int n = in.read(magic);
            // JPEG SOI FF D8 FF  — also accept FF D8 alone
            return n >= 2 && (magic[0] & 0xFF) == 0xFF && (magic[1] & 0xFF) == 0xD8;
        } catch (Exception e) {
            return false;
        } finally {
            if (in != null) {
                try { in.close(); } catch (Exception ignored) {}
            }
        }
    }

    @PluginMethod
    public void pickPhoto(PluginCall call) {
        Intent intent;
        this.pendingQuality = clamp(call.getInt("quality", 85).intValue(), 1, 100);
        this.pendingMaxWidth = Math.max(0, call.getInt("maxWidth", 1920).intValue());
        try {
            if (Build.VERSION.SDK_INT >= 33) {
                intent = new Intent("android.provider.action.PICK_IMAGES");
                intent.setType("image/*");
            } else {
                intent = new Intent("android.intent.action.GET_CONTENT");
                intent.setType("image/*");
                intent.addCategory("android.intent.category.OPENABLE");
            }
            Intent chooser = Intent.createChooser(intent, "Pick photo");
            startActivityForResult(call, chooser, "pickResult");
        } catch (Exception e) {
            call.reject("pickPhoto failed: " + e.getMessage(), e);
        }
    }

    @ActivityCallback
    private void pickResult(PluginCall call, ActivityResult result) {
        if (call == null) {
            return;
        }
        try {
            if (result.getResultCode() != -1) {
                call.reject("Pick cancelled");
                return;
            }
            Intent data = result.getData();
            Uri uri = data != null ? data.getData() : null;
            if (uri == null) {
                call.reject("No image selected");
            } else {
                call.resolve(encodeUri(uri, this.pendingQuality, this.pendingMaxWidth));
            }
        } catch (Exception e) {
            call.reject("pickResult failed: " + e.getMessage(), e);
        }
    }

    private JSObject encodeFile(File file, int quality, int maxWidth) throws Exception {
        Bitmap bitmap = decodeBounded(file.getAbsolutePath(), maxWidth);
        if (bitmap == null) {
            throw new Exception("Decode failed (null bitmap, fileBytes=" + file.length() + ")");
        }
        Bitmap oriented = applyExifOrientation(file.getAbsolutePath(), bitmap);
        if (oriented == null) {
            throw new Exception("EXIF orient failed");
        }
        return encodeBitmap(oriented, quality, maxWidth, file.getAbsolutePath());
    }

    private JSObject encodeUri(Uri uri, int quality, int maxWidth) throws Exception {
        BitmapFactory.Options bounds = new BitmapFactory.Options();
        bounds.inJustDecodeBounds = true;
        InputStream is = getContext().getContentResolver().openInputStream(uri);
        if (is == null) {
            throw new Exception("Cannot open image");
        }
        BitmapFactory.decodeStream(is, null, bounds);
        is.close();
        int sample = 1;
        if (maxWidth > 0) {
            int w = Math.max(bounds.outWidth, bounds.outHeight);
            while (w / sample > maxWidth * 2) {
                sample *= 2;
            }
        }
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inSampleSize = sample;
        InputStream is2 = getContext().getContentResolver().openInputStream(uri);
        if (is2 == null) {
            throw new Exception("Cannot open image");
        }
        Bitmap bitmap = BitmapFactory.decodeStream(is2, null, opts);
        is2.close();
        if (bitmap == null) {
            throw new Exception("Decode failed");
        }
        if (Build.VERSION.SDK_INT >= 24) {
            try {
                InputStream exifStream = getContext().getContentResolver().openInputStream(uri);
                if (exifStream != null) {
                    ExifInterface exif = new ExifInterface(exifStream);
                    Bitmap bitmap2 = rotateFromExif(bitmap, exif.getAttributeInt("Orientation", 1));
                    try {
                        exifStream.close();
                        bitmap = bitmap2;
                    } catch (Exception e) {
                        bitmap = bitmap2;
                    }
                }
            } catch (Exception e2) {
            }
        }
        JSObject o = encodeBitmap(bitmap, quality, maxWidth, null);
        o.put("uri", uri.toString());
        return o;
    }

    private JSObject encodeBitmap(Bitmap bitmap, int quality, int maxWidth, String path) {
        int w;
        int h;
        int longEdge;
        if (bitmap == null) {
            throw new IllegalArgumentException("null bitmap");
        }
        if (maxWidth > 0 && (longEdge = Math.max((w = bitmap.getWidth()), (h = bitmap.getHeight()))) > maxWidth) {
            // Must cast: int/int truncates to 0 when image is larger than maxWidth → 1×1 JPEG.
            float scale = maxWidth / (float) longEdge;
            int nw = Math.max(1, Math.round(w * scale));
            int nh = Math.max(1, Math.round(h * scale));
            Bitmap scaled = Bitmap.createScaledBitmap(bitmap, nw, nh, true);
            if (scaled != bitmap) {
                bitmap.recycle();
                bitmap = scaled;
            }
        }
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        // Re-encode ourselves so mini-apps always get a clean baseline JPEG (not OEM partials).
        if (!bitmap.compress(Bitmap.CompressFormat.JPEG, quality, bos)) {
            bitmap.recycle();
            throw new IllegalStateException("JPEG compress failed");
        }
        byte[] bytes = bos.toByteArray();
        if (bytes.length < 24 || (bytes[0] & 0xFF) != 0xFF || (bytes[1] & 0xFF) != 0xD8) {
            bitmap.recycle();
            throw new IllegalStateException("Invalid JPEG produced (bytes=" + bytes.length + ")");
        }
        // NO_WRAP — safe for data URLs / atob
        String b64 = Base64.encodeToString(bytes, Base64.NO_WRAP);
        JSObject o = new JSObject();
        o.put("base64", b64);
        o.put("dataUrl", "data:image/jpeg;base64," + b64);
        o.put("mime", "image/jpeg");
        o.put("format", "jpeg");
        o.put("width", bitmap.getWidth());
        o.put("height", bitmap.getHeight());
        o.put("bytes", bytes.length);
        o.put("quality", quality);
        if (path != null) {
            o.put("path", path);
        }
        bitmap.recycle();
        return o;
    }

    private Bitmap decodeBounded(String path, int maxWidth) {
        BitmapFactory.Options bounds = new BitmapFactory.Options();
        bounds.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(path, bounds);
        int sample = 1;
        if (maxWidth > 0) {
            int w = Math.max(bounds.outWidth, bounds.outHeight);
            while (w / sample > maxWidth * 2) {
                sample *= 2;
            }
        }
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inSampleSize = sample;
        return BitmapFactory.decodeFile(path, opts);
    }

    private Bitmap applyExifOrientation(String path, Bitmap bitmap) {
        if (bitmap == null) {
            return null;
        }
        try {
            ExifInterface exif = new ExifInterface(path);
            int orientation = exif.getAttributeInt("Orientation", 1);
            return rotateFromExif(bitmap, orientation);
        } catch (Exception e) {
            return bitmap;
        }
    }

    private Bitmap rotateFromExif(Bitmap bitmap, int orientation) {
        int degrees;
        switch (orientation) {
            case 3:
                degrees = 180;
                break;
            case 6:
                degrees = 90;
                break;
            case 8:
                degrees = 270;
                break;
            default:
                return bitmap;
        }
        Matrix m = new Matrix();
        m.postRotate(degrees);
        Bitmap rotated = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), m, true);
        if (rotated != bitmap) {
            bitmap.recycle();
        }
        return rotated;
    }

    private void cleanupPending() {
        File file = this.pendingCaptureFile;
        if (file != null && file.exists()) {
            try {
                this.pendingCaptureFile.delete();
            } catch (Exception e) {
            }
        }
        cleanupPendingKeepFile();
    }

    private void cleanupPendingKeepFile() {
        this.pendingCaptureFile = null;
        this.pendingCaptureUri = null;
    }

    private static int clamp(int v, int lo, int hi) {
        return Math.max(lo, Math.min(hi, v));
    }
}
