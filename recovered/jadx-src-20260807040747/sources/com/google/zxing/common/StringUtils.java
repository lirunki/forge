package com.google.zxing.common;

import com.google.zxing.DecodeHintType;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.charset.UnsupportedCharsetException;
import java.util.Map;

/* loaded from: classes.dex */
public final class StringUtils {
    private static final boolean ASSUME_SHIFT_JIS;
    private static final Charset EUC_JP;
    public static final String GB2312 = "GB2312";
    public static final Charset GB2312_CHARSET;
    private static final Charset PLATFORM_DEFAULT_ENCODING = Charset.defaultCharset();
    public static final String SHIFT_JIS = "SJIS";
    public static final Charset SHIFT_JIS_CHARSET;

    static {
        Charset sjisCharset;
        Charset gb2312Charset;
        Charset eucJpCharset;
        try {
            sjisCharset = Charset.forName(SHIFT_JIS);
        } catch (UnsupportedCharsetException e) {
            sjisCharset = null;
        }
        SHIFT_JIS_CHARSET = sjisCharset;
        try {
            gb2312Charset = Charset.forName(GB2312);
        } catch (UnsupportedCharsetException e2) {
            gb2312Charset = null;
        }
        GB2312_CHARSET = gb2312Charset;
        try {
            eucJpCharset = Charset.forName("EUC_JP");
        } catch (UnsupportedCharsetException e3) {
            eucJpCharset = null;
        }
        EUC_JP = eucJpCharset;
        Charset charset = SHIFT_JIS_CHARSET;
        ASSUME_SHIFT_JIS = (charset != null && charset.equals(PLATFORM_DEFAULT_ENCODING)) || (eucJpCharset != null && eucJpCharset.equals(PLATFORM_DEFAULT_ENCODING));
    }

    private StringUtils() {
    }

    public static String guessEncoding(byte[] bytes, Map<DecodeHintType, ?> hints) {
        Charset c = guessCharset(bytes, hints);
        if (c.equals(SHIFT_JIS_CHARSET)) {
            return SHIFT_JIS;
        }
        if (c.equals(StandardCharsets.UTF_8)) {
            return "UTF8";
        }
        if (c.equals(StandardCharsets.ISO_8859_1)) {
            return "ISO8859_1";
        }
        return c.name();
    }

