package com.google.zxing.oned;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.DecodeHintType;
import com.google.zxing.NotFoundException;
import com.google.zxing.Reader;
import com.google.zxing.ReaderException;
import com.google.zxing.Result;
import com.google.zxing.common.BitArray;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;

/* loaded from: classes.dex */
public final class MultiFormatUPCEANReader extends OneDReader {
    private static final UPCEANReader[] EMPTY_READER_ARRAY = new UPCEANReader[0];
    private final UPCEANReader[] readers;

    public MultiFormatUPCEANReader(Map<DecodeHintType, ?> hints) {
        Collection<BarcodeFormat> possibleFormats = hints == null ? null : (Collection) hints.get(DecodeHintType.POSSIBLE_FORMATS);
        Collection<UPCEANReader> readers = new ArrayList<>();
        if (possibleFormats != null) {
            if (possibleFormats.contains(BarcodeFormat.EAN_13)) {
                readers.add(new EAN13Reader());
            } else if (possibleFormats.contains(BarcodeFormat.UPC_A)) {
                readers.add(new UPCAReader());
            }
            if (possibleFormats.contains(BarcodeFormat.EAN_8)) {
                readers.add(new EAN8Reader());
            }
            if (possibleFormats.contains(BarcodeFormat.UPC_E)) {
                readers.add(new UPCEReader());
            }
        }
        if (readers.isEmpty()) {
            readers.add(new EAN13Reader());
            readers.add(new EAN8Reader());
            readers.add(new UPCEReader());
        }
        this.readers = (UPCEANReader[]) readers.toArray(EMPTY_READER_ARRAY);
    }

    /* JADX WARN: Removed duplicated region for block: B:10:0x0038  */
    /* JADX WARN: Removed duplicated region for block: B:12:0x0045 A[Catch: ReaderException -> 0x0031, TRY_ENTER, TRY_LEAVE, TryCatch #0 {ReaderException -> 0x0031, blocks: (B:39:0x0023, B:12:0x0045), top: B:38:0x0023 }] */
    /* JADX WARN: Removed duplicated region for block: B:16:0x0053 A[ADDED_TO_REGION] */
    /* JADX WARN: Removed duplicated region for block: B:31:0x0079 A[ADDED_TO_REGION, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:37:0x003a A[Catch: ReaderException -> 0x007c, TRY_ENTER, TRY_LEAVE, TryCatch #2 {ReaderException -> 0x007c, blocks: (B:5:0x0015, B:17:0x0055, B:37:0x003a), top: B:4:0x0015 }] */
    @Override // com.google.zxing.oned.OneDReader
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    public Result decodeRow(int rowNumber, BitArray row, Map<DecodeHintType, ?> hints) throws NotFoundException {
        int[] startGuardPattern;
        boolean ean13MayBeUPCA;
        Collection<BarcodeFormat> possibleFormats;
        boolean canReturnUPCA;
        Map<DecodeHintType, ?> map = hints;
        int[] startGuardPattern2 = UPCEANReader.findStartGuardPattern(row);
        UPCEANReader[] uPCEANReaderArr = this.readers;
        int length = uPCEANReaderArr.length;
        int i = 0;
        int i2 = 0;
        while (i2 < length) {
            UPCEANReader reader = uPCEANReaderArr[i2];
            try {
                Result result = reader.decodeRow(rowNumber, row, startGuardPattern2, map);
                if (result.getBarcodeFormat() == BarcodeFormat.EAN_13) {
                    try {
                        if (result.getText().charAt(i) == '0') {
                            ean13MayBeUPCA = true;
                            possibleFormats = map != null ? null : (Collection) map.get(DecodeHintType.POSSIBLE_FORMATS);
                            if (possibleFormats != null) {
                                if (!possibleFormats.contains(BarcodeFormat.UPC_A)) {
                                    canReturnUPCA = false;
                                    if (ean13MayBeUPCA && canReturnUPCA) {
                                        startGuardPattern = startGuardPattern2;
                                        try {
                                            Result resultUPCA = new Result(result.getText().substring(1), result.getRawBytes(), result.getResultPoints(), BarcodeFormat.UPC_A);
                                            resultUPCA.putAllMetadata(result.getResultMetadata());
                                            return resultUPCA;
                                        } catch (ReaderException e) {
                                            i2++;
                                            map = hints;
                                            startGuardPattern2 = startGuardPattern;
                                            i = 0;
                                        }
                                    } else {
                                        return result;
                                    }
                                }
                            }
                            canReturnUPCA = true;
                            if (ean13MayBeUPCA) {
                            }
                            return result;
                        }
                    } catch (ReaderException e2) {
                        startGuardPattern = startGuardPattern2;
                        i2++;
                        map = hints;
                        startGuardPattern2 = startGuardPattern;
                        i = 0;
                    }
                }
                ean13MayBeUPCA = false;
                if (map != null) {
                }
                if (possibleFormats != null) {
                }
                canReturnUPCA = true;
                if (ean13MayBeUPCA) {
                }
                return result;
            } catch (ReaderException e3) {
                startGuardPattern = startGuardPattern2;
            }
        }
        throw NotFoundException.getNotFoundInstance();
    }

    @Override // com.google.zxing.oned.OneDReader, com.google.zxing.Reader
    public void reset() {
        for (Reader reader : this.readers) {
            reader.reset();
        }
    }
}
