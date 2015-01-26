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
#import "PPSpinner.h"
#import "PPPoopRating.h"
#import "PPColors.h"
#import "PPNetworkClient.h"
#import "KSPromise.h"
#import <AFNetworking/AFNetworking.h>

@interface PPRatingViewController ()

@property (nonatomic, weak) id<BSInjector> injector;

@property (nonatomic, assign, readwrite) NSInteger difficulty;
@property (nonatomic, assign, readwrite) NSInteger smell;
@property (nonatomic, assign, readwrite) NSInteger relief;
@property (nonatomic, assign, readwrite) NSInteger size;
@property (nonatomic, assign, readwrite) NSInteger overall;

@property (nonatomic, strong) NSArray *poopStrings;

@property (nonatomic, strong) PPSpinner *spinner;
@property (nonatomic, strong) PPNetworkClient *networkClient;

@property (nonatomic, strong) NSTimer *pingResetTimer;
@property (nonatomic, assign) NSInteger secondsSincePing;

@property (nonatomic, strong) NSString *poopComment;

@end

@implementation PPRatingViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"spinner", @"networkClient", nil];
    [properties bindProperty:@"spinner" toKey:[PPSpinner class]];
    [properties bindProperty:@"networkClient" toKey:PPSharedNetworkClient];
    return properties;
}

+ (BSInitializer *)bsInitializer {
    return [BSInitializer initializerWithClass:self
                                 classSelector:@selector(controllerWithInjector:)
                                  argumentKeys:
            @protocol(BSInjector),
            nil];
}

+ (instancetype)controllerWithInjector:(id<BSInjector>)injector {
    UIStoryboard *storyboard = [injector getInstance:[UIStoryboard class] withArgs:PPRatingStoryboard, nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"Poop Rates", @"The title text for the rating view");
    [super viewDidLoad];
    
    self.difficultyLabel.text = NSLocalizedString(@"Difficulty", @"The text on the difficulty rating label");
    self.smellLabel.text = NSLocalizedString(@"Smell", @"The text on the smell rating label");
    self.reliefLabel.text = NSLocalizedString(@"Relief", @"The text on the relief rating label");
    self.sizeLabel.text = NSLocalizedString(@"Size", @"The text on the size rating label");
    self.overallLabel.text = NSLocalizedString(@"Overall", @"The text on the overall rating label");
    
    self.poopStrings = @[
                         @"",
                         [@":poop:" emojizedString],
                         [@":poop::poop:" emojizedString],
                         [@":poop::poop::poop:" emojizedString],
                         [@":poop::poop::poop::poop:" emojizedString],
                         [@":poop::poop::poop::poop::poop:" emojizedString],
                         ];
    
    for (UITextField *textField in self.foregroundTextFields) {
        textField.text = [self.poopStrings firstObject];
    }
    
    for (UITextField *textField in self.backgroundTextFields) {
        textField.text = [self.poopStrings lastObject];
    }
    
    self.pooPingButton.layer.cornerRadius = 5.0f;
    self.addCommentButton.layer.cornerRadius = 5.0f;
    
    self.poopComment = @"";
    
    [self styleButtons];
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didTapCancelBarButtonItem:)];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
}

