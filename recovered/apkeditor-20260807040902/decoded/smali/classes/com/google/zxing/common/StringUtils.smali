.class public final Lcom/google/zxing/common/StringUtils;
.super Ljava/lang/Object;
.source "StringUtils.java"


# static fields
.field private static final ASSUME_SHIFT_JIS:Z

.field private static final EUC_JP:Ljava/nio/charset/Charset;

.field public static final GB2312:Ljava/lang/String; = "GB2312"

.field public static final GB2312_CHARSET:Ljava/nio/charset/Charset;

.field private static final PLATFORM_DEFAULT_ENCODING:Ljava/nio/charset/Charset;

.field public static final SHIFT_JIS:Ljava/lang/String; = "SJIS"

.field public static final SHIFT_JIS_CHARSET:Ljava/nio/charset/Charset;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .line 34
    invoke-static {}, Ljava/nio/charset/Charset;->defaultCharset()Ljava/nio/charset/Charset;

    move-result-object v0

    sput-object v0, Lcom/google/zxing/common/StringUtils;->PLATFORM_DEFAULT_ENCODING:Ljava/nio/charset/Charset;

    .line 39
    :try_start_0
    const-string v0, "SJIS"

    invoke-static {v0}, Ljava/nio/charset/Charset;->forName(Ljava/lang/String;)Ljava/nio/charset/Charset;

    move-result-object v0
    :try_end_0
    .catch Ljava/nio/charset/UnsupportedCharsetException; {:try_start_0 .. :try_end_0} :catch_0

    .line 43
    .local v0, "sjisCharset":Ljava/nio/charset/Charset;
    goto :goto_0

    .line 40
    .end local v0    # "sjisCharset":Ljava/nio/charset/Charset;
    :catch_0
    move-exception v0

    .line 42
    .local v0, "ucee":Ljava/nio/charset/UnsupportedCharsetException;
    const/4 v1, 0x0

    move-object v0, v1

    .line 44
    .local v0, "sjisCharset":Ljava/nio/charset/Charset;
    :goto_0
    sput-object v0, Lcom/google/zxing/common/StringUtils;->SHIFT_JIS_CHARSET:Ljava/nio/charset/Charset;

    .line 50
    .end local v0    # "sjisCharset":Ljava/nio/charset/Charset;
    :try_start_1
    const-string v0, "GB2312"

    invoke-static {v0}, Ljava/nio/charset/Charset;->forName(Ljava/lang/String;)Ljava/nio/charset/Charset;

    move-result-object v0
    :try_end_1
    .catch Ljava/nio/charset/UnsupportedCharsetException; {:try_start_1 .. :try_end_1} :catch_1

    .line 54
    .local v0, "gb2312Charset":Ljava/nio/charset/Charset;
    goto :goto_1

    .line 51
    .end local v0    # "gb2312Charset":Ljava/nio/charset/Charset;
    :catch_1
    move-exception v0

    .line 53
    .local v0, "ucee":Ljava/nio/charset/UnsupportedCharsetException;
    const/4 v1, 0x0

    move-object v0, v1

    .line 55
    .local v0, "gb2312Charset":Ljava/nio/charset/Charset;
    :goto_1
    sput-object v0, Lcom/google/zxing/common/StringUtils;->GB2312_CHARSET:Ljava/nio/charset/Charset;

    .line 61
    .end local v0    # "gb2312Charset":Ljava/nio/charset/Charset;
    :try_start_2
    const-string v0, "EUC_JP"

    invoke-static {v0}, Ljava/nio/charset/Charset;->forName(Ljava/lang/String;)Ljava/nio/charset/Charset;

    move-result-object v0
    :try_end_2
    .catch Ljava/nio/charset/UnsupportedCharsetException; {:try_start_2 .. :try_end_2} :catch_2

    .line 65
    .local v0, "eucJpCharset":Ljava/nio/charset/Charset;
    goto :goto_2

    .line 62
    .end local v0    # "eucJpCharset":Ljava/nio/charset/Charset;
    :catch_2
    move-exception v0

    .line 64
    .local v0, "ucee":Ljava/nio/charset/UnsupportedCharsetException;
    const/4 v1, 0x0

    move-object v0, v1

    .line 66
    .local v0, "eucJpCharset":Ljava/nio/charset/Charset;
    :goto_2
    sput-object v0, Lcom/google/zxing/common/StringUtils;->EUC_JP:Ljava/nio/charset/Charset;

    .line 68
    .end local v0    # "eucJpCharset":Ljava/nio/charset/Charset;
    sget-object v1, Lcom/google/zxing/common/StringUtils;->SHIFT_JIS_CHARSET:Ljava/nio/charset/Charset;

    if-eqz v1, :cond_0

    sget-object v2, Lcom/google/zxing/common/StringUtils;->PLATFORM_DEFAULT_ENCODING:Ljava/nio/charset/Charset;

    .line 69
    invoke-virtual {v1, v2}, Ljava/nio/charset/Charset;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_1

    :cond_0
    if-eqz v0, :cond_2

    sget-object v1, Lcom/google/zxing/common/StringUtils;->PLATFORM_DEFAULT_ENCODING:Ljava/nio/charset/Charset;

    .line 70
    invoke-virtual {v0, v1}, Ljava/nio/charset/Charset;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_2

    :cond_1
    const/4 v0, 0x1

    goto :goto_3

    :cond_2
    const/4 v0, 0x0

    :goto_3
    sput-boolean v0, Lcom/google/zxing/common/StringUtils;->ASSUME_SHIFT_JIS:Z

    .line 68
    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .line 76
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static guessCharset([BLjava/util/Map;)Ljava/nio/charset/Charset;
    .locals 20
    .param p0, "bytes"    # [B
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "([B",
            "Ljava/util/Map<",
            "Lcom/google/zxing/DecodeHintType;",
            "*>;)",
            "Ljava/nio/charset/Charset;"
        }
    .end annotation

    .line 109
    .local p1, "hints":Ljava/util/Map;, "Ljava/util/Map<Lcom/google/zxing/DecodeHintType;*>;"
    move-object/from16 v0, p0

    move-object/from16 v1, p1

    if-eqz v1, :cond_0

    sget-object v2, Lcom/google/zxing/DecodeHintType;->CHARACTER_SET:Lcom/google/zxing/DecodeHintType;

    invoke-interface {v1, v2}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 110
    sget-object v2, Lcom/google/zxing/DecodeHintType;->CHARACTER_SET:Lcom/google/zxing/DecodeHintType;

    invoke-interface {v1, v2}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Ljava/nio/charset/Charset;->forName(Ljava/lang/String;)Ljava/nio/charset/Charset;

    move-result-object v2

    return-object v2

    .line 114
    :cond_0
    array-length v2, v0

    const/4 v3, 0x2

    const/4 v4, 0x0

    const/4 v5, 0x1

    if-le v2, v3, :cond_3

    aget-byte v2, v0, v4

    const/4 v6, -0x2

    const/4 v7, -0x1

    if-ne v2, v6, :cond_1

    aget-byte v2, v0, v5

    if-eq v2, v7, :cond_2

    :cond_1
    aget-byte v2, v0, v4

    if-ne v2, v7, :cond_3

    aget-byte v2, v0, v5

    if-ne v2, v6, :cond_3

    .line 117
    :cond_2
    sget-object v2, Ljava/nio/charset/StandardCharsets;->UTF_16:Ljava/nio/charset/Charset;

    return-object v2

    .line 122
    :cond_3
    array-length v2, v0

    .line 123
    .local v2, "length":I
    const/4 v6, 0x1

    .line 124
    .local v6, "canBeISO88591":Z
    sget-object v7, Lcom/google/zxing/common/StringUtils;->SHIFT_JIS_CHARSET:Ljava/nio/charset/Charset;

    if-eqz v7, :cond_4

    const/4 v7, 0x1

    goto :goto_0

    :cond_4
    const/4 v7, 0x0

    .line 125
    .local v7, "canBeShiftJIS":Z
    :goto_0
    const/4 v8, 0x1

    .line 126
    .local v8, "canBeUTF8":Z
    const/4 v9, 0x0

    .line 127
    .local v9, "utf8BytesLeft":I
    const/4 v10, 0x0

    .line 128
    .local v10, "utf2BytesChars":I
    const/4 v11, 0x0

    .line 129
    .local v11, "utf3BytesChars":I
    const/4 v12, 0x0

    .line 130
    .local v12, "utf4BytesChars":I
    const/4 v13, 0x0

    .line 131
    .local v13, "sjisBytesLeft":I
    const/4 v14, 0x0

    .line 132
    .local v14, "sjisKatakanaChars":I
    const/4 v15, 0x0

    .line 133
    .local v15, "sjisCurKatakanaWordLength":I
    const/16 v16, 0x0

    .line 134
    .local v16, "sjisCurDoubleBytesWordLength":I
    const/16 v17, 0x0

    .line 135
    .local v17, "sjisMaxKatakanaWordLength":I
    const/16 v18, 0x0

    .line 136
    .local v18, "sjisMaxDoubleBytesWordLength":I
    const/16 v19, 0x0

    .line 138
    .local v19, "isoHighOther":I
    array-length v3, v0

    const/4 v5, 0x3

    if-le v3, v5, :cond_5

    aget-byte v3, v0, v4

    const/16 v4, -0x11

    if-ne v3, v4, :cond_5

    const/4 v3, 0x1

    aget-byte v4, v0, v3

    const/16 v3, -0x45

    if-ne v4, v3, :cond_5

    const/4 v3, 0x2

    aget-byte v4, v0, v3

    const/16 v3, -0x41

    if-ne v4, v3, :cond_5

    const/4 v4, 0x1

    goto :goto_1

    :cond_5
    const/4 v4, 0x0

    :goto_1
    move v3, v4

    .line 143
    .local v3, "utf8bom":Z
    const/4 v4, 0x0

    move/from16 v5, v17

    move/from16 v1, v18

    .line 144
    .end local v17    # "sjisMaxKatakanaWordLength":I
    .end local v18    # "sjisMaxDoubleBytesWordLength":I
    .local v1, "sjisMaxDoubleBytesWordLength":I
    .local v4, "i":I
    .local v5, "sjisMaxKatakanaWordLength":I
    :goto_2
    if-ge v4, v2, :cond_1c

    if-nez v6, :cond_7

    if-nez v7, :cond_7

    if-eqz v8, :cond_6

    goto :goto_3

    :cond_6
    move/from16 v18, v2

    goto/16 :goto_9

    .line 147
    :cond_7
    :goto_3
    move/from16 v18, v2

    .end local v2    # "length":I
    .local v18, "length":I
    aget-byte v2, v0, v4

    and-int/lit16 v2, v2, 0xff

    .line 150
    .local v2, "value":I
    if-eqz v8, :cond_e

    .line 151
    if-lez v9, :cond_9

    .line 152
    and-int/lit16 v0, v2, 0x80

    if-nez v0, :cond_8

    .line 153
    const/4 v0, 0x0

    move v8, v0

    .end local v8    # "canBeUTF8":Z
    .local v0, "canBeUTF8":Z
    goto :goto_4

    .line 155
    .end local v0    # "canBeUTF8":Z
    .restart local v8    # "canBeUTF8":Z
    :cond_8
    add-int/lit8 v9, v9, -0x1

    goto :goto_4

    .line 157
    :cond_9
    and-int/lit16 v0, v2, 0x80

    if-eqz v0, :cond_e

    .line 158
    and-int/lit8 v0, v2, 0x40

    if-nez v0, :cond_a

    .line 159
    const/4 v0, 0x0

    move v8, v0

    .end local v8    # "canBeUTF8":Z
    .restart local v0    # "canBeUTF8":Z
    goto :goto_4

    .line 161
    .end local v0    # "canBeUTF8":Z
    .restart local v8    # "canBeUTF8":Z
    :cond_a
    add-int/lit8 v9, v9, 0x1

    .line 162
    and-int/lit8 v0, v2, 0x20

    if-nez v0, :cond_b

    .line 163
    add-int/lit8 v10, v10, 0x1

    goto :goto_4

    .line 165
    :cond_b
    add-int/lit8 v9, v9, 0x1

    .line 166
    and-int/lit8 v0, v2, 0x10

    if-nez v0, :cond_c

    .line 167
    add-int/lit8 v11, v11, 0x1

    goto :goto_4

    .line 169
    :cond_c
    add-int/lit8 v9, v9, 0x1

    .line 170
    and-int/lit8 v0, v2, 0x8

    if-nez v0, :cond_d

    .line 171
    add-int/lit8 v12, v12, 0x1

    goto :goto_4

    .line 173
    :cond_d
    const/4 v0, 0x0

    move v8, v0

    .line 182
    :cond_e
    :goto_4
    const/16 v0, 0x7f

    if-eqz v6, :cond_11

    .line 183
    if-le v2, v0, :cond_f

    const/16 v0, 0xa0

    if-ge v2, v0, :cond_f

    .line 184
    const/4 v0, 0x0

    move v6, v0

    .end local v6    # "canBeISO88591":Z
    .local v0, "canBeISO88591":Z
    goto :goto_5

    .line 185
    .end local v0    # "canBeISO88591":Z
    .restart local v6    # "canBeISO88591":Z
    :cond_f
    const/16 v0, 0x9f

    if-le v2, v0, :cond_11

    const/16 v0, 0xc0

    if-lt v2, v0, :cond_10

    const/16 v0, 0xd7

    if-eq v2, v0, :cond_10

    const/16 v0, 0xf7

    if-ne v2, v0, :cond_11

    .line 186
    :cond_10
    add-int/lit8 v19, v19, 0x1

    .line 191
    :cond_11
    :goto_5
    if-eqz v7, :cond_1b

    .line 192
    if-lez v13, :cond_14

    .line 193
    const/16 v0, 0x40

    if-lt v2, v0, :cond_13

    const/16 v0, 0x7f

    if-eq v2, v0, :cond_13

    const/16 v0, 0xfc

    if-le v2, v0, :cond_12

    goto :goto_6

    .line 196
    :cond_12
    add-int/lit8 v13, v13, -0x1

    goto :goto_8

    .line 194
    :cond_13
    :goto_6
    const/4 v0, 0x0

    move v7, v0

    .end local v7    # "canBeShiftJIS":Z
    .local v0, "canBeShiftJIS":Z
    goto :goto_8

    .line 198
    .end local v0    # "canBeShiftJIS":Z
    .restart local v7    # "canBeShiftJIS":Z
    :cond_14
    const/16 v0, 0x80

    if-eq v2, v0, :cond_1a

    const/16 v0, 0xa0

    if-eq v2, v0, :cond_1a

    const/16 v0, 0xef

    if-le v2, v0, :cond_15

    goto :goto_7

    .line 200
    :cond_15
    const/16 v0, 0xa0

    if-le v2, v0, :cond_17

    const/16 v0, 0xe0

    if-ge v2, v0, :cond_17

    .line 201
    add-int/lit8 v14, v14, 0x1

    .line 202
    const/4 v0, 0x0

    .line 203
    .end local v16    # "sjisCurDoubleBytesWordLength":I
    .local v0, "sjisCurDoubleBytesWordLength":I
    add-int/lit8 v15, v15, 0x1

    .line 204
    if-le v15, v5, :cond_16

    .line 205
    move v5, v15

    move/from16 v16, v0

    goto :goto_8

    .line 204
    :cond_16
    move/from16 v16, v0

    goto :goto_8

    .line 207
    .end local v0    # "sjisCurDoubleBytesWordLength":I
    .restart local v16    # "sjisCurDoubleBytesWordLength":I
    :cond_17
    const/16 v0, 0x7f

    if-le v2, v0, :cond_19

    .line 208
    add-int/lit8 v13, v13, 0x1

    .line 210
    const/4 v0, 0x0

    .line 211
    .end local v15    # "sjisCurKatakanaWordLength":I
    .local v0, "sjisCurKatakanaWordLength":I
    add-int/lit8 v15, v16, 0x1

    .line 212
    .end local v16    # "sjisCurDoubleBytesWordLength":I
    .local v15, "sjisCurDoubleBytesWordLength":I
    if-le v15, v1, :cond_18

    .line 213
    move v1, v15

    move/from16 v16, v15

    move v15, v0

    goto :goto_8

    .line 212
    :cond_18
    move/from16 v16, v15

    move v15, v0

    goto :goto_8

    .line 217
    .end local v0    # "sjisCurKatakanaWordLength":I
    .local v15, "sjisCurKatakanaWordLength":I
    .restart local v16    # "sjisCurDoubleBytesWordLength":I
    :cond_19
    const/4 v0, 0x0

    .line 218
    .end local v15    # "sjisCurKatakanaWordLength":I
    .restart local v0    # "sjisCurKatakanaWordLength":I
    const/4 v15, 0x0

    move/from16 v16, v15

    move v15, v0

    .end local v16    # "sjisCurDoubleBytesWordLength":I
    .local v15, "sjisCurDoubleBytesWordLength":I
    goto :goto_8

    .line 199
    .end local v0    # "sjisCurKatakanaWordLength":I
    .local v15, "sjisCurKatakanaWordLength":I
    .restart local v16    # "sjisCurDoubleBytesWordLength":I
    :cond_1a
    :goto_7
    const/4 v0, 0x0

    move v7, v0

    .line 145
    .end local v2    # "value":I
    :cond_1b
    :goto_8
    add-int/lit8 v4, v4, 0x1

    move-object/from16 v0, p0

    move/from16 v2, v18

    goto/16 :goto_2

    .line 144
    .end local v18    # "length":I
    .local v2, "length":I
    :cond_1c
    move/from16 v18, v2

    .line 223
    .end local v2    # "length":I
    .end local v4    # "i":I
    .restart local v18    # "length":I
    :goto_9
    if-eqz v8, :cond_1d

    if-lez v9, :cond_1d

    .line 224
    const/4 v8, 0x0

    .line 226
    :cond_1d
    if-eqz v7, :cond_1e

    if-lez v13, :cond_1e

    .line 227
    const/4 v7, 0x0

    .line 231
    :cond_1e
    if-eqz v8, :cond_20

    if-nez v3, :cond_1f

    add-int v0, v10, v11

    add-int/2addr v0, v12

    if-lez v0, :cond_20

    .line 232
    :cond_1f
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    return-object v0

    .line 235
    :cond_20
    if-eqz v7, :cond_22

    sget-boolean v0, Lcom/google/zxing/common/StringUtils;->ASSUME_SHIFT_JIS:Z

    if-nez v0, :cond_21

    const/4 v0, 0x3

    if-ge v5, v0, :cond_21

    if-lt v1, v0, :cond_22

    .line 236
    :cond_21
    sget-object v0, Lcom/google/zxing/common/StringUtils;->SHIFT_JIS_CHARSET:Ljava/nio/charset/Charset;

    return-object v0

    .line 243
    :cond_22
    if-eqz v6, :cond_26

    if-eqz v7, :cond_26

    .line 244
    const/4 v0, 0x2

    if-ne v5, v0, :cond_24

    if-eq v14, v0, :cond_23

    goto :goto_a

    :cond_23
    move/from16 v2, v18

    goto :goto_b

    :cond_24
    :goto_a
    mul-int/lit8 v0, v19, 0xa

    move/from16 v2, v18

    .end local v18    # "length":I
    .restart local v2    # "length":I
    if-lt v0, v2, :cond_25

    :goto_b
    sget-object v0, Lcom/google/zxing/common/StringUtils;->SHIFT_JIS_CHARSET:Ljava/nio/charset/Charset;

    goto :goto_c

    :cond_25
    sget-object v0, Ljava/nio/charset/StandardCharsets;->ISO_8859_1:Ljava/nio/charset/Charset;

    :goto_c
    return-object v0

    .line 243
    .end local v2    # "length":I
    .restart local v18    # "length":I
    :cond_26
    move/from16 v2, v18

    .line 249
    .end local v18    # "length":I
    .restart local v2    # "length":I
    if-eqz v6, :cond_27

    .line 250
    sget-object v0, Ljava/nio/charset/StandardCharsets;->ISO_8859_1:Ljava/nio/charset/Charset;

    return-object v0

    .line 252
    :cond_27
    if-eqz v7, :cond_28

    .line 253
    sget-object v0, Lcom/google/zxing/common/StringUtils;->SHIFT_JIS_CHARSET:Ljava/nio/charset/Charset;

    return-object v0

    .line 255
    :cond_28
    if-eqz v8, :cond_29

    .line 256
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    return-object v0

    .line 259
    :cond_29
    sget-object v0, Lcom/google/zxing/common/StringUtils;->PLATFORM_DEFAULT_ENCODING:Ljava/nio/charset/Charset;

    return-object v0
