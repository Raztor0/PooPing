//
//  PPModule.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPModule.h"
#import "PPStoryboardProvider.h"

@implementation PPModule

- (void)configure:(id<BSBinder>)binder {
    [binder bind:@protocol(BSInjector) toBlock:^id(NSArray *args, id<BSInjector> injector) {
        return injector;
    }];
    
    [binder bind:[UIStoryboard class] toProvider:[PPStoryboardProvider new]];
}

@end
