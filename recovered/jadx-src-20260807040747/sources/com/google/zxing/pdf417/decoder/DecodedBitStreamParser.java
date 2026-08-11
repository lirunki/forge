package com.google.zxing.pdf417.decoder;

import androidx.core.view.MotionEventCompat;
import com.google.zxing.FormatException;
import com.google.zxing.common.DecoderResult;
import com.google.zxing.common.ECIStringBuilder;
import com.google.zxing.pdf417.PDF417ResultMetadata;
import java.math.BigInteger;
import java.util.Arrays;

/* loaded from: classes.dex */
final class DecodedBitStreamParser {
    private static final int AL = 28;
    private static final int AS = 27;
    private static final int BEGIN_MACRO_PDF417_CONTROL_BLOCK = 928;
    private static final int BEGIN_MACRO_PDF417_OPTIONAL_FIELD = 923;
    private static final int BYTE_COMPACTION_MODE_LATCH = 901;
    private static final int BYTE_COMPACTION_MODE_LATCH_6 = 924;
    private static final int ECI_CHARSET = 927;
    private static final int ECI_GENERAL_PURPOSE = 926;
    private static final int ECI_USER_DEFINED = 925;
    private static final BigInteger[] EXP900;
    private static final int LL = 27;
    private static final int MACRO_PDF417_OPTIONAL_FIELD_ADDRESSEE = 4;
    private static final int MACRO_PDF417_OPTIONAL_FIELD_CHECKSUM = 6;
    private static final int MACRO_PDF417_OPTIONAL_FIELD_FILE_NAME = 0;
    private static final int MACRO_PDF417_OPTIONAL_FIELD_FILE_SIZE = 5;
    private static final int MACRO_PDF417_OPTIONAL_FIELD_SEGMENT_COUNT = 1;
    private static final int MACRO_PDF417_OPTIONAL_FIELD_SENDER = 3;
    private static final int MACRO_PDF417_OPTIONAL_FIELD_TIME_STAMP = 2;
    private static final int MACRO_PDF417_TERMINATOR = 922;
    private static final int MAX_NUMERIC_CODEWORDS = 15;
    private static final int ML = 28;
    private static final int MODE_SHIFT_TO_BYTE_COMPACTION_MODE = 913;
    private static final int NUMBER_OF_SEQUENCE_CODEWORDS = 2;
    private static final int NUMERIC_COMPACTION_MODE_LATCH = 902;
    private static final int PAL = 29;
    private static final int PL = 25;
    private static final int PS = 29;
    private static final int TEXT_COMPACTION_MODE_LATCH = 900;
    private static final char[] PUNCT_CHARS = ";<>@[\\]_`~!\r\t,:\n-.$/\"|*()?{}'".toCharArray();
    private static final char[] MIXED_CHARS = "0123456789&\r\t,:#-.$/+%*=^".toCharArray();

    private enum Mode {
        ALPHA,
        LOWER,
        MIXED,
        PUNCT,
        ALPHA_SHIFT,
        PUNCT_SHIFT
    }

    static {
        BigInteger[] bigIntegerArr = new BigInteger[16];
        EXP900 = bigIntegerArr;
        bigIntegerArr[0] = BigInteger.ONE;
        BigInteger nineHundred = BigInteger.valueOf(900L);
        bigIntegerArr[1] = nineHundred;
        int i = 2;
        while (true) {
            BigInteger[] bigIntegerArr2 = EXP900;
            if (i < bigIntegerArr2.length) {
                bigIntegerArr2[i] = bigIntegerArr2[i - 1].multiply(nineHundred);
                i++;
            } else {
                return;
            }
        }
    }

    private DecodedBitStreamParser() {
    }

