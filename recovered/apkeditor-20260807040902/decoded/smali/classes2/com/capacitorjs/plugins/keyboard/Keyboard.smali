.class public Lcom/capacitorjs/plugins/keyboard/Keyboard;
.super Ljava/lang/Object;
.source "Keyboard.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;
    }
.end annotation


# static fields
.field static final EVENT_KB_DID_HIDE:Ljava/lang/String; = "keyboardDidHide"

.field static final EVENT_KB_DID_SHOW:Ljava/lang/String; = "keyboardDidShow"

.field static final EVENT_KB_WILL_HIDE:Ljava/lang/String; = "keyboardWillHide"

.field static final EVENT_KB_WILL_SHOW:Ljava/lang/String; = "keyboardWillShow"


# instance fields
.field private activity:Landroidx/appcompat/app/AppCompatActivity;

.field private frameLayoutParams:Landroid/widget/FrameLayout$LayoutParams;

.field private keyboardEventListener:Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;

.field private mChildOfContent:Landroid/view/View;

.field private rootView:Landroid/view/View;

.field private usableHeightPrevious:I


# direct methods
.method static bridge synthetic -$$Nest$fgetkeyboardEventListener(Lcom/capacitorjs/plugins/keyboard/Keyboard;)Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;
    .locals 0

    iget-object p0, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->keyboardEventListener:Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$fgetrootView(Lcom/capacitorjs/plugins/keyboard/Keyboard;)Landroid/view/View;
    .locals 0

    iget-object p0, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->rootView:Landroid/view/View;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$mpossiblyResizeChildOfContent(Lcom/capacitorjs/plugins/keyboard/Keyboard;Z)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->possiblyResizeChildOfContent(Z)V

    return-void
.end method

.method public constructor <init>(Landroidx/appcompat/app/AppCompatActivity;Z)V
    .locals 4
    .param p1, "activity"    # Landroidx/appcompat/app/AppCompatActivity;
    .param p2, "resizeOnFullScreen"    # Z

    .line 42
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 43
    iput-object p1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->activity:Landroidx/appcompat/app/AppCompatActivity;

    .line 46
    invoke-virtual {p1}, Landroidx/appcompat/app/AppCompatActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    const v1, 0x1020002    # @android:id/content

    invoke-virtual {v0, v1}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/FrameLayout;

    .line 47
    .local v0, "content":Landroid/widget/FrameLayout;
    invoke-virtual {v0}, Landroid/widget/FrameLayout;->getRootView()Landroid/view/View;

    move-result-object v1

    iput-object v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->rootView:Landroid/view/View;

    .line 49
    new-instance v2, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;

    const/4 v3, 0x0

    invoke-direct {v2, p0, v3, p1, p2}, Lcom/capacitorjs/plugins/keyboard/Keyboard$1;-><init>(Lcom/capacitorjs/plugins/keyboard/Keyboard;ILandroidx/appcompat/app/AppCompatActivity;Z)V

    invoke-static {v1, v2}, Landroidx/core/view/ViewCompat;->setWindowInsetsAnimationCallback(Landroid/view/View;Landroidx/core/view/WindowInsetsAnimationCompat$Callback;)V

    .line 103
    invoke-virtual {v0, v3}, Landroid/widget/FrameLayout;->getChildAt(I)Landroid/view/View;

    move-result-object v1

    iput-object v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->mChildOfContent:Landroid/view/View;

    .line 104
    invoke-virtual {v1}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object v1

    check-cast v1, Landroid/widget/FrameLayout$LayoutParams;

    iput-object v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->frameLayoutParams:Landroid/widget/FrameLayout$LayoutParams;

    .line 105
    return-void
.end method

.method private computeUsableHeight()I
    .locals 2

    .line 132
    new-instance v0, Landroid/graphics/Rect;

    invoke-direct {v0}, Landroid/graphics/Rect;-><init>()V

    .line 133
    .local v0, "r":Landroid/graphics/Rect;
    iget-object v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->mChildOfContent:Landroid/view/View;

    invoke-virtual {v1, v0}, Landroid/view/View;->getWindowVisibleDisplayFrame(Landroid/graphics/Rect;)V

    .line 134
    invoke-direct {p0}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->isOverlays()Z

    move-result v1

    if-eqz v1, :cond_0

    iget v1, v0, Landroid/graphics/Rect;->bottom:I

    goto :goto_0

    :cond_0
    invoke-virtual {v0}, Landroid/graphics/Rect;->height()I

    move-result v1

    :goto_0
    return v1
