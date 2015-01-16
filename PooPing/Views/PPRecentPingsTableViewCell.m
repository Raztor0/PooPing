//
//  PPRecentPingsTableViewCell.m
//  PooPing
//
//  Created by Razvan Bangu on 2015-01-04.
//  Copyright (c) 2015 Raz. All rights reserved.
//

#import "PPRecentPingsTableViewCell.h"
#import "PPPing.h"
#import "NSString+Emojize.h"
#import "PPColors.h"

@interface PPRecentPingsTableViewCell ()

@property (nonatomic, strong) NSArray *poopStrings;

@end

@implementation PPRecentPingsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.poopStrings = @[
                         @"",
                         [@":poop:" emojizedString],
                         [@":poop::poop:" emojizedString],
                         [@":poop::poop::poop:" emojizedString],
                         [@":poop::poop::poop::poop:" emojizedString],
                         [@":poop::poop::poop::poop::poop:" emojizedString],
                         ];
    
    self.backgroundColor = [PPColors pooPingAppColor];
}

- (void)setupWithPing:(PPPing *)ping username:(NSString *)username forSizing:(BOOL)sizing {
    self.commentLabel.text = ping.comment;
    
    if(!sizing) {
        self.usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
        self.dateLabel.text = [self dateStringFromDate:ping.dateSent];
        [self styleLabels];
        
        self.difficultyTextField.text = [self.poopStrings objectAtIndex:ping.difficulty];
        self.smellTextField.text = [self.poopStrings objectAtIndex:ping.smell];
        self.reliefTextField.text = [self.poopStrings objectAtIndex:ping.relief];
        self.sizeTextField.text = [self.poopStrings objectAtIndex:ping.size];
        self.overallTextField.text = [self.poopStrings objectAtIndex:ping.overall];
    }
}

- (CGFloat)height {
    CGFloat totalHeight = 0;
    
    CGFloat usernameLabelHeight = self.usernameLabel.frame.size.height;
    
    CGFloat ratingLabelsHeight = self.difficultyTitleLabel.frame.size.height + self.smellTitleLabel.frame.size.height + self.reliefTitleLabel.frame.size.height + self.sizeTitleLabel.frame.size.height + self.overallTitleLabel.frame.size.height;
    
    CGFloat commentLabelHeight = [self heightForLabel:self.commentLabel];
    
    totalHeight += self.usernameLabel.frame.origin.y;
    totalHeight += usernameLabelHeight;
    totalHeight += 5;
    totalHeight += ratingLabelsHeight;
    totalHeight += 5;
    totalHeight += commentLabelHeight;
    totalHeight += 5;
    totalHeight ++; // for the cell divider
    return totalHeight;
}

#pragma mark - Private

- (NSAttributedString*)attributedStringForRating:(NSInteger)rating {
    NSMutableAttributedString *ratingString = [[NSMutableAttributedString alloc] initWithString:[@"AAAAA" emojizedString]];
    NSUInteger poopLength = [[@"A" emojizedString] length];
    UIColor *disabledPoopColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [ratingString addAttribute:NSForegroundColorAttributeName value:disabledPoopColor range:NSMakeRange(poopLength * rating, (5 - rating) * poopLength)];
    return ratingString;
}

- (CGFloat)heightForLabel:(UILabel*)label {
    return [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, MAXFLOAT)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{
                                              NSFontAttributeName : label.font
                                              }
                                    context:nil].size.height;
}

- (void)styleLabels {
    self.usernameLabel.adjustsFontSizeToFitWidth = YES;
    self.usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
    self.usernameLabel.textColor = [UIColor whiteColor];
    self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0f];
    self.dateLabel.textColor = [UIColor whiteColor];
    if([self.commentLabel.text isEqualToString:@""]) {
        self.commentLabel.text = @"no comment";
        self.commentLabel.textColor = [UIColor lightGrayColor];
        self.commentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:16.0f];
    } else {
        self.commentLabel.textColor = [UIColor whiteColor];
        self.commentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
    }
    
    self.difficultyTitleLabel.text = NSLocalizedString(@"Difficulty:", @"Difficulty label text in the recent poops list view cell");
    self.smellTitleLabel.text = NSLocalizedString(@"Smell:", @"Smell label text in the recent poops list view cell");
    self.reliefTitleLabel.text = NSLocalizedString(@"Relief:", @"Relief label text in the recent poops list view cell");
    self.sizeTitleLabel.text = NSLocalizedString(@"Size:", @"Size label text in the recent poops list view cell");
    self.overallTitleLabel.text = NSLocalizedString(@"Overall:", @"Overall label text in the recent poops list view cell");
    
    for (UILabel *titleLabel in self.titleLabels) {
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];;
    }
    
    for (UITextField *textField in self.foregroundTextFields) {
        textField.text = [self.poopStrings firstObject];
    }
    
    for(UITextField *textField in self.backgroundTextFields) {
        textField.text = [self.poopStrings lastObject];
    }
}

- (NSString*)dateStringFromDate:(NSDate*)date {
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
    [dayFormat setDateFormat:@"MMM d, yyyy"];
    NSDateFormatter *hourFormat = [[NSDateFormatter alloc] init];
    [hourFormat setDateFormat:@"h:mm a"];
    return[NSString stringWithFormat:@"%@ at %@", [dayFormat stringFromDate:date], [[hourFormat stringFromDate:date] lowercaseString]];
}

@end
