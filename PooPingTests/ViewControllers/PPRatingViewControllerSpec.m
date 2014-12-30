#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPRatingViewController.h"
#import "UIKit+PivotalSpecHelper.h"


SPEC_BEGIN(PPRatingViewControllerSpec)

__block PPRatingViewController *subject;
__block id<BSInjector, BSBinder> injector;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
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

SPEC_END