//
//  PPColors.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-20.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPColors : NSObject

+ (UIColor*)pooPingAppColor;
+ (UIColor*)pooPingLightBlue;
+ (UIColor*)pooPingNavBarColor;
+ (UIColor*)pooPingNavBarButtonItemColor;
+ (UIColor*)pooPingButtonDisabled;
+ (NSArray*)pooPingButtonColors;
+ (UIColor*)pooPingRandomButtonColor;
+ (UIColor*)randomColor;

+ (UIColor*)oppositeOfColor:(UIColor*)color;

@end
