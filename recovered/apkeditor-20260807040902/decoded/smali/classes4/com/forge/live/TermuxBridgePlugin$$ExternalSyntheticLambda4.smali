.class public final synthetic Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/forge/live/TermuxBridgePlugin;

.field public final synthetic f$1:Lcom/forge/live/TermuxBridgePlugin$CommandSpec;

.field public final synthetic f$2:I

.field public final synthetic f$3:Lcom/getcapacitor/PluginCall;


# direct methods
.method public synthetic constructor <init>(Lcom/forge/live/TermuxBridgePlugin;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;ILcom/getcapacitor/PluginCall;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;->f$0:Lcom/forge/live/TermuxBridgePlugin;

    iput-object p2, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;->f$1:Lcom/forge/live/TermuxBridgePlugin$CommandSpec;

    iput p3, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;->f$2:I

    iput-object p4, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;->f$3:Lcom/getcapacitor/PluginCall;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 4

    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;->f$0:Lcom/forge/live/TermuxBridgePlugin;

    iget-object v1, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;->f$1:Lcom/forge/live/TermuxBridgePlugin$CommandSpec;

    iget v2, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;->f$2:I

    iget-object v3, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda4;->f$3:Lcom/getcapacitor/PluginCall;

    invoke-static {v0, v1, v2, v3}, Lcom/forge/live/TermuxBridgePlugin;->$r8$lambda$tZVhasa-PRtbq9hfyunLn31BjUo(Lcom/forge/live/TermuxBridgePlugin;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;ILcom/getcapacitor/PluginCall;)V

    return-void
.end method
