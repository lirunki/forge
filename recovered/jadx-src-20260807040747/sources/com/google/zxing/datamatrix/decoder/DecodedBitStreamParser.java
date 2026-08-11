package com.google.zxing.datamatrix.decoder;

import com.google.zxing.FormatException;
import com.google.zxing.common.BitSource;
import com.google.zxing.common.DecoderResult;
import com.google.zxing.common.ECIStringBuilder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import kotlin.text.Typography;

/* loaded from: classes.dex */
final class DecodedBitStreamParser {
    private static final char[] C40_BASIC_SET_CHARS = {'*', '*', '*', ' ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
    private static final char[] C40_SHIFT2_SET_CHARS;
    private static final char[] TEXT_BASIC_SET_CHARS;
    private static final char[] TEXT_SHIFT2_SET_CHARS;
    private static final char[] TEXT_SHIFT3_SET_CHARS;

    private enum Mode {
        PAD_ENCODE,
        ASCII_ENCODE,
        C40_ENCODE,
        TEXT_ENCODE,
        ANSIX12_ENCODE,
        EDIFACT_ENCODE,
        BASE256_ENCODE,
        ECI_ENCODE
    }

    static {
        char[] cArr = {'!', Typography.quote, '#', Typography.dollar, '%', Typography.amp, '\'', '(', ')', '*', '+', ',', '-', '.', '/', ':', ';', Typography.less, '=', Typography.greater, '?', '@', '[', '\\', ']', '^', '_'};
        C40_SHIFT2_SET_CHARS = cArr;
        TEXT_BASIC_SET_CHARS = new char[]{'*', '*', '*', ' ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
        TEXT_SHIFT2_SET_CHARS = cArr;
        TEXT_SHIFT3_SET_CHARS = new char[]{'`', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '{', '|', '}', '~', 127};
    }

    private DecodedBitStreamParser() {
    }

    /* JADX WARN: Removed duplicated region for block: B:12:0x006c  */
    /* JADX WARN: Removed duplicated region for block: B:15:0x0073  */
    /* JADX WARN: Removed duplicated region for block: B:26:0x00ce  */
    /* JADX WARN: Removed duplicated region for block: B:30:0x00d1  */
    /* JADX WARN: Removed duplicated region for block: B:33:0x009b  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    static DecoderResult decode(byte[] bytes) throws FormatException {
        int symbologyModifier;
        BitSource bits = new BitSource(bytes);
        ECIStringBuilder result = new ECIStringBuilder(100);
        StringBuilder resultTrailer = new StringBuilder(0);
        List<byte[]> byteSegments = new ArrayList<>(1);
        Mode mode = Mode.ASCII_ENCODE;
        Set<Integer> fnc1Positions = new HashSet<>();
        boolean isECIencoded = false;
        do {
            if (mode == Mode.ASCII_ENCODE) {
                mode = decodeAsciiSegment(bits, result, resultTrailer, fnc1Positions);
            } else {
                switch (AnonymousClass1.$SwitchMap$com$google$zxing$datamatrix$decoder$DecodedBitStreamParser$Mode[mode.ordinal()]) {
                    case 1:
                        decodeC40Segment(bits, result, fnc1Positions);
                        break;
                    case 2:
                        decodeTextSegment(bits, result, fnc1Positions);
                        break;
                    case 3:
                        decodeAnsiX12Segment(bits, result);
                        break;
                    case 4:
                        decodeEdifactSegment(bits, result);
                        break;
                    case 5:
                        decodeBase256Segment(bits, result, byteSegments);
                        break;
                    case 6:
                        decodeECISegment(bits, result);
                        isECIencoded = true;
                        break;
                    default:
                        throw FormatException.getFormatInstance();
                }
                mode = Mode.ASCII_ENCODE;
            }
            if (mode != Mode.PAD_ENCODE) {
            }
            if (resultTrailer.length() > 0) {
                result.appendCharacters(resultTrailer);
            }
            if (!isECIencoded) {
                if (fnc1Positions.contains(0) || fnc1Positions.contains(4)) {
                    symbologyModifier = 5;
                } else if (fnc1Positions.contains(1) || fnc1Positions.contains(5)) {
                    symbologyModifier = 6;
                } else {
                    symbologyModifier = 4;
                }
            } else if (fnc1Positions.contains(0) || fnc1Positions.contains(4)) {
                symbologyModifier = 2;
            } else if (fnc1Positions.contains(1) || fnc1Positions.contains(5)) {
                symbologyModifier = 3;
            } else {
                symbologyModifier = 1;
            }
            return new DecoderResult(bytes, result.toString(), !byteSegments.isEmpty() ? null : byteSegments, null, symbologyModifier);
        } while (bits.available() > 0);
        if (resultTrailer.length() > 0) {
        }
        if (!isECIencoded) {
        }
        return new DecoderResult(bytes, result.toString(), !byteSegments.isEmpty() ? null : byteSegments, null, symbologyModifier);
    }

    /* renamed from: com.google.zxing.datamatrix.decoder.DecodedBitStreamParser$1, reason: invalid class name */
    static /* synthetic */ class AnonymousClass1 {
        static final /* synthetic */ int[] $SwitchMap$com$google$zxing$datamatrix$decoder$DecodedBitStreamParser$Mode;

        static {
            int[] iArr = new int[Mode.values().length];
            $SwitchMap$com$google$zxing$datamatrix$decoder$DecodedBitStreamParser$Mode = iArr;
            try {
                iArr[Mode.C40_ENCODE.ordinal()] = 1;
            } catch (NoSuchFieldError e) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$decoder$DecodedBitStreamParser$Mode[Mode.TEXT_ENCODE.ordinal()] = 2;
            } catch (NoSuchFieldError e2) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$decoder$DecodedBitStreamParser$Mode[Mode.ANSIX12_ENCODE.ordinal()] = 3;
            } catch (NoSuchFieldError e3) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$decoder$DecodedBitStreamParser$Mode[Mode.EDIFACT_ENCODE.ordinal()] = 4;
            } catch (NoSuchFieldError e4) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$decoder$DecodedBitStreamParser$Mode[Mode.BASE256_ENCODE.ordinal()] = 5;
            } catch (NoSuchFieldError e5) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$decoder$DecodedBitStreamParser$Mode[Mode.ECI_ENCODE.ordinal()] = 6;
            } catch (NoSuchFieldError e6) {
            }
        }
    }

    private static Mode decodeAsciiSegment(BitSource bits, ECIStringBuilder result, StringBuilder resultTrailer, Set<Integer> fnc1positions) throws FormatException {
        boolean upperShift = false;
        do {
            int oneByte = bits.readBits(8);
            if (oneByte == 0) {
                throw FormatException.getFormatInstance();
            }
            if (oneByte <= 128) {
                if (upperShift) {
                    oneByte += 128;
                }
                result.append((char) (oneByte - 1));
                return Mode.ASCII_ENCODE;
            }
            if (oneByte == 129) {
                return Mode.PAD_ENCODE;
            }
            if (oneByte <= 229) {
                int value = oneByte - 130;
                if (value < 10) {
                    result.append('0');
                }
                result.append(value);
            } else {
                switch (oneByte) {
                    case 230:
                        return Mode.C40_ENCODE;
                    case 231:
                        return Mode.BASE256_ENCODE;
                    case 232:
                        fnc1positions.add(Integer.valueOf(result.length()));
                        result.append((char) 29);
                        break;
                    case 233:
                    case 234:
                        break;
                    case 235:
                        upperShift = true;
                        break;
                    case 236:
                        result.append("[)>\u001e05\u001d");
                        resultTrailer.insert(0, "\u001e\u0004");
                        break;
                    case 237:
                        result.append("[)>\u001e06\u001d");
                        resultTrailer.insert(0, "\u001e\u0004");
                        break;
                    case 238:
                        return Mode.ANSIX12_ENCODE;
                    case 239:
                        return Mode.TEXT_ENCODE;
                    case 240:
                        return Mode.EDIFACT_ENCODE;
                    case 241:
                        return Mode.ECI_ENCODE;
                    default:
                        if (oneByte != 254 || bits.available() != 0) {
                            throw FormatException.getFormatInstance();
                        }
                        break;
                }
            }
        } while (bits.available() > 0);
        return Mode.ASCII_ENCODE;
    }

    private static void decodeC40Segment(BitSource bits, ECIStringBuilder result, Set<Integer> fnc1positions) throws FormatException {
        int firstByte;
        boolean upperShift = false;
        int[] cValues = new int[3];
        int shift = 0;
        while (bits.available() != 8 && (firstByte = bits.readBits(8)) != 254) {
            parseTwoBytes(firstByte, bits.readBits(8), cValues);
            for (int i = 0; i < 3; i++) {
                int cValue = cValues[i];
                switch (shift) {
                    case 0:
                        if (cValue < 3) {
                            shift = cValue + 1;
                            break;
                        } else {
                            char[] cArr = C40_BASIC_SET_CHARS;
                            if (cValue < cArr.length) {
                                char c40char = cArr[cValue];
                                if (upperShift) {
                                    result.append((char) (c40char + 128));
                                    upperShift = false;
                                    break;
                                } else {
                                    result.append(c40char);
                                    break;
                                }
                            } else {
                                throw FormatException.getFormatInstance();
                            }
                        }
                    case 1:
                        if (upperShift) {
                            result.append((char) (cValue + 128));
                            upperShift = false;
                        } else {
                            result.append((char) cValue);
                        }
                        shift = 0;
                        break;
                    case 2:
                        char[] cArr2 = C40_SHIFT2_SET_CHARS;
                        if (cValue < cArr2.length) {
                            char c40char2 = cArr2[cValue];
                            if (upperShift) {
                                result.append((char) (c40char2 + 128));
                                upperShift = false;
                            } else {
                                result.append(c40char2);
                            }
                        } else {
                            switch (cValue) {
                                case 27:
                                    fnc1positions.add(Integer.valueOf(result.length()));
                                    result.append((char) 29);
                                    break;
                                case 30:
                                    upperShift = true;
                                    break;
                                default:
                                    throw FormatException.getFormatInstance();
                            }
                        }
                        shift = 0;
                        break;
                    case 3:
                        if (upperShift) {
                            result.append((char) (cValue + 224));
                            upperShift = false;
                        } else {
                            result.append((char) (cValue + 96));
                        }
                        shift = 0;
                        break;
                    default:
                        throw FormatException.getFormatInstance();
                }
            }
            if (bits.available() <= 0) {
                return;
            }
        }
    }

    private static void decodeTextSegment(BitSource bits, ECIStringBuilder result, Set<Integer> fnc1positions) throws FormatException {
        int firstByte;
        boolean upperShift = false;
        int[] cValues = new int[3];
        int shift = 0;
        while (bits.available() != 8 && (firstByte = bits.readBits(8)) != 254) {
            parseTwoBytes(firstByte, bits.readBits(8), cValues);
            for (int i = 0; i < 3; i++) {
                int cValue = cValues[i];
                switch (shift) {
                    case 0:
                        if (cValue < 3) {
                            shift = cValue + 1;
                            break;
                        } else {
                            char[] cArr = TEXT_BASIC_SET_CHARS;
                            if (cValue < cArr.length) {
                                char textChar = cArr[cValue];
                                if (upperShift) {
                                    result.append((char) (textChar + 128));
                                    upperShift = false;
                                    break;
                                } else {
                                    result.append(textChar);
                                    break;
                                }
                            } else {
                                throw FormatException.getFormatInstance();
                            }
                        }
                    case 1:
                        if (upperShift) {
                            result.append((char) (cValue + 128));
                            upperShift = false;
                        } else {
                            result.append((char) cValue);
                        }
                        shift = 0;
                        break;
                    case 2:
                        char[] cArr2 = TEXT_SHIFT2_SET_CHARS;
                        if (cValue < cArr2.length) {
                            char textChar2 = cArr2[cValue];
                            if (upperShift) {
                                result.append((char) (textChar2 + 128));
                                upperShift = false;
                            } else {
                                result.append(textChar2);
                            }
                        } else {
                            switch (cValue) {
                                case 27:
                                    fnc1positions.add(Integer.valueOf(result.length()));
                                    result.append((char) 29);
                                    break;
                                case 30:
                                    upperShift = true;
                                    break;
                                default:
                                    throw FormatException.getFormatInstance();
                            }
                        }
                        shift = 0;
                        break;
                    case 3:
                        char[] cArr3 = TEXT_SHIFT3_SET_CHARS;
                        if (cValue < cArr3.length) {
                            char textChar3 = cArr3[cValue];
                            if (upperShift) {
                                result.append((char) (textChar3 + 128));
                                upperShift = false;
                            } else {
                                result.append(textChar3);
                            }
                            shift = 0;
                            break;
                        } else {
                            throw FormatException.getFormatInstance();
                        }
                    default:
                        throw FormatException.getFormatInstance();
                }
            }
            if (bits.available() <= 0) {
                return;
            }
        }
    }

    private static void decodeAnsiX12Segment(BitSource bits, ECIStringBuilder result) throws FormatException {
        int firstByte;
        int[] cValues = new int[3];
        while (bits.available() != 8 && (firstByte = bits.readBits(8)) != 254) {
            parseTwoBytes(firstByte, bits.readBits(8), cValues);
            for (int i = 0; i < 3; i++) {
                int cValue = cValues[i];
                switch (cValue) {
                    case 0:
                        result.append('\r');
                        break;
                    case 1:
                        result.append('*');
                        break;
                    case 2:
                        result.append(Typography.greater);
                        break;
                    case 3:
                        result.append(' ');
                        break;
                    default:
                        if (cValue < 14) {
                            result.append((char) (cValue + 44));
                            break;
                        } else if (cValue < 40) {
                            result.append((char) (cValue + 51));
                            break;
                        } else {
                            throw FormatException.getFormatInstance();
                        }
                }
            }
            if (bits.available() <= 0) {
                return;
            }
        }
    }

    private static void parseTwoBytes(int firstByte, int secondByte, int[] result) {
        int fullBitValue = ((firstByte << 8) + secondByte) - 1;
        int temp = fullBitValue / 1600;
        result[0] = temp;
        int fullBitValue2 = fullBitValue - (temp * 1600);
        int temp2 = fullBitValue2 / 40;
        result[1] = temp2;
        result[2] = fullBitValue2 - (temp2 * 40);
    }

    private static void decodeEdifactSegment(BitSource bits, ECIStringBuilder result) {
        while (bits.available() > 16) {
            for (int i = 0; i < 4; i++) {
                int edifactValue = bits.readBits(6);
                if (edifactValue == 31) {
                    int bitsLeft = 8 - bits.getBitOffset();
                    if (bitsLeft != 8) {
                        bits.readBits(bitsLeft);
                        return;
                    }
                    return;
                }
                if ((edifactValue & 32) == 0) {
                    edifactValue |= 64;
                }
                result.append((char) edifactValue);
            }
            int i2 = bits.available();
            if (i2 <= 0) {
                return;
            }
        }
    }

    private static void decodeBase256Segment(BitSource bits, ECIStringBuilder result, Collection<byte[]> byteSegments) throws FormatException {
        int count;
        int codewordPosition = bits.getByteOffset() + 1;
        int codewordPosition2 = codewordPosition + 1;
        int d1 = unrandomize255State(bits.readBits(8), codewordPosition);
        if (d1 == 0) {
            count = bits.available() / 8;
        } else if (d1 >= 250) {
            count = unrandomize255State(bits.readBits(8), codewordPosition2) + ((d1 - 249) * 250);
            codewordPosition2++;
        } else {
            count = d1;
        }
        if (count < 0) {
            throw FormatException.getFormatInstance();
        }
        byte[] bytes = new byte[count];
        int i = 0;
        while (i < count) {
            if (bits.available() < 8) {
                throw FormatException.getFormatInstance();
            }
            bytes[i] = (byte) unrandomize255State(bits.readBits(8), codewordPosition2);
            i++;
            codewordPosition2++;
        }
        byteSegments.add(bytes);
        result.append(new String(bytes, StandardCharsets.ISO_8859_1));
    }

    private static void decodeECISegment(BitSource bits, ECIStringBuilder result) throws FormatException {
        if (bits.available() < 8) {
            throw FormatException.getFormatInstance();
        }
        int c1 = bits.readBits(8);
        if (c1 <= 127) {
            result.appendECI(c1 - 1);
        }
    }

    private static int unrandomize255State(int randomizedBase256Codeword, int base256CodewordPosition) {
        int pseudoRandomNumber = ((base256CodewordPosition * 149) % 255) + 1;
        int tempVariable = randomizedBase256Codeword - pseudoRandomNumber;
        return tempVariable >= 0 ? tempVariable : tempVariable + 256;
    }
}
