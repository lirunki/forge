package com.google.zxing.datamatrix.decoder;

import androidx.appcompat.app.AppCompatDelegate;
import androidx.core.location.LocationRequestCompat;
import com.google.zxing.FormatException;

/* loaded from: classes.dex */
public final class Version {
    private static final Version[] VERSIONS = buildVersions();
    private final int dataRegionSizeColumns;
    private final int dataRegionSizeRows;
    private final ECBlocks ecBlocks;
    private final int symbolSizeColumns;
    private final int symbolSizeRows;
    private final int totalCodewords;
    private final int versionNumber;

    private Version(int versionNumber, int symbolSizeRows, int symbolSizeColumns, int dataRegionSizeRows, int dataRegionSizeColumns, ECBlocks ecBlocks) {
        this.versionNumber = versionNumber;
        this.symbolSizeRows = symbolSizeRows;
        this.symbolSizeColumns = symbolSizeColumns;
        this.dataRegionSizeRows = dataRegionSizeRows;
        this.dataRegionSizeColumns = dataRegionSizeColumns;
        this.ecBlocks = ecBlocks;
        int total = 0;
        int ecCodewords = ecBlocks.getECCodewords();
        ECB[] ecbArray = ecBlocks.getECBlocks();
        for (ECB ecBlock : ecbArray) {
            total += ecBlock.getCount() * (ecBlock.getDataCodewords() + ecCodewords);
        }
        this.totalCodewords = total;
    }

    public int getVersionNumber() {
        return this.versionNumber;
    }

    public int getSymbolSizeRows() {
        return this.symbolSizeRows;
    }

    public int getSymbolSizeColumns() {
        return this.symbolSizeColumns;
    }

    public int getDataRegionSizeRows() {
        return this.dataRegionSizeRows;
    }

    public int getDataRegionSizeColumns() {
        return this.dataRegionSizeColumns;
    }

    public int getTotalCodewords() {
        return this.totalCodewords;
    }

    ECBlocks getECBlocks() {
        return this.ecBlocks;
    }

    public static Version getVersionForDimensions(int numRows, int numColumns) throws FormatException {
        if ((numRows & 1) != 0 || (numColumns & 1) != 0) {
            throw FormatException.getFormatInstance();
        }
        for (Version version : VERSIONS) {
            if (version.symbolSizeRows == numRows && version.symbolSizeColumns == numColumns) {
                return version;
            }
        }
        throw FormatException.getFormatInstance();
    }

    static final class ECBlocks {
        private final ECB[] ecBlocks;
        private final int ecCodewords;

        private ECBlocks(int ecCodewords, ECB ecBlocks) {
            this.ecCodewords = ecCodewords;
            this.ecBlocks = new ECB[]{ecBlocks};
        }

        private ECBlocks(int ecCodewords, ECB ecBlocks1, ECB ecBlocks2) {
            this.ecCodewords = ecCodewords;
            this.ecBlocks = new ECB[]{ecBlocks1, ecBlocks2};
        }

        int getECCodewords() {
            return this.ecCodewords;
        }

        ECB[] getECBlocks() {
            return this.ecBlocks;
        }
    }

    static final class ECB {
        private final int count;
        private final int dataCodewords;

        private ECB(int count, int dataCodewords) {
            this.count = count;
            this.dataCodewords = dataCodewords;
        }

        int getCount() {
            return this.count;
        }

        int getDataCodewords() {
            return this.dataCodewords;
        }
    }

    public String toString() {
        return String.valueOf(this.versionNumber);
    }

