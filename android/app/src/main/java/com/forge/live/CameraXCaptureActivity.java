package com.forge.live;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.google.common.util.concurrent.ListenableFuture;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * In-process CameraX capture UI. Avoids OEM ACTION_IMAGE_CAPTURE flakiness.
 * Returns EXTRA_PATH to a JPEG under app external files Pictures/ForgeCam/.
 */
public class CameraXCaptureActivity extends AppCompatActivity {
    private static final String TAG = "CameraXCapture";
    public static final String EXTRA_FACING = "facing";
    public static final String EXTRA_PATH = "path";
    public static final String EXTRA_ERROR = "error";
    private static final int REQ_CAMERA = 4401;

    private PreviewView previewView;
    private TextView statusView;
    private Button btnShutter;
    private Button btnFlip;
    private Button btnCancel;

    private ProcessCameraProvider cameraProvider;
    private ImageCapture imageCapture;
    private ExecutorService cameraExecutor;
    private boolean useFront = false;
    private boolean capturing = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_camerax_capture);

        previewView = findViewById(R.id.previewView);
        statusView = findViewById(R.id.camStatus);
        btnShutter = findViewById(R.id.btnShutter);
        btnFlip = findViewById(R.id.btnFlip);
        btnCancel = findViewById(R.id.btnCancel);

        String facing = getIntent() != null ? getIntent().getStringExtra(EXTRA_FACING) : null;
        useFront = facing != null && "front".equalsIgnoreCase(facing);

        cameraExecutor = Executors.newSingleThreadExecutor();

        btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                setResult(RESULT_CANCELED);
                finish();
            }
        });
        btnFlip.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                if (capturing) return;
                useFront = !useFront;
                bindCamera();
            }
        });
        btnShutter.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                takePhoto();
            }
        });

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, REQ_CAMERA);
        } else {
            startCamera();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQ_CAMERA) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startCamera();
            } else {
                failAndFinish("CAMERA permission denied");
            }
        }
    }

    private void setStatus(String msg) {
        if (statusView != null) statusView.setText(msg != null ? msg : "");
    }

    private void startCamera() {
        setStatus("Starting camera…");
        final ListenableFuture<ProcessCameraProvider> future = ProcessCameraProvider.getInstance(this);
        future.addListener(new Runnable() {
            @Override public void run() {
                try {
                    cameraProvider = future.get();
                    bindCamera();
                } catch (Exception e) {
                    Log.e(TAG, "Camera provider failed", e);
                    failAndFinish("CameraX failed: " + e.getMessage());
                }
            }
        }, ContextCompat.getMainExecutor(this));
    }

    private void bindCamera() {
        if (cameraProvider == null) return;
        try {
            cameraProvider.unbindAll();

            Preview preview = new Preview.Builder().build();
            preview.setSurfaceProvider(previewView.getSurfaceProvider());

            imageCapture = new ImageCapture.Builder()
                    .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                    .setJpegQuality(95)
                    .build();

            CameraSelector selector = useFront
                    ? CameraSelector.DEFAULT_FRONT_CAMERA
                    : CameraSelector.DEFAULT_BACK_CAMERA;

            // Fall back if requested lens missing
            try {
                cameraProvider.bindToLifecycle(this, selector, preview, imageCapture);
            } catch (Exception e) {
                Log.w(TAG, "bind " + (useFront ? "front" : "back") + " failed, trying other", e);
                useFront = !useFront;
                selector = useFront
                        ? CameraSelector.DEFAULT_FRONT_CAMERA
                        : CameraSelector.DEFAULT_BACK_CAMERA;
                cameraProvider.bindToLifecycle(this, selector, preview, imageCapture);
            }
            setStatus(useFront ? "Front camera" : "Back camera");
        } catch (Exception e) {
            Log.e(TAG, "bindCamera failed", e);
            failAndFinish("Cannot open camera: " + e.getMessage());
        }
    }

    private File captureDir() {
        File base = getExternalFilesDir(android.os.Environment.DIRECTORY_PICTURES);
        if (base == null) base = new File(getCacheDir(), "camera");
        File dir = new File(base, "ForgeCam");
        if (!dir.exists()) {
            //noinspection ResultOfMethodCallIgnored
            dir.mkdirs();
        }
        return dir;
    }

    private void takePhoto() {
        if (imageCapture == null || capturing) return;
        capturing = true;
        btnShutter.setEnabled(false);
        setStatus("Capturing…");

        final String name = "camerax_"
                + new SimpleDateFormat("yyyyMMdd_HHmmss_SSS", Locale.US).format(new Date())
                + ".jpg";
        final File out = new File(captureDir(), name);
        if (out.exists()) {
            //noinspection ResultOfMethodCallIgnored
            out.delete();
        }

        ImageCapture.OutputFileOptions options =
                new ImageCapture.OutputFileOptions.Builder(out).build();

        imageCapture.takePicture(
                options,
                cameraExecutor,
                new ImageCapture.OnImageSavedCallback() {
                    @Override
                    public void onImageSaved(@NonNull ImageCapture.OutputFileResults outputFileResults) {
                        runOnUiThread(new Runnable() {
                            @Override public void run() {
                                capturing = false;
                                btnShutter.setEnabled(true);
                                if (!out.exists() || out.length() < 100) {
                                    failAndFinish("Capture file empty");
                                    return;
                                }
                                Intent data = new Intent();
                                data.putExtra(EXTRA_PATH, out.getAbsolutePath());
                                setResult(RESULT_OK, data);
                                finish();
                            }
                        });
                    }

                    @Override
                    public void onError(@NonNull ImageCaptureException exception) {
                        Log.e(TAG, "takePicture error", exception);
                        runOnUiThread(new Runnable() {
                            @Override public void run() {
                                capturing = false;
                                btnShutter.setEnabled(true);
                                setStatus("Capture failed");
                                Toast.makeText(
                                        CameraXCaptureActivity.this,
                                        "Capture failed: " + exception.getMessage(),
                                        Toast.LENGTH_SHORT).show();
                            }
                        });
                    }
                });
    }

    private void failAndFinish(String msg) {
        Intent data = new Intent();
        data.putExtra(EXTRA_ERROR, msg != null ? msg : "camera error");
        setResult(RESULT_CANCELED, data);
        finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        try {
            if (cameraProvider != null) cameraProvider.unbindAll();
        } catch (Exception ignore) {}
        if (cameraExecutor != null) {
            cameraExecutor.shutdown();
            cameraExecutor = null;
        }
    }
}
