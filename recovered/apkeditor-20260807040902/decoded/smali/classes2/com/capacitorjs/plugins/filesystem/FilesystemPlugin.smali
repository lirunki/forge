.class public Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;
.super Lcom/getcapacitor/Plugin;
.source "FilesystemPlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "Filesystem"
    permissions = {
        .subannotation Lcom/getcapacitor/annotation/Permission;
            alias = "publicStorage"
            strings = {
                "android.permission.READ_EXTERNAL_STORAGE",
                "android.permission.WRITE_EXTERNAL_STORAGE"
            }
        .end subannotation
    }
.end annotation


# static fields
.field private static final PERMISSION_DENIED_ERROR:Ljava/lang/String; = "Unable to do file operation, user denied permission request"

.field static final PUBLIC_STORAGE:Ljava/lang/String; = "publicStorage"


# instance fields
.field private implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;


# direct methods
.method public static synthetic $r8$lambda$tJinBSNTGfJjWjnt9ILUoMFMeN8(Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;Lcom/getcapacitor/PluginCall;Ljava/lang/Integer;Ljava/lang/Integer;)V
    .locals 0

    invoke-direct {p0, p1, p2, p3}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->lambda$downloadFile$0(Lcom/getcapacitor/PluginCall;Ljava/lang/Integer;Ljava/lang/Integer;)V

    return-void
.end method

.method static bridge synthetic -$$Nest$misPublicDirectory(Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;Ljava/lang/String;)Z
    .locals 0

    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result p0

    return p0
.end method

.method public constructor <init>()V
    .locals 0

    .line 39
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    return-void
.end method

