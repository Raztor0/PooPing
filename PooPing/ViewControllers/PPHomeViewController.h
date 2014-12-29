//
//  PPHomeViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPLoginViewController.h"

@class PPRatingViewController;

@interface PPHomeViewController : UIViewController <PPLoginViewControllerDelegate>

@property (nonatomic, strong) PPRatingViewController *ratingViewController;
@property (nonatomic, weak) IBOutlet UIButton *pooPingButton;

- (void)showLoginViewAnimated:(BOOL)animated;

@end
