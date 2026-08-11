package com.google.zxing.aztec.detector;

import com.google.zxing.NotFoundException;
import com.google.zxing.ResultPoint;
import com.google.zxing.aztec.AztecDetectorResult;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.GridSampler;
import com.google.zxing.common.detector.MathUtils;
import com.google.zxing.common.detector.WhiteRectangleDetector;
import com.google.zxing.common.reedsolomon.GenericGF;
import com.google.zxing.common.reedsolomon.ReedSolomonDecoder;
import com.google.zxing.common.reedsolomon.ReedSolomonException;
import kotlin.text.Typography;
import kotlinx.coroutines.scheduling.WorkQueueKt;

/* loaded from: classes.dex */
public final class Detector {
    private static final int[] EXPECTED_CORNER_BITS = {3808, 476, 2107, 1799};
    private boolean compact;
    private final BitMatrix image;
    private int nbCenterLayers;
    private int nbDataBlocks;
    private int nbLayers;
    private int shift;

    public Detector(BitMatrix image) {
        this.image = image;
    }

    public AztecDetectorResult detect() throws NotFoundException {
        return detect(false);
    }

    public AztecDetectorResult detect(boolean isMirror) throws NotFoundException {
        Point pCenter = getMatrixCenter();
        ResultPoint[] bullsEyeCorners = getBullsEyeCorners(pCenter);
        if (isMirror) {
            ResultPoint temp = bullsEyeCorners[0];
            bullsEyeCorners[0] = bullsEyeCorners[2];
            bullsEyeCorners[2] = temp;
        }
        int errorsCorrected = extractParameters(bullsEyeCorners);
        BitMatrix bitMatrix = this.image;
        int i = this.shift;
        BitMatrix bits = sampleGrid(bitMatrix, bullsEyeCorners[i % 4], bullsEyeCorners[(i + 1) % 4], bullsEyeCorners[(i + 2) % 4], bullsEyeCorners[(i + 3) % 4]);
        ResultPoint[] corners = getMatrixCornerPoints(bullsEyeCorners);
        return new AztecDetectorResult(bits, corners, this.compact, this.nbDataBlocks, this.nbLayers, errorsCorrected);
    }

    private int extractParameters(ResultPoint[] bullsEyeCorners) throws NotFoundException {
        long parameterData;
        int i;
        if (!isValid(bullsEyeCorners[0]) || !isValid(bullsEyeCorners[1]) || !isValid(bullsEyeCorners[2]) || !isValid(bullsEyeCorners[3])) {
            throw NotFoundException.getNotFoundInstance();
        }
        int length = this.nbCenterLayers * 2;
        int[] sides = {sampleLine(bullsEyeCorners[0], bullsEyeCorners[1], length), sampleLine(bullsEyeCorners[1], bullsEyeCorners[2], length), sampleLine(bullsEyeCorners[2], bullsEyeCorners[3], length), sampleLine(bullsEyeCorners[3], bullsEyeCorners[0], length)};
        this.shift = getRotation(sides, length);
        long parameterData2 = 0;
        for (int i2 = 0; i2 < 4; i2++) {
            int side = sides[(this.shift + i2) % 4];
            if (this.compact) {
                parameterData = parameterData2 << 7;
                i = (side >> 1) & WorkQueueKt.MASK;
            } else {
                parameterData = parameterData2 << 10;
                i = ((side >> 2) & 992) + ((side >> 1) & 31);
            }
            parameterData2 = parameterData + i;
        }
        CorrectedParameter correctedParam = getCorrectedParameterData(parameterData2, this.compact);
        int correctedData = correctedParam.getData();
        if (this.compact) {
            this.nbLayers = (correctedData >> 6) + 1;
            this.nbDataBlocks = (correctedData & 63) + 1;
        } else {
            this.nbLayers = (correctedData >> 11) + 1;
            this.nbDataBlocks = (correctedData & 2047) + 1;
        }
        return correctedParam.getErrorsCorrected();
    }

    private static int getRotation(int[] sides, int length) throws NotFoundException {
        int cornerBits = 0;
        for (int side : sides) {
            int t = ((side >> (length - 2)) << 1) + (side & 1);
            cornerBits = (cornerBits << 3) + t;
        }
        int cornerBits2 = ((cornerBits & 1) << 11) + (cornerBits >> 1);
        for (int shift = 0; shift < 4; shift++) {
            if (Integer.bitCount(EXPECTED_CORNER_BITS[shift] ^ cornerBits2) <= 2) {
                return shift;
            }
        }
        throw NotFoundException.getNotFoundInstance();
    }

