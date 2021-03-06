//
//  Menu.m
//  Menu
//
//  Created by Dan Kalinin on 8/24/17.
//  Copyright © 2017 Dan Kalinin. All rights reserved.
//

#import "Menu.h"
#import <Helpers/Helpers.h>










@interface MenuView ()

@property CATransform3D startTransform;
@property CATransform3D contentEndTransform;
@property UIScreenEdgePanGestureRecognizer *pgr;

@end



@implementation MenuView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dimmingColor = UIColor.blackColor;
        self.dimmingEndAlpha = 0.4;
        self.contentEndScale = 1.0;
        self.anchor = 0.5;
        self.duration = 0.3;
        self.above = NO;
        self.prefersStatusBarHidden = NO;
    }
    return self;
}

@end










@interface MenuViewController ()

@property (weak) UIViewController *topViewController;
@property (weak) UIViewController *leftViewController;
@property (weak) UIViewController *bottomViewController;
@property (weak) UIViewController *rightViewController;

@property UIPanGestureRecognizer *pgrDimming;
@property UITapGestureRecognizer *tgrDimming;

@property BOOL showing;
@property UIView *content;
@property UIView *dimming;
@property MenuView *menu;
@property UIViewController *viewController;

@property UIViewPropertyAnimator *animator;
@property CGFloat fraction;

@property BOOL shouldAutorotate;
@property BOOL prefersStatusBarHidden;
@property UIStatusBarAnimation preferredStatusBarUpdateAnimation;

@end



@implementation MenuViewController

@synthesize prefersStatusBarHidden = _prefersStatusBarHidden;
@synthesize preferredStatusBarUpdateAnimation = _preferredStatusBarUpdateAnimation;

- (void)menu:(MenuView *)menu show:(BOOL)show animated:(BOOL)animated {
    if (self.animator) return;
    
    self.showing = show;
    BOOL hide = !show;
    
    [UIView setAnimationsEnabled:animated];
    
    if (show) {
        self.menu = menu;
        menu.hidden = NO;
        self.dimming.backgroundColor = menu.dimmingColor;
        
        for (UIScreenEdgePanGestureRecognizer *pgr in self.view.gestureRecognizers) {
            pgr.enabled = [pgr isEqual:menu.pgr];
        }
        
        [self setPrefersStatusBarHidden:menu.prefersStatusBarHidden animated:animated];
    } else {
        
    }
    
    UICubicTimingParameters *timing = [UICubicTimingParameters.alloc initWithAnimationCurve:UIViewAnimationCurveLinear];
    UIViewPropertyAnimator *animator = [UIViewPropertyAnimator.alloc initWithDuration:menu.duration timingParameters:timing];
    [animator addAnimations:^{
        if (show) {
            menu.layer.transform = CATransform3DIdentity;
            CATransform3D transform = menu.above ? CATransform3DIdentity : menu.contentEndTransform;
            self.content.layer.transform = CATransform3DScale(transform, menu.contentEndScale, menu.contentEndScale, 1.0);
            self.dimming.alpha = menu.dimmingEndAlpha;
        } else {
            menu.layer.transform = menu.startTransform;
            self.content.layer.transform = CATransform3DIdentity;
            self.dimming.alpha = 0.0;
        }
    }];
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        if ((show && self.animator.reversed) || (hide && !self.animator.reversed)) {
            [self setPrefersStatusBarHidden:NO animated:animated];
            [self.view.gestureRecognizers setValue:@YES forKey:@"enabled"];
            menu.hidden = YES;
            self.menu = nil;
        }
        self.animator = nil;
        self.shouldAutorotate = YES;
        self.pgrDimming.enabled = self.tgrDimming.enabled = YES;
    }];
    [animator startAnimation];
    self.animator = animator;
    self.shouldAutorotate = NO;
    self.pgrDimming.enabled = self.tgrDimming.enabled = hide;
    
    [UIView setAnimationsEnabled:YES];
}

- (void)setViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isEqual:self.viewController]) return;
    
    [self removeEmbeddedViewController:self.viewController];
    [self embedViewController:viewController toView:self.content];
    
    self.viewController = viewController;
}

