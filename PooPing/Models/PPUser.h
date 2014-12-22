//
//  PPUser.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-21.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPUser : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSArray *friends;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