    static DecoderResult decode(int[] codewords, String ecLevel) throws FormatException {
        ECIStringBuilder result = new ECIStringBuilder(codewords.length * 2);
        int code = textCompaction(codewords, 1, result);
        PDF417ResultMetadata resultMetadata = new PDF417ResultMetadata();
        while (code < codewords[0]) {
            int codeIndex = code + 1;
            int code2 = codewords[code];
            switch (code2) {
                case TEXT_COMPACTION_MODE_LATCH /* 900 */:
                    code = textCompaction(codewords, codeIndex, result);
                    break;
                case BYTE_COMPACTION_MODE_LATCH /* 901 */:
                case BYTE_COMPACTION_MODE_LATCH_6 /* 924 */:
                    code = byteCompaction(code2, codewords, codeIndex, result);
                    break;
                case NUMERIC_COMPACTION_MODE_LATCH /* 902 */:
                    code = numericCompaction(codewords, codeIndex, result);
                    break;
                case MODE_SHIFT_TO_BYTE_COMPACTION_MODE /* 913 */:
                    result.append((char) codewords[codeIndex]);
                    code = codeIndex + 1;
                    break;
                case MACRO_PDF417_TERMINATOR /* 922 */:
                case BEGIN_MACRO_PDF417_OPTIONAL_FIELD /* 923 */:
                    throw FormatException.getFormatInstance();
                case ECI_USER_DEFINED /* 925 */:
                    code = codeIndex + 1;
                    break;
                case ECI_GENERAL_PURPOSE /* 926 */:
                    code = codeIndex + 2;
                    break;
                case ECI_CHARSET /* 927 */:
                    result.appendECI(codewords[codeIndex]);
                    code = codeIndex + 1;
                    break;
                case 928:
                    code = decodeMacroBlock(codewords, codeIndex, resultMetadata);
                    break;
                default:
                    code = textCompaction(codewords, codeIndex - 1, result);
                    break;
            }
        }
        if (result.isEmpty() && resultMetadata.getFileId() == null) {
            throw FormatException.getFormatInstance();
        }
        DecoderResult decoderResult = new DecoderResult(null, result.toString(), null, ecLevel);
        decoderResult.setOther(resultMetadata);
        return decoderResult;
    }

    static int decodeMacroBlock(int[] codewords, int codeIndex, PDF417ResultMetadata resultMetadata) throws FormatException {
        if (codeIndex + 2 > codewords[0]) {
            throw FormatException.getFormatInstance();
        }
        int[] segmentIndexArray = new int[2];
        int i = 0;
        while (i < 2) {
            segmentIndexArray[i] = codewords[codeIndex];
            i++;
            codeIndex++;
        }
        String segmentIndexString = decodeBase900toBase10(segmentIndexArray, 2);
        if (segmentIndexString.isEmpty()) {
            resultMetadata.setSegmentIndex(0);
        } else {
            try {
                resultMetadata.setSegmentIndex(Integer.parseInt(segmentIndexString));
            } catch (NumberFormatException e) {
                throw FormatException.getFormatInstance();
            }
        }
        StringBuilder fileId = new StringBuilder();
        while (codeIndex < codewords[0] && codeIndex < codewords.length && codewords[codeIndex] != MACRO_PDF417_TERMINATOR && codewords[codeIndex] != BEGIN_MACRO_PDF417_OPTIONAL_FIELD) {
            fileId.append(String.format("%03d", Integer.valueOf(codewords[codeIndex])));
            codeIndex++;
        }
        if (fileId.length() == 0) {
            throw FormatException.getFormatInstance();
        }
        resultMetadata.setFileId(fileId.toString());
        int optionalFieldsStart = -1;
        if (codewords[codeIndex] == BEGIN_MACRO_PDF417_OPTIONAL_FIELD) {
            optionalFieldsStart = codeIndex + 1;
        }
        while (codeIndex < codewords[0]) {
            switch (codewords[codeIndex]) {
                case MACRO_PDF417_TERMINATOR /* 922 */:
                    codeIndex++;
                    resultMetadata.setLastSegment(true);
                    break;
                case BEGIN_MACRO_PDF417_OPTIONAL_FIELD /* 923 */:
                    int codeIndex2 = codeIndex + 1;
                    switch (codewords[codeIndex2]) {
                        case 0:
                            ECIStringBuilder fileName = new ECIStringBuilder();
                            codeIndex = textCompaction(codewords, codeIndex2 + 1, fileName);
                            resultMetadata.setFileName(fileName.toString());
                            break;
                        case 1:
                            ECIStringBuilder segmentCount = new ECIStringBuilder();
                            codeIndex = numericCompaction(codewords, codeIndex2 + 1, segmentCount);
                            try {
                                resultMetadata.setSegmentCount(Integer.parseInt(segmentCount.toString()));
                                break;
                            } catch (NumberFormatException e2) {
                                throw FormatException.getFormatInstance();
                            }
                        case 2:
                            ECIStringBuilder timestamp = new ECIStringBuilder();
                            codeIndex = numericCompaction(codewords, codeIndex2 + 1, timestamp);
                            try {
                                resultMetadata.setTimestamp(Long.parseLong(timestamp.toString()));
                                break;
                            } catch (NumberFormatException e3) {
                                throw FormatException.getFormatInstance();
                            }
                        case 3:
                            ECIStringBuilder sender = new ECIStringBuilder();
                            codeIndex = textCompaction(codewords, codeIndex2 + 1, sender);
                            resultMetadata.setSender(sender.toString());
                            break;
                        case 4:
                            ECIStringBuilder addressee = new ECIStringBuilder();
                            codeIndex = textCompaction(codewords, codeIndex2 + 1, addressee);
                            resultMetadata.setAddressee(addressee.toString());
                            break;
                        case 5:
                            ECIStringBuilder fileSize = new ECIStringBuilder();
                            codeIndex = numericCompaction(codewords, codeIndex2 + 1, fileSize);
                            try {
                                resultMetadata.setFileSize(Long.parseLong(fileSize.toString()));
                                break;
                            } catch (NumberFormatException e4) {
                                throw FormatException.getFormatInstance();
                            }
                        case 6:
                            ECIStringBuilder checksum = new ECIStringBuilder();
                            codeIndex = numericCompaction(codewords, codeIndex2 + 1, checksum);
                            try {
                                resultMetadata.setChecksum(Integer.parseInt(checksum.toString()));
                                break;
                            } catch (NumberFormatException e5) {
                                throw FormatException.getFormatInstance();
                            }
                        default:
                            throw FormatException.getFormatInstance();
                    }
                default:
                    throw FormatException.getFormatInstance();
            }
        }
        if (optionalFieldsStart != -1) {
            int optionalFieldsLength = codeIndex - optionalFieldsStart;
            if (resultMetadata.isLastSegment()) {
                optionalFieldsLength--;
            }
            if (optionalFieldsLength > 0) {
                resultMetadata.setOptionalData(Arrays.copyOfRange(codewords, optionalFieldsStart, optionalFieldsStart + optionalFieldsLength));
            }
        }
        return codeIndex;
    }

