//
//  MenuVC.m
//  Menu
//
//  Created by Dan Kalinin on 30/08/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "MenuVC.h"
#import <Helpers/Helpers.h>

static NSString *const ShowMenuSegue = @"Show Menu";
static NSString *const HideMenuSegue = @"Hide Menu";
static const CGFloat StatusBarHeight = 20.0;










@interface MenuPresentationController : UIPresentationController

@property CGFloat width;
@property CGFloat alpha;

@property UIView *dimmingView;
@property UIView *presentingSuperView;

@property UITapGestureRecognizer *tgr;
@property UIPanGestureRecognizer *pgr;

@end



@implementation MenuPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.dimmingView = [UIView new];
        
        self.tgr = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onTap:)];
        [self.dimmingView addGestureRecognizer:self.tgr];
    }
    return self;
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGRect frame = self.containerView.frame;
    frame.size.width = self.width;
    return frame;
}

- (void)presentationTransitionWillBegin {
    
    [self hideStatusBar:YES];
    
    self.presentingSuperView = self.presentingViewController.view.superview;
    self.presentingViewController.view.tag = -1;
    [self.containerView addSubview:self.presentingViewController.view];
    
    self.dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:self.alpha];
    [self.containerView addSubview:self.dimmingView];
    
    [self assignParameters:NO];
    
    if (self.presentedViewController.transitionCoordinator) {
        [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self assignParameters:YES];
        } completion:nil];
    } else {
        [self assignParameters:YES];
    }
    
    if (self.pgr) return;
    
    self.pgr = [UIPanGestureRecognizer.alloc initWithTarget:self.presentingViewController action:NSSelectorFromString(@"onPan:")];
    self.pgr.maximumNumberOfTouches = 1;
    [self.dimmingView addGestureRecognizer:self.pgr];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmingView removeFromSuperview];
        [self.presentingSuperView addSubview:self.presentingViewController.view];
        [self hideStatusBar:NO];
    }
}

- (void)dismissalTransitionWillBegin {
    
    [self assignParameters:YES];
    
    if (self.presentedViewController.transitionCoordinator) {
        [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self assignParameters:NO];
        } completion:nil];
    } else {
        [self assignParameters:NO];
    }
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.dimmingView removeFromSuperview];
        [self.presentingSuperView addSubview:self.presentingViewController.view];
        [self hideStatusBar:NO];
    }
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    [self assignFrames:YES];
}

#pragma mark - Actions

- (void)onTap:(UITapGestureRecognizer *)tgr {
    [(MenuVC *)self.presentingViewController hideMenu];
}

#pragma mark - Helpers

- (CGRect)frame:(BOOL)final {
    CGRect frame = self.containerView.frame;
    if (final) {
        frame.origin.x = self.width;
    }
    return frame;
}

- (void)assignFrames:(BOOL)final {
    self.dimmingView.frame = self.presentingViewController.view.frame = [self frame:final];
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

- (void)assignParameters:(BOOL)final {
    [self assignFrames:final];
    self.dimmingView.alpha = final;
}

- (void)hideStatusBar:(BOOL)hide {
    [self.presentingViewController setValue:@(hide) forKey:@"statusBarHidden"];
    [self.presentingViewController setNeedsStatusBarAppearanceUpdate];
}

@end










@interface MenuVC () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property BOOL presenting;
@property BOOL interacting;
@property UIPercentDrivenInteractiveTransition *interactor;
@property UIScreenEdgePanGestureRecognizer *pgr;
@property BOOL statusBarHidden;

@end



@implementation MenuVC

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.duration = 0.3;
        self.width = 200.0;
        self.alpha = 0.4;
        self.anchor = 0.5;
        
        self.interactor = [UIPercentDrivenInteractiveTransition new];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pgr = [UIScreenEdgePanGestureRecognizer.alloc initWithTarget:self action:@selector(onPan:)];
    self.pgr.edges = UIRectEdgeLeft;
    self.pgr.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:self.pgr];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:ShowMenuSegue]) {
        UIViewController *vc = segue.destinationViewController;
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.transitioningDelegate = self;
    }
}

