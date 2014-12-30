//
//  PPPing.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-30.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPPing : NSObject <NSCoding>

@property (nonatomic, assign, readonly) NSInteger userId;
@property (nonatomic, assign, readonly) NSInteger pingId;
@property (nonatomic, assign, readonly) NSInteger difficulty;
@property (nonatomic, assign, readonly) NSInteger smell;
@property (nonatomic, assign, readonly) NSInteger relief;
@property (nonatomic, assign, readonly) NSInteger size;
@property (nonatomic, assign, readonly) NSInteger overall;
@property (nonatomic, strong, readonly) NSString *comment;

+ (PPPing*)pingFromDictionary:(NSDictionary*)dictionary;

@end
