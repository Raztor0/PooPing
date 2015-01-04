#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPRecentPingsTableViewController.h"
#import "PPUser.h"
#import "PPSessionManager.h"
#import "PPPing.h"
#import "PPRecentPingsTableViewCell.h"


SPEC_BEGIN(PPRecentPingsTableViewControllerSpec)

__block PPRecentPingsTableViewController *subject;
__block id<BSInjector, BSBinder> injector;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    subject = [injector getInstance:[PPRecentPingsTableViewController class]];
    [subject view];
});

describe(@"UITableViewDataSource", ^{
    beforeEach(^{
        PPUser *user = [PPUser userFromDictionary:@{
                                                    @"username" : @"user",
                                                    @"friends" : @[@{
                                                                       @"username" : @"user2",
                                                                       @"friends" : @[],
                                                                       @"pings" : @[@{
                                                                                        @"id" : @(3),
                                                                                        @"difficulty" : @(0),
                                                                                        @"smell" : @(0),
                                                                                        @"relief" : @(0),
                                                                                        @"size" : @(0),
                                                                                        @"overall" : @(0),
                                                                                        @"comment" : @"third ping",
                                                                                        @"date_sent" : @"2014-12-22 00:00:02",
                                                                                        }],
                                                                       }],
                                                    @"pings" : @[@{
                                                                     @"id" : @(0),
                                                                     @"difficulty" : @(0),
                                                                     @"smell" : @(0),
                                                                     @"relief" : @(0),
                                                                     @"size" : @(0),
                                                                     @"overall" : @(0),
                                                                     @"comment" : @"second ping",
                                                                     @"date_sent" : @"2014-12-22 00:00:01",
                                                                     },
                                                                 @{
                                                                     @"id" : @(1),
                                                                     @"difficulty" : @(0),
                                                                     @"smell" : @(0),
                                                                     @"relief" : @(0),
                                                                     @"size" : @(0),
                                                                     @"overall" : @(0),
                                                                     @"comment" : @"first ping",
                                                                     @"date_sent" : @"2014-12-22 00:00:00",
                                                                     }],
                                                    }];
        [subject setupWithUsers:@[user]];
    });
    
    it(@"should have 1 section", ^{
        [[theValue([subject.tableView numberOfSections]) should] equal:theValue(1)];
    });
    
    it(@"should have 2 cells", ^{
        [[theValue([subject.tableView numberOfRowsInSection:0]) should] equal:theValue(2)];
    });
    
    it(@"should order the pings in chronological order, most recent at the top", ^{
        PPRecentPingsTableViewCell *firstCell = [[subject.tableView visibleCells] firstObject];
        PPRecentPingsTableViewCell *lastCell = [[subject.tableView visibleCells] lastObject];
        [[firstCell.commentLabel.text should] equal:@"'first ping'"];
        [[lastCell.commentLabel.text should] equal:@"'second ping'"];
    });
});

SPEC_END