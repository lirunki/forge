package com.getcapacitor;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;

/* loaded from: classes2.dex */
class JSInjector {
    private String bridgeJS;
    private String cordovaJS;
    private String cordovaPluginsFileJS;
    private String cordovaPluginsJS;
    private String globalJS;
    private String localUrlJS;
    private String pluginJS;

    public JSInjector(String globalJS, String bridgeJS, String pluginJS, String cordovaJS, String cordovaPluginsJS, String cordovaPluginsFileJS, String localUrlJS) {
        this.globalJS = globalJS;
        this.bridgeJS = bridgeJS;
        this.pluginJS = pluginJS;
        this.cordovaJS = cordovaJS;
        this.cordovaPluginsJS = cordovaPluginsJS;
        this.cordovaPluginsFileJS = cordovaPluginsFileJS;
        this.localUrlJS = localUrlJS;
    }

    public String getScriptString() {
        return this.globalJS + "\n\n" + this.localUrlJS + "\n\n" + this.bridgeJS + "\n\n" + this.pluginJS + "\n\n" + this.cordovaJS + "\n\n" + this.cordovaPluginsFileJS + "\n\n" + this.cordovaPluginsJS;
    }

    public InputStream getInjectedStream(InputStream responseStream) {
        String js = "<script type=\"text/javascript\">" + getScriptString() + "</script>";
        String html = readAssetStream(responseStream);
        StringBuilder modifiedHtml = new StringBuilder(html);
        if (html.contains("<head>")) {
            modifiedHtml.insert(html.indexOf("<head>") + "<head>".length(), "\n" + js + "\n");
            html = modifiedHtml.toString();
        } else if (html.contains("</head>")) {
            modifiedHtml.insert(html.indexOf("</head>"), "\n" + js + "\n");
            html = modifiedHtml.toString();
        } else {
            Logger.error("Unable to inject Capacitor, Plugins won't work");
        }
        return new ByteArrayInputStream(html.getBytes(StandardCharsets.UTF_8));
    }

    private String readAssetStream(InputStream stream) {
        try {
            char[] buffer = new char[1024];
            StringBuilder out = new StringBuilder();
            Reader in = new InputStreamReader(stream, StandardCharsets.UTF_8);
            while (true) {
                int rsz = in.read(buffer, 0, buffer.length);
                if (rsz >= 0) {
                    out.append(buffer, 0, rsz);
                } else {
                    return out.toString();
                }
            }
        } catch (Exception e) {
            Logger.error("Unable to process HTML asset file. This is a fatal error", e);
            return "";
        }
    }
}
