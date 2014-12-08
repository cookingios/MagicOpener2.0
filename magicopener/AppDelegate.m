//
//  AppDelegate.m
//  magicopener
//
//  Created by wenlin on 14/11/27.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import "AppDelegate.h"
#import "FaceppAPI.h"
#import "MOManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    [Parse setApplicationId:@"uVNIxVLBvUWvVtLaFhMquaYZR2Tqje84YwcQ63i6"
                  clientKey:@"i28vvdncRQOzvLg7MqC4EYTXOyAChThecuC5D2Dm"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //parse config
    [[MOManager sharedManager] refreshCurrentCofig];
    
    //Mobclick
    //[MobClick startWithAppkey:@"5394383a56240b4ed102115a" reportPolicy:SEND_INTERVAL   channelId:@"APP Store"];
    
    
    //NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //[MobClick setAppVersion:version];
    
    //FacePP API
    [FaceppAPI initWithApiKey:@"87d3930c16fb8344c92b5ff8112aaf49" andApiSecret:@"GqqSTgSt611FzDN2j1Qh9fbv_Q2kgMh1" andRegion:APIServerRegionCN];
    
    [FaceppAPI setDebugMode:YES];
    
    //PUSH Notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        //这里还是原来的代码
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    /*
    if ([PFUser currentUser]) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (![[PFUser currentUser] objectForKey:@"isExpert"]){
            //user badge 打开即消失
            if (currentInstallation.badge != 0) {
                currentInstallation.badge = 0;
                [currentInstallation saveEventually];
            }
        }else{
            //expert 的badge一直保留
            PFQuery *query = [PFQuery queryWithClassName:@"Message"];
            [query whereKey:@"expert" equalTo:[PFUser currentUser]];
            [query whereKey:@"isReplyed" equalTo:[NSNumber numberWithBool:NO]];
            [query setCachePolicy:kPFCachePolicyNetworkOnly];
            [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
                if (!error) {
                    // The count request succeeded. Log the count
                    currentInstallation.badge = count;
                    [currentInstallation saveEventually];
                }
            }];
        }
    }
 */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - push notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    if ([PFUser currentUser]) {
        [currentInstallation setObject:[PFUser currentUser] forKey:@"owner"];
    }
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //[[MOManager sharedManager] getUnreadMessageCount];
    
}


@end
