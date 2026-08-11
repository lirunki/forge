.class public Lcom/forge/live/MicBridgePlugin;
.super Lcom/getcapacitor/Plugin;
.source "MicBridgePlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "MicBridge"
    permissions = {
        .subannotation Lcom/getcapacitor/annotation/Permission;
            alias = "mic"
            strings = {
                "android.permission.RECORD_AUDIO"
            }
        .end subannotation
    }
.end annotation


# instance fields
.field private activeCall:Lcom/getcapacitor/PluginCall;

.field private audioRecord:Landroid/media/AudioRecord;

.field private listening:Z

.field private final main:Landroid/os/Handler;

.field private maxRecordMs:I

.field private recognizer:Landroid/speech/SpeechRecognizer;

.field private recordSampleRate:I

.field private recordStartedAt:J

.field private recordThread:Ljava/lang/Thread;

.field private final recording:Ljava/util/concurrent/atomic/AtomicBoolean;

.field private wavFile:Ljava/io/File;


# direct methods
.method public static synthetic $r8$lambda$9DsIlTNjQrTz4AZQJHGuxtzQUi8(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;ZLjava/lang/String;I)V
    .locals 0

    invoke-direct {p0, p1, p2, p3, p4}, Lcom/forge/live/MicBridgePlugin;->lambda$listen$0(Lcom/getcapacitor/PluginCall;ZLjava/lang/String;I)V

    return-void
.end method

.method public static synthetic $r8$lambda$DwvNWEcfAcjOd2TuuI1Bk5Xh3aU(Lcom/forge/live/MicBridgePlugin;II)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/forge/live/MicBridgePlugin;->lambda$startRecord$3(II)V

    return-void
.end method

.method public static synthetic $r8$lambda$E6_K3VyjEmoqmIG131m0JL8HH0g(Lcom/forge/live/MicBridgePlugin;)V
    .locals 0

    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->lambda$startRecord$4()V

    return-void
.end method

