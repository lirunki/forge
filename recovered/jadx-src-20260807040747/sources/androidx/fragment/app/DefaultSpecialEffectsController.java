package androidx.fragment.app;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Context;
import android.graphics.Rect;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import androidx.collection.ArrayMap;
import androidx.core.app.SharedElementCallback;
import androidx.core.os.CancellationSignal;
import androidx.core.view.OneShotPreDrawListener;
import androidx.core.view.ViewCompat;
import androidx.core.view.ViewGroupCompat;
import androidx.fragment.app.DefaultSpecialEffectsController;
import androidx.fragment.app.FragmentAnim;
import androidx.fragment.app.SpecialEffectsController;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Set;
import kotlin.Metadata;
import kotlin.Pair;
import kotlin.TuplesKt;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.internal.Intrinsics;

/* compiled from: DefaultSpecialEffectsController.kt */
@Metadata(d1 = {"\u0000v\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010 \n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010%\n\u0002\u0010\u000e\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010!\n\u0002\b\u0002\n\u0002\u0010$\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0004\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u001e\n\u0002\b\u0004\b\u0000\u0018\u00002\u00020\u0001:\u0003*+,B\r\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0002\u0010\u0004J\u0010\u0010\u0005\u001a\u00020\u00062\u0006\u0010\u0007\u001a\u00020\bH\u0002J(\u0010\t\u001a\u00020\u00062\u0016\u0010\n\u001a\u0012\u0012\u0004\u0012\u00020\f0\u000bj\b\u0012\u0004\u0012\u00020\f`\r2\u0006\u0010\u000e\u001a\u00020\fH\u0002J\u001e\u0010\u000f\u001a\u00020\u00062\f\u0010\u0010\u001a\b\u0012\u0004\u0012\u00020\b0\u00112\u0006\u0010\u0012\u001a\u00020\u0013H\u0016J$\u0010\u0014\u001a\u00020\u00062\u0012\u0010\u0015\u001a\u000e\u0012\u0004\u0012\u00020\u0017\u0012\u0004\u0012\u00020\f0\u00162\u0006\u0010\u000e\u001a\u00020\fH\u0002J@\u0010\u0018\u001a\u00020\u00062\f\u0010\u0019\u001a\b\u0012\u0004\u0012\u00020\u001a0\u00112\f\u0010\u001b\u001a\b\u0012\u0004\u0012\u00020\b0\u001c2\u0006\u0010\u001d\u001a\u00020\u00132\u0012\u0010\u001e\u001a\u000e\u0012\u0004\u0012\u00020\b\u0012\u0004\u0012\u00020\u00130\u001fH\u0002JL\u0010 \u001a\u000e\u0012\u0004\u0012\u00020\b\u0012\u0004\u0012\u00020\u00130\u001f2\f\u0010!\u001a\b\u0012\u0004\u0012\u00020\"0\u00112\f\u0010\u001b\u001a\b\u0012\u0004\u0012\u00020\b0\u001c2\u0006\u0010\u0012\u001a\u00020\u00132\b\u0010#\u001a\u0004\u0018\u00010\b2\b\u0010$\u001a\u0004\u0018\u00010\bH\u0002J\u0016\u0010%\u001a\u00020\u00062\f\u0010\u0010\u001a\b\u0012\u0004\u0012\u00020\b0\u0011H\u0002J&\u0010&\u001a\u00020\u0006*\u000e\u0012\u0004\u0012\u00020\u0017\u0012\u0004\u0012\u00020\f0'2\f\u0010(\u001a\b\u0012\u0004\u0012\u00020\u00170)H\u0002¨\u0006-"}, d2 = {"Landroidx/fragment/app/DefaultSpecialEffectsController;", "Landroidx/fragment/app/SpecialEffectsController;", "container", "Landroid/view/ViewGroup;", "(Landroid/view/ViewGroup;)V", "applyContainerChanges", "", "operation", "Landroidx/fragment/app/SpecialEffectsController$Operation;", "captureTransitioningViews", "transitioningViews", "Ljava/util/ArrayList;", "Landroid/view/View;", "Lkotlin/collections/ArrayList;", "view", "executeOperations", "operations", "", "isPop", "", "findNamedViews", "namedViews", "", "", "startAnimations", "animationInfos", "Landroidx/fragment/app/DefaultSpecialEffectsController$AnimationInfo;", "awaitingContainerChanges", "", "startedAnyTransition", "startedTransitions", "", "startTransitions", "transitionInfos", "Landroidx/fragment/app/DefaultSpecialEffectsController$TransitionInfo;", "firstOut", "lastIn", "syncAnimations", "retainMatchingViews", "Landroidx/collection/ArrayMap;", "names", "", "AnimationInfo", "SpecialEffectsInfo", "TransitionInfo", "fragment_release"}, k = 1, mv = {1, 8, 0}, xi = 48)
/* loaded from: classes.dex */
public final class DefaultSpecialEffectsController extends SpecialEffectsController {
    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public DefaultSpecialEffectsController(ViewGroup container) {
        super(container);
        Intrinsics.checkNotNullParameter(container, "container");
    }

