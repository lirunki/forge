package com.google.zxing.oned;

import androidx.core.location.LocationRequestCompat;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.Map;

/* loaded from: classes.dex */
public final class Code128Writer extends OneDimensionalCodeWriter {
    private static final int CODE_CODE_A = 101;
    private static final int CODE_CODE_B = 100;
    private static final int CODE_CODE_C = 99;
    private static final int CODE_FNC_1 = 102;
    private static final int CODE_FNC_2 = 97;
    private static final int CODE_FNC_3 = 96;
    private static final int CODE_FNC_4_A = 101;
    private static final int CODE_FNC_4_B = 100;
    private static final int CODE_START_A = 103;
    private static final int CODE_START_B = 104;
    private static final int CODE_START_C = 105;
    private static final int CODE_STOP = 106;
    private static final char ESCAPE_FNC_1 = 241;
    private static final char ESCAPE_FNC_2 = 242;
    private static final char ESCAPE_FNC_3 = 243;
    private static final char ESCAPE_FNC_4 = 244;

    private enum CType {
        UNCODABLE,
        ONE_DIGIT,
        TWO_DIGITS,
        FNC_1
    }

    @Override // com.google.zxing.oned.OneDimensionalCodeWriter
    protected Collection<BarcodeFormat> getSupportedWriteFormats() {
        return Collections.singleton(BarcodeFormat.CODE_128);
    }

    @Override // com.google.zxing.oned.OneDimensionalCodeWriter
    public boolean[] encode(String contents) {
        return encode(contents, null);
    }

