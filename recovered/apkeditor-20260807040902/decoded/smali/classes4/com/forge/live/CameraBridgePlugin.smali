.class public Lcom/forge/live/CameraBridgePlugin;
.super Lcom/getcapacitor/Plugin;
.source "CameraBridgePlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "CameraBridge"
    permissions = {
        .subannotation Lcom/getcapacitor/annotation/Permission;
            alias = "camera"
            strings = {
                "android.permission.CAMERA"
            }
        .end subannotation,
        .subannotation Lcom/getcapacitor/annotation/Permission;
            alias = "photos"
            strings = {
                "android.permission.READ_EXTERNAL_STORAGE"
            }
        .end subannotation
    }
.end annotation


# instance fields
.field private pendingCaptureFile:Ljava/io/File;

.field private pendingCaptureUri:Landroid/net/Uri;

.field private pendingMaxWidth:I

.field private pendingQuality:I


# direct methods
.method public constructor <init>()V
    .locals 1

    .line 56
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    .line 60
    const/16 v0, 0x55

    iput v0, p0, Lcom/forge/live/CameraBridgePlugin;->pendingQuality:I

    .line 61
    const/16 v0, 0x780

    iput v0, p0, Lcom/forge/live/CameraBridgePlugin;->pendingMaxWidth:I

    return-void
.end method