    private static Version[] buildVersions() {
        int i = 48;
        int i2 = 8;
        int i3 = 1;
        int i4 = 5;
        int i5 = 7;
        int i6 = 12;
        int i7 = 18;
        int i8 = 36;
        int i9 = 62;
        int i10 = 42;
        int i11 = 56;
        ECB ecb = new ECB(i3, 10);
        ECB ecb2 = new ECB(i3, 16);
        int i12 = 32;
        int i13 = 38;
        return new Version[]{new Version(1, 10, 10, 8, 8, new ECBlocks(i4, new ECB(i3, 3))), new Version(2, 12, 12, 10, 10, new ECBlocks(i5, new ECB(i3, i4))), new Version(3, 14, 14, 12, 12, new ECBlocks(10, new ECB(i3, i2))), new Version(4, 16, 16, 14, 14, new ECBlocks(i6, new ECB(i3, i6))), new Version(5, 18, 18, 16, 16, new ECBlocks(14, new ECB(i3, 18))), new Version(6, 20, 20, 18, 18, new ECBlocks(i7, new ECB(i3, 22))), new Version(7, 22, 22, 20, 20, new ECBlocks(20, new ECB(i3, 30))), new Version(8, 24, 24, 22, 22, new ECBlocks(24, new ECB(i3, i8))), new Version(9, 26, 26, 24, 24, new ECBlocks(28, new ECB(i3, 44))), new Version(10, 32, 32, 14, 14, new ECBlocks(i8, new ECB(i3, i9))), new Version(11, 36, 36, 16, 16, new ECBlocks(i10, new ECB(i3, 86))), new Version(12, 40, 40, 18, 18, new ECBlocks(i, new ECB(i3, 114))), new Version(13, 44, 44, 20, 20, new ECBlocks(i11, new ECB(i3, 144))), new Version(14, 48, 48, 22, 22, new ECBlocks(68, new ECB(i3, 174))), new Version(15, 52, 52, 24, 24, new ECBlocks(i10, new ECB(2, LocationRequestCompat.QUALITY_BALANCED_POWER_ACCURACY))), new Version(16, 64, 64, 14, 14, new ECBlocks(i11, new ECB(2, 140))), new Version(17, 72, 72, 16, 16, new ECBlocks(i8, new ECB(4, 92))), new Version(18, 80, 80, 18, 18, new ECBlocks(i, new ECB(4, 114))), new Version(19, 88, 88, 20, 20, new ECBlocks(i11, new ECB(4, 144))), new Version(20, 96, 96, 22, 22, new ECBlocks(68, new ECB(4, 174))), new Version(21, LocationRequestCompat.QUALITY_LOW_POWER, LocationRequestCompat.QUALITY_LOW_POWER, 24, 24, new ECBlocks(i11, new ECB(6, 136))), new Version(22, 120, 120, 18, 18, new ECBlocks(68, new ECB(6, 175))), new Version(23, 132, 132, 20, 20, new ECBlocks(i9, new ECB(i2, 163))), new Version(24, 144, 144, 22, 22, new ECBlocks(i9, new ECB(i2, 156), new ECB(2, 155))), new Version(25, 8, 18, 6, 16, new ECBlocks(i5, new ECB(i3, 5))), new Version(26, 8, 32, 6, 14, new ECBlocks(11, ecb)), new Version(27, 12, 26, 10, 24, new ECBlocks(14, ecb2)), new Version(28, 12, 36, 10, 16, new ECBlocks(i7, new ECB(i3, 22))), new Version(29, 16, 36, 14, 16, new ECBlocks(24, new ECB(i3, i12))), new Version(30, 16, 48, 14, 22, new ECBlocks(28, new ECB(i3, 49))), new Version(31, 8, 48, 6, 22, new ECBlocks(15, new ECB(i3, i7))), new Version(32, 8, 64, 6, 14, new ECBlocks(i7, new ECB(i3, 24))), new Version(33, 8, 80, 6, 18, new ECBlocks(22, new ECB(i3, i12))), new Version(34, 8, 96, 6, 22, new ECBlocks(28, new ECB(i3, i13))), new Version(35, 8, 120, 6, 18, new ECBlocks(i12, new ECB(i3, 49))), new Version(36, 8, 144, 6, 22, new ECBlocks(i8, new ECB(i3, 63))), new Version(37, 12, 64, 10, 14, new ECBlocks(27, new ECB(i3, 43))), new Version(38, 12, 88, 10, 20, new ECBlocks(i8, new ECB(i3, 64))), new Version(39, 16, 64, 14, 14, new ECBlocks(i8, new ECB(i3, i9))), new Version(40, 20, 36, 18, 16, new ECBlocks(28, new ECB(i3, 44))), new Version(41, 20, 44, 18, 20, new ECBlocks(34, new ECB(i3, i11))), new Version(42, 20, 64, 18, 14, new ECBlocks(i10, new ECB(i3, 84))), new Version(43, 22, 48, 20, 22, new ECBlocks(i13, new ECB(i3, 72))), new Version(44, 24, 48, 22, 22, new ECBlocks(41, new ECB(i3, 80))), new Version(45, 24, 64, 22, 14, new ECBlocks(46, new ECB(i3, AppCompatDelegate.FEATURE_SUPPORT_ACTION_BAR))), new Version(46, 26, 40, 24, 18, new ECBlocks(i13, new ECB(i3, 70))), new Version(47, 26, 48, 24, 22, new ECBlocks(i10, new ECB(i3, 90))), new Version(48, 26, 64, 24, 14, new ECBlocks(50, new ECB(i3, 118)))};
    }
}
