package com.capacitorjs.plugins.statusbar;

import android.view.View;
import android.view.Window;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import androidx.core.view.accessibility.AccessibilityEventCompat;

/* loaded from: classes2.dex */
public class StatusBar {
    private final AppCompatActivity activity;
    private int currentStatusBarColor;
    private final String defaultStyle = getStyle();

    public StatusBar(AppCompatActivity activity) {
        this.activity = activity;
        this.currentStatusBarColor = activity.getWindow().getStatusBarColor();
    }

    public void setStyle(String style) {
        Window window = this.activity.getWindow();
        View decorView = window.getDecorView();
        if (style.equals("DEFAULT")) {
            style = this.defaultStyle;
        }
        WindowInsetsControllerCompat windowInsetsControllerCompat = WindowCompat.getInsetsController(window, decorView);
        windowInsetsControllerCompat.setAppearanceLightStatusBars(!style.equals("DARK"));
    }

    public void setBackgroundColor(int color) {
        Window window = this.activity.getWindow();
        window.clearFlags(AccessibilityEventCompat.TYPE_VIEW_TARGETED_BY_SCROLL);
        window.addFlags(Integer.MIN_VALUE);
        window.setStatusBarColor(color);
        this.currentStatusBarColor = color;
    }

    public void hide() {
        View decorView = this.activity.getWindow().getDecorView();
        WindowInsetsControllerCompat windowInsetsControllerCompat = WindowCompat.getInsetsController(this.activity.getWindow(), decorView);
        windowInsetsControllerCompat.hide(WindowInsetsCompat.Type.statusBars());
    }

    public void show() {
        View decorView = this.activity.getWindow().getDecorView();
        WindowInsetsControllerCompat windowInsetsControllerCompat = WindowCompat.getInsetsController(this.activity.getWindow(), decorView);
        windowInsetsControllerCompat.show(WindowInsetsCompat.Type.statusBars());
    }

    public void setOverlaysWebView(Boolean overlays) {
        View decorView = this.activity.getWindow().getDecorView();
        int uiOptions = decorView.getSystemUiVisibility();
        if (overlays.booleanValue()) {
            decorView.setSystemUiVisibility(uiOptions | 256 | 1024);
            this.currentStatusBarColor = this.activity.getWindow().getStatusBarColor();
            this.activity.getWindow().setStatusBarColor(0);
        } else {
            decorView.setSystemUiVisibility(uiOptions & (-257) & (-1025));
            this.activity.getWindow().setStatusBarColor(this.currentStatusBarColor);
        }
    }

    private boolean getIsOverlaid() {
        return (this.activity.getWindow().getDecorView().getSystemUiVisibility() & 1024) == 1024;
    }

    public StatusBarInfo getInfo() {
        Window window = this.activity.getWindow();
        WindowInsetsCompat windowInsetsCompat = ViewCompat.getRootWindowInsets(window.getDecorView());
        boolean isVisible = windowInsetsCompat != null && windowInsetsCompat.isVisible(WindowInsetsCompat.Type.statusBars());
        StatusBarInfo info = new StatusBarInfo();
        info.setStyle(getStyle());
        info.setOverlays(getIsOverlaid());
        info.setVisible(isVisible);
        info.setColor(String.format("#%06X", Integer.valueOf(16777215 & window.getStatusBarColor())));
        return info;
    }

    private String getStyle() {
        View decorView = this.activity.getWindow().getDecorView();
        WindowInsetsControllerCompat windowInsetsControllerCompat = WindowCompat.getInsetsController(this.activity.getWindow(), decorView);
        if (!windowInsetsControllerCompat.isAppearanceLightStatusBars()) {
            return "DARK";
        }
        return "LIGHT";
    }
}
