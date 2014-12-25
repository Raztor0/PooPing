//
//  PPLoginViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPLoginViewController.h"
#import "KSPromise.h"
#import "PPNetworking.h"
#import "PPHomeViewController.h"
#import "PPStoryboardNames.h"
#import "BlindsidedStoryboard.h"
#import "PPSpinner.h"
#import "PPSessionManager.h"
@interface PPLoginViewController ()

@property (nonatomic, strong) PPSpinner *spinner;
@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation PPLoginViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"spinner", nil];
    [properties bindProperty:@"spinner" toKey:[PPSpinner class]];
    return properties;
}

+ (BSInitializer *)bsInitializer {
    return [BSInitializer initializerWithClass:self
                                 classSelector:@selector(controllerWithInjector:)
                                  argumentKeys:
            @protocol(BSInjector),
            nil];
}

+ (instancetype)controllerWithInjector:(id<BSInjector>)injector {
    UIStoryboard *storyboard = [injector getInstance:[UIStoryboard class] withArgs:PPLoginStoryboard, nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef DEBUG
    self.usernameTextField.text = @"raz";
    self.passwordTextField.text = @"12345678";
#else
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
#endif
    
    self.signInButton.layer.cornerRadius = 5.0f;
    
    
    UITapGestureRecognizer *signUpLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSignUpLabel:)];
    [self.signUpLabel addGestureRecognizer:signUpLabelTapGestureRecognizer];
}

- (IBAction)didTapLoginButton:(UIButton*)sender {
    [self.spinner startAnimating];
    __block NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    KSPromise *promise = [PPNetworking loginRequestForUsername:username password:password];
    [promise then:^id(NSDictionary *json) {
        [[PPNetworking getCurrentUser] then:^id(NSDictionary *json) {
            [self.delegate userLoggedIn];
            [self.spinner stopAnimating];
            return json;
        } error:^id(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            [self.spinner stopAnimating];
            return error;
        }];
        return json;
    } error:^id(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        [self.spinner stopAnimating];
        return error;
    }];
}

#pragma mark - UIGestureRecognizers

- (void)didTapSignUpLabel:(UITapGestureRecognizer*)recognizer {
    PPSignUpViewController *signUpViewController = [self.injector getInstance:[PPSignUpViewController class]];
    [signUpViewController setupWithDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signUpViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - PPSignUpViewControllerDelegate

- (void)signUpViewController:(PPSignUpViewController*)viewController userSignedUpWithUsername:(NSString *)username andPassword:(NSString *)password {
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.usernameTextField.text = username;
    self.passwordTextField.text = password;
}

@end
