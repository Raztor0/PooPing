//
//  PPScreenDimmer.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-20.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPScreenDimmer.h"

@interface PPScreenDimmer()

@property (nonatomic, strong) UIView *view;
@property (nonatomic, weak) UIView *viewToDim;

@end

@implementation PPScreenDimmer

- (instancetype)initWithView:(UIView *)viewToDim {
    self = [super init];
    
    if (self) {
        CGRect frame = viewToDim.frame;
        self.view = [[UIView alloc] initWithFrame:frame];
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.view setTintColor:[[UIApplication sharedApplication] keyWindow].tintColor];
        
        self.viewToDim = viewToDim;
    }
    
    return self;
}

- (void)dimView {
    [self.viewToDim addSubview:self.view];
    [self.viewToDim bringSubviewToFront:self.view];
}

- (void)undimView {
    [self.view removeFromSuperview];
}

@end
