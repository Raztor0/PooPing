#import "Kiwi.h"
#import "Blindside.h"
#import "PPNetworking.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPSessionManager.h"
#import "PPUser.h"


SPEC_BEGIN(PPSessionManagerSpec)

__block id<BSInjector> injector;

beforeEach(^{
    injector = [Blindside injectorWithModule:[PPSpecModule new]];
});

context(@"current user", ^{
    __block PPUser *user;
    beforeEach(^{
        user = [PPUser nullMock];
    });
    
    context(@"setting and retreiving the current user", ^{
        it(@"should set the user", ^{
            [PPSessionManager setCurrentUser:user];
            [[[PPSessionManager getCurrentUser] should] equal:user];
        });
    });
    
    context(@"deleting the current user", ^{
        it(@"should delete the user", ^{
            [PPSessionManager setCurrentUser:user];
            [PPSessionManager deleteCurrentUser];
            [[[PPSessionManager getCurrentUser] should] beNil];
        });
    });
});

context(@"access token", ^{
    __block NSString *accessToken;
    beforeEach(^{
        accessToken = @"an access token";
    });
    
    context(@"setting and retreiving the access token", ^{
        it(@"should set the access token", ^{
            [PPSessionManager setAccessToken:accessToken];
            [[[PPSessionManager getAccessToken] should] equal:accessToken];
        });
    });
    
    context(@"deleting the access token", ^{
        it(@"should delete the access token", ^{
            [PPSessionManager setAccessToken:accessToken];
            [PPSessionManager deleteAccessToken];
            [[[PPSessionManager getAccessToken] should] beNil];
        });
    });
});

context(@"refresh token", ^{
    __block NSString *refreshToken;
    beforeEach(^{
        refreshToken = @"a refresh token";
    });
    
    context(@"setting and retreiving the refresh token", ^{
        it(@"should set the refresh token", ^{
            [PPSessionManager setRefreshToken:refreshToken];
            [[[PPSessionManager getRefreshToken] should] equal:refreshToken];
        });
    });
    
    context(@"deleting the refresh token", ^{
        it(@"should delete the refresh token", ^{
            [PPSessionManager setRefreshToken:refreshToken];
            [PPSessionManager deleteRefreshToken];
            [[[PPSessionManager getRefreshToken] should] beNil];
        });
    });
});

context(@"notification token", ^{
    __block NSString *notificationToken;
    beforeEach(^{
        notificationToken = @"a notification token";
    });
    
    context(@"setting and retreiving the notification token", ^{
        it(@"should set the notification token", ^{
            [PPSessionManager setNotificationToken:notificationToken];
            [[[PPSessionManager getNotificationToken] should] equal:notificationToken];
        });
    });
    
    context(@"deleting the notification token", ^{
        it(@"should delete the notification token", ^{
            [PPSessionManager setNotificationToken:notificationToken];
            [PPSessionManager deleteNotificationToken];
            [[[PPSessionManager getNotificationToken] should] beNil];
        });
    });
});

context(@"+deleteAllInfo", ^{
    beforeEach(^{
        [PPSessionManager setCurrentUser:[PPUser nullMock]];
        [PPSessionManager setAccessToken:@"access token"];
        [PPSessionManager setRefreshToken:@"refresh token"];
        [PPSessionManager setNotificationToken:@"notification token"];
        
        [[[PPSessionManager getCurrentUser] shouldNot] beNil];
        [[[PPSessionManager getAccessToken] shouldNot] beNil];
        [[[PPSessionManager getRefreshToken] shouldNot] beNil];
        [[[PPSessionManager getNotificationToken] shouldNot] beNil];
    });
    
    it(@"should delete everything", ^{
        [PPSessionManager deleteAllInfo];
        [[[PPSessionManager getCurrentUser] should] beNil];
        [[[PPSessionManager getAccessToken] should] beNil];
        [[[PPSessionManager getRefreshToken] should] beNil];
        [[[PPSessionManager getNotificationToken] should] beNil];
    });
});

SPEC_END