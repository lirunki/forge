.class public Lcom/forge/live/JobBridgePlugin;
.super Lcom/getcapacitor/Plugin;
.source "JobBridgePlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "JobBridge"
.end annotation


# static fields
.field public static final EXTRA_JOB_ID:Ljava/lang/String; = "forge_job_id"

.field private static final PENDING_PREFS:Ljava/lang/String; = "forge_jobs_pending_v1"

.field private static final PREFS:Ljava/lang/String; = "forge_jobs_v1"


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 29
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    return-void
.end method

.method private static canScheduleExact(Landroid/content/Context;)Z
    .locals 3
    .param p0, "ctx"    # Landroid/content/Context;

    .line 315
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1f

    const/4 v2, 0x1

    if-lt v0, v1, :cond_1

    .line 316
    const-string v0, "alarm"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/AlarmManager;

    .line 317
    .local v0, "am":Landroid/app/AlarmManager;
    if-eqz v0, :cond_0

    invoke-virtual {v0}, Landroid/app/AlarmManager;->canScheduleExactAlarms()Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_0

    :cond_0
    const/4 v2, 0x0

    :goto_0
    return v2

    .line 319
    .end local v0    # "am":Landroid/app/AlarmManager;
    :cond_1
    return v2
.end method

.method public static cancelAlarm(Landroid/content/Context;Ljava/lang/String;)V
    .locals 2
    .param p0, "ctx"    # Landroid/content/Context;
    .param p1, "jobId"    # Ljava/lang/String;

    .line 267
    const-string v0, "alarm"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/AlarmManager;

    .line 268
    .local v0, "am":Landroid/app/AlarmManager;
    if-nez v0, :cond_0

    return-void

    .line 270
    :cond_0
    :try_start_0
    invoke-static {p0, p1}, Lcom/forge/live/JobBridgePlugin;->jobPendingIntent(Landroid/content/Context;Ljava/lang/String;)Landroid/app/PendingIntent;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/AlarmManager;->cancel(Landroid/app/PendingIntent;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 271
    :catch_0
    move-exception v1

    :goto_0
    nop

    .line 272
    return-void
.end method

.method private static jobPendingIntent(Landroid/content/Context;Ljava/lang/String;)Landroid/app/PendingIntent;
    .locals 4
    .param p0, "ctx"    # Landroid/content/Context;
    .param p1, "jobId"    # Ljava/lang/String;

    .line 303
    new-instance v0, Landroid/content/Intent;

    const-class v1, Lcom/forge/live/ForgeJobReceiver;

    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 304
    .local v0, "i":Landroid/content/Intent;
    const-string v1, "com.forge.live.JOB_FIRE"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 305
    const-string v1, "forge_job_id"

    invoke-virtual {v0, v1, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 306
    const/high16 v1, 0x8000000

    .line 307
    .local v1, "flags":I
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x17

    if-lt v2, v3, :cond_0

    .line 308
    const/high16 v2, 0x4000000

    or-int/2addr v1, v2

    .line 310
    :cond_0
    invoke-virtual {p1}, Ljava/lang/String;->hashCode()I

    move-result v2

    invoke-static {v2}, Ljava/lang/Math;->abs(I)I

    move-result v2

    .line 311
    .local v2, "req":I
    invoke-static {p0, v2, v0, v1}, Landroid/app/PendingIntent;->getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v3

    return-object v3
.end method

.method public static rescheduleAll(Landroid/content/Context;)V
    .locals 15
    .param p0, "ctx"    # Landroid/content/Context;

    .line 275
    const-string v0, "atMs"

    const-string v1, "forge_jobs_v1"

    const/4 v2, 0x0

    invoke-virtual {p0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v1

    .line 276
    .local v1, "prefs":Landroid/content/SharedPreferences;
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v2

    .line 277
    .local v2, "now":J
    invoke-interface {v1}, Landroid/content/SharedPreferences;->getAll()Ljava/util/Map;

    move-result-object v4

    invoke-interface {v4}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v4

    invoke-interface {v4}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v4

    :goto_0
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_3

    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/Map$Entry;

    .line 279
    .local v5, "e":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/String;*>;"
    :try_start_0
    new-instance v6, Lorg/json/JSONObject;

    invoke-interface {v5}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v7

    invoke-static {v7}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v7

    invoke-direct {v6, v7}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 280
    .local v6, "job":Lorg/json/JSONObject;
    const-wide/16 v7, 0x0

    invoke-virtual {v6, v0, v7, v8}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;J)J

    move-result-wide v9

    .line 281
    .local v9, "at":J
    const-string v11, "type"

    const-string v12, "once"

    invoke-virtual {v6, v11, v12}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    .line 282
    .local v11, "type":Ljava/lang/String;
    cmp-long v12, v9, v2

    if-gtz v12, :cond_2

    .line 283
    const-string v12, "interval"

    invoke-virtual {v12, v11}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v12

    if-eqz v12, :cond_1

    .line 284
    const-string v12, "intervalMs"

    invoke-virtual {v6, v12, v7, v8}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;J)J

    move-result-wide v7

    .line 285
    .local v7, "interval":J
    const-wide/32 v12, 0xea60

    cmp-long v14, v7, v12

    if-ltz v14, :cond_0

    .line 286
    add-long v9, v2, v7

    .line 287
    invoke-virtual {v6, v0, v9, v10}, Lorg/json/JSONObject;->put(Ljava/lang/String;J)Lorg/json/JSONObject;

    .line 288
    invoke-interface {v1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v12

    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v13

    check-cast v13, Ljava/lang/String;

    invoke-virtual {v6}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v14

    invoke-interface {v12, v13, v14}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v12

    invoke-interface {v12}, Landroid/content/SharedPreferences$Editor;->apply()V

    .line 292
    .end local v7    # "interval":J
    goto :goto_1

    .line 290
    .restart local v7    # "interval":J
    :cond_0
    goto :goto_0

    .line 294
    .end local v7    # "interval":J
    :cond_1
    const-wide/16 v7, 0x1388

    add-long v9, v2, v7

    .line 297
    :cond_2
    :goto_1
    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Ljava/lang/String;

    invoke-static {p0, v7, v9, v10}, Lcom/forge/live/JobBridgePlugin;->scheduleAlarm(Landroid/content/Context;Ljava/lang/String;J)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .end local v6    # "job":Lorg/json/JSONObject;
    .end local v9    # "at":J
    .end local v11    # "type":Ljava/lang/String;
    goto :goto_2

    .line 298
    :catch_0
    move-exception v6

    :goto_2
    nop

    .line 299
    .end local v5    # "e":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/String;*>;"
    goto :goto_0

    .line 300
    :cond_3
    return-void
.end method

.method private static sanitize(Ljava/lang/String;)Ljava/lang/String;
    .locals 3
    .param p0, "id"    # Ljava/lang/String;

    .line 323
    invoke-virtual {p0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    const-string v1, "[^a-zA-Z0-9._-]"

    const-string v2, "_"

    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public static scheduleAlarm(Landroid/content/Context;Ljava/lang/String;J)V
    .locals 5
    .param p0, "ctx"    # Landroid/content/Context;
    .param p1, "jobId"    # Ljava/lang/String;
    .param p2, "atMs"    # J

    .line 242
    const-string v0, "alarm"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/AlarmManager;

    .line 243
    .local v0, "am":Landroid/app/AlarmManager;
    if-nez v0, :cond_0

    return-void

    .line 244
    :cond_0
    invoke-static {p0, p1}, Lcom/forge/live/JobBridgePlugin;->jobPendingIntent(Landroid/content/Context;Ljava/lang/String;)Landroid/app/PendingIntent;

    move-result-object v1

    .line 246
    .local v1, "pi":Landroid/app/PendingIntent;
    const/4 v2, 0x0

    :try_start_0
    sget v3, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v4, 0x17

    if-lt v3, v4, :cond_2

    .line 247
    invoke-static {p0}, Lcom/forge/live/JobBridgePlugin;->canScheduleExact(Landroid/content/Context;)Z

    move-result v3

    if-eqz v3, :cond_1

    .line 248
    invoke-virtual {v0, v2, p2, p3, v1}, Landroid/app/AlarmManager;->setExactAndAllowWhileIdle(IJLandroid/app/PendingIntent;)V

    goto :goto_0

    .line 250
    :cond_1
    invoke-virtual {v0, v2, p2, p3, v1}, Landroid/app/AlarmManager;->setAndAllowWhileIdle(IJLandroid/app/PendingIntent;)V

    goto :goto_0

    .line 253
    :cond_2
    invoke-virtual {v0, v2, p2, p3, v1}, Landroid/app/AlarmManager;->setExact(IJLandroid/app/PendingIntent;)V
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_2
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 263
    :goto_0
    goto :goto_1

    .line 261
    :catch_0
    move-exception v3

    .line 262
    .local v3, "e":Ljava/lang/Exception;
    :try_start_1
    invoke-virtual {v0, v2, p2, p3, v1}, Landroid/app/AlarmManager;->set(IJLandroid/app/PendingIntent;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    :catch_1
    move-exception v2

    goto :goto_1

    .line 255
    .end local v3    # "e":Ljava/lang/Exception;
    :catch_2
    move-exception v3

    .line 257
    .local v3, "se":Ljava/lang/SecurityException;
    :try_start_2
    invoke-virtual {v0, v2, p2, p3, v1}, Landroid/app/AlarmManager;->setAndAllowWhileIdle(IJLandroid/app/PendingIntent;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_3

    .line 260
    goto :goto_0

    .line 258
    :catch_3
    move-exception v4

    .line 259
    .local v4, "e2":Ljava/lang/Exception;
    :try_start_3
    invoke-virtual {v0, v2, p2, p3, v1}, Landroid/app/AlarmManager;->set(IJLandroid/app/PendingIntent;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_4

    goto :goto_0

    :catch_4
    move-exception v2

    goto :goto_0

    .line 264
    .end local v3    # "se":Ljava/lang/SecurityException;
    .end local v4    # "e2":Ljava/lang/Exception;
    :goto_1
    return-void
.end method


# virtual methods
.method public cancel(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 144
    const-string v0, "id"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 145
    .local v1, "id":Ljava/lang/String;
    if-eqz v1, :cond_1

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_0

    goto :goto_0

    .line 149
    :cond_0
    invoke-static {v1}, Lcom/forge/live/JobBridgePlugin;->sanitize(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 150
    invoke-virtual {p0}, Lcom/forge/live/JobBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-static {v2, v1}, Lcom/forge/live/JobBridgePlugin;->cancelAlarm(Landroid/content/Context;Ljava/lang/String;)V

    .line 151
    invoke-virtual {p0}, Lcom/forge/live/JobBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    const-string v3, "forge_jobs_v1"

    const/4 v4, 0x0

    invoke-virtual {v2, v3, v4}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v2

    invoke-interface {v2}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v2

    invoke-interface {v2, v1}, Landroid/content/SharedPreferences$Editor;->remove(Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v2

    invoke-interface {v2}, Landroid/content/SharedPreferences$Editor;->apply()V

    .line 152
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 153
    .local v2, "o":Lcom/getcapacitor/JSObject;
    const-string v3, "ok"

    const/4 v4, 0x1

    invoke-virtual {v2, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 154
    invoke-virtual {v2, v0, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 155
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 156
    return-void

    .line 146
    .end local v2    # "o":Lcom/getcapacitor/JSObject;
    :cond_1
    :goto_0
    const-string v0, "id required"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 147
    return-void
.end method

.method public cancelAll(Lcom/getcapacitor/PluginCall;)V
    .locals 10
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 160
    invoke-virtual {p0}, Lcom/forge/live/JobBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    .line 161
    .local v0, "ctx":Landroid/content/Context;
    const-string v1, "forge_jobs_v1"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v1

    .line 162
    .local v1, "prefs":Landroid/content/SharedPreferences;
    const/4 v2, 0x0

    const-string v3, "appId"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 163
    .local v2, "appId":Ljava/lang/String;
    invoke-interface {v1}, Landroid/content/SharedPreferences;->getAll()Ljava/util/Map;

    move-result-object v4

    .line 164
    .local v4, "all":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;*>;"
    new-instance v5, Ljava/util/ArrayList;

    invoke-direct {v5}, Ljava/util/ArrayList;-><init>()V

    .line 165
    .local v5, "removed":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    invoke-interface {v4}, Ljava/util/Map;->keySet()Ljava/util/Set;

    move-result-object v6

    invoke-interface {v6}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v6

    :goto_0
    invoke-interface {v6}, Ljava/util/Iterator;->hasNext()Z

    move-result v7

    if-eqz v7, :cond_1

    invoke-interface {v6}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Ljava/lang/String;

    .line 167
    .local v7, "key":Ljava/lang/String;
    :try_start_0
    new-instance v8, Lorg/json/JSONObject;

    invoke-interface {v4, v7}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v9

    invoke-static {v9}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v9

    invoke-direct {v8, v9}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 168
    .local v8, "job":Lorg/json/JSONObject;
    if-eqz v2, :cond_0

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v9

    if-nez v9, :cond_0

    invoke-virtual {v8, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v2, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-nez v9, :cond_0

    goto :goto_0

    .line 169
    :cond_0
    invoke-static {v0, v7}, Lcom/forge/live/JobBridgePlugin;->cancelAlarm(Landroid/content/Context;Ljava/lang/String;)V

    .line 170
    invoke-interface {v5, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 173
    nop

    .end local v8    # "job":Lorg/json/JSONObject;
    goto :goto_1

    .line 171
    :catch_0
    move-exception v8

    .line 172
    .local v8, "ignored":Ljava/lang/Exception;
    invoke-interface {v5, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 174
    .end local v7    # "key":Ljava/lang/String;
    .end local v8    # "ignored":Ljava/lang/Exception;
    :goto_1
    goto :goto_0

    .line 175
    :cond_1
    invoke-interface {v1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v3

    .line 176
    .local v3, "ed":Landroid/content/SharedPreferences$Editor;
    invoke-interface {v5}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v6

    :goto_2
    invoke-interface {v6}, Ljava/util/Iterator;->hasNext()Z

    move-result v7

    if-eqz v7, :cond_2

    invoke-interface {v6}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Ljava/lang/String;

    .local v7, "k":Ljava/lang/String;
    invoke-interface {v3, v7}, Landroid/content/SharedPreferences$Editor;->remove(Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    goto :goto_2

    .line 177
    .end local v7    # "k":Ljava/lang/String;
    :cond_2
    invoke-interface {v3}, Landroid/content/SharedPreferences$Editor;->apply()V

    .line 178
    new-instance v6, Lcom/getcapacitor/JSObject;

    invoke-direct {v6}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 179
    .local v6, "o":Lcom/getcapacitor/JSObject;
    const-string v7, "ok"

    const/4 v8, 0x1

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 180
    const-string v7, "cancelled"

    invoke-interface {v5}, Ljava/util/List;->size()I

    move-result v8

    invoke-virtual {v6, v7, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 181
    invoke-virtual {p1, v6}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 182
    return-void
.end method

.method public isAvailable(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 37
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 38
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "available"

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 39
    invoke-virtual {p0}, Lcom/forge/live/JobBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-static {v1}, Lcom/forge/live/JobBridgePlugin;->canScheduleExact(Landroid/content/Context;)Z

    move-result v1

    const-string v2, "exact"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 40
    const-string v1, "minIntervalMs"

    const v2, 0xea60

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 41
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 42
    return-void
.end method

.method public list(Lcom/getcapacitor/PluginCall;)V
    .locals 18
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 186
    move-object/from16 v1, p1

    const-string v2, "notify"

    const-string v3, "intervalMs"

    const-string v4, "type"

    const-string v5, "atMs"

    const-string v6, "text"

    const-string v7, "title"

    const-string v8, "id"

    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/JobBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    const-string v9, "forge_jobs_v1"

    const/4 v10, 0x0

    invoke-virtual {v0, v9, v10}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v9

    .line 187
    .local v9, "prefs":Landroid/content/SharedPreferences;
    const/4 v0, 0x0

    const-string v10, "appId"

    invoke-virtual {v1, v10, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    .line 188
    .local v11, "appId":Ljava/lang/String;
    new-instance v0, Lcom/getcapacitor/JSArray;

    invoke-direct {v0}, Lcom/getcapacitor/JSArray;-><init>()V

    move-object v12, v0

    .line 189
    .local v12, "arr":Lcom/getcapacitor/JSArray;
    invoke-interface {v9}, Landroid/content/SharedPreferences;->getAll()Ljava/util/Map;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v13

    :goto_0
    invoke-interface {v13}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-interface {v13}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    move-object v14, v0

    check-cast v14, Ljava/util/Map$Entry;

    .line 191
    .local v14, "e":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/String;*>;"
    :try_start_0
    new-instance v0, Lorg/json/JSONObject;

    invoke-interface {v14}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v15

    invoke-static {v15}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v15

    invoke-direct {v0, v15}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_3

    .line 192
    .local v0, "job":Lorg/json/JSONObject;
    if-eqz v11, :cond_0

    :try_start_1
    invoke-virtual {v11}, Ljava/lang/String;->isEmpty()Z

    move-result v15

    if-nez v15, :cond_0

    invoke-virtual {v0, v10}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v11, v15}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v15
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    if-nez v15, :cond_0

    goto :goto_0

    .line 203
    .end local v0    # "job":Lorg/json/JSONObject;
    :catch_0
    move-exception v0

    move-object/from16 v16, v7

    move-object/from16 v17, v9

    move-object v9, v6

    goto :goto_1

    .line 193
    .restart local v0    # "job":Lorg/json/JSONObject;
    :cond_0
    :try_start_2
    new-instance v15, Lcom/getcapacitor/JSObject;

    invoke-direct {v15}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 194
    .local v15, "o":Lcom/getcapacitor/JSObject;
    invoke-interface {v14}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v16
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_3

    move-object/from16 v17, v9

    .end local v9    # "prefs":Landroid/content/SharedPreferences;
    .local v17, "prefs":Landroid/content/SharedPreferences;
    :try_start_3
    move-object/from16 v9, v16

    check-cast v9, Ljava/lang/String;

    invoke-virtual {v0, v8, v9}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v15, v8, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 195
    invoke-virtual {v0, v10}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v15, v10, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 196
    invoke-virtual {v0, v7}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v15, v7, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 197
    invoke-virtual {v0, v6}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v15, v6, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_2

    .line 198
    move-object v9, v6

    move-object/from16 v16, v7

    :try_start_4
    invoke-virtual {v0, v5}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;)J

    move-result-wide v6

    invoke-virtual {v15, v5, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 199
    const-string v6, "once"

    invoke-virtual {v0, v4, v6}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v15, v4, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 200
    invoke-virtual {v0, v3}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;)J

    move-result-wide v6

    invoke-virtual {v15, v3, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 201
    const/4 v6, 0x1

    invoke-virtual {v0, v2, v6}, Lorg/json/JSONObject;->optBoolean(Ljava/lang/String;Z)Z

    move-result v6

    invoke-virtual {v15, v2, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 202
    invoke-virtual {v12, v15}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_1

    .line 203
    nop

    .end local v0    # "job":Lorg/json/JSONObject;
    .end local v15    # "o":Lcom/getcapacitor/JSObject;
    goto :goto_1

    :catch_1
    move-exception v0

    goto :goto_1

    :catch_2
    move-exception v0

    move-object v9, v6

    move-object/from16 v16, v7

    goto :goto_1

    .end local v17    # "prefs":Landroid/content/SharedPreferences;
    .restart local v9    # "prefs":Landroid/content/SharedPreferences;
    :catch_3
    move-exception v0

    move-object/from16 v16, v7

    move-object/from16 v17, v9

    move-object v9, v6

    .line 204
    .end local v9    # "prefs":Landroid/content/SharedPreferences;
    .end local v14    # "e":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/String;*>;"
    .restart local v17    # "prefs":Landroid/content/SharedPreferences;
    :goto_1
    move-object v6, v9

    move-object/from16 v7, v16

    move-object/from16 v9, v17

    goto/16 :goto_0

    .line 205
    .end local v17    # "prefs":Landroid/content/SharedPreferences;
    .restart local v9    # "prefs":Landroid/content/SharedPreferences;
    :cond_1
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 206
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    const-string v2, "jobs"

    invoke-virtual {v0, v2, v12}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 207
    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 208
    return-void
.end method

.method public listPending(Lcom/getcapacitor/PluginCall;)V
    .locals 19
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 212
    move-object/from16 v1, p1

    const-string v2, "firedAt"

    const-string v3, "text"

    const-string v4, "title"

    const-string v5, "payload"

    const-string v6, "jobId"

    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/JobBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    const-string v7, "forge_jobs_pending_v1"

    const/4 v8, 0x0

    invoke-virtual {v0, v7, v8}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v7

    .line 213
    .local v7, "pending":Landroid/content/SharedPreferences;
    const-string v0, ""

    const-string v8, "appId"

    invoke-virtual {v1, v8, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    .line 214
    .local v9, "appId":Ljava/lang/String;
    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    const/4 v10, 0x1

    invoke-static {v10}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v11

    const-string v12, "consume"

    invoke-virtual {v1, v12, v11}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v11

    invoke-virtual {v0, v11}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v0

    xor-int/2addr v0, v10

    move v10, v0

    .line 215
    .local v10, "consume":Z
    new-instance v0, Lcom/getcapacitor/JSArray;

    invoke-direct {v0}, Lcom/getcapacitor/JSArray;-><init>()V

    move-object v11, v0

    .line 216
    .local v11, "arr":Lcom/getcapacitor/JSArray;
    invoke-interface {v7}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v12

    .line 217
    .local v12, "ed":Landroid/content/SharedPreferences$Editor;
    invoke-interface {v7}, Landroid/content/SharedPreferences;->getAll()Ljava/util/Map;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v13

    :goto_0
    invoke-interface {v13}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_4

    invoke-interface {v13}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    move-object v14, v0

    check-cast v14, Ljava/util/Map$Entry;

    .line 218
    .local v14, "e":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/String;*>;"
    invoke-interface {v14}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v0

    move-object v15, v0

    check-cast v15, Ljava/lang/String;

    .line 219
    .local v15, "key":Ljava/lang/String;
    if-eqz v9, :cond_0

    invoke-virtual {v9}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    move-object/from16 v16, v7

    .end local v7    # "pending":Landroid/content/SharedPreferences;
    .local v16, "pending":Landroid/content/SharedPreferences;
    const-string v7, "::"

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v15, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_1

    move-object/from16 v7, v16

    goto :goto_0

    .end local v16    # "pending":Landroid/content/SharedPreferences;
    .restart local v7    # "pending":Landroid/content/SharedPreferences;
    :cond_0
    move-object/from16 v16, v7

    .line 221
    .end local v7    # "pending":Landroid/content/SharedPreferences;
    .restart local v16    # "pending":Landroid/content/SharedPreferences;
    :cond_1
    :try_start_0
    new-instance v0, Lorg/json/JSONObject;

    invoke-interface {v14}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v7

    invoke-static {v7}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v7

    invoke-direct {v0, v7}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    .line 222
    .local v0, "p":Lorg/json/JSONObject;
    new-instance v7, Lcom/getcapacitor/JSObject;

    invoke-direct {v7}, Lcom/getcapacitor/JSObject;-><init>()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_2

    .line 223
    .local v7, "o":Lcom/getcapacitor/JSObject;
    move-object/from16 v17, v9

    .end local v9    # "appId":Ljava/lang/String;
    .local v17, "appId":Ljava/lang/String;
    :try_start_1
    invoke-virtual {v0, v6}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v7, v6, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 224
    invoke-virtual {v0, v8}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v7, v8, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 225
    invoke-virtual {v0, v5}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v7, v5, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 226
    invoke-virtual {v0, v4}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v7, v4, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 227
    invoke-virtual {v0, v3}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v7, v3, v9}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    .line 228
    move-object v9, v3

    move-object/from16 v18, v4

    :try_start_2
    invoke-virtual {v0, v2}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;)J

    move-result-wide v3

    invoke-virtual {v7, v2, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 229
    invoke-virtual {v11, v7}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    .line 230
    if-eqz v10, :cond_2

    invoke-interface {v12, v15}, Landroid/content/SharedPreferences$Editor;->remove(Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    .line 233
    .end local v0    # "p":Lorg/json/JSONObject;
    .end local v7    # "o":Lcom/getcapacitor/JSObject;
    :cond_2
    goto :goto_2

    .line 231
    :catch_0
    move-exception v0

    goto :goto_1

    :catch_1
    move-exception v0

    move-object v9, v3

    move-object/from16 v18, v4

    goto :goto_1

    .end local v17    # "appId":Ljava/lang/String;
    .restart local v9    # "appId":Ljava/lang/String;
    :catch_2
    move-exception v0

    move-object/from16 v18, v4

    move-object/from16 v17, v9

    move-object v9, v3

    .line 232
    .end local v9    # "appId":Ljava/lang/String;
    .local v0, "ignored":Ljava/lang/Exception;
    .restart local v17    # "appId":Ljava/lang/String;
    :goto_1
    if-eqz v10, :cond_3

    invoke-interface {v12, v15}, Landroid/content/SharedPreferences$Editor;->remove(Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    .line 234
    .end local v0    # "ignored":Ljava/lang/Exception;
    .end local v14    # "e":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/String;*>;"
    .end local v15    # "key":Ljava/lang/String;
    :cond_3
    :goto_2
    move-object v3, v9

    move-object/from16 v7, v16

    move-object/from16 v9, v17

    move-object/from16 v4, v18

    goto/16 :goto_0

    .line 235
    .end local v16    # "pending":Landroid/content/SharedPreferences;
    .end local v17    # "appId":Ljava/lang/String;
    .local v7, "pending":Landroid/content/SharedPreferences;
    .restart local v9    # "appId":Ljava/lang/String;
    :cond_4
    move-object/from16 v16, v7

    move-object/from16 v17, v9

    .end local v7    # "pending":Landroid/content/SharedPreferences;
    .end local v9    # "appId":Ljava/lang/String;
    .restart local v16    # "pending":Landroid/content/SharedPreferences;
    .restart local v17    # "appId":Ljava/lang/String;
    if-eqz v10, :cond_5

    invoke-interface {v12}, Landroid/content/SharedPreferences$Editor;->apply()V

    .line 236
    :cond_5
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 237
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    const-string v2, "pending"

    invoke-virtual {v0, v2, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 238
    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 239
    return-void
.end method

.method public schedule(Lcom/getcapacitor/PluginCall;)V
    .locals 40
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 47
    move-object/from16 v1, p1

    const-string v2, "payload"

    const-string v3, "notify"

    const-string v4, "forge_jobs"

    const-string v5, "channel"

    const-string v6, "Reminder"

    const-string v7, "text"

    const-string v8, "title"

    const-string v0, "once"

    const-string v9, "Forge app"

    const-string v10, "appTitle"

    const-string v11, "appId"

    const-string v12, "data"

    const-string v13, "intervalMs"

    const-string v14, "atMs"

    const-string v15, "id"

    move-object/from16 v16, v12

    const-string v12, "type"

    :try_start_0
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/JobBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v17

    move-object/from16 v18, v17

    .line 48
    .local v18, "ctx":Landroid/content/Context;
    invoke-virtual {v1, v15}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v17
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_4

    .line 49
    .local v17, "id":Ljava/lang/String;
    move-object/from16 v19, v15

    const-string v15, ""

    if-eqz v17, :cond_1

    :try_start_1
    invoke-virtual/range {v17 .. v17}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v21

    invoke-virtual/range {v21 .. v21}, Ljava/lang/String;->isEmpty()Z

    move-result v21

    if-eqz v21, :cond_0

    goto :goto_0

    :cond_0
    move-object/from16 v21, v2

    move-object/from16 v22, v3

    move-object/from16 v23, v4

    move-object/from16 v24, v5

    goto :goto_1

    .line 50
    :cond_1
    :goto_0
    move-object/from16 v21, v2

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    move-object/from16 v22, v3

    const-string v3, "job_"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v3

    invoke-virtual {v3}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v3

    move-object/from16 v23, v4

    const-string v4, "-"

    invoke-virtual {v3, v4, v15}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v3

    const/16 v4, 0xc

    move-object/from16 v24, v5

    const/4 v5, 0x0

    invoke-virtual {v3, v5, v4}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    move-object/from16 v17, v2

    .line 52
    :goto_1
    invoke-static/range {v17 .. v17}, Lcom/forge/live/JobBridgePlugin;->sanitize(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 54
    .end local v17    # "id":Ljava/lang/String;
    .local v2, "id":Ljava/lang/String;
    invoke-virtual {v1, v11, v15}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 55
    .local v3, "appId":Ljava/lang/String;
    if-nez v3, :cond_2

    move-object v3, v15

    .line 56
    :cond_2
    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    move-object v3, v4

    .line 57
    invoke-virtual {v1, v10, v9}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    .line 59
    .local v4, "appTitle":Ljava/lang/String;
    const-wide/16 v25, 0x0

    .line 60
    .local v25, "atMs":J
    invoke-virtual {v1, v14}, Lcom/getcapacitor/PluginCall;->getDouble(Ljava/lang/String;)Ljava/lang/Double;

    move-result-object v5

    .line 61
    .local v5, "at":Ljava/lang/Double;
    const-wide/16 v27, 0x0

    if-eqz v5, :cond_3

    invoke-virtual {v5}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v29

    cmpl-double v15, v29, v27

    if-lez v15, :cond_3

    invoke-virtual {v5}, Ljava/lang/Double;->longValue()J

    move-result-wide v29

    move-wide/from16 v25, v29

    .line 62
    :cond_3
    const-wide/16 v29, 0x0

    cmp-long v15, v25, v29

    if-gtz v15, :cond_4

    .line 63
    const-string v15, "inMs"

    invoke-virtual {v1, v15}, Lcom/getcapacitor/PluginCall;->getDouble(Ljava/lang/String;)Ljava/lang/Double;

    move-result-object v15

    .line 64
    .local v15, "inMs":Ljava/lang/Double;
    if-eqz v15, :cond_4

    invoke-virtual {v15}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v31

    cmpl-double v17, v31, v27

    if-lez v17, :cond_4

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v31

    invoke-virtual {v15}, Ljava/lang/Double;->longValue()J

    move-result-wide v33

    add-long v25, v31, v33

    .line 66
    .end local v15    # "inMs":Ljava/lang/Double;
    :cond_4
    cmp-long v15, v25, v29

    if-gtz v15, :cond_6

    .line 67
    const-string v15, "inSeconds"

    invoke-virtual {v1, v15}, Lcom/getcapacitor/PluginCall;->getDouble(Ljava/lang/String;)Ljava/lang/Double;

    move-result-object v15

    .line 68
    .local v15, "inSec":Ljava/lang/Double;
    if-eqz v15, :cond_5

    invoke-virtual {v15}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v31

    cmpl-double v17, v31, v27

    if-lez v17, :cond_5

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v27

    invoke-virtual {v15}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v31

    const-wide v33, 0x408f400000000000L    # 1000.0

    move-object/from16 v17, v14

    move-object/from16 v35, v15

    .end local v15    # "inSec":Ljava/lang/Double;
    .local v35, "inSec":Ljava/lang/Double;
    mul-double v14, v31, v33

    double-to-long v14, v14

    add-long v25, v27, v14

    goto :goto_2

    .end local v35    # "inSec":Ljava/lang/Double;
    .restart local v15    # "inSec":Ljava/lang/Double;
    :cond_5
    move-object/from16 v17, v14

    move-object/from16 v35, v15

    .end local v15    # "inSec":Ljava/lang/Double;
    .restart local v35    # "inSec":Ljava/lang/Double;
    goto :goto_2

    .line 66
    .end local v35    # "inSec":Ljava/lang/Double;
    :cond_6
    move-object/from16 v17, v14

    .line 70
    :goto_2
    cmp-long v14, v25, v29

    if-gtz v14, :cond_7

    .line 71
    const-string v0, "Provide atMs, inMs, or inSeconds"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 72
    return-void

    .line 75
    :cond_7
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v14

    const-wide/16 v27, 0x1388

    add-long v14, v14, v27

    .line 76
    .local v14, "minAt":J
    cmp-long v27, v25, v14

    if-gez v27, :cond_8

    move-wide/from16 v25, v14

    move-wide/from16 v27, v14

    goto :goto_3

    :cond_8
    move-wide/from16 v27, v14

    move-wide/from16 v14, v25

    .line 78
    .end local v25    # "atMs":J
    .local v14, "atMs":J
    .local v27, "minAt":J
    :goto_3
    invoke-virtual {v1, v12, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v25

    .line 79
    .local v25, "type":Ljava/lang/String;
    if-nez v25, :cond_9

    move-object/from16 v25, v0

    :cond_9
    move-object/from16 v26, v5

    move-object/from16 v5, v25

    .line 80
    .end local v25    # "type":Ljava/lang/String;
    .local v5, "type":Ljava/lang/String;
    .local v26, "at":Ljava/lang/Double;
    const-wide/16 v29, 0x0

    .line 81
    .local v29, "intervalMs":J
    invoke-virtual {v1, v13}, Lcom/getcapacitor/PluginCall;->getDouble(Ljava/lang/String;)Ljava/lang/Double;

    move-result-object v0

    move-object/from16 v25, v0

    .line 82
    .local v25, "interval":Ljava/lang/Double;
    if-eqz v25, :cond_a

    invoke-virtual/range {v25 .. v25}, Ljava/lang/Double;->longValue()J

    move-result-wide v31

    move-wide/from16 v29, v31

    :cond_a
    move-object/from16 v31, v13

    move-wide/from16 v32, v14

    move-wide/from16 v13, v29

    .line 83
    .end local v14    # "atMs":J
    .end local v29    # "intervalMs":J
    .local v13, "intervalMs":J
    .local v32, "atMs":J
    const-string v0, "interval"

    invoke-virtual {v0, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_b

    const-wide/32 v29, 0xea60

    cmp-long v0, v13, v29

    if-gez v0, :cond_b

    .line 84
    const-string v0, "intervalMs minimum is 60000 (1 minute)"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 85
    return-void

    .line 88
    :cond_b
    invoke-virtual {v1, v8, v4}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    move-object v15, v0

    .line 89
    .local v15, "title":Ljava/lang/String;
    const-string v0, "message"

    invoke-virtual {v1, v0, v6}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v7, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    move-object/from16 v29, v0

    .line 90
    .local v29, "text":Ljava/lang/String;
    move-object/from16 v30, v6

    move-object/from16 v6, v24

    move-object/from16 v39, v23

    move-object/from16 v23, v9

    move-object/from16 v9, v39

    invoke-virtual {v1, v6, v9}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    move-object/from16 v24, v0

    .line 91
    .local v24, "channel":Ljava/lang/String;
    sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    move-object/from16 v34, v9

    const/4 v9, 0x1

    move-wide/from16 v35, v13

    .end local v13    # "intervalMs":J
    .local v35, "intervalMs":J
    invoke-static {v9}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v13

    move-object/from16 v14, v22

    invoke-virtual {v1, v14, v13}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v13

    invoke-virtual {v0, v13}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_c

    const/4 v0, 0x1

    goto :goto_4

    :cond_c
    const/4 v0, 0x0

    :goto_4
    move v13, v0

    .line 93
    .local v13, "notify":Z
    const/4 v0, 0x0

    move-object/from16 v9, v21

    invoke-virtual {v1, v9, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_4

    move-object/from16 v21, v0

    .line 94
    .local v21, "payload":Ljava/lang/String;
    const-string v1, "jobId"

    if-nez v21, :cond_d

    :try_start_2
    invoke-virtual/range {p1 .. p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v0

    if-eqz v0, :cond_d

    invoke-virtual/range {p1 .. p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v0

    move-object/from16 v37, v9

    move-object/from16 v9, v16

    invoke-virtual {v0, v9}, Lcom/getcapacitor/JSObject;->has(Ljava/lang/String;)Z

    move-result v0
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_3

    if-eqz v0, :cond_e

    .line 96
    :try_start_3
    invoke-virtual/range {p1 .. p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v0

    invoke-virtual {v0, v9}, Lcom/getcapacitor/JSObject;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    .line 97
    .local v0, "data":Ljava/lang/Object;
    new-instance v16, Lorg/json/JSONObject;

    invoke-direct/range {v16 .. v16}, Lorg/json/JSONObject;-><init>()V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_2

    move-object/from16 v38, v16

    .line 98
    .local v38, "p":Lorg/json/JSONObject;
    move/from16 v16, v13

    move-object/from16 v13, v38

    .end local v38    # "p":Lorg/json/JSONObject;
    .local v13, "p":Lorg/json/JSONObject;
    .local v16, "notify":Z
    :try_start_4
    invoke-virtual {v13, v1, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_1

    .line 99
    move-object/from16 v38, v14

    :try_start_5
    const-string v14, "job"

    invoke-virtual {v13, v12, v14}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 100
    invoke-virtual {v13, v9, v0}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 101
    invoke-virtual {v13}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v9
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_0

    move-object/from16 v21, v9

    .line 102
    .end local v0    # "data":Ljava/lang/Object;
    .end local v13    # "p":Lorg/json/JSONObject;
    :goto_5
    goto :goto_6

    :catch_0
    move-exception v0

    goto :goto_5

    :catch_1
    move-exception v0

    move-object/from16 v38, v14

    goto :goto_5

    .end local v16    # "notify":Z
    .local v13, "notify":Z
    :catch_2
    move-exception v0

    move/from16 v16, v13

    move-object/from16 v38, v14

    .end local v13    # "notify":Z
    .restart local v16    # "notify":Z
    goto :goto_5

    .line 137
    .end local v2    # "id":Ljava/lang/String;
    .end local v3    # "appId":Ljava/lang/String;
    .end local v4    # "appTitle":Ljava/lang/String;
    .end local v5    # "type":Ljava/lang/String;
    .end local v15    # "title":Ljava/lang/String;
    .end local v16    # "notify":Z
    .end local v18    # "ctx":Landroid/content/Context;
    .end local v21    # "payload":Ljava/lang/String;
    .end local v24    # "channel":Ljava/lang/String;
    .end local v25    # "interval":Ljava/lang/Double;
    .end local v26    # "at":Ljava/lang/Double;
    .end local v27    # "minAt":J
    .end local v29    # "text":Ljava/lang/String;
    .end local v32    # "atMs":J
    .end local v35    # "intervalMs":J
    :catch_3
    move-exception v0

    move-object/from16 v1, p1

    goto/16 :goto_c

    .line 94
    .restart local v2    # "id":Ljava/lang/String;
    .restart local v3    # "appId":Ljava/lang/String;
    .restart local v4    # "appTitle":Ljava/lang/String;
    .restart local v5    # "type":Ljava/lang/String;
    .restart local v13    # "notify":Z
    .restart local v15    # "title":Ljava/lang/String;
    .restart local v18    # "ctx":Landroid/content/Context;
    .restart local v21    # "payload":Ljava/lang/String;
    .restart local v24    # "channel":Ljava/lang/String;
    .restart local v25    # "interval":Ljava/lang/Double;
    .restart local v26    # "at":Ljava/lang/Double;
    .restart local v27    # "minAt":J
    .restart local v29    # "text":Ljava/lang/String;
    .restart local v32    # "atMs":J
    .restart local v35    # "intervalMs":J
    :cond_d
    move-object/from16 v37, v9

    :cond_e
    move/from16 v16, v13

    move-object/from16 v38, v14

    .line 104
    .end local v13    # "notify":Z
    .restart local v16    # "notify":Z
    :goto_6
    if-nez v21, :cond_f

    .line 105
    :try_start_6
    new-instance v0, Lorg/json/JSONObject;

    invoke-direct {v0}, Lorg/json/JSONObject;-><init>()V

    .line 106
    .local v0, "p":Lorg/json/JSONObject;
    invoke-virtual {v0, v1, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 107
    const-string v1, "job"

    invoke-virtual {v0, v12, v1}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 108
    invoke-virtual {v0}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v1

    move-object/from16 v21, v1

    move-object/from16 v0, v21

    goto :goto_7

    .line 104
    .end local v0    # "p":Lorg/json/JSONObject;
    :cond_f
    move-object/from16 v0, v21

    .line 111
    .end local v21    # "payload":Ljava/lang/String;
    .local v0, "payload":Ljava/lang/String;
    :goto_7
    new-instance v1, Lorg/json/JSONObject;

    invoke-direct {v1}, Lorg/json/JSONObject;-><init>()V

    .line 112
    .local v1, "job":Lorg/json/JSONObject;
    move-object/from16 v9, v19

    invoke-virtual {v1, v9, v2}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 113
    invoke-virtual {v1, v11, v3}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 114
    if-eqz v4, :cond_10

    move-object v11, v4

    goto :goto_8

    :cond_10
    move-object/from16 v11, v23

    :goto_8
    invoke-virtual {v1, v10, v11}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 115
    if-eqz v15, :cond_11

    move-object v10, v15

    goto :goto_9

    :cond_11
    const-string v10, "Forge"

    :goto_9
    invoke-virtual {v1, v8, v10}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 116
    if-eqz v29, :cond_12

    move-object/from16 v8, v29

    goto :goto_a

    :cond_12
    move-object/from16 v8, v30

    :goto_a
    invoke-virtual {v1, v7, v8}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 117
    if-eqz v24, :cond_13

    move-object/from16 v7, v24

    goto :goto_b

    :cond_13
    move-object/from16 v7, v34

    :goto_b
    invoke-virtual {v1, v6, v7}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 118
    move-object/from16 v8, v17

    move-wide/from16 v6, v32

    .end local v32    # "atMs":J
    .local v6, "atMs":J
    invoke-virtual {v1, v8, v6, v7}, Lorg/json/JSONObject;->put(Ljava/lang/String;J)Lorg/json/JSONObject;

    .line 119
    invoke-virtual {v1, v12, v5}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 120
    move-object/from16 v13, v31

    move-wide/from16 v10, v35

    .end local v35    # "intervalMs":J
    .local v10, "intervalMs":J
    invoke-virtual {v1, v13, v10, v11}, Lorg/json/JSONObject;->put(Ljava/lang/String;J)Lorg/json/JSONObject;

    .line 121
    move/from16 v14, v16

    move-object/from16 v16, v3

    move-object/from16 v3, v38

    .end local v3    # "appId":Ljava/lang/String;
    .local v14, "notify":Z
    .local v16, "appId":Ljava/lang/String;
    invoke-virtual {v1, v3, v14}, Lorg/json/JSONObject;->put(Ljava/lang/String;Z)Lorg/json/JSONObject;

    .line 122
    move-object/from16 v3, v37

    invoke-virtual {v1, v3, v0}, Lorg/json/JSONObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lorg/json/JSONObject;

    .line 123
    const-string v3, "createdAt"

    move/from16 v19, v14

    move-object/from16 v17, v15

    .end local v14    # "notify":Z
    .end local v15    # "title":Ljava/lang/String;
    .local v17, "title":Ljava/lang/String;
    .local v19, "notify":Z
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v14

    invoke-virtual {v1, v3, v14, v15}, Lorg/json/JSONObject;->put(Ljava/lang/String;J)Lorg/json/JSONObject;

    .line 125
    const-string v3, "forge_jobs_v1"

    move-object/from16 v14, v18

    const/4 v15, 0x0

    .end local v18    # "ctx":Landroid/content/Context;
    .local v14, "ctx":Landroid/content/Context;
    invoke-virtual {v14, v3, v15}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v3

    .line 126
    .local v3, "prefs":Landroid/content/SharedPreferences;
    invoke-interface {v3}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v15

    move-object/from16 v18, v0

    .end local v0    # "payload":Ljava/lang/String;
    .local v18, "payload":Ljava/lang/String;
    invoke-virtual {v1}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-interface {v15, v2, v0}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V

    .line 127
    invoke-static {v14, v2, v6, v7}, Lcom/forge/live/JobBridgePlugin;->scheduleAlarm(Landroid/content/Context;Ljava/lang/String;J)V

    .line 129
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 130
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    const-string v15, "ok"

    move-object/from16 v20, v1

    const/4 v1, 0x1

    .end local v1    # "job":Lorg/json/JSONObject;
    .local v20, "job":Lorg/json/JSONObject;
    invoke-virtual {v0, v15, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 131
    invoke-virtual {v0, v9, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 132
    invoke-virtual {v0, v8, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 133
    invoke-virtual {v0, v12, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 134
    invoke-virtual {v0, v13, v10, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 135
    const-string v1, "exact"

    invoke-static {v14}, Lcom/forge/live/JobBridgePlugin;->canScheduleExact(Landroid/content/Context;)Z

    move-result v8

    invoke-virtual {v0, v1, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;
    :try_end_6
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_6} :catch_3

    .line 136
    move-object/from16 v1, p1

    :try_start_7
    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_7} :catch_4

    .line 139
    .end local v0    # "ret":Lcom/getcapacitor/JSObject;
    .end local v2    # "id":Ljava/lang/String;
    .end local v3    # "prefs":Landroid/content/SharedPreferences;
    .end local v4    # "appTitle":Ljava/lang/String;
    .end local v5    # "type":Ljava/lang/String;
    .end local v6    # "atMs":J
    .end local v10    # "intervalMs":J
    .end local v14    # "ctx":Landroid/content/Context;
    .end local v16    # "appId":Ljava/lang/String;
    .end local v17    # "title":Ljava/lang/String;
    .end local v18    # "payload":Ljava/lang/String;
    .end local v19    # "notify":Z
    .end local v20    # "job":Lorg/json/JSONObject;
    .end local v24    # "channel":Ljava/lang/String;
    .end local v25    # "interval":Ljava/lang/Double;
    .end local v26    # "at":Ljava/lang/Double;
    .end local v27    # "minAt":J
    .end local v29    # "text":Ljava/lang/String;
    goto :goto_d

    .line 137
    :catch_4
    move-exception v0

    .line 138
    .local v0, "e":Ljava/lang/Exception;
    :goto_c
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "schedule failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 140
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_d
    return-void
.end method
