package com.forge.live;

import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import androidx.webkit.internal.AssetHelper;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.function.Function;
import org.json.JSONArray;
import org.json.JSONObject;

@CapacitorPlugin(name = "AppsBridge")
/* loaded from: classes4.dex */
public class AppsBridgePlugin extends Plugin {
    private static final int DEFAULT_LIMIT = 400;
    private static final String[] KNOWN_PACKAGES = {"com.google.android.apps.maps", "com.waze", "com.google.android.apps.mapslite", "com.mapquest.android.ace", "com.mapfactor.maps", "com.here.app.maps", "com.sygic.aura", "com.tomtom.gplay.navapp", "com.autonavi.minimap", "com.baidu.BaiduMap", "ru.yandex.yandexnavi", "ru.yandex.yandexmaps", "com.ubercab", "com.ubercab.driver", "com.lyft.android", "com.whatsapp", "com.whatsapp.w4b", "org.telegram.messenger", "org.telegram.messenger.web", "com.facebook.orca", "com.facebook.katana", "com.instagram.android", "com.twitter.android", "com.zhiliaoapp.musically", "com.snapchat.android", "com.viber.voip", "com.discord", "com.slack", "com.google.android.apps.messaging", "com.samsung.android.messaging", "com.google.android.gm", "com.android.chrome", "com.chrome.beta", "com.sec.android.app.sbrowser", "org.mozilla.firefox", "com.google.android.youtube", "com.spotify.music", "com.netflix.mediaclient", "com.google.android.googlequicksearchbox", "com.google.android.apps.photos", "com.google.android.calendar", "com.google.android.keep", "com.google.android.contacts", "com.google.android.dialer", "com.android.vending", "com.android.settings"};
    private static final int MAX_LIMIT = 2000;

    @PluginMethod
    public void getCapabilities(PluginCall call) {
        JSObject caps = new JSObject();
        caps.put("apps", true);
        caps.put("listApps", true);
        caps.put("listActivities", true);
        caps.put("launch", true);
        caps.put("resolve", true);
        caps.put("queryAllPackages", hasQueryAllPackages());
        call.resolve(caps);
    }

