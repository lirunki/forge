package com.forge.live;

import android.app.ActivityManager;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Bundle;

/* loaded from: classes4.dex */
public class RunActivity extends MainActivity {
    @Override // com.forge.live.MainActivity
    protected boolean isRunnerInstance() {
        return true;
    }

    @Override // com.forge.live.MainActivity, com.getcapacitor.BridgeActivity, androidx.fragment.app.FragmentActivity, androidx.activity.ComponentActivity, androidx.core.app.ComponentActivity, android.app.Activity
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        applyTaskLabel(getIntent());
    }

    @Override // com.forge.live.MainActivity, com.getcapacitor.BridgeActivity, androidx.activity.ComponentActivity, android.app.Activity
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        applyTaskLabel(intent);
    }

    private void applyTaskLabel(Intent intent) {
        String q;
        ActivityManager.TaskDescription desc;
        if (intent == null) {
            return;
        }
        String title = intent.getStringExtra(ShortcutBridgePlugin.EXTRA_APP_TITLE);
        if ((title == null || title.trim().isEmpty()) && intent.getData() != null && (q = intent.getData().getQueryParameter("title")) != null && !q.trim().isEmpty()) {
            title = q.trim();
        }
        if (title == null || title.trim().isEmpty()) {
            title = "Forge app";
        }
        String title2 = title.trim();
        try {
            if (Build.VERSION.SDK_INT >= 28) {
                desc = new ActivityManager.TaskDescription(title2, R.mipmap.ic_launcher);
            } else {
                desc = new ActivityManager.TaskDescription(title2, BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher));
            }
            setTaskDescription(desc);
            setTitle(title2);
        } catch (Exception e) {
        }
    }
}
