.class public Lcom/capacitorjs/plugins/preferences/Preferences;
.super Ljava/lang/Object;
.source "Preferences.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/capacitorjs/plugins/preferences/Preferences$PreferencesOperation;
    }
.end annotation


# instance fields
.field private preferences:Landroid/content/SharedPreferences;


# direct methods
.method constructor <init>(Landroid/content/Context;Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;)V
    .locals 2
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "configuration"    # Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;

    .line 16
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 17
    iget-object v0, p2, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->group:Ljava/lang/String;

    const/4 v1, 0x0

    invoke-virtual {p1, v0, v1}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;

    move-result-object v0

    iput-object v0, p0, Lcom/capacitorjs/plugins/preferences/Preferences;->preferences:Landroid/content/SharedPreferences;

    .line 18
    return-void
.end method

.method private executeOperation(Lcom/capacitorjs/plugins/preferences/Preferences$PreferencesOperation;)V
    .locals 1
    .param p1, "op"    # Lcom/capacitorjs/plugins/preferences/Preferences$PreferencesOperation;

    .line 41
    iget-object v0, p0, Lcom/capacitorjs/plugins/preferences/Preferences;->preferences:Landroid/content/SharedPreferences;

    invoke-interface {v0}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    .line 42
    .local v0, "editor":Landroid/content/SharedPreferences$Editor;
    invoke-interface {p1, v0}, Lcom/capacitorjs/plugins/preferences/Preferences$PreferencesOperation;->execute(Landroid/content/SharedPreferences$Editor;)V

    .line 43
    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->apply()V

    .line 44
    return-void
.end method

.method static synthetic lambda$remove$1(Ljava/lang/String;Landroid/content/SharedPreferences$Editor;)V
    .locals 0
    .param p0, "key"    # Ljava/lang/String;
    .param p1, "editor"    # Landroid/content/SharedPreferences$Editor;

    .line 29
    invoke-interface {p1, p0}, Landroid/content/SharedPreferences$Editor;->remove(Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    return-void
.end method

.method static synthetic lambda$set$0(Ljava/lang/String;Ljava/lang/String;Landroid/content/SharedPreferences$Editor;)V
    .locals 0
    .param p0, "key"    # Ljava/lang/String;
    .param p1, "value"    # Ljava/lang/String;
    .param p2, "editor"    # Landroid/content/SharedPreferences$Editor;

    .line 25
    invoke-interface {p2, p0, p1}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;

    return-void
.end method


# virtual methods
.method public clear()V
    .locals 1

    .line 37
    new-instance v0, Lcom/capacitorjs/plugins/preferences/Preferences$$ExternalSyntheticLambda0;

    invoke-direct {v0}, Lcom/capacitorjs/plugins/preferences/Preferences$$ExternalSyntheticLambda0;-><init>()V

    invoke-direct {p0, v0}, Lcom/capacitorjs/plugins/preferences/Preferences;->executeOperation(Lcom/capacitorjs/plugins/preferences/Preferences$PreferencesOperation;)V

    .line 38
    return-void
.end method

.method public get(Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    .param p1, "key"    # Ljava/lang/String;

    .line 21
    iget-object v0, p0, Lcom/capacitorjs/plugins/preferences/Preferences;->preferences:Landroid/content/SharedPreferences;

    const/4 v1, 0x0

    invoke-interface {v0, p1, v1}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public keys()Ljava/util/Set;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/Set<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 33
    iget-object v0, p0, Lcom/capacitorjs/plugins/preferences/Preferences;->preferences:Landroid/content/SharedPreferences;

    invoke-interface {v0}, Landroid/content/SharedPreferences;->getAll()Ljava/util/Map;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Map;->keySet()Ljava/util/Set;

    move-result-object v0

    return-object v0
.end method

.method public remove(Ljava/lang/String;)V
    .locals 1
    .param p1, "key"    # Ljava/lang/String;

    .line 29
    new-instance v0, Lcom/capacitorjs/plugins/preferences/Preferences$$ExternalSyntheticLambda2;

    invoke-direct {v0, p1}, Lcom/capacitorjs/plugins/preferences/Preferences$$ExternalSyntheticLambda2;-><init>(Ljava/lang/String;)V

    invoke-direct {p0, v0}, Lcom/capacitorjs/plugins/preferences/Preferences;->executeOperation(Lcom/capacitorjs/plugins/preferences/Preferences$PreferencesOperation;)V

    .line 30
    return-void
.end method

.method public set(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p1, "key"    # Ljava/lang/String;
    .param p2, "value"    # Ljava/lang/String;

    .line 25
    new-instance v0, Lcom/capacitorjs/plugins/preferences/Preferences$$ExternalSyntheticLambda1;

    invoke-direct {v0, p1, p2}, Lcom/capacitorjs/plugins/preferences/Preferences$$ExternalSyntheticLambda1;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    invoke-direct {p0, v0}, Lcom/capacitorjs/plugins/preferences/Preferences;->executeOperation(Lcom/capacitorjs/plugins/preferences/Preferences$PreferencesOperation;)V

    .line 26
    return-void
.end method
