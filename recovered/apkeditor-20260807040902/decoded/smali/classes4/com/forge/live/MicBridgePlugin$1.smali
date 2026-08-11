.class Lcom/forge/live/MicBridgePlugin$1;
.super Ljava/lang/Object;
.source "MicBridgePlugin.java"

# interfaces
.implements Landroid/speech/RecognitionListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/forge/live/MicBridgePlugin;->listen(Lcom/getcapacitor/PluginCall;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/forge/live/MicBridgePlugin;

.field final synthetic val$wantPartial:Z


# direct methods
.method constructor <init>(Lcom/forge/live/MicBridgePlugin;Z)V
    .locals 0
    .param p1, "this$0"    # Lcom/forge/live/MicBridgePlugin;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 128
    iput-object p1, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    iput-boolean p2, p0, Lcom/forge/live/MicBridgePlugin$1;->val$wantPartial:Z

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onBeginningOfSpeech()V
    .locals 0

    .line 130
    return-void
.end method

.method public onBufferReceived([B)V
    .locals 0
    .param p1, "buffer"    # [B

    .line 132
    return-void
.end method

.method public onEndOfSpeech()V
    .locals 0

    .line 133
    return-void
.end method

.method public onError(I)V
    .locals 3
    .param p1, "error"    # I

    .line 137
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lcom/forge/live/MicBridgePlugin;->-$$Nest$fputlistening(Lcom/forge/live/MicBridgePlugin;Z)V

    .line 138
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    invoke-static {v0}, Lcom/forge/live/MicBridgePlugin;->-$$Nest$fgetactiveCall(Lcom/forge/live/MicBridgePlugin;)Lcom/getcapacitor/PluginCall;

    move-result-object v0

    .line 139
    .local v0, "c":Lcom/getcapacitor/PluginCall;
    iget-object v1, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    const/4 v2, 0x0

    invoke-static {v1, v2}, Lcom/forge/live/MicBridgePlugin;->-$$Nest$fputactiveCall(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    .line 140
    iget-object v1, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    invoke-static {v1}, Lcom/forge/live/MicBridgePlugin;->-$$Nest$mdestroyRecognizer(Lcom/forge/live/MicBridgePlugin;)V

    .line 141
    if-eqz v0, :cond_0

    .line 142
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Speech error code "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " ("

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-static {p1}, Lcom/forge/live/MicBridgePlugin;->-$$Nest$smerrorName(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ")"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 144
    :cond_0
    return-void
.end method

.method public onEvent(ILandroid/os/Bundle;)V
    .locals 0
    .param p1, "eventType"    # I
    .param p2, "params"    # Landroid/os/Bundle;

    .line 186
    return-void
.end method

.method public onPartialResults(Landroid/os/Bundle;)V
    .locals 4
    .param p1, "partialResults"    # Landroid/os/Bundle;

    .line 178
    iget-boolean v0, p0, Lcom/forge/live/MicBridgePlugin$1;->val$wantPartial:Z

    if-eqz v0, :cond_3

    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    invoke-static {v0}, Lcom/forge/live/MicBridgePlugin;->-$$Nest$fgetactiveCall(Lcom/forge/live/MicBridgePlugin;)Lcom/getcapacitor/PluginCall;

    move-result-object v0

    if-eqz v0, :cond_3

    if-nez p1, :cond_0

    goto :goto_1

    .line 179
    :cond_0
    const-string v0, "results_recognition"

    invoke-virtual {p1, v0}, Landroid/os/Bundle;->getStringArrayList(Ljava/lang/String;)Ljava/util/ArrayList;

    move-result-object v0

    .line 180
    .local v0, "list":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/String;>;"
    if-eqz v0, :cond_2

    invoke-virtual {v0}, Ljava/util/ArrayList;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_1

    goto :goto_0

    .line 181
    :cond_1
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 182
    .local v1, "ev":Lcom/getcapacitor/JSObject;
    const/4 v2, 0x0

    invoke-virtual {v0, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    const-string v3, "transcript"

    invoke-virtual {v1, v3, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 183
    iget-object v2, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    const-string v3, "partial"

    invoke-static {v2, v3, v1}, Lcom/forge/live/MicBridgePlugin;->access$000(Lcom/forge/live/MicBridgePlugin;Ljava/lang/String;Lcom/getcapacitor/JSObject;)V

    .line 184
    return-void

    .line 180
    .end local v1    # "ev":Lcom/getcapacitor/JSObject;
    :cond_2
    :goto_0
    return-void

    .line 178
    .end local v0    # "list":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/String;>;"
    :cond_3
    :goto_1
    return-void
.end method

.method public onReadyForSpeech(Landroid/os/Bundle;)V
    .locals 0
    .param p1, "params"    # Landroid/os/Bundle;

    .line 129
    return-void
.end method

.method public onResults(Landroid/os/Bundle;)V
    .locals 11
    .param p1, "results"    # Landroid/os/Bundle;

    .line 148
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lcom/forge/live/MicBridgePlugin;->-$$Nest$fputlistening(Lcom/forge/live/MicBridgePlugin;Z)V

    .line 149
    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    invoke-static {v0}, Lcom/forge/live/MicBridgePlugin;->-$$Nest$fgetactiveCall(Lcom/forge/live/MicBridgePlugin;)Lcom/getcapacitor/PluginCall;

    move-result-object v0

    .line 150
    .local v0, "c":Lcom/getcapacitor/PluginCall;
    iget-object v1, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    const/4 v2, 0x0

    invoke-static {v1, v2}, Lcom/forge/live/MicBridgePlugin;->-$$Nest$fputactiveCall(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    .line 151
    iget-object v1, p0, Lcom/forge/live/MicBridgePlugin$1;->this$0:Lcom/forge/live/MicBridgePlugin;

    invoke-static {v1}, Lcom/forge/live/MicBridgePlugin;->-$$Nest$mdestroyRecognizer(Lcom/forge/live/MicBridgePlugin;)V

    .line 152
    if-nez v0, :cond_0

    return-void

    .line 153
    :cond_0
    if-eqz p1, :cond_1

    .line 154
    const-string v1, "results_recognition"

    invoke-virtual {p1, v1}, Landroid/os/Bundle;->getStringArrayList(Ljava/lang/String;)Ljava/util/ArrayList;

    move-result-object v1

    goto :goto_0

    .line 155
    :cond_1
    move-object v1, v2

    :goto_0
    nop

    .line 156
    .local v1, "list":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/String;>;"
    if-eqz p1, :cond_2

    .line 157
    const-string v2, "confidence_scores"

    invoke-virtual {p1, v2}, Landroid/os/Bundle;->getFloatArray(Ljava/lang/String;)[F

    move-result-object v2

    goto :goto_1

    .line 158
    :cond_2
    nop

    :goto_1
    nop

    .line 159
    .local v2, "scores":[F
    new-instance v3, Lcom/getcapacitor/JSArray;

    invoke-direct {v3}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 160
    .local v3, "alts":Lcom/getcapacitor/JSArray;
    const-string v4, ""

    .line 161
    .local v4, "best":Ljava/lang/String;
    const-string v5, "transcript"

    if-eqz v1, :cond_5

    .line 162
    const/4 v6, 0x0

    .local v6, "i":I
    :goto_2
    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    move-result v7

    if-ge v6, v7, :cond_5

    .line 163
    new-instance v7, Lcom/getcapacitor/JSObject;

    invoke-direct {v7}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 164
    .local v7, "a":Lcom/getcapacitor/JSObject;
    invoke-virtual {v1, v6}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/lang/String;

    invoke-virtual {v7, v5, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 165
    if-eqz v2, :cond_3

    array-length v8, v2

    if-ge v6, v8, :cond_3

    aget v8, v2, v6

    float-to-double v8, v8

    const-string v10, "confidence"

    invoke-virtual {v7, v10, v8, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;D)Lcom/getcapacitor/JSObject;

    .line 166
    :cond_3
    invoke-virtual {v3, v7}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 167
    if-nez v6, :cond_4

    invoke-virtual {v1, v6}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v8

    move-object v4, v8

    check-cast v4, Ljava/lang/String;

    .line 162
    .end local v7    # "a":Lcom/getcapacitor/JSObject;
    :cond_4
    add-int/lit8 v6, v6, 0x1

    goto :goto_2

    .line 170
    .end local v6    # "i":I
    :cond_5
    new-instance v6, Lcom/getcapacitor/JSObject;

    invoke-direct {v6}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 171
    .local v6, "ret":Lcom/getcapacitor/JSObject;
    invoke-virtual {v6, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 172
    const-string v5, "alternatives"

    invoke-virtual {v6, v5, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 173
    invoke-virtual {v0, v6}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 174
    return-void
.end method

.method public onRmsChanged(F)V
    .locals 0
    .param p1, "rmsdB"    # F

    .line 131
    return-void
.end method
