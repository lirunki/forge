package com.google.zxing.aztec.encoder;

import com.google.zxing.common.BitArray;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.reedsolomon.GenericGF;
import com.google.zxing.common.reedsolomon.ReedSolomonEncoder;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

/* loaded from: classes.dex */
public final class Encoder {
    public static final int DEFAULT_AZTEC_LAYERS = 0;
    public static final int DEFAULT_EC_PERCENT = 33;
    private static final int MAX_NB_BITS = 32;
    private static final int MAX_NB_BITS_COMPACT = 4;
    private static final int[] WORD_SIZE = {4, 6, 6, 8, 8, 8, 8, 8, 8, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12};

    private Encoder() {
    }

    public static AztecCode encode(String data) {
        return encode(data.getBytes(StandardCharsets.ISO_8859_1));
    }

    public static AztecCode encode(String data, int minECCPercent, int userSpecifiedLayers) {
        return encode(data.getBytes(StandardCharsets.ISO_8859_1), minECCPercent, userSpecifiedLayers, (Charset) null);
    }

    public static AztecCode encode(String data, int minECCPercent, int userSpecifiedLayers, Charset charset) {
        byte[] bytes = data.getBytes(charset != null ? charset : StandardCharsets.ISO_8859_1);
        return encode(bytes, minECCPercent, userSpecifiedLayers, charset);
    }

    public static AztecCode encode(byte[] data) {
        return encode(data, 33, 0, (Charset) null);
    }

    public static AztecCode encode(byte[] data, int minECCPercent, int userSpecifiedLayers) {
        return encode(data, minECCPercent, userSpecifiedLayers, (Charset) null);
    }

