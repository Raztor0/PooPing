//
//  PPPing.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-30.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPPing.h"

@interface PPPing()

@property (nonatomic, assign, readwrite) NSInteger userId;
@property (nonatomic, assign, readwrite) NSInteger pingId;
@property (nonatomic, assign, readwrite) NSInteger difficulty;
@property (nonatomic, assign, readwrite) NSInteger smell;
@property (nonatomic, assign, readwrite) NSInteger relief;
@property (nonatomic, assign, readwrite) NSInteger size;
@property (nonatomic, assign, readwrite) NSInteger overall;
@property (nonatomic, strong, readwrite) NSString *comment;
@property (nonatomic, strong, readwrite) NSDate *dateSent;

@end

@implementation PPPing

+ (PPPing *)pingFromDictionary:(NSDictionary *)dictionary {
    PPPing *ping = [[PPPing alloc] initWithDictionary:dictionary];
    return ping;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if(self) {
        self.userId = [[dictionary objectForKey:@"userId"] integerValue];
        self.pingId = [[dictionary objectForKey:@"pingId"] integerValue];
        self.difficulty = [[dictionary objectForKey:@"difficulty"] integerValue];
        self.smell = [[dictionary objectForKey:@"smell"] integerValue];
        self.relief = [[dictionary objectForKey:@"relief"] integerValue];
        self.size = [[dictionary objectForKey:@"size"] integerValue];
        self.overall = [[dictionary objectForKey:@"overall"] integerValue];
        self.comment = [dictionary objectForKey:@"comment"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.dateSent = [dateFormatter dateFromString:[dictionary objectForKey:@"date_sent"]];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[@(self.userId) stringValue] forKey:@"userId"];
    [aCoder encodeObject:[@(self.pingId) stringValue] forKey:@"pingId"];
    [aCoder encodeObject:[@(self.difficulty) stringValue] forKey:@"difficulty"];
    [aCoder encodeObject:[@(self.smell) stringValue] forKey:@"smell"];
    [aCoder encodeObject:[@(self.relief) stringValue] forKey:@"relief"];
    [aCoder encodeObject:[@(self.size) stringValue] forKey:@"size"];
    [aCoder encodeObject:[@(self.overall) stringValue] forKey:@"overall"];
    [aCoder encodeObject:self.comment forKey:@"comment"];
    [aCoder encodeObject:self.dateSent forKey:@"dateSent"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.userId = [[aDecoder decodeObjectForKey:@"userId"] integerValue];
        self.pingId = [[aDecoder decodeObjectForKey:@"pingId"] integerValue];
        self.difficulty = [[aDecoder decodeObjectForKey:@"difficulty"] integerValue];
        self.smell = [[aDecoder decodeObjectForKey:@"smell"] integerValue];
        self.relief = [[aDecoder decodeObjectForKey:@"relief"] integerValue];
        self.size = [[aDecoder decodeObjectForKey:@"size"] integerValue];
        self.overall = [[aDecoder decodeObjectForKey:@"overall"] integerValue];
        self.comment = [aDecoder decodeObjectForKey:@"comment"];
        self.dateSent = [aDecoder decodeObjectForKey:@"dateSent"];
    }
    return self;
}

@end
