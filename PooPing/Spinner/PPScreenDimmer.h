//
//  PPScreenDimmer.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-20.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface PPScreenDimmer : NSObject

@property (nonatomic, strong, readonly) UIView *view;

- (instancetype)initWithView:(UIView *)viewToDim NS_DESIGNATED_INITIALIZER;

- (void)dimView;
- (void)undimView;

@end