    @PluginMethod
    public void listApps(PluginCall call) {
        int knownHits;
        int knownHits2;
        int intentHits;
        int installedHits;
        int launcherHits;
        Map<String, JSObject> byPkg;
        try {
            String query = norm(call.getString("query", null));
            if (query == null) {
                query = norm(call.getString("q", null));
            }
            boolean z = true;
            boolean launchableOnly = call.getBoolean("launchableOnly", true).booleanValue();
            boolean includeSystem = call.getBoolean("includeSystem", true).booleanValue();
            boolean probeKnown = call.getBoolean("probeKnown", true).booleanValue();
            int limit = clampLimit(call.getInt("limit", Integer.valueOf(DEFAULT_LIMIT)));
            PackageManager pm = getContext().getPackageManager();
            Map<String, JSObject> byPkg2 = new LinkedHashMap<>();
            int launcherHits2 = addFromLauncherQuery(pm, byPkg2, includeSystem);
            int installedHits2 = addFromInstalledApps(pm, byPkg2, includeSystem, launchableOnly);
            int intentHits2 = addFromCommonIntents(pm, byPkg2, includeSystem);
            if (!probeKnown) {
                knownHits = 0;
            } else {
                int knownHits3 = addFromKnownPackages(pm, byPkg2, includeSystem, launchableOnly);
                knownHits = knownHits3;
            }
            if (query == null || !query.contains(".")) {
                knownHits2 = knownHits;
                intentHits = intentHits2;
                installedHits = installedHits2;
                launcherHits = launcherHits2;
                byPkg = byPkg2;
            } else {
                knownHits2 = knownHits;
                intentHits = intentHits2;
                installedHits = installedHits2;
                launcherHits = launcherHits2;
                byPkg = byPkg2;
                addPackageIfVisible(pm, byPkg2, query, includeSystem, launchableOnly, "query");
            }
            List<JSObject> apps = new ArrayList<>();
            for (JSObject row : byPkg.values()) {
                String label = row.getString("label");
                String pkg = row.getString("packageName");
                if (query == null || matchesQuery(query, label, pkg)) {
                    if (!launchableOnly || row.optBoolean("launchable", false)) {
                        apps.add(row);
                    }
                }
            }
            Collections.sort(apps, new Comparator() { // from class: com.forge.live.AppsBridgePlugin$$ExternalSyntheticLambda1
                @Override // java.util.Comparator
                public final int compare(Object obj, Object obj2) {
                    return AppsBridgePlugin.lambda$listApps$0((JSObject) obj, (JSObject) obj2);
                }
            });
            int totalMatched = apps.size();
            if (apps.size() > limit) {
                apps = new ArrayList<>(apps.subList(0, limit));
            }
            JSObject ret = new JSObject();
            ret.put("ok", true);
            ret.put("count", apps.size());
            ret.put("totalMatched", totalMatched);
            if (totalMatched <= apps.size()) {
                z = false;
            }
            ret.put("truncated", z);
            ret.put("apps", toArray(apps));
            ret.put("queryAllPackages", hasQueryAllPackages());
            int launcherHits3 = launcherHits;
            ret.put("launcherHits", launcherHits3);
            ret.put("installedHits", installedHits);
            ret.put("intentHits", intentHits);
            ret.put("knownHits", knownHits2);
            int knownHits4 = byPkg.size();
            ret.put("discovered", knownHits4);
            JSArray labels = new JSArray();
            JSArray packages = new JSArray();
            JSArray options = new JSArray();
            for (JSObject a : apps) {
                int totalMatched2 = totalMatched;
                labels.put(a.getString("label"));
                packages.put(a.getString("packageName"));
                JSObject opt = new JSObject();
                int launcherHits4 = launcherHits3;
                opt.put("value", a.getString("packageName"));
                opt.put("label", a.getString("label"));
                JSArray options2 = options;
                options2.put(opt);
                options = options2;
                apps = apps;
                totalMatched = totalMatched2;
                launcherHits3 = launcherHits4;
            }
            ret.put("labels", (Object) labels);
            ret.put("packages", (Object) packages);
            ret.put("options", (Object) options);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("listApps failed: " + e.getMessage(), e);
        }
    }

    static /* synthetic */ int lambda$listApps$0(JSObject a, JSObject b) {
        String la = a.getString("label");
        String lb = b.getString("label");
        if (la == null) {
            la = "";
        }
        if (lb == null) {
            lb = "";
        }
        return la.compareToIgnoreCase(lb);
    }

    @PluginMethod
    public void find(PluginCall call) {
        listApps(call);
    }

    @PluginMethod
    public void getApp(PluginCall call) {
        long vc;
        try {
            try {
                String pkg = packageNameOf(call);
                if (pkg == null) {
                    call.reject("packageName required");
                    return;
                }
                PackageManager pm = getContext().getPackageManager();
                ApplicationInfo ai = getApplicationInfo(pm, pkg);
                CharSequence labelCs = pm.getApplicationLabel(ai);
                String label = labelCs != null ? labelCs.toString() : pkg;
                Intent launch = pm.getLaunchIntentForPackage(pkg);
                JSObject row = new JSObject();
                boolean z = true;
                row.put("ok", true);
                row.put("packageName", pkg);
                row.put("label", label);
                row.put("name", label);
                row.put("system", isSystemApp(ai));
                if (launch == null) {
                    z = false;
                }
                row.put("launchable", z);
                if (launch != null && launch.getComponent() != null) {
                    row.put("activity", launch.getComponent().getClassName());
                }
                try {
                    PackageInfo pi = getPackageInfo(pm, pkg, 0);
                    row.put("versionName", pi.versionName);
                    if (Build.VERSION.SDK_INT >= 28) {
                        vc = pi.getLongVersionCode();
                    } else {
                        vc = pi.versionCode;
                    }
                    row.put("versionCode", vc);
                } catch (Exception e) {
                }
                call.resolve(row);
            } catch (Exception e2) {
                call.reject("getApp failed: " + e2.getMessage(), e2);
            }
        } catch (PackageManager.NameNotFoundException e3) {
            JSObject ret = new JSObject();
            ret.put("ok", false);
            ret.put("error", "Package not found: " + packageNameOf(call));
            call.resolve(ret);
        }
    }

