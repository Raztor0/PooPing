//
//  PPColors.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-20.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPColors.h"

@implementation PPColors

+ (UIColor*)pooPingButtonDisabled {
    return [UIColor grayColor];
}

+ (NSArray*)pooPingButtonColors {
    UIColor *orange = [UIColor colorWithRed:255.0/255.0 green:173.0/255.0 blue:0.0/255.0 alpha:1.0];
    UIColor *pink = [UIColor colorWithRed:255.0/255.0 green:173.0/255.0 blue:255.0/255.0 alpha:1.0];
    return @[orange, pink];
}

+ (UIColor*)pooPingRandomButtonColor {
    u_int32_t randNum = arc4random_uniform((u_int32_t)([[self pooPingButtonColors] count]));
    return [[self pooPingButtonColors] objectAtIndex:randNum];
}

@end
