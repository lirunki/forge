package com.forge.live;

import android.content.ContentResolver;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.os.VibratorManager;
import android.provider.ContactsContract;
import android.provider.Telephony;
import android.telephony.SmsManager;
import android.telephony.TelephonyManager;
import android.widget.Toast;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;
import androidx.core.net.MailTo;
import androidx.vectordrawable.graphics.drawable.PathInterpolatorCompat;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import org.apache.cordova.BuildConfig;

@CapacitorPlugin(name = "PhoneBridge", permissions = {@Permission(alias = "sms", strings = {"android.permission.SEND_SMS", "android.permission.READ_SMS", "android.permission.RECEIVE_SMS"}), @Permission(alias = "contacts", strings = {"android.permission.READ_CONTACTS"}), @Permission(alias = "phone", strings = {"android.permission.CALL_PHONE", "android.permission.READ_PHONE_STATE"}), @Permission(alias = "location", strings = {"android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION"})})
/* loaded from: classes4.dex */
public class PhoneBridgePlugin extends Plugin {
    @PluginMethod
    public void getCapabilities(PluginCall call) {
        JSObject caps = new JSObject();
        PackageManager pm = getContext().getPackageManager();
        caps.put("platform", "android");
        caps.put("smsCompose", true);
        caps.put("smsSend", pm.hasSystemFeature("android.hardware.telephony"));
        caps.put("smsRead", true);
        caps.put("dial", true);
        caps.put(NotificationCompat.CATEGORY_CALL, pm.hasSystemFeature("android.hardware.telephony"));
        caps.put("contacts", true);
        caps.put("location", pm.hasSystemFeature("android.hardware.location"));
        caps.put("vibrate", true);
        caps.put("maps", true);
        caps.put(NotificationCompat.CATEGORY_EMAIL, true);
        caps.put("settings", true);
        caps.put("tts", true);
        caps.put("permissions", (Object) permissionSnapshot());
        call.resolve(caps);
    }

