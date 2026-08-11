.class public Lcom/forge/live/QrScanActivity;
.super Landroid/app/Activity;
.source "QrScanActivity.java"

# interfaces
.implements Landroid/view/TextureView$SurfaceTextureListener;
.implements Landroid/hardware/Camera$PreviewCallback;


# static fields
.field public static final EXTRA_FORMAT:Ljava/lang/String; = "format"

.field public static final EXTRA_QR_ONLY:Ljava/lang/String; = "qrOnly"

.field public static final EXTRA_RAW_B64:Ljava/lang/String; = "rawB64"

.field public static final EXTRA_TEXT:Ljava/lang/String; = "text"

.field public static final EXTRA_TITLE:Ljava/lang/String; = "title"


# instance fields
.field private camera:Landroid/hardware/Camera;

.field private final handled:Ljava/util/concurrent/atomic/AtomicBoolean;

.field private previewH:I

.field private previewW:I

.field private qrOnly:Z

.field private reader:Lcom/google/zxing/MultiFormatReader;

.field private textureView:Landroid/view/TextureView;


# direct methods
.method public static synthetic $r8$lambda$bBhysXFAzCSbUza1CY13DbSn4GA(Lcom/forge/live/QrScanActivity;Landroid/view/View;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/QrScanActivity;->lambda$onCreate$0(Landroid/view/View;)V

    return-void
.end method

.method public constructor <init>()V
    .locals 2

    .line 36
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    .line 46
    new-instance v0, Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Ljava/util/concurrent/atomic/AtomicBoolean;-><init>(Z)V

    iput-object v0, p0, Lcom/forge/live/QrScanActivity;->handled:Ljava/util/concurrent/atomic/AtomicBoolean;

    .line 47
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/forge/live/QrScanActivity;->qrOnly:Z

    return-void
.end method

.method private finishCancelled()V
    .locals 1

    .line 205
    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/forge/live/QrScanActivity;->setResult(I)V

    .line 206
    invoke-virtual {p0}, Lcom/forge/live/QrScanActivity;->finish()V

    .line 207
    return-void
.end method

.method private synthetic lambda$onCreate$0(Landroid/view/View;)V
    .locals 1
    .param p1, "v"    # Landroid/view/View;

    .line 94
    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/forge/live/QrScanActivity;->setResult(I)V

    .line 95
    invoke-virtual {p0}, Lcom/forge/live/QrScanActivity;->finish()V

    .line 96
    return-void
.end method

.method private openCamera(Landroid/graphics/SurfaceTexture;)V
    .locals 6
    .param p1, "surface"    # Landroid/graphics/SurfaceTexture;

    .line 125
    const-string v0, "auto"

    const-string v1, "continuous-picture"

    :try_start_0
    invoke-static {}, Landroid/hardware/Camera;->open()Landroid/hardware/Camera;

    move-result-object v2

    iput-object v2, p0, Lcom/forge/live/QrScanActivity;->camera:Landroid/hardware/Camera;

    .line 126
    if-nez v2, :cond_0

    .line 127
    invoke-direct {p0}, Lcom/forge/live/QrScanActivity;->finishCancelled()V

    .line 128
    return-void

    .line 130
    :cond_0
    invoke-virtual {v2}, Landroid/hardware/Camera;->getParameters()Landroid/hardware/Camera$Parameters;

    move-result-object v2

    .line 131
    .local v2, "params":Landroid/hardware/Camera$Parameters;
    invoke-virtual {v2}, Landroid/hardware/Camera$Parameters;->getSupportedPreviewSizes()Ljava/util/List;

    move-result-object v3

    const/16 v4, 0x500

    const/16 v5, 0x2d0

    invoke-static {v3, v4, v5}, Lcom/forge/live/QrScanActivity;->pickPreviewSize(Ljava/util/List;II)Landroid/hardware/Camera$Size;

    move-result-object v3

    .line 132
    .local v3, "best":Landroid/hardware/Camera$Size;
    if-eqz v3, :cond_1

    .line 133
    iget v4, v3, Landroid/hardware/Camera$Size;->width:I

    iget v5, v3, Landroid/hardware/Camera$Size;->height:I

    invoke-virtual {v2, v4, v5}, Landroid/hardware/Camera$Parameters;->setPreviewSize(II)V

    .line 134
    iget v4, v3, Landroid/hardware/Camera$Size;->width:I

    iput v4, p0, Lcom/forge/live/QrScanActivity;->previewW:I

    .line 135
    iget v4, v3, Landroid/hardware/Camera$Size;->height:I

    iput v4, p0, Lcom/forge/live/QrScanActivity;->previewH:I

    goto :goto_0

    .line 137
    :cond_1
    invoke-virtual {v2}, Landroid/hardware/Camera$Parameters;->getPreviewSize()Landroid/hardware/Camera$Size;

    move-result-object v4

    .line 138
    .local v4, "s":Landroid/hardware/Camera$Size;
    iget v5, v4, Landroid/hardware/Camera$Size;->width:I

    iput v5, p0, Lcom/forge/live/QrScanActivity;->previewW:I

    .line 139
    iget v5, v4, Landroid/hardware/Camera$Size;->height:I

    iput v5, p0, Lcom/forge/live/QrScanActivity;->previewH:I

    .line 141
    .end local v4    # "s":Landroid/hardware/Camera$Size;
    :goto_0
    invoke-virtual {v2}, Landroid/hardware/Camera$Parameters;->getSupportedFocusModes()Ljava/util/List;

    move-result-object v4

    .line 142
    .local v4, "focus":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    if-eqz v4, :cond_2

    invoke-interface {v4, v1}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_2

    .line 143
    invoke-virtual {v2, v1}, Landroid/hardware/Camera$Parameters;->setFocusMode(Ljava/lang/String;)V

    goto :goto_1

    .line 144
    :cond_2
    if-eqz v4, :cond_3

    invoke-interface {v4, v0}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_3

    .line 145
    invoke-virtual {v2, v0}, Landroid/hardware/Camera$Parameters;->setFocusMode(Ljava/lang/String;)V

    .line 147
    :cond_3
    :goto_1
    invoke-virtual {v2}, Landroid/hardware/Camera$Parameters;->getSupportedPreviewFormats()Ljava/util/List;

    move-result-object v0

    const/16 v1, 0x11

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    invoke-interface {v0, v5}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_4

    .line 148
    invoke-virtual {v2, v1}, Landroid/hardware/Camera$Parameters;->setPreviewFormat(I)V

    .line 150
    :cond_4
    iget-object v0, p0, Lcom/forge/live/QrScanActivity;->camera:Landroid/hardware/Camera;

    invoke-virtual {v0, v2}, Landroid/hardware/Camera;->setParameters(Landroid/hardware/Camera$Parameters;)V

    .line 151
    iget-object v0, p0, Lcom/forge/live/QrScanActivity;->camera:Landroid/hardware/Camera;

    const/16 v1, 0x5a

    invoke-virtual {v0, v1}, Landroid/hardware/Camera;->setDisplayOrientation(I)V

    .line 152
    iget-object v0, p0, Lcom/forge/live/QrScanActivity;->camera:Landroid/hardware/Camera;

    invoke-virtual {v0, p1}, Landroid/hardware/Camera;->setPreviewTexture(Landroid/graphics/SurfaceTexture;)V

    .line 153
    iget-object v0, p0, Lcom/forge/live/QrScanActivity;->camera:Landroid/hardware/Camera;

    invoke-virtual {v0, p0}, Landroid/hardware/Camera;->setPreviewCallback(Landroid/hardware/Camera$PreviewCallback;)V

    .line 154
    iget-object v0, p0, Lcom/forge/live/QrScanActivity;->camera:Landroid/hardware/Camera;

    invoke-virtual {v0}, Landroid/hardware/Camera;->startPreview()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 158
    .end local v2    # "params":Landroid/hardware/Camera$Parameters;
    .end local v3    # "best":Landroid/hardware/Camera$Size;
    .end local v4    # "focus":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    goto :goto_2

    .line 155
    :catch_0
    move-exception v0

    .line 156
    .local v0, "e":Ljava/lang/Exception;
    invoke-direct {p0}, Lcom/forge/live/QrScanActivity;->releaseCamera()V

    .line 157
    invoke-direct {p0}, Lcom/forge/live/QrScanActivity;->finishCancelled()V

    .line 159
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_2
    return-void
.end method

.method private static pickPreviewSize(Ljava/util/List;II)Landroid/hardware/Camera$Size;
    .locals 6
    .param p1, "wantW"    # I
    .param p2, "wantH"    # I
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Landroid/hardware/Camera$Size;",
            ">;II)",
            "Landroid/hardware/Camera$Size;"
        }
    .end annotation

    .line 162
    .local p0, "sizes":Ljava/util/List;, "Ljava/util/List<Landroid/hardware/Camera$Size;>;"
    if-eqz p0, :cond_3

    invoke-interface {p0}, Ljava/util/List;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_1

    .line 163
    :cond_0
    const/4 v0, 0x0

    .line 164
    .local v0, "best":Landroid/hardware/Camera$Size;
    const v1, 0x7fffffff

    .line 165
    .local v1, "bestScore":I
    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_2

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Landroid/hardware/Camera$Size;

    .line 166
    .local v3, "s":Landroid/hardware/Camera$Size;
    iget v4, v3, Landroid/hardware/Camera$Size;->width:I

    sub-int/2addr v4, p1

    invoke-static {v4}, Ljava/lang/Math;->abs(I)I

    move-result v4

    iget v5, v3, Landroid/hardware/Camera$Size;->height:I

    sub-int/2addr v5, p2

    invoke-static {v5}, Ljava/lang/Math;->abs(I)I

    move-result v5

    add-int/2addr v4, v5

    .line 167
    .local v4, "score":I
    if-ge v4, v1, :cond_1

    .line 168
    move v1, v4

    .line 169
    move-object v0, v3

    .line 171
    .end local v3    # "s":Landroid/hardware/Camera$Size;
    .end local v4    # "score":I
    :cond_1
    goto :goto_0

    .line 172
    :cond_2
    return-object v0

    .line 162
    .end local v0    # "best":Landroid/hardware/Camera$Size;
    .end local v1    # "bestScore":I
    :cond_3
    :goto_1
    const/4 v0, 0x0

    return-object v0
