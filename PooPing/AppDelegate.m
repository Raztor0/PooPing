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
#import "PPMenuViewController.h"
#import "PPSpecModule.h"

@interface AppDelegate ()

@property (nonatomic, strong) PPNetworkClient *networkClient;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        [PPSessionManager deleteAllInfo];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [Fabric with:@[CrashlyticsKit]];
    
    if([[[NSProcessInfo processInfo] environment] objectForKey:@"SPECS"]) {
        self.injector = [Blindside injectorWithModule:[[PPSpecModule alloc] init]];
    } else {
        self.injector = [Blindside injectorWithModule:[[PPModule alloc] init]];
    }
    
    
    self.networkClient = [self.injector getInstance:[PPNetworkClient class]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UINavigationBar appearance] setTintColor:[PPColors pooPingNavBarButtonItemColor]];
    [[UINavigationBar appearance] setBarTintColor:[PPColors pooPingNavBarColor]];
    
    self.rootViewController = [self.injector getInstance:[PPHomeViewController class]];
    
    SlideNavigationController *slideNavController = [[SlideNavigationController alloc] initWithRootViewController:self.rootViewController];
    slideNavController.navigationBar.translucent = NO;
    slideNavController.enableSwipeGesture = NO;
    
    PPMenuViewController *menuViewController = [self.injector getInstance:[PPMenuViewController class]];
    [menuViewController setupWithDelegate:self];
    [SlideNavigationController sharedInstance].leftMenu = menuViewController;
    
    self.window.rootViewController = slideNavController;
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

#pragma mark - PPMenuViewControllerDelegate

- (void)didTapLogout {
    [self.networkClient logout];
    [PPSessionManager deleteAllInfo];
    [self.rootViewController showLoginViewAnimated:YES];
}

- (void)didTapRecentPings {
    [self.rootViewController showRecentPingsView];
}

- (void)didTapPooPals {
    [self.rootViewController showPooPalsView];
}

@end
