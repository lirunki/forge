package com.google.zxing.common;

import java.nio.charset.Charset;
import java.nio.charset.CharsetEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.charset.UnsupportedCharsetException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/* loaded from: classes.dex */
public final class ECIEncoderSet {
    static final /* synthetic */ boolean $assertionsDisabled = false;
    private static final List<CharsetEncoder> ENCODERS = new ArrayList();
    private final CharsetEncoder[] encoders;
    private final int priorityEncoderIndex;

    static {
        String[] names = {"IBM437", "ISO-8859-2", "ISO-8859-3", "ISO-8859-4", "ISO-8859-5", "ISO-8859-6", "ISO-8859-7", "ISO-8859-8", "ISO-8859-9", "ISO-8859-10", "ISO-8859-11", "ISO-8859-13", "ISO-8859-14", "ISO-8859-15", "ISO-8859-16", "windows-1250", "windows-1251", "windows-1252", "windows-1256", "Shift_JIS"};
        for (String name : names) {
            if (CharacterSetECI.getCharacterSetECIByName(name) != null) {
                try {
                    ENCODERS.add(Charset.forName(name).newEncoder());
                } catch (UnsupportedCharsetException e) {
                }
            }
        }
    }

    public ECIEncoderSet(String stringToEncode, Charset priorityCharset, int fnc1) {
        List<CharsetEncoder> neededEncoders = new ArrayList<>();
        neededEncoders.add(StandardCharsets.ISO_8859_1.newEncoder());
        boolean needUnicodeEncoder = priorityCharset != null && priorityCharset.name().startsWith("UTF");
        for (int i = 0; i < stringToEncode.length(); i++) {
            boolean canEncode = false;
            for (CharsetEncoder encoder : neededEncoders) {
                char c = stringToEncode.charAt(i);
                if (c == fnc1 || encoder.canEncode(c)) {
                    canEncode = true;
                    break;
                }
            }
            if (!canEncode) {
                Iterator<CharsetEncoder> it = ENCODERS.iterator();
                while (true) {
                    if (!it.hasNext()) {
                        break;
                    }
                    CharsetEncoder encoder2 = it.next();
                    if (encoder2.canEncode(stringToEncode.charAt(i))) {
                        neededEncoders.add(encoder2);
                        canEncode = true;
                        break;
                    }
                }
            }
            if (!canEncode) {
                needUnicodeEncoder = true;
            }
        }
        int i2 = neededEncoders.size();
        if (i2 == 1 && !needUnicodeEncoder) {
            this.encoders = new CharsetEncoder[]{neededEncoders.get(0)};
        } else {
            this.encoders = new CharsetEncoder[neededEncoders.size() + 2];
            int index = 0;
            Iterator<CharsetEncoder> it2 = neededEncoders.iterator();
            while (it2.hasNext()) {
                this.encoders[index] = it2.next();
                index++;
            }
            this.encoders[index] = StandardCharsets.UTF_8.newEncoder();
            this.encoders[index + 1] = StandardCharsets.UTF_16BE.newEncoder();
        }
        int priorityEncoderIndexValue = -1;
        if (priorityCharset != null) {
            int i3 = 0;
            while (true) {
                CharsetEncoder[] charsetEncoderArr = this.encoders;
                if (i3 >= charsetEncoderArr.length) {
                    break;
                }
                if (charsetEncoderArr[i3] == null || !priorityCharset.name().equals(this.encoders[i3].charset().name())) {
                    i3++;
                } else {
                    priorityEncoderIndexValue = i3;
                    break;
                }
            }
        }
        this.priorityEncoderIndex = priorityEncoderIndexValue;
        if (!this.encoders[0].charset().equals(StandardCharsets.ISO_8859_1)) {
            throw new AssertionError();
        }
    }

    public int length() {
        return this.encoders.length;
    }

    public String getCharsetName(int index) {
        if (index >= length()) {
            throw new AssertionError();
        }
        return this.encoders[index].charset().name();
    }

    public Charset getCharset(int index) {
        if (index >= length()) {
            throw new AssertionError();
        }
        return this.encoders[index].charset();
    }

    public int getECIValue(int encoderIndex) {
        return CharacterSetECI.getCharacterSetECI(this.encoders[encoderIndex].charset()).getValue();
    }

    public int getPriorityEncoderIndex() {
        return this.priorityEncoderIndex;
    }

    public boolean canEncode(char c, int encoderIndex) {
        if (encoderIndex >= length()) {
            throw new AssertionError();
        }
        CharsetEncoder encoder = this.encoders[encoderIndex];
        return encoder.canEncode("" + c);
    }

    public byte[] encode(char c, int encoderIndex) {
        if (encoderIndex >= length()) {
            throw new AssertionError();
        }
        CharsetEncoder encoder = this.encoders[encoderIndex];
        if (!encoder.canEncode("" + c)) {
            throw new AssertionError();
        }
        return ("" + c).getBytes(encoder.charset());
    }

    public byte[] encode(String s, int encoderIndex) {
        if (encoderIndex >= length()) {
            throw new AssertionError();
        }
        CharsetEncoder encoder = this.encoders[encoderIndex];
        return s.getBytes(encoder.charset());
    }
}
