//
//  PPHomeViewController.h
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPLoginViewController.h"

@interface PPHomeViewController : UIViewController <PPLoginViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *pooPingButton;
@property (weak, nonatomic) IBOutlet UITextField *difficultyTextField;
@property (weak, nonatomic) IBOutlet UITextField *smellTextField;
@property (weak, nonatomic) IBOutlet UITextField *reliefTextField;
@property (weak, nonatomic) IBOutlet UITextField *sizeTextField;
@property (weak, nonatomic) IBOutlet UITextField *overallTextField;
@property (weak, nonatomic) IBOutlet UIButton *difficultyDownButton;
@property (weak, nonatomic) IBOutlet UIButton *smellDownButton;
@property (weak, nonatomic) IBOutlet UIButton *reliefDownButton;
@property (weak, nonatomic) IBOutlet UIButton *sizeDownButton;
@property (weak, nonatomic) IBOutlet UIButton *overallDownButton;
@property (weak, nonatomic) IBOutlet UIButton *difficultyUpButton;
@property (weak, nonatomic) IBOutlet UIButton *smellUpButton;
@property (weak, nonatomic) IBOutlet UIButton *reliefUpButton;
@property (weak, nonatomic) IBOutlet UIButton *sizeUpButton;
@property (weak, nonatomic) IBOutlet UIButton *overallUpButton;


- (void)showLoginViewAnimated:(BOOL)animated;

@end
