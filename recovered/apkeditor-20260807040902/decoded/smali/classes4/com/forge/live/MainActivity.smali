.class public Lcom/forge/live/MainActivity;
.super Lcom/getcapacitor/BridgeActivity;
.source "MainActivity.java"


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 11
    invoke-direct {p0}, Lcom/getcapacitor/BridgeActivity;-><init>()V

    return-void
.end method

.method private dispatchForgeIntent(Landroid/content/Intent;)V
    .locals 2
    .param p1, "intent"    # Landroid/content/Intent;

    .line 106
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/MainActivity;->getBridge()Lcom/getcapacitor/Bridge;

    move-result-object v0

    if-eqz v0, :cond_2

    if-nez p1, :cond_0

    goto :goto_0

    .line 107
    :cond_0
    invoke-virtual {p0}, Lcom/forge/live/MainActivity;->getBridge()Lcom/getcapacitor/Bridge;

    move-result-object v0

    const-string v1, "ShortcutBridge"

    invoke-virtual {v0, v1}, Lcom/getcapacitor/Bridge;->getPlugin(Ljava/lang/String;)Lcom/getcapacitor/PluginHandle;

    move-result-object v0

    .line 108
    .local v0, "handle":Lcom/getcapacitor/PluginHandle;
    if-nez v0, :cond_1

    return-void

    .line 109
    :cond_1
    invoke-virtual {v0}, Lcom/getcapacitor/PluginHandle;->getInstance()Lcom/getcapacitor/Plugin;

    move-result-object v1

    instance-of v1, v1, Lcom/forge/live/ShortcutBridgePlugin;

    if-eqz v1, :cond_3

    .line 110
    invoke-virtual {v0}, Lcom/getcapacitor/PluginHandle;->getInstance()Lcom/getcapacitor/Plugin;

    move-result-object v1

    check-cast v1, Lcom/forge/live/ShortcutBridgePlugin;

    invoke-virtual {v1, p1}, Lcom/forge/live/ShortcutBridgePlugin;->captureLaunchIntent(Landroid/content/Intent;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    .line 106
    .end local v0    # "handle":Lcom/getcapacitor/PluginHandle;
    :cond_2
    :goto_0
    return-void

    .line 112
    :catch_0
    move-exception v0

    :cond_3
    :goto_1
    nop

    .line 113
    return-void
.end method

.method static extractAppId(Landroid/content/Intent;)Ljava/lang/String;
    .locals 7
    .param p0, "intent"    # Landroid/content/Intent;

    .line 83
    const/4 v0, 0x0

    if-nez p0, :cond_0

    return-object v0

    .line 84
    :cond_0
    const-string v1, "forge_app_id"

    invoke-virtual {p0, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 85
    .local v1, "id":Ljava/lang/String;
    if-eqz v1, :cond_1

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-nez v2, :cond_1

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    return-object v0

    .line 86
    :cond_1
    invoke-virtual {p0}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v2

    .line 87
    .local v2, "data":Landroid/net/Uri;
    if-nez v2, :cond_2

    return-object v0

    .line 88
    :cond_2
    invoke-virtual {v2}, Landroid/net/Uri;->getHost()Ljava/lang/String;

    move-result-object v3

    .line 89
    .local v3, "host":Ljava/lang/String;
    invoke-virtual {v2}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v4

    .line 90
    .local v4, "path":Ljava/lang/String;
    const-string v5, "app"

    invoke-virtual {v5, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_6

    if-eqz v4, :cond_6

    invoke-virtual {v4}, Ljava/lang/String;->length()I

    move-result v5

    const/4 v6, 0x1

    if-le v5, v6, :cond_6

    .line 91
    const-string v5, "/"

    invoke-virtual {v4, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v5

    if-eqz v5, :cond_3

    invoke-virtual {v4, v6}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v5

    goto :goto_0

    :cond_3
    move-object v5, v4

    :goto_0
    move-object v1, v5

    .line 93
    const/16 v5, 0x2f

    invoke-virtual {v1, v5}, Ljava/lang/String;->indexOf(I)I

    move-result v5

    .line 94
    .local v5, "slash":I
    if-lez v5, :cond_4

    const/4 v6, 0x0

    invoke-virtual {v1, v6, v5}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    .line 95
    :cond_4
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/String;->isEmpty()Z

    move-result v6

    if-eqz v6, :cond_5

    goto :goto_1

    :cond_5
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    :goto_1
    return-object v0

    .line 97
    .end local v5    # "slash":I
    :cond_6
    const-string v5, "id"

    invoke-virtual {v2, v5}, Landroid/net/Uri;->getQueryParameter(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    if-eqz v6, :cond_7

    .line 98
    invoke-virtual {v2, v5}, Landroid/net/Uri;->getQueryParameter(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 99
    if-eqz v1, :cond_7

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v5

    if-nez v5, :cond_7

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    return-object v0

    .line 101
    :cond_7
    return-object v0
.end method

.method private forwardOpenAppToRunner(Landroid/content/Intent;)Z
    .locals 5
    .param p1, "intent"    # Landroid/content/Intent;

    .line 58
    const-string v0, "forge_app_title"

    const/4 v1, 0x0

    if-nez p1, :cond_0

    return v1

    .line 59
    :cond_0
    invoke-static {p1}, Lcom/forge/live/MainActivity;->extractAppId(Landroid/content/Intent;)Ljava/lang/String;

    move-result-object v2

    .line 60
    .local v2, "id":Ljava/lang/String;
    if-nez v2, :cond_1

    return v1

    .line 63
    :cond_1
    :try_start_0
    invoke-virtual {p1, v0}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 64
    .local v3, "title":Ljava/lang/String;
    invoke-static {p0, v2, v3}, Lcom/forge/live/ShortcutBridgePlugin;->buildRunIntent(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v4

    .line 65
    .local v4, "run":Landroid/content/Intent;
    invoke-virtual {p0, v4}, Lcom/forge/live/MainActivity;->startActivity(Landroid/content/Intent;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 68
    .end local v3    # "title":Ljava/lang/String;
    .end local v4    # "run":Landroid/content/Intent;
    nop

    .line 72
    :try_start_1
    const-string v1, "forge_app_id"

    invoke-virtual {p1, v1}, Landroid/content/Intent;->removeExtra(Ljava/lang/String;)V

    .line 73
    invoke-virtual {p1, v0}, Landroid/content/Intent;->removeExtra(Ljava/lang/String;)V

    .line 74
    const/4 v0, 0x0

    invoke-virtual {p1, v0}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 75
    const-string v0, "com.forge.live.OPEN_APP"

    invoke-virtual {p1}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_2

    .line 76
    const-string v0, "android.intent.action.MAIN"

    invoke-virtual {p1, v0}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_0

    .line 78
    :catch_0
    move-exception v0

    :cond_2
    :goto_0
    nop

    .line 79
    const/4 v0, 0x1

    return v0

    .line 66
    :catch_1
    move-exception v0

    .line 67
    .local v0, "ignored":Ljava/lang/Exception;
    return v1
.end method

.method private keepWebViewAlive()V
    .locals 1

    .line 135
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/MainActivity;->getBridge()Lcom/getcapacitor/Bridge;

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    .line 136
    :cond_0
    invoke-virtual {p0}, Lcom/forge/live/MainActivity;->getBridge()Lcom/getcapacitor/Bridge;

    move-result-object v0

    invoke-virtual {v0}, Lcom/getcapacitor/Bridge;->getWebView()Landroid/webkit/WebView;

    move-result-object v0

    .line 137
    .local v0, "webView":Landroid/webkit/WebView;
    if-nez v0, :cond_1

    return-void

    .line 138
    :cond_1
    invoke-virtual {v0}, Landroid/webkit/WebView;->resumeTimers()V

    .line 139
    invoke-virtual {v0}, Landroid/webkit/WebView;->onResume()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .end local v0    # "webView":Landroid/webkit/WebView;
    goto :goto_0

    .line 140
    :catch_0
    move-exception v0

    :goto_0
    nop

    .line 141
    return-void
.end method


# virtual methods
.method protected isRunnerInstance()Z
    .locals 1

    .line 15
    const/4 v0, 0x0

    return v0
.end method

.method public onCreate(Landroid/os/Bundle;)V
    .locals 2
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    .line 20
    const-class v0, Lcom/forge/live/BackgroundForgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 21
    const-class v0, Lcom/forge/live/PhoneBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 22
    const-class v0, Lcom/forge/live/AppsBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 23
    const-class v0, Lcom/forge/live/TtsBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 24
    const-class v0, Lcom/forge/live/MicBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 25
    const-class v0, Lcom/forge/live/CameraBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 26
    const-class v0, Lcom/forge/live/FilesBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 27
    const-class v0, Lcom/forge/live/TermuxBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 28
    const-class v0, Lcom/forge/live/ShortcutBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 29
    const-class v0, Lcom/forge/live/NotifyBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 30
    const-class v0, Lcom/forge/live/JobBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 31
    const-class v0, Lcom/forge/live/QrBridgePlugin;

    invoke-virtual {p0, v0}, Lcom/forge/live/MainActivity;->registerPlugin(Ljava/lang/Class;)V

    .line 32
    invoke-super {p0, p1}, Lcom/getcapacitor/BridgeActivity;->onCreate(Landroid/os/Bundle;)V

    .line 34
    invoke-virtual {p0}, Lcom/forge/live/MainActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    .line 35
    .local v0, "intent":Landroid/content/Intent;
    invoke-virtual {p0}, Lcom/forge/live/MainActivity;->isRunnerInstance()Z

    move-result v1

    if-nez v1, :cond_0

    invoke-direct {p0, v0}, Lcom/forge/live/MainActivity;->forwardOpenAppToRunner(Landroid/content/Intent;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 37
    return-void

    .line 39
    :cond_0
    invoke-direct {p0, v0}, Lcom/forge/live/MainActivity;->dispatchForgeIntent(Landroid/content/Intent;)V

    .line 40
    return-void
.end method

.method protected onNewIntent(Landroid/content/Intent;)V
    .locals 1
    .param p1, "intent"    # Landroid/content/Intent;

    .line 44
    invoke-super {p0, p1}, Lcom/getcapacitor/BridgeActivity;->onNewIntent(Landroid/content/Intent;)V

    .line 45
    invoke-virtual {p0, p1}, Lcom/forge/live/MainActivity;->setIntent(Landroid/content/Intent;)V

    .line 46
    invoke-virtual {p0}, Lcom/forge/live/MainActivity;->isRunnerInstance()Z

    move-result v0

    if-nez v0, :cond_0

    invoke-direct {p0, p1}, Lcom/forge/live/MainActivity;->forwardOpenAppToRunner(Landroid/content/Intent;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 47
    return-void

    .line 49
    :cond_0
    invoke-direct {p0, p1}, Lcom/forge/live/MainActivity;->dispatchForgeIntent(Landroid/content/Intent;)V

    .line 50
    return-void
.end method

.method public onPause()V
    .locals 0

    .line 117
    invoke-super {p0}, Lcom/getcapacitor/BridgeActivity;->onPause()V

    .line 118
    invoke-direct {p0}, Lcom/forge/live/MainActivity;->keepWebViewAlive()V

    .line 119
    return-void
.end method

.method public onStop()V
    .locals 0

    .line 123
    invoke-super {p0}, Lcom/getcapacitor/BridgeActivity;->onStop()V

    .line 124
    invoke-direct {p0}, Lcom/forge/live/MainActivity;->keepWebViewAlive()V

    .line 125
    return-void
.end method

.method public onWindowFocusChanged(Z)V
    .locals 0
    .param p1, "hasFocus"    # Z

    .line 129
    invoke-super {p0, p1}, Lcom/getcapacitor/BridgeActivity;->onWindowFocusChanged(Z)V

    .line 130
    if-nez p1, :cond_0

    invoke-direct {p0}, Lcom/forge/live/MainActivity;->keepWebViewAlive()V

    .line 131
    :cond_0
    return-void
.end method
