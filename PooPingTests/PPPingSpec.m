#import "Kiwi.h"
#import "PPPing.h"


SPEC_BEGIN(PPPingSpec)

__block PPPing *subject;


context(@"+pingFromDictionary:", ^{
    __block NSInteger userId, pingId, difficulty, smell, relief, size, overall;
    __block NSString *comment, *date_sent;
    
    beforeEach(^{
        userId = 1;
        pingId = 3;
        difficulty = 1;
        smell = 2;
        relief = 3;
        size = 4;
        overall = 5;
        comment = @"my comment";
        date_sent = @"2014-12-30 14:17:30";
        subject = [PPPing pingFromDictionary:@{
                                               @"userId" : [@(userId) stringValue],
                                               @"pingId" : [@(pingId) stringValue],
                                               @"difficulty" : [@(difficulty) stringValue],
                                               @"smell" : [@(smell) stringValue],
                                               @"relief" : [@(relief) stringValue],
                                               @"size" : [@(size) stringValue],
                                               @"overall" : [@(overall) stringValue],
                                               @"comment" : comment,
                                               @"date_sent" : date_sent
                                               }];
    });
    
    it(@"should set up the ping object with the values passed in the dictionary", ^{
        [[theValue(subject.userId) should] equal:theValue(userId)];
        [[theValue(subject.pingId) should] equal:theValue(pingId)];
        [[theValue(subject.difficulty) should] equal:theValue(difficulty)];
        [[theValue(subject.smell) should] equal:theValue(smell)];
        [[theValue(subject.relief) should] equal:theValue(relief)];
        [[theValue(subject.size) should] equal:theValue(size)];
        [[theValue(subject.overall) should] equal:theValue(overall)];
        [[subject.comment should] equal:comment];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateSent = [dateFormatter dateFromString:date_sent];
        [[subject.dateSent should] equal:dateSent];
    });
});

SPEC_END