package com.forge.live;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

/**
 * Explicit AAForge -> Forge RPC entry point.
 *
 * Security: the sender must own com.forge.aaforgehost AND present a valid
 * HMAC over the request (validated here). Every received request — accepted or
 * rejected — is logged, and the caller's callback PendingIntent always receives
 * a definitive answer (never silence, which would only produce a timeout).
 */
public final class ForgeRpcReceiver extends BroadcastReceiver {
    public static final String ACTION = "com.forge.live.FORGE_RPC";
    private static final String AA_PACKAGE = "com.forge.aaforgehost";
    private static final String TAG = "ForgeRpcReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null || !ACTION.equals(intent.getAction())) return;
        PendingIntent callback = extractCallback(intent);
        String requestId = intent.getStringExtra("request_id");
        String service = intent.getStringExtra("service");
        String method = intent.getStringExtra("method");
        String params = intent.getStringExtra("params_json");
        Log.i(TAG, "RPC received: id=" + requestId + " service=" + service + " method=" + method);

        String reject = null;
        Boolean senderIsAaForge = callerOwnsAaForge(context);
        if (Boolean.FALSE.equals(senderIsAaForge)) reject = "Caller is not the paired AAForge app";
        else if (!validToken(service)) reject = "Invalid RPC service";
        else if (!validMethod(method)) reject = "Invalid RPC method";
        else if (params == null || params.length() > 32768) reject = "Invalid RPC params";

        if (reject != null) {
            Log.w(TAG, "RPC rejected (id=" + requestId + "): " + reject);
            answer(context, callback, requestId, false, null, reject);
            return;
        }
        if (!validSignature(context, requestId, intent.getLongExtra("timestamp", 0L), service, method, params, intent.getStringExtra("signature"))) {
            Log.w(TAG, "RPC rejected (id=" + requestId + "): AA-link signature check failed");
            answer(context, callback, requestId, false, null, "AA-link signature check failed");
            return;
        }

        // Preferred path: dispatch directly while Forge stays in the background.
        if (MainActivity.dispatchRpc(context, requestId, service, method, params, callback)) {
            return;
        }
        // Fallback: bring Forge forward once; the activity then dispatches itself.
        // (Background activity starts are restricted, so this only works shortly
        // after Forge was last visible. Otherwise we answer with a clear error.)
        try {
            context.startActivity(new Intent(context, MainActivity.class)
                    .setAction(ACTION)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    .putExtra("request_id", requestId)
                    .putExtra("service", service)
                    .putExtra("method", method)
                    .putExtra("params_json", params)
                    .putExtra("callback", callback));
        } catch (Exception e) {
            Log.w(TAG, "RPC could not be dispatched (id=" + requestId + ")", e);
            answer(context, callback, requestId, false, null, "Forge is not awake — open Forge once, then retry");
        }
    }

    static void answer(Context ctx, PendingIntent callback, String requestId, boolean ok, String resultJson, String error) {
        if (callback == null) return;
        try {
            Intent out = new Intent().putExtra("request_id", requestId).putExtra("ok", ok);
            if (resultJson != null) out.putExtra("result_json", resultJson);
            if (error != null) out.putExtra("error", error);
            callback.send(ctx, 0, out);
        } catch (Exception e) {
            Log.w(TAG, "RPC answer failed", e);
        }
    }

    private static PendingIntent extractCallback(Intent intent) {
        try {
            if (Build.VERSION.SDK_INT >= 33) return intent.getParcelableExtra("callback", PendingIntent.class);
            return (PendingIntent) intent.getParcelableExtra("callback");
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * TRUE (sender identified as AAForge), FALSE (identified and different),
     * or null when this firmware does not expose sender identity. When null,
     * authentication rests on the mandatory HMAC signature, which only the
     * holder of the paired AA-link secret can produce.
     */
    private Boolean callerOwnsAaForge(Context context) {
        // Broadcasts are delivered by system_server, so Binder.getCallingUid()
        // returns the system uid, not the sender. getSentFrom* (API 34+) is the
        // correct source for the original sender.
        String pkg = null;
        int uid = -1;
        if (Build.VERSION.SDK_INT >= 34) {
            pkg = getSentFromPackage();
            uid = getSentFromUid();
        } else {
            uid = android.os.Binder.getCallingUid();
        }
        try {
            String[] packages = context.getPackageManager().getPackagesForUid(uid);
            if (packages != null) {
                for (String p : packages) if (AA_PACKAGE.equals(p)) return Boolean.TRUE;
                if (uid > 0 && packages.length > 0) {
                    Log.w(TAG, "RPC sender identity: uid=" + uid + " pkg=" + pkg + " packages=" + String.join(",", packages));
                    return Boolean.FALSE;
                }
            }
        } catch (Exception ignored) {}
        return null;
    }

    private static boolean validToken(String service) {
        return service != null && service.matches("[A-Za-z][A-Za-z0-9_.-]{0,63}");
    }

    private static boolean validMethod(String method) {
        return method != null && method.matches("[A-Za-z][A-Za-z0-9_.-]{0,127}")
                && !method.toLowerCase().contains("javascript")
                && !method.toLowerCase().contains("eval");
    }

    private static boolean validSignature(Context context, String requestId, long timestamp, String service, String method, String params, String signature) {
        if (requestId == null || signature == null || Math.abs(System.currentTimeMillis() - timestamp) > 120000L) return false;
        try {
            String key = AaLinkPlugin.readStoredKey(context);
            if (key == null || key.isEmpty()) return false;
            if (!validSignatureImpl.verify(key, requestId, timestamp, service, method, params, signature)) return false;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /** HMAC-SHA256 + single-use request-id replay protection. */
    private static final class validSignatureImpl {
        private static final java.util.concurrent.ConcurrentHashMap<String, Long> USED = new java.util.concurrent.ConcurrentHashMap<>();
        static boolean verify(String key, String requestId, long timestamp, String service, String method, String params, String signature) {
            long now = System.currentTimeMillis();
            USED.entrySet().removeIf(e -> now - e.getValue() > 180000L);
            try {
                String material = requestId + "|" + timestamp + "|" + service + "|" + method + "|" + params;
                javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA256");
                mac.init(new javax.crypto.spec.SecretKeySpec(
                        android.util.Base64.decode(key, android.util.Base64.NO_WRAP | android.util.Base64.URL_SAFE), "HmacSHA256"));
                byte[] expected = mac.doFinal(material.getBytes(java.nio.charset.StandardCharsets.UTF_8));
                byte[] actual = android.util.Base64.decode(signature, android.util.Base64.NO_WRAP | android.util.Base64.URL_SAFE);
                if (!java.security.MessageDigest.isEqual(expected, actual)) return false;
                return USED.putIfAbsent(requestId, now) == null;
            } catch (Exception e) {
                return false;
            }
        }
    }
}
