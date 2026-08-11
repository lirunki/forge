.class public Lcom/forge/live/AppsBridgePlugin;
.super Lcom/getcapacitor/Plugin;
.source "AppsBridgePlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "AppsBridge"
.end annotation


# static fields
.field private static final DEFAULT_LIMIT:I = 0x190

.field private static final KNOWN_PACKAGES:[Ljava/lang/String;

.field private static final MAX_LIMIT:I = 0x7d0


# direct methods
.method static constructor <clinit>()V
    .locals 46

    .line 48
    const-string v0, "com.google.android.apps.maps"

    const-string v1, "com.waze"

    const-string v2, "com.google.android.apps.mapslite"

    const-string v3, "com.mapquest.android.ace"

    const-string v4, "com.mapfactor.maps"

    const-string v5, "com.here.app.maps"

    const-string v6, "com.sygic.aura"

    const-string v7, "com.tomtom.gplay.navapp"

    const-string v8, "com.autonavi.minimap"

    const-string v9, "com.baidu.BaiduMap"

    const-string v10, "ru.yandex.yandexnavi"

    const-string v11, "ru.yandex.yandexmaps"

    const-string v12, "com.ubercab"

    const-string v13, "com.ubercab.driver"

    const-string v14, "com.lyft.android"

    const-string v15, "com.whatsapp"

    const-string v16, "com.whatsapp.w4b"

    const-string v17, "org.telegram.messenger"

    const-string v18, "org.telegram.messenger.web"

    const-string v19, "com.facebook.orca"

    const-string v20, "com.facebook.katana"

    const-string v21, "com.instagram.android"

    const-string v22, "com.twitter.android"

    const-string v23, "com.zhiliaoapp.musically"

    const-string v24, "com.snapchat.android"

    const-string v25, "com.viber.voip"

    const-string v26, "com.discord"

    const-string v27, "com.slack"

    const-string v28, "com.google.android.apps.messaging"

    const-string v29, "com.samsung.android.messaging"

    const-string v30, "com.google.android.gm"

    const-string v31, "com.android.chrome"

    const-string v32, "com.chrome.beta"

    const-string v33, "com.sec.android.app.sbrowser"

    const-string v34, "org.mozilla.firefox"

    const-string v35, "com.google.android.youtube"

    const-string v36, "com.spotify.music"

    const-string v37, "com.netflix.mediaclient"

    const-string v38, "com.google.android.googlequicksearchbox"

    const-string v39, "com.google.android.apps.photos"

    const-string v40, "com.google.android.calendar"

    const-string v41, "com.google.android.keep"

    const-string v42, "com.google.android.contacts"

    const-string v43, "com.google.android.dialer"

    const-string v44, "com.android.vending"

    const-string v45, "com.android.settings"

    filled-new-array/range {v0 .. v45}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/forge/live/AppsBridgePlugin;->KNOWN_PACKAGES:[Ljava/lang/String;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .line 40
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    return-void
.end method

.method private activityOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 759
    const-string v0, "activity"

    const/4 v1, 0x0

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 760
    .local v0, "a":Ljava/lang/String;
    if-nez v0, :cond_0

    const-string v2, "className"

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 761
    :cond_0
    if-nez v0, :cond_1

    const-string v2, "class"

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 762
    :cond_1
    const-string v2, "."

    if-nez v0, :cond_3

    .line 763
    const-string v3, "component"

    invoke-virtual {p1, v3, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 764
    .local v1, "component":Ljava/lang/String;
    if-eqz v1, :cond_2

    const-string v3, "/"

    invoke-virtual {v1, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v4

    if-eqz v4, :cond_2

    .line 765
    const/4 v4, 0x2

    invoke-virtual {v1, v3, v4}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;

    move-result-object v3

    const/4 v4, 0x1

    aget-object v0, v3, v4

    .line 766
    invoke-direct {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->packageNameOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v3

    .line 767
    .local v3, "pkg":Ljava/lang/String;
    invoke-virtual {v0, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_2

    if-eqz v3, :cond_2

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 769
    .end local v1    # "component":Ljava/lang/String;
    .end local v3    # "pkg":Ljava/lang/String;
    :cond_2
    goto :goto_0

    .line 770
    :cond_3
    invoke-direct {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->packageNameOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v1

    .line 771
    .local v1, "pkg":Ljava/lang/String;
    invoke-virtual {v0, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_4

    if-eqz v1, :cond_4

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 773
    .end local v1    # "pkg":Ljava/lang/String;
    :cond_4
    :goto_0
    return-object v0
.end method

.method private addFromCommonIntents(Landroid/content/pm/PackageManager;Ljava/util/Map;Z)I
    .locals 20
    .param p1, "pm"    # Landroid/content/pm/PackageManager;
    .param p3, "includeSystem"    # Z
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/pm/PackageManager;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lcom/getcapacitor/JSObject;",
            ">;Z)I"
        }
    .end annotation

    .line 452
    .local p2, "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    move-object/from16 v1, p1

    move-object/from16 v2, p2

    invoke-interface/range {p2 .. p2}, Ljava/util/Map;->size()I

    move-result v3

    .line 453
    .local v3, "before":I
    const/4 v0, 0x7

    new-array v0, v0, [Landroid/content/Intent;

    .line 454
    const-string v4, "geo:0,0?q=coffee"

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->viewIntent(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v4

    const/4 v5, 0x0

    aput-object v4, v0, v5

    .line 455
    const-string v4, "google.navigation:q=Home"

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->viewIntent(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v4

    const/4 v6, 0x1

    aput-object v4, v0, v6

    .line 456
    const-string v4, "https://maps.google.com/?q=coffee"

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->viewIntent(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v4

    const/4 v7, 0x2

    aput-object v4, v0, v7

    .line 457
    const-string v4, "https://www.google.com/maps/search/?api=1&query=coffee"

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->viewIntent(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v4

    const/4 v7, 0x3

    aput-object v4, v0, v7

    .line 458
    const-string v4, "waze://?q=coffee"

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->viewIntent(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v4

    const/4 v7, 0x4

    aput-object v4, v0, v7

    .line 459
    const-string v4, "https://waze.com/ul?q=coffee"

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->viewIntent(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v4

    const/4 v7, 0x5

    aput-object v4, v0, v7

    .line 460
    invoke-static {}, Lcom/forge/live/AppsBridgePlugin;->sendTextIntent()Landroid/content/Intent;

    move-result-object v4

    const/4 v7, 0x6

    aput-object v4, v0, v7

    move-object v4, v0

    .line 462
    .local v4, "probes":[Landroid/content/Intent;
    array-length v7, v4

    const/4 v8, 0x0

    :goto_0
    if-ge v8, v7, :cond_a

    aget-object v9, v4, v8

    .line 464
    .local v9, "intent":Landroid/content/Intent;
    move-object/from16 v10, p0

    :try_start_0
    invoke-direct {v10, v1, v9}, Lcom/forge/live/AppsBridgePlugin;->queryActivities(Landroid/content/pm/PackageManager;Landroid/content/Intent;)Ljava/util/List;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v11

    :goto_1
    invoke-interface {v11}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_9

    invoke-interface {v11}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/pm/ResolveInfo;

    move-object v12, v0

    .line 465
    .local v12, "ri":Landroid/content/pm/ResolveInfo;
    if-eqz v12, :cond_8

    iget-object v0, v12, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    if-nez v0, :cond_0

    goto :goto_1

    .line 466
    :cond_0
    iget-object v0, v12, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v0, v0, Landroid/content/pm/ActivityInfo;->packageName:Ljava/lang/String;

    move-object v13, v0

    .line 467
    .local v13, "pkg":Ljava/lang/String;
    if-eqz v13, :cond_7

    invoke-interface {v2, v13}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    goto :goto_1

    .line 468
    :cond_1
    iget-object v0, v12, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v0, v0, Landroid/content/pm/ActivityInfo;->applicationInfo:Landroid/content/pm/ApplicationInfo;

    move-object v14, v0

    .line 469
    .local v14, "ai":Landroid/content/pm/ApplicationInfo;
    invoke-static {v14}, Lcom/forge/live/AppsBridgePlugin;->isSystemApp(Landroid/content/pm/ApplicationInfo;)Z

    move-result v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_2

    move v15, v0

    .line 470
    .local v15, "system":Z
    if-nez p3, :cond_2

    if-eqz v15, :cond_2

    goto :goto_1

    .line 471
    :cond_2
    move-object/from16 v16, v13

    .line 473
    .local v16, "label":Ljava/lang/String;
    if-eqz v14, :cond_4

    .line 474
    :try_start_1
    invoke-virtual {v1, v14}, Landroid/content/pm/PackageManager;->getApplicationLabel(Landroid/content/pm/ApplicationInfo;)Ljava/lang/CharSequence;

    move-result-object v0

    .line 475
    .local v0, "appLabel":Ljava/lang/CharSequence;
    if-eqz v0, :cond_3

    invoke-interface {v0}, Ljava/lang/CharSequence;->length()I

    move-result v17

    if-lez v17, :cond_3

    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;

    move-result-object v17

    move-object/from16 v16, v17

    .line 476
    .end local v0    # "appLabel":Ljava/lang/CharSequence;
    :cond_3
    goto :goto_2

    .line 477
    :cond_4
    invoke-virtual {v12, v1}, Landroid/content/pm/ResolveInfo;->loadLabel(Landroid/content/pm/PackageManager;)Ljava/lang/CharSequence;

    move-result-object v0

    .line 478
    .local v0, "labelCs":Ljava/lang/CharSequence;
    if-eqz v0, :cond_5

    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;

    move-result-object v17
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    move-object/from16 v16, v17

    goto :goto_2

    .line 480
    .end local v0    # "labelCs":Ljava/lang/CharSequence;
    :catch_0
    move-exception v0

    :cond_5
    :goto_2
    move-object/from16 v6, v16

    .line 481
    .end local v16    # "label":Ljava/lang/String;
    .local v6, "label":Ljava/lang/String;
    const/16 v16, 0x1

    .line 482
    .local v16, "launchable":Z
    :try_start_2
    invoke-virtual {v1, v13}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v0
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    if-eqz v0, :cond_6

    const/4 v0, 0x1

    goto :goto_3

    :cond_6
    const/4 v0, 0x0

    :goto_3
    move/from16 v16, v0

    goto :goto_4

    :catch_1
    move-exception v0

    :goto_4
    move/from16 v0, v16

    .line 483
    .end local v16    # "launchable":Z
    .local v0, "launchable":Z
    :try_start_3
    invoke-static {v13, v6, v15, v0}, Lcom/forge/live/AppsBridgePlugin;->baseAppRow(Ljava/lang/String;Ljava/lang/String;ZZ)Lcom/getcapacitor/JSObject;

    move-result-object v16

    move-object/from16 v18, v16

    .line 484
    .local v18, "row":Lcom/getcapacitor/JSObject;
    const-string v5, "activity"

    move/from16 v19, v0

    .end local v0    # "launchable":Z
    .local v19, "launchable":Z
    iget-object v0, v12, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v0, v0, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    move-object/from16 v1, v18

    .end local v18    # "row":Lcom/getcapacitor/JSObject;
    .local v1, "row":Lcom/getcapacitor/JSObject;
    invoke-virtual {v1, v5, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 485
    const-string v0, "source"

    const-string v5, "intent"

    invoke-virtual {v1, v0, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 486
    invoke-interface {v2, v13, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_2

    .line 487
    move-object/from16 v1, p1

    const/4 v5, 0x0

    const/4 v6, 0x1

    .end local v1    # "row":Lcom/getcapacitor/JSObject;
    .end local v6    # "label":Ljava/lang/String;
    .end local v12    # "ri":Landroid/content/pm/ResolveInfo;
    .end local v13    # "pkg":Ljava/lang/String;
    .end local v14    # "ai":Landroid/content/pm/ApplicationInfo;
    .end local v15    # "system":Z
    .end local v19    # "launchable":Z
    goto/16 :goto_1

    .line 467
    .restart local v12    # "ri":Landroid/content/pm/ResolveInfo;
    .restart local v13    # "pkg":Ljava/lang/String;
    :cond_7
    move-object/from16 v1, p1

    const/4 v5, 0x0

    const/4 v6, 0x1

    goto/16 :goto_1

    .line 465
    .end local v13    # "pkg":Ljava/lang/String;
    :cond_8
    move-object/from16 v1, p1

    const/4 v5, 0x0

    const/4 v6, 0x1

    goto/16 :goto_1

    .line 488
    .end local v12    # "ri":Landroid/content/pm/ResolveInfo;
    :catch_2
    move-exception v0

    :cond_9
    nop

    .line 462
    .end local v9    # "intent":Landroid/content/Intent;
    add-int/lit8 v8, v8, 0x1

    move-object/from16 v1, p1

    const/4 v5, 0x0

    const/4 v6, 0x1

    goto/16 :goto_0

    .line 490
    :cond_a
    move-object/from16 v10, p0

    invoke-interface/range {p2 .. p2}, Ljava/util/Map;->size()I

    move-result v0

    sub-int/2addr v0, v3

    const/4 v1, 0x0

    invoke-static {v1, v0}, Ljava/lang/Math;->max(II)I

    move-result v0

    return v0
.end method

.method private addFromInstalledApps(Landroid/content/pm/PackageManager;Ljava/util/Map;ZZ)I
    .locals 11
    .param p1, "pm"    # Landroid/content/pm/PackageManager;
    .param p3, "includeSystem"    # Z
    .param p4, "launchableOnly"    # Z
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/pm/PackageManager;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lcom/getcapacitor/JSObject;",
            ">;ZZ)I"
        }
    .end annotation

    .line 426
    .local p2, "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    const/4 v0, 0x0

    .line 428
    .local v0, "added":I
    :try_start_0
    invoke-direct {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->getInstalledApplications(Landroid/content/pm/PackageManager;)Ljava/util/List;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_0
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_8

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/content/pm/ApplicationInfo;

    .line 429
    .local v2, "ai":Landroid/content/pm/ApplicationInfo;
    if-eqz v2, :cond_0

    iget-object v3, v2, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;

    if-nez v3, :cond_1

    goto :goto_0

    .line 430
    :cond_1
    iget-object v3, v2, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;

    invoke-interface {p2, v3}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_2

    goto :goto_0

    .line 431
    :cond_2
    invoke-static {v2}, Lcom/forge/live/AppsBridgePlugin;->isSystemApp(Landroid/content/pm/ApplicationInfo;)Z

    move-result v3
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 432
    .local v3, "system":Z
    if-nez p3, :cond_3

    if-eqz v3, :cond_3

    goto :goto_0

    .line 433
    :cond_3
    const/4 v4, 0x0

    .line 434
    .local v4, "launch":Landroid/content/Intent;
    :try_start_1
    iget-object v5, v2, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;

    invoke-virtual {p1, v5}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v5
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    move-object v4, v5

    goto :goto_1

    :catch_0
    move-exception v5

    .line 435
    :goto_1
    if-eqz v4, :cond_4

    const/4 v5, 0x1

    goto :goto_2

    :cond_4
    const/4 v5, 0x0

    .line 436
    .local v5, "launchable":Z
    :goto_2
    if-eqz p4, :cond_5

    if-nez v5, :cond_5

    goto :goto_0

    .line 437
    :cond_5
    :try_start_2
    invoke-virtual {p1, v2}, Landroid/content/pm/PackageManager;->getApplicationLabel(Landroid/content/pm/ApplicationInfo;)Ljava/lang/CharSequence;

    move-result-object v6

    .line 438
    .local v6, "labelCs":Ljava/lang/CharSequence;
    if-eqz v6, :cond_6

    invoke-interface {v6}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;

    move-result-object v7

    goto :goto_3

    :cond_6
    iget-object v7, v2, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;

    .line 439
    .local v7, "label":Ljava/lang/String;
    :goto_3
    iget-object v8, v2, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;

    invoke-static {v8, v7, v3, v5}, Lcom/forge/live/AppsBridgePlugin;->baseAppRow(Ljava/lang/String;Ljava/lang/String;ZZ)Lcom/getcapacitor/JSObject;

    move-result-object v8

    .line 440
    .local v8, "row":Lcom/getcapacitor/JSObject;
    if-eqz v4, :cond_7

    invoke-virtual {v4}, Landroid/content/Intent;->getComponent()Landroid/content/ComponentName;

    move-result-object v9

    if-eqz v9, :cond_7

    .line 441
    const-string v9, "activity"

    invoke-virtual {v4}, Landroid/content/Intent;->getComponent()Landroid/content/ComponentName;

    move-result-object v10

    invoke-virtual {v10}, Landroid/content/ComponentName;->getClassName()Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v8, v9, v10}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 443
    :cond_7
    const-string v9, "source"

    const-string v10, "installed"

    invoke-virtual {v8, v9, v10}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 444
    iget-object v9, v2, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;

    invoke-interface {p2, v9, v8}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    .line 445
    nop

    .end local v2    # "ai":Landroid/content/pm/ApplicationInfo;
    .end local v3    # "system":Z
    .end local v4    # "launch":Landroid/content/Intent;
    .end local v5    # "launchable":Z
    .end local v6    # "labelCs":Ljava/lang/CharSequence;
    .end local v7    # "label":Ljava/lang/String;
    .end local v8    # "row":Lcom/getcapacitor/JSObject;
    add-int/lit8 v0, v0, 0x1

    .line 446
    goto :goto_0

    .line 447
    :catch_1
    move-exception v1

    :cond_8
    nop

    .line 448
    return v0
.end method

.method private addFromKnownPackages(Landroid/content/pm/PackageManager;Ljava/util/Map;ZZ)I
    .locals 12
    .param p1, "pm"    # Landroid/content/pm/PackageManager;
    .param p3, "includeSystem"    # Z
    .param p4, "launchableOnly"    # Z
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/pm/PackageManager;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lcom/getcapacitor/JSObject;",
            ">;ZZ)I"
        }
    .end annotation

    .line 495
    .local p2, "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    const/4 v0, 0x0

    .line 496
    .local v0, "added":I
    sget-object v1, Lcom/forge/live/AppsBridgePlugin;->KNOWN_PACKAGES:[Ljava/lang/String;

    array-length v2, v1

    const/4 v3, 0x0

    :goto_0
    if-ge v3, v2, :cond_1

    aget-object v11, v1, v3

    .line 497
    .local v11, "pkg":Ljava/lang/String;
    const-string v10, "known"

    move-object v4, p0

    move-object v5, p1

    move-object v6, p2

    move-object v7, v11

    move v8, p3

    move/from16 v9, p4

    invoke-direct/range {v4 .. v10}, Lcom/forge/live/AppsBridgePlugin;->addPackageIfVisible(Landroid/content/pm/PackageManager;Ljava/util/Map;Ljava/lang/String;ZZLjava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 498
    add-int/lit8 v0, v0, 0x1

    .line 496
    .end local v11    # "pkg":Ljava/lang/String;
    :cond_0
    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    .line 501
    :cond_1
    return v0
.end method

.method private addFromLauncherQuery(Landroid/content/pm/PackageManager;Ljava/util/Map;Z)I
    .locals 12
    .param p1, "pm"    # Landroid/content/pm/PackageManager;
    .param p3, "includeSystem"    # Z
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/pm/PackageManager;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lcom/getcapacitor/JSObject;",
            ">;Z)I"
        }
    .end annotation

    .line 400
    .local p2, "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    const/4 v0, 0x0

    .line 402
    .local v0, "added":I
    :try_start_0
    new-instance v1, Landroid/content/Intent;

    const-string v2, "android.intent.action.MAIN"

    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 403
    .local v1, "main":Landroid/content/Intent;
    const-string v2, "android.intent.category.LAUNCHER"

    invoke-virtual {v1, v2}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;

    .line 404
    invoke-direct {p0, p1, v1}, Lcom/forge/live/AppsBridgePlugin;->queryActivities(Landroid/content/pm/PackageManager;Landroid/content/Intent;)Ljava/util/List;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :cond_0
    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_5

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Landroid/content/pm/ResolveInfo;

    .line 405
    .local v3, "ri":Landroid/content/pm/ResolveInfo;
    if-eqz v3, :cond_0

    iget-object v4, v3, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    if-nez v4, :cond_1

    goto :goto_0

    .line 406
    :cond_1
    iget-object v4, v3, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v4, v4, Landroid/content/pm/ActivityInfo;->packageName:Ljava/lang/String;

    .line 407
    .local v4, "pkg":Ljava/lang/String;
    if-eqz v4, :cond_0

    invoke-interface {p2, v4}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_2

    goto :goto_0

    .line 408
    :cond_2
    iget-object v5, v3, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v5, v5, Landroid/content/pm/ActivityInfo;->applicationInfo:Landroid/content/pm/ApplicationInfo;

    .line 409
    .local v5, "ai":Landroid/content/pm/ApplicationInfo;
    invoke-static {v5}, Lcom/forge/live/AppsBridgePlugin;->isSystemApp(Landroid/content/pm/ApplicationInfo;)Z

    move-result v6

    .line 410
    .local v6, "system":Z
    if-nez p3, :cond_3

    if-eqz v6, :cond_3

    goto :goto_0

    .line 411
    :cond_3
    invoke-virtual {v3, p1}, Landroid/content/pm/ResolveInfo;->loadLabel(Landroid/content/pm/PackageManager;)Ljava/lang/CharSequence;

    move-result-object v7

    .line 412
    .local v7, "labelCs":Ljava/lang/CharSequence;
    if-eqz v7, :cond_4

    invoke-interface {v7}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;

    move-result-object v8

    goto :goto_1

    :cond_4
    move-object v8, v4

    .line 413
    .local v8, "label":Ljava/lang/String;
    :goto_1
    const/4 v9, 0x1

    invoke-static {v4, v8, v6, v9}, Lcom/forge/live/AppsBridgePlugin;->baseAppRow(Ljava/lang/String;Ljava/lang/String;ZZ)Lcom/getcapacitor/JSObject;

    move-result-object v9

    .line 414
    .local v9, "row":Lcom/getcapacitor/JSObject;
    const-string v10, "activity"

    iget-object v11, v3, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v11, v11, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    invoke-virtual {v9, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 415
    const-string v10, "exported"

    iget-object v11, v3, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-boolean v11, v11, Landroid/content/pm/ActivityInfo;->exported:Z

    invoke-virtual {v9, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 416
    const-string v10, "source"

    const-string v11, "launcher"

    invoke-virtual {v9, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 417
    invoke-interface {p2, v4, v9}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 418
    nop

    .end local v3    # "ri":Landroid/content/pm/ResolveInfo;
    .end local v4    # "pkg":Ljava/lang/String;
    .end local v5    # "ai":Landroid/content/pm/ApplicationInfo;
    .end local v6    # "system":Z
    .end local v7    # "labelCs":Ljava/lang/CharSequence;
    .end local v8    # "label":Ljava/lang/String;
    .end local v9    # "row":Lcom/getcapacitor/JSObject;
    add-int/lit8 v0, v0, 0x1

    .line 419
    goto :goto_0

    .line 404
    .end local v1    # "main":Landroid/content/Intent;
    :cond_5
    goto :goto_2

    .line 420
    :catch_0
    move-exception v1

    :goto_2
    nop

    .line 421
    return v0
.end method

.method private addPackageIfVisible(Landroid/content/pm/PackageManager;Ljava/util/Map;Ljava/lang/String;ZZLjava/lang/String;)Z
    .locals 14
    .param p1, "pm"    # Landroid/content/pm/PackageManager;
    .param p3, "pkg"    # Ljava/lang/String;
    .param p4, "includeSystem"    # Z
    .param p5, "launchableOnly"    # Z
    .param p6, "source"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/pm/PackageManager;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lcom/getcapacitor/JSObject;",
            ">;",
            "Ljava/lang/String;",
            "ZZ",
            "Ljava/lang/String;",
            ")Z"
        }
    .end annotation

    .line 506
    .local p2, "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    move-object v1, p1

    move-object/from16 v2, p3

    const/4 v3, 0x0

    if-eqz v2, :cond_6

    invoke-virtual/range {p3 .. p3}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_6

    invoke-interface/range {p2 .. p3}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    move-object v4, p0

    move-object/from16 v12, p2

    move-object/from16 v13, p6

    goto/16 :goto_4

    .line 508
    :cond_0
    move-object v4, p0

    :try_start_0
    invoke-direct {p0, p1, v2}, Lcom/forge/live/AppsBridgePlugin;->getApplicationInfo(Landroid/content/pm/PackageManager;Ljava/lang/String;)Landroid/content/pm/ApplicationInfo;

    move-result-object v0

    move-object v5, v0

    .line 509
    .local v5, "ai":Landroid/content/pm/ApplicationInfo;
    invoke-static {v5}, Lcom/forge/live/AppsBridgePlugin;->isSystemApp(Landroid/content/pm/ApplicationInfo;)Z

    move-result v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_3

    move v6, v0

    .line 510
    .local v6, "system":Z
    if-nez p4, :cond_1

    if-eqz v6, :cond_1

    return v3

    .line 511
    :cond_1
    const/4 v7, 0x0

    .line 512
    .local v7, "launch":Landroid/content/Intent;
    :try_start_1
    invoke-virtual {p1, v2}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v0
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    move-object v7, v0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 513
    :goto_0
    const/4 v0, 0x1

    if-eqz v7, :cond_2

    const/4 v8, 0x1

    goto :goto_1

    :cond_2
    const/4 v8, 0x0

    .line 514
    .local v8, "launchable":Z
    :goto_1
    if-eqz p5, :cond_3

    if-nez v8, :cond_3

    return v3

    .line 515
    :cond_3
    :try_start_2
    invoke-virtual {p1, v5}, Landroid/content/pm/PackageManager;->getApplicationLabel(Landroid/content/pm/ApplicationInfo;)Ljava/lang/CharSequence;

    move-result-object v9

    .line 516
    .local v9, "labelCs":Ljava/lang/CharSequence;
    if-eqz v9, :cond_4

    invoke-interface {v9}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;

    move-result-object v10

    goto :goto_2

    :cond_4
    move-object v10, v2

    .line 517
    .local v10, "label":Ljava/lang/String;
    :goto_2
    invoke-static {v2, v10, v6, v8}, Lcom/forge/live/AppsBridgePlugin;->baseAppRow(Ljava/lang/String;Ljava/lang/String;ZZ)Lcom/getcapacitor/JSObject;

    move-result-object v11

    .line 518
    .local v11, "row":Lcom/getcapacitor/JSObject;
    if-eqz v7, :cond_5

    invoke-virtual {v7}, Landroid/content/Intent;->getComponent()Landroid/content/ComponentName;

    move-result-object v12

    if-eqz v12, :cond_5

    .line 519
    const-string v12, "activity"

    invoke-virtual {v7}, Landroid/content/Intent;->getComponent()Landroid/content/ComponentName;

    move-result-object v13

    invoke-virtual {v13}, Landroid/content/ComponentName;->getClassName()Ljava/lang/String;

    move-result-object v13

    invoke-virtual {v11, v12, v13}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 521
    :cond_5
    const-string v12, "source"
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_3

    move-object/from16 v13, p6

    :try_start_3
    invoke-virtual {v11, v12, v13}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_2

    .line 522
    move-object/from16 v12, p2

    :try_start_4
    invoke-interface {v12, v2, v11}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_1

    .line 523
    return v0

    .line 524
    .end local v5    # "ai":Landroid/content/pm/ApplicationInfo;
    .end local v6    # "system":Z
    .end local v7    # "launch":Landroid/content/Intent;
    .end local v8    # "launchable":Z
    .end local v9    # "labelCs":Ljava/lang/CharSequence;
    .end local v10    # "label":Ljava/lang/String;
    .end local v11    # "row":Lcom/getcapacitor/JSObject;
    :catch_1
    move-exception v0

    goto :goto_3

    :catch_2
    move-exception v0

    move-object/from16 v12, p2

    goto :goto_3

    :catch_3
    move-exception v0

    move-object/from16 v12, p2

    move-object/from16 v13, p6

    .line 525
    .local v0, "e":Ljava/lang/Exception;
    :goto_3
    return v3

    .line 506
    .end local v0    # "e":Ljava/lang/Exception;
    :cond_6
    move-object v4, p0

    move-object/from16 v12, p2

    move-object/from16 v13, p6

    :goto_4
    return v3
.end method

.method private static baseAppRow(Ljava/lang/String;Ljava/lang/String;ZZ)Lcom/getcapacitor/JSObject;
    .locals 2
    .param p0, "pkg"    # Ljava/lang/String;
    .param p1, "label"    # Ljava/lang/String;
    .param p2, "system"    # Z
    .param p3, "launchable"    # Z

    .line 530
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 531
    .local v0, "row":Lcom/getcapacitor/JSObject;
    const-string v1, "packageName"

    invoke-virtual {v0, v1, p0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 532
    const-string v1, "label"

    invoke-virtual {v0, v1, p1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 533
    const-string v1, "name"

    invoke-virtual {v0, v1, p1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 534
    const-string v1, "system"

    invoke-virtual {v0, v1, p2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 535
    const-string v1, "launchable"

    invoke-virtual {v0, v1, p3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 536
    return-object v0
.end method

.method private buildIntent(Lcom/getcapacitor/PluginCall;)Landroid/content/Intent;
    .locals 13
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 555
    const-string v0, "action"

    const/4 v1, 0x0

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 556
    .local v0, "action":Ljava/lang/String;
    const-string v2, "data"

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 557
    .local v2, "data":Ljava/lang/String;
    if-nez v2, :cond_0

    const-string v3, "uri"

    invoke-virtual {p1, v3, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 558
    :cond_0
    if-nez v2, :cond_1

    const-string v3, "url"

    invoke-virtual {p1, v3, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 559
    :cond_1
    const-string v3, "type"

    invoke-virtual {p1, v3, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 560
    .local v3, "type":Ljava/lang/String;
    if-nez v3, :cond_2

    const-string v4, "mime"

    invoke-virtual {p1, v4, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 561
    :cond_2
    invoke-direct {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->packageNameOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v4

    .line 562
    .local v4, "pkg":Ljava/lang/String;
    invoke-direct {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->activityOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v5

    .line 563
    .local v5, "activity":Ljava/lang/String;
    const-string v6, "component"

    invoke-virtual {p1, v6, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-static {v6}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    .line 565
    .local v6, "component":Ljava/lang/String;
    if-nez v0, :cond_6

    .line 566
    if-eqz v2, :cond_3

    const-string v0, "android.intent.action.VIEW"

    goto :goto_1

    .line 567
    :cond_3
    if-nez v4, :cond_5

    if-nez v5, :cond_5

    if-eqz v6, :cond_4

    goto :goto_0

    .line 568
    :cond_4
    const-string v0, "android.intent.action.VIEW"

    goto :goto_1

    .line 567
    :cond_5
    :goto_0
    const-string v0, "android.intent.action.MAIN"

    .line 571
    :cond_6
    :goto_1
    new-instance v7, Landroid/content/Intent;

    invoke-direct {v7, v0}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 572
    .local v7, "intent":Landroid/content/Intent;
    if-eqz v2, :cond_7

    if-eqz v3, :cond_7

    .line 573
    invoke-static {v2}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v8

    invoke-virtual {v7, v8, v3}, Landroid/content/Intent;->setDataAndType(Landroid/net/Uri;Ljava/lang/String;)Landroid/content/Intent;

    goto :goto_2

    .line 574
    :cond_7
    if-eqz v2, :cond_8

    .line 575
    invoke-static {v2}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v8

    invoke-virtual {v7, v8}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    goto :goto_2

    .line 576
    :cond_8
    if-eqz v3, :cond_9

    .line 577
    invoke-virtual {v7, v3}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    .line 580
    :cond_9
    :goto_2
    const-string v8, "categories"

    invoke-virtual {p1, v8}, Lcom/getcapacitor/PluginCall;->getArray(Ljava/lang/String;)Lcom/getcapacitor/JSArray;

    move-result-object v8

    .line 581
    .local v8, "cats":Lcom/getcapacitor/JSArray;
    if-eqz v8, :cond_c

    .line 582
    const/4 v9, 0x0

    .local v9, "i":I
    :goto_3
    invoke-virtual {v8}, Lcom/getcapacitor/JSArray;->length()I

    move-result v10

    if-ge v9, v10, :cond_b

    .line 583
    invoke-virtual {v8, v9, v1}, Lcom/getcapacitor/JSArray;->optString(ILjava/lang/String;)Ljava/lang/String;

    move-result-object v10

    .line 584
    .local v10, "c":Ljava/lang/String;
    if-eqz v10, :cond_a

    invoke-virtual {v10}, Ljava/lang/String;->isEmpty()Z

    move-result v11

    if-nez v11, :cond_a

    invoke-virtual {v7, v10}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;

    .line 582
    .end local v10    # "c":Ljava/lang/String;
    :cond_a
    add-int/lit8 v9, v9, 0x1

    goto :goto_3

    .end local v9    # "i":I
    :cond_b
    goto :goto_4

    .line 586
    :cond_c
    const-string v9, "android.intent.action.MAIN"

    invoke-virtual {v9, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_d

    if-nez v5, :cond_d

    if-nez v6, :cond_d

    if-nez v2, :cond_d

    .line 587
    const-string v9, "android.intent.category.LAUNCHER"

    invoke-virtual {v7, v9}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;

    .line 590
    :cond_d
    :goto_4
    if-eqz v6, :cond_f

    .line 591
    invoke-static {v6, v4}, Lcom/forge/live/AppsBridgePlugin;->parseComponent(Ljava/lang/String;Ljava/lang/String;)Landroid/content/ComponentName;

    move-result-object v9

    .line 592
    .local v9, "cn":Landroid/content/ComponentName;
    if-eqz v9, :cond_e

    invoke-virtual {v7, v9}, Landroid/content/Intent;->setComponent(Landroid/content/ComponentName;)Landroid/content/Intent;

    .line 593
    .end local v9    # "cn":Landroid/content/ComponentName;
    :cond_e
    goto :goto_5

    :cond_f
    if-eqz v4, :cond_10

    if-eqz v5, :cond_10

    .line 594
    invoke-virtual {v7, v4, v5}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    goto :goto_5

    .line 595
    :cond_10
    if-eqz v4, :cond_11

    .line 596
    invoke-virtual {v7, v4}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;

    .line 599
    :cond_11
    :goto_5
    const-string v9, "extras"

    invoke-virtual {p1, v9, v1}, Lcom/getcapacitor/PluginCall;->getObject(Ljava/lang/String;Lcom/getcapacitor/JSObject;)Lcom/getcapacitor/JSObject;

    move-result-object v9

    .line 600
    .local v9, "extras":Lcom/getcapacitor/JSObject;
    if-nez v9, :cond_12

    const-string v10, "extra"

    invoke-virtual {p1, v10, v1}, Lcom/getcapacitor/PluginCall;->getObject(Ljava/lang/String;Lcom/getcapacitor/JSObject;)Lcom/getcapacitor/JSObject;

    move-result-object v9

    .line 601
    :cond_12
    if-eqz v9, :cond_13

    invoke-direct {p0, v7, v9}, Lcom/forge/live/AppsBridgePlugin;->putExtras(Landroid/content/Intent;Lcom/getcapacitor/JSObject;)V

    .line 603
    :cond_13
    const-string v10, "text"

    invoke-virtual {p1, v10, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v10

    .line 604
    .local v10, "text":Ljava/lang/String;
    if-eqz v10, :cond_14

    const-string v11, "android.intent.extra.TEXT"

    invoke-virtual {v7, v11, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 605
    :cond_14
    const-string v11, "subject"

    invoke-virtual {p1, v11, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    .line 606
    .local v11, "subject":Ljava/lang/String;
    if-eqz v11, :cond_15

    const-string v12, "android.intent.extra.SUBJECT"

    invoke-virtual {v7, v12, v11}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 607
    :cond_15
    const-string v12, "title"

    invoke-virtual {p1, v12, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 608
    .local v1, "title":Ljava/lang/String;
    if-eqz v1, :cond_16

    const-string v12, "android.intent.extra.TITLE"

    invoke-virtual {v7, v12, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 610
    :cond_16
    return-object v7
.end method

.method private static clampLimit(Ljava/lang/Integer;)I
    .locals 2
    .param p0, "n"    # Ljava/lang/Integer;

    .line 806
    if-eqz p0, :cond_1

    invoke-virtual {p0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    const/4 v1, 0x1

    if-ge v0, v1, :cond_0

    goto :goto_0

    .line 807
    :cond_0
    invoke-virtual {p0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    const/16 v1, 0x7d0

    invoke-static {v0, v1}, Ljava/lang/Math;->min(II)I

    move-result v0

    return v0

    .line 806
    :cond_1
    :goto_0
    const/16 v0, 0x190

    return v0
.end method

.method private getApplicationInfo(Landroid/content/pm/PackageManager;Ljava/lang/String;)Landroid/content/pm/ApplicationInfo;
    .locals 2
    .param p1, "pm"    # Landroid/content/pm/PackageManager;
    .param p2, "pkg"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/content/pm/PackageManager$NameNotFoundException;
        }
    .end annotation

    .line 713
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    if-lt v0, v1, :cond_0

    .line 714
    const-wide/16 v0, 0x0

    invoke-static {v0, v1}, Landroid/content/pm/PackageManager$ApplicationInfoFlags;->of(J)Landroid/content/pm/PackageManager$ApplicationInfoFlags;

    move-result-object v0

    invoke-virtual {p1, p2, v0}, Landroid/content/pm/PackageManager;->getApplicationInfo(Ljava/lang/String;Landroid/content/pm/PackageManager$ApplicationInfoFlags;)Landroid/content/pm/ApplicationInfo;

    move-result-object v0

    return-object v0

    .line 717
    :cond_0
    const/4 v0, 0x0

    invoke-virtual {p1, p2, v0}, Landroid/content/pm/PackageManager;->getApplicationInfo(Ljava/lang/String;I)Landroid/content/pm/ApplicationInfo;

    move-result-object v0

    return-object v0
.end method

.method private getInstalledApplications(Landroid/content/pm/PackageManager;)Ljava/util/List;
    .locals 2
    .param p1, "pm"    # Landroid/content/pm/PackageManager;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/pm/PackageManager;",
            ")",
            "Ljava/util/List<",
            "Landroid/content/pm/ApplicationInfo;",
            ">;"
        }
    .end annotation

    .line 701
    :try_start_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    if-lt v0, v1, :cond_0

    .line 702
    const-wide/16 v0, 0x0

    invoke-static {v0, v1}, Landroid/content/pm/PackageManager$ApplicationInfoFlags;->of(J)Landroid/content/pm/PackageManager$ApplicationInfoFlags;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroid/content/pm/PackageManager;->getInstalledApplications(Landroid/content/pm/PackageManager$ApplicationInfoFlags;)Ljava/util/List;

    move-result-object v0

    return-object v0

    .line 705
    :cond_0
    const/4 v0, 0x0

    invoke-virtual {p1, v0}, Landroid/content/pm/PackageManager;->getInstalledApplications(I)Ljava/util/List;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object v0

    .line 706
    :catch_0
    move-exception v0

    .line 707
    .local v0, "e":Ljava/lang/Exception;
    invoke-static {}, Ljava/util/Collections;->emptyList()Ljava/util/List;

    move-result-object v1

    return-object v1
.end method

.method private getPackageInfo(Landroid/content/pm/PackageManager;Ljava/lang/String;I)Landroid/content/pm/PackageInfo;
    .locals 2
    .param p1, "pm"    # Landroid/content/pm/PackageManager;
    .param p2, "pkg"    # Ljava/lang/String;
    .param p3, "flags"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/content/pm/PackageManager$NameNotFoundException;
        }
    .end annotation

    .line 722
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    if-lt v0, v1, :cond_0

    .line 723
    int-to-long v0, p3

    invoke-static {v0, v1}, Landroid/content/pm/PackageManager$PackageInfoFlags;->of(J)Landroid/content/pm/PackageManager$PackageInfoFlags;

    move-result-object v0

    invoke-virtual {p1, p2, v0}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;Landroid/content/pm/PackageManager$PackageInfoFlags;)Landroid/content/pm/PackageInfo;

    move-result-object v0

    return-object v0

    .line 726
    :cond_0
    invoke-virtual {p1, p2, p3}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v0

    return-object v0
.end method

.method private hasQueryAllPackages()Z
    .locals 5

    .line 777
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    const/4 v2, 0x1

    if-ge v0, v1, :cond_0

    return v2

    .line 779
    :cond_0
    const/4 v0, 0x0

    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/AppsBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v1

    const-string v3, "android.permission.QUERY_ALL_PACKAGES"

    .line 781
    invoke-virtual {p0}, Lcom/forge/live/AppsBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-virtual {v4}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v4

    .line 780
    invoke-virtual {v1, v3, v4}, Landroid/content/pm/PackageManager;->checkPermission(Ljava/lang/String;Ljava/lang/String;)I

    move-result v1
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    if-nez v1, :cond_1

    goto :goto_0

    :cond_1
    const/4 v2, 0x0

    .line 779
    :goto_0
    return v2

    .line 783
    :catch_0
    move-exception v1

    .line 784
    .local v1, "e":Ljava/lang/Exception;
    return v0
.end method

.method private static isSystemApp(Landroid/content/pm/ApplicationInfo;)Z
    .locals 3
    .param p0, "ai"    # Landroid/content/pm/ApplicationInfo;

    .line 789
    const/4 v0, 0x0

    if-nez p0, :cond_0

    return v0

    .line 790
    :cond_0
    iget v1, p0, Landroid/content/pm/ApplicationInfo;->flags:I

    const/4 v2, 0x1

    and-int/2addr v1, v2

    if-eqz v1, :cond_1

    const/4 v0, 0x1

    :cond_1
    return v0
.end method

.method static synthetic lambda$listActivities$1(Lcom/getcapacitor/JSObject;)Ljava/lang/String;
    .locals 2
    .param p0, "a"    # Lcom/getcapacitor/JSObject;

    .line 277
    const-string v0, "label"

    invoke-virtual {p0, v0}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 278
    .local v0, "l":Ljava/lang/String;
    if-eqz v0, :cond_0

    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-virtual {v0, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v1

    goto :goto_0

    :cond_0
    const-string v1, ""

    :goto_0
    return-object v1
.end method

.method static synthetic lambda$listApps$0(Lcom/getcapacitor/JSObject;Lcom/getcapacitor/JSObject;)I
    .locals 3
    .param p0, "a"    # Lcom/getcapacitor/JSObject;
    .param p1, "b"    # Lcom/getcapacitor/JSObject;

    .line 149
    const-string v0, "label"

    invoke-virtual {p0, v0}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 150
    .local v1, "la":Ljava/lang/String;
    invoke-virtual {p1, v0}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 151
    .local v0, "lb":Ljava/lang/String;
    if-nez v1, :cond_0

    const-string v1, ""

    .line 152
    :cond_0
    if-nez v0, :cond_1

    const-string v0, ""

    .line 153
    :cond_1
    invoke-virtual {v1, v0}, Ljava/lang/String;->compareToIgnoreCase(Ljava/lang/String;)I

    move-result v2

    return v2
.end method

.method private static matchesQuery(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z
    .locals 2
    .param p0, "query"    # Ljava/lang/String;
    .param p1, "label"    # Ljava/lang/String;
    .param p2, "pkg"    # Ljava/lang/String;

    .line 794
    sget-object v0, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-virtual {p0, v0}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v0

    .line 795
    .local v0, "q":Ljava/lang/String;
    if-eqz p1, :cond_0

    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-virtual {p1, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-nez v1, :cond_1

    :cond_0
    if-eqz p2, :cond_2

    sget-object v1, Ljava/util/Locale;->US:Ljava/util/Locale;

    .line 796
    invoke-virtual {p2, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_2

    :cond_1
    const/4 v1, 0x1

    goto :goto_0

    :cond_2
    const/4 v1, 0x0

    .line 795
    :goto_0
    return v1
.end method

.method private static norm(Ljava/lang/String;)Ljava/lang/String;
    .locals 3
    .param p0, "s"    # Ljava/lang/String;

    .line 800
    const/4 v0, 0x0

    if-nez p0, :cond_0

    return-object v0

    .line 801
    :cond_0
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    .line 802
    .local v1, "t":Ljava/lang/String;
    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_1

    goto :goto_0

    :cond_1
    move-object v0, v1

    :goto_0
    return-object v0
.end method

.method private packageNameOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;

    .line 746
    const-string v0, "packageName"

    const/4 v1, 0x0

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 747
    .local v0, "pkg":Ljava/lang/String;
    if-nez v0, :cond_0

    const-string v2, "package"

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 748
    :cond_0
    if-nez v0, :cond_1

    const-string v2, "pkg"

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 749
    :cond_1
    if-nez v0, :cond_2

    .line 750
    const-string v2, "component"

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 751
    .local v1, "component":Ljava/lang/String;
    if-eqz v1, :cond_2

    const-string v2, "/"

    invoke-virtual {v1, v2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v3

    if-eqz v3, :cond_2

    .line 752
    const/4 v3, 0x2

    invoke-virtual {v1, v2, v3}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;

    move-result-object v2

    const/4 v3, 0x0

    aget-object v2, v2, v3

    invoke-static {v2}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 755
    .end local v1    # "component":Ljava/lang/String;
    :cond_2
    return-object v0
.end method

.method private static parseComponent(Ljava/lang/String;Ljava/lang/String;)Landroid/content/ComponentName;
    .locals 4
    .param p0, "component"    # Ljava/lang/String;
    .param p1, "defaultPkg"    # Ljava/lang/String;

    .line 730
    if-eqz p0, :cond_5

    invoke-virtual {p0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_1

    .line 731
    :cond_0
    const-string v0, "/"

    invoke-virtual {p0, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    const-string v2, "."

    if-eqz v1, :cond_2

    .line 732
    const/4 v1, 0x2

    invoke-virtual {p0, v0, v1}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;

    move-result-object v0

    .line 733
    .local v0, "parts":[Ljava/lang/String;
    const/4 v1, 0x0

    aget-object v1, v0, v1

    .line 734
    .local v1, "p":Ljava/lang/String;
    const/4 v3, 0x1

    aget-object v3, v0, v3

    .line 735
    .local v3, "c":Ljava/lang/String;
    invoke-virtual {v3, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 736
    :cond_1
    new-instance v2, Landroid/content/ComponentName;

    invoke-direct {v2, v1, v3}, Landroid/content/ComponentName;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    return-object v2

    .line 738
    .end local v0    # "parts":[Ljava/lang/String;
    .end local v1    # "p":Ljava/lang/String;
    .end local v3    # "c":Ljava/lang/String;
    :cond_2
    if-eqz p1, :cond_4

    .line 739
    invoke-virtual {p0, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_3

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    goto :goto_0

    :cond_3
    move-object v0, p0

    .line 740
    .local v0, "c":Ljava/lang/String;
    :goto_0
    new-instance v1, Landroid/content/ComponentName;

    invoke-direct {v1, p1, v0}, Landroid/content/ComponentName;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    return-object v1

    .line 742
    .end local v0    # "c":Ljava/lang/String;
    :cond_4
    invoke-static {p0}, Landroid/content/ComponentName;->unflattenFromString(Ljava/lang/String;)Landroid/content/ComponentName;

    move-result-object v0

    return-object v0

    .line 730
    :cond_5
    :goto_1
    const/4 v0, 0x0

    return-object v0
.end method

.method private putExtraValue(Landroid/content/Intent;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 9
    .param p1, "intent"    # Landroid/content/Intent;
    .param p2, "key"    # Ljava/lang/String;
    .param p3, "val"    # Ljava/lang/Object;

    .line 626
    const/4 v0, 0x0

    if-eqz p3, :cond_14

    sget-object v1, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;

    if-ne p3, v1, :cond_0

    goto/16 :goto_6

    .line 630
    :cond_0
    instance-of v1, p3, Ljava/lang/Boolean;

    if-eqz v1, :cond_1

    .line 631
    move-object v0, p3

    check-cast v0, Ljava/lang/Boolean;

    invoke-virtual {p1, p2, v0}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/io/Serializable;)Landroid/content/Intent;

    goto/16 :goto_5

    .line 632
    :cond_1
    instance-of v1, p3, Ljava/lang/Integer;

    if-eqz v1, :cond_2

    .line 633
    move-object v0, p3

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {p1, p2, v0}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/io/Serializable;)Landroid/content/Intent;

    goto/16 :goto_5

    .line 634
    :cond_2
    instance-of v1, p3, Ljava/lang/Long;

    if-eqz v1, :cond_3

    .line 635
    move-object v0, p3

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {p1, p2, v0}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/io/Serializable;)Landroid/content/Intent;

    goto/16 :goto_5

    .line 636
    :cond_3
    instance-of v1, p3, Ljava/lang/Double;

    if-eqz v1, :cond_6

    .line 637
    move-object v0, p3

    check-cast v0, Ljava/lang/Double;

    invoke-virtual {v0}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v0

    .line 638
    .local v0, "d":D
    invoke-static {v0, v1}, Ljava/lang/Math;->rint(D)D

    move-result-wide v2

    cmpl-double v4, v0, v2

    if-nez v4, :cond_5

    invoke-static {v0, v1}, Ljava/lang/Double;->isInfinite(D)Z

    move-result v2

    if-nez v2, :cond_5

    .line 639
    double-to-long v2, v0

    .line 640
    .local v2, "l":J
    const-wide/32 v4, -0x80000000

    cmp-long v6, v2, v4

    if-ltz v6, :cond_4

    const-wide/32 v4, 0x7fffffff

    cmp-long v6, v2, v4

    if-gtz v6, :cond_4

    long-to-int v4, v2

    invoke-virtual {p1, p2, v4}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    goto :goto_0

    .line 641
    :cond_4
    invoke-virtual {p1, p2, v2, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;J)Landroid/content/Intent;

    .line 642
    .end local v2    # "l":J
    :goto_0
    goto :goto_1

    .line 643
    :cond_5
    invoke-virtual {p1, p2, v0, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;D)Landroid/content/Intent;

    .line 645
    .end local v0    # "d":D
    :goto_1
    goto/16 :goto_5

    :cond_6
    instance-of v1, p3, Ljava/lang/Float;

    if-eqz v1, :cond_7

    .line 646
    move-object v0, p3

    check-cast v0, Ljava/lang/Float;

    invoke-virtual {p1, p2, v0}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/io/Serializable;)Landroid/content/Intent;

    goto/16 :goto_5

    .line 647
    :cond_7
    instance-of v1, p3, Lorg/json/JSONArray;

    if-eqz v1, :cond_a

    .line 648
    move-object v0, p3

    check-cast v0, Lorg/json/JSONArray;

    .line 649
    .local v0, "arr":Lorg/json/JSONArray;
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 650
    .local v1, "list":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/String;>;"
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_2
    invoke-virtual {v0}, Lorg/json/JSONArray;->length()I

    move-result v3

    if-ge v2, v3, :cond_9

    .line 651
    invoke-virtual {v0, v2}, Lorg/json/JSONArray;->opt(I)Ljava/lang/Object;

    move-result-object v3

    .line 652
    .local v3, "o":Ljava/lang/Object;
    if-eqz v3, :cond_8

    sget-object v4, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;

    if-eq v3, v4, :cond_8

    invoke-static {v3}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v1, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 650
    .end local v3    # "o":Ljava/lang/Object;
    :cond_8
    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    .line 654
    .end local v2    # "i":I
    :cond_9
    invoke-virtual {p1, p2, v1}, Landroid/content/Intent;->putStringArrayListExtra(Ljava/lang/String;Ljava/util/ArrayList;)Landroid/content/Intent;

    .line 655
    .end local v0    # "arr":Lorg/json/JSONArray;
    .end local v1    # "list":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/String;>;"
    goto/16 :goto_5

    :cond_a
    instance-of v1, p3, Lorg/json/JSONObject;

    if-eqz v1, :cond_13

    .line 656
    new-instance v1, Landroid/os/Bundle;

    invoke-direct {v1}, Landroid/os/Bundle;-><init>()V

    .line 657
    .local v1, "b":Landroid/os/Bundle;
    move-object v2, p3

    check-cast v2, Lorg/json/JSONObject;

    .line 658
    .local v2, "o":Lorg/json/JSONObject;
    invoke-virtual {v2}, Lorg/json/JSONObject;->names()Lorg/json/JSONArray;

    move-result-object v3

    .line 659
    .local v3, "names":Lorg/json/JSONArray;
    if-eqz v3, :cond_12

    .line 660
    const/4 v4, 0x0

    .local v4, "i":I
    :goto_3
    invoke-virtual {v3}, Lorg/json/JSONArray;->length()I

    move-result v5

    if-ge v4, v5, :cond_12

    .line 661
    invoke-virtual {v3, v4, v0}, Lorg/json/JSONArray;->optString(ILjava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .line 662
    .local v5, "k":Ljava/lang/String;
    if-nez v5, :cond_b

    goto :goto_4

    .line 663
    :cond_b
    invoke-virtual {v2, v5}, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v6

    .line 664
    .local v6, "v":Ljava/lang/Object;
    if-eqz v6, :cond_11

    sget-object v7, Lorg/json/JSONObject;->NULL:Ljava/lang/Object;

    if-ne v6, v7, :cond_c

    goto :goto_4

    .line 665
    :cond_c
    instance-of v7, v6, Ljava/lang/Boolean;

    if-eqz v7, :cond_d

    move-object v7, v6

    check-cast v7, Ljava/lang/Boolean;

    invoke-virtual {v7}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v7

    invoke-virtual {v1, v5, v7}, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V

    goto :goto_4

    .line 666
    :cond_d
    instance-of v7, v6, Ljava/lang/Integer;

    if-eqz v7, :cond_e

    move-object v7, v6

    check-cast v7, Ljava/lang/Integer;

    invoke-virtual {v7}, Ljava/lang/Integer;->intValue()I

    move-result v7

    invoke-virtual {v1, v5, v7}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V

    goto :goto_4

    .line 667
    :cond_e
    instance-of v7, v6, Ljava/lang/Long;

    if-eqz v7, :cond_f

    move-object v7, v6

    check-cast v7, Ljava/lang/Long;

    invoke-virtual {v7}, Ljava/lang/Long;->longValue()J

    move-result-wide v7

    invoke-virtual {v1, v5, v7, v8}, Landroid/os/Bundle;->putLong(Ljava/lang/String;J)V

    goto :goto_4

    .line 668
    :cond_f
    instance-of v7, v6, Ljava/lang/Double;

    if-eqz v7, :cond_10

    move-object v7, v6

    check-cast v7, Ljava/lang/Double;

    invoke-virtual {v7}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v7

    invoke-virtual {v1, v5, v7, v8}, Landroid/os/Bundle;->putDouble(Ljava/lang/String;D)V

    goto :goto_4

    .line 669
    :cond_10
    invoke-static {v6}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v1, v5, v7}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V

    .line 660
    .end local v5    # "k":Ljava/lang/String;
    .end local v6    # "v":Ljava/lang/Object;
    :cond_11
    :goto_4
    add-int/lit8 v4, v4, 0x1

    goto :goto_3

    .line 672
    .end local v4    # "i":I
    :cond_12
    invoke-virtual {p1, p2, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Landroid/os/Bundle;)Landroid/content/Intent;

    .line 673
    .end local v1    # "b":Landroid/os/Bundle;
    .end local v2    # "o":Lorg/json/JSONObject;
    .end local v3    # "names":Lorg/json/JSONArray;
    goto :goto_5

    .line 674
    :cond_13
    invoke-static {p3}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, p2, v0}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 676
    :goto_5
    return-void

    .line 627
    :cond_14
    :goto_6
    move-object v1, v0

    check-cast v1, Ljava/lang/String;

    invoke-virtual {p1, p2, v0}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 628
    return-void
.end method

.method private putExtras(Landroid/content/Intent;Lcom/getcapacitor/JSObject;)V
    .locals 5
    .param p1, "intent"    # Landroid/content/Intent;
    .param p2, "extras"    # Lcom/getcapacitor/JSObject;

    .line 614
    if-nez p2, :cond_0

    return-void

    .line 615
    :cond_0
    move-object v0, p2

    .line 616
    .local v0, "raw":Lorg/json/JSONObject;
    invoke-virtual {v0}, Lorg/json/JSONObject;->names()Lorg/json/JSONArray;

    move-result-object v1

    .line 617
    .local v1, "names":Lorg/json/JSONArray;
    if-nez v1, :cond_1

    return-void

    .line 618
    :cond_1
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_0
    invoke-virtual {v1}, Lorg/json/JSONArray;->length()I

    move-result v3

    if-ge v2, v3, :cond_3

    .line 619
    const/4 v3, 0x0

    invoke-virtual {v1, v2, v3}, Lorg/json/JSONArray;->optString(ILjava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 620
    .local v3, "key":Ljava/lang/String;
    if-nez v3, :cond_2

    goto :goto_1

    .line 621
    :cond_2
    invoke-virtual {v0, v3}, Lorg/json/JSONObject;->opt(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v4

    invoke-direct {p0, p1, v3, v4}, Lcom/forge/live/AppsBridgePlugin;->putExtraValue(Landroid/content/Intent;Ljava/lang/String;Ljava/lang/Object;)V

    .line 618
    .end local v3    # "key":Ljava/lang/String;
    :goto_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 623
    .end local v2    # "i":I
    :cond_3
    return-void
.end method

.method private queryActivities(Landroid/content/pm/PackageManager;Landroid/content/Intent;)Ljava/util/List;
    .locals 4
    .param p1, "pm"    # Landroid/content/pm/PackageManager;
    .param p2, "intent"    # Landroid/content/Intent;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/pm/PackageManager;",
            "Landroid/content/Intent;",
            ")",
            "Ljava/util/List<",
            "Landroid/content/pm/ResolveInfo;",
            ">;"
        }
    .end annotation

    .line 680
    const/high16 v0, 0x20000

    .line 681
    .local v0, "flags":I
    const/16 v1, 0x21

    :try_start_0
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    if-lt v2, v1, :cond_0

    .line 682
    int-to-long v2, v0

    invoke-static {v2, v3}, Landroid/content/pm/PackageManager$ResolveInfoFlags;->of(J)Landroid/content/pm/PackageManager$ResolveInfoFlags;

    move-result-object v2

    invoke-virtual {p1, p2, v2}, Landroid/content/pm/PackageManager;->queryIntentActivities(Landroid/content/Intent;Landroid/content/pm/PackageManager$ResolveInfoFlags;)Ljava/util/List;

    move-result-object v1

    return-object v1

    .line 685
    :cond_0
    invoke-virtual {p1, p2, v0}, Landroid/content/pm/PackageManager;->queryIntentActivities(Landroid/content/Intent;I)Ljava/util/List;

    move-result-object v1
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object v1

    .line 686
    .end local v0    # "flags":I
    :catch_0
    move-exception v0

    .line 688
    .local v0, "e":Ljava/lang/Exception;
    :try_start_1
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    if-lt v2, v1, :cond_1

    .line 689
    const-wide/16 v1, 0x0

    invoke-static {v1, v2}, Landroid/content/pm/PackageManager$ResolveInfoFlags;->of(J)Landroid/content/pm/PackageManager$ResolveInfoFlags;

    move-result-object v1

    invoke-virtual {p1, p2, v1}, Landroid/content/pm/PackageManager;->queryIntentActivities(Landroid/content/Intent;Landroid/content/pm/PackageManager$ResolveInfoFlags;)Ljava/util/List;

    move-result-object v1

    return-object v1

    .line 692
    :cond_1
    const/4 v1, 0x0

    invoke-virtual {p1, p2, v1}, Landroid/content/pm/PackageManager;->queryIntentActivities(Landroid/content/Intent;I)Ljava/util/List;

    move-result-object v1
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    return-object v1

    .line 693
    :catch_1
    move-exception v1

    .line 694
    .local v1, "e2":Ljava/lang/Exception;
    invoke-static {}, Ljava/util/Collections;->emptyList()Ljava/util/List;

    move-result-object v2

    return-object v2
.end method

.method private static sendTextIntent()Landroid/content/Intent;
    .locals 3

    .line 546
    new-instance v0, Landroid/content/Intent;

    const-string v1, "android.intent.action.SEND"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 547
    .local v0, "i":Landroid/content/Intent;
    const-string v1, "text/plain"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    .line 548
    const-string v1, "android.intent.extra.TEXT"

    const-string v2, "hi"

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 549
    return-object v0
.end method

.method private static shortClass(Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    .param p0, "name"    # Ljava/lang/String;

    .line 811
    if-nez p0, :cond_0

    const-string v0, ""

    return-object v0

    .line 812
    :cond_0
    const/16 v0, 0x2e

    invoke-virtual {p0, v0}, Ljava/lang/String;->lastIndexOf(I)I

    move-result v0

    .line 813
    .local v0, "i":I
    if-ltz v0, :cond_1

    add-int/lit8 v1, v0, 0x1

    invoke-virtual {p0, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v1

    goto :goto_0

    :cond_1
    move-object v1, p0

    :goto_0
    return-object v1
.end method

.method private static toArray(Ljava/util/List;)Lcom/getcapacitor/JSArray;
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Lcom/getcapacitor/JSObject;",
            ">;)",
            "Lcom/getcapacitor/JSArray;"
        }
    .end annotation

    .line 817
    .local p0, "list":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    new-instance v0, Lcom/getcapacitor/JSArray;

    invoke-direct {v0}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 818
    .local v0, "arr":Lcom/getcapacitor/JSArray;
    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/getcapacitor/JSObject;

    .local v2, "o":Lcom/getcapacitor/JSObject;
    invoke-virtual {v0, v2}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    goto :goto_0

    .line 819
    .end local v2    # "o":Lcom/getcapacitor/JSObject;
    :cond_0
    return-object v0
.end method

.method private static viewIntent(Ljava/lang/String;)Landroid/content/Intent;
    .locals 2
    .param p0, "uri"    # Ljava/lang/String;

    .line 540
    new-instance v0, Landroid/content/Intent;

    const-string v1, "android.intent.action.VIEW"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 541
    .local v0, "i":Landroid/content/Intent;
    :try_start_0
    invoke-static {p0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v1

    .line 542
    :goto_0
    return-object v0
.end method


# virtual methods
.method public find(Lcom/getcapacitor/PluginCall;)V
    .locals 0
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 196
    invoke-virtual {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->listApps(Lcom/getcapacitor/PluginCall;)V

    .line 197
    return-void
.end method

.method public getApp(Lcom/getcapacitor/PluginCall;)V
    .locals 13
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 202
    const-string v0, "ok"

    const/4 v1, 0x0

    :try_start_0
    invoke-direct {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->packageNameOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v2

    .line 203
    .local v2, "pkg":Ljava/lang/String;
    if-nez v2, :cond_0

    .line 204
    const-string v3, "packageName required"

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 205
    return-void

    .line 207
    :cond_0
    invoke-virtual {p0}, Lcom/forge/live/AppsBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-virtual {v3}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v3

    .line 208
    .local v3, "pm":Landroid/content/pm/PackageManager;
    invoke-direct {p0, v3, v2}, Lcom/forge/live/AppsBridgePlugin;->getApplicationInfo(Landroid/content/pm/PackageManager;Ljava/lang/String;)Landroid/content/pm/ApplicationInfo;

    move-result-object v4

    .line 209
    .local v4, "ai":Landroid/content/pm/ApplicationInfo;
    invoke-virtual {v3, v4}, Landroid/content/pm/PackageManager;->getApplicationLabel(Landroid/content/pm/ApplicationInfo;)Ljava/lang/CharSequence;

    move-result-object v5

    .line 210
    .local v5, "labelCs":Ljava/lang/CharSequence;
    if-eqz v5, :cond_1

    invoke-interface {v5}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;

    move-result-object v6

    goto :goto_0

    :cond_1
    move-object v6, v2

    .line 211
    .local v6, "label":Ljava/lang/String;
    :goto_0
    invoke-virtual {v3, v2}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v7

    .line 212
    .local v7, "launch":Landroid/content/Intent;
    new-instance v8, Lcom/getcapacitor/JSObject;

    invoke-direct {v8}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 213
    .local v8, "row":Lcom/getcapacitor/JSObject;
    const/4 v9, 0x1

    invoke-virtual {v8, v0, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 214
    const-string v10, "packageName"

    invoke-virtual {v8, v10, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 215
    const-string v10, "label"

    invoke-virtual {v8, v10, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 216
    const-string v10, "name"

    invoke-virtual {v8, v10, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 217
    const-string v10, "system"

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->isSystemApp(Landroid/content/pm/ApplicationInfo;)Z

    move-result v11

    invoke-virtual {v8, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 218
    const-string v10, "launchable"

    if-eqz v7, :cond_2

    goto :goto_1

    :cond_2
    const/4 v9, 0x0

    :goto_1
    invoke-virtual {v8, v10, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 219
    if-eqz v7, :cond_3

    invoke-virtual {v7}, Landroid/content/Intent;->getComponent()Landroid/content/ComponentName;

    move-result-object v9

    if-eqz v9, :cond_3

    .line 220
    const-string v9, "activity"

    invoke-virtual {v7}, Landroid/content/Intent;->getComponent()Landroid/content/ComponentName;

    move-result-object v10

    invoke-virtual {v10}, Landroid/content/ComponentName;->getClassName()Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v8, v9, v10}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    :try_end_0
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_0 .. :try_end_0} :catch_2
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 223
    :cond_3
    :try_start_1
    invoke-direct {p0, v3, v2, v1}, Lcom/forge/live/AppsBridgePlugin;->getPackageInfo(Landroid/content/pm/PackageManager;Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v9

    .line 224
    .local v9, "pi":Landroid/content/pm/PackageInfo;
    const-string v10, "versionName"

    iget-object v11, v9, Landroid/content/pm/PackageInfo;->versionName:Ljava/lang/String;

    invoke-virtual {v8, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 225
    sget v10, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v11, 0x1c

    if-lt v10, v11, :cond_4

    .line 226
    invoke-virtual {v9}, Landroid/content/pm/PackageInfo;->getLongVersionCode()J

    move-result-wide v10

    goto :goto_2

    .line 227
    :cond_4
    iget v10, v9, Landroid/content/pm/PackageInfo;->versionCode:I

    int-to-long v10, v10

    :goto_2
    nop

    .line 228
    .local v10, "vc":J
    const-string v12, "versionCode"

    invoke-virtual {v8, v12, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_1 .. :try_end_1} :catch_2

    goto :goto_3

    .line 229
    .end local v9    # "pi":Landroid/content/pm/PackageInfo;
    .end local v10    # "vc":J
    :catch_0
    move-exception v9

    :goto_3
    nop

    .line 230
    :try_start_2
    invoke-virtual {p1, v8}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_2
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_2 .. :try_end_2} :catch_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    .end local v2    # "pkg":Ljava/lang/String;
    .end local v3    # "pm":Landroid/content/pm/PackageManager;
    .end local v4    # "ai":Landroid/content/pm/ApplicationInfo;
    .end local v5    # "labelCs":Ljava/lang/CharSequence;
    .end local v6    # "label":Ljava/lang/String;
    .end local v7    # "launch":Landroid/content/Intent;
    .end local v8    # "row":Lcom/getcapacitor/JSObject;
    goto :goto_4

    .line 236
    :catch_1
    move-exception v0

    .line 237
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "getApp failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    goto :goto_5

    .line 231
    .end local v0    # "e":Ljava/lang/Exception;
    :catch_2
    move-exception v2

    .line 232
    .local v2, "nf":Landroid/content/pm/PackageManager$NameNotFoundException;
    new-instance v3, Lcom/getcapacitor/JSObject;

    invoke-direct {v3}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 233
    .local v3, "ret":Lcom/getcapacitor/JSObject;
    invoke-virtual {v3, v0, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 234
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Package not found: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-direct {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->packageNameOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "error"

    invoke-virtual {v3, v1, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 235
    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 238
    .end local v2    # "nf":Landroid/content/pm/PackageManager$NameNotFoundException;
    .end local v3    # "ret":Lcom/getcapacitor/JSObject;
    :goto_4
    nop

    .line 239
    :goto_5
    return-void
.end method

.method public getCapabilities(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 104
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 105
    .local v0, "caps":Lcom/getcapacitor/JSObject;
    const-string v1, "apps"

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 106
    const-string v1, "listApps"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 107
    const-string v1, "listActivities"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 108
    const-string v1, "launch"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 109
    const-string v1, "resolve"

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 110
    const-string v1, "queryAllPackages"

    invoke-direct {p0}, Lcom/forge/live/AppsBridgePlugin;->hasQueryAllPackages()Z

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 111
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 112
    return-void
.end method

.method public launch(Lcom/getcapacitor/PluginCall;)V
    .locals 16
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 338
    move-object/from16 v1, p1

    const-string v0, "action"

    const-string v2, "data"

    const-string v3, "Open with"

    :try_start_0
    const-string v4, "chooser"

    const/4 v5, 0x0

    invoke-static {v5}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v6

    invoke-virtual {v1, v4, v6}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v4

    .line 339
    .local v4, "chooser":Z
    const-string v6, "chooserTitle"

    invoke-virtual {v1, v6, v3}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    .line 340
    .local v6, "chooserTitle":Ljava/lang/String;
    invoke-direct/range {p0 .. p1}, Lcom/forge/live/AppsBridgePlugin;->buildIntent(Lcom/getcapacitor/PluginCall;)Landroid/content/Intent;

    move-result-object v7

    .line 342
    .local v7, "intent":Landroid/content/Intent;
    invoke-direct/range {p0 .. p1}, Lcom/forge/live/AppsBridgePlugin;->packageNameOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v8

    .line 343
    .local v8, "pkg":Ljava/lang/String;
    invoke-direct/range {p0 .. p1}, Lcom/forge/live/AppsBridgePlugin;->activityOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v9

    .line 344
    .local v9, "activity":Ljava/lang/String;
    const/4 v10, 0x0

    invoke-virtual {v1, v2, v10}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-static {v11}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    .line 345
    .local v11, "data":Ljava/lang/String;
    if-nez v11, :cond_0

    const-string v12, "uri"

    invoke-virtual {v1, v12, v10}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v12

    invoke-static {v12}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v12

    move-object v11, v12

    .line 346
    :cond_0
    invoke-virtual {v1, v0, v10}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v12

    invoke-static {v12}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v12

    .line 347
    .local v12, "action":Ljava/lang/String;
    const/4 v13, 0x1

    if-eqz v8, :cond_2

    if-nez v9, :cond_2

    if-nez v11, :cond_2

    if-eqz v12, :cond_1

    const-string v14, "android.intent.action.MAIN"

    .line 348
    invoke-virtual {v14, v12}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_2

    :cond_1
    const/4 v5, 0x1

    goto :goto_0

    :cond_2
    nop

    .line 350
    .local v5, "onlyPkg":Z
    :goto_0
    if-eqz v5, :cond_4

    .line 351
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/AppsBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v14

    invoke-virtual {v14}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v14

    invoke-virtual {v14, v8}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v14

    .line 352
    .local v14, "launch":Landroid/content/Intent;
    if-nez v14, :cond_3

    .line 353
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "No launchable activity for "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 354
    return-void

    .line 356
    :cond_3
    move-object v7, v14

    .line 359
    .end local v14    # "launch":Landroid/content/Intent;
    :cond_4
    const/high16 v14, 0x10000000

    invoke-virtual {v7, v14}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 360
    const-string v15, "flags"

    invoke-virtual {v1, v15, v10}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v10

    .line 361
    .local v10, "flags":Ljava/lang/Integer;
    if-eqz v10, :cond_5

    invoke-virtual {v10}, Ljava/lang/Integer;->intValue()I

    move-result v15

    invoke-virtual {v7, v15}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 363
    :cond_5
    move-object v15, v7

    .line 364
    .local v15, "toStart":Landroid/content/Intent;
    if-eqz v4, :cond_7

    .line 365
    if-eqz v6, :cond_6

    move-object v3, v6

    :cond_6
    invoke-static {v7, v3}, Landroid/content/Intent;->createChooser(Landroid/content/Intent;Ljava/lang/CharSequence;)Landroid/content/Intent;

    move-result-object v3

    move-object v15, v3

    .line 366
    invoke-virtual {v15, v14}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 369
    :cond_7
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/AppsBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-virtual {v3, v15}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 371
    new-instance v3, Lcom/getcapacitor/JSObject;

    invoke-direct {v3}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 372
    .local v3, "ret":Lcom/getcapacitor/JSObject;
    const-string v14, "ok"

    invoke-virtual {v3, v14, v13}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 373
    const-string v14, "opened"

    invoke-virtual {v3, v14, v13}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 374
    const-string v14, "launched"

    invoke-virtual {v3, v14, v13}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 375
    if-eqz v8, :cond_8

    const-string v13, "packageName"

    invoke-virtual {v3, v13, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 376
    :cond_8
    if-eqz v9, :cond_9

    const-string v13, "activity"

    invoke-virtual {v3, v13, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 377
    :cond_9
    invoke-virtual {v15}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v13

    if-eqz v13, :cond_a

    invoke-virtual {v15}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v13

    invoke-virtual {v3, v0, v13}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 378
    :cond_a
    invoke-virtual {v15}, Landroid/content/Intent;->getDataString()Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_b

    invoke-virtual {v15}, Landroid/content/Intent;->getDataString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v3, v2, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 379
    :cond_b
    invoke-virtual {v1, v3}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Landroid/content/ActivityNotFoundException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .end local v3    # "ret":Lcom/getcapacitor/JSObject;
    .end local v4    # "chooser":Z
    .end local v5    # "onlyPkg":Z
    .end local v6    # "chooserTitle":Ljava/lang/String;
    .end local v7    # "intent":Landroid/content/Intent;
    .end local v8    # "pkg":Ljava/lang/String;
    .end local v9    # "activity":Ljava/lang/String;
    .end local v10    # "flags":Ljava/lang/Integer;
    .end local v11    # "data":Ljava/lang/String;
    .end local v12    # "action":Ljava/lang/String;
    .end local v15    # "toStart":Landroid/content/Intent;
    goto :goto_1

    .line 382
    :catch_0
    move-exception v0

    .line 383
    .local v0, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "launch failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    goto :goto_2

    .line 380
    .end local v0    # "e":Ljava/lang/Exception;
    :catch_1
    move-exception v0

    .line 381
    .local v0, "anf":Landroid/content/ActivityNotFoundException;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "No activity found to handle intent: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Landroid/content/ActivityNotFoundException;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 384
    .end local v0    # "anf":Landroid/content/ActivityNotFoundException;
    :goto_1
    nop

    .line 385
    :goto_2
    return-void
.end method

.method public listActivities(Lcom/getcapacitor/PluginCall;)V
    .locals 21
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 244
    move-object/from16 v1, p1

    :try_start_0
    invoke-direct/range {p0 .. p1}, Lcom/forge/live/AppsBridgePlugin;->packageNameOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v0

    .line 245
    .local v0, "pkg":Ljava/lang/String;
    if-nez v0, :cond_0

    .line 246
    const-string v2, "packageName required"

    invoke-virtual {v1, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 247
    return-void

    .line 249
    :cond_0
    const-string v2, "exportedOnly"

    const/4 v3, 0x0

    invoke-static {v3}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v4

    invoke-virtual {v1, v2, v4}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v2

    .line 250
    .local v2, "exportedOnly":Z
    const-string v4, "limit"

    const/16 v5, 0x190

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    invoke-virtual {v1, v4, v5}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v4

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->clampLimit(Ljava/lang/Integer;)I

    move-result v4

    .line 251
    .local v4, "limit":I
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/AppsBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v5

    invoke-virtual {v5}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v5

    .line 253
    .local v5, "pm":Landroid/content/pm/PackageManager;
    const/4 v6, 0x1

    move-object/from16 v7, p0

    invoke-direct {v7, v5, v0, v6}, Lcom/forge/live/AppsBridgePlugin;->getPackageInfo(Landroid/content/pm/PackageManager;Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v8

    .line 254
    .local v8, "pi":Landroid/content/pm/PackageInfo;
    new-instance v9, Ljava/util/ArrayList;

    invoke-direct {v9}, Ljava/util/ArrayList;-><init>()V

    .line 255
    .local v9, "acts":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    iget-object v10, v8, Landroid/content/pm/PackageInfo;->activities:[Landroid/content/pm/ActivityInfo;
    :try_end_0
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 256
    .local v10, "infos":[Landroid/content/pm/ActivityInfo;
    const-string v11, "packageName"

    const-string v12, "label"

    const-string v13, "name"

    if-eqz v10, :cond_7

    .line 257
    :try_start_1
    array-length v14, v10

    :goto_0
    if-ge v3, v14, :cond_6

    aget-object v15, v10, v3

    .line 258
    .local v15, "ai":Landroid/content/pm/ActivityInfo;
    if-nez v15, :cond_1

    move/from16 v16, v2

    move-object/from16 v17, v5

    move-object/from16 v18, v8

    goto/16 :goto_2

    .line 259
    :cond_1
    if-eqz v2, :cond_2

    iget-boolean v6, v15, Landroid/content/pm/ActivityInfo;->exported:Z

    if-nez v6, :cond_2

    move/from16 v16, v2

    move-object/from16 v17, v5

    move-object/from16 v18, v8

    goto/16 :goto_2

    .line 260
    :cond_2
    invoke-virtual {v15, v5}, Landroid/content/pm/ActivityInfo;->loadLabel(Landroid/content/pm/PackageManager;)Ljava/lang/CharSequence;

    move-result-object v6

    .line 261
    .local v6, "labelCs":Ljava/lang/CharSequence;
    if-eqz v6, :cond_3

    invoke-interface {v6}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;

    move-result-object v16

    move-object/from16 v20, v16

    move/from16 v16, v2

    move-object/from16 v2, v20

    goto :goto_1

    :cond_3
    move/from16 v16, v2

    .end local v2    # "exportedOnly":Z
    .local v16, "exportedOnly":Z
    iget-object v2, v15, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    .line 262
    .local v2, "label":Ljava/lang/String;
    :goto_1
    new-instance v17, Lcom/getcapacitor/JSObject;

    invoke-direct/range {v17 .. v17}, Lcom/getcapacitor/JSObject;-><init>()V

    move-object/from16 v18, v17

    .line 263
    .local v18, "row":Lcom/getcapacitor/JSObject;
    move-object/from16 v17, v5

    .end local v5    # "pm":Landroid/content/pm/PackageManager;
    .local v17, "pm":Landroid/content/pm/PackageManager;
    iget-object v5, v15, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    move-object/from16 v19, v6

    move-object/from16 v6, v18

    .end local v18    # "row":Lcom/getcapacitor/JSObject;
    .local v6, "row":Lcom/getcapacitor/JSObject;
    .local v19, "labelCs":Ljava/lang/CharSequence;
    invoke-virtual {v6, v13, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 264
    const-string v5, "className"

    iget-object v7, v15, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    invoke-virtual {v6, v5, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 265
    invoke-virtual {v6, v11, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 266
    const-string v5, "component"

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v7, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    move-object/from16 v18, v8

    .end local v8    # "pi":Landroid/content/pm/PackageInfo;
    .local v18, "pi":Landroid/content/pm/PackageInfo;
    const-string v8, "/"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget-object v8, v15, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v5, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 267
    invoke-virtual {v6, v12, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 268
    const-string v5, "exported"

    iget-boolean v7, v15, Landroid/content/pm/ActivityInfo;->exported:Z

    invoke-virtual {v6, v5, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 269
    const-string v5, "enabled"

    iget-boolean v7, v15, Landroid/content/pm/ActivityInfo;->enabled:Z

    invoke-virtual {v6, v5, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 270
    iget-object v5, v15, Landroid/content/pm/ActivityInfo;->permission:Ljava/lang/String;

    if-eqz v5, :cond_4

    const-string v5, "permission"

    iget-object v7, v15, Landroid/content/pm/ActivityInfo;->permission:Ljava/lang/String;

    invoke-virtual {v6, v5, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 271
    :cond_4
    invoke-interface {v9, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 272
    invoke-interface {v9}, Ljava/util/List;->size()I

    move-result v5

    if-lt v5, v4, :cond_5

    goto :goto_3

    .line 257
    .end local v2    # "label":Ljava/lang/String;
    .end local v6    # "row":Lcom/getcapacitor/JSObject;
    .end local v15    # "ai":Landroid/content/pm/ActivityInfo;
    .end local v19    # "labelCs":Ljava/lang/CharSequence;
    :cond_5
    :goto_2
    add-int/lit8 v3, v3, 0x1

    move-object/from16 v7, p0

    move/from16 v2, v16

    move-object/from16 v5, v17

    move-object/from16 v8, v18

    const/4 v6, 0x1

    goto/16 :goto_0

    .end local v16    # "exportedOnly":Z
    .end local v17    # "pm":Landroid/content/pm/PackageManager;
    .end local v18    # "pi":Landroid/content/pm/PackageInfo;
    .local v2, "exportedOnly":Z
    .restart local v5    # "pm":Landroid/content/pm/PackageManager;
    .restart local v8    # "pi":Landroid/content/pm/PackageInfo;
    :cond_6
    move/from16 v16, v2

    move-object/from16 v17, v5

    move-object/from16 v18, v8

    .end local v2    # "exportedOnly":Z
    .end local v5    # "pm":Landroid/content/pm/PackageManager;
    .end local v8    # "pi":Landroid/content/pm/PackageInfo;
    .restart local v16    # "exportedOnly":Z
    .restart local v17    # "pm":Landroid/content/pm/PackageManager;
    .restart local v18    # "pi":Landroid/content/pm/PackageInfo;
    goto :goto_3

    .line 256
    .end local v16    # "exportedOnly":Z
    .end local v17    # "pm":Landroid/content/pm/PackageManager;
    .end local v18    # "pi":Landroid/content/pm/PackageInfo;
    .restart local v2    # "exportedOnly":Z
    .restart local v5    # "pm":Landroid/content/pm/PackageManager;
    .restart local v8    # "pi":Landroid/content/pm/PackageInfo;
    :cond_7
    move/from16 v16, v2

    move-object/from16 v17, v5

    move-object/from16 v18, v8

    .line 276
    .end local v2    # "exportedOnly":Z
    .end local v5    # "pm":Landroid/content/pm/PackageManager;
    .end local v8    # "pi":Landroid/content/pm/PackageInfo;
    .restart local v16    # "exportedOnly":Z
    .restart local v17    # "pm":Landroid/content/pm/PackageManager;
    .restart local v18    # "pi":Landroid/content/pm/PackageInfo;
    :goto_3
    new-instance v2, Lcom/forge/live/AppsBridgePlugin$$ExternalSyntheticLambda0;

    invoke-direct {v2}, Lcom/forge/live/AppsBridgePlugin$$ExternalSyntheticLambda0;-><init>()V

    invoke-static {v2}, Ljava/util/Comparator;->comparing(Ljava/util/function/Function;)Ljava/util/Comparator;

    move-result-object v2

    invoke-static {v9, v2}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 281
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 282
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    const-string v3, "ok"

    const/4 v5, 0x1

    invoke-virtual {v2, v3, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 283
    invoke-virtual {v2, v11, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 284
    const-string v3, "count"

    invoke-interface {v9}, Ljava/util/List;->size()I

    move-result v5

    invoke-virtual {v2, v3, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 285
    const-string v3, "activities"

    invoke-static {v9}, Lcom/forge/live/AppsBridgePlugin;->toArray(Ljava/util/List;)Lcom/getcapacitor/JSArray;

    move-result-object v5

    invoke-virtual {v2, v3, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 286
    new-instance v3, Lcom/getcapacitor/JSArray;

    invoke-direct {v3}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 287
    .local v3, "options":Lcom/getcapacitor/JSArray;
    invoke-interface {v9}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v5

    :goto_4
    invoke-interface {v5}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_8

    invoke-interface {v5}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Lcom/getcapacitor/JSObject;

    .line 288
    .local v6, "a":Lcom/getcapacitor/JSObject;
    new-instance v7, Lcom/getcapacitor/JSObject;

    invoke-direct {v7}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 289
    .local v7, "opt":Lcom/getcapacitor/JSObject;
    const-string v8, "value"

    invoke-virtual {v6, v13}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v7, v8, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 290
    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v12}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v8, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v11, " ("

    invoke-virtual {v8, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v6, v13}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-static {v11}, Lcom/forge/live/AppsBridgePlugin;->shortClass(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v8, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v11, ")"

    invoke-virtual {v8, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v12, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 291
    invoke-virtual {v3, v7}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 292
    nop

    .end local v6    # "a":Lcom/getcapacitor/JSObject;
    .end local v7    # "opt":Lcom/getcapacitor/JSObject;
    goto :goto_4

    .line 293
    :cond_8
    const-string v5, "options"

    invoke-virtual {v2, v5, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 294
    invoke-virtual {v1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_1
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_1 .. :try_end_1} :catch_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .end local v0    # "pkg":Ljava/lang/String;
    .end local v2    # "ret":Lcom/getcapacitor/JSObject;
    .end local v3    # "options":Lcom/getcapacitor/JSArray;
    .end local v4    # "limit":I
    .end local v9    # "acts":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    .end local v10    # "infos":[Landroid/content/pm/ActivityInfo;
    .end local v16    # "exportedOnly":Z
    .end local v17    # "pm":Landroid/content/pm/PackageManager;
    .end local v18    # "pi":Landroid/content/pm/PackageInfo;
    goto :goto_5

    .line 297
    :catch_0
    move-exception v0

    .line 298
    .local v0, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "listActivities failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    goto :goto_6

    .line 295
    .end local v0    # "e":Ljava/lang/Exception;
    :catch_1
    move-exception v0

    .line 296
    .local v0, "nf":Landroid/content/pm/PackageManager$NameNotFoundException;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Package not found: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-direct/range {p0 .. p1}, Lcom/forge/live/AppsBridgePlugin;->packageNameOf(Lcom/getcapacitor/PluginCall;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 299
    .end local v0    # "nf":Landroid/content/pm/PackageManager$NameNotFoundException;
    :goto_5
    nop

    .line 300
    :goto_6
    return-void
.end method

.method public listApps(Lcom/getcapacitor/PluginCall;)V
    .locals 25
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 117
    move-object/from16 v8, p0

    move-object/from16 v9, p1

    :try_start_0
    const-string v0, "query"

    const/4 v1, 0x0

    invoke-virtual {v9, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 118
    .local v0, "query":Ljava/lang/String;
    if-nez v0, :cond_0

    const-string v2, "q"

    invoke-virtual {v9, v2, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/forge/live/AppsBridgePlugin;->norm(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    move-object v0, v1

    .line 119
    :cond_0
    const-string v1, "launchableOnly"

    const/4 v10, 0x1

    invoke-static {v10}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v9, v1, v2}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1

    move v11, v1

    .line 120
    .local v11, "launchableOnly":Z
    const-string v1, "includeSystem"

    invoke-static {v10}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v9, v1, v2}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1

    move v12, v1

    .line 121
    .local v12, "includeSystem":Z
    const-string v1, "probeKnown"

    invoke-static {v10}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v9, v1, v2}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1

    move v13, v1

    .line 122
    .local v13, "probeKnown":Z
    const-string v1, "limit"

    const/16 v2, 0x190

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v9, v1, v2}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v1}, Lcom/forge/live/AppsBridgePlugin;->clampLimit(Ljava/lang/Integer;)I

    move-result v1

    move v14, v1

    .line 124
    .local v14, "limit":I
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/AppsBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v1

    move-object v15, v1

    .line 125
    .local v15, "pm":Landroid/content/pm/PackageManager;
    new-instance v1, Ljava/util/LinkedHashMap;

    invoke-direct {v1}, Ljava/util/LinkedHashMap;-><init>()V

    move-object v7, v1

    .line 127
    .local v7, "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    invoke-direct {v8, v15, v7, v12}, Lcom/forge/live/AppsBridgePlugin;->addFromLauncherQuery(Landroid/content/pm/PackageManager;Ljava/util/Map;Z)I

    move-result v1

    move v6, v1

    .line 128
    .local v6, "launcherHits":I
    invoke-direct {v8, v15, v7, v12, v11}, Lcom/forge/live/AppsBridgePlugin;->addFromInstalledApps(Landroid/content/pm/PackageManager;Ljava/util/Map;ZZ)I

    move-result v1

    move v5, v1

    .line 129
    .local v5, "installedHits":I
    invoke-direct {v8, v15, v7, v12}, Lcom/forge/live/AppsBridgePlugin;->addFromCommonIntents(Landroid/content/pm/PackageManager;Ljava/util/Map;Z)I

    move-result v1

    move v4, v1

    .line 130
    .local v4, "intentHits":I
    const/4 v1, 0x0

    .line 131
    .local v1, "knownHits":I
    if-eqz v13, :cond_1

    .line 132
    invoke-direct {v8, v15, v7, v12, v11}, Lcom/forge/live/AppsBridgePlugin;->addFromKnownPackages(Landroid/content/pm/PackageManager;Ljava/util/Map;ZZ)I

    move-result v2

    move v1, v2

    move v3, v1

    goto :goto_0

    .line 131
    :cond_1
    move v3, v1

    .line 134
    .end local v1    # "knownHits":I
    .local v3, "knownHits":I
    :goto_0
    if-eqz v0, :cond_2

    const-string v1, "."

    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_2

    .line 135
    const-string v16, "query"

    move-object/from16 v1, p0

    move-object v2, v15

    move/from16 v17, v3

    .end local v3    # "knownHits":I
    .local v17, "knownHits":I
    move-object v3, v7

    move/from16 v18, v4

    .end local v4    # "intentHits":I
    .local v18, "intentHits":I
    move-object v4, v0

    move/from16 v19, v5

    .end local v5    # "installedHits":I
    .local v19, "installedHits":I
    move v5, v12

    move/from16 v20, v6

    .end local v6    # "launcherHits":I
    .local v20, "launcherHits":I
    move v6, v11

    move-object/from16 v21, v7

    .end local v7    # "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    .local v21, "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    move-object/from16 v7, v16

    invoke-direct/range {v1 .. v7}, Lcom/forge/live/AppsBridgePlugin;->addPackageIfVisible(Landroid/content/pm/PackageManager;Ljava/util/Map;Ljava/lang/String;ZZLjava/lang/String;)Z

    goto :goto_1

    .line 134
    .end local v17    # "knownHits":I
    .end local v18    # "intentHits":I
    .end local v19    # "installedHits":I
    .end local v20    # "launcherHits":I
    .end local v21    # "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    .restart local v3    # "knownHits":I
    .restart local v4    # "intentHits":I
    .restart local v5    # "installedHits":I
    .restart local v6    # "launcherHits":I
    .restart local v7    # "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    :cond_2
    move/from16 v17, v3

    move/from16 v18, v4

    move/from16 v19, v5

    move/from16 v20, v6

    move-object/from16 v21, v7

    .line 139
    .end local v3    # "knownHits":I
    .end local v4    # "intentHits":I
    .end local v5    # "installedHits":I
    .end local v6    # "launcherHits":I
    .end local v7    # "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    .restart local v17    # "knownHits":I
    .restart local v18    # "intentHits":I
    .restart local v19    # "installedHits":I
    .restart local v20    # "launcherHits":I
    .restart local v21    # "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    :goto_1
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 140
    .local v1, "apps":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    invoke-interface/range {v21 .. v21}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_2
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    const/4 v4, 0x0

    const-string v5, "packageName"

    const-string v6, "label"

    if-eqz v3, :cond_5

    :try_start_1
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lcom/getcapacitor/JSObject;

    .line 141
    .local v3, "row":Lcom/getcapacitor/JSObject;
    invoke-virtual {v3, v6}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    .line 142
    .local v6, "label":Ljava/lang/String;
    invoke-virtual {v3, v5}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .line 143
    .local v5, "pkg":Ljava/lang/String;
    if-eqz v0, :cond_3

    invoke-static {v0, v6, v5}, Lcom/forge/live/AppsBridgePlugin;->matchesQuery(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z

    move-result v7

    if-nez v7, :cond_3

    goto :goto_2

    .line 144
    :cond_3
    if-eqz v11, :cond_4

    const-string v7, "launchable"

    invoke-virtual {v3, v7, v4}, Lcom/getcapacitor/JSObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result v4

    if-nez v4, :cond_4

    goto :goto_2

    .line 145
    :cond_4
    invoke-interface {v1, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 146
    nop

    .end local v3    # "row":Lcom/getcapacitor/JSObject;
    .end local v5    # "pkg":Ljava/lang/String;
    .end local v6    # "label":Ljava/lang/String;
    goto :goto_2

    .line 148
    :cond_5
    new-instance v2, Lcom/forge/live/AppsBridgePlugin$$ExternalSyntheticLambda1;

    invoke-direct {v2}, Lcom/forge/live/AppsBridgePlugin$$ExternalSyntheticLambda1;-><init>()V

    invoke-static {v1, v2}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 156
    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v2

    .line 157
    .local v2, "totalMatched":I
    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v3

    if-le v3, v14, :cond_6

    .line 158
    new-instance v3, Ljava/util/ArrayList;

    invoke-interface {v1, v4, v14}, Ljava/util/List;->subList(II)Ljava/util/List;

    move-result-object v7

    invoke-direct {v3, v7}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    move-object v1, v3

    .line 161
    :cond_6
    new-instance v3, Lcom/getcapacitor/JSObject;

    invoke-direct {v3}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 162
    .local v3, "ret":Lcom/getcapacitor/JSObject;
    const-string v7, "ok"

    invoke-virtual {v3, v7, v10}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 163
    const-string v7, "count"

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v4

    invoke-virtual {v3, v7, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 164
    const-string v4, "totalMatched"

    invoke-virtual {v3, v4, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 165
    const-string v4, "truncated"

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v7

    if-le v2, v7, :cond_7

    goto :goto_3

    :cond_7
    const/4 v10, 0x0

    :goto_3
    invoke-virtual {v3, v4, v10}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 166
    const-string v4, "apps"

    invoke-static {v1}, Lcom/forge/live/AppsBridgePlugin;->toArray(Ljava/util/List;)Lcom/getcapacitor/JSArray;

    move-result-object v7

    invoke-virtual {v3, v4, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 167
    const-string v4, "queryAllPackages"

    invoke-direct/range {p0 .. p0}, Lcom/forge/live/AppsBridgePlugin;->hasQueryAllPackages()Z

    move-result v7

    invoke-virtual {v3, v4, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 168
    const-string v4, "launcherHits"

    move/from16 v7, v20

    .end local v20    # "launcherHits":I
    .local v7, "launcherHits":I
    invoke-virtual {v3, v4, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 169
    const-string v4, "installedHits"

    move/from16 v10, v19

    .end local v19    # "installedHits":I
    .local v10, "installedHits":I
    invoke-virtual {v3, v4, v10}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 170
    const-string v4, "intentHits"

    move-object/from16 v16, v0

    move/from16 v0, v18

    .end local v18    # "intentHits":I
    .local v0, "intentHits":I
    .local v16, "query":Ljava/lang/String;
    invoke-virtual {v3, v4, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 171
    const-string v4, "knownHits"

    move/from16 v18, v0

    move/from16 v0, v17

    .end local v17    # "knownHits":I
    .local v0, "knownHits":I
    .restart local v18    # "intentHits":I
    invoke-virtual {v3, v4, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 172
    const-string v4, "discovered"

    move/from16 v17, v0

    .end local v0    # "knownHits":I
    .restart local v17    # "knownHits":I
    invoke-interface/range {v21 .. v21}, Ljava/util/Map;->size()I

    move-result v0

    invoke-virtual {v3, v4, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 174
    new-instance v0, Lcom/getcapacitor/JSArray;

    invoke-direct {v0}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 175
    .local v0, "labels":Lcom/getcapacitor/JSArray;
    new-instance v4, Lcom/getcapacitor/JSArray;

    invoke-direct {v4}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 176
    .local v4, "packages":Lcom/getcapacitor/JSArray;
    new-instance v19, Lcom/getcapacitor/JSArray;

    invoke-direct/range {v19 .. v19}, Lcom/getcapacitor/JSArray;-><init>()V

    move-object/from16 v20, v19

    .line 177
    .local v20, "options":Lcom/getcapacitor/JSArray;
    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v19

    :goto_4
    invoke-interface/range {v19 .. v19}, Ljava/util/Iterator;->hasNext()Z

    move-result v22

    if-eqz v22, :cond_8

    invoke-interface/range {v19 .. v19}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v22

    check-cast v22, Lcom/getcapacitor/JSObject;

    move-object/from16 v23, v22

    .line 178
    .local v23, "a":Lcom/getcapacitor/JSObject;
    move-object/from16 v22, v1

    move-object/from16 v1, v23

    move/from16 v23, v2

    .end local v2    # "totalMatched":I
    .local v1, "a":Lcom/getcapacitor/JSObject;
    .local v22, "apps":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    .local v23, "totalMatched":I
    invoke-virtual {v1, v6}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 179
    invoke-virtual {v1, v5}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v4, v2}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 180
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 181
    .local v2, "opt":Lcom/getcapacitor/JSObject;
    move/from16 v24, v7

    .end local v7    # "launcherHits":I
    .local v24, "launcherHits":I
    const-string v7, "value"

    invoke-virtual {v1, v5}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v2, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 182
    invoke-virtual {v1, v6}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v2, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 183
    move-object/from16 v7, v20

    .end local v20    # "options":Lcom/getcapacitor/JSArray;
    .local v7, "options":Lcom/getcapacitor/JSArray;
    invoke-virtual {v7, v2}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 184
    move-object/from16 v8, p0

    move-object/from16 v20, v7

    move-object/from16 v1, v22

    move/from16 v2, v23

    move/from16 v7, v24

    .end local v1    # "a":Lcom/getcapacitor/JSObject;
    .end local v2    # "opt":Lcom/getcapacitor/JSObject;
    goto :goto_4

    .line 185
    .end local v22    # "apps":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    .end local v23    # "totalMatched":I
    .end local v24    # "launcherHits":I
    .local v1, "apps":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    .local v2, "totalMatched":I
    .local v7, "launcherHits":I
    .restart local v20    # "options":Lcom/getcapacitor/JSArray;
    :cond_8
    move-object/from16 v22, v1

    move/from16 v23, v2

    move/from16 v24, v7

    move-object/from16 v7, v20

    .end local v1    # "apps":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    .end local v2    # "totalMatched":I
    .end local v20    # "options":Lcom/getcapacitor/JSArray;
    .local v7, "options":Lcom/getcapacitor/JSArray;
    .restart local v22    # "apps":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    .restart local v23    # "totalMatched":I
    .restart local v24    # "launcherHits":I
    const-string v1, "labels"

    invoke-virtual {v3, v1, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 186
    const-string v1, "packages"

    invoke-virtual {v3, v1, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 187
    const-string v1, "options"

    invoke-virtual {v3, v1, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 188
    invoke-virtual {v9, v3}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .line 191
    .end local v0    # "labels":Lcom/getcapacitor/JSArray;
    .end local v3    # "ret":Lcom/getcapacitor/JSObject;
    .end local v4    # "packages":Lcom/getcapacitor/JSArray;
    .end local v7    # "options":Lcom/getcapacitor/JSArray;
    .end local v10    # "installedHits":I
    .end local v11    # "launchableOnly":Z
    .end local v12    # "includeSystem":Z
    .end local v13    # "probeKnown":Z
    .end local v14    # "limit":I
    .end local v15    # "pm":Landroid/content/pm/PackageManager;
    .end local v16    # "query":Ljava/lang/String;
    .end local v17    # "knownHits":I
    .end local v18    # "intentHits":I
    .end local v21    # "byPkg":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    .end local v22    # "apps":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    .end local v23    # "totalMatched":I
    .end local v24    # "launcherHits":I
    goto :goto_5

    .line 189
    :catch_0
    move-exception v0

    .line 190
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "listApps failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v9, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 192
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_5
    return-void
.end method

.method public openApp(Lcom/getcapacitor/PluginCall;)V
    .locals 0
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 394
    invoke-virtual {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->launch(Lcom/getcapacitor/PluginCall;)V

    .line 395
    return-void
.end method

.method public resolve(Lcom/getcapacitor/PluginCall;)V
    .locals 13
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 305
    :try_start_0
    invoke-direct {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->buildIntent(Lcom/getcapacitor/PluginCall;)Landroid/content/Intent;

    move-result-object v0

    .line 306
    .local v0, "intent":Landroid/content/Intent;
    invoke-virtual {p0}, Lcom/forge/live/AppsBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v1

    .line 307
    .local v1, "pm":Landroid/content/pm/PackageManager;
    const-string v2, "limit"

    const/16 v3, 0x32

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-virtual {p1, v2, v3}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v2

    invoke-static {v2}, Lcom/forge/live/AppsBridgePlugin;->clampLimit(Ljava/lang/Integer;)I

    move-result v2

    .line 308
    .local v2, "limit":I
    invoke-direct {p0, v1, v0}, Lcom/forge/live/AppsBridgePlugin;->queryActivities(Landroid/content/pm/PackageManager;Landroid/content/Intent;)Ljava/util/List;

    move-result-object v3

    .line 309
    .local v3, "resolved":Ljava/util/List;, "Ljava/util/List<Landroid/content/pm/ResolveInfo;>;"
    new-instance v4, Ljava/util/ArrayList;

    invoke-direct {v4}, Ljava/util/ArrayList;-><init>()V

    .line 310
    .local v4, "acts":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v5

    :goto_0
    invoke-interface {v5}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_3

    invoke-interface {v5}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Landroid/content/pm/ResolveInfo;

    .line 311
    .local v6, "ri":Landroid/content/pm/ResolveInfo;
    iget-object v7, v6, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    if-nez v7, :cond_0

    goto :goto_0

    .line 312
    :cond_0
    invoke-virtual {v6, v1}, Landroid/content/pm/ResolveInfo;->loadLabel(Landroid/content/pm/PackageManager;)Ljava/lang/CharSequence;

    move-result-object v7

    .line 313
    .local v7, "labelCs":Ljava/lang/CharSequence;
    if-eqz v7, :cond_1

    invoke-interface {v7}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;

    move-result-object v8

    goto :goto_1

    :cond_1
    iget-object v8, v6, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v8, v8, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    .line 314
    .local v8, "label":Ljava/lang/String;
    :goto_1
    new-instance v9, Lcom/getcapacitor/JSObject;

    invoke-direct {v9}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 315
    .local v9, "row":Lcom/getcapacitor/JSObject;
    const-string v10, "packageName"

    iget-object v11, v6, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v11, v11, Landroid/content/pm/ActivityInfo;->packageName:Ljava/lang/String;

    invoke-virtual {v9, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 316
    const-string v10, "activity"

    iget-object v11, v6, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v11, v11, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    invoke-virtual {v9, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 317
    const-string v10, "className"

    iget-object v11, v6, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v11, v11, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    invoke-virtual {v9, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 318
    const-string v10, "component"

    new-instance v11, Ljava/lang/StringBuilder;

    invoke-direct {v11}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v12, v6, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v12, v12, Landroid/content/pm/ActivityInfo;->packageName:Ljava/lang/String;

    invoke-virtual {v11, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    const-string v12, "/"

    invoke-virtual {v11, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    iget-object v12, v6, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-object v12, v12, Landroid/content/pm/ActivityInfo;->name:Ljava/lang/String;

    invoke-virtual {v11, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-virtual {v11}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v9, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 319
    const-string v10, "label"

    invoke-virtual {v9, v10, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 320
    const-string v10, "exported"

    iget-object v11, v6, Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;

    iget-boolean v11, v11, Landroid/content/pm/ActivityInfo;->exported:Z

    invoke-virtual {v9, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 321
    invoke-interface {v4, v9}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 322
    invoke-interface {v4}, Ljava/util/List;->size()I

    move-result v10

    if-lt v10, v2, :cond_2

    goto :goto_2

    .line 323
    .end local v6    # "ri":Landroid/content/pm/ResolveInfo;
    .end local v7    # "labelCs":Ljava/lang/CharSequence;
    .end local v8    # "label":Ljava/lang/String;
    .end local v9    # "row":Lcom/getcapacitor/JSObject;
    :cond_2
    goto :goto_0

    .line 324
    :cond_3
    :goto_2
    new-instance v5, Lcom/getcapacitor/JSObject;

    invoke-direct {v5}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 325
    .local v5, "ret":Lcom/getcapacitor/JSObject;
    const-string v6, "ok"

    const/4 v7, 0x1

    invoke-virtual {v5, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 326
    const-string v6, "count"

    invoke-interface {v4}, Ljava/util/List;->size()I

    move-result v7

    invoke-virtual {v5, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 327
    const-string v6, "activities"

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->toArray(Ljava/util/List;)Lcom/getcapacitor/JSArray;

    move-result-object v7

    invoke-virtual {v5, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 328
    const-string v6, "apps"

    invoke-static {v4}, Lcom/forge/live/AppsBridgePlugin;->toArray(Ljava/util/List;)Lcom/getcapacitor/JSArray;

    move-result-object v7

    invoke-virtual {v5, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 329
    invoke-virtual {p1, v5}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 332
    .end local v0    # "intent":Landroid/content/Intent;
    .end local v1    # "pm":Landroid/content/pm/PackageManager;
    .end local v2    # "limit":I
    .end local v3    # "resolved":Ljava/util/List;, "Ljava/util/List<Landroid/content/pm/ResolveInfo;>;"
    .end local v4    # "acts":Ljava/util/List;, "Ljava/util/List<Lcom/getcapacitor/JSObject;>;"
    .end local v5    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_3

    .line 330
    :catch_0
    move-exception v0

    .line 331
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "resolve failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 333
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_3
    return-void
.end method

.method public startActivity(Lcom/getcapacitor/PluginCall;)V
    .locals 0
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 389
    invoke-virtual {p0, p1}, Lcom/forge/live/AppsBridgePlugin;->launch(Lcom/getcapacitor/PluginCall;)V

    .line 390
    return-void
.end method
