package com.google.zxing.oned;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.ChecksumException;
import com.google.zxing.DecodeHintType;
import com.google.zxing.FormatException;
import com.google.zxing.NotFoundException;
import com.google.zxing.Reader;
import com.google.zxing.ReaderException;
import com.google.zxing.Result;
import com.google.zxing.ResultMetadataType;
import com.google.zxing.ResultPoint;
import com.google.zxing.common.BitArray;
import java.util.Arrays;
import java.util.EnumMap;
import java.util.Map;

/* loaded from: classes.dex */
public abstract class OneDReader implements Reader {
    public abstract Result decodeRow(int i, BitArray bitArray, Map<DecodeHintType, ?> map) throws NotFoundException, ChecksumException, FormatException;

    @Override // com.google.zxing.Reader
    public Result decode(BinaryBitmap image) throws NotFoundException, FormatException {
        return decode(image, null);
    }

    @Override // com.google.zxing.Reader
    public Result decode(BinaryBitmap image, Map<DecodeHintType, ?> hints) throws NotFoundException, FormatException {
        try {
            return doDecode(image, hints);
        } catch (NotFoundException nfe) {
            boolean tryHarder = hints != null && hints.containsKey(DecodeHintType.TRY_HARDER);
            if (tryHarder && image.isRotateSupported()) {
                BinaryBitmap rotatedImage = image.rotateCounterClockwise();
                Result result = doDecode(rotatedImage, hints);
                Map<ResultMetadataType, ?> metadata = result.getResultMetadata();
                int orientation = 270;
                if (metadata != null && metadata.containsKey(ResultMetadataType.ORIENTATION)) {
                    orientation = (((Integer) metadata.get(ResultMetadataType.ORIENTATION)).intValue() + 270) % 360;
                }
                result.putMetadata(ResultMetadataType.ORIENTATION, Integer.valueOf(orientation));
                ResultPoint[] points = result.getResultPoints();
                if (points != null) {
                    int height = rotatedImage.getHeight();
                    for (int i = 0; i < points.length; i++) {
                        points[i] = new ResultPoint((height - points[i].getY()) - 1.0f, points[i].getX());
                    }
                }
                return result;
            }
            throw nfe;
        }
    }

    @Override // com.google.zxing.Reader
    public void reset() {
    }

