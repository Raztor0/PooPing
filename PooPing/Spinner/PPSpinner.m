//
//  PPSpinner.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-20.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPSpinner.h"
#import "PPScreenDimmer.h"

@interface PPSpinner()

@property (nonatomic, strong, readwrite) PPScreenDimmer *dimmer;
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *indicator;

@end

@implementation PPSpinner

- (instancetype)init {
    self = [super init];
    if (self) {
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return self;
}

- (void)startAnimatingInView:(UIView*)view {
    self.dimmer = [[PPScreenDimmer alloc] initWithView:view];
    self.indicator.center = view.center;
    [view addSubview:self.indicator];
    
    [self.dimmer dimView];
    [view bringSubviewToFront:self.indicator];
    [self.indicator startAnimating];
}

- (void)startAnimating {
    [self startAnimatingInView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)stopAnimating {
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
    
    [self.dimmer undimView];
    self.dimmer = nil;
}

- (BOOL)isAnimating {
    return self.indicator.isAnimating;
}

@end
