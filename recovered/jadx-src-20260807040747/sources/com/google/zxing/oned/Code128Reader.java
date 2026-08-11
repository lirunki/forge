package com.google.zxing.oned;

import androidx.core.location.LocationRequestCompat;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.ChecksumException;
import com.google.zxing.DecodeHintType;
import com.google.zxing.FormatException;
import com.google.zxing.NotFoundException;
import com.google.zxing.Result;
import com.google.zxing.ResultMetadataType;
import com.google.zxing.ResultPoint;
import com.google.zxing.common.BitArray;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/* loaded from: classes.dex */
public final class Code128Reader extends OneDReader {
    private static final int CODE_CODE_A = 101;
    private static final int CODE_CODE_B = 100;
    private static final int CODE_CODE_C = 99;
    private static final int CODE_FNC_1 = 102;
    private static final int CODE_FNC_2 = 97;
    private static final int CODE_FNC_3 = 96;
    private static final int CODE_FNC_4_A = 101;
    private static final int CODE_FNC_4_B = 100;
    static final int[][] CODE_PATTERNS = {new int[]{2, 1, 2, 2, 2, 2}, new int[]{2, 2, 2, 1, 2, 2}, new int[]{2, 2, 2, 2, 2, 1}, new int[]{1, 2, 1, 2, 2, 3}, new int[]{1, 2, 1, 3, 2, 2}, new int[]{1, 3, 1, 2, 2, 2}, new int[]{1, 2, 2, 2, 1, 3}, new int[]{1, 2, 2, 3, 1, 2}, new int[]{1, 3, 2, 2, 1, 2}, new int[]{2, 2, 1, 2, 1, 3}, new int[]{2, 2, 1, 3, 1, 2}, new int[]{2, 3, 1, 2, 1, 2}, new int[]{1, 1, 2, 2, 3, 2}, new int[]{1, 2, 2, 1, 3, 2}, new int[]{1, 2, 2, 2, 3, 1}, new int[]{1, 1, 3, 2, 2, 2}, new int[]{1, 2, 3, 1, 2, 2}, new int[]{1, 2, 3, 2, 2, 1}, new int[]{2, 2, 3, 2, 1, 1}, new int[]{2, 2, 1, 1, 3, 2}, new int[]{2, 2, 1, 2, 3, 1}, new int[]{2, 1, 3, 2, 1, 2}, new int[]{2, 2, 3, 1, 1, 2}, new int[]{3, 1, 2, 1, 3, 1}, new int[]{3, 1, 1, 2, 2, 2}, new int[]{3, 2, 1, 1, 2, 2}, new int[]{3, 2, 1, 2, 2, 1}, new int[]{3, 1, 2, 2, 1, 2}, new int[]{3, 2, 2, 1, 1, 2}, new int[]{3, 2, 2, 2, 1, 1}, new int[]{2, 1, 2, 1, 2, 3}, new int[]{2, 1, 2, 3, 2, 1}, new int[]{2, 3, 2, 1, 2, 1}, new int[]{1, 1, 1, 3, 2, 3}, new int[]{1, 3, 1, 1, 2, 3}, new int[]{1, 3, 1, 3, 2, 1}, new int[]{1, 1, 2, 3, 1, 3}, new int[]{1, 3, 2, 1, 1, 3}, new int[]{1, 3, 2, 3, 1, 1}, new int[]{2, 1, 1, 3, 1, 3}, new int[]{2, 3, 1, 1, 1, 3}, new int[]{2, 3, 1, 3, 1, 1}, new int[]{1, 1, 2, 1, 3, 3}, new int[]{1, 1, 2, 3, 3, 1}, new int[]{1, 3, 2, 1, 3, 1}, new int[]{1, 1, 3, 1, 2, 3}, new int[]{1, 1, 3, 3, 2, 1}, new int[]{1, 3, 3, 1, 2, 1}, new int[]{3, 1, 3, 1, 2, 1}, new int[]{2, 1, 1, 3, 3, 1}, new int[]{2, 3, 1, 1, 3, 1}, new int[]{2, 1, 3, 1, 1, 3}, new int[]{2, 1, 3, 3, 1, 1}, new int[]{2, 1, 3, 1, 3, 1}, new int[]{3, 1, 1, 1, 2, 3}, new int[]{3, 1, 1, 3, 2, 1}, new int[]{3, 3, 1, 1, 2, 1}, new int[]{3, 1, 2, 1, 1, 3}, new int[]{3, 1, 2, 3, 1, 1}, new int[]{3, 3, 2, 1, 1, 1}, new int[]{3, 1, 4, 1, 1, 1}, new int[]{2, 2, 1, 4, 1, 1}, new int[]{4, 3, 1, 1, 1, 1}, new int[]{1, 1, 1, 2, 2, 4}, new int[]{1, 1, 1, 4, 2, 2}, new int[]{1, 2, 1, 1, 2, 4}, new int[]{1, 2, 1, 4, 2, 1}, new int[]{1, 4, 1, 1, 2, 2}, new int[]{1, 4, 1, 2, 2, 1}, new int[]{1, 1, 2, 2, 1, 4}, new int[]{1, 1, 2, 4, 1, 2}, new int[]{1, 2, 2, 1, 1, 4}, new int[]{1, 2, 2, 4, 1, 1}, new int[]{1, 4, 2, 1, 1, 2}, new int[]{1, 4, 2, 2, 1, 1}, new int[]{2, 4, 1, 2, 1, 1}, new int[]{2, 2, 1, 1, 1, 4}, new int[]{4, 1, 3, 1, 1, 1}, new int[]{2, 4, 1, 1, 1, 2}, new int[]{1, 3, 4, 1, 1, 1}, new int[]{1, 1, 1, 2, 4, 2}, new int[]{1, 2, 1, 1, 4, 2}, new int[]{1, 2, 1, 2, 4, 1}, new int[]{1, 1, 4, 2, 1, 2}, new int[]{1, 2, 4, 1, 1, 2}, new int[]{1, 2, 4, 2, 1, 1}, new int[]{4, 1, 1, 2, 1, 2}, new int[]{4, 2, 1, 1, 1, 2}, new int[]{4, 2, 1, 2, 1, 1}, new int[]{2, 1, 2, 1, 4, 1}, new int[]{2, 1, 4, 1, 2, 1}, new int[]{4, 1, 2, 1, 2, 1}, new int[]{1, 1, 1, 1, 4, 3}, new int[]{1, 1, 1, 3, 4, 1}, new int[]{1, 3, 1, 1, 4, 1}, new int[]{1, 1, 4, 1, 1, 3}, new int[]{1, 1, 4, 3, 1, 1}, new int[]{4, 1, 1, 1, 1, 3}, new int[]{4, 1, 1, 3, 1, 1}, new int[]{1, 1, 3, 1, 4, 1}, new int[]{1, 1, 4, 1, 3, 1}, new int[]{3, 1, 1, 1, 4, 1}, new int[]{4, 1, 1, 1, 3, 1}, new int[]{2, 1, 1, 4, 1, 2}, new int[]{2, 1, 1, 2, 1, 4}, new int[]{2, 1, 1, 2, 3, 2}, new int[]{2, 3, 3, 1, 1, 1, 2}};
    private static final int CODE_SHIFT = 98;
    private static final int CODE_START_A = 103;
    private static final int CODE_START_B = 104;
    private static final int CODE_START_C = 105;
    private static final int CODE_STOP = 106;
    private static final float MAX_AVG_VARIANCE = 0.25f;
    private static final float MAX_INDIVIDUAL_VARIANCE = 0.7f;