    @Override // androidx.fragment.app.SpecialEffectsController
    public void executeOperations(List<? extends SpecialEffectsController.Operation> operations, boolean isPop) {
        Object element$iv;
        Object obj;
        Intrinsics.checkNotNullParameter(operations, "operations");
        List<? extends SpecialEffectsController.Operation> $this$firstOrNull$iv = operations;
        Iterator it = $this$firstOrNull$iv.iterator();
        while (true) {
            if (it.hasNext()) {
                element$iv = it.next();
                SpecialEffectsController.Operation operation = (SpecialEffectsController.Operation) element$iv;
                SpecialEffectsController.Operation.State.Companion companion = SpecialEffectsController.Operation.State.INSTANCE;
                View view = operation.getFragment().mView;
                Intrinsics.checkNotNullExpressionValue(view, "operation.fragment.mView");
                SpecialEffectsController.Operation.State currentState = companion.asOperationState(view);
                if (currentState == SpecialEffectsController.Operation.State.VISIBLE && operation.getFinalState() != SpecialEffectsController.Operation.State.VISIBLE) {
                    break;
                }
            } else {
                element$iv = null;
                break;
            }
        }
        SpecialEffectsController.Operation firstOut = (SpecialEffectsController.Operation) element$iv;
        ListIterator iterator$iv = operations.listIterator(operations.size());
        while (true) {
            if (iterator$iv.hasPrevious()) {
                Object element$iv2 = iterator$iv.previous();
                SpecialEffectsController.Operation operation2 = (SpecialEffectsController.Operation) element$iv2;
                SpecialEffectsController.Operation.State.Companion companion2 = SpecialEffectsController.Operation.State.INSTANCE;
                View view2 = operation2.getFragment().mView;
                Intrinsics.checkNotNullExpressionValue(view2, "operation.fragment.mView");
                SpecialEffectsController.Operation.State currentState2 = companion2.asOperationState(view2);
                if (currentState2 != SpecialEffectsController.Operation.State.VISIBLE && operation2.getFinalState() == SpecialEffectsController.Operation.State.VISIBLE) {
                    obj = element$iv2;
                    break;
                }
            } else {
                obj = null;
                break;
            }
        }
        SpecialEffectsController.Operation lastIn = (SpecialEffectsController.Operation) obj;
        if (FragmentManager.isLoggingEnabled(2)) {
            Log.v(FragmentManager.TAG, "Executing operations from " + firstOut + " to " + lastIn);
        }
        List animations = new ArrayList();
        List transitions = new ArrayList();
        final List awaitingContainerChanges = CollectionsKt.toMutableList((Collection) operations);
        syncAnimations(operations);
        Iterator<? extends SpecialEffectsController.Operation> it2 = operations.iterator();
        while (it2.hasNext()) {
            final SpecialEffectsController.Operation operation3 = it2.next();
            CancellationSignal animCancellationSignal = new CancellationSignal();
            operation3.markStartedSpecialEffect(animCancellationSignal);
            animations.add(new AnimationInfo(operation3, animCancellationSignal, isPop));
            CancellationSignal transitionCancellationSignal = new CancellationSignal();
            operation3.markStartedSpecialEffect(transitionCancellationSignal);
            transitions.add(new TransitionInfo(operation3, transitionCancellationSignal, isPop, !isPop ? operation3 != lastIn : operation3 != firstOut));
            operation3.addCompletionListener(new Runnable() { // from class: androidx.fragment.app.DefaultSpecialEffectsController$$ExternalSyntheticLambda0
                @Override // java.lang.Runnable
                public final void run() {
                    DefaultSpecialEffectsController.executeOperations$lambda$2(awaitingContainerChanges, operation3, this);
                }
            });
        }
        Map startedTransitions = startTransitions(transitions, awaitingContainerChanges, isPop, firstOut, lastIn);
        boolean startedAnyTransition = startedTransitions.containsValue(true);
        startAnimations(animations, awaitingContainerChanges, startedAnyTransition, startedTransitions);
        Iterator<SpecialEffectsController.Operation> it3 = awaitingContainerChanges.iterator();
        while (it3.hasNext()) {
            applyContainerChanges(it3.next());
        }
        awaitingContainerChanges.clear();
        if (FragmentManager.isLoggingEnabled(2)) {
            Log.v(FragmentManager.TAG, "Completed executing operations from " + firstOut + " to " + lastIn);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static final void executeOperations$lambda$2(List awaitingContainerChanges, SpecialEffectsController.Operation operation, DefaultSpecialEffectsController this$0) {
        Intrinsics.checkNotNullParameter(awaitingContainerChanges, "$awaitingContainerChanges");
        Intrinsics.checkNotNullParameter(operation, "$operation");
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        if (awaitingContainerChanges.contains(operation)) {
            awaitingContainerChanges.remove(operation);
            this$0.applyContainerChanges(operation);
        }
    }

    private final void syncAnimations(List<? extends SpecialEffectsController.Operation> operations) {
        Fragment lastOpFragment = ((SpecialEffectsController.Operation) CollectionsKt.last((List) operations)).getFragment();
        for (SpecialEffectsController.Operation operation : operations) {
            operation.getFragment().mAnimationInfo.mEnterAnim = lastOpFragment.mAnimationInfo.mEnterAnim;
            operation.getFragment().mAnimationInfo.mExitAnim = lastOpFragment.mAnimationInfo.mExitAnim;
            operation.getFragment().mAnimationInfo.mPopEnterAnim = lastOpFragment.mAnimationInfo.mPopEnterAnim;
            operation.getFragment().mAnimationInfo.mPopExitAnim = lastOpFragment.mAnimationInfo.mPopExitAnim;
        }
    }

    private final void startAnimations(List<AnimationInfo> animationInfos, List<SpecialEffectsController.Operation> awaitingContainerChanges, boolean startedAnyTransition, Map<SpecialEffectsController.Operation, Boolean> startedTransitions) {
        boolean startedAnyAnimator;
        Context context = getContainer().getContext();
        List<AnimationInfo> animationsToRun = new ArrayList();
        boolean startedAnyAnimator2 = false;
        Iterator<AnimationInfo> it = animationInfos.iterator();
        while (it.hasNext()) {
            final AnimationInfo animationInfo = it.next();
            if (animationInfo.isVisibilityUnchanged()) {
                animationInfo.completeSpecialEffect();
            } else {
                Intrinsics.checkNotNullExpressionValue(context, "context");
                FragmentAnim.AnimationOrAnimator anim = animationInfo.getAnimation(context);
                if (anim == null) {
                    animationInfo.completeSpecialEffect();
                } else {
                    final Animator animator = anim.animator;
                    if (animator == null) {
                        animationsToRun.add(animationInfo);
                    } else {
                        final SpecialEffectsController.Operation operation = animationInfo.getOperation();
                        Fragment fragment = operation.getFragment();
                        boolean startedTransition = Intrinsics.areEqual((Object) startedTransitions.get(operation), (Object) true);
                        if (startedTransition) {
                            if (FragmentManager.isLoggingEnabled(2)) {
                                Log.v(FragmentManager.TAG, "Ignoring Animator set on " + fragment + " as this Fragment was involved in a Transition.");
                            }
                            animationInfo.completeSpecialEffect();
                        } else {
                            final boolean isHideOperation = operation.getFinalState() == SpecialEffectsController.Operation.State.GONE;
                            if (isHideOperation) {
                                awaitingContainerChanges.remove(operation);
                            }
                            final View viewToAnimate = fragment.mView;
                            getContainer().startViewTransition(viewToAnimate);
                            Iterator<AnimationInfo> it2 = it;
                            animator.addListener(new AnimatorListenerAdapter() { // from class: androidx.fragment.app.DefaultSpecialEffectsController$startAnimations$1
                                @Override // android.animation.AnimatorListenerAdapter, android.animation.Animator.AnimatorListener
                                public void onAnimationEnd(Animator anim2) {
                                    Intrinsics.checkNotNullParameter(anim2, "anim");
                                    DefaultSpecialEffectsController.this.getContainer().endViewTransition(viewToAnimate);
                                    if (isHideOperation) {
                                        SpecialEffectsController.Operation.State finalState = operation.getFinalState();
                                        View viewToAnimate2 = viewToAnimate;
                                        Intrinsics.checkNotNullExpressionValue(viewToAnimate2, "viewToAnimate");
                                        finalState.applyState(viewToAnimate2);
                                    }
                                    animationInfo.completeSpecialEffect();
                                    if (FragmentManager.isLoggingEnabled(2)) {
                                        Log.v(FragmentManager.TAG, "Animator from operation " + operation + " has ended.");
                                    }
                                }
                            });
                            animator.setTarget(viewToAnimate);
                            animator.start();
                            if (FragmentManager.isLoggingEnabled(2)) {
                                Log.v(FragmentManager.TAG, "Animator from operation " + operation + " has started.");
                            }
                            CancellationSignal signal = animationInfo.getSignal();
                            signal.setOnCancelListener(new CancellationSignal.OnCancelListener() { // from class: androidx.fragment.app.DefaultSpecialEffectsController$$ExternalSyntheticLambda5
                                @Override // androidx.core.os.CancellationSignal.OnCancelListener
                                public final void onCancel() {
                                    DefaultSpecialEffectsController.startAnimations$lambda$3(animator, operation);
                                }
                            });
                            startedAnyAnimator2 = true;
                            it = it2;
                        }
                    }
                }
            }
        }
        for (final AnimationInfo animationInfo2 : animationsToRun) {
            final SpecialEffectsController.Operation operation2 = animationInfo2.getOperation();
            Fragment fragment2 = operation2.getFragment();
            if (startedAnyTransition) {
                if (FragmentManager.isLoggingEnabled(2)) {
                    Log.v(FragmentManager.TAG, "Ignoring Animation set on " + fragment2 + " as Animations cannot run alongside Transitions.");
                }
                animationInfo2.completeSpecialEffect();
            } else if (startedAnyAnimator2) {
                if (FragmentManager.isLoggingEnabled(2)) {
                    Log.v(FragmentManager.TAG, "Ignoring Animation set on " + fragment2 + " as Animations cannot run alongside Animators.");
                }
                animationInfo2.completeSpecialEffect();
            } else {
                final View viewToAnimate2 = fragment2.mView;
                Intrinsics.checkNotNullExpressionValue(context, "context");
                FragmentAnim.AnimationOrAnimator animation = animationInfo2.getAnimation(context);
                if (animation == null) {
                    throw new IllegalStateException("Required value was null.".toString());
                }
                Animation anim2 = animation.animation;
                if (anim2 == null) {
                    throw new IllegalStateException("Required value was null.".toString());
                }
                SpecialEffectsController.Operation.State finalState = operation2.getFinalState();
                if (finalState != SpecialEffectsController.Operation.State.REMOVED) {
                    viewToAnimate2.startAnimation(anim2);
                    animationInfo2.completeSpecialEffect();
                    startedAnyAnimator = startedAnyAnimator2;
                } else {
                    getContainer().startViewTransition(viewToAnimate2);
                    Animation animation2 = new FragmentAnim.EndViewTransitionAnimation(anim2, getContainer(), viewToAnimate2);
                    animation2.setAnimationListener(new DefaultSpecialEffectsController$startAnimations$3(operation2, this, viewToAnimate2, animationInfo2));
                    viewToAnimate2.startAnimation(animation2);
                    if (!FragmentManager.isLoggingEnabled(2)) {
                        startedAnyAnimator = startedAnyAnimator2;
                    } else {
                        startedAnyAnimator = startedAnyAnimator2;
                        Log.v(FragmentManager.TAG, "Animation from operation " + operation2 + " has started.");
                    }
                }
                CancellationSignal signal2 = animationInfo2.getSignal();
                signal2.setOnCancelListener(new CancellationSignal.OnCancelListener() { // from class: androidx.fragment.app.DefaultSpecialEffectsController$$ExternalSyntheticLambda6
                    @Override // androidx.core.os.CancellationSignal.OnCancelListener
                    public final void onCancel() {
                        DefaultSpecialEffectsController.startAnimations$lambda$4(viewToAnimate2, this, animationInfo2, operation2);
                    }
                });
                startedAnyAnimator2 = startedAnyAnimator;
            }
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static final void startAnimations$lambda$3(Animator $animator, SpecialEffectsController.Operation operation) {
        Intrinsics.checkNotNullParameter(operation, "$operation");
        $animator.end();
        if (FragmentManager.isLoggingEnabled(2)) {
            Log.v(FragmentManager.TAG, "Animator from operation " + operation + " has been canceled.");
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static final void startAnimations$lambda$4(View $viewToAnimate, DefaultSpecialEffectsController this$0, AnimationInfo animationInfo, SpecialEffectsController.Operation operation) {
        Intrinsics.checkNotNullParameter(this$0, "this$0");
        Intrinsics.checkNotNullParameter(animationInfo, "$animationInfo");
        Intrinsics.checkNotNullParameter(operation, "$operation");
        $viewToAnimate.clearAnimation();
        this$0.getContainer().endViewTransition($viewToAnimate);
        animationInfo.completeSpecialEffect();
        if (FragmentManager.isLoggingEnabled(2)) {
            Log.v(FragmentManager.TAG, "Animation from operation " + operation + " has been cancelled.");
        }
    }

    /* JADX WARN: Code restructure failed: missing block: B:228:0x06d3, code lost:
    
        if (r1 == r47) goto L189;
     */
    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:237:0x06f8  */
    /* JADX WARN: Removed duplicated region for block: B:243:0x0731  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
    */
    private final Map<SpecialEffectsController.Operation, Boolean> startTransitions(List<TransitionInfo> transitionInfos, List<SpecialEffectsController.Operation> awaitingContainerChanges, boolean isPop, SpecialEffectsController.Operation firstOut, SpecialEffectsController.Operation lastIn) {
        String str;
        boolean involvedInSharedElementTransition;
        String str2;
        Rect lastInEpicenterRect;
        int $i$f$forEach;
        Iterator<TransitionInfo> it;
        ArrayMap sharedElementNameMapping;
        String str3;
        View firstOutEpicenterView;
        Rect lastInEpicenterRect2;
        FragmentTransitionImpl transitionImpl;
        Object sharedElementTransition;
        final Rect lastInEpicenterRect3;
        SharedElementCallback enteringCallback;
        SharedElementCallback exitingCallback;
        DefaultSpecialEffectsController defaultSpecialEffectsController = this;
        final boolean z = isPop;
        final SpecialEffectsController.Operation operation = firstOut;
        final SpecialEffectsController.Operation operation2 = lastIn;
        Map startedTransitions = new LinkedHashMap();
        List<TransitionInfo> $this$filterNot$iv = transitionInfos;
        Collection destination$iv$iv = new ArrayList();
        for (Object element$iv$iv : $this$filterNot$iv) {
            if (!((TransitionInfo) element$iv$iv).isVisibilityUnchanged()) {
                destination$iv$iv.add(element$iv$iv);
            }
        }
        Iterable $this$filter$iv = (List) destination$iv$iv;
        Collection destination$iv$iv2 = new ArrayList();
        Iterator it2 = $this$filter$iv.iterator();
        while (true) {
            if (!it2.hasNext()) {
                break;
            }
            Object element$iv$iv2 = it2.next();
            if (((TransitionInfo) element$iv$iv2).getHandlingImpl() != null) {
                destination$iv$iv2.add(element$iv$iv2);
            }
        }
        Iterable $this$fold$iv = (List) destination$iv$iv2;
        FragmentTransitionImpl fragmentTransitionImpl = null;
        for (Object element$iv : $this$fold$iv) {
            TransitionInfo transitionInfo = (TransitionInfo) element$iv;
            FragmentTransitionImpl chosenImpl = fragmentTransitionImpl;
            FragmentTransitionImpl handlingImpl = transitionInfo.getHandlingImpl();
            if (!(chosenImpl == null || handlingImpl == chosenImpl)) {
                throw new IllegalArgumentException(("Mixing framework transitions and AndroidX transitions is not allowed. Fragment " + transitionInfo.getOperation().getFragment() + " returned Transition " + transitionInfo.getTransition() + " which uses a different Transition type than other Fragments.").toString());
            }
            fragmentTransitionImpl = handlingImpl;
        }
        FragmentTransitionImpl transitionImpl2 = fragmentTransitionImpl;
        if (transitionImpl2 == null) {
            for (TransitionInfo transitionInfo2 : transitionInfos) {
                startedTransitions.put(transitionInfo2.getOperation(), false);
                transitionInfo2.completeSpecialEffect();
            }
            return startedTransitions;
        }
        View nonExistentView = new View(getContainer().getContext());
        Object sharedElementTransition2 = null;
        View firstOutEpicenterView2 = null;
        boolean hasLastInEpicenter = false;
        Rect lastInEpicenterRect4 = new Rect();
        ArrayList sharedElementFirstOutViews = new ArrayList();
        ArrayList sharedElementLastInViews = new ArrayList();
        ArrayMap sharedElementNameMapping2 = new ArrayMap();
        Iterator<TransitionInfo> it3 = transitionInfos.iterator();
        while (true) {
            boolean hasNext = it3.hasNext();
            str = FragmentManager.TAG;
            if (!hasNext) {
                break;
            }
            TransitionInfo transitionInfo3 = it3.next();
            boolean hasSharedElementTransition = transitionInfo3.hasSharedElementTransition();
            if (!hasSharedElementTransition || operation == null || operation2 == null) {
                nonExistentView = nonExistentView;
                startedTransitions = startedTransitions;
                it3 = it3;
                firstOutEpicenterView2 = firstOutEpicenterView2;
                hasLastInEpicenter = hasLastInEpicenter;
                z = isPop;
                lastInEpicenterRect4 = lastInEpicenterRect4;
                transitionImpl2 = transitionImpl2;
            } else {
                Iterator<TransitionInfo> it4 = it3;
                Object sharedElementTransition3 = transitionImpl2.wrapTransitionInSet(transitionImpl2.cloneTransition(transitionInfo3.getSharedElementTransition()));
                ArrayList exitingNames = lastIn.getFragment().getSharedElementSourceNames();
                View firstOutEpicenterView3 = firstOutEpicenterView2;
                Intrinsics.checkNotNullExpressionValue(exitingNames, "lastIn.fragment.sharedElementSourceNames");
                ArrayList firstOutSourceNames = firstOut.getFragment().getSharedElementSourceNames();
                boolean hasLastInEpicenter2 = hasLastInEpicenter;
                Intrinsics.checkNotNullExpressionValue(firstOutSourceNames, "firstOut.fragment.sharedElementSourceNames");
                ArrayList sharedElementTargetNames = firstOut.getFragment().getSharedElementTargetNames();
                Map startedTransitions2 = startedTransitions;
                Intrinsics.checkNotNullExpressionValue(sharedElementTargetNames, "firstOut.fragment.sharedElementTargetNames");
                ArrayList firstOutTargetNames = sharedElementTargetNames;
                int size = firstOutTargetNames.size();
                View nonExistentView2 = nonExistentView;
                int index = 0;
                while (true) {
                    lastInEpicenterRect2 = lastInEpicenterRect4;
                    if (index >= size) {
                        break;
                    }
                    int nameIndex = exitingNames.indexOf(firstOutTargetNames.get(index));
                    ArrayList firstOutTargetNames2 = firstOutTargetNames;
                    if (nameIndex != -1) {
                        exitingNames.set(nameIndex, firstOutSourceNames.get(index));
                    }
                    index++;
                    lastInEpicenterRect4 = lastInEpicenterRect2;
                    firstOutTargetNames = firstOutTargetNames2;
                }
                ArrayList enteringNames = lastIn.getFragment().getSharedElementTargetNames();
                Intrinsics.checkNotNullExpressionValue(enteringNames, "lastIn.fragment.sharedElementTargetNames");
                Pair pair = !z ? TuplesKt.to(firstOut.getFragment().getExitTransitionCallback(), lastIn.getFragment().getEnterTransitionCallback()) : TuplesKt.to(firstOut.getFragment().getEnterTransitionCallback(), lastIn.getFragment().getExitTransitionCallback());
                SharedElementCallback exitingCallback2 = (SharedElementCallback) pair.component1();
                SharedElementCallback enteringCallback2 = (SharedElementCallback) pair.component2();
                int numSharedElements = exitingNames.size();
                int i = 0;
                while (i < numSharedElements) {
                    int numSharedElements2 = numSharedElements;
                    String exitingName = exitingNames.get(i);
                    FragmentTransitionImpl transitionImpl3 = transitionImpl2;
                    String enteringName = enteringNames.get(i);
                    sharedElementNameMapping2.put(exitingName, enteringName);
                    i++;
                    numSharedElements = numSharedElements2;
                    transitionImpl2 = transitionImpl3;
                    sharedElementTransition3 = sharedElementTransition3;
                }
                FragmentTransitionImpl transitionImpl4 = transitionImpl2;
                Object sharedElementTransition4 = sharedElementTransition3;
                if (FragmentManager.isLoggingEnabled(2)) {
                    Log.v(FragmentManager.TAG, ">>> entering view names <<<");
                    Iterator<String> it5 = enteringNames.iterator();
                    while (it5.hasNext()) {
                        Log.v(FragmentManager.TAG, "Name: " + it5.next());
                    }
                    Log.v(FragmentManager.TAG, ">>> exiting view names <<<");
                    Iterator<String> it6 = exitingNames.iterator();
                    while (it6.hasNext()) {
                        Log.v(FragmentManager.TAG, "Name: " + it6.next());
                    }
                }
                ArrayMap firstOutViews = new ArrayMap();
                View view = firstOut.getFragment().mView;
                Intrinsics.checkNotNullExpressionValue(view, "firstOut.fragment.mView");
                defaultSpecialEffectsController.findNamedViews(firstOutViews, view);
                firstOutViews.retainAll(exitingNames);
                if (exitingCallback2 != null) {
                    if (FragmentManager.isLoggingEnabled(2)) {
                        Log.v(FragmentManager.TAG, "Executing exit callback for operation " + operation);
                    }
                    exitingCallback2.onMapSharedElements(exitingNames, firstOutViews);
                    int i2 = -1;
                    int size2 = exitingNames.size() - 1;
                    if (size2 >= 0) {
                        while (true) {
                            int i3 = size2;
                            size2 += i2;
                            String name = (String) exitingNames.get(i3);
                            View view2 = firstOutViews.get(name);
                            if (view2 == null) {
                                sharedElementNameMapping2.remove(name);
                                exitingCallback = exitingCallback2;
                            } else {
                                exitingCallback = exitingCallback2;
                                if (!Intrinsics.areEqual(name, ViewCompat.getTransitionName(view2))) {
                                    String targetValue = (String) sharedElementNameMapping2.remove(name);
                                    sharedElementNameMapping2.put(ViewCompat.getTransitionName(view2), targetValue);
                                }
                            }
                            if (size2 < 0) {
                                break;
                            }
                            exitingCallback2 = exitingCallback;
                            i2 = -1;
                        }
                    }
                } else {
                    sharedElementNameMapping2.retainAll(firstOutViews.keySet());
                }
                final ArrayMap lastInViews = new ArrayMap();
                View view3 = lastIn.getFragment().mView;
                Intrinsics.checkNotNullExpressionValue(view3, "lastIn.fragment.mView");
                defaultSpecialEffectsController.findNamedViews(lastInViews, view3);
                lastInViews.retainAll(enteringNames);
                lastInViews.retainAll(sharedElementNameMapping2.values());
                if (enteringCallback2 != null) {
                    if (FragmentManager.isLoggingEnabled(2)) {
                        Log.v(FragmentManager.TAG, "Executing enter callback for operation " + operation2);
                    }
                    enteringCallback2.onMapSharedElements(enteringNames, lastInViews);
                    int i4 = -1;
                    int size3 = enteringNames.size() - 1;
                    if (size3 >= 0) {
                        while (true) {
                            int i5 = size3;
                            size3 += i4;
                            String name2 = enteringNames.get(i5);
                            View view4 = lastInViews.get(name2);
                            if (view4 == null) {
                                Intrinsics.checkNotNullExpressionValue(name2, "name");
                                String key = FragmentTransition.findKeyForValue(sharedElementNameMapping2, name2);
                                if (key != null) {
                                    sharedElementNameMapping2.remove(key);
                                    enteringCallback = enteringCallback2;
                                } else {
                                    enteringCallback = enteringCallback2;
                                }
                            } else {
                                enteringCallback = enteringCallback2;
                                if (!Intrinsics.areEqual(name2, ViewCompat.getTransitionName(view4))) {
                                    Intrinsics.checkNotNullExpressionValue(name2, "name");
                                    String key2 = FragmentTransition.findKeyForValue(sharedElementNameMapping2, name2);
                                    if (key2 != null) {
                                        sharedElementNameMapping2.put(key2, ViewCompat.getTransitionName(view4));
                                    }
                                }
                            }
                            if (size3 < 0) {
                                break;
                            }
                            enteringCallback2 = enteringCallback;
                            i4 = -1;
                        }
                    }
                } else {
                    FragmentTransition.retainValues(sharedElementNameMapping2, lastInViews);
                }
                Set keySet = sharedElementNameMapping2.keySet();
                Intrinsics.checkNotNullExpressionValue(keySet, "sharedElementNameMapping.keys");
                defaultSpecialEffectsController.retainMatchingViews(firstOutViews, keySet);
                Collection<String> values = sharedElementNameMapping2.values();
                Intrinsics.checkNotNullExpressionValue(values, "sharedElementNameMapping.values");
                defaultSpecialEffectsController.retainMatchingViews(lastInViews, values);
                if (sharedElementNameMapping2.isEmpty()) {
                    sharedElementFirstOutViews.clear();
                    sharedElementLastInViews.clear();
                    sharedElementTransition2 = null;
                    it3 = it4;
                    firstOutEpicenterView2 = firstOutEpicenterView3;
                    hasLastInEpicenter = hasLastInEpicenter2;
                    startedTransitions = startedTransitions2;
                    nonExistentView = nonExistentView2;
                    lastInEpicenterRect4 = lastInEpicenterRect2;
                    transitionImpl2 = transitionImpl4;
                } else {
                    FragmentTransition.callSharedElementStartEnd(lastIn.getFragment(), firstOut.getFragment(), z, firstOutViews, true);
                    OneShotPreDrawListener.add(getContainer(), new Runnable() { // from class: androidx.fragment.app.DefaultSpecialEffectsController$$ExternalSyntheticLambda1
                        @Override // java.lang.Runnable
                        public final void run() {
                            DefaultSpecialEffectsController.startTransitions$lambda$9(SpecialEffectsController.Operation.this, operation, z, lastInViews);
                        }
                    });
                    sharedElementFirstOutViews.addAll(firstOutViews.values());
                    if (!exitingNames.isEmpty()) {
                        String epicenterViewName = (String) exitingNames.get(0);
                        View firstOutEpicenterView4 = firstOutViews.get(epicenterViewName);
                        transitionImpl = transitionImpl4;
                        sharedElementTransition = sharedElementTransition4;
                        transitionImpl.setEpicenter(sharedElementTransition, firstOutEpicenterView4);
                        firstOutEpicenterView3 = firstOutEpicenterView4;
                    } else {
                        transitionImpl = transitionImpl4;
                        sharedElementTransition = sharedElementTransition4;
                    }
                    sharedElementLastInViews.addAll(lastInViews.values());
                    if (!enteringNames.isEmpty()) {
                        String epicenterViewName2 = (String) enteringNames.get(0);
                        final View lastInEpicenterView = lastInViews.get(epicenterViewName2);
                        if (lastInEpicenterView != null) {
                            final FragmentTransitionImpl impl = transitionImpl;
                            lastInEpicenterRect3 = lastInEpicenterRect2;
                            OneShotPreDrawListener.add(getContainer(), new Runnable() { // from class: androidx.fragment.app.DefaultSpecialEffectsController$$ExternalSyntheticLambda2
                                @Override // java.lang.Runnable
                                public final void run() {
                                    DefaultSpecialEffectsController.startTransitions$lambda$10(FragmentTransitionImpl.this, lastInEpicenterView, lastInEpicenterRect3);
                                }
                            });
                            hasLastInEpicenter = true;
                            transitionImpl.setSharedElementTargets(sharedElementTransition, nonExistentView2, sharedElementFirstOutViews);
                            transitionImpl.scheduleRemoveTargets(sharedElementTransition, null, null, null, null, sharedElementTransition, sharedElementLastInViews);
                            startedTransitions2.put(operation, true);
                            startedTransitions2.put(operation2, true);
                            nonExistentView = nonExistentView2;
                            sharedElementTransition2 = sharedElementTransition;
                            startedTransitions = startedTransitions2;
                            it3 = it4;
                            firstOutEpicenterView2 = firstOutEpicenterView3;
                            z = isPop;
                            FragmentTransitionImpl fragmentTransitionImpl2 = transitionImpl;
                            lastInEpicenterRect4 = lastInEpicenterRect3;
                            transitionImpl2 = fragmentTransitionImpl2;
                        } else {
                            lastInEpicenterRect3 = lastInEpicenterRect2;
                        }
                    } else {
                        lastInEpicenterRect3 = lastInEpicenterRect2;
                    }
                    hasLastInEpicenter = hasLastInEpicenter2;
                    transitionImpl.setSharedElementTargets(sharedElementTransition, nonExistentView2, sharedElementFirstOutViews);
                    transitionImpl.scheduleRemoveTargets(sharedElementTransition, null, null, null, null, sharedElementTransition, sharedElementLastInViews);
                    startedTransitions2.put(operation, true);
                    startedTransitions2.put(operation2, true);
                    nonExistentView = nonExistentView2;
                    sharedElementTransition2 = sharedElementTransition;
                    startedTransitions = startedTransitions2;
                    it3 = it4;
                    firstOutEpicenterView2 = firstOutEpicenterView3;
                    z = isPop;
                    FragmentTransitionImpl fragmentTransitionImpl22 = transitionImpl;
                    lastInEpicenterRect4 = lastInEpicenterRect3;
                    transitionImpl2 = fragmentTransitionImpl22;
                }
            }
        }
        Map startedTransitions3 = startedTransitions;
        View nonExistentView3 = nonExistentView;
        View firstOutEpicenterView5 = firstOutEpicenterView2;
        boolean hasLastInEpicenter3 = hasLastInEpicenter;
        Rect rect = lastInEpicenterRect4;
        FragmentTransitionImpl transitionImpl5 = transitionImpl2;
        Rect lastInEpicenterRect5 = rect;
        ArrayList enteringViews = new ArrayList();
        Object mergedTransition = null;
        Object mergedNonOverlappingTransition = null;
        Iterator<TransitionInfo> it7 = transitionInfos.iterator();
        while (it7.hasNext()) {
            TransitionInfo transitionInfo4 = it7.next();
            if (transitionInfo4.isVisibilityUnchanged()) {
                it = it7;
                sharedElementNameMapping = sharedElementNameMapping2;
                startedTransitions3.put(transitionInfo4.getOperation(), false);
                transitionInfo4.completeSpecialEffect();
                str3 = str;
            } else {
                it = it7;
                sharedElementNameMapping = sharedElementNameMapping2;
                Object transition = transitionImpl5.cloneTransition(transitionInfo4.getTransition());
                SpecialEffectsController.Operation operation3 = transitionInfo4.getOperation();
                boolean involvedInSharedElementTransition2 = sharedElementTransition2 != null && (operation3 == operation || operation3 == operation2);
                if (transition != null) {
                    String str4 = str;
                    final ArrayList transitioningViews = new ArrayList();
                    View view5 = operation3.getFragment().mView;
                    Object sharedElementTransition5 = sharedElementTransition2;
                    Intrinsics.checkNotNullExpressionValue(view5, "operation.fragment.mView");
                    defaultSpecialEffectsController.captureTransitioningViews(transitioningViews, view5);
                    if (involvedInSharedElementTransition2) {
                        if (operation3 == operation) {
                            transitioningViews.removeAll(CollectionsKt.toSet(sharedElementFirstOutViews));
                        } else {
                            transitioningViews.removeAll(CollectionsKt.toSet(sharedElementLastInViews));
                        }
                    }
                    if (transitioningViews.isEmpty()) {
                        transitionImpl5.addTarget(transition, nonExistentView3);
                    } else {
                        transitionImpl5.addTargets(transition, transitioningViews);
                        transitionImpl5.scheduleRemoveTargets(transition, transition, transitioningViews, null, null, null, null);
                        if (operation3.getFinalState() == SpecialEffectsController.Operation.State.GONE) {
                            awaitingContainerChanges.remove(operation3);
                            ArrayList transitioningViewsToHide = new ArrayList(transitioningViews);
                            transitioningViewsToHide.remove(operation3.getFragment().mView);
                            transitionImpl5.scheduleHideFragmentView(transition, operation3.getFragment().mView, transitioningViewsToHide);
                            OneShotPreDrawListener.add(getContainer(), new Runnable() { // from class: androidx.fragment.app.DefaultSpecialEffectsController$$ExternalSyntheticLambda3
                                @Override // java.lang.Runnable
                                public final void run() {
                                    DefaultSpecialEffectsController.startTransitions$lambda$11(transitioningViews);
                                }
                            });
                        }
                    }
                    if (operation3.getFinalState() == SpecialEffectsController.Operation.State.VISIBLE) {
                        enteringViews.addAll(transitioningViews);
                        if (hasLastInEpicenter3) {
                            transitionImpl5.setEpicenter(transition, lastInEpicenterRect5);
                            firstOutEpicenterView = firstOutEpicenterView5;
                        } else {
                            firstOutEpicenterView = firstOutEpicenterView5;
                        }
                    } else {
                        firstOutEpicenterView = firstOutEpicenterView5;
                        transitionImpl5.setEpicenter(transition, firstOutEpicenterView);
                    }
                    firstOutEpicenterView5 = firstOutEpicenterView;
                    startedTransitions3.put(operation3, true);
                    if (transitionInfo4.getIsOverlapAllowed()) {
                        mergedTransition = transitionImpl5.mergeTransitionsTogether(mergedTransition, transition, null);
                        defaultSpecialEffectsController = this;
                        operation2 = lastIn;
                        it7 = it;
                        sharedElementNameMapping2 = sharedElementNameMapping;
                        str = str4;
                        sharedElementTransition2 = sharedElementTransition5;
                    } else {
                        mergedNonOverlappingTransition = transitionImpl5.mergeTransitionsTogether(mergedNonOverlappingTransition, transition, null);
                        defaultSpecialEffectsController = this;
                        operation2 = lastIn;
                        it7 = it;
                        sharedElementNameMapping2 = sharedElementNameMapping;
                        str = str4;
                        sharedElementTransition2 = sharedElementTransition5;
                    }
                } else if (involvedInSharedElementTransition2) {
                    str3 = str;
                } else {
                    str3 = str;
                    startedTransitions3.put(operation3, false);
                    transitionInfo4.completeSpecialEffect();
                }
            }
            it7 = it;
            sharedElementNameMapping2 = sharedElementNameMapping;
            str = str3;
        }
        String str5 = str;
        ArrayMap sharedElementNameMapping3 = sharedElementNameMapping2;
        Object mergedTransition2 = transitionImpl5.mergeTransitionsInSequence(mergedTransition, mergedNonOverlappingTransition, sharedElementTransition2);
        if (mergedTransition2 == null) {
            return startedTransitions3;
        }
        List<TransitionInfo> $this$filterNot$iv2 = transitionInfos;
        Collection destination$iv$iv3 = new ArrayList();
        for (Object element$iv$iv3 : $this$filterNot$iv2) {
            View nonExistentView4 = nonExistentView3;
            if (!((TransitionInfo) element$iv$iv3).isVisibilityUnchanged()) {
                destination$iv$iv3.add(element$iv$iv3);
            }
            nonExistentView3 = nonExistentView4;
        }
        Iterable $this$forEach$iv = (List) destination$iv$iv3;
        int $i$f$forEach2 = 0;
        for (Object element$iv2 : $this$forEach$iv) {
            final TransitionInfo transitionInfo5 = (TransitionInfo) element$iv2;
            Object transition2 = transitionInfo5.getTransition();
            Iterable $this$forEach$iv2 = $this$forEach$iv;
            final SpecialEffectsController.Operation operation4 = transitionInfo5.getOperation();
            if (sharedElementTransition2 != null) {
                if (operation4 != operation) {
                }
                involvedInSharedElementTransition = true;
                if (transition2 != null && !involvedInSharedElementTransition) {
                    lastInEpicenterRect = lastInEpicenterRect5;
                    $i$f$forEach = $i$f$forEach2;
                    str2 = str5;
                } else if (ViewCompat.isLaidOut(getContainer())) {
                    if (FragmentManager.isLoggingEnabled(2)) {
                        str2 = str5;
                        Log.v(str2, "SpecialEffectsController: Container " + getContainer() + " has not been laid out. Completing operation " + operation4);
                    } else {
                        str2 = str5;
                    }
                    transitionInfo5.completeSpecialEffect();
                    lastInEpicenterRect = lastInEpicenterRect5;
                    $i$f$forEach = $i$f$forEach2;
                } else {
                    str2 = str5;
                    lastInEpicenterRect = lastInEpicenterRect5;
                    $i$f$forEach = $i$f$forEach2;
                    transitionImpl5.setListenerForTransitionEnd(transitionInfo5.getOperation().getFragment(), mergedTransition2, transitionInfo5.getSignal(), new Runnable() { // from class: androidx.fragment.app.DefaultSpecialEffectsController$$ExternalSyntheticLambda4
                        @Override // java.lang.Runnable
                        public final void run() {
                            DefaultSpecialEffectsController.startTransitions$lambda$14$lambda$13(DefaultSpecialEffectsController.TransitionInfo.this, operation4);
                        }
                    });
                }
                operation = firstOut;
                str5 = str2;
                $this$forEach$iv = $this$forEach$iv2;
                $i$f$forEach2 = $i$f$forEach;
                lastInEpicenterRect5 = lastInEpicenterRect;
            }
            involvedInSharedElementTransition = false;
            if (transition2 != null) {
            }
            if (ViewCompat.isLaidOut(getContainer())) {
            }
            operation = firstOut;
            str5 = str2;
            $this$forEach$iv = $this$forEach$iv2;
            $i$f$forEach2 = $i$f$forEach;
            lastInEpicenterRect5 = lastInEpicenterRect;
        }
        String str6 = str5;
        if (!ViewCompat.isLaidOut(getContainer())) {
            return startedTransitions3;
        }
        FragmentTransition.setViewVisibility(enteringViews, 4);
        ArrayList inNames = transitionImpl5.prepareSetNameOverridesReordered(sharedElementLastInViews);
        if (FragmentManager.isLoggingEnabled(2)) {
            Log.v(str6, ">>>>> Beginning transition <<<<<");
            Log.v(str6, ">>>>> SharedElementFirstOutViews <<<<<");
            Iterator<View> it8 = sharedElementFirstOutViews.iterator();
            while (it8.hasNext()) {
                View sharedElementFirstOutViews2 = it8.next();
                Intrinsics.checkNotNullExpressionValue(sharedElementFirstOutViews2, "sharedElementFirstOutViews");
                View view6 = sharedElementFirstOutViews2;
                Log.v(str6, "View: " + view6 + " Name: " + ViewCompat.getTransitionName(view6));
            }
            Log.v(str6, ">>>>> SharedElementLastInViews <<<<<");
            Iterator<View> it9 = sharedElementLastInViews.iterator();
            while (it9.hasNext()) {
                View sharedElementLastInViews2 = it9.next();
                Intrinsics.checkNotNullExpressionValue(sharedElementLastInViews2, "sharedElementLastInViews");
                View view7 = sharedElementLastInViews2;
                Log.v(str6, "View: " + view7 + " Name: " + ViewCompat.getTransitionName(view7));
            }
        }
        transitionImpl5.beginDelayedTransition(getContainer(), mergedTransition2);
        transitionImpl5.setNameOverridesReordered(getContainer(), sharedElementFirstOutViews, sharedElementLastInViews, inNames, sharedElementNameMapping3);
        FragmentTransition.setViewVisibility(enteringViews, 0);
        transitionImpl5.swapSharedElementTargets(sharedElementTransition2, sharedElementFirstOutViews, sharedElementLastInViews);
        return startedTransitions3;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static final void startTransitions$lambda$9(SpecialEffectsController.Operation $lastIn, SpecialEffectsController.Operation $firstOut, boolean $isPop, ArrayMap lastInViews) {
        Intrinsics.checkNotNullParameter(lastInViews, "$lastInViews");
        FragmentTransition.callSharedElementStartEnd($lastIn.getFragment(), $firstOut.getFragment(), $isPop, lastInViews, false);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static final void startTransitions$lambda$10(FragmentTransitionImpl impl, View $lastInEpicenterView, Rect lastInEpicenterRect) {
        Intrinsics.checkNotNullParameter(impl, "$impl");
        Intrinsics.checkNotNullParameter(lastInEpicenterRect, "$lastInEpicenterRect");
        impl.getBoundsOnScreen($lastInEpicenterView, lastInEpicenterRect);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static final void startTransitions$lambda$11(ArrayList transitioningViews) {
        Intrinsics.checkNotNullParameter(transitioningViews, "$transitioningViews");
        FragmentTransition.setViewVisibility(transitioningViews, 4);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static final void startTransitions$lambda$14$lambda$13(TransitionInfo transitionInfo, SpecialEffectsController.Operation operation) {
        Intrinsics.checkNotNullParameter(transitionInfo, "$transitionInfo");
        Intrinsics.checkNotNullParameter(operation, "$operation");
        transitionInfo.completeSpecialEffect();
        if (FragmentManager.isLoggingEnabled(2)) {
            Log.v(FragmentManager.TAG, "Transition for operation " + operation + " has completed");
        }
    }

    private final void retainMatchingViews(ArrayMap<String, View> arrayMap, final Collection<String> collection) {
        Set<Map.Entry<String, View>> entries = arrayMap.entrySet();
        Intrinsics.checkNotNullExpressionValue(entries, "entries");
        CollectionsKt.retainAll(entries, new Function1<Map.Entry<String, View>, Boolean>() { // from class: androidx.fragment.app.DefaultSpecialEffectsController$retainMatchingViews$1
            /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
            {
                super(1);
            }

            @Override // kotlin.jvm.functions.Function1
            public final Boolean invoke(Map.Entry<String, View> entry) {
                Intrinsics.checkNotNullParameter(entry, "entry");
                return Boolean.valueOf(CollectionsKt.contains(collection, ViewCompat.getTransitionName(entry.getValue())));
            }
        });
    }

    private final void captureTransitioningViews(ArrayList<View> transitioningViews, View view) {
        if (view instanceof ViewGroup) {
            if (ViewGroupCompat.isTransitionGroup((ViewGroup) view)) {
                if (!transitioningViews.contains(view)) {
                    transitioningViews.add(view);
                    return;
                }
                return;
            }
            int count = ((ViewGroup) view).getChildCount();
            for (int i = 0; i < count; i++) {
                View child = ((ViewGroup) view).getChildAt(i);
                if (child.getVisibility() == 0) {
                    Intrinsics.checkNotNullExpressionValue(child, "child");
                    captureTransitioningViews(transitioningViews, child);
                }
            }
            return;
        }
        if (!transitioningViews.contains(view)) {
            transitioningViews.add(view);
        }
    }

    private final void findNamedViews(Map<String, View> namedViews, View view) {
        String transitionName = ViewCompat.getTransitionName(view);
        if (transitionName != null) {
            namedViews.put(transitionName, view);
        }
        if (view instanceof ViewGroup) {
            int count = ((ViewGroup) view).getChildCount();
            for (int i = 0; i < count; i++) {
                View child = ((ViewGroup) view).getChildAt(i);
                if (child.getVisibility() == 0) {
                    Intrinsics.checkNotNullExpressionValue(child, "child");
                    findNamedViews(namedViews, child);
                }
            }
        }
    }

    private final void applyContainerChanges(SpecialEffectsController.Operation operation) {
        View view = operation.getFragment().mView;
        SpecialEffectsController.Operation.State finalState = operation.getFinalState();
        Intrinsics.checkNotNullExpressionValue(view, "view");
        finalState.applyState(view);
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* compiled from: DefaultSpecialEffectsController.kt */
    @Metadata(d1 = {"\u0000&\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u000b\n\u0002\b\u0006\n\u0002\u0010\u0002\n\u0000\b\u0012\u0018\u00002\u00020\u0001B\u0015\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0005¢\u0006\u0002\u0010\u0006J\u0006\u0010\u000e\u001a\u00020\u000fR\u0011\u0010\u0007\u001a\u00020\b8F¢\u0006\u0006\u001a\u0004\b\u0007\u0010\tR\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\n\u0010\u000bR\u0011\u0010\u0004\u001a\u00020\u0005¢\u0006\b\n\u0000\u001a\u0004\b\f\u0010\r¨\u0006\u0010"}, d2 = {"Landroidx/fragment/app/DefaultSpecialEffectsController$SpecialEffectsInfo;", "", "operation", "Landroidx/fragment/app/SpecialEffectsController$Operation;", "signal", "Landroidx/core/os/CancellationSignal;", "(Landroidx/fragment/app/SpecialEffectsController$Operation;Landroidx/core/os/CancellationSignal;)V", "isVisibilityUnchanged", "", "()Z", "getOperation", "()Landroidx/fragment/app/SpecialEffectsController$Operation;", "getSignal", "()Landroidx/core/os/CancellationSignal;", "completeSpecialEffect", "", "fragment_release"}, k = 1, mv = {1, 8, 0}, xi = 48)
    static class SpecialEffectsInfo {
        private final SpecialEffectsController.Operation operation;
        private final CancellationSignal signal;

        public SpecialEffectsInfo(SpecialEffectsController.Operation operation, CancellationSignal signal) {
            Intrinsics.checkNotNullParameter(operation, "operation");
            Intrinsics.checkNotNullParameter(signal, "signal");
            this.operation = operation;
            this.signal = signal;
        }

        public final SpecialEffectsController.Operation getOperation() {
            return this.operation;
        }

        public final CancellationSignal getSignal() {
            return this.signal;
        }

        public final boolean isVisibilityUnchanged() {
            SpecialEffectsController.Operation.State.Companion companion = SpecialEffectsController.Operation.State.INSTANCE;
            View view = this.operation.getFragment().mView;
            Intrinsics.checkNotNullExpressionValue(view, "operation.fragment.mView");
            SpecialEffectsController.Operation.State currentState = companion.asOperationState(view);
            SpecialEffectsController.Operation.State finalState = this.operation.getFinalState();
            return currentState == finalState || !(currentState == SpecialEffectsController.Operation.State.VISIBLE || finalState == SpecialEffectsController.Operation.State.VISIBLE);
        }

        public final void completeSpecialEffect() {
            this.operation.completeSpecialEffect(this.signal);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* compiled from: DefaultSpecialEffectsController.kt */
    @Metadata(d1 = {"\u0000,\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\b\u0002\u0018\u00002\u00020\u0001B\u001d\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0005\u0012\u0006\u0010\u0006\u001a\u00020\u0007¢\u0006\u0002\u0010\bJ\u0010\u0010\f\u001a\u0004\u0018\u00010\n2\u0006\u0010\r\u001a\u00020\u000eR\u0010\u0010\t\u001a\u0004\u0018\u00010\nX\u0082\u000e¢\u0006\u0002\n\u0000R\u000e\u0010\u000b\u001a\u00020\u0007X\u0082\u000e¢\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0007X\u0082\u0004¢\u0006\u0002\n\u0000¨\u0006\u000f"}, d2 = {"Landroidx/fragment/app/DefaultSpecialEffectsController$AnimationInfo;", "Landroidx/fragment/app/DefaultSpecialEffectsController$SpecialEffectsInfo;", "operation", "Landroidx/fragment/app/SpecialEffectsController$Operation;", "signal", "Landroidx/core/os/CancellationSignal;", "isPop", "", "(Landroidx/fragment/app/SpecialEffectsController$Operation;Landroidx/core/os/CancellationSignal;Z)V", "animation", "Landroidx/fragment/app/FragmentAnim$AnimationOrAnimator;", "isAnimLoaded", "getAnimation", "context", "Landroid/content/Context;", "fragment_release"}, k = 1, mv = {1, 8, 0}, xi = 48)
    static final class AnimationInfo extends SpecialEffectsInfo {
        private FragmentAnim.AnimationOrAnimator animation;
        private boolean isAnimLoaded;
        private final boolean isPop;

        /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
        public AnimationInfo(SpecialEffectsController.Operation operation, CancellationSignal signal, boolean isPop) {
            super(operation, signal);
            Intrinsics.checkNotNullParameter(operation, "operation");
            Intrinsics.checkNotNullParameter(signal, "signal");
            this.isPop = isPop;
        }

        public final FragmentAnim.AnimationOrAnimator getAnimation(Context context) {
            Intrinsics.checkNotNullParameter(context, "context");
            if (this.isAnimLoaded) {
                return this.animation;
            }
            FragmentAnim.AnimationOrAnimator it = FragmentAnim.loadAnimation(context, getOperation().getFragment(), getOperation().getFinalState() == SpecialEffectsController.Operation.State.VISIBLE, this.isPop);
            this.animation = it;
            this.isAnimLoaded = true;
            return it;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* compiled from: DefaultSpecialEffectsController.kt */
    @Metadata(d1 = {"\u0000.\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0002\b\u0005\n\u0002\u0010\u0000\n\u0002\b\u0006\b\u0002\u0018\u00002\u00020\u0001B%\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0005\u0012\u0006\u0010\u0006\u001a\u00020\u0007\u0012\u0006\u0010\b\u001a\u00020\u0007¢\u0006\u0002\u0010\tJ\u0014\u0010\f\u001a\u0004\u0018\u00010\u000b2\b\u0010\u0014\u001a\u0004\u0018\u00010\u0011H\u0002J\u0006\u0010\u0016\u001a\u00020\u0007R\u0013\u0010\n\u001a\u0004\u0018\u00010\u000b8F¢\u0006\u0006\u001a\u0004\b\f\u0010\rR\u0011\u0010\u000e\u001a\u00020\u0007¢\u0006\b\n\u0000\u001a\u0004\b\u000e\u0010\u000fR\u0013\u0010\u0010\u001a\u0004\u0018\u00010\u0011¢\u0006\b\n\u0000\u001a\u0004\b\u0012\u0010\u0013R\u0013\u0010\u0014\u001a\u0004\u0018\u00010\u0011¢\u0006\b\n\u0000\u001a\u0004\b\u0015\u0010\u0013¨\u0006\u0017"}, d2 = {"Landroidx/fragment/app/DefaultSpecialEffectsController$TransitionInfo;", "Landroidx/fragment/app/DefaultSpecialEffectsController$SpecialEffectsInfo;", "operation", "Landroidx/fragment/app/SpecialEffectsController$Operation;", "signal", "Landroidx/core/os/CancellationSignal;", "isPop", "", "providesSharedElementTransition", "(Landroidx/fragment/app/SpecialEffectsController$Operation;Landroidx/core/os/CancellationSignal;ZZ)V", "handlingImpl", "Landroidx/fragment/app/FragmentTransitionImpl;", "getHandlingImpl", "()Landroidx/fragment/app/FragmentTransitionImpl;", "isOverlapAllowed", "()Z", "sharedElementTransition", "", "getSharedElementTransition", "()Ljava/lang/Object;", "transition", "getTransition", "hasSharedElementTransition", "fragment_release"}, k = 1, mv = {1, 8, 0}, xi = 48)
    static final class TransitionInfo extends SpecialEffectsInfo {
        private final boolean isOverlapAllowed;
        private final Object sharedElementTransition;
        private final Object transition;

        /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
        public TransitionInfo(SpecialEffectsController.Operation operation, CancellationSignal signal, boolean isPop, boolean providesSharedElementTransition) {
            super(operation, signal);
            Object returnTransition;
            boolean z;
            Object obj;
            Intrinsics.checkNotNullParameter(operation, "operation");
            Intrinsics.checkNotNullParameter(signal, "signal");
            if (operation.getFinalState() == SpecialEffectsController.Operation.State.VISIBLE) {
                Fragment fragment = operation.getFragment();
                returnTransition = isPop ? fragment.getReenterTransition() : fragment.getEnterTransition();
            } else {
                Fragment fragment2 = operation.getFragment();
                returnTransition = isPop ? fragment2.getReturnTransition() : fragment2.getExitTransition();
            }
            this.transition = returnTransition;
            if (operation.getFinalState() == SpecialEffectsController.Operation.State.VISIBLE) {
                if (isPop) {
                    z = operation.getFragment().getAllowReturnTransitionOverlap();
                } else {
                    z = operation.getFragment().getAllowEnterTransitionOverlap();
                }
            } else {
                z = true;
            }
            this.isOverlapAllowed = z;
            if (providesSharedElementTransition) {
                if (isPop) {
                    obj = operation.getFragment().getSharedElementReturnTransition();
                } else {
                    obj = operation.getFragment().getSharedElementEnterTransition();
                }
            } else {
                obj = null;
            }
            this.sharedElementTransition = obj;
        }

        public final Object getTransition() {
            return this.transition;
        }

        /* renamed from: isOverlapAllowed, reason: from getter */
        public final boolean getIsOverlapAllowed() {
            return this.isOverlapAllowed;
        }

        public final Object getSharedElementTransition() {
            return this.sharedElementTransition;
        }

        public final boolean hasSharedElementTransition() {
            return this.sharedElementTransition != null;
        }

        public final FragmentTransitionImpl getHandlingImpl() {
            FragmentTransitionImpl transitionImpl = getHandlingImpl(this.transition);
            FragmentTransitionImpl sharedElementTransitionImpl = getHandlingImpl(this.sharedElementTransition);
            if (transitionImpl == null || sharedElementTransitionImpl == null || transitionImpl == sharedElementTransitionImpl) {
                return transitionImpl == null ? sharedElementTransitionImpl : transitionImpl;
            }
            throw new IllegalArgumentException(("Mixing framework transitions and AndroidX transitions is not allowed. Fragment " + getOperation().getFragment() + " returned Transition " + this.transition + " which uses a different Transition  type than its shared element transition " + this.sharedElementTransition).toString());
        }

        private final FragmentTransitionImpl getHandlingImpl(Object transition) {
            if (transition == null) {
                return null;
            }
            if (FragmentTransition.PLATFORM_IMPL != null && FragmentTransition.PLATFORM_IMPL.canHandle(transition)) {
                return FragmentTransition.PLATFORM_IMPL;
            }
            if (FragmentTransition.SUPPORT_IMPL != null && FragmentTransition.SUPPORT_IMPL.canHandle(transition)) {
                return FragmentTransition.SUPPORT_IMPL;
            }
            throw new IllegalArgumentException("Transition " + transition + " for fragment " + getOperation().getFragment() + " is not a valid framework Transition or AndroidX Transition");
        }
    }
}
