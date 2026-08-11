.class public Lcom/forge/live/TermuxBridgePlugin;
.super Lcom/getcapacitor/Plugin;
.source "TermuxBridgePlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "TermuxBridge"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    }
.end annotation


# static fields
.field private static final ACTION_EXEC_RESULT:Ljava/lang/String; = "com.forge.live.TERMUX_EXEC_RESULT"

.field private static final ACTION_RUN_COMMAND:Ljava/lang/String; = "com.termux.RUN_COMMAND"

.field private static final BRIDGE_DIR_NAME:Ljava/lang/String; = "ForgeBridge"

.field private static final DEFAULT_AGENT_PORT:I = 0x2253

.field private static final EXTRA_ARGUMENTS:Ljava/lang/String; = "com.termux.RUN_COMMAND_ARGUMENTS"

.field private static final EXTRA_BACKGROUND:Ljava/lang/String; = "com.termux.RUN_COMMAND_BACKGROUND"

.field private static final EXTRA_COMMAND_DESCRIPTION:Ljava/lang/String; = "com.termux.RUN_COMMAND_DESCRIPTION"

.field private static final EXTRA_COMMAND_LABEL:Ljava/lang/String; = "com.termux.RUN_COMMAND_LABEL"

.field private static final EXTRA_COMMAND_PATH:Ljava/lang/String; = "com.termux.RUN_COMMAND_PATH"

.field private static final EXTRA_EXEC_TOKEN:Ljava/lang/String; = "forge_exec_token"

.field private static final EXTRA_PENDING_INTENT:Ljava/lang/String; = "com.termux.RUN_COMMAND_PENDING_INTENT"

.field private static final EXTRA_SESSION_ACTION:Ljava/lang/String; = "com.termux.RUN_COMMAND_SESSION_ACTION"

.field private static final EXTRA_WORKDIR:Ljava/lang/String; = "com.termux.RUN_COMMAND_WORKDIR"

.field private static final RESULT_BUNDLE:Ljava/lang/String; = "result"

.field private static final RESULT_ERR:Ljava/lang/String; = "err"

.field private static final RESULT_ERRMSG:Ljava/lang/String; = "errmsg"

.field private static final RESULT_EXIT_CODE:Ljava/lang/String; = "exitCode"

.field private static final RESULT_STDERR:Ljava/lang/String; = "stderr"

.field private static final RESULT_STDERR_ORIG_LEN:Ljava/lang/String; = "stderr_original_length"

.field private static final RESULT_STDOUT:Ljava/lang/String; = "stdout"

.field private static final RESULT_STDOUT_ORIG_LEN:Ljava/lang/String; = "stdout_original_length"

.field private static final RUN_COMMAND_SERVICE:Ljava/lang/String; = "com.termux.app.RunCommandService"

.field private static final TERMUX_HOME:Ljava/lang/String; = "/data/data/com.termux/files/home"

.field private static final TERMUX_PACKAGE:Ljava/lang/String; = "com.termux"

.field private static final TERMUX_PREFIX:Ljava/lang/String; = "/data/data/com.termux/files/usr"


# instance fields
.field private execReceiver:Landroid/content/BroadcastReceiver;

.field private final ioPool:Ljava/util/concurrent/ExecutorService;

.field private final mainHandler:Landroid/os/Handler;

.field private final pendingExec:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Integer;",
            "Lcom/getcapacitor/PluginCall;",
            ">;"
        }
    .end annotation
.end field

.field private receiverRegistered:Z

.field private final tokenSeq:Ljava/util/concurrent/atomic/AtomicInteger;


# direct methods
.method public static synthetic $r8$lambda$037oac5EdKTFwk9Dwsjgg_GcL80(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;I)V
    .locals 0

    invoke-direct {p0, p1, p2, p3}, Lcom/forge/live/TermuxBridgePlugin;->lambda$exec$4(Lcom/getcapacitor/PluginCall;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;I)V

    return-void
.end method

.method public static synthetic $r8$lambda$FG4Sg4k1QI7BvRrVTSNH6KPQs-M(Lcom/forge/live/TermuxBridgePlugin;II)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/forge/live/TermuxBridgePlugin;->lambda$execViaRunCommand$7(II)V

    return-void
.end method

