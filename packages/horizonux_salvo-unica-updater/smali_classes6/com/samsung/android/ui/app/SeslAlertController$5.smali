.class Lcom/samsung/android/ui/app/SeslAlertController$5;
.super Ljava/lang/Object;
.source "SeslAlertController.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/samsung/android/ui/app/SeslAlertController;->setScrollIndicators(Landroid/view/ViewGroup;Landroid/view/View;II)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/samsung/android/ui/app/SeslAlertController;

.field final synthetic val$finalVar6:Landroid/view/View;

.field final synthetic val$finalVar7:Landroid/view/View;


# direct methods
.method constructor <init>(Lcom/samsung/android/ui/app/SeslAlertController;Landroid/view/View;Landroid/view/View;)V
    .locals 0
    .param p1, "this$0"    # Lcom/samsung/android/ui/app/SeslAlertController;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 359
    iput-object p1, p0, Lcom/samsung/android/ui/app/SeslAlertController$5;->this$0:Lcom/samsung/android/ui/app/SeslAlertController;

    iput-object p2, p0, Lcom/samsung/android/ui/app/SeslAlertController$5;->val$finalVar6:Landroid/view/View;

    iput-object p3, p0, Lcom/samsung/android/ui/app/SeslAlertController$5;->val$finalVar7:Landroid/view/View;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .line 361
    iget-object v0, p0, Lcom/samsung/android/ui/app/SeslAlertController$5;->this$0:Lcom/samsung/android/ui/app/SeslAlertController;

    iget-object v0, v0, Lcom/samsung/android/ui/app/SeslAlertController;->mListView:Landroid/widget/ListView;

    iget-object v1, p0, Lcom/samsung/android/ui/app/SeslAlertController$5;->val$finalVar6:Landroid/view/View;

    iget-object v2, p0, Lcom/samsung/android/ui/app/SeslAlertController$5;->val$finalVar7:Landroid/view/View;

    invoke-static {v0, v1, v2}, Lcom/samsung/android/ui/app/SeslAlertController;->manageScrollIndicators(Landroid/view/View;Landroid/view/View;Landroid/view/View;)V

    .line 362
    return-void
.end method