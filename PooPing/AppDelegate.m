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

@interface AppDelegate ()

@property (nonatomic, strong) id<BSInjector> injector;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.injector = [Blindside injectorWithModule:[[PPModule alloc] init]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.rootViewController = [self.injector getInstance:[PPHomeViewController class]];
    self.rootViewController.view.hidden = YES;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(![PPSessionManager getAccessToken]) {
        [self.rootViewController showLoginViewAnimated:NO];
    } else {
        self.rootViewController.view.hidden = NO;
    }
}

@end
