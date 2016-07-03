//
//  AppDelegate.h
//  Walli
//
//  Created by Ryang on 12/12/15.
//  Copyright © 2015 Ryang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDevice.h"
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) BLEDevice *d;
@property (strong, nonatomic) MainViewController* vc;

@end

