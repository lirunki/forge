package com.google.zxing.common;

import androidx.core.view.InputDeviceCompat;
import java.lang.reflect.Array;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import kotlin.UByte;

/* loaded from: classes.dex */
public class MinimalECIInput implements ECIInput {
    private static final int COST_PER_ECI = 3;
    private final int[] bytes;
    private final int fnc1;

    public MinimalECIInput(String stringToEncode, Charset priorityCharset, int fnc1) {
        this.fnc1 = fnc1;
        ECIEncoderSet encoderSet = new ECIEncoderSet(stringToEncode, priorityCharset, fnc1);
        if (encoderSet.length() == 1) {
            this.bytes = new int[stringToEncode.length()];
            for (int i = 0; i < this.bytes.length; i++) {
                char c = stringToEncode.charAt(i);
                this.bytes[i] = c == fnc1 ? (char) 1000 : c;
            }
            return;
        }
        this.bytes = encodeMinimally(stringToEncode, encoderSet, fnc1);
    }

    public int getFNC1Character() {
        return this.fnc1;
    }

    @Override // com.google.zxing.common.ECIInput
    public int length() {
        return this.bytes.length;
    }

    @Override // com.google.zxing.common.ECIInput
    public boolean haveNCharacters(int index, int n) {
        if ((index + n) - 1 >= this.bytes.length) {
            return false;
        }
        for (int i = 0; i < n; i++) {
            if (isECI(index + i)) {
                return false;
            }
        }
        return true;
    }

    @Override // com.google.zxing.common.ECIInput
    public char charAt(int index) {
        if (index < 0 || index >= length()) {
            throw new IndexOutOfBoundsException("" + index);
        }
        if (isECI(index)) {
            throw new IllegalArgumentException("value at " + index + " is not a character but an ECI");
        }
        return (char) (isFNC1(index) ? this.fnc1 : this.bytes[index]);
    }

    @Override // com.google.zxing.common.ECIInput
    public CharSequence subSequence(int start, int end) {
        if (start < 0 || start > end || end > length()) {
            throw new IndexOutOfBoundsException("" + start);
        }
        StringBuilder result = new StringBuilder();
        for (int i = start; i < end; i++) {
            if (isECI(i)) {
                throw new IllegalArgumentException("value at " + i + " is not a character but an ECI");
            }
            result.append(charAt(i));
        }
        return result;
    }

    @Override // com.google.zxing.common.ECIInput
    public boolean isECI(int index) {
        if (index < 0 || index >= length()) {
            throw new IndexOutOfBoundsException("" + index);
        }
        int i = this.bytes[index];
        return i > 255 && i <= 999;
    }

    public boolean isFNC1(int index) {
        if (index < 0 || index >= length()) {
            throw new IndexOutOfBoundsException("" + index);
        }
        return this.bytes[index] == 1000;
    }

    @Override // com.google.zxing.common.ECIInput
    public int getECIValue(int index) {
        if (index < 0 || index >= length()) {
            throw new IndexOutOfBoundsException("" + index);
        }
        if (!isECI(index)) {
            throw new IllegalArgumentException("value at " + index + " is not an ECI but a character");
        }
        return this.bytes[index] + InputDeviceCompat.SOURCE_ANY;
    }

