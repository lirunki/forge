package com.capacitorjs.plugins.keyboard;

import android.os.Handler;
import android.os.Looper;
import com.capacitorjs.plugins.keyboard.Keyboard;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "Keyboard")
/* loaded from: classes2.dex */
public class KeyboardPlugin extends Plugin {
    private Keyboard implementation;

    @Override // com.getcapacitor.Plugin
    public void load() {
        execute(new Runnable() { // from class: com.capacitorjs.plugins.keyboard.KeyboardPlugin$$ExternalSyntheticLambda3
            @Override // java.lang.Runnable
            public final void run() {
                KeyboardPlugin.this.lambda$load$0();
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$load$0() {
        boolean resizeOnFullScreen = getConfig().getBoolean("resizeOnFullScreen", false);
        Keyboard keyboard = new Keyboard(getActivity(), resizeOnFullScreen);
        this.implementation = keyboard;
        keyboard.setKeyboardEventListener(new Keyboard.KeyboardEventListener() { // from class: com.capacitorjs.plugins.keyboard.KeyboardPlugin$$ExternalSyntheticLambda2
            @Override // com.capacitorjs.plugins.keyboard.Keyboard.KeyboardEventListener
            public final void onKeyboardEvent(String str, int i) {
                KeyboardPlugin.this.onKeyboardEvent(str, i);
            }
        });
    }

    @PluginMethod
    public void show(final PluginCall call) {
        execute(new Runnable() { // from class: com.capacitorjs.plugins.keyboard.KeyboardPlugin$$ExternalSyntheticLambda4
            @Override // java.lang.Runnable
            public final void run() {
                KeyboardPlugin.this.lambda$show$2(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$show$2(final PluginCall call) {
        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() { // from class: com.capacitorjs.plugins.keyboard.KeyboardPlugin$$ExternalSyntheticLambda1
            @Override // java.lang.Runnable
            public final void run() {
                KeyboardPlugin.this.lambda$show$1(call);
            }
        }, 350L);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$show$1(PluginCall call) {
        this.implementation.show();
        call.resolve();
    }

    @PluginMethod
    public void hide(final PluginCall call) {
        execute(new Runnable() { // from class: com.capacitorjs.plugins.keyboard.KeyboardPlugin$$ExternalSyntheticLambda0
            @Override // java.lang.Runnable
            public final void run() {
                KeyboardPlugin.this.lambda$hide$3(call);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$hide$3(PluginCall call) {
        if (!this.implementation.hide()) {
            call.reject("Can't close keyboard, not currently focused");
        } else {
            call.resolve();
        }
    }

    @PluginMethod
    public void setAccessoryBarVisible(PluginCall call) {
        call.unimplemented();
    }

    @PluginMethod
    public void setStyle(PluginCall call) {
        call.unimplemented();
    }

    @PluginMethod
    public void setResizeMode(PluginCall call) {
        call.unimplemented();
    }

    @PluginMethod
    public void getResizeMode(PluginCall call) {
        call.unimplemented();
    }

    @PluginMethod
    public void setScroll(PluginCall call) {
        call.unimplemented();
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    void onKeyboardEvent(String event, int size) {
        char c;
        JSObject kbData = new JSObject();
        switch (event.hashCode()) {
            case -662060934:
                if (event.equals("keyboardDidHide")) {
                    c = 3;
                    break;
                }
                c = 65535;
                break;
            case -661733835:
                if (event.equals("keyboardDidShow")) {
                    c = 1;
                    break;
                }
                c = 65535;
                break;
            case -34092741:
                if (event.equals("keyboardWillHide")) {
                    c = 2;
                    break;
                }
                c = 65535;
                break;
            case -33765642:
                if (event.equals("keyboardWillShow")) {
                    c = 0;
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
                String data = "{ 'keyboardHeight': " + size + " }";
                this.bridge.triggerWindowJSEvent(event, data);
                kbData.put("keyboardHeight", size);
                notifyListeners(event, kbData);
                break;
            case 2:
            case 3:
                this.bridge.triggerWindowJSEvent(event);
                notifyListeners(event, kbData);
                break;
        }
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnDestroy() {
        this.implementation.setKeyboardEventListener(null);
    }
}
