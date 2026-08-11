package com.google.zxing.qrcode.encoder;

import com.google.zxing.WriterException;
import com.google.zxing.common.BitArray;
import com.google.zxing.common.ECIEncoderSet;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import com.google.zxing.qrcode.decoder.Mode;
import com.google.zxing.qrcode.decoder.Version;
import java.lang.reflect.Array;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

/* loaded from: classes.dex */
final class MinimalEncoder {
    private final ErrorCorrectionLevel ecLevel;
    private final ECIEncoderSet encoders;
    private final boolean isGS1;
    private final String stringToEncode;

    private enum VersionSize {
        SMALL("version 1-9"),
        MEDIUM("version 10-26"),
        LARGE("version 27-40");

        private final String description;

        VersionSize(String description) {
            this.description = description;
        }

        @Override // java.lang.Enum
        public String toString() {
            return this.description;
        }
    }

    MinimalEncoder(String stringToEncode, Charset priorityCharset, boolean isGS1, ErrorCorrectionLevel ecLevel) {
        this.stringToEncode = stringToEncode;
        this.isGS1 = isGS1;
        this.encoders = new ECIEncoderSet(stringToEncode, priorityCharset, -1);
        this.ecLevel = ecLevel;
    }

    static ResultList encode(String stringToEncode, Version version, Charset priorityCharset, boolean isGS1, ErrorCorrectionLevel ecLevel) throws WriterException {
        return new MinimalEncoder(stringToEncode, priorityCharset, isGS1, ecLevel).encode(version);
    }

    ResultList encode(Version version) throws WriterException {
        if (version == null) {
            Version[] versions = {getVersion(VersionSize.SMALL), getVersion(VersionSize.MEDIUM), getVersion(VersionSize.LARGE)};
            ResultList[] results = {encodeSpecificVersion(versions[0]), encodeSpecificVersion(versions[1]), encodeSpecificVersion(versions[2])};
            int smallestSize = Integer.MAX_VALUE;
            int smallestResult = -1;
            for (int i = 0; i < 3; i++) {
                int size = results[i].getSize();
                if (Encoder.willFit(size, versions[i], this.ecLevel) && size < smallestSize) {
                    smallestSize = size;
                    smallestResult = i;
                }
            }
            if (smallestResult < 0) {
                throw new WriterException("Data too big for any version");
            }
            return results[smallestResult];
        }
        ResultList result = encodeSpecificVersion(version);
        if (!Encoder.willFit(result.getSize(), getVersion(getVersionSize(result.getVersion())), this.ecLevel)) {
            throw new WriterException("Data too big for version" + version);
        }
        return result;
    }

    static VersionSize getVersionSize(Version version) {
        return version.getVersionNumber() <= 9 ? VersionSize.SMALL : version.getVersionNumber() <= 26 ? VersionSize.MEDIUM : VersionSize.LARGE;
    }

    static Version getVersion(VersionSize versionSize) {
        switch (AnonymousClass1.$SwitchMap$com$google$zxing$qrcode$encoder$MinimalEncoder$VersionSize[versionSize.ordinal()]) {
            case 1:
                return Version.getVersionForNumber(9);
            case 2:
                return Version.getVersionForNumber(26);
            default:
                return Version.getVersionForNumber(40);
        }
    }

    static boolean isNumeric(char c) {
        return c >= '0' && c <= '9';
    }

    static boolean isDoubleByteKanji(char c) {
        return Encoder.isOnlyDoubleByteKanji(String.valueOf(c));
    }

    static boolean isAlphanumeric(char c) {
        return Encoder.getAlphanumericCode(c) != -1;
    }