.end method

.method public static guessEncoding([BLjava/util/Map;)Ljava/lang/String;
    .locals 2
    .param p0, "bytes"    # [B
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "([B",
            "Ljava/util/Map<",
            "Lcom/google/zxing/DecodeHintType;",
            "*>;)",
            "Ljava/lang/String;"
        }
    .end annotation

    .line 86
    .local p1, "hints":Ljava/util/Map;, "Ljava/util/Map<Lcom/google/zxing/DecodeHintType;*>;"
    invoke-static {p0, p1}, Lcom/google/zxing/common/StringUtils;->guessCharset([BLjava/util/Map;)Ljava/nio/charset/Charset;

    move-result-object v0

    .line 87
    .local v0, "c":Ljava/nio/charset/Charset;
    sget-object v1, Lcom/google/zxing/common/StringUtils;->SHIFT_JIS_CHARSET:Ljava/nio/charset/Charset;

    invoke-virtual {v0, v1}, Ljava/nio/charset/Charset;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 88
    const-string v1, "SJIS"

    return-object v1

    .line 90
    :cond_0
    sget-object v1, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {v0, v1}, Ljava/nio/charset/Charset;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 91
    const-string v1, "UTF8"

    return-object v1

    .line 93
    :cond_1
    sget-object v1, Ljava/nio/charset/StandardCharsets;->ISO_8859_1:Ljava/nio/charset/Charset;

    invoke-virtual {v0, v1}, Ljava/nio/charset/Charset;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_2

    .line 94
    const-string v1, "ISO8859_1"

    return-object v1

    .line 96
    :cond_2
    invoke-virtual {v0}, Ljava/nio/charset/Charset;->name()Ljava/lang/String;

    move-result-object v1

    return-object v1
.end method
