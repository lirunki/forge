.class public Lcom/forge/live/ShortcutBridgePlugin;
.super Lcom/getcapacitor/Plugin;
.source "ShortcutBridgePlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "ShortcutBridge"
.end annotation


# static fields
.field public static final ACTION_OPEN_APP:Ljava/lang/String; = "com.forge.live.OPEN_APP"

.field public static final EXTRA_APP_ID:Ljava/lang/String; = "forge_app_id"

.field public static final EXTRA_APP_TITLE:Ljava/lang/String; = "forge_app_title"


# instance fields
.field private pendingAppId:Ljava/lang/String;

.field private pendingAppTitle:Ljava/lang/String;

.field private pendingLaunchSource:Ljava/lang/String;

.field private pendingNotifyId:Ljava/lang/Integer;

.field private pendingNotifyTag:Ljava/lang/String;

.field private pendingPayload:Ljava/lang/String;


# direct methods
.method public constructor <init>()V
    .locals 1

    .line 29
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    .line 35
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppId:Ljava/lang/String;

    .line 36
    iput-object v0, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppTitle:Ljava/lang/String;

    .line 37
    iput-object v0, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingPayload:Ljava/lang/String;

    .line 38
    iput-object v0, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingNotifyTag:Ljava/lang/String;

    .line 39
    iput-object v0, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingNotifyId:Ljava/lang/Integer;

    .line 40
    iput-object v0, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingLaunchSource:Ljava/lang/String;

    return-void
.end method

