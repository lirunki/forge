package com.google.zxing.pdf417.encoder;

import com.google.zxing.WriterException;
import com.google.zxing.common.CharacterSetECI;
import com.google.zxing.common.ECIInput;
import com.google.zxing.common.MinimalECIInput;
import java.math.BigInteger;
import java.nio.charset.Charset;
import java.nio.charset.CharsetEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import kotlin.UByte;
import kotlin.io.encoding.Base64;

/* loaded from: classes.dex */
final class PDF417HighLevelEncoder {
    static final /* synthetic */ boolean $assertionsDisabled = false;
    private static final int BYTE_COMPACTION = 1;
    private static final int ECI_CHARSET = 927;
    private static final int ECI_GENERAL_PURPOSE = 926;
    private static final int ECI_USER_DEFINED = 925;
    private static final int LATCH_TO_BYTE = 924;
    private static final int LATCH_TO_BYTE_PADDED = 901;
    private static final int LATCH_TO_NUMERIC = 902;
    private static final int LATCH_TO_TEXT = 900;
    private static final byte[] MIXED;
    private static final int NUMERIC_COMPACTION = 2;
    private static final int SHIFT_TO_BYTE = 913;
    private static final int SUBMODE_ALPHA = 0;
    private static final int SUBMODE_LOWER = 1;
    private static final int SUBMODE_MIXED = 2;
    private static final int SUBMODE_PUNCTUATION = 3;
    private static final int TEXT_COMPACTION = 0;
    private static final byte[] TEXT_MIXED_RAW = {48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 38, 13, 9, 44, 58, 35, 45, 46, 36, 47, 43, 37, 42, Base64.padSymbol, 94, 0, 32, 0, 0, 0};
    private static final byte[] TEXT_PUNCTUATION_RAW = {59, 60, 62, 64, 91, 92, 93, 95, 96, 126, 33, 13, 9, 44, 58, 10, 45, 46, 36, 47, 34, 124, 42, 40, 41, 63, 123, 125, 39, 0};
    private static final byte[] PUNCTUATION = new byte[128];
    private static final Charset DEFAULT_ENCODING = StandardCharsets.ISO_8859_1;

    static {
        byte[] bArr = new byte[128];
        MIXED = bArr;
        Arrays.fill(bArr, (byte) -1);
        int i = 0;
        while (true) {
            byte[] bArr2 = TEXT_MIXED_RAW;
            if (i >= bArr2.length) {
                break;
            }
            byte b = bArr2[i];
            if (b > 0) {
                MIXED[b] = (byte) i;
            }
            i++;
        }
        Arrays.fill(PUNCTUATION, (byte) -1);
        int i2 = 0;
        while (true) {
            byte[] bArr3 = TEXT_PUNCTUATION_RAW;
            if (i2 < bArr3.length) {
                byte b2 = bArr3[i2];
                if (b2 > 0) {
                    PUNCTUATION[b2] = (byte) i2;
                }
                i2++;
            } else {
                return;
            }
        }
    }

    private PDF417HighLevelEncoder() {
    }

