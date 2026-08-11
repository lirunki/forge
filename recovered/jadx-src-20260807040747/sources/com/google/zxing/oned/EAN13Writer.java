package com.google.zxing.oned;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.FormatException;
import java.util.Collection;
import java.util.Collections;

/* loaded from: classes.dex */
public final class EAN13Writer extends UPCEANWriter {
    private static final int CODE_WIDTH = 95;

    @Override // com.google.zxing.oned.OneDimensionalCodeWriter
    protected Collection<BarcodeFormat> getSupportedWriteFormats() {
        return Collections.singleton(BarcodeFormat.EAN_13);
    }

    @Override // com.google.zxing.oned.OneDimensionalCodeWriter
    public boolean[] encode(String contents) {
        int length = contents.length();
        switch (length) {
            case 12:
                try {
                    int check = UPCEANReader.getStandardUPCEANChecksum(contents);
                    contents = contents + check;
                    break;
                } catch (FormatException fe) {
                    throw new IllegalArgumentException(fe);
                }
            case 13:
                try {
                    if (!UPCEANReader.checkStandardUPCEANChecksum(contents)) {
                        throw new IllegalArgumentException("Contents do not pass checksum");
                    }
                    break;
                } catch (FormatException e) {
                    throw new IllegalArgumentException("Illegal contents");
                }
            default:
                throw new IllegalArgumentException("Requested contents should be 12 or 13 digits long, but got " + length);
        }
        checkNumeric(contents);
        int firstDigit = Character.digit(contents.charAt(0), 10);
        int parities = EAN13Reader.FIRST_DIGIT_ENCODINGS[firstDigit];
        boolean[] result = new boolean[CODE_WIDTH];
        int pos = 0 + appendPattern(result, 0, UPCEANReader.START_END_PATTERN, true);
        for (int i = 1; i <= 6; i++) {
            int digit = Character.digit(contents.charAt(i), 10);
            if (((parities >> (6 - i)) & 1) == 1) {
                digit += 10;
            }
            pos += appendPattern(result, pos, UPCEANReader.L_AND_G_PATTERNS[digit], false);
        }
        int pos2 = pos + appendPattern(result, pos, UPCEANReader.MIDDLE_PATTERN, false);
        for (int i2 = 7; i2 <= 12; i2++) {
            pos2 += appendPattern(result, pos2, UPCEANReader.L_PATTERNS[Character.digit(contents.charAt(i2), 10)], true);
        }
        appendPattern(result, pos2, UPCEANReader.START_END_PATTERN, true);
        return result;
    }
}
