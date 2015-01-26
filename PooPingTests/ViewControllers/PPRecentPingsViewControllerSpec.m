#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPRecentPingsViewController.h"
#import "UIKit+PivotalSpecHelper.h"
#import "DatePlot.h"
#import "PPRecentPingsTableViewController.h"
#import "PPNetworkClient.h"
#import "PPInjectorKeys.h"


SPEC_BEGIN(PPRecentPingsViewControllerSpec)

__block PPRecentPingsViewController *subject;
__block id<BSInjector, BSBinder> injector;
__block PPRecentPingsTableViewController *recentPingsTableViewController;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    PPNetworkClient *networkClient = [PPNetworkClient nullMock];
    [injector bind:PPSharedNetworkClient toInstance:networkClient];
    
    subject = [injector getInstance:[PPRecentPingsViewController class]];
    [subject view];
    
    recentPingsTableViewController = [PPRecentPingsTableViewController nullMock];
    UIStoryboardSegue *segue = [UIStoryboardSegue nullMock];
    [segue stub:@selector(identifier) andReturn:@"PPRecentPingsTableViewControllerSegue"];
    [segue stub:@selector(destinationViewController) andReturn:recentPingsTableViewController];
    [subject prepareForSegue:segue sender:nil];
});

describe(@"tapping the close bar button item", ^{
    it(@"should dismiss itself", ^{
        [[subject should] receive:@selector(dismissViewControllerAnimated:completion:)];
        [subject.navigationItem.leftBarButtonItem tap];
    });
});

describe(@"-setupWithUsers:", ^{
    __block NSArray *users;
    beforeEach(^{
        users = @[];
    });
    
    it(@"should call setupWithUsers on the PPRecentPingsTableViewController", ^{
        [[recentPingsTableViewController should] receive:@selector(setupWithUsers:) withArguments:users];
        [subject setupWithUsers:users];
    });
});

SPEC_END