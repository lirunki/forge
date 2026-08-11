.class public Lcom/forge/live/TtsBridgePlugin;
.super Lcom/getcapacitor/Plugin;
.source "TtsBridgePlugin.java"

# interfaces
.implements Landroid/speech/tts/TextToSpeech$OnInitListener;


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "TtsBridge"
.end annotation


# instance fields
.field private initStarted:Z

.field private lastError:Ljava/lang/String;

.field private final main:Landroid/os/Handler;

.field private ready:Z

.field private speakingCall:Lcom/getcapacitor/PluginCall;

.field private tts:Landroid/speech/tts/TextToSpeech;

.field private final whenReadyQueue:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Ljava/lang/Runnable;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public static synthetic $r8$lambda$9XONinvwzV4FyrzRb63Ngzz56RY(Lcom/forge/live/TtsBridgePlugin;ZLjava/lang/String;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/forge/live/TtsBridgePlugin;->lambda$completeSpeaking$2(ZLjava/lang/String;)V

    return-void
.end method

.method public static synthetic $r8$lambda$MvpoNRh9QRzIOdR-LnkHD-2Xw0M(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/forge/live/TtsBridgePlugin;->lambda$enqueueWhenReady$0(Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V

    return-void
.end method

.method public static synthetic $r8$lambda$RIiEg-5nnamK2CscKMGu6nE-xa8(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/TtsBridgePlugin;->lambda$getStatus$4(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method public static synthetic $r8$lambda$X_lwGGli-t63i5K9fSF0h52ixbY(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/TtsBridgePlugin;->lambda$getVoices$6(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method public static synthetic $r8$lambda$ZxX86E6CrvLfh0wwI_wcil6XeT0(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/TtsBridgePlugin;->lambda$stop$9(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method public static synthetic $r8$lambda$aJe3TZ1EhUX0Sqicaq-2po-33aw(Lcom/forge/live/TtsBridgePlugin;)V
    .locals 0

    invoke-direct {p0}, Lcom/forge/live/TtsBridgePlugin;->lambda$startInitIfNeeded$1()V

    return-void
.end method

.method public static synthetic $r8$lambda$bA7RNYctQu_wmtfH9aAUiPAx5-Y(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/TtsBridgePlugin;->lambda$isAvailable$3(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method public static synthetic $r8$lambda$ghXD3e_bbjw-M3NGby56dAPocfU(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/forge/live/TtsBridgePlugin;->lambda$getLanguages$5(Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method public static synthetic $r8$lambda$tmKy0doay3CJPf0raIT-WWfQdoA(Lcom/forge/live/TtsBridgePlugin;Ljava/lang/String;Ljava/lang/String;DDZLcom/getcapacitor/PluginCall;ZLjava/lang/String;)V
    .locals 0

    invoke-direct/range {p0 .. p10}, Lcom/forge/live/TtsBridgePlugin;->lambda$speak$8(Ljava/lang/String;Ljava/lang/String;DDZLcom/getcapacitor/PluginCall;ZLjava/lang/String;)V

    return-void
.end method

.method public static synthetic $r8$lambda$wiM5UBeesnzxlOaN_Q-sMJZmQak(Lcom/forge/live/TtsBridgePlugin;Ljava/lang/String;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/forge/live/TtsBridgePlugin;->lambda$setLanguage$7(Ljava/lang/String;Lcom/getcapacitor/PluginCall;)V

    return-void
.end method

.method static bridge synthetic -$$Nest$mcompleteSpeaking(Lcom/forge/live/TtsBridgePlugin;ZLjava/lang/String;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/forge/live/TtsBridgePlugin;->completeSpeaking(ZLjava/lang/String;)V

    return-void
.end method

.method public constructor <init>()V
    .locals 2

    .line 25
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    .line 27
    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->main:Landroid/os/Handler;

    .line 29
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    .line 30
    iput-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->initStarted:Z

    .line 31
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->lastError:Ljava/lang/String;

    .line 33
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    iput-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->whenReadyQueue:Ljava/util/List;

    .line 34
    iput-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    return-void
.end method

.method private completeSpeaking(ZLjava/lang/String;)V
    .locals 2
    .param p1, "ok"    # Z
    .param p2, "err"    # Ljava/lang/String;

    .line 115
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->main:Landroid/os/Handler;

    new-instance v1, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda2;

    invoke-direct {v1, p0, p1, p2}, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda2;-><init>(Lcom/forge/live/TtsBridgePlugin;ZLjava/lang/String;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 127
    return-void
.end method

.method private enqueueWhenReady(Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "action"    # Ljava/lang/Runnable;

    .line 37
    iget-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    if-eqz v0, :cond_0

    .line 38
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->main:Landroid/os/Handler;

    invoke-virtual {v0, p2}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 39
    return-void

    .line 41
    :cond_0
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->whenReadyQueue:Ljava/util/List;

    new-instance v1, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda5;

    invoke-direct {v1, p0, p1, p2}, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda5;-><init>(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 48
    invoke-direct {p0}, Lcom/forge/live/TtsBridgePlugin;->startInitIfNeeded()V

    .line 49
    return-void
.end method

.method private flushQueue()V
    .locals 4

    .line 105
    new-instance v0, Ljava/util/ArrayList;

    iget-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->whenReadyQueue:Ljava/util/List;

    invoke-direct {v0, v1}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 106
    .local v0, "copy":Ljava/util/List;, "Ljava/util/List<Ljava/lang/Runnable;>;"
    iget-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->whenReadyQueue:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->clear()V

    .line 107
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Runnable;

    .line 109
    .local v2, "r":Ljava/lang/Runnable;
    :try_start_0
    iget-object v3, p0, Lcom/forge/live/TtsBridgePlugin;->main:Landroid/os/Handler;

    invoke-virtual {v3, v2}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    .line 110
    :catch_0
    move-exception v3

    :goto_1
    nop

    .line 111
    .end local v2    # "r":Ljava/lang/Runnable;
    goto :goto_0

    .line 112
    :cond_0
    return-void
.end method

.method private synthetic lambda$completeSpeaking$2(ZLjava/lang/String;)V
    .locals 4
    .param p1, "ok"    # Z
    .param p2, "err"    # Ljava/lang/String;

    .line 116
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    if-nez v0, :cond_0

    return-void

    .line 117
    :cond_0
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    .line 118
    .local v0, "c":Lcom/getcapacitor/PluginCall;
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    .line 119
    if-eqz p1, :cond_1

    .line 120
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 121
    .local v1, "ret":Lcom/getcapacitor/JSObject;
    const-string v2, "spoken"

    const/4 v3, 0x1

    invoke-virtual {v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 122
    invoke-virtual {v0, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 123
    .end local v1    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_1

    .line 124
    :cond_1
    if-eqz p2, :cond_2

    move-object v1, p2

    goto :goto_0

    :cond_2
    const-string v1, "TTS failed"

    :goto_0
    invoke-virtual {v0, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 126
    :goto_1
    return-void
.end method

.method private synthetic lambda$enqueueWhenReady$0(Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .param p2, "action"    # Ljava/lang/Runnable;

    .line 42
    iget-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    if-eqz v0, :cond_1

    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    if-nez v0, :cond_0

    goto :goto_0

    .line 46
    :cond_0
    invoke-interface {p2}, Ljava/lang/Runnable;->run()V

    .line 47
    return-void

    .line 43
    :cond_1
    :goto_0
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->lastError:Ljava/lang/String;

    if-eqz v0, :cond_2

    goto :goto_1

    :cond_2
    const-string v0, "TTS not available"

    :goto_1
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 44
    return-void
.end method

.method private synthetic lambda$getLanguages$5(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 171
    new-instance v0, Lcom/getcapacitor/JSArray;

    invoke-direct {v0}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 173
    .local v0, "langs":Lcom/getcapacitor/JSArray;
    :try_start_0
    iget-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-virtual {v1}, Landroid/speech/tts/TextToSpeech;->getAvailableLanguages()Ljava/util/Set;

    move-result-object v1

    .line 174
    .local v1, "set":Ljava/util/Set;, "Ljava/util/Set<Ljava/util/Locale;>;"
    if-eqz v1, :cond_1

    .line 175
    invoke-interface {v1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_1

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Locale;

    .line 176
    .local v3, "l":Ljava/util/Locale;
    if-eqz v3, :cond_0

    invoke-virtual {v3}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v0, v4}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 177
    .end local v3    # "l":Ljava/util/Locale;
    :cond_0
    goto :goto_0

    .line 182
    .end local v1    # "set":Ljava/util/Set;, "Ljava/util/Set<Ljava/util/Locale;>;"
    :cond_1
    goto :goto_1

    .line 179
    :catch_0
    move-exception v1

    .line 180
    .local v1, "e":Ljava/lang/Exception;
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v2

    invoke-virtual {v2}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 181
    const-string v2, "en-US"

    invoke-virtual {v0, v2}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 183
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_1
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 184
    .local v1, "ret":Lcom/getcapacitor/JSObject;
    const-string v2, "languages"

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 185
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 186
    return-void
.end method

.method private synthetic lambda$getStatus$4(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 165
    invoke-direct {p0}, Lcom/forge/live/TtsBridgePlugin;->statusObject()Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    return-void
.end method

.method private synthetic lambda$getVoices$6(Lcom/getcapacitor/PluginCall;)V
    .locals 7
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 192
    new-instance v0, Lcom/getcapacitor/JSArray;

    invoke-direct {v0}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 194
    .local v0, "voices":Lcom/getcapacitor/JSArray;
    :try_start_0
    iget-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-virtual {v1}, Landroid/speech/tts/TextToSpeech;->getVoices()Ljava/util/Set;

    move-result-object v1

    .line 195
    .local v1, "set":Ljava/util/Set;, "Ljava/util/Set<Landroid/speech/tts/Voice;>;"
    if-eqz v1, :cond_2

    .line 196
    invoke-interface {v1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_2

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Landroid/speech/tts/Voice;

    .line 197
    .local v3, "v":Landroid/speech/tts/Voice;
    if-nez v3, :cond_0

    goto :goto_0

    .line 198
    :cond_0
    new-instance v4, Lcom/getcapacitor/JSObject;

    invoke-direct {v4}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 199
    .local v4, "o":Lcom/getcapacitor/JSObject;
    const-string v5, "name"

    invoke-virtual {v3}, Landroid/speech/tts/Voice;->getName()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 200
    const-string v5, "locale"

    invoke-virtual {v3}, Landroid/speech/tts/Voice;->getLocale()Ljava/util/Locale;

    move-result-object v6

    if-eqz v6, :cond_1

    invoke-virtual {v3}, Landroid/speech/tts/Voice;->getLocale()Ljava/util/Locale;

    move-result-object v6

    invoke-virtual {v6}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v6

    goto :goto_1

    :cond_1
    const-string v6, ""

    :goto_1
    invoke-virtual {v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 201
    const-string v5, "quality"

    invoke-virtual {v3}, Landroid/speech/tts/Voice;->getQuality()I

    move-result v6

    invoke-virtual {v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 202
    const-string v5, "latency"

    invoke-virtual {v3}, Landroid/speech/tts/Voice;->getLatency()I

    move-result v6

    invoke-virtual {v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 203
    const-string v5, "networkConnectionRequired"

    invoke-virtual {v3}, Landroid/speech/tts/Voice;->isNetworkConnectionRequired()Z

    move-result v6

    invoke-virtual {v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 204
    invoke-virtual {v0, v4}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 205
    nop

    .end local v3    # "v":Landroid/speech/tts/Voice;
    .end local v4    # "o":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 210
    .end local v1    # "set":Ljava/util/Set;, "Ljava/util/Set<Landroid/speech/tts/Voice;>;"
    :cond_2
    nop

    .line 211
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 212
    .local v1, "ret":Lcom/getcapacitor/JSObject;
    const-string v2, "voices"

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 213
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 214
    return-void

    .line 207
    .end local v1    # "ret":Lcom/getcapacitor/JSObject;
    :catch_0
    move-exception v1

    .line 208
    .local v1, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "getVoices failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 209
    return-void
.end method

.method private synthetic lambda$isAvailable$3(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 156
    invoke-direct {p0}, Lcom/forge/live/TtsBridgePlugin;->statusObject()Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    return-void
.end method

.method private synthetic lambda$setLanguage$7(Ljava/lang/String;Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "lang"    # Ljava/lang/String;
    .param p2, "call"    # Lcom/getcapacitor/PluginCall;

    .line 226
    :try_start_0
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-static {p1}, Ljava/util/Locale;->forLanguageTag(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/speech/tts/TextToSpeech;->setLanguage(Ljava/util/Locale;)I

    move-result v0

    .line 227
    .local v0, "r":I
    const/4 v1, -0x1

    if-eq v0, v1, :cond_0

    const/4 v1, -0x2

    if-eq v0, v1, :cond_0

    const/4 v1, 0x1

    goto :goto_0

    :cond_0
    const/4 v1, 0x0

    .line 228
    .local v1, "ok":Z
    :goto_0
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 229
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    const-string v3, "ok"

    invoke-virtual {v2, v3, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 230
    const-string v3, "code"

    invoke-virtual {v2, v3, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 231
    invoke-virtual {p2, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 234
    .end local v0    # "r":I
    .end local v1    # "ok":Z
    .end local v2    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_1

    .line 232
    :catch_0
    move-exception v0

    .line 233
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "setLanguage failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p2, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 235
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1
    return-void
.end method

.method private synthetic lambda$speak$8(Ljava/lang/String;Ljava/lang/String;DDZLcom/getcapacitor/PluginCall;ZLjava/lang/String;)V
    .locals 16
    .param p1, "lang"    # Ljava/lang/String;
    .param p2, "voiceName"    # Ljava/lang/String;
    .param p3, "rateD"    # D
    .param p5, "pitchD"    # D
    .param p7, "queue"    # Z
    .param p8, "call"    # Lcom/getcapacitor/PluginCall;
    .param p9, "wait"    # Z
    .param p10, "speakText"    # Ljava/lang/String;

    .line 257
    move-object/from16 v1, p0

    move-object/from16 v2, p2

    move-object/from16 v3, p8

    const/4 v4, 0x0

    if-eqz p1, :cond_0

    :try_start_0
    invoke-virtual/range {p1 .. p1}, Ljava/lang/String;->isEmpty()Z

    move-result v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    if-nez v0, :cond_0

    .line 259
    :try_start_1
    iget-object v0, v1, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-static/range {p1 .. p1}, Ljava/util/Locale;->forLanguageTag(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v5

    invoke-virtual {v0, v5}, Landroid/speech/tts/TextToSpeech;->setLanguage(Ljava/util/Locale;)I
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_0

    .line 260
    :catch_0
    move-exception v0

    :goto_0
    goto :goto_2

    .line 310
    :catch_1
    move-exception v0

    move-wide/from16 v5, p3

    move-wide/from16 v8, p5

    :goto_1
    move-object/from16 v15, p10

    goto/16 :goto_5

    .line 262
    :cond_0
    :goto_2
    if-eqz v2, :cond_3

    :try_start_2
    invoke-virtual/range {p2 .. p2}, Ljava/lang/String;->isEmpty()Z

    move-result v0
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    if-nez v0, :cond_3

    .line 264
    :try_start_3
    iget-object v0, v1, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-virtual {v0}, Landroid/speech/tts/TextToSpeech;->getVoices()Ljava/util/Set;

    move-result-object v0

    .line 265
    .local v0, "set":Ljava/util/Set;, "Ljava/util/Set<Landroid/speech/tts/Voice;>;"
    if-eqz v0, :cond_2

    .line 266
    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v5

    :goto_3
    invoke-interface {v5}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_2

    invoke-interface {v5}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Landroid/speech/tts/Voice;

    .line 267
    .local v6, "v":Landroid/speech/tts/Voice;
    if-eqz v6, :cond_1

    invoke-virtual {v6}, Landroid/speech/tts/Voice;->getName()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v2, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_1

    .line 268
    iget-object v5, v1, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-virtual {v5, v6}, Landroid/speech/tts/TextToSpeech;->setVoice(Landroid/speech/tts/Voice;)I
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_2

    .line 269
    goto :goto_4

    .line 271
    .end local v6    # "v":Landroid/speech/tts/Voice;
    :cond_1
    goto :goto_3

    .line 273
    .end local v0    # "set":Ljava/util/Set;, "Ljava/util/Set<Landroid/speech/tts/Voice;>;"
    :catch_2
    move-exception v0

    :cond_2
    :goto_4
    nop

    .line 276
    :cond_3
    move-wide/from16 v5, p3

    double-to-float v0, v5

    .line 277
    .local v0, "rate":F
    const v7, 0x3dcccccd    # 0.1f

    cmpg-float v8, v0, v7

    if-gez v8, :cond_4

    const v0, 0x3dcccccd    # 0.1f

    .line 278
    :cond_4
    const/high16 v8, 0x40400000    # 3.0f

    cmpl-float v8, v0, v8

    if-lez v8, :cond_5

    const/high16 v0, 0x40400000    # 3.0f

    .line 279
    :cond_5
    move-wide/from16 v8, p5

    double-to-float v10, v8

    .line 280
    .local v10, "pitch":F
    cmpg-float v7, v10, v7

    if-gez v7, :cond_6

    const v10, 0x3dcccccd    # 0.1f

    .line 281
    :cond_6
    const/high16 v7, 0x40000000    # 2.0f

    cmpl-float v7, v10, v7

    if-lez v7, :cond_7

    const/high16 v10, 0x40000000    # 2.0f

    .line 282
    :cond_7
    :try_start_4
    iget-object v7, v1, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-virtual {v7, v0}, Landroid/speech/tts/TextToSpeech;->setSpeechRate(F)I

    .line 283
    iget-object v7, v1, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-virtual {v7, v10}, Landroid/speech/tts/TextToSpeech;->setPitch(F)I

    .line 286
    const/4 v7, 0x1

    if-nez p7, :cond_8

    iget-object v11, v1, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    if-eqz v11, :cond_8

    if-eq v11, v3, :cond_8

    .line 287
    nop

    .line 288
    .local v11, "prev":Lcom/getcapacitor/PluginCall;
    iput-object v4, v1, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    .line 289
    new-instance v12, Lcom/getcapacitor/JSObject;

    invoke-direct {v12}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 290
    .local v12, "r":Lcom/getcapacitor/JSObject;
    const-string v13, "spoken"

    const/4 v14, 0x0

    invoke-virtual {v12, v13, v14}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 291
    const-string v13, "interrupted"

    invoke-virtual {v12, v13, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 292
    invoke-virtual {v11, v12}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 295
    .end local v11    # "prev":Lcom/getcapacitor/PluginCall;
    .end local v12    # "r":Lcom/getcapacitor/JSObject;
    :cond_8
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v11

    invoke-virtual {v11}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v11

    .line 296
    .local v11, "id":Ljava/lang/String;
    move/from16 v12, p7

    .line 297
    .local v12, "mode":I
    if-eqz p9, :cond_9

    iput-object v3, v1, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    .line 299
    :cond_9
    iget-object v13, v1, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    new-instance v14, Landroid/os/Bundle;

    invoke-direct {v14}, Landroid/os/Bundle;-><init>()V
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_4

    move-object/from16 v15, p10

    :try_start_5
    invoke-virtual {v13, v15, v12, v14, v11}, Landroid/speech/tts/TextToSpeech;->speak(Ljava/lang/CharSequence;ILandroid/os/Bundle;Ljava/lang/String;)I

    move-result v13

    .line 300
    .local v13, "result":I
    const/4 v14, -0x1

    if-ne v13, v14, :cond_a

    .line 301
    iput-object v4, v1, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    .line 302
    const-string v7, "TTS speak() returned ERROR"

    invoke-virtual {v3, v7}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 303
    return-void

    .line 305
    :cond_a
    if-nez p9, :cond_b

    .line 306
    new-instance v14, Lcom/getcapacitor/JSObject;

    invoke-direct {v14}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 307
    .local v14, "ret":Lcom/getcapacitor/JSObject;
    const-string v4, "started"

    invoke-virtual {v14, v4, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 308
    invoke-virtual {v3, v14}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_3

    .line 313
    .end local v0    # "rate":F
    .end local v10    # "pitch":F
    .end local v11    # "id":Ljava/lang/String;
    .end local v12    # "mode":I
    .end local v13    # "result":I
    .end local v14    # "ret":Lcom/getcapacitor/JSObject;
    :cond_b
    goto :goto_6

    .line 310
    :catch_3
    move-exception v0

    goto :goto_5

    :catch_4
    move-exception v0

    goto/16 :goto_1

    .line 311
    .local v0, "e":Ljava/lang/Exception;
    :goto_5
    const/4 v4, 0x0

    iput-object v4, v1, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    .line 312
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "speak failed: "

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 314
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_6
    return-void
.end method

.method private synthetic lambda$startInitIfNeeded$1()V
    .locals 3

    .line 56
    :try_start_0
    new-instance v0, Landroid/speech/tts/TextToSpeech;

    invoke-virtual {p0}, Lcom/forge/live/TtsBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v1

    invoke-direct {v0, v1, p0}, Landroid/speech/tts/TextToSpeech;-><init>(Landroid/content/Context;Landroid/speech/tts/TextToSpeech$OnInitListener;)V

    iput-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 61
    goto :goto_0

    .line 57
    :catch_0
    move-exception v0

    .line 58
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "TTS init failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    iput-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->lastError:Ljava/lang/String;

    .line 59
    const/4 v1, 0x0

    iput-boolean v1, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    .line 60
    invoke-direct {p0}, Lcom/forge/live/TtsBridgePlugin;->flushQueue()V

    .line 62
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method private synthetic lambda$stop$9(Lcom/getcapacitor/PluginCall;)V
    .locals 6
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 321
    :try_start_0
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-virtual {v0}, Landroid/speech/tts/TextToSpeech;->stop()I

    .line 322
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    const/4 v1, 0x1

    const-string v2, "stopped"

    if-eqz v0, :cond_0

    .line 323
    nop

    .line 324
    .local v0, "c":Lcom/getcapacitor/PluginCall;
    const/4 v3, 0x0

    :try_start_1
    iput-object v3, p0, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    .line 325
    new-instance v3, Lcom/getcapacitor/JSObject;

    invoke-direct {v3}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 326
    .local v3, "r":Lcom/getcapacitor/JSObject;
    const-string v4, "spoken"

    const/4 v5, 0x0

    invoke-virtual {v3, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 327
    invoke-virtual {v3, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 328
    invoke-virtual {v0, v3}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 330
    .end local v0    # "c":Lcom/getcapacitor/PluginCall;
    .end local v3    # "r":Lcom/getcapacitor/JSObject;
    :cond_0
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 331
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 332
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .line 335
    .end local v0    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 333
    :catch_0
    move-exception v0

    .line 334
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "stop failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 336
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method private startInitIfNeeded()V
    .locals 2

    .line 52
    iget-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->initStarted:Z

    if-eqz v0, :cond_0

    return-void

    .line 53
    :cond_0
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->initStarted:Z

    .line 54
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->main:Landroid/os/Handler;

    new-instance v1, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda6;

    invoke-direct {v1, p0}, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda6;-><init>(Lcom/forge/live/TtsBridgePlugin;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 63
    return-void
.end method

.method private statusObject()Lcom/getcapacitor/JSObject;
    .locals 6

    .line 130
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 131
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "ready"

    iget-boolean v2, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 132
    const-string v1, "available"

    iget-boolean v2, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 133
    iget-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->lastError:Ljava/lang/String;

    if-eqz v1, :cond_0

    const-string v2, "error"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 134
    :cond_0
    iget-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    const/4 v2, 0x0

    const-string v3, "speaking"

    if-eqz v1, :cond_2

    iget-boolean v4, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    if-eqz v4, :cond_2

    .line 136
    :try_start_0
    invoke-virtual {v1}, Landroid/speech/tts/TextToSpeech;->getLanguage()Ljava/util/Locale;

    move-result-object v1

    .line 137
    .local v1, "lang":Ljava/util/Locale;
    if-eqz v1, :cond_1

    const-string v4, "language"

    invoke-virtual {v1}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v0, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 138
    .end local v1    # "lang":Ljava/util/Locale;
    :catch_0
    move-exception v1

    :cond_1
    :goto_0
    nop

    .line 140
    :try_start_1
    iget-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-virtual {v1}, Landroid/speech/tts/TextToSpeech;->isSpeaking()Z

    move-result v1

    invoke-virtual {v0, v3, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    .line 141
    :catch_1
    move-exception v1

    .line 142
    .local v1, "e":Ljava/lang/Exception;
    invoke-virtual {v0, v3, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 143
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_1
    goto :goto_2

    .line 145
    :cond_2
    invoke-virtual {v0, v3, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 147
    :goto_2
    return-object v0
.end method


# virtual methods
.method public getLanguages(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 170
    new-instance v0, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda0;

    invoke-direct {v0, p0, p1}, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda0;-><init>(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-direct {p0, p1, v0}, Lcom/forge/live/TtsBridgePlugin;->enqueueWhenReady(Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V

    .line 187
    return-void
.end method

.method public getStatus(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 161
    iget-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    if-eqz v0, :cond_0

    .line 162
    invoke-direct {p0}, Lcom/forge/live/TtsBridgePlugin;->statusObject()Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 163
    return-void

    .line 165
    :cond_0
    new-instance v0, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda4;

    invoke-direct {v0, p0, p1}, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda4;-><init>(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-direct {p0, p1, v0}, Lcom/forge/live/TtsBridgePlugin;->enqueueWhenReady(Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V

    .line 166
    return-void
.end method

.method public getVoices(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 191
    new-instance v0, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda8;

    invoke-direct {v0, p0, p1}, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda8;-><init>(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-direct {p0, p1, v0}, Lcom/forge/live/TtsBridgePlugin;->enqueueWhenReady(Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V

    .line 215
    return-void
.end method

.method protected handleOnDestroy()V
    .locals 2

    .line 341
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    const/4 v1, 0x0

    if-eqz v0, :cond_0

    .line 342
    :try_start_0
    invoke-virtual {v0}, Landroid/speech/tts/TextToSpeech;->stop()I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 343
    :goto_0
    :try_start_1
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-virtual {v0}, Landroid/speech/tts/TextToSpeech;->shutdown()V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    :catch_1
    move-exception v0

    .line 344
    :goto_1
    iput-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    .line 346
    :cond_0
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    .line 347
    iput-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->initStarted:Z

    .line 348
    iput-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->speakingCall:Lcom/getcapacitor/PluginCall;

    .line 349
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->whenReadyQueue:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->clear()V

    .line 350
    invoke-super {p0}, Lcom/getcapacitor/Plugin;->handleOnDestroy()V

    .line 351
    return-void
.end method

.method public isAvailable(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 152
    iget-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    if-eqz v0, :cond_0

    .line 153
    invoke-direct {p0}, Lcom/forge/live/TtsBridgePlugin;->statusObject()Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 154
    return-void

    .line 156
    :cond_0
    new-instance v0, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda3;

    invoke-direct {v0, p0, p1}, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda3;-><init>(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-direct {p0, p1, v0}, Lcom/forge/live/TtsBridgePlugin;->enqueueWhenReady(Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V

    .line 157
    return-void
.end method

.method public onInit(I)V
    .locals 3
    .param p1, "status"    # I

    .line 67
    if-nez p1, :cond_2

    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    if-eqz v0, :cond_2

    .line 68
    const/4 v1, 0x1

    iput-boolean v1, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    .line 69
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->lastError:Ljava/lang/String;

    .line 71
    :try_start_0
    new-instance v1, Lcom/forge/live/TtsBridgePlugin$1;

    invoke-direct {v1, p0}, Lcom/forge/live/TtsBridgePlugin$1;-><init>(Lcom/forge/live/TtsBridgePlugin;)V

    invoke-virtual {v0, v1}, Landroid/speech/tts/TextToSpeech;->setOnUtteranceProgressListener(Landroid/speech/tts/UtteranceProgressListener;)I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 89
    :catch_0
    move-exception v0

    :goto_0
    nop

    .line 92
    :try_start_1
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/speech/tts/TextToSpeech;->setLanguage(Ljava/util/Locale;)I

    move-result v0

    .line 93
    .local v0, "r":I
    const/4 v1, -0x1

    if-eq v0, v1, :cond_0

    const/4 v1, -0x2

    if-ne v0, v1, :cond_1

    .line 94
    :cond_0
    iget-object v1, p0, Lcom/forge/live/TtsBridgePlugin;->tts:Landroid/speech/tts/TextToSpeech;

    sget-object v2, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-virtual {v1, v2}, Landroid/speech/tts/TextToSpeech;->setLanguage(Ljava/util/Locale;)I
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    .line 96
    .end local v0    # "r":I
    :catch_1
    move-exception v0

    :cond_1
    :goto_1
    goto :goto_2

    .line 98
    :cond_2
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/forge/live/TtsBridgePlugin;->ready:Z

    .line 99
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "TTS engine failed to initialize (status="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "). Install a TTS engine in system settings."

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/forge/live/TtsBridgePlugin;->lastError:Ljava/lang/String;

    .line 101
    :goto_2
    invoke-direct {p0}, Lcom/forge/live/TtsBridgePlugin;->flushQueue()V

    .line 102
    return-void
.end method

.method public setLanguage(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 219
    const-string v0, "lang"

    const-string v1, ""

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 220
    .local v0, "lang":Ljava/lang/String;
    if-eqz v0, :cond_1

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_0

    .line 224
    :cond_0
    new-instance v1, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda9;

    invoke-direct {v1, p0, v0, p1}, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda9;-><init>(Lcom/forge/live/TtsBridgePlugin;Ljava/lang/String;Lcom/getcapacitor/PluginCall;)V

    invoke-direct {p0, p1, v1}, Lcom/forge/live/TtsBridgePlugin;->enqueueWhenReady(Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V

    .line 236
    return-void

    .line 221
    :cond_1
    :goto_0
    const-string v1, "lang required (e.g. en-US)"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 222
    return-void
.end method

.method public speak(Lcom/getcapacitor/PluginCall;)V
    .locals 22
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 240
    move-object/from16 v12, p1

    const-string v0, "text"

    const-string v1, ""

    invoke-virtual {v12, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 241
    .local v0, "text":Ljava/lang/String;
    if-eqz v0, :cond_2

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_0

    move-object/from16 v1, p0

    goto/16 :goto_0

    .line 245
    :cond_0
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    const/4 v2, 0x0

    const/16 v3, 0xfa0

    if-le v1, v3, :cond_1

    invoke-virtual {v0, v2, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    :cond_1
    move-object v13, v0

    .line 247
    .end local v0    # "text":Ljava/lang/String;
    .local v13, "text":Ljava/lang/String;
    move-object v11, v13

    .line 248
    .local v11, "speakText":Ljava/lang/String;
    const-string v0, "lang"

    const/4 v1, 0x0

    invoke-virtual {v12, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v14

    .line 249
    .local v14, "lang":Ljava/lang/String;
    const-string v0, "voice"

    invoke-virtual {v12, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v15

    .line 250
    .local v15, "voiceName":Ljava/lang/String;
    const-string v0, "rate"

    const-wide/high16 v3, 0x3ff0000000000000L    # 1.0

    invoke-static {v3, v4}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v1

    invoke-virtual {v12, v0, v1}, Lcom/getcapacitor/PluginCall;->getDouble(Ljava/lang/String;Ljava/lang/Double;)Ljava/lang/Double;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v16

    .line 251
    .local v16, "rateD":D
    const-string v0, "pitch"

    invoke-static {v3, v4}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v1

    invoke-virtual {v12, v0, v1}, Lcom/getcapacitor/PluginCall;->getDouble(Ljava/lang/String;Ljava/lang/Double;)Ljava/lang/Double;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v18

    .line 252
    .local v18, "pitchD":D
    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v1, "queue"

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v12, v1, v2}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v20

    .line 253
    .local v20, "queue":Z
    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    const-string v1, "wait"

    const/4 v2, 0x1

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v3

    invoke-virtual {v12, v1, v3}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v0

    xor-int/lit8 v10, v0, 0x1

    .line 255
    .local v10, "wait":Z
    new-instance v9, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda1;

    move-object v0, v9

    move-object/from16 v1, p0

    move-object v2, v14

    move-object v3, v15

    move-wide/from16 v4, v16

    move-wide/from16 v6, v18

    move/from16 v8, v20

    move-object/from16 v21, v13

    move-object v13, v9

    .end local v13    # "text":Ljava/lang/String;
    .local v21, "text":Ljava/lang/String;
    move-object/from16 v9, p1

    invoke-direct/range {v0 .. v11}, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda1;-><init>(Lcom/forge/live/TtsBridgePlugin;Ljava/lang/String;Ljava/lang/String;DDZLcom/getcapacitor/PluginCall;ZLjava/lang/String;)V

    invoke-direct {v1, v12, v13}, Lcom/forge/live/TtsBridgePlugin;->enqueueWhenReady(Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V

    .line 315
    return-void

    .line 241
    .end local v10    # "wait":Z
    .end local v11    # "speakText":Ljava/lang/String;
    .end local v14    # "lang":Ljava/lang/String;
    .end local v15    # "voiceName":Ljava/lang/String;
    .end local v16    # "rateD":D
    .end local v18    # "pitchD":D
    .end local v20    # "queue":Z
    .end local v21    # "text":Ljava/lang/String;
    .restart local v0    # "text":Ljava/lang/String;
    :cond_2
    move-object/from16 v1, p0

    .line 242
    :goto_0
    const-string v2, "text is required"

    invoke-virtual {v12, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 243
    return-void
.end method

.method public stop(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 319
    new-instance v0, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda7;

    invoke-direct {v0, p0, p1}, Lcom/forge/live/TtsBridgePlugin$$ExternalSyntheticLambda7;-><init>(Lcom/forge/live/TtsBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    invoke-direct {p0, p1, v0}, Lcom/forge/live/TtsBridgePlugin;->enqueueWhenReady(Lcom/getcapacitor/PluginCall;Ljava/lang/Runnable;)V

    .line 337
    return-void
.end method
