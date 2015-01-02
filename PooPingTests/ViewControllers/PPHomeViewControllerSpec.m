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
    [injector bind:[PPNetworkClient class] toInstance:networkClient];
    
    ratingViewController = [PPRatingViewController nullMock];
    
    recentPingsViewController = [injector getInstance:[PPRecentPingsViewController class]];
    [injector bind:[PPRecentPingsViewController class] toInstance:recentPingsViewController];
    
    currentUser = [PPUser nullMock];
    [PPSessionManager stub:@selector(getCurrentUser) andReturn:currentUser];
    
    subject = [injector getInstance:[PPHomeViewController class]];
    [subject viewDidLoad];
    subject.ratingViewController = ratingViewController;
});

describe(@"tapping the ping button", ^{
    beforeEach(^{
        [ratingViewController stub:@selector(difficulty) andReturn:theValue(1)];
        [ratingViewController stub:@selector(smell) andReturn:theValue(2)];
        [ratingViewController stub:@selector(relief) andReturn:theValue(3)];
        [ratingViewController stub:@selector(size) andReturn:theValue(4)];
        [ratingViewController stub:@selector(overall) andReturn:theValue(5)];
        
        UIAlertView *commentAlertView = [UIAlertView nullMock];
        UITextField *commentTextField = [UITextField nullMock];
        [commentTextField stub:@selector(text) andReturn:@"a comment"];
        [commentAlertView stub:@selector(textFieldAtIndex:) andReturn:commentTextField];
        [subject alertView:commentAlertView didDismissWithButtonIndex:0];
    });
    
    it(@"should tell the network client to post a ping", ^{
        [[networkClient should] receive:@selector(postPooPingWithPoopRating:)];
        [subject.pooPingButton tap];
    });
    
    it(@"should post with the appropriate rating", ^{
        [networkClient stub:@selector(postPooPingWithPoopRating:) withBlock:^id(NSArray *params) {
            PPPoopRating *rating = [params objectAtIndex:0];
            [[theValue(rating.difficulty) should] equal:theValue(1)];
            [[theValue(rating.smell) should] equal:theValue(2)];
            [[theValue(rating.relief) should] equal:theValue(3)];
            [[theValue(rating.size) should] equal:theValue(4)];
            [[theValue(rating.overall) should] equal:theValue(5)];
            [[rating.comment should] equal:@"a comment"];
            return nil;
        }];
        [subject.pooPingButton tap];
    });
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

describe(@"-showRecentPingsForPoopalsView", ^{
    __block NSArray *friends;
    beforeEach(^{
        friends = [NSArray new];
        [currentUser stub:@selector(friends) andReturn:friends];
    });
    
    it(@"should call setupWithUsers: on the recent pings view controller", ^{
        [[recentPingsViewController should] receive:@selector(setupWithUsers:) withArguments:friends];
        [subject showRecentPingsForPoopalsView];
    });
    
    it(@"should display a PPRecentPingsViewController", ^{
        [subject showRecentPingsForPoopalsView];
        [[[(UINavigationController*)[subject presentedViewController] topViewController]should] beKindOfClass:[PPRecentPingsViewController class]];
    });
});

context(@"loginViewControllerDelegate", ^{
    describe(@"-userLoggedIn", ^{
        beforeEach(^{
            UIAlertView *commentAlertView = [UIAlertView nullMock];
            UITextField *commentTextField = [UITextField nullMock];
            [commentTextField stub:@selector(text) andReturn:@"a comment"];
            [commentAlertView stub:@selector(textFieldAtIndex:) andReturn:commentTextField];
            [subject alertView:commentAlertView didDismissWithButtonIndex:0];
        });
        
        it(@"should tell the rating view controller to enable ratings", ^{
            [[subject.ratingViewController should] receive:@selector(enableRating)];
            [subject userLoggedIn];
        });
        
        it(@"should tell the rating view controller to reset ratings", ^{
            [[subject.ratingViewController should] receive:@selector(clearRating)];
            [subject userLoggedIn];
        });
        
        it(@"should clear the comment", ^{
            [subject userLoggedIn];
            [[subject.poopComment should] equal:@""];
        });
    });
});

SPEC_END