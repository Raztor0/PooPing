//
//  PPRecentPingsViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-30.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPRecentPingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *listView;
@property (weak, nonatomic) IBOutlet UIView *graphView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewLeadingSpaceConstraint;

- (void)setupWithUsers:(NSArray*)users;

@end
