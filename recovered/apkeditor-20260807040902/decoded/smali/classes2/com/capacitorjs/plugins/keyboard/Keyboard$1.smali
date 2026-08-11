.class Lcom/capacitorjs/plugins/keyboard/Keyboard$1;
.super Landroidx/core/view/WindowInsetsAnimationCompat$Callback;
.source "Keyboard.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/capacitorjs/plugins/keyboard/Keyboard;-><init>(Landroidx/appcompat/app/AppCompatActivity;Z)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

.field final synthetic val$activity:Landroidx/appcompat/app/AppCompatActivity;

.field final synthetic val$resizeOnFullScreen:Z


# direct methods
.method constructor <init>(Lcom/capacitorjs/plugins/keyboard/Keyboard;ILandroidx/appcompat/app/AppCompatActivity;Z)V
    .locals 0
    .param p1, "this$0"    # Lcom/capacitorjs/plugins/keyboard/Keyboard;
    .param p2, "arg0"    # I

    .line 51
    iput-object p1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

    iput-object p3, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->val$activity:Landroidx/appcompat/app/AppCompatActivity;

    iput-boolean p4, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->val$resizeOnFullScreen:Z

    invoke-direct {p0, p2}, Landroidx/core/view/WindowInsetsAnimationCompat$Callback;-><init>(I)V

    return-void
.end method


# virtual methods
.method public onEnd(Landroidx/core/view/WindowInsetsAnimationCompat;)V
    .locals 8
    .param p1, "animation"    # Landroidx/core/view/WindowInsetsAnimationCompat;

    .line 87
    invoke-super {p0, p1}, Landroidx/core/view/WindowInsetsAnimationCompat$Callback;->onEnd(Landroidx/core/view/WindowInsetsAnimationCompat;)V

    .line 88
    iget-object v0, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

    invoke-static {v0}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->-$$Nest$fgetrootView(Lcom/capacitorjs/plugins/keyboard/Keyboard;)Landroid/view/View;

    move-result-object v0

    invoke-static {v0}, Landroidx/core/view/ViewCompat;->getRootWindowInsets(Landroid/view/View;)Landroidx/core/view/WindowInsetsCompat;

    move-result-object v0

    invoke-static {}, Landroidx/core/view/WindowInsetsCompat$Type;->ime()I

    move-result v1

    invoke-virtual {v0, v1}, Landroidx/core/view/WindowInsetsCompat;->isVisible(I)Z

    move-result v0

    .line 89
    .local v0, "showingKeyboard":Z
    iget-object v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

    invoke-static {v1}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->-$$Nest$fgetrootView(Lcom/capacitorjs/plugins/keyboard/Keyboard;)Landroid/view/View;

    move-result-object v1

    invoke-static {v1}, Landroidx/core/view/ViewCompat;->getRootWindowInsets(Landroid/view/View;)Landroidx/core/view/WindowInsetsCompat;

    move-result-object v1

    .line 90
    .local v1, "insets":Landroidx/core/view/WindowInsetsCompat;
    invoke-static {}, Landroidx/core/view/WindowInsetsCompat$Type;->ime()I

    move-result v2

    invoke-virtual {v1, v2}, Landroidx/core/view/WindowInsetsCompat;->getInsets(I)Landroidx/core/graphics/Insets;

    move-result-object v2

    iget v2, v2, Landroidx/core/graphics/Insets;->bottom:I

    .line 91
    .local v2, "imeHeight":I
    iget-object v3, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->val$activity:Landroidx/appcompat/app/AppCompatActivity;

    invoke-virtual {v3}, Landroidx/appcompat/app/AppCompatActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v3

    invoke-virtual {v3}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v3

    .line 92
    .local v3, "dm":Landroid/util/DisplayMetrics;
    iget v4, v3, Landroid/util/DisplayMetrics;->density:F

    .line 94
    .local v4, "density":F
    if-eqz v0, :cond_0

    .line 95
    iget-object v5, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

    invoke-static {v5}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->-$$Nest$fgetkeyboardEventListener(Lcom/capacitorjs/plugins/keyboard/Keyboard;)Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;

    move-result-object v5

    int-to-float v6, v2

    div-float/2addr v6, v4

    invoke-static {v6}, Ljava/lang/Math;->round(F)I

    move-result v6

    const-string v7, "keyboardDidShow"

    invoke-interface {v5, v7, v6}, Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;->onKeyboardEvent(Ljava/lang/String;I)V

    goto :goto_0

    .line 97
    :cond_0
    iget-object v5, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

    invoke-static {v5}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->-$$Nest$fgetkeyboardEventListener(Lcom/capacitorjs/plugins/keyboard/Keyboard;)Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;

    move-result-object v5

    const-string v6, "keyboardDidHide"

    const/4 v7, 0x0

    invoke-interface {v5, v6, v7}, Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;->onKeyboardEvent(Ljava/lang/String;I)V

    .line 99
    :goto_0
    return-void
.end method