    /* renamed from: com.google.zxing.qrcode.encoder.MinimalEncoder$1, reason: invalid class name */
    static /* synthetic */ class AnonymousClass1 {
        static final /* synthetic */ int[] $SwitchMap$com$google$zxing$qrcode$decoder$Mode;
        static final /* synthetic */ int[] $SwitchMap$com$google$zxing$qrcode$encoder$MinimalEncoder$VersionSize;

        static {
            int[] iArr = new int[Mode.values().length];
            $SwitchMap$com$google$zxing$qrcode$decoder$Mode = iArr;
            try {
                iArr[Mode.KANJI.ordinal()] = 1;
            } catch (NoSuchFieldError e) {
            }
            try {
                $SwitchMap$com$google$zxing$qrcode$decoder$Mode[Mode.ALPHANUMERIC.ordinal()] = 2;
            } catch (NoSuchFieldError e2) {
            }
            try {
                $SwitchMap$com$google$zxing$qrcode$decoder$Mode[Mode.NUMERIC.ordinal()] = 3;
            } catch (NoSuchFieldError e3) {
            }
            try {
                $SwitchMap$com$google$zxing$qrcode$decoder$Mode[Mode.BYTE.ordinal()] = 4;
            } catch (NoSuchFieldError e4) {
            }
            try {
                $SwitchMap$com$google$zxing$qrcode$decoder$Mode[Mode.ECI.ordinal()] = 5;
            } catch (NoSuchFieldError e5) {
            }
            int[] iArr2 = new int[VersionSize.values().length];
            $SwitchMap$com$google$zxing$qrcode$encoder$MinimalEncoder$VersionSize = iArr2;
            try {
                iArr2[VersionSize.SMALL.ordinal()] = 1;
            } catch (NoSuchFieldError e6) {
            }
            try {
                $SwitchMap$com$google$zxing$qrcode$encoder$MinimalEncoder$VersionSize[VersionSize.MEDIUM.ordinal()] = 2;
            } catch (NoSuchFieldError e7) {
            }
            try {
                $SwitchMap$com$google$zxing$qrcode$encoder$MinimalEncoder$VersionSize[VersionSize.LARGE.ordinal()] = 3;
            } catch (NoSuchFieldError e8) {
            }
        }
    }

    boolean canEncode(Mode mode, char c) {
        switch (AnonymousClass1.$SwitchMap$com$google$zxing$qrcode$decoder$Mode[mode.ordinal()]) {
            case 1:
                return isDoubleByteKanji(c);
            case 2:
                return isAlphanumeric(c);
            case 3:
                return isNumeric(c);
            case 4:
                return true;
            default:
                return false;
        }
    }

    static int getCompactedOrdinal(Mode mode) {
        if (mode == null) {
            return 0;
        }
        switch (AnonymousClass1.$SwitchMap$com$google$zxing$qrcode$decoder$Mode[mode.ordinal()]) {
            case 1:
                return 0;
            case 2:
                return 1;
            case 3:
                return 2;
            case 4:
                return 3;
            default:
                throw new IllegalStateException("Illegal mode " + mode);
        }
    }

    void addEdge(Edge[][][] edges, int position, Edge edge) {
        int vertexIndex = edge.characterLength + position;
        Edge[] modeEdges = edges[vertexIndex][edge.charsetEncoderIndex];
        int modeOrdinal = getCompactedOrdinal(edge.mode);
        if (modeEdges[modeOrdinal] == null || modeEdges[modeOrdinal].cachedTotalSize > edge.cachedTotalSize) {
            modeEdges[modeOrdinal] = edge;
        }
    }

