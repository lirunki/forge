package com.google.zxing.common;

import java.util.List;

/* loaded from: classes.dex */
public final class DecoderResult {
    private final List<byte[]> byteSegments;
    private final String ecLevel;
    private Integer erasures;
    private Integer errorsCorrected;
    private int numBits;
    private Object other;
    private final byte[] rawBytes;
    private final int structuredAppendParity;
    private final int structuredAppendSequenceNumber;
    private final int symbologyModifier;
    private final String text;

    public DecoderResult(byte[] rawBytes, String text, List<byte[]> byteSegments, String ecLevel) {
        this(rawBytes, text, byteSegments, ecLevel, -1, -1, 0);
    }

    public DecoderResult(byte[] rawBytes, String text, List<byte[]> byteSegments, String ecLevel, int symbologyModifier) {
        this(rawBytes, text, byteSegments, ecLevel, -1, -1, symbologyModifier);
    }

    public DecoderResult(byte[] rawBytes, String text, List<byte[]> byteSegments, String ecLevel, int saSequence, int saParity) {
        this(rawBytes, text, byteSegments, ecLevel, saSequence, saParity, 0);
    }

    public DecoderResult(byte[] rawBytes, String text, List<byte[]> byteSegments, String ecLevel, int saSequence, int saParity, int symbologyModifier) {
        this.rawBytes = rawBytes;
        this.numBits = rawBytes == null ? 0 : rawBytes.length * 8;
        this.text = text;
        this.byteSegments = byteSegments;
        this.ecLevel = ecLevel;
        this.structuredAppendParity = saParity;
        this.structuredAppendSequenceNumber = saSequence;
        this.symbologyModifier = symbologyModifier;
    }

    public byte[] getRawBytes() {
        return this.rawBytes;
    }

    public int getNumBits() {
        return this.numBits;
    }

    public void setNumBits(int numBits) {
        this.numBits = numBits;
    }

    public String getText() {
        return this.text;
    }

    public List<byte[]> getByteSegments() {
        return this.byteSegments;
    }

    public String getECLevel() {
        return this.ecLevel;
    }

    public Integer getErrorsCorrected() {
        return this.errorsCorrected;
    }

    public void setErrorsCorrected(Integer errorsCorrected) {
        this.errorsCorrected = errorsCorrected;
    }

    public Integer getErasures() {
        return this.erasures;
    }

    public void setErasures(Integer erasures) {
        this.erasures = erasures;
    }

    public Object getOther() {
        return this.other;
    }

    public void setOther(Object other) {
        this.other = other;
    }

    public boolean hasStructuredAppend() {
        return this.structuredAppendParity >= 0 && this.structuredAppendSequenceNumber >= 0;
    }

    public int getStructuredAppendParity() {
        return this.structuredAppendParity;
    }

    public int getStructuredAppendSequenceNumber() {
        return this.structuredAppendSequenceNumber;
    }

    public int getSymbologyModifier() {
        return this.symbologyModifier;
    }
}
