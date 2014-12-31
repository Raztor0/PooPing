//
//  AppDelegate.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPMenuViewController.h"

@class PPHomeViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, PPMenuViewControllerDelegate>

@property (nonatomic, strong) id<BSInjector> injector;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) PPHomeViewController *rootViewController;


@end

