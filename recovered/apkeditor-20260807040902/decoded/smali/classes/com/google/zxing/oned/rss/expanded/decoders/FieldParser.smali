.class final Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;
.super Ljava/lang/Object;
.source "FieldParser.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;
    }
.end annotation


# static fields
.field private static final FOUR_DIGIT_DATA_LENGTH:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;",
            ">;"
        }
    .end annotation
.end field

.field private static final THREE_DIGIT_DATA_LENGTH:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;",
            ">;"
        }
    .end annotation
.end field

.field private static final THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;",
            ">;"
        }
    .end annotation
.end field

.field private static final TWO_DIGIT_DATA_LENGTH:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 15

    .line 40
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->TWO_DIGIT_DATA_LENGTH:Ljava/util/Map;

    .line 42
    const/16 v1, 0x12

    invoke-static {v1}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    const-string v3, "00"

    invoke-interface {v0, v3, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 43
    const/16 v2, 0xe

    invoke-static {v2}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v3

    const-string v4, "01"

    invoke-interface {v0, v4, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 44
    const-string v3, "02"

    invoke-static {v2}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v4

    invoke-interface {v0, v3, v4}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 45
    const/16 v3, 0x14

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v4

    const-string v5, "10"

    invoke-interface {v0, v5, v4}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 46
    const/4 v4, 0x6

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v5

    const-string v6, "11"

    invoke-interface {v0, v6, v5}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 47
    const-string v5, "12"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v5, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 48
    const-string v5, "13"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v5, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 49
    const-string v5, "15"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v5, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 50
    const-string v5, "16"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v5, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 51
    const-string v5, "17"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v5, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 52
    const/4 v5, 0x2

    invoke-static {v5}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    const-string v7, "20"

    invoke-interface {v0, v7, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 53
    const-string v6, "21"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v7

    invoke-interface {v0, v6, v7}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 54
    const/16 v6, 0x1d

    invoke-static {v6}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    const-string v7, "22"

    invoke-interface {v0, v7, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 55
    const/16 v6, 0x8

    invoke-static {v6}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v7

    const-string v8, "30"

    invoke-interface {v0, v8, v7}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 56
    const-string v7, "37"

    invoke-static {v6}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v7, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 58
    const/16 v0, 0x5a

    .local v0, "i":I
    :goto_0
    const/16 v6, 0x63

    const/16 v7, 0x1e

    if-gt v0, v6, :cond_0

    .line 59
    sget-object v6, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->TWO_DIGIT_DATA_LENGTH:Ljava/util/Map;

    invoke-static {v0}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v8

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v7

    invoke-interface {v6, v8, v7}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 58
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 63
    .end local v0    # "i":I
    :cond_0
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->THREE_DIGIT_DATA_LENGTH:Ljava/util/Map;

    .line 65
    const/16 v6, 0x1c

    invoke-static {v6}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    const-string v8, "235"

    invoke-interface {v0, v8, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 66
    const-string v6, "240"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v8

    invoke-interface {v0, v6, v8}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 67
    const-string v6, "241"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v8

    invoke-interface {v0, v6, v8}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 68
    const-string v6, "242"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v8

    invoke-interface {v0, v6, v8}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 69
    const-string v6, "243"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v8

    invoke-interface {v0, v6, v8}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 70
    const-string v6, "250"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v8

    invoke-interface {v0, v6, v8}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 71
    const-string v6, "251"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v8

    invoke-interface {v0, v6, v8}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 72
    const-string v6, "253"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v8

    invoke-interface {v0, v6, v8}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 73
    const-string v6, "254"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v8

    invoke-interface {v0, v6, v8}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 74
    const-string v6, "255"

    const/16 v8, 0x19

    invoke-static {v8}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v9

    invoke-interface {v0, v6, v9}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 75
    const-string v6, "400"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v9

    invoke-interface {v0, v6, v9}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 76
    const-string v6, "401"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v9

    invoke-interface {v0, v6, v9}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 77
    const/16 v6, 0x11

    invoke-static {v6}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    const-string v9, "402"

    invoke-interface {v0, v9, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 78
    const-string v6, "403"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v9

    invoke-interface {v0, v6, v9}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 79
    const-string v6, "410"

    const/16 v9, 0xd

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 80
    const-string v6, "411"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 81
    const-string v6, "412"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 82
    const-string v6, "413"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 83
    const-string v6, "414"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 84
    const-string v6, "415"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 85
    const-string v6, "416"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 86
    const-string v6, "417"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 87
    const-string v6, "420"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 88
    const-string v6, "421"

    const/16 v10, 0xf

    invoke-static {v10}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 89
    const-string v6, "422"

    const/4 v11, 0x3

    invoke-static {v11}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 90
    const-string v6, "423"

    invoke-static {v10}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 91
    const-string v6, "424"

    invoke-static {v11}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 92
    const-string v6, "425"

    invoke-static {v10}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 93
    const-string v6, "426"

    invoke-static {v11}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 94
    const-string v6, "427"

    invoke-static {v11}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 95
    const-string v6, "710"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 96
    const-string v6, "711"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 97
    const-string v6, "712"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 98
    const-string v6, "713"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 99
    const-string v6, "714"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 100
    const-string v6, "715"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 103
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH:Ljava/util/Map;

    .line 105
    const/16 v0, 0x136

    .restart local v0    # "i":I
    :goto_1
    const/16 v6, 0x13c

    if-gt v0, v6, :cond_1

    .line 106
    sget-object v6, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH:Ljava/util/Map;

    invoke-static {v0}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v12

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v13

    invoke-interface {v6, v12, v13}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 105
    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    .line 108
    .end local v0    # "i":I
    :cond_1
    const/16 v0, 0x140

    .restart local v0    # "i":I
    :goto_2
    const/16 v6, 0x151

    if-gt v0, v6, :cond_2

    .line 109
    sget-object v6, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH:Ljava/util/Map;

    invoke-static {v0}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v12

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v13

    invoke-interface {v6, v12, v13}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 108
    add-int/lit8 v0, v0, 0x1

    goto :goto_2

    .line 111
    .end local v0    # "i":I
    :cond_2
    const/16 v0, 0x154

    .restart local v0    # "i":I
    :goto_3
    const/16 v6, 0x165

    if-gt v0, v6, :cond_3

    .line 112
    sget-object v6, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH:Ljava/util/Map;

    invoke-static {v0}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v12

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v13

    invoke-interface {v6, v12, v13}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 111
    add-int/lit8 v0, v0, 0x1

    goto :goto_3

    .line 114
    .end local v0    # "i":I
    :cond_3
    const/16 v0, 0x168

    .restart local v0    # "i":I
    :goto_4
    const/16 v6, 0x171

    if-gt v0, v6, :cond_4

    .line 115
    sget-object v6, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH:Ljava/util/Map;

    invoke-static {v0}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v12

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v13

    invoke-interface {v6, v12, v13}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 114
    add-int/lit8 v0, v0, 0x1

    goto :goto_4

    .line 117
    .end local v0    # "i":I
    :cond_4
    sget-object v0, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH:Ljava/util/Map;

    const-string v6, "390"

    invoke-static {v10}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 118
    const-string v6, "391"

    invoke-static {v1}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 119
    const-string v6, "392"

    invoke-static {v10}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 120
    const-string v6, "393"

    invoke-static {v1}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v10

    invoke-interface {v0, v6, v10}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 121
    const-string v6, "394"

    const/4 v10, 0x4

    invoke-static {v10}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 122
    const-string v6, "395"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 123
    const-string v6, "703"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 124
    const-string v6, "723"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 127
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->FOUR_DIGIT_DATA_LENGTH:Ljava/util/Map;

    .line 129
    const-string v6, "4300"

    const/16 v12, 0x23

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v13

    invoke-interface {v0, v6, v13}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 130
    const-string v6, "4301"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v13

    invoke-interface {v0, v6, v13}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 131
    const-string v6, "4302"

    const/16 v13, 0x46

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 132
    const-string v6, "4303"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 133
    const-string v6, "4304"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 134
    const-string v6, "4305"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 135
    const-string v6, "4306"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 136
    const-string v6, "4307"

    invoke-static {v5}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 137
    const-string v6, "4308"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 138
    const-string v6, "4309"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 139
    const-string v6, "4310"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 140
    const-string v6, "4311"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 141
    const-string v6, "4312"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 142
    const-string v6, "4313"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 143
    const-string v6, "4314"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 144
    const-string v6, "4315"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 145
    const-string v6, "4316"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 146
    const-string v6, "4317"

    invoke-static {v5}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 147
    const-string v6, "4318"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 148
    const-string v6, "4319"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 149
    const-string v6, "4320"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 150
    const-string v6, "4321"

    const/4 v12, 0x1

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 151
    const-string v6, "4322"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 152
    const-string v6, "4323"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v12

    invoke-interface {v0, v6, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 153
    const-string v6, "4324"

    const/16 v12, 0xa

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 154
    const-string v6, "4325"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 155
    const-string v6, "4326"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 156
    const-string v6, "7001"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v9

    invoke-interface {v0, v6, v9}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 157
    const-string v6, "7002"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v9

    invoke-interface {v0, v6, v9}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 158
    const-string v6, "7003"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v9

    invoke-interface {v0, v6, v9}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 159
    const-string v6, "7004"

    invoke-static {v10}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v9

    invoke-interface {v0, v6, v9}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 160
    const-string v6, "7005"

    const/16 v9, 0xc

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 161
    const-string v6, "7006"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 162
    const-string v6, "7007"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v14

    invoke-interface {v0, v6, v14}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 163
    const-string v6, "7008"

    invoke-static {v11}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 164
    const-string v6, "7009"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 165
    const-string v6, "7010"

    invoke-static {v5}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 166
    const-string v6, "7011"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 167
    const-string v6, "7020"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 168
    const-string v6, "7021"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 169
    const-string v6, "7022"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 170
    const-string v6, "7023"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 171
    const-string v6, "7040"

    invoke-static {v10}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 172
    const-string v6, "7240"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v11

    invoke-interface {v0, v6, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 173
    const-string v6, "8001"

    invoke-static {v2}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    invoke-interface {v0, v6, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 174
    const-string v2, "8002"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v2, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 175
    const-string v2, "8003"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v2, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 176
    const-string v2, "8004"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v2, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 177
    const-string v2, "8005"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v2, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 178
    const-string v2, "8006"

    invoke-static {v1}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v2, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 179
    const/16 v2, 0x22

    invoke-static {v2}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    const-string v6, "8007"

    invoke-interface {v0, v6, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 180
    const-string v2, "8008"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v2, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 181
    const/16 v2, 0x32

    invoke-static {v2}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    const-string v6, "8009"

    invoke-interface {v0, v6, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 182
    const-string v2, "8010"

    invoke-static {v7}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v2, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 183
    const-string v2, "8011"

    invoke-static {v9}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v6

    invoke-interface {v0, v2, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 184
    const-string v2, "8012"

    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v3

    invoke-interface {v0, v2, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 185
    const-string v2, "8013"

    invoke-static {v8}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v3

    invoke-interface {v0, v2, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 186
    const-string v2, "8017"

    invoke-static {v1}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v3

    invoke-interface {v0, v2, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 187
    const-string v2, "8018"

    invoke-static {v1}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v3

    invoke-interface {v0, v2, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 188
    const-string v2, "8019"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v3

    invoke-interface {v0, v2, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 189
    const-string v2, "8020"

    invoke-static {v8}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v3

    invoke-interface {v0, v2, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 190
    const-string v2, "8026"

    invoke-static {v1}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v1

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 191
    const-string v1, "8100"

    invoke-static {v4}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 192
    const-string v1, "8101"

    invoke-static {v12}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 193
    const-string v1, "8102"

    invoke-static {v5}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 194
    const-string v1, "8110"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 195
    const-string v1, "8111"

    invoke-static {v10}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->fixed(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 196
    const-string v1, "8112"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 197
    const-string v1, "8200"

    invoke-static {v13}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable(I)Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 198
    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .line 200
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 201
    return-void
.end method

.method static parseFieldsInGeneralPurpose(Ljava/lang/String;)Ljava/lang/String;
    .locals 7
    .param p0, "rawInformation"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/google/zxing/NotFoundException;
        }
    .end annotation

    .line 204
    invoke-virtual {p0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 205
    const/4 v0, 0x0

    return-object v0

    .line 210
    :cond_0
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    const/4 v1, 0x2

    if-lt v0, v1, :cond_b

    .line 214
    sget-object v0, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->TWO_DIGIT_DATA_LENGTH:Ljava/util/Map;

    const/4 v2, 0x0

    invoke-virtual {p0, v2, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v3

    invoke-interface {v0, v3}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    .line 215
    .local v0, "twoDigitDataLength":Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;
    if-eqz v0, :cond_2

    .line 216
    iget-boolean v2, v0, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable:Z

    if-eqz v2, :cond_1

    .line 217
    iget v2, v0, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->length:I

    invoke-static {v1, v2, p0}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->processVariableAI(IILjava/lang/String;)Ljava/lang/String;

    move-result-object v1

    return-object v1

    .line 219
    :cond_1
    iget v2, v0, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->length:I

    invoke-static {v1, v2, p0}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->processFixedAI(IILjava/lang/String;)Ljava/lang/String;

    move-result-object v1

    return-object v1

    .line 222
    :cond_2
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v1

    const/4 v3, 0x3

    if-lt v1, v3, :cond_a

    .line 226
    invoke-virtual {p0, v2, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    .line 227
    .local v1, "firstThreeDigits":Ljava/lang/String;
    sget-object v4, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->THREE_DIGIT_DATA_LENGTH:Ljava/util/Map;

    invoke-interface {v4, v1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    .line 228
    .local v4, "threeDigitDataLength":Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;
    if-eqz v4, :cond_4

    .line 229
    iget-boolean v2, v4, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable:Z

    if-eqz v2, :cond_3

    .line 230
    iget v2, v4, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->length:I

    invoke-static {v3, v2, p0}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->processVariableAI(IILjava/lang/String;)Ljava/lang/String;

    move-result-object v2

    return-object v2

    .line 232
    :cond_3
    iget v2, v4, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->length:I

    invoke-static {v3, v2, p0}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->processFixedAI(IILjava/lang/String;)Ljava/lang/String;

    move-result-object v2

    return-object v2

    .line 235
    :cond_4
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v3

    const/4 v5, 0x4

    if-lt v3, v5, :cond_9

    .line 239
    sget-object v3, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->THREE_DIGIT_PLUS_DIGIT_DATA_LENGTH:Ljava/util/Map;

    invoke-interface {v3, v1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    .line 240
    .local v3, "threeDigitPlusDigitDataLength":Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;
    if-eqz v3, :cond_6

    .line 241
    iget-boolean v2, v3, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable:Z

    if-eqz v2, :cond_5

    .line 242
    iget v2, v3, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->length:I

    invoke-static {v5, v2, p0}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->processVariableAI(IILjava/lang/String;)Ljava/lang/String;

    move-result-object v2

    return-object v2

    .line 244
    :cond_5
    iget v2, v3, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->length:I

    invoke-static {v5, v2, p0}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->processFixedAI(IILjava/lang/String;)Ljava/lang/String;

    move-result-object v2

    return-object v2

    .line 247
    :cond_6
    sget-object v6, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->FOUR_DIGIT_DATA_LENGTH:Ljava/util/Map;

    invoke-virtual {p0, v2, v5}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v2

    invoke-interface {v6, v2}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;

    .line 248
    .local v2, "firstFourDigitLength":Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;
    if-eqz v2, :cond_8

    .line 249
    iget-boolean v6, v2, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->variable:Z

    if-eqz v6, :cond_7

    .line 250
    iget v6, v2, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->length:I

    invoke-static {v5, v6, p0}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->processVariableAI(IILjava/lang/String;)Ljava/lang/String;

    move-result-object v5

    return-object v5

    .line 252
    :cond_7
    iget v6, v2, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;->length:I

    invoke-static {v5, v6, p0}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->processFixedAI(IILjava/lang/String;)Ljava/lang/String;

    move-result-object v5

    return-object v5

    .line 255
    :cond_8
    invoke-static {}, Lcom/google/zxing/NotFoundException;->getNotFoundInstance()Lcom/google/zxing/NotFoundException;

    move-result-object v5

    throw v5

    .line 236
    .end local v2    # "firstFourDigitLength":Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;
    .end local v3    # "threeDigitPlusDigitDataLength":Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;
    :cond_9
    invoke-static {}, Lcom/google/zxing/NotFoundException;->getNotFoundInstance()Lcom/google/zxing/NotFoundException;

    move-result-object v2

    throw v2

    .line 223
    .end local v1    # "firstThreeDigits":Ljava/lang/String;
    .end local v4    # "threeDigitDataLength":Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;
    :cond_a
    invoke-static {}, Lcom/google/zxing/NotFoundException;->getNotFoundInstance()Lcom/google/zxing/NotFoundException;

    move-result-object v1

    throw v1

    .line 211
    .end local v0    # "twoDigitDataLength":Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser$DataLength;
    :cond_b
    invoke-static {}, Lcom/google/zxing/NotFoundException;->getNotFoundInstance()Lcom/google/zxing/NotFoundException;

    move-result-object v0

    throw v0
.end method

.method private static processFixedAI(IILjava/lang/String;)Ljava/lang/String;
    .locals 6
    .param p0, "aiSize"    # I
    .param p1, "fieldSize"    # I
    .param p2, "rawInformation"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/google/zxing/NotFoundException;
        }
    .end annotation

    .line 259
    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v0

    if-lt v0, p0, :cond_2

    .line 263
    const/4 v0, 0x0

    invoke-virtual {p2, v0, p0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    .line 265
    .local v0, "ai":Ljava/lang/String;
    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v1

    add-int v2, p0, p1

    if-lt v1, v2, :cond_1

    .line 269
    add-int v1, p0, p1

    invoke-virtual {p2, p0, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    .line 270
    .local v1, "field":Ljava/lang/String;
    add-int v2, p0, p1

    invoke-virtual {p2, v2}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v2

    .line 271
    .local v2, "remaining":Ljava/lang/String;
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const/16 v4, 0x28

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const/16 v4, 0x29

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 272
    .local v3, "result":Ljava/lang/String;
    invoke-static {v2}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->parseFieldsInGeneralPurpose(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    .line 273
    .local v4, "parsedAI":Ljava/lang/String;
    if-nez v4, :cond_0

    move-object v5, v3

    goto :goto_0

    :cond_0
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    :goto_0
    return-object v5

    .line 266
    .end local v1    # "field":Ljava/lang/String;
    .end local v2    # "remaining":Ljava/lang/String;
    .end local v3    # "result":Ljava/lang/String;
    .end local v4    # "parsedAI":Ljava/lang/String;
    :cond_1
    invoke-static {}, Lcom/google/zxing/NotFoundException;->getNotFoundInstance()Lcom/google/zxing/NotFoundException;

    move-result-object v1

    throw v1

    .line 260
    .end local v0    # "ai":Ljava/lang/String;
    :cond_2
    invoke-static {}, Lcom/google/zxing/NotFoundException;->getNotFoundInstance()Lcom/google/zxing/NotFoundException;

    move-result-object v0

    throw v0
.end method

.method private static processVariableAI(IILjava/lang/String;)Ljava/lang/String;
    .locals 7
    .param p0, "aiSize"    # I
    .param p1, "variableFieldSize"    # I
    .param p2, "rawInformation"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/google/zxing/NotFoundException;
        }
    .end annotation

    .line 278
    const/4 v0, 0x0

    invoke-virtual {p2, v0, p0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    .line 279
    .local v0, "ai":Ljava/lang/String;
    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v1

    add-int v2, p0, p1

    invoke-static {v1, v2}, Ljava/lang/Math;->min(II)I

    move-result v1

    .line 280
    .local v1, "maxSize":I
    invoke-virtual {p2, p0, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v2

    .line 281
    .local v2, "field":Ljava/lang/String;
    invoke-virtual {p2, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v3

    .line 282
    .local v3, "remaining":Ljava/lang/String;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const/16 v5, 0x28

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const/16 v5, 0x29

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    .line 283
    .local v4, "result":Ljava/lang/String;
    invoke-static {v3}, Lcom/google/zxing/oned/rss/expanded/decoders/FieldParser;->parseFieldsInGeneralPurpose(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .line 284
    .local v5, "parsedAI":Ljava/lang/String;
    if-nez v5, :cond_0

    move-object v6, v4

    goto :goto_0

    :cond_0
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    :goto_0
    return-object v6
.end method
