package com.capacitorjs.plugins.preferences;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Set;
import org.json.JSONException;

@CapacitorPlugin(name = "Preferences")
/* loaded from: classes2.dex */
public class PreferencesPlugin extends Plugin {
    private Preferences preferences;

    @Override // com.getcapacitor.Plugin
    public void load() {
        this.preferences = new Preferences(getContext(), PreferencesConfiguration.DEFAULTS);
    }

    @PluginMethod
    public void configure(PluginCall call) {
        try {
            PreferencesConfiguration configuration = PreferencesConfiguration.DEFAULTS.m69clone();
            configuration.group = call.getString("group", PreferencesConfiguration.DEFAULTS.group);
            this.preferences = new Preferences(getContext(), configuration);
            call.resolve();
        } catch (CloneNotSupportedException e) {
            call.reject("Error while configuring", e);
        }
    }

    @PluginMethod
    public void get(PluginCall call) {
        String key = call.getString("key");
        if (key == null) {
            call.reject("Must provide key");
            return;
        }
        String value = this.preferences.get(key);
        JSObject ret = new JSObject();
        ret.put("value", value == null ? JSObject.NULL : value);
        call.resolve(ret);
    }

    @PluginMethod
    public void set(PluginCall call) {
        String key = call.getString("key");
        if (key == null) {
            call.reject("Must provide key");
            return;
        }
        String value = call.getString("value");
        this.preferences.set(key, value);
        call.resolve();
    }

    @PluginMethod
    public void remove(PluginCall call) {
        String key = call.getString("key");
        if (key == null) {
            call.reject("Must provide key");
        } else {
            this.preferences.remove(key);
            call.resolve();
        }
    }

    @PluginMethod
    public void keys(PluginCall call) {
        Set<String> keySet = this.preferences.keys();
        String[] keys = (String[]) keySet.toArray(new String[0]);
        JSObject ret = new JSObject();
        try {
            ret.put("keys", (Object) new JSArray(keys));
            call.resolve(ret);
        } catch (JSONException ex) {
            call.reject("Unable to serialize response.", ex);
        }
    }

    @PluginMethod
    public void clear(PluginCall call) {
        this.preferences.clear();
        call.resolve();
    }

    @PluginMethod
    public void migrate(PluginCall call) {
        List<String> migrated = new ArrayList<>();
        List<String> existing = new ArrayList<>();
        Preferences oldPreferences = new Preferences(getContext(), PreferencesConfiguration.DEFAULTS);
        for (String key : oldPreferences.keys()) {
            String value = oldPreferences.get(key);
            String currentValue = this.preferences.get(key);
            if (currentValue == null) {
                this.preferences.set(key, value);
                migrated.add(key);
            } else {
                existing.add(key);
            }
        }
        JSObject ret = new JSObject();
        ret.put("migrated", (Object) new JSArray((Collection) migrated));
        ret.put("existing", (Object) new JSArray((Collection) existing));
        call.resolve(ret);
    }

    @PluginMethod
    public void removeOld(PluginCall call) {
        call.resolve();
    }
}
