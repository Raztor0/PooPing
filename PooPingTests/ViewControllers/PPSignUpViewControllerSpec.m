#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPSignUpViewController.h"
#import "PPNetworkClient.h"
#import "UIKit+PivotalSpecHelper.h"
#import "KSDeferred.h"
#import "KSPromise.h"


SPEC_BEGIN(PPSignUpViewControllerSpec)

__block PPSignUpViewController *subject;
__block id<BSInjector, BSBinder> injector;
__block id<PPSignUpViewControllerDelegate>delegate;
__block PPNetworkClient *networkClient;

beforeEach(^{
    injector = (id<BSInjector, BSBinder>)[Blindside injectorWithModule:[PPSpecModule new]];
    
    delegate = [KWMock mockForProtocol:@protocol(PPSignUpViewControllerDelegate)];
    
    networkClient = [PPNetworkClient nullMock];
    [injector bind:[PPNetworkClient class] toInstance:networkClient];
    
    subject = [injector getInstance:[PPSignUpViewController class]];
    
    [subject setupWithDelegate:delegate];
    [subject view];
});

describe(@"pressing the sign up button", ^{
    __block NSString *email, *username, *password;
    beforeEach(^{
        email = @"email@domain.com";
        username = @"username";
        password = @"password";
        subject.emailTextField.text = email;
        subject.usernameTextField.text = username;
        subject.passwordTextField.text = password;
        subject.passwordConfirmationTextField.text = password;
    });
    
    context(@"when all the fields are valid", ^{
        it(@"should tell the network client to make a sign up request with the info entered", ^{
            [[networkClient should] receive:@selector(signUpWithEmail:username:password:) withArguments:email, username, password, nil];
            [[subject signUpButton] tap];
        });
        
        context(@"on success", ^{
            __block KSDeferred *deferred;
            beforeEach(^{
                deferred = [KSDeferred defer];
                [networkClient stub:@selector(signUpWithEmail:username:password:) andReturn:deferred.promise];
            });
            
            it(@"should tell the delegate that the sign up was successful", ^{
                [[(id)delegate should] receive:@selector(signUpViewController:userSignedUpWithUsername:andPassword:)];
                [[subject signUpButton] tap];
                [deferred resolveWithValue:nil];
            });
        });
    });
    
    context(@"when the email is invalid", ^{
        describe(@"wrong format", ^{
            beforeEach(^{
                subject.emailTextField.text = @"not an email";
            });
            
            it(@"should not make a network request", ^{
                [[networkClient shouldNot] receive:@selector(signUpWithEmail:username:password:)];
                [subject.signUpButton tap];
            });
        });
        
        describe(@"not entered", ^{
            beforeEach(^{
                subject.emailTextField.text = @"";
            });
            
            it(@"should not make a network request", ^{
                [[networkClient shouldNot] receive:@selector(signUpWithEmail:username:password:)];
                [subject.signUpButton tap];
            });
        });
    });
    
    context(@"when the username is invalid", ^{
        describe(@"not entered", ^{
            beforeEach(^{
                subject.usernameTextField.text = @"";
            });
            
            it(@"should not make a network request", ^{
                [[networkClient shouldNot] receive:@selector(signUpWithEmail:username:password:)];
                [subject.signUpButton tap];
            });
        });
    });
    
    context(@"when the password is invalid", ^{
        describe(@"not entered", ^{
            beforeEach(^{
                subject.passwordTextField.text = @"";
                subject.passwordConfirmationTextField.text = @"";
            });
            
            it(@"should not make a network request", ^{
                [[networkClient shouldNot] receive:@selector(signUpWithEmail:username:password:)];
                [subject.signUpButton tap];
            });
        });
        
        describe(@"too short", ^{
            beforeEach(^{
                subject.passwordTextField.text = @"1234567";
                subject.passwordConfirmationTextField.text = @"1234567";
            });
            
            it(@"should not make a network request", ^{
                [[networkClient shouldNot] receive:@selector(signUpWithEmail:username:password:)];
                [subject.signUpButton tap];
            });
        });
    });
    
    context(@"when the passwords typed do not match", ^{
        beforeEach(^{
            subject.passwordTextField.text = @"12345678";
            subject.passwordConfirmationTextField.text = @"12345679";
        });
        
        it(@"should not make a network request", ^{
            [[networkClient shouldNot] receive:@selector(signUpWithEmail:username:password:)];
            [subject.signUpButton tap];
        });
    });
});

SPEC_END