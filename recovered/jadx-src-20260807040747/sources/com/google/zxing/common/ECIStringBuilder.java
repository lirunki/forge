package com.google.zxing.common;

import com.google.zxing.FormatException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import kotlin.UByte;

/* loaded from: classes.dex */
public final class ECIStringBuilder {
    private StringBuilder currentBytes;
    private Charset currentCharset;
    private StringBuilder result;

    public ECIStringBuilder() {
        this.currentCharset = StandardCharsets.ISO_8859_1;
        this.currentBytes = new StringBuilder();
    }

    public ECIStringBuilder(int initialCapacity) {
        this.currentCharset = StandardCharsets.ISO_8859_1;
        this.currentBytes = new StringBuilder(initialCapacity);
    }

    public void append(char value) {
        this.currentBytes.append((char) (value & 255));
    }

    public void append(byte value) {
        this.currentBytes.append((char) (value & UByte.MAX_VALUE));
    }

    public void append(String value) {
        this.currentBytes.append(value);
    }

    public void append(int value) {
        append(String.valueOf(value));
    }

    public void appendECI(int value) throws FormatException {
        encodeCurrentBytesIfAny();
        CharacterSetECI characterSetECI = CharacterSetECI.getCharacterSetECIByValue(value);
        if (characterSetECI == null) {
            throw FormatException.getFormatInstance();
        }
        this.currentCharset = characterSetECI.getCharset();
    }

    private void encodeCurrentBytesIfAny() {
        if (this.currentCharset.equals(StandardCharsets.ISO_8859_1)) {
            if (this.currentBytes.length() > 0) {
                StringBuilder sb = this.result;
                if (sb == null) {
                    this.result = this.currentBytes;
                    this.currentBytes = new StringBuilder();
                    return;
                } else {
                    sb.append((CharSequence) this.currentBytes);
                    this.currentBytes = new StringBuilder();
                    return;
                }
            }
            return;
        }
        if (this.currentBytes.length() > 0) {
            byte[] bytes = this.currentBytes.toString().getBytes(StandardCharsets.ISO_8859_1);
            this.currentBytes = new StringBuilder();
            StringBuilder sb2 = this.result;
            if (sb2 == null) {
                this.result = new StringBuilder(new String(bytes, this.currentCharset));
            } else {
                sb2.append(new String(bytes, this.currentCharset));
            }
        }
    }

    public void appendCharacters(StringBuilder value) {
        encodeCurrentBytesIfAny();
        this.result.append((CharSequence) value);
    }

    public int length() {
        return toString().length();
    }

    public boolean isEmpty() {
        StringBuilder sb;
        return this.currentBytes.length() == 0 && ((sb = this.result) == null || sb.length() == 0);
    }

    public String toString() {
        encodeCurrentBytesIfAny();
        StringBuilder sb = this.result;
        return sb == null ? "" : sb.toString();
    }
}
