#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPRecentPingsTableViewController.h"
#import "PPUser.h"
#import "PPSessionManager.h"
#import "PPPing.h"
#import "PPRecentPingsTableViewCell.h"
#import "PPNetworkClient.h"


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
        [[firstCell.commentLabel.text should] equal:@"second ping"];
        [[lastCell.commentLabel.text should] equal:@"first ping"];
    });
});

context(@"UITableViewDelegate", ^{
    __block PPUser *user;
    beforeEach(^{
        user = [PPUser userFromDictionary:@{
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
        NSMutableArray *users = [NSMutableArray arrayWithArray:user.friends];
        [users addObject:user];
        [subject setupWithUsers:users];
    });
    
    describe(@"swiping to delete", ^{
        it(@"shouldn't let the user swipe to delete a friend's ping", ^{
            [[theValue([subject tableView:subject.tableView canEditRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]) should] beNo];
        });
    });
});

context(@"deleting a ping", ^{
    __block PPUser *user;
    beforeEach(^{
        user = [PPUser userFromDictionary:@{
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
        NSMutableArray *users = [NSMutableArray arrayWithArray:user.friends];
        [users addObject:user];
        [subject setupWithUsers:users];
        
        user = [PPUser userFromDictionary:@{
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
                                                             }],
                                            }];
        
        [PPSessionManager setCurrentUser:user];
    });
    
    describe(@"one delete", ^{
        it(@"should update the tableview appropriately on user refresh notification", ^{
            [[theValue([[subject.tableView visibleCells] count]) should] equal:theValue(3)];
            [[NSNotificationCenter defaultCenter] postNotificationName:PPNetworkClientUserRefreshNotification object:nil];
            [[theValue([[subject.tableView visibleCells] count]) should] equal:theValue(2)];
        });
    });
    
    describe(@"one delete and an add by a friend", ^{
        beforeEach(^{
            user = [PPUser userFromDictionary:@{
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
                                                                 }],
                                                }];
            [PPSessionManager setCurrentUser:user];
        });
        
        it(@"should update the tableview appropriately on user refresh notification", ^{
            [[theValue([[subject.tableView visibleCells] count]) should] equal:theValue(3)];
            [[NSNotificationCenter defaultCenter] postNotificationName:PPNetworkClientUserRefreshNotification object:nil];
            [[theValue([[subject.tableView visibleCells] count]) should] equal:theValue(3)];
        });
    });
});

SPEC_END