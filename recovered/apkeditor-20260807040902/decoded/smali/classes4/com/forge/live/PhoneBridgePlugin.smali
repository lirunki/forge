.class public Lcom/forge/live/PhoneBridgePlugin;
.super Lcom/getcapacitor/Plugin;
.source "PhoneBridgePlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "PhoneBridge"
    permissions = {
        .subannotation Lcom/getcapacitor/annotation/Permission;
            alias = "sms"
            strings = {
                "android.permission.SEND_SMS",
                "android.permission.READ_SMS",
                "android.permission.RECEIVE_SMS"
            }
        .end subannotation,
        .subannotation Lcom/getcapacitor/annotation/Permission;
            alias = "contacts"
            strings = {
                "android.permission.READ_CONTACTS"
            }
        .end subannotation,
        .subannotation Lcom/getcapacitor/annotation/Permission;
            alias = "phone"
            strings = {
                "android.permission.CALL_PHONE",
                "android.permission.READ_PHONE_STATE"
            }
        .end subannotation,
        .subannotation Lcom/getcapacitor/annotation/Permission;
            alias = "location"
            strings = {
                "android.permission.ACCESS_COARSE_LOCATION",
                "android.permission.ACCESS_FINE_LOCATION"
            }
        .end subannotation
    }
.end annotation


# direct methods
.method public static synthetic $r8$lambda$OfNREInRZG8rFW3qimxLYuyHrvk(Lcom/forge/live/PhoneBridgePlugin;Ljava/lang/String;Z)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lcom/forge/live/PhoneBridgePlugin;->lambda$toast$0(Ljava/lang/String;Z)V

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .line 64
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    return-void
.end method

