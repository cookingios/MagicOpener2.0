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
#import "MOHomeViewController.h"

@interface AppDelegate ()

@property (strong,nonatomic) NSString *htmlContent;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Parse
    [Parse setApplicationId:@"uVNIxVLBvUWvVtLaFhMquaYZR2Tqje84YwcQ63i6"
                  clientKey:@"i28vvdncRQOzvLg7MqC4EYTXOyAChThecuC5D2Dm"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [[MOManager sharedManager] refreshCurrentCofig];
    
    //Mobclick
    //[MobClick startWithAppkey:@"5394383a56240b4ed102115a" reportPolicy:SEND_INTERVAL   channelId:@"APP Store"];
    
    
    //NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //[MobClick setAppVersion:version];
    
    //FacePP API
    [FaceppAPI initWithApiKey:@"87d3930c16fb8344c92b5ff8112aaf49" andApiSecret:@"GqqSTgSt611FzDN2j1Qh9fbv_Q2kgMh1" andRegion:APIServerRegionCN];
    
    [FaceppAPI setDebugMode:YES];
    
    //Push Notification Settings
    //iOS8.0或以上
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else
    {
        //iOS7.0及以下
        [application registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }

    //Receive Push Notification
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    //打开性情专栏文章
    NSString *htmlContent = notificationPayload[@"htmlContent"];
    if (htmlContent&&[PFUser currentUser]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        
        self.window.rootViewController = tabBarController;
        [tabBarController setSelectedIndex:2];
        UIViewController *webViewController = [storyboard instantiateViewControllerWithIdentifier:@"ArticleDetailViewController"];
        [webViewController setValue:htmlContent forKey:@"htmlContent"];
        [(UINavigationController*)tabBarController.selectedViewController pushViewController:webViewController animated:YES];
    }
    //转到消息页
    NSString *eventId = notificationPayload[@"eventId"];
    if (eventId && [PFUser currentUser]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MOHomeViewController *tabBarController = (MOHomeViewController*)[storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [tabBarController setSelectedIndex:1];
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
    //响应新的性情专栏文章,询问用户是否现在查看
    self.htmlContent = userInfo[@"htmlContent"];
    if (_htmlContent && [PFUser currentUser]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收到新的专栏" message:@"是否现在查看?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 180;
        [alert show];
    }
    //响应消息推送,询问用户是否现在查看
    NSString *eventId = userInfo[@"eventId"];
    if (eventId && [PFUser currentUser]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收到新的消息" message:@"是否现在查看?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 240;
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==180 && buttonIndex == 1) {
        
        MOHomeViewController *tabBarController = (MOHomeViewController*)[self.window rootViewController];
        [tabBarController setSelectedIndex:2];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *webViewController = [storyboard instantiateViewControllerWithIdentifier:@"ArticleDetailViewController"];
        [webViewController setValue:self.htmlContent forKey:@"htmlContent"];
        [(UINavigationController*)tabBarController.selectedViewController pushViewController:webViewController animated:YES];

    }else if (alertView.tag==240 && buttonIndex==1){
        
        MOHomeViewController *tabBarController = (MOHomeViewController*)[self.window rootViewController];
        [tabBarController setSelectedIndex:1];
    }
}


@end
