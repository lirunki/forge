package com.google.zxing.oned;

import androidx.core.view.MotionEventCompat;
import com.google.zxing.BarcodeFormat;
import java.util.Collection;
import java.util.Collections;
import kotlin.text.Typography;

/* loaded from: classes.dex */
public final class Code39Writer extends OneDimensionalCodeWriter {
    @Override // com.google.zxing.oned.OneDimensionalCodeWriter
    protected Collection<BarcodeFormat> getSupportedWriteFormats() {
        return Collections.singleton(BarcodeFormat.CODE_39);
    }

    @Override // com.google.zxing.oned.OneDimensionalCodeWriter
    public boolean[] encode(String contents) {
        int length = contents.length();
        if (length > 80) {
            throw new IllegalArgumentException("Requested contents should be less than 80 digits long, but got " + length);
        }
        int i = 0;
        while (true) {
            if (i >= length) {
                break;
            }
            int indexInString = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%".indexOf(contents.charAt(i));
            if (indexInString >= 0) {
                i++;
            } else {
                contents = tryToConvertToExtendedMode(contents);
                length = contents.length();
                if (length > 80) {
                    throw new IllegalArgumentException("Requested contents should be less than 80 digits long, but got " + length + " (extended full ASCII mode)");
                }
            }
        }
        int[] widths = new int[9];
        int codeWidth = (length * 13) + 25;
        boolean[] result = new boolean[codeWidth];
        toIntArray(148, widths);
        int pos = appendPattern(result, 0, widths, true);
        int[] narrowWhite = {1};
        int pos2 = pos + appendPattern(result, pos, narrowWhite, false);
        for (int i2 = 0; i2 < length; i2++) {
            int indexInString2 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%".indexOf(contents.charAt(i2));
            toIntArray(Code39Reader.CHARACTER_ENCODINGS[indexInString2], widths);
            int pos3 = pos2 + appendPattern(result, pos2, widths, true);
            pos2 = pos3 + appendPattern(result, pos3, narrowWhite, false);
        }
        toIntArray(148, widths);
        appendPattern(result, pos2, widths, true);
        return result;
    }

    private static void toIntArray(int a, int[] toReturn) {
        for (int i = 0; i < 9; i++) {
            int i2 = 1;
            int temp = (1 << (8 - i)) & a;
            if (temp != 0) {
                i2 = 2;
            }
            toReturn[i] = i2;
        }
    }

    private static String tryToConvertToExtendedMode(String contents) {
        int length = contents.length();
        StringBuilder extendedContent = new StringBuilder();
        for (int i = 0; i < length; i++) {
            char character = contents.charAt(i);
            switch (character) {
                case 0:
                    extendedContent.append("%U");
                    break;
                case ' ':
                case MotionEventCompat.AXIS_GENERIC_14 /* 45 */:
                case MotionEventCompat.AXIS_GENERIC_15 /* 46 */:
                    extendedContent.append(character);
                    break;
                case '@':
                    extendedContent.append("%V");
                    break;
                case '`':
                    extendedContent.append("%W");
                    break;
                default:
                    if (character <= 26) {
                        extendedContent.append(Typography.dollar);
                        extendedContent.append((char) ((character - 1) + 65));
                        break;
                    } else if (character < ' ') {
                        extendedContent.append('%');
                        extendedContent.append((char) ((character - 27) + 65));
                        break;
                    } else if (character <= ',' || character == '/' || character == ':') {
                        extendedContent.append('/');
                        extendedContent.append((char) ((character - '!') + 65));
                        break;
                    } else if (character <= '9') {
                        extendedContent.append((char) ((character - '0') + 48));
                        break;
                    } else if (character <= '?') {
                        extendedContent.append('%');
                        extendedContent.append((char) ((character - ';') + 70));
                        break;
                    } else if (character <= 'Z') {
                        extendedContent.append((char) ((character - 'A') + 65));
                        break;
                    } else if (character <= '_') {
                        extendedContent.append('%');
                        extendedContent.append((char) ((character - '[') + 75));
                        break;
                    } else if (character <= 'z') {
                        extendedContent.append('+');
                        extendedContent.append((char) ((character - 'a') + 65));
                        break;
                    } else if (character <= 127) {
                        extendedContent.append('%');
                        extendedContent.append((char) ((character - '{') + 80));
                        break;
                    } else {
                        throw new IllegalArgumentException("Requested content contains a non-encodable character: '" + contents.charAt(i) + "'");
                    }
            }
        }
        return extendedContent.toString();
    }
}