.method private applyExifOrientation(Ljava/lang/String;Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;
    .locals 3
    .param p1, "path"    # Ljava/lang/String;
    .param p2, "bitmap"    # Landroid/graphics/Bitmap;

    .line 408
    if-nez p2, :cond_0

    const/4 v0, 0x0

    return-object v0

    .line 410
    :cond_0
    :try_start_0
    new-instance v0, Landroid/media/ExifInterface;

    invoke-direct {v0, p1}, Landroid/media/ExifInterface;-><init>(Ljava/lang/String;)V

    .line 411
    .local v0, "exif":Landroid/media/ExifInterface;
    const-string v1, "Orientation"

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Landroid/media/ExifInterface;->getAttributeInt(Ljava/lang/String;I)I

    move-result v1

    .line 412
    .local v1, "orientation":I
    invoke-direct {p0, p2, v1}, Lcom/forge/live/CameraBridgePlugin;->rotateFromExif(Landroid/graphics/Bitmap;I)Landroid/graphics/Bitmap;

    move-result-object v2
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object v2

    .line 413
    .end local v0    # "exif":Landroid/media/ExifInterface;
    .end local v1    # "orientation":I
    :catch_0
    move-exception v0

    .line 414
    .local v0, "e":Ljava/lang/Exception;
    return-object p2
.end method

.method private cameraPermCallback(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/annotation/PermissionCallback;
    .end annotation

    .line 136
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 137
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "granted"

    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->hasCameraPermission()Z

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 138
    const-string v1, "alias"

    const-string v2, "camera"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 139
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 140
    return-void
.end method

.method private captureResult(Lcom/getcapacitor/PluginCall;Landroidx/activity/result/ActivityResult;)V
    .locals 9
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "result"    # Landroidx/activity/result/ActivityResult;
    .annotation runtime Lcom/getcapacitor/annotation/ActivityCallback;
    .end annotation

    .line 215
    const-string v0, "savedToGallery"

    const-string v1, "data"

    if-nez p1, :cond_0

    .line 216
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->cleanupPending()V

    .line 217
    return-void

    .line 220
    :cond_0
    :try_start_0
    invoke-virtual {p2}, Landroidx/activity/result/ActivityResult;->getResultCode()I

    move-result v2

    const/4 v3, -0x1

    if-eq v2, v3, :cond_1

    .line 221
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->cleanupPending()V

    .line 222
    const-string v0, "Camera cancelled"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 223
    return-void

    .line 225
    :cond_1
    iget-object v2, p0, Lcom/forge/live/CameraBridgePlugin;->pendingCaptureFile:Ljava/io/File;

    .line 226
    .local v2, "file":Ljava/io/File;
    if-eqz v2, :cond_4

    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    move-result v3

    if-eqz v3, :cond_4

    invoke-virtual {v2}, Ljava/io/File;->length()J

    move-result-wide v3

    const-wide/16 v5, 0x0

    cmp-long v7, v3, v5

    if-nez v7, :cond_2

    goto :goto_1

    .line 246
    :cond_2
    iget v1, p0, Lcom/forge/live/CameraBridgePlugin;->pendingQuality:I

    iget v3, p0, Lcom/forge/live/CameraBridgePlugin;->pendingMaxWidth:I

    invoke-direct {p0, v2, v1, v3}, Lcom/forge/live/CameraBridgePlugin;->encodeFile(Ljava/io/File;II)Lcom/getcapacitor/JSObject;

    move-result-object v1

    .line 247
    .local v1, "o":Lcom/getcapacitor/JSObject;
    sget-object v3, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v4, "saveToGallery"

    const/4 v5, 0x0

    invoke-static {v5}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v6

    invoke-virtual {p1, v4, v6}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v3
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 248
    .local v3, "saveToGallery":Z
    if-eqz v3, :cond_3

    .line 250
    nop

    .line 251
    :try_start_1
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-virtual {v4}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v4

    .line 252
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v6

    .line 253
    invoke-virtual {v2}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v7

    const-string v8, "Forge capture"

    .line 250
    invoke-static {v4, v6, v7, v8}, Landroid/provider/MediaStore$Images$Media;->insertImage(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 256
    const/4 v4, 0x1

    invoke-virtual {v1, v0, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .line 259
    goto :goto_0

    .line 257
    :catch_0
    move-exception v4

    .line 258
    .local v4, "ignored":Ljava/lang/Exception;
    :try_start_2
    invoke-virtual {v1, v0, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 262
    .end local v4    # "ignored":Ljava/lang/Exception;
    :cond_3
    :goto_0
    const-string v0, "path"

    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v1, v0, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 263
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->cleanupPendingKeepFile()V

    .line 264
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 268
    .end local v1    # "o":Lcom/getcapacitor/JSObject;
    .end local v2    # "file":Ljava/io/File;
    .end local v3    # "saveToGallery":Z
    goto :goto_2

    .line 228
    .restart local v2    # "file":Ljava/io/File;
    :cond_4
    :goto_1
    invoke-virtual {p2}, Landroidx/activity/result/ActivityResult;->getData()Landroid/content/Intent;

    move-result-object v0

    .line 229
    .local v0, "data":Landroid/content/Intent;
    if-eqz v0, :cond_5

    invoke-virtual {v0}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v3

    if-eqz v3, :cond_5

    .line 230
    invoke-virtual {v0}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v1

    iget v3, p0, Lcom/forge/live/CameraBridgePlugin;->pendingQuality:I

    iget v4, p0, Lcom/forge/live/CameraBridgePlugin;->pendingMaxWidth:I

    invoke-direct {p0, v1, v3, v4}, Lcom/forge/live/CameraBridgePlugin;->encodeUri(Landroid/net/Uri;II)Lcom/getcapacitor/JSObject;

    move-result-object v1

    .line 231
    .restart local v1    # "o":Lcom/getcapacitor/JSObject;
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->cleanupPending()V

    .line 232
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 233
    return-void

    .line 235
    .end local v1    # "o":Lcom/getcapacitor/JSObject;
    :cond_5
    if-eqz v0, :cond_6

    invoke-virtual {v0}, Landroid/content/Intent;->getExtras()Landroid/os/Bundle;

    move-result-object v3

    if-eqz v3, :cond_6

    invoke-virtual {v0}, Landroid/content/Intent;->getExtras()Landroid/os/Bundle;

    move-result-object v3

    invoke-virtual {v3, v1}, Landroid/os/Bundle;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v3

    instance-of v3, v3, Landroid/graphics/Bitmap;

    if-eqz v3, :cond_6

    .line 236
    invoke-virtual {v0}, Landroid/content/Intent;->getExtras()Landroid/os/Bundle;

    move-result-object v3

    invoke-virtual {v3, v1}, Landroid/os/Bundle;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/graphics/Bitmap;

    .line 237
    .local v1, "thumb":Landroid/graphics/Bitmap;
    iget v3, p0, Lcom/forge/live/CameraBridgePlugin;->pendingQuality:I

    iget v4, p0, Lcom/forge/live/CameraBridgePlugin;->pendingMaxWidth:I

    const/4 v5, 0x0

    invoke-direct {p0, v1, v3, v4, v5}, Lcom/forge/live/CameraBridgePlugin;->encodeBitmap(Landroid/graphics/Bitmap;IILjava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v3

    .line 238
    .local v3, "o":Lcom/getcapacitor/JSObject;
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->cleanupPending()V

    .line 239
    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 240
    return-void

    .line 242
    .end local v1    # "thumb":Landroid/graphics/Bitmap;
    .end local v3    # "o":Lcom/getcapacitor/JSObject;
    :cond_6
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->cleanupPending()V

    .line 243
    const-string v1, "No image returned from camera"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    .line 244
    return-void

    .line 265
    .end local v0    # "data":Landroid/content/Intent;
    .end local v2    # "file":Ljava/io/File;
    :catch_1
    move-exception v0

    .line 266
    .local v0, "e":Ljava/lang/Exception;
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->cleanupPending()V

    .line 267
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "captureResult failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 269
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_2
    return-void
.end method

.method private static clamp(III)I
    .locals 1
    .param p0, "v"    # I
    .param p1, "lo"    # I
    .param p2, "hi"    # I

    .line 450
    invoke-static {p2, p0}, Ljava/lang/Math;->min(II)I

    move-result v0

    invoke-static {p1, v0}, Ljava/lang/Math;->max(II)I

    move-result v0

    return v0
.end method

.method private cleanupPending()V
    .locals 1

    .line 436
    iget-object v0, p0, Lcom/forge/live/CameraBridgePlugin;->pendingCaptureFile:Ljava/io/File;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 438
    :try_start_0
    iget-object v0, p0, Lcom/forge/live/CameraBridgePlugin;->pendingCaptureFile:Ljava/io/File;

    invoke-virtual {v0}, Ljava/io/File;->delete()Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 439
    :catch_0
    move-exception v0

    :goto_0
    nop

    .line 441
    :cond_0
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->cleanupPendingKeepFile()V

    .line 442
    return-void
.end method

.method private cleanupPendingKeepFile()V
    .locals 1

    .line 445
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/forge/live/CameraBridgePlugin;->pendingCaptureFile:Ljava/io/File;

    .line 446
    iput-object v0, p0, Lcom/forge/live/CameraBridgePlugin;->pendingCaptureUri:Landroid/net/Uri;

    .line 447
    return-void
.end method

.method private decodeBounded(Ljava/lang/String;I)Landroid/graphics/Bitmap;
    .locals 5
    .param p1, "path"    # Ljava/lang/String;
    .param p2, "maxWidth"    # I

    .line 394
    new-instance v0, Landroid/graphics/BitmapFactory$Options;

    invoke-direct {v0}, Landroid/graphics/BitmapFactory$Options;-><init>()V

    .line 395
    .local v0, "bounds":Landroid/graphics/BitmapFactory$Options;
    const/4 v1, 0x1

    iput-boolean v1, v0, Landroid/graphics/BitmapFactory$Options;->inJustDecodeBounds:Z

    .line 396
    invoke-static {p1, v0}, Landroid/graphics/BitmapFactory;->decodeFile(Ljava/lang/String;Landroid/graphics/BitmapFactory$Options;)Landroid/graphics/Bitmap;

    .line 397
    const/4 v1, 0x1

    .line 398
    .local v1, "sample":I
    if-lez p2, :cond_0

    .line 399
    iget v2, v0, Landroid/graphics/BitmapFactory$Options;->outWidth:I

    iget v3, v0, Landroid/graphics/BitmapFactory$Options;->outHeight:I

    invoke-static {v2, v3}, Ljava/lang/Math;->max(II)I

    move-result v2

    .line 400
    .local v2, "w":I
    :goto_0
    div-int v3, v2, v1

    mul-int/lit8 v4, p2, 0x2

    if-le v3, v4, :cond_0

    mul-int/lit8 v1, v1, 0x2

    goto :goto_0

    .line 402
    .end local v2    # "w":I
    :cond_0
    new-instance v2, Landroid/graphics/BitmapFactory$Options;

    invoke-direct {v2}, Landroid/graphics/BitmapFactory$Options;-><init>()V

    .line 403
    .local v2, "opts":Landroid/graphics/BitmapFactory$Options;
    iput v1, v2, Landroid/graphics/BitmapFactory$Options;->inSampleSize:I

    .line 404
    invoke-static {p1, v2}, Landroid/graphics/BitmapFactory;->decodeFile(Ljava/lang/String;Landroid/graphics/BitmapFactory$Options;)Landroid/graphics/Bitmap;

    move-result-object v3

    return-object v3
.end method

.method private deviceHasCamera()Z
    .locals 2

    .line 84
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    .line 85
    .local v0, "pm":Landroid/content/pm/PackageManager;
    const-string v1, "android.hardware.camera.any"

    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->hasSystemFeature(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_1

    .line 86
    const-string v1, "android.hardware.camera"

    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->hasSystemFeature(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_0

    :cond_0
    const/4 v1, 0x0

    goto :goto_1

    :cond_1
    :goto_0
    const/4 v1, 0x1

    .line 85
    :goto_1
    return v1
.end method

.method private encodeBitmap(Landroid/graphics/Bitmap;IILjava/lang/String;)Lcom/getcapacitor/JSObject;
    .locals 7
    .param p1, "bitmap"    # Landroid/graphics/Bitmap;
    .param p2, "quality"    # I
    .param p3, "maxWidth"    # I
    .param p4, "path"    # Ljava/lang/String;

    .line 360
    if-eqz p1, :cond_2

    .line 361
    if-lez p3, :cond_0

    .line 362
    invoke-virtual {p1}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v0

    .line 363
    .local v0, "w":I
    invoke-virtual {p1}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v1

    .line 364
    .local v1, "h":I
    invoke-static {v0, v1}, Ljava/lang/Math;->max(II)I

    move-result v2

    .line 365
    .local v2, "longEdge":I
    if-le v2, p3, :cond_0

    .line 366
    int-to-float v3, p3

    int-to-float v4, v2

    div-float/2addr v3, v4

    .line 367
    .local v3, "scale":F
    int-to-float v4, v0

    mul-float v4, v4, v3

    invoke-static {v4}, Ljava/lang/Math;->round(F)I

    move-result v4

    const/4 v5, 0x1

    invoke-static {v5, v4}, Ljava/lang/Math;->max(II)I

    move-result v4

    .line 368
    .local v4, "nw":I
    int-to-float v6, v1

    mul-float v6, v6, v3

    invoke-static {v6}, Ljava/lang/Math;->round(F)I

    move-result v6

    invoke-static {v5, v6}, Ljava/lang/Math;->max(II)I

    move-result v6

    .line 369
    .local v6, "nh":I
    invoke-static {p1, v4, v6, v5}, Landroid/graphics/Bitmap;->createScaledBitmap(Landroid/graphics/Bitmap;IIZ)Landroid/graphics/Bitmap;

    move-result-object v5

    .line 370
    .local v5, "scaled":Landroid/graphics/Bitmap;
    if-eq v5, p1, :cond_0

    .line 371
    invoke-virtual {p1}, Landroid/graphics/Bitmap;->recycle()V

    .line 372
    move-object p1, v5

    .line 376
    .end local v0    # "w":I
    .end local v1    # "h":I
    .end local v2    # "longEdge":I
    .end local v3    # "scale":F
    .end local v4    # "nw":I
    .end local v5    # "scaled":Landroid/graphics/Bitmap;
    .end local v6    # "nh":I
    :cond_0
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 377
    .local v0, "bos":Ljava/io/ByteArrayOutputStream;
    sget-object v1, Landroid/graphics/Bitmap$CompressFormat;->JPEG:Landroid/graphics/Bitmap$CompressFormat;

    invoke-virtual {p1, v1, p2, v0}, Landroid/graphics/Bitmap;->compress(Landroid/graphics/Bitmap$CompressFormat;ILjava/io/OutputStream;)Z

    .line 378
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v1

    .line 379
    .local v1, "bytes":[B
    const/4 v2, 0x2

    invoke-static {v1, v2}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;

    move-result-object v2

    .line 380
    .local v2, "b64":Ljava/lang/String;
    new-instance v3, Lcom/getcapacitor/JSObject;

    invoke-direct {v3}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 381
    .local v3, "o":Lcom/getcapacitor/JSObject;
    const-string v4, "base64"

    invoke-virtual {v3, v4, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 382
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "data:image/jpeg;base64,"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    const-string v5, "dataUrl"

    invoke-virtual {v3, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 383
    const-string v4, "format"

    const-string v5, "jpeg"

    invoke-virtual {v3, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 384
    const-string v4, "width"

    invoke-virtual {p1}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v5

    invoke-virtual {v3, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 385
    const-string v4, "height"

    invoke-virtual {p1}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v5

    invoke-virtual {v3, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 386
    const-string v4, "bytes"

    array-length v5, v1

    invoke-virtual {v3, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 387
    const-string v4, "quality"

    invoke-virtual {v3, v4, p2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 388
    if-eqz p4, :cond_1

    const-string v4, "path"

    invoke-virtual {v3, v4, p4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 389
    :cond_1
    invoke-virtual {p1}, Landroid/graphics/Bitmap;->recycle()V

    .line 390
    return-object v3

    .line 360
    .end local v0    # "bos":Ljava/io/ByteArrayOutputStream;
    .end local v1    # "bytes":[B
    .end local v2    # "b64":Ljava/lang/String;
    .end local v3    # "o":Lcom/getcapacitor/JSObject;
    :cond_2
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "null bitmap"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method private encodeFile(Ljava/io/File;II)Lcom/getcapacitor/JSObject;
    .locals 2
    .param p1, "file"    # Ljava/io/File;
    .param p2, "quality"    # I
    .param p3, "maxWidth"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 317
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p0, v0, p3}, Lcom/forge/live/CameraBridgePlugin;->decodeBounded(Ljava/lang/String;I)Landroid/graphics/Bitmap;

    move-result-object v0

    .line 318
    .local v0, "bitmap":Landroid/graphics/Bitmap;
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v1

    invoke-direct {p0, v1, v0}, Lcom/forge/live/CameraBridgePlugin;->applyExifOrientation(Ljava/lang/String;Landroid/graphics/Bitmap;)Landroid/graphics/Bitmap;

    move-result-object v0

    .line 319
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v1

    invoke-direct {p0, v0, p2, p3, v1}, Lcom/forge/live/CameraBridgePlugin;->encodeBitmap(Landroid/graphics/Bitmap;IILjava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v1

    return-object v1
.end method

.method private encodeUri(Landroid/net/Uri;II)Lcom/getcapacitor/JSObject;
    .locals 10
    .param p1, "uri"    # Landroid/net/Uri;
    .param p2, "quality"    # I
    .param p3, "maxWidth"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 323
    new-instance v0, Landroid/graphics/BitmapFactory$Options;

    invoke-direct {v0}, Landroid/graphics/BitmapFactory$Options;-><init>()V

    .line 324
    .local v0, "bounds":Landroid/graphics/BitmapFactory$Options;
    const/4 v1, 0x1

    iput-boolean v1, v0, Landroid/graphics/BitmapFactory$Options;->inJustDecodeBounds:Z

    .line 325
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    invoke-virtual {v2, p1}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;

    move-result-object v2

    .line 326
    .local v2, "is":Ljava/io/InputStream;
    const-string v3, "Cannot open image"

    if-eqz v2, :cond_5

    .line 327
    const/4 v4, 0x0

    invoke-static {v2, v4, v0}, Landroid/graphics/BitmapFactory;->decodeStream(Ljava/io/InputStream;Landroid/graphics/Rect;Landroid/graphics/BitmapFactory$Options;)Landroid/graphics/Bitmap;

    .line 328
    invoke-virtual {v2}, Ljava/io/InputStream;->close()V

    .line 330
    const/4 v5, 0x1

    .line 331
    .local v5, "sample":I
    if-lez p3, :cond_0

    .line 332
    iget v6, v0, Landroid/graphics/BitmapFactory$Options;->outWidth:I

    iget v7, v0, Landroid/graphics/BitmapFactory$Options;->outHeight:I

    invoke-static {v6, v7}, Ljava/lang/Math;->max(II)I

    move-result v6

    .line 333
    .local v6, "w":I
    :goto_0
    div-int v7, v6, v5

    mul-int/lit8 v8, p3, 0x2

    if-le v7, v8, :cond_0

    mul-int/lit8 v5, v5, 0x2

    goto :goto_0

    .line 335
    .end local v6    # "w":I
    :cond_0
    new-instance v6, Landroid/graphics/BitmapFactory$Options;

    invoke-direct {v6}, Landroid/graphics/BitmapFactory$Options;-><init>()V

    .line 336
    .local v6, "opts":Landroid/graphics/BitmapFactory$Options;
    iput v5, v6, Landroid/graphics/BitmapFactory$Options;->inSampleSize:I

    .line 337
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v7

    invoke-virtual {v7}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v7

    invoke-virtual {v7, p1}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;

    move-result-object v2

    .line 338
    if-eqz v2, :cond_4

    .line 339
    invoke-static {v2, v4, v6}, Landroid/graphics/BitmapFactory;->decodeStream(Ljava/io/InputStream;Landroid/graphics/Rect;Landroid/graphics/BitmapFactory$Options;)Landroid/graphics/Bitmap;

    move-result-object v3

    .line 340
    .local v3, "bitmap":Landroid/graphics/Bitmap;
    invoke-virtual {v2}, Ljava/io/InputStream;->close()V

    .line 341
    if-eqz v3, :cond_3

    .line 343
    sget v7, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v8, 0x18

    if-lt v7, v8, :cond_2

    .line 345
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v7

    invoke-virtual {v7}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v7

    invoke-virtual {v7, p1}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;

    move-result-object v7

    .line 346
    .local v7, "exifStream":Ljava/io/InputStream;
    if-eqz v7, :cond_1

    .line 347
    new-instance v8, Landroid/media/ExifInterface;

    invoke-direct {v8, v7}, Landroid/media/ExifInterface;-><init>(Ljava/io/InputStream;)V

    .line 348
    .local v8, "exif":Landroid/media/ExifInterface;
    const-string v9, "Orientation"

    invoke-virtual {v8, v9, v1}, Landroid/media/ExifInterface;->getAttributeInt(Ljava/lang/String;I)I

    move-result v1

    invoke-direct {p0, v3, v1}, Lcom/forge/live/CameraBridgePlugin;->rotateFromExif(Landroid/graphics/Bitmap;I)Landroid/graphics/Bitmap;

    move-result-object v1
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 349
    .end local v3    # "bitmap":Landroid/graphics/Bitmap;
    .local v1, "bitmap":Landroid/graphics/Bitmap;
    :try_start_1
    invoke-virtual {v7}, Ljava/io/InputStream;->close()V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    move-object v3, v1

    goto :goto_1

    .line 351
    .end local v7    # "exifStream":Ljava/io/InputStream;
    .end local v8    # "exif":Landroid/media/ExifInterface;
    :catch_0
    move-exception v3

    move-object v3, v1

    goto :goto_1

    .end local v1    # "bitmap":Landroid/graphics/Bitmap;
    .restart local v3    # "bitmap":Landroid/graphics/Bitmap;
    :catch_1
    move-exception v1

    :cond_1
    :goto_1
    nop

    .line 354
    :cond_2
    invoke-direct {p0, v3, p2, p3, v4}, Lcom/forge/live/CameraBridgePlugin;->encodeBitmap(Landroid/graphics/Bitmap;IILjava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v1

    .line 355
    .local v1, "o":Lcom/getcapacitor/JSObject;
    const-string v4, "uri"

    invoke-virtual {p1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v1, v4, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 356
    return-object v1

    .line 341
    .end local v1    # "o":Lcom/getcapacitor/JSObject;
    :cond_3
    new-instance v1, Ljava/lang/Exception;

    const-string v4, "Decode failed"

    invoke-direct {v1, v4}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v1

    .line 338
    .end local v3    # "bitmap":Landroid/graphics/Bitmap;
    :cond_4
    new-instance v1, Ljava/lang/Exception;

    invoke-direct {v1, v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v1

    .line 326
    .end local v5    # "sample":I
    .end local v6    # "opts":Landroid/graphics/BitmapFactory$Options;
    :cond_5
    new-instance v1, Ljava/lang/Exception;

    invoke-direct {v1, v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method private hasCameraPermission()Z
    .locals 2

    .line 64
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    const-string v1, "android.permission.CAMERA"

    invoke-static {v0, v1}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result v0

    if-nez v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method private hasGalleryPermission()Z
    .locals 5

    .line 69
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    const/4 v2, 0x0

    const-string v3, "android.permission.READ_EXTERNAL_STORAGE"

    const/4 v4, 0x1

    if-lt v0, v1, :cond_2

    .line 70
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    const-string v1, "android.permission.READ_MEDIA_IMAGES"

    invoke-static {v0, v1}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result v0

    if-eqz v0, :cond_0

    .line 72
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0, v3}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result v0

    if-nez v0, :cond_1

    :cond_0
    const/4 v2, 0x1

    .line 70
    :cond_1
    return v2

    .line 75
    :cond_2
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1d

    if-lt v0, v1, :cond_3

    .line 77
    return v4

    .line 79
    :cond_3
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0, v3}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result v0

    if-nez v0, :cond_4

    const/4 v2, 0x1

    :cond_4
    return v2
.end method

.method private photosPermCallback(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/annotation/PermissionCallback;
    .end annotation

    .line 144
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 145
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "granted"

    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->hasGalleryPermission()Z

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 146
    const-string v1, "alias"

    const-string v2, "photos"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 147
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 148
    return-void
.end method

.method private pickResult(Lcom/getcapacitor/PluginCall;Landroidx/activity/result/ActivityResult;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "result"    # Landroidx/activity/result/ActivityResult;
    .annotation runtime Lcom/getcapacitor/annotation/ActivityCallback;
    .end annotation

    .line 298
    if-nez p1, :cond_0

    return-void

    .line 300
    :cond_0
    :try_start_0
    invoke-virtual {p2}, Landroidx/activity/result/ActivityResult;->getResultCode()I

    move-result v0

    const/4 v1, -0x1

    if-eq v0, v1, :cond_1

    .line 301
    const-string v0, "Pick cancelled"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 302
    return-void

    .line 304
    :cond_1
    invoke-virtual {p2}, Landroidx/activity/result/ActivityResult;->getData()Landroid/content/Intent;

    move-result-object v0

    .line 305
    .local v0, "data":Landroid/content/Intent;
    if-eqz v0, :cond_2

    invoke-virtual {v0}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v1

    goto :goto_0

    :cond_2
    const/4 v1, 0x0

    .line 306
    .local v1, "uri":Landroid/net/Uri;
    :goto_0
    if-nez v1, :cond_3

    .line 307
    const-string v2, "No image selected"

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 308
    return-void

    .line 310
    :cond_3
    iget v2, p0, Lcom/forge/live/CameraBridgePlugin;->pendingQuality:I

    iget v3, p0, Lcom/forge/live/CameraBridgePlugin;->pendingMaxWidth:I

    invoke-direct {p0, v1, v2, v3}, Lcom/forge/live/CameraBridgePlugin;->encodeUri(Landroid/net/Uri;II)Lcom/getcapacitor/JSObject;

    move-result-object v2

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 313
    .end local v0    # "data":Landroid/content/Intent;
    .end local v1    # "uri":Landroid/net/Uri;
    goto :goto_1

    .line 311
    :catch_0
    move-exception v0

    .line 312
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "pickResult failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 314
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1
    return-void
.end method

.method private rotateFromExif(Landroid/graphics/Bitmap;I)Landroid/graphics/Bitmap;
    .locals 9
    .param p1, "bitmap"    # Landroid/graphics/Bitmap;
    .param p2, "orientation"    # I

    .line 419
    const/4 v0, 0x0

    .line 420
    .local v0, "degrees":I
    sparse-switch p2, :sswitch_data_0

    .line 426
    return-object p1

    .line 423
    :sswitch_0
    const/16 v0, 0x10e

    goto :goto_0

    .line 421
    :sswitch_1
    const/16 v0, 0x5a

    goto :goto_0

    .line 422
    :sswitch_2
    const/16 v0, 0xb4

    .line 428
    :goto_0
    new-instance v1, Landroid/graphics/Matrix;

    invoke-direct {v1}, Landroid/graphics/Matrix;-><init>()V

    .line 429
    .local v1, "m":Landroid/graphics/Matrix;
    int-to-float v2, v0

    invoke-virtual {v1, v2}, Landroid/graphics/Matrix;->postRotate(F)Z

    .line 430
    const/4 v3, 0x0

    const/4 v4, 0x0

    invoke-virtual {p1}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v5

    invoke-virtual {p1}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v6

    const/4 v8, 0x1

    move-object v2, p1

    move-object v7, v1

    invoke-static/range {v2 .. v8}, Landroid/graphics/Bitmap;->createBitmap(Landroid/graphics/Bitmap;IIIILandroid/graphics/Matrix;Z)Landroid/graphics/Bitmap;

    move-result-object v2

    .line 431
    .local v2, "rotated":Landroid/graphics/Bitmap;
    if-eq v2, p1, :cond_0

    invoke-virtual {p1}, Landroid/graphics/Bitmap;->recycle()V

    .line 432
    :cond_0
    return-object v2

    nop

    :sswitch_data_0
    .sparse-switch
        0x3 -> :sswitch_2
        0x6 -> :sswitch_1
        0x8 -> :sswitch_0
    .end sparse-switch
.end method


# virtual methods
.method public isAvailable(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 91
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 92
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "camera"

    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->deviceHasCamera()Z

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 93
    const-string v1, "permission"

    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->hasCameraPermission()Z

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 94
    const-string v1, "galleryPermission"

    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->hasGalleryPermission()Z

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 95
    const-string v1, "facingModes"

    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->deviceHasCamera()Z

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 96
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 97
    return-void
.end method

.method public pickPhoto(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 277
    const/16 v0, 0x55

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    const-string v1, "quality"

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    const/4 v1, 0x1

    const/16 v2, 0x64

    invoke-static {v0, v1, v2}, Lcom/forge/live/CameraBridgePlugin;->clamp(III)I

    move-result v0

    iput v0, p0, Lcom/forge/live/CameraBridgePlugin;->pendingQuality:I

    .line 278
    const/16 v0, 0x780

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    const-string v1, "maxWidth"

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    const/4 v1, 0x0

    invoke-static {v1, v0}, Ljava/lang/Math;->max(II)I

    move-result v0

    iput v0, p0, Lcom/forge/live/CameraBridgePlugin;->pendingMaxWidth:I

    .line 281
    :try_start_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    const/16 v1, 0x21

    const-string v2, "image/*"

    if-lt v0, v1, :cond_0

    .line 282
    :try_start_1
    new-instance v0, Landroid/content/Intent;

    const-string v1, "android.provider.action.PICK_IMAGES"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 283
    .local v0, "intent":Landroid/content/Intent;
    invoke-virtual {v0, v2}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    goto :goto_0

    .line 285
    .end local v0    # "intent":Landroid/content/Intent;
    :cond_0
    new-instance v0, Landroid/content/Intent;

    const-string v1, "android.intent.action.GET_CONTENT"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 286
    .restart local v0    # "intent":Landroid/content/Intent;
    invoke-virtual {v0, v2}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    .line 287
    const-string v1, "android.intent.category.OPENABLE"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;

    .line 289
    :goto_0
    const-string v1, "Pick photo"

    invoke-static {v0, v1}, Landroid/content/Intent;->createChooser(Landroid/content/Intent;Ljava/lang/CharSequence;)Landroid/content/Intent;

    move-result-object v1

    .line 290
    .local v1, "chooser":Landroid/content/Intent;
    const-string v2, "pickResult"

    invoke-virtual {p0, p1, v1, v2}, Lcom/forge/live/CameraBridgePlugin;->startActivityForResult(Lcom/getcapacitor/PluginCall;Landroid/content/Intent;Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .line 293
    .end local v0    # "intent":Landroid/content/Intent;
    .end local v1    # "chooser":Landroid/content/Intent;
    goto :goto_1

    .line 291
    :catch_0
    move-exception v0

    .line 292
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "pickPhoto failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 294
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1
    return-void
.end method

.method public requestPermission(Lcom/getcapacitor/PluginCall;)V
    .locals 7
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 101
    const-string v0, "alias"

    const-string v1, "camera"

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 102
    .local v2, "which":Ljava/lang/String;
    const-string v3, "photos"

    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    const/4 v5, 0x1

    const-string v6, "granted"

    if-nez v4, :cond_2

    const-string v4, "gallery"

    invoke-virtual {v4, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_0

    goto :goto_0

    .line 124
    :cond_0
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->hasCameraPermission()Z

    move-result v3

    if-eqz v3, :cond_1

    .line 125
    new-instance v3, Lcom/getcapacitor/JSObject;

    invoke-direct {v3}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 126
    .local v3, "o":Lcom/getcapacitor/JSObject;
    invoke-virtual {v3, v6, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 127
    invoke-virtual {v3, v0, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 128
    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 129
    return-void

    .line 131
    .end local v3    # "o":Lcom/getcapacitor/JSObject;
    :cond_1
    const-string v0, "cameraPermCallback"

    invoke-virtual {p0, v1, p1, v0}, Lcom/forge/live/CameraBridgePlugin;->requestPermissionForAlias(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    .line 132
    return-void

    .line 103
    :cond_2
    :goto_0
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v4, 0x21

    if-lt v1, v4, :cond_3

    .line 105
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->hasGalleryPermission()Z

    move-result v1

    if-eqz v1, :cond_3

    .line 106
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 107
    .local v1, "o":Lcom/getcapacitor/JSObject;
    invoke-virtual {v1, v6, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 108
    invoke-virtual {v1, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 109
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 110
    return-void

    .line 114
    .end local v1    # "o":Lcom/getcapacitor/JSObject;
    :cond_3
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->hasGalleryPermission()Z

    move-result v1

    if-eqz v1, :cond_4

    .line 115
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 116
    .restart local v1    # "o":Lcom/getcapacitor/JSObject;
    invoke-virtual {v1, v6, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 117
    invoke-virtual {v1, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 118
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 119
    return-void

    .line 121
    .end local v1    # "o":Lcom/getcapacitor/JSObject;
    :cond_4
    const-string v0, "photosPermCallback"

    invoke-virtual {p0, v3, p1, v0}, Lcom/forge/live/CameraBridgePlugin;->requestPermissionForAlias(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    .line 122
    return-void
.end method

.method public takePhoto(Lcom/getcapacitor/PluginCall;)V
    .locals 10
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 159
    const-string v0, "output"

    const-string v1, "front"

    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->deviceHasCamera()Z

    move-result v2

    if-nez v2, :cond_0

    .line 160
    const-string v0, "No camera on this device"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 161
    return-void

    .line 163
    :cond_0
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->hasCameraPermission()Z

    move-result v2

    if-nez v2, :cond_1

    .line 164
    const-string v0, "CAMERA permission not granted. Call requestPermission first."

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 165
    return-void

    .line 168
    :cond_1
    const/16 v2, 0x55

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    const-string v3, "quality"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    const/16 v3, 0x64

    const/4 v4, 0x1

    invoke-static {v2, v4, v3}, Lcom/forge/live/CameraBridgePlugin;->clamp(III)I

    move-result v2

    iput v2, p0, Lcom/forge/live/CameraBridgePlugin;->pendingQuality:I

    .line 169
    const/16 v2, 0x780

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    const-string v3, "maxWidth"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    const/4 v3, 0x0

    invoke-static {v3, v2}, Ljava/lang/Math;->max(II)I

    move-result v2

    iput v2, p0, Lcom/forge/live/CameraBridgePlugin;->pendingMaxWidth:I

    .line 170
    const-string v2, "facing"

    const-string v5, "back"

    invoke-virtual {p1, v2, v5}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 173
    .local v2, "facing":Ljava/lang/String;
    :try_start_0
    new-instance v5, Ljava/io/File;

    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v6

    invoke-virtual {v6}, Landroid/content/Context;->getCacheDir()Ljava/io/File;

    move-result-object v6

    const-string v7, "camera"

    invoke-direct {v5, v6, v7}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 174
    .local v5, "dir":Ljava/io/File;
    invoke-virtual {v5}, Ljava/io/File;->exists()Z

    move-result v6

    if-nez v6, :cond_2

    invoke-virtual {v5}, Ljava/io/File;->mkdirs()Z

    move-result v6

    if-nez v6, :cond_2

    .line 175
    const-string v0, "Cannot create camera cache dir"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 176
    return-void

    .line 178
    :cond_2
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "forge_"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    new-instance v7, Ljava/text/SimpleDateFormat;

    const-string v8, "yyyyMMdd_HHmmss"

    sget-object v9, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-direct {v7, v8, v9}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;Ljava/util/Locale;)V

    new-instance v8, Ljava/util/Date;

    invoke-direct {v8}, Ljava/util/Date;-><init>()V

    invoke-virtual {v7, v8}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, ".jpg"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    .line 179
    .local v6, "name":Ljava/lang/String;
    new-instance v7, Ljava/io/File;

    invoke-direct {v7, v5, v6}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    iput-object v7, p0, Lcom/forge/live/CameraBridgePlugin;->pendingCaptureFile:Ljava/io/File;

    .line 180
    nop

    .line 181
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v7

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    .line 182
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v9

    invoke-virtual {v9}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, ".fileprovider"

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    iget-object v9, p0, Lcom/forge/live/CameraBridgePlugin;->pendingCaptureFile:Ljava/io/File;

    .line 180
    invoke-static {v7, v8, v9}, Landroidx/core/content/FileProvider;->getUriForFile(Landroid/content/Context;Ljava/lang/String;Ljava/io/File;)Landroid/net/Uri;

    move-result-object v7

    iput-object v7, p0, Lcom/forge/live/CameraBridgePlugin;->pendingCaptureUri:Landroid/net/Uri;

    .line 186
    new-instance v7, Landroid/content/Intent;

    const-string v8, "android.media.action.IMAGE_CAPTURE"

    invoke-direct {v7, v8}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 187
    .local v7, "intent":Landroid/content/Intent;
    iget-object v8, p0, Lcom/forge/live/CameraBridgePlugin;->pendingCaptureUri:Landroid/net/Uri;

    invoke-virtual {v7, v0, v8}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;

    .line 188
    const/4 v8, 0x3

    invoke-virtual {v7, v8}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 190
    iget-object v8, p0, Lcom/forge/live/CameraBridgePlugin;->pendingCaptureUri:Landroid/net/Uri;

    invoke-static {v0, v8}, Landroid/content/ClipData;->newRawUri(Ljava/lang/CharSequence;Landroid/net/Uri;)Landroid/content/ClipData;

    move-result-object v0

    invoke-virtual {v7, v0}, Landroid/content/Intent;->setClipData(Landroid/content/ClipData;)V

    .line 192
    invoke-virtual {v1, v2}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    const-string v8, "android.intent.extras.CAMERA_FACING"

    if-eqz v0, :cond_3

    .line 193
    :try_start_1
    invoke-virtual {v7, v8, v4}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 194
    const-string v0, "android.intent.extra.USE_FRONT_CAMERA"

    invoke-virtual {v7, v0, v4}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 195
    const-string v0, "camerafacing"

    invoke-virtual {v7, v0, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 196
    const-string v0, "previous_mode"

    invoke-virtual {v7, v0, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    goto :goto_0

    .line 198
    :cond_3
    invoke-virtual {v7, v8, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 201
    :goto_0
    invoke-virtual {p0}, Lcom/forge/live/CameraBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    invoke-virtual {v7, v0}, Landroid/content/Intent;->resolveActivity(Landroid/content/pm/PackageManager;)Landroid/content/ComponentName;

    move-result-object v0

    if-nez v0, :cond_4

    .line 202
    const-string v0, "No camera app available"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 203
    return-void

    .line 206
    :cond_4
    const-string v0, "captureResult"

    invoke-virtual {p0, p1, v7, v0}, Lcom/forge/live/CameraBridgePlugin;->startActivityForResult(Lcom/getcapacitor/PluginCall;Landroid/content/Intent;Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .line 210
    .end local v5    # "dir":Ljava/io/File;
    .end local v6    # "name":Ljava/lang/String;
    .end local v7    # "intent":Landroid/content/Intent;
    goto :goto_1

    .line 207
    :catch_0
    move-exception v0

    .line 208
    .local v0, "e":Ljava/lang/Exception;
    invoke-direct {p0}, Lcom/forge/live/CameraBridgePlugin;->cleanupPending()V

    .line 209
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "takePhoto failed: "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 211
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1
    return-void
.end method
