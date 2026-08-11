package com.getcapacitor.plugin.util;

import android.os.Build;
import android.os.LocaleList;
import android.text.TextUtils;
import com.getcapacitor.Bridge;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.JSValue;
import com.getcapacitor.PluginCall;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.ProtocolException;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLSocketFactory;
import org.json.JSONException;
import org.json.JSONObject;

/* loaded from: classes2.dex */
public class CapacitorHttpUrlConnection implements ICapacitorHttpUrlConnection {
    private final HttpURLConnection connection;

    public CapacitorHttpUrlConnection(HttpURLConnection conn) {
        this.connection = conn;
        setDefaultRequestProperties();
    }

    public HttpURLConnection getHttpConnection() {
        return this.connection;
    }

    public void disconnect() {
        this.connection.disconnect();
    }

    public void setAllowUserInteraction(boolean isAllowedInteraction) {
        this.connection.setAllowUserInteraction(isAllowedInteraction);
    }

    public void setRequestMethod(String method) throws ProtocolException {
        this.connection.setRequestMethod(method);
    }

    public void setConnectTimeout(int timeout) {
        if (timeout < 0) {
            throw new IllegalArgumentException("timeout can not be negative");
        }
        this.connection.setConnectTimeout(timeout);
    }

    public void setReadTimeout(int timeout) {
        if (timeout < 0) {
            throw new IllegalArgumentException("timeout can not be negative");
        }
        this.connection.setReadTimeout(timeout);
    }

    public void setDisableRedirects(boolean disableRedirects) {
        this.connection.setInstanceFollowRedirects(!disableRedirects);
    }

