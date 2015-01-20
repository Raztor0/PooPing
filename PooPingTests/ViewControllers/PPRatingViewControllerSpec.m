#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPRatingViewController.h"
#import "UIKit+PivotalSpecHelper.h"
#import "PPNetworkClient.h"
#import "PPPoopRating.h"
#import "NSString+Emojize.h"
#import "KSPromise.h"
#import "KSDeferred.h"

SPEC_BEGIN(PPRatingViewControllerSpec)

__block PPRatingViewController *subject;
__block id<BSInjector, BSBinder> injector;
__block PPNetworkClient *networkClient;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    networkClient = [PPNetworkClient nullMock];
    [injector bind:[PPNetworkClient class] toInstance:networkClient];
    
    subject = [injector getInstance:[PPRatingViewController class]];
    [subject view];
});

describe(@"pressing up buttons", ^{
    describe(@"once", ^{
        beforeEach(^{
            for(UIButton *upButton in subject.upButtons) {
                [upButton tap];
            }
        });
        
        it(@"should raise all ratings up by 1", ^{
            [[theValue(subject.difficulty) should] equal:theValue(1)];
            [[theValue(subject.smell) should] equal:theValue(1)];
            [[theValue(subject.relief) should] equal:theValue(1)];
            [[theValue(subject.size) should] equal:theValue(1)];
            [[theValue(subject.overall) should] equal:theValue(1)];
        });
    });
    
    describe(@"more than 5 times", ^{
        beforeEach(^{
            for(UIButton *upButton in subject.upButtons) {
                for(int i = 0; i < 6; i++) {
                    [upButton tap];
                }
            }
        });
        
        it(@"should cap the rating limit at 5", ^{
            [[theValue(subject.difficulty) should] equal:theValue(5)];
            [[theValue(subject.smell) should] equal:theValue(5)];
            [[theValue(subject.relief) should] equal:theValue(5)];
            [[theValue(subject.size) should] equal:theValue(5)];
            [[theValue(subject.overall) should] equal:theValue(5)];
        });
    });
});

describe(@"pressing down buttons", ^{
    beforeEach(^{
        for(UIButton *upButton in subject.upButtons) {
            for(int i = 0; i < 5; i++) {
                [upButton tap];
            }
        }
    });
    
    describe(@"once", ^{
        beforeEach(^{
            for(UIButton *downButton in subject.downButtons) {
                [downButton tap];
            }
        });
        
        it(@"should lower all ratings down by 1", ^{
            [[theValue(subject.difficulty) should] equal:theValue(4)];
            [[theValue(subject.smell) should] equal:theValue(4)];
            [[theValue(subject.relief) should] equal:theValue(4)];
            [[theValue(subject.size) should] equal:theValue(4)];
            [[theValue(subject.overall) should] equal:theValue(4)];
        });
    });
    
    describe(@"more than 5 times", ^{
        beforeEach(^{
            for(UIButton *downButton in subject.downButtons) {
                for(int i = 0; i < 6; i++) {
                    [downButton tap];
                }
            }
        });
        
        it(@"should cap the rating limit at 0", ^{
            [[theValue(subject.difficulty) should] equal:theValue(0)];
            [[theValue(subject.smell) should] equal:theValue(0)];
            [[theValue(subject.relief) should] equal:theValue(0)];
            [[theValue(subject.size) should] equal:theValue(0)];
            [[theValue(subject.overall) should] equal:theValue(0)];
        });
    });
});

describe(@"tapping the ping button", ^{
    beforeEach(^{
        [subject stub:@selector(difficulty) andReturn:theValue(1)];
        [subject stub:@selector(smell) andReturn:theValue(2)];
        [subject stub:@selector(relief) andReturn:theValue(3)];
        [subject stub:@selector(size) andReturn:theValue(4)];
        [subject stub:@selector(overall) andReturn:theValue(5)];
        
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
    
    it(@"should dismiss itself upon success", ^{
        KSDeferred *deferred = [KSDeferred defer];
        [networkClient stub:@selector(postPooPingWithPoopRating:) andReturn:deferred.promise];
        [subject.pooPingButton tap];
        [[subject should] receive:@selector(dismissViewControllerAnimated:completion:)];
        [deferred resolveWithValue:nil];
    });
});

describe(@"setting a comment", ^{
    __block UIAlertView *alertView;
    __block UITextView *textView;
    beforeEach(^{
        alertView = [UIAlertView nullMock];
        textView = [[UITextView alloc] init];
        [alertView stub:@selector(textFieldAtIndex:) andReturn:textView];
    });
    
    context(@"when the comment is not empty", ^{
        beforeEach(^{
            textView.text = @"some comment";
            [subject alertView:alertView didDismissWithButtonIndex:0];
        });
        
        it(@"should update the add comment button title to have the speech_balloon emoji", ^{
            [[subject.addCommentButton.titleLabel.text should] equal:[@"Add comment :speech_balloon:" emojizedString]];
        });
    });
    
    context(@"when the comment is empty", ^{
        beforeEach(^{
            textView.text = @"some comment";
            [subject alertView:alertView didDismissWithButtonIndex:0];
            textView.text = @"";
            [subject alertView:alertView didDismissWithButtonIndex:0];
        });
        
        it(@"should update the add comment button title to not have the speech_balloon emoji", ^{
            [[subject.addCommentButton.titleLabel.text should] equal:@"Add comment"];
        });
    });
});

describe(@"tapping the cancel barbuttonitem", ^{
    it(@"should dismiss the view", ^{
        [[subject should] receive:@selector(dismissViewControllerAnimated:completion:)];
        [subject.navigationItem.leftBarButtonItem tap];
    });
});

context(@"-enableRating", ^{
    beforeEach(^{
        [subject enableRating];
    });
    
    it(@"should enable all the rating up/down buttons", ^{
        for(UIButton *downButton in subject.downButtons) {
            [[theValue(downButton.enabled) should] beYes];
        }
        
        for(UIButton *upButton in subject.upButtons) {
            [[theValue(upButton.enabled) should] beYes];
        }
    });
});

context(@"-disableRating", ^{
    beforeEach(^{
        [subject disableRating];
    });
    
    it(@"should disable all the rating up/down buttons", ^{
        for(UIButton *downButton in subject.downButtons) {
            [[theValue(downButton.enabled) should] beNo];
        }
        
        for(UIButton *upButton in subject.upButtons) {
            [[theValue(upButton.enabled) should] beNo];
        }
    });
});

context(@"-clearRating", ^{
    beforeEach(^{
        for(UIButton *downButton in subject.downButtons) {
            [downButton tap];
        }
        [subject clearRating];
    });
    
    it(@"should reset all the ratings back to 0", ^{
        [[theValue(subject.difficulty) should] equal:theValue(0)];
        [[theValue(subject.smell) should] equal:theValue(0)];
        [[theValue(subject.relief) should] equal:theValue(0)];
        [[theValue(subject.size) should] equal:theValue(0)];
        [[theValue(subject.overall) should] equal:theValue(0)];
    });
});

SPEC_END