    /* JADX WARN: Multi-variable type inference failed */
    static String encodeHighLevel(String str, Compaction compaction, Charset charset, boolean z) throws WriterException {
        ECIInput noECIInput;
        CharacterSetECI characterSetECI;
        Charset charset2 = charset;
        if (str.isEmpty()) {
            throw new WriterException("Empty message not allowed");
        }
        if (charset2 == null && !z) {
            for (int i = 0; i < str.length(); i++) {
                if (str.charAt(i) > 255) {
                    throw new WriterException("Non-encodable character detected: " + str.charAt(i) + " (Unicode: " + ((int) str.charAt(i)) + "). Consider specifying EncodeHintType.PDF417_AUTO_ECI and/or EncodeTypeHint.CHARACTER_SET.");
                }
            }
        }
        StringBuilder sb = new StringBuilder(str.length());
        Charset charset3 = null;
        boolean z2 = false;
        if (z) {
            noECIInput = new MinimalECIInput(str, charset2, -1);
        } else {
            noECIInput = new NoECIInput(str, z2 ? 1 : 0);
            if (charset2 == null) {
                charset2 = DEFAULT_ENCODING;
            } else if (!DEFAULT_ENCODING.equals(charset2) && (characterSetECI = CharacterSetECI.getCharacterSetECI(charset)) != null) {
                encodingECI(characterSetECI.getValue(), sb);
            }
        }
        int length = noECIInput.length();
        int i2 = 0;
        int i3 = 0;
        switch (AnonymousClass1.$SwitchMap$com$google$zxing$pdf417$encoder$Compaction[compaction.ordinal()]) {
            case 1:
                encodeText(noECIInput, 0, length, sb, 0);
                break;
            case 2:
                if (z) {
                    encodeMultiECIBinary(noECIInput, 0, noECIInput.length(), 0, sb);
                    break;
                } else {
                    byte[] bytes = noECIInput.toString().getBytes(charset2);
                    encodeBinary(bytes, 0, bytes.length, 1, sb);
                    break;
                }
            case 3:
                sb.append((char) 902);
                encodeNumeric(noECIInput, 0, length, sb);
                break;
            default:
                int i4 = 0;
                while (i2 < length) {
                    while (i2 < length && noECIInput.isECI(i2)) {
                        encodingECI(noECIInput.getECIValue(i2), sb);
                        i2++;
                    }
                    if (i2 >= length) {
                        break;
                    } else {
                        int determineConsecutiveDigitCount = determineConsecutiveDigitCount(noECIInput, i2);
                        if (determineConsecutiveDigitCount >= 13) {
                            sb.append((char) 902);
                            i4 = 2;
                            i3 = 0;
                            encodeNumeric(noECIInput, i2, determineConsecutiveDigitCount, sb);
                            i2 += determineConsecutiveDigitCount;
                        } else {
                            int determineConsecutiveTextCount = determineConsecutiveTextCount(noECIInput, i2);
                            if (determineConsecutiveTextCount >= 5 || determineConsecutiveDigitCount == length) {
                                if (i4 != 0) {
                                    sb.append((char) 900);
                                    i4 = 0;
                                    i3 = 0;
                                }
                                int encodeText = encodeText(noECIInput, i2, determineConsecutiveTextCount, sb, i3);
                                i2 += determineConsecutiveTextCount;
                                i3 = encodeText;
                            } else {
                                int determineConsecutiveBinaryCount = determineConsecutiveBinaryCount(noECIInput, i2, z ? charset3 : charset2);
                                if (determineConsecutiveBinaryCount == 0) {
                                    determineConsecutiveBinaryCount = 1;
                                }
                                byte[] bytes2 = z ? charset3 : noECIInput.subSequence(i2, i2 + determineConsecutiveBinaryCount).toString().getBytes(charset2);
                                if (((bytes2 == null && determineConsecutiveBinaryCount == 1) || (bytes2 != null && bytes2.length == 1)) && i4 == 0) {
                                    if (z) {
                                        encodeMultiECIBinary(noECIInput, i2, 1, 0, sb);
                                    } else {
                                        encodeBinary(bytes2, 0, 1, 0, sb);
                                    }
                                } else {
                                    if (z) {
                                        encodeMultiECIBinary(noECIInput, i2, i2 + determineConsecutiveBinaryCount, i4, sb);
                                    } else {
                                        encodeBinary(bytes2, 0, bytes2.length, i4, sb);
                                    }
                                    i4 = 1;
                                    i3 = 0;
                                }
                                i2 += determineConsecutiveBinaryCount;
                            }
                        }
                        charset3 = null;
                    }
                }
                break;
        }
        return sb.toString();
    }

    /* renamed from: com.google.zxing.pdf417.encoder.PDF417HighLevelEncoder$1, reason: invalid class name */
    static /* synthetic */ class AnonymousClass1 {
        static final /* synthetic */ int[] $SwitchMap$com$google$zxing$pdf417$encoder$Compaction;

        static {
            int[] iArr = new int[Compaction.values().length];
            $SwitchMap$com$google$zxing$pdf417$encoder$Compaction = iArr;
            try {
                iArr[Compaction.TEXT.ordinal()] = 1;
            } catch (NoSuchFieldError e) {
            }
            try {
                $SwitchMap$com$google$zxing$pdf417$encoder$Compaction[Compaction.BYTE.ordinal()] = 2;
            } catch (NoSuchFieldError e2) {
            }
            try {
                $SwitchMap$com$google$zxing$pdf417$encoder$Compaction[Compaction.NUMERIC.ordinal()] = 3;
            } catch (NoSuchFieldError e3) {
            }
        }
    }

