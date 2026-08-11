.class public final Landroidx/drawerlayout/R$styleable;
.super Ljava/lang/Object;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Landroidx/drawerlayout/R;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "styleable"
.end annotation


# static fields
.field public static ColorStateListItem:[I = null

.field public static ColorStateListItem_alpha:I = 0x3

.field public static ColorStateListItem_android_alpha:I = 0x1

.field public static ColorStateListItem_android_color:I = 0x0

.field public static ColorStateListItem_android_lStar:I = 0x2

.field public static ColorStateListItem_lStar:I = 0x4

.field public static FontFamily:[I = null

.field public static FontFamilyFont:[I = null

.field public static FontFamilyFont_android_font:I = 0x0

.field public static FontFamilyFont_android_fontStyle:I = 0x2

.field public static FontFamilyFont_android_fontVariationSettings:I = 0x4

.field public static FontFamilyFont_android_fontWeight:I = 0x1

.field public static FontFamilyFont_android_ttcIndex:I = 0x3

.field public static FontFamilyFont_font:I = 0x5

.field public static FontFamilyFont_fontStyle:I = 0x6

.field public static FontFamilyFont_fontVariationSettings:I = 0x7

.field public static FontFamilyFont_fontWeight:I = 0x8

.field public static FontFamilyFont_ttcIndex:I = 0x9

.field public static FontFamily_fontProviderAuthority:I = 0x0

.field public static FontFamily_fontProviderCerts:I = 0x1

.field public static FontFamily_fontProviderFetchStrategy:I = 0x2

.field public static FontFamily_fontProviderFetchTimeout:I = 0x3

.field public static FontFamily_fontProviderPackage:I = 0x4

.field public static FontFamily_fontProviderQuery:I = 0x5

.field public static FontFamily_fontProviderSystemFontFamily:I = 0x6

.field public static GradientColor:[I = null

.field public static GradientColorItem:[I = null

.field public static GradientColorItem_android_color:I = 0x0

.field public static GradientColorItem_android_offset:I = 0x1

.field public static GradientColor_android_centerColor:I = 0x7

.field public static GradientColor_android_centerX:I = 0x3

.field public static GradientColor_android_centerY:I = 0x4

.field public static GradientColor_android_endColor:I = 0x1

.field public static GradientColor_android_endX:I = 0xa

.field public static GradientColor_android_endY:I = 0xb

.field public static GradientColor_android_gradientRadius:I = 0x5

.field public static GradientColor_android_startColor:I = 0x0

.field public static GradientColor_android_startX:I = 0x8

.field public static GradientColor_android_startY:I = 0x9

.field public static GradientColor_android_tileMode:I = 0x6

.field public static GradientColor_android_type:I = 0x2


# direct methods
.method public static constructor <clinit>()V
    .locals 5

    const v0, 0x7f030029    # @attr/alpha

    const v1, 0x7f03009e    # @attr/lStar

    const v2, 0x10101a5    # @android:attr/color

    const v3, 0x101031f    # @android:attr/alpha

    const v4, 0x1010647    # @android:attr/lStar

    filled-new-array {v2, v3, v4, v0, v1}, [I

    move-result-object v0

    sput-object v0, Landroidx/drawerlayout/R$styleable;->ColorStateListItem:[I

    const/4 v0, 0x7

    new-array v0, v0, [I

    fill-array-data v0, :array_0

    sput-object v0, Landroidx/drawerlayout/R$styleable;->FontFamily:[I

    const/16 v0, 0xa

    new-array v0, v0, [I

    fill-array-data v0, :array_1

    sput-object v0, Landroidx/drawerlayout/R$styleable;->FontFamilyFont:[I

    const/16 v0, 0xc

    new-array v0, v0, [I

    fill-array-data v0, :array_2

    sput-object v0, Landroidx/drawerlayout/R$styleable;->GradientColor:[I

    const v0, 0x1010514    # @android:attr/offset

    filled-new-array {v2, v0}, [I

    move-result-object v0

    sput-object v0, Landroidx/drawerlayout/R$styleable;->GradientColorItem:[I

    return-void

    nop

    :array_0
    .array-data 4
        0x7f030084    # @attr/fontProviderAuthority
        0x7f030085    # @attr/fontProviderCerts
        0x7f030086    # @attr/fontProviderFetchStrategy
        0x7f030087    # @attr/fontProviderFetchTimeout
        0x7f030088    # @attr/fontProviderPackage
        0x7f030089    # @attr/fontProviderQuery
        0x7f03008a    # @attr/fontProviderSystemFontFamily
    .end array-data

    :array_1
    .array-data 4
        0x1010532    # @android:attr/font
        0x1010533    # @android:attr/fontWeight
        0x101053f    # @android:attr/fontStyle
        0x101056f    # @android:attr/ttcIndex
        0x1010570    # @android:attr/fontVariationSettings
        0x7f030082    # @attr/font
        0x7f03008b    # @attr/fontStyle
        0x7f03008c    # @attr/fontVariationSettings
        0x7f03008d    # @attr/fontWeight
        0x7f030120    # @attr/ttcIndex
    .end array-data

    :array_2
    .array-data 4
        0x101019d    # @android:attr/startColor
        0x101019e    # @android:attr/endColor
        0x10101a1    # @android:attr/type
        0x10101a2    # @android:attr/centerX
        0x10101a3    # @android:attr/centerY
        0x10101a4    # @android:attr/gradientRadius
        0x1010201    # @android:attr/tileMode
        0x101020b    # @android:attr/centerColor
        0x1010510    # @android:attr/startX
        0x1010511    # @android:attr/startY
        0x1010512    # @android:attr/endX
        0x1010513    # @android:attr/endY
    .end array-data
.end method

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
