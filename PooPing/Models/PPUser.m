
//
//  PPUser.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-21.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPUser.h"
#import "PPPing.h"

@interface PPUser()

@property (nonatomic, strong, readwrite) NSString *username;
@property (nonatomic, strong, readwrite) NSArray *friends;
@property (nonatomic, strong, readwrite) NSMutableArray *recentPings;

@end

@implementation PPUser

+ (PPUser *)userFromDictionary:(NSDictionary *)userDictionary {
    return [[PPUser alloc] initWithDictionary:userDictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
        [self setupWithDictionary:dictionary];
        self.recentPings = [NSMutableArray array];
    }
    return self;
}

- (void)setupWithDictionary:(NSDictionary*)dictionary {
    self.username = [dictionary objectForKey:@"username"];
    self.friends = [dictionary objectForKey:@"friends"];
}

- (void)addRecentPings:(NSArray*)pings {
    NSMutableArray *pingIds = [NSMutableArray array];
    for (PPPing *ping in self.recentPings) {
        [pingIds addObject:@(ping.pingId)];
    }
    
    for(PPPing *ping in pings) {
        if (![pingIds containsObject:@(ping.pingId)]) {
            [self.recentPings addObject:ping];
        }
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.friends forKey:@"friends"];
    [aCoder encodeObject:self.recentPings forKey:@"recentPings"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.friends = [aDecoder decodeObjectForKey:@"friends"];
        self.recentPings = [aDecoder decodeObjectForKey:@"recentPings"];
    }
    return self;
}

@end
