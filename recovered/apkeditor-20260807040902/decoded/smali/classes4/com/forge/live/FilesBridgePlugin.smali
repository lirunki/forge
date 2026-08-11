.class public Lcom/forge/live/FilesBridgePlugin;
.super Lcom/getcapacitor/Plugin;
.source "FilesBridgePlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "FilesBridge"
.end annotation


# static fields
.field private static final DEFAULT_MAX_BYTES:J = 0x1900000L

.field private static final HARD_MAX_BYTES:J = 0x2800000L

.field private static final INLINE_BASE64_MAX:J = 0x15e000L


# instance fields
.field private pendingMaxBytes:J

.field private pendingMultiple:Z


# direct methods
.method public constructor <init>()V
    .locals 2

    .line 39
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    .line 46
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/forge/live/FilesBridgePlugin;->pendingMultiple:Z

    .line 47
    const-wide/32 v0, 0x1900000

    iput-wide v0, p0, Lcom/forge/live/FilesBridgePlugin;->pendingMaxBytes:J

    return-void
.end method

.method private callMaxBytes(Lcom/getcapacitor/PluginCall;)J
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 196
    const-string v0, "_forgeMaxBytes"

    :try_start_0
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v1

    if-eqz v1, :cond_1

    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v1

    invoke-virtual {v1, v0}, Lcom/getcapacitor/JSObject;->has(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 197
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v1

    invoke-virtual {v1, v0}, Lcom/getcapacitor/JSObject;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    .line 198
    .local v0, "v":Ljava/lang/Object;
    instance-of v1, v0, Ljava/lang/Number;

    if-eqz v1, :cond_0

    move-object v1, v0

    check-cast v1, Ljava/lang/Number;

    invoke-virtual {v1}, Ljava/lang/Number;->longValue()J

    move-result-wide v1

    return-wide v1

    .line 199
    :cond_0
    if-eqz v0, :cond_1

    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Ljava/lang/Double;->parseDouble(Ljava/lang/String;)D

    move-result-wide v1
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    double-to-long v1, v1

    return-wide v1

    .line 201
    .end local v0    # "v":Ljava/lang/Object;
    :catch_0
    move-exception v0

    :cond_1
    nop

    .line 202
    iget-wide v0, p0, Lcom/forge/live/FilesBridgePlugin;->pendingMaxBytes:J

    const-wide/16 v2, 0x0

    cmp-long v4, v0, v2

    if-lez v4, :cond_2

    goto :goto_0

    :cond_2
    const-wide/32 v0, 0x1900000

    :goto_0
    return-wide v0
.end method

.method private callMultiple(Lcom/getcapacitor/PluginCall;)Z
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 185
    const-string v0, "_forgeMultiple"

    :try_start_0
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v1

    if-eqz v1, :cond_1

    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v1

    invoke-virtual {v1, v0}, Lcom/getcapacitor/JSObject;->has(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 186
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v1

    invoke-virtual {v1, v0}, Lcom/getcapacitor/JSObject;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    .line 187
    .local v0, "v":Ljava/lang/Object;
    instance-of v1, v0, Ljava/lang/Boolean;

    if-eqz v1, :cond_0

    move-object v1, v0

    check-cast v1, Ljava/lang/Boolean;

    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1

    return v1

    .line 188
    :cond_0
    if-eqz v0, :cond_1

    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Ljava/lang/Boolean;->parseBoolean(Ljava/lang/String;)Z

    move-result v1
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return v1

    .line 190
    .end local v0    # "v":Ljava/lang/Object;
    :catch_0
    move-exception v0

    :cond_1
    nop

    .line 191
    iget-boolean v0, p0, Lcom/forge/live/FilesBridgePlugin;->pendingMultiple:Z

    return v0
.end method

.method private static cancelObj()Lcom/getcapacitor/JSObject;
    .locals 3

    .line 292
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 293
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "cancelled"

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 294
    new-instance v1, Lcom/getcapacitor/JSArray;

    invoke-direct {v1}, Lcom/getcapacitor/JSArray;-><init>()V

    const-string v2, "files"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 295
    const-string v1, "count"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 296
    return-object v0
.end method

.method private static guessMimeFromName(Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    .param p0, "name"    # Ljava/lang/String;

    .line 394
    invoke-virtual {p0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v0

    .line 395
    .local v0, "n":Ljava/lang/String;
    const-string v1, ".html"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_c

    const-string v1, ".htm"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    goto/16 :goto_1

    .line 396
    :cond_0
    const-string v1, ".json"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_1

    const-string v1, "application/json"

    return-object v1

    .line 397
    :cond_1
    const-string v1, ".txt"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_2

    const-string v1, "text/plain"

    return-object v1

    .line 398
    :cond_2
    const-string v1, ".pdf"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_3

    const-string v1, "application/pdf"

    return-object v1

    .line 399
    :cond_3
    const-string v1, ".png"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_4

    const-string v1, "image/png"

    return-object v1

    .line 400
    :cond_4
    const-string v1, ".jpg"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_b

    const-string v1, ".jpeg"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_5

    goto :goto_0

    .line 401
    :cond_5
    const-string v1, ".gif"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_6

    const-string v1, "image/gif"

    return-object v1

    .line 402
    :cond_6
    const-string v1, ".webp"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_7

    const-string v1, "image/webp"

    return-object v1

    .line 403
    :cond_7
    const-string v1, ".svg"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_8

    const-string v1, "image/svg+xml"

    return-object v1

    .line 404
    :cond_8
    const-string v1, ".wav"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_9

    const-string v1, "audio/wav"

    return-object v1

    .line 405
    :cond_9
    const-string v1, ".mp3"

    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_a

    const-string v1, "audio/mpeg"

    return-object v1

    .line 406
    :cond_a
    const-string v1, "application/octet-stream"

    return-object v1

    .line 400
    :cond_b
    :goto_0
    const-string v1, "image/jpeg"

    return-object v1

    .line 395
    :cond_c
    :goto_1
    const-string v1, "text/html"

    return-object v1
.end method

.method private static parseAccept(Ljava/lang/String;)[Ljava/lang/String;
    .locals 11
    .param p0, "accept"    # Ljava/lang/String;

    .line 431
    const-string v0, "*/*"

    if-eqz p0, :cond_6

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_0

    goto/16 :goto_5

    .line 432
    :cond_0
    const-string v1, ","

    invoke-virtual {p0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v1

    .line 433
    .local v1, "parts":[Ljava/lang/String;
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    .line 434
    .local v2, "out":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/String;>;"
    array-length v3, v1

    const/4 v4, 0x0

    const/4 v5, 0x0

    :goto_0
    if-ge v5, v3, :cond_4

    aget-object v6, v1, v5

    .line 435
    .local v6, "p":Ljava/lang/String;
    invoke-virtual {v6}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v7

    .line 436
    .local v7, "t":Ljava/lang/String;
    invoke-virtual {v7}, Ljava/lang/String;->isEmpty()Z

    move-result v8

    if-eqz v8, :cond_1

    goto/16 :goto_4

    .line 437
    :cond_1
    const-string v8, "."

    invoke-virtual {v7, v8}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v8

    if-eqz v8, :cond_3

    .line 438
    const/4 v8, 0x1

    invoke-virtual {v7, v8}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v9

    .line 439
    .local v9, "ext":Ljava/lang/String;
    invoke-virtual {v9}, Ljava/lang/String;->hashCode()I

    move-result v10

    sparse-switch v10, :sswitch_data_0

    :cond_2
    goto/16 :goto_1

    :sswitch_0
    const-string v8, "webp"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_2

    const/4 v8, 0x5

    goto/16 :goto_2

    :sswitch_1
    const-string v8, "json"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_2

    const/16 v8, 0x8

    goto :goto_2

    :sswitch_2
    const-string v8, "jpeg"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_2

    const/4 v8, 0x3

    goto :goto_2

    :sswitch_3
    const-string v8, "html"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_2

    const/16 v8, 0x9

    goto :goto_2

    :sswitch_4
    const-string v8, "txt"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_2

    const/4 v8, 0x6

    goto :goto_2

    :sswitch_5
    const-string v10, "png"

    invoke-virtual {v9, v10}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v10

    if-eqz v10, :cond_2

    goto :goto_2

    :sswitch_6
    const-string v8, "pdf"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_2

    const/4 v8, 0x0

    goto :goto_2

    :sswitch_7
    const-string v8, "jpg"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_2

    const/4 v8, 0x2

    goto :goto_2

    :sswitch_8
    const-string v8, "htm"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_2

    const/16 v8, 0xa

    goto :goto_2

    :sswitch_9
    const-string v8, "gif"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_2

    const/4 v8, 0x4

    goto :goto_2

    :sswitch_a
    const-string v8, "csv"

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_2

    const/4 v8, 0x7

    goto :goto_2

    :goto_1
    const/4 v8, -0x1

    :goto_2
    packed-switch v8, :pswitch_data_0

    .line 451
    invoke-virtual {v2, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_3

    .line 450
    :pswitch_0
    const-string v8, "text/html"

    invoke-virtual {v2, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_3

    .line 448
    :pswitch_1
    const-string v8, "application/json"

    invoke-virtual {v2, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_3

    .line 447
    :pswitch_2
    const-string v8, "text/csv"

    invoke-virtual {v2, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_3

    .line 446
    :pswitch_3
    const-string v8, "text/plain"

    invoke-virtual {v2, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_3

    .line 445
    :pswitch_4
    const-string v8, "image/webp"

    invoke-virtual {v2, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_3

    .line 444
    :pswitch_5
    const-string v8, "image/gif"

    invoke-virtual {v2, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_3

    .line 443
    :pswitch_6
    const-string v8, "image/jpeg"

    invoke-virtual {v2, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_3

    .line 441
    :pswitch_7
    const-string v8, "image/png"

    invoke-virtual {v2, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_3

    .line 440
    :pswitch_8
    const-string v8, "application/pdf"

    invoke-virtual {v2, v8}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 453
    .end local v9    # "ext":Ljava/lang/String;
    :goto_3
    goto :goto_4

    .line 454
    :cond_3
    invoke-virtual {v2, v7}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 434
    .end local v6    # "p":Ljava/lang/String;
    .end local v7    # "t":Ljava/lang/String;
    :goto_4
    add-int/lit8 v5, v5, 0x1

    goto/16 :goto_0

    .line 457
    :cond_4
    invoke-virtual {v2}, Ljava/util/ArrayList;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_5

    invoke-virtual {v2, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 458
    :cond_5
    new-array v0, v4, [Ljava/lang/String;

    invoke-virtual {v2, v0}, Ljava/util/ArrayList;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Ljava/lang/String;

    return-object v0

    .line 431
    .end local v1    # "parts":[Ljava/lang/String;
    .end local v2    # "out":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/String;>;"
    :cond_6
    :goto_5
    filled-new-array {v0}, [Ljava/lang/String;

    move-result-object v0

    return-object v0

    nop

    :sswitch_data_0
    .sparse-switch
        0x18206 -> :sswitch_a
        0x18fc4 -> :sswitch_9
        0x194e1 -> :sswitch_8
        0x19be1 -> :sswitch_7
        0x1b0f2 -> :sswitch_6
        0x1b229 -> :sswitch_5
        0x1c270 -> :sswitch_4
        0x3107ab -> :sswitch_3
        0x31e068 -> :sswitch_2
        0x31ece8 -> :sswitch_1
        0x379f9c -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
        :pswitch_0
    .end packed-switch
.end method

.method private pickResult(Lcom/getcapacitor/PluginCall;Landroidx/activity/result/ActivityResult;)V
    .locals 16
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "result"    # Landroidx/activity/result/ActivityResult;
    .annotation runtime Lcom/getcapacitor/annotation/ActivityCallback;
    .end annotation

    .line 207
    move-object/from16 v1, p1

    const-string v2, "FilesBridge"

    if-nez v1, :cond_0

    .line 208
    const-string v0, "pickResult called with null call (keepAlive probably failed)"

    invoke-static {v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 209
    return-void

    .line 211
    :cond_0
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "pickResult received, resultCode="

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual/range {p2 .. p2}, Landroidx/activity/result/ActivityResult;->getResultCode()I

    move-result v3

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, " data="

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    .line 212
    invoke-virtual/range {p2 .. p2}, Landroidx/activity/result/ActivityResult;->getData()Landroid/content/Intent;

    move-result-object v3

    if-eqz v3, :cond_1

    const-string v3, "yes"

    goto :goto_0

    :cond_1
    const-string v3, "no"

    :goto_0
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 211
    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 213
    invoke-virtual/range {p2 .. p2}, Landroidx/activity/result/ActivityResult;->getData()Landroid/content/Intent;

    move-result-object v0

    const/4 v3, 0x0

    if-eqz v0, :cond_3

    .line 214
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "  uri="

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual/range {p2 .. p2}, Landroidx/activity/result/ActivityResult;->getData()Landroid/content/Intent;

    move-result-object v4

    invoke-virtual {v4}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v4

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v4, " clipCount="

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    .line 215
    invoke-virtual/range {p2 .. p2}, Landroidx/activity/result/ActivityResult;->getData()Landroid/content/Intent;

    move-result-object v4

    invoke-virtual {v4}, Landroid/content/Intent;->getClipData()Landroid/content/ClipData;

    move-result-object v4

    if-eqz v4, :cond_2

    invoke-virtual/range {p2 .. p2}, Landroidx/activity/result/ActivityResult;->getData()Landroid/content/Intent;

    move-result-object v4

    invoke-virtual {v4}, Landroid/content/Intent;->getClipData()Landroid/content/ClipData;

    move-result-object v4

    invoke-virtual {v4}, Landroid/content/ClipData;->getItemCount()I

    move-result v4

    goto :goto_1

    :cond_2
    const/4 v4, 0x0

    :goto_1
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 214
    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 217
    :cond_3
    invoke-direct/range {p0 .. p1}, Lcom/forge/live/FilesBridgePlugin;->callMultiple(Lcom/getcapacitor/PluginCall;)Z

    move-result v4

    .line 218
    .local v4, "multiple":Z
    invoke-direct/range {p0 .. p1}, Lcom/forge/live/FilesBridgePlugin;->callMaxBytes(Lcom/getcapacitor/PluginCall;)J

    move-result-wide v5

    .line 220
    .local v5, "maxBytes":J
    :try_start_0
    invoke-virtual/range {p2 .. p2}, Landroidx/activity/result/ActivityResult;->getResultCode()I

    move-result v0

    const/4 v7, -0x1

    if-eq v0, v7, :cond_4

    .line 221
    const-string v0, "user cancelled or no selection"

    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 222
    invoke-static {}, Lcom/forge/live/FilesBridgePlugin;->cancelObj()Lcom/getcapacitor/JSObject;

    move-result-object v0

    .line 223
    .local v0, "o":Lcom/getcapacitor/JSObject;
    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 224
    return-void

    .line 227
    .end local v0    # "o":Lcom/getcapacitor/JSObject;
    :cond_4
    invoke-virtual/range {p2 .. p2}, Landroidx/activity/result/ActivityResult;->getData()Landroid/content/Intent;

    move-result-object v0

    move-object v7, v0

    .line 228
    .local v7, "data":Landroid/content/Intent;
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    move-object v8, v0

    .line 229
    .local v8, "uris":Ljava/util/List;, "Ljava/util/List<Landroid/net/Uri;>;"
    if-eqz v7, :cond_8

    .line 230
    invoke-virtual {v7}, Landroid/content/Intent;->getClipData()Landroid/content/ClipData;

    move-result-object v0

    .line 231
    .local v0, "clip":Landroid/content/ClipData;
    if-eqz v0, :cond_7

    invoke-virtual {v0}, Landroid/content/ClipData;->getItemCount()I

    move-result v9

    if-lez v9, :cond_7

    .line 232
    const/4 v9, 0x0

    .local v9, "i":I
    :goto_2
    invoke-virtual {v0}, Landroid/content/ClipData;->getItemCount()I

    move-result v10

    if-ge v9, v10, :cond_6

    .line 233
    invoke-virtual {v0, v9}, Landroid/content/ClipData;->getItemAt(I)Landroid/content/ClipData$Item;

    move-result-object v10

    invoke-virtual {v10}, Landroid/content/ClipData$Item;->getUri()Landroid/net/Uri;

    move-result-object v10

    .line 234
    .local v10, "u":Landroid/net/Uri;
    if-eqz v10, :cond_5

    invoke-interface {v8, v10}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 232
    .end local v10    # "u":Landroid/net/Uri;
    :cond_5
    add-int/lit8 v9, v9, 0x1

    goto :goto_2

    .end local v9    # "i":I
    :cond_6
    goto :goto_3

    .line 236
    :cond_7
    invoke-virtual {v7}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v9

    if-eqz v9, :cond_8

    .line 237
    invoke-virtual {v7}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v9

    invoke-interface {v8, v9}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 241
    .end local v0    # "clip":Landroid/content/ClipData;
    :cond_8
    :goto_3
    invoke-interface {v8}, Ljava/util/List;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_9

    .line 242
    invoke-static {}, Lcom/forge/live/FilesBridgePlugin;->cancelObj()Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 243
    return-void

    .line 246
    :cond_9
    new-instance v0, Lcom/getcapacitor/JSArray;

    invoke-direct {v0}, Lcom/getcapacitor/JSArray;-><init>()V

    move-object v9, v0

    .line 247
    .local v9, "okFiles":Lcom/getcapacitor/JSArray;
    const/4 v0, 0x0

    .line 248
    .local v0, "first":Lcom/getcapacitor/JSObject;
    const/4 v10, 0x0

    .line 249
    .local v10, "lastErr":Ljava/lang/String;
    invoke-interface {v8}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v11

    move-object v12, v10

    move-object v10, v0

    .end local v0    # "first":Lcom/getcapacitor/JSObject;
    .local v10, "first":Lcom/getcapacitor/JSObject;
    .local v12, "lastErr":Ljava/lang/String;
    :goto_4
    invoke-interface {v11}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_b

    invoke-interface {v11}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/net/Uri;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_3

    move-object v13, v0

    .line 252
    .local v13, "uri":Landroid/net/Uri;
    :try_start_1
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/FilesBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    const/4 v14, 0x1

    invoke-virtual {v0, v13, v14}, Landroid/content/ContentResolver;->takePersistableUriPermission(Landroid/net/Uri;I)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_5

    .line 254
    :catch_0
    move-exception v0

    :goto_5
    nop

    .line 256
    move-object/from16 v14, p0

    :try_start_2
    invoke-direct {v14, v13, v5, v6}, Lcom/forge/live/FilesBridgePlugin;->readUri(Landroid/net/Uri;J)Lcom/getcapacitor/JSObject;

    move-result-object v0

    .line 257
    .local v0, "file":Lcom/getcapacitor/JSObject;
    if-nez v10, :cond_a

    move-object v10, v0

    .line 258
    :cond_a
    invoke-virtual {v9, v0}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    .line 261
    .end local v0    # "file":Lcom/getcapacitor/JSObject;
    goto :goto_6

    .line 259
    :catch_1
    move-exception v0

    .line 260
    .local v0, "ex":Ljava/lang/Exception;
    :try_start_3
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v15

    move-object v12, v15

    .line 262
    .end local v0    # "ex":Ljava/lang/Exception;
    .end local v13    # "uri":Landroid/net/Uri;
    :goto_6
    goto :goto_4

    .line 264
    :cond_b
    move-object/from16 v14, p0

    invoke-virtual {v9}, Lcom/getcapacitor/JSArray;->length()I

    move-result v0

    if-nez v0, :cond_d

    .line 265
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "No readable files after processing URIs, lastErr="

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 266
    if-eqz v12, :cond_c

    move-object v0, v12

    goto :goto_7

    :cond_c
    const-string v0, "Could not read selected file(s)"

    :goto_7
    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_2

    .line 267
    return-void

    .line 270
    :cond_d
    const-string v0, "cancelled"

    if-eqz v4, :cond_e

    .line 271
    :try_start_4
    new-instance v11, Lcom/getcapacitor/JSObject;

    invoke-direct {v11}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 272
    .local v11, "o":Lcom/getcapacitor/JSObject;
    const-string v13, "files"

    invoke-virtual {v11, v13, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 273
    invoke-virtual {v11, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 274
    const-string v0, "count"

    invoke-virtual {v9}, Lcom/getcapacitor/JSArray;->length()I

    move-result v3

    invoke-virtual {v11, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 275
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "resolving multiple, count="

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v9}, Lcom/getcapacitor/JSArray;->length()I

    move-result v3

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 276
    invoke-virtual {v1, v11}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 277
    .end local v11    # "o":Lcom/getcapacitor/JSObject;
    goto :goto_8

    .line 278
    :cond_e
    if-nez v10, :cond_f

    .line 279
    const-string v0, "Failed to read file"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 280
    return-void

    .line 282
    :cond_f
    invoke-virtual {v10, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 283
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "resolving single file: "

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, "name"

    invoke-virtual {v10, v3}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, " size="

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, "size"

    invoke-virtual {v10, v3}, Lcom/getcapacitor/JSObject;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, " inline="

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, "inline"

    invoke-virtual {v10, v3}, Lcom/getcapacitor/JSObject;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 284
    invoke-virtual {v1, v10}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_2

    .line 288
    .end local v7    # "data":Landroid/content/Intent;
    .end local v8    # "uris":Ljava/util/List;, "Ljava/util/List<Landroid/net/Uri;>;"
    .end local v9    # "okFiles":Lcom/getcapacitor/JSArray;
    .end local v10    # "first":Lcom/getcapacitor/JSObject;
    .end local v12    # "lastErr":Ljava/lang/String;
    :goto_8
    goto :goto_a

    .line 286
    :catch_2
    move-exception v0

    goto :goto_9

    :catch_3
    move-exception v0

    move-object/from16 v14, p0

    .line 287
    .local v0, "e":Ljava/lang/Exception;
    :goto_9
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "pickResult failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 289
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_a
    return-void
.end method

.method private queryDisplayName(Landroid/net/Uri;)Ljava/lang/String;
    .locals 7
    .param p1, "uri"    # Landroid/net/Uri;

    .line 410
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/FilesBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    const/4 v6, 0x0

    move-object v2, p1

    invoke-virtual/range {v1 .. v6}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 411
    .local v0, "c":Landroid/database/Cursor;
    if-eqz v0, :cond_2

    :try_start_1
    invoke-interface {v0}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v1

    if-eqz v1, :cond_2

    .line 412
    const-string v1, "_display_name"

    invoke-interface {v0, v1}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I

    move-result v1

    .line 413
    .local v1, "idx":I
    if-ltz v1, :cond_2

    invoke-interface {v0, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v2
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 415
    if-eqz v0, :cond_0

    :try_start_2
    invoke-interface {v0}, Landroid/database/Cursor;->close()V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    .line 413
    :cond_0
    return-object v2

    .line 410
    .end local v1    # "idx":I
    :catchall_0
    move-exception v1

    if-eqz v0, :cond_1

    :try_start_3
    invoke-interface {v0}, Landroid/database/Cursor;->close()V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v2

    :try_start_4
    invoke-virtual {v1, v2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .end local p1    # "uri":Landroid/net/Uri;
    :cond_1
    :goto_0
    throw v1

    .line 415
    .restart local p1    # "uri":Landroid/net/Uri;
    :cond_2
    if-eqz v0, :cond_3

    invoke-interface {v0}, Landroid/database/Cursor;->close()V
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_0

    goto :goto_1

    .end local v0    # "c":Landroid/database/Cursor;
    :catch_0
    move-exception v0

    .line 416
    :cond_3
    :goto_1
    invoke-virtual {p1}, Landroid/net/Uri;->getLastPathSegment()Ljava/lang/String;

    move-result-object v0

    .line 417
    .local v0, "last":Ljava/lang/String;
    if-eqz v0, :cond_4

    move-object v1, v0

    goto :goto_2

    :cond_4
    const-string v1, "file"

    :goto_2
    return-object v1
.end method

.method private querySize(Landroid/net/Uri;)J
    .locals 7
    .param p1, "uri"    # Landroid/net/Uri;

    .line 421
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/FilesBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    const/4 v6, 0x0

    move-object v2, p1

    invoke-virtual/range {v1 .. v6}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 422
    .local v0, "c":Landroid/database/Cursor;
    if-eqz v0, :cond_2

    :try_start_1
    invoke-interface {v0}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v1

    if-eqz v1, :cond_2

    .line 423
    const-string v1, "_size"

    invoke-interface {v0, v1}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I

    move-result v1

    .line 424
    .local v1, "idx":I
    if-ltz v1, :cond_2

    invoke-interface {v0, v1}, Landroid/database/Cursor;->isNull(I)Z

    move-result v2

    if-nez v2, :cond_2

    invoke-interface {v0, v1}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v2
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 426
    if-eqz v0, :cond_0

    :try_start_2
    invoke-interface {v0}, Landroid/database/Cursor;->close()V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    .line 424
    :cond_0
    return-wide v2

    .line 421
    .end local v1    # "idx":I
    :catchall_0
    move-exception v1

    if-eqz v0, :cond_1

    :try_start_3
    invoke-interface {v0}, Landroid/database/Cursor;->close()V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v2

    :try_start_4
    invoke-virtual {v1, v2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .end local p1    # "uri":Landroid/net/Uri;
    :cond_1
    :goto_0
    throw v1

    .line 426
    .restart local p1    # "uri":Landroid/net/Uri;
    :cond_2
    if-eqz v0, :cond_3

    invoke-interface {v0}, Landroid/database/Cursor;->close()V
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_0

    goto :goto_1

    .end local v0    # "c":Landroid/database/Cursor;
    :catch_0
    move-exception v0

    .line 427
    :cond_3
    :goto_1
    const-wide/16 v0, -0x1

    return-wide v0
.end method

.method private static readFileBytes(Ljava/io/File;J)[B
    .locals 6
    .param p0, "f"    # Ljava/io/File;
    .param p1, "max"    # J
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 379
    invoke-virtual {p0}, Ljava/io/File;->length()J

    move-result-wide v0

    .line 380
    .local v0, "len":J
    cmp-long v2, v0, p1

    if-gtz v2, :cond_2

    .line 381
    long-to-int v2, v0

    new-array v2, v2, [B

    .line 382
    .local v2, "data":[B
    new-instance v3, Ljava/io/FileInputStream;

    invoke-direct {v3, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 383
    .local v3, "in":Ljava/io/FileInputStream;
    const/4 v4, 0x0

    .line 384
    .local v4, "off":I
    :goto_0
    :try_start_0
    array-length v5, v2

    if-ge v4, v5, :cond_1

    .line 385
    array-length v5, v2

    sub-int/2addr v5, v4

    invoke-virtual {v3, v2, v4, v5}, Ljava/io/FileInputStream;->read([BII)I

    move-result v5
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 386
    .local v5, "n":I
    if-gez v5, :cond_0

    goto :goto_1

    .line 387
    :cond_0
    add-int/2addr v4, v5

    .line 388
    .end local v5    # "n":I
    goto :goto_0

    .line 389
    .end local v4    # "off":I
    :cond_1
    :goto_1
    invoke-virtual {v3}, Ljava/io/FileInputStream;->close()V

    .line 390
    .end local v3    # "in":Ljava/io/FileInputStream;
    return-object v2

    .line 382
    .restart local v3    # "in":Ljava/io/FileInputStream;
    :catchall_0
    move-exception v4

    :try_start_1
    invoke-virtual {v3}, Ljava/io/FileInputStream;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_2

    :catchall_1
    move-exception v5

    invoke-virtual {v4, v5}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_2
    throw v4

    .line 380
    .end local v2    # "data":[B
    .end local v3    # "in":Ljava/io/FileInputStream;
    :cond_2
    new-instance v2, Ljava/lang/Exception;

    const-string v3, "File too large"

    invoke-direct {v2, v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v2
.end method

.method private readUri(Landroid/net/Uri;J)Lcom/getcapacitor/JSObject;
    .locals 20
    .param p1, "uri"    # Landroid/net/Uri;
    .param p2, "maxBytes"    # J
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 300
    move-object/from16 v1, p1

    move-wide/from16 v2, p2

    invoke-direct/range {p0 .. p1}, Lcom/forge/live/FilesBridgePlugin;->queryDisplayName(Landroid/net/Uri;)Ljava/lang/String;

    move-result-object v0

    .line 301
    .local v0, "name":Ljava/lang/String;
    if-eqz v0, :cond_0

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-eqz v4, :cond_1

    :cond_0
    const-string v0, "file"

    .line 303
    :cond_1
    const-string v4, "[\\\\/:*?\"<>|]"

    const-string v5, "_"

    invoke-virtual {v0, v4, v5}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    .line 305
    .end local v0    # "name":Ljava/lang/String;
    .local v4, "name":Ljava/lang/String;
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/FilesBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    invoke-virtual {v0, v1}, Landroid/content/ContentResolver;->getType(Landroid/net/Uri;)Ljava/lang/String;

    move-result-object v0

    .line 306
    .local v0, "mime":Ljava/lang/String;
    if-eqz v0, :cond_3

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v6

    if-eqz v6, :cond_2

    goto :goto_0

    :cond_2
    move-object v6, v0

    goto :goto_1

    .line 307
    :cond_3
    :goto_0
    invoke-static {v4}, Lcom/forge/live/FilesBridgePlugin;->guessMimeFromName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    move-object v6, v0

    .line 310
    .end local v0    # "mime":Ljava/lang/String;
    .local v6, "mime":Ljava/lang/String;
    :goto_1
    invoke-direct/range {p0 .. p1}, Lcom/forge/live/FilesBridgePlugin;->querySize(Landroid/net/Uri;)J

    move-result-wide v7

    .line 311
    .local v7, "declared":J
    cmp-long v0, v7, v2

    if-gtz v0, :cond_c

    .line 315
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/FilesBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    invoke-virtual {v0, v1}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;

    move-result-object v9

    .line 316
    .local v9, "in":Ljava/io/InputStream;
    if-eqz v9, :cond_b

    .line 319
    new-instance v0, Ljava/io/File;

    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/FilesBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v10

    invoke-virtual {v10}, Landroid/content/Context;->getCacheDir()Ljava/io/File;

    move-result-object v10

    const-string v11, "forge_picks"

    invoke-direct {v0, v10, v11}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    move-object v10, v0

    .line 320
    .local v10, "dir":Ljava/io/File;
    invoke-virtual {v10}, Ljava/io/File;->exists()Z

    move-result v0

    if-nez v0, :cond_4

    invoke-virtual {v10}, Ljava/io/File;->mkdirs()Z

    move-result v0

    if-nez v0, :cond_4

    .line 322
    invoke-virtual {v10}, Ljava/io/File;->exists()Z

    move-result v0

    if-nez v0, :cond_4

    invoke-virtual {v10}, Ljava/io/File;->mkdirs()Z

    .line 324
    :cond_4
    invoke-virtual {v10}, Ljava/io/File;->exists()Z

    move-result v0

    if-eqz v0, :cond_a

    invoke-virtual {v10}, Ljava/io/File;->isDirectory()Z

    move-result v0

    if-eqz v0, :cond_a

    .line 328
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v11

    invoke-virtual {v11}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v11

    const-string v12, "-"

    const-string v13, ""

    invoke-virtual {v11, v12, v13}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v11

    const/16 v12, 0xc

    const/4 v13, 0x0

    invoke-virtual {v11, v13, v12}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v0, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    .line 329
    .local v5, "safe":Ljava/lang/String;
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, v10, v5}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    move-object v11, v0

    .line 331
    .local v11, "out":Ljava/io/File;
    const-wide/16 v14, 0x0

    .line 332
    .local v14, "total":J
    move-object v12, v9

    .local v12, "input":Ljava/io/InputStream;
    :try_start_0
    new-instance v0, Ljava/io/FileOutputStream;

    invoke-direct {v0, v11}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_6

    move-object/from16 v16, v0

    .line 333
    .local v16, "fos":Ljava/io/FileOutputStream;
    const/16 v0, 0x4000

    :try_start_1
    new-array v0, v0, [B

    move-object/from16 v17, v0

    .line 335
    .local v17, "buf":[B
    :goto_2
    move-object/from16 v13, v17

    .end local v17    # "buf":[B
    .local v13, "buf":[B
    invoke-virtual {v12, v13}, Ljava/io/InputStream;->read([B)I

    move-result v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_3

    move/from16 v17, v0

    .local v17, "n":I
    if-ltz v0, :cond_6

    .line 336
    move-wide/from16 v18, v7

    move/from16 v1, v17

    .end local v7    # "declared":J
    .end local v17    # "n":I
    .local v1, "n":I
    .local v18, "declared":J
    int-to-long v7, v1

    add-long/2addr v14, v7

    .line 337
    cmp-long v0, v14, v2

    if-gtz v0, :cond_5

    .line 341
    move-object/from16 v7, v16

    const/4 v8, 0x0

    .end local v16    # "fos":Ljava/io/FileOutputStream;
    .local v7, "fos":Ljava/io/FileOutputStream;
    :try_start_2
    invoke-virtual {v7, v13, v8, v1}, Ljava/io/FileOutputStream;->write([BII)V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    move-object/from16 v1, p1

    move-object/from16 v16, v7

    move-object/from16 v17, v13

    move-wide/from16 v7, v18

    const/4 v13, 0x0

    goto :goto_2

    .line 332
    .end local v1    # "n":I
    .end local v13    # "buf":[B
    :catchall_0
    move-exception v0

    move-object v1, v0

    move-object/from16 v16, v4

    goto/16 :goto_6

    .line 338
    .end local v7    # "fos":Ljava/io/FileOutputStream;
    .restart local v1    # "n":I
    .restart local v13    # "buf":[B
    .restart local v16    # "fos":Ljava/io/FileOutputStream;
    :cond_5
    move-object/from16 v7, v16

    .end local v16    # "fos":Ljava/io/FileOutputStream;
    .restart local v7    # "fos":Ljava/io/FileOutputStream;
    :try_start_3
    invoke-virtual {v11}, Ljava/io/File;->delete()Z
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_0
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    goto :goto_3

    :catch_0
    move-exception v0

    .line 339
    :goto_3
    :try_start_4
    new-instance v0, Ljava/lang/Exception;

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    move/from16 v16, v1

    .end local v1    # "n":I
    .local v16, "n":I
    const-string v1, "File too large while reading. Max "

    invoke-virtual {v8, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v8, " bytes"

    invoke-virtual {v1, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    .end local v4    # "name":Ljava/lang/String;
    .end local v5    # "safe":Ljava/lang/String;
    .end local v6    # "mime":Ljava/lang/String;
    .end local v7    # "fos":Ljava/io/FileOutputStream;
    .end local v9    # "in":Ljava/io/InputStream;
    .end local v10    # "dir":Ljava/io/File;
    .end local v11    # "out":Ljava/io/File;
    .end local v12    # "input":Ljava/io/InputStream;
    .end local v14    # "total":J
    .end local v18    # "declared":J
    .end local p1    # "uri":Landroid/net/Uri;
    .end local p2    # "maxBytes":J
    throw v0
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_0

    .line 343
    .restart local v4    # "name":Ljava/lang/String;
    .restart local v5    # "safe":Ljava/lang/String;
    .restart local v6    # "mime":Ljava/lang/String;
    .local v7, "declared":J
    .restart local v9    # "in":Ljava/io/InputStream;
    .restart local v10    # "dir":Ljava/io/File;
    .restart local v11    # "out":Ljava/io/File;
    .restart local v12    # "input":Ljava/io/InputStream;
    .restart local v14    # "total":J
    .local v16, "fos":Ljava/io/FileOutputStream;
    .restart local v17    # "n":I
    .restart local p1    # "uri":Landroid/net/Uri;
    .restart local p2    # "maxBytes":J
    :cond_6
    move-wide/from16 v18, v7

    move-object/from16 v7, v16

    move/from16 v16, v17

    .end local v17    # "n":I
    .local v7, "fos":Ljava/io/FileOutputStream;
    .local v16, "n":I
    .restart local v18    # "declared":J
    :try_start_5
    invoke-virtual {v7}, Ljava/io/FileOutputStream;->flush()V
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_2

    .line 344
    .end local v13    # "buf":[B
    .end local v16    # "n":I
    :try_start_6
    invoke-virtual {v7}, Ljava/io/FileOutputStream;->close()V
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_1

    .end local v7    # "fos":Ljava/io/FileOutputStream;
    if-eqz v12, :cond_7

    invoke-virtual {v12}, Ljava/io/InputStream;->close()V

    .line 346
    .end local v12    # "input":Ljava/io/InputStream;
    :cond_7
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    move-object v1, v0

    .line 347
    .local v1, "o":Lcom/getcapacitor/JSObject;
    const-string v0, "name"

    invoke-virtual {v1, v0, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 348
    const-string v0, "type"

    invoke-virtual {v1, v0, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 349
    const-string v0, "mime"

    invoke-virtual {v1, v0, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 350
    const-string v0, "size"

    invoke-virtual {v1, v0, v14, v15}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 351
    const-string v0, "path"

    invoke-virtual {v11}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v1, v0, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 352
    const-string v0, "uri"

    invoke-virtual/range {p1 .. p1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v1, v0, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 354
    nop

    .line 355
    :try_start_7
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/FilesBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    .line 356
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/FilesBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v8

    invoke-virtual {v8}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ".fileprovider"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    .line 354
    invoke-static {v0, v7, v11}, Landroidx/core/content/FileProvider;->getUriForFile(Landroid/content/Context;Ljava/lang/String;Ljava/io/File;)Landroid/net/Uri;

    move-result-object v0

    .line 359
    .local v0, "content":Landroid/net/Uri;
    const-string v7, "contentUri"

    invoke-virtual {v0}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v1, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_7} :catch_1

    .line 360
    nop

    .end local v0    # "content":Landroid/net/Uri;
    goto :goto_4

    :catch_1
    move-exception v0

    .line 363
    :goto_4
    const-wide/16 v7, 0x0

    const-string v0, "dataUrl"

    const-string v12, "base64"

    const-string v13, "inline"

    cmp-long v16, v14, v7

    if-lez v16, :cond_8

    const-wide/32 v7, 0x15e000

    cmp-long v16, v14, v7

    if-gtz v16, :cond_8

    .line 364
    invoke-static {v11, v7, v8}, Lcom/forge/live/FilesBridgePlugin;->readFileBytes(Ljava/io/File;J)[B

    move-result-object v7

    .line 365
    .local v7, "bytes":[B
    const/4 v8, 0x2

    invoke-static {v7, v8}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;

    move-result-object v8

    .line 366
    .local v8, "b64":Ljava/lang/String;
    invoke-virtual {v1, v12, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 367
    new-instance v12, Ljava/lang/StringBuilder;

    invoke-direct {v12}, Ljava/lang/StringBuilder;-><init>()V

    move-object/from16 v16, v4

    .end local v4    # "name":Ljava/lang/String;
    .local v16, "name":Ljava/lang/String;
    const-string v4, "data:"

    invoke-virtual {v12, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v12, ";base64,"

    invoke-virtual {v4, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v1, v0, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 368
    const/4 v0, 0x1

    invoke-virtual {v1, v13, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 369
    .end local v7    # "bytes":[B
    .end local v8    # "b64":Ljava/lang/String;
    goto :goto_5

    .line 363
    .end local v16    # "name":Ljava/lang/String;
    .restart local v4    # "name":Ljava/lang/String;
    :cond_8
    move-object/from16 v16, v4

    .line 370
    .end local v4    # "name":Ljava/lang/String;
    .restart local v16    # "name":Ljava/lang/String;
    const/4 v4, 0x0

    invoke-virtual {v1, v13, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 371
    const/4 v4, 0x0

    invoke-virtual {v1, v12, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 372
    invoke-virtual {v1, v0, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 373
    const-string v0, "note"

    const-string v4, "File staged on disk; use path/readStaged for content"

    invoke-virtual {v1, v0, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 375
    :goto_5
    return-object v1

    .line 332
    .end local v1    # "o":Lcom/getcapacitor/JSObject;
    .end local v16    # "name":Ljava/lang/String;
    .restart local v4    # "name":Ljava/lang/String;
    .restart local v12    # "input":Ljava/io/InputStream;
    :catchall_1
    move-exception v0

    move-object/from16 v16, v4

    move-object v1, v0

    .end local v4    # "name":Ljava/lang/String;
    .restart local v16    # "name":Ljava/lang/String;
    goto :goto_8

    .end local v16    # "name":Ljava/lang/String;
    .restart local v4    # "name":Ljava/lang/String;
    .local v7, "fos":Ljava/io/FileOutputStream;
    :catchall_2
    move-exception v0

    move-object/from16 v16, v4

    move-object v1, v0

    .end local v4    # "name":Ljava/lang/String;
    .restart local v16    # "name":Ljava/lang/String;
    goto :goto_6

    .end local v18    # "declared":J
    .restart local v4    # "name":Ljava/lang/String;
    .local v7, "declared":J
    .local v16, "fos":Ljava/io/FileOutputStream;
    :catchall_3
    move-exception v0

    move-wide/from16 v18, v7

    move-object/from16 v7, v16

    move-object/from16 v16, v4

    move-object v1, v0

    .end local v4    # "name":Ljava/lang/String;
    .local v7, "fos":Ljava/io/FileOutputStream;
    .local v16, "name":Ljava/lang/String;
    .restart local v18    # "declared":J
    :goto_6
    :try_start_8
    invoke-virtual {v7}, Ljava/io/FileOutputStream;->close()V
    :try_end_8
    .catchall {:try_start_8 .. :try_end_8} :catchall_4

    goto :goto_7

    :catchall_4
    move-exception v0

    move-object v4, v0

    :try_start_9
    invoke-virtual {v1, v4}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .end local v5    # "safe":Ljava/lang/String;
    .end local v6    # "mime":Ljava/lang/String;
    .end local v9    # "in":Ljava/io/InputStream;
    .end local v10    # "dir":Ljava/io/File;
    .end local v11    # "out":Ljava/io/File;
    .end local v12    # "input":Ljava/io/InputStream;
    .end local v14    # "total":J
    .end local v16    # "name":Ljava/lang/String;
    .end local v18    # "declared":J
    .end local p1    # "uri":Landroid/net/Uri;
    .end local p2    # "maxBytes":J
    :goto_7
    throw v1
    :try_end_9
    .catchall {:try_start_9 .. :try_end_9} :catchall_5

    .end local v7    # "fos":Ljava/io/FileOutputStream;
    .restart local v5    # "safe":Ljava/lang/String;
    .restart local v6    # "mime":Ljava/lang/String;
    .restart local v9    # "in":Ljava/io/InputStream;
    .restart local v10    # "dir":Ljava/io/File;
    .restart local v11    # "out":Ljava/io/File;
    .restart local v12    # "input":Ljava/io/InputStream;
    .restart local v14    # "total":J
    .restart local v16    # "name":Ljava/lang/String;
    .restart local v18    # "declared":J
    .restart local p1    # "uri":Landroid/net/Uri;
    .restart local p2    # "maxBytes":J
    :catchall_5
    move-exception v0

    move-object v1, v0

    goto :goto_8

    .end local v16    # "name":Ljava/lang/String;
    .end local v18    # "declared":J
    .restart local v4    # "name":Ljava/lang/String;
    .local v7, "declared":J
    :catchall_6
    move-exception v0

    move-object/from16 v16, v4

    move-wide/from16 v18, v7

    move-object v1, v0

    .end local v4    # "name":Ljava/lang/String;
    .end local v7    # "declared":J
    .restart local v16    # "name":Ljava/lang/String;
    .restart local v18    # "declared":J
    :goto_8
    if-eqz v12, :cond_9

    :try_start_a
    invoke-virtual {v12}, Ljava/io/InputStream;->close()V
    :try_end_a
    .catchall {:try_start_a .. :try_end_a} :catchall_7

    goto :goto_9

    :catchall_7
    move-exception v0

    move-object v4, v0

    invoke-virtual {v1, v4}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_9
    :goto_9
    throw v1

    .line 324
    .end local v5    # "safe":Ljava/lang/String;
    .end local v11    # "out":Ljava/io/File;
    .end local v12    # "input":Ljava/io/InputStream;
    .end local v14    # "total":J
    .end local v16    # "name":Ljava/lang/String;
    .end local v18    # "declared":J
    .restart local v4    # "name":Ljava/lang/String;
    .restart local v7    # "declared":J
    :cond_a
    move-object/from16 v16, v4

    move-wide/from16 v18, v7

    .line 325
    .end local v4    # "name":Ljava/lang/String;
    .end local v7    # "declared":J
    .restart local v16    # "name":Ljava/lang/String;
    .restart local v18    # "declared":J
    invoke-virtual {v9}, Ljava/io/InputStream;->close()V

    .line 326
    new-instance v0, Ljava/lang/Exception;

    const-string v1, "Cannot create forge_picks cache dir"

    invoke-direct {v0, v1}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v0

    .line 316
    .end local v10    # "dir":Ljava/io/File;
    .end local v16    # "name":Ljava/lang/String;
    .end local v18    # "declared":J
    .restart local v4    # "name":Ljava/lang/String;
    .restart local v7    # "declared":J
    :cond_b
    new-instance v0, Ljava/lang/Exception;

    const-string v1, "Cannot open file"

    invoke-direct {v0, v1}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v0

    .line 312
    .end local v9    # "in":Ljava/io/InputStream;
    :cond_c
    move-object/from16 v16, v4

    move-wide/from16 v18, v7

    .end local v4    # "name":Ljava/lang/String;
    .end local v7    # "declared":J
    .restart local v16    # "name":Ljava/lang/String;
    .restart local v18    # "declared":J
    new-instance v0, Ljava/lang/Exception;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "File too large ("

    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    move-wide/from16 v4, v18

    .end local v18    # "declared":J
    .local v4, "declared":J
    invoke-virtual {v1, v4, v5}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v7, " bytes). Max "

    invoke-virtual {v1, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v0
.end method


# virtual methods
.method public isAvailable(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 51
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 52
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "available"

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 53
    const-string v1, "native"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 54
    const-string v1, "maxBytes"

    const-wide/32 v2, 0x1900000

    invoke-virtual {v0, v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 55
    const-string v1, "inlineMaxBytes"

    const-wide/32 v2, 0x15e000

    invoke-virtual {v0, v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 56
    const-string v1, "note"

    const-string v2, "System document picker; large files returned via cache path"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 57
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 58
    return-void
.end method

.method public pick(Lcom/getcapacitor/PluginCall;)V
    .locals 14
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 119
    const-string v0, "pickResult"

    const-string v1, "android.intent.extra.ALLOW_MULTIPLE"

    const-string v2, "android.intent.category.OPENABLE"

    const-string v3, "maxBytes"

    const/4 v4, 0x1

    invoke-static {v4}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v5

    invoke-virtual {p1, v5}, Lcom/getcapacitor/PluginCall;->setKeepAlive(Ljava/lang/Boolean;)V

    .line 121
    sget-object v5, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const/4 v6, 0x0

    invoke-static {v6}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v7

    const-string v8, "multiple"

    invoke-virtual {p1, v8, v7}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v7

    invoke-virtual {v5, v7}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v5

    .line 122
    .local v5, "multiple":Z
    iput-boolean v5, p0, Lcom/forge/live/FilesBridgePlugin;->pendingMultiple:Z

    .line 123
    const-wide/32 v7, 0x1900000

    .line 125
    .local v7, "max":J
    :try_start_0
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v9

    if-eqz v9, :cond_0

    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v9

    invoke-virtual {v9, v3}, Lcom/getcapacitor/JSObject;->has(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_0

    .line 126
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v9

    invoke-virtual {v9, v3}, Lcom/getcapacitor/JSObject;->getDouble(Ljava/lang/String;)D

    move-result-wide v9
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    double-to-long v7, v9

    goto :goto_0

    .line 128
    :catch_0
    move-exception v3

    :cond_0
    :goto_0
    nop

    .line 129
    const-wide/16 v9, 0x0

    cmp-long v3, v7, v9

    if-gtz v3, :cond_1

    const-wide/32 v7, 0x1900000

    .line 130
    :cond_1
    const-wide/32 v9, 0x2800000

    cmp-long v3, v7, v9

    if-lez v3, :cond_2

    const-wide/32 v7, 0x2800000

    .line 131
    :cond_2
    iput-wide v7, p0, Lcom/forge/live/FilesBridgePlugin;->pendingMaxBytes:J

    .line 134
    :try_start_1
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v3

    if-eqz v3, :cond_3

    .line 135
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v3

    const-string v9, "_forgeMultiple"

    invoke-virtual {v3, v9, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 136
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v3

    const-string v9, "_forgeMaxBytes"

    invoke-virtual {v3, v9, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    .line 138
    :catch_1
    move-exception v3

    :cond_3
    :goto_1
    nop

    .line 140
    const-string v3, "accept"

    const-string v9, "*/*"

    invoke-virtual {p1, v3, v9}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 144
    .local v3, "accept":Ljava/lang/String;
    const/4 v10, 0x1

    .line 147
    .local v10, "forceAll":Z
    :try_start_2
    new-instance v11, Landroid/content/Intent;

    const-string v12, "android.intent.action.OPEN_DOCUMENT"

    invoke-direct {v11, v12}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 148
    .local v11, "intent":Landroid/content/Intent;
    invoke-virtual {v11, v2}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;

    .line 149
    invoke-virtual {v11, v4}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 150
    const/16 v12, 0x40

    invoke-virtual {v11, v12}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 152
    if-eqz v10, :cond_4

    .line 153
    invoke-virtual {v11, v9}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    goto :goto_2

    .line 155
    :cond_4
    invoke-static {v3}, Lcom/forge/live/FilesBridgePlugin;->parseAccept(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v12

    .line 156
    .local v12, "mimes":[Ljava/lang/String;
    array-length v13, v12

    if-ne v13, v4, :cond_5

    .line 157
    aget-object v6, v12, v6

    invoke-virtual {v11, v6}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    goto :goto_2

    .line 159
    :cond_5
    invoke-virtual {v11, v9}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    .line 160
    const-string v6, "android.intent.extra.MIME_TYPES"

    invoke-virtual {v11, v6, v12}, Landroid/content/Intent;->putExtra(Ljava/lang/String;[Ljava/lang/String;)Landroid/content/Intent;

    .line 163
    .end local v12    # "mimes":[Ljava/lang/String;
    :goto_2
    if-eqz v5, :cond_6

    .line 164
    invoke-virtual {v11, v1, v4}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 168
    :cond_6
    invoke-virtual {p0, p1, v11, v0}, Lcom/forge/live/FilesBridgePlugin;->startActivityForResult(Lcom/getcapacitor/PluginCall;Landroid/content/Intent;Ljava/lang/String;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

    .line 180
    .end local v11    # "intent":Landroid/content/Intent;
    goto :goto_3

    .line 169
    :catch_2
    move-exception v6

    .line 171
    .local v6, "e":Ljava/lang/Exception;
    :try_start_3
    new-instance v11, Landroid/content/Intent;

    const-string v12, "android.intent.action.GET_CONTENT"

    invoke-direct {v11, v12}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 172
    .restart local v11    # "intent":Landroid/content/Intent;
    invoke-virtual {v11, v2}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;

    .line 173
    invoke-virtual {v11, v9}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    .line 174
    invoke-virtual {v11, v4}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 175
    if-eqz v5, :cond_7

    invoke-virtual {v11, v1, v4}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 176
    :cond_7
    const-string v1, "Choose file"

    invoke-static {v11, v1}, Landroid/content/Intent;->createChooser(Landroid/content/Intent;Ljava/lang/CharSequence;)Landroid/content/Intent;

    move-result-object v1

    invoke-virtual {p0, p1, v1, v0}, Lcom/forge/live/FilesBridgePlugin;->startActivityForResult(Lcom/getcapacitor/PluginCall;Landroid/content/Intent;Ljava/lang/String;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_3

    .line 179
    .end local v11    # "intent":Landroid/content/Intent;
    goto :goto_3

    .line 177
    :catch_3
    move-exception v0

    .line 178
    .local v0, "e2":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "files.pick failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 181
    .end local v0    # "e2":Ljava/lang/Exception;
    .end local v6    # "e":Ljava/lang/Exception;
    :goto_3
    return-void
.end method

.method public readStaged(Lcom/getcapacitor/PluginCall;)V
    .locals 16
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 67
    move-object/from16 v1, p1

    const-string v2, "application/octet-stream"

    const-string v3, "mime"

    const-string v0, "maxBytes"

    const-string v4, "path"

    const/4 v5, 0x1

    invoke-static {v5}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v5

    invoke-virtual {v1, v5}, Lcom/getcapacitor/PluginCall;->setKeepAlive(Ljava/lang/Boolean;)V

    .line 69
    :try_start_0
    const-string v5, ""

    invoke-virtual {v1, v4, v5}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .line 70
    .local v5, "path":Ljava/lang/String;
    if-eqz v5, :cond_7

    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v6

    if-eqz v6, :cond_0

    goto/16 :goto_1

    .line 74
    :cond_0
    new-instance v6, Ljava/io/File;

    invoke-direct {v6, v5}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 76
    .local v6, "f":Ljava/io/File;
    new-instance v7, Ljava/io/File;

    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/FilesBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v8

    invoke-virtual {v8}, Landroid/content/Context;->getCacheDir()Ljava/io/File;

    move-result-object v8

    const-string v9, "forge_picks"

    invoke-direct {v7, v8, v9}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 77
    .local v7, "cacheRoot":Ljava/io/File;
    invoke-virtual {v7}, Ljava/io/File;->getCanonicalPath()Ljava/lang/String;

    move-result-object v8

    .line 78
    .local v8, "root":Ljava/lang/String;
    invoke-virtual {v6}, Ljava/io/File;->getCanonicalPath()Ljava/lang/String;

    move-result-object v9

    .line 79
    .local v9, "target":Ljava/lang/String;
    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    sget-object v11, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v9, v10}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v10

    if-nez v10, :cond_1

    invoke-virtual {v9, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v10

    if-nez v10, :cond_1

    .line 80
    const-string v0, "path not allowed"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 81
    return-void

    .line 83
    :cond_1
    invoke-virtual {v6}, Ljava/io/File;->isFile()Z

    move-result v10

    if-nez v10, :cond_2

    .line 84
    const-string v0, "file not found"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 85
    return-void

    .line 87
    :cond_2
    const-wide/32 v10, 0x1b58000

    .line 89
    .local v10, "max":J
    :try_start_1
    invoke-virtual/range {p1 .. p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v12

    if-eqz v12, :cond_3

    invoke-virtual/range {p1 .. p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v12

    invoke-virtual {v12, v0}, Lcom/getcapacitor/JSObject;->has(Ljava/lang/String;)Z

    move-result v12

    if-eqz v12, :cond_3

    .line 90
    invoke-virtual/range {p1 .. p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v12

    invoke-virtual {v12, v0}, Lcom/getcapacitor/JSObject;->getDouble(Ljava/lang/String;)D

    move-result-wide v12
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    double-to-long v10, v12

    goto :goto_0

    .line 92
    :catch_0
    move-exception v0

    :cond_3
    :goto_0
    nop

    .line 93
    :try_start_2
    invoke-virtual {v6}, Ljava/io/File;->length()J

    move-result-wide v12

    cmp-long v0, v12, v10

    if-lez v0, :cond_4

    .line 94
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "File too large to read ("

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v6}, Ljava/io/File;->length()J

    move-result-wide v2

    invoke-virtual {v0, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, " > "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v10, v11}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, ")"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 95
    return-void

    .line 97
    :cond_4
    invoke-static {v6, v10, v11}, Lcom/forge/live/FilesBridgePlugin;->readFileBytes(Ljava/io/File;J)[B

    move-result-object v0

    .line 98
    .local v0, "bytes":[B
    invoke-virtual {v1, v3, v2}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v12

    .line 99
    .local v12, "mime":Ljava/lang/String;
    if-eqz v12, :cond_5

    invoke-virtual {v12}, Ljava/lang/String;->isEmpty()Z

    move-result v13

    if-eqz v13, :cond_6

    :cond_5
    move-object v12, v2

    .line 100
    :cond_6
    const/4 v2, 0x2

    invoke-static {v0, v2}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;

    move-result-object v2

    .line 101
    .local v2, "b64":Ljava/lang/String;
    new-instance v13, Lcom/getcapacitor/JSObject;

    invoke-direct {v13}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 102
    .local v13, "o":Lcom/getcapacitor/JSObject;
    const-string v14, "name"

    invoke-virtual {v6}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v13, v14, v15}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 103
    invoke-virtual {v6}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v13, v4, v14}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 104
    const-string v4, "size"

    array-length v14, v0

    invoke-virtual {v13, v4, v14}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 105
    invoke-virtual {v13, v3, v12}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 106
    const-string v3, "type"

    invoke-virtual {v13, v3, v12}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 107
    const-string v3, "base64"

    invoke-virtual {v13, v3, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 108
    const-string v3, "dataUrl"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v14, "data:"

    invoke-virtual {v4, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v14, ";base64,"

    invoke-virtual {v4, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v13, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 109
    invoke-virtual {v1, v13}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 112
    .end local v0    # "bytes":[B
    .end local v2    # "b64":Ljava/lang/String;
    .end local v5    # "path":Ljava/lang/String;
    .end local v6    # "f":Ljava/io/File;
    .end local v7    # "cacheRoot":Ljava/io/File;
    .end local v8    # "root":Ljava/lang/String;
    .end local v9    # "target":Ljava/lang/String;
    .end local v10    # "max":J
    .end local v12    # "mime":Ljava/lang/String;
    .end local v13    # "o":Lcom/getcapacitor/JSObject;
    goto :goto_2

    .line 71
    .restart local v5    # "path":Ljava/lang/String;
    :cond_7
    :goto_1
    const-string v0, "path required"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    .line 72
    return-void

    .line 110
    .end local v5    # "path":Ljava/lang/String;
    :catch_1
    move-exception v0

    .line 111
    .local v0, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "readStaged failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 113
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_2
    return-void
.end method
