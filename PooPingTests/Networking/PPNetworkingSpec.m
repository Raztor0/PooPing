#import "Kiwi.h"
#import "Blindside.h"
#import "PPNetworking.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "NSDictionary+QueryString.h"

#import <AFNetworking/AFNetworking.h>
#import "KSPromise.h"
#import "KSDeferred.h"
#import "PPSessionManager.h"
#import "PPPoopRating.h"
#import "PPUser.h"

SPEC_BEGIN(PPNetworkingSpec)
__block id<BSInjector, BSBinder> injector;
__block AFHTTPRequestOperationManager *manager;
__block NSURL *baseUrl;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    baseUrl = [NSURL URLWithString:@"http://api.example.com"];
    
    manager = [AFHTTPRequestOperationManager nullMock];
    [manager stub:@selector(baseURL) andReturn:baseUrl];
    [[PPNetworking class] stub:@selector(requestOperationManager) andReturn:manager];
});

describe(@"+signUpWithEmail:username:password:", ^{
    __block NSString *email;
    __block NSString *username;
    __block NSString *password;
    
    beforeEach(^{
        email = @"email@example.com";
        username = @"username";
        password = @"password";
    });
    
    it(@"should set up the network request", ^{
        [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
            NSURLRequest *request = [params objectAtIndex:0];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"Accept"] should] equal:@"application/json"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/x-www-form-urlencoded"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldNot] beNil];
            
            NSDictionary *query = [NSDictionary dictionaryWithQueryString:request.URL.query];
            [[theValue(query.count) should] equal:theValue(3)];
            
            [[[query objectForKey:@"email"] should] equal:email];
            [[[query objectForKey:@"username"] should] equal:username];
            [[[query objectForKey:@"password"] should] equal:password];
            
            [[[request.URL lastPathComponent] should] equal:@"register"];
            return nil;
        }];
        
        [PPNetworking signUpWithEmail:email username:username password:password];
    });
    
    context(@"on success", ^{
        __block AFHTTPRequestOperation *operation;
        __block NSDictionary *response;
        beforeEach(^{
            operation = [AFHTTPRequestOperation nullMock];
            response = @{
                         @"status" : @"success"
                         };
        });
        
        it(@"should resolve the promise with the json returned from the server", ^{
            __block void(^successBlock)(AFHTTPRequestOperation *, id);
            [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
                successBlock = [params objectAtIndex:1];
                return nil;
            }];
            
            KSPromise *promise = [PPNetworking signUpWithEmail:email username:username password:password];
            
            [[promise should] receive:@selector(resolveWithValue:) withArguments:response];
            
            successBlock(operation, response);
        });
    });
    
    context(@"on failure", ^{
        __block AFHTTPRequestOperation *operation;
        __block NSError *error;
        beforeEach(^{
            operation = [AFHTTPRequestOperation nullMock];
            error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
        });
        
        it(@"should reject the promise with the error returned from the server", ^{
            __block void(^errorBlock)(AFHTTPRequestOperation *, NSError *);
            [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
                errorBlock = [params objectAtIndex:2];
                return nil;
            }];
            
            KSPromise *promise = [PPNetworking signUpWithEmail:email username:username password:password];
            
            [[promise should] receive:@selector(rejectWithError:) withArguments:error];
            
            errorBlock(operation, error);
        });
    });
});

describe(@"+loginRequestForUsername:password:", ^{
    __block NSString *username;
    __block NSString *password;
    
    __block PPSessionManager *sessionManager;
    
    beforeEach(^{
        username = @"username";
        password = @"password";
        
        sessionManager = [PPSessionManager nullMock];
        [PPSessionManager stub:@selector(class) andReturn:sessionManager];
    });
    
    it(@"should set up the network request", ^{
        [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
            NSURLRequest *request = [params objectAtIndex:0];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"Accept"] should] equal:@"application/json"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/x-www-form-urlencoded"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldNot] beNil];
            
            NSDictionary *body = [NSDictionary dictionaryWithQueryString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
            
            [[theValue(body.count) should] equal:theValue(3)];
            
            [[[body objectForKey:@"grant_type"] should] equal:@"password"];
            [[[body objectForKey:@"username"] should] equal:username];
            [[[body objectForKey:@"password"] should] equal:password];
            
            [[[request.URL lastPathComponent] should] equal:@"token"];
            return nil;
        }];
        
        [PPNetworking loginRequestForUsername:username password:password];
    });
});