    void addEdges(Version version, Edge[][][] edges, int from, Edge previous) {
        int start;
        int end;
        int i;
        int priorityEncoderIndex;
        int end2 = this.encoders.length();
        int priorityEncoderIndex2 = this.encoders.getPriorityEncoderIndex();
        if (priorityEncoderIndex2 >= 0 && this.encoders.canEncode(this.stringToEncode.charAt(from), priorityEncoderIndex2)) {
            int end3 = priorityEncoderIndex2 + 1;
            start = priorityEncoderIndex2;
            end = end3;
        } else {
            start = 0;
            end = end2;
        }
        int i2 = start;
        while (i2 < end) {
            if (this.encoders.canEncode(this.stringToEncode.charAt(from), i2)) {
                priorityEncoderIndex = priorityEncoderIndex2;
                addEdge(edges, from, new Edge(this, Mode.BYTE, from, i2, 1, previous, version, null));
            } else {
                priorityEncoderIndex = priorityEncoderIndex2;
            }
            i2++;
            priorityEncoderIndex2 = priorityEncoderIndex;
        }
        if (canEncode(Mode.KANJI, this.stringToEncode.charAt(from))) {
            addEdge(edges, from, new Edge(this, Mode.KANJI, from, 0, 1, previous, version, null));
        }
        int inputLength = this.stringToEncode.length();
        if (canEncode(Mode.ALPHANUMERIC, this.stringToEncode.charAt(from))) {
            addEdge(edges, from, new Edge(this, Mode.ALPHANUMERIC, from, 0, (from + 1 >= inputLength || !canEncode(Mode.ALPHANUMERIC, this.stringToEncode.charAt(from + 1))) ? 1 : 2, previous, version, null));
        }
        if (canEncode(Mode.NUMERIC, this.stringToEncode.charAt(from))) {
            Mode mode = Mode.NUMERIC;
            int i3 = 0;
            if (from + 1 < inputLength && canEncode(Mode.NUMERIC, this.stringToEncode.charAt(from + 1))) {
                i = (from + 2 >= inputLength || !canEncode(Mode.NUMERIC, this.stringToEncode.charAt(from + 2))) ? 2 : 3;
            } else {
                i = 1;
            }
            addEdge(edges, from, new Edge(this, mode, from, i3, i, previous, version, null));
        }
    }

    ResultList encodeSpecificVersion(Version version) throws WriterException {
        int inputLength = this.stringToEncode.length();
        Edge[][][] edges = (Edge[][][]) Array.newInstance((Class<?>) Edge.class, inputLength + 1, this.encoders.length(), 4);
        addEdges(version, edges, 0, null);
        for (int i = 1; i <= inputLength; i++) {
            for (int j = 0; j < this.encoders.length(); j++) {
                for (int k = 0; k < 4; k++) {
                    if (edges[i][j][k] != null && i < inputLength) {
                        addEdges(version, edges, i, edges[i][j][k]);
                    }
                }
            }
        }
        int minimalJ = -1;
        int minimalK = -1;
        int minimalSize = Integer.MAX_VALUE;
        for (int j2 = 0; j2 < this.encoders.length(); j2++) {
            for (int k2 = 0; k2 < 4; k2++) {
                if (edges[inputLength][j2][k2] != null) {
                    Edge edge = edges[inputLength][j2][k2];
                    if (edge.cachedTotalSize < minimalSize) {
                        minimalSize = edge.cachedTotalSize;
                        minimalJ = j2;
                        minimalK = k2;
                    }
                }
            }
        }
        if (minimalJ < 0) {
            throw new WriterException("Internal error: failed to encode \"" + this.stringToEncode + "\"");
        }
        return new ResultList(version, edges[inputLength][minimalJ][minimalK]);
    }

    private final class Edge {
        private final int cachedTotalSize;
        private final int characterLength;
        private final int charsetEncoderIndex;
        private final int fromPosition;
        private final Mode mode;
        private final Edge previous;

        /* synthetic */ Edge(MinimalEncoder x0, Mode x1, int x2, int x3, int x4, Edge x5, Version x6, AnonymousClass1 x7) {
            this(x1, x2, x3, x4, x5, x6);
        }

