package com.google.zxing.oned.rss.expanded.decoders;

import com.google.zxing.NotFoundException;
import java.util.HashMap;
import java.util.Map;

/* loaded from: classes.dex */
final class FieldParser {
    private static final Map<String, DataLength> FOUR_DIGIT_DATA_LENGTH;
    private static final Map<String, DataLength> THREE_DIGIT_DATA_LENGTH;
    private static final Map<String, DataLength> THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH;
    private static final Map<String, DataLength> TWO_DIGIT_DATA_LENGTH;

    static {
        HashMap hashMap = new HashMap();
        TWO_DIGIT_DATA_LENGTH = hashMap;
        hashMap.put("00", DataLength.fixed(18));
        hashMap.put("01", DataLength.fixed(14));
        hashMap.put("02", DataLength.fixed(14));
        hashMap.put("10", DataLength.variable(20));
        hashMap.put("11", DataLength.fixed(6));
        hashMap.put("12", DataLength.fixed(6));
        hashMap.put("13", DataLength.fixed(6));
        hashMap.put("15", DataLength.fixed(6));
        hashMap.put("16", DataLength.fixed(6));
        hashMap.put("17", DataLength.fixed(6));
        hashMap.put("20", DataLength.fixed(2));
        hashMap.put("21", DataLength.variable(20));
        hashMap.put("22", DataLength.variable(29));
        hashMap.put("30", DataLength.variable(8));
        hashMap.put("37", DataLength.variable(8));
        for (int i = 90; i <= 99; i++) {
            TWO_DIGIT_DATA_LENGTH.put(String.valueOf(i), DataLength.variable(30));
        }
        HashMap hashMap2 = new HashMap();
        THREE_DIGIT_DATA_LENGTH = hashMap2;
        hashMap2.put("235", DataLength.variable(28));
        hashMap2.put("240", DataLength.variable(30));
        hashMap2.put("241", DataLength.variable(30));
        hashMap2.put("242", DataLength.variable(6));
        hashMap2.put("243", DataLength.variable(20));
        hashMap2.put("250", DataLength.variable(30));
        hashMap2.put("251", DataLength.variable(30));
        hashMap2.put("253", DataLength.variable(30));
        hashMap2.put("254", DataLength.variable(20));
        hashMap2.put("255", DataLength.variable(25));
        hashMap2.put("400", DataLength.variable(30));
        hashMap2.put("401", DataLength.variable(30));
        hashMap2.put("402", DataLength.fixed(17));
        hashMap2.put("403", DataLength.variable(30));
        hashMap2.put("410", DataLength.fixed(13));
        hashMap2.put("411", DataLength.fixed(13));
        hashMap2.put("412", DataLength.fixed(13));
        hashMap2.put("413", DataLength.fixed(13));
        hashMap2.put("414", DataLength.fixed(13));
        hashMap2.put("415", DataLength.fixed(13));
        hashMap2.put("416", DataLength.fixed(13));
        hashMap2.put("417", DataLength.fixed(13));
        hashMap2.put("420", DataLength.variable(20));
        hashMap2.put("421", DataLength.variable(15));
        hashMap2.put("422", DataLength.fixed(3));
        hashMap2.put("423", DataLength.variable(15));
        hashMap2.put("424", DataLength.fixed(3));
        hashMap2.put("425", DataLength.variable(15));
        hashMap2.put("426", DataLength.fixed(3));
        hashMap2.put("427", DataLength.variable(3));
        hashMap2.put("710", DataLength.variable(20));
        hashMap2.put("711", DataLength.variable(20));
        hashMap2.put("712", DataLength.variable(20));
        hashMap2.put("713", DataLength.variable(20));
        hashMap2.put("714", DataLength.variable(20));
        hashMap2.put("715", DataLength.variable(20));
        THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH = new HashMap();
        for (int i2 = 310; i2 <= 316; i2++) {
            THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH.put(String.valueOf(i2), DataLength.fixed(6));
        }
        for (int i3 = 320; i3 <= 337; i3++) {
            THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH.put(String.valueOf(i3), DataLength.fixed(6));
        }
        for (int i4 = 340; i4 <= 357; i4++) {
            THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH.put(String.valueOf(i4), DataLength.fixed(6));
        }
        for (int i5 = 360; i5 <= 369; i5++) {
            THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH.put(String.valueOf(i5), DataLength.fixed(6));
        }
        Map<String, DataLength> map = THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH;
        map.put("390", DataLength.variable(15));
        map.put("391", DataLength.variable(18));
        map.put("392", DataLength.variable(15));
        map.put("393", DataLength.variable(18));
        map.put("394", DataLength.fixed(4));
        map.put("395", DataLength.fixed(6));
        map.put("703", DataLength.variable(30));
        map.put("723", DataLength.variable(30));
        HashMap hashMap3 = new HashMap();
        FOUR_DIGIT_DATA_LENGTH = hashMap3;
        hashMap3.put("4300", DataLength.variable(35));
        hashMap3.put("4301", DataLength.variable(35));
        hashMap3.put("4302", DataLength.variable(70));
        hashMap3.put("4303", DataLength.variable(70));
        hashMap3.put("4304", DataLength.variable(70));
        hashMap3.put("4305", DataLength.variable(70));
        hashMap3.put("4306", DataLength.variable(70));
        hashMap3.put("4307", DataLength.fixed(2));
        hashMap3.put("4308", DataLength.variable(30));
        hashMap3.put("4309", DataLength.fixed(20));
        hashMap3.put("4310", DataLength.variable(35));
        hashMap3.put("4311", DataLength.variable(35));
        hashMap3.put("4312", DataLength.variable(70));
        hashMap3.put("4313", DataLength.variable(70));
        hashMap3.put("4314", DataLength.variable(70));
        hashMap3.put("4315", DataLength.variable(70));
        hashMap3.put("4316", DataLength.variable(70));
        hashMap3.put("4317", DataLength.fixed(2));
        hashMap3.put("4318", DataLength.variable(20));
        hashMap3.put("4319", DataLength.variable(30));
        hashMap3.put("4320", DataLength.variable(35));
        hashMap3.put("4321", DataLength.fixed(1));
        hashMap3.put("4322", DataLength.fixed(1));
        hashMap3.put("4323", DataLength.fixed(1));
        hashMap3.put("4324", DataLength.fixed(10));
        hashMap3.put("4325", DataLength.fixed(10));
        hashMap3.put("4326", DataLength.fixed(6));
        hashMap3.put("7001", DataLength.fixed(13));
        hashMap3.put("7002", DataLength.variable(30));
        hashMap3.put("7003", DataLength.fixed(10));
        hashMap3.put("7004", DataLength.variable(4));
        hashMap3.put("7005", DataLength.variable(12));
        hashMap3.put("7006", DataLength.fixed(6));
        hashMap3.put("7007", DataLength.variable(12));
        hashMap3.put("7008", DataLength.variable(3));
        hashMap3.put("7009", DataLength.variable(10));
        hashMap3.put("7010", DataLength.variable(2));
        hashMap3.put("7011", DataLength.variable(10));
        hashMap3.put("7020", DataLength.variable(20));
        hashMap3.put("7021", DataLength.variable(20));
        hashMap3.put("7022", DataLength.variable(20));
        hashMap3.put("7023", DataLength.variable(30));
        hashMap3.put("7040", DataLength.fixed(4));
        hashMap3.put("7240", DataLength.variable(20));
        hashMap3.put("8001", DataLength.fixed(14));
        hashMap3.put("8002", DataLength.variable(20));
        hashMap3.put("8003", DataLength.variable(30));
        hashMap3.put("8004", DataLength.variable(30));
        hashMap3.put("8005", DataLength.fixed(6));
        hashMap3.put("8006", DataLength.fixed(18));
        hashMap3.put("8007", DataLength.variable(34));
        hashMap3.put("8008", DataLength.variable(12));
        hashMap3.put("8009", DataLength.variable(50));
        hashMap3.put("8010", DataLength.variable(30));
        hashMap3.put("8011", DataLength.variable(12));
        hashMap3.put("8012", DataLength.variable(20));
        hashMap3.put("8013", DataLength.variable(25));
        hashMap3.put("8017", DataLength.fixed(18));
        hashMap3.put("8018", DataLength.fixed(18));
        hashMap3.put("8019", DataLength.variable(10));
        hashMap3.put("8020", DataLength.variable(25));
        hashMap3.put("8026", DataLength.fixed(18));
        hashMap3.put("8100", DataLength.fixed(6));
        hashMap3.put("8101", DataLength.fixed(10));
        hashMap3.put("8102", DataLength.fixed(2));
        hashMap3.put("8110", DataLength.variable(70));
        hashMap3.put("8111", DataLength.fixed(4));
        hashMap3.put("8112", DataLength.variable(70));
        hashMap3.put("8200", DataLength.variable(70));
    }

