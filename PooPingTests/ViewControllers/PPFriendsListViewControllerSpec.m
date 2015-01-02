#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPFriendsListViewController.h"
#import "PPNetworkClient.h"
#import "PPUser.h"
#import "PPSessionManager.h"
#import "UIKit+PivotalSpecHelper.h"
#import "PPRecentPingsViewController.h"


SPEC_BEGIN(PPFriendsListViewControllerSpec)

__block PPFriendsListViewController *subject;
__block id<BSInjector, BSBinder> injector;
__block PPNetworkClient *networkClient;
__block PPUser *currentUser;
__block NSArray *friends;
__block PPRecentPingsViewController *recentPingsViewController;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    currentUser = [PPUser new];
    friends = @[
                @{
                    @"username" : @"friend1",
                    @"pings" : @[],
                    },
                @{
                    @"username" : @"friend2",
                    @"pings" : @[],
                    },
                @{
                    @"username" : @"friend3",
                    @"pings" : @[],
                    },
                ];
    [currentUser setupWithDictionary:@{
                                       @"username" : @"currentuser",
                                       @"friends" : friends,
                                       @"pings" : @[]
                                       }];
    
    [PPSessionManager stub:@selector(getCurrentUser) andReturn:currentUser];
    
    networkClient = [PPNetworkClient nullMock];
    [injector bind:[PPNetworkClient class] toInstance:networkClient];
    
    recentPingsViewController = [PPRecentPingsViewController nullMock];
    [injector bind:[PPRecentPingsViewController class] toInstance:recentPingsViewController];
    
    subject = [injector getInstance:[PPFriendsListViewController class]];
    [subject view];
    [subject.tableView reloadData];
});

context(@"tableview data source", ^{
    it(@"should have 1 section", ^{
        [[theValue([subject.tableView numberOfSections]) should] equal:theValue(1)];
    });
    
    it(@"should have 3 rows", ^{
        [[theValue([subject.tableView numberOfRowsInSection:0]) should] equal:theValue([friends count])];
    });
    
    it(@"should setup the cells with the friend's names", ^{
        UITableViewCell *friendCell1 = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITableViewCell *friendCell2 = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        UITableViewCell *friendCell3 = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        
        [[friendCell1.textLabel.text should] equal:[[friends objectAtIndex:0] objectForKey:@"username"]];
        [[friendCell2.textLabel.text should] equal:[[friends objectAtIndex:1] objectForKey:@"username"]];
        [[friendCell3.textLabel.text should] equal:[[friends objectAtIndex:2] objectForKey:@"username"]];
    });
});

context(@"deleting a friend", ^{
    it(@"should tell the network client to delete the first friend", ^{
        [[networkClient should] receive:@selector(deleteFriend:) withArguments:[[friends objectAtIndex:0] objectForKey:@"username"]];
        [subject tableView:subject.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    });
});

context(@"adding a friend", ^{
    __block NSString *friendToAdd;
    beforeEach(^{
        friendToAdd = @"a friend";
        [[subject.addFriendAlertView textFieldAtIndex:0] setText:friendToAdd];
    });
    
    it(@"should tell the network client to add a friend", ^{
        [[networkClient should] receive:@selector(postFriendRequestForUser:) withArguments:friendToAdd, nil];
        [subject.navigationItem.rightBarButtonItem tap];
        [subject.addFriendAlertView dismissWithClickedButtonIndex:1 animated:NO];
    });
});

context(@"tapping a cell", ^{
   it(@"should display a recent pings view controller for the proper friend", ^{
       [[recentPingsViewController should] receive:@selector(setupWithUsers:) withArguments:@[[currentUser friends][1]]];
       [[[subject.tableView visibleCells] objectAtIndex:1] tap];
       [[[(UINavigationController*)subject.presentedViewController topViewController] should] equal:recentPingsViewController];
   });
});

SPEC_END