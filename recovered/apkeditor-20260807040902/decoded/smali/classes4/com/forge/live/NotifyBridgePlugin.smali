.class public Lcom/forge/live/NotifyBridgePlugin;
.super Lcom/getcapacitor/Plugin;
.source "NotifyBridgePlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "NotifyBridge"
    permissions = {
        .subannotation Lcom/getcapacitor/annotation/Permission;
            alias = "notifications"
            strings = {
                "android.permission.POST_NOTIFICATIONS"
            }
        .end subannotation
    }
.end annotation


# static fields
.field public static final ACTION_OPEN_FROM_NOTIFY:Ljava/lang/String; = "com.forge.live.OPEN_FROM_NOTIFY"

.field private static final BASE_NOTIFY_ID:I = 0xcb20

.field public static final CHANNEL_ALERTS:Ljava/lang/String; = "forge_alerts"

.field public static final CHANNEL_DEFAULT:Ljava/lang/String; = "forge_default"

.field public static final CHANNEL_JOBS:Ljava/lang/String; = "forge_jobs"

.field public static final EXTRA_NOTIFY_ID:Ljava/lang/String; = "forge_notify_id"

.field public static final EXTRA_PAYLOAD:Ljava/lang/String; = "forge_notify_payload"

.field public static final EXTRA_TAG:Ljava/lang/String; = "forge_notify_tag"


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 40
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    return-void
.end method

