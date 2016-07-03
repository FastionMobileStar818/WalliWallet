//
//  MainScanViewController.m
//  Walli
//
//  Created by Ryang on 12/17/15.
//  Copyright © 2015 Ryang. All rights reserved.
//

#import "MainScanViewController.h"
#import "MainViewController.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"

@interface MainScanViewController ()
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imgViewWifi;
@property (weak, nonatomic) IBOutlet UIButton *btnScan;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imgViewSonar;

@end

@implementation MainScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.m = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.nDevices = [[NSMutableArray alloc]init];
    self.sensorTags = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onScan:(id)sender {
    if(self.m.state == CBCentralManagerStatePoweredOn){
        self.btnScan.hidden = YES;
        self.imgViewSonar.hidden = NO;
        self.imgViewWifi.hidden = NO;
        FLAnimatedImage *wifiGif = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"wifi" ofType:@"gif"]]];
        self.imgViewWifi.animatedImage = wifiGif;
        [self.imgViewWifi startAnimating];
        FLAnimatedImage *sonarGif = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sonar" ofType:@"gif"]]];
        self.imgViewSonar.animatedImage = sonarGif;
        [self.imgViewSonar startAnimating];
        self.btnScan.hidden = YES;
        [self.m scanForPeripheralsWithServices:nil options:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.imgViewSonar stopAnimating];
            [self.imgViewWifi stopAnimating];
            self.btnScan.hidden = NO;
            self.imgViewSonar.hidden = YES;
            self.imgViewWifi.hidden = YES;
            [self.m stopScan];
        });
    }
}




#pragma mark - CBCentralManager delegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBCentralManagerStatePoweredOn) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"BLE not supported !" message:[NSString stringWithFormat:@"CoreBluetooth return state: %d",central.state] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}




-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Found a BLE Device : %@",peripheral);
    
    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
     The reason for this is that the CFUUID .UUID property of CBPeripheral
     here is null the first time an unkown (never connected before in any app)
     peripheral is connected. So therefore we connect to all peripherals we find.
     */
    
    peripheral.delegate = self;
    [central connectPeripheral:peripheral options:nil];
    
    [self.nDevices addObject:peripheral];
    
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral discoverServices:nil];
}

#pragma  mark - CBPeripheral delegate

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services scanned !");
    [self.m cancelPeripheralConnection:peripheral];
    for (CBService *s in peripheral.services) {
        NSLog(@"Service found : %@ %d %@",[s.UUID UUIDString], s.peripheral.state, s.peripheral.name);
        for (CBCharacteristic *characteristic in s.characteristics ){
            NSLog(@"Character %@", characteristic.UUID);
        }
        if (/*[[s.UUID UUIDString] isEqual:@"0000FFE1-0000-1000-8000-00805F9B34FB"] &&*/ [s.peripheral.name isEqualToString:@"YOURWALLET"])
//        if (/*[[s.UUID UUIDString] isEqual:@"0000FFE1-0000-1000-8000-00805F9B34FB"] &&*/ [s.peripheral.name isEqualToString:@"TI BLE Sensor Tag"])
        {
            NSLog(@"This is a SensorTag !");
            found = YES;
        }
    }
    if (found) {
        // Match if we have this device from before
        for (int ii=0; ii < self.sensorTags.count; ii++) {
            CBPeripheral *p = [self.sensorTags objectAtIndex:ii];
            if ([p isEqual:peripheral]) {
                [self.sensorTags replaceObjectAtIndex:ii withObject:peripheral];
                replace = YES;
            }
        }
        if (!replace) {
            [self.sensorTags addObject:peripheral];
            [self.imgViewSonar stopAnimating];
            [self.imgViewWifi stopAnimating];
            self.imgViewWifi.hidden = YES;
            
            
            SWRevealViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
            MainViewController* front =  (MainViewController*) vc.frontViewController;
            
            
            AppDelegate *pDelegate = [[UIApplication sharedApplication] delegate];
            BLEDevice *d = [[BLEDevice alloc]init];
            
            d.p = peripheral;
            d.manager = self.m;
            d.setupData = [self makeSensorTagConfiguration];
            
            pDelegate.d = d;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateValueForCharacteristic = %@",characteristic.UUID);
}

#pragma mark - SensorTag configuration

-(NSMutableDictionary *) makeSensorTagConfiguration {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    
    [d setValue:@"1" forKey:@"Notification active"];
    
    [d setValue:@"FFE0" forKey:@"Notification service UUID"];
    [d setValue:@"FFE1" forKey:@"Notification config UUID"];
    //[d setValue:@"FFE2" forKey:@"Notification config UUID"];
    // Append the UUID to make it easy for app
    [d setValue:@"1" forKey:@"Battery active"];
    [d setValue:@"0000180F"  forKey:@"Battery service UUID"];
    [d setValue:@"00002A19" forKey:@"Battery config UUID"];
    // Then we setup the accelerometer

    [d setValue:@"1" forKey:@"IMMEDIATE active"];
    [d setValue:@"00001802-0000-1000-8000-00805f9b34fb"  forKey:@"IMMEDIATE service UUID"];
    [d setValue:@"00002a06-0000-1000-8000-00805f9b34fb"  forKey:@"IMMEDIATE data UUID"];

    
    //Then we setup the rH sensor
    [d setValue:@"1" forKey:@"Humidity active"];
    [d setValue:@"F000AA20-0451-4000-B000-000000000000"   forKey:@"Humidity service UUID"];
    [d setValue:@"F000AA21-0451-4000-B000-000000000000" forKey:@"Humidity data UUID"];
    [d setValue:@"F000AA22-0451-4000-B000-000000000000" forKey:@"Humidity config UUID"];
    
    //Then we setup the magnetometer
    [d setValue:@"1" forKey:@"Magnetometer active"];
    [d setValue:@"500" forKey:@"Magnetometer period"];
    [d setValue:@"F000AA30-0451-4000-B000-000000000000" forKey:@"Magnetometer service UUID"];
    [d setValue:@"F000AA31-0451-4000-B000-000000000000" forKey:@"Magnetometer data UUID"];
    [d setValue:@"F000AA32-0451-4000-B000-000000000000" forKey:@"Magnetometer config UUID"];
    [d setValue:@"F000AA33-0451-4000-B000-000000000000" forKey:@"Magnetometer period UUID"];
    
    //Then we setup the barometric sensor
    [d setValue:@"1" forKey:@"Barometer active"];
    [d setValue:@"F000AA40-0451-4000-B000-000000000000" forKey:@"Barometer service UUID"];
    [d setValue:@"F000AA41-0451-4000-B000-000000000000" forKey:@"Barometer data UUID"];
    [d setValue:@"F000AA42-0451-4000-B000-000000000000" forKey:@"Barometer config UUID"];
    [d setValue:@"F000AA43-0451-4000-B000-000000000000" forKey:@"Barometer calibration UUID"];
    
    [d setValue:@"1" forKey:@"Gyroscope active"];
    [d setValue:@"F000AA50-0451-4000-B000-000000000000" forKey:@"Gyroscope service UUID"];
    [d setValue:@"F000AA51-0451-4000-B000-000000000000" forKey:@"Gyroscope data UUID"];
    [d setValue:@"F000AA52-0451-4000-B000-000000000000" forKey:@"Gyroscope config UUID"];
    
    NSLog(@"%@",d);
    
    return d;
}


@end
