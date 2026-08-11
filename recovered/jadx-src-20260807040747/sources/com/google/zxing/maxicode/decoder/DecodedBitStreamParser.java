package com.google.zxing.maxicode.decoder;

import com.google.zxing.FormatException;
import com.google.zxing.common.DecoderResult;
import java.text.DecimalFormat;
import java.text.NumberFormat;

/* loaded from: classes.dex */
final class DecodedBitStreamParser {
    private static final char ECI = 65530;
    private static final char FS = 28;
    private static final char GS = 29;
    private static final char LATCHA = 65527;
    private static final char LATCHB = 65528;
    private static final char LOCK = 65529;
    private static final char NS = 65531;
    private static final char PAD = 65532;
    private static final char RS = 30;
    private static final char SHIFTA = 65520;
    private static final char SHIFTB = 65521;
    private static final char SHIFTC = 65522;
    private static final char SHIFTD = 65523;
    private static final char SHIFTE = 65524;
    private static final char THREESHIFTA = 65526;
    private static final char TWOSHIFTA = 65525;
    private static final byte[] COUNTRY_BYTES = {53, 54, 43, 44, 45, 46, 47, 48, 37, 38};
    private static final byte[] SERVICE_CLASS_BYTES = {55, 56, 57, 58, 59, 60, 49, 50, 51, 52};
    private static final byte[] POSTCODE_2_LENGTH_BYTES = {39, 40, 41, 42, 31, 32};
    private static final byte[] POSTCODE_2_BYTES = {33, 34, 35, 36, 25, 26, 27, 28, 29, 30, 19, 20, 21, 22, 23, 24, 13, 14, 15, 16, 17, 18, 7, 8, 9, 10, 11, 12, 1, 2};
    private static final byte[][] POSTCODE_3_BYTES = {new byte[]{39, 40, 41, 42, 31, 32}, new byte[]{33, 34, 35, 36, 25, 26}, new byte[]{27, 28, 29, 30, 19, 20}, new byte[]{21, 22, 23, 24, 13, 14}, new byte[]{15, 16, 17, 18, 7, 8}, new byte[]{9, 10, 11, 12, 1, 2}};
    private static final String[] SETS = {"\rABCDEFGHIJKLMNOPQRSTUVWXYZ\ufffa\u001c\u001d\u001e\ufffb ￼\"#$%&'()*+,-./0123456789:\ufff1\ufff2\ufff3\ufff4\ufff8", "`abcdefghijklmnopqrstuvwxyz\ufffa\u001c\u001d\u001e\ufffb{￼}~\u007f;<=>?[\\]^_ ,./:@!|￼\ufff5\ufff6￼\ufff0\ufff2\ufff3\ufff4\ufff7", "ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚ\ufffa\u001c\u001d\u001e\ufffbÛÜÝÞßª¬±²³µ¹º¼½¾\u0080\u0081\u0082\u0083\u0084\u0085\u0086\u0087\u0088\u0089\ufff7 \ufff9\ufff3\ufff4\ufff8", "àáâãäåæçèéêëìíîïðñòóôõö÷øùú\ufffa\u001c\u001d\u001e\ufffbûüýþÿ¡¨«¯°´·¸»¿\u008a\u008b\u008c\u008d\u008e\u008f\u0090\u0091\u0092\u0093\u0094\ufff7 \ufff2\ufff9\ufff4\ufff8", "\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\b\t\n\u000b\f\r\u000e\u000f\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001a\ufffa￼￼\u001b\ufffb\u001c\u001d\u001e\u001f\u009f ¢£¤¥¦§©\u00ad®¶\u0095\u0096\u0097\u0098\u0099\u009a\u009b\u009c\u009d\u009e\ufff7 \ufff2\ufff3\ufff9\ufff8"};

    private DecodedBitStreamParser() {
    }