    private static int textCompaction(int[] codewords, int code, ECIStringBuilder result) throws FormatException {
        int[] textCompactionData = new int[(codewords[0] - code) * 2];
        int[] byteCompactionData = new int[(codewords[0] - code) * 2];
        int index = 0;
        boolean end = false;
        Mode subMode = Mode.ALPHA;
        while (code < codewords[0] && !end) {
            int codeIndex = code + 1;
            int code2 = codewords[code];
            if (code2 >= TEXT_COMPACTION_MODE_LATCH) {
                switch (code2) {
                    case TEXT_COMPACTION_MODE_LATCH /* 900 */:
                        textCompactionData[index] = TEXT_COMPACTION_MODE_LATCH;
                        code = codeIndex;
                        index++;
                        break;
                    case BYTE_COMPACTION_MODE_LATCH /* 901 */:
                    case NUMERIC_COMPACTION_MODE_LATCH /* 902 */:
                    case MACRO_PDF417_TERMINATOR /* 922 */:
                    case BEGIN_MACRO_PDF417_OPTIONAL_FIELD /* 923 */:
                    case BYTE_COMPACTION_MODE_LATCH_6 /* 924 */:
                    case 928:
                        end = true;
                        code = codeIndex - 1;
                        break;
                    case MODE_SHIFT_TO_BYTE_COMPACTION_MODE /* 913 */:
                        textCompactionData[index] = MODE_SHIFT_TO_BYTE_COMPACTION_MODE;
                        byteCompactionData[index] = codewords[codeIndex];
                        index++;
                        code = codeIndex + 1;
                        break;
                    case ECI_CHARSET /* 927 */:
                        subMode = decodeTextCompaction(textCompactionData, byteCompactionData, index, result, subMode);
                        int codeIndex2 = codeIndex + 1;
                        result.appendECI(codewords[codeIndex]);
                        if (codeIndex2 > codewords[0]) {
                            throw FormatException.getFormatInstance();
                        }
                        textCompactionData = new int[(codewords[0] - codeIndex2) * 2];
                        byteCompactionData = new int[(codewords[0] - codeIndex2) * 2];
                        index = 0;
                        code = codeIndex2;
                        break;
                    default:
                        code = codeIndex;
                        break;
                }
            } else {
                textCompactionData[index] = code2 / 30;
                textCompactionData[index + 1] = code2 % 30;
                index += 2;
                code = codeIndex;
            }
        }
        decodeTextCompaction(textCompactionData, byteCompactionData, index, result, subMode);
        return code;
    }