    private static CorrectedParameter getCorrectedParameterData(long parameterData, boolean compact) throws NotFoundException {
        int numCodewords;
        int numDataCodewords;
        if (compact) {
            numCodewords = 7;
            numDataCodewords = 2;
        } else {
            numCodewords = 10;
            numDataCodewords = 4;
        }
        int numECCodewords = numCodewords - numDataCodewords;
        int[] parameterWords = new int[numCodewords];
        for (int i = numCodewords - 1; i >= 0; i--) {
            parameterWords[i] = ((int) parameterData) & 15;
            parameterData >>= 4;
        }
        try {
            ReedSolomonDecoder rsDecoder = new ReedSolomonDecoder(GenericGF.AZTEC_PARAM);
            int errorsCorrected = rsDecoder.decodeWithECCount(parameterWords, numECCodewords);
            int result = 0;
            for (int i2 = 0; i2 < numDataCodewords; i2++) {
                result = (result << 4) + parameterWords[i2];
            }
            return new CorrectedParameter(result, errorsCorrected);
        } catch (ReedSolomonException e) {
            throw NotFoundException.getNotFoundInstance();
        }
    }

    private ResultPoint[] getBullsEyeCorners(Point pCenter) throws NotFoundException {
        Point pina = pCenter;
        Point pinb = pCenter;
        Point pinc = pCenter;
        Point pind = pCenter;
        boolean color = true;
        this.nbCenterLayers = 1;
        while (true) {
            boolean z = false;
            if (this.nbCenterLayers >= 9) {
                break;
            }
            Point pouta = getFirstDifferent(pina, color, 1, -1);
            Point poutb = getFirstDifferent(pinb, color, 1, 1);
            Point poutc = getFirstDifferent(pinc, color, -1, 1);
            Point poutd = getFirstDifferent(pind, color, -1, -1);
            if (this.nbCenterLayers > 2) {
                float q = (distance(poutd, pouta) * this.nbCenterLayers) / (distance(pind, pina) * (this.nbCenterLayers + 2));
                if (q >= 0.75d) {
                    if (q <= 1.25d) {
                        if (!isWhiteOrBlackRectangle(pouta, poutb, poutc, poutd)) {
                            break;
                        }
                    } else {
                        break;
                    }
                } else {
                    break;
                }
            }
            pina = pouta;
            pinb = poutb;
            pinc = poutc;
            pind = poutd;
            if (!color) {
                z = true;
            }
            color = z;
            this.nbCenterLayers++;
        }
        int i = this.nbCenterLayers;
        if (i == 5 || i == 7) {
            this.compact = i == 5;
            ResultPoint pinax = new ResultPoint(pina.getX() + 0.5f, pina.getY() - 0.5f);
            ResultPoint pinbx = new ResultPoint(pinb.getX() + 0.5f, pinb.getY() + 0.5f);
            ResultPoint pincx = new ResultPoint(pinc.getX() - 0.5f, pinc.getY() + 0.5f);
            ResultPoint pindx = new ResultPoint(pind.getX() - 0.5f, pind.getY() - 0.5f);
            ResultPoint[] resultPointArr = {pinax, pinbx, pincx, pindx};
            int i2 = this.nbCenterLayers;
            return expandSquare(resultPointArr, (i2 * 2) - 3, i2 * 2);
        }
        throw NotFoundException.getNotFoundInstance();
    }

