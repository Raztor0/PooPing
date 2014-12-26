//
//  PPPoopRating.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-25.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPPoopRating.h"

@interface PPPoopRating()

@property (nonatomic, assign, readwrite) NSInteger difficulty;
@property (nonatomic, assign, readwrite) NSInteger smell;
@property (nonatomic, assign, readwrite) NSInteger relief;
@property (nonatomic, assign, readwrite) NSInteger size;
@property (nonatomic, assign, readwrite) NSInteger overall;

@end

@implementation PPPoopRating

- (void)setupWithDifficulty:(NSInteger)difficulty smell:(NSInteger)smell relief:(NSInteger)relief size:(NSInteger)size overall:(NSInteger)overall {
    self.difficulty = difficulty;
    self.smell = smell;
    self.relief = relief;
    self.size = size;
    self.overall = overall;
}

@end
