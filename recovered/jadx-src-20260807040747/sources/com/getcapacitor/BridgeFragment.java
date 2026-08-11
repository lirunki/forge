package com.getcapacitor;

import android.content.Context;
import android.content.res.TypedArray;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.fragment.app.Fragment;
import com.getcapacitor.Bridge;
import com.getcapacitor.android.R;
import java.util.ArrayList;
import java.util.List;

/* loaded from: classes2.dex */
public class BridgeFragment extends Fragment {
    private static final String ARG_START_DIR = "startDir";
    protected Bridge bridge;
    protected boolean keepRunning = true;
    private final List<Class<? extends Plugin>> initialPlugins = new ArrayList();
    private CapConfig config = null;
    private final List<WebViewListener> webViewListeners = new ArrayList();

    public static BridgeFragment newInstance(String startDir) {
        BridgeFragment fragment = new BridgeFragment();
        Bundle args = new Bundle();
        args.putString(ARG_START_DIR, startDir);
        fragment.setArguments(args);
        return fragment;
    }

    public void addPlugin(Class<? extends Plugin> plugin) {
        this.initialPlugins.add(plugin);
    }

    public void setConfig(CapConfig config) {
        this.config = config;
    }

    public Bridge getBridge() {
        return this.bridge;
    }

    public void addWebViewListener(WebViewListener webViewListener) {
        this.webViewListeners.add(webViewListener);
    }

    protected void load(Bundle savedInstanceState) {
        Logger.debug("Loading Bridge with BridgeFragment");
        Bundle args = getArguments();
        String startDir = null;
        if (args != null) {
            startDir = getArguments().getString(ARG_START_DIR);
        }
        Bridge create = new Bridge.Builder(this).setInstanceState(savedInstanceState).setPlugins(this.initialPlugins).setConfig(this.config).addWebViewListeners(this.webViewListeners).create();
        this.bridge = create;
        if (startDir != null) {
            create.setServerAssetPath(startDir);
        }
        this.keepRunning = this.bridge.shouldKeepRunning();
    }

    @Override // androidx.fragment.app.Fragment
    public void onInflate(Context context, AttributeSet attrs, Bundle savedInstanceState) {
        super.onInflate(context, attrs, savedInstanceState);
        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.bridge_fragment);
        CharSequence c = a.getString(R.styleable.bridge_fragment_start_dir);
        if (c != null) {
            String startDir = c.toString();
            Bundle args = new Bundle();
            args.putString(ARG_START_DIR, startDir);
            setArguments(args);
        }
    }

    @Override // androidx.fragment.app.Fragment
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override // androidx.fragment.app.Fragment
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_bridge, container, false);
    }

    @Override // androidx.fragment.app.Fragment
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        load(savedInstanceState);
    }

    @Override // androidx.fragment.app.Fragment
    public void onDestroy() {
        super.onDestroy();
        Bridge bridge = this.bridge;
        if (bridge != null) {
            bridge.onDestroy();
        }
    }
}
