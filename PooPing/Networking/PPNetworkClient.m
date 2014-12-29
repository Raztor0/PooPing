//
//  PPNetworking.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPNetworkClient.h"
#import "AFNetworking.h"
#import "KSDeferred.h"
#import "PPSessionManager.h"
#import "NSDictionary+QueryString.h"
#import "PPUser.h"
#import "PPPoopRating.h"

#ifdef DEBUG
#define CLIENT_ID @"testclient"
#define CLIENT_SECRET @"testpass"
#else
#define CLIENT_ID @"b3c95b2fac296e9e8cd155b62360f82ce9eaf79af159df7bbd3a4dc1e07479dc"
#define CLIENT_SECRET @"6585be7004e547009133b7b49cdd9e2d5aaf7a397bf0d7f0ac3f968f91dcaa3a"
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

const struct PPNetworkingEndpoints {
    __unsafe_unretained NSString *signup;
    __unsafe_unretained NSString *token;
    __unsafe_unretained NSString *me;
    __unsafe_unretained NSString *ping;
    __unsafe_unretained NSString *notifications;
    __unsafe_unretained NSString *friends;
    __unsafe_unretained NSString *logout;
} PPNetworkingEndpoints;

const struct PPNetworkingEndpoints PPNetworkingEndpoints = {
    .signup = @"/register",
    .token = @"/token",
    .me = @"/me",
    .ping = @"/ping",
    .notifications = @"/notifications",
    .friends = @"/friends",
    .logout = @"/logout",
};

NSString * PPNetworkingInvalidTokenNotification = @"invalid_token_notification";
NSString * PPNetworkingUserRefreshNotification = @"user_refresh_notification";

@interface PPNetworkClient()

@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

@end

@implementation PPNetworkClient

+ (BSInitializer *)bsInitializer {
    BSInitializer *initializer = [BSInitializer initializerWithClass:[self class]
                                                            selector:@selector(initWithOperationManager:)
                                                        argumentKeys:[AFHTTPRequestOperationManager class], nil];
    return initializer;
}

- (instancetype)initWithOperationManager:(AFHTTPRequestOperationManager*)operationManager {
    self = [super init];
    
    if(self) {
        self.operationManager = operationManager;
    }
    
    return self;
}

#pragma mark - Public

- (KSPromise *)signUpWithEmail:(NSString *)email username:(NSString*)username password:(NSString *)password {
    return [self promisePOSTForEndpoint:PPNetworkingEndpoints.signup
                        withQueryParams:@{
                                          @"email" : email,
                                          @"username" : username,
                                          @"password" : password,
                                          }
                      additionalHeaders:nil
                                andBody:nil];
}

- (KSPromise*)loginRequestForUsername:(NSString*)username password:(NSString*)password {
    return [[self promiseAUTHForEndpoint:PPNetworkingEndpoints.token withUsername:username password:password] then:^id(NSDictionary *json) {
        NSString *accessToken = [json objectForKey:PPSessionManagerKeys.accessToken];
        NSString *refreshToken = [json objectForKey:PPSessionManagerKeys.refreshToken];
        
        [PPSessionManager setAccessToken:accessToken];
        [PPSessionManager setRefreshToken:refreshToken];
        return json;
    } error:^id(NSError *error) {
        return error;
    }];
}

- (KSPromise*)logout {
    if([PPSessionManager getNotificationToken]) {
        return [self promisePOSTForEndpoint:PPNetworkingEndpoints.logout
                            withQueryParams:nil
                          additionalHeaders:nil
                                    andBody:@{
                                              @"notification_token" : [PPSessionManager getNotificationToken]
                                              }];
    } else {
        return [self promisePOSTForEndpoint:PPNetworkingEndpoints.logout
                            withQueryParams:nil
                          additionalHeaders:nil
                                    andBody:nil];
    }
}

- (KSPromise*)refreshToken {
    return [[self promiseRefreshTokenForEndpoint:PPNetworkingEndpoints.token] then:^id(NSDictionary *json) {
        NSString *accessToken = [json objectForKey:PPSessionManagerKeys.accessToken];
        NSString *refreshToken = [json objectForKey:PPSessionManagerKeys.refreshToken];
        [PPSessionManager setAccessToken:accessToken];
        [PPSessionManager setRefreshToken:refreshToken];
        return json;
    } error:nil];
}

- (KSPromise*)getCurrentUser {
    return [[self promiseGETForEndpoint:PPNetworkingEndpoints.me] then:^id(NSDictionary *json) {
        PPUser *user = [PPUser userFromDictionary:json];
        [PPSessionManager setCurrentUser:user];
        [[NSNotificationCenter defaultCenter] postNotificationName:PPNetworkingUserRefreshNotification object:user];
        return json;
    } error:^id(NSError *error) {
        NSLog(@"get current user error: %@", error);
        return error;
    }];
}

- (KSPromise*)postPooPingWithPoopRating:(PPPoopRating *)rating {
    return [self promisePOSTForEndpoint:PPNetworkingEndpoints.ping
                        withQueryParams:nil
                      additionalHeaders:nil
                                andBody:@{
                                          @"difficulty" : [@(rating.difficulty) stringValue],
                                          @"smell" : [@(rating.smell) stringValue],
                                          @"relief" : [@(rating.relief) stringValue],
                                          @"size" : [@(rating.size) stringValue],
                                          @"overall" : [@(rating.overall) stringValue],
                                          }];
}

- (KSPromise*)postFriendRequestForUser:(NSString*)userName {
    return [[self promisePOSTForEndpoint:PPNetworkingEndpoints.friends
                         withQueryParams:nil
                       additionalHeaders:nil
                                 andBody:@{
                                           @"username" : userName,
                                           }]
            then:^id(id value) {
                [self getCurrentUser];
                return value;
            } error:nil];
}

