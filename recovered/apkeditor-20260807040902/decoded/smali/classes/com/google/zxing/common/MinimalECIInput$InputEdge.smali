.class final Lcom/google/zxing/common/MinimalECIInput$InputEdge;
.super Ljava/lang/Object;
.source "MinimalECIInput.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/google/zxing/common/MinimalECIInput;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "InputEdge"
.end annotation


# instance fields
.field private final c:C

.field private final cachedTotalSize:I

.field private final encoderIndex:I

.field private final previous:Lcom/google/zxing/common/MinimalECIInput$InputEdge;


# direct methods
.method private constructor <init>(CLcom/google/zxing/common/ECIEncoderSet;ILcom/google/zxing/common/MinimalECIInput$InputEdge;I)V
    .locals 3
    .param p1, "c"    # C
    .param p2, "encoderSet"    # Lcom/google/zxing/common/ECIEncoderSet;
    .param p3, "encoderIndex"    # I
    .param p4, "previous"    # Lcom/google/zxing/common/MinimalECIInput$InputEdge;
    .param p5, "fnc1"    # I

    .line 325
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 326
    const/16 v0, 0x3e8

    if-ne p1, p5, :cond_0

    const/16 v1, 0x3e8

    goto :goto_0

    :cond_0
    move v1, p1

    :goto_0
    iput-char v1, p0, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->c:C

    .line 327
    iput p3, p0, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->encoderIndex:I

    .line 328
    iput-object p4, p0, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->previous:Lcom/google/zxing/common/MinimalECIInput$InputEdge;

    .line 330
    if-ne v1, v0, :cond_1

    const/4 v0, 0x1

    goto :goto_1

    :cond_1
    invoke-virtual {p2, p1, p3}, Lcom/google/zxing/common/ECIEncoderSet;->encode(CI)[B

    move-result-object v0

    array-length v0, v0

    .line 331
    .local v0, "size":I
    :goto_1
    if-nez p4, :cond_2

    const/4 v1, 0x0

    goto :goto_2

    :cond_2
    iget v1, p4, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->encoderIndex:I

    .line 332
    .local v1, "previousEncoderIndex":I
    :goto_2
    if-eq v1, p3, :cond_3

    .line 333
    add-int/lit8 v0, v0, 0x3

    .line 335
    :cond_3
    if-eqz p4, :cond_4

    .line 336
    iget v2, p4, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->cachedTotalSize:I

    add-int/2addr v0, v2

    .line 338
    :cond_4
    iput v0, p0, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->cachedTotalSize:I

    .line 339
    return-void
.end method

.method synthetic constructor <init>(CLcom/google/zxing/common/ECIEncoderSet;ILcom/google/zxing/common/MinimalECIInput$InputEdge;ILcom/google/zxing/common/MinimalECIInput$1;)V
    .locals 0
    .param p1, "x0"    # C
    .param p2, "x1"    # Lcom/google/zxing/common/ECIEncoderSet;
    .param p3, "x2"    # I
    .param p4, "x3"    # Lcom/google/zxing/common/MinimalECIInput$InputEdge;
    .param p5, "x4"    # I
    .param p6, "x5"    # Lcom/google/zxing/common/MinimalECIInput$1;

    .line 319
    invoke-direct/range {p0 .. p5}, Lcom/google/zxing/common/MinimalECIInput$InputEdge;-><init>(CLcom/google/zxing/common/ECIEncoderSet;ILcom/google/zxing/common/MinimalECIInput$InputEdge;I)V

    return-void
.end method

.method static synthetic access$000(Lcom/google/zxing/common/MinimalECIInput$InputEdge;)I
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/common/MinimalECIInput$InputEdge;

    .line 319
    iget v0, p0, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->encoderIndex:I

    return v0
.end method

.method static synthetic access$100(Lcom/google/zxing/common/MinimalECIInput$InputEdge;)I
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/common/MinimalECIInput$InputEdge;

    .line 319
    iget v0, p0, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->cachedTotalSize:I

    return v0
.end method

.method static synthetic access$300(Lcom/google/zxing/common/MinimalECIInput$InputEdge;)C
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/common/MinimalECIInput$InputEdge;

    .line 319
    iget-char v0, p0, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->c:C

    return v0
.end method

.method static synthetic access$400(Lcom/google/zxing/common/MinimalECIInput$InputEdge;)Lcom/google/zxing/common/MinimalECIInput$InputEdge;
    .locals 1
    .param p0, "x0"    # Lcom/google/zxing/common/MinimalECIInput$InputEdge;

    .line 319
    iget-object v0, p0, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->previous:Lcom/google/zxing/common/MinimalECIInput$InputEdge;

    return-object v0
.end method


# virtual methods
.method isFNC1()Z
    .locals 2

    .line 342
    iget-char v0, p0, Lcom/google/zxing/common/MinimalECIInput$InputEdge;->c:C

    const/16 v1, 0x3e8

    if-ne v0, v1, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method