.method private _copy(Lcom/getcapacitor/PluginCall;Ljava/lang/Boolean;)V
    .locals 10
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "doRename"    # Ljava/lang/Boolean;

    .line 428
    const-string v0, "from"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 429
    .local v0, "from":Ljava/lang/String;
    const-string v1, "to"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    .line 430
    .local v7, "to":Ljava/lang/String;
    const-string v1, "directory"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    .line 431
    .local v8, "directory":Ljava/lang/String;
    const-string v1, "toDirectory"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    .line 433
    .local v9, "toDirectory":Ljava/lang/String;
    if-eqz v0, :cond_4

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_4

    if-eqz v7, :cond_4

    invoke-virtual {v7}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_0

    goto/16 :goto_2

    .line 437
    :cond_0
    invoke-direct {p0, v8}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_1

    invoke-direct {p0, v9}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_2

    .line 438
    :cond_1
    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v1

    if-nez v1, :cond_2

    .line 439
    const-string v1, "permissionCallback"

    invoke-virtual {p0, p1, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    .line 440
    return-void

    .line 444
    :cond_2
    :try_start_0
    iget-object v1, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {p2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v6

    move-object v2, v0

    move-object v3, v8

    move-object v4, v7

    move-object v5, v9

    invoke-virtual/range {v1 .. v6}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->copy(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Z)Ljava/io/File;

    move-result-object v1

    .line 445
    .local v1, "file":Ljava/io/File;
    invoke-virtual {p2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v2

    if-nez v2, :cond_3

    .line 446
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 447
    .local v2, "result":Lcom/getcapacitor/JSObject;
    const-string v3, "uri"

    invoke-static {v1}, Landroid/net/Uri;->fromFile(Ljava/io/File;)Landroid/net/Uri;

    move-result-object v4

    invoke-virtual {v4}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 448
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 449
    .end local v2    # "result":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 450
    :cond_3
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V
    :try_end_0
    .catch Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 454
    .end local v1    # "file":Ljava/io/File;
    :catch_0
    move-exception v1

    .line 455
    .local v1, "ex":Ljava/io/IOException;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Unable to perform action: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Ljava/io/IOException;->getLocalizedMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    goto :goto_1

    .line 452
    .end local v1    # "ex":Ljava/io/IOException;
    :catch_1
    move-exception v1

    .line 453
    .local v1, "ex":Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;
    invoke-virtual {v1}, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 456
    .end local v1    # "ex":Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;
    :goto_0
    nop

    .line 457
    :goto_1
    return-void

    .line 434
    :cond_4
    :goto_2
    const-string v1, "Both to and from must be provided"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 435
    return-void
.end method

.method private getDirectoryParameter(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 541
    const-string v0, "directory"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private isPublicDirectory(Ljava/lang/String;)Z
    .locals 1
    .param p1, "directory"    # Ljava/lang/String;

    .line 549
    const-string v0, "DOCUMENTS"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1

    const-string v0, "EXTERNAL_STORAGE"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    goto :goto_1

    :cond_1
    :goto_0
    const/4 v0, 0x1

    :goto_1
    return v0
.end method

.method private isStoragePermissionGranted()Z
    .locals 2

    .line 533
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-ge v0, v1, :cond_1

    const-string v0, "publicStorage"

    invoke-virtual {p0, v0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getPermissionState(Ljava/lang/String;)Lcom/getcapacitor/PermissionState;

    move-result-object v0

    sget-object v1, Lcom/getcapacitor/PermissionState;->GRANTED:Lcom/getcapacitor/PermissionState;

    if-ne v0, v1, :cond_0

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    goto :goto_1

    :cond_1
    :goto_0
    const/4 v0, 0x1

    :goto_1
    return v0
.end method

.method private synthetic lambda$downloadFile$0(Lcom/getcapacitor/PluginCall;Ljava/lang/Integer;Ljava/lang/Integer;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "bytes"    # Ljava/lang/Integer;
    .param p3, "contentLength"    # Ljava/lang/Integer;

    .line 395
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 396
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    const-string v1, "url"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 397
    const-string v1, "bytes"

    invoke-virtual {v0, v1, p2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 398
    const-string v1, "contentLength"

    invoke-virtual {v0, v1, p3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 399
    const-string v1, "progress"

    invoke-virtual {p0, v1, v0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->notifyListeners(Ljava/lang/String;Lcom/getcapacitor/JSObject;)V

    .line 400
    return-void
.end method

.method private permissionCallback(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/annotation/PermissionCallback;
    .end annotation

    .line 483
    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v0

    if-nez v0, :cond_0

    .line 484
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getLogTag()Ljava/lang/String;

    move-result-object v0

    const-string v1, "User denied storage permission"

    invoke-static {v0, v1}, Lcom/getcapacitor/Logger;->debug(Ljava/lang/String;Ljava/lang/String;)V

    .line 485
    const-string v0, "Unable to do file operation, user denied permission request"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 486
    return-void

    .line 489
    :cond_0
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getMethodName()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v1

    sparse-switch v1, :sswitch_data_0

    :cond_1
    goto/16 :goto_0

    :sswitch_0
    const-string v1, "deleteFile"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/4 v0, 0x2

    goto/16 :goto_1

    :sswitch_1
    const-string v1, "downloadFile"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/16 v0, 0xb

    goto/16 :goto_1

    :sswitch_2
    const-string v1, "readdir"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/16 v0, 0x8

    goto :goto_1

    :sswitch_3
    const-string v1, "rmdir"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/4 v0, 0x4

    goto :goto_1

    :sswitch_4
    const-string v1, "mkdir"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/4 v0, 0x3

    goto :goto_1

    :sswitch_5
    const-string v1, "stat"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/16 v0, 0xa

    goto :goto_1

    :sswitch_6
    const-string v1, "copy"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/4 v0, 0x6

    goto :goto_1

    :sswitch_7
    const-string v1, "readFile"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/4 v0, 0x7

    goto :goto_1

    :sswitch_8
    const-string v1, "rename"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/4 v0, 0x5

    goto :goto_1

    :sswitch_9
    const-string v1, "getUri"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/16 v0, 0x9

    goto :goto_1

    :sswitch_a
    const-string v1, "writeFile"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/4 v0, 0x1

    goto :goto_1

    :sswitch_b
    const-string v1, "appendFile"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const/4 v0, 0x0

    goto :goto_1

    :goto_0
    const/4 v0, -0x1

    :goto_1
    packed-switch v0, :pswitch_data_0

    goto :goto_2

    .line 522
    :pswitch_0
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->downloadFile(Lcom/getcapacitor/PluginCall;)V

    goto :goto_2

    .line 519
    :pswitch_1
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->stat(Lcom/getcapacitor/PluginCall;)V

    .line 520
    goto :goto_2

    .line 516
    :pswitch_2
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getUri(Lcom/getcapacitor/PluginCall;)V

    .line 517
    goto :goto_2

    .line 513
    :pswitch_3
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->readdir(Lcom/getcapacitor/PluginCall;)V

    .line 514
    goto :goto_2

    .line 510
    :pswitch_4
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->readFile(Lcom/getcapacitor/PluginCall;)V

    .line 511
    goto :goto_2

    .line 507
    :pswitch_5
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->copy(Lcom/getcapacitor/PluginCall;)V

    .line 508
    goto :goto_2

    .line 504
    :pswitch_6
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->rename(Lcom/getcapacitor/PluginCall;)V

    .line 505
    goto :goto_2

    .line 501
    :pswitch_7
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->rmdir(Lcom/getcapacitor/PluginCall;)V

    .line 502
    goto :goto_2

    .line 498
    :pswitch_8
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->mkdir(Lcom/getcapacitor/PluginCall;)V

    .line 499
    goto :goto_2

    .line 495
    :pswitch_9
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->deleteFile(Lcom/getcapacitor/PluginCall;)V

    .line 496
    goto :goto_2

    .line 492
    :pswitch_a
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->writeFile(Lcom/getcapacitor/PluginCall;)V

    .line 493
    nop

    .line 525
    :goto_2
    return-void

    :sswitch_data_0
    .sparse-switch
        -0x7f8ae44a -> :sswitch_b
        -0x53d94605 -> :sswitch_a
        -0x4a7789ca -> :sswitch_9
        -0x37b4c8c2 -> :sswitch_8
        -0x33bbf7ce -> :sswitch_7
        0x2eaf75 -> :sswitch_6
        0x360654 -> :sswitch_5
        0x6322a2f -> :sswitch_4
        0x6798872 -> :sswitch_3
        0x4065bb37 -> :sswitch_2
        0x4214ae24 -> :sswitch_1
        0x692721c7 -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_a
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method private saveFile(Lcom/getcapacitor/PluginCall;Ljava/io/File;Ljava/lang/String;)V
    .locals 7
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "file"    # Ljava/io/File;
    .param p3, "data"    # Ljava/lang/String;

    .line 151
    const-string v0, "encoding"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 152
    .local v0, "encoding":Ljava/lang/String;
    const/4 v1, 0x0

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    const-string v3, "append"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v2

    .line 154
    .local v2, "append":Z
    iget-object v3, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {v3, v0}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getEncoding(Ljava/lang/String;)Ljava/nio/charset/Charset;

    move-result-object v3

    .line 155
    .local v3, "charset":Ljava/nio/charset/Charset;
    if-eqz v0, :cond_0

    if-nez v3, :cond_0

    .line 156
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Unsupported encoding provided: "

    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 157
    return-void

    .line 161
    :cond_0
    :try_start_0
    iget-object v4, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v5

    invoke-virtual {v4, p2, p3, v3, v5}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->saveFile(Ljava/io/File;Ljava/lang/String;Ljava/nio/charset/Charset;Ljava/lang/Boolean;)V

    .line 163
    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getDirectoryParameter(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v4

    invoke-direct {p0, v4}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_1

    .line 164
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getContext()Landroid/content/Context;

    move-result-object v4

    const/4 v5, 0x1

    new-array v5, v5, [Ljava/lang/String;

    invoke-virtual {p2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v6

    aput-object v6, v5, v1

    const/4 v1, 0x0

    invoke-static {v4, v5, v1, v1}, Landroid/media/MediaScannerConnection;->scanFile(Landroid/content/Context;[Ljava/lang/String;[Ljava/lang/String;Landroid/media/MediaScannerConnection$OnScanCompletedListener;)V

    .line 166
    :cond_1
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getLogTag()Ljava/lang/String;

    move-result-object v1

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "File \'"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {p2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\' saved!"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v1, v4}, Lcom/getcapacitor/Logger;->debug(Ljava/lang/String;Ljava/lang/String;)V

    .line 167
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 168
    .local v1, "result":Lcom/getcapacitor/JSObject;
    const-string v4, "uri"

    invoke-static {p2}, Landroid/net/Uri;->fromFile(Ljava/io/File;)Landroid/net/Uri;

    move-result-object v5

    invoke-virtual {v5}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v1, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 169
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_0

    .end local v1    # "result":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 177
    :catch_0
    move-exception v1

    .line 178
    .local v1, "ex":Ljava/lang/IllegalArgumentException;
    const-string v4, "The supplied data is not valid base64 content."

    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    goto :goto_1

    .line 170
    .end local v1    # "ex":Ljava/lang/IllegalArgumentException;
    :catch_1
    move-exception v1

    .line 171
    .local v1, "ex":Ljava/io/IOException;
    nop

    .line 172
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getLogTag()Ljava/lang/String;

    move-result-object v4

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Creating file \'"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    .line 173
    invoke-virtual {p2}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "\' with charset \'"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "\' failed. Error: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v1}, Ljava/io/IOException;->getMessage()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    .line 171
    invoke-static {v4, v5, v1}, Lcom/getcapacitor/Logger;->error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 176
    const-string v4, "FILE_NOTCREATED"

    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 179
    .end local v1    # "ex":Ljava/io/IOException;
    :goto_0
    nop

    .line 180
    :goto_1
    return-void
.end method


# virtual methods
.method public appendFile(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 185
    :try_start_0
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v0

    const-string v1, "append"

    const/4 v2, 0x1

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->putOpt(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    :try_end_0
    .catch Lorg/json/JSONException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 186
    :catch_0
    move-exception v0

    :goto_0
    nop

    .line 188
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->writeFile(Lcom/getcapacitor/PluginCall;)V

    .line 189
    return-void
.end method

.method public checkPermissions(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 461
    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 462
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 463
    .local v0, "permissionsResultJSON":Lcom/getcapacitor/JSObject;
    const-string v1, "publicStorage"

    const-string v2, "granted"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 464
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 465
    .end local v0    # "permissionsResultJSON":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 466
    :cond_0
    invoke-super {p0, p1}, Lcom/getcapacitor/Plugin;->checkPermissions(Lcom/getcapacitor/PluginCall;)V

    .line 468
    :goto_0
    return-void
.end method

.method public copy(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 381
    const/4 v0, 0x0

    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    invoke-direct {p0, p1, v0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->_copy(Lcom/getcapacitor/PluginCall;Ljava/lang/Boolean;)V

    .line 382
    return-void
.end method

.method public deleteFile(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 193
    const-string v0, "path"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 194
    .local v0, "file":Ljava/lang/String;
    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getDirectoryParameter(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v1

    .line 195
    .local v1, "directory":Ljava/lang/String;
    invoke-direct {p0, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v2

    if-nez v2, :cond_0

    .line 196
    const-string v2, "permissionCallback"

    invoke-virtual {p0, p1, v2}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    goto :goto_1

    .line 199
    :cond_0
    :try_start_0
    iget-object v2, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {v2, v0, v1}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->deleteFile(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v2

    .line 200
    .local v2, "deleted":Z
    if-nez v2, :cond_1

    .line 201
    const-string v3, "Unable to delete file"

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    goto :goto_0

    .line 203
    :cond_1
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V
    :try_end_0
    .catch Ljava/io/FileNotFoundException; {:try_start_0 .. :try_end_0} :catch_0

    .line 207
    .end local v2    # "deleted":Z
    :goto_0
    goto :goto_1

    .line 205
    :catch_0
    move-exception v2

    .line 206
    .local v2, "ex":Ljava/io/FileNotFoundException;
    invoke-virtual {v2}, Ljava/io/FileNotFoundException;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 209
    .end local v2    # "ex":Ljava/io/FileNotFoundException;
    :goto_1
    return-void
.end method

.method public downloadFile(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 387
    :try_start_0
    const-string v0, "directory"

    sget-object v1, Landroid/os/Environment;->DIRECTORY_DOWNLOADS:Ljava/lang/String;

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 389
    .local v0, "directory":Ljava/lang/String;
    invoke-direct {p0, v0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v1

    if-nez v1, :cond_0

    .line 390
    const-string v1, "permissionCallback"

    invoke-virtual {p0, p1, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    .line 391
    return-void

    .line 394
    :cond_0
    new-instance v1, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$$ExternalSyntheticLambda0;

    invoke-direct {v1, p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$$ExternalSyntheticLambda0;-><init>(Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;Lcom/getcapacitor/PluginCall;)V

    .line 402
    .local v1, "emitter":Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;
    iget-object v2, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    iget-object v3, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->bridge:Lcom/getcapacitor/Bridge;

    new-instance v4, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;

    invoke-direct {v4, p0, v0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;-><init>(Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;Ljava/lang/String;Lcom/getcapacitor/PluginCall;)V

    invoke-virtual {v2, p1, v3, v1, v4}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->downloadFile(Lcom/getcapacitor/PluginCall;Lcom/getcapacitor/Bridge;Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 424
    .end local v0    # "directory":Ljava/lang/String;
    .end local v1    # "emitter":Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;
    goto :goto_0

    .line 422
    :catch_0
    move-exception v0

    .line 423
    .local v0, "ex":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Error downloading file: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getLocalizedMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 425
    .end local v0    # "ex":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method public getUri(Lcom/getcapacitor/PluginCall;)V
    .locals 6
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 320
    const-string v0, "path"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 321
    .local v0, "path":Ljava/lang/String;
    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getDirectoryParameter(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v1

    .line 323
    .local v1, "directory":Ljava/lang/String;
    iget-object v2, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {v2, v0, v1}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getFileObject(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;

    move-result-object v2

    .line 325
    .local v2, "fileObject":Ljava/io/File;
    invoke-direct {p0, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v3

    if-nez v3, :cond_0

    .line 326
    const-string v3, "permissionCallback"

    invoke-virtual {p0, p1, v3}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    goto :goto_0

    .line 328
    :cond_0
    new-instance v3, Lcom/getcapacitor/JSObject;

    invoke-direct {v3}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 329
    .local v3, "data":Lcom/getcapacitor/JSObject;
    invoke-static {v2}, Landroid/net/Uri;->fromFile(Ljava/io/File;)Landroid/net/Uri;

    move-result-object v4

    invoke-virtual {v4}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v4

    const-string v5, "uri"

    invoke-virtual {v3, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 330
    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 332
    .end local v3    # "data":Lcom/getcapacitor/JSObject;
    :goto_0
    return-void
.end method

.method public load()V
    .locals 2

    .line 46
    new-instance v0, Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-direct {v0, v1}, Lcom/capacitorjs/plugins/filesystem/Filesystem;-><init>(Landroid/content/Context;)V

    iput-object v0, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    .line 47
    return-void
.end method

.method public mkdir(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 213
    const-string v0, "path"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 214
    .local v0, "path":Ljava/lang/String;
    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getDirectoryParameter(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v1

    .line 215
    .local v1, "directory":Ljava/lang/String;
    const/4 v2, 0x0

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    const-string v3, "recursive"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v2

    .line 216
    .local v2, "recursive":Z
    invoke-direct {p0, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v3

    if-nez v3, :cond_0

    .line 217
    const-string v3, "permissionCallback"

    invoke-virtual {p0, p1, v3}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    goto :goto_1

    .line 220
    :cond_0
    :try_start_0
    iget-object v3, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v4

    invoke-virtual {v3, v0, v1, v4}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->mkdir(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Boolean;)Z

    move-result v3

    .line 221
    .local v3, "created":Z
    if-nez v3, :cond_1

    .line 222
    const-string v4, "Unable to create directory, unknown reason"

    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    goto :goto_0

    .line 224
    :cond_1
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V
    :try_end_0
    .catch Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryExistsException; {:try_start_0 .. :try_end_0} :catch_0

    .line 228
    .end local v3    # "created":Z
    :goto_0
    goto :goto_1

    .line 226
    :catch_0
    move-exception v3

    .line 227
    .local v3, "ex":Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryExistsException;
    invoke-virtual {v3}, Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryExistsException;->getMessage()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 230
    .end local v3    # "ex":Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryExistsException;
    :goto_1
    return-void
.end method

.method public readFile(Lcom/getcapacitor/PluginCall;)V
    .locals 7
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 53
    const-string v0, "path"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 54
    .local v0, "path":Ljava/lang/String;
    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getDirectoryParameter(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v1

    .line 55
    .local v1, "directory":Ljava/lang/String;
    const-string v2, "encoding"

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 57
    .local v2, "encoding":Ljava/lang/String;
    iget-object v3, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {v3, v2}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getEncoding(Ljava/lang/String;)Ljava/nio/charset/Charset;

    move-result-object v3

    .line 58
    .local v3, "charset":Ljava/nio/charset/Charset;
    if-eqz v2, :cond_0

    if-nez v3, :cond_0

    .line 59
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "Unsupported encoding provided: "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 60
    return-void

    .line 63
    :cond_0
    invoke-direct {p0, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_1

    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v4

    if-nez v4, :cond_1

    .line 64
    const-string v4, "permissionCallback"

    invoke-virtual {p0, p1, v4}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    goto :goto_1

    .line 67
    :cond_1
    :try_start_0
    iget-object v4, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {v4, v0, v1, v3}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->readFile(Ljava/lang/String;Ljava/lang/String;Ljava/nio/charset/Charset;)Ljava/lang/String;

    move-result-object v4

    .line 68
    .local v4, "dataStr":Ljava/lang/String;
    new-instance v5, Lcom/getcapacitor/JSObject;

    invoke-direct {v5}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 69
    .local v5, "ret":Lcom/getcapacitor/JSObject;
    const-string v6, "data"

    invoke-virtual {v5, v6, v4}, Lcom/getcapacitor/JSObject;->putOpt(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 70
    invoke-virtual {p1, v5}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/io/FileNotFoundException; {:try_start_0 .. :try_end_0} :catch_2
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Lorg/json/JSONException; {:try_start_0 .. :try_end_0} :catch_0

    .end local v4    # "dataStr":Ljava/lang/String;
    .end local v5    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 75
    :catch_0
    move-exception v4

    .line 76
    .local v4, "ex":Lorg/json/JSONException;
    const-string v5, "Unable to return value for reading file"

    invoke-virtual {p1, v5, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    goto :goto_1

    .line 73
    .end local v4    # "ex":Lorg/json/JSONException;
    :catch_1
    move-exception v4

    .line 74
    .local v4, "ex":Ljava/io/IOException;
    const-string v5, "Unable to read file"

    invoke-virtual {p1, v5, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .end local v4    # "ex":Ljava/io/IOException;
    goto :goto_0

    .line 71
    :catch_2
    move-exception v4

    .line 72
    .local v4, "ex":Ljava/io/FileNotFoundException;
    const-string v5, "File does not exist"

    invoke-virtual {p1, v5, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 77
    .end local v4    # "ex":Ljava/io/FileNotFoundException;
    :goto_0
    nop

    .line 79
    :goto_1
    return-void
.end method

.method public readdir(Lcom/getcapacitor/PluginCall;)V
    .locals 14
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 270
    const-string v0, "path"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 271
    .local v0, "path":Ljava/lang/String;
    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getDirectoryParameter(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v1

    .line 273
    .local v1, "directory":Ljava/lang/String;
    invoke-direct {p0, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v2

    if-nez v2, :cond_0

    .line 274
    const-string v2, "permissionCallback"

    invoke-virtual {p0, p1, v2}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    goto/16 :goto_5

    .line 277
    :cond_0
    :try_start_0
    iget-object v2, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {v2, v0, v1}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->readdir(Ljava/lang/String;Ljava/lang/String;)[Ljava/io/File;

    move-result-object v2

    .line 278
    .local v2, "files":[Ljava/io/File;
    new-instance v3, Lcom/getcapacitor/JSArray;

    invoke-direct {v3}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 279
    .local v3, "filesArray":Lcom/getcapacitor/JSArray;
    if-eqz v2, :cond_5

    .line 280
    const/4 v4, 0x0

    .local v4, "i":I
    :goto_0
    array-length v5, v2

    if-ge v4, v5, :cond_4

    .line 281
    aget-object v5, v2, v4

    .line 282
    .local v5, "fileObject":Ljava/io/File;
    new-instance v6, Lcom/getcapacitor/JSObject;

    invoke-direct {v6}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 283
    .local v6, "data":Lcom/getcapacitor/JSObject;
    const-string v7, "name"

    invoke-virtual {v5}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 284
    const-string v7, "type"

    invoke-virtual {v5}, Ljava/io/File;->isDirectory()Z

    move-result v8

    if-eqz v8, :cond_1

    const-string v8, "directory"

    goto :goto_1

    :cond_1
    const-string v8, "file"

    :goto_1
    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 285
    const-string v7, "size"

    invoke-virtual {v5}, Ljava/io/File;->length()J

    move-result-wide v8

    invoke-virtual {v6, v7, v8, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 286
    const-string v7, "mtime"

    invoke-virtual {v5}, Ljava/io/File;->lastModified()J

    move-result-wide v8

    invoke-virtual {v6, v7, v8, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 287
    const-string v7, "uri"

    invoke-static {v5}, Landroid/net/Uri;->fromFile(Ljava/io/File;)Landroid/net/Uri;

    move-result-object v8

    invoke-virtual {v8}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 289
    sget v7, Landroid/os/Build$VERSION;->SDK_INT:I
    :try_end_0
    .catch Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryNotFoundException; {:try_start_0 .. :try_end_0} :catch_1

    const/16 v8, 0x1a

    const-string v9, "ctime"

    if-lt v7, v8, :cond_3

    .line 291
    :try_start_1
    invoke-virtual {v5}, Ljava/io/File;->toPath()Ljava/nio/file/Path;

    move-result-object v7

    const-class v8, Ljava/nio/file/attribute/BasicFileAttributes;

    const/4 v10, 0x0

    new-array v10, v10, [Ljava/nio/file/LinkOption;

    invoke-static {v7, v8, v10}, Ljava/nio/file/Files;->readAttributes(Ljava/nio/file/Path;Ljava/lang/Class;[Ljava/nio/file/LinkOption;)Ljava/nio/file/attribute/BasicFileAttributes;

    move-result-object v7

    .line 294
    .local v7, "attr":Ljava/nio/file/attribute/BasicFileAttributes;
    invoke-interface {v7}, Ljava/nio/file/attribute/BasicFileAttributes;->creationTime()Ljava/nio/file/attribute/FileTime;

    move-result-object v8

    invoke-virtual {v8}, Ljava/nio/file/attribute/FileTime;->toMillis()J

    move-result-wide v10

    invoke-interface {v7}, Ljava/nio/file/attribute/BasicFileAttributes;->lastAccessTime()Ljava/nio/file/attribute/FileTime;

    move-result-object v8

    invoke-virtual {v8}, Ljava/nio/file/attribute/FileTime;->toMillis()J

    move-result-wide v12

    cmp-long v8, v10, v12

    if-gez v8, :cond_2

    .line 295
    invoke-interface {v7}, Ljava/nio/file/attribute/BasicFileAttributes;->creationTime()Ljava/nio/file/attribute/FileTime;

    move-result-object v8

    invoke-virtual {v8}, Ljava/nio/file/attribute/FileTime;->toMillis()J

    move-result-wide v10

    invoke-virtual {v6, v9, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    goto :goto_2

    .line 297
    :cond_2
    invoke-interface {v7}, Ljava/nio/file/attribute/BasicFileAttributes;->lastAccessTime()Ljava/nio/file/attribute/FileTime;

    move-result-object v8

    invoke-virtual {v8}, Ljava/nio/file/attribute/FileTime;->toMillis()J

    move-result-wide v10

    invoke-virtual {v6, v9, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catch Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryNotFoundException; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_2

    .line 299
    .end local v7    # "attr":Ljava/nio/file/attribute/BasicFileAttributes;
    :catch_0
    move-exception v7

    :goto_2
    goto :goto_3

    .line 301
    :cond_3
    const/4 v7, 0x0

    :try_start_2
    invoke-virtual {v6, v9, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 303
    :goto_3
    invoke-virtual {v3, v6}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 280
    nop

    .end local v5    # "fileObject":Ljava/io/File;
    .end local v6    # "data":Lcom/getcapacitor/JSObject;
    add-int/lit8 v4, v4, 0x1

    goto/16 :goto_0

    .line 306
    .end local v4    # "i":I
    :cond_4
    new-instance v4, Lcom/getcapacitor/JSObject;

    invoke-direct {v4}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 307
    .local v4, "ret":Lcom/getcapacitor/JSObject;
    const-string v5, "files"

    invoke-virtual {v4, v5, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 308
    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 309
    .end local v4    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_4

    .line 310
    :cond_5
    const-string v4, "Unable to read directory"

    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V
    :try_end_2
    .catch Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryNotFoundException; {:try_start_2 .. :try_end_2} :catch_1

    .line 314
    .end local v2    # "files":[Ljava/io/File;
    .end local v3    # "filesArray":Lcom/getcapacitor/JSArray;
    :goto_4
    goto :goto_5

    .line 312
    :catch_1
    move-exception v2

    .line 313
    .local v2, "ex":Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryNotFoundException;
    invoke-virtual {v2}, Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryNotFoundException;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 316
    .end local v2    # "ex":Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryNotFoundException;
    :goto_5
    return-void
.end method

.method public rename(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 376
    const/4 v0, 0x1

    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    invoke-direct {p0, p1, v0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->_copy(Lcom/getcapacitor/PluginCall;Ljava/lang/Boolean;)V

    .line 377
    return-void
.end method

.method public requestPermissions(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 472
    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 473
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 474
    .local v0, "permissionsResultJSON":Lcom/getcapacitor/JSObject;
    const-string v1, "publicStorage"

    const-string v2, "granted"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 475
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 476
    .end local v0    # "permissionsResultJSON":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 477
    :cond_0
    invoke-super {p0, p1}, Lcom/getcapacitor/Plugin;->requestPermissions(Lcom/getcapacitor/PluginCall;)V

    .line 479
    :goto_0
    return-void
.end method

.method public rmdir(Lcom/getcapacitor/PluginCall;)V
    .locals 6
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 234
    const-string v0, "path"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 235
    .local v0, "path":Ljava/lang/String;
    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getDirectoryParameter(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v1

    .line 236
    .local v1, "directory":Ljava/lang/String;
    const/4 v2, 0x0

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    const-string v3, "recursive"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v2

    .line 238
    .local v2, "recursive":Ljava/lang/Boolean;
    iget-object v3, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {v3, v0, v1}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getFileObject(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;

    move-result-object v3

    .line 240
    .local v3, "fileObject":Ljava/io/File;
    invoke-direct {p0, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_0

    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v4

    if-nez v4, :cond_0

    .line 241
    const-string v4, "permissionCallback"

    invoke-virtual {p0, p1, v4}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    goto :goto_1

    .line 243
    :cond_0
    invoke-virtual {v3}, Ljava/io/File;->exists()Z

    move-result v4

    if-nez v4, :cond_1

    .line 244
    const-string v4, "Directory does not exist"

    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 245
    return-void

    .line 248
    :cond_1
    invoke-virtual {v3}, Ljava/io/File;->isDirectory()Z

    move-result v4

    if-eqz v4, :cond_2

    invoke-virtual {v3}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object v4

    array-length v4, v4

    if-eqz v4, :cond_2

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v4

    if-nez v4, :cond_2

    .line 249
    const-string v4, "Directory is not empty"

    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 250
    return-void

    .line 253
    :cond_2
    const/4 v4, 0x0

    .line 256
    .local v4, "deleted":Z
    :try_start_0
    iget-object v5, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {v5, v3}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->deleteRecursively(Ljava/io/File;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 257
    const/4 v4, 0x1

    goto :goto_0

    .line 258
    :catch_0
    move-exception v5

    :goto_0
    nop

    .line 260
    if-nez v4, :cond_3

    .line 261
    const-string v5, "Unable to delete directory, unknown reason"

    invoke-virtual {p1, v5}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    goto :goto_1

    .line 263
    :cond_3
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V

    .line 266
    .end local v4    # "deleted":Z
    :goto_1
    return-void
.end method

.method public stat(Lcom/getcapacitor/PluginCall;)V
    .locals 11
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 336
    const-string v0, "path"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 337
    .local v0, "path":Ljava/lang/String;
    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getDirectoryParameter(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v1

    .line 339
    .local v1, "directory":Ljava/lang/String;
    iget-object v2, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {v2, v0, v1}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getFileObject(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;

    move-result-object v2

    .line 341
    .local v2, "fileObject":Ljava/io/File;
    invoke-direct {p0, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v3

    if-nez v3, :cond_0

    .line 342
    const-string v3, "permissionCallback"

    invoke-virtual {p0, p1, v3}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    goto/16 :goto_3

    .line 344
    :cond_0
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    move-result v3

    if-nez v3, :cond_1

    .line 345
    const-string v3, "File does not exist"

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 346
    return-void

    .line 349
    :cond_1
    new-instance v3, Lcom/getcapacitor/JSObject;

    invoke-direct {v3}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 350
    .local v3, "data":Lcom/getcapacitor/JSObject;
    invoke-virtual {v2}, Ljava/io/File;->isDirectory()Z

    move-result v4

    if-eqz v4, :cond_2

    const-string v4, "directory"

    goto :goto_0

    :cond_2
    const-string v4, "file"

    :goto_0
    const-string v5, "type"

    invoke-virtual {v3, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 351
    const-string v4, "size"

    invoke-virtual {v2}, Ljava/io/File;->length()J

    move-result-wide v5

    invoke-virtual {v3, v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 352
    const-string v4, "mtime"

    invoke-virtual {v2}, Ljava/io/File;->lastModified()J

    move-result-wide v5

    invoke-virtual {v3, v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 353
    invoke-static {v2}, Landroid/net/Uri;->fromFile(Ljava/io/File;)Landroid/net/Uri;

    move-result-object v4

    invoke-virtual {v4}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v4

    const-string v5, "uri"

    invoke-virtual {v3, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 355
    sget v4, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v5, 0x1a

    const-string v6, "ctime"

    if-lt v4, v5, :cond_4

    .line 357
    :try_start_0
    invoke-virtual {v2}, Ljava/io/File;->toPath()Ljava/nio/file/Path;

    move-result-object v4

    const-class v5, Ljava/nio/file/attribute/BasicFileAttributes;

    const/4 v7, 0x0

    new-array v7, v7, [Ljava/nio/file/LinkOption;

    invoke-static {v4, v5, v7}, Ljava/nio/file/Files;->readAttributes(Ljava/nio/file/Path;Ljava/lang/Class;[Ljava/nio/file/LinkOption;)Ljava/nio/file/attribute/BasicFileAttributes;

    move-result-object v4

    .line 360
    .local v4, "attr":Ljava/nio/file/attribute/BasicFileAttributes;
    invoke-interface {v4}, Ljava/nio/file/attribute/BasicFileAttributes;->creationTime()Ljava/nio/file/attribute/FileTime;

    move-result-object v5

    invoke-virtual {v5}, Ljava/nio/file/attribute/FileTime;->toMillis()J

    move-result-wide v7

    invoke-interface {v4}, Ljava/nio/file/attribute/BasicFileAttributes;->lastAccessTime()Ljava/nio/file/attribute/FileTime;

    move-result-object v5

    invoke-virtual {v5}, Ljava/nio/file/attribute/FileTime;->toMillis()J

    move-result-wide v9

    cmp-long v5, v7, v9

    if-gez v5, :cond_3

    .line 361
    invoke-interface {v4}, Ljava/nio/file/attribute/BasicFileAttributes;->creationTime()Ljava/nio/file/attribute/FileTime;

    move-result-object v5

    invoke-virtual {v5}, Ljava/nio/file/attribute/FileTime;->toMillis()J

    move-result-wide v7

    invoke-virtual {v3, v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    goto :goto_1

    .line 363
    :cond_3
    invoke-interface {v4}, Ljava/nio/file/attribute/BasicFileAttributes;->lastAccessTime()Ljava/nio/file/attribute/FileTime;

    move-result-object v5

    invoke-virtual {v5}, Ljava/nio/file/attribute/FileTime;->toMillis()J

    move-result-wide v7

    invoke-virtual {v3, v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    .line 365
    .end local v4    # "attr":Ljava/nio/file/attribute/BasicFileAttributes;
    :catch_0
    move-exception v4

    :goto_1
    goto :goto_2

    .line 367
    :cond_4
    const/4 v4, 0x0

    invoke-virtual {v3, v6, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 370
    :goto_2
    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 372
    .end local v3    # "data":Lcom/getcapacitor/JSObject;
    :goto_3
    return-void
.end method

.method public writeFile(Lcom/getcapacitor/PluginCall;)V
    .locals 9
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 83
    const-string v0, "path"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 84
    .local v0, "path":Ljava/lang/String;
    const-string v1, "data"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 85
    .local v1, "data":Ljava/lang/String;
    const/4 v2, 0x0

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    const-string v3, "recursive"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v2

    .line 87
    .local v2, "recursive":Ljava/lang/Boolean;
    const/4 v3, 0x0

    if-nez v0, :cond_0

    .line 88
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getLogTag()Ljava/lang/String;

    move-result-object v4

    const-string v5, "No path or filename retrieved from call"

    invoke-static {v4, v5, v3}, Lcom/getcapacitor/Logger;->error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 89
    const-string v3, "NO_PATH"

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 90
    return-void

    .line 93
    :cond_0
    if-nez v1, :cond_1

    .line 94
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getLogTag()Ljava/lang/String;

    move-result-object v4

    const-string v5, "No data retrieved from call"

    invoke-static {v4, v5, v3}, Lcom/getcapacitor/Logger;->error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 95
    const-string v3, "NO_DATA"

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 96
    return-void

    .line 99
    :cond_1
    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getDirectoryParameter(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v4

    .line 100
    .local v4, "directory":Ljava/lang/String;
    const-string v5, "Parent folder doesn\'t exist"

    const-string v6, "permissionCallback"

    if-eqz v4, :cond_8

    .line 101
    invoke-direct {p0, v4}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isPublicDirectory(Ljava/lang/String;)Z

    move-result v7

    if-eqz v7, :cond_2

    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v7

    if-nez v7, :cond_2

    .line 102
    invoke-virtual {p0, p1, v6}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    goto/16 :goto_7

    .line 105
    :cond_2
    iget-object v6, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->implementation:Lcom/capacitorjs/plugins/filesystem/Filesystem;

    invoke-virtual {v6, v4}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getDirectory(Ljava/lang/String;)Ljava/io/File;

    move-result-object v6

    .line 106
    .local v6, "androidDir":Ljava/io/File;
    if-eqz v6, :cond_7

    .line 107
    invoke-virtual {v6}, Ljava/io/File;->exists()Z

    move-result v7

    if-nez v7, :cond_4

    invoke-virtual {v6}, Ljava/io/File;->mkdirs()Z

    move-result v7

    if-eqz v7, :cond_3

    goto :goto_0

    .line 116
    :cond_3
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getLogTag()Ljava/lang/String;

    move-result-object v5

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "Not able to create \'"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, "\'!"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v5, v7, v3}, Lcom/getcapacitor/Logger;->error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 117
    const-string v3, "NOT_CREATED_DIR"

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    goto :goto_3

    .line 109
    :cond_4
    :goto_0
    new-instance v3, Ljava/io/File;

    invoke-direct {v3, v6, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 110
    .local v3, "fileObject":Ljava/io/File;
    invoke-virtual {v3}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v7

    invoke-virtual {v7}, Ljava/io/File;->exists()Z

    move-result v7

    if-nez v7, :cond_6

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v7

    if-eqz v7, :cond_5

    invoke-virtual {v3}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v7

    invoke-virtual {v7}, Ljava/io/File;->mkdirs()Z

    move-result v7

    if-eqz v7, :cond_5

    goto :goto_1

    .line 113
    :cond_5
    invoke-virtual {p1, v5}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    goto :goto_2

    .line 111
    :cond_6
    :goto_1
    invoke-direct {p0, p1, v3, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->saveFile(Lcom/getcapacitor/PluginCall;Ljava/io/File;Ljava/lang/String;)V

    .line 115
    .end local v3    # "fileObject":Ljava/io/File;
    :goto_2
    goto :goto_3

    .line 120
    :cond_7
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getLogTag()Ljava/lang/String;

    move-result-object v5

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "Directory ID \'"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, "\' is not supported by plugin"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v5, v7, v3}, Lcom/getcapacitor/Logger;->error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    .line 121
    const-string v3, "INVALID_DIR"

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 123
    .end local v6    # "androidDir":Ljava/io/File;
    :goto_3
    goto/16 :goto_7

    .line 126
    :cond_8
    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v3

    .line 127
    .local v3, "u":Landroid/net/Uri;
    invoke-virtual {v3}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v7

    if-eqz v7, :cond_a

    invoke-virtual {v3}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v7

    const-string v8, "file"

    invoke-virtual {v7, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_9

    goto :goto_4

    .line 145
    :cond_9
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v3}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, " scheme not supported"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {p1, v5}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    goto :goto_7

    .line 128
    :cond_a
    :goto_4
    new-instance v7, Ljava/io/File;

    invoke-virtual {v3}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v8

    invoke-direct {v7, v8}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 131
    .local v7, "fileObject":Ljava/io/File;
    invoke-direct {p0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->isStoragePermissionGranted()Z

    move-result v8

    if-nez v8, :cond_b

    .line 132
    invoke-virtual {p0, p1, v6}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->requestAllPermissions(Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    goto :goto_6

    .line 134
    :cond_b
    nop

    .line 135
    invoke-virtual {v7}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v6

    if-eqz v6, :cond_d

    .line 136
    invoke-virtual {v7}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v6

    invoke-virtual {v6}, Ljava/io/File;->exists()Z

    move-result v6

    if-nez v6, :cond_d

    .line 137
    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v6

    if-eqz v6, :cond_c

    invoke-virtual {v7}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v6

    invoke-virtual {v6}, Ljava/io/File;->mkdirs()Z

    move-result v6

    if-eqz v6, :cond_c

    goto :goto_5

    .line 141
    :cond_c
    invoke-virtual {p1, v5}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    goto :goto_6

    .line 139
    :cond_d
    :goto_5
    invoke-direct {p0, p1, v7, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->saveFile(Lcom/getcapacitor/PluginCall;Ljava/io/File;Ljava/lang/String;)V

    .line 144
    .end local v7    # "fileObject":Ljava/io/File;
    :goto_6
    nop

    .line 148
    .end local v3    # "u":Landroid/net/Uri;
    :goto_7
    return-void
.end method
