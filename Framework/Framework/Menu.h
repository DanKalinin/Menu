//
//  Menu.h
//  Menu
//
//  Created by Dan Kalinin on 8/24/17.
//  Copyright © 2017 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double MenuVersionNumber;
FOUNDATION_EXPORT const unsigned char MenuVersionString[];

#import <UIKit/UIKit.h>










@interface MenuView : UIView

@property IBInspectable UIColor *dimmingColor;
@property IBInspectable CGFloat dimmingEndAlpha;
@property IBInspectable CGFloat anchor;
@property IBInspectable BOOL above;
@property IBInspectable BOOL prefersStatusBarHidden;

@property CGAffineTransform contentEndTransform;
@property NSTimeInterval duration;

@end










@interface MenuViewController : UIViewController

@property (strong, nonatomic) IBOutlet MenuView *top;
@property (strong, nonatomic) IBOutlet MenuView *left;
@property (strong, nonatomic) IBOutlet MenuView *bottom;
@property (strong, nonatomic) IBOutlet MenuView *right;

@property (readonly) MenuView *menu;
@property (readonly) UIViewController *viewController;

- (void)menu:(MenuView *)menu show:(BOOL)show animated:(BOOL)animated;
- (void)setViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
