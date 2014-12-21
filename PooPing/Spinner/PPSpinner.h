//
//  PPSpinner.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-20.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PPScreenDimmer;

@interface PPSpinner : NSObject

@property (nonatomic, strong, readonly) PPScreenDimmer *dimmer;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicator;

- (void)startAnimating; // animates over the window
- (void)startAnimatingInView:(UIView*)view;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
