.class final Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;
.super Ljava/lang/Object;
.source "Code128Writer.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/google/zxing/oned/Code128Writer;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "MinimalEncoder"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;,
        Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;
    }
.end annotation


# static fields
.field static final synthetic $assertionsDisabled:Z = false

.field static final A:Ljava/lang/String; = " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u0008\t\n\u000b\u000c\r\u000e\u000f\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001a\u001b\u001c\u001d\u001e\u001f\u00ff"

.field static final B:Ljava/lang/String; = " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\u007f\u00ff"

.field private static final CODE_SHIFT:I = 0x62


# instance fields
.field private memoizedCost:[[I

.field private minPath:[[Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .line 365
    const-class v0, Lcom/google/zxing/oned/Code128Writer;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .line 365
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method synthetic constructor <init>(Lcom/google/zxing/oned/Code128Writer$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/google/zxing/oned/Code128Writer$1;

    .line 365
    invoke-direct {p0}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;-><init>()V

    return-void
.end method

.method static synthetic access$100(Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;Ljava/lang/String;)[Z
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;
    .param p1, "x1"    # Ljava/lang/String;

    .line 365
    invoke-direct {p0, p1}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->encode(Ljava/lang/String;)[Z

    move-result-object v0

    return-object v0
.end method

.method private static addPattern(Ljava/util/Collection;I[I[II)V
    .locals 3
    .param p1, "patternIndex"    # I
    .param p2, "checkSum"    # [I
    .param p3, "checkWeight"    # [I
    .param p4, "position"    # I
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Collection<",
            "[I>;I[I[II)V"
        }
    .end annotation

    .line 463
    .local p0, "patterns":Ljava/util/Collection;, "Ljava/util/Collection<[I>;"
    sget-object v0, Lcom/google/zxing/oned/Code128Reader;->CODE_PATTERNS:[[I

    aget-object v0, v0, p1

    invoke-interface {p0, v0}, Ljava/util/Collection;->add(Ljava/lang/Object;)Z

    .line 464
    const/4 v0, 0x0

    if-eqz p4, :cond_0

    .line 465
    aget v1, p3, v0

    add-int/lit8 v1, v1, 0x1

    aput v1, p3, v0

    .line 467
    :cond_0
    aget v1, p2, v0

    aget v2, p3, v0

    mul-int v2, v2, p1

    add-int/2addr v1, v2

    aput v1, p2, v0

    .line 468
    return-void
.end method

.method private canEncode(Ljava/lang/CharSequence;Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;I)Z
    .locals 8
    .param p1, "contents"    # Ljava/lang/CharSequence;
    .param p2, "charset"    # Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;
    .param p3, "position"    # I

    .line 475
    invoke-interface {p1, p3}, Ljava/lang/CharSequence;->charAt(I)C

    move-result v0

    .line 476
    .local v0, "c":C
    sget-object v1, Lcom/google/zxing/oned/Code128Writer$1;->$SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Charset:[I

    invoke-virtual {p2}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->ordinal()I

    move-result v2

    aget v1, v1, v2

    const/16 v2, 0xf4

    const/16 v3, 0xf3

    const/16 v4, 0xf2

    const/16 v5, 0xf1

    const/4 v6, 0x0

    const/4 v7, 0x1

    packed-switch v1, :pswitch_data_0

    .line 491
    return v6

    .line 487
    :pswitch_0
    if-eq v0, v5, :cond_1

    add-int/lit8 v1, p3, 0x1

    .line 488
    invoke-interface {p1}, Ljava/lang/CharSequence;->length()I

    move-result v2

    if-ge v1, v2, :cond_0

    .line 489
    invoke-static {v0}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->isDigit(C)Z

    move-result v1

    if-eqz v1, :cond_0

    add-int/lit8 v1, p3, 0x1

    .line 490
    invoke-interface {p1, v1}, Ljava/lang/CharSequence;->charAt(I)C

    move-result v1

    invoke-static {v1}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->isDigit(C)Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_0

    :cond_0
    goto :goto_1

    :cond_1
    :goto_0
    const/4 v6, 0x1

    .line 487
    :goto_1
    return v6

    .line 482
    :pswitch_1
    if-eq v0, v5, :cond_2

    if-eq v0, v4, :cond_2

    if-eq v0, v3, :cond_2

    if-eq v0, v2, :cond_2

    .line 486
    const-string v1, " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\u007f\u00ff"

    invoke-virtual {v1, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v1

    if-ltz v1, :cond_3

    :cond_2
    const/4 v6, 0x1

    .line 482
    :cond_3
    return v6

    .line 477
    :pswitch_2
    if-eq v0, v5, :cond_4

    if-eq v0, v4, :cond_4

    if-eq v0, v3, :cond_4

    if-eq v0, v2, :cond_4

    .line 481
    const-string v1, " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u0008\t\n\u000b\u000c\r\u000e\u000f\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001a\u001b\u001c\u001d\u001e\u001f\u00ff"

    invoke-virtual {v1, v0}, Ljava/lang/String;->indexOf(I)I

    move-result v1

    if-ltz v1, :cond_5

    :cond_4
    const/4 v6, 0x1

    .line 477
    :cond_5
    return v6

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method private encode(Ljava/lang/CharSequence;Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;I)I
    .locals 12
    .param p1, "contents"    # Ljava/lang/CharSequence;
    .param p2, "charset"    # Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;
    .param p3, "position"    # I

    .line 499
    invoke-interface {p1}, Ljava/lang/CharSequence;->length()I

    move-result v0

    if-ge p3, v0, :cond_d

    .line 500
    iget-object v0, p0, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->memoizedCost:[[I

    invoke-virtual {p2}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->ordinal()I

    move-result v1

    aget-object v0, v0, v1

    aget v0, v0, p3

    .line 501
    .local v0, "mCost":I
    if-lez v0, :cond_0

    .line 502
    return v0

    .line 505
    :cond_0
    const v1, 0x7fffffff

    .line 506
    .local v1, "minCost":I
    sget-object v2, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->NONE:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    .line 507
    .local v2, "minLatch":Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;
    add-int/lit8 v3, p3, 0x1

    invoke-interface {p1}, Ljava/lang/CharSequence;->length()I

    move-result v4

    const/4 v5, 0x0

    const/4 v6, 0x1

    if-lt v3, v4, :cond_1

    const/4 v3, 0x1

    goto :goto_0

    :cond_1
    const/4 v3, 0x0

    .line 509
    .local v3, "atEnd":Z
    :goto_0
    const/4 v4, 0x2

    new-array v7, v4, [Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    sget-object v8, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->A:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    aput-object v8, v7, v5

    sget-object v5, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->B:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    aput-object v5, v7, v6

    move-object v5, v7

    .line 510
    .local v5, "sets":[Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;
    const/4 v7, 0x0

    .local v7, "i":I
    :goto_1
    if-gt v7, v6, :cond_7

    .line 511
    aget-object v8, v5, v7

    invoke-direct {p0, p1, v8, p3}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->canEncode(Ljava/lang/CharSequence;Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;I)Z

    move-result v8

    if-eqz v8, :cond_6

    .line 512
    const/4 v8, 0x1

    .line 513
    .local v8, "cost":I
    sget-object v9, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->NONE:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    .line 514
    .local v9, "latch":Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;
    aget-object v10, v5, v7

    if-eq p2, v10, :cond_2

    .line 515
    add-int/lit8 v8, v8, 0x1

    .line 516
    aget-object v10, v5, v7

    invoke-virtual {v10}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-static {v10}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->valueOf(Ljava/lang/String;)Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    move-result-object v9

    .line 518
    :cond_2
    if-nez v3, :cond_3

    .line 519
    aget-object v10, v5, v7

    add-int/lit8 v11, p3, 0x1

    invoke-direct {p0, p1, v10, v11}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->encode(Ljava/lang/CharSequence;Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;I)I

    move-result v10

    add-int/2addr v8, v10

    .line 521
    :cond_3
    if-ge v8, v1, :cond_4

    .line 522
    move v1, v8

    .line 523
    move-object v2, v9

    .line 525
    :cond_4
    const/4 v8, 0x1

    .line 526
    add-int/lit8 v10, v7, 0x1

    rem-int/2addr v10, v4

    aget-object v10, v5, v10

    if-ne p2, v10, :cond_6

    .line 527
    add-int/lit8 v8, v8, 0x1

    .line 528
    sget-object v9, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->SHIFT:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    .line 529
    if-nez v3, :cond_5

    .line 530
    add-int/lit8 v10, p3, 0x1

    invoke-direct {p0, p1, p2, v10}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->encode(Ljava/lang/CharSequence;Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;I)I

    move-result v10

    add-int/2addr v8, v10

    .line 532
    :cond_5
    if-ge v8, v1, :cond_6

    .line 533
    move v1, v8

    .line 534
    move-object v2, v9

    .line 510
    .end local v8    # "cost":I
    .end local v9    # "latch":Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;
    :cond_6
    add-int/lit8 v7, v7, 0x1

    goto :goto_1

    .line 539
    .end local v7    # "i":I
    :cond_7
    sget-object v7, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->C:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    invoke-direct {p0, p1, v7, p3}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->canEncode(Ljava/lang/CharSequence;Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;I)Z

    move-result v7

    if-eqz v7, :cond_b

    .line 540
    const/4 v7, 0x1

    .line 541
    .local v7, "cost":I
    sget-object v8, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->NONE:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    .line 542
    .local v8, "latch":Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;
    sget-object v9, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->C:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    if-eq p2, v9, :cond_8

    .line 543
    add-int/lit8 v7, v7, 0x1

    .line 544
    sget-object v8, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->C:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    .line 546
    :cond_8
    invoke-interface {p1, p3}, Ljava/lang/CharSequence;->charAt(I)C

    move-result v9

    const/16 v10, 0xf1

    if-ne v9, v10, :cond_9

    goto :goto_2

    :cond_9
    const/4 v6, 0x2

    :goto_2
    move v4, v6

    .line 547
    .local v4, "advance":I
    add-int v6, p3, v4

    invoke-interface {p1}, Ljava/lang/CharSequence;->length()I

    move-result v9

    if-ge v6, v9, :cond_a

    .line 548
    sget-object v6, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->C:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    add-int v9, p3, v4

    invoke-direct {p0, p1, v6, v9}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->encode(Ljava/lang/CharSequence;Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;I)I

    move-result v6

    add-int/2addr v7, v6

    .line 550
    :cond_a
    if-ge v7, v1, :cond_b

    .line 551
    move v1, v7

    .line 552
    move-object v2, v8

    .line 555
    .end local v4    # "advance":I
    .end local v7    # "cost":I
    .end local v8    # "latch":Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;
    :cond_b
    const v4, 0x7fffffff

    if-eq v1, v4, :cond_c

    .line 558
    iget-object v4, p0, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->memoizedCost:[[I

    invoke-virtual {p2}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->ordinal()I

    move-result v6

    aget-object v4, v4, v6

    aput v1, v4, p3

    .line 559
    iget-object v4, p0, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->minPath:[[Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    invoke-virtual {p2}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->ordinal()I

    move-result v6

    aget-object v4, v4, v6

    aput-object v2, v4, p3

    .line 560
    return v1

    .line 556
    :cond_c
    new-instance v4, Ljava/lang/IllegalArgumentException;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "Bad character in input: ASCII value="

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-interface {p1, p3}, Ljava/lang/CharSequence;->charAt(I)C

    move-result v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-direct {v4, v6}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v4

    .line 499
    .end local v0    # "mCost":I
    .end local v1    # "minCost":I
    .end local v2    # "minLatch":Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;
    .end local v3    # "atEnd":Z
    .end local v5    # "sets":[Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;
    :cond_d
    new-instance v0, Ljava/lang/AssertionError;

    invoke-direct {v0}, Ljava/lang/AssertionError;-><init>()V

    throw v0
.end method

.method private encode(Ljava/lang/String;)[Z
    .locals 11
    .param p1, "contents"    # Ljava/lang/String;

    .line 383
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v0

    const/4 v1, 0x4

    filled-new-array {v1, v0}, [I

    move-result-object v0

    sget-object v2, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    invoke-static {v2, v0}, Ljava/lang/reflect/Array;->newInstance(Ljava/lang/Class;[I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [[I

    iput-object v0, p0, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->memoizedCost:[[I

    .line 384
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v0

    filled-new-array {v1, v0}, [I

    move-result-object v0

    const-class v1, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    invoke-static {v1, v0}, Ljava/lang/reflect/Array;->newInstance(Ljava/lang/Class;[I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [[Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    iput-object v0, p0, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->minPath:[[Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    .line 386
    sget-object v0, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->NONE:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    const/4 v1, 0x0

    invoke-direct {p0, p1, v0, v1}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->encode(Ljava/lang/CharSequence;Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;I)I

    .line 388
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 389
    .local v0, "patterns":Ljava/util/Collection;, "Ljava/util/Collection<[I>;"
    filled-new-array {v1}, [I

    move-result-object v2

    .line 390
    .local v2, "checkSum":[I
    const/4 v3, 0x1

    filled-new-array {v3}, [I

    move-result-object v4

    .line 391
    .local v4, "checkWeight":[I
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v5

    .line 392
    .local v5, "length":I
    sget-object v6, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->NONE:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    .line 393
    .local v6, "charset":Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;
    const/4 v7, 0x0

    .local v7, "i":I
    :goto_0
    if-ge v7, v5, :cond_d

    .line 394
    iget-object v8, p0, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->minPath:[[Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    invoke-virtual {v6}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->ordinal()I

    move-result v9

    aget-object v8, v8, v9

    aget-object v8, v8, v7

    .line 395
    .local v8, "latch":Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;
    sget-object v9, Lcom/google/zxing/oned/Code128Writer$1;->$SwitchMap$com$google$zxing$oned$Code128Writer$MinimalEncoder$Latch:[I

    invoke-virtual {v8}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->ordinal()I

    move-result v10

    aget v9, v9, v10

    packed-switch v9, :pswitch_data_0

    goto :goto_4

    .line 409
    :pswitch_0
    const/16 v9, 0x62

    invoke-static {v0, v9, v2, v4, v7}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->addPattern(Ljava/util/Collection;I[I[II)V

    goto :goto_4

    .line 405
    :pswitch_1
    sget-object v6, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->C:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    .line 406
    if-nez v7, :cond_0

    const/16 v9, 0x69

    goto :goto_1

    :cond_0
    const/16 v9, 0x63

    :goto_1
    invoke-static {v0, v9, v2, v4, v7}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->addPattern(Ljava/util/Collection;I[I[II)V

    .line 407
    goto :goto_4

    .line 401
    :pswitch_2
    sget-object v6, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->B:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    .line 402
    if-nez v7, :cond_1

    const/16 v9, 0x68

    goto :goto_2

    :cond_1
    const/16 v9, 0x64

    :goto_2
    invoke-static {v0, v9, v2, v4, v7}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->addPattern(Ljava/util/Collection;I[I[II)V

    .line 403
    goto :goto_4

    .line 397
    :pswitch_3
    sget-object v6, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->A:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    .line 398
    if-nez v7, :cond_2

    const/16 v9, 0x67

    goto :goto_3

    :cond_2
    const/16 v9, 0x65

    :goto_3
    invoke-static {v0, v9, v2, v4, v7}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->addPattern(Ljava/util/Collection;I[I[II)V

    .line 399
    nop

    .line 412
    :goto_4
    sget-object v9, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->C:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    if-ne v6, v9, :cond_5

    .line 413
    invoke-virtual {p1, v7}, Ljava/lang/String;->charAt(I)C

    move-result v9

    const/16 v10, 0xf1

    if-ne v9, v10, :cond_3

    .line 414
    const/16 v9, 0x66

    invoke-static {v0, v9, v2, v4, v7}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->addPattern(Ljava/util/Collection;I[I[II)V

    goto :goto_6

    .line 416
    :cond_3
    add-int/lit8 v9, v7, 0x2

    invoke-virtual {p1, v7, v9}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v9

    invoke-static {v9}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v9

    invoke-static {v0, v9, v2, v4, v7}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->addPattern(Ljava/util/Collection;I[I[II)V

    .line 417
    add-int/lit8 v9, v7, 0x1

    if-ge v9, v5, :cond_4

    .line 418
    add-int/lit8 v9, v7, 0x1

    if-ge v9, v5, :cond_c

    .line 419
    add-int/lit8 v7, v7, 0x1

    goto :goto_6

    .line 417
    :cond_4
    new-instance v1, Ljava/lang/AssertionError;

    invoke-direct {v1}, Ljava/lang/AssertionError;-><init>()V

    throw v1

    .line 424
    :cond_5
    invoke-virtual {p1, v7}, Ljava/lang/String;->charAt(I)C

    move-result v9

    packed-switch v9, :pswitch_data_1

    .line 443
    invoke-virtual {p1, v7}, Ljava/lang/String;->charAt(I)C

    move-result v9

    add-int/lit8 v9, v9, -0x20

    .local v9, "patternIndex":I
    goto :goto_5

    .line 435
    .end local v9    # "patternIndex":I
    :pswitch_4
    sget-object v9, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->A:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    if-ne v6, v9, :cond_6

    sget-object v9, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->SHIFT:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    if-ne v8, v9, :cond_7

    :cond_6
    sget-object v9, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->B:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    if-ne v6, v9, :cond_8

    sget-object v9, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->SHIFT:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    if-ne v8, v9, :cond_8

    .line 437
    :cond_7
    const/16 v9, 0x65

    .restart local v9    # "patternIndex":I
    goto :goto_5

    .line 439
    .end local v9    # "patternIndex":I
    :cond_8
    const/16 v9, 0x64

    .line 441
    .restart local v9    # "patternIndex":I
    goto :goto_5

    .line 432
    .end local v9    # "patternIndex":I
    :pswitch_5
    const/16 v9, 0x60

    .line 433
    .restart local v9    # "patternIndex":I
    goto :goto_5

    .line 429
    .end local v9    # "patternIndex":I
    :pswitch_6
    const/16 v9, 0x61

    .line 430
    .restart local v9    # "patternIndex":I
    goto :goto_5

    .line 426
    .end local v9    # "patternIndex":I
    :pswitch_7
    const/16 v9, 0x66

    .line 427
    .restart local v9    # "patternIndex":I
    nop

    .line 445
    :goto_5
    sget-object v10, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->A:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    if-ne v6, v10, :cond_9

    sget-object v10, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->SHIFT:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    if-ne v8, v10, :cond_a

    :cond_9
    sget-object v10, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;->B:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Charset;

    if-ne v6, v10, :cond_b

    sget-object v10, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;->SHIFT:Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    if-ne v8, v10, :cond_b

    :cond_a
    if-gez v9, :cond_b

    .line 448
    add-int/lit8 v9, v9, 0x60

    .line 450
    :cond_b
    invoke-static {v0, v9, v2, v4, v7}, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->addPattern(Ljava/util/Collection;I[I[II)V

    .line 393
    .end local v8    # "latch":Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;
    .end local v9    # "patternIndex":I
    :cond_c
    :goto_6
    add-int/2addr v7, v3

    goto/16 :goto_0

    .line 453
    .end local v7    # "i":I
    :cond_d
    const/4 v3, 0x0

    move-object v7, v3

    check-cast v7, [[I

    iput-object v3, p0, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->memoizedCost:[[I

    .line 454
    move-object v7, v3

    check-cast v7, [[Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    iput-object v3, p0, Lcom/google/zxing/oned/Code128Writer$MinimalEncoder;->minPath:[[Lcom/google/zxing/oned/Code128Writer$MinimalEncoder$Latch;

    .line 455
    aget v1, v2, v1

    invoke-static {v0, v1}, Lcom/google/zxing/oned/Code128Writer;->produceResult(Ljava/util/Collection;I)[Z

    move-result-object v1

    return-object v1

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch

    :pswitch_data_1
    .packed-switch 0xf1
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
    .end packed-switch
.end method

.method private static isDigit(C)Z
    .locals 1
    .param p0, "c"    # C

    .line 471
    const/16 v0, 0x30

    if-lt p0, v0, :cond_0

    const/16 v0, 0x39

    if-gt p0, v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method
