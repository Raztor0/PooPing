#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPLoginViewController.h"
#import "PPNetworkClient.h"
#import "UIKit+PivotalSpecHelper.h"
#import "UIGestureRecognizer+Spec.h"
#import "PPSignUpViewController.h"
#import "PPInjectorKeys.h"

SPEC_BEGIN(PPLoginViewControllerSpec)

__block PPLoginViewController *subject;
__block PPNetworkClient *networkClient;
__block id<BSInjector, BSBinder> injector;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    networkClient = [PPNetworkClient nullMock];
    [injector bind:PPSharedNetworkClient toInstance:networkClient];
    
    subject = [injector getInstance:[PPLoginViewController class]];
    [subject view];
});

describe(@"pressing the sign in button", ^{
    beforeEach(^{
        subject.usernameTextField.text = @"username";
        subject.passwordTextField.text = @"password";
    });
    
    it(@"should make a network request to login with the credentials", ^{
        [[networkClient should] receive:@selector(loginRequestForUsername:password:) withArguments:@"username", @"password"];
        [[subject signInButton] tap];
    });
});

describe(@"pressing the sign up label", ^{
    it(@"should present the sign up view controller", ^{
        [[[[subject signUpLabel] gestureRecognizers] firstObject] recognize];
        [[[(UINavigationController*)subject.presentedViewController topViewController] should] beKindOfClass:[PPSignUpViewController class]];
    });
});

SPEC_END