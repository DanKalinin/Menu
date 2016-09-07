//
//  ColorsVC.m
//  Menu
//
//  Created by Dan Kalinin on 31.08.16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "ColorsVC.h"
#import <Menu/Menu.h>



@interface ColorsVC ()

@end



@implementation ColorsVC

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Actions

- (IBAction)onColor:(UIButton *)sender {
    MenuVC *vc = (MenuVC *)self.presentingViewController;
    
    NSString *name;
    if (sender.tag == 0) {
        name = @"Red";
    } else if (sender.tag == 1) {
        name = @"Green";
    } else {
        name = @"Blue";
    }
    
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:name];
    [vc showViewController:nc];
    
    [vc hideMenu];
}

@end
