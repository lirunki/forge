package org.apache.cordova;

import android.net.Uri;
import androidx.webkit.ProxyConfig;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/* loaded from: classes.dex */
public class AllowList {
    public static final String TAG = "CordovaAllowList";
    private ArrayList<URLPattern> allowList = new ArrayList<>();

    private static class URLPattern {
        public Pattern host;
        public Pattern path;
        public Integer port;
        public Pattern scheme;

        private String regexFromPattern(String pattern, boolean allowWildcards) {
            StringBuilder regex = new StringBuilder();
            for (int i = 0; i < pattern.length(); i++) {
                char c = pattern.charAt(i);
                if (c == '*' && allowWildcards) {
                    regex.append(".");
                } else if ("\\.[]{}()^$?+|".indexOf(c) > -1) {
                    regex.append('\\');
                }
                regex.append(c);
            }
            return regex.toString();
        }

        /* JADX WARN: Removed duplicated region for block: B:13:0x0075 A[Catch: NumberFormatException -> 0x008e, TryCatch #0 {NumberFormatException -> 0x008e, blocks: (B:27:0x000a, B:30:0x0011, B:4:0x001e, B:6:0x0024, B:8:0x005d, B:11:0x0064, B:13:0x0075, B:16:0x007e, B:19:0x008a, B:21:0x0071, B:22:0x0027, B:24:0x002f, B:25:0x0051, B:3:0x001c), top: B:26:0x000a }] */
        /* JADX WARN: Removed duplicated region for block: B:22:0x0027 A[Catch: NumberFormatException -> 0x008e, TryCatch #0 {NumberFormatException -> 0x008e, blocks: (B:27:0x000a, B:30:0x0011, B:4:0x001e, B:6:0x0024, B:8:0x005d, B:11:0x0064, B:13:0x0075, B:16:0x007e, B:19:0x008a, B:21:0x0071, B:22:0x0027, B:24:0x002f, B:25:0x0051, B:3:0x001c), top: B:26:0x000a }] */
        /* JADX WARN: Removed duplicated region for block: B:6:0x0024 A[Catch: NumberFormatException -> 0x008e, TryCatch #0 {NumberFormatException -> 0x008e, blocks: (B:27:0x000a, B:30:0x0011, B:4:0x001e, B:6:0x0024, B:8:0x005d, B:11:0x0064, B:13:0x0075, B:16:0x007e, B:19:0x008a, B:21:0x0071, B:22:0x0027, B:24:0x002f, B:25:0x0051, B:3:0x001c), top: B:26:0x000a }] */
        /*
            Code decompiled incorrectly, please refer to instructions dump.
        */
        public URLPattern(String scheme, String host, String port, String path) throws MalformedURLException {
            if (scheme != null) {
                try {
                    if (!ProxyConfig.MATCH_ALL_SCHEMES.equals(scheme)) {
                        this.scheme = Pattern.compile(regexFromPattern(scheme, false), 2);
                        if (!ProxyConfig.MATCH_ALL_SCHEMES.equals(host)) {
                            this.host = null;
                        } else if (host.startsWith("*.")) {
                            this.host = Pattern.compile("([a-z0-9.-]*\\.)?" + regexFromPattern(host.substring(2), false), 2);
                        } else {
                            this.host = Pattern.compile(regexFromPattern(host, false), 2);
                        }
                        if (port != null && !ProxyConfig.MATCH_ALL_SCHEMES.equals(port)) {
                            this.port = Integer.valueOf(Integer.parseInt(port, 10));
                            if (path != null && !"/*".equals(path)) {
                                this.path = Pattern.compile(regexFromPattern(path, true));
                                return;
                            }
                            this.path = null;
                        }
                        this.port = null;
                        if (path != null) {
                            this.path = Pattern.compile(regexFromPattern(path, true));
                            return;
                        }
                        this.path = null;
                    }
                } catch (NumberFormatException e) {
                    throw new MalformedURLException("Port must be a number");
                }
            }
            this.scheme = null;
            if (!ProxyConfig.MATCH_ALL_SCHEMES.equals(host)) {
            }
            if (port != null) {
                this.port = Integer.valueOf(Integer.parseInt(port, 10));
                if (path != null) {
                }
                this.path = null;
            }
            this.port = null;
            if (path != null) {
            }
            this.path = null;
        }

        public boolean matches(Uri uri) {
            try {
                Pattern pattern = this.scheme;
                if (pattern != null && !pattern.matcher(uri.getScheme()).matches()) {
                    return false;
                }
                Pattern pattern2 = this.host;
                if (pattern2 != null && !pattern2.matcher(uri.getHost()).matches()) {
                    return false;
                }
                Integer num = this.port;
                if (num != null && !num.equals(Integer.valueOf(uri.getPort()))) {
                    return false;
                }
                Pattern pattern3 = this.path;
                if (pattern3 != null) {
                    if (!pattern3.matcher(uri.getPath()).matches()) {
                        return false;
                    }
                }
                return true;
            } catch (Exception e) {
                LOG.d(AllowList.TAG, e.toString());
                return false;
            }
        }
    }

    public void addAllowListEntry(String origin, boolean subdomains) {
        if (this.allowList != null) {
            try {
                if (origin.compareTo(ProxyConfig.MATCH_ALL_SCHEMES) == 0) {
                    LOG.d(TAG, "Unlimited access to network resources");
                    this.allowList = null;
                    return;
                }
                Pattern parts = Pattern.compile("^((\\*|[A-Za-z-]+):(//)?)?(\\*|((\\*\\.)?[^*/:]+))?(:(\\d+))?(/.*)?");
                Matcher m = parts.matcher(origin);
                if (m.matches()) {
                    String scheme = m.group(2);
                    String host = m.group(4);
                    if (("file".equals(scheme) || "content".equals(scheme)) && host == null) {
                        host = ProxyConfig.MATCH_ALL_SCHEMES;
                    }
                    String port = m.group(8);
                    String path = m.group(9);
                    if (scheme == null) {
                        this.allowList.add(new URLPattern("http", host, port, path));
                        this.allowList.add(new URLPattern("https", host, port, path));
                    } else {
                        this.allowList.add(new URLPattern(scheme, host, port, path));
                    }
                }
            } catch (Exception e) {
                LOG.d(TAG, "Failed to add origin %s", origin);
            }
        }
    }

    public boolean isUrlAllowListed(String uri) {
        if (this.allowList == null) {
            return true;
        }
        Uri parsedUri = Uri.parse(uri);
        Iterator<URLPattern> pit = this.allowList.iterator();
        while (pit.hasNext()) {
            URLPattern p = pit.next();
            if (p.matches(parsedUri)) {
                return true;
            }
        }
        return false;
    }
}
