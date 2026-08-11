package com.google.zxing.datamatrix.encoder;

import androidx.core.view.InputDeviceCompat;
import com.google.zxing.common.MinimalECIInput;
import java.lang.reflect.Array;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import kotlin.UByte;
import kotlin.text.Typography;

/* loaded from: classes.dex */
public final class MinimalEncoder {
    static final char[] C40_SHIFT2_CHARS = {'!', Typography.quote, '#', Typography.dollar, '%', Typography.amp, '\'', '(', ')', '*', '+', ',', '-', '.', '/', ':', ';', Typography.less, '=', Typography.greater, '?', '@', '[', '\\', ']', '^', '_'};

    enum Mode {
        ASCII,
        C40,
        TEXT,
        X12,
        EDF,
        B256
    }

    private MinimalEncoder() {
    }

    static boolean isExtendedASCII(char ch, int fnc1) {
        return ch != fnc1 && ch >= 128 && ch <= 255;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static boolean isInC40Shift1Set(char ch) {
        return ch <= 31;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static boolean isInC40Shift2Set(char ch, int fnc1) {
        for (char c40Shift2Char : C40_SHIFT2_CHARS) {
            if (c40Shift2Char == ch) {
                return true;
            }
        }
        return ch == fnc1;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static boolean isInTextShift1Set(char ch) {
        return isInC40Shift1Set(ch);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static boolean isInTextShift2Set(char ch, int fnc1) {
        return isInC40Shift2Set(ch, fnc1);
    }

    public static String encodeHighLevel(String msg) {
        return encodeHighLevel(msg, null, -1, SymbolShapeHint.FORCE_NONE);
    }

    public static String encodeHighLevel(String msg, Charset priorityCharset, int fnc1, SymbolShapeHint shape) {
        int macroId = 0;
        if (msg.startsWith("[)>\u001e05\u001d") && msg.endsWith("\u001e\u0004")) {
            macroId = 5;
            msg = msg.substring("[)>\u001e05\u001d".length(), msg.length() - 2);
        } else if (msg.startsWith("[)>\u001e06\u001d") && msg.endsWith("\u001e\u0004")) {
            macroId = 6;
            msg = msg.substring("[)>\u001e06\u001d".length(), msg.length() - 2);
        }
        return new String(encode(msg, priorityCharset, fnc1, shape, macroId), StandardCharsets.ISO_8859_1);
    }

    static byte[] encode(String input, Charset priorityCharset, int fnc1, SymbolShapeHint shape, int macroId) {
        return encodeMinimally(new Input(input, priorityCharset, fnc1, shape, macroId, null)).getBytes();
    }

    static void addEdge(Edge[][] edges, Edge edge) {
        int vertexIndex = edge.fromPosition + edge.characterLength;
        if (edges[vertexIndex][edge.getEndMode().ordinal()] == null || edges[vertexIndex][edge.getEndMode().ordinal()].cachedTotalSize > edge.cachedTotalSize) {
            edges[vertexIndex][edge.getEndMode().ordinal()] = edge;
        }
    }

    static int getNumberOfC40Words(Input input, int from, boolean c40, int[] characterLength) {
        int thirdsCount = 0;
        for (int i = from; i < input.length(); i++) {
            if (input.isECI(i)) {
                characterLength[0] = 0;
                return 0;
            }
            char ci = input.charAt(i);
            if ((c40 && HighLevelEncoder.isNativeC40(ci)) || (!c40 && HighLevelEncoder.isNativeText(ci))) {
                thirdsCount++;
            } else if (!isExtendedASCII(ci, input.getFNC1Character())) {
                thirdsCount += 2;
            } else {
                int asciiValue = ci & 255;
                if (asciiValue >= 128 && ((c40 && HighLevelEncoder.isNativeC40((char) (asciiValue - 128))) || (!c40 && HighLevelEncoder.isNativeText((char) (asciiValue - 128))))) {
                    thirdsCount += 3;
                } else {
                    thirdsCount += 4;
                }
            }
            if (thirdsCount % 3 == 0 || ((thirdsCount - 2) % 3 == 0 && i + 1 == input.length())) {
                characterLength[0] = (i - from) + 1;
                return (int) Math.ceil(thirdsCount / 3.0d);
            }
        }
        characterLength[0] = 0;
        return 0;
    }

    static void addEdges(Input input, Edge[][] edges, int from, Edge previous) {
        int i;
        if (input.isECI(from)) {
            addEdge(edges, new Edge(input, Mode.ASCII, from, 1, previous, null));
            return;
        }
        char ch = input.charAt(from);
        if (previous == null || previous.getEndMode() != Mode.EDF) {
            if (HighLevelEncoder.isDigit(ch) && input.haveNCharacters(from, 2) && HighLevelEncoder.isDigit(input.charAt(from + 1))) {
                addEdge(edges, new Edge(input, Mode.ASCII, from, 2, previous, null));
            } else {
                addEdge(edges, new Edge(input, Mode.ASCII, from, 1, previous, null));
            }
            char c = 0;
            Mode[] modes = {Mode.C40, Mode.TEXT};
            int length = modes.length;
            int i2 = 0;
            while (i2 < length) {
                Mode mode = modes[i2];
                int[] characterLength = new int[1];
                if (getNumberOfC40Words(input, from, mode == Mode.C40, characterLength) > 0) {
                    i = i2;
                    addEdge(edges, new Edge(input, mode, from, characterLength[c], previous, null));
                } else {
                    i = i2;
                }
                i2 = i + 1;
                c = 0;
            }
            if (input.haveNCharacters(from, 3) && HighLevelEncoder.isNativeX12(input.charAt(from)) && HighLevelEncoder.isNativeX12(input.charAt(from + 1)) && HighLevelEncoder.isNativeX12(input.charAt(from + 2))) {
                addEdge(edges, new Edge(input, Mode.X12, from, 3, previous, null));
            }
            addEdge(edges, new Edge(input, Mode.B256, from, 1, previous, null));
        }
        int i3 = 0;
        while (i3 < 3) {
            int pos = from + i3;
            if (!input.haveNCharacters(pos, 1) || !HighLevelEncoder.isNativeEDIFACT(input.charAt(pos))) {
                break;
            }
            addEdge(edges, new Edge(input, Mode.EDF, from, i3 + 1, previous, null));
            i3++;
        }
        if (i3 == 3 && input.haveNCharacters(from, 4) && HighLevelEncoder.isNativeEDIFACT(input.charAt(from + 3))) {
            addEdge(edges, new Edge(input, Mode.EDF, from, 4, previous, null));
        }
    }

    static Result encodeMinimally(Input input) {
        int i;
        int inputLength = input.length();
        Edge[][] edges = (Edge[][]) Array.newInstance((Class<?>) Edge.class, inputLength + 1, 6);
        addEdges(input, edges, 0, null);
        for (int i2 = 1; i2 <= inputLength; i2++) {
            for (int j = 0; j < 6; j++) {
                if (edges[i2][j] != null && i2 < inputLength) {
                    addEdges(input, edges, i2, edges[i2][j]);
                }
            }
            for (int j2 = 0; j2 < 6; j2++) {
                edges[i2 - 1][j2] = null;
            }
        }
        int minimalJ = -1;
        int minimalSize = Integer.MAX_VALUE;
        for (int j3 = 0; j3 < 6; j3++) {
            if (edges[inputLength][j3] != null) {
                Edge edge = edges[inputLength][j3];
                if (j3 >= 1 && j3 <= 3) {
                    i = edge.cachedTotalSize + 1;
                } else {
                    i = edge.cachedTotalSize;
                }
                int size = i;
                if (size < minimalSize) {
                    minimalSize = size;
                    minimalJ = j3;
                }
            }
        }
        if (minimalJ < 0) {
            throw new IllegalStateException("Failed to encode \"" + input + "\"");
        }
        return new Result(edges[inputLength][minimalJ]);
    }

    private static final class Edge {
        static final /* synthetic */ boolean $assertionsDisabled = false;
        private final int cachedTotalSize;
        private final int characterLength;
        private final int fromPosition;
        private final Input input;
        private final Mode mode;
        private final Edge previous;
        private static final int[] allCodewordCapacities = {3, 5, 8, 10, 12, 16, 18, 22, 30, 32, 36, 44, 49, 62, 86, 114, 144, 174, 204, 280, 368, 456, 576, 696, 816, 1050, 1304, 1558};
        private static final int[] squareCodewordCapacities = {3, 5, 8, 12, 18, 22, 30, 36, 44, 62, 86, 114, 144, 174, 204, 280, 368, 456, 576, 696, 816, 1050, 1304, 1558};
        private static final int[] rectangularCodewordCapacities = {5, 10, 16, 33, 32, 49};

        /* synthetic */ Edge(Input x0, Mode x1, int x2, int x3, Edge x4, AnonymousClass1 x5) {
            this(x0, x1, x2, x3, x4);
        }

        private Edge(Input input, Mode mode, int fromPosition, int characterLength, Edge previous) {
            this.input = input;
            this.mode = mode;
            this.fromPosition = fromPosition;
            this.characterLength = characterLength;
            this.previous = previous;
            if (fromPosition + characterLength > input.length()) {
                throw new AssertionError();
            }
            int size = previous != null ? previous.cachedTotalSize : 0;
            Mode previousMode = getPreviousMode();
            switch (AnonymousClass1.$SwitchMap$com$google$zxing$datamatrix$encoder$MinimalEncoder$Mode[mode.ordinal()]) {
                case 1:
                    size++;
                    size = (input.isECI(fromPosition) || MinimalEncoder.isExtendedASCII(input.charAt(fromPosition), input.getFNC1Character())) ? size + 1 : size;
                    if (previousMode == Mode.C40 || previousMode == Mode.TEXT || previousMode == Mode.X12) {
                        size++;
                        break;
                    }
                    break;
                case 2:
                    size++;
                    if (previousMode != Mode.B256) {
                        size++;
                    } else if (getB256Size() == 250) {
                        size++;
                    }
                    if (previousMode == Mode.ASCII) {
                        size++;
                        break;
                    } else if (previousMode == Mode.C40 || previousMode == Mode.TEXT || previousMode == Mode.X12) {
                        size += 2;
                        break;
                    }
                    break;
                case 3:
                case 4:
                case 5:
                    if (mode == Mode.X12) {
                        size += 2;
                    } else {
                        int[] charLen = new int[1];
                        size += MinimalEncoder.getNumberOfC40Words(input, fromPosition, mode == Mode.C40, charLen) * 2;
                    }
                    if (previousMode == Mode.ASCII || previousMode == Mode.B256) {
                        size++;
                        break;
                    } else if (previousMode != mode && (previousMode == Mode.C40 || previousMode == Mode.TEXT || previousMode == Mode.X12)) {
                        size += 2;
                        break;
                    }
                    break;
                case 6:
                    size += 3;
                    if (previousMode == Mode.ASCII || previousMode == Mode.B256) {
                        size++;
                        break;
                    } else if (previousMode == Mode.C40 || previousMode == Mode.TEXT || previousMode == Mode.X12) {
                        size += 2;
                        break;
                    }
                    break;
            }
            this.cachedTotalSize = size;
        }

        int getB256Size() {
            int cnt = 0;
            for (Edge current = this; current != null && current.mode == Mode.B256 && cnt <= 250; current = current.previous) {
                cnt++;
            }
            return cnt;
        }

        Mode getPreviousStartMode() {
            Edge edge = this.previous;
            return edge == null ? Mode.ASCII : edge.mode;
        }

        Mode getPreviousMode() {
            Edge edge = this.previous;
            return edge == null ? Mode.ASCII : edge.getEndMode();
        }

        Mode getEndMode() {
            if (this.mode == Mode.EDF) {
                if (this.characterLength < 4) {
                    return Mode.ASCII;
                }
                int lastASCII = getLastASCII();
                if (lastASCII > 0 && getCodewordsRemaining(this.cachedTotalSize + lastASCII) <= 2 - lastASCII) {
                    return Mode.ASCII;
                }
            }
            if (this.mode == Mode.C40 || this.mode == Mode.TEXT || this.mode == Mode.X12) {
                if (this.fromPosition + this.characterLength >= this.input.length() && getCodewordsRemaining(this.cachedTotalSize) == 0) {
                    return Mode.ASCII;
                }
                if (getLastASCII() == 1 && getCodewordsRemaining(this.cachedTotalSize + 1) == 0) {
                    return Mode.ASCII;
                }
            }
            return this.mode;
        }

        Mode getMode() {
            return this.mode;
        }

        int getLastASCII() {
            int length = this.input.length();
            int from = this.fromPosition + this.characterLength;
            if (length - from > 4 || from >= length) {
                return 0;
            }
            if (length - from == 1) {
                return MinimalEncoder.isExtendedASCII(this.input.charAt(from), this.input.getFNC1Character()) ? 0 : 1;
            }
            if (length - from == 2) {
                if (MinimalEncoder.isExtendedASCII(this.input.charAt(from), this.input.getFNC1Character()) || MinimalEncoder.isExtendedASCII(this.input.charAt(from + 1), this.input.getFNC1Character())) {
                    return 0;
                }
                return (HighLevelEncoder.isDigit(this.input.charAt(from)) && HighLevelEncoder.isDigit(this.input.charAt(from + 1))) ? 1 : 2;
            }
            if (length - from != 3) {
                return (HighLevelEncoder.isDigit(this.input.charAt(from)) && HighLevelEncoder.isDigit(this.input.charAt(from + 1)) && HighLevelEncoder.isDigit(this.input.charAt(from + 2)) && HighLevelEncoder.isDigit(this.input.charAt(from + 3))) ? 2 : 0;
            }
            if (HighLevelEncoder.isDigit(this.input.charAt(from)) && HighLevelEncoder.isDigit(this.input.charAt(from + 1)) && !MinimalEncoder.isExtendedASCII(this.input.charAt(from + 2), this.input.getFNC1Character())) {
                return 2;
            }
            return (HighLevelEncoder.isDigit(this.input.charAt(from + 1)) && HighLevelEncoder.isDigit(this.input.charAt(from + 2)) && !MinimalEncoder.isExtendedASCII(this.input.charAt(from), this.input.getFNC1Character())) ? 2 : 0;
        }

        int getMinSymbolSize(int minimum) {
            switch (AnonymousClass1.$SwitchMap$com$google$zxing$datamatrix$encoder$SymbolShapeHint[this.input.getShapeHint().ordinal()]) {
                case 1:
                    for (int capacity : squareCodewordCapacities) {
                        if (capacity >= minimum) {
                            return capacity;
                        }
                    }
                    break;
                case 2:
                    for (int capacity2 : rectangularCodewordCapacities) {
                        if (capacity2 >= minimum) {
                            return capacity2;
                        }
                    }
                    break;
            }
            for (int capacity3 : allCodewordCapacities) {
                if (capacity3 >= minimum) {
                    return capacity3;
                }
            }
            return allCodewordCapacities[r0.length - 1];
        }

        int getCodewordsRemaining(int minimum) {
            return getMinSymbolSize(minimum) - minimum;
        }

        static byte[] getBytes(int c) {
            byte[] result = {(byte) c};
            return result;
        }

        static byte[] getBytes(int c1, int c2) {
            byte[] result = {(byte) c1, (byte) c2};
            return result;
        }

        static void setC40Word(byte[] bytes, int offset, int c1, int c2, int c3) {
            int val16 = ((c1 & 255) * 1600) + ((c2 & 255) * 40) + (c3 & 255) + 1;
            bytes[offset] = (byte) (val16 / 256);
            bytes[offset + 1] = (byte) (val16 % 256);
        }

        private static int getX12Value(char c) {
            if (c == '\r') {
                return 0;
            }
            if (c == '*') {
                return 1;
            }
            if (c == '>') {
                return 2;
            }
            if (c == ' ') {
                return 3;
            }
            return (c < '0' || c > '9') ? (c < 'A' || c > 'Z') ? c : c - '3' : c - ',';
        }

        byte[] getX12Words() {
            int i = this.characterLength;
            if (i % 3 != 0) {
                throw new AssertionError();
            }
            byte[] result = new byte[(i / 3) * 2];
            for (int i2 = 0; i2 < result.length; i2 += 2) {
                setC40Word(result, i2, getX12Value(this.input.charAt(this.fromPosition + ((i2 / 2) * 3))), getX12Value(this.input.charAt(this.fromPosition + ((i2 / 2) * 3) + 1)), getX12Value(this.input.charAt(this.fromPosition + ((i2 / 2) * 3) + 2)));
            }
            return result;
        }

        static int getShiftValue(char c, boolean c40, int fnc1) {
            if (!(c40 && MinimalEncoder.isInC40Shift1Set(c)) && (c40 || !MinimalEncoder.isInTextShift1Set(c))) {
                return (!(c40 && MinimalEncoder.isInC40Shift2Set(c, fnc1)) && (c40 || !MinimalEncoder.isInTextShift2Set(c, fnc1))) ? 2 : 1;
            }
            return 0;
        }

        private static int getC40Value(boolean c40, int setIndex, char c, int fnc1) {
            if (c == fnc1) {
                if (setIndex != 2) {
                    throw new AssertionError();
                }
                return 27;
            }
            if (c40) {
                if (c > 31) {
                    if (c == ' ') {
                        return 3;
                    }
                    if (c <= '/') {
                        return c - '!';
                    }
                    if (c <= '9') {
                        return c - ',';
                    }
                    if (c <= '@') {
                        return c - '+';
                    }
                    if (c <= 'Z') {
                        return c - '3';
                    }
                    if (c <= '_') {
                        return c - 'E';
                    }
                    if (c <= 127) {
                        return c - '`';
                    }
                }
                return c;
            }
            if (c != 0) {
                if (setIndex == 0 && c <= 3) {
                    return c - 1;
                }
                if (setIndex != 1 || c > 31) {
                    if (c == ' ') {
                        return 3;
                    }
                    if (c >= '!' && c <= '/') {
                        return c - '!';
                    }
                    if (c >= '0' && c <= '9') {
                        return c - ',';
                    }
                    if (c >= ':' && c <= '@') {
                        return c - '+';
                    }
                    if (c >= 'A' && c <= 'Z') {
                        return c - '@';
                    }
                    if (c >= '[' && c <= '_') {
                        return c - 'E';
                    }
                    if (c != '`') {
                        if (c >= 'a' && c <= 'z') {
                            return c - 'S';
                        }
                        if (c >= '{' && c <= 127) {
                            return c - '`';
                        }
                    }
                }
                return c;
            }
            return 0;
        }

        byte[] getC40Words(boolean c40, int fnc1) {
            List<Byte> c40Values = new ArrayList<>();
            for (int i = 0; i < this.characterLength; i++) {
                char ci = this.input.charAt(this.fromPosition + i);
                if ((c40 && HighLevelEncoder.isNativeC40(ci)) || (!c40 && HighLevelEncoder.isNativeText(ci))) {
                    c40Values.add(Byte.valueOf((byte) getC40Value(c40, 0, ci, fnc1)));
                } else if (!MinimalEncoder.isExtendedASCII(ci, fnc1)) {
                    int shiftValue = getShiftValue(ci, c40, fnc1);
                    c40Values.add(Byte.valueOf((byte) shiftValue));
                    c40Values.add(Byte.valueOf((byte) getC40Value(c40, shiftValue, ci, fnc1)));
                } else {
                    char asciiValue = (char) ((ci & 255) - 128);
                    if ((c40 && HighLevelEncoder.isNativeC40(asciiValue)) || (!c40 && HighLevelEncoder.isNativeText(asciiValue))) {
                        c40Values.add((byte) 1);
                        c40Values.add((byte) 30);
                        c40Values.add(Byte.valueOf((byte) getC40Value(c40, 0, asciiValue, fnc1)));
                    } else {
                        c40Values.add((byte) 1);
                        c40Values.add((byte) 30);
                        int shiftValue2 = getShiftValue(asciiValue, c40, fnc1);
                        c40Values.add(Byte.valueOf((byte) shiftValue2));
                        c40Values.add(Byte.valueOf((byte) getC40Value(c40, shiftValue2, asciiValue, fnc1)));
                    }
                }
            }
            int i2 = c40Values.size();
            if (i2 % 3 != 0) {
                if ((c40Values.size() - 2) % 3 != 0 || this.fromPosition + this.characterLength != this.input.length()) {
                    throw new AssertionError();
                }
                c40Values.add((byte) 0);
            }
            byte[] result = new byte[(c40Values.size() / 3) * 2];
            int byteIndex = 0;
            for (int i3 = 0; i3 < c40Values.size(); i3 += 3) {
                setC40Word(result, byteIndex, c40Values.get(i3).byteValue() & UByte.MAX_VALUE, c40Values.get(i3 + 1).byteValue() & UByte.MAX_VALUE, c40Values.get(i3 + 2).byteValue() & UByte.MAX_VALUE);
                byteIndex += 2;
            }
            return result;
        }

        byte[] getEDFBytes() {
            int numberOfThirds = (int) Math.ceil(this.characterLength / 4.0d);
            byte[] result = new byte[numberOfThirds * 3];
            int pos = this.fromPosition;
            int endPos = Math.min((this.fromPosition + this.characterLength) - 1, this.input.length() - 1);
            for (int i = 0; i < numberOfThirds; i += 3) {
                int[] edfValues = new int[4];
                int j = 0;
                while (true) {
                    if (j < 4) {
                        if (pos <= endPos) {
                            edfValues[j] = this.input.charAt(pos) & 63;
                            pos++;
                        } else {
                            int pos2 = endPos + 1;
                            edfValues[j] = pos == pos2 ? 31 : 0;
                        }
                        j++;
                    }
                }
                int val24 = (edfValues[0] << 18) | (edfValues[1] << 12) | (edfValues[2] << 6) | edfValues[3];
                result[i] = (byte) ((val24 >> 16) & 255);
                result[i + 1] = (byte) ((val24 >> 8) & 255);
                result[i + 2] = (byte) (val24 & 255);
            }
            return result;
        }

        byte[] getLatchBytes() {
            switch (AnonymousClass1.$SwitchMap$com$google$zxing$datamatrix$encoder$MinimalEncoder$Mode[getPreviousMode().ordinal()]) {
                case 1:
                case 2:
                    switch (this.mode) {
                        case B256:
                            return getBytes(231);
                        case C40:
                            return getBytes(230);
                        case TEXT:
                            return getBytes(239);
                        case X12:
                            return getBytes(238);
                        case EDF:
                            return getBytes(240);
                    }
                case 3:
                case 4:
                case 5:
                    if (this.mode != getPreviousMode()) {
                        switch (AnonymousClass1.$SwitchMap$com$google$zxing$datamatrix$encoder$MinimalEncoder$Mode[this.mode.ordinal()]) {
                            case 1:
                                return getBytes(254);
                            case 2:
                                return getBytes(254, 231);
                            case 3:
                                return getBytes(254, 230);
                            case 4:
                                return getBytes(254, 239);
                            case 5:
                                return getBytes(254, 238);
                            case 6:
                                return getBytes(254, 240);
                        }
                    }
                    break;
                case 6:
                    if (this.mode != Mode.EDF) {
                        throw new AssertionError();
                    }
                    break;
            }
            return new byte[0];
        }

        byte[] getDataBytes() {
            switch (AnonymousClass1.$SwitchMap$com$google$zxing$datamatrix$encoder$MinimalEncoder$Mode[this.mode.ordinal()]) {
                case 1:
                    if (this.input.isECI(this.fromPosition)) {
                        return getBytes(241, this.input.getECIValue(this.fromPosition) + 1);
                    }
                    if (MinimalEncoder.isExtendedASCII(this.input.charAt(this.fromPosition), this.input.getFNC1Character())) {
                        return getBytes(235, this.input.charAt(this.fromPosition) - 127);
                    }
                    if (this.characterLength == 2) {
                        return getBytes(((((this.input.charAt(this.fromPosition) - '0') * 10) + this.input.charAt(this.fromPosition + 1)) - 48) + 130);
                    }
                    if (this.input.isFNC1(this.fromPosition)) {
                        return getBytes(232);
                    }
                    return getBytes(this.input.charAt(this.fromPosition) + 1);
                case 2:
                    return getBytes(this.input.charAt(this.fromPosition));
                case 3:
                    return getC40Words(true, this.input.getFNC1Character());
                case 4:
                    return getC40Words(false, this.input.getFNC1Character());
                case 5:
                    return getX12Words();
                case 6:
                    return getEDFBytes();
                default:
                    throw new AssertionError();
            }
        }
    }

    /* renamed from: com.google.zxing.datamatrix.encoder.MinimalEncoder$1, reason: invalid class name */
    static /* synthetic */ class AnonymousClass1 {
        static final /* synthetic */ int[] $SwitchMap$com$google$zxing$datamatrix$encoder$SymbolShapeHint;

        static {
            int[] iArr = new int[SymbolShapeHint.values().length];
            $SwitchMap$com$google$zxing$datamatrix$encoder$SymbolShapeHint = iArr;
            try {
                iArr[SymbolShapeHint.FORCE_SQUARE.ordinal()] = 1;
            } catch (NoSuchFieldError e) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$encoder$SymbolShapeHint[SymbolShapeHint.FORCE_RECTANGLE.ordinal()] = 2;
            } catch (NoSuchFieldError e2) {
            }
            int[] iArr2 = new int[Mode.values().length];
            $SwitchMap$com$google$zxing$datamatrix$encoder$MinimalEncoder$Mode = iArr2;
            try {
                iArr2[Mode.ASCII.ordinal()] = 1;
            } catch (NoSuchFieldError e3) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$encoder$MinimalEncoder$Mode[Mode.B256.ordinal()] = 2;
            } catch (NoSuchFieldError e4) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$encoder$MinimalEncoder$Mode[Mode.C40.ordinal()] = 3;
            } catch (NoSuchFieldError e5) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$encoder$MinimalEncoder$Mode[Mode.TEXT.ordinal()] = 4;
            } catch (NoSuchFieldError e6) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$encoder$MinimalEncoder$Mode[Mode.X12.ordinal()] = 5;
            } catch (NoSuchFieldError e7) {
            }
            try {
                $SwitchMap$com$google$zxing$datamatrix$encoder$MinimalEncoder$Mode[Mode.EDF.ordinal()] = 6;
            } catch (NoSuchFieldError e8) {
            }
        }
    }

    private static final class Result {
        private final byte[] bytes;

        Result(Edge solution) {
            int size;
            Input input = solution.input;
            int size2 = 0;
            List<Byte> bytesAL = new ArrayList<>();
            List<Integer> randomizePostfixLength = new ArrayList<>();
            List<Integer> randomizeLengths = new ArrayList<>();
            if ((solution.mode == Mode.C40 || solution.mode == Mode.TEXT || solution.mode == Mode.X12) && solution.getEndMode() != Mode.ASCII) {
                size2 = 0 + prepend(Edge.getBytes(254), bytesAL);
            }
            for (Edge current = solution; current != null; current = current.previous) {
                size2 += prepend(current.getDataBytes(), bytesAL);
                if (current.previous == null || current.getPreviousStartMode() != current.getMode()) {
                    if (current.getMode() == Mode.B256) {
                        if (size2 <= 249) {
                            bytesAL.add(0, Byte.valueOf((byte) size2));
                            size = size2 + 1;
                        } else {
                            bytesAL.add(0, Byte.valueOf((byte) (size2 % 250)));
                            bytesAL.add(0, Byte.valueOf((byte) ((size2 / 250) + 249)));
                            size = size2 + 2;
                        }
                        randomizePostfixLength.add(Integer.valueOf(bytesAL.size()));
                        randomizeLengths.add(Integer.valueOf(size));
                    }
                    prepend(current.getLatchBytes(), bytesAL);
                    size2 = 0;
                }
            }
            if (input.getMacroId() == 5) {
                size2 += prepend(Edge.getBytes(236), bytesAL);
            } else if (input.getMacroId() == 6) {
                size2 += prepend(Edge.getBytes(237), bytesAL);
            }
            if (input.getFNC1Character() > 0) {
                int prepend = size2 + prepend(Edge.getBytes(232), bytesAL);
            }
            for (int i = 0; i < randomizePostfixLength.size(); i++) {
                applyRandomPattern(bytesAL, bytesAL.size() - randomizePostfixLength.get(i).intValue(), randomizeLengths.get(i).intValue());
            }
            int i2 = bytesAL.size();
            int capacity = solution.getMinSymbolSize(i2);
            if (bytesAL.size() < capacity) {
                bytesAL.add((byte) -127);
            }
            while (bytesAL.size() < capacity) {
                bytesAL.add(Byte.valueOf((byte) randomize253State(bytesAL.size() + 1)));
            }
            this.bytes = new byte[bytesAL.size()];
            int i3 = 0;
            while (true) {
                byte[] bArr = this.bytes;
                if (i3 < bArr.length) {
                    bArr[i3] = bytesAL.get(i3).byteValue();
                    i3++;
                } else {
                    return;
                }
            }
        }

        static int prepend(byte[] bytes, List<Byte> into) {
            for (int i = bytes.length - 1; i >= 0; i--) {
                into.add(0, Byte.valueOf(bytes[i]));
            }
            int i2 = bytes.length;
            return i2;
        }

        private static int randomize253State(int codewordPosition) {
            int pseudoRandom = ((codewordPosition * 149) % 253) + 1;
            int tempVariable = pseudoRandom + 129;
            return tempVariable <= 254 ? tempVariable : tempVariable - 254;
        }

        static void applyRandomPattern(List<Byte> bytesAL, int startPosition, int length) {
            for (int i = 0; i < length; i++) {
                int Pad_codeword_position = startPosition + i;
                int Pad_codeword_value = bytesAL.get(Pad_codeword_position).byteValue() & UByte.MAX_VALUE;
                int pseudo_random_number = (((Pad_codeword_position + 1) * 149) % 255) + 1;
                int temp_variable = Pad_codeword_value + pseudo_random_number;
                bytesAL.set(Pad_codeword_position, Byte.valueOf((byte) (temp_variable <= 255 ? temp_variable : temp_variable + InputDeviceCompat.SOURCE_ANY)));
            }
        }

        public byte[] getBytes() {
            return this.bytes;
        }
    }

    private static final class Input extends MinimalECIInput {
        private final int macroId;
        private final SymbolShapeHint shape;

        /* synthetic */ Input(String x0, Charset x1, int x2, SymbolShapeHint x3, int x4, AnonymousClass1 x5) {
            this(x0, x1, x2, x3, x4);
        }

        private Input(String stringToEncode, Charset priorityCharset, int fnc1, SymbolShapeHint shape, int macroId) {
            super(stringToEncode, priorityCharset, fnc1);
            this.shape = shape;
            this.macroId = macroId;
        }

        /* JADX INFO: Access modifiers changed from: private */
        public int getMacroId() {
            return this.macroId;
        }

        /* JADX INFO: Access modifiers changed from: private */
        public SymbolShapeHint getShapeHint() {
            return this.shape;
        }
    }
}