    private Point getMatrixCenter() {
        ResultPoint pointA;
        ResultPoint pointB;
        ResultPoint pointA2;
        ResultPoint pointD;
        ResultPoint pointA3;
        ResultPoint pointB2;
        ResultPoint pointC;
        ResultPoint pointD2;
        try {
            ResultPoint[] cornerPoints = new WhiteRectangleDetector(this.image).detect();
            pointA = cornerPoints[0];
            pointB = cornerPoints[1];
            pointA2 = cornerPoints[2];
            pointD = cornerPoints[3];
        } catch (NotFoundException e) {
            int cx = this.image.getWidth() / 2;
            int cy = this.image.getHeight() / 2;
            ResultPoint pointA4 = getFirstDifferent(new Point(cx + 7, cy - 7), false, 1, -1).toResultPoint();
            ResultPoint pointB3 = getFirstDifferent(new Point(cx + 7, cy + 7), false, 1, 1).toResultPoint();
            ResultPoint pointC2 = getFirstDifferent(new Point(cx - 7, cy + 7), false, -1, 1).toResultPoint();
            ResultPoint resultPoint = getFirstDifferent(new Point(cx - 7, cy - 7), false, -1, -1).toResultPoint();
            pointA = pointA4;
            pointB = pointB3;
            pointA2 = pointC2;
            pointD = resultPoint;
        }
        int cx2 = MathUtils.round((((pointA.getX() + pointD.getX()) + pointB.getX()) + pointA2.getX()) / 4.0f);
        int cy2 = MathUtils.round((((pointA.getY() + pointD.getY()) + pointB.getY()) + pointA2.getY()) / 4.0f);
        try {
            ResultPoint[] cornerPoints2 = new WhiteRectangleDetector(this.image, 15, cx2, cy2).detect();
            pointA3 = cornerPoints2[0];
            pointB2 = cornerPoints2[1];
            pointC = cornerPoints2[2];
            pointD2 = cornerPoints2[3];
        } catch (NotFoundException e2) {
            pointA3 = getFirstDifferent(new Point(cx2 + 7, cy2 - 7), false, 1, -1).toResultPoint();
            pointB2 = getFirstDifferent(new Point(cx2 + 7, cy2 + 7), false, 1, 1).toResultPoint();
            pointC = getFirstDifferent(new Point(cx2 - 7, cy2 + 7), false, -1, 1).toResultPoint();
            pointD2 = getFirstDifferent(new Point(cx2 - 7, cy2 - 7), false, -1, -1).toResultPoint();
        }
        return new Point(MathUtils.round((((pointA3.getX() + pointD2.getX()) + pointB2.getX()) + pointC.getX()) / 4.0f), MathUtils.round((((pointA3.getY() + pointD2.getY()) + pointB2.getY()) + pointC.getY()) / 4.0f));
    }

    private ResultPoint[] getMatrixCornerPoints(ResultPoint[] bullsEyeCorners) {
        return expandSquare(bullsEyeCorners, this.nbCenterLayers * 2, getDimension());
    }

    private BitMatrix sampleGrid(BitMatrix image, ResultPoint topLeft, ResultPoint topRight, ResultPoint bottomRight, ResultPoint bottomLeft) throws NotFoundException {
        GridSampler sampler = GridSampler.getInstance();
        int dimension = getDimension();
        int i = this.nbCenterLayers;
        float low = (dimension / 2.0f) - i;
        float high = (dimension / 2.0f) + i;
        return sampler.sampleGrid(image, dimension, dimension, low, low, high, low, high, high, low, high, topLeft.getX(), topLeft.getY(), topRight.getX(), topRight.getY(), bottomRight.getX(), bottomRight.getY(), bottomLeft.getX(), bottomLeft.getY());
    }

    private int sampleLine(ResultPoint p1, ResultPoint p2, int size) {
        int result = 0;
        float d = distance(p1, p2);
        float moduleSize = d / size;
        float px = p1.getX();
        float py = p1.getY();
        float dx = ((p2.getX() - p1.getX()) * moduleSize) / d;
        float dy = ((p2.getY() - p1.getY()) * moduleSize) / d;
        for (int i = 0; i < size; i++) {
            if (this.image.get(MathUtils.round((i * dx) + px), MathUtils.round((i * dy) + py))) {
                result |= 1 << ((size - i) - 1);
            }
        }
        return result;
    }

    private boolean isWhiteOrBlackRectangle(Point p1, Point p2, Point p3, Point p4) {
        Point p12 = new Point(Math.max(0, p1.getX() - 3), Math.min(this.image.getHeight() - 1, p1.getY() + 3));
        Point p22 = new Point(Math.max(0, p2.getX() - 3), Math.max(0, p2.getY() - 3));
        Point p32 = new Point(Math.min(this.image.getWidth() - 1, p3.getX() + 3), Math.max(0, Math.min(this.image.getHeight() - 1, p3.getY() - 3)));
        Point p42 = new Point(Math.min(this.image.getWidth() - 1, p4.getX() + 3), Math.min(this.image.getHeight() - 1, p4.getY() + 3));
        int cInit = getColor(p42, p12);
        if (cInit == 0) {
            return false;
        }
        int c = getColor(p12, p22);
        if (c != cInit) {
            return false;
        }
        int c2 = getColor(p22, p32);
        if (c2 != cInit) {
            return false;
        }
        int c3 = getColor(p32, p42);
        return c3 == cInit;
    }

