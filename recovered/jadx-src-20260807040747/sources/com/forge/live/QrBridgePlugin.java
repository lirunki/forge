package com.forge.live;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
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
import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import java.util.Arrays;
import java.util.Collection;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.Map;

@CapacitorPlugin(name = "QrBridge", permissions = {@Permission(alias = "camera", strings = {"android.permission.CAMERA"})})
/* loaded from: classes4.dex */
public class QrBridgePlugin extends Plugin {
    @PluginMethod
    public void isAvailable(PluginCall call) {
        JSObject o = new JSObject();
        PackageManager pm = getContext().getPackageManager();
        o.put("available", true);
        o.put("camera", pm.hasSystemFeature("android.hardware.camera.any"));
        o.put("permission", hasCameraPermission());
        o.put("live", true);
        o.put("image", true);
        o.put("formats", "QR_CODE,CODE_128,EAN_13,UPC_A,…");
        call.resolve(o);
    }

    @PluginMethod
    public void requestPermission(PluginCall call) {
        if (hasCameraPermission()) {
            JSObject o = new JSObject();
            o.put("granted", true);
            o.put("permission", true);
            call.resolve(o);
            return;
        }
        requestPermissionForAlias("camera", call, "qrCamPerm");
    }

    @PermissionCallback
    private void qrCamPerm(PluginCall call) {
        JSObject o = new JSObject();
        boolean g = hasCameraPermission();
        o.put("granted", g);
        o.put("permission", g);
        call.resolve(o);
    }

    @PluginMethod
    public void scan(PluginCall call) {
        if (!hasCameraPermission()) {
            call.reject("CAMERA permission not granted. Call requestPermission first.");
            return;
        }
        try {
            Intent i = new Intent(getContext(), (Class<?>) QrScanActivity.class);
            String title = call.getString("title", "Scan code");
            i.putExtra("title", title);
            boolean z = true;
            if (Boolean.FALSE.equals(call.getBoolean(QrScanActivity.EXTRA_QR_ONLY, true))) {
                z = false;
            }
            boolean qrOnly = z;
            i.putExtra(QrScanActivity.EXTRA_QR_ONLY, qrOnly);
            startActivityForResult(call, i, "scanResult");
        } catch (Exception e) {
            call.reject("scan failed: " + e.getMessage(), e);
        }
    }

    @ActivityCallback
    private void scanResult(PluginCall call, ActivityResult result) {
        if (call == null) {
            return;
        }
        if (result.getResultCode() != -1 || result.getData() == null) {
            JSObject o = new JSObject();
            o.put("cancelled", true);
            o.put("text", (String) null);
            call.resolve(o);
            return;
        }
        Intent data = result.getData();
        JSObject o2 = new JSObject();
        o2.put("cancelled", false);
        o2.put("text", data.getStringExtra("text"));
        o2.put(QrScanActivity.EXTRA_FORMAT, data.getStringExtra(QrScanActivity.EXTRA_FORMAT));
        o2.put("rawBytes", data.getStringExtra(QrScanActivity.EXTRA_RAW_B64));
        call.resolve(o2);
    }

    @PluginMethod
    public void decodeImage(PluginCall call) {
        String b64 = call.getString("base64", null);
        String dataUrl = call.getString("dataUrl", null);
        if ((b64 == null || b64.isEmpty()) && dataUrl != null && dataUrl.contains("base64,")) {
            b64 = dataUrl.substring(dataUrl.indexOf("base64,") + 7);
        }
        if (b64 == null || b64.isEmpty()) {
            call.reject("base64 or dataUrl required");
            return;
        }
        try {
            byte[] bytes = Base64.decode(b64.replaceAll("\\s+", ""), 0);
            Bitmap bmp = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
            if (bmp == null) {
                call.reject("Could not decode image");
                return;
            }
            int w = bmp.getWidth();
            int h = bmp.getHeight();
            if (Math.max(w, h) > 1600) {
                float s = 1600 / Math.max(w, h);
                bmp = Bitmap.createScaledBitmap(bmp, Math.round(w * s), Math.round(h * s), true);
            }
            Result r = decodeBitmap(bmp, !Boolean.FALSE.equals(call.getBoolean(QrScanActivity.EXTRA_QR_ONLY, false)));
            if (r == null) {
                JSObject o = new JSObject();
                o.put("found", false);
                o.put("text", (String) null);
                call.resolve(o);
                return;
            }
            JSObject o2 = new JSObject();
            o2.put("found", true);
            o2.put("text", r.getText());
            o2.put(QrScanActivity.EXTRA_FORMAT, r.getBarcodeFormat() != null ? r.getBarcodeFormat().toString() : null);
            call.resolve(o2);
        } catch (Exception e) {
            call.reject("decodeImage failed: " + e.getMessage(), e);
        }
    }

    static Result decodeBitmap(Bitmap bmp, boolean qrOnly) {
        try {
            int w = bmp.getWidth();
            int h = bmp.getHeight();
            int[] pixels = new int[w * h];
            bmp.getPixels(pixels, 0, w, 0, 0, w, h);
            RGBLuminanceSource source = new RGBLuminanceSource(w, h, pixels);
            BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
            Map<DecodeHintType, Object> hints = new EnumMap<>(DecodeHintType.class);
            if (qrOnly) {
                hints.put(DecodeHintType.POSSIBLE_FORMATS, EnumSet.of(BarcodeFormat.QR_CODE));
            } else {
                hints.put(DecodeHintType.POSSIBLE_FORMATS, EnumSet.copyOf((Collection) Arrays.asList(BarcodeFormat.QR_CODE, BarcodeFormat.CODE_128, BarcodeFormat.CODE_39, BarcodeFormat.EAN_13, BarcodeFormat.EAN_8, BarcodeFormat.UPC_A, BarcodeFormat.UPC_E, BarcodeFormat.DATA_MATRIX, BarcodeFormat.ITF)));
            }
            hints.put(DecodeHintType.TRY_HARDER, Boolean.TRUE);
            MultiFormatReader reader = new MultiFormatReader();
            reader.setHints(hints);
            return reader.decodeWithState(bitmap);
        } catch (Exception e) {
            return null;
        }
    }

    private boolean hasCameraPermission() {
        return ContextCompat.checkSelfPermission(getContext(), "android.permission.CAMERA") == 0;
    }
}
