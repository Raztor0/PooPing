//
//  PPNetworking.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPNetworking.h"
#import "AFNetworking.h"
#import "KSDeferred.h"
#import "PPSessionManager.h"
#import "NSDictionary+QueryString.h"
#import "PPUser.h"

#ifdef DEBUG
#define CLIENT_ID @"testclient"
#define CLIENT_SECRET @"testpass"
#define HOSTNAME @"pooping.razb.me"
#else
#define CLIENT_ID @"prodclient"
#define CLIENT_SECRET @"prodpass"
#define HOSTNAME @"pooping.razb.me"
#endif

const struct PPNetworkingGrantType {
    __unsafe_unretained NSString *password;
    __unsafe_unretained NSString *refreshToken;
} PPNetworkingGrantType;

const struct PPNetworkingGrantType PPNetworkingGrantType = {
    .password = @"password",
    .refreshToken = @"refresh_token",
};

const struct PPNetworkingErrorType {
    __unsafe_unretained NSString *expiredToken;
    __unsafe_unretained NSString *invalidToken;
} PPNetworkingErrorType;

const struct PPNetworkingErrorType PPNetworkingErrorType = {
    .expiredToken = @"expired_token",
    .invalidToken = @"invalid_token",
};

NSString * PPNetworkingInvalidTokenNotification = @"invalid_token_notification";
NSString * PPNetworkingUserRefreshNotification = @"user_refresh_notification";

@implementation PPNetworking

+ (AFHTTPRequestOperationManager*)requestOperationManager {
    static AFHTTPRequestOperationManager *requestOperationManager;
    if(!requestOperationManager) {
        requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/", HOSTNAME]]];
        requestOperationManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
    }
    return requestOperationManager;
}

#pragma mark - Public

+ (KSPromise*)loginRequestForUsername:(NSString*)username password:(NSString*)password {
    return [[self promiseAUTHForEndpoint:@"/token.php" withUsername:username password:password] then:^id(NSDictionary *json) {
        NSString *accessToken = [json objectForKey:PPSessionManagerKeys.accessToken];
        NSString *refreshToken = [json objectForKey:PPSessionManagerKeys.refreshToken];
        
        [PPSessionManager setAccessToken:accessToken];
        [PPSessionManager setRefreshToken:refreshToken];
        return json;
    } error:^id(NSError *error) {
        return error;
    }];
}

+ (KSPromise*)refreshToken {
    return [[self promiseRefreshTokenForEndpoint:@"/token.php"] then:^id(NSDictionary *json) {
        NSString *accessToken = [json objectForKey:PPSessionManagerKeys.accessToken];
        NSString *refreshToken = [json objectForKey:PPSessionManagerKeys.refreshToken];
        [PPSessionManager setAccessToken:accessToken];
        [PPSessionManager setRefreshToken:refreshToken];
        return json;
    } error:nil];
}

+ (KSPromise*)getCurrentUser {
    return [[self promiseGETForEndpoint:@"/me.php"] then:^id(NSDictionary *json) {
        PPUser *user = [[PPUser alloc] initWithDictionary:json];
        [PPSessionManager setCurrentUser:user];
        [[NSNotificationCenter defaultCenter] postNotificationName:PPNetworkingUserRefreshNotification object:user];
        return json;
    } error:^id(NSError *error) {
        NSLog(@"get current user error: %@", error);
        return error;
    }];
}

+ (KSPromise*)postPooPing {
    return [self promisePOSTForEndpoint:@"/ping.php"
                        withQueryParams:nil
                      additionalHeaders:nil
                                andBody:nil];
}

+ (KSPromise*)postFriendRequestForUser:(NSString*)userName {
    NSMutableURLRequest *request = [self addFriendPostURLRequestWithAdditionalBodyParameters:@{
                                                                                               @"username" : userName,
                                                                                               }];
    return [[self promiseForRequest:request] then:^id(id value) {
        [self getCurrentUser];
        return value;
    } error:^id(NSError *error) {
        return error;
    }];
}

