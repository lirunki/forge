package com.forge.live;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import androidx.activity.result.ActivityResult;
import androidx.core.content.ContextCompat;
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

/**
 * Camera bridge — CameraX in-process capture (v2.6.16+).
 *
 * takePhoto launches {@link CameraXCaptureActivity} (no OEM camera intent).
 * pickPhoto still uses the system gallery picker.
 *
 * Result shape (back-compat):
 *   base64, dataUrl, mime, format, width, height, bytes, quality, path?, tempName?
 */
@CapacitorPlugin(
        name = "CameraBridge",
        permissions = {
            @Permission(alias = "camera", strings = {"android.permission.CAMERA"}),
            @Permission(alias = "photos", strings = {"android.permission.READ_EXTERNAL_STORAGE"})
        })
public class CameraBridgePlugin extends Plugin {
    private static final String TAG = "CameraBridge";
    public static final String TEMP_PREFIX = "camerax_";

    private File pendingCaptureFile;
    private int pendingQuality = 85;
    private int pendingMaxWidth = 1280;

    private boolean hasCameraPermission() {
        return ContextCompat.checkSelfPermission(getContext(), "android.permission.CAMERA") == 0;
    }

    private boolean hasGalleryPermission() {
        if (Build.VERSION.SDK_INT >= 33) {
            return ContextCompat.checkSelfPermission(getContext(), "android.permission.READ_MEDIA_IMAGES") == 0
                    || ContextCompat.checkSelfPermission(getContext(), "android.permission.READ_EXTERNAL_STORAGE") == 0;
        }
        return Build.VERSION.SDK_INT >= 29
                || ContextCompat.checkSelfPermission(getContext(), "android.permission.READ_EXTERNAL_STORAGE") == 0;
    }