    private static int[] findStartPattern(BitArray row) throws NotFoundException {
        int width = row.getSize();
        int rowOffset = row.getNextSet(0);
        int counterPosition = 0;
        int[] counters = new int[6];
        int patternStart = rowOffset;
        boolean isWhite = false;
        int patternLength = counters.length;
        for (int i = rowOffset; i < width; i++) {
            if (row.get(i) != isWhite) {
                counters[counterPosition] = counters[counterPosition] + 1;
            } else {
                if (counterPosition == patternLength - 1) {
                    float bestVariance = MAX_AVG_VARIANCE;
                    int bestMatch = -1;
                    for (int startCode = CODE_START_A; startCode <= CODE_START_C; startCode++) {
                        float variance = patternMatchVariance(counters, CODE_PATTERNS[startCode], MAX_INDIVIDUAL_VARIANCE);
                        if (variance < bestVariance) {
                            bestVariance = variance;
                            bestMatch = startCode;
                        }
                    }
                    if (bestMatch >= 0 && row.isRange(Math.max(0, patternStart - ((i - patternStart) / 2)), patternStart, false)) {
                        return new int[]{patternStart, i, bestMatch};
                    }
                    patternStart += counters[0] + counters[1];
                    System.arraycopy(counters, 2, counters, 0, counterPosition - 1);
                    counters[counterPosition - 1] = 0;
                    counters[counterPosition] = 0;
                    counterPosition--;
                } else {
                    counterPosition++;
                }
                counters[counterPosition] = 1;
                isWhite = isWhite ? false : true;
            }
        }
        throw NotFoundException.getNotFoundInstance();
    }