    public static Charset guessCharset(byte[] bytes, Map<DecodeHintType, ?> hints) {
        int length;
        byte[] bArr = bytes;
        if (hints != null && hints.containsKey(DecodeHintType.CHARACTER_SET)) {
            return Charset.forName(hints.get(DecodeHintType.CHARACTER_SET).toString());
        }
        if (bArr.length > 2 && ((bArr[0] == -2 && bArr[1] == -1) || (bArr[0] == -1 && bArr[1] == -2))) {
            return StandardCharsets.UTF_16;
        }
        int length2 = bArr.length;
        boolean canBeISO88591 = true;
        boolean canBeShiftJIS = SHIFT_JIS_CHARSET != null;
        boolean canBeUTF8 = true;
        int utf8BytesLeft = 0;
        int utf2BytesChars = 0;
        int utf3BytesChars = 0;
        int utf4BytesChars = 0;
        int sjisBytesLeft = 0;
        int sjisKatakanaChars = 0;
        int sjisCurKatakanaWordLength = 0;
        int sjisCurDoubleBytesWordLength = 0;
        int isoHighOther = 0;
        boolean utf8bom = bArr.length > 3 && bArr[0] == -17 && bArr[1] == -69 && bArr[2] == -65;
        int i = 0;
        int sjisMaxKatakanaWordLength = 0;
        int sjisMaxDoubleBytesWordLength = 0;
        while (true) {
            if (i >= length2) {
                length = length2;
                break;
            }
            if (!canBeISO88591 && !canBeShiftJIS && !canBeUTF8) {
                length = length2;
                break;
            }
            int length3 = length2;
            int length4 = bArr[i];
            int value = length4 & 255;
            if (canBeUTF8) {
                if (utf8BytesLeft > 0) {
                    if ((value & 128) == 0) {
                        canBeUTF8 = false;
                    } else {
                        utf8BytesLeft--;
                    }
                } else if ((value & 128) != 0) {
                    if ((value & 64) == 0) {
                        canBeUTF8 = false;
                    } else {
                        utf8BytesLeft++;
                        if ((value & 32) == 0) {
                            utf2BytesChars++;
                        } else {
                            utf8BytesLeft++;
                            if ((value & 16) == 0) {
                                utf3BytesChars++;
                            } else {
                                utf8BytesLeft++;
                                if ((value & 8) == 0) {
                                    utf4BytesChars++;
                                } else {
                                    canBeUTF8 = false;
                                }
                            }
                        }
                    }
                }
            }
            if (canBeISO88591) {
                if (value > 127 && value < 160) {
                    canBeISO88591 = false;
                } else if (value > 159 && (value < 192 || value == 215 || value == 247)) {
                    isoHighOther++;
                }
            }
            if (canBeShiftJIS) {
                if (sjisBytesLeft > 0) {
                    if (value < 64 || value == 127 || value > 252) {
                        canBeShiftJIS = false;
                    } else {
                        sjisBytesLeft--;
                    }
                } else if (value == 128 || value == 160 || value > 239) {
                    canBeShiftJIS = false;
                } else if (value > 160 && value < 224) {
                    sjisKatakanaChars++;
                    sjisCurKatakanaWordLength++;
                    if (sjisCurKatakanaWordLength <= sjisMaxKatakanaWordLength) {
                        sjisCurDoubleBytesWordLength = 0;
                    } else {
                        sjisMaxKatakanaWordLength = sjisCurKatakanaWordLength;
                        sjisCurDoubleBytesWordLength = 0;
                    }
                } else if (value > 127) {
                    sjisBytesLeft++;
                    int sjisCurKatakanaWordLength2 = sjisCurDoubleBytesWordLength + 1;
                    if (sjisCurKatakanaWordLength2 <= sjisMaxDoubleBytesWordLength) {
                        sjisCurDoubleBytesWordLength = sjisCurKatakanaWordLength2;
                        sjisCurKatakanaWordLength = 0;
                    } else {
                        sjisMaxDoubleBytesWordLength = sjisCurKatakanaWordLength2;
                        sjisCurDoubleBytesWordLength = sjisCurKatakanaWordLength2;
                        sjisCurKatakanaWordLength = 0;
                    }
                } else {
                    sjisCurDoubleBytesWordLength = 0;
                    sjisCurKatakanaWordLength = 0;
                }
            }
            i++;
            bArr = bytes;
            length2 = length3;
        }
        if (canBeUTF8 && utf8BytesLeft > 0) {
            canBeUTF8 = false;
        }
        if (canBeShiftJIS && sjisBytesLeft > 0) {
            canBeShiftJIS = false;
        }
        if (canBeUTF8 && (utf8bom || utf2BytesChars + utf3BytesChars + utf4BytesChars > 0)) {
            return StandardCharsets.UTF_8;
        }
        if (canBeShiftJIS && (ASSUME_SHIFT_JIS || sjisMaxKatakanaWordLength >= 3 || sjisMaxDoubleBytesWordLength >= 3)) {
            return SHIFT_JIS_CHARSET;
        }
        if (canBeISO88591 && canBeShiftJIS) {
            if ((sjisMaxKatakanaWordLength != 2 || sjisKatakanaChars != 2) && isoHighOther * 10 < length) {
                return StandardCharsets.ISO_8859_1;
            }
            return SHIFT_JIS_CHARSET;
        }
        if (canBeISO88591) {
            return StandardCharsets.ISO_8859_1;
        }
        if (canBeShiftJIS) {
            return SHIFT_JIS_CHARSET;
        }
        if (canBeUTF8) {
            return StandardCharsets.UTF_8;
        }
        return PLATFORM_DEFAULT_ENCODING;
    }
}
