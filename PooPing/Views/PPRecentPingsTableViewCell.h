//
//  PPRecentPingsTableViewCell.h
//  PooPing
//
//  Created by Razvan Bangu on 2015-01-04.
//  Copyright (c) 2015 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPPing;

@interface PPRecentPingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

- (void)setupWithPing:(PPPing*)ping username:(NSString*)username forSizing:(BOOL)sizing;
- (CGFloat)height;

@end
