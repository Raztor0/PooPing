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

+ (UIColor*)pooPingLightBlue {
    return [self colorWithR:55 G:235 B:235];
}

+ (UIColor*)pooPingNavBarColor {
    return [UIColor whiteColor];
}

+ (UIColor*)pooPingNavBarButtonItemColor {
    return [UIColor blackColor];
}

+ (UIColor*)pooPingButtonDisabled {
    return [UIColor grayColor];
}

+ (NSArray*)pooPingButtonColors {
    return @[
             [self colorWithR:203 G:176 B:229], //light purple
             [self colorWithR:255 G:220 B:89],  //orange
             [self colorWithR:255 G:173 B:255], //pink
             [self colorWithR:9 G:200 B:146],   //green
             [self colorWithR:249 G:173 B:137], //beige
             [self colorWithR:148 G:40 B:216],
             [self colorWithR:74 G:209 B:190],
             [self colorWithR:175 G:13 B:104],
             [self colorWithR:143 G:81 B:167],
             [self colorWithR:239 G:210 B:245],
             [self colorWithR:185 G:218 B:228],
             ];
}

+ (UIColor*)oppositeOfColor:(UIColor*)color {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGFloat luminance = 0.2126*red + 0.7152*green + 0.0722*blue;
    if(luminance > 0.4) {
        return [UIColor blackColor];
    } else {
        return [UIColor whiteColor];
    }
}

+ (UIColor*)pooPingRandomButtonColor {
    u_int32_t randNum = arc4random_uniform((u_int32_t)([[self pooPingButtonColors] count]));
    return [[self pooPingButtonColors] objectAtIndex:randNum];
}

+ (UIColor*)randomColor {
    return [PPColors colorWithR:arc4random_uniform(255) G:arc4random_uniform(255) B:arc4random_uniform(255)];
}

#pragma mark - Private

+ (UIColor*)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue {
    return [self colorWithR:red G:green B:blue A:1.0f];
}

+ (UIColor*)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