    public static AztecCode encode(byte[] data, int minECCPercent, int userSpecifiedLayers, Charset charset) {
        int wordSize;
        int layers;
        int totalBitsInLayer;
        BitArray stuffedBits;
        boolean compact;
        int origCenter;
        int totalBitsInLayer2;
        int wordSize2;
        BitArray bits = new HighLevelEncoder(data, charset).encode();
        int eccBits = ((bits.getSize() * minECCPercent) / 100) + 11;
        int totalSizeBits = bits.getSize() + eccBits;
        if (userSpecifiedLayers != 0) {
            compact = userSpecifiedLayers < 0;
            layers = Math.abs(userSpecifiedLayers);
            if (layers > (compact ? 4 : 32)) {
                throw new IllegalArgumentException(String.format("Illegal value %s for layers", Integer.valueOf(userSpecifiedLayers)));
            }
            totalBitsInLayer = totalBitsInLayer(layers, compact);
            wordSize = WORD_SIZE[layers];
            int usableBitsInLayers = totalBitsInLayer - (totalBitsInLayer % wordSize);
            stuffedBits = stuffBits(bits, wordSize);
            if (stuffedBits.getSize() + eccBits > usableBitsInLayers) {
                throw new IllegalArgumentException("Data to large for user specified layer");
            }
            if (compact && stuffedBits.getSize() > wordSize * 64) {
                throw new IllegalArgumentException("Data to large for user specified layer");
            }
        } else {
            int wordSize3 = 0;
            BitArray stuffedBits2 = null;
            int i = 0;
            while (i <= r6) {
                boolean compact2 = i <= 3;
                int layers2 = compact2 ? i + 1 : i;
                int totalBitsInLayer3 = totalBitsInLayer(layers2, compact2);
                if (totalSizeBits <= totalBitsInLayer3) {
                    if (stuffedBits2 == null || wordSize3 != WORD_SIZE[layers2]) {
                        wordSize3 = WORD_SIZE[layers2];
                        stuffedBits2 = stuffBits(bits, wordSize3);
                    }
                    int usableBitsInLayers2 = totalBitsInLayer3 - (totalBitsInLayer3 % wordSize3);
                    if ((!compact2 || stuffedBits2.getSize() <= wordSize3 * 64) && stuffedBits2.getSize() + eccBits <= usableBitsInLayers2) {
                        wordSize = wordSize3;
                        layers = layers2;
                        totalBitsInLayer = totalBitsInLayer3;
                        stuffedBits = stuffedBits2;
                        compact = compact2;
                    }
                }
                i++;
                bits = bits;
                eccBits = eccBits;
                totalSizeBits = totalSizeBits;
                r6 = 32;
            }
            throw new IllegalArgumentException("Data too large for an Aztec code");
        }
        BitArray messageBits = generateCheckWords(stuffedBits, totalBitsInLayer, wordSize);
        int messageSizeInWords = stuffedBits.getSize() / wordSize;
        BitArray modeMessage = generateModeMessage(compact, layers, messageSizeInWords);
        int baseMatrixSize = (compact ? 11 : 14) + (layers * 4);
        int[] alignmentMap = new int[baseMatrixSize];
        if (compact) {
            int i2 = 0;
            while (true) {
                BitArray bits2 = bits;
                if (i2 >= alignmentMap.length) {
                    break;
                }
                alignmentMap[i2] = i2;
                i2++;
                bits = bits2;
            }
            origCenter = baseMatrixSize;
        } else {
            int matrixSize = baseMatrixSize + 1 + ((((baseMatrixSize / 2) - 1) / 15) * 2);
            int origCenter2 = baseMatrixSize / 2;
            int center = matrixSize / 2;
            for (int i3 = 0; i3 < origCenter2; i3++) {
                int newOffset = i3 + (i3 / 15);
                alignmentMap[(origCenter2 - i3) - 1] = (center - newOffset) - 1;
                alignmentMap[origCenter2 + i3] = center + newOffset + 1;
            }
            origCenter = matrixSize;
        }
        BitMatrix matrix = new BitMatrix(origCenter);
        int i4 = 0;
        int rowOffset = 0;
        while (i4 < layers) {
            int rowSize = ((layers - i4) * 4) + (compact ? 9 : 12);
            int eccBits2 = eccBits;
            int eccBits3 = 0;
            while (eccBits3 < rowSize) {
                int columnOffset = eccBits3 * 2;
                int totalSizeBits2 = totalSizeBits;
                int totalSizeBits3 = 0;
                while (true) {
                    totalBitsInLayer2 = totalBitsInLayer;
                    if (totalSizeBits3 < 2) {
                        if (!messageBits.get(rowOffset + columnOffset + totalSizeBits3)) {
                            wordSize2 = wordSize;
                        } else {
                            int i5 = alignmentMap[(i4 * 2) + totalSizeBits3];
                            wordSize2 = wordSize;
                            int wordSize4 = alignmentMap[(i4 * 2) + eccBits3];
                            matrix.set(i5, wordSize4);
                        }
                        if (messageBits.get(rowOffset + (rowSize * 2) + columnOffset + totalSizeBits3)) {
                            matrix.set(alignmentMap[(i4 * 2) + eccBits3], alignmentMap[((baseMatrixSize - 1) - (i4 * 2)) - totalSizeBits3]);
                        }
                        if (messageBits.get(rowOffset + (rowSize * 4) + columnOffset + totalSizeBits3)) {
                            matrix.set(alignmentMap[((baseMatrixSize - 1) - (i4 * 2)) - totalSizeBits3], alignmentMap[((baseMatrixSize - 1) - (i4 * 2)) - eccBits3]);
                        }
                        if (messageBits.get(rowOffset + (rowSize * 6) + columnOffset + totalSizeBits3)) {
                            matrix.set(alignmentMap[((baseMatrixSize - 1) - (i4 * 2)) - eccBits3], alignmentMap[(i4 * 2) + totalSizeBits3]);
                        }
                        totalSizeBits3++;
                        totalBitsInLayer = totalBitsInLayer2;
                        wordSize = wordSize2;
                    }
                }
                eccBits3++;
                totalBitsInLayer = totalBitsInLayer2;
                totalSizeBits = totalSizeBits2;
            }
            int j = rowSize * 8;
            rowOffset += j;
            i4++;
            eccBits = eccBits2;
        }
        drawModeMessage(matrix, compact, origCenter, modeMessage);
        if (compact) {
            drawBullsEye(matrix, origCenter / 2, 5);
        } else {
            drawBullsEye(matrix, origCenter / 2, 7);
            int i6 = 0;
            int j2 = 0;
            while (i6 < (baseMatrixSize / 2) - 1) {
                for (int k = (origCenter / 2) & 1; k < origCenter; k += 2) {
                    matrix.set((origCenter / 2) - j2, k);
                    matrix.set((origCenter / 2) + j2, k);
                    matrix.set(k, (origCenter / 2) - j2);
                    matrix.set(k, (origCenter / 2) + j2);
                }
                i6 += 15;
                j2 += 16;
            }
        }
        AztecCode aztec = new AztecCode();
        aztec.setCompact(compact);
        aztec.setSize(origCenter);
        aztec.setLayers(layers);
        aztec.setCodeWords(messageSizeInWords);
        aztec.setMatrix(matrix);
        return aztec;
    }

    private static void drawBullsEye(BitMatrix matrix, int center, int size) {
        for (int i = 0; i < size; i += 2) {
            for (int j = center - i; j <= center + i; j++) {
                matrix.set(j, center - i);
                matrix.set(j, center + i);
                matrix.set(center - i, j);
                matrix.set(center + i, j);
            }
        }
        int i2 = center - size;
        matrix.set(i2, center - size);
        matrix.set((center - size) + 1, center - size);
        matrix.set(center - size, (center - size) + 1);
        matrix.set(center + size, center - size);
        matrix.set(center + size, (center - size) + 1);
        matrix.set(center + size, (center + size) - 1);
    }

