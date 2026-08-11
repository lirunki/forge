package com.google.zxing.client.result;

import androidx.core.net.MailTo;
import com.google.zxing.Result;
import java.util.List;

/* loaded from: classes.dex */
public final class VEventResultParser extends ResultParser {
    @Override // com.google.zxing.client.result.ResultParser
    public CalendarParsedResult parse(Result result) {
        double latitude;
        double longitude;
        String rawText = getMassagedText(result);
        int vEventStart = rawText.indexOf("BEGIN:VEVENT");
        if (vEventStart < 0) {
            return null;
        }
        String summary = matchSingleVCardPrefixedField("SUMMARY", rawText);
        String start = matchSingleVCardPrefixedField("DTSTART", rawText);
        if (start == null) {
            return null;
        }
        String end = matchSingleVCardPrefixedField("DTEND", rawText);
        String duration = matchSingleVCardPrefixedField("DURATION", rawText);
        String location = matchSingleVCardPrefixedField("LOCATION", rawText);
        String organizer = stripMailto(matchSingleVCardPrefixedField("ORGANIZER", rawText));
        String[] attendees = matchVCardPrefixedField("ATTENDEE", rawText);
        if (attendees != null) {
            for (int i = 0; i < attendees.length; i++) {
                attendees[i] = stripMailto(attendees[i]);
            }
        }
        String description = matchSingleVCardPrefixedField("DESCRIPTION", rawText);
        String geoString = matchSingleVCardPrefixedField("GEO", rawText);
        if (geoString == null) {
            latitude = Double.NaN;
            longitude = Double.NaN;
        } else {
            int semicolon = geoString.indexOf(59);
            if (semicolon < 0) {
                return null;
            }
            try {
                double latitude2 = Double.parseDouble(geoString.substring(0, semicolon));
                double longitude2 = Double.parseDouble(geoString.substring(semicolon + 1));
                latitude = latitude2;
                longitude = longitude2;
            } catch (NumberFormatException e) {
                return null;
            }
        }
        try {
            try {
                return new CalendarParsedResult(summary, start, end, duration, location, organizer, attendees, description, latitude, longitude);
            } catch (IllegalArgumentException e2) {
                return null;
            }
        } catch (IllegalArgumentException e3) {
        }
    }

    private static String matchSingleVCardPrefixedField(CharSequence prefix, String rawText) {
        List<String> values = VCardResultParser.matchSingleVCardPrefixedField(prefix, rawText, true, false);
        if (values == null || values.isEmpty()) {
            return null;
        }
        return values.get(0);
    }

    private static String[] matchVCardPrefixedField(CharSequence prefix, String rawText) {
        List<List<String>> values = VCardResultParser.matchVCardPrefixedField(prefix, rawText, true, false);
        if (values == null || values.isEmpty()) {
            return null;
        }
        int size = values.size();
        String[] result = new String[size];
        for (int i = 0; i < size; i++) {
            result[i] = values.get(i).get(0);
        }
        return result;
    }

    private static String stripMailto(String s) {
        if (s == null) {
            return s;
        }
        if (s.startsWith(MailTo.MAILTO_SCHEME) || s.startsWith("MAILTO:")) {
            return s.substring(7);
        }
        return s;
    }
}
