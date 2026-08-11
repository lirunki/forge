package com.forge.live;

import android.app.Activity;
import android.content.Intent;
import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.os.Bundle;
import android.util.Base64;
import android.view.TextureView;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.TextView;
import androidx.core.view.ViewCompat;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.PlanarYUVLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

public class QrScanActivity extends Activity implements TextureView.SurfaceTextureListener, Camera.PreviewCallback {
    public static final String EXTRA_FORMAT = "format";
    public static final String EXTRA_QR_ONLY = "qrOnly";
    public static final String EXTRA_RAW_B64 = "rawB64";
    public static final String EXTRA_TEXT = "text";
    public static final String EXTRA_TITLE = "title";
    private Camera camera;
    private int previewH;
    private int previewW;
    private MultiFormatReader reader;
    private TextureView textureView;
    private final AtomicBoolean handled = new AtomicBoolean(false);
    private boolean qrOnly = true;

    @Override // android.app.Activity
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String title = getIntent() != null ? getIntent().getStringExtra("title") : null;
        if (title == null || title.isEmpty()) {
            title = "Scan code";
        }
        this.qrOnly = getIntent() == null || getIntent().getBooleanExtra(EXTRA_QR_ONLY, true);
        this.reader = new MultiFormatReader();
        Map<DecodeHintType, Object> hints = new EnumMap<>(DecodeHintType.class);
        if (this.qrOnly) {
            hints.put(DecodeHintType.POSSIBLE_FORMATS, EnumSet.of(BarcodeFormat.QR_CODE));
        } else {
            hints.put(DecodeHintType.POSSIBLE_FORMATS, EnumSet.of(BarcodeFormat.QR_CODE, BarcodeFormat.CODE_128, BarcodeFormat.CODE_39, BarcodeFormat.EAN_13, BarcodeFormat.EAN_8, BarcodeFormat.UPC_A, BarcodeFormat.DATA_MATRIX));
        }
        hints.put(DecodeHintType.TRY_HARDER, Boolean.TRUE);
        this.reader.setHints(hints);
        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(ViewCompat.MEASURED_STATE_MASK);
        TextureView textureView = new TextureView(this);
        this.textureView = textureView;
        textureView.setSurfaceTextureListener(this);
        root.addView(this.textureView, new FrameLayout.LayoutParams(-1, -1));
        TextView label = new TextView(this);
        label.setText(title + "\nAlign code in view");
        label.setTextColor(-1);
        label.setTextSize(16.0f);
        label.setGravity(1);
        label.setPadding(24, 48, 24, 24);
        label.setShadowLayer(4.0f, 0.0f, 0.0f, ViewCompat.MEASURED_STATE_MASK);
        FrameLayout.LayoutParams lpLabel = new FrameLayout.LayoutParams(-1, -2);
        lpLabel.gravity = 48;
        root.addView(label, lpLabel);
        Button cancel = new Button(this);
        cancel.setText("Cancel");
        cancel.setOnClickListener(new View.OnClickListener() {
            @Override // android.view.View.OnClickListener
            public final void onClick(View view) {
                QrScanActivity.this.lambda$onCreate$0(view);
            }
        });
        FrameLayout.LayoutParams lpBtn = new FrameLayout.LayoutParams(-2, -2);
        lpBtn.gravity = 81;
        lpBtn.bottomMargin = 64;
        root.addView(cancel, lpBtn);
        setContentView(root);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$onCreate$0(View v) {
        setResult(0);
        finish();
    }

    @Override // android.view.TextureView.SurfaceTextureListener
    public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
        openCamera(surface);
    }

    @Override // android.view.TextureView.SurfaceTextureListener
    public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
    }

    @Override // android.view.TextureView.SurfaceTextureListener
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
        releaseCamera();
        return true;
    }

    @Override // android.view.TextureView.SurfaceTextureListener
    public void onSurfaceTextureUpdated(SurfaceTexture surface) {
    }

    private void openCamera(SurfaceTexture surface) {
        try {
            Camera open = Camera.open();
            this.camera = open;
            if (open == null) {
                finishCancelled();
                return;
            }
            Camera.Parameters params = open.getParameters();
            Camera.Size best = pickPreviewSize(params.getSupportedPreviewSizes(), 1280, 720);
            if (best != null) {
                params.setPreviewSize(best.width, best.height);
                this.previewW = best.width;
                this.previewH = best.height;
            } else {
                Camera.Size s = params.getPreviewSize();
                this.previewW = s.width;
                this.previewH = s.height;
            }
            List<String> focus = params.getSupportedFocusModes();
            if (focus != null && focus.contains("continuous-picture")) {
                params.setFocusMode("continuous-picture");
            } else if (focus != null && focus.contains("auto")) {
                params.setFocusMode("auto");
            }
            if (params.getSupportedPreviewFormats().contains(17)) {
                params.setPreviewFormat(17);
            }
            this.camera.setParameters(params);
            this.camera.setDisplayOrientation(90);
            this.camera.setPreviewTexture(surface);
            this.camera.setPreviewCallback(this);
            this.camera.startPreview();
        } catch (Exception e) {
            releaseCamera();
            finishCancelled();
        }
    }

    private static Camera.Size pickPreviewSize(List<Camera.Size> sizes, int wantW, int wantH) {
        if (sizes == null || sizes.isEmpty()) {
            return null;
        }
        Camera.Size best = null;
        int bestScore = Integer.MAX_VALUE;
        for (Camera.Size s : sizes) {
            int score = Math.abs(s.width - wantW) + Math.abs(s.height - wantH);
            if (score < bestScore) {
                bestScore = score;
                best = s;
            }
        }
        return best;
    }

    @Override // android.hardware.Camera.PreviewCallback
    public void onPreviewFrame(byte[] data, Camera cam) {
        if (this.handled.get() || data == null || this.previewW <= 0 || this.previewH <= 0) {
            return;
        }
        try {
            int i = this.previewW;
            int i2 = this.previewH;
            PlanarYUVLuminanceSource source = new PlanarYUVLuminanceSource(data, i, i2, 0, 0, i, i2, false);
            BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
            Result result = this.reader.decodeWithState(bitmap);
            this.reader.reset();
            if (result == null || result.getText() == null || !this.handled.compareAndSet(false, true)) {
                return;
            }
            Intent out = new Intent();
            out.putExtra("text", result.getText());
            if (result.getBarcodeFormat() != null) {
                out.putExtra(EXTRA_FORMAT, result.getBarcodeFormat().toString());
            }
            if (result.getRawBytes() != null) {
                out.putExtra(EXTRA_RAW_B64, Base64.encodeToString(result.getRawBytes(), 2));
            }
            setResult(-1, out);
            releaseCamera();
            finish();
        } catch (Exception e) {
            try {
                this.reader.reset();
            } catch (Exception e2) {
            }
        }
    }

    private void finishCancelled() {
        setResult(0);
        finish();
    }

    private void releaseCamera() {
        Camera camera = this.camera;
        if (camera != null) {
            try {
                camera.setPreviewCallback(null);
            } catch (Exception e) {
            }
            try {
                this.camera.stopPreview();
            } catch (Exception e2) {
            }
            try {
                this.camera.release();
            } catch (Exception e3) {
            }
            this.camera = null;
        }
    }

    @Override // android.app.Activity
    protected void onPause() {
        super.onPause();
        releaseCamera();
    }

    @Override // android.app.Activity
    public void onBackPressed() {
        setResult(0);
        super.onBackPressed();
    }
}
