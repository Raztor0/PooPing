//
//  PPColors.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-20.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPColors.h"

@implementation PPColors

+ (UIColor*)pooPingAppColor {
    return [self colorWithR:35 G:142 B:168];
}

+ (UIColor*)pooPingButtonDisabled {
    return [UIColor grayColor];
}

+ (NSArray*)pooPingButtonColors {
    UIColor *orange = [self colorWithR:255 G:173 B:0];
    UIColor *pink = [self colorWithR:255 G:173 B:255];
    return @[orange, pink];
}

+ (UIColor*)pooPingRandomButtonColor {
    u_int32_t randNum = arc4random_uniform((u_int32_t)([[self pooPingButtonColors] count]));
    return [[self pooPingButtonColors] objectAtIndex:randNum];
}

#pragma mark - Private

+ (UIColor*)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue {
    return [self colorWithR:red G:green B:blue A:1.0f];
}

+ (UIColor*)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