.method private aliasGranted(Ljava/lang/String;)Z
    .locals 3
    .param p1, "alias"    # Ljava/lang/String;

    .line 211
    invoke-virtual {p1}, Ljava/lang/String;->hashCode()I

    move-result v0

    const/4 v1, 0x1

    const/4 v2, 0x0

    sparse-switch v0, :sswitch_data_0

    :cond_0
    goto :goto_0

    :sswitch_0
    const-string v0, "location"

    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x3

    goto :goto_1

    :sswitch_1
    const-string v0, "phone"

    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x2

    goto :goto_1

    :sswitch_2
    const-string v0, "sms"

    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x0

    goto :goto_1

    :sswitch_3
    const-string v0, "contacts"

    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_1

    :goto_0
    const/4 v0, -0x1

    :goto_1
    packed-switch v0, :pswitch_data_0

    .line 222
    return v2

    .line 219
    :pswitch_0
    const-string v0, "android.permission.ACCESS_FINE_LOCATION"

    invoke-direct {p0, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_2

    .line 220
    const-string v0, "android.permission.ACCESS_COARSE_LOCATION"

    invoke-direct {p0, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_1

    goto :goto_2

    :cond_1
    const/4 v1, 0x0

    goto :goto_3

    :cond_2
    :goto_2
    nop

    .line 219
    :goto_3
    return v1

    .line 217
    :pswitch_1
    const-string v0, "android.permission.CALL_PHONE"

    invoke-direct {p0, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    return v0

    .line 215
    :pswitch_2
    const-string v0, "android.permission.READ_CONTACTS"

    invoke-direct {p0, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    return v0

    .line 213
    :pswitch_3
    const-string v0, "android.permission.SEND_SMS"

    invoke-direct {p0, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_4

    const-string v0, "android.permission.READ_SMS"

    invoke-direct {p0, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_3

    goto :goto_4

    :cond_3
    const/4 v1, 0x0

    :cond_4
    :goto_4
    return v1

    nop

    :sswitch_data_0
    .sparse-switch
        -0x21d29fad -> :sswitch_3
        0x1bd59 -> :sswitch_2
        0x65b3d6e -> :sswitch_1
        0x714f9fb5 -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method private getCol(Landroid/database/Cursor;Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    .param p1, "c"    # Landroid/database/Cursor;
    .param p2, "name"    # Ljava/lang/String;

    .line 691
    invoke-interface {p1, p2}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I

    move-result v0

    .line 692
    .local v0, "i":I
    if-gez v0, :cond_0

    const/4 v1, 0x0

    return-object v1

    .line 693
    :cond_0
    invoke-interface {p1, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v1

    return-object v1
.end method

.method private getColInt(Landroid/database/Cursor;Ljava/lang/String;)I
    .locals 2
    .param p1, "c"    # Landroid/database/Cursor;
    .param p2, "name"    # Ljava/lang/String;

    .line 703
    invoke-interface {p1, p2}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I

    move-result v0

    .line 704
    .local v0, "i":I
    if-gez v0, :cond_0

    const/4 v1, 0x0

    return v1

    .line 705
    :cond_0
    invoke-interface {p1, v0}, Landroid/database/Cursor;->getInt(I)I

    move-result v1

    return v1
.end method

.method private getColLong(Landroid/database/Cursor;Ljava/lang/String;)J
    .locals 3
    .param p1, "c"    # Landroid/database/Cursor;
    .param p2, "name"    # Ljava/lang/String;

    .line 697
    invoke-interface {p1, p2}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I

    move-result v0

    .line 698
    .local v0, "i":I
    if-gez v0, :cond_0

    const-wide/16 v1, 0x0

    return-wide v1

    .line 699
    :cond_0
    invoke-interface {p1, v0}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v1

    return-wide v1
.end method

.method private granted(Ljava/lang/String;)Z
    .locals 1
    .param p1, "perm"    # Ljava/lang/String;

    .line 247
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0, p1}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result v0

    if-nez v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method private synthetic lambda$toast$0(Ljava/lang/String;Z)V
    .locals 2
    .param p1, "message"    # Ljava/lang/String;
    .param p2, "longToast"    # Z

    .line 596
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    if-eqz p1, :cond_0

    move-object v1, p1

    goto :goto_0

    :cond_0
    const-string v1, ""

    :goto_0
    invoke-static {v0, v1, p2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    return-void
.end method

.method private packOneCallback(Lcom/getcapacitor/PluginCall;)V
    .locals 6
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/annotation/PermissionCallback;
    .end annotation

    .line 180
    const-string v0, "_packAliases"

    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 181
    .local v1, "ret":Lcom/getcapacitor/JSObject;
    const-string v2, "ok"

    const/4 v3, 0x1

    invoke-virtual {v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 182
    const-string v2, "requested"

    invoke-virtual {v1, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 183
    const-string v2, "permissions"

    invoke-direct {p0}, Lcom/forge/live/PhoneBridgePlugin;->permissionSnapshot()Lcom/getcapacitor/JSObject;

    move-result-object v4

    invoke-virtual {v1, v2, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 184
    const/4 v2, 0x0

    .line 186
    .local v2, "aliases":Lcom/getcapacitor/JSArray;
    :try_start_0
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v4

    if-eqz v4, :cond_1

    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v4

    invoke-virtual {v4, v0}, Lcom/getcapacitor/JSObject;->has(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_1

    .line 187
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v4

    invoke-virtual {v4, v0}, Lcom/getcapacitor/JSObject;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    .line 188
    .local v0, "raw":Ljava/lang/Object;
    instance-of v4, v0, Lcom/getcapacitor/JSArray;

    if-eqz v4, :cond_0

    move-object v4, v0

    check-cast v4, Lcom/getcapacitor/JSArray;

    move-object v2, v4

    goto :goto_0

    .line 189
    :cond_0
    if-eqz v0, :cond_1

    new-instance v4, Lcom/getcapacitor/JSArray;

    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-direct {v4, v5}, Lcom/getcapacitor/JSArray;-><init>(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-object v2, v4

    goto :goto_0

    .line 191
    .end local v0    # "raw":Ljava/lang/Object;
    :catch_0
    move-exception v0

    :cond_1
    :goto_0
    nop

    .line 192
    if-eqz v2, :cond_2

    const-string v0, "aliases"

    invoke-virtual {v1, v0, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 194
    :cond_2
    const/4 v0, 0x1

    .line 196
    .local v0, "done":Z
    if-eqz v2, :cond_5

    .line 197
    const/4 v3, 0x0

    .local v3, "i":I
    :goto_1
    :try_start_1
    invoke-virtual {v2}, Lcom/getcapacitor/JSArray;->length()I

    move-result v4

    if-ge v3, v4, :cond_4

    .line 198
    invoke-virtual {v2, v3}, Lcom/getcapacitor/JSArray;->get(I)Ljava/lang/Object;

    move-result-object v4

    invoke-static {v4}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-direct {p0, v4}, Lcom/forge/live/PhoneBridgePlugin;->aliasGranted(Ljava/lang/String;)Z

    move-result v4

    if-nez v4, :cond_3

    const/4 v0, 0x0

    goto :goto_2

    .line 197
    :cond_3
    add-int/lit8 v3, v3, 0x1

    goto :goto_1

    .end local v3    # "i":I
    :cond_4
    :goto_2
    goto :goto_4

    .line 202
    :cond_5
    const-string v4, "sms"

    invoke-direct {p0, v4}, Lcom/forge/live/PhoneBridgePlugin;->aliasGranted(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_6

    const-string v4, "phone"

    invoke-direct {p0, v4}, Lcom/forge/live/PhoneBridgePlugin;->aliasGranted(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_6

    const-string v4, "contacts"

    .line 203
    invoke-direct {p0, v4}, Lcom/forge/live/PhoneBridgePlugin;->aliasGranted(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_6

    const-string v4, "location"

    invoke-direct {p0, v4}, Lcom/forge/live/PhoneBridgePlugin;->aliasGranted(Ljava/lang/String;)Z

    move-result v4
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    if-eqz v4, :cond_6

    goto :goto_3

    :cond_6
    const/4 v3, 0x0

    :goto_3
    move v0, v3

    goto :goto_4

    .line 205
    :catch_1
    move-exception v3

    :goto_4
    nop

    .line 206
    const-string v3, "done"

    invoke-virtual {v1, v3, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 207
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 208
    return-void
.end method

.method private permCallback(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/annotation/PermissionCallback;
    .end annotation

    .line 228
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 229
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    const-string v1, "permissions"

    invoke-direct {p0}, Lcom/forge/live/PhoneBridgePlugin;->permissionSnapshot()Lcom/getcapacitor/JSObject;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 230
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 231
    return-void
.end method

.method private permissionSnapshot()Lcom/getcapacitor/JSObject;
    .locals 3

    .line 234
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 235
    .local v0, "o":Lcom/getcapacitor/JSObject;
    const-string v1, "android.permission.SEND_SMS"

    invoke-direct {p0, v1}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v1

    const-string v2, "sendSms"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 236
    const-string v1, "android.permission.READ_SMS"

    invoke-direct {p0, v1}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v1

    const-string v2, "readSms"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 237
    const-string v1, "android.permission.RECEIVE_SMS"

    invoke-direct {p0, v1}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v1

    const-string v2, "receiveSms"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 238
    const-string v1, "android.permission.READ_CONTACTS"

    invoke-direct {p0, v1}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v1

    const-string v2, "readContacts"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 239
    const-string v1, "android.permission.CALL_PHONE"

    invoke-direct {p0, v1}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v1

    const-string v2, "callPhone"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 240
    const-string v1, "android.permission.READ_PHONE_STATE"

    invoke-direct {p0, v1}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v1

    const-string v2, "readPhoneState"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 241
    const-string v1, "android.permission.ACCESS_FINE_LOCATION"

    invoke-direct {p0, v1}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_1

    .line 242
    const-string v1, "android.permission.ACCESS_COARSE_LOCATION"

    invoke-direct {p0, v1}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_0

    :cond_0
    const/4 v1, 0x0

    goto :goto_1

    :cond_1
    :goto_0
    const/4 v1, 0x1

    .line 241
    :goto_1
    const-string v2, "location"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 243
    return-object v0
.end method


# virtual methods
.method public call(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 388
    const-string v0, "android.permission.CALL_PHONE"

    invoke-direct {p0, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 389
    const-string v0, "CALL_PHONE permission not granted. Call requestPermission({alias:\'phone\'}) first."

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 390
    return-void

    .line 392
    :cond_0
    const-string v0, "number"

    const-string v1, ""

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 393
    .local v0, "number":Ljava/lang/String;
    if-eqz v0, :cond_2

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_1

    goto :goto_1

    .line 398
    :cond_1
    :try_start_0
    new-instance v1, Landroid/content/Intent;

    const-string v2, "android.intent.action.CALL"

    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 399
    .local v1, "intent":Landroid/content/Intent;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "tel:"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 400
    const/high16 v2, 0x10000000

    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 401
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2, v1}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 402
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 403
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    const-string v3, "started"

    const/4 v4, 0x1

    invoke-virtual {v2, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 404
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 407
    .end local v1    # "intent":Landroid/content/Intent;
    .end local v2    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 405
    :catch_0
    move-exception v1

    .line 406
    .local v1, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "call failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 408
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_0
    return-void

    .line 394
    :cond_2
    :goto_1
    const-string v1, "\'number\' is required"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 395
    return-void
.end method

.method public composeEmail(Lcom/getcapacitor/PluginCall;)V
    .locals 7
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 638
    const-string v0, "to"

    const-string v1, ""

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 639
    .local v0, "to":Ljava/lang/String;
    const-string v2, "subject"

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 640
    .local v2, "subject":Ljava/lang/String;
    const-string v3, "body"

    invoke-virtual {p1, v3, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 642
    .local v3, "body":Ljava/lang/String;
    :try_start_0
    new-instance v4, Landroid/content/Intent;

    const-string v5, "android.intent.action.SENDTO"

    invoke-direct {v4, v5}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 643
    .local v4, "intent":Landroid/content/Intent;
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "mailto:"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    if-eqz v0, :cond_0

    move-object v1, v0

    :cond_0
    invoke-virtual {v5, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v4, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 644
    if-eqz v2, :cond_1

    const-string v1, "android.intent.extra.SUBJECT"

    invoke-virtual {v4, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 645
    :cond_1
    if-eqz v3, :cond_2

    const-string v1, "android.intent.extra.TEXT"

    invoke-virtual {v4, v1, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 646
    :cond_2
    const/high16 v1, 0x10000000

    invoke-virtual {v4, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 647
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1, v4}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 648
    new-instance v1, Lcom/getcapacitor/JSObject;

    invoke-direct {v1}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 649
    .local v1, "ret":Lcom/getcapacitor/JSObject;
    const-string v5, "opened"

    const/4 v6, 0x1

    invoke-virtual {v1, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 650
    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 653
    .end local v1    # "ret":Lcom/getcapacitor/JSObject;
    .end local v4    # "intent":Landroid/content/Intent;
    goto :goto_0

    .line 651
    :catch_0
    move-exception v1

    .line 652
    .local v1, "e":Ljava/lang/Exception;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "composeEmail failed: "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {p1, v4, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 654
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method public composeSms(Lcom/getcapacitor/PluginCall;)V
    .locals 7
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 255
    const-string v0, "to"

    const-string v1, ""

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 256
    .local v0, "to":Ljava/lang/String;
    const-string v2, "body"

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 258
    .local v2, "body":Ljava/lang/String;
    :try_start_0
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "smsto:"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    if-eqz v0, :cond_0

    move-object v1, v0

    :cond_0
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    .line 259
    .local v1, "uri":Landroid/net/Uri;
    new-instance v3, Landroid/content/Intent;

    const-string v4, "android.intent.action.SENDTO"

    invoke-direct {v3, v4, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V

    .line 260
    .local v3, "intent":Landroid/content/Intent;
    if-eqz v2, :cond_1

    const-string v4, "sms_body"

    invoke-virtual {v3, v4, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 261
    :cond_1
    const/high16 v4, 0x10000000

    invoke-virtual {v3, v4}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 262
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-virtual {v4, v3}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 263
    new-instance v4, Lcom/getcapacitor/JSObject;

    invoke-direct {v4}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 264
    .local v4, "ret":Lcom/getcapacitor/JSObject;
    const-string v5, "opened"

    const/4 v6, 0x1

    invoke-virtual {v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 265
    invoke-virtual {p1, v4}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 268
    .end local v1    # "uri":Landroid/net/Uri;
    .end local v3    # "intent":Landroid/content/Intent;
    .end local v4    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 266
    :catch_0
    move-exception v1

    .line 267
    .local v1, "e":Ljava/lang/Exception;
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "composeSms failed: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p1, v3, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 269
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method public dial(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 367
    const-string v0, "number"

    const-string v1, ""

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 369
    .local v0, "number":Ljava/lang/String;
    :try_start_0
    new-instance v1, Landroid/content/Intent;

    const-string v2, "android.intent.action.DIAL"

    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 370
    .local v1, "intent":Landroid/content/Intent;
    const-string v2, "tel:"

    if-eqz v0, :cond_0

    :try_start_1
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_0

    .line 371
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    goto :goto_0

    .line 373
    :cond_0
    invoke-static {v2}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 375
    :goto_0
    const/high16 v2, 0x10000000

    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 376
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2, v1}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 377
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 378
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    const-string v3, "opened"

    const/4 v4, 0x1

    invoke-virtual {v2, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 379
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .line 382
    .end local v1    # "intent":Landroid/content/Intent;
    .end local v2    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_1

    .line 380
    :catch_0
    move-exception v1

    .line 381
    .local v1, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "dial failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 383
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_1
    return-void
.end method

.method public getCapabilities(Lcom/getcapacitor/PluginCall;)V
    .locals 6
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 70
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 71
    .local v0, "caps":Lcom/getcapacitor/JSObject;
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v1

    .line 72
    .local v1, "pm":Landroid/content/pm/PackageManager;
    const-string v2, "platform"

    const-string v3, "android"

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 73
    const-string v2, "smsCompose"

    const/4 v3, 0x1

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 74
    const-string v2, "android.hardware.telephony"

    invoke-virtual {v1, v2}, Landroid/content/pm/PackageManager;->hasSystemFeature(Ljava/lang/String;)Z

    move-result v4

    const-string v5, "smsSend"

    invoke-virtual {v0, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 75
    const-string v4, "smsRead"

    invoke-virtual {v0, v4, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 76
    const-string v4, "dial"

    invoke-virtual {v0, v4, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 77
    const-string v4, "call"

    invoke-virtual {v1, v2}, Landroid/content/pm/PackageManager;->hasSystemFeature(Ljava/lang/String;)Z

    move-result v2

    invoke-virtual {v0, v4, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 78
    const-string v2, "contacts"

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 79
    const-string v2, "android.hardware.location"

    invoke-virtual {v1, v2}, Landroid/content/pm/PackageManager;->hasSystemFeature(Ljava/lang/String;)Z

    move-result v2

    const-string v4, "location"

    invoke-virtual {v0, v4, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 80
    const-string v2, "vibrate"

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 81
    const-string v2, "maps"

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 82
    const-string v2, "email"

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 83
    const-string v2, "settings"

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 84
    const-string v2, "tts"

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 85
    const-string v2, "permissions"

    invoke-direct {p0}, Lcom/forge/live/PhoneBridgePlugin;->permissionSnapshot()Lcom/getcapacitor/JSObject;

    move-result-object v3

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 86
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 87
    return-void
.end method

.method public getContacts(Lcom/getcapacitor/PluginCall;)V
    .locals 20
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 414
    move-object/from16 v1, p1

    const-string v0, "android.permission.READ_CONTACTS"

    move-object/from16 v2, p0

    invoke-direct {v2, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 415
    const-string v0, "READ_CONTACTS permission not granted. Call requestPermission({alias:\'contacts\'}) first."

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 416
    return-void

    .line 418
    :cond_0
    const/16 v0, 0x64

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    const-string v3, "limit"

    invoke-virtual {v1, v3, v0}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    .line 419
    .local v0, "limit":I
    const/4 v3, 0x1

    if-ge v0, v3, :cond_1

    const/4 v0, 0x1

    .line 420
    :cond_1
    const/16 v4, 0x1f4

    if-le v0, v4, :cond_2

    const/16 v0, 0x1f4

    :cond_2
    move v4, v0

    .line 421
    .end local v0    # "limit":I
    .local v4, "limit":I
    const-string v0, "query"

    const/4 v5, 0x0

    invoke-virtual {v1, v0, v5}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .line 423
    .local v5, "query":Ljava/lang/String;
    new-instance v0, Ljava/util/LinkedHashMap;

    invoke-direct {v0}, Ljava/util/LinkedHashMap;-><init>()V

    move-object v6, v0

    .line 424
    .local v6, "byId":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v13

    .line 426
    .local v13, "cr":Landroid/content/ContentResolver;
    sget-object v14, Landroid/provider/ContactsContract$CommonDataKinds$Phone;->CONTENT_URI:Landroid/net/Uri;

    .line 427
    .local v14, "uri":Landroid/net/Uri;
    const-string v0, "data1"

    const-string v7, "data2"

    const-string v8, "contact_id"

    const-string v9, "display_name"

    filled-new-array {v8, v9, v0, v7}, [Ljava/lang/String;

    move-result-object v9

    .line 433
    .local v9, "projection":[Ljava/lang/String;
    const/4 v0, 0x0

    .line 434
    .local v0, "selection":Ljava/lang/String;
    const/4 v7, 0x0

    .line 435
    .local v7, "args":[Ljava/lang/String;
    if-eqz v5, :cond_3

    invoke-virtual {v5}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/String;->isEmpty()Z

    move-result v8

    if-nez v8, :cond_3

    .line 436
    const-string v0, "display_name LIKE ? OR data1 LIKE ?"

    .line 438
    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "%"

    invoke-virtual {v8, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v5}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v8, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    .line 439
    .local v8, "q":Ljava/lang/String;
    filled-new-array {v8, v8}, [Ljava/lang/String;

    move-result-object v10

    move-object v7, v10

    move-object v15, v0

    move-object/from16 v16, v7

    goto :goto_0

    .line 442
    .end local v8    # "q":Ljava/lang/String;
    :cond_3
    move-object v15, v0

    move-object/from16 v16, v7

    .end local v0    # "selection":Ljava/lang/String;
    .end local v7    # "args":[Ljava/lang/String;
    .local v15, "selection":Ljava/lang/String;
    .local v16, "args":[Ljava/lang/String;
    :goto_0
    :try_start_0
    const-string v12, "display_name ASC"

    move-object v7, v13

    move-object v8, v14

    move-object v10, v15

    move-object/from16 v11, v16

    invoke-virtual/range {v7 .. v12}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    move-object v7, v0

    .line 444
    .local v7, "c":Landroid/database/Cursor;
    if-eqz v7, :cond_9

    .line 445
    :goto_1
    :try_start_1
    invoke-interface {v7}, Landroid/database/Cursor;->moveToNext()Z

    move-result v0

    if-eqz v0, :cond_7

    invoke-interface {v6}, Ljava/util/Map;->size()I

    move-result v0

    if-ge v0, v4, :cond_7

    .line 446
    const/4 v0, 0x0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 447
    .local v0, "id":Ljava/lang/String;
    invoke-interface {v7, v3}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v8

    .line 448
    .local v8, "name":Ljava/lang/String;
    const/4 v10, 0x2

    invoke-interface {v7, v10}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v10

    .line 449
    .local v10, "number":Ljava/lang/String;
    const/4 v11, 0x3

    invoke-interface {v7, v11}, Landroid/database/Cursor;->getInt(I)I

    move-result v11

    .line 450
    .local v11, "type":I
    invoke-interface {v6, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v12

    check-cast v12, Lcom/getcapacitor/JSObject;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 451
    .local v12, "contact":Lcom/getcapacitor/JSObject;
    const-string v3, "phones"

    const-string v17, ""

    if-nez v12, :cond_5

    .line 452
    :try_start_2
    new-instance v18, Lcom/getcapacitor/JSObject;

    invoke-direct/range {v18 .. v18}, Lcom/getcapacitor/JSObject;-><init>()V

    move-object/from16 v12, v18

    .line 453
    const-string v2, "id"

    invoke-virtual {v12, v2, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 454
    const-string v2, "name"
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    if-eqz v8, :cond_4

    move/from16 v18, v4

    move-object v4, v8

    goto :goto_2

    :cond_4
    move/from16 v18, v4

    move-object/from16 v4, v17

    .end local v4    # "limit":I
    .local v18, "limit":I
    :goto_2
    :try_start_3
    invoke-virtual {v12, v2, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 455
    new-instance v2, Lcom/getcapacitor/JSArray;

    invoke-direct {v2}, Lcom/getcapacitor/JSArray;-><init>()V

    invoke-virtual {v12, v3, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 456
    invoke-interface {v6, v0, v12}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_3

    .line 451
    .end local v18    # "limit":I
    .restart local v4    # "limit":I
    :cond_5
    move/from16 v18, v4

    .line 458
    .end local v4    # "limit":I
    .restart local v18    # "limit":I
    :goto_3
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 459
    .local v2, "phone":Lcom/getcapacitor/JSObject;
    const-string v4, "number"

    if-eqz v10, :cond_6

    move-object/from16 v19, v0

    move-object v0, v10

    goto :goto_4

    :cond_6
    move-object/from16 v19, v0

    move-object/from16 v0, v17

    .end local v0    # "id":Ljava/lang/String;
    .local v19, "id":Ljava/lang/String;
    :goto_4
    invoke-virtual {v2, v4, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 460
    const-string v0, "type"

    invoke-virtual {v2, v0, v11}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 461
    invoke-virtual {v12, v3}, Lcom/getcapacitor/JSObject;->get(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/getcapacitor/JSArray;

    invoke-virtual {v0, v2}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    .line 462
    const/4 v3, 0x1

    move-object/from16 v2, p0

    move/from16 v4, v18

    .end local v2    # "phone":Lcom/getcapacitor/JSObject;
    .end local v8    # "name":Ljava/lang/String;
    .end local v10    # "number":Ljava/lang/String;
    .end local v11    # "type":I
    .end local v12    # "contact":Lcom/getcapacitor/JSObject;
    .end local v19    # "id":Ljava/lang/String;
    goto :goto_1

    .line 442
    :catchall_0
    move-exception v0

    move-object v2, v0

    goto :goto_5

    .line 445
    .end local v18    # "limit":I
    .restart local v4    # "limit":I
    :cond_7
    move/from16 v18, v4

    .end local v4    # "limit":I
    .restart local v18    # "limit":I
    goto :goto_7

    .line 442
    .end local v18    # "limit":I
    .restart local v4    # "limit":I
    :catchall_1
    move-exception v0

    move/from16 v18, v4

    move-object v2, v0

    .end local v4    # "limit":I
    .restart local v18    # "limit":I
    :goto_5
    if-eqz v7, :cond_8

    :try_start_4
    invoke-interface {v7}, Landroid/database/Cursor;->close()V
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_2

    goto :goto_6

    :catchall_2
    move-exception v0

    move-object v3, v0

    :try_start_5
    invoke-virtual {v2, v3}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .end local v5    # "query":Ljava/lang/String;
    .end local v6    # "byId":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    .end local v9    # "projection":[Ljava/lang/String;
    .end local v13    # "cr":Landroid/content/ContentResolver;
    .end local v14    # "uri":Landroid/net/Uri;
    .end local v15    # "selection":Ljava/lang/String;
    .end local v16    # "args":[Ljava/lang/String;
    .end local v18    # "limit":I
    .end local p1    # "call":Lcom/getcapacitor/PluginCall;
    :cond_8
    :goto_6
    throw v2

    .line 444
    .restart local v4    # "limit":I
    .restart local v5    # "query":Ljava/lang/String;
    .restart local v6    # "byId":Ljava/util/Map;, "Ljava/util/Map<Ljava/lang/String;Lcom/getcapacitor/JSObject;>;"
    .restart local v9    # "projection":[Ljava/lang/String;
    .restart local v13    # "cr":Landroid/content/ContentResolver;
    .restart local v14    # "uri":Landroid/net/Uri;
    .restart local v15    # "selection":Ljava/lang/String;
    .restart local v16    # "args":[Ljava/lang/String;
    .restart local p1    # "call":Lcom/getcapacitor/PluginCall;
    :cond_9
    move/from16 v18, v4

    .line 464
    .end local v4    # "limit":I
    .restart local v18    # "limit":I
    :goto_7
    if-eqz v7, :cond_a

    invoke-interface {v7}, Landroid/database/Cursor;->close()V
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_0

    goto :goto_8

    .end local v7    # "c":Landroid/database/Cursor;
    :catch_0
    move-exception v0

    goto :goto_a

    .line 467
    :cond_a
    :goto_8
    nop

    .line 469
    new-instance v0, Lcom/getcapacitor/JSArray;

    invoke-direct {v0}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 470
    .local v0, "list":Lcom/getcapacitor/JSArray;
    invoke-interface {v6}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_9
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_b

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lcom/getcapacitor/JSObject;

    .local v3, "o":Lcom/getcapacitor/JSObject;
    invoke-virtual {v0, v3}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    goto :goto_9

    .line 471
    .end local v3    # "o":Lcom/getcapacitor/JSObject;
    :cond_b
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 472
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    const-string v3, "contacts"

    invoke-virtual {v2, v3, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 473
    const-string v3, "count"

    invoke-virtual {v0}, Lcom/getcapacitor/JSArray;->length()I

    move-result v4

    invoke-virtual {v2, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 474
    invoke-virtual {v1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 475
    return-void

    .line 464
    .end local v0    # "list":Lcom/getcapacitor/JSArray;
    .end local v2    # "ret":Lcom/getcapacitor/JSObject;
    .end local v18    # "limit":I
    .restart local v4    # "limit":I
    :catch_1
    move-exception v0

    move/from16 v18, v4

    .line 465
    .end local v4    # "limit":I
    .local v0, "e":Ljava/lang/Exception;
    .restart local v18    # "limit":I
    :goto_a
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "getContacts failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 466
    return-void
.end method

.method public getDeviceInfo(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 606
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 607
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    const-string v1, "manufacturer"

    sget-object v2, Landroid/os/Build;->MANUFACTURER:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 608
    const-string v1, "model"

    sget-object v2, Landroid/os/Build;->MODEL:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 609
    const-string v1, "brand"

    sget-object v2, Landroid/os/Build;->BRAND:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 610
    const-string v1, "device"

    sget-object v2, Landroid/os/Build;->DEVICE:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 611
    const-string v1, "sdkInt"

    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 612
    const-string v1, "release"

    sget-object v2, Landroid/os/Build$VERSION;->RELEASE:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 613
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "packageName"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 615
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    const-string v2, "phone"

    invoke-virtual {v1, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/telephony/TelephonyManager;

    .line 616
    .local v1, "tm":Landroid/telephony/TelephonyManager;
    if-eqz v1, :cond_1

    .line 617
    const-string v2, "networkOperatorName"

    invoke-virtual {v1}, Landroid/telephony/TelephonyManager;->getNetworkOperatorName()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 618
    const-string v2, "simCountryIso"

    invoke-virtual {v1}, Landroid/telephony/TelephonyManager;->getSimCountryIso()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 619
    const-string v2, "phoneType"

    invoke-virtual {v1}, Landroid/telephony/TelephonyManager;->getPhoneType()I

    move-result v3

    invoke-virtual {v0, v2, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 620
    const-string v2, "android.permission.READ_PHONE_STATE"

    invoke-direct {p0, v2}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v2
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    if-eqz v2, :cond_1

    .line 623
    :try_start_1
    invoke-virtual {v1}, Landroid/telephony/TelephonyManager;->getLine1Number()Ljava/lang/String;

    move-result-object v2

    .line 624
    .local v2, "line1":Ljava/lang/String;
    if-eqz v2, :cond_0

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_0

    const-string v3, "line1Number"

    invoke-virtual {v0, v3, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_0

    .line 625
    .end local v2    # "line1":Ljava/lang/String;
    :catch_0
    move-exception v2

    :cond_0
    :goto_0
    goto :goto_1

    .line 628
    .end local v1    # "tm":Landroid/telephony/TelephonyManager;
    :catch_1
    move-exception v1

    :cond_1
    :goto_1
    nop

    .line 630
    :try_start_2
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-static {v1}, Landroid/provider/Telephony$Sms;->getDefaultSmsPackage(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v1

    .line 631
    .local v1, "defaultSms":Ljava/lang/String;
    const-string v2, "defaultSmsPackage"

    invoke-virtual {v0, v2, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

    .line 632
    nop

    .end local v1    # "defaultSms":Ljava/lang/String;
    goto :goto_2

    :catch_2
    move-exception v1

    .line 633
    :goto_2
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 634
    return-void
.end method

.method public getLocation(Lcom/getcapacitor/PluginCall;)V
    .locals 9
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 481
    const-string v0, "android.permission.ACCESS_FINE_LOCATION"

    invoke-direct {p0, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 482
    const-string v0, "android.permission.ACCESS_COARSE_LOCATION"

    invoke-direct {p0, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 483
    const-string v0, "Location permission not granted. Call requestPermission({alias:\'location\'}) first."

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 484
    return-void

    .line 487
    :cond_0
    :try_start_0
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    const-string v1, "location"

    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/location/LocationManager;

    .line 488
    .local v0, "lm":Landroid/location/LocationManager;
    if-nez v0, :cond_1

    .line 489
    const-string v1, "LocationManager unavailable"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 490
    return-void

    .line 492
    :cond_1
    new-instance v1, Landroid/location/Criteria;

    invoke-direct {v1}, Landroid/location/Criteria;-><init>()V

    .line 493
    .local v1, "criteria":Landroid/location/Criteria;
    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Landroid/location/Criteria;->setAccuracy(I)V

    .line 494
    invoke-virtual {v0, v1, v2}, Landroid/location/LocationManager;->getBestProvider(Landroid/location/Criteria;Z)Ljava/lang/String;

    move-result-object v3

    .line 495
    .local v3, "provider":Ljava/lang/String;
    const/4 v4, 0x0

    .line 496
    .local v4, "loc":Landroid/location/Location;
    if-eqz v3, :cond_2

    .line 497
    invoke-virtual {v0, v3}, Landroid/location/LocationManager;->getLastKnownLocation(Ljava/lang/String;)Landroid/location/Location;

    move-result-object v5

    move-object v4, v5

    .line 499
    :cond_2
    if-nez v4, :cond_4

    .line 500
    const/4 v5, 0x3

    new-array v6, v5, [Ljava/lang/String;

    const-string v7, "gps"

    const/4 v8, 0x0

    aput-object v7, v6, v8

    const-string v7, "network"

    aput-object v7, v6, v2

    const-string v2, "passive"

    const/4 v7, 0x2

    aput-object v2, v6, v7

    :goto_0
    if-ge v8, v5, :cond_4

    aget-object v2, v6, v8
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_2
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 506
    .local v2, "p":Ljava/lang/String;
    :try_start_1
    invoke-virtual {v0, v2}, Landroid/location/LocationManager;->isProviderEnabled(Ljava/lang/String;)Z

    move-result v7

    if-eqz v7, :cond_3

    .line 507
    invoke-virtual {v0, v2}, Landroid/location/LocationManager;->getLastKnownLocation(Ljava/lang/String;)Landroid/location/Location;

    move-result-object v7
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catch Ljava/lang/SecurityException; {:try_start_1 .. :try_end_1} :catch_2

    move-object v4, v7

    .line 508
    if-eqz v4, :cond_3

    goto :goto_1

    .line 510
    :catch_0
    move-exception v7

    :cond_3
    nop

    .line 500
    .end local v2    # "p":Ljava/lang/String;
    add-int/lit8 v8, v8, 0x1

    goto :goto_0

    .line 513
    :cond_4
    :goto_1
    if-nez v4, :cond_5

    .line 514
    :try_start_2
    const-string v2, "No last-known location yet. Open Maps once or wait for a GPS fix, then retry."

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 515
    return-void

    .line 517
    :cond_5
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 518
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    const-string v5, "latitude"

    invoke-virtual {v4}, Landroid/location/Location;->getLatitude()D

    move-result-wide v6

    invoke-virtual {v2, v5, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;D)Lcom/getcapacitor/JSObject;

    .line 519
    const-string v5, "longitude"

    invoke-virtual {v4}, Landroid/location/Location;->getLongitude()D

    move-result-wide v6

    invoke-virtual {v2, v5, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;D)Lcom/getcapacitor/JSObject;

    .line 520
    const-string v5, "accuracy"

    invoke-virtual {v4}, Landroid/location/Location;->hasAccuracy()Z

    move-result v6

    if-eqz v6, :cond_6

    invoke-virtual {v4}, Landroid/location/Location;->getAccuracy()F

    move-result v6

    invoke-static {v6}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v6

    goto :goto_2

    :cond_6
    sget-object v6, Lcom/getcapacitor/JSObject;->NULL:Ljava/lang/Object;

    :goto_2
    invoke-virtual {v2, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 521
    const-string v5, "altitude"

    invoke-virtual {v4}, Landroid/location/Location;->hasAltitude()Z

    move-result v6

    if-eqz v6, :cond_7

    invoke-virtual {v4}, Landroid/location/Location;->getAltitude()D

    move-result-wide v6

    invoke-static {v6, v7}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v6

    goto :goto_3

    :cond_7
    sget-object v6, Lcom/getcapacitor/JSObject;->NULL:Ljava/lang/Object;

    :goto_3
    invoke-virtual {v2, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 522
    const-string v5, "speed"

    invoke-virtual {v4}, Landroid/location/Location;->hasSpeed()Z

    move-result v6

    if-eqz v6, :cond_8

    invoke-virtual {v4}, Landroid/location/Location;->getSpeed()F

    move-result v6

    invoke-static {v6}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v6

    goto :goto_4

    :cond_8
    sget-object v6, Lcom/getcapacitor/JSObject;->NULL:Ljava/lang/Object;

    :goto_4
    invoke-virtual {v2, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 523
    const-string v5, "time"

    invoke-virtual {v4}, Landroid/location/Location;->getTime()J

    move-result-wide v6

    invoke-virtual {v2, v5, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 524
    const-string v5, "provider"

    invoke-virtual {v4}, Landroid/location/Location;->getProvider()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v2, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 525
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_2
    .catch Ljava/lang/SecurityException; {:try_start_2 .. :try_end_2} :catch_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    .end local v0    # "lm":Landroid/location/LocationManager;
    .end local v1    # "criteria":Landroid/location/Criteria;
    .end local v2    # "ret":Lcom/getcapacitor/JSObject;
    .end local v3    # "provider":Ljava/lang/String;
    .end local v4    # "loc":Landroid/location/Location;
    goto :goto_5

    .line 528
    :catch_1
    move-exception v0

    .line 529
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "getLocation failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    goto :goto_6

    .line 526
    .end local v0    # "e":Ljava/lang/Exception;
    :catch_2
    move-exception v0

    .line 527
    .local v0, "se":Ljava/lang/SecurityException;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Location blocked: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/SecurityException;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 530
    .end local v0    # "se":Ljava/lang/SecurityException;
    :goto_5
    nop

    .line 531
    :goto_6
    return-void
.end method

.method public getPermissions(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 91
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 92
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    const-string v1, "permissions"

    invoke-direct {p0}, Lcom/forge/live/PhoneBridgePlugin;->permissionSnapshot()Lcom/getcapacitor/JSObject;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 93
    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 94
    return-void
.end method

.method public openAppSettings(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 659
    :try_start_0
    new-instance v0, Landroid/content/Intent;

    const-string v1, "android.settings.APPLICATION_DETAILS_SETTINGS"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 660
    .local v0, "intent":Landroid/content/Intent;
    const-string v1, "package"

    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v2

    const/4 v3, 0x0

    invoke-static {v1, v2, v3}, Landroid/net/Uri;->fromParts(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    .line 661
    const/high16 v1, 0x10000000

    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 662
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 663
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 666
    .end local v0    # "intent":Landroid/content/Intent;
    goto :goto_0

    .line 664
    :catch_0
    move-exception v0

    .line 665
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "openAppSettings failed: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 667
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_0
    return-void
.end method

.method public openMaps(Lcom/getcapacitor/PluginCall;)V
    .locals 8
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 535
    const-string v0, ","

    const-string v1, ""

    const-string v2, "latitude"

    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->getDouble(Ljava/lang/String;)Ljava/lang/Double;

    move-result-object v2

    .line 536
    .local v2, "lat":Ljava/lang/Double;
    const-string v3, "longitude"

    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->getDouble(Ljava/lang/String;)Ljava/lang/Double;

    move-result-object v3

    .line 537
    .local v3, "lng":Ljava/lang/Double;
    const-string v4, "query"

    const/4 v5, 0x0

    invoke-virtual {p1, v4, v5}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    .line 540
    .local v4, "query":Ljava/lang/String;
    if-eqz v2, :cond_1

    if-eqz v3, :cond_1

    .line 541
    :try_start_0
    const-string v5, "label"

    invoke-virtual {p1, v5, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .line 542
    .local v5, "label":Ljava/lang/String;
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "geo:"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "?q="

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    if-eqz v5, :cond_0

    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v6

    if-nez v6, :cond_0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "("

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-static {v5}, Landroid/net/Uri;->encode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v6, ")"

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    :cond_0
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    .line 543
    .end local v5    # "label":Ljava/lang/String;
    .local v0, "uri":Landroid/net/Uri;
    goto :goto_0

    .end local v0    # "uri":Landroid/net/Uri;
    :cond_1
    if-eqz v4, :cond_2

    invoke-virtual {v4}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_2

    .line 544
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "geo:0,0?q="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-static {v4}, Landroid/net/Uri;->encode(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    .restart local v0    # "uri":Landroid/net/Uri;
    goto :goto_0

    .line 546
    .end local v0    # "uri":Landroid/net/Uri;
    :cond_2
    const-string v0, "geo:0,0"

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    .line 548
    .restart local v0    # "uri":Landroid/net/Uri;
    :goto_0
    new-instance v1, Landroid/content/Intent;

    const-string v5, "android.intent.action.VIEW"

    invoke-direct {v1, v5, v0}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V

    .line 549
    .local v1, "intent":Landroid/content/Intent;
    const/high16 v5, 0x10000000

    invoke-virtual {v1, v5}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 550
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v5

    invoke-virtual {v5, v1}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 551
    new-instance v5, Lcom/getcapacitor/JSObject;

    invoke-direct {v5}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 552
    .local v5, "ret":Lcom/getcapacitor/JSObject;
    const-string v6, "opened"

    const/4 v7, 0x1

    invoke-virtual {v5, v6, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 553
    invoke-virtual {p1, v5}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 556
    .end local v0    # "uri":Landroid/net/Uri;
    .end local v1    # "intent":Landroid/content/Intent;
    .end local v5    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_1

    .line 554
    :catch_0
    move-exception v0

    .line 555
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "openMaps failed: "

    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 557
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1
    return-void
.end method

.method public openUrl(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 671
    const-string v0, "url"

    const-string v1, ""

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 672
    .local v0, "url":Ljava/lang/String;
    if-eqz v0, :cond_1

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_1

    .line 677
    :cond_0
    :try_start_0
    new-instance v1, Landroid/content/Intent;

    const-string v2, "android.intent.action.VIEW"

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v3

    invoke-direct {v1, v2, v3}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V

    .line 678
    .local v1, "intent":Landroid/content/Intent;
    const/high16 v2, 0x10000000

    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    .line 679
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2, v1}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 680
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 681
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    const-string v3, "opened"

    const/4 v4, 0x1

    invoke-virtual {v2, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 682
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 685
    .end local v1    # "intent":Landroid/content/Intent;
    .end local v2    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_0

    .line 683
    :catch_0
    move-exception v1

    .line 684
    .local v1, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "openUrl failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 686
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_0
    return-void

    .line 673
    :cond_1
    :goto_1
    const-string v1, "url required"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 674
    return-void
.end method

.method public readSms(Lcom/getcapacitor/PluginCall;)V
    .locals 23
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 305
    move-object/from16 v1, p0

    move-object/from16 v2, p1

    const-string v0, "read"

    const-string v3, "type"

    const-string v4, "date"

    const-string v5, "body"

    const-string v6, "android.permission.READ_SMS"

    invoke-direct {v1, v6}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v6

    if-nez v6, :cond_0

    .line 306
    const-string v0, "READ_SMS permission not granted. Call requestPermission({alias:\'sms\'}) first."

    invoke-virtual {v2, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 307
    return-void

    .line 309
    :cond_0
    const/16 v6, 0x1e

    invoke-static {v6}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v6

    const-string v7, "limit"

    invoke-virtual {v2, v7, v6}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/Integer;->intValue()I

    move-result v6

    .line 310
    .local v6, "limit":I
    const/4 v7, 0x1

    if-ge v6, v7, :cond_1

    const/4 v6, 0x1

    .line 311
    :cond_1
    const/16 v8, 0xc8

    if-le v6, v8, :cond_2

    const/16 v6, 0xc8

    .line 312
    :cond_2
    const-string v8, "box"

    const-string v9, "inbox"

    invoke-virtual {v2, v8, v9}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    .line 313
    .local v8, "box":Ljava/lang/String;
    const/4 v9, 0x0

    const-string v10, "address"

    invoke-virtual {v2, v10, v9}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    .line 315
    .local v9, "addressFilter":Ljava/lang/String;
    new-instance v11, Ljava/util/ArrayList;

    invoke-direct {v11}, Ljava/util/ArrayList;-><init>()V

    .line 316
    .local v11, "uris":Ljava/util/List;, "Ljava/util/List<Landroid/net/Uri;>;"
    const-string v12, "sent"

    invoke-virtual {v12, v8}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v12

    if-eqz v12, :cond_3

    .line 317
    const-string v12, "content://sms/sent"

    invoke-static {v12}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v12

    invoke-interface {v11, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 318
    :cond_3
    const-string v12, "all"

    invoke-virtual {v12, v8}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v12

    if-eqz v12, :cond_4

    .line 319
    const-string v12, "content://sms"

    invoke-static {v12}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v12

    invoke-interface {v11, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 321
    :cond_4
    const-string v12, "content://sms/inbox"

    invoke-static {v12}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v12

    invoke-interface {v11, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 324
    :goto_0
    new-instance v12, Lcom/getcapacitor/JSArray;

    invoke-direct {v12}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 325
    .local v12, "messages":Lcom/getcapacitor/JSArray;
    invoke-virtual/range {p0 .. p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v13

    invoke-virtual {v13}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v13

    .line 326
    .local v13, "cr":Landroid/content/ContentResolver;
    const/4 v14, 0x0

    .line 327
    .local v14, "selection":Ljava/lang/String;
    const/4 v15, 0x0

    .line 328
    .local v15, "selArgs":[Ljava/lang/String;
    if-eqz v9, :cond_5

    invoke-virtual {v9}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v16

    invoke-virtual/range {v16 .. v16}, Ljava/lang/String;->isEmpty()Z

    move-result v16

    if-nez v16, :cond_5

    .line 329
    const-string v14, "address LIKE ?"

    .line 330
    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    move-object/from16 v20, v8

    .end local v8    # "box":Ljava/lang/String;
    .local v20, "box":Ljava/lang/String;
    const-string v8, "%"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    move-object/from16 v16, v14

    .end local v14    # "selection":Ljava/lang/String;
    .local v16, "selection":Ljava/lang/String;
    invoke-virtual {v9}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v7, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    filled-new-array {v7}, [Ljava/lang/String;

    move-result-object v7

    move-object v15, v7

    move-object v8, v15

    move-object/from16 v7, v16

    goto :goto_1

    .line 328
    .end local v16    # "selection":Ljava/lang/String;
    .end local v20    # "box":Ljava/lang/String;
    .restart local v8    # "box":Ljava/lang/String;
    .restart local v14    # "selection":Ljava/lang/String;
    :cond_5
    move-object/from16 v20, v8

    .line 334
    .end local v8    # "box":Ljava/lang/String;
    .restart local v20    # "box":Ljava/lang/String;
    move-object v7, v14

    move-object v8, v15

    .end local v14    # "selection":Ljava/lang/String;
    .end local v15    # "selArgs":[Ljava/lang/String;
    .local v7, "selection":Ljava/lang/String;
    .local v8, "selArgs":[Ljava/lang/String;
    :goto_1
    :try_start_0
    invoke-interface {v11}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v21

    :cond_6
    :goto_2
    invoke-interface/range {v21 .. v21}, Ljava/util/Iterator;->hasNext()Z

    move-result v14

    if-eqz v14, :cond_c

    invoke-interface/range {v21 .. v21}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v14

    move-object v15, v14

    check-cast v15, Landroid/net/Uri;

    .line 335
    .local v15, "uri":Landroid/net/Uri;
    const/16 v16, 0x0

    const-string v19, "date DESC"

    move-object v14, v13

    move-object/from16 v17, v7

    move-object/from16 v18, v8

    invoke-virtual/range {v14 .. v19}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v14
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_5
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_4

    .line 336
    .local v14, "c":Landroid/database/Cursor;
    if-nez v14, :cond_7

    .line 349
    if-eqz v14, :cond_6

    :try_start_1
    invoke-interface {v14}, Landroid/database/Cursor;->close()V
    :try_end_1
    .catch Ljava/lang/SecurityException; {:try_start_1 .. :try_end_1} :catch_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_2

    .line 357
    .end local v14    # "c":Landroid/database/Cursor;
    .end local v15    # "uri":Landroid/net/Uri;
    :catch_0
    move-exception v0

    move/from16 v16, v6

    move-object/from16 v17, v7

    move-object/from16 v19, v8

    move-object/from16 v22, v9

    goto/16 :goto_7

    .line 355
    :catch_1
    move-exception v0

    move/from16 v16, v6

    move-object/from16 v17, v7

    move-object/from16 v19, v8

    move-object/from16 v22, v9

    goto/16 :goto_8

    .line 337
    .restart local v14    # "c":Landroid/database/Cursor;
    .restart local v15    # "uri":Landroid/net/Uri;
    :cond_7
    const/16 v16, 0x0

    move-object/from16 v17, v7

    move/from16 v7, v16

    .line 338
    .local v7, "count":I
    .local v17, "selection":Ljava/lang/String;
    :goto_3
    :try_start_2
    invoke-interface {v14}, Landroid/database/Cursor;->moveToNext()Z

    move-result v16

    if-eqz v16, :cond_9

    if-ge v7, v6, :cond_9

    .line 339
    new-instance v16, Lcom/getcapacitor/JSObject;

    invoke-direct/range {v16 .. v16}, Lcom/getcapacitor/JSObject;-><init>()V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_3

    move-object/from16 v18, v16

    .line 340
    .local v18, "m":Lcom/getcapacitor/JSObject;
    move/from16 v16, v6

    .end local v6    # "limit":I
    .local v16, "limit":I
    :try_start_3
    const-string v6, "id"
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_2

    move-object/from16 v19, v8

    .end local v8    # "selArgs":[Ljava/lang/String;
    .local v19, "selArgs":[Ljava/lang/String;
    :try_start_4
    const-string v8, "_id"

    invoke-direct {v1, v14, v8}, Lcom/forge/live/PhoneBridgePlugin;->getCol(Landroid/database/Cursor;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_1

    move-object/from16 v22, v9

    move-object/from16 v9, v18

    .end local v18    # "m":Lcom/getcapacitor/JSObject;
    .local v9, "m":Lcom/getcapacitor/JSObject;
    .local v22, "addressFilter":Ljava/lang/String;
    :try_start_5
    invoke-virtual {v9, v6, v8}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 341
    invoke-direct {v1, v14, v10}, Lcom/forge/live/PhoneBridgePlugin;->getCol(Landroid/database/Cursor;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v9, v10, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 342
    invoke-direct {v1, v14, v5}, Lcom/forge/live/PhoneBridgePlugin;->getCol(Landroid/database/Cursor;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v9, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 343
    move-object v8, v5

    invoke-direct {v1, v14, v4}, Lcom/forge/live/PhoneBridgePlugin;->getColLong(Landroid/database/Cursor;Ljava/lang/String;)J

    move-result-wide v5

    invoke-virtual {v9, v4, v5, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;J)Lcom/getcapacitor/JSObject;

    .line 344
    invoke-direct {v1, v14, v3}, Lcom/forge/live/PhoneBridgePlugin;->getColInt(Landroid/database/Cursor;Ljava/lang/String;)I

    move-result v5

    invoke-virtual {v9, v3, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 345
    invoke-direct {v1, v14, v0}, Lcom/forge/live/PhoneBridgePlugin;->getColInt(Landroid/database/Cursor;Ljava/lang/String;)I

    move-result v5

    const/4 v6, 0x1

    if-ne v5, v6, :cond_8

    const/4 v5, 0x1

    goto :goto_4

    :cond_8
    const/4 v5, 0x0

    :goto_4
    invoke-virtual {v9, v0, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 346
    invoke-virtual {v12, v9}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    .line 347
    nop

    .end local v9    # "m":Lcom/getcapacitor/JSObject;
    add-int/lit8 v7, v7, 0x1

    .line 348
    move-object v5, v8

    move/from16 v6, v16

    move-object/from16 v8, v19

    move-object/from16 v9, v22

    goto :goto_3

    .line 335
    .end local v7    # "count":I
    :catchall_0
    move-exception v0

    move-object v3, v0

    goto :goto_5

    .end local v22    # "addressFilter":Ljava/lang/String;
    .local v9, "addressFilter":Ljava/lang/String;
    :catchall_1
    move-exception v0

    move-object/from16 v22, v9

    move-object v3, v0

    .end local v9    # "addressFilter":Ljava/lang/String;
    .restart local v22    # "addressFilter":Ljava/lang/String;
    goto :goto_5

    .end local v19    # "selArgs":[Ljava/lang/String;
    .end local v22    # "addressFilter":Ljava/lang/String;
    .restart local v8    # "selArgs":[Ljava/lang/String;
    .restart local v9    # "addressFilter":Ljava/lang/String;
    :catchall_2
    move-exception v0

    move-object/from16 v19, v8

    move-object/from16 v22, v9

    move-object v3, v0

    .end local v8    # "selArgs":[Ljava/lang/String;
    .end local v9    # "addressFilter":Ljava/lang/String;
    .restart local v19    # "selArgs":[Ljava/lang/String;
    .restart local v22    # "addressFilter":Ljava/lang/String;
    goto :goto_5

    .line 338
    .end local v16    # "limit":I
    .end local v19    # "selArgs":[Ljava/lang/String;
    .end local v22    # "addressFilter":Ljava/lang/String;
    .restart local v6    # "limit":I
    .restart local v7    # "count":I
    .restart local v8    # "selArgs":[Ljava/lang/String;
    .restart local v9    # "addressFilter":Ljava/lang/String;
    :cond_9
    move/from16 v16, v6

    move-object/from16 v19, v8

    move-object/from16 v22, v9

    const/4 v6, 0x1

    move-object v8, v5

    .line 349
    .end local v6    # "limit":I
    .end local v7    # "count":I
    .end local v8    # "selArgs":[Ljava/lang/String;
    .end local v9    # "addressFilter":Ljava/lang/String;
    .restart local v16    # "limit":I
    .restart local v19    # "selArgs":[Ljava/lang/String;
    .restart local v22    # "addressFilter":Ljava/lang/String;
    if-eqz v14, :cond_a

    :try_start_6
    invoke-interface {v14}, Landroid/database/Cursor;->close()V
    :try_end_6
    .catch Ljava/lang/SecurityException; {:try_start_6 .. :try_end_6} :catch_3
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_6} :catch_2

    .line 350
    .end local v14    # "c":Landroid/database/Cursor;
    .end local v15    # "uri":Landroid/net/Uri;
    :cond_a
    move-object v5, v8

    move/from16 v6, v16

    move-object/from16 v7, v17

    move-object/from16 v8, v19

    move-object/from16 v9, v22

    goto/16 :goto_2

    .line 335
    .end local v16    # "limit":I
    .end local v19    # "selArgs":[Ljava/lang/String;
    .end local v22    # "addressFilter":Ljava/lang/String;
    .restart local v6    # "limit":I
    .restart local v8    # "selArgs":[Ljava/lang/String;
    .restart local v9    # "addressFilter":Ljava/lang/String;
    .restart local v14    # "c":Landroid/database/Cursor;
    .restart local v15    # "uri":Landroid/net/Uri;
    :catchall_3
    move-exception v0

    move/from16 v16, v6

    move-object/from16 v19, v8

    move-object/from16 v22, v9

    move-object v3, v0

    .end local v6    # "limit":I
    .end local v8    # "selArgs":[Ljava/lang/String;
    .end local v9    # "addressFilter":Ljava/lang/String;
    .restart local v16    # "limit":I
    .restart local v19    # "selArgs":[Ljava/lang/String;
    .restart local v22    # "addressFilter":Ljava/lang/String;
    :goto_5
    if-eqz v14, :cond_b

    :try_start_7
    invoke-interface {v14}, Landroid/database/Cursor;->close()V
    :try_end_7
    .catchall {:try_start_7 .. :try_end_7} :catchall_4

    goto :goto_6

    :catchall_4
    move-exception v0

    move-object v4, v0

    :try_start_8
    invoke-virtual {v3, v4}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    .end local v11    # "uris":Ljava/util/List;, "Ljava/util/List<Landroid/net/Uri;>;"
    .end local v12    # "messages":Lcom/getcapacitor/JSArray;
    .end local v13    # "cr":Landroid/content/ContentResolver;
    .end local v16    # "limit":I
    .end local v17    # "selection":Ljava/lang/String;
    .end local v19    # "selArgs":[Ljava/lang/String;
    .end local v20    # "box":Ljava/lang/String;
    .end local v22    # "addressFilter":Ljava/lang/String;
    .end local p1    # "call":Lcom/getcapacitor/PluginCall;
    :cond_b
    :goto_6
    throw v3

    .line 351
    .end local v14    # "c":Landroid/database/Cursor;
    .end local v15    # "uri":Landroid/net/Uri;
    .restart local v6    # "limit":I
    .local v7, "selection":Ljava/lang/String;
    .restart local v8    # "selArgs":[Ljava/lang/String;
    .restart local v9    # "addressFilter":Ljava/lang/String;
    .restart local v11    # "uris":Ljava/util/List;, "Ljava/util/List<Landroid/net/Uri;>;"
    .restart local v12    # "messages":Lcom/getcapacitor/JSArray;
    .restart local v13    # "cr":Landroid/content/ContentResolver;
    .restart local v20    # "box":Ljava/lang/String;
    .restart local p1    # "call":Lcom/getcapacitor/PluginCall;
    :cond_c
    move/from16 v16, v6

    move-object/from16 v17, v7

    move-object/from16 v19, v8

    move-object/from16 v22, v9

    .end local v6    # "limit":I
    .end local v7    # "selection":Ljava/lang/String;
    .end local v8    # "selArgs":[Ljava/lang/String;
    .end local v9    # "addressFilter":Ljava/lang/String;
    .restart local v16    # "limit":I
    .restart local v17    # "selection":Ljava/lang/String;
    .restart local v19    # "selArgs":[Ljava/lang/String;
    .restart local v22    # "addressFilter":Ljava/lang/String;
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 352
    .local v0, "ret":Lcom/getcapacitor/JSObject;
    const-string v3, "messages"

    invoke-virtual {v0, v3, v12}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 353
    const-string v3, "count"

    invoke-virtual {v12}, Lcom/getcapacitor/JSArray;->length()I

    move-result v4

    invoke-virtual {v0, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;I)Lcom/getcapacitor/JSObject;

    .line 354
    invoke-virtual {v2, v0}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_8
    .catch Ljava/lang/SecurityException; {:try_start_8 .. :try_end_8} :catch_3
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_8} :catch_2

    .end local v0    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_9

    .line 357
    :catch_2
    move-exception v0

    goto :goto_7

    .line 355
    :catch_3
    move-exception v0

    goto :goto_8

    .line 357
    .end local v16    # "limit":I
    .end local v17    # "selection":Ljava/lang/String;
    .end local v19    # "selArgs":[Ljava/lang/String;
    .end local v22    # "addressFilter":Ljava/lang/String;
    .restart local v6    # "limit":I
    .restart local v7    # "selection":Ljava/lang/String;
    .restart local v8    # "selArgs":[Ljava/lang/String;
    .restart local v9    # "addressFilter":Ljava/lang/String;
    :catch_4
    move-exception v0

    move/from16 v16, v6

    move-object/from16 v17, v7

    move-object/from16 v19, v8

    move-object/from16 v22, v9

    .line 358
    .end local v6    # "limit":I
    .end local v7    # "selection":Ljava/lang/String;
    .end local v8    # "selArgs":[Ljava/lang/String;
    .end local v9    # "addressFilter":Ljava/lang/String;
    .local v0, "e":Ljava/lang/Exception;
    .restart local v16    # "limit":I
    .restart local v17    # "selection":Ljava/lang/String;
    .restart local v19    # "selArgs":[Ljava/lang/String;
    .restart local v22    # "addressFilter":Ljava/lang/String;
    :goto_7
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "readSms failed: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    goto :goto_a

    .line 355
    .end local v0    # "e":Ljava/lang/Exception;
    .end local v16    # "limit":I
    .end local v17    # "selection":Ljava/lang/String;
    .end local v19    # "selArgs":[Ljava/lang/String;
    .end local v22    # "addressFilter":Ljava/lang/String;
    .restart local v6    # "limit":I
    .restart local v7    # "selection":Ljava/lang/String;
    .restart local v8    # "selArgs":[Ljava/lang/String;
    .restart local v9    # "addressFilter":Ljava/lang/String;
    :catch_5
    move-exception v0

    move/from16 v16, v6

    move-object/from16 v17, v7

    move-object/from16 v19, v8

    move-object/from16 v22, v9

    .line 356
    .end local v6    # "limit":I
    .end local v7    # "selection":Ljava/lang/String;
    .end local v8    # "selArgs":[Ljava/lang/String;
    .end local v9    # "addressFilter":Ljava/lang/String;
    .local v0, "se":Ljava/lang/SecurityException;
    .restart local v16    # "limit":I
    .restart local v17    # "selection":Ljava/lang/String;
    .restart local v19    # "selArgs":[Ljava/lang/String;
    .restart local v22    # "addressFilter":Ljava/lang/String;
    :goto_8
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "SMS read blocked: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v0}, Ljava/lang/SecurityException;->getMessage()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 359
    .end local v0    # "se":Ljava/lang/SecurityException;
    :goto_9
    nop

    .line 360
    :goto_a
    return-void
.end method

.method public requestPack(Lcom/getcapacitor/PluginCall;)V
    .locals 11
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 122
    const-string v0, "aliases"

    new-instance v1, Ljava/util/LinkedHashSet;

    invoke-direct {v1}, Ljava/util/LinkedHashSet;-><init>()V

    .line 123
    .local v1, "aliases":Ljava/util/LinkedHashSet;, "Ljava/util/LinkedHashSet<Ljava/lang/String;>;"
    const-string v2, "id"

    const-string v3, ""

    invoke-virtual {p1, v2, v3}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    const-string v3, "pack"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 124
    .local v2, "pack":Ljava/lang/String;
    const-string v3, "location"

    const-string v4, "contacts"

    const-string v5, "sms"

    const-string v6, "phone"

    if-eqz v2, :cond_4

    .line 125
    invoke-virtual {v6, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-nez v7, :cond_3

    const-string v7, "phone_features"

    invoke-virtual {v7, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-nez v7, :cond_3

    const-string v7, "enable_phone"

    invoke-virtual {v7, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_0

    goto :goto_1

    .line 130
    :cond_0
    invoke-virtual {v5, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    const-string v8, "phone_only"

    if-nez v7, :cond_1

    invoke-virtual {v4, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-nez v7, :cond_1

    .line 131
    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-nez v7, :cond_1

    invoke-virtual {v8, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_4

    .line 132
    :cond_1
    invoke-virtual {v8, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_2

    move-object v7, v6

    goto :goto_0

    :cond_2
    move-object v7, v2

    :goto_0
    invoke-virtual {v1, v7}, Ljava/util/LinkedHashSet;->add(Ljava/lang/Object;)Z

    goto :goto_2

    .line 126
    :cond_3
    :goto_1
    invoke-virtual {v1, v5}, Ljava/util/LinkedHashSet;->add(Ljava/lang/Object;)Z

    .line 127
    invoke-virtual {v1, v6}, Ljava/util/LinkedHashSet;->add(Ljava/lang/Object;)Z

    .line 128
    invoke-virtual {v1, v4}, Ljava/util/LinkedHashSet;->add(Ljava/lang/Object;)Z

    .line 129
    invoke-virtual {v1, v3}, Ljava/util/LinkedHashSet;->add(Ljava/lang/Object;)Z

    .line 136
    :cond_4
    :goto_2
    :try_start_0
    const-string v7, "features"

    invoke-virtual {p1, v7}, Lcom/getcapacitor/PluginCall;->getArray(Ljava/lang/String;)Lcom/getcapacitor/JSArray;

    move-result-object v7

    .line 137
    .local v7, "features":Lcom/getcapacitor/JSArray;
    if-nez v7, :cond_5

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getArray(Ljava/lang/String;)Lcom/getcapacitor/JSArray;

    move-result-object v8

    move-object v7, v8

    .line 138
    :cond_5
    if-eqz v7, :cond_8

    .line 139
    const/4 v8, 0x0

    .local v8, "i":I
    :goto_3
    invoke-virtual {v7}, Lcom/getcapacitor/JSArray;->length()I

    move-result v9

    if-ge v8, v9, :cond_8

    .line 140
    invoke-virtual {v7, v8}, Lcom/getcapacitor/JSArray;->get(I)Ljava/lang/Object;

    move-result-object v9

    invoke-static {v9}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v9

    .line 141
    .local v9, "a":Ljava/lang/String;
    invoke-virtual {v5, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v10

    if-nez v10, :cond_6

    invoke-virtual {v4, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v10

    if-nez v10, :cond_6

    invoke-virtual {v6, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v10

    if-nez v10, :cond_6

    invoke-virtual {v3, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v10

    if-eqz v10, :cond_7

    .line 142
    :cond_6
    invoke-virtual {v1, v9}, Ljava/util/LinkedHashSet;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 139
    .end local v9    # "a":Ljava/lang/String;
    :cond_7
    add-int/lit8 v8, v8, 0x1

    goto :goto_3

    .line 146
    .end local v7    # "features":Lcom/getcapacitor/JSArray;
    .end local v8    # "i":I
    :catch_0
    move-exception v3

    :cond_8
    nop

    .line 148
    invoke-virtual {v1}, Ljava/util/LinkedHashSet;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_9

    .line 149
    const-string v0, "Use pack:\'phone_features\' or features:[\'sms\',\'phone\',\'contacts\',\'location\']"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 150
    return-void

    .line 154
    :cond_9
    invoke-virtual {v1}, Ljava/util/LinkedHashSet;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :goto_4
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_c

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    .line 155
    .local v4, "alias":Ljava/lang/String;
    invoke-direct {p0, v4}, Lcom/forge/live/PhoneBridgePlugin;->aliasGranted(Ljava/lang/String;)Z

    move-result v5

    if-nez v5, :cond_b

    .line 158
    :try_start_1
    new-instance v0, Lcom/getcapacitor/JSArray;

    invoke-direct {v0}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 159
    .local v0, "all":Lcom/getcapacitor/JSArray;
    invoke-virtual {v1}, Ljava/util/LinkedHashSet;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :goto_5
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_a

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/String;

    .local v5, "a":Ljava/lang/String;
    invoke-virtual {v0, v5}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    goto :goto_5

    .line 160
    .end local v5    # "a":Ljava/lang/String;
    :cond_a
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->getData()Lcom/getcapacitor/JSObject;

    move-result-object v3

    const-string v5, "_packAliases"

    invoke-virtual {v3, v5, v0}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    .line 161
    nop

    .end local v0    # "all":Lcom/getcapacitor/JSArray;
    goto :goto_6

    :catch_1
    move-exception v0

    .line 162
    :goto_6
    const-string v0, "packOneCallback"

    invoke-virtual {p0, v4, p1, v0}, Lcom/forge/live/PhoneBridgePlugin;->requestPermissionForAlias(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    .line 163
    return-void

    .line 165
    .end local v4    # "alias":Ljava/lang/String;
    :cond_b
    goto :goto_4

    .line 167
    :cond_c
    new-instance v3, Lcom/getcapacitor/JSObject;

    invoke-direct {v3}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 168
    .local v3, "ret":Lcom/getcapacitor/JSObject;
    const-string v4, "ok"

    const/4 v5, 0x1

    invoke-virtual {v3, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 169
    const-string v4, "requested"

    const/4 v6, 0x0

    invoke-virtual {v3, v4, v6}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 170
    const-string v4, "done"

    invoke-virtual {v3, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 171
    const-string v4, "permissions"

    invoke-direct {p0}, Lcom/forge/live/PhoneBridgePlugin;->permissionSnapshot()Lcom/getcapacitor/JSObject;

    move-result-object v5

    invoke-virtual {v3, v4, v5}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 172
    new-instance v4, Lcom/getcapacitor/JSArray;

    invoke-direct {v4}, Lcom/getcapacitor/JSArray;-><init>()V

    .line 173
    .local v4, "all":Lcom/getcapacitor/JSArray;
    invoke-virtual {v1}, Ljava/util/LinkedHashSet;->iterator()Ljava/util/Iterator;

    move-result-object v5

    :goto_7
    invoke-interface {v5}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_d

    invoke-interface {v5}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/lang/String;

    .local v6, "a":Ljava/lang/String;
    invoke-virtual {v4, v6}, Lcom/getcapacitor/JSArray;->put(Ljava/lang/Object;)Lorg/json/JSONArray;

    goto :goto_7

    .line 174
    .end local v6    # "a":Ljava/lang/String;
    :cond_d
    invoke-virtual {v3, v0, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 175
    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 176
    return-void
.end method

.method public requestPermission(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 98
    const-string v0, "alias"

    const-string v1, ""

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 99
    .local v0, "alias":Ljava/lang/String;
    if-eqz v0, :cond_2

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_3

    .line 103
    :cond_0
    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v1

    sparse-switch v1, :sswitch_data_0

    :cond_1
    goto :goto_0

    :sswitch_0
    const-string v1, "location"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    const/4 v1, 0x3

    goto :goto_1

    :sswitch_1
    const-string v1, "phone"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    const/4 v1, 0x2

    goto :goto_1

    :sswitch_2
    const-string v1, "sms"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    const/4 v1, 0x0

    goto :goto_1

    :sswitch_3
    const-string v1, "contacts"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    const/4 v1, 0x1

    goto :goto_1

    :goto_0
    const/4 v1, -0x1

    :goto_1
    packed-switch v1, :pswitch_data_0

    .line 111
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Unknown alias: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    goto :goto_2

    .line 108
    :pswitch_0
    const-string v1, "permCallback"

    invoke-virtual {p0, v0, p1, v1}, Lcom/forge/live/PhoneBridgePlugin;->requestPermissionForAlias(Ljava/lang/String;Lcom/getcapacitor/PluginCall;Ljava/lang/String;)V

    .line 109
    nop

    .line 113
    :goto_2
    return-void

    .line 100
    :cond_2
    :goto_3
    const-string v1, "alias required: sms | contacts | phone | location"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 101
    return-void

    nop

    :sswitch_data_0
    .sparse-switch
        -0x21d29fad -> :sswitch_3
        0x1bd59 -> :sswitch_2
        0x65b3d6e -> :sswitch_1
        0x714f9fb5 -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
    .end packed-switch
.end method

.method public sendSms(Lcom/getcapacitor/PluginCall;)V
    .locals 17
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 274
    move-object/from16 v1, p1

    const-string v0, "android.permission.SEND_SMS"

    move-object/from16 v2, p0

    invoke-direct {v2, v0}, Lcom/forge/live/PhoneBridgePlugin;->granted(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 275
    const-string v0, "SEND_SMS permission not granted. Call requestPermission({alias:\'sms\'}) first."

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 276
    return-void

    .line 278
    :cond_0
    const-string v0, "to"

    const-string v3, ""

    invoke-virtual {v1, v0, v3}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    .line 279
    .local v4, "to":Ljava/lang/String;
    const-string v5, "body"

    invoke-virtual {v1, v5, v3}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    .line 280
    .local v3, "body":Ljava/lang/String;
    if-eqz v4, :cond_4

    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v5

    if-eqz v5, :cond_1

    goto :goto_2

    .line 284
    :cond_1
    if-nez v3, :cond_2

    const-string v3, ""

    .line 286
    :cond_2
    :try_start_0
    invoke-static {}, Landroid/telephony/SmsManager;->getDefault()Landroid/telephony/SmsManager;

    move-result-object v5

    move-object v15, v5

    .line 287
    .local v15, "sms":Landroid/telephony/SmsManager;
    invoke-virtual {v15, v3}, Landroid/telephony/SmsManager;->divideMessage(Ljava/lang/String;)Ljava/util/ArrayList;

    move-result-object v14

    .line 288
    .local v14, "parts":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/String;>;"
    invoke-virtual {v14}, Ljava/util/ArrayList;->size()I

    move-result v5

    const/4 v13, 0x1

    if-gt v5, v13, :cond_3

    .line 289
    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v6

    const/4 v7, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    move-object v5, v15

    move-object v8, v3

    invoke-virtual/range {v5 .. v10}, Landroid/telephony/SmsManager;->sendTextMessage(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/app/PendingIntent;Landroid/app/PendingIntent;)V

    move-object v5, v15

    const/4 v7, 0x1

    goto :goto_0

    .line 291
    :cond_3
    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v12

    const/4 v5, 0x0

    const/4 v6, 0x0

    const/16 v16, 0x0

    move-object v11, v15

    const/4 v7, 0x1

    move-object v13, v5

    move-object v5, v15

    .end local v15    # "sms":Landroid/telephony/SmsManager;
    .local v5, "sms":Landroid/telephony/SmsManager;
    move-object v15, v6

    invoke-virtual/range {v11 .. v16}, Landroid/telephony/SmsManager;->sendMultipartTextMessage(Ljava/lang/String;Ljava/lang/String;Ljava/util/ArrayList;Ljava/util/ArrayList;Ljava/util/ArrayList;)V

    .line 293
    :goto_0
    new-instance v6, Lcom/getcapacitor/JSObject;

    invoke-direct {v6}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 294
    .local v6, "ret":Lcom/getcapacitor/JSObject;
    const-string v8, "sent"

    invoke-virtual {v6, v8, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 295
    invoke-virtual {v4}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v0, v7}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/String;)Lcom/getcapacitor/JSObject;

    .line 296
    invoke-virtual {v1, v6}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 299
    .end local v5    # "sms":Landroid/telephony/SmsManager;
    .end local v6    # "ret":Lcom/getcapacitor/JSObject;
    .end local v14    # "parts":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Ljava/lang/String;>;"
    goto :goto_1

    .line 297
    :catch_0
    move-exception v0

    .line 298
    .local v0, "e":Ljava/lang/Exception;
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "sendSms failed: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v1, v5, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 300
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1
    return-void

    .line 281
    :cond_4
    :goto_2
    const-string v0, "\'to\' phone number is required"

    invoke-virtual {v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 282
    return-void
.end method

.method public toast(Lcom/getcapacitor/PluginCall;)V
    .locals 4
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 592
    const-string v0, "message"

    const-string v1, ""

    invoke-virtual {p1, v0, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 593
    .local v0, "message":Ljava/lang/String;
    const/4 v2, 0x0

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    const-string v3, "long"

    invoke-virtual {p1, v3, v2}, Lcom/getcapacitor/PluginCall;->getBoolean(Ljava/lang/String;Ljava/lang/Boolean;)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v2

    .line 594
    .local v2, "longToast":Z
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getActivity()Landroidx/appcompat/app/AppCompatActivity;

    move-result-object v3

    if-eqz v3, :cond_0

    .line 595
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getActivity()Landroidx/appcompat/app/AppCompatActivity;

    move-result-object v1

    new-instance v3, Lcom/forge/live/PhoneBridgePlugin$$ExternalSyntheticLambda0;

    invoke-direct {v3, p0, v0, v2}, Lcom/forge/live/PhoneBridgePlugin$$ExternalSyntheticLambda0;-><init>(Lcom/forge/live/PhoneBridgePlugin;Ljava/lang/String;Z)V

    invoke-virtual {v1, v3}, Landroidx/appcompat/app/AppCompatActivity;->runOnUiThread(Ljava/lang/Runnable;)V

    goto :goto_0

    .line 599
    :cond_0
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v3

    if-eqz v0, :cond_1

    move-object v1, v0

    :cond_1
    invoke-static {v3, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v1

    invoke-virtual {v1}, Landroid/widget/Toast;->show()V

    .line 601
    :goto_0
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V

    .line 602
    return-void
.end method

.method public vibrate(Lcom/getcapacitor/PluginCall;)V
    .locals 7
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 563
    const/16 v0, 0x28

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    const-string v1, "ms"

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->getInt(Ljava/lang/String;Ljava/lang/Integer;)Ljava/lang/Integer;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    .line 564
    .local v0, "ms":I
    const/4 v1, 0x1

    if-ge v0, v1, :cond_0

    const/4 v0, 0x1

    .line 565
    :cond_0
    const/16 v2, 0xbb8

    if-le v0, v2, :cond_1

    const/16 v0, 0xbb8

    .line 567
    :cond_1
    :try_start_0
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1f

    const/4 v4, -0x1

    if-lt v2, v3, :cond_3

    .line 568
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    const-string v3, "vibrator_manager"

    invoke-virtual {v2, v3}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/os/VibratorManager;

    .line 569
    .local v2, "vm":Landroid/os/VibratorManager;
    if-eqz v2, :cond_2

    .line 570
    invoke-virtual {v2}, Landroid/os/VibratorManager;->getDefaultVibrator()Landroid/os/Vibrator;

    move-result-object v3

    int-to-long v5, v0

    invoke-static {v5, v6, v4}, Landroid/os/VibrationEffect;->createOneShot(JI)Landroid/os/VibrationEffect;

    move-result-object v4

    invoke-virtual {v3, v4}, Landroid/os/Vibrator;->vibrate(Landroid/os/VibrationEffect;)V

    .line 572
    .end local v2    # "vm":Landroid/os/VibratorManager;
    :cond_2
    goto :goto_0

    .line 573
    :cond_3
    invoke-virtual {p0}, Lcom/forge/live/PhoneBridgePlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    const-string v3, "vibrator"

    invoke-virtual {v2, v3}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/os/Vibrator;

    .line 574
    .local v2, "v":Landroid/os/Vibrator;
    if-eqz v2, :cond_5

    .line 575
    sget v3, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v5, 0x1a

    if-lt v3, v5, :cond_4

    .line 576
    int-to-long v5, v0

    invoke-static {v5, v6, v4}, Landroid/os/VibrationEffect;->createOneShot(JI)Landroid/os/VibrationEffect;

    move-result-object v3

    invoke-virtual {v2, v3}, Landroid/os/Vibrator;->vibrate(Landroid/os/VibrationEffect;)V

    goto :goto_0

    .line 578
    :cond_4
    int-to-long v3, v0

    invoke-virtual {v2, v3, v4}, Landroid/os/Vibrator;->vibrate(J)V

    .line 582
    .end local v2    # "v":Landroid/os/Vibrator;
    :cond_5
    :goto_0
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 583
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    const-string v3, "ok"

    invoke-virtual {v2, v3, v1}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 584
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 587
    .end local v2    # "ret":Lcom/getcapacitor/JSObject;
    goto :goto_1

    .line 585
    :catch_0
    move-exception v1

    .line 586
    .local v1, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "vibrate failed: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 588
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_1
    return-void
.end method
