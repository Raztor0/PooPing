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

describe(@"-signUpWithEmail:username:password:", ^{
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

describe(@"-loginRequestForUsername:password:", ^{
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

SPEC_END