.method public onProgress(Landroidx/core/view/WindowInsetsCompat;Ljava/util/List;)Landroidx/core/view/WindowInsetsCompat;
    .locals 0
    .param p1, "insets"    # Landroidx/core/view/WindowInsetsCompat;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroidx/core/view/WindowInsetsCompat;",
            "Ljava/util/List<",
            "Landroidx/core/view/WindowInsetsAnimationCompat;",
            ">;)",
            "Landroidx/core/view/WindowInsetsCompat;"
        }
    .end annotation

    .line 58
    .local p2, "runningAnimations":Ljava/util/List;, "Ljava/util/List<Landroidx/core/view/WindowInsetsAnimationCompat;>;"
    return-object p1
.end method

.method public onStart(Landroidx/core/view/WindowInsetsAnimationCompat;Landroidx/core/view/WindowInsetsAnimationCompat$BoundsCompat;)Landroidx/core/view/WindowInsetsAnimationCompat$BoundsCompat;
    .locals 8
    .param p1, "animation"    # Landroidx/core/view/WindowInsetsAnimationCompat;
    .param p2, "bounds"    # Landroidx/core/view/WindowInsetsAnimationCompat$BoundsCompat;

    .line 67
    iget-object v0, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

    invoke-static {v0}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->-$$Nest$fgetrootView(Lcom/capacitorjs/plugins/keyboard/Keyboard;)Landroid/view/View;

    move-result-object v0

    invoke-static {v0}, Landroidx/core/view/ViewCompat;->getRootWindowInsets(Landroid/view/View;)Landroidx/core/view/WindowInsetsCompat;

    move-result-object v0

    invoke-static {}, Landroidx/core/view/WindowInsetsCompat$Type;->ime()I

    move-result v1

    invoke-virtual {v0, v1}, Landroidx/core/view/WindowInsetsCompat;->isVisible(I)Z

    move-result v0

    .line 68
    .local v0, "showingKeyboard":Z
    iget-object v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

    invoke-static {v1}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->-$$Nest$fgetrootView(Lcom/capacitorjs/plugins/keyboard/Keyboard;)Landroid/view/View;

    move-result-object v1

    invoke-static {v1}, Landroidx/core/view/ViewCompat;->getRootWindowInsets(Landroid/view/View;)Landroidx/core/view/WindowInsetsCompat;

    move-result-object v1

    .line 69
    .local v1, "insets":Landroidx/core/view/WindowInsetsCompat;
    invoke-static {}, Landroidx/core/view/WindowInsetsCompat$Type;->ime()I

    move-result v2

    invoke-virtual {v1, v2}, Landroidx/core/view/WindowInsetsCompat;->getInsets(I)Landroidx/core/graphics/Insets;

    move-result-object v2

    iget v2, v2, Landroidx/core/graphics/Insets;->bottom:I

    .line 70
    .local v2, "imeHeight":I
    iget-object v3, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->val$activity:Landroidx/appcompat/app/AppCompatActivity;

    invoke-virtual {v3}, Landroidx/appcompat/app/AppCompatActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v3

    invoke-virtual {v3}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v3

    .line 71
    .local v3, "dm":Landroid/util/DisplayMetrics;
    iget v4, v3, Landroid/util/DisplayMetrics;->density:F

    .line 73
    .local v4, "density":F
    iget-boolean v5, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->val$resizeOnFullScreen:Z

    if-eqz v5, :cond_0

    .line 74
    iget-object v5, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

    invoke-static {v5, v0}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->-$$Nest$mpossiblyResizeChildOfContent(Lcom/capacitorjs/plugins/keyboard/Keyboard;Z)V

    .line 77
    :cond_0
    if-eqz v0, :cond_1

    .line 78
    iget-object v5, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

    invoke-static {v5}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->-$$Nest$fgetkeyboardEventListener(Lcom/capacitorjs/plugins/keyboard/Keyboard;)Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;

    move-result-object v5

    int-to-float v6, v2

    div-float/2addr v6, v4

    invoke-static {v6}, Ljava/lang/Math;->round(F)I

    move-result v6

    const-string v7, "keyboardWillShow"

    invoke-interface {v5, v7, v6}, Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;->onKeyboardEvent(Ljava/lang/String;I)V

    goto :goto_0

    .line 80
    :cond_1
    iget-object v5, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;->this$0:Lcom/capacitorjs/plugins/keyboard/Keyboard;

    invoke-static {v5}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->-$$Nest$fgetkeyboardEventListener(Lcom/capacitorjs/plugins/keyboard/Keyboard;)Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;

    move-result-object v5

    const-string v6, "keyboardWillHide"

    const/4 v7, 0x0

    invoke-interface {v5, v6, v7}, Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;->onKeyboardEvent(Ljava/lang/String;I)V

    .line 82
    :goto_0
    invoke-super {p0, p1, p2}, Landroidx/core/view/WindowInsetsAnimationCompat$Callback;->onStart(Landroidx/core/view/WindowInsetsAnimationCompat;Landroidx/core/view/WindowInsetsAnimationCompat$BoundsCompat;)Landroidx/core/view/WindowInsetsAnimationCompat$BoundsCompat;

    move-result-object v5

    return-object v5
.end method
