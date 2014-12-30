//
//  PPRatingViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-27.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPRatingViewController : UIViewController

@property (nonatomic, assign, readonly) NSInteger difficulty;
@property (nonatomic, assign, readonly) NSInteger smell;
@property (nonatomic, assign, readonly) NSInteger relief;
@property (nonatomic, assign, readonly) NSInteger size;
@property (nonatomic, assign, readonly) NSInteger overall;

@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *smellLabel;
@property (weak, nonatomic) IBOutlet UILabel *overallLabel;
@property (weak, nonatomic) IBOutlet UILabel *reliefLabel;

@property (weak, nonatomic) IBOutlet UITextField *difficultyTextField;
@property (weak, nonatomic) IBOutlet UITextField *smellTextField;
@property (weak, nonatomic) IBOutlet UITextField *reliefTextField;
@property (weak, nonatomic) IBOutlet UITextField *sizeTextField;
@property (weak, nonatomic) IBOutlet UITextField *overallTextField;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *downButtons;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *backgroundTextFields;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *foregroundTextFields;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *upButtons;

- (void)enableRating;
- (void)disableRating;


@end
