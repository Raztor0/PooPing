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

@interface PPHomeViewController : UIViewController <PPLoginViewControllerDelegate,SlideNavigationControllerDelegate>

@property (nonatomic, strong) PPRatingViewController *ratingViewController;

@property (nonatomic, strong, readonly) NSString *poopComment;

- (void)showLoginViewAnimated:(BOOL)animated;
- (void)showRecentPingsView;
- (void)showRecentPingsForPoopalsView;

@end
