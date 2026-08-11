.class Lcom/forge/live/TtsBridgePlugin$1;
.super Landroid/speech/tts/UtteranceProgressListener;
.source "TtsBridgePlugin.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/forge/live/TtsBridgePlugin;->onInit(I)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/forge/live/TtsBridgePlugin;


# direct methods
.method constructor <init>(Lcom/forge/live/TtsBridgePlugin;)V
    .locals 0
    .param p1, "this$0"    # Lcom/forge/live/TtsBridgePlugin;

    .line 71
    iput-object p1, p0, Lcom/forge/live/TtsBridgePlugin$1;->this$0:Lcom/forge/live/TtsBridgePlugin;

    invoke-direct {p0}, Landroid/speech/tts/UtteranceProgressListener;-><init>()V

    return-void
.end method


# virtual methods
.method public onDone(Ljava/lang/String;)V
    .locals 3
    .param p1, "utteranceId"    # Ljava/lang/String;

    .line 76
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin$1;->this$0:Lcom/forge/live/TtsBridgePlugin;

    const/4 v1, 0x1

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Lcom/forge/live/TtsBridgePlugin;->-$$Nest$mcompleteSpeaking(Lcom/forge/live/TtsBridgePlugin;ZLjava/lang/String;)V

    .line 77
    return-void
.end method

.method public onError(Ljava/lang/String;)V
    .locals 3
    .param p1, "utteranceId"    # Ljava/lang/String;

    .line 81
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin$1;->this$0:Lcom/forge/live/TtsBridgePlugin;

    const/4 v1, 0x0

    const-string v2, "TTS utterance error"

    invoke-static {v0, v1, v2}, Lcom/forge/live/TtsBridgePlugin;->-$$Nest$mcompleteSpeaking(Lcom/forge/live/TtsBridgePlugin;ZLjava/lang/String;)V

    .line 82
    return-void
.end method

.method public onError(Ljava/lang/String;I)V
    .locals 3
    .param p1, "utteranceId"    # Ljava/lang/String;
    .param p2, "errorCode"    # I

    .line 86
    iget-object v0, p0, Lcom/forge/live/TtsBridgePlugin$1;->this$0:Lcom/forge/live/TtsBridgePlugin;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "TTS error code "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    invoke-static {v0, v2, v1}, Lcom/forge/live/TtsBridgePlugin;->-$$Nest$mcompleteSpeaking(Lcom/forge/live/TtsBridgePlugin;ZLjava/lang/String;)V

    .line 87
    return-void
.end method

.method public onStart(Ljava/lang/String;)V
    .locals 0
    .param p1, "utteranceId"    # Ljava/lang/String;

    .line 72
    return-void
.end method
