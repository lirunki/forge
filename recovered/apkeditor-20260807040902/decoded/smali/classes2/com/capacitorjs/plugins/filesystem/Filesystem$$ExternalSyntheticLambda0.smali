.class public final synthetic Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;

.field public final synthetic f$1:Lcom/getcapacitor/JSObject;


# direct methods
.method public synthetic constructor <init>(Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;Lcom/getcapacitor/JSObject;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda0;->f$0:Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;

    iput-object p2, p0, Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda0;->f$1:Lcom/getcapacitor/JSObject;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 2

    iget-object v0, p0, Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda0;->f$0:Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;

    iget-object v1, p0, Lcom/capacitorjs/plugins/filesystem/Filesystem$$ExternalSyntheticLambda0;->f$1:Lcom/getcapacitor/JSObject;

    invoke-static {v0, v1}, Lcom/capacitorjs/plugins/filesystem/Filesystem;->lambda$downloadFile$0(Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;Lcom/getcapacitor/JSObject;)V

    return-void
.end method