- (void)styleButtons {
    [self.addCommentButton setTitle:NSLocalizedString(@"Add comment", @"Add comment button text on poop rating page") forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.pooPingButton.enabled) {
        [self resetPing];
    }
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

- (void)clearRating {
    self.addCommentButton.userInteractionEnabled = YES;
    self.addCommentButton.enabled = YES;
    [self styleButtons];
    self.poopComment = @"";
    self.difficulty = 0;
    self.smell = 0;
    self.relief = 0;
    self.size = 0;
    self.overall = 0;
    [self updateRatings];
}


- (void)resetPing {
    [self.pingResetTimer invalidate];
    self.pingResetTimer = nil;
    self.secondsSincePing = 0;
    self.pooPingButton.userInteractionEnabled = YES;
    self.pooPingButton.enabled = YES;
    [self enableRating];
    [self.pooPingButton setTitle:@"PooPing!" forState:UIControlStateNormal];
    [self.pooPingButton setTitle:@"PooPing!" forState:UIControlStateDisabled];
    UIColor *pooPingBackgroundColor = [PPColors pooPingRandomButtonColor];
    [self.pooPingButton setBackgroundColor:pooPingBackgroundColor];
    [self.pooPingButton setTitleColor:[PPColors oppositeOfColor:pooPingBackgroundColor] forState:UIControlStateNormal];
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

- (IBAction)didPressAddCommentButton:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comment" message:@"Add a comment (160 character limit)" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView textFieldAtIndex:0].text = self.poopComment;
    [alertView show];
}

- (IBAction)didPressPooPingButton:(UIButton *)sender {
    [self.spinner startAnimating];
    
    PPPoopRating *rating = [self.injector getInstance:[PPPoopRating class]];
    [rating setupWithDifficulty:self.difficulty smell:self.smell relief:self.relief size:self.size overall:self.overall];
    rating.comment = self.poopComment;
    
    KSPromise *promise = [self.networkClient postPooPingWithPoopRating:rating];
    [promise then:^id(NSDictionary *json) {
        [self.spinner stopAnimating];
        [self clearRating];
        [self resetPing];
        [self.pooPingButton setTitle:NSLocalizedString(@"Ping sent!", @"Ping button title after ping has been sent") forState:UIControlStateNormal];
        [self.pooPingButton setBackgroundColor:[PPColors pooPingButtonDisabled]];
        self.pooPingButton.enabled = NO;
        self.addCommentButton.userInteractionEnabled = NO;
        self.addCommentButton.enabled = NO;
        [self disableRating];
        self.pingResetTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pingResetTimerFired:) userInfo:nil repeats:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        return json;
    } error:^id(NSError *error) {
        [self.spinner stopAnimating];
        if([error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey]) {
            NSHTTPURLResponse *response = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
            if(response.statusCode != 401 && [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey]) {
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableContainers error:nil];
                NSString *errorString = [response objectForKey:@"error"];
                NSString *errorDescription = [response objectForKey:@"error_description"];
                [[[UIAlertView alloc] initWithTitle:errorString message:errorDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            }
        }
        return error;
    }];
}

- (void)updateRatings {
    self.difficultyTextField.text = [self.poopStrings objectAtIndex:self.difficulty];
    self.smellTextField.text = [self.poopStrings objectAtIndex:self.smell];
    self.reliefTextField.text = [self.poopStrings objectAtIndex:self.relief];
    self.sizeTextField.text = [self.poopStrings objectAtIndex:self.size];
    self.overallTextField.text = [self.poopStrings objectAtIndex:self.overall];
}

#pragma mark - UIBarButtonItems

- (void)didTapCancelBarButtonItem:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSTimer

- (void)pingResetTimerFired:(NSTimer*)timer {
    self.secondsSincePing++;
    if(self.secondsSincePing >= 10) {
        [self resetPing];
    } else {
        [UIView setAnimationsEnabled:NO];
        [self.pooPingButton setTitle:[NSString stringWithFormat:@"%@ (%lds)", NSLocalizedString(@"Ping sent!", @"Ping button title after ping has been sent"), 10 - (long)self.secondsSincePing] forState:UIControlStateDisabled];
        [UIView setAnimationsEnabled:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // prevent the user from entering more than 160 characters
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    return newLength <= 160;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        self.poopComment = [[alertView textFieldAtIndex:0] text];
        if(![self.poopComment isEqualToString:@""]) {
            [self.addCommentButton setTitle:[[NSString stringWithFormat:@"%@ :speech_balloon:", NSLocalizedString(@"Add comment", @"Add comment button text on poop rating page")] emojizedString] forState:UIControlStateNormal];
        } else {
            [self.addCommentButton setTitle:NSLocalizedString(@"Add comment", @"Add comment button text on poop rating page") forState:UIControlStateNormal];
        }
    }
}

@end
