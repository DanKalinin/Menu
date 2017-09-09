//
//  MyMenuVC.m
//  Menu
//
//  Created by Dan Kalinin on 9/5/17.
//  Copyright © 2017 Dan Kalinin. All rights reserved.
//

#import "MenuVC.h"









@interface MenuVC ()

@end



@implementation MenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Red"];
    [self setViewController:vc animated:NO];
}

@end










@interface MenuTVC ()

@property MenuVC *menuViewController;

@end



@implementation MenuTVC

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    self.menuViewController = (MenuVC *)parent;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:cell.reuseIdentifier];
    [self.menuViewController setViewController:vc animated:YES];
    
    [self.menuViewController menu:self.menuViewController.menu show:NO animated:YES];
}

@end










@interface ContentVC ()

@property MenuVC *menuViewController;

@end



@implementation ContentVC

@dynamic parentViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuViewController = (MenuVC *)self.navigationController.parentViewController;
}

- (IBAction)onMenu:(UIBarButtonItem *)sender {
    [self.menuViewController menu:self.menuViewController.left show:YES animated:YES];
}

@end
