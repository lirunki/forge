package com.forge.live;

import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Base64;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.nio.charset.StandardCharsets;
import java.security.KeyStore;
import java.security.SecureRandom;
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;

@CapacitorPlugin(name = "AaLink")
public final class AaLinkPlugin extends Plugin {
    private static final String ALIAS = "forge_aa_link_key_v1";
    private static final String PREFS = "forge_aa_link_secure_v1";
    private static final String VALUE = "value";

    @PluginMethod
    public void get(PluginCall call) {
        try {
            String key = readStoredKeyInternal(getContext());
            JSObject out = new JSObject();
            out.put("linked", key != null && !key.isEmpty());
            if (key != null) out.put("key", key);
            call.resolve(out);
        } catch (Exception e) { call.reject("Could not read AA-link", e); }
    }

    @PluginMethod
    public void generate(PluginCall call) {
        try {
            byte[] bytes = new byte[32];
            new SecureRandom().nextBytes(bytes);
            String key = Base64.encodeToString(bytes, Base64.NO_WRAP | Base64.URL_SAFE);
            getContext().getSharedPreferences(PREFS, 0).edit().putString(VALUE, encrypt(key)).apply();
            JSObject out = new JSObject(); out.put("linked", true); out.put("key", key); call.resolve(out);
        } catch (Exception e) { call.reject("Could not generate AA-link", e); }
    }

    public static String readStoredKey(android.content.Context context) throws Exception {
        return new AaLinkPlugin().readStoredKeyInternal(context);
    }

    private String readStoredKeyInternal(android.content.Context context) throws Exception {
        return decrypt(context.getSharedPreferences(PREFS, 0).getString(VALUE, null));
    }

    @PluginMethod
    public void clear(PluginCall call) {
        getContext().getSharedPreferences(PREFS, 0).edit().remove(VALUE).apply();
        call.resolve();
    }

    private SecretKey getKey() throws Exception {
        KeyStore ks = KeyStore.getInstance("AndroidKeyStore"); ks.load(null);
        if (!ks.containsAlias(ALIAS)) {
            KeyGenerator kg = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore");
            kg.init(new KeyGenParameterSpec.Builder(ALIAS, KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
                    .setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build());
            kg.generateKey();
        }
        return ((KeyStore.SecretKeyEntry) ks.getEntry(ALIAS, null)).getSecretKey();
    }
    private String encrypt(String plain) throws Exception {
        Cipher c = Cipher.getInstance("AES/GCM/NoPadding"); c.init(Cipher.ENCRYPT_MODE, getKey());
        String iv = Base64.encodeToString(c.getIV(), Base64.NO_WRAP); String body = Base64.encodeToString(c.doFinal(plain.getBytes(StandardCharsets.UTF_8)), Base64.NO_WRAP);
        return iv + ":" + body;
    }
    private String decrypt(String packed) throws Exception {
        if (packed == null || packed.isEmpty()) return null; String[] p = packed.split(":", 2); if (p.length != 2) return null;
        Cipher c = Cipher.getInstance("AES/GCM/NoPadding"); c.init(Cipher.DECRYPT_MODE, getKey(), new GCMParameterSpec(128, Base64.decode(p[0], Base64.NO_WRAP)));
        return new String(c.doFinal(Base64.decode(p[1], Base64.NO_WRAP)), StandardCharsets.UTF_8);
    }
}
