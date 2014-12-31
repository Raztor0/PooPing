#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPRecentPingsViewController.h"
#import "UIKit+PivotalSpecHelper.h"


SPEC_BEGIN(PPRecentPingsViewControllerSpec)

__block PPRecentPingsViewController *subject;
__block id<BSInjector, BSBinder> injector;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    subject = [injector getInstance:[PPRecentPingsViewController class]];
    
    [subject view];
});

describe(@"tapping the close bar button item", ^{
    it(@"should dismiss itself", ^{
        [[subject should] receive:@selector(dismissViewControllerAnimated:completion:)];
        [subject.navigationItem.leftBarButtonItem tap];
    });
});

describe(@"-setupWithUsers:", ^{
    
});

SPEC_END