    private static Mode decodeTextCompaction(int[] textCompactionData, int[] byteCompactionData, int length, ECIStringBuilder result, Mode startMode) {
        Mode subMode = startMode;
        Mode priorToShiftMode = startMode;
        Mode latchedMode = startMode;
        for (int i = 0; i < length; i++) {
            int subModeCh = textCompactionData[i];
            char ch = 0;
            switch (AnonymousClass1.$SwitchMap$com$google$zxing$pdf417$decoder$DecodedBitStreamParser$Mode[subMode.ordinal()]) {
                case 1:
                    if (subModeCh < 26) {
                        ch = (char) (subModeCh + 65);
                        break;
                    } else {
                        switch (subModeCh) {
                            case 26:
                                ch = ' ';
                                break;
                            case 27:
                                subMode = Mode.LOWER;
                                latchedMode = subMode;
                                break;
                            case MotionEventCompat.AXIS_RELATIVE_Y /* 28 */:
                                subMode = Mode.MIXED;
                                latchedMode = subMode;
                                break;
                            case 29:
                                priorToShiftMode = subMode;
                                subMode = Mode.PUNCT_SHIFT;
                                break;
                            case TEXT_COMPACTION_MODE_LATCH /* 900 */:
                                subMode = Mode.ALPHA;
                                latchedMode = subMode;
                                break;
                            case MODE_SHIFT_TO_BYTE_COMPACTION_MODE /* 913 */:
                                result.append((char) byteCompactionData[i]);
                                break;
                        }
                    }
                case 2:
                    if (subModeCh < 26) {
                        ch = (char) (subModeCh + 97);
                        break;
                    } else {
                        switch (subModeCh) {
                            case 26:
                                ch = ' ';
                                break;
                            case 27:
                                priorToShiftMode = subMode;
                                subMode = Mode.ALPHA_SHIFT;
                                break;
                            case MotionEventCompat.AXIS_RELATIVE_Y /* 28 */:
                                subMode = Mode.MIXED;
                                latchedMode = subMode;
                                break;
                            case 29:
                                priorToShiftMode = subMode;
                                subMode = Mode.PUNCT_SHIFT;
                                break;
                            case TEXT_COMPACTION_MODE_LATCH /* 900 */:
                                subMode = Mode.ALPHA;
                                latchedMode = subMode;
                                break;
                            case MODE_SHIFT_TO_BYTE_COMPACTION_MODE /* 913 */:
                                result.append((char) byteCompactionData[i]);
                                break;
                        }
                    }
                case 3:
                    if (subModeCh < 25) {
                        ch = MIXED_CHARS[subModeCh];
                        break;
                    } else {
                        switch (subModeCh) {
                            case 25:
                                subMode = Mode.PUNCT;
                                latchedMode = subMode;
                                break;
                            case 26:
                                ch = ' ';
                                break;
                            case 27:
                                subMode = Mode.LOWER;
                                latchedMode = subMode;
                                break;
                            case MotionEventCompat.AXIS_RELATIVE_Y /* 28 */:
                            case TEXT_COMPACTION_MODE_LATCH /* 900 */:
                                subMode = Mode.ALPHA;
                                latchedMode = subMode;
                                break;
                            case 29:
                                priorToShiftMode = subMode;
                                subMode = Mode.PUNCT_SHIFT;
                                break;
                            case MODE_SHIFT_TO_BYTE_COMPACTION_MODE /* 913 */:
                                result.append((char) byteCompactionData[i]);
                                break;
                        }
                    }
                case 4:
                    if (subModeCh < 29) {
                        ch = PUNCT_CHARS[subModeCh];
                        break;
                    } else {
                        switch (subModeCh) {
                            case 29:
                            case TEXT_COMPACTION_MODE_LATCH /* 900 */:
                                subMode = Mode.ALPHA;
                                latchedMode = subMode;
                                break;
                            case MODE_SHIFT_TO_BYTE_COMPACTION_MODE /* 913 */:
                                result.append((char) byteCompactionData[i]);
                                break;
                        }
                    }
                    break;
                case 5:
                    subMode = priorToShiftMode;
                    if (subModeCh < 26) {
                        ch = (char) (subModeCh + 65);
                        break;
                    } else {
                        switch (subModeCh) {
                            case 26:
                                ch = ' ';
                                break;
                            case TEXT_COMPACTION_MODE_LATCH /* 900 */:
                                subMode = Mode.ALPHA;
                                break;
                        }
                    }
                case 6:
                    subMode = priorToShiftMode;
                    if (subModeCh < 29) {
                        ch = PUNCT_CHARS[subModeCh];
                        break;
                    } else {
                        switch (subModeCh) {
                            case 29:
                            case TEXT_COMPACTION_MODE_LATCH /* 900 */:
                                subMode = Mode.ALPHA;
                                break;
                            case MODE_SHIFT_TO_BYTE_COMPACTION_MODE /* 913 */:
                                result.append((char) byteCompactionData[i]);
                                break;
                        }
                    }
                    break;
            }
            if (ch != 0) {
                result.append(ch);
            }
        }
        return latchedMode;
    }

