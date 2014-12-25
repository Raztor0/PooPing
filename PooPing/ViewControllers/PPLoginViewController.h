//
//  PPLoginViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPSignUpViewController.h"

@protocol PPLoginViewControllerDelegate;

@interface PPLoginViewController : UIViewController <PPSignUpViewControllerDelegate>

@property (nonatomic, weak) id<PPLoginViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;

@end

@protocol PPLoginViewControllerDelegate <NSObject>
@required
- (void)userLoggedIn;
@end
