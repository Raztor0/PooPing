//
//  PPSessionManager.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPSessionManager.h"
#import "FDKeychain.h"

const struct PPSessionManagerKeys PPSessionManagerKeys = {
    .accessToken = @"access_token",
    .refreshToken = @"refresh_token",
    .username = @"username",
};

static NSString *service = @"PooPing";

@implementation PPSessionManager

+ (void)setUsername:(NSString *)username {
    [FDKeychain saveItem:username forKey:PPSessionManagerKeys.username forService:service error:nil];
}

+ (NSString*)getUsername {
    return [FDKeychain itemForKey:PPSessionManagerKeys.username forService:service error:nil];
}

+ (void)deleteUsername {
    [FDKeychain deleteItemForKey:PPSessionManagerKeys.username forService:service error:nil];
}

+ (void)setAccessToken:(NSString *)accessToken {
    [FDKeychain saveItem:accessToken forKey:PPSessionManagerKeys.accessToken forService:service error:nil];
}

+ (NSString*)getAccessToken {
    return [FDKeychain itemForKey:PPSessionManagerKeys.accessToken forService:service error:nil];
}

+ (void)deleteAccessToken {
    [FDKeychain deleteItemForKey:PPSessionManagerKeys.accessToken forService:service error:nil];
}

+ (void)setRefreshToken:(NSString *)refreshToken {
    [FDKeychain saveItem:refreshToken forKey:PPSessionManagerKeys.refreshToken forService:service error:nil];
}

+ (NSString*)getRefreshToken {
    return [FDKeychain itemForKey:PPSessionManagerKeys.refreshToken forService:service error:nil];
}

+ (void)deleteRefreshToken {
    [FDKeychain deleteItemForKey:PPSessionManagerKeys.refreshToken forService:service error:nil];
}

+ (void)deleteAllInfo {
    [self deleteUsername];
    [self deleteAccessToken];
    [self deleteRefreshToken];
}

@end
