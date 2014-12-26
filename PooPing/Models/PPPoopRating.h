//
//  PPPoopRating.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-25.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPPoopRating : NSObject

@property (nonatomic, assign, readonly) NSInteger difficulty;
@property (nonatomic, assign, readonly) NSInteger smell;
@property (nonatomic, assign, readonly) NSInteger relief;
@property (nonatomic, assign, readonly) NSInteger size;
@property (nonatomic, assign, readonly) NSInteger overall;

- (void)setupWithDifficulty:(NSInteger)difficulty smell:(NSInteger)smell relief:(NSInteger)relief size:(NSInteger)size overall:(NSInteger)overall;

@end
