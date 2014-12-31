#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPMenuViewController.h"
#import "UIKit+PivotalSpecHelper.h"


SPEC_BEGIN(PPMenuViewControllerSpec)

__block PPMenuViewController *subject;
__block id<PPMenuViewControllerDelegate> delegate;
__block id<BSInjector, BSBinder> injector;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    subject = [injector getInstance:[PPMenuViewController class]];
    
    delegate = [KWMock mockForProtocol:@protocol(PPMenuViewControllerDelegate)];
    [subject setupWithDelegate:delegate];
    
    [subject view];
});

describe(@"tableview setup", ^{
    it(@"should have 1 section", ^{
        [[theValue([subject.tableView numberOfSections]) should] equal:theValue(1)];
    });
    
    it(@"should have 2 cells", ^{
        [[theValue([subject.tableView numberOfRowsInSection:0]) should] equal:theValue(2)];
    });
});

describe(@"tapping logout cell", ^{
    it(@"should notify the delegate", ^{
        [[(id)delegate should] receive:@selector(didTapLogout)];
        [[[subject.tableView visibleCells] objectAtIndex:0] tap];
    });
});

describe(@"tapping the recent pings cell", ^{
   it(@"should notify the delegate", ^{
       [[(id)delegate should] receive:@selector(didTapRecentPings)];
       [[[subject.tableView visibleCells] objectAtIndex:1] tap];
   });
});

SPEC_END