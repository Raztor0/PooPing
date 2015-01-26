#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "AppDelegate.h"
#import "PPHomeViewController.h"
#import "PPNetworkClient.h"
#import "PPSessionManager.h"
#import "PPInjectorKeys.h"


SPEC_BEGIN(AppDelegateSpec)

__block AppDelegate *subject;
__block id<BSInjector, BSBinder> injector;
__block PPNetworkClient *networkClient;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPModule new]];
    networkClient = [PPNetworkClient nullMock];
    
    [injector bind:PPSharedNetworkClient toInstance:networkClient];
    
    subject = [[AppDelegate alloc] init];
    [subject stub:@selector(injector) andReturn:injector];
    [subject application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];
});

describe(@"PPMenuViewControllerDelegate", ^{
    describe(@"-didTapLogout", ^{
        it(@"should tell the network client to logout", ^{
            [[networkClient should] receive:@selector(logout)];
            [subject didTapLogout];
        });
        
        it(@"should tell the home view controller to bring up the login view", ^{
            [[subject.rootViewController should] receive:@selector(showLoginViewAnimated:)];
            [subject didTapLogout];
        });
        
        it(@"should tell the PPSessionManager to delete all info", ^{
            [[PPSessionManager should] receive:@selector(deleteAllInfo)];
            [subject didTapLogout];
        });
    });
    
    describe(@"-didTapRecentPings", ^{
        it(@"should tell the home view controller to bring up the recent pings view", ^{
            [[subject.rootViewController should] receive:@selector(showRecentPingsView)];
            [subject didTapRecentPings];
        });
    });
    
    describe(@"-didTapPooPals", ^{
       it(@"should tell the home view controller to bring up the PooPals view", ^{
           [[subject.rootViewController should] receive:@selector(showPooPalsView)];
           [subject didTapPooPals];
       });
    });
});

SPEC_END