    /* renamed from: com.google.zxing.pdf417.decoder.DecodedBitStreamParser$1, reason: invalid class name */
    static /* synthetic */ class AnonymousClass1 {
        static final /* synthetic */ int[] $SwitchMap$com$google$zxing$pdf417$decoder$DecodedBitStreamParser$Mode;

        static {
            int[] iArr = new int[Mode.values().length];
            $SwitchMap$com$google$zxing$pdf417$decoder$DecodedBitStreamParser$Mode = iArr;
            try {
                iArr[Mode.ALPHA.ordinal()] = 1;
            } catch (NoSuchFieldError e) {
            }
            try {
                $SwitchMap$com$google$zxing$pdf417$decoder$DecodedBitStreamParser$Mode[Mode.LOWER.ordinal()] = 2;
            } catch (NoSuchFieldError e2) {
            }
            try {
                $SwitchMap$com$google$zxing$pdf417$decoder$DecodedBitStreamParser$Mode[Mode.MIXED.ordinal()] = 3;
            } catch (NoSuchFieldError e3) {
            }
            try {
                $SwitchMap$com$google$zxing$pdf417$decoder$DecodedBitStreamParser$Mode[Mode.PUNCT.ordinal()] = 4;
            } catch (NoSuchFieldError e4) {
            }
            try {
                $SwitchMap$com$google$zxing$pdf417$decoder$DecodedBitStreamParser$Mode[Mode.ALPHA_SHIFT.ordinal()] = 5;
            } catch (NoSuchFieldError e5) {
            }
            try {
                $SwitchMap$com$google$zxing$pdf417$decoder$DecodedBitStreamParser$Mode[Mode.PUNCT_SHIFT.ordinal()] = 6;
            } catch (NoSuchFieldError e6) {
            }
        }
    }

