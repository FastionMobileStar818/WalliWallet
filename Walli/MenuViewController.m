//
//  MenuViewController.m
//  Walli
//
//  Created by Ryang on 12/19/15.
//  Copyright © 2015 Ryang. All rights reserved.
//

#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import "NotificationsViewController.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTap:(id)sender {
    [self.revealViewController revealToggleAnimated:YES];
}
- (IBAction)onNotification:(id)sender {
    NotificationsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    [self.revealViewController revealToggleAnimated:YES];
}
- (IBAction)onSettings:(id)sender {
    SettingsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    [self.revealViewController revealToggleAnimated:YES];
    
}
- (IBAction)onAboutUs:(id)sender {
    AboutViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    [self.revealViewController revealToggleAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
