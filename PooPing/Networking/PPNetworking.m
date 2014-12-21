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

@implementation PPNetworking

+ (KSPromise*)loginRequestForUsername:(NSString*)username password:(NSString*)password {
    NSDictionary *body = @{
                           @"grant_type" : PPNetworkingGrantType.password,
                           @"username" : username,
                           @"password" : password,
                           };
    NSMutableURLRequest *request = [self tokenPostURLRequestWithAdditionalBodyParameters:body];
    KSPromise *promise = [self promiseForRequest:request];
    [promise then:^id(NSDictionary *json) {
        NSString *accessToken = [json objectForKey:PPSessionManagerKeys.accessToken];
        NSString *refreshToken = [json objectForKey:PPSessionManagerKeys.refreshToken];
        
        [PPSessionManager setUsername:username];
        [PPSessionManager setAccessToken:accessToken];
        [PPSessionManager setRefreshToken:refreshToken];
        return json;
    } error:^id(NSError *error) {
        return error;
    }];
    return promise;
}

+ (KSPromise*)refreshToken {
    NSDictionary *body = @{
                           @"grant_type" : PPNetworkingGrantType.refreshToken,
                           @"refresh_token" : [PPSessionManager getRefreshToken],
                           };
    NSMutableURLRequest *request = [self tokenPostURLRequestWithAdditionalBodyParameters:body];
    KSPromise *promise = [self promiseForRequest:request];
    [promise then:^id(NSDictionary *json) {
        NSString *accessToken = [json objectForKey:PPSessionManagerKeys.accessToken];
        NSString *refreshToken = [json objectForKey:PPSessionManagerKeys.refreshToken];
        
        [PPSessionManager setAccessToken:accessToken];
        [PPSessionManager setRefreshToken:refreshToken];
        return json;
    } error:^id(NSError *error) {
        return error;
    }];
    return promise;
}

+ (KSPromise*)postPooPing {
    NSMutableURLRequest *request = [self pingPostURLRequestWithAddtionalBodyParameters:@{
                                                                                         @"access_token" : [PPSessionManager getAccessToken],
                                                                                         }];
    KSPromise *promise = [self promiseForRequest:request];
    return promise;
}

#pragma mark - Private

+ (KSPromise*)promiseForRequest:(NSMutableURLRequest*)request {
    __block KSDeferred *deferred = [KSDeferred defer];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *json) {
        [deferred resolveWithValue:json];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey]) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableContainers error:nil];
            NSString *errorString = [response objectForKey:@"error"];
            if ([errorString isEqualToString:PPNetworkingErrorType.expiredToken]) {
                [[self refreshToken] then:^id(id value) {
                    [self updateRequestBodyAccessToken:request];
                    [deferred resolveWithValue:[self promiseForRequest:request]];
                    return value;
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
    }];
    [op start];
    return deferred.promise;
}

+ (NSMutableURLRequest*)pingPostURLRequestWithAddtionalBodyParameters:(NSDictionary*)bodyParams {
    NSMutableURLRequest *request = [self postURLRequestWithEndpoint:@"/ping.php"];
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

+ (NSMutableURLRequest*)postURLRequestWithEndpoint:(NSString*)endpoint {
    NSString *urlString = [self urlStringForPath:endpoint];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    return request;
}

+ (NSString*)urlStringForPath:(NSString*)path {
    return [NSString stringWithFormat:@"http://%@/%@", HOSTNAME, path];;
}

+ (void)updateRequestBodyAccessToken:(NSMutableURLRequest*)request {
    NSMutableDictionary *body = [[NSDictionary dictionaryWithQueryString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]] mutableCopy];
    if([body objectForKey:@"access_token"]) {
        [body setObject:[PPSessionManager getAccessToken] forKey:@"access_token"];
    }
    [request setHTTPBody:[[body queryStringValue] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
