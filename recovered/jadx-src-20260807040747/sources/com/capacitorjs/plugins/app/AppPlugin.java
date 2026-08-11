package com.capacitorjs.plugins.app;

import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.net.Uri;
import androidx.activity.OnBackPressedCallback;
import androidx.core.content.pm.PackageInfoCompat;
import com.getcapacitor.App;
import com.getcapacitor.JSObject;
import com.getcapacitor.Logger;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.PluginResult;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.util.InternalUtils;

@CapacitorPlugin(name = "App")
/* loaded from: classes2.dex */
public class AppPlugin extends Plugin {
    private static final String EVENT_BACK_BUTTON = "backButton";
    private static final String EVENT_PAUSE = "pause";
    private static final String EVENT_RESTORED_RESULT = "appRestoredResult";
    private static final String EVENT_RESUME = "resume";
    private static final String EVENT_STATE_CHANGE = "appStateChange";
    private static final String EVENT_URL_OPEN = "appUrlOpen";
    private boolean hasPausedEver = false;

    @Override // com.getcapacitor.Plugin
    public void load() {
        this.bridge.getApp().setStatusChangeListener(new App.AppStatusChangeListener() { // from class: com.capacitorjs.plugins.app.AppPlugin$$ExternalSyntheticLambda0
            @Override // com.getcapacitor.App.AppStatusChangeListener
            public final void onAppStatusChanged(Boolean bool) {
                AppPlugin.this.lambda$load$0(bool);
            }
        });
        this.bridge.getApp().setAppRestoredListener(new App.AppRestoredListener() { // from class: com.capacitorjs.plugins.app.AppPlugin$$ExternalSyntheticLambda1
            @Override // com.getcapacitor.App.AppRestoredListener
            public final void onAppRestored(PluginResult pluginResult) {
                AppPlugin.this.lambda$load$1(pluginResult);
            }
        });
        OnBackPressedCallback callback = new OnBackPressedCallback(true) { // from class: com.capacitorjs.plugins.app.AppPlugin.1
            @Override // androidx.activity.OnBackPressedCallback
            public void handleOnBackPressed() {
                if (!AppPlugin.this.hasListeners(AppPlugin.EVENT_BACK_BUTTON)) {
                    if (AppPlugin.this.bridge.getWebView().canGoBack()) {
                        AppPlugin.this.bridge.getWebView().goBack();
                    }
                } else {
                    JSObject data = new JSObject();
                    data.put("canGoBack", AppPlugin.this.bridge.getWebView().canGoBack());
                    AppPlugin.this.notifyListeners(AppPlugin.EVENT_BACK_BUTTON, data, true);
                    AppPlugin.this.bridge.triggerJSEvent("backbutton", "document");
                }
            }
        };
        getActivity().getOnBackPressedDispatcher().addCallback(getActivity(), callback);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$load$0(Boolean isActive) {
        Logger.debug(getLogTag(), "Firing change: " + isActive);
        JSObject data = new JSObject();
        data.put("isActive", (Object) isActive);
        notifyListeners(EVENT_STATE_CHANGE, data, false);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$load$1(PluginResult result) {
        Logger.debug(getLogTag(), "Firing restored result");
        notifyListeners(EVENT_RESTORED_RESULT, result.getWrappedResult(), true);
    }

    @PluginMethod
    public void exitApp(PluginCall call) {
        unsetAppListeners();
        call.resolve();
        getBridge().getActivity().finish();
    }

    @PluginMethod
    public void getInfo(PluginCall call) {
        JSObject data = new JSObject();
        try {
            PackageInfo pinfo = InternalUtils.getPackageInfo(getContext().getPackageManager(), getContext().getPackageName());
            ApplicationInfo applicationInfo = getContext().getApplicationInfo();
            int stringId = applicationInfo.labelRes;
            String appName = stringId == 0 ? applicationInfo.nonLocalizedLabel.toString() : getContext().getString(stringId);
            data.put("name", appName);
            data.put("id", pinfo.packageName);
            data.put("build", Integer.toString((int) PackageInfoCompat.getLongVersionCode(pinfo)));
            data.put("version", pinfo.versionName);
            call.resolve(data);
        } catch (Exception e) {
            call.reject("Unable to get App Info");
        }
    }

    @PluginMethod
    public void getLaunchUrl(PluginCall call) {
        Uri launchUri = this.bridge.getIntentUri();
        if (launchUri != null) {
            JSObject d = new JSObject();
            d.put("url", launchUri.toString());
            call.resolve(d);
            return;
        }
        call.resolve();
    }

    @PluginMethod
    public void getState(PluginCall call) {
        JSObject data = new JSObject();
        data.put("isActive", this.bridge.getApp().isActive());
        call.resolve(data);
    }

    @PluginMethod
    public void minimizeApp(PluginCall call) {
        getActivity().moveTaskToBack(true);
        call.resolve();
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnNewIntent(Intent intent) {
        super.handleOnNewIntent(intent);
        String action = intent.getAction();
        Uri url = intent.getData();
        if (!"android.intent.action.VIEW".equals(action) || url == null) {
            return;
        }
        JSObject ret = new JSObject();
        ret.put("url", url.toString());
        notifyListeners(EVENT_URL_OPEN, ret, true);
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnPause() {
        super.handleOnPause();
        this.hasPausedEver = true;
        notifyListeners(EVENT_PAUSE, null);
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnResume() {
        super.handleOnResume();
        if (this.hasPausedEver) {
            notifyListeners(EVENT_RESUME, null);
        }
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnDestroy() {
        unsetAppListeners();
    }

    private void unsetAppListeners() {
        this.bridge.getApp().setStatusChangeListener(null);
        this.bridge.getApp().setAppRestoredListener(null);
    }
}
