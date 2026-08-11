.class public final synthetic Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/forge/live/MicBridgePlugin;

.field public final synthetic f$1:Lcom/getcapacitor/PluginCall;

.field public final synthetic f$2:Z

.field public final synthetic f$3:Ljava/lang/String;

.field public final synthetic f$4:I


# direct methods
.method public synthetic constructor <init>(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;ZLjava/lang/String;I)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;->f$0:Lcom/forge/live/MicBridgePlugin;

    iput-object p2, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;->f$1:Lcom/getcapacitor/PluginCall;

    iput-boolean p3, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;->f$2:Z

    iput-object p4, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;->f$3:Ljava/lang/String;

    iput p5, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;->f$4:I

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 5

    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;->f$0:Lcom/forge/live/MicBridgePlugin;

    iget-object v1, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;->f$1:Lcom/getcapacitor/PluginCall;

    iget-boolean v2, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;->f$2:Z

    iget-object v3, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;->f$3:Ljava/lang/String;

    iget v4, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda2;->f$4:I

    invoke-static {v0, v1, v2, v3, v4}, Lcom/forge/live/MicBridgePlugin;->$r8$lambda$9DsIlTNjQrTz4AZQJHGuxtzQUi8(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;ZLjava/lang/String;I)V

    return-void
.end method
