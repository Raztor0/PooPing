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
#import <AFNetworking/AFNetworking.h>
#import "PPNetworkClient.h"

#ifdef DEBUG
#define HOSTNAME @"staging.pooping.co"
#else
#define HOSTNAME @"api.pooping.co"
#endif

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
    
    [binder bind:PPSharedNetworkClient toBlock:^id(NSArray *args, id<BSInjector> injector) {
        static PPNetworkClient *networkClient;
        if(!networkClient) {
            networkClient = [injector getInstance:[PPNetworkClient class]];
        }
        return  networkClient;
    }];
    
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@", HOSTNAME]]];
    requestOperationManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
    [binder bind:[AFHTTPRequestOperationManager class] toInstance:requestOperationManager];
}

@end
