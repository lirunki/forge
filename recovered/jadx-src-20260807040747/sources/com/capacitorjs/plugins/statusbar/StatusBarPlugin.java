package com.capacitorjs.plugins.statusbar;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.util.WebColor;
import java.util.Locale;

@CapacitorPlugin(name = "StatusBar")
/* loaded from: classes2.dex */
public class StatusBarPlugin extends Plugin {
    private StatusBar implementation;

    @Override // com.getcapacitor.Plugin
    public void load() {
        this.implementation = new StatusBar(getActivity());
    }

    @PluginMethod
    public void setStyle(final PluginCall call) {
        final String style = call.getString("style");
        if (style == null) {
            call.reject("Style must be provided");
        } else {
            getBridge().executeOnMainThread(new Runnable() { // from class: com.capacitorjs.plugins.statusbar.StatusBarPlugin$$ExternalSyntheticLambda4
                @Override // java.lang.Runnable
                public final void run() {
                    StatusBarPlugin.this.lambda$setStyle$0(style, call);
                }
            });
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$setStyle$0(String style, PluginCall call) {
        this.implementation.setStyle(style);
        call.resolve();
    }

    @PluginMethod
    public void setBackgroundColor(final PluginCall call) {
        final String color = call.getString("color");
        if (color == null) {
            call.reject("Color must be provided");
        } else {
            getBridge().executeOnMainThread(new Runnable() { // from class: com.capacitorjs.plugins.statusbar.StatusBarPlugin$$ExternalSyntheticLambda0
                @Override // java.lang.Runnable
                public final void run() {
                    StatusBarPlugin.this.lambda$setBackgroundColor$1(color, call);
                }
            });
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$setBackgroundColor$1(String color, PluginCall call) {
        try {
            int parsedColor = WebColor.parseColor(color.toUpperCase(Locale.ROOT));
            this.implementation.setBackgroundColor(parsedColor);
            call.resolve();
        } catch (IllegalArgumentException e) {
            call.reject("Invalid color provided. Must be a hex string (ex: #ff0000");
        }
    }

    @PluginMethod
    public void hide(final PluginCall call) {
        getBridge().executeOnMainThread(new Runnable() { // from class: com.capacitorjs.plugins.statusbar.StatusBarPlugin$$ExternalSyntheticLambda1
            @Override // java.lang.Runnable
            public final void run() {
                StatusBarPlugin.this.lambda$hide$2(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$hide$2(PluginCall call) {
        this.implementation.hide();
        call.resolve();
    }

    @PluginMethod
    public void show(final PluginCall call) {
        getBridge().executeOnMainThread(new Runnable() { // from class: com.capacitorjs.plugins.statusbar.StatusBarPlugin$$ExternalSyntheticLambda2
            @Override // java.lang.Runnable
            public final void run() {
                StatusBarPlugin.this.lambda$show$3(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$show$3(PluginCall call) {
        this.implementation.show();
        call.resolve();
    }

    @PluginMethod
    public void getInfo(PluginCall call) {
        StatusBarInfo info = this.implementation.getInfo();
        JSObject data = new JSObject();
        data.put("visible", info.isVisible());
        data.put("style", info.getStyle());
        data.put("color", info.getColor());
        data.put("overlays", info.isOverlays());
        call.resolve(data);
    }

    @PluginMethod
    public void setOverlaysWebView(final PluginCall call) {
        final Boolean overlays = call.getBoolean("overlay", true);
        getBridge().executeOnMainThread(new Runnable() { // from class: com.capacitorjs.plugins.statusbar.StatusBarPlugin$$ExternalSyntheticLambda3
            @Override // java.lang.Runnable
            public final void run() {
                StatusBarPlugin.this.lambda$setOverlaysWebView$4(overlays, call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$setOverlaysWebView$4(Boolean overlays, PluginCall call) {
        this.implementation.setOverlaysWebView(overlays);
        call.resolve();
    }
}