    static DecoderResult decode(byte[] bytes, int mode) throws FormatException {
        String postcode;
        StringBuilder result = new StringBuilder(144);
        switch (mode) {
            case 2:
            case 3:
                if (mode == 2) {
                    int pc = getPostCode2(bytes);
                    int ps2Length = getPostCode2Length(bytes);
                    if (ps2Length > 10) {
                        throw FormatException.getFormatInstance();
                    }
                    NumberFormat df = new DecimalFormat("0000000000".substring(0, ps2Length));
                    postcode = df.format(pc);
                } else {
                    postcode = getPostCode3(bytes);
                }
                NumberFormat threeDigits = new DecimalFormat("000");
                String country = threeDigits.format(getCountry(bytes));
                String service = threeDigits.format(getServiceClass(bytes));
                result.append(getMessage(bytes, 10, 84));
                if (result.toString().startsWith("[)>\u001e01\u001d")) {
                    result.insert(9, postcode + GS + country + GS + service + GS);
                    break;
                } else {
                    result.insert(0, postcode + GS + country + GS + service + GS);
                    break;
                }
            case 4:
                result.append(getMessage(bytes, 1, 93));
                break;
            case 5:
                result.append(getMessage(bytes, 1, 77));
                break;
        }
        return new DecoderResult(bytes, result.toString(), null, String.valueOf(mode));
    }

    private static int getBit(int bit, byte[] bytes) {
        int bit2 = bit - 1;
        return (bytes[bit2 / 6] & (1 << (5 - (bit2 % 6)))) == 0 ? 0 : 1;
    }

    private static int getInt(byte[] bytes, byte[] x) {
        int val = 0;
        for (int i = 0; i < x.length; i++) {
            val += getBit(x[i], bytes) << ((x.length - i) - 1);
        }
        return val;
    }

    private static int getCountry(byte[] bytes) {
        return getInt(bytes, COUNTRY_BYTES);
    }

    private static int getServiceClass(byte[] bytes) {
        return getInt(bytes, SERVICE_CLASS_BYTES);
    }

    private static int getPostCode2Length(byte[] bytes) {
        return getInt(bytes, POSTCODE_2_LENGTH_BYTES);
    }

    private static int getPostCode2(byte[] bytes) {
        return getInt(bytes, POSTCODE_2_BYTES);
    }

    private static String getPostCode3(byte[] bytes) {
        byte[][] bArr = POSTCODE_3_BYTES;
        StringBuilder sb = new StringBuilder(bArr.length);
        for (byte[] p3bytes : bArr) {
            sb.append(SETS[0].charAt(getInt(bytes, p3bytes)));
        }
        return sb.toString();
    }

    /* JADX WARN: Incorrect condition in loop: B:22:0x0074 */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    private static String getMessage(byte[] bytes, int start, int len) {
        StringBuilder sb = new StringBuilder();
        int shift = -1;
        int set = 0;
        int lastset = 0;
        int i = start;
        while (i < start + len) {
            char c = SETS[set].charAt(bytes[i]);
            switch (c) {
                case 65520:
                case 65521:
                case 65522:
                case 65523:
                case 65524:
                    lastset = set;
                    set = c - SHIFTA;
                    shift = 1;
                    break;
                case 65525:
                    lastset = set;
                    set = 0;
                    shift = 2;
                    break;
                case 65526:
                    lastset = set;
                    set = 0;
                    shift = 3;
                    break;
                case 65527:
                    set = 0;
                    shift = -1;
                    break;
                case 65528:
                    set = 1;
                    shift = -1;
                    break;
                case 65529:
                    shift = -1;
                    break;
                case 65530:
                default:
                    sb.append(c);
                    break;
                case 65531:
                    int i2 = i + 1;
                    int i3 = bytes[i2] << 24;
                    int i4 = i2 + 1;
                    int i5 = i3 + (bytes[i4] << 18);
                    int i6 = i4 + 1;
                    int i7 = i5 + (bytes[i6] << 12);
                    int i8 = i6 + 1;
                    int i9 = i7 + (bytes[i8] << 6);
                    i = i8 + 1;
                    int nsval = i9 + bytes[i];
                    sb.append(new DecimalFormat("000000000").format(nsval));
                    break;
            }
            int shift2 = shift - 1;
            if (shift == 0) {
                set = lastset;
            }
            i++;
            shift = shift2;
        }
        while (i > 0 && sb.charAt(sb.length() - 1) == 65532) {
            sb.setLength(sb.length() - 1);
        }
        return sb.toString();
    }
}