    private int getColor(Point p1, Point p2) {
        float d = distance(p1, p2);
        if (d == 0.0f) {
            return 0;
        }
        float dx = (p2.getX() - p1.getX()) / d;
        float dy = (p2.getY() - p1.getY()) / d;
        int error = 0;
        float px = p1.getX();
        float py = p1.getY();
        boolean colorModel = this.image.get(p1.getX(), p1.getY());
        int iMax = (int) Math.floor(d);
        for (int i = 0; i < iMax; i++) {
            if (this.image.get(MathUtils.round(px), MathUtils.round(py)) != colorModel) {
                error++;
            }
            px += dx;
            py += dy;
        }
        float errRatio = error / d;
        if (errRatio <= 0.1f || errRatio >= 0.9f) {
            return (errRatio <= 0.1f) == colorModel ? 1 : -1;
        }
        return 0;
    }

    private Point getFirstDifferent(Point init, boolean color, int dx, int dy) {
        int x = init.getX() + dx;
        int y = init.getY();
        while (true) {
            y += dy;
            if (!isValid(x, y) || this.image.get(x, y) != color) {
                break;
            }
            x += dx;
        }
        int x2 = x - dx;
        int y2 = y - dy;
        while (isValid(x2, y2) && this.image.get(x2, y2) == color) {
            x2 += dx;
        }
        int x3 = x2 - dx;
        while (isValid(x3, y2) && this.image.get(x3, y2) == color) {
            y2 += dy;
        }
        return new Point(x3, y2 - dy);
    }

    private static ResultPoint[] expandSquare(ResultPoint[] cornerPoints, int oldSide, int newSide) {
        float ratio = newSide / (oldSide * 2.0f);
        float dx = cornerPoints[0].getX() - cornerPoints[2].getX();
        float dy = cornerPoints[0].getY() - cornerPoints[2].getY();
        float centerx = (cornerPoints[0].getX() + cornerPoints[2].getX()) / 2.0f;
        float centery = (cornerPoints[0].getY() + cornerPoints[2].getY()) / 2.0f;
        ResultPoint result0 = new ResultPoint((ratio * dx) + centerx, (ratio * dy) + centery);
        ResultPoint result2 = new ResultPoint(centerx - (ratio * dx), centery - (ratio * dy));
        float dx2 = cornerPoints[1].getX() - cornerPoints[3].getX();
        float dy2 = cornerPoints[1].getY() - cornerPoints[3].getY();
        float centerx2 = (cornerPoints[1].getX() + cornerPoints[3].getX()) / 2.0f;
        float centery2 = (cornerPoints[1].getY() + cornerPoints[3].getY()) / 2.0f;
        ResultPoint result1 = new ResultPoint((ratio * dx2) + centerx2, (ratio * dy2) + centery2);
        ResultPoint result3 = new ResultPoint(centerx2 - (ratio * dx2), centery2 - (ratio * dy2));
        return new ResultPoint[]{result0, result1, result2, result3};
    }

    private boolean isValid(int x, int y) {
        return x >= 0 && x < this.image.getWidth() && y >= 0 && y < this.image.getHeight();
    }

    private boolean isValid(ResultPoint point) {
        int x = MathUtils.round(point.getX());
        int y = MathUtils.round(point.getY());
        return isValid(x, y);
    }

    private static float distance(Point a, Point b) {
        return MathUtils.distance(a.getX(), a.getY(), b.getX(), b.getY());
    }

    private static float distance(ResultPoint a, ResultPoint b) {
        return MathUtils.distance(a.getX(), a.getY(), b.getX(), b.getY());
    }

    private int getDimension() {
        if (this.compact) {
            return (this.nbLayers * 4) + 11;
        }
        int i = this.nbLayers;
        return (i * 4) + ((((i * 2) + 6) / 15) * 2) + 15;
    }

    static final class Point {
        private final int x;
        private final int y;

        ResultPoint toResultPoint() {
            return new ResultPoint(this.x, this.y);
        }

        Point(int x, int y) {
            this.x = x;
            this.y = y;
        }

        int getX() {
            return this.x;
        }

        int getY() {
            return this.y;
        }

        public String toString() {
            return "<" + this.x + ' ' + this.y + Typography.greater;
        }
    }

    static final class CorrectedParameter {
        private final int data;
        private final int errorsCorrected;

        CorrectedParameter(int data, int errorsCorrected) {
            this.data = data;
            this.errorsCorrected = errorsCorrected;
        }

        int getData() {
            return this.data;
        }

        int getErrorsCorrected() {
            return this.errorsCorrected;
        }
    }
}
