package com.google.zxing.aztec;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.FormatException;
import com.google.zxing.NotFoundException;
import com.google.zxing.Reader;
import com.google.zxing.Result;
import com.google.zxing.ResultMetadataType;
import com.google.zxing.ResultPoint;
import com.google.zxing.ResultPointCallback;
import com.google.zxing.aztec.decoder.Decoder;
import com.google.zxing.aztec.detector.Detector;
import com.google.zxing.common.DecoderResult;
import java.util.List;
import java.util.Map;

/* loaded from: classes.dex */
public final class AztecReader implements Reader {
    @Override // com.google.zxing.Reader
    public Result decode(BinaryBitmap image) throws NotFoundException, FormatException {
        return decode(image, null);
    }

    @Override // com.google.zxing.Reader
    public Result decode(BinaryBitmap image, Map<DecodeHintType, ?> hints) throws NotFoundException, FormatException {
        ResultPointCallback rpcb;
        NotFoundException notFoundException = null;
        FormatException formatException = null;
        Detector detector = new Detector(image.getBlackMatrix());
        ResultPoint[] points = null;
        DecoderResult decoderResult = null;
        int errorsCorrected = 0;
        try {
            AztecDetectorResult detectorResult = detector.detect(false);
            points = detectorResult.getPoints();
            errorsCorrected = detectorResult.getErrorsCorrected();
            decoderResult = new Decoder().decode(detectorResult);
        } catch (FormatException e) {
            formatException = e;
        } catch (NotFoundException e2) {
            notFoundException = e2;
        }
        if (decoderResult == null) {
            try {
                AztecDetectorResult detectorResult2 = detector.detect(true);
                points = detectorResult2.getPoints();
                errorsCorrected = detectorResult2.getErrorsCorrected();
                decoderResult = new Decoder().decode(detectorResult2);
            } catch (FormatException | NotFoundException e3) {
                if (notFoundException != null) {
                    throw notFoundException;
                }
                if (formatException != null) {
                    throw formatException;
                }
                throw e3;
            }
        }
        if (hints != null && (rpcb = (ResultPointCallback) hints.get(DecodeHintType.NEED_RESULT_POINT_CALLBACK)) != null) {
            for (ResultPoint point : points) {
                rpcb.foundPossibleResultPoint(point);
            }
        }
        Result result = new Result(decoderResult.getText(), decoderResult.getRawBytes(), decoderResult.getNumBits(), points, BarcodeFormat.AZTEC, System.currentTimeMillis());
        List<byte[]> byteSegments = decoderResult.getByteSegments();
        if (byteSegments != null) {
            result.putMetadata(ResultMetadataType.BYTE_SEGMENTS, byteSegments);
        }
        String ecLevel = decoderResult.getECLevel();
        if (ecLevel != null) {
            result.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, ecLevel);
        }
        result.putMetadata(ResultMetadataType.ERRORS_CORRECTED, Integer.valueOf(errorsCorrected + decoderResult.getErrorsCorrected().intValue()));
        result.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]z" + decoderResult.getSymbologyModifier());
        return result;
    }

    @Override // com.google.zxing.Reader
    public void reset() {
    }
}
