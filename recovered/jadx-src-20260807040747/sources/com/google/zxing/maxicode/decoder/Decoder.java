package com.google.zxing.maxicode.decoder;

import com.google.zxing.ChecksumException;
import com.google.zxing.DecodeHintType;
import com.google.zxing.FormatException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.DecoderResult;
import com.google.zxing.common.reedsolomon.GenericGF;
import com.google.zxing.common.reedsolomon.ReedSolomonDecoder;
import com.google.zxing.common.reedsolomon.ReedSolomonException;
import java.util.Map;
import kotlin.UByte;

/* loaded from: classes.dex */
public final class Decoder {
    private static final int ALL = 0;
    private static final int EVEN = 1;
    private static final int ODD = 2;
    private final ReedSolomonDecoder rsDecoder = new ReedSolomonDecoder(GenericGF.MAXICODE_FIELD_64);

    public DecoderResult decode(BitMatrix bits) throws ChecksumException, FormatException {
        return decode(bits, null);
    }

    public DecoderResult decode(BitMatrix bits, Map<DecodeHintType, ?> hints) throws FormatException, ChecksumException {
        int errorsCorrected;
        byte[] datawords;
        BitMatrixParser parser = new BitMatrixParser(bits);
        byte[] codewords = parser.readCodewords();
        int errorsCorrected2 = correctErrors(codewords, 0, 10, 10, 0);
        int mode = codewords[0] & 15;
        switch (mode) {
            case 2:
            case 3:
            case 4:
                errorsCorrected = errorsCorrected2 + correctErrors(codewords, 20, 84, 40, 1) + correctErrors(codewords, 20, 84, 40, 2);
                datawords = new byte[94];
                break;
            case 5:
                errorsCorrected = errorsCorrected2 + correctErrors(codewords, 20, 68, 56, 1) + correctErrors(codewords, 20, 68, 56, 2);
                datawords = new byte[78];
                break;
            default:
                throw FormatException.getFormatInstance();
        }
        System.arraycopy(codewords, 0, datawords, 0, 10);
        System.arraycopy(codewords, 20, datawords, 10, datawords.length - 10);
        DecoderResult result = DecodedBitStreamParser.decode(datawords, mode);
        result.setErrorsCorrected(Integer.valueOf(errorsCorrected));
        return result;
    }

    private int correctErrors(byte[] codewordBytes, int start, int dataCodewords, int ecCodewords, int mode) throws ChecksumException {
        int codewords = dataCodewords + ecCodewords;
        int divisor = mode == 0 ? 1 : 2;
        int[] codewordsInts = new int[codewords / divisor];
        for (int i = 0; i < codewords; i++) {
            if (mode == 0 || i % 2 == mode - 1) {
                codewordsInts[i / divisor] = codewordBytes[i + start] & UByte.MAX_VALUE;
            }
        }
        try {
            int errorsCorrected = this.rsDecoder.decodeWithECCount(codewordsInts, ecCodewords / divisor);
            for (int i2 = 0; i2 < dataCodewords; i2++) {
                if (mode == 0 || i2 % 2 == mode - 1) {
                    codewordBytes[i2 + start] = (byte) codewordsInts[i2 / divisor];
                }
            }
            return errorsCorrected;
        } catch (ReedSolomonException e) {
            throw ChecksumException.getChecksumInstance();
        }
    }
}
