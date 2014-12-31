//
//  PPHomeViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPLoginViewController.h"
#import "SlideNavigationController.h"

@class PPRatingViewController;

@interface PPHomeViewController : UIViewController <PPLoginViewControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, SlideNavigationControllerDelegate>

@property (nonatomic, strong) PPRatingViewController *ratingViewController;
@property (nonatomic, weak) IBOutlet UIButton *pooPingButton;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *selectToiletPaperButton;

@property (nonatomic, strong, readonly) NSString *poopComment;

- (void)showLoginViewAnimated:(BOOL)animated;
- (void)showRecentPingsView;

@end
