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
@property (weak, nonatomic) IBOutlet UILabel *difficultyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *smellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *reliefTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *overallTitleLabel;

@property (weak, nonatomic) IBOutlet UITextField *difficultyTextField;
@property (weak, nonatomic) IBOutlet UITextField *smellTextField;
@property (weak, nonatomic) IBOutlet UITextField *reliefTextField;
@property (weak, nonatomic) IBOutlet UITextField *sizeTextField;
@property (weak, nonatomic) IBOutlet UITextField *overallTextField;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *backgroundTextFields;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *foregroundTextFields;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

- (void)setupWithPing:(PPPing*)ping username:(NSString*)username;
- (CGFloat)height;

@end