    private boolean deviceHasCamera() {
        PackageManager pm = getContext().getPackageManager();
        return pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY)
                || pm.hasSystemFeature(PackageManager.FEATURE_CAMERA);
    }

    private File tempCaptureDir() {
        File base = null;
        try {
            base = getContext().getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        } catch (Exception ignore) {}
        if (base == null) {
            base = new File(getContext().getCacheDir(), "camera");
        }
        File dir = new File(base, "ForgeCam");
        if (!dir.exists()) {
            //noinspection ResultOfMethodCallIgnored
            dir.mkdirs();
        }
        return dir;
    }

    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject o = new JSObject();
        o.put("camera", deviceHasCamera());
        o.put("permission", hasCameraPermission());
        o.put("galleryPermission", hasGalleryPermission());
        o.put("facingModes", deviceHasCamera());
        o.put("engine", "camerax");
        o.put("tempPrefix", TEMP_PREFIX);
        call.resolve(o);
    }

    @PluginMethod
    public void requestPermission(PluginCall call) {
        String which = call.getString("alias", "camera");
        if ("photos".equals(which) || "gallery".equals(which)) {
            if (hasGalleryPermission()) {
                JSObject o = new JSObject();
                o.put("granted", true);
                o.put("alias", "photos");
                call.resolve(o);
                return;
            }
            requestPermissionForAlias("photos", call, "photosPermCallback");
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

    /** Delete camerax_* / legacy forge_* / cameratempix_* temps. Host may call on mini-app exit. */
    @PluginMethod
    public void cleanupTempPhotos(PluginCall call) {
        int n = 0;
        try {
            n += deleteTempsIn(tempCaptureDir());
        } catch (Exception e) {
            Log.w(TAG, "cleanup external: " + e.getMessage());
        }
        try {
            n += deleteTempsIn(new File(getContext().getCacheDir(), "camera"));
        } catch (Exception e) {
            Log.w(TAG, "cleanup cache: " + e.getMessage());
        }
        JSObject o = new JSObject();
        o.put("ok", true);
        o.put("deletedFiles", n);
        o.put("prefix", TEMP_PREFIX);
        call.resolve(o);
    }

    private int deleteTempsIn(File dir) {
        if (dir == null || !dir.isDirectory()) return 0;
        File[] list = dir.listFiles();
        if (list == null) return 0;
        int n = 0;
        for (File f : list) {
            if (f == null || !f.isFile()) continue;
            String name = f.getName();
            if (name == null) continue;
            if (name.startsWith(TEMP_PREFIX)
                    || name.startsWith("forge_")
                    || name.startsWith("cameratempix_")) {
                if (f.delete()) n++;
            }
        }
        return n;
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
        int mw = call.getInt("maxWidth", 1280).intValue();
        if (mw <= 0) mw = 1280;
        if (mw > 2048) mw = 2048;
        this.pendingMaxWidth = mw;
        String facing = call.getString("facing", "back");
        this.pendingCaptureFile = null;

        try {
            Intent intent = new Intent(getContext(), CameraXCaptureActivity.class);
            intent.putExtra(CameraXCaptureActivity.EXTRA_FACING, facing != null ? facing : "back");
            startActivityForResult(call, intent, "captureResult");
        } catch (Exception e) {
            Log.e(TAG, "takePhoto launch failed", e);
            call.reject("takePhoto failed: " + e.getMessage(), e);
        }
    }

    @ActivityCallback
    private void captureResult(PluginCall call, ActivityResult result) {
        if (call == null) return;
        try {
            int code = result != null ? result.getResultCode() : 0;
            Intent data = result != null ? result.getData() : null;

            if (code != -1 /* RESULT_OK */) {
                String err = data != null ? data.getStringExtra(CameraXCaptureActivity.EXTRA_ERROR) : null;
                if (err != null && !err.isEmpty()) {
                    call.reject(err);
                } else {
                    call.reject("Camera cancelled");
                }
                return;
            }

            String path = data != null ? data.getStringExtra(CameraXCaptureActivity.EXTRA_PATH) : null;
            if (path == null || path.isEmpty()) {
                call.reject("No image path from camera");
                return;
            }
            File file = new File(path);
            if (!file.exists() || file.length() < 32) {
                call.reject("Capture file missing or empty");
                return;
            }
            this.pendingCaptureFile = file;
            resolveFromFile(call, file);
        } catch (Exception e) {
            Log.e(TAG, "captureResult failed", e);
            call.reject("captureResult failed: " + e.getMessage(), e);
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
        o.put("tempName", file.getName());
        o.put("tempPrefix", TEMP_PREFIX);
        o.put("engine", "camerax");
        this.pendingCaptureFile = null;
        call.resolve(o);
    }

    @PluginMethod
    public void pickPhoto(PluginCall call) {
        this.pendingQuality = clamp(call.getInt("quality", 85).intValue(), 1, 100);
        int mw = call.getInt("maxWidth", 1280).intValue();
        if (mw <= 0) mw = 1280;
        if (mw > 2048) mw = 2048;
        this.pendingMaxWidth = mw;
        try {
            Intent intent;
            if (Build.VERSION.SDK_INT >= 33) {
                intent = new Intent(MediaStore.ACTION_PICK_IMAGES);
                intent.setType("image/*");
            } else {
                intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.setType("image/*");
                intent.addCategory(Intent.CATEGORY_OPENABLE);
            }
            Intent chooser = Intent.createChooser(intent, "Pick photo");
            startActivityForResult(call, chooser, "pickResult");
        } catch (Exception e) {
            call.reject("pickPhoto failed: " + e.getMessage(), e);
        }
    }

    @ActivityCallback
    private void pickResult(PluginCall call, ActivityResult result) {
        if (call == null) return;
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
                JSObject o = encodeUri(uri, this.pendingQuality, this.pendingMaxWidth);
                o.put("engine", "gallery");
                call.resolve(o);
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
        if (is == null) throw new Exception("Cannot open image");
        BitmapFactory.decodeStream(is, null, bounds);
        is.close();

        int sample = 1;
        if (maxWidth > 0) {
            int w = Math.max(bounds.outWidth, bounds.outHeight);
            while (w / sample > maxWidth * 2) sample *= 2;
        }
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inSampleSize = sample;
        InputStream is2 = getContext().getContentResolver().openInputStream(uri);
        if (is2 == null) throw new Exception("Cannot open image");
        Bitmap bitmap = BitmapFactory.decodeStream(is2, null, opts);
        is2.close();
        if (bitmap == null) throw new Exception("Decode failed");

        if (Build.VERSION.SDK_INT >= 24) {
            try {
                InputStream exifStream = getContext().getContentResolver().openInputStream(uri);
                if (exifStream != null) {
                    ExifInterface exif = new ExifInterface(exifStream);
                    bitmap = rotateFromExif(bitmap, exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, 1));
                    try { exifStream.close(); } catch (Exception ignore) {}
                }
            } catch (Exception ignore) {}
        }
        JSObject o = encodeBitmap(bitmap, quality, maxWidth, null);
        o.put("uri", uri.toString());
        return o;
    }

    private JSObject encodeBitmap(Bitmap bitmap, int quality, int maxWidth, String path) {
        if (bitmap == null) throw new IllegalArgumentException("null bitmap");

        int w = bitmap.getWidth();
        int h = bitmap.getHeight();
        int longEdge = Math.max(w, h);
        if (maxWidth > 0 && longEdge > maxWidth) {
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
        if (!bitmap.compress(Bitmap.CompressFormat.JPEG, quality, bos)) {
            bitmap.recycle();
            throw new IllegalStateException("JPEG compress failed");
        }
        byte[] bytes = bos.toByteArray();
        if (bytes.length < 24 || (bytes[0] & 0xFF) != 0xFF || (bytes[1] & 0xFF) != 0xD8) {
            bitmap.recycle();
            throw new IllegalStateException("Invalid JPEG produced (bytes=" + bytes.length + ")");
        }

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
        if (path != null) o.put("path", path);
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
            while (w / sample > maxWidth * 2) sample *= 2;
        }
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inSampleSize = sample;
        return BitmapFactory.decodeFile(path, opts);
    }

    private Bitmap applyExifOrientation(String path, Bitmap bitmap) {
        if (bitmap == null) return null;
        try {
            ExifInterface exif = new ExifInterface(path);
            int orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
            return rotateFromExif(bitmap, orientation);
        } catch (Exception e) {
            return bitmap;
        }
    }

    private Bitmap rotateFromExif(Bitmap bitmap, int orientation) {
        int degrees;
        switch (orientation) {
            case ExifInterface.ORIENTATION_ROTATE_180: degrees = 180; break;
            case ExifInterface.ORIENTATION_ROTATE_90:  degrees = 90;  break;
            case ExifInterface.ORIENTATION_ROTATE_270: degrees = 270; break;
            default: return bitmap;
        }
        Matrix m = new Matrix();
        m.postRotate(degrees);
        Bitmap rotated = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), m, true);
        if (rotated != bitmap) bitmap.recycle();
        return rotated;
    }

    private static int clamp(int v, int lo, int hi) {
        return Math.max(lo, Math.min(hi, v));
    }
}
