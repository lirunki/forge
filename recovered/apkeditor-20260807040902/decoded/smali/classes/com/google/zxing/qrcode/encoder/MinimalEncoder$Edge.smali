.class final Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;
.super Ljava/lang/Object;
.source "MinimalEncoder.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/google/zxing/qrcode/encoder/MinimalEncoder;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x12
    name = "Edge"
.end annotation


# instance fields
.field private final cachedTotalSize:I

.field private final characterLength:I

.field private final charsetEncoderIndex:I

.field private final fromPosition:I

.field private final mode:Lcom/google/zxing/qrcode/decoder/Mode;

.field private final previous:Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;

.field final synthetic this$0:Lcom/google/zxing/qrcode/encoder/MinimalEncoder;


# direct methods
.method private constructor <init>(Lcom/google/zxing/qrcode/encoder/MinimalEncoder;Lcom/google/zxing/qrcode/decoder/Mode;IIILcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;Lcom/google/zxing/qrcode/decoder/Version;)V
    .locals 6
    .param p2, "mode"    # Lcom/google/zxing/qrcode/decoder/Mode;
    .param p3, "fromPosition"    # I
    .param p4, "charsetEncoderIndex"    # I
    .param p5, "characterLength"    # I
    .param p6, "previous"    # Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;
    .param p7, "version"    # Lcom/google/zxing/qrcode/decoder/Version;

    .line 414
    iput-object p1, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->this$0:Lcom/google/zxing/qrcode/encoder/MinimalEncoder;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 415
    iput-object p2, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->mode:Lcom/google/zxing/qrcode/decoder/Mode;

    .line 416
    iput p3, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->fromPosition:I

    .line 417
    sget-object v0, Lcom/google/zxing/qrcode/decoder/Mode;->BYTE:Lcom/google/zxing/qrcode/decoder/Mode;

    if-eq p2, v0, :cond_1

    if-nez p6, :cond_0

    goto :goto_0

    :cond_0
    iget v0, p6, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->charsetEncoderIndex:I

    goto :goto_1

    :cond_1
    :goto_0
    move v0, p4

    :goto_1
    iput v0, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->charsetEncoderIndex:I

    .line 419
    iput p5, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->characterLength:I

    .line 420
    iput-object p6, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->previous:Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;

    .line 422
    const/4 v1, 0x0

    if-eqz p6, :cond_2

    iget v2, p6, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->cachedTotalSize:I

    goto :goto_2

    :cond_2
    const/4 v2, 0x0

    .line 424
    .local v2, "size":I
    :goto_2
    sget-object v3, Lcom/google/zxing/qrcode/decoder/Mode;->BYTE:Lcom/google/zxing/qrcode/decoder/Mode;

    const/4 v4, 0x1

    if-ne p2, v3, :cond_3

    if-nez p6, :cond_3

    if-nez v0, :cond_4

    :cond_3
    if-eqz p6, :cond_5

    iget v3, p6, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->charsetEncoderIndex:I

    if-eq v0, v3, :cond_5

    :cond_4
    const/4 v1, 0x1

    :cond_5
    move v0, v1

    .line 428
    .local v0, "needECI":Z
    const/4 v1, 0x4

    if-eqz p6, :cond_6

    iget-object v3, p6, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->mode:Lcom/google/zxing/qrcode/decoder/Mode;

    if-ne p2, v3, :cond_6

    if-eqz v0, :cond_7

    .line 429
    :cond_6
    invoke-virtual {p2, p7}, Lcom/google/zxing/qrcode/decoder/Mode;->getCharacterCountBits(Lcom/google/zxing/qrcode/decoder/Version;)I

    move-result v3

    add-int/2addr v3, v1

    add-int/2addr v2, v3

    .line 431
    :cond_7
    sget-object v3, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$1;->$SwitchMap$com$google$zxing$qrcode$decoder$Mode:[I

    invoke-virtual {p2}, Lcom/google/zxing/qrcode/decoder/Mode;->ordinal()I

    move-result v5

    aget v3, v3, v5

    packed-switch v3, :pswitch_data_0

    goto :goto_5

    .line 442
    :pswitch_0
    invoke-static {p1}, Lcom/google/zxing/qrcode/encoder/MinimalEncoder;->access$600(Lcom/google/zxing/qrcode/encoder/MinimalEncoder;)Lcom/google/zxing/common/ECIEncoderSet;

    move-result-object v1

    invoke-static {p1}, Lcom/google/zxing/qrcode/encoder/MinimalEncoder;->access$500(Lcom/google/zxing/qrcode/encoder/MinimalEncoder;)Ljava/lang/String;

    move-result-object p1

    add-int v3, p3, p5

    invoke-virtual {p1, p3, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v1, p1, p4}, Lcom/google/zxing/common/ECIEncoderSet;->encode(Ljava/lang/String;I)[B

    move-result-object p1

    array-length p1, p1

    mul-int/lit8 p1, p1, 0x8

    add-int/2addr v2, p1

    .line 444
    if-eqz v0, :cond_b

    .line 445
    add-int/lit8 v2, v2, 0xc

    goto :goto_5

    .line 439
    :pswitch_1
    if-ne p5, v4, :cond_8

    goto :goto_3

    :cond_8
    const/4 p1, 0x2

    if-ne p5, p1, :cond_9

    const/4 v1, 0x7

    goto :goto_3

    :cond_9
    const/16 v1, 0xa

    :goto_3
    add-int/2addr v2, v1

    .line 440
    goto :goto_5

    .line 436
    :pswitch_2
    if-ne p5, v4, :cond_a

    const/4 p1, 0x6

    goto :goto_4

    :cond_a
    const/16 p1, 0xb

    :goto_4
    add-int/2addr v2, p1

    .line 437
    goto :goto_5

    .line 433
    :pswitch_3
    add-int/lit8 v2, v2, 0xd

    .line 434
    nop

    .line 449
    :cond_b
    :goto_5
    iput v2, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->cachedTotalSize:I

    .line 450
    return-void

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method synthetic constructor <init>(Lcom/google/zxing/qrcode/encoder/MinimalEncoder;Lcom/google/zxing/qrcode/decoder/Mode;IIILcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;Lcom/google/zxing/qrcode/decoder/Version;Lcom/google/zxing/qrcode/encoder/MinimalEncoder$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/google/zxing/qrcode/encoder/MinimalEncoder;
    .param p2, "x1"    # Lcom/google/zxing/qrcode/decoder/Mode;
    .param p3, "x2"    # I
    .param p4, "x3"    # I
    .param p5, "x4"    # I
    .param p6, "x5"    # Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;
    .param p7, "x6"    # Lcom/google/zxing/qrcode/decoder/Version;
    .param p8, "x7"    # Lcom/google/zxing/qrcode/encoder/MinimalEncoder$1;

    .line 405
    invoke-direct/range {p0 .. p7}, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;-><init>(Lcom/google/zxing/qrcode/encoder/MinimalEncoder;Lcom/google/zxing/qrcode/decoder/Mode;IIILcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;Lcom/google/zxing/qrcode/decoder/Version;)V

    return-void
.end method

.method static synthetic access$000(Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;)I
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;

    .line 405
    iget v0, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->characterLength:I

    return v0
.end method

.method static synthetic access$100(Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;)I
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;

    .line 405
    iget v0, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->charsetEncoderIndex:I

    return v0
.end method

.method static synthetic access$200(Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;)Lcom/google/zxing/qrcode/decoder/Mode;
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;

    .line 405
    iget-object v0, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->mode:Lcom/google/zxing/qrcode/decoder/Mode;

    return-object v0
.end method

.method static synthetic access$300(Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;)I
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;

    .line 405
    iget v0, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->cachedTotalSize:I

    return v0
.end method

.method static synthetic access$700(Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;)Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;

    .line 405
    iget-object v0, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->previous:Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;

    return-object v0
.end method

.method static synthetic access$800(Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;)I
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;

    .line 405
    iget v0, p0, Lcom/google/zxing/qrcode/encoder/MinimalEncoder$Edge;->fromPosition:I

    return v0
.end method
