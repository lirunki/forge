.class Lcom/capacitorjs/plugins/app/AppPlugin$1;
.super Landroidx/activity/OnBackPressedCallback;
.source "AppPlugin.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/capacitorjs/plugins/app/AppPlugin;->load()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/capacitorjs/plugins/app/AppPlugin;


# direct methods
.method constructor <init>(Lcom/capacitorjs/plugins/app/AppPlugin;Z)V
    .locals 0
    .param p1, "this$0"    # Lcom/capacitorjs/plugins/app/AppPlugin;
    .param p2, "arg0"    # Z

    .line 47
    iput-object p1, p0, Lcom/capacitorjs/plugins/app/AppPlugin$1;->this$0:Lcom/capacitorjs/plugins/app/AppPlugin;

    invoke-direct {p0, p2}, Landroidx/activity/OnBackPressedCallback;-><init>(Z)V

    return-void
.end method


# virtual methods
.method public handleOnBackPressed()V
    .locals 4

    .line 50
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin$1;->this$0:Lcom/capacitorjs/plugins/app/AppPlugin;

    const-string v1, "backButton"

    invoke-static {v0, v1}, Lcom/capacitorjs/plugins/app/AppPlugin;->access$000(Lcom/capacitorjs/plugins/app/AppPlugin;Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 51
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin$1;->this$0:Lcom/capacitorjs/plugins/app/AppPlugin;

    invoke-static {v0}, Lcom/capacitorjs/plugins/app/AppPlugin;->access$100(Lcom/capacitorjs/plugins/app/AppPlugin;)Lcom/getcapacitor/Bridge;

    move-result-object v0

    invoke-virtual {v0}, Lcom/getcapacitor/Bridge;->getWebView()Landroid/webkit/WebView;

    move-result-object v0

    invoke-virtual {v0}, Landroid/webkit/WebView;->canGoBack()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 52
    iget-object v0, p0, Lcom/capacitorjs/plugins/app/AppPlugin$1;->this$0:Lcom/capacitorjs/plugins/app/AppPlugin;

    invoke-static {v0}, Lcom/capacitorjs/plugins/app/AppPlugin;->access$200(Lcom/capacitorjs/plugins/app/AppPlugin;)Lcom/getcapacitor/Bridge;

    move-result-object v0

    invoke-virtual {v0}, Lcom/getcapacitor/Bridge;->getWebView()Landroid/webkit/WebView;

    move-result-object v0

    invoke-virtual {v0}, Landroid/webkit/WebView;->goBack()V

    goto :goto_0

    .line 55
    :cond_0
    new-instance v0, Lcom/getcapacitor/JSObject;

    invoke-direct {v0}, Lcom/getcapacitor/JSObject;-><init>()V

    .line 56
    .local v0, "data":Lcom/getcapacitor/JSObject;
    iget-object v2, p0, Lcom/capacitorjs/plugins/app/AppPlugin$1;->this$0:Lcom/capacitorjs/plugins/app/AppPlugin;

    invoke-static {v2}, Lcom/capacitorjs/plugins/app/AppPlugin;->access$300(Lcom/capacitorjs/plugins/app/AppPlugin;)Lcom/getcapacitor/Bridge;

    move-result-object v2

    invoke-virtual {v2}, Lcom/getcapacitor/Bridge;->getWebView()Landroid/webkit/WebView;

    move-result-object v2

    invoke-virtual {v2}, Landroid/webkit/WebView;->canGoBack()Z

    move-result v2

    const-string v3, "canGoBack"

    invoke-virtual {v0, v3, v2}, Lcom/getcapacitor/JSObject;->put(Ljava/lang/String;Z)Lcom/getcapacitor/JSObject;

    .line 57
    iget-object v2, p0, Lcom/capacitorjs/plugins/app/AppPlugin$1;->this$0:Lcom/capacitorjs/plugins/app/AppPlugin;

    const/4 v3, 0x1

    invoke-static {v2, v1, v0, v3}, Lcom/capacitorjs/plugins/app/AppPlugin;->access$400(Lcom/capacitorjs/plugins/app/AppPlugin;Ljava/lang/String;Lcom/getcapacitor/JSObject;Z)V

    .line 58
    iget-object v1, p0, Lcom/capacitorjs/plugins/app/AppPlugin$1;->this$0:Lcom/capacitorjs/plugins/app/AppPlugin;

    invoke-static {v1}, Lcom/capacitorjs/plugins/app/AppPlugin;->access$500(Lcom/capacitorjs/plugins/app/AppPlugin;)Lcom/getcapacitor/Bridge;

    move-result-object v1

    const-string v2, "backbutton"

    const-string v3, "document"

    invoke-virtual {v1, v2, v3}, Lcom/getcapacitor/Bridge;->triggerJSEvent(Ljava/lang/String;Ljava/lang/String;)V

    .line 60
    .end local v0    # "data":Lcom/getcapacitor/JSObject;
    :cond_1
    :goto_0
    return-void
.end method
