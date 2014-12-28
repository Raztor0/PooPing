//
//  PPSpecModule.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-27.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPSpecModule.h"
#import "PPStoryboardProvider.h"
#import <UIKit/UIKit.h>

@implementation PPSpecModule

- (void)configure:(id<BSBinder>)binder {
    [binder bind:@protocol(BSInjector) toBlock:^id(NSArray *args, id<BSInjector> injector) {
        return injector;
    }];
    
    [binder bind:[UIStoryboard class] toProvider:[PPStoryboardProvider new]];
}

@end