describe(@"+logout", ^{
    context(@"when there is a notification token", ^{
        beforeAll(^{
            [PPSessionManager stub:@selector(getNotificationToken) andReturn:@"a token"];
        });
        
        it(@"should set up the network request with the token in the body", ^{
            [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
                NSURLRequest *request = [params objectAtIndex:0];
                
                [[[[request allHTTPHeaderFields] objectForKey:@"Accept"] should] equal:@"application/json"];
                [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/x-www-form-urlencoded"];
                [[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldNot] beNil];
                
                NSDictionary *body = [NSDictionary dictionaryWithQueryString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
                
                [[theValue(body.count) should] equal:theValue(1)];
                
                [[[body objectForKey:@"notification_token"] should] equal:@"a token"];
                
                [[[request.URL lastPathComponent] should] equal:@"logout"];
                return nil;
            }];
            
            [PPNetworking logout];
        });
    });
    
    context(@"when there is no notification token", ^{
        beforeAll(^{
            [PPSessionManager stub:@selector(getNotificationToken) andReturn:nil];
        });
        
        it(@"should set up the network request without a token in the body", ^{
            [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
                NSURLRequest *request = [params objectAtIndex:0];
                
                [[[[request allHTTPHeaderFields] objectForKey:@"Accept"] should] equal:@"application/json"];
                [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/x-www-form-urlencoded"];
                [[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldNot] beNil];
                
                NSDictionary *body = [NSDictionary dictionaryWithQueryString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
                
                [[theValue(body.count) should] equal:theValue(0)];
                
                [[[request.URL lastPathComponent] should] equal:@"logout"];
                return nil;
            }];
            
            [PPNetworking logout];
        });
    });
});

describe(@"+postPooPingWithPoopRating:", ^{
    __block PPPoopRating *rating;
    beforeEach(^{
        rating = [injector getInstance:[PPPoopRating class]];
        [rating setupWithDifficulty:1 smell:2 relief:3 size:4 overall:5];
    });
    
    it(@"should set up the network request with all the ratings in the body", ^{
        [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
            NSURLRequest *request = [params objectAtIndex:0];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"Accept"] should] equal:@"application/json"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/x-www-form-urlencoded"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldNot] beNil];
            
            NSDictionary *body = [NSDictionary dictionaryWithQueryString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
            
            [[theValue(body.count) should] equal:theValue(5)];
            
            [[[body objectForKey:@"difficulty"] should] equal:@"1"];
            [[[body objectForKey:@"smell"] should] equal:@"2"];
            [[[body objectForKey:@"relief"] should] equal:@"3"];
            [[[body objectForKey:@"size"] should] equal:@"4"];
            [[[body objectForKey:@"overall"] should] equal:@"5"];
            
            [[[request.URL lastPathComponent] should] equal:@"ping"];
            return nil;
        }];
        
        [PPNetworking postPooPingWithPoopRating:rating];
    });
});

describe(@"+postFriendRequestForUser:", ^{
    __block NSString *friend;
    beforeEach(^{
        friend = @"my_friend";
    });
    
    it(@"should set up the network request with all the ratings in the body", ^{
        [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
            NSURLRequest *request = [params objectAtIndex:0];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"Accept"] should] equal:@"application/json"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/x-www-form-urlencoded"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldNot] beNil];
            
            NSDictionary *body = [NSDictionary dictionaryWithQueryString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
            
            [[theValue(body.count) should] equal:theValue(1)];
            
            [[[body objectForKey:@"username"] should] equal:friend];
            
            [[[request.URL lastPathComponent] should] equal:@"friends"];
            return nil;
        }];
        
        [PPNetworking postFriendRequestForUser:friend];
    });
});

describe(@"+getCurrentUser", ^{
    it(@"should set up the network request with all the ratings in the body", ^{
        [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
            NSURLRequest *request = [params objectAtIndex:0];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"Accept"] should] equal:@"application/json"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/x-www-form-urlencoded"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldNot] beNil];
            
            [[[request.URL lastPathComponent] should] equal:@"me"];
            return nil;
        }];
        
        [PPNetworking getCurrentUser];
    });
    
    context(@"on success", ^{
        __block void(^successBlock)(AFHTTPRequestOperation *, id);
        __block NSDictionary *userJson;
        beforeEach(^{
            userJson = @{
                         @"username" : @"a user",
                         @"friends" : @[],
                         };
            
            [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
                successBlock = [params objectAtIndex:1];
                return nil;
            }];
        });
        
        it(@"should set the current users in the session manager", ^{
            [PPNetworking getCurrentUser];
            successBlock(nil, userJson);
            PPUser *currentUser = [PPSessionManager getCurrentUser];
            [[currentUser.username should] equal:@"a user"];
            [[currentUser.friends should] equal:@[]];
        });
    });
});

describe(@"+deleteFriend", ^{
    __block NSString *friendToDelete;
    beforeEach(^{
        friendToDelete = @"you";
    });
    
    it(@"should set up the network request with the friend's username in the body", ^{
        [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
            NSURLRequest *request = [params objectAtIndex:0];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"Accept"] should] equal:@"application/json"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/x-www-form-urlencoded"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldNot] beNil];
            
            NSDictionary *body = [NSDictionary dictionaryWithQueryString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
            
            [[[body objectForKey:@"username"] should] equal:friendToDelete];
            
            [[[request.URL lastPathComponent] should] equal:@"friends"];
            return nil;
        }];
        
        [PPNetworking deleteFriend:friendToDelete];
    });
});

describe(@"+postNotificationToken:", ^{
    __block NSString *token;
    beforeEach(^{
        token = @"a notification token";
    });
    
    it(@"should set up the network request with the friend's username in the body", ^{
        [manager stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
            NSURLRequest *request = [params objectAtIndex:0];
            
            [[[[request allHTTPHeaderFields] objectForKey:@"Accept"] should] equal:@"application/json"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Content-Type"] should] equal:@"application/x-www-form-urlencoded"];
            [[[[request allHTTPHeaderFields] objectForKey:@"Authorization"] shouldNot] beNil];
            
            NSDictionary *body = [NSDictionary dictionaryWithQueryString:[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
            
            [[[body objectForKey:@"notification_token"] should] equal:token];
            
            [[[request.URL lastPathComponent] should] equal:@"notifications"];
            return nil;
        }];
        
        [PPNetworking postNotificationToken:token];
    });
});

SPEC_END