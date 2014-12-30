//
//  AppDelegate.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "AppDelegate.h"
#import "PPModule.h"
#import "PPStoryboardNames.h"
#import "BlindsidedStoryboard.h"
#import "PPHomeViewController.h"
#import "PPSessionManager.h"
#import "PPNetworkClient.h"
#import "PPHomeViewController.h"
#import "PPColors.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "KSPromise.h"
#import "SlideNavigationController.h"

@interface AppDelegate ()

@property (nonatomic, strong) PPNetworkClient *networkClient;
@property (nonatomic, strong) id<BSInjector> injector;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        [PPSessionManager deleteAllInfo];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [Fabric with:@[CrashlyticsKit]];
    
    self.injector = [Blindside injectorWithModule:[[PPModule alloc] init]];
    self.networkClient = [self.injector getInstance:[PPNetworkClient class]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UINavigationBar appearance] setTintColor:[PPColors pooPingNavBarButtonItemColor]];
    [[UINavigationBar appearance] setBarTintColor:[PPColors pooPingNavBarColor]];
    
    UITableViewController *menuViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [SlideNavigationController sharedInstance].leftMenu = menuViewController;
    
    self.rootViewController = [self.injector getInstance:[PPHomeViewController class]];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSString *notificationText = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    [[[UIAlertView alloc] initWithTitle:@"Received a notification" message:notificationText delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(![PPSessionManager getAccessToken]) {
        [self.rootViewController showLoginViewAnimated:NO];
    } else {
        [self.networkClient getCurrentUser];
        [self.networkClient getUserPingHistoryWithPage:0];
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
#ifdef DEBUG
    [[[UIAlertView alloc] initWithTitle:@"device token" message:token delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
#endif
    [PPSessionManager setNotificationToken:token];
    [self.networkClient postNotificationToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#ifdef DEBUG
    [[[UIAlertView alloc] initWithTitle:@"Error registering for remote notificiations" message:error.description delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
#endif
    NSLog(@"Error registering for remote notifications: %@", error);
}

@end
