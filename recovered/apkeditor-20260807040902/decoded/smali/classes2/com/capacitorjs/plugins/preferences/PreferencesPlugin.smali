.class public Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;
.super Lcom/getcapacitor/Plugin;
.source "PreferencesPlugin.java"


# annotations
.annotation runtime Lcom/getcapacitor/annotation/CapacitorPlugin;
    name = "Preferences"
.end annotation


# instance fields
.field private preferences:Lcom/capacitorjs/plugins/preferences/Preferences;


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 15
    invoke-direct {p0}, Lcom/getcapacitor/Plugin;-><init>()V

    return-void
.end method


# virtual methods
.method public clear(Lcom/getcapacitor/PluginCall;)V
    .locals 1
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 97
    iget-object v0, p0, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->preferences:Lcom/capacitorjs/plugins/preferences/Preferences;

    invoke-virtual {v0}, Lcom/capacitorjs/plugins/preferences/Preferences;->clear()V

    .line 98
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V

    .line 99
    return-void
.end method

.method public configure(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 27
    :try_start_0
    sget-object v0, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->DEFAULTS:Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;

    invoke-virtual {v0}, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->clone()Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;

    move-result-object v0

    .line 28
    .local v0, "configuration":Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;
    const-string v1, "group"

    sget-object v2, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->DEFAULTS:Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;

    iget-object v2, v2, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->group:Ljava/lang/String;

    invoke-virtual {p1, v1, v2}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    iput-object v1, v0, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->group:Ljava/lang/String;

    .line 30
    new-instance v1, Lcom/capacitorjs/plugins/preferences/Preferences;

    invoke-virtual {p0}, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2, v0}, Lcom/capacitorjs/plugins/preferences/Preferences;-><init>(Landroid/content/Context;Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;)V

    iput-object v1, p0, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->preferences:Lcom/capacitorjs/plugins/preferences/Preferences;
    :try_end_0
    .catch Ljava/lang/CloneNotSupportedException; {:try_start_0 .. :try_end_0} :catch_0

    .line 34
    .end local v0    # "configuration":Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;
    nop

    .line 35
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V

    .line 36
    return-void

    .line 31
    :catch_0
    move-exception v0

    .line 32
    .local v0, "e":Ljava/lang/CloneNotSupportedException;
    const-string v1, "Error while configuring"

    invoke-virtual {p1, v1, v0}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 33
    return-void
.end method

