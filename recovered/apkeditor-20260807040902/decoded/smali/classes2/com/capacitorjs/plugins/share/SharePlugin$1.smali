.class Lcom/capacitorjs/plugins/share/SharePlugin$1;
.super Landroid/content/BroadcastReceiver;
.source "SharePlugin.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/capacitorjs/plugins/share/SharePlugin;->load()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/capacitorjs/plugins/share/SharePlugin;


# direct methods
.method constructor <init>(Lcom/capacitorjs/plugins/share/SharePlugin;)V
    .locals 0
    .param p1, "this$0"    # Lcom/capacitorjs/plugins/share/SharePlugin;

    .line 35
    iput-object p1, p0, Lcom/capacitorjs/plugins/share/SharePlugin$1;->this$0:Lcom/capacitorjs/plugins/share/SharePlugin;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .line 38
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x21

    const-string v2, "android.intent.extra.CHOSEN_COMPONENT"

    if-lt v0, v1, :cond_0

    .line 39
    iget-object v0, p0, Lcom/capacitorjs/plugins/share/SharePlugin$1;->this$0:Lcom/capacitorjs/plugins/share/SharePlugin;

    const-class v1, Landroid/content/ComponentName;

    invoke-virtual {p2, v2, v1}, Landroid/content/Intent;->getParcelableExtra(Ljava/lang/String;Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/content/ComponentName;

    invoke-static {v0, v1}, Lcom/capacitorjs/plugins/share/SharePlugin;->-$$Nest$fputchosenComponent(Lcom/capacitorjs/plugins/share/SharePlugin;Landroid/content/ComponentName;)V

    goto :goto_0

    .line 41
    :cond_0
    iget-object v0, p0, Lcom/capacitorjs/plugins/share/SharePlugin$1;->this$0:Lcom/capacitorjs/plugins/share/SharePlugin;

    invoke-static {v0, p2, v2}, Lcom/capacitorjs/plugins/share/SharePlugin;->-$$Nest$mgetParcelableExtraLegacy(Lcom/capacitorjs/plugins/share/SharePlugin;Landroid/content/Intent;Ljava/lang/String;)Landroid/content/ComponentName;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/capacitorjs/plugins/share/SharePlugin;->-$$Nest$fputchosenComponent(Lcom/capacitorjs/plugins/share/SharePlugin;Landroid/content/ComponentName;)V

    .line 43
    :goto_0
    return-void
.end method