    @Override // com.google.zxing.oned.OneDimensionalCodeWriter
    public boolean[] encode(String contents, Map<EncodeHintType, ?> hints) {
        int forcedCodeSet = check(contents, hints);
        boolean hasCompactionHint = hints != null && hints.containsKey(EncodeHintType.CODE128_COMPACT) && Boolean.parseBoolean(hints.get(EncodeHintType.CODE128_COMPACT).toString());
        return hasCompactionHint ? new MinimalEncoder(null).encode(contents) : encodeFast(contents, forcedCodeSet);
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    private static int check(String contents, Map<EncodeHintType, ?> hints) {
        char c;
        int forcedCodeSet = -1;
        if (hints != null && hints.containsKey(EncodeHintType.FORCE_CODE_SET)) {
            String codeSetHint = hints.get(EncodeHintType.FORCE_CODE_SET).toString();
            switch (codeSetHint.hashCode()) {
                case 65:
                    if (codeSetHint.equals("A")) {
                        c = 0;
                        break;
                    }
                    c = 65535;
                    break;
                case 66:
                    if (codeSetHint.equals("B")) {
                        c = 1;
                        break;
                    }
                    c = 65535;
                    break;
                case 67:
                    if (codeSetHint.equals("C")) {
                        c = 2;
                        break;
                    }
                    c = 65535;
                    break;
                default:
                    c = 65535;
                    break;
            }
            switch (c) {
                case 0:
                    forcedCodeSet = 101;
                    break;
                case 1:
                    forcedCodeSet = 100;
                    break;
                case 2:
                    forcedCodeSet = CODE_CODE_C;
                    break;
                default:
                    throw new IllegalArgumentException("Unsupported code set hint: " + codeSetHint);
            }
        }
        int length = contents.length();
        for (int i = 0; i < length; i++) {
            char c2 = contents.charAt(i);
            switch (c2) {
                case 241:
                case 242:
                case 243:
                case 244:
                    break;
                default:
                    if (c2 > 127) {
                        throw new IllegalArgumentException("Bad character in input: ASCII value=" + ((int) c2));
                    }
                    break;
            }
            switch (forcedCodeSet) {
                case CODE_CODE_C /* 99 */:
                    if (c2 < '0' || ((c2 > '9' && c2 <= 127) || c2 == 242 || c2 == 243 || c2 == 244)) {
                        throw new IllegalArgumentException("Bad character in input for forced code set C: ASCII value=" + ((int) c2));
                    }
                    break;
                case LocationRequestCompat.QUALITY_HIGH_ACCURACY /* 100 */:
                    if (c2 < ' ') {
                        throw new IllegalArgumentException("Bad character in input for forced code set B: ASCII value=" + ((int) c2));
                    }
                    break;
                case 101:
                    if (c2 > '_' && c2 <= 127) {
                        throw new IllegalArgumentException("Bad character in input for forced code set A: ASCII value=" + ((int) c2));
                    }
                    break;
            }
        }
        return forcedCodeSet;
    }

    private static boolean[] encodeFast(String contents, int forcedCodeSet) {
        int newCodeSet;
        int patternIndex;
        int length = contents.length();
        Collection<int[]> patterns = new ArrayList<>();
        int checkSum = 0;
        int checkWeight = 1;
        int codeSet = 0;
        int position = 0;
        while (position < length) {
            if (forcedCodeSet == -1) {
                newCodeSet = chooseCode(contents, position, codeSet);
            } else {
                newCodeSet = forcedCodeSet;
            }
            if (newCodeSet == codeSet) {
                switch (contents.charAt(position)) {
                    case 241:
                        patternIndex = 102;
                        break;
                    case 242:
                        patternIndex = CODE_FNC_2;
                        break;
                    case 243:
                        patternIndex = CODE_FNC_3;
                        break;
                    case 244:
                        if (codeSet == 101) {
                            patternIndex = 101;
                            break;
                        } else {
                            patternIndex = 100;
                            break;
                        }
                    default:
                        switch (codeSet) {
                            case LocationRequestCompat.QUALITY_HIGH_ACCURACY /* 100 */:
                                int patternIndex2 = contents.charAt(position);
                                patternIndex = patternIndex2 - 32;
                                break;
                            case 101:
                                int patternIndex3 = contents.charAt(position);
                                patternIndex = patternIndex3 - 32;
                                if (patternIndex < 0) {
                                    patternIndex += CODE_FNC_3;
                                    break;
                                }
                                break;
                            default:
                                if (position + 1 == length) {
                                    throw new IllegalArgumentException("Bad number of characters for digit only encoding.");
                                }
                                patternIndex = Integer.parseInt(contents.substring(position, position + 2));
                                position++;
                                break;
                        }
                }
                position++;
            } else {
                if (codeSet == 0) {
                    switch (newCodeSet) {
                        case LocationRequestCompat.QUALITY_HIGH_ACCURACY /* 100 */:
                            patternIndex = 104;
                            break;
                        case 101:
                            patternIndex = CODE_START_A;
                            break;
                        default:
                            patternIndex = CODE_START_C;
                            break;
                    }
                } else {
                    patternIndex = newCodeSet;
                }
                codeSet = newCodeSet;
            }
            patterns.add(Code128Reader.CODE_PATTERNS[patternIndex]);
            checkSum += patternIndex * checkWeight;
            if (position != 0) {
                checkWeight++;
            }
        }
        return produceResult(patterns, checkSum);
    }

    static boolean[] produceResult(Collection<int[]> patterns, int checkSum) {
        int checkSum2 = checkSum % CODE_START_A;
        if (checkSum2 < 0) {
            throw new IllegalArgumentException("Unable to compute a valid input checksum");
        }
        patterns.add(Code128Reader.CODE_PATTERNS[checkSum2]);
        patterns.add(Code128Reader.CODE_PATTERNS[CODE_STOP]);
        int codeWidth = 0;
        for (int[] pattern : patterns) {
            for (int width : pattern) {
                codeWidth += width;
            }
        }
        boolean[] result = new boolean[codeWidth];
        int pos = 0;
        Iterator<int[]> it = patterns.iterator();
        while (it.hasNext()) {
            pos += appendPattern(result, pos, it.next(), true);
        }
        return result;
    }

    private static CType findCType(CharSequence value, int start) {
        int last = value.length();
        if (start >= last) {
            return CType.UNCODABLE;
        }
        char c = value.charAt(start);
        if (c == 241) {
            return CType.FNC_1;
        }
        if (c < '0' || c > '9') {
            return CType.UNCODABLE;
        }
        if (start + 1 >= last) {
            return CType.ONE_DIGIT;
        }
        char c2 = value.charAt(start + 1);
        if (c2 < '0' || c2 > '9') {
            return CType.ONE_DIGIT;
        }
        return CType.TWO_DIGITS;
    }

    private static int chooseCode(CharSequence value, int start, int oldCode) {
        CType lookahead;
        CType lookahead2;
        char c;
        CType lookahead3 = findCType(value, start);
        if (lookahead3 == CType.ONE_DIGIT) {
            return oldCode == 101 ? 101 : 100;
        }
        if (lookahead3 == CType.UNCODABLE) {
            return (start >= value.length() || ((c = value.charAt(start)) >= ' ' && (oldCode != 101 || (c >= CODE_FNC_3 && (c < 241 || c > 244))))) ? 100 : 101;
        }
        if (oldCode == 101 && lookahead3 == CType.FNC_1) {
            return 101;
        }
        if (oldCode == CODE_CODE_C) {
            return CODE_CODE_C;
        }
        if (oldCode == 100) {
            if (lookahead3 == CType.FNC_1 || (lookahead = findCType(value, start + 2)) == CType.UNCODABLE || lookahead == CType.ONE_DIGIT) {
                return 100;
            }
            if (lookahead == CType.FNC_1) {
                if (findCType(value, start + 3) == CType.TWO_DIGITS) {
                    return CODE_CODE_C;
                }
                return 100;
            }
            int index = start + 4;
            while (true) {
                lookahead2 = findCType(value, index);
                if (lookahead2 != CType.TWO_DIGITS) {
                    break;
                }
                index += 2;
            }
            if (lookahead2 == CType.ONE_DIGIT) {
                return 100;
            }
            return CODE_CODE_C;
        }
        if (lookahead3 == CType.FNC_1) {
            lookahead3 = findCType(value, start + 1);
        }
        if (lookahead3 == CType.TWO_DIGITS) {
            return CODE_CODE_C;
        }
        return 100;
    }

    private static final class MinimalEncoder {
        static final /* synthetic */ boolean $assertionsDisabled = false;
        static final String A = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\b\t\n\u000b\f\r\u000e\u000f\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001a\u001b\u001c\u001d\u001e\u001fÿ";
        static final String B = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\u007fÿ";
        private static final int CODE_SHIFT = 98;
        private int[][] memoizedCost;
        private Latch[][] minPath;

        private enum Charset {
            A,
            B,
            C,
            NONE
        }

        private enum Latch {
            A,
            B,
            C,
            SHIFT,
            NONE
        }

        private MinimalEncoder() {
        }

        /* synthetic */ MinimalEncoder(AnonymousClass1 x0) {
            this();
        }

        /* JADX INFO: Access modifiers changed from: private */
        public boolean[] encode(String contents) {
            int patternIndex;
            this.memoizedCost = (int[][]) Array.newInstance((Class<?>) Integer.TYPE, 4, contents.length());
            this.minPath = (Latch[][]) Array.newInstance((Class<?>) Latch.class, 4, contents.length());
            encode(contents, Charset.NONE, 0);
            Collection<int[]> patterns = new ArrayList<>();
            int[] checkSum = {0};
            int[] checkWeight = {1};
            int length = contents.length();
            Charset charset = Charset.NONE;
            int i = 0;
            while (i < length) {
                Latch latch = this.minPath[charset.ordinal()][i];
                switch (AnonymousClass1.$SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Latch[latch.ordinal()]) {
                    case 1:
                        charset = Charset.A;
                        addPattern(patterns, i == 0 ? Code128Writer.CODE_START_A : 101, checkSum, checkWeight, i);
                        break;
                    case 2:
                        charset = Charset.B;
                        addPattern(patterns, i == 0 ? 104 : 100, checkSum, checkWeight, i);
                        break;
                    case 3:
                        charset = Charset.C;
                        addPattern(patterns, i == 0 ? Code128Writer.CODE_START_C : Code128Writer.CODE_CODE_C, checkSum, checkWeight, i);
                        break;
                    case 4:
                        addPattern(patterns, CODE_SHIFT, checkSum, checkWeight, i);
                        break;
                }
                if (charset == Charset.C) {
                    if (contents.charAt(i) == 241) {
                        addPattern(patterns, 102, checkSum, checkWeight, i);
                    } else {
                        addPattern(patterns, Integer.parseInt(contents.substring(i, i + 2)), checkSum, checkWeight, i);
                        if (i + 1 >= length) {
                            throw new AssertionError();
                        }
                        if (i + 1 < length) {
                            i++;
                        }
                    }
                } else {
                    switch (contents.charAt(i)) {
                        case 241:
                            patternIndex = 102;
                            break;
                        case 242:
                            patternIndex = Code128Writer.CODE_FNC_2;
                            break;
                        case 243:
                            patternIndex = Code128Writer.CODE_FNC_3;
                            break;
                        case 244:
                            if ((charset == Charset.A && latch != Latch.SHIFT) || (charset == Charset.B && latch == Latch.SHIFT)) {
                                patternIndex = 101;
                                break;
                            } else {
                                patternIndex = 100;
                                break;
                            }
                            break;
                        default:
                            patternIndex = contents.charAt(i) - ' ';
                            break;
                    }
                    if (((charset == Charset.A && latch != Latch.SHIFT) || (charset == Charset.B && latch == Latch.SHIFT)) && patternIndex < 0) {
                        patternIndex += Code128Writer.CODE_FNC_3;
                    }
                    addPattern(patterns, patternIndex, checkSum, checkWeight, i);
                }
                i++;
            }
            this.memoizedCost = null;
            this.minPath = null;
            return Code128Writer.produceResult(patterns, checkSum[0]);
        }

        private static void addPattern(Collection<int[]> patterns, int patternIndex, int[] checkSum, int[] checkWeight, int position) {
            patterns.add(Code128Reader.CODE_PATTERNS[patternIndex]);
            if (position != 0) {
                checkWeight[0] = checkWeight[0] + 1;
            }
            checkSum[0] = checkSum[0] + (checkWeight[0] * patternIndex);
        }

        private static boolean isDigit(char c) {
            return c >= '0' && c <= '9';
        }

        private boolean canEncode(CharSequence contents, Charset charset, int position) {
            char c = contents.charAt(position);
            switch (AnonymousClass1.$SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Charset[charset.ordinal()]) {
                case 1:
                    if (c == 241 || c == 242 || c == 243 || c == 244 || A.indexOf(c) >= 0) {
                    }
                    break;
                case 2:
                    if (c == 241 || c == 242 || c == 243 || c == 244 || B.indexOf(c) >= 0) {
                    }
                    break;
                case 3:
                    if (c == 241 || (position + 1 < contents.length() && isDigit(c) && isDigit(contents.charAt(position + 1)))) {
                    }
                    break;
            }
            return false;
        }

        private int encode(CharSequence contents, Charset charset, int position) {
            if (position >= contents.length()) {
                throw new AssertionError();
            }
            int mCost = this.memoizedCost[charset.ordinal()][position];
            if (mCost > 0) {
                return mCost;
            }
            int minCost = Integer.MAX_VALUE;
            Latch minLatch = Latch.NONE;
            boolean atEnd = position + 1 >= contents.length();
            Charset[] sets = {Charset.A, Charset.B};
            for (int i = 0; i <= 1; i++) {
                if (canEncode(contents, sets[i], position)) {
                    int cost = 1;
                    Latch latch = Latch.NONE;
                    if (charset != sets[i]) {
                        cost = 1 + 1;
                        latch = Latch.valueOf(sets[i].toString());
                    }
                    if (!atEnd) {
                        cost += encode(contents, sets[i], position + 1);
                    }
                    if (cost < minCost) {
                        minCost = cost;
                        minLatch = latch;
                    }
                    if (charset == sets[(i + 1) % 2]) {
                        int cost2 = 1 + 1;
                        Latch latch2 = Latch.SHIFT;
                        if (!atEnd) {
                            cost2 += encode(contents, charset, position + 1);
                        }
                        if (cost2 < minCost) {
                            minCost = cost2;
                            minLatch = latch2;
                        }
                    }
                }
            }
            if (canEncode(contents, Charset.C, position)) {
                int cost3 = 1;
                Latch latch3 = Latch.NONE;
                if (charset != Charset.C) {
                    cost3 = 1 + 1;
                    latch3 = Latch.C;
                }
                int advance = contents.charAt(position) != 241 ? 2 : 1;
                if (position + advance < contents.length()) {
                    cost3 += encode(contents, Charset.C, position + advance);
                }
                if (cost3 < minCost) {
                    minCost = cost3;
                    minLatch = latch3;
                }
            }
            if (minCost == Integer.MAX_VALUE) {
                throw new IllegalArgumentException("Bad character in input: ASCII value=" + ((int) contents.charAt(position)));
            }
            this.memoizedCost[charset.ordinal()][position] = minCost;
            this.minPath[charset.ordinal()][position] = minLatch;
            return minCost;
        }
    }

    /* renamed from: com.google.zxing.oned.Code128Writer$1, reason: invalid class name */
    static /* synthetic */ class AnonymousClass1 {
        static final /* synthetic */ int[] $SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Charset;
        static final /* synthetic */ int[] $SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Latch;

        static {
            int[] iArr = new int[MinimalEncoder.Charset.values().length];
            $SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Charset = iArr;
            try {
                iArr[MinimalEncoder.Charset.A.ordinal()] = 1;
            } catch (NoSuchFieldError e) {
            }
            try {
                $SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Charset[MinimalEncoder.Charset.B.ordinal()] = 2;
            } catch (NoSuchFieldError e2) {
            }
            try {
                $SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Charset[MinimalEncoder.Charset.C.ordinal()] = 3;
            } catch (NoSuchFieldError e3) {
            }
            int[] iArr2 = new int[MinimalEncoder.Latch.values().length];
            $SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Latch = iArr2;
            try {
                iArr2[MinimalEncoder.Latch.A.ordinal()] = 1;
            } catch (NoSuchFieldError e4) {
            }
            try {
                $SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Latch[MinimalEncoder.Latch.B.ordinal()] = 2;
            } catch (NoSuchFieldError e5) {
            }
            try {
                $SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Latch[MinimalEncoder.Latch.C.ordinal()] = 3;
            } catch (NoSuchFieldError e6) {
            }
            try {
                $SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Latch[MinimalEncoder.Latch.SHIFT.ordinal()] = 4;
            } catch (NoSuchFieldError e7) {
            }
        }
    }
}