.method public static buildRunIntent(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    .locals 3
    .param p0, "context"    # Landroid/content/Context;
    .param p1, "id"    # Ljava/lang/String;
    .param p2, "title"    # Ljava/lang/String;

    .line 44
    if-nez p1, :cond_0

    const-string p1, ""

    .line 45
    :cond_0
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p1

    .line 46
    if-eqz p2, :cond_1

    invoke-virtual {p2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_2

    :cond_1
    const-string p2, "Forge app"

    .line 47
    :cond_2
    invoke-virtual {p2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object p2

    .line 49
    new-instance v0, Landroid/content/Intent;

    const-class v1, Lcom/forge/live/RunActivity;

    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 50
    .local v0, "launch":Landroid/content/Intent;
    const-string v1, "com.forge.live.OPEN_APP"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 53
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "forge://app/"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-static {p1}, Landroid/net/Uri;->encode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 54
    const-string v1, "forge_app_id"

    invoke-virtual {v0, v1, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 55
    const-string v1, "forge_app_title"

    invoke-virtual {v0, v1, p2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 56
    const/high16 v1, 0x18080000

    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 59
    return-object v0
.end method

.method static renderAppIconBitmap(Ljava/lang/String;Ljava/lang/String;)Landroid/graphics/Bitmap;
    .locals 11
    .param p0, "emoji"    # Ljava/lang/String;
    .param p1, "colorHex"    # Ljava/lang/String;

    .line 315
    const/16 v0, 0xc0

    .line 316
    .local v0, "size":I
    sget-object v1, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;

    invoke-static {v0, v0, v1}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;

    move-result-object v1

    .line 317
    .local v1, "bmp":Landroid/graphics/Bitmap;
    new-instance v2, Landroid/graphics/Canvas;

    invoke-direct {v2, v1}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V

    .line 318
    .local v2, "c":Landroid/graphics/Canvas;
    const-string v3, "#6D28D9"

    invoke-static {v3}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I

    move-result v3

    .line 320
    .local v3, "bg":I
    if-eqz p1, :cond_0

    :try_start_0
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    const-string v5, "#"

    invoke-virtual {v4, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_0

    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->length()I

    move-result v4

    const/4 v5, 0x4

    if-lt v4, v5, :cond_0

    .line 321
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-static {v4}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I

    move-result v4
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move v3, v4

    goto :goto_0

    .line 323
    :catch_0
    move-exception v4

    :cond_0
    :goto_0
    nop

    .line 324
    new-instance v4, Landroid/graphics/Paint;

    const/4 v5, 0x1

    invoke-direct {v4, v5}, Landroid/graphics/Paint;-><init>(I)V

    .line 325
    .local v4, "p":Landroid/graphics/Paint;
    invoke-virtual {v4, v3}, Landroid/graphics/Paint;->setColor(I)V

    .line 326
    int-to-float v5, v0

    const/high16 v6, 0x40000000    # 2.0f

    div-float/2addr v5, v6

    int-to-float v7, v0

    div-float/2addr v7, v6

    int-to-float v8, v0

    div-float/2addr v8, v6

    invoke-virtual {v2, v5, v7, v8, v4}, Landroid/graphics/Canvas;->drawCircle(FFFLandroid/graphics/Paint;)V

    .line 327
    if-eqz p0, :cond_1

    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v5

    goto :goto_1

    :cond_1
    const-string v5, ""

    .line 328
    .local v5, "em":Ljava/lang/String;
    :goto_1
    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v7

    if-eqz v7, :cond_2

    const-string v5, "\u26a1"

    .line 330
    :cond_2
    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v7

    const/4 v8, 0x0

    const/16 v9, 0x8

    if-le v7, v9, :cond_3

    invoke-virtual {v5, v8, v9}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v5

    .line 331
    :cond_3
    const/4 v7, -0x1

    invoke-virtual {v4, v7}, Landroid/graphics/Paint;->setColor(I)V

    .line 332
    sget-object v7, Landroid/graphics/Paint$Align;->CENTER:Landroid/graphics/Paint$Align;

    invoke-virtual {v4, v7}, Landroid/graphics/Paint;->setTextAlign(Landroid/graphics/Paint$Align;)V

    .line 333
    sget-object v7, Landroid/graphics/Typeface;->DEFAULT:Landroid/graphics/Typeface;

    invoke-virtual {v4, v7}, Landroid/graphics/Paint;->setTypeface(Landroid/graphics/Typeface;)Landroid/graphics/Typeface;

    .line 334
    int-to-float v7, v0

    const v9, 0x3ef5c28f    # 0.48f

    mul-float v7, v7, v9

    .line 335
    .local v7, "textSize":F
    invoke-virtual {v4, v7}, Landroid/graphics/Paint;->setTextSize(F)V

    .line 336
    new-instance v9, Landroid/graphics/Rect;

    invoke-direct {v9}, Landroid/graphics/Rect;-><init>()V

    .line 337
    .local v9, "bounds":Landroid/graphics/Rect;
    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v10

    invoke-virtual {v4, v5, v8, v10, v9}, Landroid/graphics/Paint;->getTextBounds(Ljava/lang/String;IILandroid/graphics/Rect;)V

    .line 338
    int-to-float v8, v0

    div-float/2addr v8, v6

    .line 339
    .local v8, "x":F
    int-to-float v10, v0

    div-float/2addr v10, v6

    invoke-virtual {v9}, Landroid/graphics/Rect;->exactCenterY()F

    move-result v6

    sub-float/2addr v10, v6

    .line 340
    .local v10, "y":F
    invoke-virtual {v2, v5, v8, v10, v4}, Landroid/graphics/Canvas;->drawText(Ljava/lang/String;FFLandroid/graphics/Paint;)V

    .line 341
    return-object v1
.end method

.method private static sanitizeId(Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    .param p0, "id"    # Ljava/lang/String;

    .line 310
    const-string v0, "[^a-zA-Z0-9._-]"

    const-string v1, "_"

    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method


# virtual methods
.method public captureLaunchIntent(Landroid/content/Intent;)V
    .locals 16
    .param p1, "intent"    # Landroid/content/Intent;

    .line 77
    move-object/from16 v1, p0

    move-object/from16 v2, p1

    const-string v3, "forge_notify_tag"

    const-string v4, "forge_notify_payload"

    const-string v5, "forge_notify_id"

    if-nez v2, :cond_0

    return-void

    .line 78
    :cond_0
    invoke-static/range {p1 .. p1}, Lcom/forge/live/MainActivity;->extractAppId(Landroid/content/Intent;)Ljava/lang/String;

    move-result-object v6

    .line 81
    .local v6, "id":Ljava/lang/String;
    const/4 v7, 0x0

    .line 82
    .local v7, "payload":Ljava/lang/String;
    :try_start_0
    invoke-virtual {v2, v4}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-object v7, v0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 83
    :goto_0
    const/4 v8, 0x0

    .line 84
    .local v8, "notifyTag":Ljava/lang/String;
    :try_start_1
    invoke-virtual {v2, v3}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    move-object v8, v0

    goto :goto_1

    :catch_1
    move-exception v0

    .line 85
    :goto_1
    const/4 v9, 0x0

    .line 87
    .local v9, "notifyId":Ljava/lang/Integer;
    const/4 v10, 0x0

    :try_start_2
    invoke-virtual {v2, v5}, Landroid/content/Intent;->hasExtra(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_1

    .line 88
    invoke-virtual {v2, v5, v10}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I

    move-result v0

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

    move-object v9, v0

    goto :goto_2

    .line 90
    :catch_2
    move-exception v0

    :cond_1
    :goto_2
    nop

    .line 92
    invoke-virtual/range {p1 .. p1}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v11

    .line 93
    .local v11, "action":Ljava/lang/String;
    const-string v0, "com.forge.live.OPEN_FROM_NOTIFY"

    invoke-virtual {v0, v11}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_3

    if-eqz v7, :cond_2

    .line 94
    invoke-virtual {v7}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_2

    goto :goto_3

    :cond_2
    goto :goto_4

    :cond_3
    :goto_3
    const/4 v10, 0x1

    .line 96
    .local v10, "fromNotify":Z
    :goto_4
    if-eqz v6, :cond_4

    invoke-virtual {v6}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_6

    .line 98
    :cond_4
    if-nez v10, :cond_5

    return-void

    .line 99
    :cond_5
    const-string v6, ""

    .line 102
    :cond_6
    iput-object v6, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppId:Ljava/lang/String;

    .line 103
    const-string v0, "forge_app_title"

    invoke-virtual {v2, v0}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v13

    iput-object v13, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppTitle:Ljava/lang/String;

    .line 104
    const-string v14, "title"

    if-eqz v13, :cond_7

    invoke-virtual {v13}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v13

    invoke-virtual {v13}, Ljava/lang/String;->isEmpty()Z

    move-result v13

    if-eqz v13, :cond_8

    :cond_7
    invoke-virtual/range {p1 .. p1}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v13

    if-eqz v13, :cond_8

    .line 105
    invoke-virtual/range {p1 .. p1}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v13

    invoke-virtual {v13, v14}, Landroid/net/Uri;->getQueryParameter(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v13

    .line 106
    .local v13, "q":Ljava/lang/String;
    if-eqz v13, :cond_8

    invoke-virtual {v13}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v15}, Ljava/lang/String;->isEmpty()Z

    move-result v15

    if-nez v15, :cond_8

    invoke-virtual {v13}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v15

    iput-object v15, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppTitle:Ljava/lang/String;

    .line 108
    .end local v13    # "q":Ljava/lang/String;
    :cond_8
    iput-object v7, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingPayload:Ljava/lang/String;

    .line 109
    iput-object v8, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingNotifyTag:Ljava/lang/String;

    .line 110
    iput-object v9, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingNotifyId:Ljava/lang/Integer;

    .line 111
    if-eqz v10, :cond_9

    const-string v13, "notify"

    iput-object v13, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingLaunchSource:Ljava/lang/String;

    goto :goto_5

    .line 112
    :cond_9
    const-string v13, "com.forge.live.OPEN_APP"

    invoke-virtual {v13, v11}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v13

    if-eqz v13, :cond_a

    const-string v13, "shortcut"

    iput-object v13, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingLaunchSource:Ljava/lang/String;

    goto :goto_5

    .line 113
    :cond_a
    const-string v13, "link"

    iput-object v13, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingLaunchSource:Ljava/lang/String;

    .line 115
    :goto_5
    new-instance v13, Lcom/getcapacitor/JSObject;

    invoke-direct {v13}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 116
    .local v13, "data":Lcom/getcapacitor/JSObject;
    const-string v15, "id"

    iget-object v12, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppId:Ljava/lang/String;

    invoke-virtual {v13, v15, v12}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 117
    iget-object v12, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppTitle:Ljava/lang/String;

    if-eqz v12, :cond_b

    invoke-virtual {v13, v14, v12}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 118
    :cond_b
    iget-object v12, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingPayload:Ljava/lang/String;

    if-eqz v12, :cond_c

    const-string v14, "payload"

    invoke-virtual {v13, v14, v12}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 119
    :cond_c
    iget-object v12, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingNotifyTag:Ljava/lang/String;

    if-eqz v12, :cond_d

    const-string v14, "tag"

    invoke-virtual {v13, v14, v12}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 120
    :cond_d
    iget-object v12, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingNotifyId:Ljava/lang/Integer;

    if-eqz v12, :cond_e

    const-string v14, "notifyId"

    invoke-virtual {v13, v14, v12}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 121
    :cond_e
    const-string v12, "source"

    iget-object v14, v1, Lcom/forge/live/ShortcutBridgePlugin;->pendingLaunchSource:Ljava/lang/String;

    invoke-virtual {v13, v12, v14}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 122
    const-string v12, "appLaunch"

    const/4 v14, 0x1

    invoke-virtual {v1, v12, v13, v14}, Lcom/forge/live/ShortcutBridgePlugin;->notifyListeners(Ljava/lang/String;Lcom/getcapacitor/JSObject;Z)V

    .line 126
    :try_start_3
    const-string v12, "forge_app_id"

    invoke-virtual {v2, v12}, Landroid/content/Intent;->removeExtra(Ljava/lang/String;)V

    .line 127
    invoke-virtual {v2, v0}, Landroid/content/Intent;->removeExtra(Ljava/lang/String;)V

    .line 128
    invoke-virtual {v2, v4}, Landroid/content/Intent;->removeExtra(Ljava/lang/String;)V

    .line 129
    invoke-virtual {v2, v3}, Landroid/content/Intent;->removeExtra(Ljava/lang/String;)V

    .line 130
    invoke-virtual {v2, v5}, Landroid/content/Intent;->removeExtra(Ljava/lang/String;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_3

    goto :goto_6

    .line 131
    :catch_3
    move-exception v0

    :goto_6
    nop

    .line 132
    return-void
.end method

.method public getPendingLaunch(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 149
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 150
    .local v0, "o":Lcom/getcapacitor/JSObject;
    iget-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppId:Ljava/lang/String;

    const-string v2, "pending"

    if-nez v1, :cond_1

    iget-object v3, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingPayload:Ljava/lang/String;

    if-eqz v3, :cond_0

    goto :goto_0

    .line 165
    :cond_0
    const/4 v1, 0x0

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    goto :goto_1

    .line 151
    :cond_1
    :goto_0
    if-eqz v1, :cond_2

    const-string v3, "id"

    invoke-virtual {v0, v3, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 152
    :cond_2
    iget-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppTitle:Ljava/lang/String;

    if-eqz v1, :cond_3

    const-string v3, "title"

    invoke-virtual {v0, v3, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 153
    :cond_3
    iget-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingPayload:Ljava/lang/String;

    if-eqz v1, :cond_4

    const-string v3, "payload"

    invoke-virtual {v0, v3, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 154
    :cond_4
    iget-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingNotifyTag:Ljava/lang/String;

    if-eqz v1, :cond_5

    const-string v3, "tag"

    invoke-virtual {v0, v3, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 155
    :cond_5
    iget-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingNotifyId:Ljava/lang/Integer;

    if-eqz v1, :cond_6

    const-string v3, "notifyId"

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    invoke-virtual {v0, v3, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 156
    :cond_6
    iget-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingLaunchSource:Ljava/lang/String;

    if-eqz v1, :cond_7

    const-string v3, "source"

    invoke-virtual {v0, v3, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 157
    :cond_7
    const/4 v1, 0x1

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 158
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppId:Ljava/lang/String;

    .line 159
    iput-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingAppTitle:Ljava/lang/String;

    .line 160
    iput-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingPayload:Ljava/lang/String;

    .line 161
    iput-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingNotifyTag:Ljava/lang/String;

    .line 162
    iput-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingNotifyId:Ljava/lang/Integer;

    .line 163
    iput-object v1, p0, Lcom/forge/live/ShortcutBridgePlugin;->pendingLaunchSource:Ljava/lang/String;

    .line 167
    :goto_1
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 168
    return-void
.end method

.method protected handleOnNewIntent(Landroid/content/Intent;)V
    .locals 0
    .param p1, "intent"    # Landroid/content/Intent;

    .line 64
    invoke-super {p0, p1}, Lcom/getcapacitor/Plugin;->handleOnNewIntent(Landroid/content/Intent;)V

    .line 65
    invoke-virtual {p0, p1}, Lcom/forge/live/ShortcutBridgePlugin;->captureLaunchIntent(Landroid/content/Intent;)V

    .line 66
    return-void
.end method

.method protected handleOnStart()V
    .locals 1

    .line 70
    invoke-super {p0}, Lcom/getcapacitor/Plugin;->handleOnStart()V

    .line 71
    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getActivity()Landroidx/appcompat/app/AppCompatActivity;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 72
    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getActivity()Landroidx/appcompat/app/AppCompatActivity;

    move-result-object v0

    invoke-virtual {v0}, Landroidx/appcompat/app/AppCompatActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/forge/live/ShortcutBridgePlugin;->captureLaunchIntent(Landroid/content/Intent;)V

    .line 74
    :cond_0
    return-void
.end method

.method public isSupported(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 136
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 137
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const/4 v1, 0x1

    .line 138
    .local v1, "supported":Z
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1a

    if-lt v2, v3, :cond_1

    .line 139
    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    const-class v3, Landroid/content/pm/ShortcutManager;

    invoke-virtual {v2, v3}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/content/pm/ShortcutManager;

    .line 140
    .local v2, "sm":Landroid/content/pm/ShortcutManager;
    if-eqz v2, :cond_0

    invoke-virtual {v2}, Landroid/content/pm/ShortcutManager;->isRequestPinShortcutSupported()Z

    move-result v3

    if-eqz v3, :cond_0

    const/4 v3, 0x1

    goto :goto_0

    :cond_0
    const/4 v3, 0x0

    :goto_0
    move v1, v3

    .line 142
    .end local v2    # "sm":Landroid/content/pm/ShortcutManager;
    :cond_1
    const-string v2, "supported"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 143
    const-string v2, "api"

    sget v3, Landroid/os/Build$VERSION;->SDK_INT:I

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 144
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 145
    return-void
.end method

.method public openRunner(Lcom/getcapacitor/PluginCall;)V
    .locals 7
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 176
    const-string v0, "id"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 177
    .local v1, "id":Ljava/lang/String;
    if-eqz v1, :cond_4

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_0

    goto :goto_2

    .line 181
    :cond_0
    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    .line 182
    const-string v2, "title"

    const-string v3, "Forge app"

    invoke-virtual {p1, v2, v3}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 183
    .local v2, "title":Ljava/lang/String;
    if-eqz v2, :cond_1

    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_2

    :cond_1
    const-string v2, "Forge app"

    .line 185
    :cond_2
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v1, v4}, Lcom/forge/live/ShortcutBridgePlugin;->buildRunIntent(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v3

    .line 186
    .local v3, "launch":Landroid/content/Intent;
    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getActivity()Landroidx/appcompat/app/AppCompatActivity;

    move-result-object v4

    if-eqz v4, :cond_3

    .line 187
    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getActivity()Landroidx/appcompat/app/AppCompatActivity;

    move-result-object v4

    invoke-virtual {v4, v3}, Landroidx/appcompat/app/AppCompatActivity;->startActivity(Landroid/content/Intent;)V

    goto :goto_0

    .line 189
    :cond_3
    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-virtual {v4, v3}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 191
    :goto_0
    new-instance v4, Lcom/getcapacitor/JSObject;

    invoke-direct {v4}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 192
    .local v4, "o":Lcom/getcapacitor/JSObject;
    const-string v5, "launched"

    const/4 v6, 0x1

    invoke-virtual {v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 193
    invoke-virtual {v4, v0, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 194
    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 197
    .end local v3    # "launch":Landroid/content/Intent;
    .end local v4    # "o":Lcom/getcapacitor/JSObject;
    goto :goto_1

    .line 195
    :catch_0
    move-exception v0

    .line 196
    .local v0, "e":Ljava/lang/Exception;
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "openRunner failed: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p1, v3, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 198
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1
    return-void

    .line 178
    .end local v2    # "title":Ljava/lang/String;
    :cond_4
    :goto_2
    const-string v0, "id required"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 179
    return-void
.end method

.method public pinApp(Lcom/getcapacitor/PluginCall;)V
    .locals 18
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 202
    move-object/from16 v1, p1

    const-string v2, "id"

    invoke-virtual {v1, v2}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 203
    .local v0, "id":Ljava/lang/String;
    if-eqz v0, :cond_d

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_0

    goto/16 :goto_6

    .line 207
    :cond_0
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v3

    .line 208
    .end local v0    # "id":Ljava/lang/String;
    .local v3, "id":Ljava/lang/String;
    const-string v0, "title"

    const-string v4, "Forge app"

    invoke-virtual {v1, v0, v4}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 209
    .local v0, "title":Ljava/lang/String;
    if-eqz v0, :cond_1

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-eqz v4, :cond_2

    :cond_1
    const-string v0, "Forge app"

    .line 210
    :cond_2
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    .line 211
    .end local v0    # "title":Ljava/lang/String;
    .local v4, "title":Ljava/lang/String;
    const-string v0, "shortLabel"

    invoke-virtual {v1, v0, v4}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 212
    .local v0, "shortLabel":Ljava/lang/String;
    if-eqz v0, :cond_3

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v5

    if-eqz v5, :cond_4

    :cond_3
    move-object v0, v4

    .line 213
    :cond_4
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    .line 214
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v5

    const/16 v6, 0x14

    const/4 v7, 0x0

    if-le v5, v6, :cond_5

    invoke-virtual {v0, v7, v6}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    :cond_5
    move-object v5, v0

    .line 215
    .end local v0    # "shortLabel":Ljava/lang/String;
    .local v5, "shortLabel":Ljava/lang/String;
    const-string v0, "longLabel"

    invoke-virtual {v1, v0, v4}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 216
    .local v0, "longLabel":Ljava/lang/String;
    if-eqz v0, :cond_6

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/String;->isEmpty()Z

    move-result v6

    if-eqz v6, :cond_7

    :cond_6
    move-object v0, v4

    :cond_7
    move-object v6, v0

    .line 218
    .end local v0    # "longLabel":Ljava/lang/String;
    .local v6, "longLabel":Ljava/lang/String;
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0, v3, v4}, Lcom/forge/live/ShortcutBridgePlugin;->buildRunIntent(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v8

    .line 219
    .local v8, "launch":Landroid/content/Intent;
    const-string v0, "emoji"

    const/4 v9, 0x0

    invoke-virtual {v1, v0, v9}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v10, "iconEmoji"

    invoke-virtual {v1, v10, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v10

    .line 220
    .local v10, "iconEmoji":Ljava/lang/String;
    const-string v0, "color"

    invoke-virtual {v1, v0, v9}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v11, "iconColor"

    invoke-virtual {v1, v11, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    .line 223
    .local v11, "iconColor":Ljava/lang/String;
    :try_start_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_3

    const/16 v12, 0x1a

    const-string v13, "runner"

    const-string v14, "mode"

    const-string v15, "requested"

    if-lt v0, v12, :cond_c

    .line 224
    :try_start_1
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    const-class v12, Landroid/content/pm/ShortcutManager;

    invoke-virtual {v0, v12}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/pm/ShortcutManager;

    move-object v12, v0

    .line 225
    .local v12, "sm":Landroid/content/pm/ShortcutManager;
    if-eqz v12, :cond_b

    invoke-virtual {v12}, Landroid/content/pm/ShortcutManager;->isRequestPinShortcutSupported()Z

    move-result v0

    if-nez v0, :cond_8

    move-object/from16 v16, v4

    move-object/from16 v17, v10

    goto/16 :goto_2

    .line 229
    :cond_8
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v9, "forge_app_"

    invoke-virtual {v0, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-static {v3}, Lcom/forge/live/ShortcutBridgePlugin;->sanitizeId(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v0, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    move-object v9, v0

    .line 230
    .local v9, "shortcutId":Ljava/lang/String;
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    sget v7, Lcom/forge/live/R$mipmap;->ic_launcher:I

    invoke-static {v0, v7}, Landroid/graphics/drawable/Icon;->createWithResource(Landroid/content/Context;I)Landroid/graphics/drawable/Icon;

    move-result-object v0
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_3

    move-object v7, v0

    .line 232
    .local v7, "icon":Landroid/graphics/drawable/Icon;
    :try_start_2
    invoke-static {v10, v11}, Lcom/forge/live/ShortcutBridgePlugin;->renderAppIconBitmap(Ljava/lang/String;Ljava/lang/String;)Landroid/graphics/Bitmap;

    move-result-object v0

    .line 233
    .local v0, "bmp":Landroid/graphics/Bitmap;
    if-eqz v0, :cond_9

    invoke-static {v0}, Landroid/graphics/drawable/Icon;->createWithBitmap(Landroid/graphics/Bitmap;)Landroid/graphics/drawable/Icon;

    move-result-object v16
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    move-object/from16 v7, v16

    goto :goto_0

    .line 234
    .end local v0    # "bmp":Landroid/graphics/Bitmap;
    :catch_0
    move-exception v0

    :cond_9
    :goto_0
    nop

    .line 235
    :try_start_3
    new-instance v0, Landroid/content/pm/ShortcutInfo$Builder;
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_3

    move-object/from16 v16, v4

    .end local v4    # "title":Ljava/lang/String;
    .local v16, "title":Ljava/lang/String;
    :try_start_4
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-direct {v0, v4, v9}, Landroid/content/pm/ShortcutInfo$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 236
    invoke-virtual {v0, v5}, Landroid/content/pm/ShortcutInfo$Builder;->setShortLabel(Ljava/lang/CharSequence;)Landroid/content/pm/ShortcutInfo$Builder;

    move-result-object v0

    .line 237
    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result v4
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_1

    move-object/from16 v17, v10

    .end local v10    # "iconEmoji":Ljava/lang/String;
    .local v17, "iconEmoji":Ljava/lang/String;
    const/16 v10, 0x32

    if-le v4, v10, :cond_a

    const/4 v4, 0x0

    :try_start_5
    invoke-virtual {v6, v4, v10}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v4

    goto :goto_1

    :cond_a
    move-object v4, v6

    :goto_1
    invoke-virtual {v0, v4}, Landroid/content/pm/ShortcutInfo$Builder;->setLongLabel(Ljava/lang/CharSequence;)Landroid/content/pm/ShortcutInfo$Builder;

    move-result-object v0

    .line 238
    invoke-virtual {v0, v7}, Landroid/content/pm/ShortcutInfo$Builder;->setIcon(Landroid/graphics/drawable/Icon;)Landroid/content/pm/ShortcutInfo$Builder;

    move-result-object v0

    .line 239
    invoke-virtual {v0, v8}, Landroid/content/pm/ShortcutInfo$Builder;->setIntent(Landroid/content/Intent;)Landroid/content/pm/ShortcutInfo$Builder;

    move-result-object v0

    .line 241
    .local v0, "builder":Landroid/content/pm/ShortcutInfo$Builder;
    invoke-virtual {v0}, Landroid/content/pm/ShortcutInfo$Builder;->build()Landroid/content/pm/ShortcutInfo;

    move-result-object v4

    const/4 v10, 0x0

    invoke-virtual {v12, v4, v10}, Landroid/content/pm/ShortcutManager;->requestPinShortcut(Landroid/content/pm/ShortcutInfo;Landroid/content/IntentSender;)Z

    move-result v4

    .line 242
    .local v4, "ok":Z
    new-instance v10, Lcom/getcapacitor/JSObject;

    invoke-direct {v10}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 243
    .local v10, "o":Lcom/getcapacitor/JSObject;
    invoke-virtual {v10, v15, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 244
    invoke-virtual {v10, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 245
    const-string v2, "shortcutId"

    invoke-virtual {v10, v2, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 246
    const-string v2, "pin"

    invoke-virtual {v10, v14, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 247
    const/4 v2, 0x1

    invoke-virtual {v10, v13, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 248
    invoke-virtual {v1, v10}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 249
    .end local v0    # "builder":Landroid/content/pm/ShortcutInfo$Builder;
    .end local v4    # "ok":Z
    .end local v7    # "icon":Landroid/graphics/drawable/Icon;
    .end local v9    # "shortcutId":Ljava/lang/String;
    .end local v10    # "o":Lcom/getcapacitor/JSObject;
    .end local v12    # "sm":Landroid/content/pm/ShortcutManager;
    goto :goto_3

    .line 265
    .end local v17    # "iconEmoji":Ljava/lang/String;
    .local v10, "iconEmoji":Ljava/lang/String;
    :catch_1
    move-exception v0

    move-object/from16 v17, v10

    .end local v10    # "iconEmoji":Ljava/lang/String;
    .restart local v17    # "iconEmoji":Ljava/lang/String;
    goto :goto_4

    .line 225
    .end local v16    # "title":Ljava/lang/String;
    .end local v17    # "iconEmoji":Ljava/lang/String;
    .local v4, "title":Ljava/lang/String;
    .restart local v10    # "iconEmoji":Ljava/lang/String;
    .restart local v12    # "sm":Landroid/content/pm/ShortcutManager;
    :cond_b
    move-object/from16 v16, v4

    move-object/from16 v17, v10

    .line 226
    .end local v4    # "title":Ljava/lang/String;
    .end local v10    # "iconEmoji":Ljava/lang/String;
    .restart local v16    # "title":Ljava/lang/String;
    .restart local v17    # "iconEmoji":Ljava/lang/String;
    :goto_2
    const-string v0, "Launcher does not support pinned shortcuts"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 227
    return-void

    .line 251
    .end local v12    # "sm":Landroid/content/pm/ShortcutManager;
    .end local v16    # "title":Ljava/lang/String;
    .end local v17    # "iconEmoji":Ljava/lang/String;
    .restart local v4    # "title":Ljava/lang/String;
    .restart local v10    # "iconEmoji":Ljava/lang/String;
    :cond_c
    move-object/from16 v16, v4

    move-object/from16 v17, v10

    .end local v4    # "title":Ljava/lang/String;
    .end local v10    # "iconEmoji":Ljava/lang/String;
    .restart local v16    # "title":Ljava/lang/String;
    .restart local v17    # "iconEmoji":Ljava/lang/String;
    new-instance v0, Landroid/content/Intent;

    const-string v4, "com.android.launcher.action.INSTALL_SHORTCUT"

    invoke-direct {v0, v4}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 252
    .local v0, "add":Landroid/content/Intent;
    const-string v4, "android.intent.extra.shortcut.INTENT"

    invoke-virtual {v0, v4, v8}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;

    .line 253
    const-string v4, "android.intent.extra.shortcut.NAME"

    invoke-virtual {v0, v4, v5}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 254
    const-string v4, "android.intent.extra.shortcut.ICON_RESOURCE"

    .line 255
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v7

    sget v9, Lcom/forge/live/R$mipmap;->ic_launcher:I

    invoke-static {v7, v9}, Landroid/content/Intent$ShortcutIconResource;->fromContext(Landroid/content/Context;I)Landroid/content/Intent$ShortcutIconResource;

    move-result-object v7

    .line 254
    invoke-virtual {v0, v4, v7}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;

    .line 256
    const-string v4, "duplicate"

    const/4 v7, 0x0

    invoke-virtual {v0, v4, v7}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 257
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-virtual {v4, v0}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    .line 258
    new-instance v4, Lcom/getcapacitor/JSObject;

    invoke-direct {v4}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 259
    .local v4, "o":Lcom/getcapacitor/JSObject;
    const/4 v7, 0x1

    invoke-virtual {v4, v15, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 260
    invoke-virtual {v4, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 261
    const-string v2, "legacy"

    invoke-virtual {v4, v14, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 262
    const/4 v2, 0x1

    invoke-virtual {v4, v13, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 263
    invoke-virtual {v1, v4}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_2

    .line 267
    .end local v0    # "add":Landroid/content/Intent;
    .end local v4    # "o":Lcom/getcapacitor/JSObject;
    :goto_3
    goto :goto_5

    .line 265
    :catch_2
    move-exception v0

    goto :goto_4

    .end local v16    # "title":Ljava/lang/String;
    .end local v17    # "iconEmoji":Ljava/lang/String;
    .local v4, "title":Ljava/lang/String;
    .restart local v10    # "iconEmoji":Ljava/lang/String;
    :catch_3
    move-exception v0

    move-object/from16 v16, v4

    move-object/from16 v17, v10

    .line 266
    .end local v4    # "title":Ljava/lang/String;
    .end local v10    # "iconEmoji":Ljava/lang/String;
    .local v0, "e":Ljava/lang/Exception;
    .restart local v16    # "title":Ljava/lang/String;
    .restart local v17    # "iconEmoji":Ljava/lang/String;
    :goto_4
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "pin failed: "

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 268
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_5
    return-void

    .line 204
    .end local v3    # "id":Ljava/lang/String;
    .end local v5    # "shortLabel":Ljava/lang/String;
    .end local v6    # "longLabel":Ljava/lang/String;
    .end local v8    # "launch":Landroid/content/Intent;
    .end local v11    # "iconColor":Ljava/lang/String;
    .end local v16    # "title":Ljava/lang/String;
    .end local v17    # "iconEmoji":Ljava/lang/String;
    .local v0, "id":Ljava/lang/String;
    :cond_d
    :goto_6
    const-string v2, "id required"

    invoke-virtual {v1, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 205
    return-void
.end method

.method public updatePinned(Lcom/getcapacitor/PluginCall;)V
    .locals 11
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 273
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x19

    const-string v2, "updated"

    const/4 v3, 0x0

    if-ge v0, v1, :cond_0

    .line 274
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 275
    return-void

    .line 277
    :cond_0
    const-string v0, "id"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 278
    .local v0, "id":Ljava/lang/String;
    if-eqz v0, :cond_7

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_1

    goto/16 :goto_3

    .line 282
    :cond_1
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    .line 283
    const-string v1, "title"

    const-string v4, "Forge app"

    invoke-virtual {p1, v1, v4}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 284
    .local v1, "title":Ljava/lang/String;
    if-eqz v1, :cond_2

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-eqz v4, :cond_3

    :cond_2
    const-string v1, "Forge app"

    .line 287
    :cond_3
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v4

    const-class v5, Landroid/content/pm/ShortcutManager;

    invoke-virtual {v4, v5}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Landroid/content/pm/ShortcutManager;

    .line 288
    .local v4, "sm":Landroid/content/pm/ShortcutManager;
    if-nez v4, :cond_4

    .line 289
    new-instance v5, Lcom/getcapacitor/JSObject;

    invoke-direct {v5}, Lcom/getcapacitor/JSObject;-><init>()V

    invoke-virtual {v5, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    move-result-object v2

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 290
    return-void

    .line 292
    :cond_4
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "forge_app_"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-static {v0}, Lcom/forge/live/ShortcutBridgePlugin;->sanitizeId(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    .line 293
    .local v5, "shortcutId":Ljava/lang/String;
    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v6

    invoke-static {v6, v0, v1}, Lcom/forge/live/ShortcutBridgePlugin;->buildRunIntent(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v6

    .line 295
    .local v6, "launch":Landroid/content/Intent;
    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v7

    const/16 v8, 0x14

    if-le v7, v8, :cond_5

    invoke-virtual {v1, v3, v8}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v7

    goto :goto_0

    :cond_5
    move-object v7, v1

    .line 296
    .local v7, "shortLabel":Ljava/lang/String;
    :goto_0
    new-instance v8, Landroid/content/pm/ShortcutInfo$Builder;

    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v9

    invoke-direct {v8, v9, v5}, Landroid/content/pm/ShortcutInfo$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 297
    invoke-virtual {v8, v7}, Landroid/content/pm/ShortcutInfo$Builder;->setShortLabel(Ljava/lang/CharSequence;)Landroid/content/pm/ShortcutInfo$Builder;

    move-result-object v8

    .line 298
    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v9

    const/16 v10, 0x32

    if-le v9, v10, :cond_6

    invoke-virtual {v1, v3, v10}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v3

    goto :goto_1

    :cond_6
    move-object v3, v1

    :goto_1
    invoke-virtual {v8, v3}, Landroid/content/pm/ShortcutInfo$Builder;->setLongLabel(Ljava/lang/CharSequence;)Landroid/content/pm/ShortcutInfo$Builder;

    move-result-object v3

    .line 299
    invoke-virtual {p0}, Lcom/forge/live/ShortcutBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v8

    sget v9, Lcom/forge/live/R$mipmap;->ic_launcher:I

    invoke-static {v8, v9}, Landroid/graphics/drawable/Icon;->createWithResource(Landroid/content/Context;I)Landroid/graphics/drawable/Icon;

    move-result-object v8

    invoke-virtual {v3, v8}, Landroid/content/pm/ShortcutInfo$Builder;->setIcon(Landroid/graphics/drawable/Icon;)Landroid/content/pm/ShortcutInfo$Builder;

    move-result-object v3

    .line 300
    invoke-virtual {v3, v6}, Landroid/content/pm/ShortcutInfo$Builder;->setIntent(Landroid/content/Intent;)Landroid/content/pm/ShortcutInfo$Builder;

    move-result-object v3

    .line 301
    invoke-virtual {v3}, Landroid/content/pm/ShortcutInfo$Builder;->build()Landroid/content/pm/ShortcutInfo;

    move-result-object v3

    .line 302
    .local v3, "info":Landroid/content/pm/ShortcutInfo;
    invoke-static {v3}, Ljava/util/Collections;->singletonList(Ljava/lang/Object;)Ljava/util/List;

    move-result-object v8

    invoke-virtual {v4, v8}, Landroid/content/pm/ShortcutManager;->updateShortcuts(Ljava/util/List;)Z

    .line 303
    new-instance v8, Lcom/getcapacitor/JSObject;

    invoke-direct {v8}, Lcom/getcapacitor/JSObject;-><init>()V

    const/4 v9, 0x1

    invoke-virtual {v8, v2, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    move-result-object v2

    const-string v8, "shortcutId"

    invoke-virtual {v2, v8, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v2

    const-string v8, "runner"

    invoke-virtual {v2, v8, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    move-result-object v2

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 306
    .end local v3    # "info":Landroid/content/pm/ShortcutInfo;
    .end local v4    # "sm":Landroid/content/pm/ShortcutManager;
    .end local v5    # "shortcutId":Ljava/lang/String;
    .end local v6    # "launch":Landroid/content/Intent;
    .end local v7    # "shortLabel":Ljava/lang/String;
    goto :goto_2

    .line 304
    :catch_0
    move-exception v2

    .line 305
    .local v2, "e":Ljava/lang/Exception;
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "update failed: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v2}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 307
    .end local v2    # "e":Ljava/lang/Exception;
    :goto_2
    return-void

    .line 279
    .end local v1    # "title":Ljava/lang/String;
    :cond_7
    :goto_3
    const-string v1, "id required"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 280
    return-void
.end method
