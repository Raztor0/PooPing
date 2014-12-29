
//
//  PPUser.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-21.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPUser.h"

@interface PPUser()

@property (nonatomic, strong, readwrite) NSString *username;
@property (nonatomic, strong, readwrite) NSArray *friends;

@end

@implementation PPUser

+ (PPUser *)userFromDictionary:(NSDictionary *)userDictionary {
    return [[PPUser alloc] initWithDictionary:userDictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
        self.username = [dictionary objectForKey:@"username"];
        self.friends = [dictionary objectForKey:@"friends"];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.friends forKey:@"friends"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.friends = [aDecoder decodeObjectForKey:@"friends"];
    }
    return self;
}

@end