    static BitArray generateModeMessage(boolean compact, int layers, int messageSizeInWords) {
        BitArray modeMessage = new BitArray();
        if (compact) {
            modeMessage.appendBits(layers - 1, 2);
            modeMessage.appendBits(messageSizeInWords - 1, 6);
            return generateCheckWords(modeMessage, 28, 4);
        }
        modeMessage.appendBits(layers - 1, 5);
        modeMessage.appendBits(messageSizeInWords - 1, 11);
        return generateCheckWords(modeMessage, 40, 4);
    }

    private static void drawModeMessage(BitMatrix matrix, boolean compact, int matrixSize, BitArray modeMessage) {
        int center = matrixSize / 2;
        if (compact) {
            for (int i = 0; i < 7; i++) {
                int offset = (center - 3) + i;
                if (modeMessage.get(i)) {
                    matrix.set(offset, center - 5);
                }
                if (modeMessage.get(i + 7)) {
                    matrix.set(center + 5, offset);
                }
                if (modeMessage.get(20 - i)) {
                    matrix.set(offset, center + 5);
                }
                if (modeMessage.get(27 - i)) {
                    matrix.set(center - 5, offset);
                }
            }
            return;
        }
        for (int i2 = 0; i2 < 10; i2++) {
            int offset2 = (center - 5) + i2 + (i2 / 5);
            if (modeMessage.get(i2)) {
                matrix.set(offset2, center - 7);
            }
            if (modeMessage.get(i2 + 10)) {
                matrix.set(center + 7, offset2);
            }
            if (modeMessage.get(29 - i2)) {
                matrix.set(offset2, center + 7);
            }
            if (modeMessage.get(39 - i2)) {
                matrix.set(center - 7, offset2);
            }
        }
    }

    private static BitArray generateCheckWords(BitArray bitArray, int totalBits, int wordSize) {
        int messageSizeInWords = bitArray.getSize() / wordSize;
        ReedSolomonEncoder rs = new ReedSolomonEncoder(getGF(wordSize));
        int totalWords = totalBits / wordSize;
        int[] messageWords = bitsToWords(bitArray, wordSize, totalWords);
        rs.encode(messageWords, totalWords - messageSizeInWords);
        int startPad = totalBits % wordSize;
        BitArray messageBits = new BitArray();
        messageBits.appendBits(0, startPad);
        for (int messageWord : messageWords) {
            messageBits.appendBits(messageWord, wordSize);
        }
        return messageBits;
    }

    private static int[] bitsToWords(BitArray stuffedBits, int wordSize, int totalWords) {
        int[] message = new int[totalWords];
        int n = stuffedBits.getSize() / wordSize;
        for (int i = 0; i < n; i++) {
            int value = 0;
            for (int j = 0; j < wordSize; j++) {
                value |= stuffedBits.get((i * wordSize) + j) ? 1 << ((wordSize - j) - 1) : 0;
            }
            message[i] = value;
        }
        return message;
    }

    private static GenericGF getGF(int wordSize) {
        switch (wordSize) {
            case 4:
                return GenericGF.AZTEC_PARAM;
            case 5:
            case 7:
            case 9:
            case 11:
            default:
                throw new IllegalArgumentException("Unsupported word size " + wordSize);
            case 6:
                return GenericGF.AZTEC_DATA_6;
            case 8:
                return GenericGF.AZTEC_DATA_8;
            case 10:
                return GenericGF.AZTEC_DATA_10;
            case 12:
                return GenericGF.AZTEC_DATA_12;
        }
    }

    static BitArray stuffBits(BitArray bits, int wordSize) {
        BitArray out = new BitArray();
        int n = bits.getSize();
        int mask = (1 << wordSize) - 2;
        int i = 0;
        while (i < n) {
            int word = 0;
            for (int j = 0; j < wordSize; j++) {
                if (i + j >= n || bits.get(i + j)) {
                    word |= 1 << ((wordSize - 1) - j);
                }
            }
            int j2 = word & mask;
            if (j2 == mask) {
                out.appendBits(word & mask, wordSize);
                i--;
            } else if ((word & mask) == 0) {
                out.appendBits(word | 1, wordSize);
                i--;
            } else {
                out.appendBits(word, wordSize);
            }
            i += wordSize;
        }
        return out;
    }

    private static int totalBitsInLayer(int layers, boolean compact) {
        return ((compact ? 88 : 112) + (layers * 16)) * layers;
    }
}
