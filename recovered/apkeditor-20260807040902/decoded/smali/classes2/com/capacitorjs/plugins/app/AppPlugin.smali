.class public Lcom/capacitorjs/plugins/app/AppPlugin;
.super Lcom/getcapacitor/Plugin;
.source "AppPlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "App"
.end annotation


# static fields
.field private static final EVENT_BACK_BUTTON:Ljava/lang/String; = "backButton"

.field private static final EVENT_PAUSE:Ljava/lang/String; = "pause"

.field private static final EVENT_RESTORED_RESULT:Ljava/lang/String; = "appRestoredResult"

.field private static final EVENT_RESUME:Ljava/lang/String; = "resume"

.field private static final EVENT_STATE_CHANGE:Ljava/lang/String; = "appStateChange"

.field private static final EVENT_URL_OPEN:Ljava/lang/String; = "appUrlOpen"


# instance fields
.field private hasPausedEver:Z


# direct methods
.method public static synthetic $r8$lambda$UWvIpVCPW1MoxD4BF5qw2EagBy4(Lcom/capacitorjs/plugins/app/AppPlugin;Ljava/lang/Boolean;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/app/AppPlugin;->lambda$load$0(Ljava/lang/Boolean;)V

    return-void
.end method

.method public static synthetic $r8$lambda$tMEuYQE92f5zA_pvXg6u8yKz7zA(Lcom/capacitorjs/plugins/app/AppPlugin;Lcom/getcapacitor/PluginResult;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/app/AppPlugin;->lambda$load$1(Lcom/getcapacitor/PluginResult;)V

    return-void
.end method

.method public constructor <init>()V
    .locals 1

    .line 18
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    .line 26
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->hasPausedEver:Z

    return-void
.end method

.method static synthetic access$000(Lcom/capacitorjs/plugins/app/AppPlugin;Ljava/lang/String;)Z
    .locals 1
    .param p0, "x0"    # Lcom/capacitorjs/plugins/app/AppPlugin;
    .param p1, "x1"    # Ljava/lang/String;

    .line 18
    invoke-virtual {p0, p1}, Lcom/capacitorjs/plugins/app/AppPlugin;->hasListeners(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method static synthetic access$100(Lcom/capacitorjs/plugins/app/AppPlugin;)Lcom/getcapacitor/Bridge;
    .locals 1
    .param p0, "x0"    # Lcom/capacitorjs/plugins/app/AppPlugin;

    .line 18
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->bridge:Lcom/getcapacitor/Bridge;

    return-object v0
.end method

.method static synthetic access$200(Lcom/capacitorjs/plugins/app/AppPlugin;)Lcom/getcapacitor/Bridge;
    .locals 1
    .param p0, "x0"    # Lcom/capacitorjs/plugins/app/AppPlugin;

    .line 18
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->bridge:Lcom/getcapacitor/Bridge;

    return-object v0
.end method

.method static synthetic access$300(Lcom/capacitorjs/plugins/app/AppPlugin;)Lcom/getcapacitor/Bridge;
    .locals 1
    .param p0, "x0"    # Lcom/capacitorjs/plugins/app/AppPlugin;

    .line 18
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->bridge:Lcom/getcapacitor/Bridge;

    return-object v0
.end method

.method static synthetic access$400(Lcom/capacitorjs/plugins/app/AppPlugin;Ljava/lang/String;Lcom/getcapacitor/JSObject;Z)V
    .locals 0
    .param p0, "x0"    # Lcom/capacitorjs/plugins/app/AppPlugin;
    .param p1, "x1"    # Ljava/lang/String;
    .param p2, "x2"    # Lcom/getcapacitor/JSObject;
    .param p3, "x3"    # Z

    .line 18
    invoke-virtual {p0, p1, p2, p3}, Lcom/capacitorjs/plugins/app/AppPlugin;->notifyListeners(Ljava/lang/String;Lcom/getcapacitor/JSObject;Z)V

    return-void
.end method

.method static synthetic access$500(Lcom/capacitorjs/plugins/app/AppPlugin;)Lcom/getcapacitor/Bridge;
    .locals 1
    .param p0, "x0"    # Lcom/capacitorjs/plugins/app/AppPlugin;

    .line 18
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->bridge:Lcom/getcapacitor/Bridge;

    return-object v0
.end method

.method private synthetic lambda$load$0(Ljava/lang/Boolean;)V
    .locals 3
    .param p1, "isActive"    # Ljava/lang/Boolean;

    .line 33
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->getLogTag()Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Firing change: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/getcapacitor/Logger;->debug(Ljava/lang/String;Ljava/lang/String;)V

    .line 34
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 35
    .local v0, "data":Lcom/getcapacitor/JSObject;
    const-string v1, "isActive"

    invoke-virtual {v0, v1, p1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 36
    const-string v1, "appStateChange"

    const/4 v2, 0x0

    invoke-virtual {p0, v1, v0, v2}, Lcom/capacitorjs/plugins/app/AppPlugin;->notifyListeners(Ljava/lang/String;Lcom/getcapacitor/JSObject;Z)V

    .line 37
    return-void
.end method

.method private synthetic lambda$load$1(Lcom/getcapacitor/PluginResult;)V
    .locals 3
    .param p1, "result"    # Lcom/getcapacitor/PluginResult;

    .line 43
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->getLogTag()Ljava/lang/String;

    move-result-object v0

    const-string v1, "Firing restored result"

    invoke-static {v0, v1}, Lcom/getcapacitor/Logger;->debug(Ljava/lang/String;Ljava/lang/String;)V

    .line 44
    invoke-virtual {p1}, Lcom/getcapacitor/PluginResult;->getWrappedResult()Lcom/getcapacitor/JSObject;

    move-result-object v0

    const/4 v1, 0x1

    const-string v2, "appRestoredResult"

    invoke-virtual {p0, v2, v0, v1}, Lcom/capacitorjs/plugins/app/AppPlugin;->notifyListeners(Ljava/lang/String;Lcom/getcapacitor/JSObject;Z)V

    .line 45
    return-void
.end method

.method private unsetAppListeners()V
    .locals 2

    .line 156
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->bridge:Lcom/getcapacitor/Bridge;

    invoke-virtual {v0}, Lcom/getcapacitor/Bridge;->getApp()Lcom/getcapacitor/App;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lcom/getcapacitor/App;->setStatusChangeListener(Lcom/getcapacitor/App$AppStatusChangeListener;)V

    .line 157
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->bridge:Lcom/getcapacitor/Bridge;

    invoke-virtual {v0}, Lcom/getcapacitor/Bridge;->getApp()Lcom/getcapacitor/App;

    move-result-object v0

    invoke-virtual {v0, v1}, Lcom/getcapacitor/App;->setAppRestoredListener(Lcom/getcapacitor/App$AppRestoredListener;)V

    .line 158
    return-void
.end method


# virtual methods
.method public exitApp(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 67
    invoke-direct {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->unsetAppListeners()V

    .line 68
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V

    .line 69
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->getBridge()Lcom/getcapacitor/Bridge;

    move-result-object v0

    invoke-virtual {v0}, Lcom/getcapacitor/Bridge;->getActivity()Landroidx/appcompat/app/AppCompatActivity;

    move-result-object v0

    invoke-virtual {v0}, Landroidx/appcompat/app/AppCompatActivity;->finish()V

    .line 70
    return-void
.end method

.method public getInfo(Lcom/getcapacitor/PluginCall;)V
    .locals 8
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 74
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 76
    .local v0, "data":Lcom/getcapacitor/JSObject;
    :try_start_0
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v1

    invoke-virtual {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/getcapacitor/util/InternalUtils;->getPackageInfo(Landroid/content/pm/PackageManager;Ljava/lang/String;)Landroid/content/pm/PackageInfo;

    move-result-object v1

    .line 77
    .local v1, "pinfo":Landroid/content/pm/PackageInfo;
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v2

    .line 78
    .local v2, "applicationInfo":Landroid/content/pm/ApplicationInfo;
    iget v3, v2, Landroid/content/pm/ApplicationInfo;->labelRes:I

    .line 79
    .local v3, "stringId":I
    if-nez v3, :cond_0

    iget-object v4, v2, Landroid/content/pm/ApplicationInfo;->nonLocalizedLabel:Ljava/lang/CharSequence;

    invoke-interface {v4}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;

    move-result-object v4

    goto :goto_0

    :cond_0
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-virtual {v4, v3}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v4

    .line 80
    .local v4, "appName":Ljava/lang/String;
    :goto_0
    const-string v5, "name"

    invoke-virtual {v0, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 81
    const-string v5, "id"

    iget-object v6, v1, Landroid/content/pm/PackageInfo;->packageName:Ljava/lang/String;

    invoke-virtual {v0, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 82
    const-string v5, "build"

    invoke-static {v1}, Landroidx/core/content/pm/PackageInfoCompat;->getLongVersionCode(Landroid/content/pm/PackageInfo;)J

    move-result-wide v6

    long-to-int v7, v6

    invoke-static {v7}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v0, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 83
    const-string v5, "version"

    iget-object v6, v1, Landroid/content/pm/PackageInfo;->versionName:Ljava/lang/String;

    invoke-virtual {v0, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 84
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 87
    .end local v1    # "pinfo":Landroid/content/pm/PackageInfo;
    .end local v2    # "applicationInfo":Landroid/content/pm/ApplicationInfo;
    .end local v3    # "stringId":I
    .end local v4    # "appName":Ljava/lang/String;
    goto :goto_1

    .line 85
    :catch_0
    move-exception v1

    .line 86
    .local v1, "ex":Ljava/lang/Exception;
    const-string v2, "Unable to get App Info"

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 88
    .end local v1    # "ex":Ljava/lang/Exception;
    :goto_1
    return-void
.end method

.method public getLaunchUrl(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 92
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->bridge:Lcom/getcapacitor/Bridge;

    invoke-virtual {v0}, Lcom/getcapacitor/Bridge;->getIntentUri()Landroid/net/Uri;

    move-result-object v0

    .line 93
    .local v0, "launchUri":Landroid/net/Uri;
    if-eqz v0, :cond_0

    .line 94
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 95
    .local v1, "d":Lcom/getcapacitor/JSObject;
    const-string v2, "url"

    invoke-virtual {v0}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 96
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 97
    .end local v1    # "d":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 98
    :cond_0
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V

    .line 100
    :goto_0
    return-void
.end method

.method public getState(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 104
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 105
    .local v0, "data":Lcom/getcapacitor/JSObject;
    iget-object v1, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->bridge:Lcom/getcapacitor/Bridge;

    invoke-virtual {v1}, Lcom/getcapacitor/Bridge;->getApp()Lcom/getcapacitor/App;

    move-result-object v1

    invoke-virtual {v1}, Lcom/getcapacitor/App;->isActive()Z

    move-result v1

    const-string v2, "isActive"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 106
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 107
    return-void
.end method

.method protected handleOnDestroy()V
    .locals 0

    .line 152
    invoke-direct {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->unsetAppListeners()V

    .line 153
    return-void
.end method

.method protected handleOnNewIntent(Landroid/content/Intent;)V
    .locals 5
    .param p1, "intent"    # Landroid/content/Intent;

    .line 121
    invoke-super {p0, p1}, Lcom/getcapacitor/Plugin;->handleOnNewIntent(Landroid/content/Intent;)V

    .line 123
    invoke-virtual {p1}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v0

    .line 124
    .local v0, "action":Ljava/lang/String;
    invoke-virtual {p1}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v1

    .line 126
    .local v1, "url":Landroid/net/Uri;
    const-string v2, "android.intent.action.VIEW"

    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    if-nez v1, :cond_0

    goto :goto_0

    .line 130
    :cond_0
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 131
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    const-string v3, "url"

    invoke-virtual {v1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 132
    const-string v3, "appUrlOpen"

    const/4 v4, 0x1

    invoke-virtual {p0, v3, v2, v4}, Lcom/capacitorjs/plugins/app/AppPlugin;->notifyListeners(Ljava/lang/String;Lcom/getcapacitor/JSObject;Z)V

    .line 133
    return-void

    .line 127
    .end local v2    # "ret":Lcom/getcapacitor/JSObject;
    :cond_1
    :goto_0
    return-void
.end method

.method protected handleOnPause()V
    .locals 2

    .line 137
    invoke-super {p0}, Lcom/getcapacitor/Plugin;->handleOnPause()V

    .line 138
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->hasPausedEver:Z

    .line 139
    const-string v0, "pause"

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1}, Lcom/capacitorjs/plugins/app/AppPlugin;->notifyListeners(Ljava/lang/String;Lcom/getcapacitor/JSObject;)V

    .line 140
    return-void
.end method

.method protected handleOnResume()V
    .locals 2

    .line 144
    invoke-super {p0}, Lcom/getcapacitor/Plugin;->handleOnResume()V

    .line 145
    iget-boolean v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->hasPausedEver:Z

    if-eqz v0, :cond_0

    .line 146
    const-string v0, "resume"

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1}, Lcom/capacitorjs/plugins/app/AppPlugin;->notifyListeners(Ljava/lang/String;Lcom/getcapacitor/JSObject;)V

    .line 148
    :cond_0
    return-void
.end method

.method public load()V
    .locals 3

    .line 29
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->bridge:Lcom/getcapacitor/Bridge;

    .line 30
    invoke-virtual {v0}, Lcom/getcapacitor/Bridge;->getApp()Lcom/getcapacitor/App;

    move-result-object v0

    new-instance v1, Lcom/capacitorjs/plugins/app/AppPlugin$$ExternalSyntheticLambda0;

    invoke-direct {v1, p0}, Lcom/capacitorjs/plugins/app/AppPlugin$$ExternalSyntheticLambda0;-><init>(Lcom/capacitorjs/plugins/app/AppPlugin;)V

    .line 31
    invoke-virtual {v0, v1}, Lcom/getcapacitor/App;->setStatusChangeListener(Lcom/getcapacitor/App$AppStatusChangeListener;)V

    .line 39
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin;->bridge:Lcom/getcapacitor/Bridge;

    .line 40
    invoke-virtual {v0}, Lcom/getcapacitor/Bridge;->getApp()Lcom/getcapacitor/App;

    move-result-object v0

    new-instance v1, Lcom/capacitorjs/plugins/app/AppPlugin$$ExternalSyntheticLambda1;

    invoke-direct {v1, p0}, Lcom/capacitorjs/plugins/app/AppPlugin$$ExternalSyntheticLambda1;-><init>(Lcom/capacitorjs/plugins/app/AppPlugin;)V

    .line 41
    invoke-virtual {v0, v1}, Lcom/getcapacitor/App;->setAppRestoredListener(Lcom/getcapacitor/App$AppRestoredListener;)V

    .line 47
    new-instance v0, Lcom/capacitorjs/plugins/app/AppPlugin$1;

    const/4 v1, 0x1

    invoke-direct {v0, p0, v1}, Lcom/capacitorjs/plugins/app/AppPlugin$1;-><init>(Lcom/capacitorjs/plugins/app/AppPlugin;Z)V

    .line 62
    .local v0, "callback":Landroidx/activity/OnBackPressedCallback;
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->getActivity()Landroidx/appcompat/app/AppCompatActivity;

    move-result-object v1

    invoke-virtual {v1}, Landroidx/appcompat/app/AppCompatActivity;->getOnBackPressedDispatcher()Landroidx/activity/OnBackPressedDispatcher;

    move-result-object v1

    invoke-virtual {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->getActivity()Landroidx/appcompat/app/AppCompatActivity;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Landroidx/activity/OnBackPressedDispatcher;->addCallback(Landroidx/lifecycle/LifecycleOwner;Landroidx/activity/OnBackPressedCallback;)V

    .line 63
    return-void
.end method

.method public minimizeApp(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 111
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/app/AppPlugin;->getActivity()Landroidx/appcompat/app/AppCompatActivity;

    move-result-object v0

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroidx/appcompat/app/AppCompatActivity;->moveTaskToBack(Z)Z

    .line 112
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V

    .line 113
    return-void
.end method