    public void setRequestHeaders(JSObject headers) {
        Iterator<String> keys = headers.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            String value = headers.getString(key);
            this.connection.setRequestProperty(key, value);
        }
    }

    public void setDoOutput(boolean shouldDoOutput) {
        this.connection.setDoOutput(shouldDoOutput);
    }

    public void setRequestBody(PluginCall call, JSValue body) throws JSONException, IOException {
        setRequestBody(call, body, null);
    }

    public void setRequestBody(PluginCall call, JSValue body, String bodyType) throws JSONException, IOException {
        String contentType = this.connection.getRequestProperty("Content-Type");
        String dataString = "";
        if (contentType == null || contentType.isEmpty()) {
            return;
        }
        if (contentType.contains("application/json")) {
            JSArray jsArray = null;
            if (body == null) {
                jsArray = call.getArray("data", null);
            } else {
                dataString = body.toString();
            }
            if (jsArray != null) {
                dataString = jsArray.toString();
            } else if (body == null) {
                dataString = call.getString("data");
            }
            writeRequestBody(dataString != null ? dataString : "");
            return;
        }
        if (bodyType != null && bodyType.equals("file")) {
            DataOutputStream os = new DataOutputStream(this.connection.getOutputStream());
            try {
                if (Build.VERSION.SDK_INT >= 26) {
                    os.write(Base64.getDecoder().decode(body.toString()));
                }
                os.flush();
                os.close();
                return;
            } catch (Throwable th) {
                try {
                    os.close();
                } catch (Throwable th2) {
                    th.addSuppressed(th2);
                }
                throw th;
            }
        }
        if (contentType.contains("application/x-www-form-urlencoded")) {
            try {
                JSObject obj = body.toJSObject();
                writeObjectRequestBody(obj);
                return;
            } catch (Exception e) {
                writeRequestBody(body.toString());
                return;
            }
        }
        if (bodyType != null && bodyType.equals("formData")) {
            writeFormDataRequestBody(contentType, body.toJSArray());
        } else {
            writeRequestBody(body.toString());
        }
    }

    private void writeRequestBody(String body) throws IOException {
        DataOutputStream os = new DataOutputStream(this.connection.getOutputStream());
        try {
            os.write(body.getBytes(StandardCharsets.UTF_8));
            os.flush();
            os.close();
        } catch (Throwable th) {
            try {
                os.close();
            } catch (Throwable th2) {
                th.addSuppressed(th2);
            }
            throw th;
        }
    }

    private void writeObjectRequestBody(JSObject object) throws IOException, JSONException {
        DataOutputStream os = new DataOutputStream(this.connection.getOutputStream());
        try {
            Iterator<String> keys = object.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                Object d = object.get(key);
                os.writeBytes(key);
                os.writeBytes("=");
                os.writeBytes(URLEncoder.encode(d.toString(), "UTF-8"));
                if (keys.hasNext()) {
                    os.writeBytes("&");
                }
            }
            os.flush();
            os.close();
        } catch (Throwable th) {
            try {
                os.close();
            } catch (Throwable th2) {
                th.addSuppressed(th2);
            }
            throw th;
        }
    }

    /* JADX WARN: Unreachable blocks removed: 2, instructions: 2 */
    private void writeFormDataRequestBody(String contentType, JSArray entries) throws IOException, JSONException {
        DataOutputStream os = new DataOutputStream(this.connection.getOutputStream());
        try {
            String boundary = contentType.split(";")[1].split("=")[1];
            for (Object e : entries.toList()) {
                if (e instanceof JSONObject) {
                    JSONObject entry = (JSONObject) e;
                    String type = entry.getString("type");
                    String key = entry.getString("key");
                    String value = entry.getString("value");
                    if (type.equals("string")) {
                        os.writeBytes("--" + boundary + "\r\n");
                        os.writeBytes("Content-Disposition: form-data; name=\"" + key + "\"\r\n\r\n");
                        os.write(value.getBytes(StandardCharsets.UTF_8));
                        os.writeBytes("\r\n");
                    } else if (type.equals("base64File")) {
                        String fileName = entry.getString("fileName");
                        String fileContentType = entry.getString("contentType");
                        os.writeBytes("--" + boundary + "\r\n");
                        os.writeBytes("Content-Disposition: form-data; name=\"" + key + "\"; filename=\"" + fileName + "\"\r\n");
                        os.writeBytes("Content-Type: " + fileContentType + "\r\n");
                        os.writeBytes("Content-Transfer-Encoding: binary\r\n");
                        os.writeBytes("\r\n");
                        if (Build.VERSION.SDK_INT >= 26) {
                            os.write(Base64.getDecoder().decode(value));
                        } else {
                            os.write(android.util.Base64.decode(value, 0));
                        }
                        os.writeBytes("\r\n");
                    }
                }
            }
            os.writeBytes("--" + boundary + "--\r\n");
            os.flush();
            os.close();
        } catch (Throwable th) {
            try {
                os.close();
                throw th;
            } catch (Throwable th2) {
                th.addSuppressed(th2);
                throw th;
            }
        }
    }

    public void connect() throws IOException {
        this.connection.connect();
    }

    public int getResponseCode() throws IOException {
        return this.connection.getResponseCode();
    }

    public URL getURL() {
        return this.connection.getURL();
    }

    @Override // com.getcapacitor.plugin.util.ICapacitorHttpUrlConnection
    public InputStream getErrorStream() {
        return this.connection.getErrorStream();
    }

    @Override // com.getcapacitor.plugin.util.ICapacitorHttpUrlConnection
    public String getHeaderField(String name) {
        return this.connection.getHeaderField(name);
    }

    @Override // com.getcapacitor.plugin.util.ICapacitorHttpUrlConnection
    public InputStream getInputStream() throws IOException {
        return this.connection.getInputStream();
    }

    public Map<String, List<String>> getHeaderFields() {
        return this.connection.getHeaderFields();
    }

    private void setDefaultRequestProperties() {
        String acceptLanguage = buildDefaultAcceptLanguageProperty();
        if (!TextUtils.isEmpty(acceptLanguage)) {
            this.connection.setRequestProperty("Accept-Language", acceptLanguage);
        }
    }

    private String buildDefaultAcceptLanguageProperty() {
        Locale locale;
        if (Build.VERSION.SDK_INT >= 24) {
            locale = LocaleList.getDefault().get(0);
        } else {
            locale = Locale.getDefault();
        }
        String lang = locale.getLanguage();
        String country = locale.getCountry();
        if (TextUtils.isEmpty(lang)) {
            return "";
        }
        if (!TextUtils.isEmpty(country)) {
            String result = String.format("%s-%s,%s;q=0.5", lang, country, lang);
            return result;
        }
        String result2 = String.format("%s;q=0.5", lang);
        return result2;
    }

    public void setSSLSocketFactory(Bridge bridge) {
        try {
            Class<?> sslPinningImpl = Class.forName("io.ionic.sslpinning.SSLPinning");
            Method method = sslPinningImpl.getDeclaredMethod("getSSLSocketFactory", Bridge.class);
            SSLSocketFactory sslSocketFactory = (SSLSocketFactory) method.invoke(sslPinningImpl.getDeclaredConstructor(new Class[0]).newInstance(new Object[0]), bridge);
            if (sslSocketFactory != null) {
                ((HttpsURLConnection) this.connection).setSSLSocketFactory(sslSocketFactory);
            }
        } catch (Exception e) {
        }
    }
}
