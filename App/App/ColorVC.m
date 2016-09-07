//
//  ViewController.m
//  Menu
//
//  Created by Dan Kalinin on 30/08/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "ColorVC.h"
#import <Menu/Menu.h>



@interface ColorVC ()

@end



@implementation ColorVC

- (IBAction)onMenu:(UIBarButtonItem *)sender {
    MenuVC *vc = (MenuVC *)self.navigationController.parentViewController;
    [vc showMenu];
}

@end
