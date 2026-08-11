package com.google.zxing.datamatrix.detector;

import com.google.zxing.NotFoundException;
import com.google.zxing.ResultPoint;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.DetectorResult;
import com.google.zxing.common.GridSampler;
import com.google.zxing.common.detector.WhiteRectangleDetector;

/* loaded from: classes.dex */
public final class Detector {
    private final BitMatrix image;
    private final WhiteRectangleDetector rectangleDetector;

    public Detector(BitMatrix image) throws NotFoundException {
        this.image = image;
        this.rectangleDetector = new WhiteRectangleDetector(image);
    }

    public DetectorResult detect() throws NotFoundException {
        int dimensionTop;
        int dimensionRight;
        ResultPoint[] cornerPoints = this.rectangleDetector.detect();
        ResultPoint[] points = detectSolid2(detectSolid1(cornerPoints));
        points[3] = correctTopRight(points);
        if (points[3] == null) {
            throw NotFoundException.getNotFoundInstance();
        }
        ResultPoint[] points2 = shiftToModuleCenter(points);
        ResultPoint topLeft = points2[0];
        ResultPoint bottomLeft = points2[1];
        ResultPoint bottomRight = points2[2];
        ResultPoint topRight = points2[3];
        int dimensionTop2 = transitionsBetween(topLeft, topRight) + 1;
        int dimensionRight2 = transitionsBetween(bottomRight, topRight) + 1;
        if ((dimensionTop2 & 1) == 1) {
            dimensionTop2++;
        }
        if ((dimensionRight2 & 1) == 1) {
            dimensionRight2++;
        }
        if (dimensionTop2 * 4 < dimensionRight2 * 6 && dimensionRight2 * 4 < dimensionTop2 * 6) {
            int dimensionRight3 = Math.max(dimensionTop2, dimensionRight2);
            dimensionTop = dimensionRight3;
            dimensionRight = dimensionRight3;
        } else {
            dimensionTop = dimensionTop2;
            dimensionRight = dimensionRight2;
        }
        BitMatrix bits = sampleGrid(this.image, topLeft, bottomLeft, bottomRight, topRight, dimensionTop, dimensionRight);
        return new DetectorResult(bits, new ResultPoint[]{topLeft, bottomLeft, bottomRight, topRight});
    }

    private static ResultPoint shiftPoint(ResultPoint point, ResultPoint to, int div) {
        float x = (to.getX() - point.getX()) / (div + 1);
        float y = (to.getY() - point.getY()) / (div + 1);
        return new ResultPoint(point.getX() + x, point.getY() + y);
    }

    private static ResultPoint moveAway(ResultPoint point, float fromX, float fromY) {
        float x;
        float y;
        float x2 = point.getX();
        float y2 = point.getY();
        if (x2 < fromX) {
            x = x2 - 1.0f;
        } else {
            x = x2 + 1.0f;
        }
        if (y2 < fromY) {
            y = y2 - 1.0f;
        } else {
            y = y2 + 1.0f;
        }
        return new ResultPoint(x, y);
    }

    private ResultPoint[] detectSolid1(ResultPoint[] cornerPoints) {
        ResultPoint pointA = cornerPoints[0];
        ResultPoint pointB = cornerPoints[1];
        ResultPoint pointC = cornerPoints[3];
        ResultPoint pointD = cornerPoints[2];
        int trAB = transitionsBetween(pointA, pointB);
        int trBC = transitionsBetween(pointB, pointC);
        int trCD = transitionsBetween(pointC, pointD);
        int trDA = transitionsBetween(pointD, pointA);
        int min = trAB;
        ResultPoint[] points = {pointD, pointA, pointB, pointC};
        if (min > trBC) {
            min = trBC;
            points[0] = pointA;
            points[1] = pointB;
            points[2] = pointC;
            points[3] = pointD;
        }
        if (min > trCD) {
            min = trCD;
            points[0] = pointB;
            points[1] = pointC;
            points[2] = pointD;
            points[3] = pointA;
        }
        if (min > trDA) {
            points[0] = pointC;
            points[1] = pointD;
            points[2] = pointA;
            points[3] = pointB;
        }
        return points;
    }

    private ResultPoint[] detectSolid2(ResultPoint[] points) {
        ResultPoint pointA = points[0];
        ResultPoint pointB = points[1];
        ResultPoint pointC = points[2];
        ResultPoint pointD = points[3];
        int tr = transitionsBetween(pointA, pointD);
        ResultPoint pointBs = shiftPoint(pointB, pointC, (tr + 1) * 4);
        ResultPoint pointCs = shiftPoint(pointC, pointB, (tr + 1) * 4);
        int trBA = transitionsBetween(pointBs, pointA);
        int trCD = transitionsBetween(pointCs, pointD);
        if (trBA < trCD) {
            points[0] = pointA;
            points[1] = pointB;
            points[2] = pointC;
            points[3] = pointD;
        } else {
            points[0] = pointB;
            points[1] = pointC;
            points[2] = pointD;
            points[3] = pointA;
        }
        return points;
    }

