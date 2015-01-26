#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPHomeViewController.h"
#import "PPNetworkClient.h"
#import "UIKit+PivotalSpecHelper.h"
#import "PPRatingViewController.h"
#import "PPPoopRating.h"
#import "PPRecentPingsViewController.h"
#import "PPUser.h"
#import "PPSessionManager.h"
#import "NSString+Emojize.h"
#import "PPFriendsListViewController.h"
#import "PPInjectorKeys.h"


SPEC_BEGIN(PPHomeViewControllerSpec)

__block PPHomeViewController *subject;
__block id<BSInjector, BSBinder> injector;
__block PPNetworkClient *networkClient;
__block PPRatingViewController *ratingViewController;
__block PPRecentPingsViewController *recentPingsViewController;
__block PPUser *currentUser;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    networkClient = [PPNetworkClient nullMock];
    [injector bind:PPSharedNetworkClient toInstance:networkClient];
    
    ratingViewController = [PPRatingViewController nullMock];
    
    recentPingsViewController = [injector getInstance:[PPRecentPingsViewController class]];
    [injector bind:[PPRecentPingsViewController class] toInstance:recentPingsViewController];
    
    currentUser = [PPUser nullMock];
    [currentUser stub:@selector(username) andReturn:@"some user"];
    [PPSessionManager stub:@selector(getCurrentUser) andReturn:currentUser];
    
    subject = [injector getInstance:[PPHomeViewController class]];
    [subject viewDidLoad];
    subject.ratingViewController = ratingViewController;
});

context(@"-showLoginViewAnimated:", ^{
    beforeEach(^{
        [subject showLoginViewAnimated:NO];
    });
    
    it(@"should display a PPLoginViewController", ^{
        [[[subject presentedViewController] should] beKindOfClass:[PPLoginViewController class]];
    });
});

context(@"-showRecentPingsView", ^{
    it(@"should call setupWithUsers: on the recent pings view controller", ^{
        [[recentPingsViewController should] receive:@selector(setupWithUsers:) withArguments:@[currentUser]];
        [subject showRecentPingsView];
    });
    
    it(@"should display a PPRecentPingsViewController", ^{
        [subject showRecentPingsView];
        [[[(UINavigationController*)[subject presentedViewController] topViewController]should] beKindOfClass:[PPRecentPingsViewController class]];
    });
});

describe(@"-showPooPalsView", ^{
    it(@"should display a PPFriendsListViewController", ^{
        [subject showPooPalsView];
        [[[(UINavigationController*)[subject presentedViewController] topViewController]should] beKindOfClass:[PPFriendsListViewController class]];
    });
});

describe(@"Tapping the PooPing bar button item", ^{
    it(@"should display a PPRatingViewController", ^{
        [[subject.navigationItem rightBarButtonItem] tap];
        [[[(UINavigationController*)[subject presentedViewController] topViewController]should] beKindOfClass:[PPRatingViewController class]];
    });
});

context(@"loginViewControllerDelegate", ^{
    describe(@"-userLoggedIn", ^{
        it(@"should tell the rating view controller to enable ratings", ^{
            [[subject.ratingViewController should] receive:@selector(enableRating)];
            [subject userLoggedIn];
        });
        
        it(@"should tell the rating view controller to reset the ping", ^{
            [[subject.ratingViewController should] receive:@selector(resetPing)];
            [subject userLoggedIn];
        });
    });
});

context(@"getting a user refresh notification", ^{
    it(@"should refresh the recent pings view controller", ^{
        [[recentPingsViewController should] receive:@selector(setupWithUsers:) withCountAtLeast:1];
        [[NSNotificationCenter defaultCenter] postNotificationName:PPNetworkClientUserRefreshNotification object:nil];
    });
});

SPEC_END