        private Edge(Mode mode, int fromPosition, int charsetEncoderIndex, int characterLength, Edge previous, Version version) {
            this.mode = mode;
            this.fromPosition = fromPosition;
            int i = (mode == Mode.BYTE || previous == null) ? charsetEncoderIndex : previous.charsetEncoderIndex;
            this.charsetEncoderIndex = i;
            this.characterLength = characterLength;
            this.previous = previous;
            boolean z = false;
            int size = previous != null ? previous.cachedTotalSize : 0;
            if ((mode == Mode.BYTE && previous == null && i != 0) || (previous != null && i != previous.charsetEncoderIndex)) {
                z = true;
            }
            boolean needECI = z;
            size = (previous == null || mode != previous.mode || needECI) ? size + mode.getCharacterCountBits(version) + 4 : size;
            switch (AnonymousClass1.$SwitchMap$com$google$zxing$qrcode$decoder$Mode[mode.ordinal()]) {
                case 1:
                    size += 13;
                    break;
                case 2:
                    size += characterLength == 1 ? 6 : 11;
                    break;
                case 3:
                    size += characterLength != 1 ? characterLength == 2 ? 7 : 10 : 4;
                    break;
                case 4:
                    size += MinimalEncoder.this.encoders.encode(MinimalEncoder.this.stringToEncode.substring(fromPosition, fromPosition + characterLength), charsetEncoderIndex).length * 8;
                    if (needECI) {
                        size += 12;
                        break;
                    }
                    break;
            }
            this.cachedTotalSize = size;
        }
    }

    final class ResultList {
        private final List<ResultNode> list = new ArrayList();
        private final Version version;

        ResultList(Version version, Edge solution) {
            int lowerLimit;
            int upperLimit;
            int length = 0;
            Edge current = solution;
            boolean containsECI = false;
            while (true) {
                if (current == null) {
                    break;
                }
                length += current.characterLength;
                Edge previous = current.previous;
                if ((current.mode != Mode.BYTE || previous != null || current.charsetEncoderIndex == 0) && (previous == null || current.charsetEncoderIndex == previous.charsetEncoderIndex)) {
                    r11 = 0;
                }
                containsECI = r11 != 0 ? true : containsECI;
                if (previous == null || previous.mode != current.mode || r11 != 0) {
                    this.list.add(0, new ResultNode(current.mode, current.fromPosition, current.charsetEncoderIndex, length));
                    length = 0;
                }
                if (r11 != 0) {
                    this.list.add(0, new ResultNode(Mode.ECI, current.fromPosition, current.charsetEncoderIndex, 0));
                }
                current = previous;
            }
            if (MinimalEncoder.this.isGS1) {
                ResultNode first = this.list.get(0);
                if (first != null && first.mode != Mode.ECI && containsECI) {
                    this.list.add(0, new ResultNode(Mode.ECI, 0, 0, 0));
                }
                this.list.add(this.list.get(0).mode != Mode.ECI ? 0 : 1, new ResultNode(Mode.FNC1_FIRST_POSITION, 0, 0, 0));
            }
            int versionNumber = version.getVersionNumber();
            switch (AnonymousClass1.$SwitchMap$com$google$zxing$qrcode$encoder$MinimalEncoder$VersionSize[MinimalEncoder.getVersionSize(version).ordinal()]) {
                case 1:
                    lowerLimit = 1;
                    upperLimit = 9;
                    break;
                case 2:
                    lowerLimit = 10;
                    upperLimit = 26;
                    break;
                default:
                    lowerLimit = 27;
                    upperLimit = 40;
                    break;
            }
            int size = getSize(version);
            while (versionNumber < upperLimit && !Encoder.willFit(size, Version.getVersionForNumber(versionNumber), MinimalEncoder.this.ecLevel)) {
                versionNumber++;
            }
            while (versionNumber > lowerLimit && Encoder.willFit(size, Version.getVersionForNumber(versionNumber - 1), MinimalEncoder.this.ecLevel)) {
                versionNumber--;
            }
            this.version = Version.getVersionForNumber(versionNumber);
        }

        int getSize() {
            return getSize(this.version);
        }

        private int getSize(Version version) {
            int result = 0;
            for (ResultNode resultNode : this.list) {
                result += resultNode.getSize(version);
            }
            return result;
        }