    @PluginMethod
    public void getPermissions(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("permissions", (Object) permissionSnapshot());
        call.resolve(ret);
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    @PluginMethod
    public void requestPermission(PluginCall call) {
        char c;
        String alias = call.getString("alias", "");
        if (alias == null || alias.isEmpty()) {
            call.reject("alias required: sms | contacts | phone | location");
            return;
        }
        switch (alias.hashCode()) {
            case -567451565:
                if (alias.equals("contacts")) {
                    c = 1;
                    break;
                }
                c = 65535;
                break;
            case 114009:
                if (alias.equals("sms")) {
                    c = 0;
                    break;
                }
                c = 65535;
                break;
            case 106642798:
                if (alias.equals("phone")) {
                    c = 2;
                    break;
                }
                c = 65535;
                break;
            case 1901043637:
                if (alias.equals("location")) {
                    c = 3;
                    break;
                }
                c = 65535;
                break;
            default:
                c = 65535;
                break;
        }
        switch (c) {
            case 0:
            case 1:
            case 2:
            case 3:
                requestPermissionForAlias(alias, call, "permCallback");
                break;
            default:
                call.reject("Unknown alias: " + alias);
                break;
        }
    }

    @PluginMethod
    public void requestPack(PluginCall call) {
        LinkedHashSet<String> aliases = new LinkedHashSet<>();
        String pack = call.getString("pack", call.getString("id", ""));
        if (pack != null) {
            if ("phone".equals(pack) || "phone_features".equals(pack) || "enable_phone".equals(pack)) {
                aliases.add("sms");
                aliases.add("phone");
                aliases.add("contacts");
                aliases.add("location");
            } else if ("sms".equals(pack) || "contacts".equals(pack) || "location".equals(pack) || "phone_only".equals(pack)) {
                aliases.add("phone_only".equals(pack) ? "phone" : pack);
            }
        }
        try {
            JSArray features = call.getArray("features");
            if (features == null) {
                features = call.getArray("aliases");
            }
            if (features != null) {
                for (int i = 0; i < features.length(); i++) {
                    String a = String.valueOf(features.get(i));
                    if ("sms".equals(a) || "contacts".equals(a) || "phone".equals(a) || "location".equals(a)) {
                        aliases.add(a);
                    }
                }
            }
        } catch (Exception e) {
        }
        if (aliases.isEmpty()) {
            call.reject("Use pack:'phone_features' or features:['sms','phone','contacts','location']");
            return;
        }
        Iterator<String> it = aliases.iterator();
        while (it.hasNext()) {
            String alias = it.next();
            if (!aliasGranted(alias)) {
                try {
                    JSArray all = new JSArray();
                    Iterator<String> it2 = aliases.iterator();
                    while (it2.hasNext()) {
                        String a2 = it2.next();
                        all.put(a2);
                    }
                    call.getData().put("_packAliases", (Object) all);
                } catch (Exception e2) {
                }
                requestPermissionForAlias(alias, call, "packOneCallback");
                return;
            }
        }
        JSObject ret = new JSObject();
        ret.put("ok", true);
        ret.put("requested", false);
        ret.put("done", true);
        ret.put("permissions", permissionSnapshot());
        JSArray all2 = new JSArray();
        Iterator<String> it3 = aliases.iterator();
        while (it3.hasNext()) {
            String a3 = it3.next();
            all2.put(a3);
        }
        ret.put("aliases", (Object) all2);
        call.resolve(ret);
    }

    @PermissionCallback
    private void packOneCallback(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("ok", true);
        ret.put("requested", true);
        ret.put("permissions", permissionSnapshot());
        JSArray aliases = null;
        try {
            if (call.getData() != null && call.getData().has("_packAliases")) {
                Object raw = call.getData().get("_packAliases");
                if (raw instanceof JSArray) {
                    aliases = (JSArray) raw;
                } else if (raw != null) {
                    aliases = new JSArray(String.valueOf(raw));
                }
            }
        } catch (Exception e) {
        }
        if (aliases != null) {
            ret.put("aliases", (Object) aliases);
        }
        boolean done = true;
        try {
            if (aliases != null) {
                int i = 0;
                while (true) {
                    if (i >= aliases.length()) {
                        break;
                    }
                    if (!aliasGranted(String.valueOf(aliases.get(i)))) {
                        done = false;
                        break;
                    }
                    i++;
                }
            } else {
                done = aliasGranted("sms") && aliasGranted("phone") && aliasGranted("contacts") && aliasGranted("location");
            }
        } catch (Exception e2) {
        }
        ret.put("done", done);
        call.resolve(ret);
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    private boolean aliasGranted(String alias) {
        char c;
        switch (alias.hashCode()) {
            case -567451565:
                if (alias.equals("contacts")) {
                    c = 1;
                    break;
                }
                c = 65535;
                break;
            case 114009:
                if (alias.equals("sms")) {
                    c = 0;
                    break;
                }
                c = 65535;
                break;
            case 106642798:
                if (alias.equals("phone")) {
                    c = 2;
                    break;
                }
                c = 65535;
                break;
            case 1901043637:
                if (alias.equals("location")) {
                    c = 3;
                    break;
                }
                c = 65535;
                break;
            default:
                c = 65535;
                break;
        }
        switch (c) {
            case 0:
                return granted("android.permission.SEND_SMS") || granted("android.permission.READ_SMS");
            case 1:
                return granted("android.permission.READ_CONTACTS");
            case 2:
                return granted("android.permission.CALL_PHONE");
            case 3:
                return granted("android.permission.ACCESS_FINE_LOCATION") || granted("android.permission.ACCESS_COARSE_LOCATION");
            default:
                return false;
        }
    }

    @PermissionCallback
    private void permCallback(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("permissions", (Object) permissionSnapshot());
        call.resolve(ret);
    }

    private JSObject permissionSnapshot() {
        JSObject o = new JSObject();
        o.put("sendSms", granted("android.permission.SEND_SMS"));
        o.put("readSms", granted("android.permission.READ_SMS"));
        o.put("receiveSms", granted("android.permission.RECEIVE_SMS"));
        o.put("readContacts", granted("android.permission.READ_CONTACTS"));
        o.put("callPhone", granted("android.permission.CALL_PHONE"));
        o.put("readPhoneState", granted("android.permission.READ_PHONE_STATE"));
        o.put("location", granted("android.permission.ACCESS_FINE_LOCATION") || granted("android.permission.ACCESS_COARSE_LOCATION"));
        return o;
    }

    private boolean granted(String perm) {
        return ContextCompat.checkSelfPermission(getContext(), perm) == 0;
    }

    @PluginMethod
    public void composeSms(PluginCall call) {
        String to = call.getString("to", "");
        String body = call.getString("body", "");
        try {
            Uri uri = Uri.parse("smsto:" + (to != null ? to : ""));
            Intent intent = new Intent("android.intent.action.SENDTO", uri);
            if (body != null) {
                intent.putExtra("sms_body", body);
            }
            intent.addFlags(268435456);
            getContext().startActivity(intent);
            JSObject ret = new JSObject();
            ret.put("opened", true);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("composeSms failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void sendSms(PluginCall call) {
        boolean z;
        if (!granted("android.permission.SEND_SMS")) {
            call.reject("SEND_SMS permission not granted. Call requestPermission({alias:'sms'}) first.");
            return;
        }
        String to = call.getString("to", "");
        String body = call.getString("body", "");
        if (to == null || to.trim().isEmpty()) {
            call.reject("'to' phone number is required");
            return;
        }
        if (body == null) {
            body = "";
        }
        try {
            SmsManager sms = SmsManager.getDefault();
            ArrayList<String> parts = sms.divideMessage(body);
            if (parts.size() <= 1) {
                sms.sendTextMessage(to.trim(), null, body, null, null);
                z = true;
            } else {
                z = true;
                sms.sendMultipartTextMessage(to.trim(), null, parts, null, null);
            }
            JSObject ret = new JSObject();
            ret.put("sent", z);
            ret.put("to", to.trim());
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("sendSms failed: " + e.getMessage(), e);
        }
    }

    /* JADX WARN: Unreachable blocks removed: 2, instructions: 4 */
    @PluginMethod
    public void readSms(PluginCall pluginCall) {
        String selection;
        String[] selArgs;
        Throwable th;
        String str = "body";
        if (!granted("android.permission.READ_SMS")) {
            pluginCall.reject("READ_SMS permission not granted. Call requestPermission({alias:'sms'}) first.");
            return;
        }
        int limit = pluginCall.getInt("limit", 30).intValue();
        if (limit < 1) {
            limit = 1;
        }
        if (limit > 200) {
            limit = 200;
        }
        String box = pluginCall.getString("box", "inbox");
        String addressFilter = pluginCall.getString("address", null);
        List<Uri> uris = new ArrayList<>();
        if ("sent".equalsIgnoreCase(box)) {
            uris.add(Uri.parse("content://sms/sent"));
        } else if ("all".equalsIgnoreCase(box)) {
            uris.add(Uri.parse("content://sms"));
        } else {
            uris.add(Uri.parse("content://sms/inbox"));
        }
        JSArray messages = new JSArray();
        ContentResolver cr = getContext().getContentResolver();
        if (addressFilter != null && !addressFilter.trim().isEmpty()) {
            StringBuilder append = new StringBuilder().append("%");
            String selection2 = addressFilter.trim();
            String[] selArgs2 = {append.append(selection2).append("%").toString()};
            selArgs = selArgs2;
            selection = "address LIKE ?";
        } else {
            selection = null;
            selArgs = null;
        }
        try {
            for (Uri uri : uris) {
                Cursor c = cr.query(uri, null, selection, selArgs, "date DESC");
                if (c != null) {
                    String selection3 = selection;
                    int count = 0;
                    while (c.moveToNext() && count < limit) {
                        try {
                            JSObject m = new JSObject();
                            int limit2 = limit;
                            String[] selArgs3 = selArgs;
                            try {
                                String addressFilter2 = addressFilter;
                                try {
                                    m.put("id", getCol(c, "_id"));
                                    m.put("address", getCol(c, "address"));
                                    m.put(str, getCol(c, str));
                                    String str2 = str;
                                    m.put("date", getColLong(c, "date"));
                                    m.put("type", getColInt(c, "type"));
                                    m.put("read", getColInt(c, "read") == 1);
                                    messages.put(m);
                                    count++;
                                    str = str2;
                                    limit = limit2;
                                    selArgs = selArgs3;
                                    addressFilter = addressFilter2;
                                } catch (Throwable th2) {
                                    th = th2;
                                    if (c == null) {
                                        throw th;
                                    }
                                    try {
                                        c.close();
                                        throw th;
                                    } catch (Throwable th3) {
                                        th.addSuppressed(th3);
                                        throw th;
                                    }
                                }
                            } catch (Throwable th4) {
                                th = th4;
                            }
                        } catch (Throwable th5) {
                            th = th5;
                        }
                    }
                    int limit3 = limit;
                    String[] selArgs4 = selArgs;
                    String addressFilter3 = addressFilter;
                    String str3 = str;
                    if (c != null) {
                        try {
                            c.close();
                        } catch (SecurityException e) {
                            se = e;
                            pluginCall.reject("SMS read blocked: " + se.getMessage(), se);
                            return;
                        } catch (Exception e2) {
                            e = e2;
                            pluginCall.reject("readSms failed: " + e.getMessage(), e);
                            return;
                        }
                    }
                    str = str3;
                    limit = limit3;
                    selection = selection3;
                    selArgs = selArgs4;
                    addressFilter = addressFilter3;
                } else if (c != null) {
                    try {
                        c.close();
                    } catch (SecurityException e3) {
                        se = e3;
                        pluginCall.reject("SMS read blocked: " + se.getMessage(), se);
                        return;
                    } catch (Exception e4) {
                        e = e4;
                        pluginCall.reject("readSms failed: " + e.getMessage(), e);
                        return;
                    }
                } else {
                    continue;
                }
            }
            JSObject ret = new JSObject();
            ret.put("messages", (Object) messages);
            ret.put("count", messages.length());
            pluginCall.resolve(ret);
        } catch (SecurityException e5) {
            se = e5;
        } catch (Exception e6) {
            e = e6;
        }
    }

    @PluginMethod
    public void dial(PluginCall call) {
        String number = call.getString("number", "");
        try {
            Intent intent = new Intent("android.intent.action.DIAL");
            if (number != null && !number.isEmpty()) {
                intent.setData(Uri.parse("tel:" + number));
            } else {
                intent.setData(Uri.parse("tel:"));
            }
            intent.addFlags(268435456);
            getContext().startActivity(intent);
            JSObject ret = new JSObject();
            ret.put("opened", true);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("dial failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void call(PluginCall call) {
        if (!granted("android.permission.CALL_PHONE")) {
            call.reject("CALL_PHONE permission not granted. Call requestPermission({alias:'phone'}) first.");
            return;
        }
        String number = call.getString("number", "");
        if (number == null || number.trim().isEmpty()) {
            call.reject("'number' is required");
            return;
        }
        try {
            Intent intent = new Intent("android.intent.action.CALL");
            intent.setData(Uri.parse("tel:" + number.trim()));
            intent.addFlags(268435456);
            getContext().startActivity(intent);
            JSObject ret = new JSObject();
            ret.put("started", true);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("call failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void getContacts(PluginCall call) {
        String selection;
        String[] args;
        Throwable th;
        int limit;
        String str;
        if (!granted("android.permission.READ_CONTACTS")) {
            call.reject("READ_CONTACTS permission not granted. Call requestPermission({alias:'contacts'}) first.");
            return;
        }
        int limit2 = call.getInt("limit", 100).intValue();
        int i = 1;
        if (limit2 < 1) {
            limit2 = 1;
        }
        if (limit2 > 500) {
            limit2 = 500;
        }
        String query = call.getString("query", null);
        Map<String, JSObject> byId = new LinkedHashMap<>();
        ContentResolver cr = getContext().getContentResolver();
        Uri uri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI;
        String[] projection = {"contact_id", "display_name", "data1", "data2"};
        if (query != null && !query.trim().isEmpty()) {
            String q = "%" + query.trim() + "%";
            String[] args2 = {q, q};
            selection = "display_name LIKE ? OR data1 LIKE ?";
            args = args2;
        } else {
            selection = null;
            args = null;
        }
        try {
            Cursor c = cr.query(uri, projection, selection, args, "display_name ASC");
            try {
                if (c != null) {
                    for (int limit3 = limit2; c.moveToNext() && byId.size() < limit3; limit3 = limit) {
                        try {
                            String id = c.getString(0);
                            String name = c.getString(i);
                            String number = c.getString(2);
                            int type = c.getInt(3);
                            JSObject contact = byId.get(id);
                            if (contact != null) {
                                limit = limit3;
                            } else {
                                contact = new JSObject();
                                contact.put("id", id);
                                if (name != null) {
                                    limit = limit3;
                                    str = name;
                                } else {
                                    limit = limit3;
                                    str = "";
                                }
                                try {
                                    contact.put("name", str);
                                    contact.put("phones", (Object) new JSArray());
                                    byId.put(id, contact);
                                } catch (Throwable th2) {
                                    th = th2;
                                    if (c == null) {
                                        throw th;
                                    }
                                    try {
                                        c.close();
                                        throw th;
                                    } catch (Throwable th3) {
                                        th.addSuppressed(th3);
                                        throw th;
                                    }
                                }
                            }
                            JSObject phone = new JSObject();
                            phone.put("number", number != null ? number : "");
                            phone.put("type", type);
                            ((JSArray) contact.get("phones")).put(phone);
                            i = 1;
                        } catch (Throwable th4) {
                            th = th4;
                        }
                    }
                }
                if (c != null) {
                    c.close();
                }
                JSArray list = new JSArray();
                for (JSObject o : byId.values()) {
                    list.put(o);
                }
                JSObject ret = new JSObject();
                ret.put("contacts", (Object) list);
                ret.put("count", list.length());
                call.resolve(ret);
            } catch (Exception e) {
                e = e;
                call.reject("getContacts failed: " + e.getMessage(), e);
            }
        } catch (Exception e2) {
            e = e2;
        }
    }

    @PluginMethod
    public void getLocation(PluginCall call) {
        if (!granted("android.permission.ACCESS_FINE_LOCATION") && !granted("android.permission.ACCESS_COARSE_LOCATION")) {
            call.reject("Location permission not granted. Call requestPermission({alias:'location'}) first.");
            return;
        }
        try {
            try {
                LocationManager lm = (LocationManager) getContext().getSystemService("location");
                if (lm == null) {
                    call.reject("LocationManager unavailable");
                    return;
                }
                Criteria criteria = new Criteria();
                criteria.setAccuracy(1);
                String provider = lm.getBestProvider(criteria, true);
                Location loc = null;
                if (provider != null) {
                    loc = lm.getLastKnownLocation(provider);
                }
                if (loc == null) {
                    String[] strArr = {"gps", "network", "passive"};
                    for (int i = 0; i < 3; i++) {
                        String p = strArr[i];
                        try {
                            if (lm.isProviderEnabled(p) && (loc = lm.getLastKnownLocation(p)) != null) {
                                break;
                            }
                        } catch (Exception e) {
                        }
                    }
                }
                if (loc == null) {
                    call.reject("No last-known location yet. Open Maps once or wait for a GPS fix, then retry.");
                    return;
                }
                JSObject ret = new JSObject();
                ret.put("latitude", loc.getLatitude());
                ret.put("longitude", loc.getLongitude());
                ret.put("accuracy", loc.hasAccuracy() ? Float.valueOf(loc.getAccuracy()) : JSObject.NULL);
                ret.put("altitude", loc.hasAltitude() ? Double.valueOf(loc.getAltitude()) : JSObject.NULL);
                ret.put("speed", loc.hasSpeed() ? Float.valueOf(loc.getSpeed()) : JSObject.NULL);
                ret.put("time", loc.getTime());
                ret.put("provider", loc.getProvider());
                call.resolve(ret);
            } catch (Exception e2) {
                call.reject("getLocation failed: " + e2.getMessage(), e2);
            }
        } catch (SecurityException se) {
            call.reject("Location blocked: " + se.getMessage(), se);
        }
    }

    @PluginMethod
    public void openMaps(PluginCall call) {
        Uri uri;
        String str = "";
        Double lat = call.getDouble("latitude");
        Double lng = call.getDouble("longitude");
        String query = call.getString("query", null);
        try {
            if (lat != null && lng != null) {
                String label = call.getString("label", "");
                StringBuilder append = new StringBuilder().append("geo:").append(lat).append(",").append(lng).append("?q=").append(lat).append(",").append(lng);
                if (label != null && !label.isEmpty()) {
                    str = "(" + Uri.encode(label) + ")";
                }
                uri = Uri.parse(append.append(str).toString());
            } else if (query != null && !query.isEmpty()) {
                uri = Uri.parse("geo:0,0?q=" + Uri.encode(query));
            } else {
                uri = Uri.parse("geo:0,0");
            }
            Intent intent = new Intent("android.intent.action.VIEW", uri);
            intent.addFlags(268435456);
            getContext().startActivity(intent);
            JSObject ret = new JSObject();
            ret.put("opened", true);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("openMaps failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void vibrate(PluginCall call) {
        int ms = call.getInt("ms", 40).intValue();
        if (ms < 1) {
            ms = 1;
        }
        if (ms > 3000) {
            ms = PathInterpolatorCompat.MAX_NUM_POINTS;
        }
        try {
            if (Build.VERSION.SDK_INT >= 31) {
                VibratorManager vm = (VibratorManager) getContext().getSystemService("vibrator_manager");
                if (vm != null) {
                    vm.getDefaultVibrator().vibrate(VibrationEffect.createOneShot(ms, -1));
                }
            } else {
                Vibrator v = (Vibrator) getContext().getSystemService("vibrator");
                if (v != null) {
                    if (Build.VERSION.SDK_INT >= 26) {
                        v.vibrate(VibrationEffect.createOneShot(ms, -1));
                    } else {
                        v.vibrate(ms);
                    }
                }
            }
            JSObject ret = new JSObject();
            ret.put("ok", true);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("vibrate failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void toast(PluginCall pluginCall) {
        final String string = pluginCall.getString("message", "");
        final boolean booleanValue = pluginCall.getBoolean("long", false).booleanValue();
        if (getActivity() != null) {
            getActivity().runOnUiThread(new Runnable() { // from class: com.forge.live.PhoneBridgePlugin$$ExternalSyntheticLambda0
                @Override // java.lang.Runnable
                public final void run() {
                    PhoneBridgePlugin.this.lambda$toast$0(string, booleanValue);
                }
            });
        } else {
            Toast.makeText(getContext(), string != null ? string : "", booleanValue ? 1 : 0).show();
        }
        pluginCall.resolve();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$toast$0(String str, boolean z) {
        Toast.makeText(getContext(), str != null ? str : "", z ? 1 : 0).show();
    }

    @PluginMethod
    public void getDeviceInfo(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("manufacturer", Build.MANUFACTURER);
        ret.put("model", Build.MODEL);
        ret.put("brand", Build.BRAND);
        ret.put("device", Build.DEVICE);
        ret.put("sdkInt", Build.VERSION.SDK_INT);
        ret.put(BuildConfig.BUILD_TYPE, Build.VERSION.RELEASE);
        ret.put("packageName", getContext().getPackageName());
        try {
            TelephonyManager tm = (TelephonyManager) getContext().getSystemService("phone");
            if (tm != null) {
                ret.put("networkOperatorName", tm.getNetworkOperatorName());
                ret.put("simCountryIso", tm.getSimCountryIso());
                ret.put("phoneType", tm.getPhoneType());
                if (granted("android.permission.READ_PHONE_STATE")) {
                    try {
                        String line1 = tm.getLine1Number();
                        if (line1 != null && !line1.isEmpty()) {
                            ret.put("line1Number", line1);
                        }
                    } catch (Exception e) {
                    }
                }
            }
        } catch (Exception e2) {
        }
        try {
            String defaultSms = Telephony.Sms.getDefaultSmsPackage(getContext());
            ret.put("defaultSmsPackage", defaultSms);
        } catch (Exception e3) {
        }
        call.resolve(ret);
    }

    @PluginMethod
    public void composeEmail(PluginCall call) {
        String to = call.getString("to", "");
        String subject = call.getString("subject", "");
        String body = call.getString("body", "");
        try {
            Intent intent = new Intent("android.intent.action.SENDTO");
            intent.setData(Uri.parse(MailTo.MAILTO_SCHEME + (to != null ? to : "")));
            if (subject != null) {
                intent.putExtra("android.intent.extra.SUBJECT", subject);
            }
            if (body != null) {
                intent.putExtra("android.intent.extra.TEXT", body);
            }
            intent.addFlags(268435456);
            getContext().startActivity(intent);
            JSObject ret = new JSObject();
            ret.put("opened", true);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("composeEmail failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void openAppSettings(PluginCall call) {
        try {
            Intent intent = new Intent("android.settings.APPLICATION_DETAILS_SETTINGS");
            intent.setData(Uri.fromParts("package", getContext().getPackageName(), null));
            intent.addFlags(268435456);
            getContext().startActivity(intent);
            call.resolve();
        } catch (Exception e) {
            call.reject("openAppSettings failed: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void openUrl(PluginCall call) {
        String url = call.getString("url", "");
        if (url == null || url.isEmpty()) {
            call.reject("url required");
            return;
        }
        try {
            Intent intent = new Intent("android.intent.action.VIEW", Uri.parse(url));
            intent.addFlags(268435456);
            getContext().startActivity(intent);
            JSObject ret = new JSObject();
            ret.put("opened", true);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("openUrl failed: " + e.getMessage(), e);
        }
    }

    private String getCol(Cursor c, String name) {
        int i = c.getColumnIndex(name);
        if (i < 0) {
            return null;
        }
        return c.getString(i);
    }

    private long getColLong(Cursor c, String name) {
        int i = c.getColumnIndex(name);
        if (i < 0) {
            return 0L;
        }
        return c.getLong(i);
    }

    private int getColInt(Cursor c, String name) {
        int i = c.getColumnIndex(name);
        if (i < 0) {
            return 0;
        }
        return c.getInt(i);
    }
}
