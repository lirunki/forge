package com.google.zxing.aztec.encoder;

import com.google.zxing.common.BitArray;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/* loaded from: classes.dex */
final class State {
    static final State INITIAL_STATE = new State(Token.EMPTY, 0, 0, 0);
    private final int binaryShiftByteCount;
    private final int binaryShiftCost;
    private final int bitCount;
    private final int mode;
    private final Token token;

    private State(Token token, int mode, int binaryBytes, int bitCount) {
        this.token = token;
        this.mode = mode;
        this.binaryShiftByteCount = binaryBytes;
        this.bitCount = bitCount;
        this.binaryShiftCost = calculateBinaryShiftCost(binaryBytes);
    }

    int getMode() {
        return this.mode;
    }

    Token getToken() {
        return this.token;
    }

    int getBinaryShiftByteCount() {
        return this.binaryShiftByteCount;
    }

    int getBitCount() {
        return this.bitCount;
    }

    State appendFLGn(int eci) {
        Token token;
        State result = shiftAndAppend(4, 0);
        Token token2 = result.token;
        int bitsAdded = 3;
        if (eci < 0) {
            token = token2.add(0, 3);
        } else {
            if (eci > 999999) {
                throw new IllegalArgumentException("ECI code must be between 0 and 999999");
            }
            byte[] eciDigits = Integer.toString(eci).getBytes(StandardCharsets.ISO_8859_1);
            Token token3 = token2.add(eciDigits.length, 3);
            for (byte eciDigit : eciDigits) {
                token3 = token3.add((eciDigit - 48) + 2, 4);
            }
            bitsAdded = 3 + (eciDigits.length * 4);
            token = token3;
        }
        return new State(token, this.mode, 0, this.bitCount + bitsAdded);
    }

    State latchAndAppend(int mode, int value) {
        int bitCount = this.bitCount;
        Token token = this.token;
        if (mode != this.mode) {
            int latch = HighLevelEncoder.LATCH_TABLE[this.mode][mode];
            token = token.add(65535 & latch, latch >> 16);
            bitCount += latch >> 16;
        }
        int latchModeBitCount = mode == 2 ? 4 : 5;
        return new State(token.add(value, latchModeBitCount), mode, 0, bitCount + latchModeBitCount);
    }

    State shiftAndAppend(int mode, int value) {
        Token token = this.token;
        int thisModeBitCount = this.mode == 2 ? 4 : 5;
        return new State(token.add(HighLevelEncoder.SHIFT_TABLE[this.mode][mode], thisModeBitCount).add(value, 5), this.mode, 0, this.bitCount + thisModeBitCount + 5);
    }

    State addBinaryShiftChar(int index) {
        Token token = this.token;
        int mode = this.mode;
        int bitCount = this.bitCount;
        int i = this.mode;
        if (i == 4 || i == 2) {
            int latch = HighLevelEncoder.LATCH_TABLE[mode][0];
            token = token.add(65535 & latch, latch >> 16);
            bitCount += latch >> 16;
            mode = 0;
        }
        int latch2 = this.binaryShiftByteCount;
        int deltaBitCount = (latch2 == 0 || latch2 == 31) ? 18 : latch2 == 62 ? 9 : 8;
        State result = new State(token, mode, latch2 + 1, bitCount + deltaBitCount);
        return result.binaryShiftByteCount == 2078 ? result.endBinaryShift(index + 1) : result;
    }

    State endBinaryShift(int index) {
        int i = this.binaryShiftByteCount;
        if (i == 0) {
            return this;
        }
        Token token = this.token;
        return new State(token.addBinaryShift(index - i, i), this.mode, 0, this.bitCount);
    }

    boolean isBetterThanOrEqualTo(State other) {
        int newModeBitCount = this.bitCount + (HighLevelEncoder.LATCH_TABLE[this.mode][other.mode] >> 16);
        int i = this.binaryShiftByteCount;
        int i2 = other.binaryShiftByteCount;
        if (i < i2) {
            newModeBitCount += other.binaryShiftCost - this.binaryShiftCost;
        } else if (i > i2 && i2 > 0) {
            newModeBitCount += 10;
        }
        return newModeBitCount <= other.bitCount;
    }

    BitArray toBitArray(byte[] text) {
        List<Token> symbols = new ArrayList<>();
        for (Token token = endBinaryShift(text.length).token; token != null; token = token.getPrevious()) {
            symbols.add(token);
        }
        BitArray bitArray = new BitArray();
        for (int i = symbols.size() - 1; i >= 0; i--) {
            symbols.get(i).appendTo(bitArray, text);
        }
        return bitArray;
    }

    public String toString() {
        return String.format("%s bits=%d bytes=%d", HighLevelEncoder.MODE_NAMES[this.mode], Integer.valueOf(this.bitCount), Integer.valueOf(this.binaryShiftByteCount));
    }

    private static int calculateBinaryShiftCost(int binaryShiftByteCount) {
        if (binaryShiftByteCount > 62) {
            return 21;
        }
        if (binaryShiftByteCount > 31) {
            return 20;
        }
        if (binaryShiftByteCount > 0) {
            return 10;
        }
        return 0;
    }
}
