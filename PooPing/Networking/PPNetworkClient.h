//
//  PPNetworking.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSPromise;
@class PPPoopRating;
@class AFHTTPRequestOperationManager;

extern NSString * PPNetworkingInvalidTokenNotification;
extern NSString * PPNetworkingUserRefreshNotification;

@interface PPNetworkClient : NSObject

- (KSPromise*)signUpWithEmail:(NSString*)email username:(NSString*)username password:(NSString*)password;
- (KSPromise*)loginRequestForUsername:(NSString*)username password:(NSString*)password;
- (KSPromise*)logout;
- (KSPromise*)postPooPingWithPoopRating:(PPPoopRating*)rating;
- (KSPromise*)postFriendRequestForUser:(NSString*)userName;
- (KSPromise*)getCurrentUser;
- (KSPromise*)deleteFriend:(NSString*)username;
- (KSPromise*)postNotificationToken:(NSString*)token;

@end
