.class public final synthetic Lcom/forge/live/AppsBridgePlugin$$ExternalSyntheticLambda1;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/util/Comparator;


# direct methods
.method public synthetic constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final compare(Ljava/lang/Object;Ljava/lang/Object;)I
    .locals 0

    check-cast p1, Lcom/getcapacitor/JSObject;

    check-cast p2, Lcom/getcapacitor/JSObject;

    invoke-static {p1, p2}, Lcom/forge/live/AppsBridgePlugin;->lambda$listApps$0(Lcom/getcapacitor/JSObject;Lcom/getcapacitor/JSObject;)I

    move-result p1

    return p1
.end method