    private FieldParser() {
    }

    static String parseFieldsInGeneralPurpose(String rawInformation) throws NotFoundException {
        if (rawInformation.isEmpty()) {
            return null;
        }
        if (rawInformation.length() < 2) {
            throw NotFoundException.getNotFoundInstance();
        }
        DataLength twoDigitDataLength = TWO_DIGIT_DATA_LENGTH.get(rawInformation.substring(0, 2));
        if (twoDigitDataLength != null) {
            if (twoDigitDataLength.variable) {
                return processVariableAI(2, twoDigitDataLength.length, rawInformation);
            }
            return processFixedAI(2, twoDigitDataLength.length, rawInformation);
        }
        if (rawInformation.length() < 3) {
            throw NotFoundException.getNotFoundInstance();
        }
        String firstThreeDigits = rawInformation.substring(0, 3);
        DataLength threeDigitDataLength = THREE_DIGIT_DATA_LENGTH.get(firstThreeDigits);
        if (threeDigitDataLength != null) {
            if (threeDigitDataLength.variable) {
                return processVariableAI(3, threeDigitDataLength.length, rawInformation);
            }
            return processFixedAI(3, threeDigitDataLength.length, rawInformation);
        }
        if (rawInformation.length() < 4) {
            throw NotFoundException.getNotFoundInstance();
        }
        DataLength threeDigitPlusDigitDataLength = THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH.get(firstThreeDigits);
        if (threeDigitPlusDigitDataLength != null) {
            if (threeDigitPlusDigitDataLength.variable) {
                return processVariableAI(4, threeDigitPlusDigitDataLength.length, rawInformation);
            }
            return processFixedAI(4, threeDigitPlusDigitDataLength.length, rawInformation);
        }
        DataLength firstFourDigitLength = FOUR_DIGIT_DATA_LENGTH.get(rawInformation.substring(0, 4));
        if (firstFourDigitLength != null) {
            if (firstFourDigitLength.variable) {
                return processVariableAI(4, firstFourDigitLength.length, rawInformation);
            }
            return processFixedAI(4, firstFourDigitLength.length, rawInformation);
        }
        throw NotFoundException.getNotFoundInstance();
    }

