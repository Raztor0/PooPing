#import "Kiwi.h"
#import "Blindside.h"
#import "PPModule.h"
#import "PPSpecModule.h"
#import "PPRecentPingsTableViewCell.h"
#import "PPPing.h"
#import "NSString+Emojize.h"


SPEC_BEGIN(PPRecentPingsTableViewCellSpec)

__block PPRecentPingsTableViewCell *subject;

beforeEach(^{
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([PPRecentPingsTableViewCell class]) bundle:[NSBundle mainBundle]];
    
    subject = [[cellNib instantiateWithOwner:nil options:nil] firstObject];
});

describe(@"-setupWithPing:username:", ^{
    describe(@"when there is a comment", ^{
        __block NSString *username;
        beforeEach(^{
            PPPing *ping = [PPPing pingFromDictionary:@{
                                                        @"id" : @(0),
                                                        @"difficulty" : @(5),
                                                        @"smell" : @(1),
                                                        @"relief" : @(2),
                                                        @"size" : @(3),
                                                        @"overall" : @(4),
                                                        @"comment" : @"first ping",
                                                        @"date_sent" : @"2014-12-22 00:00:00",
                                                        }];
            
            username = @"my username";
            [subject setupWithPing:ping username:username forSizing:NO];
        });
        
        it(@"should setup the labels", ^{
            [[subject.usernameLabel.text should] equal:[NSString stringWithFormat:@"@%@", username]];
            [[subject.commentLabel.text should] equal:@"first ping"];
            [[subject.dateLabel.text should] equal:@"Dec 22, 2014 at 12:00 am"];
            [[subject.difficultyTextField.text should] equal:[@":poop::poop::poop::poop::poop:" emojizedString]];
            [[subject.smellTextField.text should] equal:[@":poop:" emojizedString]];
            [[subject.reliefTextField.text should] equal:[@":poop::poop:" emojizedString]];
            [[subject.sizeTextField.text should] equal:[@":poop::poop::poop:" emojizedString]];
            [[subject.overallTextField.text should] equal:[@":poop::poop::poop::poop:" emojizedString]];
        });
    });
    
    describe(@"when there is no comment", ^{
        __block NSString *username;
        beforeEach(^{
            PPPing *ping = [PPPing pingFromDictionary:@{
                                                        @"id" : @(0),
                                                        @"difficulty" : @(0),
                                                        @"smell" : @(0),
                                                        @"relief" : @(0),
                                                        @"size" : @(0),
                                                        @"overall" : @(0),
                                                        @"comment" : @"",
                                                        @"date_sent" : @"2014-12-22 00:00:00",
                                                        }];
            
            username = @"my username";
            [subject setupWithPing:ping username:username forSizing:NO];
        });
        
        it(@"should say 'no comment' for the comment label", ^{
            [[subject.commentLabel.text should] equal:@"no comment"];
        });
    });
});

SPEC_END