.class Lcom/samsung/android/ui/recyclerview/widget/SeslRecyclerViewFastScroller$1;
.super Landroid/util/IntProperty;
.source "SeslRecyclerViewFastScroller.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/samsung/android/ui/recyclerview/widget/SeslRecyclerViewFastScroller;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Landroid/util/IntProperty<",
        "Landroid/view/View;",
        ">;"
    }
.end annotation


# direct methods
.method constructor <init>(Ljava/lang/String;)V
    .locals 0
    .param p1, "arg0"    # Ljava/lang/String;

    .line 134
    invoke-direct {p0, p1}, Landroid/util/IntProperty;-><init>(Ljava/lang/String;)V

    return-void
.end method


# virtual methods
.method public get(Landroid/view/View;)Ljava/lang/Integer;
    .locals 1
    .param p1, "object"    # Landroid/view/View;

    .line 140
    invoke-virtual {p1}, Landroid/view/View;->getBottom()I

    move-result v0

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    return-object v0
.end method

.method public bridge synthetic get(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 0

    .line 134
    check-cast p1, Landroid/view/View;

    invoke-virtual {p0, p1}, Lcom/samsung/android/ui/recyclerview/widget/SeslRecyclerViewFastScroller$1;->get(Landroid/view/View;)Ljava/lang/Integer;

    move-result-object p1

    return-object p1
.end method

.method public setValue(Landroid/view/View;I)V
    .locals 0
    .param p1, "object"    # Landroid/view/View;
    .param p2, "value"    # I

    .line 136
    invoke-virtual {p1, p2}, Landroid/view/View;->setBottom(I)V

    .line 137
    return-void
.end method

.method public bridge synthetic setValue(Ljava/lang/Object;I)V
    .locals 0

    .line 134
    check-cast p1, Landroid/view/View;

    invoke-virtual {p0, p1, p2}, Lcom/samsung/android/ui/recyclerview/widget/SeslRecyclerViewFastScroller$1;->setValue(Landroid/view/View;I)V

    return-void
.end method