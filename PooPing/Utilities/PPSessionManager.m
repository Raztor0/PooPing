//
//  PPSessionManager.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPSessionManager.h"
#import "FDKeychain.h"
#import "PPUser.h"
#import "PPFileUtils.h"

const struct PPSessionManagerKeys PPSessionManagerKeys = {
    .accessToken = @"access_token",
    .refreshToken = @"refresh_token",
    .user = @"user",
};

static NSString *service = @"PooPing";
static PPUser *currentUser;

#define kCurrentUserData [[PPFileUtils documentsPath] stringByAppendingPathComponent:@"currentuser.dat"]

#define kNotificationTokenData [[PPFileUtils documentsPath] stringByAppendingPathComponent:@"notificationtoken.dat"]

@implementation PPSessionManager

+ (void)setCurrentUser:(PPUser *)user {
    [NSKeyedArchiver archiveRootObject:user toFile:kCurrentUserData];
    currentUser = user;
}

+ (PPUser *)getCurrentUser {
    if(!currentUser) {
        currentUser = [NSKeyedUnarchiver unarchiveObjectWithFile:kCurrentUserData];
    }
    return currentUser;
}

+ (void)deleteCurrentUser {
    [[NSFileManager defaultManager] removeItemAtPath:kCurrentUserData error:nil];
    currentUser = nil;
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

+ (void)setNotificationToken:(NSString *)notificationToken {
    [NSKeyedArchiver archiveRootObject:notificationToken toFile:kNotificationTokenData];
}

+ (NSString *)getNotificationToken {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:kNotificationTokenData];
}

+ (void)deleteNotificationToken {
    [[NSFileManager defaultManager] removeItemAtPath:kNotificationTokenData error:nil];
}

+ (void)deleteAllInfo {
    [self deleteCurrentUser];
    [self deleteAccessToken];
    [self deleteRefreshToken];
    [self deleteNotificationToken];
}

@end