#pragma mark - View controller

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.content = UIView.new;
        self.dimming = UIView.new;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Content view
    
    self.content.frame = self.view.bounds;
    self.content.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:self.content];
    
    // Dimming view
    
    self.dimming.frame = self.view.bounds;
    self.dimming.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:self.dimming];
    
    self.pgrDimming = [UIPanGestureRecognizer.alloc initWithTarget:self action:@selector(onPan:)];
    [self.dimming addGestureRecognizer:self.pgrDimming];
    
    self.tgrDimming = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onTap:)];
    [self.dimming addGestureRecognizer:self.tgrDimming];
    
    self.dimming.alpha = 0.0;
    
    // Menu views
    
    CGRect frame;
    
    if (self.top) {
        CGFloat ty = 0.5 * self.content.bounds.size.height * (1.0 - self.left.contentEndScale);
        
        self.top.startTransform = CATransform3DMakeTranslation(0.0, -self.top.bounds.size.height, 0.0);
        self.top.contentEndTransform = CATransform3DMakeTranslation(0.0, self.top.bounds.size.height - ty, 0.0);
        
        frame = self.view.bounds;
        frame.origin.y = 0.0;
        frame.size.height = self.top.bounds.size.height;
        self.top.frame = frame;
        self.top.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin);
        [self.view addSubview:self.top];
        
        self.top.pgr = [UIScreenEdgePanGestureRecognizer.alloc initWithTarget:self action:@selector(onPan:)];
        self.top.pgr.edges = UIRectEdgeTop;
        [self.view addGestureRecognizer:self.top.pgr];
        
        self.top.layer.transform = self.top.startTransform;
        self.top.hidden = YES;
    }
    
    if (self.left) {
        CGFloat tx = 0.5 * self.content.bounds.size.width * (1.0 - self.left.contentEndScale);
        
        self.left.startTransform = CATransform3DMakeTranslation(-self.left.bounds.size.width, 0.0, 0.0);
        self.left.contentEndTransform = CATransform3DMakeTranslation(self.left.bounds.size.width - tx, 0.0, 0.0);
        
        frame = self.view.bounds;
        frame.origin.x = 0.0;
        frame.size.width = self.left.bounds.size.width;
        self.left.frame = frame;
        self.left.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin);
        [self.view addSubview:self.left];
        
        self.left.pgr = [UIScreenEdgePanGestureRecognizer.alloc initWithTarget:self action:@selector(onPan:)];
        self.left.pgr.edges = UIRectEdgeLeft;
        [self.view addGestureRecognizer:self.left.pgr];
        
        self.left.layer.transform = self.left.startTransform;
        self.left.hidden = YES;
    }
    
    if (self.bottom) {
        CGFloat ty = 0.5 * self.content.bounds.size.height * (1.0 - self.left.contentEndScale);
        
        self.bottom.startTransform = CATransform3DMakeTranslation(0.0, self.bottom.bounds.size.height, 0.0);
        self.bottom.contentEndTransform = CATransform3DMakeTranslation(0.0, -self.bottom.bounds.size.height + ty, 0.0);
        
        frame = self.view.bounds;
        frame.origin.y = (self.view.bounds.size.height - self.bottom.bounds.size.height);
        frame.size.height = self.bottom.bounds.size.height;
        self.bottom.frame = frame;
        self.bottom.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
        [self.view addSubview:self.bottom];
        
        self.bottom.pgr = [UIScreenEdgePanGestureRecognizer.alloc initWithTarget:self action:@selector(onPan:)];
        self.bottom.pgr.edges = UIRectEdgeBottom;
        [self.view addGestureRecognizer:self.bottom.pgr];
        
        self.bottom.layer.transform = self.bottom.startTransform;
        self.bottom.hidden = YES;
    }
    
    if (self.right) {
        CGFloat tx = 0.5 * self.content.bounds.size.width * (1.0 - self.left.contentEndScale);
        
        self.right.startTransform = CATransform3DMakeTranslation(self.right.bounds.size.width, 0.0, 0.0);
        self.right.contentEndTransform = CATransform3DMakeTranslation(-self.right.bounds.size.width + tx, 0.0, 0.0);
        
        frame = self.view.bounds;
        frame.origin.x = self.view.bounds.size.width - self.right.bounds.size.width;
        frame.size.width = self.right.bounds.size.width;
        self.right.frame = frame;
        self.right.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin);
        [self.view addSubview:self.right];
        
        self.right.pgr = [UIScreenEdgePanGestureRecognizer.alloc initWithTarget:self action:@selector(onPan:)];
        self.right.pgr.edges = UIRectEdgeRight;
        [self.view addGestureRecognizer:self.right.pgr];
        
        self.right.layer.transform = self.right.startTransform;
        self.right.hidden = YES;
    }
    
    // Menu view controllers
    
    for (UIViewController *viewController in self.childViewControllers) {
        if ([viewController.view.superview isEqual:self.top]) {
            self.topViewController = viewController;
        } else if ([viewController.view.superview isEqual:self.left]) {
            self.leftViewController = viewController;
        } else if ([viewController.view.superview isEqual:self.bottom]) {
            self.bottomViewController = viewController;
        } else if ([viewController.view.superview isEqual:self.right]) {
            self.rightViewController = viewController;
        }
    }
}

