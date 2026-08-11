package androidx.webkit.internal;

import java.net.URLConnection;
import kotlin.text.Typography;

/* loaded from: classes.dex */
class MimeUtil {
    MimeUtil() {
    }

    public static String getMimeFromFileName(String fileName) {
        if (fileName == null) {
            return null;
        }
        String mimeType = URLConnection.guessContentTypeFromName(fileName);
        if (mimeType != null) {
            return mimeType;
        }
        return guessHardcodedMime(fileName);
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    /* JADX WARN: Code restructure failed: missing block: B:103:0x011b, code lost:
    
        if (r4.equals("zip") != false) goto L159;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    private static String guessHardcodedMime(String fileName) {
        char c = '.';
        int finalFullStop = fileName.lastIndexOf(46);
        if (finalFullStop == -1) {
            return null;
        }
        String extension = fileName.substring(finalFullStop + 1).toLowerCase();
        switch (extension.hashCode()) {
            case 3315:
                if (extension.equals("gz")) {
                    c = '*';
                    break;
                }
                c = 65535;
                break;
            case 3401:
                if (extension.equals("js")) {
                    c = '!';
                    break;
                }
                c = 65535;
                break;
            case 97669:
                if (extension.equals("bmp")) {
                    c = '/';
                    break;
                }
                c = 65535;
                break;
            case 98819:
                if (extension.equals("css")) {
                    c = 27;
                    break;
                }
                c = 65535;
                break;
            case 102340:
                if (extension.equals("gif")) {
                    c = 14;
                    break;
                }
                c = 65535;
                break;
            case 103649:
                if (extension.equals("htm")) {
                    c = 29;
                    break;
                }
                c = 65535;
                break;
            case 104085:
                if (extension.equals("ico")) {
                    c = '(';
                    break;
                }
                c = 65535;
                break;
            case 105441:
                if (extension.equals("jpg")) {
                    c = 16;
                    break;
                }
                c = 65535;
                break;
            case 106458:
                if (extension.equals("m4a")) {
                    c = '\r';
                    break;
                }
                c = 65535;
                break;
            case 106479:
                if (extension.equals("m4v")) {
                    c = '%';
                    break;
                }
                c = 65535;
                break;
            case 108089:
                if (extension.equals("mht")) {
                    c = 25;
                    break;
                }
                c = 65535;
                break;
            case 108150:
                if (extension.equals("mjs")) {
                    c = Typography.quote;
                    break;
                }
                c = 65535;
                break;
            case 108272:
                if (extension.equals("mp3")) {
                    c = 3;
                    break;
                }
                c = 65535;
                break;
            case 108273:
                if (extension.equals("mp4")) {
                    c = Typography.dollar;
                    break;
                }
                c = 65535;
                break;
            case 108324:
                if (extension.equals("mpg")) {
                    c = 2;
                    break;
                }
                c = 65535;
                break;
            case 109961:
                if (extension.equals("oga")) {
                    c = '\n';
                    break;
                }
                c = 65535;
                break;
            case 109967:
                if (extension.equals("ogg")) {
                    c = '\t';
                    break;
                }
                c = 65535;
                break;
            case 109973:
                if (extension.equals("ogm")) {
                    c = '\'';
                    break;
                }
                c = 65535;
                break;
            case 109982:
                if (extension.equals("ogv")) {
                    c = Typography.amp;
                    break;
                }
                c = 65535;
                break;
            case 110834:
                if (extension.equals("pdf")) {
                    c = '-';
                    break;
                }
                c = 65535;
                break;
            case 111030:
                if (extension.equals("pjp")) {
                    c = 19;
                    break;
                }
                c = 65535;
                break;
            case 111145:
                if (extension.equals("png")) {
                    c = 20;
                    break;
                }
                c = 65535;
                break;
            case 114276:
                if (extension.equals("svg")) {
                    c = 22;
                    break;
                }
                c = 65535;
                break;
            case 114791:
                if (extension.equals("tgz")) {
                    c = '+';
                    break;
                }
                c = 65535;
                break;
            case 114833:
                if (extension.equals("tif")) {
                    c = '1';
                    break;
                }
                c = 65535;
                break;
            case 117484:
                if (extension.equals("wav")) {
                    c = '\f';
                    break;
                }
                c = 65535;
                break;
            case 118660:
                if (extension.equals("xht")) {
                    c = 6;
                    break;
                }
                c = 65535;
                break;
            case 118807:
                if (extension.equals("xml")) {
                    c = '#';
                    break;
                }
                c = 65535;
                break;
            case 120609:
                break;
            case 3000872:
                if (extension.equals("apng")) {
                    c = 21;
                    break;
                }
                c = 65535;
                break;
            case 3145576:
                if (extension.equals("flac")) {
                    c = '\b';
                    break;
                }
                c = 65535;
                break;
            case 3213227:
                if (extension.equals("html")) {
                    c = 28;
                    break;
                }
                c = 65535;
                break;
            case 3259225:
                if (extension.equals("jfif")) {
                    c = 17;
                    break;
                }
                c = 65535;
                break;
            case 3268712:
                if (extension.equals("jpeg")) {
                    c = 15;
                    break;
                }
                c = 65535;
                break;
            case 3271912:
                if (extension.equals("json")) {
                    c = ',';
                    break;
                }
                c = 65535;
                break;
            case 3358085:
                if (extension.equals("mpeg")) {
                    c = 1;
                    break;
                }
                c = 65535;
                break;
            case 3418175:
                if (extension.equals("opus")) {
                    c = 11;
                    break;
                }
                c = 65535;
                break;
            case 3529614:
                if (extension.equals("shtm")) {
                    c = 31;
                    break;
                }
                c = 65535;
                break;
            case 3542678:
                if (extension.equals("svgz")) {
                    c = 23;
                    break;
                }
                c = 65535;
                break;
            case 3559925:
                if (extension.equals("tiff")) {
                    c = '0';
                    break;
                }
                c = 65535;
                break;
            case 3642020:
                if (extension.equals("wasm")) {
                    c = 4;
                    break;
                }
                c = 65535;
                break;
            case 3645337:
                if (extension.equals("webm")) {
                    c = 0;
                    break;
                }
                c = 65535;
                break;
            case 3645340:
                if (extension.equals("webp")) {
                    c = 24;
                    break;
                }
                c = 65535;
                break;
            case 3655064:
                if (extension.equals("woff")) {
                    c = ')';
                    break;
                }
                c = 65535;
                break;
            case 3678569:
                if (extension.equals("xhtm")) {
                    c = 7;
                    break;
                }
                c = 65535;
                break;
            case 96488848:
                if (extension.equals("ehtml")) {
                    c = ' ';
                    break;
                }
                c = 65535;
                break;
            case 103877016:
                if (extension.equals("mhtml")) {
                    c = 26;
                    break;
                }
                c = 65535;
                break;
            case 106703064:
                if (extension.equals("pjpeg")) {
                    c = 18;
                    break;
                }
                c = 65535;
                break;
            case 109418142:
                if (extension.equals("shtml")) {
                    c = 30;
                    break;
                }
                c = 65535;
                break;
            case 114035747:
                if (extension.equals("xhtml")) {
                    c = 5;
                    break;
                }
                c = 65535;
                break;
            default:
                c = 65535;
                break;
        }
        switch (c) {
        }
        return null;
    }
}
