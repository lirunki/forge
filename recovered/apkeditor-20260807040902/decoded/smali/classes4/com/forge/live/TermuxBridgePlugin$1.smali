.class Lcom/forge/live/TermuxBridgePlugin$1;
.super Landroid/content/BroadcastReceiver;
.source "TermuxBridgePlugin.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/forge/live/TermuxBridgePlugin;->ensureReceiver()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/forge/live/TermuxBridgePlugin;


# direct methods
.method constructor <init>(Lcom/forge/live/TermuxBridgePlugin;)V
    .locals 0
    .param p1, "this$0"    # Lcom/forge/live/TermuxBridgePlugin;

    .line 115
    iput-object p1, p0, Lcom/forge/live/TermuxBridgePlugin$1;->this$0:Lcom/forge/live/TermuxBridgePlugin;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 10
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .line 118
    const-string v0, "errmsg"

    const-string v1, ""

    const-string v2, "err"

    if-nez p2, :cond_0

    return-void

    .line 119
    :cond_0
    const-string v3, "forge_exec_token"

    const/4 v4, -0x1

    invoke-virtual {p2, v3, v4}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I

    move-result v3

    .line 120
    .local v3, "token":I
    iget-object v4, p0, Lcom/forge/live/TermuxBridgePlugin$1;->this$0:Lcom/forge/live/TermuxBridgePlugin;

    invoke-static {v4}, Lcom/forge/live/TermuxBridgePlugin;->-$$Nest$fgetpendingExec(Lcom/forge/live/TermuxBridgePlugin;)Ljava/util/Map;

    move-result-object v4

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    invoke-interface {v4, v5}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Lcom/getcapacitor/PluginCall;

    .line 121
    .local v4, "call":Lcom/getcapacitor/PluginCall;
    if-nez v4, :cond_1

    return-void

    .line 124
    :cond_1
    :try_start_0
    const-string v5, "result"

    invoke-virtual {p2, v5}, Landroid/content/Intent;->getBundleExtra(Ljava/lang/String;)Landroid/os/Bundle;

    move-result-object v5

    .line 125
    .local v5, "result":Landroid/os/Bundle;
    if-nez v5, :cond_2

    invoke-virtual {p2}, Landroid/content/Intent;->getExtras()Landroid/os/Bundle;

    move-result-object v6

    move-object v5, v6

    .line 127
    :cond_2
    new-instance v6, Lcom/getcapacitor/JSObject;

    invoke-direct {v6}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 128
    .local v6, "ret":Lcom/getcapacitor/JSObject;
    const-string v7, "ok"

    const/4 v8, 0x1

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 129
    const-string v7, "bridge"

    const-string v8, "run_command"

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 130
    const-string v7, "stderr"

    const-string v8, "stdout"

    const-string v9, "exitCode"

    if-eqz v5, :cond_8

    .line 131
    :try_start_1
    invoke-virtual {v5, v8}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/forge/live/TermuxBridgePlugin;->-$$Nest$smnz(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v6, v8, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 132
    invoke-virtual {v5, v7}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/forge/live/TermuxBridgePlugin;->-$$Nest$smnz(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v6, v7, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 133
    invoke-virtual {v5, v9}, Landroid/os/Bundle;->containsKey(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_3

    .line 134
    invoke-virtual {v5, v9}, Landroid/os/Bundle;->getInt(Ljava/lang/String;)I

    move-result v1

    invoke-virtual {v6, v9, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    goto :goto_0

    .line 136
    :cond_3
    sget-object v1, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;

    invoke-virtual {v6, v9, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 138
    :goto_0
    invoke-virtual {v5, v2}, Landroid/os/Bundle;->containsKey(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_4

    .line 139
    invoke-virtual {v5, v2}, Landroid/os/Bundle;->getInt(Ljava/lang/String;)I

    move-result v1

    invoke-virtual {v6, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 141
    :cond_4
    const/4 v1, 0x0

    invoke-virtual {v5, v0, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 142
    .local v2, "errmsg":Ljava/lang/String;
    if-eqz v2, :cond_5

    invoke-virtual {v6, v0, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 143
    :cond_5
    const-string v0, "stdout_original_length"

    invoke-virtual {v5, v0, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 144
    .local v0, "sol":Ljava/lang/String;
    if-eqz v0, :cond_6

    const-string v7, "stdoutOriginalLength"

    invoke-virtual {v6, v7, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 145
    :cond_6
    const-string v7, "stderr_original_length"

    invoke-virtual {v5, v7, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 146
    .local v1, "sel":Ljava/lang/String;
    if-eqz v1, :cond_7

    const-string v7, "stderrOriginalLength"

    invoke-virtual {v6, v7, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 147
    .end local v0    # "sol":Ljava/lang/String;
    .end local v1    # "sel":Ljava/lang/String;
    .end local v2    # "errmsg":Ljava/lang/String;
    :cond_7
    goto :goto_1

    .line 148
    :cond_8
    invoke-virtual {v6, v8, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 149
    invoke-virtual {v6, v7, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 150
    sget-object v0, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;

    invoke-virtual {v6, v9, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 151
    const-string v0, "note"

    const-string v1, "Result bundle missing \u2014 Termux may be outdated or RUN_COMMAND blocked."

    invoke-virtual {v6, v0, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 153
    :goto_1
    invoke-virtual {v4, v6}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .line 156
    .end local v5    # "result":Landroid/os/Bundle;
    .end local v6    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_2

    .line 154
    :catch_0
    move-exception v0

    .line 155
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Termux exec result parse failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v4, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 157
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_2
    return-void
.end method
