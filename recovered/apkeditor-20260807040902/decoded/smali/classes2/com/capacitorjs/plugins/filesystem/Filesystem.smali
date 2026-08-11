.class public Lcom/capacitorjs/plugins/filesystem/Filesystem;
.super Ljava/lang/Object;
.source "Filesystem.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;
    }
.end annotation


# instance fields
.field private context:Landroid/content/Context;


# direct methods
.method public static synthetic $r8$lambda$2TPfy96K4v66JpdCKEpoW7iZp6Y(Lcom/capacitorjs/plugins/filesystem/Filesystem;Ljava/lang/String;Lcom/getcapacitor/PluginCall;Lcom/getcapacitor/Bridge;Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;Landroid/os/Handler;Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;Ljava/util/concurrent/ExecutorService;)V
    .locals 0

    invoke-direct/range {p0 .. p7}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->lambda$downloadFile$2(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Lcom/getcapacitor/Bridge;Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;Landroid/os/Handler;Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;Ljava/util/concurrent/ExecutorService;)V

    return-void
.end method

.method constructor <init>(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .line 40
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 41
    iput-object p1, p0, Lcom/capacitorjs/plugins/filesystem/Filesystem;->context:Landroid/content/Context;

    .line 42
    return-void
.end method

.method private doDownloadInBackground(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Lcom/getcapacitor/Bridge;Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;)Lcom/getcapacitor/JSObject;
    .locals 34
    .param p1, "urlString"    # Ljava/lang/String;
    .param p2, "call"    # Lcom/getcapacitor/PluginCall;
    .param p3, "bridge"    # Lcom/getcapacitor/Bridge;
    .param p4, "emitter"    # Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;,
            Ljava/net/URISyntaxException;,
            Lorg/json/JSONException;
        }
    .end annotation

    .line 336
    move-object/from16 v1, p2

    move-object/from16 v2, p4

    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    const-string v3, "headers"

    invoke-virtual {v1, v3, v0}, Lcom/getcapacitor/PluginCall;->getObject(Ljava/lang/String;Lcom/getcapacitor/JSObject;)Lcom/getcapacitor/JSObject;

    move-result-object v3

    .line 337
    .local v3, "headers":Lcom/getcapacitor/JSObject;
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    const-string v4, "params"

    invoke-virtual {v1, v4, v0}, Lcom/getcapacitor/PluginCall;->getObject(Ljava/lang/String;Lcom/getcapacitor/JSObject;)Lcom/getcapacitor/JSObject;

    move-result-object v4

    .line 338
    .local v4, "params":Lcom/getcapacitor/JSObject;
    const-string v0, "connectTimeout"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v5

    .line 339
    .local v5, "connectTimeout":Ljava/lang/Integer;
    const-string v0, "readTimeout"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v6

    .line 340
    .local v6, "readTimeout":Ljava/lang/Integer;
    const-string v0, "disableRedirects"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;)Ljava/lang/Boolean;

    move-result-object v7

    .line 341
    .local v7, "disableRedirects":Ljava/lang/Boolean;
    const/4 v0, 0x1

    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    const-string v8, "shouldEncodeUrlParams"

    invoke-virtual {v1, v8, v0}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v8

    .line 342
    .local v8, "shouldEncode":Ljava/lang/Boolean;
    const/4 v9, 0x0

    invoke-static {v9}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    const-string v10, "progress"

    invoke-virtual {v1, v10, v0}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v10

    .line 344
    .local v10, "progress":Ljava/lang/Boolean;
    const-string v0, "method"

    const-string v11, "GET"

    invoke-virtual {v1, v0, v11}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    sget-object v11, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v0, v11}, Ljava/lang/String;->toUpperCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v11

    .line 345
    .local v11, "method":Ljava/lang/String;
    const-string v12, "path"

    invoke-virtual {v1, v12}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v13

    .line 346
    .local v13, "path":Ljava/lang/String;
    const-string v0, "directory"

    sget-object v14, Landroid/os/Environment;->DIRECTORY_DOWNLOADS:Ljava/lang/String;

    invoke-virtual {v1, v0, v14}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v14

    .line 348
    .local v14, "directory":Ljava/lang/String;
    new-instance v0, Ljava/net/URL;

    move-object/from16 v15, p1

    invoke-direct {v0, v15}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    move-object/from16 v16, v0

    .line 349
    .local v16, "url":Ljava/net/URL;
    move-object/from16 v9, p0

    invoke-virtual {v9, v13, v14}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getFileObject(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;

    move-result-object v1

    .line 351
    .local v1, "file":Ljava/io/File;
    new-instance v0, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;

    invoke-direct {v0}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;-><init>()V

    .line 352
    move-object/from16 v9, v16

    .end local v16    # "url":Ljava/net/URL;
    .local v9, "url":Ljava/net/URL;
    invoke-virtual {v0, v9}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;->setUrl(Ljava/net/URL;)Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;

    move-result-object v0

    .line 353
    invoke-virtual {v0, v11}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;->setMethod(Ljava/lang/String;)Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;

    move-result-object v0

    .line 354
    invoke-virtual {v0, v3}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;->setHeaders(Lcom/getcapacitor/JSObject;)Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;

    move-result-object v0

    .line 355
    move-object/from16 v16, v3

    .end local v3    # "headers":Lcom/getcapacitor/JSObject;
    .local v16, "headers":Lcom/getcapacitor/JSObject;
    invoke-virtual {v8}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v3

    invoke-virtual {v0, v4, v3}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;->setUrlParams(Lcom/getcapacitor/JSObject;Z)Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;

    move-result-object v0

    .line 356
    invoke-virtual {v0, v5}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;->setConnectTimeout(Ljava/lang/Integer;)Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;

    move-result-object v0

    .line 357
    invoke-virtual {v0, v6}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;->setReadTimeout(Ljava/lang/Integer;)Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;

    move-result-object v0

    .line 358
    invoke-virtual {v0, v7}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;->setDisableRedirects(Ljava/lang/Boolean;)Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;

    move-result-object v0

    .line 359
    invoke-virtual {v0}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;->openConnection()Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;

    move-result-object v3

    .line 361
    .local v3, "connectionBuilder":Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;
    move-object/from16 v18, v4

    .end local v4    # "params":Lcom/getcapacitor/JSObject;
    .local v18, "params":Lcom/getcapacitor/JSObject;
    invoke-virtual {v3}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;->build()Lcom/getcapacitor/plugin/util/CapacitorHttpUrlConnection;

    move-result-object v4

    .line 363
    .local v4, "connection":Lcom/getcapacitor/plugin/util/CapacitorHttpUrlConnection;
    move-object/from16 v19, v3

    move-object/from16 v3, p3

    .end local v3    # "connectionBuilder":Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;
    .local v19, "connectionBuilder":Lcom/getcapacitor/plugin/util/HttpRequestHandler$HttpURLConnectionBuilder;
    invoke-virtual {v4, v3}, Lcom/getcapacitor/plugin/util/CapacitorHttpUrlConnection;->setSSLSocketFactory(Lcom/getcapacitor/Bridge;)V

    .line 365
    invoke-virtual {v4}, Lcom/getcapacitor/plugin/util/CapacitorHttpUrlConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object v3

    .line 366
    .local v3, "connectionInputStream":Ljava/io/InputStream;
    new-instance v0, Ljava/io/FileOutputStream;

    move-object/from16 v20, v5

    const/4 v5, 0x0

    .end local v5    # "connectTimeout":Ljava/lang/Integer;
    .local v20, "connectTimeout":Ljava/lang/Integer;
    invoke-direct {v0, v1, v5}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;Z)V

    move-object v5, v0

    .line 368
    .local v5, "fileOutputStream":Ljava/io/FileOutputStream;
    const-string v0, "content-length"

    invoke-virtual {v4, v0}, Lcom/getcapacitor/plugin/util/CapacitorHttpUrlConnection;->getHeaderField(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v21

    .line 369
    .local v21, "contentLength":Ljava/lang/String;
    const/16 v22, 0x0

    .line 370
    .local v22, "bytes":I
    const/16 v23, 0x0

    .line 373
    .local v23, "maxBytes":I
    if-eqz v21, :cond_0

    :try_start_0
    invoke-static/range {v21 .. v21}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0
    :try_end_0
    .catch Ljava/lang/NumberFormatException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 374
    :catch_0
    move-exception v0

    goto :goto_1

    .line 373
    :cond_0
    const/4 v0, 0x0

    :goto_0
    move/from16 v23, v0

    .line 374
    :goto_1
    nop

    .line 376
    const/16 v0, 0x400

    new-array v0, v0, [B

    .line 380
    .local v0, "buffer":[B
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v24

    .line 381
    .local v24, "lastEmitTime":J
    const-wide/16 v26, 0x64

    .line 383
    .local v26, "minEmitIntervalMillis":J
    :goto_2
    invoke-virtual {v3, v0}, Ljava/io/InputStream;->read([B)I

    move-result v28

    move/from16 v29, v28

    .local v29, "len":I
    if-lez v28, :cond_3

    .line 384
    move-object/from16 v28, v4

    move-object/from16 v17, v6

    move/from16 v4, v29

    const/4 v6, 0x0

    .end local v6    # "readTimeout":Ljava/lang/Integer;
    .end local v29    # "len":I
    .local v4, "len":I
    .local v17, "readTimeout":Ljava/lang/Integer;
    .local v28, "connection":Lcom/getcapacitor/plugin/util/CapacitorHttpUrlConnection;
    invoke-virtual {v5, v0, v6, v4}, Ljava/io/FileOutputStream;->write([BII)V

    .line 386
    add-int v22, v22, v4

    .line 388
    invoke-virtual {v10}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v29

    if-eqz v29, :cond_2

    if-eqz v2, :cond_2

    .line 389
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v29

    .line 390
    .local v29, "currentTime":J
    sub-long v31, v29, v24

    cmp-long v33, v31, v26

    if-lez v33, :cond_1

    .line 391
    invoke-static/range {v22 .. v22}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v6

    move-object/from16 v32, v0

    .end local v0    # "buffer":[B
    .local v32, "buffer":[B
    invoke-static/range {v23 .. v23}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-interface {v2, v6, v0}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;->emit(Ljava/lang/Integer;Ljava/lang/Integer;)V

    .line 392
    move-wide/from16 v24, v29

    goto :goto_3

    .line 390
    .end local v32    # "buffer":[B
    .restart local v0    # "buffer":[B
    :cond_1
    move-object/from16 v32, v0

    .line 394
    .end local v0    # "buffer":[B
    .end local v29    # "currentTime":J
    .restart local v32    # "buffer":[B
    :goto_3
    move-object/from16 v6, v17

    move-object/from16 v4, v28

    move-object/from16 v0, v32

    goto :goto_2

    .line 388
    .end local v32    # "buffer":[B
    .restart local v0    # "buffer":[B
    :cond_2
    move-object/from16 v32, v0

    .line 383
    .end local v0    # "buffer":[B
    .end local v4    # "len":I
    .restart local v32    # "buffer":[B
    move-object/from16 v6, v17

    move-object/from16 v4, v28

    move-object/from16 v0, v32

    goto :goto_2

    .line 397
    .end local v17    # "readTimeout":Ljava/lang/Integer;
    .end local v28    # "connection":Lcom/getcapacitor/plugin/util/CapacitorHttpUrlConnection;
    .end local v32    # "buffer":[B
    .restart local v0    # "buffer":[B
    .local v4, "connection":Lcom/getcapacitor/plugin/util/CapacitorHttpUrlConnection;
    .restart local v6    # "readTimeout":Ljava/lang/Integer;
    .local v29, "len":I
    :cond_3
    move-object/from16 v32, v0

    move-object/from16 v28, v4

    move-object/from16 v17, v6

    move/from16 v4, v29

    .end local v0    # "buffer":[B
    .end local v6    # "readTimeout":Ljava/lang/Integer;
    .end local v29    # "len":I
    .local v4, "len":I
    .restart local v17    # "readTimeout":Ljava/lang/Integer;
    .restart local v28    # "connection":Lcom/getcapacitor/plugin/util/CapacitorHttpUrlConnection;
    .restart local v32    # "buffer":[B
    invoke-virtual {v10}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    if-eqz v0, :cond_4

    if-eqz v2, :cond_4

    .line 398
    invoke-static/range {v22 .. v22}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-static/range {v23 .. v23}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v6

    invoke-interface {v2, v0, v6}, Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;->emit(Ljava/lang/Integer;Ljava/lang/Integer;)V

    .line 401
    :cond_4
    invoke-virtual {v3}, Ljava/io/InputStream;->close()V

    .line 402
    invoke-virtual {v5}, Ljava/io/FileOutputStream;->close()V

    .line 404
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 405
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v0, v12, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 406
    return-object v0
.end method

.method static synthetic lambda$downloadFile$0(Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;Lcom/getcapacitor/JSObject;)V
    .locals 0
    .param p0, "callback"    # Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;
    .param p1, "result"    # Lcom/getcapacitor/JSObject;

    .line 324
    invoke-interface {p0, p1}, Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;->onSuccess(Lcom/getcapacitor/JSObject;)V

    return-void
.end method

.method static synthetic lambda$downloadFile$1(Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;Ljava/lang/Exception;)V
    .locals 0
    .param p0, "callback"    # Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;
    .param p1, "error"    # Ljava/lang/Exception;

    .line 326
    invoke-interface {p0, p1}, Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;->onError(Ljava/lang/Exception;)V

    return-void
.end method

.method private synthetic lambda$downloadFile$2(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Lcom/getcapacitor/Bridge;Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;Landroid/os/Handler;Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;Ljava/util/concurrent/ExecutorService;)V
    .locals 2
    .param p1, "urlString"    # Ljava/lang/String;
    .param p2, "call"    # Lcom/getcapacitor/PluginCall;
    .param p3, "bridge"    # Lcom/getcapacitor/Bridge;
    .param p4, "emitter"    # Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;
    .param p5, "handler"    # Landroid/os/Handler;
    .param p6, "callback"    # Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;
    .param p7, "executor"    # Ljava/util/concurrent/ExecutorService;

    .line 323
    :try_start_0
    invoke-direct {p0, p1, p2, p3, p4}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->doDownloadInBackground(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Lcom/getcapacitor/Bridge;Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;)Lcom/getcapacitor/JSObject;

    move-result-object v0

    .line 324
    .local v0, "result":Lcom/getcapacitor/JSObject;
    new-instance v1, Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda0;

    invoke-direct {v1, p6, v0}, Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda0;-><init>(Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;Lcom/getcapacitor/JSObject;)V

    invoke-virtual {p5, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 328
    nop

    .end local v0    # "result":Lcom/getcapacitor/JSObject;
    :goto_0
    invoke-interface {p7}, Ljava/util/concurrent/ExecutorService;->shutdown()V

    .line 329
    goto :goto_1

    .line 328
    :catchall_0
    move-exception v0

    goto :goto_2

    .line 325
    :catch_0
    move-exception v0

    .line 326
    .local v0, "error":Ljava/lang/Exception;
    :try_start_1
    new-instance v1, Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda1;

    invoke-direct {v1, p6, v0}, Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda1;-><init>(Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;Ljava/lang/Exception;)V

    invoke-virtual {p5, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 328
    nop

    .end local v0    # "error":Ljava/lang/Exception;
    goto :goto_0

    .line 330
    :goto_1
    return-void

    .line 328
    :goto_2
    invoke-interface {p7}, Ljava/util/concurrent/ExecutorService;->shutdown()V

    .line 329
    throw v0
.end method


# virtual methods
.method public copy(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Z)Ljava/io/File;
    .locals 5
    .param p1, "from"    # Ljava/lang/String;
    .param p2, "directory"    # Ljava/lang/String;
    .param p3, "to"    # Ljava/lang/String;
    .param p4, "toDirectory"    # Ljava/lang/String;
    .param p5, "doRename"    # Z
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;,
            Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;
        }
    .end annotation

    .line 109
    if-nez p4, :cond_0

    .line 110
    move-object p4, p2

    .line 113
    :cond_0
    invoke-virtual {p0, p1, p2}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getFileObject(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;

    move-result-object v0

    .line 114
    .local v0, "fromObject":Ljava/io/File;
    invoke-virtual {p0, p3, p4}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getFileObject(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;

    move-result-object v1

    .line 116
    .local v1, "toObject":Ljava/io/File;
    if-eqz v0, :cond_9

    .line 119
    if-eqz v1, :cond_8

    .line 123
    invoke-virtual {v1, v0}, Ljava/io/File;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 124
    return-object v1

    .line 127
    :cond_1
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v2

    if-eqz v2, :cond_7

    .line 131
    invoke-virtual {v1}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v2

    invoke-virtual {v2}, Ljava/io/File;->isFile()Z

    move-result v2

    if-nez v2, :cond_6

    .line 135
    invoke-virtual {v1}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v2

    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    move-result v2

    if-eqz v2, :cond_5

    .line 139
    invoke-virtual {v1}, Ljava/io/File;->isDirectory()Z

    move-result v2

    if-nez v2, :cond_4

    .line 143
    invoke-virtual {v1}, Ljava/io/File;->delete()Z

    .line 145
    if-eqz p5, :cond_3

    .line 146
    invoke-virtual {v0, v1}, Ljava/io/File;->renameTo(Ljava/io/File;)Z

    move-result v2

    .line 147
    .local v2, "modified":Z
    if-eqz v2, :cond_2

    .line 150
    .end local v2    # "modified":Z
    goto :goto_0

    .line 148
    .restart local v2    # "modified":Z
    :cond_2
    new-instance v3, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;

    const-string v4, "Unable to rename, unknown reason"

    invoke-direct {v3, v4}, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;-><init>(Ljava/lang/String;)V

    throw v3

    .line 151
    .end local v2    # "modified":Z
    :cond_3
    invoke-virtual {p0, v0, v1}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->copyRecursively(Ljava/io/File;Ljava/io/File;)V

    .line 154
    :goto_0
    return-object v1

    .line 140
    :cond_4
    new-instance v2, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;

    const-string v3, "Cannot overwrite a directory"

    invoke-direct {v2, v3}, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 136
    :cond_5
    new-instance v2, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;

    const-string v3, "The parent object of the destination does not exist"

    invoke-direct {v2, v3}, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 132
    :cond_6
    new-instance v2, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;

    const-string v3, "The parent object of the destination is a file"

    invoke-direct {v2, v3}, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 128
    :cond_7
    new-instance v2, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;

    const-string v3, "The source object does not exist"

    invoke-direct {v2, v3}, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 120
    :cond_8
    new-instance v2, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;

    const-string v3, "to file is null"

    invoke-direct {v2, v3}, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 117
    :cond_9
    new-instance v2, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;

    const-string v3, "from file is null"

    invoke-direct {v2, v3}, Lcom/capacitorjs/plugins/filesystem/exceptions/CopyFailedException;-><init>(Ljava/lang/String;)V

    throw v2
.end method

.method public copyRecursively(Ljava/io/File;Ljava/io/File;)V
    .locals 8
    .param p1, "src"    # Ljava/io/File;
    .param p2, "dst"    # Ljava/io/File;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 287
    invoke-virtual {p1}, Ljava/io/File;->isDirectory()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 288
    invoke-virtual {p2}, Ljava/io/File;->mkdir()Z

    .line 290
    invoke-virtual {p1}, Ljava/io/File;->list()[Ljava/lang/String;

    move-result-object v0

    array-length v1, v0

    const/4 v2, 0x0

    :goto_0
    if-ge v2, v1, :cond_0

    aget-object v3, v0, v2

    .line 291
    .local v3, "file":Ljava/lang/String;
    new-instance v4, Ljava/io/File;

    invoke-direct {v4, p1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    new-instance v5, Ljava/io/File;

    invoke-direct {v5, p2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {p0, v4, v5}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->copyRecursively(Ljava/io/File;Ljava/io/File;)V

    .line 290
    .end local v3    # "file":Ljava/lang/String;
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 294
    :cond_0
    return-void

    .line 297
    :cond_1
    invoke-virtual {p2}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v0

    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v0

    if-nez v0, :cond_2

    .line 298
    invoke-virtual {p2}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v0

    invoke-virtual {v0}, Ljava/io/File;->mkdirs()Z

    .line 301
    :cond_2
    invoke-virtual {p2}, Ljava/io/File;->exists()Z

    move-result v0

    if-nez v0, :cond_3

    .line 302
    invoke-virtual {p2}, Ljava/io/File;->createNewFile()Z

    .line 305
    :cond_3
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-virtual {v0}, Ljava/io/FileInputStream;->getChannel()Ljava/nio/channels/FileChannel;

    move-result-object v0

    .local v0, "source":Ljava/nio/channels/FileChannel;
    :try_start_0
    new-instance v1, Ljava/io/FileOutputStream;

    invoke-direct {v1, p2}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    invoke-virtual {v1}, Ljava/io/FileOutputStream;->getChannel()Ljava/nio/channels/FileChannel;

    move-result-object v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_2

    move-object v7, v1

    .line 306
    .local v7, "destination":Ljava/nio/channels/FileChannel;
    const-wide/16 v3, 0x0

    :try_start_1
    invoke-virtual {v0}, Ljava/nio/channels/FileChannel;->size()J

    move-result-wide v5

    move-object v1, v7

    move-object v2, v0

    invoke-virtual/range {v1 .. v6}, Ljava/nio/channels/FileChannel;->transferFrom(Ljava/nio/channels/ReadableByteChannel;JJ)J
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 307
    if-eqz v7, :cond_4

    :try_start_2
    invoke-virtual {v7}, Ljava/nio/channels/FileChannel;->close()V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    .end local v7    # "destination":Ljava/nio/channels/FileChannel;
    :cond_4
    if-eqz v0, :cond_5

    invoke-virtual {v0}, Ljava/nio/channels/FileChannel;->close()V

    .line 308
    .end local v0    # "source":Ljava/nio/channels/FileChannel;
    :cond_5
    return-void

    .line 305
    .restart local v0    # "source":Ljava/nio/channels/FileChannel;
    .restart local v7    # "destination":Ljava/nio/channels/FileChannel;
    :catchall_0
    move-exception v1

    if-eqz v7, :cond_6

    :try_start_3
    invoke-virtual {v7}, Ljava/nio/channels/FileChannel;->close()V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    goto :goto_1

    :catchall_1
    move-exception v2

    :try_start_4
    invoke-virtual {v1, v2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .end local v0    # "source":Ljava/nio/channels/FileChannel;
    .end local p1    # "src":Ljava/io/File;
    .end local p2    # "dst":Ljava/io/File;
    :cond_6
    :goto_1
    throw v1
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_2

    .end local v7    # "destination":Ljava/nio/channels/FileChannel;
    .restart local v0    # "source":Ljava/nio/channels/FileChannel;
    .restart local p1    # "src":Ljava/io/File;
    .restart local p2    # "dst":Ljava/io/File;
    :catchall_2
    move-exception v1

    if-eqz v0, :cond_7

    :try_start_5
    invoke-virtual {v0}, Ljava/nio/channels/FileChannel;->close()V
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_3

    goto :goto_2

    :catchall_3
    move-exception v2

    invoke-virtual {v1, v2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_7
    :goto_2
    throw v1
.end method

.method public deleteFile(Ljava/lang/String;Ljava/lang/String;)Z
    .locals 3
    .param p1, "file"    # Ljava/lang/String;
    .param p2, "directory"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/FileNotFoundException;
        }
    .end annotation

    .line 73
    invoke-virtual {p0, p1, p2}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getFileObject(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;

    move-result-object v0

    .line 74
    .local v0, "fileObject":Ljava/io/File;
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 77
    invoke-virtual {v0}, Ljava/io/File;->delete()Z

    move-result v1

    return v1

    .line 75
    :cond_0
    new-instance v1, Ljava/io/FileNotFoundException;

    const-string v2, "File does not exist"

    invoke-direct {v1, v2}, Ljava/io/FileNotFoundException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public deleteRecursively(Ljava/io/File;)V
    .locals 4
    .param p1, "file"    # Ljava/io/File;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 267
    invoke-virtual {p1}, Ljava/io/File;->isFile()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 268
    invoke-virtual {p1}, Ljava/io/File;->delete()Z

    .line 269
    return-void

    .line 272
    :cond_0
    invoke-virtual {p1}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object v0

    array-length v1, v0

    const/4 v2, 0x0

    :goto_0
    if-ge v2, v1, :cond_1

    aget-object v3, v0, v2

    .line 273
    .local v3, "f":Ljava/io/File;
    invoke-virtual {p0, v3}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->deleteRecursively(Ljava/io/File;)V

    .line 272
    .end local v3    # "f":Ljava/io/File;
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 276
    :cond_1
    invoke-virtual {p1}, Ljava/io/File;->delete()Z

    .line 277
    return-void
.end method

.method public downloadFile(Lcom/getcapacitor/PluginCall;Lcom/getcapacitor/Bridge;Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;)V
    .locals 13
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "bridge"    # Lcom/getcapacitor/Bridge;
    .param p3, "emitter"    # Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;
    .param p4, "callback"    # Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;

    .line 316
    const-string v0, "url"

    const-string v1, ""

    move-object v11, p1

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 317
    .local v0, "urlString":Ljava/lang/String;
    invoke-static {}, Ljava/util/concurrent/Executors;->newSingleThreadExecutor()Ljava/util/concurrent/ExecutorService;

    move-result-object v1

    .line 318
    .local v1, "executor":Ljava/util/concurrent/ExecutorService;
    new-instance v8, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v2

    invoke-direct {v8, v2}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    .line 320
    .local v8, "handler":Landroid/os/Handler;
    new-instance v12, Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda2;

    move-object v2, v12

    move-object v3, p0

    move-object v4, v0

    move-object v5, p1

    move-object v6, p2

    move-object/from16 v7, p3

    move-object/from16 v9, p4

    move-object v10, v1

    invoke-direct/range {v2 .. v10}, Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda2;-><init>(Lcom/capacitorjs/plugins/filesystem/Filesystem;Ljava/lang/String;Lcom/getcapacitor/PluginCall;Lcom/getcapacitor/Bridge;Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;Landroid/os/Handler;Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;Ljava/util/concurrent/ExecutorService;)V

    invoke-interface {v1, v12}, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V

    .line 332
    return-void
.end method

.method public getDirectory(Ljava/lang/String;)Ljava/io/File;
    .locals 3
    .param p1, "directory"    # Ljava/lang/String;

    .line 206
    iget-object v0, p0, Lcom/capacitorjs/plugins/filesystem/Filesystem;->context:Landroid/content/Context;

    .line 207
    .local v0, "c":Landroid/content/Context;
    invoke-virtual {p1}, Ljava/lang/String;->hashCode()I

    move-result v1

    sparse-switch v1, :sswitch_data_0

    :cond_0
    goto :goto_0

    :sswitch_0
    const-string v1, "EXTERNAL_STORAGE"

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, 0x5

    goto :goto_1

    :sswitch_1
    const-string v1, "LIBRARY"

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, 0x2

    goto :goto_1

    :sswitch_2
    const-string v1, "CACHE"

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, 0x3

    goto :goto_1

    :sswitch_3
    const-string v1, "DATA"

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, 0x1

    goto :goto_1

    :sswitch_4
    const-string v1, "DOCUMENTS"

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, 0x0

    goto :goto_1

    :sswitch_5
    const-string v1, "EXTERNAL"

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, 0x4

    goto :goto_1

    :goto_0
    const/4 v1, -0x1

    :goto_1
    const/4 v2, 0x0

    packed-switch v1, :pswitch_data_0

    .line 220
    return-object v2

    .line 218
    :pswitch_0
    invoke-static {}, Landroid/os/Environment;->getExternalStorageDirectory()Ljava/io/File;

    move-result-object v1

    return-object v1

    .line 216
    :pswitch_1
    invoke-virtual {v0, v2}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;

    move-result-object v1

    return-object v1

    .line 214
    :pswitch_2
    invoke-virtual {v0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;

    move-result-object v1

    return-object v1

    .line 212
    :pswitch_3
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;

    move-result-object v1

    return-object v1

    .line 209
    :pswitch_4
    sget-object v1, Landroid/os/Environment;->DIRECTORY_DOCUMENTS:Ljava/lang/String;

    invoke-static {v1}, Landroid/os/Environment;->getExternalStoragePublicDirectory(Ljava/lang/String;)Ljava/io/File;

    move-result-object v1

    return-object v1

    nop

    :sswitch_data_0
    .sparse-switch
        -0x3de0ac35 -> :sswitch_5
        -0x21aa9d68 -> :sswitch_4
        0x1fe7aa -> :sswitch_3
        0x3ceb762 -> :sswitch_2
        0x34b3b09b -> :sswitch_1
        0x3c6bcde7 -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_4
        :pswitch_3
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public getEncoding(Ljava/lang/String;)Ljava/nio/charset/Charset;
    .locals 2
    .param p1, "encoding"    # Ljava/lang/String;

    .line 245
    const/4 v0, 0x0

    if-nez p1, :cond_0

    .line 246
    return-object v0

    .line 249
    :cond_0
    invoke-virtual {p1}, Ljava/lang/String;->hashCode()I

    move-result v1

    sparse-switch v1, :sswitch_data_0

    :cond_1
    goto :goto_0

    :sswitch_0
    const-string v1, "utf16"

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    const/4 v1, 0x1

    goto :goto_1

    :sswitch_1
    const-string v1, "ascii"

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    const/4 v1, 0x2

    goto :goto_1

    :sswitch_2
    const-string v1, "utf8"

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    const/4 v1, 0x0

    goto :goto_1

    :goto_0
    const/4 v1, -0x1

    :goto_1
    packed-switch v1, :pswitch_data_0

    .line 257
    return-object v0

    .line 255
    :pswitch_0
    sget-object v0, Ljava/nio/charset/StandardCharsets;->US_ASCII:Ljava/nio/charset/Charset;

    return-object v0

    .line 253
    :pswitch_1
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_16:Ljava/nio/charset/Charset;

    return-object v0

    .line 251
    :pswitch_2
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    return-object v0

    :sswitch_data_0
    .sparse-switch
        0x36ef71 -> :sswitch_2
        0x58caf51 -> :sswitch_1
        0x6a6fe0c -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public getFileObject(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;
    .locals 3
    .param p1, "path"    # Ljava/lang/String;
    .param p2, "directory"    # Ljava/lang/String;

    .line 224
    if-nez p2, :cond_1

    .line 225
    invoke-static {p1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    .line 226
    .local v0, "u":Landroid/net/Uri;
    invoke-virtual {v0}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_0

    invoke-virtual {v0}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v1

    const-string v2, "file"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 227
    :cond_0
    new-instance v1, Ljava/io/File;

    invoke-virtual {v0}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    return-object v1

    .line 231
    .end local v0    # "u":Landroid/net/Uri;
    :cond_1
    invoke-virtual {p0, p2}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getDirectory(Ljava/lang/String;)Ljava/io/File;

    move-result-object v0

    .line 233
    .local v0, "androidDirectory":Ljava/io/File;
    if-nez v0, :cond_2

    .line 234
    const/4 v1, 0x0

    return-object v1

    .line 236
    :cond_2
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-nez v1, :cond_3

    .line 237
    invoke-virtual {v0}, Ljava/io/File;->mkdir()Z

    .line 241
    :cond_3
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, v0, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    return-object v1
.end method

.method public getInputStream(Ljava/lang/String;Ljava/lang/String;)Ljava/io/InputStream;
    .locals 4
    .param p1, "path"    # Ljava/lang/String;
    .param p2, "directory"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 158
    if-nez p2, :cond_1

    .line 159
    invoke-static {p1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    .line 160
    .local v0, "u":Landroid/net/Uri;
    invoke-virtual {v0}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v1

    const-string v2, "content"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 161
    iget-object v1, p0, Lcom/capacitorjs/plugins/filesystem/Filesystem;->context:Landroid/content/Context;

    invoke-virtual {v1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;

    move-result-object v1

    return-object v1

    .line 163
    :cond_0
    new-instance v1, Ljava/io/FileInputStream;

    new-instance v2, Ljava/io/File;

    invoke-virtual {v0}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v2, v3}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-direct {v1, v2}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    return-object v1

    .line 167
    .end local v0    # "u":Landroid/net/Uri;
    :cond_1
    invoke-virtual {p0, p2}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getDirectory(Ljava/lang/String;)Ljava/io/File;

    move-result-object v0

    .line 169
    .local v0, "androidDirectory":Ljava/io/File;
    if-eqz v0, :cond_2

    .line 173
    new-instance v1, Ljava/io/FileInputStream;

    new-instance v2, Ljava/io/File;

    invoke-direct {v2, v0, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-direct {v1, v2}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    return-object v1

    .line 170
    :cond_2
    new-instance v1, Ljava/io/IOException;

    const-string v2, "Directory not found"

    invoke-direct {v1, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public mkdir(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Boolean;)Z
    .locals 3
    .param p1, "path"    # Ljava/lang/String;
    .param p2, "directory"    # Ljava/lang/String;
    .param p3, "recursive"    # Ljava/lang/Boolean;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryExistsException;
        }
    .end annotation

    .line 81
    invoke-virtual {p0, p1, p2}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getFileObject(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;

    move-result-object v0

    .line 83
    .local v0, "fileObject":Ljava/io/File;
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-nez v1, :cond_1

    .line 87
    const/4 v1, 0x0

    .line 88
    .local v1, "created":Z
    invoke-virtual {p3}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 89
    invoke-virtual {v0}, Ljava/io/File;->mkdirs()Z

    move-result v1

    goto :goto_0

    .line 91
    :cond_0
    invoke-virtual {v0}, Ljava/io/File;->mkdir()Z

    move-result v1

    .line 93
    :goto_0
    return v1

    .line 84
    .end local v1    # "created":Z
    :cond_1
    new-instance v1, Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryExistsException;

    const-string v2, "Directory exists"

    invoke-direct {v1, v2}, Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryExistsException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public readFile(Ljava/lang/String;Ljava/lang/String;Ljava/nio/charset/Charset;)Ljava/lang/String;
    .locals 2
    .param p1, "path"    # Ljava/lang/String;
    .param p2, "directory"    # Ljava/lang/String;
    .param p3, "charset"    # Ljava/nio/charset/Charset;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 45
    invoke-virtual {p0, p1, p2}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getInputStream(Ljava/lang/String;Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v0

    .line 47
    .local v0, "is":Ljava/io/InputStream;
    if-eqz p3, :cond_0

    .line 48
    invoke-virtual {p3}, Ljava/nio/charset/Charset;->name()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v0, v1}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->readFileAsString(Ljava/io/InputStream;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .local v1, "dataStr":Ljava/lang/String;
    goto :goto_0

    .line 50
    .end local v1    # "dataStr":Ljava/lang/String;
    :cond_0
    invoke-virtual {p0, v0}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->readFileAsBase64EncodedData(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v1

    .line 52
    .restart local v1    # "dataStr":Ljava/lang/String;
    :goto_0
    return-object v1
.end method

.method public readFileAsBase64EncodedData(Ljava/io/InputStream;)Ljava/lang/String;
    .locals 6
    .param p1, "is"    # Ljava/io/InputStream;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 190
    move-object v0, p1

    check-cast v0, Ljava/io/FileInputStream;

    .line 191
    .local v0, "fileInputStreamReader":Ljava/io/FileInputStream;
    new-instance v1, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v1}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 193
    .local v1, "byteStream":Ljava/io/ByteArrayOutputStream;
    const/16 v2, 0x400

    new-array v2, v2, [B

    .line 196
    .local v2, "buffer":[B
    :goto_0
    invoke-virtual {v0, v2}, Ljava/io/FileInputStream;->read([B)I

    move-result v3

    move v4, v3

    .local v4, "c":I
    const/4 v5, -0x1

    if-eq v3, v5, :cond_0

    .line 197
    const/4 v3, 0x0

    invoke-virtual {v1, v2, v3, v4}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_0

    .line 199
    :cond_0
    invoke-virtual {v0}, Ljava/io/FileInputStream;->close()V

    .line 201
    invoke-virtual {v1}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v3

    const/4 v5, 0x2

    invoke-static {v3, v5}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;

    move-result-object v3

    return-object v3
.end method

.method public readFileAsString(Ljava/io/InputStream;Ljava/lang/String;)Ljava/lang/String;
    .locals 5
    .param p1, "is"    # Ljava/io/InputStream;
    .param p2, "encoding"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 177
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 179
    .local v0, "outputStream":Ljava/io/ByteArrayOutputStream;
    const/16 v1, 0x400

    new-array v1, v1, [B

    .line 180
    .local v1, "buffer":[B
    const/4 v2, 0x0

    .line 182
    .local v2, "length":I
    :goto_0
    invoke-virtual {p1, v1}, Ljava/io/InputStream;->read([B)I

    move-result v3

    move v2, v3

    const/4 v4, -0x1

    if-eq v3, v4, :cond_0

    .line 183
    const/4 v3, 0x0

    invoke-virtual {v0, v1, v3, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_0

    .line 186
    :cond_0
    invoke-virtual {v0, p2}, Ljava/io/ByteArrayOutputStream;->toString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    return-object v3
.end method

.method public readdir(Ljava/lang/String;Ljava/lang/String;)[Ljava/io/File;
    .locals 4
    .param p1, "path"    # Ljava/lang/String;
    .param p2, "directory"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryNotFoundException;
        }
    .end annotation

    .line 97
    const/4 v0, 0x0

    .line 98
    .local v0, "files":[Ljava/io/File;
    invoke-virtual {p0, p1, p2}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->getFileObject(Ljava/lang/String;Ljava/lang/String;)Ljava/io/File;

    move-result-object v1

    .line 99
    .local v1, "fileObject":Ljava/io/File;
    if-eqz v1, :cond_0

    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 100
    invoke-virtual {v1}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object v0

    .line 104
    return-object v0

    .line 102
    :cond_0
    new-instance v2, Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryNotFoundException;

    const-string v3, "Directory does not exist"

    invoke-direct {v2, v3}, Lcom/capacitorjs/plugins/filesystem/exceptions/DirectoryNotFoundException;-><init>(Ljava/lang/String;)V

    throw v2
.end method

.method public saveFile(Ljava/io/File;Ljava/lang/String;Ljava/nio/charset/Charset;Ljava/lang/Boolean;)V
    .locals 4
    .param p1, "file"    # Ljava/io/File;
    .param p2, "data"    # Ljava/lang/String;
    .param p3, "charset"    # Ljava/nio/charset/Charset;
    .param p4, "append"    # Ljava/lang/Boolean;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 57
    if-eqz p3, :cond_0

    .line 58
    new-instance v0, Ljava/io/BufferedWriter;

    new-instance v1, Ljava/io/OutputStreamWriter;

    new-instance v2, Ljava/io/FileOutputStream;

    invoke-virtual {p4}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v3

    invoke-direct {v2, p1, v3}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;Z)V

    invoke-direct {v1, v2, p3}, Ljava/io/OutputStreamWriter;-><init>(Ljava/io/OutputStream;Ljava/nio/charset/Charset;)V

    invoke-direct {v0, v1}, Ljava/io/BufferedWriter;-><init>(Ljava/io/Writer;)V

    .line 59
    .local v0, "writer":Ljava/io/BufferedWriter;
    invoke-virtual {v0, p2}, Ljava/io/BufferedWriter;->write(Ljava/lang/String;)V

    .line 60
    invoke-virtual {v0}, Ljava/io/BufferedWriter;->close()V

    .line 61
    .end local v0    # "writer":Ljava/io/BufferedWriter;
    goto :goto_0

    .line 63
    :cond_0
    const-string v0, ","

    invoke-virtual {p2, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 64
    invoke-virtual {p2, v0}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x1

    aget-object p2, v0, v1

    .line 66
    :cond_1
    new-instance v0, Ljava/io/FileOutputStream;

    invoke-virtual {p4}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1

    invoke-direct {v0, p1, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;Z)V

    .line 67
    .local v0, "fos":Ljava/io/FileOutputStream;
    const/4 v1, 0x2

    invoke-static {p2, v1}, Landroid/util/Base64;->decode(Ljava/lang/String;I)[B

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/io/FileOutputStream;->write([B)V

    .line 68
    invoke-virtual {v0}, Ljava/io/FileOutputStream;->close()V

    .line 70
    .end local v0    # "fos":Ljava/io/FileOutputStream;
    :goto_0
    return-void
.end method
