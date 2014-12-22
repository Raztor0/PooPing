//
//  PPSessionManager.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPUser;

extern const struct PPSessionManagerKeys {
    __unsafe_unretained NSString *accessToken;
    __unsafe_unretained NSString *refreshToken;
    __unsafe_unretained NSString *user;
} PPSessionManagerKeys;

@interface PPSessionManager : NSObject

+ (void)setCurrentUser:(PPUser*)user;
+ (PPUser*)getCurrentUser;
+ (void)deleteCurrentUser;

+ (void)setAccessToken:(NSString*)accessToken;
+ (NSString*)getAccessToken;
+ (void)deleteAccessToken;

+ (void)setRefreshToken:(NSString*)refreshToken;
+ (NSString*)getRefreshToken;
+ (void)deleteRefreshToken;

+ (void)deleteAllInfo;

@end
