#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPPrivacyPolicyViewController.h"
#import "UIKit+PivotalSpecHelper.h"


SPEC_BEGIN(PPPrivacyPolicyViewControllerSpec)

__block PPPrivacyPolicyViewController *subject;
__block id<BSInjector, BSBinder> injector;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    subject = [injector getInstance:[PPPrivacyPolicyViewController class]];
    [subject view];
});

describe(@"viewDidLoad", ^{
    it(@"should have a UIWebView as a subview", ^{
        [[[subject.view.subviews lastObject] should] beKindOfClass:[UIWebView class]];
    });
});

describe(@"tapping the close button", ^{
    it(@"should dismiss the view controller", ^{
        [[subject should] receive:@selector(dismissViewControllerAnimated:completion:)];
        [subject.navigationItem.leftBarButtonItem tap];
    });
});

SPEC_END