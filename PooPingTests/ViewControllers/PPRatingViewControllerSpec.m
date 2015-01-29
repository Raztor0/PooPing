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
#import "PPInjectorKeys.h"

SPEC_BEGIN(PPRatingViewControllerSpec)

__block PPRatingViewController *subject;
__block id<BSInjector, BSBinder> injector;
__block PPNetworkClient *networkClient;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    networkClient = [PPNetworkClient nullMock];
    [injector bind:PPSharedNetworkClient toInstance:networkClient];
    
    subject = [injector getInstance:[PPRatingViewController class]];
    [subject view];
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


SPEC_END