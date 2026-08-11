package androidx.webkit;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Looper;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.webkit.internal.ApiFeature;
import androidx.webkit.internal.ApiHelperForM;
import androidx.webkit.internal.ApiHelperForO;
import androidx.webkit.internal.ApiHelperForOMR1;
import androidx.webkit.internal.ApiHelperForP;
import androidx.webkit.internal.ApiHelperForQ;
import androidx.webkit.internal.WebMessageAdapter;
import androidx.webkit.internal.WebMessagePortImpl;
import androidx.webkit.internal.WebViewFeatureInternal;
import androidx.webkit.internal.WebViewGlueCommunicator;
import androidx.webkit.internal.WebViewProviderAdapter;
import androidx.webkit.internal.WebViewProviderFactory;
import androidx.webkit.internal.WebViewRenderProcessClientFrameworkAdapter;
import androidx.webkit.internal.WebViewRenderProcessImpl;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.Executor;
import org.chromium.support_lib_boundary.WebViewProviderBoundaryInterface;

/* loaded from: classes.dex */
public class WebViewCompat {
    private static final Uri WILDCARD_URI = Uri.parse(ProxyConfig.MATCH_ALL_SCHEMES);
    private static final Uri EMPTY_URI = Uri.parse("");

    public interface VisualStateCallback {
        void onComplete(long j);
    }

    public interface WebMessageListener {
        void onPostMessage(WebView webView, WebMessageCompat webMessageCompat, Uri uri, boolean z, JavaScriptReplyProxy javaScriptReplyProxy);
    }

    private WebViewCompat() {
    }

    public static void postVisualStateCallback(WebView webview, long requestId, VisualStateCallback callback) {
        ApiFeature.M feature = WebViewFeatureInternal.VISUAL_STATE_CALLBACK;
        if (feature.isSupportedByFramework()) {
            ApiHelperForM.postVisualStateCallback(webview, requestId, callback);
        } else {
            if (feature.isSupportedByWebView()) {
                checkThread(webview);
                getProvider(webview).insertVisualStateCallback(requestId, callback);
                return;
            }
            throw WebViewFeatureInternal.getUnsupportedOperationException();
        }
    }

    public static void startSafeBrowsing(Context context, ValueCallback<Boolean> callback) {
        ApiFeature.O_MR1 feature = WebViewFeatureInternal.START_SAFE_BROWSING;
        if (feature.isSupportedByFramework()) {
            ApiHelperForOMR1.startSafeBrowsing(context, callback);
        } else {
            if (feature.isSupportedByWebView()) {
                getFactory().getStatics().initSafeBrowsing(context, callback);
                return;
            }
            throw WebViewFeatureInternal.getUnsupportedOperationException();
        }
    }

    public static void setSafeBrowsingAllowlist(Set<String> hosts, ValueCallback<Boolean> callback) {
        ApiFeature.O_MR1 preferredFeature = WebViewFeatureInternal.SAFE_BROWSING_ALLOWLIST_PREFERRED_TO_PREFERRED;
        ApiFeature.O_MR1 deprecatedFeature = WebViewFeatureInternal.SAFE_BROWSING_ALLOWLIST_PREFERRED_TO_DEPRECATED;
        if (preferredFeature.isSupportedByWebView()) {
            getFactory().getStatics().setSafeBrowsingAllowlist(hosts, callback);
            return;
        }
        List<String> hostsList = new ArrayList<>(hosts);
        if (deprecatedFeature.isSupportedByFramework()) {
            ApiHelperForOMR1.setSafeBrowsingWhitelist(hostsList, callback);
        } else {
            if (deprecatedFeature.isSupportedByWebView()) {
                getFactory().getStatics().setSafeBrowsingWhitelist(hostsList, callback);
                return;
            }
            throw WebViewFeatureInternal.getUnsupportedOperationException();
        }
    }

    @Deprecated
    public static void setSafeBrowsingWhitelist(List<String> hosts, ValueCallback<Boolean> callback) {
        setSafeBrowsingAllowlist(new HashSet(hosts), callback);
    }

