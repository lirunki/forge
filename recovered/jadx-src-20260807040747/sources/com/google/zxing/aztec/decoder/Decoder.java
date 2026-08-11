package com.google.zxing.aztec.decoder;

import androidx.webkit.ProxyConfig;
import com.getcapacitor.Bridge;
import com.google.zxing.FormatException;
import com.google.zxing.aztec.AztecDetectorResult;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.CharacterSetECI;
import com.google.zxing.common.DecoderResult;
import com.google.zxing.common.reedsolomon.GenericGF;
import com.google.zxing.common.reedsolomon.ReedSolomonDecoder;
import com.google.zxing.common.reedsolomon.ReedSolomonException;
import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import kotlin.io.encoding.Base64;

/* loaded from: classes.dex */
public final class Decoder {
    private AztecDetectorResult ddata;
    private static final String[] UPPER_TABLE = {"CTRL_PS", " ", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "CTRL_LL", "CTRL_ML", "CTRL_DL", "CTRL_BS"};
    private static final String[] LOWER_TABLE = {"CTRL_PS", " ", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", Bridge.CAPACITOR_HTTP_INTERCEPTOR_URL_PARAM, "v", "w", "x", "y", "z", "CTRL_US", "CTRL_ML", "CTRL_DL", "CTRL_BS"};
    private static final String[] MIXED_TABLE = {"CTRL_PS", " ", "\u0001", "\u0002", "\u0003", "\u0004", "\u0005", "\u0006", "\u0007", "\b", "\t", "\n", "\u000b", "\f", "\r", "\u001b", "\u001c", "\u001d", "\u001e", "\u001f", "@", "\\", "^", "_", "`", "|", "~", "\u007f", "CTRL_LL", "CTRL_UL", "CTRL_PL", "CTRL_BS"};
    private static final String[] PUNCT_TABLE = {"FLG(n)", "\r", "\r\n", ". ", ", ", ": ", "!", "\"", "#", "$", "%", "&", "'", "(", ")", ProxyConfig.MATCH_ALL_SCHEMES, "+", ",", "-", ".", "/", ":", ";", "<", "=", ">", "?", "[", "]", "{", "}", "CTRL_UL"};
    private static final String[] DIGIT_TABLE = {"CTRL_PS", " ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ",", ".", "CTRL_UL", "CTRL_US"};
    private static final Charset DEFAULT_ENCODING = StandardCharsets.ISO_8859_1;

    private enum Table {
        UPPER,
        LOWER,
        MIXED,
        DIGIT,
        PUNCT,
        BINARY
    }

    public DecoderResult decode(AztecDetectorResult detectorResult) throws FormatException {
        this.ddata = detectorResult;
        BitMatrix matrix = detectorResult.getBits();
        boolean[] rawbits = extractBits(matrix);
        CorrectedBitsResult correctedBits = correctBits(rawbits);
        byte[] rawBytes = convertBoolArrayToByteArray(correctedBits.correctBits);
        String result = getEncodedData(correctedBits.correctBits);
        DecoderResult decoderResult = new DecoderResult(rawBytes, result, null, String.format("%d%%", Integer.valueOf(correctedBits.ecLevel)));
        decoderResult.setNumBits(correctedBits.correctBits.length);
        decoderResult.setErrorsCorrected(Integer.valueOf(correctedBits.errorsCorrected));
        return decoderResult;
    }

    public static String highLevelDecode(boolean[] correctedBits) throws FormatException {
        return getEncodedData(correctedBits);
    }

    private static String getEncodedData(boolean[] correctedBits) throws FormatException {
        int endIndex = correctedBits.length;
        Table latchTable = Table.UPPER;
        Table shiftTable = Table.UPPER;
        int i = 5;
        StringBuilder result = new StringBuilder((correctedBits.length - 5) / 4);
        ByteArrayOutputStream decodedBytes = new ByteArrayOutputStream();
        Charset encoding = DEFAULT_ENCODING;
        Table latchTable2 = latchTable;
        int index = 0;
        Charset encoding2 = encoding;
        Table shiftTable2 = shiftTable;
        try {
            while (index < endIndex) {
                if (shiftTable2 == Table.BINARY) {
                    if (endIndex - index >= i) {
                        int length = readCode(correctedBits, index, i);
                        index += 5;
                        if (length == 0) {
                            if (endIndex - index >= 11) {
                                length = readCode(correctedBits, index, 11) + 31;
                                index += 11;
                            }
                        }
                        int charCount = 0;
                        while (true) {
                            if (charCount < length) {
                                if (endIndex - index < 8) {
                                    index = endIndex;
                                } else {
                                    int code = readCode(correctedBits, index, 8);
                                    decodedBytes.write((byte) code);
                                    index += 8;
                                    charCount++;
                                }
                            }
                        }
                        shiftTable2 = latchTable2;
                    }
                } else {
                    int size = shiftTable2 == Table.DIGIT ? 4 : 5;
                    if (endIndex - index >= size) {
                        int code2 = readCode(correctedBits, index, size);
                        index += size;
                        String str = getCharacter(shiftTable2, code2);
                        if ("FLG(n)".equals(str)) {
                            if (endIndex - index >= 3) {
                                int n = readCode(correctedBits, index, 3);
                                int index2 = index + 3;
                                try {
                                    result.append(decodedBytes.toString(encoding2.name()));
                                    decodedBytes.reset();
                                    switch (n) {
                                        case 0:
                                            result.append((char) 29);
                                            break;
                                        case 7:
                                            throw FormatException.getFormatInstance();
                                        default:
                                            int eci = 0;
                                            if (endIndex - index2 >= n * 4) {
                                                while (true) {
                                                    int n2 = n - 1;
                                                    if (n > 0) {
                                                        int nextDigit = readCode(correctedBits, index2, 4);
                                                        index2 += 4;
                                                        if (nextDigit >= 2 && nextDigit <= 11) {
                                                            eci = (eci * 10) + (nextDigit - 2);
                                                            n = n2;
                                                        }
                                                    } else {
                                                        CharacterSetECI charsetECI = CharacterSetECI.getCharacterSetECIByValue(eci);
                                                        if (charsetECI == null) {
                                                            throw FormatException.getFormatInstance();
                                                        }
                                                        encoding2 = charsetECI.getCharset();
                                                        break;
                                                    }
                                                }
                                                throw FormatException.getFormatInstance();
                                            }
                                            break;
                                    }
                                    Table shiftTable3 = latchTable2;
                                    shiftTable2 = shiftTable3;
                                    index = index2;
                                    i = 5;
                                } catch (UnsupportedEncodingException uee) {
                                    throw new IllegalStateException(uee);
                                }
                            }
                        } else if (str.startsWith("CTRL_")) {
                            latchTable2 = shiftTable2;
                            i = 5;
                            shiftTable2 = getTable(str.charAt(5));
                            if (str.charAt(6) == 'L') {
                                latchTable2 = shiftTable2;
                            }
                        } else {
                            i = 5;
                            byte[] b = str.getBytes(StandardCharsets.US_ASCII);
                            decodedBytes.write(b, 0, b.length);
                            shiftTable2 = latchTable2;
                        }
                    }
                }
                result.append(decodedBytes.toString(encoding2.name()));
                return result.toString();
            }
            result.append(decodedBytes.toString(encoding2.name()));
            return result.toString();
        } catch (UnsupportedEncodingException uee2) {
            throw new IllegalStateException(uee2);
        }
    }

    private static Table getTable(char t) {
        switch (t) {
            case 'B':
                return Table.BINARY;
            case 'D':
                return Table.DIGIT;
            case Base64.mimeLineLength /* 76 */:
                return Table.LOWER;
            case 'M':
                return Table.MIXED;
            case 'P':
                return Table.PUNCT;
            default:
                return Table.UPPER;
        }
    }

    /* renamed from: com.google.zxing.aztec.decoder.Decoder$1, reason: invalid class name */
    static /* synthetic */ class AnonymousClass1 {
        static final /* synthetic */ int[] $SwitchMap$com$google$zxing$aztec$decoder$Decoder$Table;

        static {
            int[] iArr = new int[Table.values().length];
            $SwitchMap$com$google$zxing$aztec$decoder$Decoder$Table = iArr;
            try {
                iArr[Table.UPPER.ordinal()] = 1;
            } catch (NoSuchFieldError e) {
            }
            try {
                $SwitchMap$com$google$zxing$aztec$decoder$Decoder$Table[Table.LOWER.ordinal()] = 2;
            } catch (NoSuchFieldError e2) {
            }
            try {
                $SwitchMap$com$google$zxing$aztec$decoder$Decoder$Table[Table.MIXED.ordinal()] = 3;
            } catch (NoSuchFieldError e3) {
            }
            try {
                $SwitchMap$com$google$zxing$aztec$decoder$Decoder$Table[Table.PUNCT.ordinal()] = 4;
            } catch (NoSuchFieldError e4) {
            }
            try {
                $SwitchMap$com$google$zxing$aztec$decoder$Decoder$Table[Table.DIGIT.ordinal()] = 5;
            } catch (NoSuchFieldError e5) {
            }
        }
    }

    private static String getCharacter(Table table, int code) {
        switch (AnonymousClass1.$SwitchMap$com$google$zxing$aztec$decoder$Decoder$Table[table.ordinal()]) {
            case 1:
                return UPPER_TABLE[code];
            case 2:
                return LOWER_TABLE[code];
            case 3:
                return MIXED_TABLE[code];
            case 4:
                return PUNCT_TABLE[code];
            case 5:
                return DIGIT_TABLE[code];
            default:
                throw new IllegalStateException("Bad table");
        }
    }

    static final class CorrectedBitsResult {
        private final boolean[] correctBits;
        private final int ecLevel;
        private final int errorsCorrected;

        CorrectedBitsResult(boolean[] correctBits, int errorsCorrected, int ecLevel) {
            this.correctBits = correctBits;
            this.errorsCorrected = errorsCorrected;
            this.ecLevel = ecLevel;
        }
    }

    private CorrectedBitsResult correctBits(boolean[] rawbits) throws FormatException {
        GenericGF gf;
        int codewordSize;
        if (this.ddata.getNbLayers() <= 2) {
            gf = GenericGF.AZTEC_DATA_6;
            codewordSize = 6;
        } else if (this.ddata.getNbLayers() <= 8) {
            gf = GenericGF.AZTEC_DATA_8;
            codewordSize = 8;
        } else if (this.ddata.getNbLayers() <= 22) {
            gf = GenericGF.AZTEC_DATA_10;
            codewordSize = 10;
        } else {
            gf = GenericGF.AZTEC_DATA_12;
            codewordSize = 12;
        }
        int numDataCodewords = this.ddata.getNbDatablocks();
        int numCodewords = rawbits.length / codewordSize;
        if (numCodewords < numDataCodewords) {
            throw FormatException.getFormatInstance();
        }
        int offset = rawbits.length % codewordSize;
        int[] dataWords = new int[numCodewords];
        int offset2 = offset;
        int offset3 = 0;
        while (offset3 < numCodewords) {
            dataWords[offset3] = readCode(rawbits, offset2, codewordSize);
            offset3++;
            offset2 += codewordSize;
        }
        try {
            ReedSolomonDecoder rsDecoder = new ReedSolomonDecoder(gf);
            int errorsCorrected = rsDecoder.decodeWithECCount(dataWords, numCodewords - numDataCodewords);
            int i = 1;
            int mask = (1 << codewordSize) - 1;
            int stuffedBits = 0;
            for (int i2 = 0; i2 < numDataCodewords; i2++) {
                int dataWord = dataWords[i2];
                if (dataWord == 0 || dataWord == mask) {
                    throw FormatException.getFormatInstance();
                }
                if (dataWord == 1 || dataWord == mask - 1) {
                    stuffedBits++;
                }
            }
            int i3 = numDataCodewords * codewordSize;
            boolean[] correctedBits = new boolean[i3 - stuffedBits];
            int index = 0;
            int i4 = 0;
            while (i4 < numDataCodewords) {
                int dataWord2 = dataWords[i4];
                if (dataWord2 == i || dataWord2 == mask - 1) {
                    int bit = index + codewordSize;
                    Arrays.fill(correctedBits, index, bit - 1, dataWord2 > 1);
                    index += codewordSize - 1;
                } else {
                    int bit2 = codewordSize - 1;
                    while (bit2 >= 0) {
                        int index2 = index + 1;
                        correctedBits[index] = (dataWord2 & (1 << bit2)) != 0;
                        bit2--;
                        index = index2;
                    }
                }
                i4++;
                i = 1;
            }
            int ecLevel = ((numCodewords - numDataCodewords) * 100) / numCodewords;
            return new CorrectedBitsResult(correctedBits, errorsCorrected, ecLevel);
        } catch (ReedSolomonException ex) {
            throw FormatException.getFormatInstance(ex);
        }
    }

    private boolean[] extractBits(BitMatrix matrix) {
        boolean compact = this.ddata.isCompact();
        int layers = this.ddata.getNbLayers();
        int baseMatrixSize = (compact ? 11 : 14) + (layers * 4);
        int[] alignmentMap = new int[baseMatrixSize];
        boolean[] rawbits = new boolean[totalBitsInLayer(layers, compact)];
        int i = 2;
        if (compact) {
            for (int i2 = 0; i2 < alignmentMap.length; i2++) {
                alignmentMap[i2] = i2;
            }
        } else {
            int matrixSize = baseMatrixSize + 1 + ((((baseMatrixSize / 2) - 1) / 15) * 2);
            int origCenter = baseMatrixSize / 2;
            int center = matrixSize / 2;
            for (int i3 = 0; i3 < origCenter; i3++) {
                int newOffset = (i3 / 15) + i3;
                alignmentMap[(origCenter - i3) - 1] = (center - newOffset) - 1;
                alignmentMap[origCenter + i3] = center + newOffset + 1;
            }
        }
        int i4 = 0;
        int rowOffset = 0;
        while (i4 < layers) {
            int rowSize = ((layers - i4) * 4) + (compact ? 9 : 12);
            int low = i4 * 2;
            int high = (baseMatrixSize - 1) - low;
            int j = 0;
            while (j < rowSize) {
                int columnOffset = j * 2;
                int k = 0;
                while (k < i) {
                    rawbits[rowOffset + columnOffset + k] = matrix.get(alignmentMap[low + k], alignmentMap[low + j]);
                    rawbits[(rowSize * 2) + rowOffset + columnOffset + k] = matrix.get(alignmentMap[low + j], alignmentMap[high - k]);
                    rawbits[(rowSize * 4) + rowOffset + columnOffset + k] = matrix.get(alignmentMap[high - k], alignmentMap[high - j]);
                    rawbits[(rowSize * 6) + rowOffset + columnOffset + k] = matrix.get(alignmentMap[high - j], alignmentMap[low + k]);
                    k++;
                    i = 2;
                    compact = compact;
                }
                j++;
                i = 2;
            }
            rowOffset += rowSize * 8;
            i4++;
            i = 2;
        }
        return rawbits;
    }

    private static int readCode(boolean[] rawbits, int startIndex, int length) {
        int res = 0;
        for (int i = startIndex; i < startIndex + length; i++) {
            res <<= 1;
            if (rawbits[i]) {
                res |= 1;
            }
        }
        return res;
    }

    private static byte readByte(boolean[] rawbits, int startIndex) {
        int n = rawbits.length - startIndex;
        if (n >= 8) {
            return (byte) readCode(rawbits, startIndex, 8);
        }
        return (byte) (readCode(rawbits, startIndex, n) << (8 - n));
    }

    static byte[] convertBoolArrayToByteArray(boolean[] boolArr) {
        byte[] byteArr = new byte[(boolArr.length + 7) / 8];
        for (int i = 0; i < byteArr.length; i++) {
            byteArr[i] = readByte(boolArr, i * 8);
        }
        return byteArr;
    }

    private static int totalBitsInLayer(int layers, boolean compact) {
        return ((compact ? 88 : 112) + (layers * 16)) * layers;
    }
}
