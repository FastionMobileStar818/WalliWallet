//
//  MainScanViewController.h
//  Walli
//
//  Created by Ryang on 12/17/15.
//  Copyright © 2015 Ryang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"

@interface MainScanViewController : UIViewController <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong,nonatomic) CBCentralManager *m;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *sensorTags;


-(NSMutableDictionary *) makeSensorTagConfiguration;

@end
