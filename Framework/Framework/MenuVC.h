//
//  MenuVC.h
//  Menu
//
//  Created by Dan Kalinin on 30/08/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>










@interface MenuVC : UIViewController

@property NSTimeInterval duration;
@property CGFloat width;
@property CGFloat alpha;
@property (nonatomic) CGFloat anchor;

- (void)showViewController:(UIViewController *)vc;

- (void)showMenu;
- (void)hideMenu;

@end










@interface MenuNC : UINavigationController

@end










@interface MenuTBC : UITabBarController

@end