+ (KSPromise*)deleteFriend:(NSString*)username {
    NSMutableURLRequest *request = [self removeFriendDeleteURLRequestWithAdditionalBodyParameters:@{
                                                                                                    @"username" : username,
                                                                                                    }];
    return [[self promiseForRequest:request] then:^id(id value) {
        [self getCurrentUser];
        return value;
    } error:^id(NSError *error) {
        return error;
    }];
}

#pragma mark - Private

+ (KSPromise*)promiseAUTHForEndpoint:(NSString*)endpoint withUsername:(NSString*)username password:(NSString*)password {
    NSMutableURLRequest *request = [self postURLRequestWithEndpoint:endpoint];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", CLIENT_ID, CLIENT_SECRET];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", PPAFBase64EncodedStringFromString(authStr)];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *bodyParams = @{
                                 @"grant_type" : PPNetworkingGrantType.password,
                                 @"username" : username,
                                 @"password" : password,
                                 };
    [request setHTTPBody:[[bodyParams queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [self promiseForRequest:request];
}

+ (KSPromise*)promiseRefreshTokenForEndpoint:(NSString*)endpoint {
    NSMutableURLRequest *request = [self postURLRequestWithEndpoint:endpoint];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", CLIENT_ID, CLIENT_SECRET];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", PPAFBase64EncodedStringFromString(authStr)];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *bodyParams = @{
                                 @"grant_type" : PPNetworkingGrantType.refreshToken,
                                 @"refresh_token" : [PPSessionManager getRefreshToken],
                                 };
    [request setHTTPBody:[[bodyParams queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [self promiseForRequest:request];
}

+ (KSPromise*)promisePOSTForEndpoint:(NSString*)endpoint withQueryParams:(NSDictionary*)queryParams additionalHeaders:(NSDictionary*)additionalHeaders andBody:(NSDictionary*)body {
    if([queryParams count]) {
        endpoint = [NSString stringWithFormat:@"%@?%@", endpoint, [queryParams queryStringValue]];
    }
    
    NSMutableURLRequest *request = [self postURLRequestWithEndpoint:endpoint];
    
    for (NSString *key in [additionalHeaders allKeys]) {
        [request addValue:[additionalHeaders objectForKey:key] forHTTPHeaderField:key];
    }
    
    NSMutableDictionary *clientBody = [NSMutableDictionary dictionaryWithDictionary:body];
    [clientBody addEntriesFromDictionary:@{
                                           @"client_id" : CLIENT_ID,
                                           @"client_secret" : CLIENT_SECRET,
                                           }];
    [request setHTTPBody:[[body queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [self promiseForRequest:request];
}

+ (KSPromise*)promiseGETForEndpoint:(NSString*)endpoint {
    NSMutableURLRequest *request = [self getURLRequestWithEndpoint:endpoint];
    return [self promiseForRequest:request];
}

+ (KSPromise*)promiseForRequest:(NSMutableURLRequest*)request {
    __block KSDeferred *deferred = [KSDeferred defer];
    
    [[[self requestOperationManager] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [deferred resolveWithValue:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey]) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableContainers error:nil];
            NSString *errorString = [response objectForKey:@"error"];
            if ([errorString isEqualToString:PPNetworkingErrorType.expiredToken]) {
                [[self refreshToken] then:^id(id value) {
                    [self updateRequestHeaderAccessToken:request];
                    KSPromise *promise = [[self promiseForRequest:request] then:^id(id value) {
                        [deferred resolveWithValue:value];
                        return value;
                    } error:^id(NSError *error) {
                        [deferred rejectWithError:error];
                        return error;
                    }];
                    return promise;
                } error:^id(NSError *error) {
                    [deferred rejectWithError:error];
                    return error;
                }];
            } else if([errorString isEqualToString:PPNetworkingErrorType.invalidToken]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PPNetworkingInvalidTokenNotification object:nil];
                [PPSessionManager deleteAllInfo];
                [deferred rejectWithError:error];
            } else {
                [deferred rejectWithError:error];
            }
        } else {
            [deferred rejectWithError:error];
        }
    }] start];
    
    return deferred.promise;
}

+ (NSMutableURLRequest*)getCurrentUserRequestWithAddtionalQueryParameters:(NSDictionary*)headerParams {
    NSMutableURLRequest *request = [self getURLRequestWithEndpoint:[NSString stringWithFormat:@"%@?%@", @"/me.php", [headerParams queryStringValue]]];
    return request;
}

+ (NSMutableURLRequest*)pingPostURLRequestWithAddtionalBodyParameters:(NSDictionary*)bodyParams {
    NSMutableURLRequest *request = [self postURLRequestWithEndpoint:@"/ping.php"];
    [request setHTTPBody:[[bodyParams queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

+ (NSMutableURLRequest*)addFriendPostURLRequestWithAdditionalBodyParameters:(NSDictionary*)bodyParams {
    NSMutableURLRequest *request = [self postURLRequestWithEndpoint:@"/friends.php"];
    [request setHTTPBody:[[bodyParams queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

+ (NSMutableURLRequest*)removeFriendDeleteURLRequestWithAdditionalBodyParameters:(NSDictionary*)bodyParams {
    NSMutableURLRequest *request = [self deleteURLRequestWithEndpoint:@"/friends.php"];
    [request setHTTPBody:[[bodyParams queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

+ (NSMutableURLRequest*)tokenPostURLRequestWithAdditionalBodyParameters:(NSDictionary*)bodyParams {
    NSMutableDictionary *bodyDictionary = [NSMutableDictionary dictionaryWithDictionary:bodyParams];
    [bodyDictionary addEntriesFromDictionary:@{
                                               @"client_id" : CLIENT_ID,
                                               @"client_secret" : CLIENT_SECRET
                                               }];
    NSMutableURLRequest *request = [self postURLRequestWithEndpoint:@"/token.php"];
    [request setHTTPBody:[[bodyDictionary queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

+ (NSMutableURLRequest*)getURLRequestWithEndpoint:(NSString*)endpoint {
    NSMutableURLRequest *request = [self requestForEndpoint:endpoint withType:@"GET"];
    return request;
}

+ (NSMutableURLRequest*)postURLRequestWithEndpoint:(NSString*)endpoint {
    NSMutableURLRequest *request = [self requestForEndpoint:endpoint withType:@"POST"];
    return request;
}

+ (NSMutableURLRequest*)deleteURLRequestWithEndpoint:(NSString*)endpoint {
    NSMutableURLRequest *request = [self requestForEndpoint:endpoint withType:@"DELETE"];
    return request;
}

+ (NSMutableURLRequest*)requestForEndpoint:(NSString*)endpoint withType:(NSString*)type {
    NSString *urlString = [self urlStringForPath:endpoint];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:type];
    [self setHttpHeadersForRequest:request];
    if([PPSessionManager getAccessToken]) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", [PPSessionManager getAccessToken]] forHTTPHeaderField:@"Authorization"];
    }
    return request;
}

+ (void)setHttpHeadersForRequest:(NSMutableURLRequest *)request {
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [request setValue:[NSString stringWithFormat:@"iOS %@", appVersion] forHTTPHeaderField:@"X-PooPing-Client"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
}

+ (void)updateRequestHeaderAccessToken:(NSMutableURLRequest*)request {
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [PPSessionManager getAccessToken]] forHTTPHeaderField:@"Authorization"];
}

+ (NSString*)urlStringForPath:(NSString*)path {
    return [NSString stringWithFormat:@"http://%@%@", HOSTNAME, path];;
}

// Copy of non-public function used by the AFNetworking library to do Base64 encoding
static NSString * PPAFBase64EncodedStringFromString(NSString *string)
{
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

@end
