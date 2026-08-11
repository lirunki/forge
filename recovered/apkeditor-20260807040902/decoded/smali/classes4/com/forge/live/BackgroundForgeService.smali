.class public Lcom/forge/live/BackgroundForgeService;
.super Landroid/app/Service;
.source "BackgroundForgeService.java"


# static fields
.field public static final ACTION_START:Ljava/lang/String; = "com.forge.live.bg.START"

.field public static final ACTION_STOP:Ljava/lang/String; = "com.forge.live.bg.STOP"

.field public static final ACTION_UPDATE:Ljava/lang/String; = "com.forge.live.bg.UPDATE"

.field public static final CHANNEL_ID:Ljava/lang/String; = "forge_bg"

.field public static final EXTRA_TEXT:Ljava/lang/String; = "text"

.field public static final EXTRA_TITLE:Ljava/lang/String; = "title"

.field public static final NOTIFICATION_ID:I = 0xa7f9


# instance fields
.field private text:Ljava/lang/String;

.field private title:Ljava/lang/String;

.field private wakeLock:Landroid/os/PowerManager$WakeLock;


# direct methods
.method public constructor <init>()V
    .locals 1

    .line 18
    invoke-direct {p0}, Landroid/app/Service;-><init>()V

    .line 29
    const-string v0, "Forge"

    iput-object v0, p0, Lcom/forge/live/BackgroundForgeService;->title:Ljava/lang/String;

    .line 30
    const-string v0, "Working in the background\u2026"

    iput-object v0, p0, Lcom/forge/live/BackgroundForgeService;->text:Ljava/lang/String;

    return-void
.end method

.method private acquireWakeLock()V
    .locals 4

    .line 119
    iget-object v0, p0, Lcom/forge/live/BackgroundForgeService;->wakeLock:Landroid/os/PowerManager$WakeLock;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Landroid/os/PowerManager$WakeLock;->isHeld()Z

    move-result v0

    if-eqz v0, :cond_0

    return-void

    .line 120
    :cond_0
    const-string v0, "power"

    invoke-virtual {p0, v0}, Lcom/forge/live/BackgroundForgeService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/os/PowerManager;

    .line 121
    .local v0, "pm":Landroid/os/PowerManager;
    if-nez v0, :cond_1

    return-void

    .line 122
    :cond_1
    const/4 v1, 0x1

    const-string v2, "forge:bg"

    invoke-virtual {v0, v1, v2}, Landroid/os/PowerManager;->newWakeLock(ILjava/lang/String;)Landroid/os/PowerManager$WakeLock;

    move-result-object v1

    iput-object v1, p0, Lcom/forge/live/BackgroundForgeService;->wakeLock:Landroid/os/PowerManager$WakeLock;

    .line 123
    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Landroid/os/PowerManager$WakeLock;->setReferenceCounted(Z)V

    .line 124
    iget-object v1, p0, Lcom/forge/live/BackgroundForgeService;->wakeLock:Landroid/os/PowerManager$WakeLock;

    const-wide/32 v2, 0x6ddd00

    invoke-virtual {v1, v2, v3}, Landroid/os/PowerManager$WakeLock;->acquire(J)V

    .line 125
    return-void
.end method