.end method

.method private isOverlays()Z
    .locals 3

    .line 139
    iget-object v0, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->activity:Landroidx/appcompat/app/AppCompatActivity;

    invoke-virtual {v0}, Landroidx/appcompat/app/AppCompatActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    .line 140
    .local v0, "window":Landroid/view/Window;
    nop

    .line 141
    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v1

    invoke-virtual {v1}, Landroid/view/View;->getSystemUiVisibility()I

    move-result v1

    const/16 v2, 0x400

    and-int/2addr v1, v2

    if-ne v1, v2, :cond_0

    const/4 v1, 0x1

    goto :goto_0

    :cond_0
    const/4 v1, 0x0

    .line 140
    :goto_0
    return v1
.end method

.method private possiblyResizeChildOfContent(Z)V
    .locals 2
    .param p1, "keyboardShown"    # Z

    .line 123
    if-eqz p1, :cond_0

    invoke-direct {p0}, Lcom/capacitorjs/plugins/keyboard/Keyboard;->computeUsableHeight()I

    move-result v0

    goto :goto_0

    :cond_0
    const/4 v0, -0x1

    .line 124
    .local v0, "usableHeightNow":I
    :goto_0
    iget v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->usableHeightPrevious:I

    if-eq v1, v0, :cond_1

    .line 125
    iget-object v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->frameLayoutParams:Landroid/widget/FrameLayout$LayoutParams;

    iput v0, v1, Landroid/widget/FrameLayout$LayoutParams;->height:I

    .line 126
    iget-object v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->mChildOfContent:Landroid/view/View;

    invoke-virtual {v1}, Landroid/view/View;->requestLayout()V

    .line 127
    iput v0, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->usableHeightPrevious:I

    .line 129
    :cond_1
    return-void
.end method


# virtual methods
.method public hide()Z
    .locals 4

    .line 112
    iget-object v0, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->activity:Landroidx/appcompat/app/AppCompatActivity;

    const-string v1, "input_method"

    invoke-virtual {v0, v1}, Landroidx/appcompat/app/AppCompatActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/inputmethod/InputMethodManager;

    .line 113
    .local v0, "inputManager":Landroid/view/inputmethod/InputMethodManager;
    iget-object v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->activity:Landroidx/appcompat/app/AppCompatActivity;

    invoke-virtual {v1}, Landroidx/appcompat/app/AppCompatActivity;->getCurrentFocus()Landroid/view/View;

    move-result-object v1

    .line 114
    .local v1, "v":Landroid/view/View;
    if-nez v1, :cond_0

    .line 115
    const/4 v2, 0x0

    return v2

    .line 117
    :cond_0
    invoke-virtual {v1}, Landroid/view/View;->getWindowToken()Landroid/os/IBinder;

    move-result-object v2

    const/4 v3, 0x2

    invoke-virtual {v0, v2, v3}, Landroid/view/inputmethod/InputMethodManager;->hideSoftInputFromWindow(Landroid/os/IBinder;I)Z

    .line 118
    const/4 v2, 0x1

    return v2
.end method

.method public setKeyboardEventListener(Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;)V
    .locals 0
    .param p1, "keyboardEventListener"    # Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;

    .line 31
    iput-object p1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->keyboardEventListener:Lcom/capacitorjs/plugins/keyboard/Keyboard$KeyboardEventListener;

    .line 32
    return-void
.end method

.method public show()V
    .locals 3

    .line 108
    iget-object v0, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->activity:Landroidx/appcompat/app/AppCompatActivity;

    const-string v1, "input_method"

    invoke-virtual {v0, v1}, Landroidx/appcompat/app/AppCompatActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/inputmethod/InputMethodManager;

    iget-object v1, p0, Lcom/capacitorjs/plugins/keyboard/Keyboard;->activity:Landroidx/appcompat/app/AppCompatActivity;

    invoke-virtual {v1}, Landroidx/appcompat/app/AppCompatActivity;->getCurrentFocus()Landroid/view/View;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/view/inputmethod/InputMethodManager;->showSoftInput(Landroid/view/View;I)Z

    .line 109
    return-void
.end method
