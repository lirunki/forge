package org.apache.cordova;

import android.view.KeyEvent;
import android.view.View;
import android.webkit.ValueCallback;

/* loaded from: classes.dex */
public interface CordovaWebViewEngine {

    public interface Client {
        void clearLoadTimeoutTimer();

        Boolean onDispatchKeyEvent(KeyEvent event);

        boolean onNavigationAttempt(String url);

        void onPageFinishedLoading(String url);

        void onPageStarted(String newUrl);

        void onReceivedError(int errorCode, String description, String failingUrl);
    }

    public interface EngineView {
        CordovaWebView getCordovaWebView();
    }

    boolean canGoBack();

    void clearCache();

    void clearHistory();

    void destroy();

    void evaluateJavascript(String js, ValueCallback<String> callback);

    ICordovaCookieManager getCookieManager();

    CordovaWebView getCordovaWebView();

    String getUrl();

    View getView();

    boolean goBack();

    void init(CordovaWebView parentWebView, CordovaInterface cordova, Client client, CordovaResourceApi resourceApi, PluginManager pluginManager, NativeToJsMessageQueue nativeToJsMessageQueue);

    void loadUrl(String url, boolean clearNavigationStack);

    void setPaused(boolean value);

    void stopLoading();
}
