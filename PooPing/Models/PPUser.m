
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
    PPUser *user = [PPUser new];
    [user setupWithDictionary:userDictionary];
    return user;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.recentPings = [NSMutableArray array];
    }
    return self;
}

- (void)setupWithDictionary:(NSDictionary*)dictionary {
    self.username = [dictionary objectForKey:@"username"];
    NSArray *friendDictionaries = [dictionary objectForKey:@"friends"];
    NSMutableArray *friends = [NSMutableArray array];
    for (NSDictionary *friendDictionary in friendDictionaries) {
        PPUser *friend = [PPUser new];
        [friend setupWithDictionary:friendDictionary];
        [friends addObject:friend];
    }
    self.friends = friends;
    NSArray *pingDictionaries = [dictionary objectForKey:@"pings"];
    NSMutableArray *pings = [NSMutableArray array];
    
    for(NSDictionary *pingDictionary in pingDictionaries) {
        PPPing *ping = [PPPing pingFromDictionary:pingDictionary];
        [pings addObject:ping];
    }
    
    self.recentPings = pings;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.friends forKey:@"friends"];
    [aCoder encodeObject:self.recentPings forKey:@"recentPings"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if(self) {
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.friends = [aDecoder decodeObjectForKey:@"friends"];
        self.recentPings = [aDecoder decodeObjectForKey:@"recentPings"];
    }
    return self;
}

@end
