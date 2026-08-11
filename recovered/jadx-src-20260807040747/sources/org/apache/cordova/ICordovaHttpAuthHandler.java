package org.apache.cordova;

/* loaded from: classes.dex */
public interface ICordovaHttpAuthHandler {
    void cancel();

    void proceed(String username, String password);
}