    private ResultPoint correctTopRight(ResultPoint[] points) {
        ResultPoint pointA = points[0];
        ResultPoint pointB = points[1];
        ResultPoint pointC = points[2];
        ResultPoint pointD = points[3];
        int trTop = transitionsBetween(pointA, pointD);
        ResultPoint pointAs = shiftPoint(pointA, pointB, (transitionsBetween(pointB, pointD) + 1) * 4);
        ResultPoint pointCs = shiftPoint(pointC, pointB, (trTop + 1) * 4);
        int trTop2 = transitionsBetween(pointAs, pointD);
        int trRight = transitionsBetween(pointCs, pointD);
        ResultPoint candidate1 = new ResultPoint(pointD.getX() + ((pointC.getX() - pointB.getX()) / (trTop2 + 1)), pointD.getY() + ((pointC.getY() - pointB.getY()) / (trTop2 + 1)));
        ResultPoint candidate2 = new ResultPoint(pointD.getX() + ((pointA.getX() - pointB.getX()) / (trRight + 1)), pointD.getY() + ((pointA.getY() - pointB.getY()) / (trRight + 1)));
        if (!isValid(candidate1)) {
            if (isValid(candidate2)) {
                return candidate2;
            }
            return null;
        }
        if (!isValid(candidate2)) {
            return candidate1;
        }
        int sumc1 = transitionsBetween(pointAs, candidate1) + transitionsBetween(pointCs, candidate1);
        int sumc2 = transitionsBetween(pointAs, candidate2) + transitionsBetween(pointCs, candidate2);
        if (sumc1 > sumc2) {
            return candidate1;
        }
        return candidate2;
    }

    private ResultPoint[] shiftToModuleCenter(ResultPoint[] points) {
        ResultPoint pointA = points[0];
        ResultPoint pointB = points[1];
        ResultPoint pointC = points[2];
        ResultPoint pointD = points[3];
        int dimH = transitionsBetween(pointA, pointD) + 1;
        ResultPoint pointAs = shiftPoint(pointA, pointB, (transitionsBetween(pointC, pointD) + 1) * 4);
        ResultPoint pointCs = shiftPoint(pointC, pointB, dimH * 4);
        int dimH2 = transitionsBetween(pointAs, pointD) + 1;
        int dimH3 = transitionsBetween(pointCs, pointD);
        int dimV = dimH3 + 1;
        if ((dimH2 & 1) == 1) {
            dimH2++;
        }
        if ((dimV & 1) == 1) {
            dimV++;
        }
        float centerX = (((pointA.getX() + pointB.getX()) + pointC.getX()) + pointD.getX()) / 4.0f;
        float centerY = (((pointA.getY() + pointB.getY()) + pointC.getY()) + pointD.getY()) / 4.0f;
        ResultPoint pointA2 = moveAway(pointA, centerX, centerY);
        ResultPoint pointB2 = moveAway(pointB, centerX, centerY);
        ResultPoint pointC2 = moveAway(pointC, centerX, centerY);
        ResultPoint pointD2 = moveAway(pointD, centerX, centerY);
        ResultPoint pointAs2 = shiftPoint(pointA2, pointB2, dimV * 4);
        ResultPoint pointAs3 = shiftPoint(pointAs2, pointD2, dimH2 * 4);
        ResultPoint pointBs = shiftPoint(pointB2, pointA2, dimV * 4);
        ResultPoint pointBs2 = shiftPoint(pointBs, pointC2, dimH2 * 4);
        ResultPoint pointCs2 = shiftPoint(pointC2, pointD2, dimV * 4);
        ResultPoint pointCs3 = shiftPoint(pointCs2, pointB2, dimH2 * 4);
        ResultPoint pointDs = shiftPoint(pointD2, pointC2, dimV * 4);
        return new ResultPoint[]{pointAs3, pointBs2, pointCs3, shiftPoint(pointDs, pointA2, dimH2 * 4)};
    }

    private boolean isValid(ResultPoint p) {
        return p.getX() >= 0.0f && p.getX() <= ((float) (this.image.getWidth() - 1)) && p.getY() > 0.0f && p.getY() <= ((float) (this.image.getHeight() - 1));
    }

    private static BitMatrix sampleGrid(BitMatrix image, ResultPoint topLeft, ResultPoint bottomLeft, ResultPoint bottomRight, ResultPoint topRight, int dimensionX, int dimensionY) throws NotFoundException {
        GridSampler sampler = GridSampler.getInstance();
        return sampler.sampleGrid(image, dimensionX, dimensionY, 0.5f, 0.5f, dimensionX - 0.5f, 0.5f, dimensionX - 0.5f, dimensionY - 0.5f, 0.5f, dimensionY - 0.5f, topLeft.getX(), topLeft.getY(), topRight.getX(), topRight.getY(), bottomRight.getX(), bottomRight.getY(), bottomLeft.getX(), bottomLeft.getY());
    }

    private int transitionsBetween(ResultPoint from, ResultPoint to) {
        Detector detector = this;
        int fromX = (int) from.getX();
        int fromY = (int) from.getY();
        int toX = (int) to.getX();
        int toY = Math.min(detector.image.getHeight() - 1, (int) to.getY());
        boolean steep = Math.abs(toY - fromY) > Math.abs(toX - fromX);
        if (steep) {
            fromX = fromY;
            fromY = fromX;
            toX = toY;
            toY = toX;
        }
        int temp = toX - fromX;
        int dx = Math.abs(temp);
        int dy = Math.abs(toY - fromY);
        int error = (-dx) / 2;
        int ystep = fromY < toY ? 1 : -1;
        int xstep = fromX >= toX ? -1 : 1;
        int transitions = 0;
        boolean inBlack = detector.image.get(steep ? fromY : fromX, steep ? fromX : fromY);
        int x = fromX;
        int y = fromY;
        while (x != toX) {
            int fromX2 = fromX;
            boolean isBlack = detector.image.get(steep ? y : x, steep ? x : y);
            if (isBlack != inBlack) {
                transitions++;
                inBlack = isBlack;
            }
            error += dy;
            if (error > 0) {
                if (y == toY) {
                    break;
                }
                y += ystep;
                error -= dx;
            }
            x += xstep;
            detector = this;
            fromX = fromX2;
        }
        return transitions;
    }
}
