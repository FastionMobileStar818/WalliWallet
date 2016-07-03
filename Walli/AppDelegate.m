//
//  AppDelegate.m
//  Walli
//
//  Created by Ryang on 12/12/15.
//  Copyright © 2015 Ryang. All rights reserved.
//

#import "AppDelegate.h"
#import "UIAlertView+Starlet.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@import AudioToolbox;

@interface AppDelegate ()
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTaks;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    self.vc = nil;
    NSLog(@"Launch");
    return YES;
}

- (void) applicationDidEnterBackground:(UIApplication *)application{
    self.bgTaks = [application beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
        NSLog(@"222");
        [application endBackgroundTask:self.bgTaks];
        self.bgTaks = UIBackgroundTaskInvalid;
    }];
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Do the work associated with the task, preferably in chunks.
        while (1) {
            sleep(1);
            NSLog(@"1111");
        }
        [application endBackgroundTask:self.bgTaks];
        self.bgTaks = UIBackgroundTaskInvalid;
    });
}

#pragma mark - Play Background music
- (void) playBackgroundMusic:(int) nType{
    NSURL *url;
    if(nType == 0)
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"]];
    else
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp3"]];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //self.audioPlayer.numberOfLoops = -1;
    
    [self.audioPlayer play];

}


- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"Background mod");
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"%@", notification.alertBody);
    if([notification.alertBody containsString:@"Connected"])
    {
        [self playBackgroundMusic:0];
    }else{
        [self playBackgroundMusic:1];
    }
    [UIAlertView showMessage:notification.alertBody];
    //AudioServicesPlaySystemSound(1005);

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
