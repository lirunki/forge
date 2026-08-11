.class public final synthetic Lcom/capacitorjs/plugins/preferences/Preferences$$ExternalSyntheticLambda2;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lcom/capacitorjs/plugins/preferences/Preferences$PreferencesOperation;


# instance fields
.field public final synthetic f$0:Ljava/lang/String;


# direct methods
.method public synthetic constructor <init>(Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/capacitorjs/plugins/preferences/Preferences$$ExternalSyntheticLambda2;->f$0:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public final execute(Landroid/content/SharedPreferences$Editor;)V
    .locals 1

    iget-object v0, p0, Lcom/capacitorjs/plugins/preferences/Preferences$$ExternalSyntheticLambda2;->f$0:Ljava/lang/String;

    invoke-static {v0, p1}, Lcom/capacitorjs/plugins/preferences/Preferences;->lambda$remove$1(Ljava/lang/String;Landroid/content/SharedPreferences$Editor;)V

    return-void
.end method
