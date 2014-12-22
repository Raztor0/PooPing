//
//  PPModule.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPModule.h"
#import "PPStoryboardProvider.h"
#import "PPHomeViewController.h"
#import "PPFriendsListViewController.h"

@implementation PPModule

- (void)configure:(id<BSBinder>)binder {
    [binder bind:@protocol(BSInjector) toBlock:^id(NSArray *args, id<BSInjector> injector) {
        return injector;
    }];
    
    [binder bind:[UIStoryboard class] toProvider:[PPStoryboardProvider new]];
    
    [binder bind:PPCurrentHomeViewController toBlock:^id(NSArray *args, id<BSInjector> injector) {
        static PPHomeViewController *currentHomeViewController;
        if(!currentHomeViewController) {
            currentHomeViewController = [injector getInstance:[PPHomeViewController class]];
        }
        return currentHomeViewController;
    }];
    
    [binder bind:PPCurrentFriendsListViewController toBlock:^id(NSArray *args, id<BSInjector> injector) {
        static PPFriendsListViewController *currentFriendsListViewController;
        if(!currentFriendsListViewController) {
            currentFriendsListViewController = [injector getInstance:[PPFriendsListViewController class]];
        }
        return currentFriendsListViewController;
    }];
}

@end
