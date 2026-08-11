.class public final synthetic Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/forge/live/TermuxBridgePlugin;

.field public final synthetic f$1:Lcom/getcapacitor/PluginCall;

.field public final synthetic f$2:Lcom/forge/live/TermuxBridgePlugin$CommandSpec;

.field public final synthetic f$3:I


# direct methods
.method public synthetic constructor <init>(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;I)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;->f$0:Lcom/forge/live/TermuxBridgePlugin;

    iput-object p2, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;->f$1:Lcom/getcapacitor/PluginCall;

    iput-object p3, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;->f$2:Lcom/forge/live/TermuxBridgePlugin$CommandSpec;

    iput p4, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;->f$3:I

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 4

    iget-object v0, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;->f$0:Lcom/forge/live/TermuxBridgePlugin;

    iget-object v1, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;->f$1:Lcom/getcapacitor/PluginCall;

    iget-object v2, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;->f$2:Lcom/forge/live/TermuxBridgePlugin$CommandSpec;

    iget v3, p0, Lcom/forge/live/TermuxBridgePlugin$$ExternalSyntheticLambda0;->f$3:I

    invoke-static {v0, v1, v2, v3}, Lcom/forge/live/TermuxBridgePlugin;->$r8$lambda$037oac5EdKTFwk9Dwsjgg_GcL80(Lcom/forge/live/TermuxBridgePlugin;Lcom/getcapacitor/PluginCall;Lcom/forge/live/TermuxBridgePlugin$CommandSpec;I)V

    return-void
.end method
