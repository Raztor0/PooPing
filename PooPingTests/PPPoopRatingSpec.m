#import "Kiwi.h"
#import "Blindside.h"
#import "PPPoopRating.h"
#import "PPModule.h"
#import "PPSpecModule.h"


SPEC_BEGIN(PPPoopRatingSpec)

__block PPPoopRating *subject;
__block id<BSInjector> injector;
__block NSInteger difficulty, smell, relief, size, overall;

beforeEach(^{
    injector = [Blindside injectorWithModule:[PPSpecModule new]];
    subject = [injector getInstance:[PPPoopRating class]];
    
    difficulty = 1;
    smell = 2;
    relief = 3;
    size = 4;
    overall = 5;
});

context(@"-setupWithDifficulty:smell:relief:size:overall:", ^{
    beforeEach(^{
        [subject setupWithDifficulty:difficulty smell:smell relief:relief size:size overall:overall];
    });
    
    it(@"should setup the PPPoopRating class with the values given", ^{
        [[theValue(subject.difficulty) should] equal:theValue(difficulty)];
        [[theValue(subject.smell) should] equal:theValue(smell)];
        [[theValue(subject.relief) should] equal:theValue(relief)];
        [[theValue(subject.size) should] equal:theValue(size)];
        [[theValue(subject.overall) should] equal:theValue(overall)];
    });
});

SPEC_END