.end method

.method private releaseCamera()V
    .locals 2

    .line 210
    iget-object v0, p0, Lcom/forge/live/QrScanActivity;->camera:Landroid/hardware/Camera;

    if-eqz v0, :cond_0

    .line 211
    const/4 v1, 0x0

    :try_start_0
    invoke-virtual {v0, v1}, Landroid/hardware/Camera;->setPreviewCallback(Landroid/hardware/Camera$PreviewCallback;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 212
    :goto_0
    :try_start_1
    iget-object v0, p0, Lcom/forge/live/QrScanActivity;->camera:Landroid/hardware/Camera;

    invoke-virtual {v0}, Landroid/hardware/Camera;->stopPreview()V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    :catch_1
    move-exception v0

    .line 213
    :goto_1
    :try_start_2
    iget-object v0, p0, Lcom/forge/live/QrScanActivity;->camera:Landroid/hardware/Camera;

    invoke-virtual {v0}, Landroid/hardware/Camera;->release()V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

    goto :goto_2

    :catch_2
    move-exception v0

    .line 214
    :goto_2
    iput-object v1, p0, Lcom/forge/live/QrScanActivity;->camera:Landroid/hardware/Camera;

    .line 216
    :cond_0
    return-void
.end method


# virtual methods
.method public onBackPressed()V
    .locals 1

    .line 226
    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/forge/live/QrScanActivity;->setResult(I)V

    .line 227
    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V

    .line 228
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 9
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    .line 54
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 55
    invoke-virtual {p0}, Lcom/forge/live/QrScanActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-virtual {p0}, Lcom/forge/live/QrScanActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    const-string v1, "title"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    .line 56
    .local v0, "title":Ljava/lang/String;
    :goto_0
    if-eqz v0, :cond_1

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_2

    :cond_1
    const-string v0, "Scan code"

    .line 57
    :cond_2
    invoke-virtual {p0}, Lcom/forge/live/QrScanActivity;->getIntent()Landroid/content/Intent;

    move-result-object v1

    const/4 v2, 0x0

    const/4 v3, 0x1

    if-eqz v1, :cond_4

    invoke-virtual {p0}, Lcom/forge/live/QrScanActivity;->getIntent()Landroid/content/Intent;

    move-result-object v1

    const-string v4, "qrOnly"

    invoke-virtual {v1, v4, v3}, Landroid/content/Intent;->getBooleanExtra(Ljava/lang/String;Z)Z

    move-result v1

    if-eqz v1, :cond_3

    goto :goto_1

    :cond_3
    const/4 v1, 0x0

    goto :goto_2

    :cond_4
    :goto_1
    const/4 v1, 0x1

    :goto_2
    iput-boolean v1, p0, Lcom/forge/live/QrScanActivity;->qrOnly:Z

    .line 59
    new-instance v1, Lcom/google/zxing/MultiFormatReader;

    invoke-direct {v1}, Lcom/google/zxing/MultiFormatReader;-><init>()V

    iput-object v1, p0, Lcom/forge/live/QrScanActivity;->reader:Lcom/google/zxing/MultiFormatReader;

    .line 60
    new-instance v1, Ljava/util/EnumMap;

    const-class v4, Lcom/google/zxing/DecodeHintType;

    invoke-direct {v1, v4}, Ljava/util/EnumMap;-><init>(Ljava/lang/Class;)V

    .line 61
    .local v1, "hints":Ljava/util/Map;, "Ljava/util/Map<Lcom/google/zxing/DecodeHintType;Ljava/lang/Object;>;"
    iget-boolean v4, p0, Lcom/forge/live/QrScanActivity;->qrOnly:Z

    if-eqz v4, :cond_5

    .line 62
    sget-object v2, Lcom/google/zxing/DecodeHintType;->POSSIBLE_FORMATS:Lcom/google/zxing/DecodeHintType;

    sget-object v4, Lcom/google/zxing/BarcodeFormat;->QR_CODE:Lcom/google/zxing/BarcodeFormat;

    invoke-static {v4}, Ljava/util/EnumSet;->of(Ljava/lang/Enum;)Ljava/util/EnumSet;

    move-result-object v4

    invoke-interface {v1, v2, v4}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_3

    .line 64
    :cond_5
    sget-object v4, Lcom/google/zxing/DecodeHintType;->POSSIBLE_FORMATS:Lcom/google/zxing/DecodeHintType;

    sget-object v5, Lcom/google/zxing/BarcodeFormat;->QR_CODE:Lcom/google/zxing/BarcodeFormat;

    const/4 v6, 0x6

    new-array v6, v6, [Lcom/google/zxing/BarcodeFormat;

    sget-object v7, Lcom/google/zxing/BarcodeFormat;->CODE_128:Lcom/google/zxing/BarcodeFormat;

    aput-object v7, v6, v2

    sget-object v2, Lcom/google/zxing/BarcodeFormat;->CODE_39:Lcom/google/zxing/BarcodeFormat;

    aput-object v2, v6, v3

    const/4 v2, 0x2

    sget-object v7, Lcom/google/zxing/BarcodeFormat;->EAN_13:Lcom/google/zxing/BarcodeFormat;

    aput-object v7, v6, v2

    const/4 v2, 0x3

    sget-object v7, Lcom/google/zxing/BarcodeFormat;->EAN_8:Lcom/google/zxing/BarcodeFormat;

    aput-object v7, v6, v2

    const/4 v2, 0x4

    sget-object v7, Lcom/google/zxing/BarcodeFormat;->UPC_A:Lcom/google/zxing/BarcodeFormat;

    aput-object v7, v6, v2

    const/4 v2, 0x5

    sget-object v7, Lcom/google/zxing/BarcodeFormat;->DATA_MATRIX:Lcom/google/zxing/BarcodeFormat;

    aput-object v7, v6, v2

    invoke-static {v5, v6}, Ljava/util/EnumSet;->of(Ljava/lang/Enum;[Ljava/lang/Enum;)Ljava/util/EnumSet;

    move-result-object v2

    invoke-interface {v1, v4, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 69
    :goto_3
    sget-object v2, Lcom/google/zxing/DecodeHintType;->TRY_HARDER:Lcom/google/zxing/DecodeHintType;

    sget-object v4, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-interface {v1, v2, v4}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 70
    iget-object v2, p0, Lcom/forge/live/QrScanActivity;->reader:Lcom/google/zxing/MultiFormatReader;

    invoke-virtual {v2, v1}, Lcom/google/zxing/MultiFormatReader;->setHints(Ljava/util/Map;)V

    .line 72
    new-instance v2, Landroid/widget/FrameLayout;

    invoke-direct {v2, p0}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;)V

    .line 73
    .local v2, "root":Landroid/widget/FrameLayout;
    const/high16 v4, -0x1000000

    invoke-virtual {v2, v4}, Landroid/widget/FrameLayout;->setBackgroundColor(I)V

    .line 74
    new-instance v5, Landroid/view/TextureView;

    invoke-direct {v5, p0}, Landroid/view/TextureView;-><init>(Landroid/content/Context;)V

    iput-object v5, p0, Lcom/forge/live/QrScanActivity;->textureView:Landroid/view/TextureView;

    .line 75
    invoke-virtual {v5, p0}, Landroid/view/TextureView;->setSurfaceTextureListener(Landroid/view/TextureView$SurfaceTextureListener;)V

    .line 76
    iget-object v5, p0, Lcom/forge/live/QrScanActivity;->textureView:Landroid/view/TextureView;

    new-instance v6, Landroid/widget/FrameLayout$LayoutParams;

    const/4 v7, -0x1

    invoke-direct {v6, v7, v7}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v2, v5, v6}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 79
    new-instance v5, Landroid/widget/TextView;

    invoke-direct {v5, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 80
    .local v5, "label":Landroid/widget/TextView;
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v8, "\nAlign code in view"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 81
    invoke-virtual {v5, v7}, Landroid/widget/TextView;->setTextColor(I)V

    .line 82
    const/high16 v6, 0x41800000    # 16.0f

    invoke-virtual {v5, v6}, Landroid/widget/TextView;->setTextSize(F)V

    .line 83
    invoke-virtual {v5, v3}, Landroid/widget/TextView;->setGravity(I)V

    .line 84
    const/16 v3, 0x18

    const/16 v6, 0x30

    invoke-virtual {v5, v3, v6, v3, v3}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 85
    const/high16 v3, 0x40800000    # 4.0f

    const/4 v8, 0x0

    invoke-virtual {v5, v3, v8, v8, v4}, Landroid/widget/TextView;->setShadowLayer(FFFI)V

    .line 86
    new-instance v3, Landroid/widget/FrameLayout$LayoutParams;

    const/4 v4, -0x2

    invoke-direct {v3, v7, v4}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V

    .line 88
    .local v3, "lpLabel":Landroid/widget/FrameLayout$LayoutParams;
    iput v6, v3, Landroid/widget/FrameLayout$LayoutParams;->gravity:I

    .line 89
    invoke-virtual {v2, v5, v3}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 91
    new-instance v6, Landroid/widget/Button;

    invoke-direct {v6, p0}, Landroid/widget/Button;-><init>(Landroid/content/Context;)V

    .line 92
    .local v6, "cancel":Landroid/widget/Button;
    const-string v7, "Cancel"

    invoke-virtual {v6, v7}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V

    .line 93
    new-instance v7, Lcom/forge/live/QrScanActivity$$ExternalSyntheticLambda0;

    invoke-direct {v7, p0}, Lcom/forge/live/QrScanActivity$$ExternalSyntheticLambda0;-><init>(Lcom/forge/live/QrScanActivity;)V

    invoke-virtual {v6, v7}, Landroid/widget/Button;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 97
    new-instance v7, Landroid/widget/FrameLayout$LayoutParams;

    invoke-direct {v7, v4, v4}, Landroid/widget/FrameLayout$LayoutParams;-><init>(II)V

    move-object v4, v7

    .line 99
    .local v4, "lpBtn":Landroid/widget/FrameLayout$LayoutParams;
    const/16 v7, 0x51

    iput v7, v4, Landroid/widget/FrameLayout$LayoutParams;->gravity:I

    .line 100
    const/16 v7, 0x40

    iput v7, v4, Landroid/widget/FrameLayout$LayoutParams;->bottomMargin:I

    .line 101
    invoke-virtual {v2, v6, v4}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 103
    invoke-virtual {p0, v2}, Lcom/forge/live/QrScanActivity;->setContentView(Landroid/view/View;)V

    .line 104
    return-void
.end method

.method protected onPause()V
    .locals 0

    .line 220
    invoke-super {p0}, Landroid/app/Activity;->onPause()V

    .line 221
    invoke-direct {p0}, Lcom/forge/live/QrScanActivity;->releaseCamera()V

    .line 222
    return-void
.end method

.method public onPreviewFrame([BLandroid/hardware/Camera;)V
    .locals 10
    .param p1, "data"    # [B
    .param p2, "cam"    # Landroid/hardware/Camera;

    .line 177
    iget-object v0, p0, Lcom/forge/live/QrScanActivity;->handled:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v0

    if-nez v0, :cond_5

    if-eqz p1, :cond_5

    iget v0, p0, Lcom/forge/live/QrScanActivity;->previewW:I

    if-lez v0, :cond_5

    iget v0, p0, Lcom/forge/live/QrScanActivity;->previewH:I

    if-gtz v0, :cond_0

    goto/16 :goto_1

    .line 180
    :cond_0
    :try_start_0
    new-instance v0, Lcom/google/zxing/PlanarYUVLuminanceSource;

    iget v7, p0, Lcom/forge/live/QrScanActivity;->previewW:I

    iget v8, p0, Lcom/forge/live/QrScanActivity;->previewH:I

    const/4 v5, 0x0

    const/4 v6, 0x0

    const/4 v9, 0x0

    move-object v1, v0

    move-object v2, p1

    move v3, v7

    move v4, v8

    invoke-direct/range {v1 .. v9}, Lcom/google/zxing/PlanarYUVLuminanceSource;-><init>([BIIIIIIZ)V

    .line 182
    .local v0, "source":Lcom/google/zxing/PlanarYUVLuminanceSource;
    new-instance v1, Lcom/google/zxing/BinaryBitmap;

    new-instance v2, Lcom/google/zxing/common/HybridBinarizer;

    invoke-direct {v2, v0}, Lcom/google/zxing/common/HybridBinarizer;-><init>(Lcom/google/zxing/LuminanceSource;)V

    invoke-direct {v1, v2}, Lcom/google/zxing/BinaryBitmap;-><init>(Lcom/google/zxing/Binarizer;)V

    .line 183
    .local v1, "bitmap":Lcom/google/zxing/BinaryBitmap;
    iget-object v2, p0, Lcom/forge/live/QrScanActivity;->reader:Lcom/google/zxing/MultiFormatReader;

    invoke-virtual {v2, v1}, Lcom/google/zxing/MultiFormatReader;->decodeWithState(Lcom/google/zxing/BinaryBitmap;)Lcom/google/zxing/Result;

    move-result-object v2

    .line 184
    .local v2, "result":Lcom/google/zxing/Result;
    iget-object v3, p0, Lcom/forge/live/QrScanActivity;->reader:Lcom/google/zxing/MultiFormatReader;

    invoke-virtual {v3}, Lcom/google/zxing/MultiFormatReader;->reset()V

    .line 185
    if-eqz v2, :cond_4

    invoke-virtual {v2}, Lcom/google/zxing/Result;->getText()Ljava/lang/String;

    move-result-object v3

    if-eqz v3, :cond_4

    .line 186
    iget-object v3, p0, Lcom/forge/live/QrScanActivity;->handled:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v4, 0x0

    const/4 v5, 0x1

    invoke-virtual {v3, v4, v5}, Ljava/util/concurrent/atomic/AtomicBoolean;->compareAndSet(ZZ)Z

    move-result v3

    if-nez v3, :cond_1

    return-void

    .line 187
    :cond_1
    new-instance v3, Landroid/content/Intent;

    invoke-direct {v3}, Landroid/content/Intent;-><init>()V

    .line 188
    .local v3, "out":Landroid/content/Intent;
    const-string v4, "text"

    invoke-virtual {v2}, Lcom/google/zxing/Result;->getText()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v4, v5}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 189
    invoke-virtual {v2}, Lcom/google/zxing/Result;->getBarcodeFormat()Lcom/google/zxing/BarcodeFormat;

    move-result-object v4

    if-eqz v4, :cond_2

    .line 190
    const-string v4, "format"

    invoke-virtual {v2}, Lcom/google/zxing/Result;->getBarcodeFormat()Lcom/google/zxing/BarcodeFormat;

    move-result-object v5

    invoke-virtual {v5}, Lcom/google/zxing/BarcodeFormat;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v4, v5}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 192
    :cond_2
    invoke-virtual {v2}, Lcom/google/zxing/Result;->getRawBytes()[B

    move-result-object v4

    if-eqz v4, :cond_3

    .line 193
    const-string v4, "rawB64"

    invoke-virtual {v2}, Lcom/google/zxing/Result;->getRawBytes()[B

    move-result-object v5

    const/4 v6, 0x2

    invoke-static {v5, v6}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v4, v5}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 195
    :cond_3
    const/4 v4, -0x1

    invoke-virtual {p0, v4, v3}, Lcom/forge/live/QrScanActivity;->setResult(ILandroid/content/Intent;)V

    .line 196
    invoke-direct {p0}, Lcom/forge/live/QrScanActivity;->releaseCamera()V

    .line 197
    invoke-virtual {p0}, Lcom/forge/live/QrScanActivity;->finish()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 201
    .end local v0    # "source":Lcom/google/zxing/PlanarYUVLuminanceSource;
    .end local v1    # "bitmap":Lcom/google/zxing/BinaryBitmap;
    .end local v2    # "result":Lcom/google/zxing/Result;
    .end local v3    # "out":Landroid/content/Intent;
    :cond_4
    goto :goto_0

    .line 199
    :catch_0
    move-exception v0

    .line 200
    .local v0, "e":Ljava/lang/Exception;
    :try_start_1
    iget-object v1, p0, Lcom/forge/live/QrScanActivity;->reader:Lcom/google/zxing/MultiFormatReader;

    invoke-virtual {v1}, Lcom/google/zxing/MultiFormatReader;->reset()V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_0

    :catch_1
    move-exception v1

    .line 202
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    return-void

    .line 177
    :cond_5
    :goto_1
    return-void
.end method

.method public onSurfaceTextureAvailable(Landroid/graphics/SurfaceTexture;II)V
    .locals 0
    .param p1, "surface"    # Landroid/graphics/SurfaceTexture;
    .param p2, "width"    # I
    .param p3, "height"    # I

    .line 108
    invoke-direct {p0, p1}, Lcom/forge/live/QrScanActivity;->openCamera(Landroid/graphics/SurfaceTexture;)V

    .line 109
    return-void
.end method

.method public onSurfaceTextureDestroyed(Landroid/graphics/SurfaceTexture;)Z
    .locals 1
    .param p1, "surface"    # Landroid/graphics/SurfaceTexture;

    .line 116
    invoke-direct {p0}, Lcom/forge/live/QrScanActivity;->releaseCamera()V

    .line 117
    const/4 v0, 0x1

    return v0
.end method

.method public onSurfaceTextureSizeChanged(Landroid/graphics/SurfaceTexture;II)V
    .locals 0
    .param p1, "surface"    # Landroid/graphics/SurfaceTexture;
    .param p2, "width"    # I
    .param p3, "height"    # I

    .line 112
    return-void
.end method

.method public onSurfaceTextureUpdated(Landroid/graphics/SurfaceTexture;)V
    .locals 0
    .param p1, "surface"    # Landroid/graphics/SurfaceTexture;

    .line 121
    return-void
.end method
