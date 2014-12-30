//
//  PPRatingViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-27.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPRatingViewController.h"
#import "PPStoryboardNames.h"
#import "NSString+Emojize.h"

@interface PPRatingViewController ()

@property (nonatomic, assign, readwrite) NSInteger difficulty;
@property (nonatomic, assign, readwrite) NSInteger smell;
@property (nonatomic, assign, readwrite) NSInteger relief;
@property (nonatomic, assign, readwrite) NSInteger size;
@property (nonatomic, assign, readwrite) NSInteger overall;

@property (nonatomic, strong) NSArray *poopStrings;

@end

@implementation PPRatingViewController

//+ (BSPropertySet *)bsProperties {
//    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"poopStrings", nil];
//    [properties bindProperty:@"poopStrings" toKey:[NSArray class]];
//    return properties;
//}

+ (BSInitializer *)bsInitializer {
    return [BSInitializer initializerWithClass:self
                                 classSelector:@selector(controllerWithInjector:)
                                  argumentKeys:
            @protocol(BSInjector),
            nil];
}

+ (instancetype)controllerWithInjector:(id<BSInjector>)injector {
    UIStoryboard *storyboard = [injector getInstance:[UIStoryboard class] withArgs:PPHomeStoryboard, nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ratingLabel.text = NSLocalizedString(@"Rating", @"The title text for the difficulty rating labels section");
    self.difficultyLabel.text = NSLocalizedString(@"Difficulty", @"The text on the difficulty rating label");
    self.smellLabel.text = NSLocalizedString(@"Smell", @"The text on the smell rating label");
    self.reliefLabel.text = NSLocalizedString(@"Relief", @"The text on the relief rating label");
    self.sizeLabel.text = NSLocalizedString(@"Size", @"The text on the size rating label");
    self.overallLabel.text = NSLocalizedString(@"Overall", @"The text on the overall rating label");
    
    for (UITextField *textField in self.foregroundTextFields) {
        textField.text = @"";
    }
    
    for (UITextField *textField in self.backgroundTextFields) {
        textField.text = [@":poop::poop::poop::poop::poop:" emojizedString];
    }
    
    self.poopStrings = @[
                         @"",
                         [@":poop:" emojizedString],
                         [@":poop::poop:" emojizedString],
                         [@":poop::poop::poop:" emojizedString],
                         [@":poop::poop::poop::poop:" emojizedString],
                         [@":poop::poop::poop::poop::poop:" emojizedString],
                         ];
}

- (void)enableRating {
    for (UIButton *button in self.downButtons) {
        [button setEnabled:YES];
    }
    
    for (UIButton *button in self.upButtons) {
        [button setEnabled:YES];
    }
}

- (void)disableRating {
    for (UIButton *button in self.downButtons) {
        [button setEnabled:NO];
    }
    
    for (UIButton *button in self.upButtons) {
        [button setEnabled:NO];
    }
}

#pragma mark - IBActions

- (IBAction)didPressUpDifficultyButton:(UIButton*)button {
    if(self.difficulty < 5) {
        self.difficulty++;
        [self updateRatings];
    }
}

- (IBAction)didPressUpSmellButton:(UIButton*)button {
    if(self.smell < 5) {
        self.smell++;
        [self updateRatings];
    }
}

- (IBAction)didPressUpReliefButton:(UIButton*)button {
    if(self.relief < 5) {
        self.relief++;
        [self updateRatings];
    }
}

- (IBAction)didPressUpSizeButton:(UIButton*)button {
    if(self.size < 5) {
        self.size++;
        [self updateRatings];
    }
}

- (IBAction)didPressUpOverallButton:(UIButton*)button {
    if(self.overall < 5) {
        self.overall++;
        [self updateRatings];
    }
}

- (IBAction)didPressDownDifficultyButton:(UIButton*)button {
    if(self.difficulty > 0) {
        self.difficulty--;
        [self updateRatings];
    }
}

- (IBAction)didPressDownSmellButton:(UIButton*)button {
    if(self.smell > 0) {
        self.smell--;
        [self updateRatings];
    }
}

- (IBAction)didPressDownReliefButton:(UIButton*)button {
    if(self.relief > 0) {
        self.relief--;
        [self updateRatings];
    }
}

- (IBAction)didPressDownSizeButton:(UIButton*)button {
    if(self.size > 0) {
        self.size--;
        [self updateRatings];
    }
}

- (IBAction)didPressDownOverallButton:(UIButton*)button {
    if(self.overall > 0) {
        self.overall--;
        [self updateRatings];
    }
}

- (void)updateRatings {
    self.difficultyTextField.text = [self.poopStrings objectAtIndex:self.difficulty];
    self.smellTextField.text = [self.poopStrings objectAtIndex:self.smell];
    self.reliefTextField.text = [self.poopStrings objectAtIndex:self.relief];
    self.sizeTextField.text = [self.poopStrings objectAtIndex:self.size];
    self.overallTextField.text = [self.poopStrings objectAtIndex:self.overall];
}

@end
