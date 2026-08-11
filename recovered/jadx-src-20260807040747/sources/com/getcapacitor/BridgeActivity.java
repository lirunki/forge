package com.getcapacitor;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import com.getcapacitor.Bridge;
import com.getcapacitor.android.R;
import java.util.ArrayList;
import java.util.List;

/* loaded from: classes2.dex */
public class BridgeActivity extends AppCompatActivity {
    protected Bridge bridge;
    protected CapConfig config;
    protected boolean keepRunning = true;
    protected int activityDepth = 0;
    protected List<Class<? extends Plugin>> initialPlugins = new ArrayList();
    protected final Bridge.Builder bridgeBuilder = new Bridge.Builder(this);

    @Override // androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.bridgeBuilder.setInstanceState(savedInstanceState);
        getApplication().setTheme(R.style.AppTheme_NoActionBar);
        setTheme(R.style.AppTheme_NoActionBar);
        try {
            setContentView(R.layout.bridge_layout_main);
            PluginManager loader = new PluginManager(getAssets());
            try {
                this.bridgeBuilder.addPlugins(loader.loadPluginClasses());
            } catch (PluginLoadException ex) {
                Logger.error("Error loading plugins.", ex);
            }
            load();
        } catch (Exception e) {
            setContentView(R.layout.no_webview);
        }
    }

    protected void load() {
        Logger.debug("Starting BridgeActivity");
        Bridge create = this.bridgeBuilder.addPlugins(this.initialPlugins).setConfig(this.config).create();
        this.bridge = create;
        this.keepRunning = create.shouldKeepRunning();
        onNewIntent(getIntent());
    }

    public void registerPlugin(Class<? extends Plugin> plugin) {
        this.bridgeBuilder.addPlugin(plugin);
    }

    public void registerPlugins(List<Class<? extends Plugin>> plugins) {
        this.bridgeBuilder.addPlugins(plugins);
    }

    public Bridge getBridge() {
        return this.bridge;
    }

    @Override // androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        this.bridge.saveInstanceState(outState);
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onStart() {
        super.onStart();
        this.activityDepth++;
        Bridge bridge = this.bridge;
        if (bridge != null) {
            bridge.onStart();
            Logger.debug("App started");
        }
    }

    @Override // android.app.Activity
    public void onRestart() {
        super.onRestart();
        this.bridge.onRestart();
        Logger.debug("App restarted");
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onResume() {
        super.onResume();
        Bridge bridge = this.bridge;
        if (bridge != null) {
            bridge.getApp().fireStatusChange(true);
            this.bridge.onResume();
            Logger.debug("App resumed");
        }
    }

    @Override // androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onPause() {
        super.onPause();
        Bridge bridge = this.bridge;
        if (bridge != null) {
            bridge.onPause();
            Logger.debug("App paused");
        }
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onStop() {
        super.onStop();
        if (this.bridge != null) {
            int max = Math.max(0, this.activityDepth - 1);
            this.activityDepth = max;
            if (max == 0) {
                this.bridge.getApp().fireStatusChange(false);
            }
            this.bridge.onStop();
            Logger.debug("App stopped");
        }
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.fragment.app.FragmentActivity, android.app.Activity
    public void onDestroy() {
        super.onDestroy();
        Bridge bridge = this.bridge;
        if (bridge != null) {
            bridge.onDestroy();
            Logger.debug("App destroyed");
        }
    }

    @Override // android.app.Activity, android.view.Window.Callback
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        this.bridge.onDetachedFromWindow();
    }

    @Override // androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, android.app.Activity
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        Bridge bridge = this.bridge;
        if (bridge != null && !bridge.onRequestPermissionsResult(requestCode, permissions, grantResults)) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

    @Override // androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, android.app.Activity
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Bridge bridge = this.bridge;
        if (bridge != null && !bridge.onActivityResult(requestCode, resultCode, data)) {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }

    @Override // androidx.activity.ComponentActivity, android.app.Activity
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Bridge bridge = this.bridge;
        if (bridge == null || intent == null) {
            return;
        }
        bridge.onNewIntent(intent);
    }

    @Override // androidx.appcompat.app.AppCompatActivity, androidx.activity.ComponentActivity, android.app.Activity, android.content.ComponentCallbacks
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        Bridge bridge = this.bridge;
        if (bridge == null) {
            return;
        }
        bridge.onConfigurationChanged(newConfig);
    }
}