    /* JADX WARN: Removed duplicated region for block: B:38:0x008e A[EXC_TOP_SPLITTER, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:72:0x00f2 A[SYNTHETIC] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    private Result doDecode(BinaryBitmap image, Map<DecodeHintType, ?> hints) throws NotFoundException {
        int maxLines;
        int height;
        boolean tryHarder;
        Map<? extends DecodeHintType, ? extends Object> newHints;
        int height2;
        Map<? extends DecodeHintType, ? extends Object> hints2;
        boolean tryHarder2;
        int width = image.getWidth();
        int height3 = image.getHeight();
        BitArray row = new BitArray(width);
        int i = 1;
        boolean tryHarder3 = hints != null && hints.containsKey(DecodeHintType.TRY_HARDER);
        int rowStep = Math.max(1, height3 >> (tryHarder3 ? 8 : 5));
        if (tryHarder3) {
            maxLines = height3;
        } else {
            maxLines = 15;
        }
        int middle = height3 / 2;
        int x = 0;
        BitArray row2 = row;
        Map<? extends DecodeHintType, ? extends Object> hints3 = hints;
        while (x < maxLines) {
            int rowStepsAboveOrBelow = (x + 1) / 2;
            boolean isAbove = (x & 1) == 0;
            int rowNumber = middle + ((isAbove ? rowStepsAboveOrBelow : -rowStepsAboveOrBelow) * rowStep);
            if (rowNumber >= 0 && rowNumber < height3) {
                try {
                    row2 = image.getBlackRow(rowNumber, row2);
                    Map<? extends DecodeHintType, ? extends Object> map = hints3;
                    int attempt = 0;
                    Map<? extends DecodeHintType, ? extends Object> hints4 = map;
                    for (int i2 = 2; attempt < i2; i2 = 2) {
                        try {
                            if (attempt == i) {
                                row2.reverse();
                                if (hints4 != null && hints4.containsKey(DecodeHintType.NEED_RESULT_POINT_CALLBACK)) {
                                    newHints = new EnumMap<>(DecodeHintType.class);
                                    newHints.putAll(hints4);
                                    newHints.remove(DecodeHintType.NEED_RESULT_POINT_CALLBACK);
                                    Result result = decodeRow(rowNumber, row2, newHints);
                                    height2 = height3;
                                    if (attempt != 1) {
                                        try {
                                            result.putMetadata(ResultMetadataType.ORIENTATION, 180);
                                            ResultPoint[] points = result.getResultPoints();
                                            if (points != null) {
                                                hints2 = newHints;
                                                try {
                                                    tryHarder2 = tryHarder3;
                                                    try {
                                                        points[0] = new ResultPoint((width - points[0].getX()) - 1.0f, points[0].getY());
                                                        i = 1;
                                                        try {
                                                            points[1] = new ResultPoint((width - points[1].getX()) - 1.0f, points[1].getY());
                                                        } catch (ReaderException e) {
                                                            attempt++;
                                                            height3 = height2;
                                                            hints4 = hints2;
                                                            tryHarder3 = tryHarder2;
                                                        }
                                                    } catch (ReaderException e2) {
                                                        i = 1;
                                                    }
                                                } catch (ReaderException e3) {
                                                    tryHarder2 = tryHarder3;
                                                    i = 1;
                                                }
                                            }
                                        } catch (ReaderException e4) {
                                            hints2 = newHints;
                                            tryHarder2 = tryHarder3;
                                            i = 1;
                                        }
                                    }
                                    return result;
                                }
                            }
                            Result result2 = decodeRow(rowNumber, row2, newHints);
                            height2 = height3;
                            if (attempt != 1) {
                            }
                            return result2;
                        } catch (ReaderException e5) {
                            height2 = height3;
                            hints2 = newHints;
                            tryHarder2 = tryHarder3;
                            i = 1;
                        }
                        newHints = hints4;
                    }
                    height = height3;
                    tryHarder = tryHarder3;
                    hints3 = hints4;
                } catch (NotFoundException e6) {
                    height = height3;
                    tryHarder = tryHarder3;
                }
                x++;
                height3 = height;
                tryHarder3 = tryHarder;
            }
        }
        throw NotFoundException.getNotFoundInstance();
    }

    protected static void recordPattern(BitArray row, int start, int[] counters) throws NotFoundException {
        int numCounters = counters.length;
        Arrays.fill(counters, 0, numCounters, 0);
        int end = row.getSize();
        if (start >= end) {
            throw NotFoundException.getNotFoundInstance();
        }
        boolean isWhite = !row.get(start);
        int counterPosition = 0;
        int i = start;
        while (i < end) {
            if (row.get(i) != isWhite) {
                counters[counterPosition] = counters[counterPosition] + 1;
            } else {
                counterPosition++;
                if (counterPosition == numCounters) {
                    break;
                }
                counters[counterPosition] = 1;
                isWhite = !isWhite;
            }
            i++;
        }
        if (counterPosition != numCounters) {
            if (counterPosition != numCounters - 1 || i != end) {
                throw NotFoundException.getNotFoundInstance();
            }
        }
    }

    protected static void recordPatternInReverse(BitArray row, int start, int[] counters) throws NotFoundException {
        int numTransitionsLeft = counters.length;
        boolean last = row.get(start);
        while (start > 0 && numTransitionsLeft >= 0) {
            start--;
            if (row.get(start) != last) {
                numTransitionsLeft--;
                last = !last;
            }
        }
        if (numTransitionsLeft >= 0) {
            throw NotFoundException.getNotFoundInstance();
        }
        recordPattern(row, start + 1, counters);
    }

    protected static float patternMatchVariance(int[] counters, int[] pattern, float maxIndividualVariance) {
        int numCounters = counters.length;
        int total = 0;
        int patternLength = 0;
        for (int i = 0; i < numCounters; i++) {
            total += counters[i];
            patternLength += pattern[i];
        }
        if (total < patternLength) {
            return Float.POSITIVE_INFINITY;
        }
        float unitBarWidth = total / patternLength;
        float maxIndividualVariance2 = maxIndividualVariance * unitBarWidth;
        float totalVariance = 0.0f;
        for (int x = 0; x < numCounters; x++) {
            int counter = counters[x];
            float scaledPattern = pattern[x] * unitBarWidth;
            float variance = ((float) counter) > scaledPattern ? counter - scaledPattern : scaledPattern - counter;
            if (variance > maxIndividualVariance2) {
                return Float.POSITIVE_INFINITY;
            }
            totalVariance += variance;
        }
        return totalVariance / total;
    }
}