    private static String processFixedAI(int aiSize, int fieldSize, String rawInformation) throws NotFoundException {
        if (rawInformation.length() < aiSize) {
            throw NotFoundException.getNotFoundInstance();
        }
        String ai = rawInformation.substring(0, aiSize);
        if (rawInformation.length() < aiSize + fieldSize) {
            throw NotFoundException.getNotFoundInstance();
        }
        String field = rawInformation.substring(aiSize, aiSize + fieldSize);
        String remaining = rawInformation.substring(aiSize + fieldSize);
        String result = '(' + ai + ')' + field;
        String parsedAI = parseFieldsInGeneralPurpose(remaining);
        return parsedAI == null ? result : result + parsedAI;
    }

    private static String processVariableAI(int aiSize, int variableFieldSize, String rawInformation) throws NotFoundException {
        String ai = rawInformation.substring(0, aiSize);
        int maxSize = Math.min(rawInformation.length(), aiSize + variableFieldSize);
        String field = rawInformation.substring(aiSize, maxSize);
        String remaining = rawInformation.substring(maxSize);
        String result = '(' + ai + ')' + field;
        String parsedAI = parseFieldsInGeneralPurpose(remaining);
        return parsedAI == null ? result : result + parsedAI;
    }

    private static final class DataLength {
        final int length;
        final boolean variable;

        private DataLength(boolean variable, int length) {
            this.variable = variable;
            this.length = length;
        }

        static DataLength fixed(int length) {
            return new DataLength(false, length);
        }

        static DataLength variable(int length) {
            return new DataLength(true, length);
        }
    }
}