    /* JADX WARN: Code restructure failed: missing block: B:31:0x004a, code lost:
    
        if (r12 == com.google.zxing.pdf417.decoder.DecodedBitStreamParser.BYTE_COMPACTION_MODE_LATCH_6) goto L59;
     */
    /* JADX WARN: Code restructure failed: missing block: B:33:0x004e, code lost:
    
        if (r9 >= r13[0]) goto L55;
     */
    /* JADX WARN: Code restructure failed: missing block: B:35:0x0052, code lost:
    
        if (r13[r9] >= com.google.zxing.pdf417.decoder.DecodedBitStreamParser.TEXT_COMPACTION_MODE_LATCH) goto L56;
     */
    /* JADX WARN: Code restructure failed: missing block: B:60:0x0054, code lost:
    
        r14 = 0;
     */
    /* JADX WARN: Code restructure failed: missing block: B:62:0x0056, code lost:
    
        if (r14 >= 6) goto L81;
     */
    /* JADX WARN: Code restructure failed: missing block: B:63:0x0058, code lost:
    
        r15.append((byte) (r5 >> ((5 - r14) * 8)));
        r14 = r14 + 1;
     */
    /* JADX WARN: Code restructure failed: missing block: B:65:0x0066, code lost:
    
        r14 = r9;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    private static int byteCompaction(int mode, int[] codewords, int codeIndex, ECIStringBuilder result) throws FormatException {
        int codeIndex2;
        boolean end = false;
        while (codeIndex < codewords[0] && !end) {
            while (codeIndex < codewords[0] && codewords[codeIndex] == ECI_CHARSET) {
                int codeIndex3 = codeIndex + 1;
                result.appendECI(codewords[codeIndex3]);
                codeIndex = codeIndex3 + 1;
            }
            if (codeIndex >= codewords[0] || codewords[codeIndex] >= TEXT_COMPACTION_MODE_LATCH) {
                end = true;
            } else {
                long value = 0;
                int count = 0;
                while (true) {
                    codeIndex2 = codeIndex + 1;
                    value = (900 * value) + codewords[codeIndex];
                    count++;
                    if (count >= 5 || codeIndex2 >= codewords[0] || codewords[codeIndex2] >= TEXT_COMPACTION_MODE_LATCH) {
                        break;
                    }
                    codeIndex = codeIndex2;
                }
                int codeIndex4 = codeIndex2 - count;
                while (codeIndex4 < codewords[0] && !end) {
                    int codeIndex5 = codeIndex4 + 1;
                    int code = codewords[codeIndex4];
                    if (code < TEXT_COMPACTION_MODE_LATCH) {
                        result.append((byte) code);
                        codeIndex4 = codeIndex5;
                    } else if (code == ECI_CHARSET) {
                        result.appendECI(codewords[codeIndex5]);
                        codeIndex4 = codeIndex5 + 1;
                    } else {
                        end = true;
                        codeIndex4 = codeIndex5 - 1;
                    }
                }
                codeIndex = codeIndex4;
            }
        }
        return codeIndex;
    }

    private static int numericCompaction(int[] codewords, int code, ECIStringBuilder result) throws FormatException {
        int count = 0;
        boolean end = false;
        int[] numericCodewords = new int[15];
        while (code < codewords[0] && !end) {
            int codeIndex = code + 1;
            int code2 = codewords[code];
            if (codeIndex == codewords[0]) {
                end = true;
            }
            if (code2 < TEXT_COMPACTION_MODE_LATCH) {
                numericCodewords[count] = code2;
                count++;
            } else {
                switch (code2) {
                    case TEXT_COMPACTION_MODE_LATCH /* 900 */:
                    case BYTE_COMPACTION_MODE_LATCH /* 901 */:
                    case MACRO_PDF417_TERMINATOR /* 922 */:
                    case BEGIN_MACRO_PDF417_OPTIONAL_FIELD /* 923 */:
                    case BYTE_COMPACTION_MODE_LATCH_6 /* 924 */:
                    case ECI_CHARSET /* 927 */:
                    case 928:
                        codeIndex--;
                        end = true;
                        break;
                }
            }
            if ((count % 15 == 0 || code2 == NUMERIC_COMPACTION_MODE_LATCH || end) && count > 0) {
                result.append(decodeBase900toBase10(numericCodewords, count));
                count = 0;
            }
            code = codeIndex;
        }
        return code;
    }

    private static String decodeBase900toBase10(int[] codewords, int count) throws FormatException {
        BigInteger result = BigInteger.ZERO;
        for (int i = 0; i < count; i++) {
            result = result.add(EXP900[(count - i) - 1].multiply(BigInteger.valueOf(codewords[i])));
        }
        String resultString = result.toString();
        if (resultString.charAt(0) != '1') {
            throw FormatException.getFormatInstance();
        }
        return resultString.substring(1);
    }
}
