//
//  PPSessionManager.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const struct PPSessionManagerKeys {
    __unsafe_unretained NSString *accessToken;
    __unsafe_unretained NSString *refreshToken;
    __unsafe_unretained NSString *username;
} PPSessionManagerKeys;

@interface PPSessionManager : NSObject

+ (void)setUsername:(NSString*)username;
+ (NSString*)getUsername;
+ (void)deleteUsername;

+ (void)setAccessToken:(NSString*)accessToken;
+ (NSString*)getAccessToken;
+ (void)deleteAccessToken;

+ (void)setRefreshToken:(NSString*)refreshToken;
+ (NSString*)getRefreshToken;
+ (void)deleteRefreshToken;

+ (void)deleteAllInfo;

@end
