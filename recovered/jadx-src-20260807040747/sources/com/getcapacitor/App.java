package com.getcapacitor;

/* loaded from: classes2.dex */
public class App {
    private AppRestoredListener appRestoredListener;
    private boolean isActive = false;
    private AppStatusChangeListener statusChangeListener;

    public interface AppRestoredListener {
        void onAppRestored(PluginResult pluginResult);
    }

    public interface AppStatusChangeListener {
        void onAppStatusChanged(Boolean bool);
    }

    public boolean isActive() {
        return this.isActive;
    }

    public void setStatusChangeListener(AppStatusChangeListener listener) {
        this.statusChangeListener = listener;
    }

    public void setAppRestoredListener(AppRestoredListener listener) {
        this.appRestoredListener = listener;
    }

    protected void fireRestoredResult(PluginResult result) {
        AppRestoredListener appRestoredListener = this.appRestoredListener;
        if (appRestoredListener != null) {
            appRestoredListener.onAppRestored(result);
        }
    }

    public void fireStatusChange(boolean isActive) {
        this.isActive = isActive;
        AppStatusChangeListener appStatusChangeListener = this.statusChangeListener;
        if (appStatusChangeListener != null) {
            appStatusChangeListener.onAppStatusChanged(Boolean.valueOf(isActive));
        }
    }
}