    public String toString() {
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < length(); i++) {
            if (i > 0) {
                result.append(", ");
            }
            if (isECI(i)) {
                result.append("ECI(");
                result.append(getECIValue(i));
                result.append(')');
            } else if (charAt(i) < 128) {
                result.append('\'');
                result.append(charAt(i));
                result.append('\'');
            } else {
                result.append((int) charAt(i));
            }
        }
        return result.toString();
    }

    static void addEdge(InputEdge[][] edges, int to, InputEdge edge) {
        if (edges[to][edge.encoderIndex] != null && edges[to][edge.encoderIndex].cachedTotalSize <= edge.cachedTotalSize) {
            return;
        }
        edges[to][edge.encoderIndex] = edge;
    }

    static void addEdges(String stringToEncode, ECIEncoderSet encoderSet, InputEdge[][] edges, int from, InputEdge previous, int fnc1) {
        int start;
        int end;
        ECIEncoderSet eCIEncoderSet = encoderSet;
        char ch = stringToEncode.charAt(from);
        int end2 = encoderSet.length();
        if (encoderSet.getPriorityEncoderIndex() >= 0 && (ch == fnc1 || eCIEncoderSet.canEncode(ch, encoderSet.getPriorityEncoderIndex()))) {
            int start2 = encoderSet.getPriorityEncoderIndex();
            int end3 = start2 + 1;
            start = start2;
            end = end3;
        } else {
            start = 0;
            end = end2;
        }
        int i = start;
        while (i < end) {
            if (ch == fnc1 || eCIEncoderSet.canEncode(ch, i)) {
                addEdge(edges, from + 1, new InputEdge(ch, encoderSet, i, previous, fnc1));
            }
            i++;
            eCIEncoderSet = encoderSet;
        }
    }

    static int[] encodeMinimally(String stringToEncode, ECIEncoderSet encoderSet, int fnc1) {
        int inputLength = stringToEncode.length();
        InputEdge[][] edges = (InputEdge[][]) Array.newInstance((Class<?>) InputEdge.class, inputLength + 1, encoderSet.length());
        addEdges(stringToEncode, encoderSet, edges, 0, null, fnc1);
        for (int i = 1; i <= inputLength; i++) {
            for (int j = 0; j < encoderSet.length(); j++) {
                if (edges[i][j] != null && i < inputLength) {
                    addEdges(stringToEncode, encoderSet, edges, i, edges[i][j], fnc1);
                }
            }
            for (int j2 = 0; j2 < encoderSet.length(); j2++) {
                edges[i - 1][j2] = null;
            }
        }
        int minimalJ = -1;
        int minimalSize = Integer.MAX_VALUE;
        for (int j3 = 0; j3 < encoderSet.length(); j3++) {
            if (edges[inputLength][j3] != null) {
                InputEdge edge = edges[inputLength][j3];
                if (edge.cachedTotalSize < minimalSize) {
                    minimalSize = edge.cachedTotalSize;
                    minimalJ = j3;
                }
            }
        }
        if (minimalJ < 0) {
            throw new IllegalStateException("Failed to encode \"" + stringToEncode + "\"");
        }
        List<Integer> intsAL = new ArrayList<>();
        for (InputEdge current = edges[inputLength][minimalJ]; current != null; current = current.previous) {
            if (current.isFNC1()) {
                intsAL.add(0, 1000);
            } else {
                byte[] bytes = encoderSet.encode(current.c, current.encoderIndex);
                for (int i2 = bytes.length - 1; i2 >= 0; i2--) {
                    intsAL.add(0, Integer.valueOf(bytes[i2] & UByte.MAX_VALUE));
                }
            }
            int previousEncoderIndex = current.previous == null ? 0 : current.previous.encoderIndex;
            if (previousEncoderIndex != current.encoderIndex) {
                intsAL.add(0, Integer.valueOf(encoderSet.getECIValue(current.encoderIndex) + 256));
            }
        }
        int[] ints = new int[intsAL.size()];
        for (int i3 = 0; i3 < ints.length; i3++) {
            ints[i3] = intsAL.get(i3).intValue();
        }
        return ints;
    }

    private static final class InputEdge {
        private final char c;
        private final int cachedTotalSize;
        private final int encoderIndex;
        private final InputEdge previous;

        private InputEdge(char c, ECIEncoderSet encoderSet, int encoderIndex, InputEdge previous, int fnc1) {
            char c2 = c == fnc1 ? (char) 1000 : c;
            this.c = c2;
            this.encoderIndex = encoderIndex;
            this.previous = previous;
            int size = c2 == 1000 ? 1 : encoderSet.encode(c, encoderIndex).length;
            int previousEncoderIndex = previous == null ? 0 : previous.encoderIndex;
            size = previousEncoderIndex != encoderIndex ? size + 3 : size;
            this.cachedTotalSize = previous != null ? size + previous.cachedTotalSize : size;
        }

        boolean isFNC1() {
            return this.c == 1000;
        }
    }
}