#pragma mark - Actions

- (void)onPan:(UIPanGestureRecognizer *)pgr {
    BOOL hide = [pgr isEqual:self.pgrDimming];
    BOOL show = !hide;
    
    if (pgr.state == UIGestureRecognizerStateBegan) {
        MenuView *menu;
        if (hide) {
            menu = self.menu;
        } else if ([pgr isEqual:self.top.pgr]) {
            menu = self.top;
        } else if ([pgr isEqual:self.left.pgr]) {
            menu = self.left;
        } else if ([pgr isEqual:self.bottom.pgr]) {
            menu = self.bottom;
        } else {
            menu = self.right;
        }
        
        [self menu:menu show:show animated:YES];
        [self.animator pauseAnimation];
        self.fraction = self.animator.fractionComplete;
        [pgr setTranslation:CGPointZero inView:self.view];
    } else if (pgr.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pgr translationInView:self.view];
        CGFloat fraction = self.fraction;
        if ([self.menu isEqual:self.top] || [self.menu isEqual:self.bottom]) {
            if ([self.menu isEqual:self.top]) {
                if ((show && (translation.y < 0)) || (hide && (translation.y > 0))) return;
            } else {
                if ((show && (translation.y > 0)) || (hide && (translation.y < 0))) return;
            }
            fraction += fabs(translation.y / self.menu.bounds.size.height);
        } else {
            if ([self.menu isEqual:self.left]) {
                if ((show && (translation.x < 0)) || (hide && (translation.x > 0))) return;
            } else {
                if ((show && (translation.x > 0)) || (hide && (translation.x < 0))) return;
            }
            fraction += fabs(translation.x / self.menu.bounds.size.width);
        }
        
        self.animator.fractionComplete = fraction;
    } else if (pgr.state >= UIGestureRecognizerStateEnded) {
        if (show) {
            self.animator.reversed = (self.animator.fractionComplete < self.menu.anchor);
        } else {
            self.animator.reversed = (self.animator.fractionComplete < (1.0 - self.menu.anchor));
        }
        [self.animator continueAnimationWithTimingParameters:nil durationFactor:1.0];
    }
}

- (void)onTap:(UITapGestureRecognizer *)tgr {
    [self menu:self.menu show:NO animated:YES];
}

#pragma mark - Helpers

- (void)setPrefersStatusBarHidden:(BOOL)prefersStatusBarHidden animated:(BOOL)animated {
    self.prefersStatusBarHidden = prefersStatusBarHidden;
    if (animated) {
        self.preferredStatusBarUpdateAnimation = UIStatusBarAnimationSlide;
    } else {
        self.preferredStatusBarUpdateAnimation = UIStatusBarAnimationNone;
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
