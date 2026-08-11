package com.capacitorjs.plugins.share;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ClipData;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Build;
import android.webkit.MimeTypeMap;
import androidx.activity.result.ActivityResult;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import androidx.webkit.internal.AssetHelper;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

@CapacitorPlugin(name = "Share")
/* loaded from: classes2.dex */
public class SharePlugin extends Plugin {
    private BroadcastReceiver broadcastReceiver;
    private ComponentName chosenComponent;
    private boolean stopped = false;
    private boolean isPresenting = false;

    @Override // com.getcapacitor.Plugin
    public void load() {
        this.broadcastReceiver = new BroadcastReceiver() { // from class: com.capacitorjs.plugins.share.SharePlugin.1
            @Override // android.content.BroadcastReceiver
            public void onReceive(Context context, Intent intent) {
                if (Build.VERSION.SDK_INT >= 33) {
                    SharePlugin.this.chosenComponent = (ComponentName) intent.getParcelableExtra("android.intent.extra.CHOSEN_COMPONENT", ComponentName.class);
                } else {
                    SharePlugin sharePlugin = SharePlugin.this;
                    sharePlugin.chosenComponent = sharePlugin.getParcelableExtraLegacy(intent, "android.intent.extra.CHOSEN_COMPONENT");
                }
            }
        };
        ContextCompat.registerReceiver(getContext(), this.broadcastReceiver, new IntentFilter("android.intent.extra.CHOSEN_COMPONENT"), 2);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public ComponentName getParcelableExtraLegacy(Intent intent, String string) {
        return (ComponentName) intent.getParcelableExtra(string);
    }

    @ActivityCallback
    private void activityResult(PluginCall call, ActivityResult result) {
        if (result.getResultCode() == 0 && !this.stopped) {
            call.reject("Share canceled");
        } else {
            JSObject callResult = new JSObject();
            ComponentName componentName = this.chosenComponent;
            callResult.put("activityType", componentName != null ? componentName.getPackageName() : "");
            call.resolve(callResult);
        }
        this.isPresenting = false;
    }

    @PluginMethod
    public void canShare(PluginCall call) {
        JSObject callResult = new JSObject();
        callResult.put("value", true);
        call.resolve(callResult);
    }

    @PluginMethod
    public void share(PluginCall call) {
        if (!this.isPresenting) {
            String title = call.getString("title", "");
            String text = call.getString("text");
            String url = call.getString("url");
            JSArray files = call.getArray("files");
            String dialogTitle = call.getString("dialogTitle", "Share");
            if (text == null && url == null && (files == null || files.length() == 0)) {
                call.reject("Must provide a URL or Message or files");
                return;
            }
            if (url != null && !isFileUrl(url) && !isHttpUrl(url)) {
                call.reject("Unsupported url");
                return;
            }
            Intent intent = new Intent((files == null || files.length() <= 1) ? "android.intent.action.SEND" : "android.intent.action.SEND_MULTIPLE");
            if (text != null) {
                if (url != null && isHttpUrl(url)) {
                    text = text + " " + url;
                }
                intent.putExtra("android.intent.extra.TEXT", text);
                intent.setTypeAndNormalize(AssetHelper.DEFAULT_MIME_TYPE);
            }
            if (url != null && isHttpUrl(url) && text == null) {
                intent.putExtra("android.intent.extra.TEXT", url);
                intent.setTypeAndNormalize(AssetHelper.DEFAULT_MIME_TYPE);
            } else if (url != null && isFileUrl(url)) {
                JSArray filesArray = new JSArray();
                filesArray.put(url);
                shareFiles(filesArray, intent, call);
            }
            if (title != null) {
                intent.putExtra("android.intent.extra.SUBJECT", title);
            }
            if (files != null && files.length() != 0) {
                shareFiles(files, intent, call);
            }
            int flags = Build.VERSION.SDK_INT >= 31 ? 134217728 | 33554432 : 134217728;
            if (Build.VERSION.SDK_INT >= 34) {
                flags |= 16777216;
            }
            PendingIntent pi = PendingIntent.getBroadcast(getContext(), 0, new Intent("android.intent.extra.CHOSEN_COMPONENT"), flags);
            Intent chooser = Intent.createChooser(intent, dialogTitle, pi.getIntentSender());
            this.chosenComponent = null;
            chooser.addCategory("android.intent.category.DEFAULT");
            this.stopped = false;
            this.isPresenting = true;
            startActivityForResult(call, chooser, "activityResult");
            return;
        }
        call.reject("Can't share while sharing is in progress");
    }

    private void shareFiles(JSArray files, Intent intent, PluginCall call) {
        ArrayList<Uri> fileUris = new ArrayList<>();
        try {
            List<Object> filesList = files.toList();
            for (int i = 0; i < filesList.size(); i++) {
                String file = (String) filesList.get(i);
                if (isFileUrl(file)) {
                    String type = getMimeType(file);
                    if (type == null || filesList.size() > 1) {
                        type = "*/*";
                    }
                    intent.setType(type);
                    Uri fileUrl = FileProvider.getUriForFile(getActivity(), getContext().getPackageName() + ".fileprovider", new File(Uri.parse(file).getPath()));
                    fileUris.add(fileUrl);
                } else {
                    call.reject("only file urls are supported");
                    return;
                }
            }
            int i2 = fileUris.size();
            if (i2 > 1) {
                intent.putExtra("android.intent.extra.STREAM", fileUris);
            } else if (fileUris.size() == 1) {
                if (Build.VERSION.SDK_INT >= 29) {
                    intent.setClipData(ClipData.newRawUri("", fileUris.get(0)));
                }
                intent.putExtra("android.intent.extra.STREAM", fileUris.get(0));
            }
            intent.setFlags(1);
        } catch (Exception ex) {
            call.reject(ex.getLocalizedMessage());
        }
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnDestroy() {
        if (this.broadcastReceiver != null) {
            getActivity().unregisterReceiver(this.broadcastReceiver);
        }
    }

    @Override // com.getcapacitor.Plugin
    protected void handleOnStop() {
        super.handleOnStop();
        this.stopped = true;
    }

    private String getMimeType(String url) {
        String extension = MimeTypeMap.getFileExtensionFromUrl(url);
        if (extension == null) {
            return null;
        }
        String type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
        return type;
    }

    private boolean isFileUrl(String url) {
        return url.startsWith("file:");
    }

    private boolean isHttpUrl(String url) {
        return url.startsWith("http");
    }
}
