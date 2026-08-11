package com.google.zxing.datamatrix.decoder;

import com.google.zxing.datamatrix.decoder.Version;

/* loaded from: classes.dex */
final class DataBlock {
    private final byte[] codewords;
    private final int numDataCodewords;

    private DataBlock(int numDataCodewords, byte[] codewords) {
        this.numDataCodewords = numDataCodewords;
        this.codewords = codewords;
    }

    static DataBlock[] getDataBlocks(byte[] rawCodewords, Version version) {
        Version.ECBlocks ecBlocks;
        int iOffset;
        Version.ECBlocks ecBlocks2 = version.getECBlocks();
        int totalBlocks = 0;
        Version.ECB[] ecBlockArray = ecBlocks2.getECBlocks();
        for (Version.ECB ecb : ecBlockArray) {
            totalBlocks += ecb.getCount();
        }
        DataBlock[] result = new DataBlock[totalBlocks];
        int numResultBlocks = 0;
        for (Version.ECB ecBlock : ecBlockArray) {
            int i = 0;
            while (i < ecBlock.getCount()) {
                int numDataCodewords = ecBlock.getDataCodewords();
                int numBlockCodewords = ecBlocks2.getECCodewords() + numDataCodewords;
                result[numResultBlocks] = new DataBlock(numDataCodewords, new byte[numBlockCodewords]);
                i++;
                numResultBlocks++;
            }
        }
        int longerBlocksTotalCodewords = result[0].codewords.length;
        int longerBlocksNumDataCodewords = longerBlocksTotalCodewords - ecBlocks2.getECCodewords();
        int shorterBlocksNumDataCodewords = longerBlocksNumDataCodewords - 1;
        int rawCodewordsOffset = 0;
        for (int i2 = 0; i2 < shorterBlocksNumDataCodewords; i2++) {
            int j = 0;
            while (j < numResultBlocks) {
                result[j].codewords[i2] = rawCodewords[rawCodewordsOffset];
                j++;
                rawCodewordsOffset++;
            }
        }
        int i3 = version.getVersionNumber();
        boolean specialVersion = i3 == 24;
        int numLongerBlocks = specialVersion ? 8 : numResultBlocks;
        int j2 = 0;
        while (j2 < numLongerBlocks) {
            result[j2].codewords[longerBlocksNumDataCodewords - 1] = rawCodewords[rawCodewordsOffset];
            j2++;
            rawCodewordsOffset++;
        }
        int max = result[0].codewords.length;
        for (int i4 = longerBlocksNumDataCodewords; i4 < max; i4++) {
            int j3 = 0;
            while (j3 < numResultBlocks) {
                int jOffset = specialVersion ? (j3 + 8) % numResultBlocks : j3;
                if (specialVersion) {
                    ecBlocks = ecBlocks2;
                    if (jOffset > 7) {
                        iOffset = i4 - 1;
                        result[jOffset].codewords[iOffset] = rawCodewords[rawCodewordsOffset];
                        j3++;
                        ecBlocks2 = ecBlocks;
                        totalBlocks = totalBlocks;
                        rawCodewordsOffset++;
                    }
                } else {
                    ecBlocks = ecBlocks2;
                }
                iOffset = i4;
                result[jOffset].codewords[iOffset] = rawCodewords[rawCodewordsOffset];
                j3++;
                ecBlocks2 = ecBlocks;
                totalBlocks = totalBlocks;
                rawCodewordsOffset++;
            }
        }
        if (rawCodewordsOffset != rawCodewords.length) {
            throw new IllegalArgumentException();
        }
        return result;
    }

    int getNumDataCodewords() {
        return this.numDataCodewords;
    }

    byte[] getCodewords() {
        return this.codewords;
    }
}
