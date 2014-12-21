//
//  PPLoginViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PPLoginViewControllerDelegate;

@interface PPLoginViewController : UIViewController

@property (nonatomic, weak) id<PPLoginViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@protocol PPLoginViewControllerDelegate <NSObject>
@required
- (void)userLoggedIn;
@end
