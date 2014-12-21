//
//  PPStoryboardProvider.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-20.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPStoryboardProvider.h"
#import "UIDevice+DeviceType.h"

@implementation PPStoryboardProvider

- (id)provide:(NSArray *)args injector:(id<BSInjector>)injector {
    NSString *storyboardName = [args firstObject];
    NSString *deviceSpecificStoryboardName = [NSString stringWithFormat:@"%@_%@", storyboardName, ([UIDevice isIpad] ? @"iPad" : @"iPhone")];
    
    UIStoryboard *storyboard;
    
    if ([self storyboardExistsForName:storyboardName]) {
        storyboard = [BlindsidedStoryboard storyboardWithName:storyboardName
                                                       bundle:[NSBundle mainBundle]
                                                     injector:injector];
        
    } else if ([self storyboardExistsForName:deviceSpecificStoryboardName]) {
        storyboard = [BlindsidedStoryboard storyboardWithName:deviceSpecificStoryboardName
                                                       bundle:[NSBundle mainBundle]
                                                     injector:injector];
    } else {
        @throw [NSException exceptionWithName:@"TBStoryboardProviderException"
                                       reason:[NSString stringWithFormat:@"Storyboard for name '%@' doesn't exist", storyboardName]
                                     userInfo:nil];
    }
    return storyboard;
}

- (BOOL)storyboardExistsForName:(NSString *)storyboardName {
    NSString *path = [[NSBundle mainBundle] pathForResource:storyboardName ofType:@"storyboardc"];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end
