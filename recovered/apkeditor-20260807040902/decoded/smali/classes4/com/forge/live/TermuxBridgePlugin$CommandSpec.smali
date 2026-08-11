.class Lcom/forge/live/TermuxBridgePlugin$CommandSpec;
.super Ljava/lang/Object;
.source "TermuxBridgePlugin.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/forge/live/TermuxBridgePlugin;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "CommandSpec"
.end annotation


# instance fields
.field argsList:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field background:Z

.field cmdPath:Ljava/lang/String;

.field cwd:Ljava/lang/String;

.field description:Ljava/lang/String;

.field label:Ljava/lang/String;


# direct methods
.method private constructor <init>()V
    .locals 1

    .line 931
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 933
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->argsList:Ljava/util/ArrayList;

    .line 934
    const-string v0, "/data/data/com.termux/files/home"

    iput-object v0, p0, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->cwd:Ljava/lang/String;

    .line 935
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->background:Z

    .line 936
    const-string v0, "Forge"

    iput-object v0, p0, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->label:Ljava/lang/String;

    .line 937
    const-string v0, "Command from Forge"

    iput-object v0, p0, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;->description:Ljava/lang/String;

    return-void
.end method

.method synthetic constructor <init>(Lcom/forge/live/TermuxBridgePlugin$CommandSpec-IA;)V
    .locals 0

    invoke-direct {p0}, Lcom/forge/live/TermuxBridgePlugin$CommandSpec;-><init>()V

    return-void
.end method
