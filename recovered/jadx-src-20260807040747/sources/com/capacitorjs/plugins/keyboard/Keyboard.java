package com.capacitorjs.plugins.keyboard;

import android.graphics.Rect;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.FrameLayout;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsAnimationCompat;
import androidx.core.view.WindowInsetsCompat;
import java.util.List;

/* loaded from: classes2.dex */
public class Keyboard {
    static final String EVENT_KB_DID_HIDE = "keyboardDidHide";
    static final String EVENT_KB_DID_SHOW = "keyboardDidShow";
    static final String EVENT_KB_WILL_HIDE = "keyboardWillHide";
    static final String EVENT_KB_WILL_SHOW = "keyboardWillShow";
    private AppCompatActivity activity;
    private FrameLayout.LayoutParams frameLayoutParams;
    private KeyboardEventListener keyboardEventListener;
    private View mChildOfContent;
    private View rootView;
    private int usableHeightPrevious;

    interface KeyboardEventListener {
        void onKeyboardEvent(String str, int i);
    }

    public void setKeyboardEventListener(KeyboardEventListener keyboardEventListener) {
        this.keyboardEventListener = keyboardEventListener;
    }

    public Keyboard(final AppCompatActivity activity, final boolean resizeOnFullScreen) {
        this.activity = activity;
        FrameLayout content = (FrameLayout) activity.getWindow().getDecorView().findViewById(android.R.id.content);
        View rootView = content.getRootView();
        this.rootView = rootView;
        ViewCompat.setWindowInsetsAnimationCallback(rootView, new WindowInsetsAnimationCompat.Callback(0) { // from class: com.capacitorjs.plugins.keyboard.Keyboard.1
            @Override // androidx.core.view.WindowInsetsAnimationCompat.Callback
            public WindowInsetsCompat onProgress(WindowInsetsCompat insets, List<WindowInsetsAnimationCompat> runningAnimations) {
                return insets;
            }

            @Override // androidx.core.view.WindowInsetsAnimationCompat.Callback
            public WindowInsetsAnimationCompat.BoundsCompat onStart(WindowInsetsAnimationCompat animation, WindowInsetsAnimationCompat.BoundsCompat bounds) {
                boolean showingKeyboard = ViewCompat.getRootWindowInsets(Keyboard.this.rootView).isVisible(WindowInsetsCompat.Type.ime());
                WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(Keyboard.this.rootView);
                int imeHeight = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom;
                DisplayMetrics dm = activity.getResources().getDisplayMetrics();
                float density = dm.density;
                if (resizeOnFullScreen) {
                    Keyboard.this.possiblyResizeChildOfContent(showingKeyboard);
                }
                if (showingKeyboard) {
                    Keyboard.this.keyboardEventListener.onKeyboardEvent(Keyboard.EVENT_KB_WILL_SHOW, Math.round(imeHeight / density));
                } else {
                    Keyboard.this.keyboardEventListener.onKeyboardEvent(Keyboard.EVENT_KB_WILL_HIDE, 0);
                }
                return super.onStart(animation, bounds);
            }

            @Override // androidx.core.view.WindowInsetsAnimationCompat.Callback
            public void onEnd(WindowInsetsAnimationCompat animation) {
                super.onEnd(animation);
                boolean showingKeyboard = ViewCompat.getRootWindowInsets(Keyboard.this.rootView).isVisible(WindowInsetsCompat.Type.ime());
                WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(Keyboard.this.rootView);
                int imeHeight = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom;
                DisplayMetrics dm = activity.getResources().getDisplayMetrics();
                float density = dm.density;
                if (showingKeyboard) {
                    Keyboard.this.keyboardEventListener.onKeyboardEvent(Keyboard.EVENT_KB_DID_SHOW, Math.round(imeHeight / density));
                } else {
                    Keyboard.this.keyboardEventListener.onKeyboardEvent(Keyboard.EVENT_KB_DID_HIDE, 0);
                }
            }
        });
        View childAt = content.getChildAt(0);
        this.mChildOfContent = childAt;
        this.frameLayoutParams = (FrameLayout.LayoutParams) childAt.getLayoutParams();
    }

    public void show() {
        ((InputMethodManager) this.activity.getSystemService("input_method")).showSoftInput(this.activity.getCurrentFocus(), 0);
    }

    public boolean hide() {
        InputMethodManager inputManager = (InputMethodManager) this.activity.getSystemService("input_method");
        View v = this.activity.getCurrentFocus();
        if (v == null) {
            return false;
        }
        inputManager.hideSoftInputFromWindow(v.getWindowToken(), 2);
        return true;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void possiblyResizeChildOfContent(boolean keyboardShown) {
        int usableHeightNow = keyboardShown ? computeUsableHeight() : -1;
        if (this.usableHeightPrevious != usableHeightNow) {
            this.frameLayoutParams.height = usableHeightNow;
            this.mChildOfContent.requestLayout();
            this.usableHeightPrevious = usableHeightNow;
        }
    }

    private int computeUsableHeight() {
        Rect r = new Rect();
        this.mChildOfContent.getWindowVisibleDisplayFrame(r);
        return isOverlays() ? r.bottom : r.height();
    }

    private boolean isOverlays() {
        Window window = this.activity.getWindow();
        return (window.getDecorView().getSystemUiVisibility() & 1024) == 1024;
    }
}
