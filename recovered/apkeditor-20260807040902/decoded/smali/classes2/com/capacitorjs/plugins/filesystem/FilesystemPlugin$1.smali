.class Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;
.super Ljava/lang/Object;
.source "FilesystemPlugin.java"

# interfaces
.implements Lcom/capacitorjs/plugins/filesystem/Filesystem$FilesystemDownloadCallback;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->downloadFile(Lcom/getcapacitor/PluginCall;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;

.field final synthetic val$call:Lcom/getcapacitor/PluginCall;

.field final synthetic val$directory:Ljava/lang/String;


# direct methods
.method constructor <init>(Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;Ljava/lang/String;Lcom/getcapacitor/PluginCall;)V
    .locals 0
    .param p1, "this$0"    # Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 406
    iput-object p1, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;->this$0:Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;

    iput-object p2, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;->val$directory:Ljava/lang/String;

    iput-object p3, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;->val$call:Lcom/getcapacitor/PluginCall;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onError(Ljava/lang/Exception;)V
    .locals 3
    .param p1, "error"    # Ljava/lang/Exception;

    .line 418
    iget-object v0, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;->val$call:Lcom/getcapacitor/PluginCall;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Error downloading file: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {p1}, Ljava/lang/Exception;->getLocalizedMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1, p1}, Lcom/getcapacitor/PluginCall;->reject(Ljava/lang/String;Ljava/lang/Exception;)V

    .line 419
    return-void
.end method

.method public onSuccess(Lcom/getcapacitor/JSObject;)V
    .locals 3
    .param p1, "response"    # Lcom/getcapacitor/JSObject;

    .line 410
    iget-object v0, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;->this$0:Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;

    iget-object v1, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;->val$directory:Ljava/lang/String;

    invoke-static {v0, v1}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->-$$Nest$misPublicDirectory(Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 411
    iget-object v0, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;->this$0:Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;

    invoke-virtual {v0}, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin;->getContext()Landroid/content/Context;

    move-result-object v0

    const-string v1, "path"

    invoke-virtual {p1, v1}, Lcom/getcapacitor/JSObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    filled-new-array {v1}, [Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    invoke-static {v0, v1, v2, v2}, Landroid/media/MediaScannerConnection;->scanFile(Landroid/content/Context;[Ljava/lang/String;[Ljava/lang/String;Landroid/media/MediaScannerConnection$OnScanCompletedListener;)V

    .line 413
    :cond_0
    iget-object v0, p0, Lcom/capacitorjs/plugins/filesystem/FilesystemPlugin$1;->val$call:Lcom/getcapacitor/PluginCall;

    invoke-virtual {v0, p1}, Lcom/getcapacitor/PluginCall;->resolve(Lcom/getcapacitor/JSObject;)V

    .line 414
    return-void
.end method