    @PluginMethod
    public void listActivities(PluginCall pluginCall) {
        boolean exportedOnly;
        String label;
        PackageManager pm;
        PackageInfo pi;
        try {
            String pkg = packageNameOf(pluginCall);
            if (pkg == null) {
                pluginCall.reject("packageName required");
                return;
            }
            int i = 0;
            boolean exportedOnly2 = pluginCall.getBoolean("exportedOnly", false).booleanValue();
            int limit = clampLimit(pluginCall.getInt("limit", Integer.valueOf(DEFAULT_LIMIT)));
            PackageManager pm2 = getContext().getPackageManager();
            PackageInfo pi2 = getPackageInfo(pm2, pkg, 1);
            List<JSObject> acts = new ArrayList<>();
            ActivityInfo[] infos = pi2.activities;
            if (infos != null) {
                int length = infos.length;
                while (i < length) {
                    ActivityInfo ai = infos[i];
                    if (ai == null) {
                        exportedOnly = exportedOnly2;
                        pm = pm2;
                        pi = pi2;
                    } else if (!exportedOnly2 || ai.exported) {
                        CharSequence labelCs = ai.loadLabel(pm2);
                        if (labelCs != null) {
                            exportedOnly = exportedOnly2;
                            label = labelCs.toString();
                        } else {
                            exportedOnly = exportedOnly2;
                            label = ai.name;
                        }
                        JSObject row = new JSObject();
                        pm = pm2;
                        row.put("name", ai.name);
                        row.put("className", ai.name);
                        row.put("packageName", pkg);
                        pi = pi2;
                        row.put("component", pkg + "/" + ai.name);
                        row.put("label", label);
                        row.put("exported", ai.exported);
                        row.put("enabled", ai.enabled);
                        if (ai.permission != null) {
                            row.put("permission", ai.permission);
                        }
                        acts.add(row);
                        if (acts.size() >= limit) {
                            break;
                        }
                    } else {
                        exportedOnly = exportedOnly2;
                        pm = pm2;
                        pi = pi2;
                    }
                    i++;
                    exportedOnly2 = exportedOnly;
                    pm2 = pm;
                    pi2 = pi;
                }
            }
            Collections.sort(acts, Comparator.comparing(new Function() { // from class: com.forge.live.AppsBridgePlugin$$ExternalSyntheticLambda0
                @Override // java.util.function.Function
                public final Object apply(Object obj) {
                    return AppsBridgePlugin.lambda$listActivities$1((JSObject) obj);
                }
            }));
            JSObject jSObject = new JSObject();
            jSObject.put("ok", true);
            jSObject.put("packageName", pkg);
            jSObject.put("count", acts.size());
            jSObject.put("activities", toArray(acts));
            JSArray options = new JSArray();
            for (JSObject a : acts) {
                JSObject opt = new JSObject();
                opt.put("value", a.getString("name"));
                opt.put("label", a.getString("label") + " (" + shortClass(a.getString("name")) + ")");
                options.put(opt);
            }
            jSObject.put("options", (Object) options);
            pluginCall.resolve(jSObject);
        } catch (PackageManager.NameNotFoundException e) {
            pluginCall.reject("Package not found: " + packageNameOf(pluginCall));
        } catch (Exception e2) {
            pluginCall.reject("listActivities failed: " + e2.getMessage(), e2);
        }
    }

    static /* synthetic */ String lambda$listActivities$1(JSObject a) {
        String l = a.getString("label");
        return l != null ? l.toLowerCase(Locale.US) : "";
    }

