//
//  PPMenuViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-30.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PPMenuViewControllerDelegate <NSObject>
@required
- (void)didTapLogout;
- (void)didTapRecentPings;

@end

@interface PPMenuViewController : UITableViewController

- (void)setupWithDelegate:(id<PPMenuViewControllerDelegate>)delegate;

@end
