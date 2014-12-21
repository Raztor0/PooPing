//
//  PPNetworking.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSPromise;

extern NSString * PPNetworkingInvalidTokenNotification;

@interface PPNetworking : NSObject

+ (KSPromise*)loginRequestForUsername:(NSString*)username password:(NSString*)password;
+ (KSPromise*)postPooPing;

@end
