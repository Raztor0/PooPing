#import "Kiwi.h"
#import "Blindside.h"
#import "PPUser.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPPing.h"


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
    
    subject = [PPUser userFromDictionary:userDictionary];
});

context(@"+userFromDictionary:", ^{
    it(@"should set up the PPUser class", ^{
        [[subject.username should] equal:username];
        [[subject.friends should] equal:friends];
    });
});

context(@"-addRecentPings:", ^{
    __block PPPing *ping;
    beforeEach(^{
        ping = [PPPing pingFromDictionary:@{
                                            @"pingId" : [@(0) stringValue],
                                            @"difficulty" : [@(1) stringValue],
                                            @"smell" : [@(3) stringValue],
                                            }];
        [subject addRecentPings:@[ping]];
    });
    
    it(@"should add our pings to its recentPings array", ^{
        [[subject.recentPings should] contain:ping];
    });
    
    describe(@"when adding a duplicate", ^{
        beforeEach(^{
            [subject addRecentPings:@[ping]];
        });
        
       it(@"should not add the ping", ^{
           [[theValue([subject.recentPings count]) should] equal:theValue(1)];
       });
    });
});

SPEC_END