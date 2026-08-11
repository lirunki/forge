package com.google.zxing.aztec.encoder;

import com.google.zxing.common.BitArray;
import kotlin.text.Typography;

/* loaded from: classes.dex */
final class BinaryShiftToken extends Token {
    private final int binaryShiftByteCount;
    private final int binaryShiftStart;

    BinaryShiftToken(Token previous, int binaryShiftStart, int binaryShiftByteCount) {
        super(previous);
        this.binaryShiftStart = binaryShiftStart;
        this.binaryShiftByteCount = binaryShiftByteCount;
    }

    @Override // com.google.zxing.aztec.encoder.Token
    public void appendTo(BitArray bitArray, byte[] text) {
        int bsbc = this.binaryShiftByteCount;
        for (int i = 0; i < bsbc; i++) {
            if (i == 0 || (i == 31 && bsbc <= 62)) {
                bitArray.appendBits(31, 5);
                if (bsbc > 62) {
                    bitArray.appendBits(bsbc - 31, 16);
                } else if (i == 0) {
                    bitArray.appendBits(Math.min(bsbc, 31), 5);
                } else {
                    bitArray.appendBits(bsbc - 31, 5);
                }
            }
            bitArray.appendBits(text[this.binaryShiftStart + i], 8);
        }
    }

    public String toString() {
        return "<" + this.binaryShiftStart + "::" + ((this.binaryShiftStart + this.binaryShiftByteCount) - 1) + Typography.greater;
    }
}