    @PluginMethod
    public void resolve(PluginCall call) {
        try {
            Intent intent = buildIntent(call);
            PackageManager pm = getContext().getPackageManager();
            int limit = clampLimit(call.getInt("limit", 50));
            List<ResolveInfo> resolved = queryActivities(pm, intent);
            List<JSObject> acts = new ArrayList<>();
            for (ResolveInfo ri : resolved) {
                if (ri.activityInfo != null) {
                    CharSequence labelCs = ri.loadLabel(pm);
                    String label = labelCs != null ? labelCs.toString() : ri.activityInfo.name;
                    JSObject row = new JSObject();
                    row.put("packageName", ri.activityInfo.packageName);
                    row.put("activity", ri.activityInfo.name);
                    row.put("className", ri.activityInfo.name);
                    row.put("component", ri.activityInfo.packageName + "/" + ri.activityInfo.name);
                    row.put("label", label);
                    row.put("exported", ri.activityInfo.exported);
                    acts.add(row);
                    if (acts.size() >= limit) {
                        break;
                    }
                }
            }
            JSObject ret = new JSObject();
            ret.put("ok", true);
            ret.put("count", acts.size());
            ret.put("activities", (Object) toArray(acts));
            ret.put("apps", (Object) toArray(acts));
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("resolve failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void launch(PluginCall call) {
        try {
            boolean onlyPkg = false;
            boolean chooser = call.getBoolean("chooser", false).booleanValue();
            String chooserTitle = call.getString("chooserTitle", "Open with");
            Intent intent = buildIntent(call);
            String pkg = packageNameOf(call);
            String activity = activityOf(call);
            String data = norm(call.getString("data", null));
            if (data == null) {
                data = norm(call.getString("uri", null));
            }
            String action = norm(call.getString("action", null));
            if (pkg != null && activity == null && data == null && (action == null || "android.intent.action.MAIN".equals(action))) {
                onlyPkg = true;
            }
            if (onlyPkg) {
                Intent launch = getContext().getPackageManager().getLaunchIntentForPackage(pkg);
                if (launch == null) {
                    call.reject("No launchable activity for " + pkg);
                    return;
                }
                intent = launch;
            }
            intent.addFlags(268435456);
            Integer flags = call.getInt("flags", null);
            if (flags != null) {
                intent.addFlags(flags.intValue());
            }
            Intent toStart = intent;
            if (chooser) {
                toStart = Intent.createChooser(intent, chooserTitle != null ? chooserTitle : "Open with");
                toStart.addFlags(268435456);
            }
            getContext().startActivity(toStart);
            JSObject ret = new JSObject();
            ret.put("ok", true);
            ret.put("opened", true);
            ret.put("launched", true);
            if (pkg != null) {
                ret.put("packageName", pkg);
            }
            if (activity != null) {
                ret.put("activity", activity);
            }
            if (toStart.getAction() != null) {
                ret.put("action", toStart.getAction());
            }
            if (toStart.getDataString() != null) {
                ret.put("data", toStart.getDataString());
            }
            call.resolve(ret);
        } catch (ActivityNotFoundException anf) {
            call.reject("No activity found to handle intent: " + anf.getMessage(), anf);
        } catch (Exception e) {
            call.reject("launch failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void startActivity(PluginCall call) {
        launch(call);
    }

    @PluginMethod
    public void openApp(PluginCall call) {
        launch(call);
    }

    private int addFromLauncherQuery(PackageManager pm, Map<String, JSObject> byPkg, boolean includeSystem) {
        String pkg;
        int added = 0;
        try {
            Intent main = new Intent("android.intent.action.MAIN");
            main.addCategory("android.intent.category.LAUNCHER");
            for (ResolveInfo ri : queryActivities(pm, main)) {
                if (ri != null && ri.activityInfo != null && (pkg = ri.activityInfo.packageName) != null && !byPkg.containsKey(pkg)) {
                    ApplicationInfo ai = ri.activityInfo.applicationInfo;
                    boolean system = isSystemApp(ai);
                    if (includeSystem || !system) {
                        CharSequence labelCs = ri.loadLabel(pm);
                        String label = labelCs != null ? labelCs.toString() : pkg;
                        JSObject row = baseAppRow(pkg, label, system, true);
                        row.put("activity", ri.activityInfo.name);
                        row.put("exported", ri.activityInfo.exported);
                        row.put("source", "launcher");
                        byPkg.put(pkg, row);
                        added++;
                    }
                }
            }
        } catch (Exception e) {
        }
        return added;
    }

    private int addFromInstalledApps(PackageManager pm, Map<String, JSObject> byPkg, boolean includeSystem, boolean launchableOnly) {
        int added = 0;
        try {
            for (ApplicationInfo ai : getInstalledApplications(pm)) {
                if (ai != null && ai.packageName != null && !byPkg.containsKey(ai.packageName)) {
                    boolean system = isSystemApp(ai);
                    if (includeSystem || !system) {
                        Intent launch = null;
                        try {
                            launch = pm.getLaunchIntentForPackage(ai.packageName);
                        } catch (Exception e) {
                        }
                        boolean launchable = launch != null;
                        if (!launchableOnly || launchable) {
                            CharSequence labelCs = pm.getApplicationLabel(ai);
                            String label = labelCs != null ? labelCs.toString() : ai.packageName;
                            JSObject row = baseAppRow(ai.packageName, label, system, launchable);
                            if (launch != null && launch.getComponent() != null) {
                                row.put("activity", launch.getComponent().getClassName());
                            }
                            row.put("source", "installed");
                            byPkg.put(ai.packageName, row);
                            added++;
                        }
                    }
                }
            }
        } catch (Exception e2) {
        }
        return added;
    }

    private int addFromCommonIntents(PackageManager pm, Map<String, JSObject> byPkg, boolean includeSystem) {
        PackageManager packageManager = pm;
        int before = byPkg.size();
        Intent[] probes = {viewIntent("geo:0,0?q=coffee"), viewIntent("google.navigation:q=Home"), viewIntent("https://maps.google.com/?q=coffee"), viewIntent("https://www.google.com/maps/search/?api=1&query=coffee"), viewIntent("waze://?q=coffee"), viewIntent("https://waze.com/ul?q=coffee"), sendTextIntent()};
        int length = probes.length;
        int i = 0;
        while (i < length) {
            Intent intent = probes[i];
            try {
                for (ResolveInfo ri : queryActivities(packageManager, intent)) {
                    if (ri == null) {
                        packageManager = pm;
                    } else if (ri.activityInfo != null) {
                        String pkg = ri.activityInfo.packageName;
                        if (pkg == null) {
                            packageManager = pm;
                        } else if (!byPkg.containsKey(pkg)) {
                            ApplicationInfo ai = ri.activityInfo.applicationInfo;
                            boolean system = isSystemApp(ai);
                            if (includeSystem || !system) {
                                String label = pkg;
                                if (ai != null) {
                                    try {
                                        CharSequence appLabel = packageManager.getApplicationLabel(ai);
                                        if (appLabel != null && appLabel.length() > 0) {
                                            label = appLabel.toString();
                                        }
                                    } catch (Exception e) {
                                    }
                                } else {
                                    CharSequence labelCs = ri.loadLabel(packageManager);
                                    if (labelCs != null) {
                                        label = labelCs.toString();
                                    }
                                }
                                String label2 = label;
                                boolean launchable = true;
                                try {
                                    launchable = packageManager.getLaunchIntentForPackage(pkg) != null;
                                } catch (Exception e2) {
                                }
                                JSObject row = baseAppRow(pkg, label2, system, launchable);
                                row.put("activity", ri.activityInfo.name);
                                row.put("source", "intent");
                                byPkg.put(pkg, row);
                                packageManager = pm;
                            }
                        }
                    }
                }
            } catch (Exception e3) {
            }
            i++;
            packageManager = pm;
        }
        return Math.max(0, byPkg.size() - before);
    }

    private int addFromKnownPackages(PackageManager pm, Map<String, JSObject> byPkg, boolean includeSystem, boolean launchableOnly) {
        int added = 0;
        for (String pkg : KNOWN_PACKAGES) {
            if (addPackageIfVisible(pm, byPkg, pkg, includeSystem, launchableOnly, "known")) {
                added++;
            }
        }
        return added;
    }

    private boolean addPackageIfVisible(PackageManager pm, Map<String, JSObject> byPkg, String pkg, boolean includeSystem, boolean launchableOnly, String source) {
        if (pkg != null && !pkg.isEmpty()) {
            if (!byPkg.containsKey(pkg)) {
                try {
                    ApplicationInfo ai = getApplicationInfo(pm, pkg);
                    boolean system = isSystemApp(ai);
                    if (!includeSystem && system) {
                        return false;
                    }
                    Intent launch = null;
                    try {
                        launch = pm.getLaunchIntentForPackage(pkg);
                    } catch (Exception e) {
                    }
                    boolean launchable = launch != null;
                    if (launchableOnly && !launchable) {
                        return false;
                    }
                    CharSequence labelCs = pm.getApplicationLabel(ai);
                    String label = labelCs != null ? labelCs.toString() : pkg;
                    JSObject row = baseAppRow(pkg, label, system, launchable);
                    if (launch != null && launch.getComponent() != null) {
                        row.put("activity", launch.getComponent().getClassName());
                    }
                    try {
                        row.put("source", source);
                    } catch (Exception e2) {
                    }
                    try {
                        byPkg.put(pkg, row);
                        return true;
                    } catch (Exception e3) {
                        return false;
                    }
                } catch (Exception e4) {
                }
            }
        }
        return false;
    }

    private static JSObject baseAppRow(String pkg, String label, boolean system, boolean launchable) {
        JSObject row = new JSObject();
        row.put("packageName", pkg);
        row.put("label", label);
        row.put("name", label);
        row.put("system", system);
        row.put("launchable", launchable);
        return row;
    }

    private static Intent viewIntent(String uri) {
        Intent i = new Intent("android.intent.action.VIEW");
        try {
            i.setData(Uri.parse(uri));
        } catch (Exception e) {
        }
        return i;
    }

    private static Intent sendTextIntent() {
        Intent i = new Intent("android.intent.action.SEND");
        i.setType(AssetHelper.DEFAULT_MIME_TYPE);
        i.putExtra("android.intent.extra.TEXT", "hi");
        return i;
    }

    private Intent buildIntent(PluginCall call) throws Exception {
        String action = norm(call.getString("action", null));
        String data = norm(call.getString("data", null));
        if (data == null) {
            data = norm(call.getString("uri", null));
        }
        if (data == null) {
            data = norm(call.getString("url", null));
        }
        String type = norm(call.getString("type", null));
        if (type == null) {
            type = norm(call.getString("mime", null));
        }
        String pkg = packageNameOf(call);
        String activity = activityOf(call);
        String component = norm(call.getString("component", null));
        if (action == null) {
            if (data != null) {
                action = "android.intent.action.VIEW";
            } else if (pkg != null || activity != null || component != null) {
                action = "android.intent.action.MAIN";
            } else {
                action = "android.intent.action.VIEW";
            }
        }
        Intent intent = new Intent(action);
        if (data != null && type != null) {
            intent.setDataAndType(Uri.parse(data), type);
        } else if (data != null) {
            intent.setData(Uri.parse(data));
        } else if (type != null) {
            intent.setType(type);
        }
        JSArray cats = call.getArray("categories");
        if (cats != null) {
            for (int i = 0; i < cats.length(); i++) {
                String c = cats.optString(i, null);
                if (c != null && !c.isEmpty()) {
                    intent.addCategory(c);
                }
            }
        } else if ("android.intent.action.MAIN".equals(action) && activity == null && component == null && data == null) {
            intent.addCategory("android.intent.category.LAUNCHER");
        }
        if (component != null) {
            ComponentName cn = parseComponent(component, pkg);
            if (cn != null) {
                intent.setComponent(cn);
            }
        } else if (pkg != null && activity != null) {
            intent.setClassName(pkg, activity);
        } else if (pkg != null) {
            intent.setPackage(pkg);
        }
        JSObject extras = call.getObject("extras", null);
        if (extras == null) {
            extras = call.getObject("extra", null);
        }
        if (extras != null) {
            putExtras(intent, extras);
        }
        String text = call.getString("text", null);
        if (text != null) {
            intent.putExtra("android.intent.extra.TEXT", text);
        }
        String subject = call.getString("subject", null);
        if (subject != null) {
            intent.putExtra("android.intent.extra.SUBJECT", subject);
        }
        String title = call.getString("title", null);
        if (title != null) {
            intent.putExtra("android.intent.extra.TITLE", title);
        }
        return intent;
    }

    private void putExtras(Intent intent, JSObject extras) {
        JSONArray names;
        if (extras == null || (names = extras.names()) == null) {
            return;
        }
        for (int i = 0; i < names.length(); i++) {
            String key = names.optString(i, null);
            if (key != null) {
                putExtraValue(intent, key, extras.opt(key));
            }
        }
    }

    private void putExtraValue(Intent intent, String key, Object val) {
        Object v;
        if (val == null || val == JSONObject.NULL) {
            intent.putExtra(key, (String) null);
            return;
        }
        if (val instanceof Boolean) {
            intent.putExtra(key, (Boolean) val);
            return;
        }
        if (val instanceof Integer) {
            intent.putExtra(key, (Integer) val);
            return;
        }
        if (val instanceof Long) {
            intent.putExtra(key, (Long) val);
            return;
        }
        if (val instanceof Double) {
            double d = ((Double) val).doubleValue();
            if (d == Math.rint(d) && !Double.isInfinite(d)) {
                long l = (long) d;
                if (l < -2147483648L || l > 2147483647L) {
                    intent.putExtra(key, l);
                    return;
                } else {
                    intent.putExtra(key, (int) l);
                    return;
                }
            }
            intent.putExtra(key, d);
            return;
        }
        if (val instanceof Float) {
            intent.putExtra(key, (Float) val);
            return;
        }
        if (val instanceof JSONArray) {
            JSONArray arr = (JSONArray) val;
            ArrayList<String> list = new ArrayList<>();
            for (int i = 0; i < arr.length(); i++) {
                Object o = arr.opt(i);
                if (o != null && o != JSONObject.NULL) {
                    list.add(String.valueOf(o));
                }
            }
            intent.putStringArrayListExtra(key, list);
            return;
        }
        if (val instanceof JSONObject) {
            Bundle b = new Bundle();
            JSONObject o2 = (JSONObject) val;
            JSONArray names = o2.names();
            if (names != null) {
                for (int i2 = 0; i2 < names.length(); i2++) {
                    String k = names.optString(i2, null);
                    if (k != null && (v = o2.opt(k)) != null && v != JSONObject.NULL) {
                        if (v instanceof Boolean) {
                            b.putBoolean(k, ((Boolean) v).booleanValue());
                        } else if (v instanceof Integer) {
                            b.putInt(k, ((Integer) v).intValue());
                        } else if (v instanceof Long) {
                            b.putLong(k, ((Long) v).longValue());
                        } else if (v instanceof Double) {
                            b.putDouble(k, ((Double) v).doubleValue());
                        } else {
                            b.putString(k, String.valueOf(v));
                        }
                    }
                }
            }
            intent.putExtra(key, b);
            return;
        }
        intent.putExtra(key, String.valueOf(val));
    }

    private List<ResolveInfo> queryActivities(PackageManager pm, Intent intent) {
        try {
            if (Build.VERSION.SDK_INT >= 33) {
                return pm.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(131072));
            }
            return pm.queryIntentActivities(intent, 131072);
        } catch (Exception e) {
            try {
                if (Build.VERSION.SDK_INT >= 33) {
                    return pm.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0L));
                }
                return pm.queryIntentActivities(intent, 0);
            } catch (Exception e2) {
                return Collections.emptyList();
            }
        }
    }

    private List<ApplicationInfo> getInstalledApplications(PackageManager pm) {
        try {
            if (Build.VERSION.SDK_INT >= 33) {
                return pm.getInstalledApplications(PackageManager.ApplicationInfoFlags.of(0L));
            }
            return pm.getInstalledApplications(0);
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    private ApplicationInfo getApplicationInfo(PackageManager pm, String pkg) throws PackageManager.NameNotFoundException {
        if (Build.VERSION.SDK_INT >= 33) {
            return pm.getApplicationInfo(pkg, PackageManager.ApplicationInfoFlags.of(0L));
        }
        return pm.getApplicationInfo(pkg, 0);
    }

    private PackageInfo getPackageInfo(PackageManager pm, String pkg, int flags) throws PackageManager.NameNotFoundException {
        if (Build.VERSION.SDK_INT >= 33) {
            return pm.getPackageInfo(pkg, PackageManager.PackageInfoFlags.of(flags));
        }
        return pm.getPackageInfo(pkg, flags);
    }

    private static ComponentName parseComponent(String component, String defaultPkg) {
        if (component == null || component.isEmpty()) {
            return null;
        }
        if (component.contains("/")) {
            String[] parts = component.split("/", 2);
            String p = parts[0];
            String c = parts[1];
            if (c.startsWith(".")) {
                c = p + c;
            }
            return new ComponentName(p, c);
        }
        if (defaultPkg != null) {
            return new ComponentName(defaultPkg, component.startsWith(".") ? defaultPkg + component : component);
        }
        return ComponentName.unflattenFromString(component);
    }

    private String packageNameOf(PluginCall call) {
        String component;
        String pkg = norm(call.getString("packageName", null));
        if (pkg == null) {
            pkg = norm(call.getString("package", null));
        }
        if (pkg == null) {
            pkg = norm(call.getString("pkg", null));
        }
        if (pkg == null && (component = norm(call.getString("component", null))) != null && component.contains("/")) {
            return norm(component.split("/", 2)[0]);
        }
        return pkg;
    }

    private String activityOf(PluginCall call) {
        String a = norm(call.getString("activity", null));
        if (a == null) {
            a = norm(call.getString("className", null));
        }
        if (a == null) {
            a = norm(call.getString("class", null));
        }
        if (a == null) {
            String component = norm(call.getString("component", null));
            if (component != null && component.contains("/")) {
                String a2 = component.split("/", 2)[1];
                String pkg = packageNameOf(call);
                return (!a2.startsWith(".") || pkg == null) ? a2 : pkg + a2;
            }
            return a;
        }
        String pkg2 = packageNameOf(call);
        return (!a.startsWith(".") || pkg2 == null) ? a : pkg2 + a;
    }

    private boolean hasQueryAllPackages() {
        if (Build.VERSION.SDK_INT < 30) {
            return true;
        }
        try {
            return getContext().getPackageManager().checkPermission("android.permission.QUERY_ALL_PACKAGES", getContext().getPackageName()) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean isSystemApp(ApplicationInfo ai) {
        return (ai == null || (ai.flags & 1) == 0) ? false : true;
    }

    private static boolean matchesQuery(String query, String label, String pkg) {
        String q = query.toLowerCase(Locale.US);
        return (label != null && label.toLowerCase(Locale.US).contains(q)) || (pkg != null && pkg.toLowerCase(Locale.US).contains(q));
    }

    private static String norm(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        if (t.isEmpty()) {
            return null;
        }
        return t;
    }

    private static int clampLimit(Integer n) {
        if (n == null || n.intValue() < 1) {
            return DEFAULT_LIMIT;
        }
        return Math.min(n.intValue(), MAX_LIMIT);
    }

    private static String shortClass(String name) {
        if (name == null) {
            return "";
        }
        int i = name.lastIndexOf(46);
        return i >= 0 ? name.substring(i + 1) : name;
    }

    private static JSArray toArray(List<JSObject> list) {
        JSArray arr = new JSArray();
        for (JSObject o : list) {
            arr.put(o);
        }
        return arr;
    }
}