.method private buildNotification(Ljava/lang/String;Ljava/lang/String;)Landroid/app/Notification;
    .locals 6
    .param p1, "title"    # Ljava/lang/String;
    .param p2, "text"    # Ljava/lang/String;

    .line 80
    invoke-virtual {p0}, Lcom/forge/live/BackgroundForgeService;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    invoke-virtual {p0}, Lcom/forge/live/BackgroundForgeService;->getPackageName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getLaunchIntentForPackage(Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v0

    .line 81
    .local v0, "launch":Landroid/content/Intent;
    if-nez v0, :cond_0

    new-instance v1, Landroid/content/Intent;

    const-class v2, Lcom/forge/live/MainActivity;

    invoke-direct {v1, p0, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    move-object v0, v1

    .line 82
    :cond_0
    const/high16 v1, 0x24000000

    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 84
    const/high16 v1, 0x8000000

    .line 85
    .local v1, "piFlags":I
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x17

    if-lt v2, v3, :cond_1

    .line 86
    const/high16 v2, 0x4000000

    or-int/2addr v1, v2

    .line 88
    :cond_1
    const/4 v2, 0x0

    invoke-static {p0, v2, v0, v1}, Landroid/app/PendingIntent;->getActivity(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v2

    .line 90
    .local v2, "contentIntent":Landroid/app/PendingIntent;
    new-instance v3, Landroidx/core/app/NotificationCompat$Builder;

    const-string v4, "forge_bg"

    invoke-direct {v3, p0, v4}, Landroidx/core/app/NotificationCompat$Builder;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 91
    if-eqz p1, :cond_2

    move-object v4, p1

    goto :goto_0

    :cond_2
    const-string v4, "Forge"

    :goto_0
    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setContentTitle(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 92
    if-eqz p2, :cond_3

    move-object v4, p2

    goto :goto_1

    :cond_3
    const-string v4, "Working\u2026"

    :goto_1
    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setContentText(Ljava/lang/CharSequence;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 93
    const v4, 0x108003e    # @android:drawable/ic_menu_edit

    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setSmallIcon(I)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 94
    invoke-virtual {v3, v2}, Landroidx/core/app/NotificationCompat$Builder;->setContentIntent(Landroid/app/PendingIntent;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 95
    const/4 v4, 0x1

    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setOngoing(Z)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 96
    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setOnlyAlertOnce(Z)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 97
    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setForegroundServiceBehavior(I)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 98
    const-string v5, "service"

    invoke-virtual {v3, v5}, Landroidx/core/app/NotificationCompat$Builder;->setCategory(Ljava/lang/String;)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 99
    const/4 v5, -0x1

    invoke-virtual {v3, v5}, Landroidx/core/app/NotificationCompat$Builder;->setPriority(I)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 100
    invoke-virtual {v3, v4}, Landroidx/core/app/NotificationCompat$Builder;->setVisibility(I)Landroidx/core/app/NotificationCompat$Builder;

    move-result-object v3

    .line 101
    invoke-virtual {v3}, Landroidx/core/app/NotificationCompat$Builder;->build()Landroid/app/Notification;

    move-result-object v3

    .line 90
    return-object v3
.end method

.method private createChannel()V
    .locals 5

    .line 105
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1a

    if-ge v0, v1, :cond_0

    return-void

    .line 106
    :cond_0
    const-string v0, "notification"

    invoke-virtual {p0, v0}, Lcom/forge/live/BackgroundForgeService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/NotificationManager;

    .line 107
    .local v0, "nm":Landroid/app/NotificationManager;
    if-nez v0, :cond_1

    return-void

    .line 108
    :cond_1
    new-instance v1, Landroid/app/NotificationChannel;

    const-string v2, "Forge background"

    const/4 v3, 0x2

    const-string v4, "forge_bg"

    invoke-direct {v1, v4, v2, v3}, Landroid/app/NotificationChannel;-><init>(Ljava/lang/String;Ljava/lang/CharSequence;I)V

    .line 113
    .local v1, "channel":Landroid/app/NotificationChannel;
    const-string v2, "Keeps app generation running in the background"

    invoke-virtual {v1, v2}, Landroid/app/NotificationChannel;->setDescription(Ljava/lang/String;)V

    .line 114
    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Landroid/app/NotificationChannel;->setShowBadge(Z)V

    .line 115
    invoke-virtual {v0, v1}, Landroid/app/NotificationManager;->createNotificationChannel(Landroid/app/NotificationChannel;)V

    .line 116
    return-void
.end method

.method private releaseWakeLock()V
    .locals 1

    .line 128
    iget-object v0, p0, Lcom/forge/live/BackgroundForgeService;->wakeLock:Landroid/os/PowerManager$WakeLock;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Landroid/os/PowerManager$WakeLock;->isHeld()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 129
    :try_start_0
    iget-object v0, p0, Lcom/forge/live/BackgroundForgeService;->wakeLock:Landroid/os/PowerManager$WakeLock;

    invoke-virtual {v0}, Landroid/os/PowerManager$WakeLock;->release()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 131
    :cond_0
    :goto_0
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/forge/live/BackgroundForgeService;->wakeLock:Landroid/os/PowerManager$WakeLock;

    .line 132
    return-void
.end method

.method public static start(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    .param p0, "context"    # Landroid/content/Context;
    .param p1, "title"    # Ljava/lang/String;
    .param p2, "text"    # Ljava/lang/String;

    .line 157
    new-instance v0, Landroid/content/Intent;

    const-class v1, Lcom/forge/live/BackgroundForgeService;

    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 158
    .local v0, "i":Landroid/content/Intent;
    const-string v1, "com.forge.live.bg.START"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 159
    if-eqz p1, :cond_0

    const-string v1, "title"

    invoke-virtual {v0, v1, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 160
    :cond_0
    if-eqz p2, :cond_1

    const-string v1, "text"

    invoke-virtual {v0, v1, p2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 161
    :cond_1
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x1a

    if-lt v1, v2, :cond_2

    invoke-virtual {p0, v0}, Landroid/content/Context;->startForegroundService(Landroid/content/Intent;)Landroid/content/ComponentName;

    goto :goto_0

    .line 162
    :cond_2
    invoke-virtual {p0, v0}, Landroid/content/Context;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;

    .line 163
    :goto_0
    return-void
.end method

.method private startAsForeground()V
    .locals 4

    .line 62
    iget-object v0, p0, Lcom/forge/live/BackgroundForgeService;->title:Ljava/lang/String;

    iget-object v1, p0, Lcom/forge/live/BackgroundForgeService;->text:Ljava/lang/String;

    invoke-direct {p0, v0, v1}, Lcom/forge/live/BackgroundForgeService;->buildNotification(Ljava/lang/String;Ljava/lang/String;)Landroid/app/Notification;

    move-result-object v0

    .line 64
    .local v0, "notification":Landroid/app/Notification;
    const v1, 0xa7f9

    :try_start_0
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1d

    if-lt v2, v3, :cond_0

    .line 65
    const/4 v2, 0x1

    .line 66
    .local v2, "types":I
    nop

    .line 68
    const/4 v2, 0x1

    .line 70
    invoke-virtual {p0, v1, v0, v2}, Lcom/forge/live/BackgroundForgeService;->startForeground(ILandroid/app/Notification;I)V

    .line 71
    .end local v2    # "types":I
    goto :goto_0

    .line 72
    :cond_0
    invoke-virtual {p0, v1, v0}, Lcom/forge/live/BackgroundForgeService;->startForeground(ILandroid/app/Notification;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 76
    :goto_0
    goto :goto_1

    .line 74
    :catch_0
    move-exception v2

    .line 75
    .local v2, "e":Ljava/lang/Exception;
    :try_start_1
    invoke-virtual {p0, v1, v0}, Lcom/forge/live/BackgroundForgeService;->startForeground(ILandroid/app/Notification;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    :catch_1
    move-exception v1

    .line 77
    .end local v2    # "e":Ljava/lang/Exception;
    :goto_1
    return-void
.end method

.method public static stop(Landroid/content/Context;)V
    .locals 4
    .param p0, "context"    # Landroid/content/Context;

    .line 175
    new-instance v0, Landroid/content/Intent;

    const-class v1, Lcom/forge/live/BackgroundForgeService;

    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 176
    .local v0, "i":Landroid/content/Intent;
    const-string v2, "com.forge.live.bg.STOP"

    invoke-virtual {v0, v2}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 177
    :try_start_0
    invoke-virtual {p0, v0}, Landroid/content/Context;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 178
    goto :goto_0

    :catch_0
    move-exception v2

    .local v2, "e":Ljava/lang/Exception;
    new-instance v3, Landroid/content/Intent;

    invoke-direct {v3, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    invoke-virtual {p0, v3}, Landroid/content/Context;->stopService(Landroid/content/Intent;)Z

    .line 179
    .end local v2    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method private stopForegroundSafe()V
    .locals 3

    .line 136
    :try_start_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x18

    const/4 v2, 0x1

    if-lt v0, v1, :cond_0

    .line 137
    invoke-virtual {p0, v2}, Lcom/forge/live/BackgroundForgeService;->stopForeground(I)V

    goto :goto_0

    .line 139
    :cond_0
    invoke-virtual {p0, v2}, Lcom/forge/live/BackgroundForgeService;->stopForeground(Z)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 141
    :catch_0
    move-exception v0

    :goto_0
    nop

    .line 142
    return-void
.end method

.method public static update(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    .param p0, "context"    # Landroid/content/Context;
    .param p1, "title"    # Ljava/lang/String;
    .param p2, "text"    # Ljava/lang/String;

    .line 166
    new-instance v0, Landroid/content/Intent;

    const-class v1, Lcom/forge/live/BackgroundForgeService;

    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 167
    .local v0, "i":Landroid/content/Intent;
    const-string v1, "com.forge.live.bg.UPDATE"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 168
    if-eqz p1, :cond_0

    const-string v1, "title"

    invoke-virtual {v0, v1, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 169
    :cond_0
    if-eqz p2, :cond_1

    const-string v1, "text"

    invoke-virtual {v0, v1, p2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 170
    :cond_1
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x1a

    if-lt v1, v2, :cond_2

    invoke-virtual {p0, v0}, Landroid/content/Context;->startForegroundService(Landroid/content/Intent;)Landroid/content/ComponentName;

    goto :goto_0

    .line 171
    :cond_2
    invoke-virtual {p0, v0}, Landroid/content/Context;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;

    .line 172
    :goto_0
    return-void
.end method


# virtual methods
.method public onBind(Landroid/content/Intent;)Landroid/os/IBinder;
    .locals 1
    .param p1, "intent"    # Landroid/content/Intent;

    .line 153
    const/4 v0, 0x0

    return-object v0
.end method

.method public onCreate()V
    .locals 0

    .line 34
    invoke-super {p0}, Landroid/app/Service;->onCreate()V

    .line 35
    invoke-direct {p0}, Lcom/forge/live/BackgroundForgeService;->createChannel()V

    .line 36
    invoke-direct {p0}, Lcom/forge/live/BackgroundForgeService;->acquireWakeLock()V

    .line 37
    return-void
.end method

.method public onDestroy()V
    .locals 0

    .line 146
    invoke-direct {p0}, Lcom/forge/live/BackgroundForgeService;->stopForegroundSafe()V

    .line 147
    invoke-direct {p0}, Lcom/forge/live/BackgroundForgeService;->releaseWakeLock()V

    .line 148
    invoke-super {p0}, Landroid/app/Service;->onDestroy()V

    .line 149
    return-void
.end method

.method public onStartCommand(Landroid/content/Intent;II)I
    .locals 3
    .param p1, "intent"    # Landroid/content/Intent;
    .param p2, "flags"    # I
    .param p3, "startId"    # I

    .line 41
    if-eqz p1, :cond_2

    .line 42
    invoke-virtual {p1}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v0

    .line 43
    .local v0, "action":Ljava/lang/String;
    const-string v1, "com.forge.live.bg.STOP"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 44
    invoke-direct {p0}, Lcom/forge/live/BackgroundForgeService;->stopForegroundSafe()V

    .line 45
    invoke-virtual {p0}, Lcom/forge/live/BackgroundForgeService;->stopSelf()V

    .line 46
    const/4 v1, 0x2

    return v1

    .line 48
    :cond_0
    const-string v1, "title"

    invoke-virtual {p1, v1}, Landroid/content/Intent;->hasExtra(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 49
    invoke-virtual {p1, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 50
    .local v1, "t":Ljava/lang/String;
    if-eqz v1, :cond_1

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-nez v2, :cond_1

    iput-object v1, p0, Lcom/forge/live/BackgroundForgeService;->title:Ljava/lang/String;

    .line 52
    .end local v1    # "t":Ljava/lang/String;
    :cond_1
    const-string v1, "text"

    invoke-virtual {p1, v1}, Landroid/content/Intent;->hasExtra(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_2

    .line 53
    invoke-virtual {p1, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 54
    .restart local v1    # "t":Ljava/lang/String;
    if-eqz v1, :cond_2

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-nez v2, :cond_2

    iput-object v1, p0, Lcom/forge/live/BackgroundForgeService;->text:Ljava/lang/String;

    .line 57
    .end local v0    # "action":Ljava/lang/String;
    .end local v1    # "t":Ljava/lang/String;
    :cond_2
    invoke-direct {p0}, Lcom/forge/live/BackgroundForgeService;->startAsForeground()V

    .line 58
    const/4 v0, 0x1

    return v0
.end method
