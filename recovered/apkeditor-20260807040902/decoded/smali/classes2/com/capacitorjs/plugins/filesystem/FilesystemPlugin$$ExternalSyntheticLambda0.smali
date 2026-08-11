.class public final synthetic Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lcom/getcapacitor/plugin/util/HttpRequestHandler$ProgressEmitter;


# instance fields
.field public final synthetic f$0:Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;

.field public final synthetic f$1:Lcom/getcapacitor/PluginCall;


# direct methods
.method public synthetic constructor <init>(Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$$ExternalSyntheticLambda0;->f$0:Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;

    iput-object p2, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$$ExternalSyntheticLambda0;->f$1:Lcom/getcapacitor/PluginCall;

    return-void
.end method


# virtual methods
.method public final emit(Ljava/lang/Integer;Ljava/lang/Integer;)V
    .locals 2

    iget-object v0, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$$ExternalSyntheticLambda0;->f$0:Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;

    iget-object v1, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$$ExternalSyntheticLambda0;->f$1:Lcom/getcapacitor/PluginCall;

    invoke-static {v0, v1, p1, p2}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->$r8$lambda$tJinBSNTGfJjWjnt9ILUoMFMeN8(Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;Lcom/getcapacitor/PluginCall;Ljava/lang/Integer;Ljava/lang/Integer;)V

    return-void
.end method