    private static int encodeText(ECIInput input, int startpos, int count, StringBuilder sb, int initialSubmode) throws WriterException {
        StringBuilder tmp = new StringBuilder(count);
        int submode = initialSubmode;
        int idx = 0;
        while (true) {
            if (input.isECI(startpos + idx)) {
                encodingECI(input.getECIValue(startpos + idx), sb);
                idx++;
            } else {
                char ch = input.charAt(startpos + idx);
                switch (submode) {
                    case 0:
                        if (isAlphaUpper(ch)) {
                            if (ch == ' ') {
                                tmp.append((char) 26);
                                break;
                            } else {
                                tmp.append((char) (ch - 'A'));
                                break;
                            }
                        } else if (isAlphaLower(ch)) {
                            submode = 1;
                            tmp.append((char) 27);
                            break;
                        } else if (isMixed(ch)) {
                            submode = 2;
                            tmp.append((char) 28);
                            break;
                        } else {
                            tmp.append((char) 29);
                            tmp.append((char) PUNCTUATION[ch]);
                            break;
                        }
                    case 1:
                        if (isAlphaLower(ch)) {
                            if (ch == ' ') {
                                tmp.append((char) 26);
                                break;
                            } else {
                                tmp.append((char) (ch - 'a'));
                                break;
                            }
                        } else if (isAlphaUpper(ch)) {
                            tmp.append((char) 27);
                            tmp.append((char) (ch - 'A'));
                            break;
                        } else if (isMixed(ch)) {
                            submode = 2;
                            tmp.append((char) 28);
                            break;
                        } else {
                            tmp.append((char) 29);
                            tmp.append((char) PUNCTUATION[ch]);
                            break;
                        }
                    case 2:
                        if (isMixed(ch)) {
                            tmp.append((char) MIXED[ch]);
                            break;
                        } else if (isAlphaUpper(ch)) {
                            submode = 0;
                            tmp.append((char) 28);
                            break;
                        } else if (isAlphaLower(ch)) {
                            submode = 1;
                            tmp.append((char) 27);
                            break;
                        } else if (startpos + idx + 1 < count && !input.isECI(startpos + idx + 1) && isPunctuation(input.charAt(startpos + idx + 1))) {
                            submode = 3;
                            tmp.append((char) 25);
                            break;
                        } else {
                            tmp.append((char) 29);
                            tmp.append((char) PUNCTUATION[ch]);
                        }
                        break;
                    default:
                        if (isPunctuation(ch)) {
                            tmp.append((char) PUNCTUATION[ch]);
                            break;
                        } else {
                            submode = 0;
                            tmp.append((char) 29);
                            break;
                        }
                }
                idx++;
                if (idx >= count) {
                    char h = 0;
                    int len = tmp.length();
                    for (int i = 0; i < len; i++) {
                        boolean odd = i % 2 != 0;
                        if (odd) {
                            h = (char) ((h * 30) + tmp.charAt(i));
                            sb.append(h);
                        } else {
                            h = tmp.charAt(i);
                        }
                    }
                    int i2 = len % 2;
                    if (i2 != 0) {
                        sb.append((char) ((h * 30) + 29));
                    }
                    return submode;
                }
            }
        }
    }

    private static void encodeMultiECIBinary(ECIInput input, int startpos, int count, int startmode, StringBuilder sb) throws WriterException {
        int end = Math.min(startpos + count, input.length());
        int localStart = startpos;
        while (true) {
            if (localStart < end && input.isECI(localStart)) {
                encodingECI(input.getECIValue(localStart), sb);
                localStart++;
            } else {
                int localEnd = localStart;
                while (localEnd < end && !input.isECI(localEnd)) {
                    localEnd++;
                }
                int localCount = localEnd - localStart;
                if (localCount > 0) {
                    encodeBinary(subBytes(input, localStart, localEnd), 0, localCount, localStart == startpos ? startmode : 1, sb);
                    localStart = localEnd;
                } else {
                    return;
                }
            }
        }
    }

    static byte[] subBytes(ECIInput input, int start, int end) {
        int count = end - start;
        byte[] result = new byte[count];
        for (int i = start; i < end; i++) {
            result[i - start] = (byte) (input.charAt(i) & 255);
        }
        return result;
    }

    private static void encodeBinary(byte[] bytes, int startpos, int count, int startmode, StringBuilder sb) {
        if (count == 1 && startmode == 0) {
            sb.append((char) 913);
        } else if (count % 6 == 0) {
            sb.append((char) 924);
        } else {
            sb.append((char) 901);
        }
        int idx = startpos;
        if (count >= 6) {
            char[] chars = new char[5];
            while ((startpos + count) - idx >= 6) {
                long t = 0;
                for (int i = 0; i < 6; i++) {
                    t = (t << 8) + (bytes[idx + i] & UByte.MAX_VALUE);
                }
                for (int i2 = 0; i2 < 5; i2++) {
                    chars[i2] = (char) (t % 900);
                    t /= 900;
                }
                int i3 = chars.length;
                for (int i4 = i3 - 1; i4 >= 0; i4--) {
                    sb.append(chars[i4]);
                }
                idx += 6;
            }
        }
        for (int i5 = idx; i5 < startpos + count; i5++) {
            int ch = bytes[i5] & UByte.MAX_VALUE;
            sb.append((char) ch);
        }
    }

