package com.google.zxing.qrcode.decoder;

import com.google.zxing.DecodeHintType;
import com.google.zxing.FormatException;
import com.google.zxing.common.BitSource;
import com.google.zxing.common.CharacterSetECI;
import com.google.zxing.common.DecoderResult;
import com.google.zxing.common.StringUtils;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import kotlinx.coroutines.scheduling.WorkQueueKt;

/* loaded from: classes.dex */
final class DecodedBitStreamParser {
    private static final char[] ALPHANUMERIC_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:".toCharArray();
    private static final int GB2312_SUBSET = 1;

    private DecodedBitStreamParser() {
    }

    /* JADX WARN: Removed duplicated region for block: B:17:0x0124 A[LOOP:0: B:2:0x001e->B:17:0x0124, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:18:0x00e2 A[SYNTHETIC] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    static DecoderResult decode(byte[] bytes, Version version, ErrorCorrectionLevel ecLevel, Map<DecodeHintType, ?> hints) throws FormatException {
        Mode mode;
        Mode mode2;
        int count;
        int parityData;
        int symbologyModifier;
        BitSource bits = new BitSource(bytes);
        StringBuilder result = new StringBuilder(50);
        int i = 1;
        List<byte[]> byteSegments = new ArrayList<>(1);
        int symbolSequence = -1;
        int parityData2 = -1;
        CharacterSetECI currentCharacterSetECI = null;
        boolean fc1InEffect = false;
        boolean hasFNC1first = false;
        boolean hasFNC1second = false;
        while (true) {
            try {
                if (bits.available() < 4) {
                    try {
                        mode = Mode.TERMINATOR;
                    } catch (IllegalArgumentException e) {
                        throw FormatException.getFormatInstance();
                    }
                } else {
                    mode = Mode.forBits(bits.readBits(4));
                }
                switch (mode) {
                    case TERMINATOR:
                        mode2 = mode;
                        count = symbolSequence;
                        parityData = parityData2;
                        try {
                            if (mode2 != Mode.TERMINATOR) {
                                if (currentCharacterSetECI != null) {
                                    if (hasFNC1first) {
                                        symbologyModifier = 4;
                                    } else if (hasFNC1second) {
                                        symbologyModifier = 6;
                                    } else {
                                        symbologyModifier = 2;
                                    }
                                } else if (hasFNC1first) {
                                    symbologyModifier = 3;
                                } else if (hasFNC1second) {
                                    symbologyModifier = 5;
                                } else {
                                    symbologyModifier = 1;
                                }
                                return new DecoderResult(bytes, result.toString(), byteSegments.isEmpty() ? null : byteSegments, ecLevel == null ? null : ecLevel.toString(), count, parityData, symbologyModifier);
                            }
                            symbolSequence = count;
                            parityData2 = parityData;
                            i = 1;
                        } catch (IllegalArgumentException e2) {
                            throw FormatException.getFormatInstance();
                        }
                    case FNC1_FIRST_POSITION:
                        hasFNC1first = true;
                        fc1InEffect = true;
                        count = symbolSequence;
                        parityData = parityData2;
                        mode2 = mode;
                        if (mode2 != Mode.TERMINATOR) {
                        }
                        break;
                    case FNC1_SECOND_POSITION:
                        hasFNC1second = true;
                        fc1InEffect = true;
                        count = symbolSequence;
                        parityData = parityData2;
                        mode2 = mode;
                        if (mode2 != Mode.TERMINATOR) {
                        }
                        break;
                    case STRUCTURED_APPEND:
                        int value = bits.available();
                        if (value < 16) {
                            throw FormatException.getFormatInstance();
                        }
                        int symbolSequence2 = bits.readBits(8);
                        int parityData3 = bits.readBits(8);
                        count = symbolSequence2;
                        parityData = parityData3;
                        mode2 = mode;
                        if (mode2 != Mode.TERMINATOR) {
                        }
                        break;
                    case ECI:
                        int value2 = parseECIValue(bits);
                        currentCharacterSetECI = CharacterSetECI.getCharacterSetECIByValue(value2);
                        if (currentCharacterSetECI == null) {
                            throw FormatException.getFormatInstance();
                        }
                        count = symbolSequence;
                        parityData = parityData2;
                        mode2 = mode;
                        if (mode2 != Mode.TERMINATOR) {
                        }
                        break;
                    case HANZI:
                        int subset = bits.readBits(4);
                        int countHanzi = bits.readBits(mode.getCharacterCountBits(version));
                        if (subset != i) {
                            mode2 = mode;
                        } else {
                            decodeHanziSegment(bits, result, countHanzi);
                            mode2 = mode;
                        }
                        count = symbolSequence;
                        parityData = parityData2;
                        if (mode2 != Mode.TERMINATOR) {
                        }
                        break;
                    default:
                        int count2 = bits.readBits(mode.getCharacterCountBits(version));
                        switch (AnonymousClass1.$SwitchMap$com$google$zxing$qrcode$decoder$Mode[mode.ordinal()]) {
                            case 1:
                                mode2 = mode;
                                decodeNumericSegment(bits, result, count2);
                                count = symbolSequence;
                                parityData = parityData2;
                                if (mode2 != Mode.TERMINATOR) {
                                }
                                break;
                            case 2:
                                mode2 = mode;
                                decodeAlphanumericSegment(bits, result, count2, fc1InEffect);
                                count = symbolSequence;
                                parityData = parityData2;
                                if (mode2 != Mode.TERMINATOR) {
                                }
                                break;
                            case 3:
                                mode2 = mode;
                                decodeByteSegment(bits, result, count2, currentCharacterSetECI, byteSegments, hints);
                                count = symbolSequence;
                                parityData = parityData2;
                                if (mode2 != Mode.TERMINATOR) {
                                }
                                break;
                            case 4:
                                decodeKanjiSegment(bits, result, count2);
                                mode2 = mode;
                                count = symbolSequence;
                                parityData = parityData2;
                                if (mode2 != Mode.TERMINATOR) {
                                }
                                break;
                            default:
                                try {
                                    throw FormatException.getFormatInstance();
                                } catch (IllegalArgumentException e3) {
                                    throw FormatException.getFormatInstance();
                                }
                        }
                }
            } catch (IllegalArgumentException e4) {
            }
        }
    }

    private static void decodeHanziSegment(BitSource bits, StringBuilder result, int count) throws FormatException {
        int i;
        if (StringUtils.GB2312_CHARSET == null) {
            throw FormatException.getFormatInstance();
        }
        if (count * 13 > bits.available()) {
            throw FormatException.getFormatInstance();
        }
        byte[] buffer = new byte[count * 2];
        int offset = 0;
        while (count > 0) {
            int twoBytes = bits.readBits(13);
            int assembledTwoBytes = ((twoBytes / 96) << 8) | (twoBytes % 96);
            if (assembledTwoBytes < 2560) {
                i = 41377;
            } else {
                i = 42657;
            }
            int assembledTwoBytes2 = assembledTwoBytes + i;
            buffer[offset] = (byte) ((assembledTwoBytes2 >> 8) & 255);
            buffer[offset + 1] = (byte) (assembledTwoBytes2 & 255);
            offset += 2;
            count--;
        }
        result.append(new String(buffer, StringUtils.GB2312_CHARSET));
    }

    private static void decodeKanjiSegment(BitSource bits, StringBuilder result, int count) throws FormatException {
        int i;
        if (StringUtils.SHIFT_JIS_CHARSET == null) {
            throw FormatException.getFormatInstance();
        }
        if (count * 13 > bits.available()) {
            throw FormatException.getFormatInstance();
        }
        byte[] buffer = new byte[count * 2];
        int offset = 0;
        while (count > 0) {
            int twoBytes = bits.readBits(13);
            int assembledTwoBytes = ((twoBytes / 192) << 8) | (twoBytes % 192);
            if (assembledTwoBytes < 7936) {
                i = 33088;
            } else {
                i = 49472;
            }
            int assembledTwoBytes2 = assembledTwoBytes + i;
            buffer[offset] = (byte) (assembledTwoBytes2 >> 8);
            buffer[offset + 1] = (byte) assembledTwoBytes2;
            offset += 2;
            count--;
        }
        result.append(new String(buffer, StringUtils.SHIFT_JIS_CHARSET));
    }

    private static void decodeByteSegment(BitSource bits, StringBuilder result, int count, CharacterSetECI currentCharacterSetECI, Collection<byte[]> byteSegments, Map<DecodeHintType, ?> hints) throws FormatException {
        Charset encoding;
        if (count * 8 > bits.available()) {
            throw FormatException.getFormatInstance();
        }
        byte[] readBytes = new byte[count];
        for (int i = 0; i < count; i++) {
            readBytes[i] = (byte) bits.readBits(8);
        }
        if (currentCharacterSetECI == null) {
            encoding = StringUtils.guessCharset(readBytes, hints);
        } else {
            encoding = currentCharacterSetECI.getCharset();
        }
        result.append(new String(readBytes, encoding));
        byteSegments.add(readBytes);
    }

    private static char toAlphaNumericChar(int value) throws FormatException {
        char[] cArr = ALPHANUMERIC_CHARS;
        if (value >= cArr.length) {
            throw FormatException.getFormatInstance();
        }
        return cArr[value];
    }

    private static void decodeAlphanumericSegment(BitSource bits, StringBuilder result, int count, boolean fc1InEffect) throws FormatException {
        int start = result.length();
        while (count > 1) {
            if (bits.available() < 11) {
                throw FormatException.getFormatInstance();
            }
            int nextTwoCharsBits = bits.readBits(11);
            result.append(toAlphaNumericChar(nextTwoCharsBits / 45));
            result.append(toAlphaNumericChar(nextTwoCharsBits % 45));
            count -= 2;
        }
        if (count == 1) {
            if (bits.available() < 6) {
                throw FormatException.getFormatInstance();
            }
            result.append(toAlphaNumericChar(bits.readBits(6)));
        }
        if (fc1InEffect) {
            for (int i = start; i < result.length(); i++) {
                if (result.charAt(i) == '%') {
                    if (i < result.length() - 1 && result.charAt(i + 1) == '%') {
                        result.deleteCharAt(i + 1);
                    } else {
                        result.setCharAt(i, (char) 29);
                    }
                }
            }
        }
    }

    private static void decodeNumericSegment(BitSource bits, StringBuilder result, int count) throws FormatException {
        while (count >= 3) {
            if (bits.available() < 10) {
                throw FormatException.getFormatInstance();
            }
            int threeDigitsBits = bits.readBits(10);
            if (threeDigitsBits >= 1000) {
                throw FormatException.getFormatInstance();
            }
            result.append(toAlphaNumericChar(threeDigitsBits / 100));
            result.append(toAlphaNumericChar((threeDigitsBits / 10) % 10));
            result.append(toAlphaNumericChar(threeDigitsBits % 10));
            count -= 3;
        }
        if (count == 2) {
            if (bits.available() < 7) {
                throw FormatException.getFormatInstance();
            }
            int twoDigitsBits = bits.readBits(7);
            if (twoDigitsBits >= 100) {
                throw FormatException.getFormatInstance();
            }
            result.append(toAlphaNumericChar(twoDigitsBits / 10));
            result.append(toAlphaNumericChar(twoDigitsBits % 10));
            return;
        }
        if (count == 1) {
            if (bits.available() < 4) {
                throw FormatException.getFormatInstance();
            }
            int digitBits = bits.readBits(4);
            if (digitBits >= 10) {
                throw FormatException.getFormatInstance();
            }
            result.append(toAlphaNumericChar(digitBits));
        }
    }

    private static int parseECIValue(BitSource bits) throws FormatException {
        int firstByte = bits.readBits(8);
        if ((firstByte & 128) == 0) {
            return firstByte & WorkQueueKt.MASK;
        }
        if ((firstByte & 192) == 128) {
            int secondByte = bits.readBits(8);
            return ((firstByte & 63) << 8) | secondByte;
        }
        if ((firstByte & 224) == 192) {
            int secondThirdBytes = bits.readBits(16);
            return ((firstByte & 31) << 16) | secondThirdBytes;
        }
        throw FormatException.getFormatInstance();
    }
}
