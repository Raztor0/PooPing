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

@implementation PPRecentPingsTableViewCell

- (void)setupWithPing:(PPPing *)ping username:(NSString *)username {
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
    self.commentLabel.text = ping.comment;
    self.ratingLabel.text = [[NSString stringWithFormat:@"%ld/5 :poop:", (long)ping.overall] emojizedString];
    self.dateLabel.text = [self dateStringFromDate:ping.dateSent];
    [self styleLabels];
}

- (CGFloat)height {
    CGFloat totalHeight = self.usernameLabel.frame.size.height + self.usernameLabel.frame.origin.y;
    
    CGSize size = [self.commentLabel.text boundingRectWithSize:CGSizeMake(self.commentLabel.frame.size.width, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{
                                                                 NSFontAttributeName : self.commentLabel.font
                                                                 }
                                                       context:nil].size;
    totalHeight += size.height;
    totalHeight += 5 + 1;
    return totalHeight;
}

#pragma mark - Private

- (void)styleLabels {
    self.usernameLabel.adjustsFontSizeToFitWidth = YES;
    self.usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
    self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12.0f];
    self.ratingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
    if([self.commentLabel.text isEqualToString:@""]) {
        self.commentLabel.text = @"no comment";
        self.commentLabel.textColor = [UIColor lightGrayColor];
        self.commentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:16.0f];
    } else {
        self.commentLabel.textColor = [UIColor blackColor];
        self.commentLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
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
