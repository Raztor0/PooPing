#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPHomeViewController.h"
#import "PPNetworkClient.h"
#import "UIKit+PivotalSpecHelper.h"
#import "PPRatingViewController.h"
#import "PPPoopRating.h"


SPEC_BEGIN(PPHomeViewControllerSpec)

__block PPHomeViewController *subject;
__block id<BSInjector, BSBinder> injector;
__block PPNetworkClient *networkClient;
__block PPRatingViewController *ratingViewController;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    networkClient = [PPNetworkClient nullMock];
    [injector bind:[PPNetworkClient class] toInstance:networkClient];
    
    ratingViewController = [PPRatingViewController nullMock];
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

context(@"loginViewControllerDelegate", ^{
   describe(@"-userLoggedIn", ^{
      it(@"should tell the rating view controller to enable ratings", ^{
          [[subject.ratingViewController should] receive:@selector(enableRating)];
          [subject userLoggedIn];
      });
   });
});

SPEC_END