.method public get(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 40
    const-string v0, "key"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 41
    .local v0, "key":Ljava/lang/String;
    if-nez v0, :cond_0

    .line 42
    const-string v1, "Must provide key"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 43
    return-void

    .line 46
    :cond_0
    iget-object v1, p0, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->preferences:Lcom/capacitorjs/plugins/preferences/Preferences;

    invoke-virtual {v1, v0}, Lcom/capacitorjs/plugins/preferences/Preferences;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 48
    .local v1, "value":Ljava/lang/String;
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 49
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    if-nez v1, :cond_1

    sget-object v3, Lcom/getcapacitor/JSObject;->NULL:Ljava/lang/Object;

    goto :goto_0

    :cond_1
    move-object v3, v1

    :goto_0
    const-string v4, "value"

    invoke-virtual {v2, v4, v3}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 50
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 51
    return-void
.end method

.method public keys(Lcom/getcapacitor/PluginCall;)V
    .locals 5
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 82
    iget-object v0, p0, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->preferences:Lcom/capacitorjs/plugins/preferences/Preferences;

    invoke-virtual {v0}, Lcom/capacitorjs/plugins/preferences/Preferences;->keys()Ljava/util/Set;

    move-result-object v0

    .line 83
    .local v0, "keySet":Ljava/util/Set;, "Ljava/util/Set<Ljava/lang/String;>;"
    const/4 v1, 0x0

    new-array v1, v1, [Ljava/lang/String;

    invoke-interface {v0, v1}, Ljava/util/Set;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v1

    check-cast v1, [Ljava/lang/String;

    .line 85
    .local v1, "keys":[Ljava/lang/String;
    new-instance v2, Lcom/getcapacitor/JSObject;

    invoke-direct {v2}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 87
    .local v2, "ret":Lcom/getcapacitor/JSObject;
    :try_start_0
    const-string v3, "keys"

    new-instance v4, Lcom/getcapacitor/JSArray;

    invoke-direct {v4, v1}, Lcom/getcapacitor/JSArray;-><init>(Ljava/lang/Object;)V

    invoke-virtual {v2, v3, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;
    :try_end_0
    .catch Lorg/json/JSONException; {:try_start_0 .. :try_end_0} :catch_0

    .line 91
    nop

    .line 92
    invoke-virtual {p1, v2}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 93
    return-void

    .line 88
    :catch_0
    move-exception v3

    .line 89
    .local v3, "ex":Lorg/json/JSONException;
    const-string v4, "Unable to serialize response."

    invoke-virtual {p1, v4, v3}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 90
    return-void
.end method

.method public load()V
    .locals 3

    .line 21
    new-instance v0, Lcom/capacitorjs/plugins/preferences/Preferences;

    invoke-virtual {p0}, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->getContext()Landroid/content/Context;

    move-result-object v1

    sget-object v2, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->DEFAULTS:Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;

    invoke-direct {v0, v1, v2}, Lcom/capacitorjs/plugins/preferences/Preferences;-><init>(Landroid/content/Context;Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;)V

    iput-object v0, p0, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->preferences:Lcom/capacitorjs/plugins/preferences/Preferences;

    .line 22
    return-void
.end method

.method public migrate(Lcom/getcapacitor/PluginCall;)V
    .locals 8
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 103
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 104
    .local v0, "migrated":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 105
    .local v1, "existing":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    new-instance v2, Lcom/capacitorjs/plugins/preferences/Preferences;

    invoke-virtual {p0}, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->getContext()Landroid/content/Context;

    move-result-object v3

    sget-object v4, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->DEFAULTS:Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;

    invoke-direct {v2, v3, v4}, Lcom/capacitorjs/plugins/preferences/Preferences;-><init>(Landroid/content/Context;Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;)V

    .line 107
    .local v2, "oldPreferences":Lcom/capacitorjs/plugins/preferences/Preferences;
    invoke-virtual {v2}, Lcom/capacitorjs/plugins/preferences/Preferences;->keys()Ljava/util/Set;

    move-result-object v3

    invoke-interface {v3}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :goto_0
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_1

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    .line 108
    .local v4, "key":Ljava/lang/String;
    invoke-virtual {v2, v4}, Lcom/capacitorjs/plugins/preferences/Preferences;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .line 109
    .local v5, "value":Ljava/lang/String;
    iget-object v6, p0, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->preferences:Lcom/capacitorjs/plugins/preferences/Preferences;

    invoke-virtual {v6, v4}, Lcom/capacitorjs/plugins/preferences/Preferences;->get(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    .line 111
    .local v6, "currentValue":Ljava/lang/String;
    if-nez v6, :cond_0

    .line 112
    iget-object v7, p0, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->preferences:Lcom/capacitorjs/plugins/preferences/Preferences;

    invoke-virtual {v7, v4, v5}, Lcom/capacitorjs/plugins/preferences/Preferences;->set(Ljava/lang/String;Ljava/lang/String;)V

    .line 113
    invoke-interface {v0, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_1

    .line 115
    :cond_0
    invoke-interface {v1, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 117
    .end local v4    # "key":Ljava/lang/String;
    .end local v5    # "value":Ljava/lang/String;
    .end local v6    # "currentValue":Ljava/lang/String;
    :goto_1
    goto :goto_0

    .line 119
    :cond_1
    new-instance v3, Lcom/getcapacitor/JSObject;

    invoke-direct {v3}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 120
    .local v3, "ret":Lcom/getcapacitor/JSObject;
    new-instance v4, Lcom/getcapacitor/JSArray;

    invoke-direct {v4, v0}, Lcom/getcapacitor/JSArray;-><init>(Ljava/util/Collection;)V

    const-string v5, "migrated"

    invoke-virtual {v3, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 121
    new-instance v4, Lcom/getcapacitor/JSArray;

    invoke-direct {v4, v1}, Lcom/getcapacitor/JSArray;-><init>(Ljava/util/Collection;)V

    const-string v5, "existing"

    invoke-virtual {v3, v5, v4}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Ljava/lang/Object;)Lcom/getcapacitor/JSObject;

    .line 122
    invoke-virtual {p1, v3}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 123
    return-void
.end method

.method public remove(Lcom/getcapacitor/PluginCall;)V
    .locals 2
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 69
    const-string v0, "key"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 70
    .local v0, "key":Ljava/lang/String;
    if-nez v0, :cond_0

    .line 71
    const-string v1, "Must provide key"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 72
    return-void

    .line 75
    :cond_0
    iget-object v1, p0, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->preferences:Lcom/capacitorjs/plugins/preferences/Preferences;

    invoke-virtual {v1, v0}, Lcom/capacitorjs/plugins/preferences/Preferences;->remove(Ljava/lang/String;)V

    .line 77
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V

    .line 78
    return-void
.end method

.method public removeOld(Lcom/getcapacitor/PluginCall;)V
    .locals 0
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 127
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V

    .line 128
    return-void
.end method

.method public set(Lcom/getcapacitor/PluginCall;)V
    .locals 3
    .param p1, "call"    # Lcom/getcapacitor/PluginCall;
    .annotation runtime Lcom/getcapacitor/PluginMethod;
    .end annotation

    .line 55
    const-string v0, "key"

    invoke-virtual {p1, v0}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 56
    .local v0, "key":Ljava/lang/String;
    if-nez v0, :cond_0

    .line 57
    const-string v1, "Must provide key"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;)V

    .line 58
    return-void

    .line 61
    :cond_0
    const-string v1, "value"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/PluginCall;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 62
    .local v1, "value":Ljava/lang/String;
    iget-object v2, p0, Lcom/capacitorjs/plugins/preferences/PreferencesPlugin;->preferences:Lcom/capacitorjs/plugins/preferences/Preferences;

    invoke-virtual {v2, v0, v1}, Lcom/capacitorjs/plugins/preferences/Preferences;->set(Ljava/lang/String;Ljava/lang/String;)V

    .line 64
    invoke-virtual {p1}, Lcom/getcapacitor/PluginCall;->resolve()V

    .line 65
    return-void
.end method
