//
//  MyMenuVC.m
//  App
//
//  Created by Dan Kalinin on 03/09/16.
//  Copyright © 2016 Dan Kalinin. All rights reserved.
//

#import "MyMenuVC.h"



@interface MyMenuVC ()

@end



@implementation MyMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"Red"];
    [self showViewController:nc];
}

@end