.method private defaultChannelList()Lcom/getcapacitor/JSArray;
    .locals 6

    .line 350
    const-string v0, "importance"

    const-string v1, "name"

    const-string v2, "id"

    new-instance v3, Lcom/getcapacitor/JSArray;

    invoke-direct {v3}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 352
    .local v3, "arr":Lcom/getcapacitor/JSArray;
    :try_start_0
    new-instance v4, Lcom/getcapacitor/JSObject;

    invoke-direct {v4}, Lcom/getcapacitor/JSObject;-><init>()V

    const-string v5, "forge_default"

    invoke-virtual {v4, v2, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v4

    const-string v5, "Forge"

    invoke-virtual {v4, v1, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v4

    const-string v5, "low"

    invoke-virtual {v4, v0, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v4

    invoke-virtual {v3, v4}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 353
    new-instance v4, Lcom/getcapacitor/JSObject;

    invoke-direct {v4}, Lcom/getcapacitor/JSObject;-><init>()V

    const-string v5, "forge_alerts"

    invoke-virtual {v4, v2, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v4

    const-string v5, "Forge alerts"

    invoke-virtual {v4, v1, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v4

    const-string v5, "high"

    invoke-virtual {v4, v0, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v4

    invoke-virtual {v3, v4}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 354
    new-instance v4, Lcom/getcapacitor/JSObject;

    invoke-direct {v4}, Lcom/getcapacitor/JSObject;-><init>()V

    const-string v5, "forge_jobs"

    invoke-virtual {v4, v2, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v2

    const-string v4, "Forge reminders"

    invoke-virtual {v2, v1, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v1

    const-string v2, "default"

    invoke-virtual {v1, v0, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {v3, v0}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 355
    :catch_0
    move-exception v0

    :goto_0
    nop

    .line 356
    return-object v3
.end method

.method public static ensureChannels(Landroid/content/Context;)V
    .locals 7
    .param p0, "ctx"    # Landroid/content/Context;

    .line 325
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1a

    if-ge v0, v1, :cond_0

    return-void

    .line 326
    :cond_0
    const-string v0, "notification"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/NotificationManager;

    .line 327
    .local v0, "nm":Landroid/app/NotificationManager;
    if-nez v0, :cond_1

    return-void

    .line 329
    :cond_1
    new-instance v1, Landroid/app/NotificationChannel;

    const-string v2, "Forge"

    const/4 v3, 0x2

    const-string v4, "forge_default"

    invoke-direct {v1, v4, v2, v3}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V

    .line 331
    .local v1, "def":Landroid/app/NotificationChannel;
    const-string v2, "General mini-app notifications"

    invoke-virtual {v1, v2}, Landroid/app/NotificationChannel;->setDescription(Ljava/lang/String;)V

    .line 332
    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Landroid/app/NotificationChannel;->setShowBadge(Z)V

    .line 333
    invoke-virtual {v0, v1}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V

    .line 335
    new-instance v3, Landroid/app/NotificationChannel;

    const-string v4, "Forge alerts"

    const/4 v5, 0x4

    const-string v6, "forge_alerts"

    invoke-direct {v3, v6, v4, v5}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V

    .line 337
    .local v3, "alerts":Landroid/app/NotificationChannel;
    const-string v4, "Important alerts from mini-apps"

    invoke-virtual {v3, v4}, Landroid/app/NotificationChannel;->setDescription(Ljava/lang/String;)V

    .line 338
    invoke-virtual {v3, v2}, Landroid/app/NotificationChannel;->enableVibration(Z)V

    .line 339
    invoke-virtual {v0, v3}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V

    .line 341
    new-instance v2, Landroid/app/NotificationChannel;

    const-string v4, "Forge reminders"

    const/4 v5, 0x3

    const-string v6, "forge_jobs"

    invoke-direct {v2, v6, v4, v5}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V

    .line 343
    .local v2, "jobs":Landroid/app/NotificationChannel;
    const-string v4, "Scheduled jobs and reminders"

    invoke-virtual {v2, v4}, Landroid/app/NotificationChannel;->setDescription(Ljava/lang/String;)V

    .line 344
    invoke-virtual {v0, v2}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V

    .line 347
    return-void
.end method

.method private hasNotificationPermission()Z
    .locals 3

    .line 360
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    const/4 v2, 0x1

    if-ge v0, v1, :cond_0

    return v2

    .line 361
    :cond_0
    nop

    .line 362
    invoke-virtual {p0}, Lcom/forge/live/NotifyBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    .line 361
    const-string v1, "android.permission.POST_NOTIFICATIONS"

    invoke-static {v0, v1}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result v0

    if-nez v0, :cond_1

    goto :goto_0

    :cond_1
    const/4 v2, 0x0

    :goto_0
    return v2
.end method

.method private notifyPermCallback(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/annotation/PermissionCallback;
    .end annotation

    .line 90
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 91
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    invoke-direct {p0}, Lcom/forge/live/NotifyBridgePlugin;->hasNotificationPermission()Z

    move-result v1

    .line 92
    .local v1, "g":Z
    const-string v2, "granted"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 93
    const-string v2, "permission"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 94
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 95
    return-void
.end method

.method private showAfterPerm(Lcom/getcapacitor/PluginCall;)V
    .locals 0
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/annotation/PermissionCallback;
    .end annotation

    .line 129
    invoke-direct {p0, p1}, Lcom/forge/live/NotifyBridgePlugin;->showInternal(Lcom/getcapacitor/PluginCall;)V

    .line 130
    return-void
.end method

.method private showInternal(Lcom/getcapacitor/PluginCall;)V
    .locals 26
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 133
    move-object/from16 v1, p1

    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/NotifyBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    .line 134
    .local v2, "ctx":Landroid/content/Context;
    const-string v0, "title"

    const-string v3, "Forge"

    invoke-virtual {v1, v0, v3}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    .line 135
    .local v4, "title":Ljava/lang/String;
    const-string v0, "body"

    const-string v5, ""

    invoke-virtual {v1, v0, v5}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v6, "message"

    invoke-virtual {v1, v6, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    .line 136
    .local v6, "message":Ljava/lang/String;
    const-string v7, "channel"

    const-string v8, "forge_default"

    invoke-virtual {v1, v7, v8}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 137
    .local v0, "channelId":Ljava/lang/String;
    if-eqz v0, :cond_0

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v9

    if-eqz v9, :cond_1

    :cond_0
    const-string v0, "forge_default"

    .line 139
    :cond_1
    const-string v9, "alerts"

    invoke-virtual {v9, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-nez v9, :cond_7

    const-string v9, "high"

    invoke-virtual {v9, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_2

    goto :goto_2

    .line 141
    :cond_2
    const-string v9, "jobs"

    invoke-virtual {v9, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-nez v9, :cond_6

    const-string v9, "reminder"

    invoke-virtual {v9, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_3

    goto :goto_1

    .line 143
    :cond_3
    const-string v9, "default"

    invoke-virtual {v9, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-nez v9, :cond_5

    const-string v9, "low"

    invoke-virtual {v9, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_4

    goto :goto_0

    :cond_4
    move-object v9, v0

    goto :goto_3

    .line 144
    :cond_5
    :goto_0
    const-string v0, "forge_default"

    move-object v9, v0

    goto :goto_3

    .line 142
    :cond_6
    :goto_1
    const-string v0, "forge_jobs"

    move-object v9, v0

    goto :goto_3

    .line 140
    :cond_7
    :goto_2
    const-string v0, "forge_alerts"

    move-object v9, v0

    .line 147
    .end local v0    # "channelId":Ljava/lang/String;
    .local v9, "channelId":Ljava/lang/String;
    :goto_3
    const-string v0, "appId"

    invoke-virtual {v1, v0, v5}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v10

    .line 148
    .local v10, "appId":Ljava/lang/String;
    const-string v0, "appTitle"

    invoke-virtual {v1, v0, v4}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    .line 149
    .local v11, "appTitle":Ljava/lang/String;
    const-string v12, "tag"

    const/4 v13, 0x0

    invoke-virtual {v1, v12, v13}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v14

    .line 150
    .local v14, "tag":Ljava/lang/String;
    const-string v0, "payload"

    invoke-virtual {v1, v0, v13}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v15

    .line 151
    .local v15, "payload":Ljava/lang/String;
    if-nez v15, :cond_a

    invoke-virtual/range {p1 .. p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v0

    if-eqz v0, :cond_a

    invoke-virtual/range {p1 .. p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v0

    const-string v13, "data"

    invoke-virtual {v0, v13}, Lcom/getcapacitor/JSObject;->has(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_a

    .line 153
    :try_start_0
    invoke-virtual/range {p1 .. p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {v0, v13}, Lcom/getcapacitor/JSObject;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    .line 154
    .local v0, "data":Ljava/lang/Object;
    instance-of v13, v0, Lorg/json/JSONObject;

    if-eqz v13, :cond_8

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v13

    move-object v15, v13

    goto :goto_4

    .line 155
    :cond_8
    if-eqz v0, :cond_9

    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v13
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-object v15, v13

    .line 156
    .end local v0    # "data":Ljava/lang/Object;
    :cond_9
    :goto_4
    goto :goto_5

    :catch_0
    move-exception v0

    goto :goto_4

    .line 159
    :cond_a
    :goto_5
    const/4 v0, 0x0

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v13

    const-string v0, "id"

    invoke-virtual {v1, v0, v13}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v13

    invoke-virtual {v13}, Ljava/lang/Integer;->intValue()I

    move-result v13

    .line 160
    .local v13, "id":I
    if-nez v13, :cond_c

    .line 161
    move-object/from16 v18, v3

    if-eqz v14, :cond_b

    move-object v3, v14

    goto :goto_6

    :cond_b
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v3, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    :goto_6
    invoke-virtual {v3}, Ljava/lang/String;->hashCode()I

    move-result v3

    const v19, 0x186a0

    rem-int v3, v3, v19

    invoke-static {v3}, Ljava/lang/Math;->abs(I)I

    move-result v3

    const v19, 0xcb20

    add-int v13, v3, v19

    goto :goto_7

    .line 160
    :cond_c
    move-object/from16 v18, v3

    .line 164
    :goto_7
    sget-object v3, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    move-object/from16 v19, v5

    const-string v5, "ongoing"

    move-object/from16 v20, v7

    const/16 v17, 0x0

    invoke-static/range {v17 .. v17}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v7

    invoke-virtual {v1, v5, v7}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v3

    .line 165
    .local v3, "ongoing":Z
    sget-object v5, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v7, "silent"

    move-object/from16 v21, v12

    invoke-static/range {v17 .. v17}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v12

    invoke-virtual {v1, v7, v12}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v7

    invoke-virtual {v5, v7}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v5

    .line 166
    .local v5, "silent":Z
    sget-object v7, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    const-string v12, "autoCancel"

    move-object/from16 v17, v0

    const/4 v0, 0x1

    move/from16 v22, v5

    .end local v5    # "silent":Z
    .local v22, "silent":Z
    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v5

    invoke-virtual {v1, v12, v5}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v5

    invoke-virtual {v7, v5}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v5

    xor-int/2addr v5, v0

    .line 170
    .local v5, "autoCancel":Z
    const-string v7, "com.forge.live.OPEN_FROM_NOTIFY"

    if-eqz v10, :cond_d

    :try_start_1
    invoke-virtual {v10}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v12

    invoke-virtual {v12}, Ljava/lang/String;->isEmpty()Z

    move-result v12

    if-nez v12, :cond_d

    .line 171
    invoke-virtual {v10}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v12

    invoke-static {v2, v12, v11}, Lcom/forge/live/ShortcutBridgePlugin;->buildRunIntent(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v12

    .line 172
    .local v12, "launch":Landroid/content/Intent;
    invoke-virtual {v12, v7}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_8

    .line 228
    .end local v12    # "launch":Landroid/content/Intent;
    :catch_1
    move-exception v0

    move-object/from16 v16, v2

    move/from16 v25, v3

    move-object/from16 v18, v4

    move-object/from16 v23, v10

    goto/16 :goto_e

    .line 174
    :cond_d
    :try_start_2
    new-instance v12, Landroid/content/Intent;

    const-class v0, Lcom/forge/live/MainActivity;

    invoke-direct {v12, v2, v0}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 175
    .restart local v12    # "launch":Landroid/content/Intent;
    invoke-virtual {v12, v7}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 176
    const/high16 v0, 0x34000000

    invoke-virtual {v12, v0}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_9

    .line 178
    :goto_8
    if-eqz v15, :cond_e

    :try_start_3
    const-string v0, "forge_notify_payload"

    invoke-virtual {v12, v0, v15}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 179
    :cond_e
    if-eqz v14, :cond_f

    const-string v0, "forge_notify_tag"

    invoke-virtual {v12, v0, v14}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_1

    .line 180
    :cond_f
    :try_start_4
    const-string v0, "forge_notify_id"

    invoke-virtual {v12, v0, v13}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_9

    .line 181
    if-eqz v10, :cond_10

    :try_start_5
    const-string v0, "forge_app_id"

    invoke-virtual {v12, v0, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_1

    .line 183
    :cond_10
    const/high16 v0, 0x8000000

    .line 184
    .local v0, "piFlags":I
    :try_start_6
    sget v7, Landroid/os/Build$VERSION;->SDK_INT:I
    :try_end_6
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_6} :catch_9

    move-object/from16 v23, v10

    .end local v10    # "appId":Ljava/lang/String;
    .local v23, "appId":Ljava/lang/String;
    const/16 v10, 0x17

    if-lt v7, v10, :cond_11

    .line 185
    const/high16 v7, 0x4000000

    or-int/2addr v0, v7

    .line 188
    :cond_11
    :try_start_7
    invoke-static {v2, v13, v12, v0}, Landroid/app/PendingIntent;->getActivity(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v7

    .line 190
    .local v7, "contentIntent":Landroid/app/PendingIntent;
    const/4 v10, 0x0

    .line 191
    .local v10, "priority":I
    move/from16 v24, v0

    .end local v0    # "piFlags":I
    .local v24, "piFlags":I
    const-string v0, "forge_alerts"

    invoke-virtual {v0, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_12

    const/4 v10, 0x1

    .line 192
    :cond_12
    invoke-virtual {v8, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_13

    const/4 v10, -0x1

    .line 194
    :cond_13
    new-instance v0, Landroidx/core/app/NotificationCompat$Builder;

    invoke-direct {v0, v2, v9}, Landroidx/core/app/NotificationCompat$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 195
    if-eqz v4, :cond_14

    move-object v8, v4

    goto :goto_9

    :cond_14
    move-object/from16 v8, v18

    :goto_9
    invoke-virtual {v0, v8}, Landroidx/core/app/NotificationCompat$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0

    .line 196
    if-eqz v6, :cond_15

    move-object v8, v6

    goto :goto_a

    :cond_15
    move-object/from16 v8, v19

    :goto_a
    invoke-virtual {v0, v8}, Landroidx/core/app/NotificationCompat$Builder;->setContentText(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0

    new-instance v8, Landroidx/core/app/NotificationCompat$BigTextStyle;

    invoke-direct {v8}, Landroidx/core/app/NotificationCompat$BigTextStyle;-><init>()V
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_7} :catch_8

    .line 197
    if-eqz v6, :cond_16

    move-object/from16 v18, v4

    move-object v4, v6

    goto :goto_b

    :cond_16
    move-object/from16 v18, v4

    move-object/from16 v4, v19

    .end local v4    # "title":Ljava/lang/String;
    .local v18, "title":Ljava/lang/String;
    :goto_b
    :try_start_8
    invoke-virtual {v8, v4}, Landroidx/core/app/NotificationCompat$BigTextStyle;->bigText(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$BigTextStyle;

    move-result-object v4

    invoke-virtual {v0, v4}, Landroidx/core/app/NotificationCompat$Builder;->setStyle(Landroidx/core/app/NotificationCompat$Style;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0

    .line 198
    const v4, 0x108009b    # @android:drawable/ic_dialog_info

    invoke-virtual {v0, v4}, Landroidx/core/app/NotificationCompat$Builder;->setSmallIcon(I)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0

    .line 199
    invoke-virtual {v0, v7}, Landroidx/core/app/NotificationCompat$Builder;->setContentIntent(Landroid/app/PendingIntent;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0

    .line 200
    invoke-virtual {v0, v5}, Landroidx/core/app/NotificationCompat$Builder;->setAutoCancel(Z)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0

    .line 201
    invoke-virtual {v0, v3}, Landroidx/core/app/NotificationCompat$Builder;->setOngoing(Z)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0

    .line 202
    const/4 v4, 0x1

    invoke-virtual {v0, v4}, Landroidx/core/app/NotificationCompat$Builder;->setOnlyAlertOnce(Z)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0

    .line 203
    invoke-virtual {v0, v10}, Landroidx/core/app/NotificationCompat$Builder;->setPriority(I)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0

    const-string v4, "msg"

    .line 204
    invoke-virtual {v0, v4}, Landroidx/core/app/NotificationCompat$Builder;->setCategory(Ljava/lang/String;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0

    .line 205
    const/4 v4, 0x1

    invoke-virtual {v0, v4}, Landroidx/core/app/NotificationCompat$Builder;->setVisibility(I)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v0
    :try_end_8
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_8} :catch_7

    .line 207
    .local v0, "b":Landroidx/core/app/NotificationCompat$Builder;
    if-eqz v22, :cond_17

    .line 208
    :try_start_9
    invoke-virtual {v0, v4}, Landroidx/core/app/NotificationCompat$Builder;->setSilent(Z)Landroidx/core/app/NotificationCompat$Builder;
    :try_end_9
    .catch Ljava/lang/Exception; {:try_start_9 .. :try_end_9} :catch_2

    goto :goto_c

    .line 228
    .end local v0    # "b":Landroidx/core/app/NotificationCompat$Builder;
    .end local v7    # "contentIntent":Landroid/app/PendingIntent;
    .end local v10    # "priority":I
    .end local v12    # "launch":Landroid/content/Intent;
    .end local v24    # "piFlags":I
    :catch_2
    move-exception v0

    move-object/from16 v16, v2

    move/from16 v25, v3

    goto/16 :goto_e

    .line 211
    .restart local v0    # "b":Landroidx/core/app/NotificationCompat$Builder;
    .restart local v7    # "contentIntent":Landroid/app/PendingIntent;
    .restart local v10    # "priority":I
    .restart local v12    # "launch":Landroid/content/Intent;
    .restart local v24    # "piFlags":I
    :cond_17
    :goto_c
    :try_start_a
    const-string v4, "group"

    const/4 v8, 0x0

    invoke-virtual {v1, v4, v8}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4
    :try_end_a
    .catch Ljava/lang/Exception; {:try_start_a .. :try_end_a} :catch_7

    .line 212
    .local v4, "group":Ljava/lang/String;
    if-eqz v4, :cond_18

    :try_start_b
    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    move-result v8

    if-nez v8, :cond_18

    invoke-virtual {v0, v4}, Landroidx/core/app/NotificationCompat$Builder;->setGroup(Ljava/lang/String;)Landroidx/core/app/NotificationCompat$Builder;
    :try_end_b
    .catch Ljava/lang/Exception; {:try_start_b .. :try_end_b} :catch_2

    .line 214
    :cond_18
    :try_start_c
    invoke-static {v2}, Landroidx/core/app/NotificationManagerCompat;->from(Landroid/content/Context;)Landroidx/core/app/NotificationManagerCompat;

    move-result-object v8
    :try_end_c
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_c} :catch_7

    .line 215
    .local v8, "nm":Landroidx/core/app/NotificationManagerCompat;
    if-eqz v14, :cond_19

    :try_start_d
    invoke-virtual {v14}, Ljava/lang/String;->isEmpty()Z

    move-result v16
    :try_end_d
    .catch Ljava/lang/Exception; {:try_start_d .. :try_end_d} :catch_4

    if-nez v16, :cond_19

    .line 216
    move-object/from16 v16, v2

    .end local v2    # "ctx":Landroid/content/Context;
    .local v16, "ctx":Landroid/content/Context;
    :try_start_e
    invoke-virtual {v0}, Landroidx/core/app/NotificationCompat$Builder;->build()Landroid/app/Notification;

    move-result-object v2

    invoke-virtual {v8, v14, v13, v2}, Landroidx/core/app/NotificationManagerCompat;->notify(Ljava/lang/String;ILandroid/app/Notification;)V
    :try_end_e
    .catch Ljava/lang/Exception; {:try_start_e .. :try_end_e} :catch_3

    goto :goto_d

    .line 228
    .end local v0    # "b":Landroidx/core/app/NotificationCompat$Builder;
    .end local v4    # "group":Ljava/lang/String;
    .end local v7    # "contentIntent":Landroid/app/PendingIntent;
    .end local v8    # "nm":Landroidx/core/app/NotificationManagerCompat;
    .end local v10    # "priority":I
    .end local v12    # "launch":Landroid/content/Intent;
    .end local v24    # "piFlags":I
    :catch_3
    move-exception v0

    move/from16 v25, v3

    goto :goto_e

    .end local v16    # "ctx":Landroid/content/Context;
    .restart local v2    # "ctx":Landroid/content/Context;
    :catch_4
    move-exception v0

    move-object/from16 v16, v2

    move/from16 v25, v3

    .end local v2    # "ctx":Landroid/content/Context;
    .restart local v16    # "ctx":Landroid/content/Context;
    goto :goto_e

    .line 215
    .end local v16    # "ctx":Landroid/content/Context;
    .restart local v0    # "b":Landroidx/core/app/NotificationCompat$Builder;
    .restart local v2    # "ctx":Landroid/content/Context;
    .restart local v4    # "group":Ljava/lang/String;
    .restart local v7    # "contentIntent":Landroid/app/PendingIntent;
    .restart local v8    # "nm":Landroidx/core/app/NotificationManagerCompat;
    .restart local v10    # "priority":I
    .restart local v12    # "launch":Landroid/content/Intent;
    .restart local v24    # "piFlags":I
    :cond_19
    move-object/from16 v16, v2

    .line 218
    .end local v2    # "ctx":Landroid/content/Context;
    .restart local v16    # "ctx":Landroid/content/Context;
    :try_start_f
    invoke-virtual {v0}, Landroidx/core/app/NotificationCompat$Builder;->build()Landroid/app/Notification;

    move-result-object v2

    invoke-virtual {v8, v13, v2}, Landroidx/core/app/NotificationManagerCompat;->notify(ILandroid/app/Notification;)V

    .line 221
    :goto_d
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 222
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    move-object/from16 v19, v0

    .end local v0    # "b":Landroidx/core/app/NotificationCompat$Builder;
    .local v19, "b":Landroidx/core/app/NotificationCompat$Builder;
    const-string v0, "ok"
    :try_end_f
    .catch Ljava/lang/Exception; {:try_start_f .. :try_end_f} :catch_6

    move/from16 v25, v3

    const/4 v3, 0x1

    .end local v3    # "ongoing":Z
    .local v25, "ongoing":Z
    :try_start_10
    invoke-virtual {v2, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 223
    move-object/from16 v0, v17

    invoke-virtual {v2, v0, v13}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 224
    if-eqz v14, :cond_1a

    move-object/from16 v3, v21

    invoke-virtual {v2, v3, v14}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 225
    :cond_1a
    move-object/from16 v3, v20

    invoke-virtual {v2, v3, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 226
    const-string v0, "permission"

    invoke-direct/range {p0 .. p0}, Lcom/forge/live/NotifyBridgePlugin;->hasNotificationPermission()Z

    move-result v3

    invoke-virtual {v2, v0, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 227
    invoke-virtual {v1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_10
    .catch Ljava/lang/Exception; {:try_start_10 .. :try_end_10} :catch_5

    .line 230
    .end local v2    # "ret":Lcom/getcapacitor/JSObject;
    .end local v4    # "group":Ljava/lang/String;
    .end local v7    # "contentIntent":Landroid/app/PendingIntent;
    .end local v8    # "nm":Landroidx/core/app/NotificationManagerCompat;
    .end local v10    # "priority":I
    .end local v12    # "launch":Landroid/content/Intent;
    .end local v19    # "b":Landroidx/core/app/NotificationCompat$Builder;
    .end local v24    # "piFlags":I
    goto :goto_f

    .line 228
    :catch_5
    move-exception v0

    goto :goto_e

    .end local v25    # "ongoing":Z
    .restart local v3    # "ongoing":Z
    :catch_6
    move-exception v0

    move/from16 v25, v3

    .end local v3    # "ongoing":Z
    .restart local v25    # "ongoing":Z
    goto :goto_e

    .end local v16    # "ctx":Landroid/content/Context;
    .end local v25    # "ongoing":Z
    .local v2, "ctx":Landroid/content/Context;
    .restart local v3    # "ongoing":Z
    :catch_7
    move-exception v0

    move-object/from16 v16, v2

    move/from16 v25, v3

    .end local v2    # "ctx":Landroid/content/Context;
    .end local v3    # "ongoing":Z
    .restart local v16    # "ctx":Landroid/content/Context;
    .restart local v25    # "ongoing":Z
    goto :goto_e

    .end local v16    # "ctx":Landroid/content/Context;
    .end local v18    # "title":Ljava/lang/String;
    .end local v25    # "ongoing":Z
    .restart local v2    # "ctx":Landroid/content/Context;
    .restart local v3    # "ongoing":Z
    .local v4, "title":Ljava/lang/String;
    :catch_8
    move-exception v0

    move-object/from16 v16, v2

    move/from16 v25, v3

    move-object/from16 v18, v4

    .end local v2    # "ctx":Landroid/content/Context;
    .end local v3    # "ongoing":Z
    .end local v4    # "title":Ljava/lang/String;
    .restart local v16    # "ctx":Landroid/content/Context;
    .restart local v18    # "title":Ljava/lang/String;
    .restart local v25    # "ongoing":Z
    goto :goto_e

    .end local v16    # "ctx":Landroid/content/Context;
    .end local v18    # "title":Ljava/lang/String;
    .end local v23    # "appId":Ljava/lang/String;
    .end local v25    # "ongoing":Z
    .restart local v2    # "ctx":Landroid/content/Context;
    .restart local v3    # "ongoing":Z
    .restart local v4    # "title":Ljava/lang/String;
    .local v10, "appId":Ljava/lang/String;
    :catch_9
    move-exception v0

    move-object/from16 v16, v2

    move/from16 v25, v3

    move-object/from16 v18, v4

    move-object/from16 v23, v10

    .line 229
    .end local v2    # "ctx":Landroid/content/Context;
    .end local v3    # "ongoing":Z
    .end local v4    # "title":Ljava/lang/String;
    .end local v10    # "appId":Ljava/lang/String;
    .local v0, "e":Ljava/lang/Exception;
    .restart local v16    # "ctx":Landroid/content/Context;
    .restart local v18    # "title":Ljava/lang/String;
    .restart local v23    # "appId":Ljava/lang/String;
    .restart local v25    # "ongoing":Z
    :goto_e
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "notify failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 231
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_f
    return-void
.end method

.method public static showNotification(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    .locals 6
    .param p0, "ctx"    # Landroid/content/Context;
    .param p1, "appId"    # Ljava/lang/String;
    .param p2, "appTitle"    # Ljava/lang/String;
    .param p3, "title"    # Ljava/lang/String;
    .param p4, "message"    # Ljava/lang/String;
    .param p5, "channelId"    # Ljava/lang/String;
    .param p6, "tag"    # Ljava/lang/String;
    .param p7, "payloadJson"    # Ljava/lang/String;
    .param p8, "id"    # I

    .line 280
    invoke-static {p0}, Lcom/forge/live/NotifyBridgePlugin;->ensureChannels(Landroid/content/Context;)V

    .line 281
    if-eqz p5, :cond_0

    invoke-virtual {p5}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_1

    :cond_0
    const-string p5, "forge_jobs"

    .line 282
    :cond_1
    if-nez p8, :cond_3

    .line 283
    if-eqz p6, :cond_2

    move-object v0, p6

    goto :goto_0

    :cond_2
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    :goto_0
    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v0

    const v1, 0x186a0

    rem-int/2addr v0, v1

    invoke-static {v0}, Ljava/lang/Math;->abs(I)I

    move-result v0

    const v1, 0xcb20

    add-int p8, v0, v1

    .line 286
    :cond_3
    const-string v0, "com.forge.live.OPEN_FROM_NOTIFY"

    if-eqz p1, :cond_5

    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_5

    .line 287
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    if-eqz p2, :cond_4

    move-object v2, p2

    goto :goto_1

    :cond_4
    move-object v2, p3

    :goto_1
    invoke-static {p0, v1, v2}, Lcom/forge/live/ShortcutBridgePlugin;->buildRunIntent(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v1

    .line 288
    .local v1, "launch":Landroid/content/Intent;
    invoke-virtual {v1, v0}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    goto :goto_2

    .line 290
    .end local v1    # "launch":Landroid/content/Intent;
    :cond_5
    new-instance v1, Landroid/content/Intent;

    const-class v2, Lcom/forge/live/MainActivity;

    invoke-direct {v1, p0, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 291
    .restart local v1    # "launch":Landroid/content/Intent;
    invoke-virtual {v1, v0}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 292
    const/high16 v0, 0x30000000

    invoke-virtual {v1, v0}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 294
    :goto_2
    if-eqz p7, :cond_6

    const-string v0, "forge_notify_payload"

    invoke-virtual {v1, v0, p7}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 295
    :cond_6
    if-eqz p6, :cond_7

    const-string v0, "forge_notify_tag"

    invoke-virtual {v1, v0, p6}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 296
    :cond_7
    const-string v0, "forge_notify_id"

    invoke-virtual {v1, v0, p8}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 297
    if-eqz p1, :cond_8

    const-string v0, "forge_app_id"

    invoke-virtual {v1, v0, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 299
    :cond_8
    const/high16 v0, 0x8000000

    .line 300
    .local v0, "piFlags":I
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x17

    if-lt v2, v3, :cond_9

    .line 301
    const/high16 v2, 0x4000000

    or-int/2addr v0, v2

    .line 303
    :cond_9
    invoke-static {p0, p8, v1, v0}, Landroid/app/PendingIntent;->getActivity(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v2

    .line 305
    .local v2, "contentIntent":Landroid/app/PendingIntent;
    new-instance v3, Landroidx/core/app/NotificationCompat$Builder;

    invoke-direct {v3, p0, p5}, Landroidx/core/app/NotificationCompat$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 306
    if-eqz p3, :cond_a

    move-object v4, p3

    goto :goto_3

    :cond_a
    const-string v4, "Forge"

    :goto_3
    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 307
    const-string v4, ""

    if-eqz p4, :cond_b

    move-object v5, p4

    goto :goto_4

    :cond_b
    move-object v5, v4

    :goto_4
    invoke-virtual {v3, v5}, Landroidx/core/app/NotificationCompat$Builder;->setContentText(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    new-instance v5, Landroidx/core/app/NotificationCompat$BigTextStyle;

    invoke-direct {v5}, Landroidx/core/app/NotificationCompat$BigTextStyle;-><init>()V

    .line 308
    if-eqz p4, :cond_c

    move-object v4, p4

    :cond_c
    invoke-virtual {v5, v4}, Landroidx/core/app/NotificationCompat$BigTextStyle;->bigText(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$BigTextStyle;

    move-result-object v4

    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setStyle(Landroidx/core/app/NotificationCompat$Style;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 309
    const v4, 0x108005e    # @android:drawable/ic_popup_reminder

    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setSmallIcon(I)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 310
    invoke-virtual {v3, v2}, Landroidx/core/app/NotificationCompat$Builder;->setContentIntent(Landroid/app/PendingIntent;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 311
    const/4 v4, 0x1

    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setAutoCancel(Z)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 312
    const/4 v4, 0x0

    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setPriority(I)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 313
    const-string v4, "reminder"

    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setCategory(Ljava/lang/String;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 315
    .local v3, "b":Landroidx/core/app/NotificationCompat$Builder;
    invoke-static {p0}, Landroidx/core/app/NotificationManagerCompat;->from(Landroid/content/Context;)Landroidx/core/app/NotificationManagerCompat;

    move-result-object v4

    .line 317
    .local v4, "nm":Landroidx/core/app/NotificationManagerCompat;
    if-eqz p6, :cond_d

    :try_start_0
    invoke-virtual {p6}, Ljava/lang/String;->isEmpty()Z

    move-result v5

    if-nez v5, :cond_d

    invoke-virtual {v3}, Landroidx/core/app/NotificationCompat$Builder;->build()Landroid/app/Notification;

    move-result-object v5

    invoke-virtual {v4, p6, p8, v5}, Landroidx/core/app/NotificationManagerCompat;->notify(Ljava/lang/String;ILandroid/app/Notification;)V

    goto :goto_5

    .line 318
    :cond_d
    invoke-virtual {v3}, Landroidx/core/app/NotificationCompat$Builder;->build()Landroid/app/Notification;

    move-result-object v5

    invoke-virtual {v4, p8, v5}, Landroidx/core/app/NotificationManagerCompat;->notify(ILandroid/app/Notification;)V
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_0

    .line 321
    :goto_5
    goto :goto_6

    .line 319
    :catch_0
    move-exception v5

    .line 322
    :goto_6
    return-void
.end method


# virtual methods
.method public cancel(Lcom/getcapacitor/PluginCall;)V
    .locals 7
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 236
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/NotifyBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Landroidx/core/app/NotificationManagerCompat;->from(Landroid/content/Context;)Landroidx/core/app/NotificationManagerCompat;

    move-result-object v0

    .line 237
    .local v0, "nm":Landroidx/core/app/NotificationManagerCompat;
    const-string v1, "tag"

    const/4 v2, 0x0

    invoke-virtual {p1, v1, v2}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 238
    .local v1, "tag":Ljava/lang/String;
    const-string v2, "id"

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v2

    .line 239
    .local v2, "idObj":Ljava/lang/Integer;
    if-nez v2, :cond_1

    if-eqz v1, :cond_0

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_1

    .line 241
    :cond_0
    const-string v3, "id or tag required"

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 242
    return-void

    .line 244
    :cond_1
    if-eqz v2, :cond_2

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v3

    goto :goto_0

    :cond_2
    const/4 v3, 0x0

    .line 245
    .local v3, "id":I
    :goto_0
    if-eqz v1, :cond_3

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v4

    if-nez v4, :cond_3

    .line 246
    invoke-virtual {v0, v1, v3}, Landroidx/core/app/NotificationManagerCompat;->cancel(Ljava/lang/String;I)V

    goto :goto_1

    .line 248
    :cond_3
    invoke-virtual {v0, v3}, Landroidx/core/app/NotificationManagerCompat;->cancel(I)V

    .line 250
    :goto_1
    new-instance v4, Lcom/getcapacitor/JSObject;

    invoke-direct {v4}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 251
    .local v4, "o":Lcom/getcapacitor/JSObject;
    const-string v5, "ok"

    const/4 v6, 0x1

    invoke-virtual {v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 252
    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 255
    .end local v0    # "nm":Landroidx/core/app/NotificationManagerCompat;
    .end local v1    # "tag":Ljava/lang/String;
    .end local v2    # "idObj":Ljava/lang/Integer;
    .end local v3    # "id":I
    .end local v4    # "o":Lcom/getcapacitor/JSObject;
    goto :goto_2

    .line 253
    :catch_0
    move-exception v0

    .line 254
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "cancel failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 256
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_2
    return-void
.end method

.method public cancelAll(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 261
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/NotifyBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Landroidx/core/app/NotificationManagerCompat;->from(Landroid/content/Context;)Landroidx/core/app/NotificationManagerCompat;

    move-result-object v0

    invoke-virtual {v0}, Landroidx/core/app/NotificationManagerCompat;->cancelAll()V

    .line 262
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    const-string v1, "ok"

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 265
    goto :goto_0

    .line 263
    :catch_0
    move-exception v0

    .line 264
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "cancelAll failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 266
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method public ensureChannels(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 99
    invoke-virtual {p0}, Lcom/forge/live/NotifyBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Lcom/forge/live/NotifyBridgePlugin;->ensureChannels(Landroid/content/Context;)V

    .line 100
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 101
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "ok"

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 102
    const-string v1, "channels"

    invoke-direct {p0}, Lcom/forge/live/NotifyBridgePlugin;->defaultChannelList()Lcom/getcapacitor/JSArray;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 103
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 104
    return-void
.end method

.method public isAvailable(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 61
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 62
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "available"

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 63
    const-string v1, "permission"

    invoke-direct {p0}, Lcom/forge/live/NotifyBridgePlugin;->hasNotificationPermission()Z

    move-result v3

    invoke-virtual {v0, v1, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 64
    const-string v1, "channels"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 65
    const-string v1, "tapOpen"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 66
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 67
    return-void
.end method

.method public listChannels(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 108
    invoke-virtual {p0}, Lcom/forge/live/NotifyBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Lcom/forge/live/NotifyBridgePlugin;->ensureChannels(Landroid/content/Context;)V

    .line 109
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 110
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "channels"

    invoke-direct {p0}, Lcom/forge/live/NotifyBridgePlugin;->defaultChannelList()Lcom/getcapacitor/JSArray;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 111
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 112
    return-void
.end method

.method public load()V
    .locals 1

    .line 55
    invoke-super {p0}, Lcom/getcapacitor/Plugin;->load()V

    .line 56
    invoke-virtual {p0}, Lcom/forge/live/NotifyBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Lcom/forge/live/NotifyBridgePlugin;->ensureChannels(Landroid/content/Context;)V

    .line 57
    return-void
.end method

.method public requestPermission(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 71
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    const-string v2, "permission"

    const-string v3, "granted"

    const/4 v4, 0x1

    if-ge v0, v1, :cond_0

    .line 72
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 73
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    invoke-virtual {v0, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 74
    invoke-virtual {v0, v2, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 75
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 76
    return-void

    .line 78
    .end local v0    # "ret":Lcom/getcapacitor/JSObject;
    :cond_0
    invoke-direct {p0}, Lcom/forge/live/NotifyBridgePlugin;->hasNotificationPermission()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 79
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 80
    .restart local v0    # "ret":Lcom/getcapacitor/JSObject;
    invoke-virtual {v0, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 81
    invoke-virtual {v0, v2, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 82
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 83
    return-void

    .line 85
    .end local v0    # "ret":Lcom/getcapacitor/JSObject;
    :cond_1
    const-string v0, "notifications"

    const-string v1, "notifyPermCallback"

    invoke-virtual {p0, v0, p1, v1}, Lcom/forge/live/NotifyBridgePlugin;->requestPermissionForAlias(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    .line 86
    return-void
.end method

.method public show(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 116
    invoke-virtual {p0}, Lcom/forge/live/NotifyBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Lcom/forge/live/NotifyBridgePlugin;->ensureChannels(Landroid/content/Context;)V

    .line 117
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    if-lt v0, v1, :cond_0

    invoke-direct {p0}, Lcom/forge/live/NotifyBridgePlugin;->hasNotificationPermission()Z

    move-result v0

    if-nez v0, :cond_0

    .line 120
    :try_start_0
    const-string v0, "notifications"

    const-string v1, "showAfterPerm"

    invoke-virtual {p0, v0, p1, v1}, Lcom/forge/live/NotifyBridgePlugin;->requestPermissionForAlias(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 121
    return-void

    .line 122
    :catch_0
    move-exception v0

    .line 124
    :cond_0
    invoke-direct {p0, p1}, Lcom/forge/live/NotifyBridgePlugin;->showInternal(Lcom/getcapacitor/PluginCall;)V

    .line 125
    return-void
.end method