    public static Uri getSafeBrowsingPrivacyPolicyUrl() {
        ApiFeature.O_MR1 feature = WebViewFeatureInternal.SAFE_BROWSING_PRIVACY_POLICY_URL;
        if (feature.isSupportedByFramework()) {
            return ApiHelperForOMR1.getSafeBrowsingPrivacyPolicyUrl();
        }
        if (feature.isSupportedByWebView()) {
            return getFactory().getStatics().getSafeBrowsingPrivacyPolicyUrl();
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static PackageInfo getCurrentWebViewPackage(Context context) {
        PackageInfo info = getCurrentLoadedWebViewPackage();
        return info != null ? info : getNotYetLoadedWebViewPackageInfo(context);
    }

    public static PackageInfo getCurrentLoadedWebViewPackage() {
        if (Build.VERSION.SDK_INT >= 26) {
            return ApiHelperForO.getCurrentWebViewPackage();
        }
        try {
            return getLoadedWebViewPackageInfo();
        } catch (ClassNotFoundException | IllegalAccessException | NoSuchMethodException | InvocationTargetException e) {
            return null;
        }
    }

    private static PackageInfo getLoadedWebViewPackageInfo() throws ClassNotFoundException, NoSuchMethodException, InvocationTargetException, IllegalAccessException {
        Class<?> webViewFactoryClass = Class.forName("android.webkit.WebViewFactory");
        return (PackageInfo) webViewFactoryClass.getMethod("getLoadedPackageInfo", new Class[0]).invoke(null, new Object[0]);
    }

    private static PackageInfo getNotYetLoadedWebViewPackageInfo(Context context) {
        String webviewPackageName;
        try {
            if (Build.VERSION.SDK_INT <= 23) {
                Class<?> webViewFactoryClass = Class.forName("android.webkit.WebViewFactory");
                webviewPackageName = (String) webViewFactoryClass.getMethod("getWebViewPackageName", new Class[0]).invoke(null, new Object[0]);
            } else {
                Class<?> webviewUpdateServiceClass = Class.forName("android.webkit.WebViewUpdateService");
                webviewPackageName = (String) webviewUpdateServiceClass.getMethod("getCurrentWebViewPackageName", new Class[0]).invoke(null, new Object[0]);
            }
            if (webviewPackageName == null) {
                return null;
            }
            PackageManager pm = context.getPackageManager();
            try {
                return pm.getPackageInfo(webviewPackageName, 0);
            } catch (PackageManager.NameNotFoundException e) {
                return null;
            }
        } catch (ClassNotFoundException e2) {
            return null;
        } catch (IllegalAccessException e3) {
            return null;
        } catch (NoSuchMethodException e4) {
            return null;
        } catch (InvocationTargetException e5) {
            return null;
        }
    }

    private static WebViewProviderAdapter getProvider(WebView webview) {
        return new WebViewProviderAdapter(createProvider(webview));
    }

    public static WebMessagePortCompat[] createWebMessageChannel(WebView webview) {
        ApiFeature.M feature = WebViewFeatureInternal.CREATE_WEB_MESSAGE_CHANNEL;
        if (feature.isSupportedByFramework()) {
            return WebMessagePortImpl.portsToCompat(ApiHelperForM.createWebMessageChannel(webview));
        }
        if (feature.isSupportedByWebView()) {
            return getProvider(webview).createWebMessageChannel();
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static void postWebMessage(WebView webview, WebMessageCompat message, Uri targetOrigin) {
        if (WILDCARD_URI.equals(targetOrigin)) {
            targetOrigin = EMPTY_URI;
        }
        ApiFeature.M feature = WebViewFeatureInternal.POST_WEB_MESSAGE;
        if (feature.isSupportedByFramework() && message.getType() == 0) {
            ApiHelperForM.postWebMessage(webview, WebMessagePortImpl.compatToFrameworkMessage(message), targetOrigin);
        } else {
            if (feature.isSupportedByWebView() && WebMessageAdapter.isMessagePayloadTypeSupportedByWebView(message.getType())) {
                getProvider(webview).postWebMessage(message, targetOrigin);
                return;
            }
            throw WebViewFeatureInternal.getUnsupportedOperationException();
        }
    }

    public static void addWebMessageListener(WebView webView, String jsObjectName, Set<String> allowedOriginRules, WebMessageListener listener) {
        ApiFeature.NoFramework feature = WebViewFeatureInternal.WEB_MESSAGE_LISTENER;
        if (feature.isSupportedByWebView()) {
            getProvider(webView).addWebMessageListener(jsObjectName, (String[]) allowedOriginRules.toArray(new String[0]), listener);
            return;
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static void removeWebMessageListener(WebView webview, String jsObjectName) {
        ApiFeature.NoFramework feature = WebViewFeatureInternal.WEB_MESSAGE_LISTENER;
        if (feature.isSupportedByWebView()) {
            getProvider(webview).removeWebMessageListener(jsObjectName);
            return;
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static ScriptHandler addDocumentStartJavaScript(WebView webview, String script, Set<String> allowedOriginRules) {
        ApiFeature.NoFramework feature = WebViewFeatureInternal.DOCUMENT_START_SCRIPT;
        if (feature.isSupportedByWebView()) {
            return getProvider(webview).addDocumentStartJavaScript(script, (String[]) allowedOriginRules.toArray(new String[0]));
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static WebViewClient getWebViewClient(WebView webview) {
        ApiFeature.O feature = WebViewFeatureInternal.GET_WEB_VIEW_CLIENT;
        if (feature.isSupportedByFramework()) {
            return ApiHelperForO.getWebViewClient(webview);
        }
        if (feature.isSupportedByWebView()) {
            return getProvider(webview).getWebViewClient();
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static WebChromeClient getWebChromeClient(WebView webview) {
        ApiFeature.O feature = WebViewFeatureInternal.GET_WEB_CHROME_CLIENT;
        if (feature.isSupportedByFramework()) {
            return ApiHelperForO.getWebChromeClient(webview);
        }
        if (feature.isSupportedByWebView()) {
            return getProvider(webview).getWebChromeClient();
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static WebViewRenderProcess getWebViewRenderProcess(WebView webview) {
        ApiFeature.Q feature = WebViewFeatureInternal.GET_WEB_VIEW_RENDERER;
        if (feature.isSupportedByFramework()) {
            android.webkit.WebViewRenderProcess renderer = ApiHelperForQ.getWebViewRenderProcess(webview);
            if (renderer != null) {
                return WebViewRenderProcessImpl.forFrameworkObject(renderer);
            }
            return null;
        }
        if (feature.isSupportedByWebView()) {
            return getProvider(webview).getWebViewRenderProcess();
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static void setWebViewRenderProcessClient(WebView webview, Executor executor, WebViewRenderProcessClient webViewRenderProcessClient) {
        ApiFeature.Q feature = WebViewFeatureInternal.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE;
        if (feature.isSupportedByFramework()) {
            ApiHelperForQ.setWebViewRenderProcessClient(webview, executor, webViewRenderProcessClient);
        } else {
            if (feature.isSupportedByWebView()) {
                getProvider(webview).setWebViewRenderProcessClient(executor, webViewRenderProcessClient);
                return;
            }
            throw WebViewFeatureInternal.getUnsupportedOperationException();
        }
    }

    public static void setWebViewRenderProcessClient(WebView webview, WebViewRenderProcessClient webViewRenderProcessClient) {
        ApiFeature.Q feature = WebViewFeatureInternal.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE;
        if (feature.isSupportedByFramework()) {
            ApiHelperForQ.setWebViewRenderProcessClient(webview, webViewRenderProcessClient);
        } else {
            if (feature.isSupportedByWebView()) {
                getProvider(webview).setWebViewRenderProcessClient(null, webViewRenderProcessClient);
                return;
            }
            throw WebViewFeatureInternal.getUnsupportedOperationException();
        }
    }

    public static WebViewRenderProcessClient getWebViewRenderProcessClient(WebView webview) {
        ApiFeature.Q feature = WebViewFeatureInternal.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE;
        if (feature.isSupportedByFramework()) {
            android.webkit.WebViewRenderProcessClient renderer = ApiHelperForQ.getWebViewRenderProcessClient(webview);
            if (renderer == null || !(renderer instanceof WebViewRenderProcessClientFrameworkAdapter)) {
                return null;
            }
            return ((WebViewRenderProcessClientFrameworkAdapter) renderer).getFrameworkRenderProcessClient();
        }
        if (feature.isSupportedByWebView()) {
            return getProvider(webview).getWebViewRenderProcessClient();
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static boolean isMultiProcessEnabled() {
        ApiFeature.NoFramework feature = WebViewFeatureInternal.MULTI_PROCESS;
        if (feature.isSupportedByWebView()) {
            return getFactory().getStatics().isMultiProcessEnabled();
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static String getVariationsHeader() {
        ApiFeature.NoFramework feature = WebViewFeatureInternal.GET_VARIATIONS_HEADER;
        if (feature.isSupportedByWebView()) {
            return getFactory().getStatics().getVariationsHeader();
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static void setProfile(WebView webView, String profileName) {
        ApiFeature.NoFramework feature = WebViewFeatureInternal.MULTI_PROFILE;
        if (feature.isSupportedByWebView()) {
            getProvider(webView).setProfileWithName(profileName);
            return;
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    public static Profile getProfile(WebView webView) {
        ApiFeature.NoFramework feature = WebViewFeatureInternal.MULTI_PROFILE;
        if (feature.isSupportedByWebView()) {
            return getProvider(webView).getProfile();
        }
        throw WebViewFeatureInternal.getUnsupportedOperationException();
    }

    private static WebViewProviderFactory getFactory() {
        return WebViewGlueCommunicator.getFactory();
    }

    private static WebViewProviderBoundaryInterface createProvider(WebView webview) {
        return getFactory().createWebView(webview);
    }

    private static void checkThread(WebView webview) {
        if (Build.VERSION.SDK_INT >= 28) {
            Looper webViewLooper = ApiHelperForP.getWebViewLooper(webview);
            if (webViewLooper != Looper.myLooper()) {
                throw new RuntimeException("A WebView method was called on thread '" + Thread.currentThread().getName() + "'. All WebView methods must be called on the same thread. (Expected Looper " + webViewLooper + " called on " + Looper.myLooper() + ", FYI main Looper is " + Looper.getMainLooper() + ")");
            }
            return;
        }
        try {
            Method checkThreadMethod = WebView.class.getDeclaredMethod("checkThread", new Class[0]);
            checkThreadMethod.setAccessible(true);
            checkThreadMethod.invoke(webview, new Object[0]);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        } catch (NoSuchMethodException e2) {
            throw new RuntimeException(e2);
        } catch (InvocationTargetException e3) {
            throw new RuntimeException(e3);
        }
    }
}