        void getBits(BitArray bits) throws WriterException {
            for (ResultNode resultNode : this.list) {
                resultNode.getBits(bits);
            }
        }

        Version getVersion() {
            return this.version;
        }

        public String toString() {
            StringBuilder result = new StringBuilder();
            ResultNode previous = null;
            for (ResultNode current : this.list) {
                if (previous != null) {
                    result.append(",");
                }
                result.append(current.toString());
                previous = current;
            }
            return result.toString();
        }

        final class ResultNode {
            private final int characterLength;
            private final int charsetEncoderIndex;
            private final int fromPosition;
            private final Mode mode;

            ResultNode(Mode mode, int fromPosition, int charsetEncoderIndex, int characterLength) {
                this.mode = mode;
                this.fromPosition = fromPosition;
                this.charsetEncoderIndex = charsetEncoderIndex;
                this.characterLength = characterLength;
            }

            /* JADX INFO: Access modifiers changed from: private */
            public int getSize(Version version) {
                int size = this.mode.getCharacterCountBits(version) + 4;
                switch (AnonymousClass1.$SwitchMap$com$google$zxing$qrcode$decoder$Mode[this.mode.ordinal()]) {
                    case 1:
                        return size + (this.characterLength * 13);
                    case 2:
                        int i = this.characterLength;
                        return size + ((i / 2) * 11) + (i % 2 == 1 ? 6 : 0);
                    case 3:
                        int i2 = this.characterLength;
                        int size2 = size + ((i2 / 3) * 10);
                        int rest = i2 % 3;
                        return size2 + (rest != 1 ? rest == 2 ? 7 : 0 : 4);
                    case 4:
                        return size + (getCharacterCountIndicator() * 8);
                    case 5:
                        return size + 8;
                    default:
                        return size;
                }
            }

            private int getCharacterCountIndicator() {
                if (this.mode != Mode.BYTE) {
                    return this.characterLength;
                }
                ECIEncoderSet eCIEncoderSet = MinimalEncoder.this.encoders;
                String str = MinimalEncoder.this.stringToEncode;
                int i = this.fromPosition;
                return eCIEncoderSet.encode(str.substring(i, this.characterLength + i), this.charsetEncoderIndex).length;
            }

            /* JADX INFO: Access modifiers changed from: private */
            public void getBits(BitArray bits) throws WriterException {
                bits.appendBits(this.mode.getBits(), 4);
                if (this.characterLength > 0) {
                    int length = getCharacterCountIndicator();
                    bits.appendBits(length, this.mode.getCharacterCountBits(ResultList.this.version));
                }
                if (this.mode == Mode.ECI) {
                    bits.appendBits(MinimalEncoder.this.encoders.getECIValue(this.charsetEncoderIndex), 8);
                } else if (this.characterLength > 0) {
                    String str = MinimalEncoder.this.stringToEncode;
                    int i = this.fromPosition;
                    Encoder.appendBytes(str.substring(i, this.characterLength + i), this.mode, bits, MinimalEncoder.this.encoders.getCharset(this.charsetEncoderIndex));
                }
            }

            public String toString() {
                StringBuilder result = new StringBuilder();
                result.append(this.mode).append('(');
                if (this.mode == Mode.ECI) {
                    result.append(MinimalEncoder.this.encoders.getCharset(this.charsetEncoderIndex).displayName());
                } else {
                    String str = MinimalEncoder.this.stringToEncode;
                    int i = this.fromPosition;
                    result.append(makePrintable(str.substring(i, this.characterLength + i)));
                }
                result.append(')');
                return result.toString();
            }

            private String makePrintable(String s) {
                StringBuilder result = new StringBuilder();
                for (int i = 0; i < s.length(); i++) {
                    if (s.charAt(i) < ' ' || s.charAt(i) > '~') {
                        result.append('.');
                    } else {
                        result.append(s.charAt(i));
                    }
                }
                return result.toString();
            }
        }
    }
}
