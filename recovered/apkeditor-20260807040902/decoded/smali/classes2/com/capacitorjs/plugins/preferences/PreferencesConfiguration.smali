.class public Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;
.super Ljava/lang/Object;
.source "PreferencesConfiguration.java"

# interfaces
.implements Ljava/lang/Cloneable;


# static fields
.field static final DEFAULTS:Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;


# instance fields
.field group:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .line 8
    new-instance v0, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;

    invoke-direct {v0}, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;-><init>()V

    sput-object v0, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->DEFAULTS:Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;

    .line 9
    const-string v1, "CapacitorStorage"

    iput-object v1, v0, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->group:Ljava/lang/String;

    .line 10
    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .line 3
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public clone()Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/CloneNotSupportedException;
        }
    .end annotation

    .line 16
    invoke-super {p0}, Ljava/lang/Object;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;

    return-object v0
.end method

.method public bridge synthetic clone()Ljava/lang/Object;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/CloneNotSupportedException;
        }
    .end annotation

    .line 3
    invoke-virtual {p0}, Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;->clone()Lcom/capacitorjs/plugins/preferences/PreferencesConfiguration;

    move-result-object v0

    return-object v0
.end method
