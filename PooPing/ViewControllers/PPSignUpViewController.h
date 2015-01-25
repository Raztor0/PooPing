//
//  PPSignUpViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-24.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PPSignUpViewControllerDelegate;

@interface PPSignUpViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmationTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyPolicyLabel;

@property (nonatomic, weak) id <PPSignUpViewControllerDelegate> delegate;

- (void)setupWithDelegate:(id<PPSignUpViewControllerDelegate>)delegate;

@end

@protocol PPSignUpViewControllerDelegate <NSObject>
@required
- (void)signUpViewController:(PPSignUpViewController*)viewController userSignedUpWithUsername:(NSString*)username andPassword:(NSString*)password;
@end