- (void)showViewController:(UIViewController *)vc {
    UIViewController *childVC = self.childViewControllers.firstObject;
    if ([vc isEqual:childVC]) return;
    
    [self removeEmbeddedViewController:childVC];
    [self embedViewController:vc toView:self.view];
}

- (void)showMenu {
    [self performSegueWithIdentifier:ShowMenuSegue sender:self];
}

- (void)hideMenu {
    UIViewController *vc = self.presentedViewController;
    [vc performSegueWithIdentifier:HideMenuSegue sender:vc];
}

#pragma mark - Actions

- (IBAction)onHideMenu:(UIStoryboardSegue *)segue {
    
}

- (void)onPan:(UIPanGestureRecognizer *)pgr {
    
    UIWindow *window = self.view.window;
    
    if (pgr.state == UIGestureRecognizerStateBegan) {
        
        self.presenting = [pgr isEqual:self.pgr];
        self.interacting = YES;
        self.presenting ? [self showMenu] : [self hideMenu];
        [pgr setTranslation:CGPointZero inView:window];
        
    } else if (pgr.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [pgr translationInView:window];
        
        if (self.presenting && translation.x < 0.0) return;
        if (!self.presenting && translation.x > 0.0) return;
        
        CGFloat percentage = fabs(translation.x / self.width);
        percentage = [self normalizeValue:percentage];
        
        [self.interactor updateInteractiveTransition:percentage];
        
    } else if (pgr.state >= UIGestureRecognizerStateEnded) {
        
        CGFloat a, b, c, k, x, y;
        a = self.anchor;
        c = 0.4;
        x = self.presenting ? self.interactor.percentComplete : 1.0 - self.interactor.percentComplete;
        if (x < a) {
            b = 0.0;
            k = c / a;
        } else {
            b = c / (1.0 - a);
            k = -b;
        }
        y = k * x + b;
        
        self.interactor.completionSpeed = y;
        
        if (x < a || pgr.state == UIGestureRecognizerStateCancelled) {
            self.presenting ? [self.interactor cancelInteractiveTransition] : [self.interactor finishInteractiveTransition];
        } else {
            self.presenting ? [self.interactor finishInteractiveTransition] : [self.interactor cancelInteractiveTransition];
        }
        
        self.interacting = NO;
        
    }
}

#pragma mark - Transition delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.presenting = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.presenting = NO;
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (self.interacting) {
        return self.interactor;
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (self.interacting) {
        return self.interactor;
    }
    return nil;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    MenuPresentationController *mpc = [MenuPresentationController.alloc initWithPresentedViewController:presented presentingViewController:presenting];
    mpc.width = self.width;
    mpc.alpha = self.alpha;
    return mpc;
}

#pragma mark - Animator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *inView = [transitionContext containerView];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    if (self.presenting) {
        toView.frame = [transitionContext finalFrameForViewController:toVC];
        fromView = [inView viewWithTag:-1];
        [inView insertSubview:toView belowSubview:fromView];
    } else {
        toView = [inView viewWithTag:-1];
        fromView.frame = [transitionContext initialFrameForViewController:fromVC];
    }
    
    [UIView animateWithDuration:self.duration animations:^{} completion:^(BOOL finished) {
        BOOL success = ![transitionContext transitionWasCancelled];
        [transitionContext completeTransition:success];
    }];
}

#pragma mark - Helpers

- (CGFloat)normalizeValue:(CGFloat)value {
    value = fmin(value, 1.0);
    value = fmax(value, 0.0);
    return value;
}

#pragma mark - Accessors

- (void)setAnchor:(CGFloat)anchor {
    anchor = [self normalizeValue:anchor];
    _anchor = anchor;
}

@end










@implementation MenuNC

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.navigationBar.superview.frame.origin.y == StatusBarHeight) return;
    
    CGRect frame = self.view.window.frame;
    frame.origin.y += StatusBarHeight;
    frame.size.height -= StatusBarHeight;
    self.navigationBar.superview.frame = frame;
}

@end










@implementation MenuTBC

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.tabBar.superview.frame.origin.y == StatusBarHeight) return;
    
    CGRect frame = self.view.window.frame;
    frame.origin.y += StatusBarHeight;
    frame.size.height -= StatusBarHeight;
    self.tabBar.superview.frame = frame;
}

@end
