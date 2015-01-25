//
//  PPSignUpViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-24.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPSignUpViewController.h"
#import "PPStoryboardNames.h"
#import "PPSpinner.h"
#import "PPNetworkClient.h"
#import "KSDeferred.h"
#import <AFNetworking/AFNetworking.h>
#import "PPColors.h"
#import "PPPrivacyPolicyViewController.h"

@interface PPSignUpViewController ()

@property (nonatomic, strong) PPSpinner *spinner;
@property (nonatomic, strong) PPNetworkClient *networkClient;
@property (nonatomic, weak) id<BSInjector> injector;

@property (nonatomic, strong) PPPrivacyPolicyViewController *privacyPolicyViewController;

@property (nonatomic, assign) BOOL emailError;
@property (nonatomic, assign) BOOL usernameError;
@property (nonatomic, assign) BOOL passwordError;

@end

@implementation PPSignUpViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"spinner", @"networkClient", @"privacyPolicyViewController", nil];
    [properties bindProperty:@"spinner" toKey:[PPSpinner class]];
    [properties bindProperty:@"networkClient" toKey:[PPNetworkClient class]];
    [properties bindProperty:@"privacyPolicyViewController" toKey:[PPPrivacyPolicyViewController class]];
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
    UIStoryboard *storyboard = [injector getInstance:[UIStoryboard class] withArgs:PPSignUpStoryboard, nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"Sign up", @"Title of the sign up page");
    [super viewDidLoad];
    
    self.signUpButton.layer.cornerRadius = 5.0f;
    self.errorLabel.text = @"";
    self.privacyPolicyLabel.attributedText = [self privacyPolicyAttributedString];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPrivacyPolicyLabel:)];
    [self.privacyPolicyLabel addGestureRecognizer:tapRecognizer];
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didTapCancelBarButtonItem:)];
    [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem];
    
    self.view.backgroundColor = [PPColors pooPingAppColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.signUpButton.backgroundColor = [PPColors pooPingRandomButtonColor];
    [self.signUpButton setTitleColor:[PPColors oppositeOfColor:self.signUpButton.backgroundColor] forState:UIControlStateNormal];
}

- (void)setupWithDelegate:(id<PPSignUpViewControllerDelegate>)delegate {
    self.delegate = delegate;
}

- (NSAttributedString*)privacyPolicyAttributedString {
    NSString *policyString = NSLocalizedString(@"By signing up you agree to our privacy policy", @"Privacy policy label text on the sign up screen");
    NSMutableAttributedString *privacyPolicyAttributedString = [[NSMutableAttributedString alloc] initWithString:policyString];
    [privacyPolicyAttributedString addAttribute:NSForegroundColorAttributeName value:[PPColors pooPingLightBlue] range:[policyString rangeOfString:NSLocalizedString(@"privacy policy", @"Privacy Policy")]];
    return privacyPolicyAttributedString;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == self.usernameTextField) {
        if(self.usernameError) {
            self.errorLabel.text = @"";
        }
        
        // prevent the user from entering more than 16 characters
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= 16 || returnKey;
    } else if(textField == self.emailTextField) {
        if(self.emailError) {
            self.errorLabel.text = @"";
        }
        
        // prevent the user from entering more than 100 characters
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= 100 || returnKey;
    } else if (textField == self.passwordTextField) {
        if(self.passwordError) {
            self.errorLabel.text = @"";
        }
        
        NSString *updatedPasswordString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // prevent the user from entering more than 50 characters
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        if(newLength <= 50 && !returnKey) {
            self.passwordTextField.text = updatedPasswordString;
        }
        
        return returnKey;
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(textField == self.emailTextField) {
        [self.usernameTextField becomeFirstResponder];
    } else if(textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if(textField == self.passwordTextField){
        [self.passwordConfirmationTextField becomeFirstResponder];
    } else {
        [self didTapSignUpButton:self.signUpButton];
    }
    return YES;
}

#pragma mark - Private

- (BOOL)validateTextFields {
    self.emailError = NO;
    self.usernameError = NO;
    self.passwordError = NO;
    
    NSString *emailAddress = self.emailTextField.text;
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", laxString];
    
    if([emailAddress length] == 0) {
        self.errorLabel.text = NSLocalizedString(@"Please enter an email address", @"Error displayed when a user tries registering with no email address");
        self.emailError = YES;
        return NO;
    } else if (![emailTest evaluateWithObject:emailAddress]){
        self.errorLabel.text = NSLocalizedString(@"Email addresses must be of the form email@example.com", @"Error displayed when a user tries registering with an email address that is not a valid address");
        self.emailError = YES;
        return NO;
    } else if([username length] == 0) {
        self.errorLabel.text = NSLocalizedString(@"Please enter a username", @"Error displayed when a user tries registering with no username");
        self.usernameError = YES;
        return NO;
    } else if([password length] == 0) {
        self.errorLabel.text = NSLocalizedString(@"Please enter a password", @"Error displayed when a user tries registering with no password");
        self.passwordError = YES;
        return NO;
    } else if([password length] < 8) {
        self.errorLabel.text = NSLocalizedString(@"Passwords must be 8 characters or longer", @"Error displayed when a user tries registering with a password shorter than 8 characters");
        self.passwordError = YES;
        return NO;
    } else if(![self.passwordTextField.text isEqualToString:self.passwordConfirmationTextField.text]) {
        self.errorLabel.text = NSLocalizedString(@"The passwords you entered do not match", @"Error displayed when a user tries registering and the two passwords text fields don't match");
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - UIBarButtonItems

- (void)didTapCancelBarButtonItem:(UIBarButtonItem*)barButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)didTapSignUpButton:(UIButton*)button {
    if([self validateTextFields]) {
        __block NSString *emailAddress = self.emailTextField.text;
        __block NSString *username = self.usernameTextField.text;
        __block NSString *password = self.passwordTextField.text;
        [self.spinner startAnimating];
        [[self.networkClient signUpWithEmail:emailAddress username:username password:password] then:^id(id value) {
            [self.spinner stopAnimating];
            [self.delegate signUpViewController:self userSignedUpWithUsername:username andPassword:password];
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Your account has been created. You may now login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            return value;
        } error:^id(NSError *error) {
            [self.spinner stopAnimating];
            if([error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey]) {
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableContainers error:nil];
                NSString *status = [response objectForKey:@"status"];
                NSString *reason = [response objectForKey:@"reason"];
                [[[UIAlertView alloc] initWithTitle:status message:reason delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Oops" message:error.localizedFailureReason delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            }
            return error;
        }];
    }
}

#pragma mark - UIGestureRecognizers

- (void)didTapPrivacyPolicyLabel:(UIGestureRecognizer*)recognizer {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.privacyPolicyViewController];
    [self presentViewController:navController animated:YES completion:nil];
}


@end