.method public static synthetic $r8$lambda$MDFGCeGhQv29BD8Z_TjTRGmgvYg(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/TermuxBridgePlugin;->lambda$run$3(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method public static synthetic $r8$lambda$ODRlVr9IU18Wsg_ZoqToKD5XKnM(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/TermuxBridgePlugin;->lambda$installAgent$2(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method public static synthetic $r8$lambda$QFmeFiMxhLivW49fP2MZrnT162o(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/TermuxBridgePlugin;->lambda$exec$5(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method public static synthetic $r8$lambda$er2kqK-faDNG4s3f6N-ArA23JZw(Lcom/forge/live/TermuxBridgePlugin;)V
    .locals 0

    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->lambda$load$0()V

    return-void
.end method

.method public static synthetic $r8$lambda$maMQOk8pvC_pOGNER2IxCptn5mE(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/TermuxBridgePlugin;->lambda$isAvailable$1(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method public static synthetic $r8$lambda$tZVhasa-PRtbq9hfyunLn31BjUo(Lcom/forge/live/TermuxBridgePlugin;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;ILcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1, p2, p3}, Lcom/forge/live/TermuxBridgePlugin;->lambda$execViaRunCommand$6(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;ILcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method static bridge synthetic -$$Nest$fgetpendingExec(Lcom/forge/live/TermuxBridgePlugin;)Ljava/util/Map;
    .locals 0

    iget-object p0, p0, Lcom/forge/live/TermuxBridgePlugin;->pendingExec:Ljava/util/Map;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$smnz(Ljava/lang/String;)Ljava/lang/String;
    .locals 0

    invoke-static {p0}, Lcom/forge/live/TermuxBridgePlugin;->nz(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method public constructor <init>()V
    .locals 2

    .line 62
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    .line 96
    new-instance v0, Ljava/util/concurrent/atomic/AtomicInteger;

    const/4 v1, 0x1

    invoke-direct {v0, v1}, Ljava/util/concurrent/atomic/AtomicInteger;-><init>(I)V

    iput-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->tokenSeq:Ljava/util/concurrent/atomic/AtomicInteger;

    .line 97
    new-instance v0, Ljava/util/concurrent/ConcurrentHashMap;

    invoke-direct {v0}, Ljava/util/concurrent/ConcurrentHashMap;-><init>()V

    iput-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->pendingExec:Ljava/util/Map;

    .line 98
    invoke-static {}, Ljava/util/concurrent/Executors;->newCachedThreadPool()Ljava/util/concurrent/ExecutorService;

    move-result-object v0

    iput-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->ioPool:Ljava/util/concurrent/ExecutorService;

    .line 99
    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->mainHandler:Landroid/os/Handler;

    .line 101
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/forge/live/TermuxBridgePlugin;->receiverRegistered:Z

    return-void
.end method

.method private agentFileExec(Lorg/json/JSONObject;I)Lorg/json/JSONObject;
    .locals 18
    .param p1, "job"    # Lorg/json/JSONObject;
    .param p2, "timeoutMs"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 613
    move-object/from16 v0, p0

    move-object/from16 v1, p1

    move/from16 v2, p2

    const/4 v3, 0x0

    invoke-direct {v0, v3}, Lcom/forge/live/TermuxBridgePlugin;->exportAgentFiles(Z)Ljava/io/File;

    move-result-object v4

    .line 614
    .local v4, "root":Ljava/io/File;
    new-instance v5, Ljava/io/File;

    const-string v6, "inbox"

    invoke-direct {v5, v4, v6}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 615
    .local v5, "inbox":Ljava/io/File;
    new-instance v6, Ljava/io/File;

    const-string v7, "outbox"

    invoke-direct {v6, v4, v7}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 617
    .local v6, "outbox":Ljava/io/File;
    invoke-virtual {v5}, Ljava/io/File;->exists()Z

    move-result v7

    if-nez v7, :cond_1

    invoke-virtual {v5}, Ljava/io/File;->mkdirs()Z

    move-result v7

    if-eqz v7, :cond_0

    goto :goto_0

    .line 618
    :cond_0
    new-instance v3, Ljava/lang/Exception;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "Cannot create inbox at "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v5}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-direct {v3, v7}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v3

    .line 620
    :cond_1
    :goto_0
    invoke-virtual {v6}, Ljava/io/File;->exists()Z

    move-result v7

    if-nez v7, :cond_3

    invoke-virtual {v6}, Ljava/io/File;->mkdirs()Z

    move-result v7

    if-eqz v7, :cond_2

    goto :goto_1

    .line 621
    :cond_2
    new-instance v3, Ljava/lang/Exception;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "Cannot create outbox at "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v6}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-direct {v3, v7}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v3

    .line 625
    :cond_3
    :goto_1
    new-instance v7, Ljava/io/File;

    const-string v8, "agent.json"

    invoke-direct {v7, v4, v8}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 626
    .local v7, "hb":Ljava/io/File;
    invoke-virtual {v7}, Ljava/io/File;->isFile()Z

    move-result v8

    if-eqz v8, :cond_4

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v8

    invoke-virtual {v7}, Ljava/io/File;->lastModified()J

    move-result-wide v10

    sub-long/2addr v8, v10

    const-wide/16 v10, 0x2710

    cmp-long v12, v8, v10

    if-gez v12, :cond_4

    const/4 v3, 0x1

    .line 627
    .local v3, "alive":Z
    :cond_4
    if-nez v3, :cond_6

    const/16 v8, 0x2253

    invoke-direct {v0, v8}, Lcom/forge/live/TermuxBridgePlugin;->agentPortOpen(I)Z

    move-result v8

    if-eqz v8, :cond_5

    goto :goto_2

    .line 628
    :cond_5
    new-instance v8, Ljava/lang/Exception;

    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "forge-termux-agent is not running (no heartbeat in "

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    .line 629
    invoke-virtual {v7}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, ")"

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    invoke-direct {v8, v9}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v8

    .line 632
    :cond_6
    :goto_2
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v8

    invoke-virtual {v8}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v8

    const-string v9, "id"

    invoke-virtual {v1, v9, v8}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    .line 633
    .local v8, "id":Ljava/lang/String;
    invoke-virtual {v1, v9, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 634
    new-instance v9, Ljava/io/File;

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, ".json"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-direct {v9, v5, v10}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 635
    .local v9, "inFile":Ljava/io/File;
    new-instance v10, Ljava/io/File;

    new-instance v12, Ljava/lang/StringBuilder;

    invoke-direct {v12}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v12, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v12

    invoke-virtual {v12, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-virtual {v11}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v11

    invoke-direct {v10, v6, v11}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 636
    .local v10, "outFile":Ljava/io/File;
    invoke-virtual {v10}, Ljava/io/File;->exists()Z

    move-result v11

    if-eqz v11, :cond_7

    .line 637
    invoke-virtual {v10}, Ljava/io/File;->delete()Z

    .line 639
    :cond_7
    invoke-virtual/range {p1 .. p1}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v11

    invoke-static {v9, v11}, Lcom/forge/live/TermuxBridgePlugin;->writeFile(Ljava/io/File;Ljava/lang/String;)V

    .line 641
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v11

    int-to-long v13, v2

    add-long/2addr v11, v13

    .line 642
    .local v11, "deadline":J
    :goto_3
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v13

    cmp-long v15, v13, v11

    if-gez v15, :cond_9

    .line 643
    invoke-virtual {v10}, Ljava/io/File;->isFile()Z

    move-result v13

    if-eqz v13, :cond_8

    invoke-virtual {v10}, Ljava/io/File;->length()J

    move-result-wide v13

    const-wide/16 v15, 0x0

    cmp-long v17, v13, v15

    if-lez v17, :cond_8

    .line 645
    const-wide/16 v13, 0x1e

    invoke-static {v13, v14}, Ljava/lang/Thread;->sleep(J)V

    .line 646
    invoke-static {v10}, Lcom/forge/live/TermuxBridgePlugin;->readFile(Ljava/io/File;)Ljava/lang/String;

    move-result-object v13

    .line 649
    .local v13, "raw":Ljava/lang/String;
    invoke-virtual {v10}, Ljava/io/File;->delete()Z

    .line 651
    invoke-virtual {v9}, Ljava/io/File;->delete()Z

    .line 652
    new-instance v14, Lorg/json/JSONObject;

    invoke-direct {v14, v13}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    return-object v14

    .line 654
    .end local v13    # "raw":Ljava/lang/String;
    :cond_8
    const-wide/16 v13, 0x96

    invoke-static {v13, v14}, Ljava/lang/Thread;->sleep(J)V

    goto :goto_3

    .line 657
    :cond_9
    invoke-virtual {v9}, Ljava/io/File;->delete()Z

    .line 658
    new-instance v13, Ljava/lang/Exception;

    new-instance v14, Ljava/lang/StringBuilder;

    invoke-direct {v14}, Ljava/lang/StringBuilder;-><init>()V

    const-string v15, "Timed out waiting for agent file result ("

    invoke-virtual {v14, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v14

    invoke-virtual {v14, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v14

    const-string v15, "ms)"

    invoke-virtual {v14, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v14

    invoke-virtual {v14}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v14

    invoke-direct {v13, v14}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v13
.end method

.method private agentHttpExec(Lorg/json/JSONObject;I)Lorg/json/JSONObject;
    .locals 9
    .param p1, "job"    # Lorg/json/JSONObject;
    .param p2, "timeoutMs"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 584
    const/16 v0, 0x2253

    invoke-direct {p0, v0}, Lcom/forge/live/TermuxBridgePlugin;->agentPortOpen(I)Z

    move-result v0

    if-eqz v0, :cond_6

    .line 585
    new-instance v0, Ljava/net/URL;

    const-string v1, "http://127.0.0.1:8787/exec"

    invoke-direct {v0, v1}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    .line 586
    .local v0, "url":Ljava/net/URL;
    invoke-virtual {v0}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object v1

    check-cast v1, Ljava/net/HttpURLConnection;

    .line 587
    .local v1, "conn":Ljava/net/HttpURLConnection;
    const/16 v2, 0x7d0

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V

    .line 588
    const/16 v2, 0x1388

    invoke-static {p2, v2}, Ljava/lang/Math;->max(II)I

    move-result v2

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    .line 589
    const-string v2, "POST"

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    .line 590
    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setDoOutput(Z)V

    .line 591
    const-string v2, "Content-Type"

    const-string v3, "application/json; charset=utf-8"

    invoke-virtual {v1, v2, v3}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 592
    invoke-virtual {p1}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v2

    sget-object v3, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {v2, v3}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v2

    .line 593
    .local v2, "payload":[B
    array-length v3, v2

    invoke-virtual {v1, v3}, Ljava/net/HttpURLConnection;->setFixedLengthStreamingMode(I)V

    .line 594
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getOutputStream()Ljava/io/OutputStream;

    move-result-object v3

    .line 595
    .local v3, "os":Ljava/io/OutputStream;
    :try_start_0
    invoke-virtual {v3, v2}, Ljava/io/OutputStream;->write([B)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 596
    if-eqz v3, :cond_0

    invoke-virtual {v3}, Ljava/io/OutputStream;->close()V

    .line 597
    .end local v3    # "os":Ljava/io/OutputStream;
    :cond_0
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result v3

    .line 598
    .local v3, "code":I
    const/16 v4, 0x190

    if-lt v3, v4, :cond_1

    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getErrorStream()Ljava/io/InputStream;

    move-result-object v5

    goto :goto_0

    :cond_1
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object v5

    :goto_0
    invoke-static {v5}, Lcom/forge/live/TermuxBridgePlugin;->readStream(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v5

    .line 599
    .local v5, "body":Ljava/lang/String;
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 600
    if-eqz v5, :cond_4

    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v6

    if-nez v6, :cond_4

    .line 603
    new-instance v6, Lorg/json/JSONObject;

    invoke-direct {v6, v5}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 604
    .local v6, "result":Lorg/json/JSONObject;
    if-lt v3, v4, :cond_3

    const-string v4, "stdout"

    invoke-virtual {v6, v4}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_2

    goto :goto_1

    .line 605
    :cond_2
    new-instance v4, Ljava/lang/Exception;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "Agent HTTP "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ": "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-direct {v4, v7}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v4

    .line 607
    :cond_3
    :goto_1
    return-object v6

    .line 601
    .end local v6    # "result":Lorg/json/JSONObject;
    :cond_4
    new-instance v4, Ljava/lang/Exception;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "Agent returned empty body (HTTP "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, ")"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-direct {v4, v6}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v4

    .line 594
    .end local v5    # "body":Ljava/lang/String;
    .local v3, "os":Ljava/io/OutputStream;
    :catchall_0
    move-exception v4

    if-eqz v3, :cond_5

    :try_start_1
    invoke-virtual {v3}, Ljava/io/OutputStream;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_2

    :catchall_1
    move-exception v5

    invoke-virtual {v4, v5}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_5
    :goto_2
    throw v4

    .line 609
    .end local v0    # "url":Ljava/net/URL;
    .end local v1    # "conn":Ljava/net/HttpURLConnection;
    .end local v2    # "payload":[B
    .end local v3    # "os":Ljava/io/OutputStream;
    :cond_6
    invoke-direct {p0, p1, p2}, Lcom/forge/live/TermuxBridgePlugin;->agentFileExec(Lorg/json/JSONObject;I)Lorg/json/JSONObject;

    move-result-object v0

    return-object v0
.end method

.method private agentPortOpen(I)Z
    .locals 3
    .param p1, "port"    # I

    .line 572
    :try_start_0
    new-instance v0, Ljava/net/Socket;

    invoke-direct {v0}, Ljava/net/Socket;-><init>()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 573
    .local v0, "s":Ljava/net/Socket;
    :try_start_1
    new-instance v1, Ljava/net/InetSocketAddress;

    const-string v2, "127.0.0.1"

    invoke-direct {v1, v2, p1}, Ljava/net/InetSocketAddress;-><init>(Ljava/lang/String;I)V

    const/16 v2, 0x190

    invoke-virtual {v0, v1, v2}, Ljava/net/Socket;->connect(Ljava/net/SocketAddress;I)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 574
    nop

    .line 575
    :try_start_2
    invoke-virtual {v0}, Ljava/net/Socket;->close()V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    .line 574
    const/4 v1, 0x1

    return v1

    .line 572
    :catchall_0
    move-exception v1

    :try_start_3
    invoke-virtual {v0}, Ljava/net/Socket;->close()V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v2

    :try_start_4
    invoke-virtual {v1, v2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .end local p1    # "port":I
    :goto_0
    throw v1
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_0

    .line 575
    .end local v0    # "s":Ljava/net/Socket;
    .restart local p1    # "port":I
    :catch_0
    move-exception v0

    .line 576
    .local v0, "e":Ljava/lang/Exception;
    const/4 v1, 0x0

    return v1
.end method

.method private baseStarted(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;)Lcom/getcapacitor/JSObject;
    .locals 4
    .param p1, "spec"    # Lcom/forge/live/TermuxBridgePlugin$CommandSpec;

    .line 993
    new-instance v0, Lcom/getcapacitor/JSArray;

    invoke-direct {v0}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 994
    .local v0, "argsOut":Lcom/getcapacitor/JSArray;
    iget-object v1, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->argsList:Ljava/util/ArrayList;

    invoke-virtual {v1}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    .local v2, "a":Ljava/lang/String;
    invoke-virtual {v0, v2}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    goto :goto_0

    .line 995
    .end local v2    # "a":Ljava/lang/String;
    :cond_0
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 996
    .local v1, "ret":Lcom/getcapacitor/JSObject;
    const-string v2, "started"

    const/4 v3, 0x1

    invoke-virtual {v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 997
    const-string v2, "commandPath"

    iget-object v3, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cmdPath:Ljava/lang/String;

    invoke-virtual {v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 998
    const-string v2, "args"

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 999
    const-string v2, "cwd"

    iget-object v3, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cwd:Ljava/lang/String;

    invoke-virtual {v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 1000
    const-string v2, "background"

    iget-boolean v3, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->background:Z

    invoke-virtual {v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 1001
    return-object v1
.end method

.method private buildRunIntent(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;Landroid/app/PendingIntent;)Landroid/content/Intent;
    .locals 4
    .param p1, "spec"    # Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    .param p2, "resultPi"    # Landroid/app/PendingIntent;

    .line 975
    new-instance v0, Landroid/content/Intent;

    invoke-direct {v0}, Landroid/content/Intent;-><init>()V

    .line 976
    .local v0, "intent":Landroid/content/Intent;
    const-string v1, "com.termux"

    const-string v2, "com.termux.app.RunCommandService"

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 977
    const-string v1, "com.termux.RUN_COMMAND"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 978
    const-string v1, "com.termux.RUN_COMMAND_PATH"

    iget-object v2, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cmdPath:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 979
    iget-object v1, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->argsList:Ljava/util/ArrayList;

    const/4 v2, 0x0

    new-array v3, v2, [Ljava/lang/String;

    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v1

    check-cast v1, [Ljava/lang/String;

    const-string v3, "com.termux.RUN_COMMAND_ARGUMENTS"

    invoke-virtual {v0, v3, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;[Ljava/lang/String;)Landroid/content/Intent;

    .line 980
    iget-object v1, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cwd:Ljava/lang/String;

    if-eqz v1, :cond_0

    iget-object v1, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cwd:Ljava/lang/String;

    goto :goto_0

    :cond_0
    const-string v1, "/data/data/com.termux/files/home"

    :goto_0
    const-string v3, "com.termux.RUN_COMMAND_WORKDIR"

    invoke-virtual {v0, v3, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 981
    const-string v1, "com.termux.RUN_COMMAND_BACKGROUND"

    iget-boolean v3, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->background:Z

    invoke-virtual {v0, v1, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 983
    const-string v1, "com.termux.RUN_COMMAND_SESSION_ACTION"

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 984
    iget-object v1, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->label:Ljava/lang/String;

    if-eqz v1, :cond_1

    iget-object v1, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->label:Ljava/lang/String;

    goto :goto_1

    :cond_1
    const-string v1, "Forge"

    :goto_1
    const-string v2, "com.termux.RUN_COMMAND_LABEL"

    invoke-virtual {v0, v2, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 985
    iget-object v1, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->description:Ljava/lang/String;

    if-eqz v1, :cond_2

    iget-object v1, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->description:Ljava/lang/String;

    goto :goto_2

    :cond_2
    const-string v1, ""

    :goto_2
    const-string v2, "com.termux.RUN_COMMAND_DESCRIPTION"

    invoke-virtual {v0, v2, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 986
    if-eqz p2, :cond_3

    .line 987
    const-string v1, "com.termux.RUN_COMMAND_PENDING_INTENT"

    invoke-virtual {v0, v1, p2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;

    .line 989
    :cond_3
    return-object v0
.end method

.method private builtinAgentFile(Ljava/lang/String;)Ljava/lang/String;
    .locals 1
    .param p1, "name"    # Ljava/lang/String;

    .line 767
    const-string v0, "install.sh"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 768
    const-string v0, "#!/data/data/com.termux/files/usr/bin/bash\nset -euo pipefail\nPREFIX=\"${PREFIX:-/data/data/com.termux/files/usr}\"\nHOME=\"${HOME:-/data/data/com.termux/files/home}\"\nBIN=\"$HOME/bin\"\nSRC_DIR=\"/storage/emulated/0/Download/ForgeBridge\"\nmkdir -p \"$BIN\" \"$SRC_DIR/inbox\" \"$SRC_DIR/outbox\"\nif [[ ! -f \"$SRC_DIR/forge-termux-agent\" ]]; then\n  echo \"Missing $SRC_DIR/forge-termux-agent \u2014 open Forge once to export it.\" >&2\n  exit 1\nfi\ncp -f \"$SRC_DIR/forge-termux-agent\" \"$BIN/forge-termux-agent\"\nchmod +x \"$BIN/forge-termux-agent\"\nif ! grep -q \'home/bin\' \"$HOME/.bashrc\" 2>/dev/null; then\n  echo \'export PATH=\"$HOME/bin:$PATH\"\' >> \"$HOME/.bashrc\"\nfi\nexport PATH=\"$BIN:$PATH\"\necho \"Installed: $BIN/forge-termux-agent\"\necho \"Start with: forge-termux-agent\"\necho \"Daemonize:  forge-termux-agent --daemon\"\n"

    return-object v0

    .line 791
    :cond_0
    const-string v0, "#!/data/data/com.termux/files/usr/bin/bash\n# Forge Termux agent \u2014 HTTP + file-queue bridge for apps (Play Termux OK)\nset -euo pipefail\nPORT=\"${FORGE_AGENT_PORT:-8787}\"\nROOT=\"${FORGE_BRIDGE_DIR:-/storage/emulated/0/Download/ForgeBridge}\"\nVERSION=\"1.0.0\"\nPREFIX=\"${PREFIX:-/data/data/com.termux/files/usr}\"\nHOME=\"${HOME:-/data/data/com.termux/files/home}\"\nINBOX=\"$ROOT/inbox\"\nOUTBOX=\"$ROOT/outbox\"\nmkdir -p \"$INBOX\" \"$OUTBOX\"\n\nif [[ \"${1:-}\" == \"--daemon\" ]]; then\n  shift\n  nohup \"$0\" \"$@\" >/dev/null 2>&1 &\n  echo \"forge-termux-agent daemon pid $! port $PORT\"\n  exit 0\nfi\n\ncommand -v python >/dev/null || command -v python3 >/dev/null || {\n  echo \"python required: pkg install python\" >&2\n  exit 1\n}\nPY=$(command -v python3 || command -v python)\n\nexport FORGE_AGENT_PORT=\"$PORT\" FORGE_BRIDGE_ROOT=\"$ROOT\" FORGE_AGENT_VERSION=\"$VERSION\"\nexport PREFIX HOME\nexec \"$PY\" - <<\'PY\'\nimport json, os, socketserver, subprocess, threading, time, traceback\nfrom http.server import BaseHTTPRequestHandler\nfrom pathlib import Path\n\nPORT = int(os.environ.get(\'FORGE_AGENT_PORT\', \'8787\'))\nROOT = Path(os.environ.get(\'FORGE_BRIDGE_ROOT\', \'/storage/emulated/0/Download/ForgeBridge\'))\nINBOX, OUTBOX = ROOT / \'inbox\', ROOT / \'outbox\'\nINBOX.mkdir(parents=True, exist_ok=True); OUTBOX.mkdir(parents=True, exist_ok=True)\nVERSION = os.environ.get(\'FORGE_AGENT_VERSION\', \'1.0.0\')\nHOME = os.environ.get(\'HOME\', \'/data/data/com.termux/files/home\')\nPREFIX = os.environ.get(\'PREFIX\', \'/data/data/com.termux/files/usr\')\nPID = os.getpid()\n\ndef status():\n    return {\'ok\': True, \'pid\': PID, \'version\': VERSION, \'home\': HOME, \'prefix\': PREFIX,\n            \'port\': PORT, \'root\': str(ROOT), \'ts\': int(time.time())}\n\ndef write_heartbeat():\n    try:\n        (ROOT / \'agent.json\').write_text(json.dumps(status()), encoding=\'utf-8\')\n    except Exception:\n        pass\n\ndef run_job(job):\n    t0 = time.time()\n    cwd = job.get(\'cwd\') or HOME\n    timeout = max(1, min(int(job.get(\'timeoutMs\') or 120000) / 1000.0, 600))\n    env = os.environ.copy()\n    env[\'HOME\'] = HOME\n    env[\'PREFIX\'] = PREFIX\n    env[\'PATH\'] = f\"{PREFIX}/bin:\" + env.get(\'PATH\', \'\')\n    try:\n        if job.get(\'script\'):\n            cmd = [f\'{PREFIX}/bin/bash\', \'-lc\', job[\'script\']]\n        else:\n            cmd_path = job.get(\'cmdPath\') or f\'{PREFIX}/bin/bash\'\n            args = job.get(\'args\') or []\n            if not isinstance(args, list): args = []\n            cmd = [cmd_path] + [str(a) for a in args]\n        if job.get(\'background\') and not job.get(\'wait\', True):\n            subprocess.Popen(cmd, cwd=cwd, env=env, start_new_session=True)\n            return {\'ok\': True, \'stdout\': \'\', \'stderr\': \'\', \'exitCode\': 0,\n                    \'note\': \'started background\', \'id\': job.get(\'id\')}\n        p = subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True,\n                           timeout=timeout, errors=\'replace\')\n        return {\'ok\': p.returncode == 0, \'stdout\': p.stdout or \'\', \'stderr\': p.stderr or \'\',\n                \'exitCode\': p.returncode, \'id\': job.get(\'id\'),\n                \'ms\': int((time.time() - t0) * 1000)}\n    except subprocess.TimeoutExpired as e:\n        out = (e.stdout or \'\') if isinstance(e.stdout, str) else \'\'\n        err = (e.stderr or \'\') if isinstance(e.stderr, str) else \'\'\n        return {\'ok\': False, \'stdout\': out, \'stderr\': err or \'timeout\',\n                \'exitCode\': 124, \'errmsg\': f\'timeout after {timeout}s\', \'id\': job.get(\'id\')}\n    except Exception as e:\n        return {\'ok\': False, \'stdout\': \'\', \'stderr\': traceback.format_exc(),\n                \'exitCode\': 1, \'errmsg\': str(e), \'id\': job.get(\'id\')}\n\nclass H(BaseHTTPRequestHandler):\n    def log_message(self, *a): pass\n    def _send(self, code, obj):\n        b = json.dumps(obj).encode(\'utf-8\')\n        self.send_response(code)\n        self.send_header(\'Content-Type\', \'application/json\')\n        self.send_header(\'Content-Length\', str(len(b)))\n        self.end_headers(); self.wfile.write(b)\n    def do_GET(self):\n        if self.path.startswith(\'/status\') or self.path == \'/\':\n            self._send(200, status())\n        else:\n            self._send(404, {\'ok\': False, \'errmsg\': \'not found\'})\n    def do_POST(self):\n        n = int(self.headers.get(\'Content-Length\') or 0)\n        raw = self.rfile.read(n).decode(\'utf-8\', \'replace\') if n else \'{}\'\n        try: job = json.loads(raw or \'{}\')\n        except Exception as e:\n            self._send(400, {\'ok\': False, \'errmsg\': f\'bad json: {e}\'}); return\n        if self.path.startswith(\'/exec\') or self.path.startswith(\'/run\'):\n            self._send(200, run_job(job))\n        else:\n            self._send(404, {\'ok\': False, \'errmsg\': \'not found\'})\n\ndef file_worker():\n    while True:\n        try:\n            write_heartbeat()\n            for f in sorted(INBOX.glob(\'*.json\')):\n                try:\n                    job = json.loads(f.read_text(encoding=\'utf-8\'))\n                except Exception:\n                    f.unlink(missing_ok=True); continue\n                res = run_job(job)\n                out = OUTBOX / f.name\n                out.write_text(json.dumps(res), encoding=\'utf-8\')\n                try: f.unlink()\n                except Exception: pass\n        except Exception:\n            pass\n        time.sleep(0.25)\n\nthreading.Thread(target=file_worker, daemon=True).start()\nwrite_heartbeat()\nclass ReusableTCPServer(socketserver.TCPServer):\n    allow_reuse_address = True\nprint(f\'forge-termux-agent v{VERSION} on 127.0.0.1:{PORT} root={ROOT}\', flush=True)\nwith ReusableTCPServer((\'127.0.0.1\', PORT), H) as httpd:\n    httpd.serve_forever()\nPY\n"

    return-object v0
.end method

.method private ensureReceiver()V
    .locals 4

    .line 114
    iget-boolean v0, p0, Lcom/forge/live/TermuxBridgePlugin;->receiverRegistered:Z

    if-eqz v0, :cond_0

    return-void

    .line 115
    :cond_0
    new-instance v0, Lcom/forge/live/TermuxBridgePlugin$1;

    invoke-direct {v0, p0}, Lcom/forge/live/TermuxBridgePlugin$1;-><init>(Lcom/forge/live/TermuxBridgePlugin;)V

    iput-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->execReceiver:Landroid/content/BroadcastReceiver;

    .line 159
    new-instance v0, Landroid/content/IntentFilter;

    const-string v1, "com.forge.live.TERMUX_EXEC_RESULT"

    invoke-direct {v0, v1}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V

    .line 161
    .local v0, "filter":Landroid/content/IntentFilter;
    :try_start_0
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x21

    if-lt v1, v2, :cond_1

    .line 162
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    iget-object v2, p0, Lcom/forge/live/TermuxBridgePlugin;->execReceiver:Landroid/content/BroadcastReceiver;

    const/4 v3, 0x4

    invoke-virtual {v1, v2, v0, v3}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;I)Landroid/content/Intent;

    goto :goto_0

    .line 164
    :cond_1
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    iget-object v2, p0, Lcom/forge/live/TermuxBridgePlugin;->execReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {v1, v2, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 166
    :goto_0
    const/4 v1, 0x1

    iput-boolean v1, p0, Lcom/forge/live/TermuxBridgePlugin;->receiverRegistered:Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    .line 167
    :catch_0
    move-exception v1

    :goto_1
    nop

    .line 168
    return-void
.end method

.method private execViaRunCommand(Lcom/getcapacitor/PluginCall;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;I)V
    .locals 10
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "spec"    # Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    .param p3, "timeoutMs"    # I

    .line 346
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->ensureReceiver()V

    .line 347
    iget-boolean v0, p0, Lcom/forge/live/TermuxBridgePlugin;->receiverRegistered:Z

    if-nez v0, :cond_0

    .line 349
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->ioPool:Ljava/util/concurrent/ExecutorService;

    new-instance v1, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;

    invoke-direct {v1, p0, p2, p3, p1}, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;-><init>(Lcom/forge/live/TermuxBridgePlugin;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;ILcom/getcapacitor/PluginCall;)V

    invoke-interface {v0, v1}, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V

    .line 358
    return-void

    .line 362
    :cond_0
    :try_start_0
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->tokenSeq:Ljava/util/concurrent/atomic/AtomicInteger;

    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicInteger;->getAndIncrement()I

    move-result v0

    .line 363
    .local v0, "token":I
    const/4 v1, 0x1

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v1

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->setKeepAlive(Ljava/lang/Boolean;)V

    .line 364
    iget-object v1, p0, Lcom/forge/live/TermuxBridgePlugin;->pendingExec:Ljava/util/Map;

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v1, v2, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 366
    new-instance v1, Landroid/content/Intent;

    const-string v2, "com.forge.live.TERMUX_EXEC_RESULT"

    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 367
    .local v1, "resultIntent":Landroid/content/Intent;
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;

    .line 368
    const-string v2, "forge_exec_token"

    invoke-virtual {v1, v2, v0}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 370
    const/high16 v2, 0x8000000

    .line 371
    .local v2, "flags":I
    sget v3, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v4, 0x1f

    if-lt v3, v4, :cond_1

    .line 372
    const/high16 v3, 0x2000000

    or-int/2addr v2, v3

    .line 375
    :cond_1
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-static {v3, v0, v1, v2}, Landroid/app/PendingIntent;->getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v3

    .line 376
    .local v3, "pi":Landroid/app/PendingIntent;
    invoke-direct {p0, p2, v3}, Lcom/forge/live/TermuxBridgePlugin;->buildRunIntent(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;Landroid/app/PendingIntent;)Landroid/content/Intent;

    move-result-object v4

    .line 377
    .local v4, "intent":Landroid/content/Intent;
    invoke-direct {p0, v4}, Lcom/forge/live/TermuxBridgePlugin;->startTermuxService(Landroid/content/Intent;)V

    .line 379
    move v5, p3

    .line 380
    .local v5, "t":I
    iget-object v6, p0, Lcom/forge/live/TermuxBridgePlugin;->mainHandler:Landroid/os/Handler;

    new-instance v7, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda5;

    invoke-direct {v7, p0, v0, v5}, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda5;-><init>(Lcom/forge/live/TermuxBridgePlugin;II)V

    int-to-long v8, v5

    invoke-virtual {v6, v7, v8, v9}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 391
    nop

    .end local v0    # "token":I
    .end local v1    # "resultIntent":Landroid/content/Intent;
    .end local v2    # "flags":I
    .end local v3    # "pi":Landroid/app/PendingIntent;
    .end local v4    # "intent":Landroid/content/Intent;
    .end local v5    # "t":I
    goto :goto_0

    .line 389
    :catch_0
    move-exception v0

    .line 390
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Termux RUN_COMMAND exec failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    goto :goto_0

    .line 387
    .end local v0    # "e":Ljava/lang/Exception;
    :catch_1
    move-exception v0

    .line 388
    .local v0, "se":Ljava/lang/SecurityException;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Termux blocked RUN_COMMAND. "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/SecurityException;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 391
    .end local v0    # "se":Ljava/lang/SecurityException;
    nop

    .line 392
    :goto_0
    return-void
.end method

.method private exportAgentFiles(Z)Ljava/io/File;
    .locals 5
    .param p1, "force"    # Z
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 718
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->getBridgeDir()Ljava/io/File;

    move-result-object v0

    .line 719
    .local v0, "dir":Ljava/io/File;
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-nez v1, :cond_1

    invoke-virtual {v0}, Ljava/io/File;->mkdirs()Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_0

    .line 720
    :cond_0
    new-instance v1, Ljava/lang/Exception;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Cannot create "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V

    throw v1

    .line 722
    :cond_1
    :goto_0
    new-instance v1, Ljava/io/File;

    const-string v2, "inbox"

    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 723
    .local v1, "inbox":Ljava/io/File;
    new-instance v2, Ljava/io/File;

    const-string v3, "outbox"

    invoke-direct {v2, v0, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 725
    .local v2, "outbox":Ljava/io/File;
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    .line 727
    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z

    .line 729
    const-string v3, "forge-termux-agent"

    invoke-direct {p0, v0, v3, p1}, Lcom/forge/live/TermuxBridgePlugin;->writeAssetOrBuiltin(Ljava/io/File;Ljava/lang/String;Z)V

    .line 730
    const-string v3, "install.sh"

    invoke-direct {p0, v0, v3, p1}, Lcom/forge/live/TermuxBridgePlugin;->writeAssetOrBuiltin(Ljava/io/File;Ljava/lang/String;Z)V

    .line 733
    new-instance v3, Ljava/io/File;

    const-string v4, "README.txt"

    invoke-direct {v3, v0, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 734
    .local v3, "readme":Ljava/io/File;
    if-nez p1, :cond_2

    invoke-virtual {v3}, Ljava/io/File;->exists()Z

    move-result v4

    if-nez v4, :cond_3

    .line 735
    :cond_2
    const-string v4, "Forge \u2194 Termux bridge (Google Play Termux compatible)\n=====================================================\nPlay Store Termux does NOT include RUN_COMMAND.\nRun this once in Termux (after termux-setup-storage):\n\n  bash /storage/emulated/0/Download/ForgeBridge/install.sh\n  forge-termux-agent\n\nKeep the agent session open (or run: forge-termux-agent --daemon).\nThen use Forge \u2192 AI \u2192 Device bridges \u2192 Test Termux.\n"

    invoke-static {v3, v4}, Lcom/forge/live/TermuxBridgePlugin;->writeFile(Ljava/io/File;Ljava/lang/String;)V

    .line 745
    :cond_3
    return-object v0
.end method

.method private getBridgeDir()Ljava/io/File;
    .locals 5

    .line 699
    sget-object v0, Landroid/os/Environment;->DIRECTORY_DOWNLOADS:Ljava/lang/String;

    invoke-static {v0}, Landroid/os/Environment;->getExternalStoragePublicDirectory(Ljava/lang/String;)Ljava/io/File;

    move-result-object v0

    .line 700
    .local v0, "dl":Ljava/io/File;
    new-instance v1, Ljava/io/File;

    const-string v2, "ForgeBridge"

    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 701
    .local v1, "dir":Ljava/io/File;
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    move-result v3

    if-nez v3, :cond_0

    .line 703
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    .line 706
    :cond_0
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    move-result v3

    if-eqz v3, :cond_1

    invoke-virtual {v1}, Ljava/io/File;->canWrite()Z

    move-result v3

    if-nez v3, :cond_2

    .line 707
    :cond_1
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v3

    const/4 v4, 0x0

    invoke-virtual {v3, v4}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;

    move-result-object v3

    .line 708
    .local v3, "ext":Ljava/io/File;
    if-eqz v3, :cond_2

    .line 709
    new-instance v4, Ljava/io/File;

    invoke-direct {v4, v3, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    move-object v1, v4

    .line 711
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    .line 714
    .end local v3    # "ext":Ljava/io/File;
    :cond_2
    return-object v1
.end method

.method private isRunCommandSupported()Z
    .locals 8

    .line 510
    const-string v0, "com.termux.app.RunCommandService"

    const-string v1, "com.termux"

    const/4 v2, 0x0

    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-virtual {v3}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v3

    .line 511
    .local v3, "pm":Landroid/content/pm/PackageManager;
    new-instance v4, Landroid/content/Intent;

    const-string v5, "com.termux.RUN_COMMAND"

    invoke-direct {v4, v5}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 512
    .local v4, "intent":Landroid/content/Intent;
    invoke-virtual {v4, v1, v0}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 514
    sget v5, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v6, 0x21

    if-lt v5, v6, :cond_0

    .line 515
    const-wide/16 v5, 0x0

    invoke-static {v5, v6}, Landroid/content/pm/PackageManager$ResolveInfoFlags;->of(J)Landroid/content/pm/PackageManager$ResolveInfoFlags;

    move-result-object v5

    invoke-virtual {v3, v4, v5}, Landroid/content/pm/PackageManager;->queryIntentServices(Landroid/content/Intent;Landroid/content/pm/PackageManager$ResolveInfoFlags;)Ljava/util/List;

    move-result-object v5

    .local v5, "list":Ljava/util/List;, "Ljava/util/List<Landroid/content/pm/ResolveInfo;>;"
    goto :goto_0

    .line 517
    .end local v5    # "list":Ljava/util/List;, "Ljava/util/List<Landroid/content/pm/ResolveInfo;>;"
    :cond_0
    invoke-virtual {v3, v4, v2}, Landroid/content/pm/PackageManager;->queryIntentServices(Landroid/content/Intent;I)Ljava/util/List;

    move-result-object v5

    .line 519
    .restart local v5    # "list":Ljava/util/List;, "Ljava/util/List<Landroid/content/pm/ResolveInfo;>;"
    :goto_0
    const/4 v6, 0x1

    if-eqz v5, :cond_1

    invoke-interface {v5}, Ljava/util/List;->isEmpty()Z

    move-result v7

    if-nez v7, :cond_1

    return v6

    .line 522
    :cond_1
    new-instance v7, Landroid/content/Intent;

    invoke-direct {v7}, Landroid/content/Intent;-><init>()V

    move-object v4, v7

    .line 523
    invoke-virtual {v4, v1, v0}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 524
    invoke-virtual {v3, v4, v2}, Landroid/content/pm/PackageManager;->resolveService(Landroid/content/Intent;I)Landroid/content/pm/ResolveInfo;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 525
    .local v0, "ri":Landroid/content/pm/ResolveInfo;
    if-eqz v0, :cond_2

    const/4 v2, 0x1

    :cond_2
    return v2

    .line 526
    .end local v0    # "ri":Landroid/content/pm/ResolveInfo;
    .end local v3    # "pm":Landroid/content/pm/PackageManager;
    .end local v4    # "intent":Landroid/content/Intent;
    .end local v5    # "list":Ljava/util/List;, "Ljava/util/List<Landroid/content/pm/ResolveInfo;>;"
    :catch_0
    move-exception v0

    .line 527
    .local v0, "e":Ljava/lang/Exception;
    return v2
.end method

.method private isTermuxInstalled()Z
    .locals 3

    .line 501
    const/4 v0, 0x0

    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v1

    const-string v2, "com.termux"

    invoke-virtual {v1, v2, v0}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;
    :try_end_0
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_0 .. :try_end_0} :catch_0

    .line 502
    const/4 v0, 0x1

    return v0

    .line 503
    :catch_0
    move-exception v1

    .line 504
    .local v1, "e":Landroid/content/pm/PackageManager$NameNotFoundException;
    return v0
.end method

.method private jobFromSpec(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;IZ)Lorg/json/JSONObject;
    .locals 4
    .param p1, "spec"    # Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    .param p2, "timeoutMs"    # I
    .param p3, "background"    # Z
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 679
    new-instance v0, Lorg/json/JSONObject;

    invoke-direct {v0}, Lorg/json/JSONObject;-><init>()V

    .line 680
    .local v0, "job":Lorg/json/JSONObject;
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v1

    invoke-virtual {v1}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v1

    const-string v2, "id"

    invoke-virtual {v0, v2, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 681
    const-string v1, "cmdPath"

    iget-object v2, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cmdPath:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 682
    new-instance v1, Lorg/json/JSONArray;

    invoke-direct {v1}, Lorg/json/JSONArray;-><init>()V

    .line 683
    .local v1, "args":Lorg/json/JSONArray;
    iget-object v2, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->argsList:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    .local v3, "a":Ljava/lang/String;
    invoke-virtual {v1, v3}, Lorg/json/JSONArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    goto :goto_0

    .line 684
    .end local v3    # "a":Ljava/lang/String;
    :cond_0
    const-string v2, "args"

    invoke-virtual {v0, v2, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 685
    iget-object v2, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cwd:Ljava/lang/String;

    if-eqz v2, :cond_1

    iget-object v2, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cwd:Ljava/lang/String;

    goto :goto_1

    :cond_1
    const-string v2, "/data/data/com.termux/files/home"

    :goto_1
    const-string v3, "cwd"

    invoke-virtual {v0, v3, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 686
    const-string v2, "timeoutMs"

    invoke-virtual {v0, v2, p2}, Lorg/json/JSONObject;->put(Ljava/lang/String;I)Lorg/json/JSONObject;

    .line 687
    const-string v2, "background"

    invoke-virtual {v0, v2, p3}, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;

    .line 688
    const-string v2, "label"

    iget-object v3, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->label:Ljava/lang/String;

    invoke-virtual {v0, v2, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 690
    iget-object v2, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->argsList:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v2

    const/4 v3, 0x2

    if-ne v2, v3, :cond_2

    iget-object v2, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->argsList:Ljava/util/ArrayList;

    const/4 v3, 0x0

    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v2

    const-string v3, "-lc"

    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    .line 691
    iget-object v2, p1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->argsList:Ljava/util/ArrayList;

    const/4 v3, 0x1

    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v2

    const-string v3, "script"

    invoke-virtual {v0, v3, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 693
    :cond_2
    return-object v0
.end method

.method private jsFromAgentResult(Lorg/json/JSONObject;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    .locals 5
    .param p1, "result"    # Lorg/json/JSONObject;
    .param p2, "bridge"    # Ljava/lang/String;

    .line 662
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 663
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    const-string v1, "exitCode"

    const/4 v2, 0x1

    invoke-virtual {p1, v1, v2}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;I)I

    move-result v3

    if-nez v3, :cond_0

    goto :goto_0

    :cond_0
    const/4 v2, 0x0

    :goto_0
    const-string v3, "ok"

    invoke-virtual {p1, v3, v2}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result v2

    invoke-virtual {v0, v3, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 664
    const-string v2, "bridge"

    invoke-virtual {v0, v2, p2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 665
    const-string v2, "stdout"

    const-string v3, ""

    invoke-virtual {p1, v2, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v0, v2, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 666
    const-string v2, "stderr"

    invoke-virtual {p1, v2, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 667
    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v2

    if-nez v2, :cond_1

    .line 668
    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;)I

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    goto :goto_1

    .line 670
    :cond_1
    sget-object v2, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 672
    :goto_1
    const-string v1, "err"

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_2

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v2

    if-nez v2, :cond_2

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;)I

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 673
    :cond_2
    const-string v1, "errmsg"

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_3

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->isNull(Ljava/lang/String;)Z

    move-result v2

    if-nez v2, :cond_3

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 674
    :cond_3
    const-string v1, "note"

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_4

    invoke-virtual {p1, v1}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 675
    :cond_4
    return-object v0
.end method

.method private synthetic lambda$exec$4(Lcom/getcapacitor/PluginCall;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;I)V
    .locals 0
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "spec"    # Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    .param p3, "timeoutMs"    # I

    .line 302
    invoke-direct {p0, p1, p2, p3}, Lcom/forge/live/TermuxBridgePlugin;->execViaRunCommand(Lcom/getcapacitor/PluginCall;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;I)V

    return-void
.end method

.method private synthetic lambda$exec$5(Lcom/getcapacitor/PluginCall;)V
    .locals 7
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 284
    const-string v0, "agent"

    :try_start_0
    invoke-direct {p0, p1}, Lcom/forge/live/TermuxBridgePlugin;->parseCommand(Lcom/getcapacitor/PluginCall;)Lcom/forge/live/TermuxBridgePlugin$CommandSpec;

    move-result-object v1

    .line 285
    .local v1, "spec":Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    const-string v2, "background"

    const/4 v3, 0x0

    invoke-virtual {p1, v2, v3}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v2

    if-nez v2, :cond_0

    .line 286
    const/4 v2, 0x1

    iput-boolean v2, v1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->background:Z

    .line 288
    :cond_0
    const-string v2, "timeoutMs"

    const v3, 0x1d4c0

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-virtual {p1, v2, v3}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    .line 289
    .local v2, "tMs":I
    const/16 v3, 0xbb8

    if-ge v2, v3, :cond_1

    const/16 v2, 0xbb8

    .line 290
    :cond_1
    const v3, 0x927c0

    if-le v2, v3, :cond_2

    const v2, 0x927c0

    .line 291
    :cond_2
    move v3, v2

    .line 293
    .local v3, "timeoutMs":I
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->pickBridge()Ljava/lang/String;

    move-result-object v4

    .line 294
    .local v4, "bridge":Ljava/lang/String;
    invoke-virtual {v0, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    const/4 v6, 0x0

    if-nez v5, :cond_5

    const-string v5, "none"

    invoke-virtual {v5, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_3

    const/16 v5, 0x2253

    invoke-direct {p0, v5}, Lcom/forge/live/TermuxBridgePlugin;->agentPortOpen(I)Z

    move-result v5

    if-eqz v5, :cond_3

    goto :goto_0

    .line 301
    :cond_3
    const-string v0, "run_command"

    invoke-virtual {v0, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_4

    .line 302
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->mainHandler:Landroid/os/Handler;

    new-instance v5, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;

    invoke-direct {v5, p0, p1, v1, v3}, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;-><init>(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;I)V

    invoke-virtual {v0, v5}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_0
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_2
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 303
    return-void

    .line 308
    :cond_4
    :try_start_1
    invoke-direct {p0, v1, v3, v6}, Lcom/forge/live/TermuxBridgePlugin;->jobFromSpec(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;IZ)Lorg/json/JSONObject;

    move-result-object v0

    .line 309
    .local v0, "job":Lorg/json/JSONObject;
    invoke-direct {p0, v0, v3}, Lcom/forge/live/TermuxBridgePlugin;->agentFileExec(Lorg/json/JSONObject;I)Lorg/json/JSONObject;

    move-result-object v5

    .line 310
    .local v5, "result":Lorg/json/JSONObject;
    const-string v6, "file"

    invoke-direct {p0, v5, v6}, Lcom/forge/live/TermuxBridgePlugin;->jsFromAgentResult(Lorg/json/JSONObject;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v6

    invoke-virtual {p1, v6}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catch Ljava/lang/IllegalArgumentException; {:try_start_1 .. :try_end_1} :catch_2

    .line 311
    return-void

    .line 312
    .end local v0    # "job":Lorg/json/JSONObject;
    .end local v5    # "result":Lorg/json/JSONObject;
    :catch_0
    move-exception v0

    .line 313
    .local v0, "fileEx":Ljava/lang/Exception;
    :try_start_2
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->noBridgeMessage()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, " Detail: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {p1, v5}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .end local v0    # "fileEx":Ljava/lang/Exception;
    .end local v1    # "spec":Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    .end local v2    # "tMs":I
    .end local v3    # "timeoutMs":I
    .end local v4    # "bridge":Ljava/lang/String;
    goto :goto_1

    .line 295
    .restart local v1    # "spec":Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    .restart local v2    # "tMs":I
    .restart local v3    # "timeoutMs":I
    .restart local v4    # "bridge":Ljava/lang/String;
    :cond_5
    :goto_0
    invoke-direct {p0, v1, v3, v6}, Lcom/forge/live/TermuxBridgePlugin;->jobFromSpec(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;IZ)Lorg/json/JSONObject;

    move-result-object v5

    .line 296
    .local v5, "job":Lorg/json/JSONObject;
    add-int/lit16 v6, v3, 0x1388

    invoke-direct {p0, v5, v6}, Lcom/forge/live/TermuxBridgePlugin;->agentHttpExec(Lorg/json/JSONObject;I)Lorg/json/JSONObject;

    move-result-object v6

    .line 297
    .local v6, "result":Lorg/json/JSONObject;
    invoke-direct {p0, v6, v0}, Lcom/forge/live/TermuxBridgePlugin;->jsFromAgentResult(Lorg/json/JSONObject;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_2
    .catch Ljava/lang/IllegalArgumentException; {:try_start_2 .. :try_end_2} :catch_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    .line 298
    return-void

    .line 317
    .end local v1    # "spec":Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    .end local v2    # "tMs":I
    .end local v3    # "timeoutMs":I
    .end local v4    # "bridge":Ljava/lang/String;
    .end local v5    # "job":Lorg/json/JSONObject;
    .end local v6    # "result":Lorg/json/JSONObject;
    :catch_1
    move-exception v0

    .line 318
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Termux exec failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\n"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->noBridgeMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    goto :goto_2

    .line 315
    .end local v0    # "e":Ljava/lang/Exception;
    :catch_2
    move-exception v0

    .line 316
    .local v0, "iae":Ljava/lang/IllegalArgumentException;
    invoke-virtual {v0}, Ljava/lang/IllegalArgumentException;->getMessage()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 319
    .end local v0    # "iae":Ljava/lang/IllegalArgumentException;
    :goto_1
    nop

    .line 320
    :goto_2
    return-void
.end method

.method private synthetic lambda$execViaRunCommand$6(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;ILcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "spec"    # Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    .param p2, "timeoutMs"    # I
    .param p3, "call"    # Lcom/getcapacitor/PluginCall;

    .line 351
    const/4 v0, 0x0

    :try_start_0
    invoke-direct {p0, p1, p2, v0}, Lcom/forge/live/TermuxBridgePlugin;->jobFromSpec(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;IZ)Lorg/json/JSONObject;

    move-result-object v0

    .line 352
    .local v0, "job":Lorg/json/JSONObject;
    add-int/lit16 v1, p2, 0x1388

    invoke-direct {p0, v0, v1}, Lcom/forge/live/TermuxBridgePlugin;->agentHttpExec(Lorg/json/JSONObject;I)Lorg/json/JSONObject;

    move-result-object v1

    .line 353
    .local v1, "result":Lorg/json/JSONObject;
    const-string v2, "agent"

    invoke-direct {p0, v1, v2}, Lcom/forge/live/TermuxBridgePlugin;->jsFromAgentResult(Lorg/json/JSONObject;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v2

    invoke-virtual {p3, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 356
    .end local v0    # "job":Lorg/json/JSONObject;
    .end local v1    # "result":Lorg/json/JSONObject;
    goto :goto_0

    .line 354
    :catch_0
    move-exception v0

    .line 355
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Cannot register Termux result receiver and agent unavailable: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p3, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 357
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method private synthetic lambda$execViaRunCommand$7(II)V
    .locals 3
    .param p1, "token"    # I
    .param p2, "t"    # I

    .line 381
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->pendingExec:Ljava/util/Map;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/getcapacitor/PluginCall;

    .line 382
    .local v0, "c":Lcom/getcapacitor/PluginCall;
    if-eqz v0, :cond_0

    .line 383
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Termux RUN_COMMAND exec timed out after "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "ms. If you use Google Play Termux, RUN_COMMAND is not available \u2014 start forge-termux-agent instead."

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 386
    :cond_0
    return-void
.end method

.method private synthetic lambda$installAgent$2(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 210
    const/4 v0, 0x1

    :try_start_0
    invoke-direct {p0, v0}, Lcom/forge/live/TermuxBridgePlugin;->exportAgentFiles(Z)Ljava/io/File;

    move-result-object v1

    .line 211
    .local v1, "dir":Ljava/io/File;
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 212
    .local v2, "o":Lcom/getcapacitor/JSObject;
    const-string v3, "ok"

    invoke-virtual {v2, v3, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 213
    const-string v0, "bridgeDir"

    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 214
    const-string v0, "agentPath"

    new-instance v3, Ljava/io/File;

    const-string v4, "forge-termux-agent"

    invoke-direct {v3, v1, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v3}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 215
    const-string v0, "installPath"

    new-instance v3, Ljava/io/File;

    const-string v4, "install.sh"

    invoke-direct {v3, v1, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v3}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 216
    const-string v0, "port"

    const/16 v3, 0x2253

    invoke-virtual {v2, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 217
    const-string v0, "command"

    const-string v3, "bash \"/storage/emulated/0/Download/ForgeBridge/install.sh\" && forge-termux-agent"

    invoke-virtual {v2, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 219
    const-string v0, "note"

    const-string v3, "In Termux run the command above (needs termux-setup-storage once). Keep the agent running."

    invoke-virtual {v2, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 221
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 224
    .end local v1    # "dir":Ljava/io/File;
    .end local v2    # "o":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 222
    :catch_0
    move-exception v0

    .line 223
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "installAgent failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 225
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method private synthetic lambda$isAvailable$1(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 174
    :try_start_0
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->probeStatus()Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 177
    goto :goto_0

    .line 175
    :catch_0
    move-exception v0

    .line 176
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "isAvailable failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 178
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method private synthetic lambda$load$0()V
    .locals 1

    .line 109
    const/4 v0, 0x0

    :try_start_0
    invoke-direct {p0, v0}, Lcom/forge/live/TermuxBridgePlugin;->exportAgentFiles(Z)Ljava/io/File;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 110
    :goto_0
    return-void
.end method

.method private synthetic lambda$run$3(Lcom/getcapacitor/PluginCall;)V
    .locals 8
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 239
    const-string v0, "agent"

    const-string v1, "run_command"

    :try_start_0
    invoke-direct {p0, p1}, Lcom/forge/live/TermuxBridgePlugin;->parseCommand(Lcom/getcapacitor/PluginCall;)Lcom/forge/live/TermuxBridgePlugin$CommandSpec;

    move-result-object v2

    .line 240
    .local v2, "spec":Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->pickBridge()Ljava/lang/String;

    move-result-object v3

    .line 241
    .local v3, "bridge":Ljava/lang/String;
    invoke-virtual {v1, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4
    :try_end_0
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_2
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    const-string v5, "note"

    const-string v6, "bridge"

    if-eqz v4, :cond_0

    .line 242
    const/4 v0, 0x0

    :try_start_1
    invoke-direct {p0, v2, v0}, Lcom/forge/live/TermuxBridgePlugin;->buildRunIntent(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;Landroid/app/PendingIntent;)Landroid/content/Intent;

    move-result-object v0

    .line 243
    .local v0, "intent":Landroid/content/Intent;
    invoke-direct {p0, v0}, Lcom/forge/live/TermuxBridgePlugin;->startTermuxService(Landroid/content/Intent;)V

    .line 244
    invoke-direct {p0, v2}, Lcom/forge/live/TermuxBridgePlugin;->baseStarted(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;)Lcom/getcapacitor/JSObject;

    move-result-object v4

    .line 245
    .local v4, "ret":Lcom/getcapacitor/JSObject;
    invoke-virtual {v4, v6, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 246
    const-string v1, "Command dispatched via RUN_COMMAND. Stdout is NOT captured \u2014 use termux.exec()."

    invoke-virtual {v4, v5, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 247
    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 248
    return-void

    .line 250
    .end local v0    # "intent":Landroid/content/Intent;
    .end local v4    # "ret":Lcom/getcapacitor/JSObject;
    :cond_0
    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 252
    const v1, 0x1d4c0

    const/4 v4, 0x1

    invoke-direct {p0, v2, v1, v4}, Lcom/forge/live/TermuxBridgePlugin;->jobFromSpec(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;IZ)Lorg/json/JSONObject;

    move-result-object v1

    .line 253
    .local v1, "job":Lorg/json/JSONObject;
    const-string v4, "wait"

    const/4 v7, 0x0

    invoke-virtual {v1, v4, v7}, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;

    .line 254
    const/16 v4, 0x3a98

    invoke-direct {p0, v1, v4}, Lcom/forge/live/TermuxBridgePlugin;->agentHttpExec(Lorg/json/JSONObject;I)Lorg/json/JSONObject;

    .line 255
    invoke-direct {p0, v2}, Lcom/forge/live/TermuxBridgePlugin;->baseStarted(Lcom/forge/live/TermuxBridgePlugin$CommandSpec;)Lcom/getcapacitor/JSObject;

    move-result-object v4

    .line 256
    .restart local v4    # "ret":Lcom/getcapacitor/JSObject;
    invoke-virtual {v4, v6, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 257
    const-string v0, "Command accepted by forge-termux-agent. Stdout not returned \u2014 use termux.exec()."

    invoke-virtual {v4, v5, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 258
    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 259
    return-void

    .line 261
    .end local v1    # "job":Lorg/json/JSONObject;
    .end local v4    # "ret":Lcom/getcapacitor/JSObject;
    :cond_1
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->noBridgeMessage()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/lang/IllegalArgumentException; {:try_start_1 .. :try_end_1} :catch_2
    .catch Ljava/lang/SecurityException; {:try_start_1 .. :try_end_1} :catch_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .end local v2    # "spec":Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    .end local v3    # "bridge":Ljava/lang/String;
    goto :goto_0

    .line 266
    :catch_0
    move-exception v0

    .line 267
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Termux run failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    goto :goto_1

    .line 264
    .end local v0    # "e":Ljava/lang/Exception;
    :catch_1
    move-exception v0

    .line 265
    .local v0, "se":Ljava/lang/SecurityException;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Termux blocked RUN_COMMAND. "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/SecurityException;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " \u2014 "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->noBridgeMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .end local v0    # "se":Ljava/lang/SecurityException;
    goto :goto_0

    .line 262
    :catch_2
    move-exception v0

    .line 263
    .local v0, "iae":Ljava/lang/IllegalArgumentException;
    invoke-virtual {v0}, Ljava/lang/IllegalArgumentException;->getMessage()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 268
    .end local v0    # "iae":Ljava/lang/IllegalArgumentException;
    :goto_0
    nop

    .line 269
    :goto_1
    return-void
.end method

.method private noBridgeMessage()Ljava/lang/String;
    .locals 1

    .line 490
    const-string v0, "No Termux bridge available. This device has Google Play Termux (no RUN_COMMAND). In Termux run:\n  bash /storage/emulated/0/Download/ForgeBridge/install.sh\n  forge-termux-agent\nLeave the agent running, then retry. Or install F-Droid/GitHub Termux which supports RUN_COMMAND + allow-external-apps=true."

    return-object v0
.end method

.method private static nz(Ljava/lang/String;)Ljava/lang/String;
    .locals 1
    .param p0, "s"    # Ljava/lang/String;

    .line 1011
    if-eqz p0, :cond_0

    move-object v0, p0

    goto :goto_0

    :cond_0
    const-string v0, ""

    :goto_0
    return-object v0
.end method

.method private parseCommand(Lcom/getcapacitor/PluginCall;)Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    .locals 11
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 941
    const-string v0, "script"

    const/4 v1, 0x0

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 942
    .local v0, "script":Ljava/lang/String;
    const-string v2, "command"

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 943
    .local v2, "command":Ljava/lang/String;
    const-string v3, "cwd"

    const-string v4, "/data/data/com.termux/files/home"

    invoke-virtual {p1, v3, v4}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 944
    .local v3, "cwd":Ljava/lang/String;
    sget-object v5, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    const/4 v6, 0x1

    invoke-static {v6}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v7

    const-string v8, "background"

    invoke-virtual {p1, v8, v7}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v7

    invoke-virtual {v5, v7}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v5

    xor-int/2addr v5, v6

    .line 945
    .local v5, "background":Z
    const-string v6, "label"

    const-string v7, "Forge"

    invoke-virtual {p1, v6, v7}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    .line 946
    .local v6, "label":Ljava/lang/String;
    const-string v8, "description"

    const-string v9, "Command from Forge"

    invoke-virtual {p1, v8, v9}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    .line 948
    .local v8, "description":Ljava/lang/String;
    new-instance v9, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;

    invoke-direct {v9, v1}, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;-><init>(Lcom/forge/live/TermuxBridgePlugin$CommandSpec-IA;)V

    move-object v1, v9

    .line 949
    .local v1, "spec":Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
    if-eqz v3, :cond_0

    move-object v4, v3

    :cond_0
    iput-object v4, v1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cwd:Ljava/lang/String;

    .line 950
    iput-boolean v5, v1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->background:Z

    .line 951
    if-eqz v6, :cond_1

    move-object v7, v6

    :cond_1
    iput-object v7, v1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->label:Ljava/lang/String;

    .line 952
    if-eqz v8, :cond_2

    move-object v4, v8

    goto :goto_0

    :cond_2
    const-string v4, ""

    :goto_0
    iput-object v4, v1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->description:Ljava/lang/String;

    .line 954
    if-eqz v0, :cond_3

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-nez v4, :cond_3

    .line 955
    const-string v4, "/data/data/com.termux/files/usr/bin/bash"

    iput-object v4, v1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cmdPath:Ljava/lang/String;

    .line 956
    iget-object v4, v1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->argsList:Ljava/util/ArrayList;

    const-string v7, "-lc"

    invoke-virtual {v4, v7}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 957
    iget-object v4, v1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->argsList:Ljava/util/ArrayList;

    invoke-virtual {v4, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_3

    .line 958
    :cond_3
    if-eqz v2, :cond_5

    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-nez v4, :cond_5

    .line 959
    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-direct {p0, v4}, Lcom/forge/live/TermuxBridgePlugin;->resolveCommandPath(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    iput-object v4, v1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cmdPath:Ljava/lang/String;

    .line 960
    new-instance v4, Lcom/getcapacitor/JSArray;

    invoke-direct {v4}, Lcom/getcapacitor/JSArray;-><init>()V

    const-string v7, "args"

    invoke-virtual {p1, v7, v4}, Lcom/getcapacitor/PluginCall;->getArray(Ljava/lang/String;Lcom/getcapacitor/JSArray;)Lcom/getcapacitor/JSArray;

    move-result-object v4

    .line 961
    .local v4, "args":Lcom/getcapacitor/JSArray;
    if-eqz v4, :cond_4

    .line 962
    const/4 v7, 0x0

    .local v7, "i":I
    :goto_1
    invoke-virtual {v4}, Lcom/getcapacitor/JSArray;->length()I

    move-result v9

    if-ge v7, v9, :cond_4

    .line 964
    :try_start_0
    iget-object v9, v1, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->argsList:Ljava/util/ArrayList;

    invoke-virtual {v4, v7}, Lcom/getcapacitor/JSArray;->getString(I)Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v9, v10}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_2

    .line 965
    :catch_0
    move-exception v9

    :goto_2
    nop

    .line 962
    add-int/lit8 v7, v7, 0x1

    goto :goto_1

    .line 968
    .end local v4    # "args":Lcom/getcapacitor/JSArray;
    .end local v7    # "i":I
    :cond_4
    nop

    .line 971
    :goto_3
    return-object v1

    .line 969
    :cond_5
    new-instance v4, Ljava/lang/IllegalArgumentException;

    const-string v7, "Provide \'script\' (bash -lc) or \'command\' + optional \'args\'"

    invoke-direct {v4, v7}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v4
.end method

.method private pickBridge()Ljava/lang/String;
    .locals 3

    .line 482
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->isRunCommandSupported()Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "run_command"

    return-object v0

    .line 483
    :cond_0
    const/16 v0, 0x2253

    invoke-direct {p0, v0}, Lcom/forge/live/TermuxBridgePlugin;->agentPortOpen(I)Z

    move-result v0

    const-string v1, "agent"

    if-eqz v0, :cond_1

    return-object v1

    .line 484
    :cond_1
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->probeAgent()Lcom/getcapacitor/JSObject;

    move-result-object v0

    .line 485
    .local v0, "a":Lcom/getcapacitor/JSObject;
    if-eqz v0, :cond_2

    const-string v2, "running"

    invoke-virtual {v0, v2}, Lcom/getcapacitor/JSObject;->getBool(Ljava/lang/String;)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v2

    if-eqz v2, :cond_2

    return-object v1

    .line 486
    :cond_2
    const-string v1, "none"

    return-object v1
.end method

.method private probeAgent()Lcom/getcapacitor/JSObject;
    .locals 13

    .line 532
    const-string v0, "prefix"

    const-string v1, "home"

    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 533
    .local v2, "o":Lcom/getcapacitor/JSObject;
    const/4 v3, 0x0

    const-string v4, "running"

    invoke-virtual {v2, v4, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 534
    const-string v3, "port"

    const/16 v5, 0x2253

    invoke-virtual {v2, v3, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 536
    :try_start_0
    invoke-direct {p0, v5}, Lcom/forge/live/TermuxBridgePlugin;->agentPortOpen(I)Z

    move-result v3
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    const-string v5, "via"

    const/4 v6, 0x1

    const-string v7, "version"

    const-string v8, "pid"

    if-nez v3, :cond_3

    .line 538
    :try_start_1
    new-instance v0, Ljava/io/File;

    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->getBridgeDir()Ljava/io/File;

    move-result-object v1

    const-string v3, "agent.json"

    invoke-direct {v0, v1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 539
    .local v0, "hb":Ljava/io/File;
    invoke-virtual {v0}, Ljava/io/File;->isFile()Z

    move-result v1

    if-eqz v1, :cond_2

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v9

    invoke-virtual {v0}, Ljava/io/File;->lastModified()J

    move-result-wide v11

    sub-long/2addr v9, v11

    const-wide/16 v11, 0x1f40

    cmp-long v1, v9, v11

    if-gez v1, :cond_2

    .line 540
    invoke-static {v0}, Lcom/forge/live/TermuxBridgePlugin;->readFile(Ljava/io/File;)Ljava/lang/String;

    move-result-object v1

    .line 541
    .local v1, "raw":Ljava/lang/String;
    new-instance v3, Lorg/json/JSONObject;

    invoke-direct {v3, v1}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 542
    .local v3, "j":Lorg/json/JSONObject;
    invoke-virtual {v2, v4, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 543
    const-string v4, "file"

    invoke-virtual {v2, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 544
    invoke-virtual {v3, v8}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_0

    invoke-virtual {v3, v8}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;)I

    move-result v4

    invoke-virtual {v2, v8, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 545
    :cond_0
    invoke-virtual {v3, v7}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_1

    invoke-virtual {v3, v7}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v7, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 546
    :cond_1
    return-object v2

    .line 548
    .end local v1    # "raw":Ljava/lang/String;
    .end local v3    # "j":Lorg/json/JSONObject;
    :cond_2
    return-object v2

    .line 550
    .end local v0    # "hb":Ljava/io/File;
    :cond_3
    new-instance v3, Ljava/net/URL;

    const-string v9, "http://127.0.0.1:8787/status"

    invoke-direct {v3, v9}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    .line 551
    .local v3, "url":Ljava/net/URL;
    invoke-virtual {v3}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object v9

    check-cast v9, Ljava/net/HttpURLConnection;

    .line 552
    .local v9, "conn":Ljava/net/HttpURLConnection;
    const/16 v10, 0x258

    invoke-virtual {v9, v10}, Ljava/net/HttpURLConnection;->setConnectTimeout(I)V

    .line 553
    const/16 v10, 0x320

    invoke-virtual {v9, v10}, Ljava/net/HttpURLConnection;->setReadTimeout(I)V

    .line 554
    const-string v10, "GET"

    invoke-virtual {v9, v10}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    .line 555
    invoke-virtual {v9}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result v10

    .line 556
    .local v10, "code":I
    const/16 v11, 0x190

    if-lt v10, v11, :cond_4

    invoke-virtual {v9}, Ljava/net/HttpURLConnection;->getErrorStream()Ljava/io/InputStream;

    move-result-object v11

    goto :goto_0

    :cond_4
    invoke-virtual {v9}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object v11

    :goto_0
    invoke-static {v11}, Lcom/forge/live/TermuxBridgePlugin;->readStream(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v11

    .line 557
    .local v11, "body":Ljava/lang/String;
    invoke-virtual {v9}, Ljava/net/HttpURLConnection;->disconnect()V

    .line 558
    const/16 v12, 0xc8

    if-ne v10, v12, :cond_8

    if-eqz v11, :cond_8

    .line 559
    new-instance v12, Lorg/json/JSONObject;

    invoke-direct {v12, v11}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 560
    .local v12, "j":Lorg/json/JSONObject;
    invoke-virtual {v2, v4, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 561
    const-string v4, "http"

    invoke-virtual {v2, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 562
    invoke-virtual {v12, v8}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_5

    invoke-virtual {v12, v8}, Lorg/json/JSONObject;->optInt(Ljava/lang/String;)I

    move-result v4

    invoke-virtual {v2, v8, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 563
    :cond_5
    invoke-virtual {v12, v7}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_6

    invoke-virtual {v12, v7}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v7, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 564
    :cond_6
    invoke-virtual {v12, v1}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_7

    invoke-virtual {v12, v1}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v1, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 565
    :cond_7
    invoke-virtual {v12, v0}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_8

    invoke-virtual {v12, v0}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v2, v0, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_1

    .line 567
    .end local v3    # "url":Ljava/net/URL;
    .end local v9    # "conn":Ljava/net/HttpURLConnection;
    .end local v10    # "code":I
    .end local v11    # "body":Ljava/lang/String;
    .end local v12    # "j":Lorg/json/JSONObject;
    :catch_0
    move-exception v0

    :cond_8
    :goto_1
    nop

    .line 568
    return-object v2
.end method

.method private probeStatus()Lcom/getcapacitor/JSObject;
    .locals 15

    .line 405
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 406
    .local v0, "o":Lcom/getcapacitor/JSObject;
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->isTermuxInstalled()Z

    move-result v1

    .line 407
    .local v1, "installed":Z
    const-string v2, "installed"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 408
    const-string v2, "package"

    const-string v3, "com.termux"

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 409
    const-string v2, "home"

    const-string v4, "/data/data/com.termux/files/home"

    invoke-virtual {v0, v2, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 410
    const-string v2, "prefix"

    const-string v4, "/data/data/com.termux/files/usr"

    invoke-virtual {v0, v2, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 411
    const-string v2, "runCommandAction"

    const-string v4, "com.termux.RUN_COMMAND"

    invoke-virtual {v0, v2, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 412
    const-string v2, "agentPort"

    const/16 v4, 0x2253

    invoke-virtual {v0, v2, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 414
    const/4 v2, 0x0

    .line 415
    .local v2, "versionName":Ljava/lang/String;
    const-wide/16 v4, -0x1

    .line 416
    .local v4, "versionCode":J
    const/4 v6, 0x0

    if-eqz v1, :cond_2

    .line 419
    :try_start_0
    sget v7, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v8, 0x21

    if-lt v7, v8, :cond_0

    .line 420
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v7

    invoke-virtual {v7}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v7

    const-wide/16 v8, 0x0

    invoke-static {v8, v9}, Landroid/content/pm/PackageManager$PackageInfoFlags;->of(J)Landroid/content/pm/PackageManager$PackageInfoFlags;

    move-result-object v8

    invoke-virtual {v7, v3, v8}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;Landroid/content/pm/PackageManager$PackageInfoFlags;)Landroid/content/pm/PackageInfo;

    move-result-object v3

    .local v3, "pi":Landroid/content/pm/PackageInfo;
    goto :goto_0

    .line 422
    .end local v3    # "pi":Landroid/content/pm/PackageInfo;
    :cond_0
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v7

    invoke-virtual {v7}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v7

    invoke-virtual {v7, v3, v6}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v3

    .line 424
    .restart local v3    # "pi":Landroid/content/pm/PackageInfo;
    :goto_0
    iget-object v7, v3, Landroid/content/pm/PackageInfo;->versionName:Ljava/lang/String;

    move-object v2, v7

    .line 425
    sget v7, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v8, 0x1c

    if-lt v7, v8, :cond_1

    invoke-virtual {v3}, Landroid/content/pm/PackageInfo;->getLongVersionCode()J

    move-result-wide v7

    move-wide v4, v7

    goto :goto_1

    .line 426
    :cond_1
    iget v7, v3, Landroid/content/pm/PackageInfo;->versionCode:I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    int-to-long v4, v7

    goto :goto_1

    .line 427
    .end local v3    # "pi":Landroid/content/pm/PackageInfo;
    :catch_0
    move-exception v3

    :goto_1
    nop

    .line 429
    :cond_2
    if-eqz v2, :cond_3

    move-object v3, v2

    goto :goto_2

    :cond_3
    sget-object v3, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;

    :goto_2
    const-string v7, "versionName"

    invoke-virtual {v0, v7, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 430
    const-string v3, "versionCode"

    invoke-virtual {v0, v3, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 432
    const-string v3, "unknown"

    .line 433
    .local v3, "flavor":Ljava/lang/String;
    const-string v7, "googleplay"

    if-eqz v2, :cond_7

    .line 434
    invoke-virtual {v2}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v8

    .line 435
    .local v8, "vn":Ljava/lang/String;
    invoke-virtual {v8, v7}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v9

    if-nez v9, :cond_6

    const-string v9, "play"

    invoke-virtual {v8, v9}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v9

    if-eqz v9, :cond_4

    goto :goto_3

    .line 436
    :cond_4
    const-string v9, "0\\.\\d+.*"

    invoke-virtual {v8, v9}, Ljava/lang/String;->matches(Ljava/lang/String;)Z

    move-result v9

    if-nez v9, :cond_5

    const-string v9, "fdroid"

    invoke-virtual {v8, v9}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v9

    if-nez v9, :cond_5

    const-string v9, "github"

    invoke-virtual {v8, v9}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v9

    if-eqz v9, :cond_7

    :cond_5
    const-string v3, "github"

    goto :goto_4

    .line 435
    :cond_6
    :goto_3
    const-string v3, "googleplay"

    .line 438
    .end local v8    # "vn":Ljava/lang/String;
    :cond_7
    :goto_4
    const-string v8, "flavor"

    invoke-virtual {v0, v8, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 440
    const/4 v8, 0x1

    if-eqz v1, :cond_8

    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->isRunCommandSupported()Z

    move-result v9

    if-eqz v9, :cond_8

    const/4 v9, 0x1

    goto :goto_5

    :cond_8
    const/4 v9, 0x0

    .line 441
    .local v9, "runCmd":Z
    :goto_5
    const-string v10, "runCommandSupported"

    invoke-virtual {v0, v10, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 443
    const/4 v10, 0x0

    .line 444
    .local v10, "agent":Z
    const/4 v11, 0x0

    .line 445
    .local v11, "agentInfo":Lcom/getcapacitor/JSObject;
    if-eqz v1, :cond_a

    .line 446
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->probeAgent()Lcom/getcapacitor/JSObject;

    move-result-object v11

    .line 447
    if-eqz v11, :cond_9

    const-string v12, "running"

    invoke-virtual {v11, v12}, Lcom/getcapacitor/JSObject;->getBool(Ljava/lang/String;)Ljava/lang/Boolean;

    move-result-object v12

    invoke-virtual {v12}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v12

    if-eqz v12, :cond_9

    const/4 v12, 0x1

    goto :goto_6

    :cond_9
    const/4 v12, 0x0

    :goto_6
    move v10, v12

    .line 449
    :cond_a
    const-string v12, "agentRunning"

    invoke-virtual {v0, v12, v10}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 450
    if-eqz v11, :cond_b

    const-string v12, "agent"

    invoke-virtual {v0, v12, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 452
    :cond_b
    const-string v12, "none"

    .line 453
    .local v12, "bridge":Ljava/lang/String;
    if-eqz v9, :cond_c

    const-string v12, "run_command"

    goto :goto_7

    .line 454
    :cond_c
    if-eqz v10, :cond_d

    const-string v12, "agent"

    .line 455
    :cond_d
    :goto_7
    const-string v13, "bridge"

    invoke-virtual {v0, v13, v12}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 457
    if-nez v9, :cond_e

    if-eqz v10, :cond_f

    :cond_e
    const/4 v6, 0x1

    .line 458
    .local v6, "execSupported":Z
    :cond_f
    const-string v8, "execSupported"

    invoke-virtual {v0, v8, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 460
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->getBridgeDir()Ljava/io/File;

    move-result-object v8

    .line 461
    .local v8, "bridgeDir":Ljava/io/File;
    const-string v13, "bridgeDir"

    invoke-virtual {v8}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v0, v13, v14}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 464
    if-nez v1, :cond_10

    .line 465
    const-string v7, "Termux is not installed."

    .local v7, "note":Ljava/lang/String;
    goto :goto_8

    .line 466
    .end local v7    # "note":Ljava/lang/String;
    :cond_10
    if-eqz v6, :cond_11

    .line 467
    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v13, "Termux ready via "

    invoke-virtual {v7, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v13, "."

    invoke-virtual {v7, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    .restart local v7    # "note":Ljava/lang/String;
    goto :goto_8

    .line 468
    .end local v7    # "note":Ljava/lang/String;
    :cond_11
    invoke-virtual {v7, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_12

    .line 469
    const-string v7, "Google Play Termux has NO RUN_COMMAND API. Install and run the Forge agent in Termux: bash /storage/emulated/0/Download/ForgeBridge/install.sh && forge-termux-agent"

    .restart local v7    # "note":Ljava/lang/String;
    goto :goto_8

    .line 472
    .end local v7    # "note":Ljava/lang/String;
    :cond_12
    const-string v7, "Termux found but no bridge. Enable allow-external-apps=true (F-Droid Termux) OR run forge-termux-agent. Settings \u2192 Device bridges \u2192 Install agent."

    .line 475
    .restart local v7    # "note":Ljava/lang/String;
    :goto_8
    const-string v13, "note"

    invoke-virtual {v0, v13, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 476
    const-string v13, "setupCommand"

    const-string v14, "bash /storage/emulated/0/Download/ForgeBridge/install.sh && forge-termux-agent"

    invoke-virtual {v0, v13, v14}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 478
    return-object v0
.end method

.method private static readFile(Ljava/io/File;)Ljava/lang/String;
    .locals 3
    .param p0, "f"    # Ljava/io/File;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 1025
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 1026
    .local v0, "in":Ljava/io/FileInputStream;
    :try_start_0
    invoke-static {v0}, Lcom/forge/live/TermuxBridgePlugin;->readStream(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 1027
    invoke-virtual {v0}, Ljava/io/FileInputStream;->close()V

    .line 1026
    return-object v1

    .line 1025
    :catchall_0
    move-exception v1

    :try_start_1
    invoke-virtual {v0}, Ljava/io/FileInputStream;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v2

    invoke-virtual {v1, v2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_0
    throw v1
.end method

.method private static readStream(Ljava/io/InputStream;)Ljava/lang/String;
    .locals 5
    .param p0, "in"    # Ljava/io/InputStream;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 1014
    if-nez p0, :cond_0

    const-string v0, ""

    return-object v0

    .line 1015
    :cond_0
    new-instance v0, Ljava/io/BufferedReader;

    new-instance v1, Ljava/io/InputStreamReader;

    sget-object v2, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-direct {v1, p0, v2}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;Ljava/nio/charset/Charset;)V

    invoke-direct {v0, v1}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    .line 1016
    .local v0, "br":Ljava/io/BufferedReader;
    :try_start_0
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    .line 1017
    .local v1, "sb":Ljava/lang/StringBuilder;
    const/16 v2, 0x1000

    new-array v2, v2, [C

    .line 1019
    .local v2, "buf":[C
    :goto_0
    invoke-virtual {v0, v2}, Ljava/io/BufferedReader;->read([C)I

    move-result v3

    move v4, v3

    .local v4, "n":I
    if-ltz v3, :cond_1

    const/4 v3, 0x0

    invoke-virtual {v1, v2, v3, v4}, Ljava/lang/StringBuilder;->append([CII)Ljava/lang/StringBuilder;

    goto :goto_0

    .line 1020
    :cond_1
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 1021
    invoke-virtual {v0}, Ljava/io/BufferedReader;->close()V

    .line 1020
    return-object v3

    .line 1015
    .end local v1    # "sb":Ljava/lang/StringBuilder;
    .end local v2    # "buf":[C
    .end local v4    # "n":I
    :catchall_0
    move-exception v1

    :try_start_1
    invoke-virtual {v0}, Ljava/io/BufferedReader;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_1

    :catchall_1
    move-exception v2

    invoke-virtual {v1, v2}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_1
    throw v1
.end method

.method private resolveCommandPath(Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    .param p1, "command"    # Ljava/lang/String;

    .line 1005
    const-string v0, "/"

    invoke-virtual {p1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    return-object p1

    .line 1006
    :cond_0
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "/data/data/com.termux/files/usr/bin/"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private startTermuxService(Landroid/content/Intent;)V
    .locals 2
    .param p1, "intent"    # Landroid/content/Intent;

    .line 395
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1a

    if-lt v0, v1, :cond_0

    .line 396
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/content/Context;->startForegroundService(Landroid/content/Intent;)Landroid/content/ComponentName;

    goto :goto_0

    .line 398
    :cond_0
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/content/Context;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;

    .line 400
    :goto_0
    return-void
.end method

.method private writeAssetOrBuiltin(Ljava/io/File;Ljava/lang/String;Z)V
    .locals 5
    .param p1, "dir"    # Ljava/io/File;
    .param p2, "name"    # Ljava/lang/String;
    .param p3, "force"    # Z
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 749
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p1, p2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 750
    .local v0, "out":Ljava/io/File;
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-eqz v1, :cond_0

    if-nez p3, :cond_0

    return-void

    .line 751
    :cond_0
    const/4 v1, 0x0

    .line 753
    .local v1, "content":Ljava/lang/String;
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;

    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "termux-agent/"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v2

    .line 754
    .local v2, "in":Ljava/io/InputStream;
    invoke-static {v2}, Lcom/forge/live/TermuxBridgePlugin;->readStream(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v3
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-object v1, v3

    .end local v2    # "in":Ljava/io/InputStream;
    goto :goto_0

    .line 755
    :catch_0
    move-exception v2

    :goto_0
    nop

    .line 756
    if-eqz v1, :cond_1

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_2

    .line 757
    :cond_1
    invoke-direct {p0, p2}, Lcom/forge/live/TermuxBridgePlugin;->builtinAgentFile(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 759
    :cond_2
    invoke-static {v0, v1}, Lcom/forge/live/TermuxBridgePlugin;->writeFile(Ljava/io/File;Ljava/lang/String;)V

    .line 761
    const/4 v2, 0x1

    const/4 v3, 0x0

    invoke-virtual {v0, v2, v3}, Ljava/io/File;->setReadable(ZZ)Z

    .line 763
    invoke-virtual {v0, v2, v3}, Ljava/io/File;->setExecutable(ZZ)Z

    .line 764
    return-void
.end method

.method private static writeFile(Ljava/io/File;Ljava/lang/String;)V
    .locals 4
    .param p0, "f"    # Ljava/io/File;
    .param p1, "content"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 1031
    invoke-virtual {p0}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v0

    .line 1032
    .local v0, "parent":Ljava/io/File;
    if-eqz v0, :cond_0

    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-nez v1, :cond_0

    .line 1034
    invoke-virtual {v0}, Ljava/io/File;->mkdirs()Z

    .line 1036
    :cond_0
    new-instance v1, Ljava/io/FileOutputStream;

    invoke-direct {v1, p0}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    .line 1037
    .local v1, "out":Ljava/io/FileOutputStream;
    :try_start_0
    sget-object v2, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-virtual {p1, v2}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/io/FileOutputStream;->write([B)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 1038
    invoke-virtual {v1}, Ljava/io/FileOutputStream;->close()V

    .line 1039
    .end local v1    # "out":Ljava/io/FileOutputStream;
    return-void

    .line 1036
    .restart local v1    # "out":Ljava/io/FileOutputStream;
    :catchall_0
    move-exception v2

    :try_start_1
    invoke-virtual {v1}, Ljava/io/FileOutputStream;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v3

    invoke-virtual {v2, v3}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_0
    throw v2
.end method


# virtual methods
.method public exec(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 277
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->isTermuxInstalled()Z

    move-result v0

    if-nez v0, :cond_0

    .line 278
    const-string v0, "Termux is not installed"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 279
    return-void

    .line 282
    :cond_0
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->ioPool:Ljava/util/concurrent/ExecutorService;

    new-instance v1, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda7;

    invoke-direct {v1, p0, p1}, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda7;-><init>(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-interface {v0, v1}, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V

    .line 321
    return-void
.end method

.method protected handleOnDestroy()V
    .locals 3

    .line 1043
    iget-boolean v0, p0, Lcom/forge/live/TermuxBridgePlugin;->receiverRegistered:Z

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->execReceiver:Landroid/content/BroadcastReceiver;

    if-eqz v0, :cond_0

    .line 1045
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    iget-object v1, p0, Lcom/forge/live/TermuxBridgePlugin;->execReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {v0, v1}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 1046
    :catch_0
    move-exception v0

    :goto_0
    nop

    .line 1047
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/forge/live/TermuxBridgePlugin;->receiverRegistered:Z

    .line 1049
    :cond_0
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->pendingExec:Ljava/util/Map;

    invoke-interface {v0}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/getcapacitor/PluginCall;

    .line 1050
    .local v1, "c":Lcom/getcapacitor/PluginCall;
    :try_start_1
    const-string v2, "Termux bridge destroyed"

    invoke-virtual {v1, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_2

    :catch_1
    move-exception v2

    .line 1051
    .end local v1    # "c":Lcom/getcapacitor/PluginCall;
    :goto_2
    goto :goto_1

    .line 1052
    :cond_1
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->pendingExec:Ljava/util/Map;

    invoke-interface {v0}, Ljava/util/Map;->clear()V

    .line 1053
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->ioPool:Ljava/util/concurrent/ExecutorService;

    invoke-interface {v0}, Ljava/util/concurrent/ExecutorService;->shutdownNow()Ljava/util/List;

    .line 1054
    invoke-super {p0}, Lcom/getcapacitor/Plugin;->handleOnDestroy()V

    .line 1055
    return-void
.end method

.method public installAgent(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 208
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->ioPool:Ljava/util/concurrent/ExecutorService;

    new-instance v1, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda1;

    invoke-direct {v1, p0, p1}, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda1;-><init>(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-interface {v0, v1}, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V

    .line 226
    return-void
.end method

.method public isAvailable(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 172
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->ioPool:Ljava/util/concurrent/ExecutorService;

    new-instance v1, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda2;

    invoke-direct {v1, p0, p1}, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda2;-><init>(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-interface {v0, v1}, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V

    .line 179
    return-void
.end method

.method public load()V
    .locals 2

    .line 105
    invoke-super {p0}, Lcom/getcapacitor/Plugin;->load()V

    .line 106
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->ensureReceiver()V

    .line 108
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->ioPool:Ljava/util/concurrent/ExecutorService;

    new-instance v1, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda3;

    invoke-direct {v1, p0}, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda3;-><init>(Lcom/forge/live/TermuxBridgePlugin;)V

    invoke-interface {v0, v1}, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V

    .line 111
    return-void
.end method

.method public open(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 183
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->isTermuxInstalled()Z

    move-result v0

    if-nez v0, :cond_0

    .line 184
    const-string v0, "Termux is not installed"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 185
    return-void

    .line 188
    :cond_0
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    const-string v1, "com.termux"

    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v0

    .line 189
    .local v0, "launch":Landroid/content/Intent;
    if-nez v0, :cond_1

    .line 190
    const-string v1, "Cannot launch Termux"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 191
    return-void

    .line 193
    :cond_1
    const/high16 v1, 0x10000000

    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 194
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 195
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 196
    .local v1, "o":Lcom/getcapacitor/JSObject;
    const-string v2, "opened"

    const/4 v3, 0x1

    invoke-virtual {v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 197
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 200
    .end local v0    # "launch":Landroid/content/Intent;
    .end local v1    # "o":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 198
    :catch_0
    move-exception v0

    .line 199
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "open failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 201
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method public openUrl(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 325
    const-string v0, "url"

    const-string v1, ""

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 326
    .local v0, "url":Ljava/lang/String;
    if-eqz v0, :cond_1

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_1

    .line 331
    :cond_0
    :try_start_0
    new-instance v1, Landroid/content/Intent;

    const-string v2, "android.intent.action.VIEW"

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v3

    invoke-direct {v1, v2, v3}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V

    .line 332
    .local v1, "intent":Landroid/content/Intent;
    const-string v2, "com.termux"

    invoke-virtual {v1, v2}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;

    .line 333
    const/high16 v2, 0x10000000

    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 334
    invoke-virtual {p0}, Lcom/forge/live/TermuxBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2, v1}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 335
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 336
    .local v2, "o":Lcom/getcapacitor/JSObject;
    const-string v3, "opened"

    const/4 v4, 0x1

    invoke-virtual {v2, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 337
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 340
    .end local v1    # "intent":Landroid/content/Intent;
    .end local v2    # "o":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 338
    :catch_0
    move-exception v1

    .line 339
    .local v1, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Termux openUrl failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 341
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_0
    return-void

    .line 327
    :cond_1
    :goto_1
    const-string v1, "url required"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 328
    return-void
.end method

.method public run(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 233
    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin;->isTermuxInstalled()Z

    move-result v0

    if-nez v0, :cond_0

    .line 234
    const-string v0, "Termux is not installed"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 235
    return-void

    .line 237
    :cond_0
    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin;->ioPool:Ljava/util/concurrent/ExecutorService;

    new-instance v1, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda6;

    invoke-direct {v1, p0, p1}, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda6;-><init>(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-interface {v0, v1}, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V

    .line 270
    return-void
.end method
