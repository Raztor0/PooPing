#import "Kiwi.h"
#import "Blindside.h"
#import "PPUser.h"
#import "PPModule.h"
#import "PPSpecModule.h"


SPEC_BEGIN(PPUserSpec)

__block PPUser *subject;
__block NSString *username;
__block NSArray *friends;
__block NSDictionary *userDictionary;

beforeEach(^{
    username = @"a username";
    friends = @[
                @"friend1",
                @"friend2",
                @"friend3",
                ];
    userDictionary = @{
                                     @"username" : username,
                                     @"friends" : friends
                                     };
});

context(@"-initWithDictionary:", ^{
    it(@"should set up the PPUser class", ^{
        subject = [[PPUser alloc] initWithDictionary:userDictionary];
        [[subject.username should] equal:username];
        [[subject.friends should] equal:friends];
    });
});

SPEC_END