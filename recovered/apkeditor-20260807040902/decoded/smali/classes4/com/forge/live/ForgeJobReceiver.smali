.class public Lcom/forge/live/ForgeJobReceiver;
.super Landroid/content/BroadcastReceiver;
.source "ForgeJobReceiver.java"


# static fields
.field public static final ACTION_JOB:Ljava/lang/String; = "com.forge.live.JOB_FIRE"

.field public static final PENDING_PREFS:Ljava/lang/String; = "forge_jobs_pending_v1"

.field public static final PREFS:Ljava/lang/String; = "forge_jobs_v1"


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 14
    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 31
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .line 22
    move-object/from16 v10, p1

    move-object/from16 v11, p2

    const-string v12, "once"

    const-string v13, "payload"

    const-string v14, "text"

    const-string v15, "title"

    const-string v9, "appId"

    const-string v0, "data"

    if-eqz v10, :cond_f

    if-nez v11, :cond_0

    goto/16 :goto_6

    .line 23
    :cond_0
    invoke-virtual/range {p2 .. p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v1

    const-string v2, "com.forge.live.JOB_FIRE"

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    const-string v3, "android.intent.action.BOOT_COMPLETED"

    if-nez v1, :cond_1

    .line 24
    invoke-virtual/range {p2 .. p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v3, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    .line 28
    :cond_1
    invoke-virtual/range {p2 .. p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v3, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_2

    .line 29
    invoke-static/range {p1 .. p1}, Lcom/forge/live/JobBridgePlugin;->rescheduleAll(Landroid/content/Context;)V

    .line 30
    return-void

    .line 33
    :cond_2
    invoke-virtual/range {p2 .. p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_3

    return-void

    .line 35
    :cond_3
    const-string v1, "forge_job_id"

    invoke-virtual {v11, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    .line 36
    .local v8, "jobId":Ljava/lang/String;
    if-eqz v8, :cond_e

    invoke-virtual {v8}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_4

    move-object v3, v8

    goto/16 :goto_5

    .line 38
    :cond_4
    const-string v1, "forge_jobs_v1"

    const/4 v7, 0x0

    invoke-virtual {v10, v1, v7}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v5

    .line 39
    .local v5, "prefs":Landroid/content/SharedPreferences;
    const/4 v1, 0x0

    invoke-interface {v5, v8, v1}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    .line 40
    .local v4, "raw":Ljava/lang/String;
    if-nez v4, :cond_5

    return-void

    .line 43
    :cond_5
    :try_start_0
    new-instance v2, Lorg/json/JSONObject;

    invoke-direct {v2, v4}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    move-object v3, v2

    .line 44
    .local v3, "job":Lorg/json/JSONObject;
    const-string v2, ""

    invoke-virtual {v3, v9, v2}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 45
    .local v2, "appId":Ljava/lang/String;
    const-string v6, "appTitle"

    const-string v7, "Forge app"

    invoke-virtual {v3, v6, v7}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    move-object v7, v6

    .line 46
    .local v7, "appTitle":Ljava/lang/String;
    invoke-virtual {v3, v15, v7}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    .line 47
    .local v6, "title":Ljava/lang/String;
    const-string v1, "message"

    move-object/from16 v18, v2

    .end local v2    # "appId":Ljava/lang/String;
    .local v18, "appId":Ljava/lang/String;
    const-string v2, "Reminder"

    invoke-virtual {v3, v1, v2}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v3, v14, v1}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    move-object v2, v1

    .line 48
    .local v2, "text":Ljava/lang/String;
    const-string v1, "channel"

    move-object/from16 v19, v2

    .end local v2    # "text":Ljava/lang/String;
    .local v19, "text":Ljava/lang/String;
    const-string v2, "forge_jobs"

    invoke-virtual {v3, v1, v2}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    move-object v2, v6

    .end local v6    # "title":Ljava/lang/String;
    .local v2, "title":Ljava/lang/String;
    move-object v6, v1

    .line 49
    .local v6, "channel":Ljava/lang/String;
    const/4 v1, 0x0

    invoke-virtual {v3, v13, v1}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_6

    .line 50
    .local v1, "payload":Ljava/lang/String;
    const-string v11, "type"

    move-object/from16 v17, v12

    const-string v12, "jobId"

    if-eqz v1, :cond_8

    :try_start_1
    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v20
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    if-eqz v20, :cond_6

    goto :goto_1

    .line 59
    :cond_6
    :try_start_2
    new-instance v0, Lorg/json/JSONObject;

    invoke-direct {v0, v1}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 60
    .local v0, "p":Lorg/json/JSONObject;
    invoke-virtual {v0, v12}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v20

    if-nez v20, :cond_7

    invoke-virtual {v0, v12, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 61
    :cond_7
    invoke-virtual {v0}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v20
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    move-object/from16 v1, v20

    goto :goto_0

    .line 62
    .end local v0    # "p":Lorg/json/JSONObject;
    :catch_0
    move-exception v0

    :goto_0
    move-object v0, v1

    move-object/from16 v21, v2

    goto :goto_2

    .line 107
    .end local v1    # "payload":Ljava/lang/String;
    .end local v2    # "title":Ljava/lang/String;
    .end local v3    # "job":Lorg/json/JSONObject;
    .end local v6    # "channel":Ljava/lang/String;
    .end local v7    # "appTitle":Ljava/lang/String;
    .end local v18    # "appId":Ljava/lang/String;
    .end local v19    # "text":Ljava/lang/String;
    :catch_1
    move-exception v0

    move-object/from16 v26, v4

    move-object/from16 v27, v5

    move-object v3, v8

    goto/16 :goto_4

    .line 51
    .restart local v1    # "payload":Ljava/lang/String;
    .restart local v2    # "title":Ljava/lang/String;
    .restart local v3    # "job":Lorg/json/JSONObject;
    .restart local v6    # "channel":Ljava/lang/String;
    .restart local v7    # "appTitle":Ljava/lang/String;
    .restart local v18    # "appId":Ljava/lang/String;
    .restart local v19    # "text":Ljava/lang/String;
    :cond_8
    :goto_1
    :try_start_3
    new-instance v20, Lorg/json/JSONObject;

    invoke-direct/range {v20 .. v20}, Lorg/json/JSONObject;-><init>()V

    move-object/from16 v21, v20

    .line 52
    .local v21, "p":Lorg/json/JSONObject;
    move-object/from16 v20, v1

    move-object/from16 v1, v21

    .end local v21    # "p":Lorg/json/JSONObject;
    .local v1, "p":Lorg/json/JSONObject;
    .local v20, "payload":Ljava/lang/String;
    invoke-virtual {v1, v12, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 53
    move-object/from16 v21, v2

    .end local v2    # "title":Ljava/lang/String;
    .local v21, "title":Ljava/lang/String;
    const-string v2, "job"

    invoke-virtual {v1, v11, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 54
    invoke-virtual {v3, v0}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    move-result v2
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_6

    if-eqz v2, :cond_9

    :try_start_4
    invoke-virtual {v3, v0}, Lorg/json/JSONObject;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v1, v0, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_1

    .line 55
    :cond_9
    :try_start_5
    invoke-virtual {v1}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v0

    move-object v1, v0

    .line 56
    .end local v20    # "payload":Ljava/lang/String;
    .local v1, "payload":Ljava/lang/String;
    nop

    .line 65
    .end local v1    # "payload":Ljava/lang/String;
    .local v0, "payload":Ljava/lang/String;
    :goto_2
    const-string v1, "notify"

    const/4 v2, 0x1

    invoke-virtual {v3, v1, v2}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result v1
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_6

    move/from16 v20, v1

    .line 66
    .local v20, "notify":Z
    if-eqz v20, :cond_a

    .line 67
    :try_start_6
    invoke-virtual {v8}, Ljava/lang/String;->hashCode()I

    move-result v1

    invoke-static {v1}, Ljava/lang/Math;->abs(I)I

    move-result v1

    move v2, v1

    .line 68
    .local v2, "nid":I
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    move-object/from16 v22, v3

    .end local v3    # "job":Lorg/json/JSONObject;
    .local v22, "job":Lorg/json/JSONObject;
    const-string v3, "job:"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v23

    rem-int/lit16 v1, v2, 0x2710
    :try_end_6
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_6} :catch_3

    const v3, 0xcf08

    add-int v24, v1, v3

    move-object/from16 v1, p1

    move-object/from16 v3, v18

    move/from16 v18, v2

    .end local v2    # "nid":I
    .local v3, "appId":Ljava/lang/String;
    .local v18, "nid":I
    move-object v2, v3

    move-object/from16 v25, v22

    move-object/from16 v22, v11

    move-object v11, v3

    .end local v3    # "appId":Ljava/lang/String;
    .end local v22    # "job":Lorg/json/JSONObject;
    .local v11, "appId":Ljava/lang/String;
    .local v25, "job":Lorg/json/JSONObject;
    move-object v3, v7

    move-object/from16 v26, v4

    .end local v4    # "raw":Ljava/lang/String;
    .local v26, "raw":Ljava/lang/String;
    move-object/from16 v4, v21

    move-object/from16 v27, v5

    .end local v5    # "prefs":Landroid/content/SharedPreferences;
    .local v27, "prefs":Landroid/content/SharedPreferences;
    move-object/from16 v5, v19

    move-object/from16 v16, v7

    move-object/from16 v28, v14

    const/4 v14, 0x0

    .end local v7    # "appTitle":Ljava/lang/String;
    .local v16, "appTitle":Ljava/lang/String;
    move-object/from16 v7, v23

    move-object/from16 v29, v8

    .end local v8    # "jobId":Ljava/lang/String;
    .local v29, "jobId":Ljava/lang/String;
    move-object v8, v0

    move-object/from16 v30, v9

    move/from16 v9, v24

    :try_start_7
    invoke-static/range {v1 .. v9}, Lcom/forge/live/NotifyBridgePlugin;->showNotification(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_7} :catch_2

    goto :goto_3

    .line 107
    .end local v0    # "payload":Ljava/lang/String;
    .end local v6    # "channel":Ljava/lang/String;
    .end local v11    # "appId":Ljava/lang/String;
    .end local v16    # "appTitle":Ljava/lang/String;
    .end local v18    # "nid":I
    .end local v19    # "text":Ljava/lang/String;
    .end local v20    # "notify":Z
    .end local v21    # "title":Ljava/lang/String;
    .end local v25    # "job":Lorg/json/JSONObject;
    :catch_2
    move-exception v0

    move-object/from16 v3, v29

    goto/16 :goto_4

    .end local v26    # "raw":Ljava/lang/String;
    .end local v27    # "prefs":Landroid/content/SharedPreferences;
    .end local v29    # "jobId":Ljava/lang/String;
    .restart local v4    # "raw":Ljava/lang/String;
    .restart local v5    # "prefs":Landroid/content/SharedPreferences;
    .restart local v8    # "jobId":Ljava/lang/String;
    :catch_3
    move-exception v0

    move-object/from16 v26, v4

    move-object/from16 v27, v5

    move-object/from16 v29, v8

    move-object/from16 v3, v29

    .end local v4    # "raw":Ljava/lang/String;
    .end local v5    # "prefs":Landroid/content/SharedPreferences;
    .end local v8    # "jobId":Ljava/lang/String;
    .restart local v26    # "raw":Ljava/lang/String;
    .restart local v27    # "prefs":Landroid/content/SharedPreferences;
    .restart local v29    # "jobId":Ljava/lang/String;
    goto/16 :goto_4

    .line 66
    .end local v26    # "raw":Ljava/lang/String;
    .end local v27    # "prefs":Landroid/content/SharedPreferences;
    .end local v29    # "jobId":Ljava/lang/String;
    .restart local v0    # "payload":Ljava/lang/String;
    .local v3, "job":Lorg/json/JSONObject;
    .restart local v4    # "raw":Ljava/lang/String;
    .restart local v5    # "prefs":Landroid/content/SharedPreferences;
    .restart local v6    # "channel":Ljava/lang/String;
    .restart local v7    # "appTitle":Ljava/lang/String;
    .restart local v8    # "jobId":Ljava/lang/String;
    .local v18, "appId":Ljava/lang/String;
    .restart local v19    # "text":Ljava/lang/String;
    .restart local v20    # "notify":Z
    .restart local v21    # "title":Ljava/lang/String;
    :cond_a
    move-object/from16 v25, v3

    move-object/from16 v26, v4

    move-object/from16 v27, v5

    move-object/from16 v16, v7

    move-object/from16 v29, v8

    move-object/from16 v30, v9

    move-object/from16 v22, v11

    move-object/from16 v28, v14

    move-object/from16 v11, v18

    const/4 v14, 0x0

    .line 82
    .end local v3    # "job":Lorg/json/JSONObject;
    .end local v4    # "raw":Ljava/lang/String;
    .end local v5    # "prefs":Landroid/content/SharedPreferences;
    .end local v7    # "appTitle":Ljava/lang/String;
    .end local v8    # "jobId":Ljava/lang/String;
    .end local v18    # "appId":Ljava/lang/String;
    .restart local v11    # "appId":Ljava/lang/String;
    .restart local v16    # "appTitle":Ljava/lang/String;
    .restart local v25    # "job":Lorg/json/JSONObject;
    .restart local v26    # "raw":Ljava/lang/String;
    .restart local v27    # "prefs":Landroid/content/SharedPreferences;
    .restart local v29    # "jobId":Ljava/lang/String;
    :goto_3
    :try_start_8
    const-string v1, "forge_jobs_pending_v1"

    invoke-virtual {v10, v1, v14}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v1

    .line 83
    .local v1, "pending":Landroid/content/SharedPreferences;
    new-instance v2, Lorg/json/JSONObject;

    invoke-direct {v2}, Lorg/json/JSONObject;-><init>()V
    :try_end_8
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_8} :catch_5

    .line 84
    .local v2, "pend":Lorg/json/JSONObject;
    move-object/from16 v3, v29

    .end local v29    # "jobId":Ljava/lang/String;
    .local v3, "jobId":Ljava/lang/String;
    :try_start_9
    invoke-virtual {v2, v12, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 85
    move-object/from16 v4, v30

    invoke-virtual {v2, v4, v11}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 86
    invoke-virtual {v2, v13, v0}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 87
    move-object/from16 v4, v21

    .end local v21    # "title":Ljava/lang/String;
    .local v4, "title":Ljava/lang/String;
    invoke-virtual {v2, v15, v4}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 88
    move-object/from16 v5, v19

    move-object/from16 v7, v28

    .end local v19    # "text":Ljava/lang/String;
    .local v5, "text":Ljava/lang/String;
    invoke-virtual {v2, v7, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 89
    const-string v7, "firedAt"

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v8

    invoke-virtual {v2, v7, v8, v9}, Lorg/json/JSONObject;->put(Ljava/lang/String;J)Lorg/json/JSONObject;

    .line 90
    invoke-interface {v1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v7

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v8, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, "::"

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v2}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v9

    invoke-interface {v7, v8, v9}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v7

    invoke-interface {v7}, Landroid/content/SharedPreferences$Editor;->apply()V

    .line 93
    move-object/from16 v8, v17

    move-object/from16 v9, v22

    move-object/from16 v7, v25

    .end local v25    # "job":Lorg/json/JSONObject;
    .local v7, "job":Lorg/json/JSONObject;
    invoke-virtual {v7, v9, v8}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    .line 94
    .local v9, "type":Ljava/lang/String;
    invoke-virtual {v8, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_b

    .line 95
    invoke-interface/range {v27 .. v27}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v8

    invoke-interface {v8, v3}, Landroid/content/SharedPreferences$Editor;->remove(Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v8

    invoke-interface {v8}, Landroid/content/SharedPreferences$Editor;->apply()V

    goto :goto_4

    .line 96
    :cond_b
    const-string v8, "interval"

    invoke-virtual {v8, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_d

    .line 97
    const-string v8, "intervalMs"

    const-wide/16 v12, 0x0

    invoke-virtual {v7, v8, v12, v13}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;J)J

    move-result-wide v12

    .line 98
    .local v12, "intervalMs":J
    const-wide/32 v14, 0xea60

    cmp-long v8, v12, v14

    if-ltz v8, :cond_c

    .line 99
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v14

    add-long/2addr v14, v12

    .line 100
    .local v14, "next":J
    const-string v8, "atMs"

    invoke-virtual {v7, v8, v14, v15}, Lorg/json/JSONObject;->put(Ljava/lang/String;J)Lorg/json/JSONObject;

    .line 101
    invoke-interface/range {v27 .. v27}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v8

    move-object/from16 v17, v0

    .end local v0    # "payload":Ljava/lang/String;
    .local v17, "payload":Ljava/lang/String;
    invoke-virtual {v7}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-interface {v8, v3, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V

    .line 102
    invoke-static {v10, v3, v14, v15}, Lcom/forge/live/JobBridgePlugin;->scheduleAlarm(Landroid/content/Context;Ljava/lang/String;J)V

    .line 103
    .end local v14    # "next":J
    goto :goto_4

    .line 104
    .end local v17    # "payload":Ljava/lang/String;
    .restart local v0    # "payload":Ljava/lang/String;
    :cond_c
    move-object/from16 v17, v0

    .end local v0    # "payload":Ljava/lang/String;
    .restart local v17    # "payload":Ljava/lang/String;
    invoke-interface/range {v27 .. v27}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-interface {v0, v3}, Landroid/content/SharedPreferences$Editor;->remove(Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V
    :try_end_9
    .catch Ljava/lang/Exception; {:try_start_9 .. :try_end_9} :catch_4

    goto :goto_4

    .line 96
    .end local v12    # "intervalMs":J
    .end local v17    # "payload":Ljava/lang/String;
    .restart local v0    # "payload":Ljava/lang/String;
    :cond_d
    move-object/from16 v17, v0

    .end local v0    # "payload":Ljava/lang/String;
    .restart local v17    # "payload":Ljava/lang/String;
    goto :goto_4

    .line 107
    .end local v1    # "pending":Landroid/content/SharedPreferences;
    .end local v2    # "pend":Lorg/json/JSONObject;
    .end local v4    # "title":Ljava/lang/String;
    .end local v5    # "text":Ljava/lang/String;
    .end local v6    # "channel":Ljava/lang/String;
    .end local v7    # "job":Lorg/json/JSONObject;
    .end local v9    # "type":Ljava/lang/String;
    .end local v11    # "appId":Ljava/lang/String;
    .end local v16    # "appTitle":Ljava/lang/String;
    .end local v17    # "payload":Ljava/lang/String;
    .end local v20    # "notify":Z
    :catch_4
    move-exception v0

    goto :goto_4

    .end local v3    # "jobId":Ljava/lang/String;
    .restart local v29    # "jobId":Ljava/lang/String;
    :catch_5
    move-exception v0

    move-object/from16 v3, v29

    .end local v29    # "jobId":Ljava/lang/String;
    .restart local v3    # "jobId":Ljava/lang/String;
    goto :goto_4

    .end local v3    # "jobId":Ljava/lang/String;
    .end local v26    # "raw":Ljava/lang/String;
    .end local v27    # "prefs":Landroid/content/SharedPreferences;
    .local v4, "raw":Ljava/lang/String;
    .local v5, "prefs":Landroid/content/SharedPreferences;
    .restart local v8    # "jobId":Ljava/lang/String;
    :catch_6
    move-exception v0

    move-object/from16 v26, v4

    move-object/from16 v27, v5

    move-object v3, v8

    .end local v4    # "raw":Ljava/lang/String;
    .end local v5    # "prefs":Landroid/content/SharedPreferences;
    .end local v8    # "jobId":Ljava/lang/String;
    .restart local v3    # "jobId":Ljava/lang/String;
    .restart local v26    # "raw":Ljava/lang/String;
    .restart local v27    # "prefs":Landroid/content/SharedPreferences;
    :goto_4
    nop

    .line 108
    return-void

    .line 36
    .end local v3    # "jobId":Ljava/lang/String;
    .end local v26    # "raw":Ljava/lang/String;
    .end local v27    # "prefs":Landroid/content/SharedPreferences;
    .restart local v8    # "jobId":Ljava/lang/String;
    :cond_e
    move-object v3, v8

    .end local v8    # "jobId":Ljava/lang/String;
    .restart local v3    # "jobId":Ljava/lang/String;
    :goto_5
    return-void

    .line 22
    .end local v3    # "jobId":Ljava/lang/String;
    :cond_f
    :goto_6
    return-void
.end method
