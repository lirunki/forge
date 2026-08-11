package com.capacitorjs.plugins.preferences;

/* loaded from: classes2.dex */
public class PreferencesConfiguration implements Cloneable {
    static final PreferencesConfiguration DEFAULTS;
    String group;

    static {
        PreferencesConfiguration preferencesConfiguration = new PreferencesConfiguration();
        DEFAULTS = preferencesConfiguration;
        preferencesConfiguration.group = "CapacitorStorage";
    }

    /* renamed from: clone, reason: merged with bridge method [inline-methods] */
    public PreferencesConfiguration m69clone() throws CloneNotSupportedException {
        return (PreferencesConfiguration) super.clone();
    }
}
