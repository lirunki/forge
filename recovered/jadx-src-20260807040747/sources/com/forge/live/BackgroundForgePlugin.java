package com.forge.live;

import android.os.Build;
import androidx.core.content.ContextCompat;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;

@CapacitorPlugin(name = "BackgroundForge", permissions = {@Permission(alias = "notifications", strings = {"android.permission.POST_NOTIFICATIONS"})})
/* loaded from: classes4.dex */
public class BackgroundForgePlugin extends Plugin {
    @PluginMethod
    public void start(PluginCall call) {
        ensureNotificationPermission();
        String title = call.getString("title", "Forge");
        String text = call.getString("text", "Working in the background…");
        try {
            BackgroundForgeService.start(getContext(), title, text);
            JSObject ret = new JSObject();
            ret.put("running", true);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("Failed to start background service: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void update(PluginCall call) {
        try {
            BackgroundForgeService.update(getContext(), call.getString("title", null), call.getString("text", null));
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to update background service: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void stop(PluginCall call) {
        try {
            BackgroundForgeService.stop(getContext());
            JSObject ret = new JSObject();
            ret.put("running", false);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("Failed to stop background service: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void requestNotificationPermission(PluginCall call) {
        if (Build.VERSION.SDK_INT < 33) {
            JSObject ret = new JSObject();
            ret.put("granted", true);
            call.resolve(ret);
        } else {
            if (hasNotificationPermission()) {
                JSObject ret2 = new JSObject();
                ret2.put("granted", true);
                call.resolve(ret2);
                return;
            }
            requestPermissionForAlias("notifications", call, "notificationPermsCallback");
        }
    }

    @PermissionCallback
    private void notificationPermsCallback(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("granted", hasNotificationPermission());
        call.resolve(ret);
    }

    private boolean hasNotificationPermission() {
        return Build.VERSION.SDK_INT < 33 || ContextCompat.checkSelfPermission(getContext(), "android.permission.POST_NOTIFICATIONS") == 0;
    }

    private void ensureNotificationPermission() {
        if (Build.VERSION.SDK_INT >= 33 && !hasNotificationPermission()) {
            try {
                if (getActivity() != null) {
                    getActivity().requestPermissions(new String[]{"android.permission.POST_NOTIFICATIONS"}, 44002);
                }
            } catch (Exception e) {
            }
        }
    }
}
