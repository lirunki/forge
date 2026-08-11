.class public Lcom/forge/live/RunActivity;
.super Lcom/forge/live/MainActivity;
.source "RunActivity.java"


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 13
    invoke-direct {p0}, Lcom/forge/live/MainActivity;-><init>()V

    return-void
.end method

.method private applyTaskLabel(Landroid/content/Intent;)V
    .locals 4
    .param p1, "intent"    # Landroid/content/Intent;

    .line 33
    if-nez p1, :cond_0

    return-void

    .line 34
    :cond_0
    const-string v0, "forge_app_title"

    invoke-virtual {p1, v0}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 35
    .local v0, "title":Ljava/lang/String;
    if-eqz v0, :cond_1

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_2

    .line 36
    :cond_1
    invoke-virtual {p1}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v1

    if-eqz v1, :cond_2

    .line 37
    invoke-virtual {p1}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v1

    const-string v2, "title"

    invoke-virtual {v1, v2}, Landroid/net/Uri;->getQueryParameter(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 38
    .local v1, "q":Ljava/lang/String;
    if-eqz v1, :cond_2

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-nez v2, :cond_2

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    .line 41
    .end local v1    # "q":Ljava/lang/String;
    :cond_2
    if-eqz v0, :cond_3

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_4

    :cond_3
    const-string v0, "Forge app"

    .line 42
    :cond_4
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    .line 44
    nop

    .line 46
    :try_start_0
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x1c

    if-lt v1, v2, :cond_5

    .line 47
    new-instance v1, Landroid/app/ActivityManager$TaskDescription;

    sget v2, Lcom/forge/live/R$mipmap;->ic_launcher:I

    invoke-direct {v1, v0, v2}, Landroid/app/ActivityManager$TaskDescription;-><init>(Ljava/lang/String;I)V

    .local v1, "desc":Landroid/app/ActivityManager$TaskDescription;
    goto :goto_0

    .line 49
    .end local v1    # "desc":Landroid/app/ActivityManager$TaskDescription;
    :cond_5
    new-instance v1, Landroid/app/ActivityManager$TaskDescription;

    .line 51
    invoke-virtual {p0}, Lcom/forge/live/RunActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    sget v3, Lcom/forge/live/R$mipmap;->ic_launcher:I

    invoke-static {v2, v3}, Landroid/graphics/BitmapFactory;->decodeResource(Landroid/content/res/Resources;I)Landroid/graphics/Bitmap;

    move-result-object v2

    invoke-direct {v1, v0, v2}, Landroid/app/ActivityManager$TaskDescription;-><init>(Ljava/lang/String;Landroid/graphics/Bitmap;)V

    .line 54
    .restart local v1    # "desc":Landroid/app/ActivityManager$TaskDescription;
    :goto_0
    invoke-virtual {p0, v1}, Lcom/forge/live/RunActivity;->setTaskDescription(Landroid/app/ActivityManager$TaskDescription;)V

    .line 56
    .end local v1    # "desc":Landroid/app/ActivityManager$TaskDescription;
    invoke-virtual {p0, v0}, Lcom/forge/live/RunActivity;->setTitle(Ljava/lang/CharSequence;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    .line 57
    :catch_0
    move-exception v1

    :goto_1
    nop

    .line 58
    return-void
.end method


# virtual methods
.method protected isRunnerInstance()Z
    .locals 1

    .line 17
    const/4 v0, 0x1

    return v0
.end method

.method public onCreate(Landroid/os/Bundle;)V
    .locals 1
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    .line 22
    invoke-super {p0, p1}, Lcom/forge/live/MainActivity;->onCreate(Landroid/os/Bundle;)V

    .line 23
    invoke-virtual {p0}, Lcom/forge/live/RunActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    invoke-direct {p0, v0}, Lcom/forge/live/RunActivity;->applyTaskLabel(Landroid/content/Intent;)V

    .line 24
    return-void
.end method

.method protected onNewIntent(Landroid/content/Intent;)V
    .locals 0
    .param p1, "intent"    # Landroid/content/Intent;

    .line 28
    invoke-super {p0, p1}, Lcom/forge/live/MainActivity;->onNewIntent(Landroid/content/Intent;)V

    .line 29
    invoke-direct {p0, p1}, Lcom/forge/live/RunActivity;->applyTaskLabel(Landroid/content/Intent;)V

    .line 30
    return-void
.end method
