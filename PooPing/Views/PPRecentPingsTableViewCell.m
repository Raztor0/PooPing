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
    
    [self styleLabels];
}

- (void)styleLabels {
    self.usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
    if([self.commentLabel.text isEqualToString:@""]) {
        self.commentLabel.text = @"no comment";
        self.commentLabel.textColor = [UIColor lightGrayColor];
        self.commentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:16.0f];
    } else {
        self.commentLabel.text = [NSString stringWithFormat:@"'%@'", self.commentLabel.text];
    }
}

@end
