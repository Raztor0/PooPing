//
//  PPFileUtils.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-21.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPFileUtils.h"

@implementation PPFileUtils

+ (NSString*)documentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

@end