    private static int decodeCode(BitArray row, int[] counters, int rowOffset) throws NotFoundException {
        recordPattern(row, rowOffset, counters);
        float bestVariance = MAX_AVG_VARIANCE;
        int bestMatch = -1;
        int d = 0;
        while (true) {
            int[][] iArr = CODE_PATTERNS;
            if (d >= iArr.length) {
                break;
            }
            int[] pattern = iArr[d];
            float variance = patternMatchVariance(counters, pattern, MAX_INDIVIDUAL_VARIANCE);
            if (variance < bestVariance) {
                bestVariance = variance;
                bestMatch = d;
            }
            d++;
        }
        if (bestMatch >= 0) {
            return bestMatch;
        }
        throw NotFoundException.getNotFoundInstance();
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    /* JADX WARN: Removed duplicated region for block: B:14:0x0064  */
    @Override // com.google.zxing.oned.OneDReader
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    public Result decodeRow(int rowNumber, BitArray row, Map<DecodeHintType, ?> hints) throws NotFoundException, FormatException, ChecksumException {
        int codeSet;
        int[] counters;
        boolean convertFNC1 = hints != null && hints.containsKey(DecodeHintType.ASSUME_GS1);
        int symbologyModifier = 0;
        int[] startPatternInfo = findStartPattern(row);
        int code = startPatternInfo[2];
        List<Byte> rawCodes = new ArrayList<>(20);
        rawCodes.add(Byte.valueOf((byte) code));
        switch (code) {
            case CODE_START_A /* 103 */:
                codeSet = 101;
                break;
            case 104:
                codeSet = 100;
                break;
            case CODE_START_C /* 105 */:
                codeSet = CODE_CODE_C;
                break;
            default:
                throw FormatException.getFormatInstance();
        }
        boolean done = false;
        boolean isNextShifted = false;
        StringBuilder result = new StringBuilder(20);
        int lastStart = startPatternInfo[0];
        int nextStart = startPatternInfo[1];
        int[] counters2 = new int[6];
        int code2 = 0;
        int checksumTotal = code;
        int multiplier = 0;
        boolean lastCharacterWasPrintable = true;
        int nextStart2 = nextStart;
        int lastCode = 0;
        boolean upperMode = false;
        boolean shiftUpperMode = false;
        while (!done) {
            boolean unshift = isNextShifted;
            lastCode = code2;
            int startCode = code;
            int code3 = decodeCode(row, counters2, nextStart2);
            boolean done2 = done;
            rawCodes.add(Byte.valueOf((byte) code3));
            if (code3 != CODE_STOP) {
                lastCharacterWasPrintable = true;
            }
            if (code3 != CODE_STOP) {
                multiplier++;
                checksumTotal += multiplier * code3;
            }
            lastStart = nextStart2;
            for (int counter : counters2) {
                nextStart2 += counter;
            }
            switch (code3) {
                case CODE_START_A /* 103 */:
                case 104:
                case CODE_START_C /* 105 */:
                    throw FormatException.getFormatInstance();
                default:
                    switch (codeSet) {
                        case CODE_CODE_C /* 99 */:
                            counters = counters2;
                            if (code3 < 100) {
                                if (code3 < 10) {
                                    result.append('0');
                                }
                                result.append(code3);
                            } else {
                                if (code3 != CODE_STOP) {
                                    lastCharacterWasPrintable = false;
                                }
                                switch (code3) {
                                    case LocationRequestCompat.QUALITY_HIGH_ACCURACY /* 100 */:
                                        codeSet = 100;
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case 101:
                                        codeSet = 101;
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case 102:
                                        if (result.length() == 0) {
                                            symbologyModifier = 1;
                                        } else if (result.length() == 1) {
                                            symbologyModifier = 2;
                                        }
                                        if (convertFNC1) {
                                            if (result.length() == 0) {
                                                result.append("]C1");
                                                break;
                                            } else {
                                                result.append((char) 29);
                                                break;
                                            }
                                        }
                                        break;
                                    case CODE_START_A /* 103 */:
                                    case 104:
                                    case CODE_START_C /* 105 */:
                                    default:
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case CODE_STOP /* 106 */:
                                        done = true;
                                        isNextShifted = false;
                                        break;
                                }
                            }
                            done = done2;
                            isNextShifted = false;
                            break;
                        case LocationRequestCompat.QUALITY_HIGH_ACCURACY /* 100 */:
                            counters = counters2;
                            if (code3 < CODE_FNC_3) {
                                if (shiftUpperMode == upperMode) {
                                    result.append((char) (code3 + 32));
                                } else {
                                    result.append((char) (code3 + 32 + 128));
                                }
                                shiftUpperMode = false;
                                done = done2;
                                isNextShifted = false;
                                break;
                            } else {
                                if (code3 != CODE_STOP) {
                                    lastCharacterWasPrintable = false;
                                }
                                switch (code3) {
                                    case CODE_FNC_3 /* 96 */:
                                    case CODE_START_A /* 103 */:
                                    case 104:
                                    case CODE_START_C /* 105 */:
                                    default:
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case CODE_FNC_2 /* 97 */:
                                        symbologyModifier = 4;
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case CODE_SHIFT /* 98 */:
                                        isNextShifted = true;
                                        codeSet = 101;
                                        done = done2;
                                        break;
                                    case CODE_CODE_C /* 99 */:
                                        codeSet = CODE_CODE_C;
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case LocationRequestCompat.QUALITY_HIGH_ACCURACY /* 100 */:
                                        if (!upperMode && shiftUpperMode) {
                                            upperMode = true;
                                            shiftUpperMode = false;
                                            done = done2;
                                            isNextShifted = false;
                                            break;
                                        } else if (upperMode && shiftUpperMode) {
                                            upperMode = false;
                                            shiftUpperMode = false;
                                            done = done2;
                                            isNextShifted = false;
                                            break;
                                        } else {
                                            shiftUpperMode = true;
                                            done = done2;
                                            isNextShifted = false;
                                            break;
                                        }
                                    case 101:
                                        codeSet = 101;
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case 102:
                                        if (result.length() == 0) {
                                            symbologyModifier = 1;
                                        } else if (result.length() == 1) {
                                            symbologyModifier = 2;
                                        }
                                        if (convertFNC1) {
                                            if (result.length() == 0) {
                                                result.append("]C1");
                                            } else {
                                                result.append((char) 29);
                                            }
                                        }
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case CODE_STOP /* 106 */:
                                        done = true;
                                        isNextShifted = false;
                                        break;
                                }
                            }
                        case 101:
                            if (code3 < 64) {
                                if (shiftUpperMode == upperMode) {
                                    result.append((char) (code3 + 32));
                                } else {
                                    result.append((char) (code3 + 32 + 128));
                                }
                                shiftUpperMode = false;
                                counters = counters2;
                                done = done2;
                                isNextShifted = false;
                                break;
                            } else if (code3 < CODE_FNC_3) {
                                if (shiftUpperMode == upperMode) {
                                    result.append((char) (code3 - 64));
                                } else {
                                    result.append((char) (code3 + 64));
                                }
                                shiftUpperMode = false;
                                counters = counters2;
                                done = done2;
                                isNextShifted = false;
                                break;
                            } else {
                                if (code3 != CODE_STOP) {
                                    lastCharacterWasPrintable = false;
                                }
                                switch (code3) {
                                    case CODE_FNC_3 /* 96 */:
                                        counters = counters2;
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case CODE_FNC_2 /* 97 */:
                                        counters = counters2;
                                        symbologyModifier = 4;
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case CODE_SHIFT /* 98 */:
                                        counters = counters2;
                                        isNextShifted = true;
                                        codeSet = 100;
                                        done = done2;
                                        break;
                                    case CODE_CODE_C /* 99 */:
                                        counters = counters2;
                                        codeSet = CODE_CODE_C;
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case LocationRequestCompat.QUALITY_HIGH_ACCURACY /* 100 */:
                                        counters = counters2;
                                        codeSet = 100;
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case 101:
                                        counters = counters2;
                                        if (!upperMode && shiftUpperMode) {
                                            upperMode = true;
                                            shiftUpperMode = false;
                                            done = done2;
                                            isNextShifted = false;
                                            break;
                                        } else if (upperMode && shiftUpperMode) {
                                            upperMode = false;
                                            shiftUpperMode = false;
                                            done = done2;
                                            isNextShifted = false;
                                            break;
                                        } else {
                                            shiftUpperMode = true;
                                            done = done2;
                                            isNextShifted = false;
                                            break;
                                        }
                                    case 102:
                                        if (result.length() == 0) {
                                            symbologyModifier = 1;
                                            counters = counters2;
                                        } else {
                                            counters = counters2;
                                            if (result.length() == 1) {
                                                symbologyModifier = 2;
                                            }
                                        }
                                        if (convertFNC1) {
                                            if (result.length() == 0) {
                                                result.append("]C1");
                                            } else {
                                                result.append((char) 29);
                                            }
                                        }
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case CODE_START_A /* 103 */:
                                    case 104:
                                    case CODE_START_C /* 105 */:
                                    default:
                                        counters = counters2;
                                        done = done2;
                                        isNextShifted = false;
                                        break;
                                    case CODE_STOP /* 106 */:
                                        done = true;
                                        counters = counters2;
                                        isNextShifted = false;
                                        break;
                                }
                            }
                        default:
                            counters = counters2;
                            done = done2;
                            isNextShifted = false;
                            break;
                    }
                    if (unshift) {
                        codeSet = codeSet == 101 ? 100 : 101;
                    }
                    code2 = code3;
                    code = startCode;
                    counters2 = counters;
            }
            while (!done) {
            }
        }
        int lastPatternSize = nextStart2 - lastStart;
        int nextStart3 = row.getNextUnset(nextStart2);
        if (!row.isRange(nextStart3, Math.min(row.getSize(), ((nextStart3 - lastStart) / 2) + nextStart3), false)) {
            throw NotFoundException.getNotFoundInstance();
        }
        int lastCode2 = lastCode;
        if ((checksumTotal - (multiplier * lastCode2)) % CODE_START_A != lastCode2) {
            throw ChecksumException.getChecksumInstance();
        }
        int resultLength = result.length();
        if (resultLength == 0) {
            throw NotFoundException.getNotFoundInstance();
        }
        if (resultLength > 0 && lastCharacterWasPrintable) {
            if (codeSet == CODE_CODE_C) {
                result.delete(resultLength - 2, resultLength);
            } else {
                result.delete(resultLength - 1, resultLength);
            }
        }
        float left = (startPatternInfo[1] + startPatternInfo[0]) / 2.0f;
        float right = lastStart + (lastPatternSize / 2.0f);
        int rawCodesSize = rawCodes.size();
        byte[] rawBytes = new byte[rawCodesSize];
        for (int i = 0; i < rawCodesSize; i++) {
            rawBytes[i] = rawCodes.get(i).byteValue();
        }
        Result resultObject = new Result(result.toString(), rawBytes, new ResultPoint[]{new ResultPoint(left, rowNumber), new ResultPoint(right, rowNumber)}, BarcodeFormat.CODE_128);
        resultObject.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]C" + symbologyModifier);
        return resultObject;
    }
}
