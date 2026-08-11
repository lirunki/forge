.class public final synthetic Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/forge/live/MicBridgePlugin;

.field public final synthetic f$1:Lcom/getcapacitor/PluginCall;


# direct methods
.method public synthetic constructor <init>(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda0;->f$0:Lcom/forge/live/MicBridgePlugin;

    iput-object p2, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda0;->f$1:Lcom/getcapacitor/PluginCall;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 2

    iget-object v0, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda0;->f$0:Lcom/forge/live/MicBridgePlugin;

    iget-object v1, p0, Lcom/forge/live/MicBridgePlugin$$ExternalSyntheticLambda0;->f$1:Lcom/getcapacitor/PluginCall;

    invoke-static {v0, v1}, Lcom/forge/live/MicBridgePlugin;->$r8$lambda$aqxxMoqY3wJZqFbozgnyKZRzxSA(Lcom/forge/live/MicBridgePlugin;Lcom/getcapacitor/PluginCall;)V

    return-void
.end method