.method public static synthetic $r8$lambda$aqxxMoqY3wJZqFbozgnyKZRzxSA(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/MicBridgePlugin;->lambda$cancel$2(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method public static synthetic $r8$lambda$xt4v1x6XsSyaTr-aF8kwyNMcLYY(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/MicBridgePlugin;->lambda$stop$1(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method static bridge synthetic -$$Nest$fgetactiveCall(Lcom/forge/live/MicBridgePlugin;)Lcom/getcapacitor/PluginCall;
    .locals 0

    iget-object p0, p0, Lcom/forge/live/MicBridgePlugin;->activeCall:Lcom/getcapacitor/PluginCall;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fputactiveCall(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    iput-object p1, p0, Lcom/forge/live/MicBridgePlugin;->activeCall:Lcom/getcapacitor/PluginCall;

    return-void
.end method

.method static bridge synthetic -$$Nest$fputlistening(Lcom/forge/live/MicBridgePlugin;Z)V
    .locals 0

    iput-boolean p1, p0, Lcom/forge/live/MicBridgePlugin;->listening:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$mdestroyRecognizer(Lcom/forge/live/MicBridgePlugin;)V
    .locals 0

    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->destroyRecognizer()V

    return-void
.end method

.method static bridge synthetic -$$Nest$smerrorName(I)Ljava/lang/String;
    .locals 0

    invoke-static {p0}, Lcom/forge/live/MicBridgePlugin;->errorName(I)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method public constructor <init>()V
    .locals 2

    .line 43
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    .line 45
    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/forge/live/MicBridgePlugin;->main:Landroid/os/Handler;

    .line 48
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/forge/live/MicBridgePlugin;->listening:Z

    .line 51
    new-instance v1, Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-direct {v1, v0}, Ljava/util/concurrent/atomic/AtomicBoolean;-><init>(Z)V

    iput-object v1, p0, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    .line 55
    const/16 v0, 0x3e80

    iput v0, p0, Lcom/forge/live/MicBridgePlugin;->recordSampleRate:I

    .line 56
    const-wide/16 v0, 0x0

    iput-wide v0, p0, Lcom/forge/live/MicBridgePlugin;->recordStartedAt:J

    .line 57
    const v0, 0xea60

    iput v0, p0, Lcom/forge/live/MicBridgePlugin;->maxRecordMs:I

    return-void
.end method

.method static synthetic access$000(Lcom/forge/live/MicBridgePlugin;Ljava/lang/String;Lcom/getcapacitor/JSObject;)V
    .locals 0
    .param p0, "x0"    # Lcom/forge/live/MicBridgePlugin;
    .param p1, "x1"    # Ljava/lang/String;
    .param p2, "x2"    # Lcom/getcapacitor/JSObject;

    .line 43
    invoke-virtual {p0, p1, p2}, Lcom/forge/live/MicBridgePlugin;->notifyListeners(Ljava/lang/String;Lcom/getcapacitor/JSObject;)V

    return-void
.end method

.method private destroyRecognizer()V
    .locals 1

    .line 495
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recognizer:Landroid/speech/SpeechRecognizer;

    if-eqz v0, :cond_0

    .line 496
    :try_start_0
    invoke-virtual {v0}, Landroid/speech/SpeechRecognizer;->cancel()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 497
    :goto_0
    :try_start_1
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recognizer:Landroid/speech/SpeechRecognizer;

    invoke-virtual {v0}, Landroid/speech/SpeechRecognizer;->destroy()V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    :catch_1
    move-exception v0

    .line 498
    :goto_1
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recognizer:Landroid/speech/SpeechRecognizer;

    .line 500
    :cond_0
    return-void
.end method

.method private static errorName(I)Ljava/lang/String;
    .locals 1
    .param p0, "code"    # I

    .line 503
    packed-switch p0, :pswitch_data_0

    .line 513
    const-string v0, "UNKNOWN"

    return-object v0

    .line 506
    :pswitch_0
    const-string v0, "ERROR_INSUFFICIENT_PERMISSIONS"

    return-object v0

    .line 510
    :pswitch_1
    const-string v0, "ERROR_RECOGNIZER_BUSY"

    return-object v0

    .line 509
    :pswitch_2
    const-string v0, "ERROR_NO_MATCH"

    return-object v0

    .line 512
    :pswitch_3
    const-string v0, "ERROR_SPEECH_TIMEOUT"

    return-object v0

    .line 505
    :pswitch_4
    const-string v0, "ERROR_CLIENT"

    return-object v0

    .line 511
    :pswitch_5
    const-string v0, "ERROR_SERVER"

    return-object v0

    .line 504
    :pswitch_6
    const-string v0, "ERROR_AUDIO"

    return-object v0

    .line 507
    :pswitch_7
    const-string v0, "ERROR_NETWORK"

    return-object v0

    .line 508
    :pswitch_8
    const-string v0, "ERROR_NETWORK_TIMEOUT"

    return-object v0

    nop

    :pswitch_data_0
    .packed-switch 0x1
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

.method private fileToResult(Ljava/io/File;I)Lcom/getcapacitor/JSObject;
    .locals 10
    .param p1, "file"    # Ljava/io/File;
    .param p2, "sampleRate"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 419
    invoke-virtual {p1}, Ljava/io/File;->length()J

    move-result-wide v0

    .line 420
    .local v0, "bytes":J
    invoke-static {p1}, Lcom/forge/live/MicBridgePlugin;->readAll(Ljava/io/File;)[B

    move-result-object v2

    .line 421
    .local v2, "data":[B
    const/4 v3, 0x2

    invoke-static {v2, v3}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;

    move-result-object v3

    .line 422
    .local v3, "b64":Ljava/lang/String;
    const-wide/16 v4, 0x2c

    sub-long v4, v0, v4

    long-to-double v4, v4

    mul-int/lit8 v6, p2, 0x2

    int-to-double v6, v6

    div-double/2addr v4, v6

    const-wide/16 v6, 0x0

    invoke-static {v6, v7, v4, v5}, Ljava/lang/Math;->max(DD)D

    move-result-wide v4

    .line 423
    .local v4, "durationSec":D
    new-instance v6, Lcom/getcapacitor/JSObject;

    invoke-direct {v6}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 424
    .local v6, "ret":Lcom/getcapacitor/JSObject;
    const-string v7, "format"

    const-string v8, "wav"

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 425
    const-string v7, "mime"

    const-string v8, "audio/wav"

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 426
    const-string v7, "sampleRate"

    invoke-virtual {v6, v7, p2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 427
    const-string v7, "channels"

    const/4 v8, 0x1

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 428
    const-string v7, "bitsPerSample"

    const/16 v8, 0x10

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 429
    const-string v7, "bytes"

    invoke-virtual {v6, v7, v0, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 430
    const-wide v7, 0x408f400000000000L    # 1000.0

    mul-double v7, v7, v4

    invoke-static {v7, v8}, Ljava/lang/Math;->round(D)J

    move-result-wide v7

    const-string v9, "durationMs"

    invoke-virtual {v6, v9, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 431
    const-string v7, "base64"

    invoke-virtual {v6, v7, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 432
    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "data:audio/wav;base64,"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    const-string v8, "dataUrl"

    invoke-virtual {v6, v8, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 433
    const-string v7, "path"

    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 434
    const-string v7, "name"

    invoke-virtual {p1}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 435
    return-object v6
.end method

.method private hasMicPermission()Z
    .locals 2

    .line 60
    invoke-virtual {p0}, Lcom/forge/live/MicBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    const-string v1, "android.permission.RECORD_AUDIO"

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

.method private synthetic lambda$cancel$2(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 222
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->activeCall:Lcom/getcapacitor/PluginCall;

    .line 223
    .local v0, "c":Lcom/getcapacitor/PluginCall;
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/forge/live/MicBridgePlugin;->activeCall:Lcom/getcapacitor/PluginCall;

    .line 224
    const/4 v1, 0x0

    iput-boolean v1, p0, Lcom/forge/live/MicBridgePlugin;->listening:Z

    .line 225
    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->destroyRecognizer()V

    .line 226
    const-string v1, "cancelled"

    if-eqz v0, :cond_0

    .line 227
    invoke-virtual {v0, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 229
    :cond_0
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 230
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    const/4 v3, 0x1

    invoke-virtual {v2, v1, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 231
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 232
    return-void
.end method

.method private synthetic lambda$listen$0(Lcom/getcapacitor/PluginCall;ZLjava/lang/String;I)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "wantPartial"    # Z
    .param p3, "lang"    # Ljava/lang/String;
    .param p4, "maxR"    # I

    .line 123
    :try_start_0
    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->stopInternal()V

    .line 124
    iput-object p1, p0, Lcom/forge/live/MicBridgePlugin;->activeCall:Lcom/getcapacitor/PluginCall;

    .line 125
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/forge/live/MicBridgePlugin;->listening:Z

    .line 127
    invoke-virtual {p0}, Lcom/forge/live/MicBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Landroid/speech/SpeechRecognizer;->createSpeechRecognizer(Landroid/content/Context;)Landroid/speech/SpeechRecognizer;

    move-result-object v0

    iput-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recognizer:Landroid/speech/SpeechRecognizer;

    .line 128
    new-instance v1, Lcom/forge/live/MicBridgePlugin$1;

    invoke-direct {v1, p0, p2}, Lcom/forge/live/MicBridgePlugin$1;-><init>(Lcom/forge/live/MicBridgePlugin;Z)V

    invoke-virtual {v0, v1}, Landroid/speech/SpeechRecognizer;->setRecognitionListener(Landroid/speech/RecognitionListener;)V

    .line 189
    new-instance v0, Landroid/content/Intent;

    const-string v1, "android.speech.action.RECOGNIZE_SPEECH"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 190
    .local v0, "intent":Landroid/content/Intent;
    const-string v1, "android.speech.extra.LANGUAGE_MODEL"

    const-string v2, "free_form"

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 191
    const-string v1, "android.speech.extra.LANGUAGE"

    if-eqz p3, :cond_0

    move-object v2, p3

    goto :goto_0

    :cond_0
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v2

    invoke-virtual {v2}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v2

    :goto_0
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 192
    const-string v1, "android.speech.extra.MAX_RESULTS"

    invoke-virtual {v0, v1, p4}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 193
    const-string v1, "android.speech.extra.PARTIAL_RESULTS"

    invoke-virtual {v0, v1, p2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 194
    const-string v1, "calling_package"

    invoke-virtual {p0}, Lcom/forge/live/MicBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 196
    iget-object v1, p0, Lcom/forge/live/MicBridgePlugin;->recognizer:Landroid/speech/SpeechRecognizer;

    invoke-virtual {v1, v0}, Landroid/speech/SpeechRecognizer;->startListening(Landroid/content/Intent;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 202
    .end local v0    # "intent":Landroid/content/Intent;
    goto :goto_1

    .line 197
    :catch_0
    move-exception v0

    .line 198
    .local v0, "e":Ljava/lang/Exception;
    const/4 v1, 0x0

    iput-boolean v1, p0, Lcom/forge/live/MicBridgePlugin;->listening:Z

    .line 199
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/forge/live/MicBridgePlugin;->activeCall:Lcom/getcapacitor/PluginCall;

    .line 200
    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->destroyRecognizer()V

    .line 201
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "listen failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 203
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1
    return-void
.end method

.method private synthetic lambda$startRecord$3(II)V
    .locals 0
    .param p1, "sr"    # I
    .param p2, "bufferSize"    # I

    .line 287
    invoke-direct {p0, p1, p2}, Lcom/forge/live/MicBridgePlugin;->writeWavLoop(II)V

    return-void
.end method

.method private synthetic lambda$startRecord$4()V
    .locals 2

    .line 292
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 294
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 296
    :cond_0
    return-void
.end method

.method private synthetic lambda$stop$1(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 210
    :try_start_0
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recognizer:Landroid/speech/SpeechRecognizer;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Landroid/speech/SpeechRecognizer;->stopListening()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 211
    :catch_0
    move-exception v0

    :cond_0
    :goto_0
    nop

    .line 213
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 214
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    const-string v1, "stopping"

    iget-boolean v2, p0, Lcom/forge/live/MicBridgePlugin;->listening:Z

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 215
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 216
    return-void
.end method

.method private micPermCallback(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/annotation/PermissionCallback;
    .end annotation

    .line 95
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 96
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "granted"

    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->hasMicPermission()Z

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 97
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 98
    return-void
.end method

.method private static readAll(Ljava/io/File;)[B
    .locals 4
    .param p0, "f"    # Ljava/io/File;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 439
    invoke-virtual {p0}, Ljava/io/File;->length()J

    move-result-wide v0

    long-to-int v1, v0

    new-array v0, v1, [B

    .line 440
    .local v0, "data":[B
    new-instance v1, Ljava/io/FileInputStream;

    invoke-direct {v1, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 441
    .local v1, "in":Ljava/io/FileInputStream;
    const/4 v2, 0x0

    .line 442
    .local v2, "off":I
    :goto_0
    :try_start_0
    array-length v3, v0

    if-ge v2, v3, :cond_1

    .line 443
    array-length v3, v0

    sub-int/2addr v3, v2

    invoke-virtual {v1, v0, v2, v3}, Ljava/io/FileInputStream;->read([BII)I

    move-result v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 444
    .local v3, "n":I
    if-gez v3, :cond_0

    goto :goto_1

    .line 445
    :cond_0
    add-int/2addr v2, v3

    .line 446
    .end local v3    # "n":I
    goto :goto_0

    .line 447
    .end local v2    # "off":I
    :cond_1
    :goto_1
    invoke-virtual {v1}, Ljava/io/FileInputStream;->close()V

    .line 448
    .end local v1    # "in":Ljava/io/FileInputStream;
    return-object v0

    .line 440
    .restart local v1    # "in":Ljava/io/FileInputStream;
    :catchall_0
    move-exception v2

    :try_start_1
    invoke-virtual {v1}, Ljava/io/FileInputStream;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_2

    :catchall_1
    move-exception v3

    invoke-virtual {v2, v3}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_2
    throw v2
.end method

.method private releaseAudioRecord()V
    .locals 1

    .line 412
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->audioRecord:Landroid/media/AudioRecord;

    if-eqz v0, :cond_0

    .line 413
    :try_start_0
    invoke-virtual {v0}, Landroid/media/AudioRecord;->release()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 414
    :goto_0
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/forge/live/MicBridgePlugin;->audioRecord:Landroid/media/AudioRecord;

    .line 416
    :cond_0
    return-void
.end method

.method private stopInternal()V
    .locals 1

    .line 490
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/forge/live/MicBridgePlugin;->listening:Z

    .line 491
    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->destroyRecognizer()V

    .line 492
    return-void
.end method

.method private static writeIntLE([BII)V
    .locals 2
    .param p0, "b"    # [B
    .param p1, "off"    # I
    .param p2, "v"    # I

    .line 478
    and-int/lit16 v0, p2, 0xff

    int-to-byte v0, v0

    aput-byte v0, p0, p1

    .line 479
    add-int/lit8 v0, p1, 0x1

    shr-int/lit8 v1, p2, 0x8

    and-int/lit16 v1, v1, 0xff

    int-to-byte v1, v1

    aput-byte v1, p0, v0

    .line 480
    add-int/lit8 v0, p1, 0x2

    shr-int/lit8 v1, p2, 0x10

    and-int/lit16 v1, v1, 0xff

    int-to-byte v1, v1

    aput-byte v1, p0, v0

    .line 481
    add-int/lit8 v0, p1, 0x3

    shr-int/lit8 v1, p2, 0x18

    and-int/lit16 v1, v1, 0xff

    int-to-byte v1, v1

    aput-byte v1, p0, v0

    .line 482
    return-void
.end method

.method private static writeShortLE([BIS)V
    .locals 2
    .param p0, "b"    # [B
    .param p1, "off"    # I
    .param p2, "v"    # S

    .line 485
    and-int/lit16 v0, p2, 0xff

    int-to-byte v0, v0

    aput-byte v0, p0, p1

    .line 486
    add-int/lit8 v0, p1, 0x1

    shr-int/lit8 v1, p2, 0x8

    and-int/lit16 v1, v1, 0xff

    int-to-byte v1, v1

    aput-byte v1, p0, v0

    .line 487
    return-void
.end method

.method private static writeWavHeader(Ljava/io/File;IIIJ)V
    .locals 10
    .param p0, "file"    # Ljava/io/File;
    .param p1, "sampleRate"    # I
    .param p2, "channels"    # I
    .param p3, "bitsPerSample"    # I
    .param p4, "pcmBytes"    # J
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 452
    int-to-long v0, p1

    int-to-long v2, p2

    mul-long v0, v0, v2

    int-to-long v2, p3

    mul-long v0, v0, v2

    const-wide/16 v2, 0x8

    div-long/2addr v0, v2

    .line 453
    .local v0, "byteRate":J
    mul-int v2, p2, p3

    const/16 v3, 0x8

    div-int/2addr v2, v3

    .line 454
    .local v2, "blockAlign":I
    const-wide/16 v4, 0x24

    add-long/2addr v4, p4

    .line 456
    .local v4, "totalDataLen":J
    const/16 v6, 0x2c

    new-array v6, v6, [B

    .line 457
    .local v6, "header":[B
    const/4 v7, 0x0

    const/16 v8, 0x52

    aput-byte v8, v6, v7

    const/16 v7, 0x49

    const/4 v8, 0x1

    aput-byte v7, v6, v8

    const/4 v7, 0x2

    const/16 v9, 0x46

    aput-byte v9, v6, v7

    const/4 v7, 0x3

    aput-byte v9, v6, v7

    .line 458
    const/4 v7, 0x4

    long-to-int v9, v4

    invoke-static {v6, v7, v9}, Lcom/forge/live/MicBridgePlugin;->writeIntLE([BII)V

    .line 459
    const/16 v7, 0x57

    aput-byte v7, v6, v3

    const/16 v3, 0x9

    const/16 v7, 0x41

    aput-byte v7, v6, v3

    const/16 v3, 0xa

    const/16 v7, 0x56

    aput-byte v7, v6, v3

    const/16 v3, 0xb

    const/16 v7, 0x45

    aput-byte v7, v6, v3

    .line 460
    const/16 v3, 0xc

    const/16 v7, 0x66

    aput-byte v7, v6, v3

    const/16 v3, 0xd

    const/16 v7, 0x6d

    aput-byte v7, v6, v3

    const/16 v3, 0xe

    const/16 v7, 0x74

    aput-byte v7, v6, v3

    const/16 v3, 0xf

    const/16 v9, 0x20

    aput-byte v9, v6, v3

    .line 461
    const/16 v3, 0x10

    invoke-static {v6, v3, v3}, Lcom/forge/live/MicBridgePlugin;->writeIntLE([BII)V

    .line 462
    const/16 v3, 0x14

    invoke-static {v6, v3, v8}, Lcom/forge/live/MicBridgePlugin;->writeShortLE([BIS)V

    .line 463
    const/16 v3, 0x16

    int-to-short v8, p2

    invoke-static {v6, v3, v8}, Lcom/forge/live/MicBridgePlugin;->writeShortLE([BIS)V

    .line 464
    const/16 v3, 0x18

    invoke-static {v6, v3, p1}, Lcom/forge/live/MicBridgePlugin;->writeIntLE([BII)V

    .line 465
    const/16 v3, 0x1c

    long-to-int v8, v0

    invoke-static {v6, v3, v8}, Lcom/forge/live/MicBridgePlugin;->writeIntLE([BII)V

    .line 466
    int-to-short v3, v2

    invoke-static {v6, v9, v3}, Lcom/forge/live/MicBridgePlugin;->writeShortLE([BIS)V

    .line 467
    const/16 v3, 0x22

    int-to-short v8, p3

    invoke-static {v6, v3, v8}, Lcom/forge/live/MicBridgePlugin;->writeShortLE([BIS)V

    .line 468
    const/16 v3, 0x24

    const/16 v8, 0x64

    aput-byte v8, v6, v3

    const/16 v3, 0x25

    const/16 v8, 0x61

    aput-byte v8, v6, v3

    const/16 v3, 0x26

    aput-byte v7, v6, v3

    const/16 v3, 0x27

    aput-byte v8, v6, v3

    .line 469
    const/16 v3, 0x28

    long-to-int v7, p4

    invoke-static {v6, v3, v7}, Lcom/forge/live/MicBridgePlugin;->writeIntLE([BII)V

    .line 471
    new-instance v3, Ljava/io/RandomAccessFile;

    const-string v7, "rw"

    invoke-direct {v3, p0, v7}, Ljava/io/RandomAccessFile;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 472
    .local v3, "raf":Ljava/io/RandomAccessFile;
    const-wide/16 v7, 0x0

    :try_start_0
    invoke-virtual {v3, v7, v8}, Ljava/io/RandomAccessFile;->seek(J)V

    .line 473
    invoke-virtual {v3, v6}, Ljava/io/RandomAccessFile;->write([B)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 474
    invoke-virtual {v3}, Ljava/io/RandomAccessFile;->close()V

    .line 475
    .end local v3    # "raf":Ljava/io/RandomAccessFile;
    return-void

    .line 471
    .restart local v3    # "raf":Ljava/io/RandomAccessFile;
    :catchall_0
    move-exception v7

    :try_start_1
    invoke-virtual {v3}, Ljava/io/RandomAccessFile;->close()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    goto :goto_0

    :catchall_1
    move-exception v8

    invoke-virtual {v7, v8}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_0
    throw v7
.end method

.method private writeWavLoop(II)V
    .locals 18
    .param p1, "sampleRate"    # I
    .param p2, "bufferSize"    # I

    .line 376
    move-object/from16 v1, p0

    const/4 v2, 0x0

    .line 378
    .local v2, "fos":Ljava/io/FileOutputStream;
    const/4 v3, 0x0

    :try_start_0
    new-instance v0, Ljava/io/FileOutputStream;

    iget-object v4, v1, Lcom/forge/live/MicBridgePlugin;->wavFile:Ljava/io/File;

    invoke-direct {v0, v4}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    move-object v2, v0

    .line 380
    const/16 v0, 0x2c

    new-array v0, v0, [B

    move-object v4, v0

    .line 381
    .local v4, "header":[B
    invoke-virtual {v2, v4}, Ljava/io/FileOutputStream;->write([B)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_3
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    .line 383
    move/from16 v5, p2

    :try_start_1
    new-array v0, v5, [B

    move-object v6, v0

    .line 384
    .local v6, "buf":[B
    iget-object v0, v1, Lcom/forge/live/MicBridgePlugin;->audioRecord:Landroid/media/AudioRecord;

    invoke-virtual {v0}, Landroid/media/AudioRecord;->startRecording()V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_2
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 385
    move/from16 v13, p1

    int-to-long v7, v13

    const-wide/16 v9, 0x2

    mul-long v7, v7, v9

    :try_start_2
    iget v0, v1, Lcom/forge/live/MicBridgePlugin;->maxRecordMs:I

    int-to-long v9, v0

    const-wide/16 v11, 0x3e8

    div-long/2addr v9, v11

    const-wide/16 v11, 0x1

    add-long/2addr v9, v11

    mul-long v14, v7, v9

    .line 386
    .local v14, "maxBytes":J
    const-wide/16 v7, 0x0

    .line 388
    .local v7, "written":J
    :goto_0
    iget-object v0, v1, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v0

    if-eqz v0, :cond_2

    .line 389
    iget-object v0, v1, Lcom/forge/live/MicBridgePlugin;->audioRecord:Landroid/media/AudioRecord;

    array-length v9, v6

    invoke-virtual {v0, v6, v3, v9}, Landroid/media/AudioRecord;->read([BII)I

    move-result v0

    .line 390
    .local v0, "n":I
    if-lez v0, :cond_0

    .line 391
    invoke-virtual {v2, v6, v3, v0}, Ljava/io/FileOutputStream;->write([BII)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    .line 392
    int-to-long v9, v0

    add-long/2addr v7, v9

    .line 393
    cmp-long v9, v7, v14

    if-ltz v9, :cond_1

    move-wide/from16 v16, v7

    goto :goto_2

    .line 394
    :cond_0
    if-gez v0, :cond_1

    .line 395
    goto :goto_1

    .line 397
    .end local v0    # "n":I
    :cond_1
    goto :goto_0

    .line 398
    :cond_2
    :goto_1
    move-wide/from16 v16, v7

    .end local v7    # "written":J
    .local v16, "written":J
    :goto_2
    :try_start_3
    iget-object v0, v1, Lcom/forge/live/MicBridgePlugin;->audioRecord:Landroid/media/AudioRecord;

    invoke-virtual {v0}, Landroid/media/AudioRecord;->stop()V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_0
    .catchall {:try_start_3 .. :try_end_3} :catchall_2

    goto :goto_3

    :catch_0
    move-exception v0

    .line 399
    :goto_3
    :try_start_4
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->flush()V

    .line 400
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V

    .line 401
    const/4 v2, 0x0

    .line 402
    iget-object v7, v1, Lcom/forge/live/MicBridgePlugin;->wavFile:Ljava/io/File;

    const/4 v9, 0x1

    const/16 v10, 0x10

    move/from16 v8, p1

    move-wide/from16 v11, v16

    invoke-static/range {v7 .. v12}, Lcom/forge/live/MicBridgePlugin;->writeWavHeader(Ljava/io/File;IIIJ)V
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_1
    .catchall {:try_start_4 .. :try_end_4} :catchall_2

    .end local v4    # "header":[B
    .end local v6    # "buf":[B
    .end local v14    # "maxBytes":J
    .end local v16    # "written":J
    goto :goto_6

    .line 403
    :catch_1
    move-exception v0

    goto :goto_4

    .line 406
    :catchall_0
    move-exception v0

    move/from16 v13, p1

    goto :goto_5

    .line 403
    :catch_2
    move-exception v0

    move/from16 v13, p1

    goto :goto_4

    .line 406
    :catchall_1
    move-exception v0

    move/from16 v13, p1

    move/from16 v5, p2

    goto :goto_5

    .line 403
    :catch_3
    move-exception v0

    move/from16 v13, p1

    move/from16 v5, p2

    :goto_4
    move-object v4, v0

    .line 404
    .local v4, "e":Ljava/lang/Exception;
    if-eqz v2, :cond_3

    :try_start_5
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_4
    .catchall {:try_start_5 .. :try_end_5} :catchall_2

    goto :goto_6

    .line 406
    .end local v4    # "e":Ljava/lang/Exception;
    :catchall_2
    move-exception v0

    :goto_5
    iget-object v4, v1, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v4, v3}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 407
    invoke-direct/range {p0 .. p0}, Lcom/forge/live/MicBridgePlugin;->releaseAudioRecord()V

    .line 408
    throw v0

    .line 404
    .restart local v4    # "e":Ljava/lang/Exception;
    :catch_4
    move-exception v0

    .line 406
    .end local v4    # "e":Ljava/lang/Exception;
    :cond_3
    :goto_6
    iget-object v0, v1, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v0, v3}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 407
    invoke-direct/range {p0 .. p0}, Lcom/forge/live/MicBridgePlugin;->releaseAudioRecord()V

    .line 408
    nop

    .line 409
    return-void
.end method


# virtual methods
.method public cancel(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 221
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->main:Landroid/os/Handler;

    new-instance v1, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda0;

    invoke-direct {v1, p0, p1}, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda0;-><init>(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 233
    return-void
.end method

.method public cancelRecord(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 347
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 349
    :try_start_0
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recordThread:Ljava/lang/Thread;

    if-eqz v0, :cond_0

    const-wide/16 v1, 0x5dc

    invoke-virtual {v0, v1, v2}, Ljava/lang/Thread;->join(J)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 350
    :catch_0
    move-exception v0

    :cond_0
    :goto_0
    nop

    .line 351
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recordThread:Ljava/lang/Thread;

    .line 352
    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->releaseAudioRecord()V

    .line 353
    iget-object v1, p0, Lcom/forge/live/MicBridgePlugin;->wavFile:Ljava/io/File;

    if-eqz v1, :cond_1

    .line 355
    :try_start_1
    invoke-virtual {v1}, Ljava/io/File;->delete()Z
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    .line 356
    :catch_1
    move-exception v1

    :goto_1
    nop

    .line 357
    iput-object v0, p0, Lcom/forge/live/MicBridgePlugin;->wavFile:Ljava/io/File;

    .line 359
    :cond_1
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 360
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "cancelled"

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 361
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 362
    return-void
.end method

.method protected handleOnDestroy()V
    .locals 2

    .line 519
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 520
    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->releaseAudioRecord()V

    .line 521
    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->destroyRecognizer()V

    .line 522
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/forge/live/MicBridgePlugin;->activeCall:Lcom/getcapacitor/PluginCall;

    .line 523
    invoke-super {p0}, Lcom/getcapacitor/Plugin;->handleOnDestroy()V

    .line 524
    return-void
.end method

.method public isAvailable(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 66
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 67
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const/4 v1, 0x0

    .line 69
    .local v1, "speech":Z
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/MicBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-static {v2}, Landroid/speech/SpeechRecognizer;->isRecognitionAvailable(Landroid/content/Context;)Z

    move-result v2
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move v1, v2

    goto :goto_0

    .line 70
    :catch_0
    move-exception v2

    :goto_0
    nop

    .line 71
    const-string v2, "speechRecognition"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 72
    const-string v2, "permission"

    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->hasMicPermission()Z

    move-result v3

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 73
    const-string v2, "listening"

    iget-boolean v3, p0, Lcom/forge/live/MicBridgePlugin;->listening:Z

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 74
    iget-object v2, p0, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v2}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v2

    const-string v3, "recording"

    invoke-virtual {v0, v3, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 75
    const-string v2, "wav"

    const/4 v3, 0x1

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 76
    const-string v4, "record"

    invoke-virtual {v0, v4, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 77
    const-string v3, "maxRecordMs"

    const v4, 0x1d4c0

    invoke-virtual {v0, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 78
    new-instance v3, Lcom/getcapacitor/JSArray;

    invoke-direct {v3}, Lcom/getcapacitor/JSArray;-><init>()V

    invoke-virtual {v3, v2}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    move-result-object v2

    const-string v3, "formats"

    invoke-virtual {v0, v3, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 79
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 80
    return-void
.end method

.method public isRecording(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 366
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 367
    .local v0, "o":Lcom/getcapacitor/JSObject;
    iget-object v1, p0, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v1}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v1

    const-string v2, "recording"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 368
    iget-object v1, p0, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v1}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 369
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v1

    iget-wide v3, p0, Lcom/forge/live/MicBridgePlugin;->recordStartedAt:J

    sub-long/2addr v1, v3

    const-string v3, "elapsedMs"

    invoke-virtual {v0, v3, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 370
    const-string v1, "sampleRate"

    iget v2, p0, Lcom/forge/live/MicBridgePlugin;->recordSampleRate:I

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 372
    :cond_0
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 373
    return-void
.end method

.method public listen(Lcom/getcapacitor/PluginCall;)V
    .locals 11
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 102
    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->hasMicPermission()Z

    move-result v0

    if-nez v0, :cond_0

    .line 103
    const-string v0, "RECORD_AUDIO permission not granted. Call requestPermission first."

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 104
    return-void

    .line 106
    :cond_0
    invoke-virtual {p0}, Lcom/forge/live/MicBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Landroid/speech/SpeechRecognizer;->isRecognitionAvailable(Landroid/content/Context;)Z

    move-result v0

    if-nez v0, :cond_1

    .line 107
    const-string v0, "Speech recognition not available on this device."

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 108
    return-void

    .line 111
    :cond_1
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v0

    const-string v1, "lang"

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 112
    .local v0, "lang":Ljava/lang/String;
    sget-object v1, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const/4 v2, 0x0

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    const-string v3, "partial"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v1

    .line 113
    .local v1, "partial":Z
    const/4 v2, 0x3

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    const-string v3, "maxResults"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    .line 114
    .local v2, "maxResults":I
    const/4 v3, 0x1

    if-ge v2, v3, :cond_2

    const/4 v2, 0x1

    .line 115
    :cond_2
    const/4 v4, 0x5

    if-le v2, v4, :cond_3

    const/4 v2, 0x5

    :cond_3
    move v8, v2

    .line 116
    .end local v2    # "maxResults":I
    .local v8, "maxResults":I
    move v7, v8

    .line 117
    .local v7, "maxR":I
    move v5, v1

    .line 119
    .local v5, "wantPartial":Z
    invoke-static {v3}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->setKeepAlive(Ljava/lang/Boolean;)V

    .line 121
    iget-object v9, p0, Lcom/forge/live/MicBridgePlugin;->main:Landroid/os/Handler;

    new-instance v10, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;

    move-object v2, v10

    move-object v3, p0

    move-object v4, p1

    move-object v6, v0

    invoke-direct/range {v2 .. v7}, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;-><init>(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;ZLjava/lang/String;I)V

    invoke-virtual {v9, v10}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 204
    return-void
.end method

.method public requestPermission(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 84
    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->hasMicPermission()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 85
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 86
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "granted"

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 87
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 88
    return-void

    .line 90
    .end local v0    # "o":Lcom/getcapacitor/JSObject;
    :cond_0
    const-string v0, "mic"

    const-string v1, "micPermCallback"

    invoke-virtual {p0, v0, p1, v1}, Lcom/forge/live/MicBridgePlugin;->requestPermissionForAlias(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    .line 91
    return-void
.end method

.method public startRecord(Lcom/getcapacitor/PluginCall;)V
    .locals 20
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 238
    move-object/from16 v1, p0

    move-object/from16 v2, p1

    invoke-direct/range {p0 .. p0}, Lcom/forge/live/MicBridgePlugin;->hasMicPermission()Z

    move-result v0

    if-nez v0, :cond_0

    .line 239
    const-string v0, "RECORD_AUDIO permission not granted. Call requestPermission first."

    invoke-virtual {v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 240
    return-void

    .line 242
    :cond_0
    iget-object v0, v1, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 243
    const-string v0, "Already recording. Call stopRecord first."

    invoke-virtual {v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 244
    return-void

    .line 247
    :cond_1
    invoke-direct/range {p0 .. p0}, Lcom/forge/live/MicBridgePlugin;->stopInternal()V

    .line 249
    const/16 v0, 0x3e80

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    const-string v3, "sampleRate"

    invoke-virtual {v2, v3, v0}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    .line 250
    .local v0, "sampleRate":I
    const/16 v4, 0x1f40

    if-ge v0, v4, :cond_2

    const/16 v0, 0x1f40

    .line 251
    :cond_2
    const v4, 0xbb80

    if-le v0, v4, :cond_3

    const v0, 0xbb80

    :cond_3
    move v10, v0

    .line 252
    .end local v0    # "sampleRate":I
    .local v10, "sampleRate":I
    iput v10, v1, Lcom/forge/live/MicBridgePlugin;->recordSampleRate:I

    .line 254
    const v0, 0xea60

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    const-string v11, "maxMs"

    invoke-virtual {v2, v11, v0}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    .line 255
    .local v0, "maxMs":I
    const/16 v4, 0x3e8

    if-ge v0, v4, :cond_4

    const/16 v0, 0x3e8

    .line 256
    :cond_4
    const v4, 0x1d4c0

    if-le v0, v4, :cond_5

    const v0, 0x1d4c0

    :cond_5
    move v12, v0

    .line 257
    .end local v0    # "maxMs":I
    .local v12, "maxMs":I
    iput v12, v1, Lcom/forge/live/MicBridgePlugin;->maxRecordMs:I

    .line 260
    const/16 v0, 0x10

    .line 261
    .local v0, "channelConfig":I
    const/4 v13, 0x2

    .line 262
    .local v13, "audioFormat":I
    :try_start_0
    invoke-static {v10, v0, v13}, Landroid/media/AudioRecord;->getMinBufferSize(III)I

    move-result v4

    .line 263
    .local v4, "minBuf":I
    if-gtz v4, :cond_6

    mul-int/lit8 v4, v10, 0x2

    :cond_6
    move v14, v4

    .line 264
    .end local v4    # "minBuf":I
    .local v14, "minBuf":I
    mul-int/lit8 v4, v14, 0x2

    const/16 v5, 0x1000

    invoke-static {v4, v5}, Ljava/lang/Math;->max(II)I

    move-result v9

    .line 266
    .local v9, "bufSize":I
    new-instance v15, Landroid/media/AudioRecord;

    const/4 v5, 0x1

    move-object v4, v15

    move v6, v10

    move v7, v0

    move v8, v13

    invoke-direct/range {v4 .. v9}, Landroid/media/AudioRecord;-><init>(IIIII)V

    iput-object v15, v1, Lcom/forge/live/MicBridgePlugin;->audioRecord:Landroid/media/AudioRecord;

    .line 273
    invoke-virtual {v15}, Landroid/media/AudioRecord;->getState()I

    move-result v4

    const/4 v5, 0x1

    if-eq v4, v5, :cond_7

    .line 274
    invoke-direct/range {p0 .. p0}, Lcom/forge/live/MicBridgePlugin;->releaseAudioRecord()V

    .line 275
    const-string v3, "AudioRecord failed to initialize"

    invoke-virtual {v2, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 276
    return-void

    .line 279
    :cond_7
    new-instance v4, Ljava/io/File;

    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/MicBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v6

    invoke-virtual {v6}, Landroid/content/Context;->getCacheDir()Ljava/io/File;

    move-result-object v6

    const-string v7, "mic"

    invoke-direct {v4, v6, v7}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 280
    .local v4, "dir":Ljava/io/File;
    invoke-virtual {v4}, Ljava/io/File;->exists()Z

    move-result v6

    if-nez v6, :cond_8

    invoke-virtual {v4}, Ljava/io/File;->mkdirs()Z

    .line 281
    :cond_8
    new-instance v6, Ljava/io/File;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "rec_"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    move-object v15, v6

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v5

    invoke-virtual {v7, v5, v6}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, ".wav"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    move-object v6, v15

    invoke-direct {v6, v4, v5}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    iput-object v6, v1, Lcom/forge/live/MicBridgePlugin;->wavFile:Ljava/io/File;

    .line 283
    iget-object v5, v1, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v6, 0x1

    invoke-virtual {v5, v6}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 284
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v5

    iput-wide v5, v1, Lcom/forge/live/MicBridgePlugin;->recordStartedAt:J

    .line 285
    move v5, v10

    .line 286
    .local v5, "sr":I
    move v6, v9

    .line 287
    .local v6, "bufferSize":I
    new-instance v7, Ljava/lang/Thread;

    new-instance v15, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda3;

    invoke-direct {v15, v1, v5, v6}, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda3;-><init>(Lcom/forge/live/MicBridgePlugin;II)V

    const-string v8, "forge-mic-wav"

    invoke-direct {v7, v15, v8}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    iput-object v7, v1, Lcom/forge/live/MicBridgePlugin;->recordThread:Ljava/lang/Thread;

    .line 288
    invoke-virtual {v7}, Ljava/lang/Thread;->start()V

    .line 291
    iget-object v7, v1, Lcom/forge/live/MicBridgePlugin;->main:Landroid/os/Handler;

    new-instance v8, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda4;

    invoke-direct {v8, v1}, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda4;-><init>(Lcom/forge/live/MicBridgePlugin;)V

    iget v15, v1, Lcom/forge/live/MicBridgePlugin;->maxRecordMs:I

    move-object/from16 v16, v4

    move/from16 v17, v5

    .end local v4    # "dir":Ljava/io/File;
    .end local v5    # "sr":I
    .local v16, "dir":Ljava/io/File;
    .local v17, "sr":I
    int-to-long v4, v15

    const-wide/16 v18, 0xc8

    add-long v4, v4, v18

    invoke-virtual {v7, v8, v4, v5}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 298
    new-instance v4, Lcom/getcapacitor/JSObject;

    invoke-direct {v4}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 299
    .local v4, "ret":Lcom/getcapacitor/JSObject;
    const-string v5, "recording"

    const/4 v7, 0x1

    invoke-virtual {v4, v5, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 300
    invoke-virtual {v4, v3, v10}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 301
    iget v3, v1, Lcom/forge/live/MicBridgePlugin;->maxRecordMs:I

    invoke-virtual {v4, v11, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 302
    const-string v3, "format"

    const-string v5, "wav"

    invoke-virtual {v4, v3, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 303
    invoke-virtual {v2, v4}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 308
    .end local v0    # "channelConfig":I
    .end local v4    # "ret":Lcom/getcapacitor/JSObject;
    .end local v6    # "bufferSize":I
    .end local v9    # "bufSize":I
    .end local v13    # "audioFormat":I
    .end local v14    # "minBuf":I
    .end local v16    # "dir":Ljava/io/File;
    .end local v17    # "sr":I
    goto :goto_0

    .line 304
    :catch_0
    move-exception v0

    .line 305
    .local v0, "e":Ljava/lang/Exception;
    iget-object v3, v1, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v4, 0x0

    invoke-virtual {v3, v4}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 306
    invoke-direct/range {p0 .. p0}, Lcom/forge/live/MicBridgePlugin;->releaseAudioRecord()V

    .line 307
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "startRecord failed: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 309
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method public stop(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 208
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->main:Landroid/os/Handler;

    new-instance v1, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda1;

    invoke-direct {v1, p0, p1}, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda1;-><init>(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 217
    return-void
.end method

.method public stopRecord(Lcom/getcapacitor/PluginCall;)V
    .locals 6
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 313
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v0

    const-string v1, "stopRecord failed: "

    if-nez v0, :cond_2

    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recordThread:Ljava/lang/Thread;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Ljava/lang/Thread;->isAlive()Z

    move-result v0

    if-nez v0, :cond_2

    .line 315
    :cond_0
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->wavFile:Ljava/io/File;

    if-eqz v0, :cond_1

    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v0

    if-eqz v0, :cond_1

    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->wavFile:Ljava/io/File;

    invoke-virtual {v0}, Ljava/io/File;->length()J

    move-result-wide v2

    const-wide/16 v4, 0x2c

    cmp-long v0, v2, v4

    if-lez v0, :cond_1

    .line 317
    :try_start_0
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->wavFile:Ljava/io/File;

    iget v2, p0, Lcom/forge/live/MicBridgePlugin;->recordSampleRate:I

    invoke-direct {p0, v0, v2}, Lcom/forge/live/MicBridgePlugin;->fileToResult(Ljava/io/File;I)Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 318
    return-void

    .line 319
    :catch_0
    move-exception v0

    .line 320
    .local v0, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 321
    return-void

    .line 324
    .end local v0    # "e":Ljava/lang/Exception;
    :cond_1
    const-string v0, "Not recording"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 325
    return-void

    .line 327
    :cond_2
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recording:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v2, 0x0

    invoke-virtual {v0, v2}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 329
    :try_start_1
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recordThread:Ljava/lang/Thread;

    if-eqz v0, :cond_3

    const-wide/16 v2, 0xbb8

    invoke-virtual {v0, v2, v3}, Ljava/lang/Thread;->join(J)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_0

    .line 330
    :catch_1
    move-exception v0

    :cond_3
    :goto_0
    nop

    .line 331
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/forge/live/MicBridgePlugin;->recordThread:Ljava/lang/Thread;

    .line 332
    invoke-direct {p0}, Lcom/forge/live/MicBridgePlugin;->releaseAudioRecord()V

    .line 335
    :try_start_2
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->wavFile:Ljava/io/File;

    if-eqz v0, :cond_5

    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v0

    if-nez v0, :cond_4

    goto :goto_1

    .line 339
    :cond_4
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin;->wavFile:Ljava/io/File;

    iget v2, p0, Lcom/forge/live/MicBridgePlugin;->recordSampleRate:I

    invoke-direct {p0, v0, v2}, Lcom/forge/live/MicBridgePlugin;->fileToResult(Ljava/io/File;I)Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 342
    goto :goto_2

    .line 336
    :cond_5
    :goto_1
    const-string v0, "No recording file"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

    .line 337
    return-void

    .line 340
    :catch_2
    move-exception v0

    .line 341
    .restart local v0    # "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 343
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_2
    return-void
.end method