    private static void encodeNumeric(ECIInput input, int startpos, int count, StringBuilder sb) {
        int idx = 0;
        StringBuilder tmp = new StringBuilder((count / 3) + 1);
        BigInteger num900 = BigInteger.valueOf(900L);
        BigInteger num0 = BigInteger.valueOf(0L);
        while (idx < count) {
            tmp.setLength(0);
            int len = Math.min(44, count - idx);
            String part = "1" + ((Object) input.subSequence(startpos + idx, startpos + idx + len));
            BigInteger bigint = new BigInteger(part);
            do {
                tmp.append((char) bigint.mod(num900).intValue());
                bigint = bigint.divide(num900);
            } while (!bigint.equals(num0));
            for (int i = tmp.length() - 1; i >= 0; i--) {
                sb.append(tmp.charAt(i));
            }
            idx += len;
        }
    }

    private static boolean isDigit(char ch) {
        return ch >= '0' && ch <= '9';
    }

    private static boolean isAlphaUpper(char ch) {
        return ch == ' ' || (ch >= 'A' && ch <= 'Z');
    }

    private static boolean isAlphaLower(char ch) {
        return ch == ' ' || (ch >= 'a' && ch <= 'z');
    }

    private static boolean isMixed(char ch) {
        return MIXED[ch] != -1;
    }

    private static boolean isPunctuation(char ch) {
        return PUNCTUATION[ch] != -1;
    }

    private static boolean isText(char ch) {
        return ch == '\t' || ch == '\n' || ch == '\r' || (ch >= ' ' && ch <= '~');
    }

    private static int determineConsecutiveDigitCount(ECIInput input, int startpos) {
        int count = 0;
        int len = input.length();
        int idx = startpos;
        if (idx < len) {
            while (idx < len && !input.isECI(idx) && isDigit(input.charAt(idx))) {
                count++;
                idx++;
            }
        }
        return count;
    }

    /* JADX WARN: Code restructure failed: missing block: B:31:0x0028, code lost:
    
        return (r1 - r6) - r2;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    private static int determineConsecutiveTextCount(ECIInput input, int startpos) {
        int len = input.length();
        int idx = startpos;
        while (idx < len) {
            int numericCount = 0;
            while (numericCount < 13 && idx < len && !input.isECI(idx) && isDigit(input.charAt(idx))) {
                numericCount++;
                idx++;
            }
            if (numericCount <= 0) {
                if (input.isECI(idx) || !isText(input.charAt(idx))) {
                    break;
                }
                idx++;
            }
        }
        return idx - startpos;
    }

    /* JADX WARN: Code restructure failed: missing block: B:32:0x0030, code lost:
    
        return r2 - r10;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    private static int determineConsecutiveBinaryCount(ECIInput input, int startpos, Charset encoding) throws WriterException {
        CharsetEncoder encoder = encoding == null ? null : encoding.newEncoder();
        int len = input.length();
        int idx = startpos;
        while (idx < len) {
            int numericCount = 0;
            int i = idx;
            while (numericCount < 13 && !input.isECI(i) && isDigit(input.charAt(i)) && (i = idx + (numericCount = numericCount + 1)) < len) {
            }
            if (encoder != null && !encoder.canEncode(input.charAt(idx))) {
                if (!(input instanceof NoECIInput)) {
                    throw new AssertionError();
                }
                char ch = input.charAt(idx);
                throw new WriterException("Non-encodable character detected: " + ch + " (Unicode: " + ((int) ch) + ')');
            }
            idx++;
        }
        return idx - startpos;
    }

    private static void encodingECI(int eci, StringBuilder sb) throws WriterException {
        if (eci >= 0 && eci < LATCH_TO_TEXT) {
            sb.append((char) 927);
            sb.append((char) eci);
        } else if (eci < 810900) {
            sb.append((char) 926);
            sb.append((char) ((eci / LATCH_TO_TEXT) - 1));
            sb.append((char) (eci % LATCH_TO_TEXT));
        } else {
            if (eci < 811800) {
                sb.append((char) 925);
                sb.append((char) (810900 - eci));
                return;
            }
            throw new WriterException("ECI number not in valid range from 0..811799, but was " + eci);
        }
    }

    private static final class NoECIInput implements ECIInput {
        String input;

        /* synthetic */ NoECIInput(String x0, AnonymousClass1 x1) {
            this(x0);
        }

        private NoECIInput(String input) {
            this.input = input;
        }

        @Override // com.google.zxing.common.ECIInput
        public int length() {
            return this.input.length();
        }

        @Override // com.google.zxing.common.ECIInput
        public char charAt(int index) {
            return this.input.charAt(index);
        }

        @Override // com.google.zxing.common.ECIInput
        public boolean isECI(int index) {
            return false;
        }

        @Override // com.google.zxing.common.ECIInput
        public int getECIValue(int index) {
            return -1;
        }

        @Override // com.google.zxing.common.ECIInput
        public boolean haveNCharacters(int index, int n) {
            return index + n <= this.input.length();
        }

        @Override // com.google.zxing.common.ECIInput
        public CharSequence subSequence(int start, int end) {
            return this.input.subSequence(start, end);
        }

        public String toString() {
            return this.input;
        }
    }
}