- (KSPromise*)deleteFriend:(NSString*)username {
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

- (KSPromise *)postNotificationToken:(NSString *)token {
    return [self promisePOSTForEndpoint:PPNetworkingEndpoints.notifications
                        withQueryParams:nil
                      additionalHeaders:nil
                                andBody:@{
                                          @"notification_token" : token,
                                          }];
}

#pragma mark - Private

- (KSPromise*)promiseAUTHForEndpoint:(NSString*)endpoint withUsername:(NSString*)username password:(NSString*)password {
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

- (KSPromise*)promiseRefreshTokenForEndpoint:(NSString*)endpoint {
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

- (KSPromise*)promisePOSTForEndpoint:(NSString*)endpoint withQueryParams:(NSDictionary*)queryParams additionalHeaders:(NSDictionary*)additionalHeaders andBody:(NSDictionary*)body {
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

- (KSPromise*)promiseGETForEndpoint:(NSString*)endpoint {
    NSMutableURLRequest *request = [self getURLRequestWithEndpoint:endpoint];
    return [self promiseForRequest:request];
}

- (KSPromise*)promiseForRequest:(NSMutableURLRequest*)request {
    __block KSDeferred *deferred = [KSDeferred defer];
    
    [[self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                        [self showDebugAlertviewForError:error];
                        [deferred rejectWithError:error];
                        return error;
                    }];
                    return promise;
                } error:^id(NSError *error) {
                    [self showDebugAlertviewForError:error];
                    [deferred rejectWithError:error];
                    return error;
                }];
            } else if([errorString isEqualToString:PPNetworkingErrorType.invalidToken]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PPNetworkingInvalidTokenNotification object:nil];
                [PPSessionManager deleteAllInfo];
                [deferred rejectWithError:error];
            } else {
                [self showDebugAlertviewForError:error];
                [deferred rejectWithError:error];
            }
        } else {
            [self showDebugAlertviewForError:error];
            [deferred rejectWithError:error];
        }
    }] start];
    
    return deferred.promise;
}

- (NSMutableURLRequest*)getCurrentUserRequestWithAddtionalQueryParameters:(NSDictionary*)headerParams {
    NSMutableURLRequest *request = [self getURLRequestWithEndpoint:[NSString stringWithFormat:@"%@?%@", PPNetworkingEndpoints.me, [headerParams queryStringValue]]];
    return request;
}

- (NSMutableURLRequest*)pingPostURLRequestWithAddtionalBodyParameters:(NSDictionary*)bodyParams {
    NSMutableURLRequest *request = [self postURLRequestWithEndpoint:PPNetworkingEndpoints.ping];
    [request setHTTPBody:[[bodyParams queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (NSMutableURLRequest*)addFriendPostURLRequestWithAdditionalBodyParameters:(NSDictionary*)bodyParams {
    NSMutableURLRequest *request = [self postURLRequestWithEndpoint:PPNetworkingEndpoints.friends];
    [request setHTTPBody:[[bodyParams queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (NSMutableURLRequest*)removeFriendDeleteURLRequestWithAdditionalBodyParameters:(NSDictionary*)bodyParams {
    NSMutableURLRequest *request = [self deleteURLRequestWithEndpoint:PPNetworkingEndpoints.friends];
    [request setHTTPBody:[[bodyParams queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (NSMutableURLRequest*)tokenPostURLRequestWithAdditionalBodyParameters:(NSDictionary*)bodyParams {
    NSMutableDictionary *bodyDictionary = [NSMutableDictionary dictionaryWithDictionary:bodyParams];
    [bodyDictionary addEntriesFromDictionary:@{
                                               @"client_id" : CLIENT_ID,
                                               @"client_secret" : CLIENT_SECRET
                                               }];
    NSMutableURLRequest *request = [self postURLRequestWithEndpoint:PPNetworkingEndpoints.token];
    [request setHTTPBody:[[bodyDictionary queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (NSMutableURLRequest*)getURLRequestWithEndpoint:(NSString*)endpoint {
    NSMutableURLRequest *request = [self requestForEndpoint:endpoint withType:@"GET"];
    return request;
}

- (NSMutableURLRequest*)postURLRequestWithEndpoint:(NSString*)endpoint {
    NSMutableURLRequest *request = [self requestForEndpoint:endpoint withType:@"POST"];
    return request;
}

- (NSMutableURLRequest*)deleteURLRequestWithEndpoint:(NSString*)endpoint {
    NSMutableURLRequest *request = [self requestForEndpoint:endpoint withType:@"DELETE"];
    return request;
}

- (NSMutableURLRequest*)requestForEndpoint:(NSString*)endpoint withType:(NSString*)type {
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

- (void)setHttpHeadersForRequest:(NSMutableURLRequest *)request {
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [request setValue:[NSString stringWithFormat:@"iOS %@", appVersion] forHTTPHeaderField:@"X-PooPing-Client"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
}

- (void)updateRequestHeaderAccessToken:(NSMutableURLRequest*)request {
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [PPSessionManager getAccessToken]] forHTTPHeaderField:@"Authorization"];
}

- (NSString*)urlStringForPath:(NSString*)path {
    NSString *baseURL = [[self.operationManager baseURL] absoluteString];
    return [NSString stringWithFormat:@"%@%@", baseURL, path];;
}

- (void)showDebugAlertviewForError:(NSError*)error {
#ifdef DEBUG
    [[[UIAlertView alloc] initWithTitle:@"error" message:error.description delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
#endif
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
