//
//  MainViewController.h
//  Walli
//
//  Created by Ryang on 12/19/15.
//  Copyright © 2015 Ryang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDevice.h"
#import "FLAnimatedImageView.h"

@interface MainViewController : UIViewController <CBCentralManagerDelegate,CBPeripheralDelegate>
@property (strong,nonatomic) BLEDevice *d;
@property NSMutableArray *sensorsEnabled;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *mainAnimationView;
@property (strong,nonatomic) NSMutableArray *sensorTags;
@end
