//
//  PPHomeViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPHomeViewController.h"
#import "PPNetworkClient.h"
#import "KSPromise.h"
#import "PPStoryboardNames.h"
#import <AFNetworking/AFNetworking.h>
#import "PPColors.h"
#import "PPFriendsListViewController.h"
#import "PPSessionManager.h"
#import "PPSpinner.h"
#import "NSString+Emojize.h"
#import "PPPoopRating.h"
#import "PPRatingViewController.h"
#import "PPRecentPingsViewController.h"
#import "PPUser.h"

@interface PPHomeViewController ()

@property (nonatomic, strong) PPLoginViewController *loginViewController;
@property (nonatomic, strong) PPFriendsListViewController *friendsListViewController;
@property (nonatomic, strong) PPRecentPingsViewController *recentPingsViewController;
@property (nonatomic, strong) PPSpinner *spinner;
@property (nonatomic, strong) PPNetworkClient *networkClient;
@property (nonatomic, strong, readwrite) NSString *poopComment;
@property (nonatomic, strong) NSTimer *pingResetTimer;
@property (nonatomic, assign) NSInteger secondsSincePing;

@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation PPHomeViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"loginViewController", @"friendsListViewController", @"recentPingsViewController", @"spinner", @"networkClient", nil];
    [properties bindProperty:@"loginViewController" toKey:[PPLoginViewController class]];
    [properties bindProperty:@"friendsListViewController" toKey:[PPFriendsListViewController class]];
    [properties bindProperty:@"recentPingsViewController" toKey:[PPRecentPingsViewController class]];
    [properties bindProperty:@"spinner" toKey:[PPSpinner class]];
    [properties bindProperty:@"networkClient" toKey:[PPNetworkClient class]];
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
    UIStoryboard *storyboard = [injector getInstance:[UIStoryboard class] withArgs:PPHomeStoryboard, nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"Home", @"Title of the home screen");
    [super viewDidLoad];
    self.pooPingButton.layer.cornerRadius = 5.0f;
    self.addCommentButton.layer.cornerRadius = 5.0f;
    self.selectToiletPaperButton.layer.cornerRadius = 5.0f;
    self.selectToiletPaperButton.enabled = NO;
    self.selectToiletPaperButton.alpha = 0.5;
    self.loginViewController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidTokenNotification:) name:PPNetworkingInvalidTokenNotification object:nil];
    
    if([PPSessionManager getCurrentUser]) {
        [self registerForRemoteNotifications];
    }
    self.view.backgroundColor = [PPColors pooPingAppColor];
    
    self.poopComment = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.pooPingButton.enabled) {
        [self resetPing];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:NSStringFromClass([PPRatingViewController class])]) {
        self.ratingViewController = (PPRatingViewController*)segue.destinationViewController;
        [self.injector injectProperties:self.ratingViewController];
    }
}

- (void)invalidTokenNotification:(NSNotification*)notification {
    [self showLoginViewAnimated:YES];
}

- (void)showLoginViewAnimated:(BOOL)animated {
    if(self.presentedViewController != self.loginViewController) {
        [self presentViewController:self.loginViewController animated:animated completion:^{
            self.view.hidden = NO;
        }];
    }
}

- (void)showRecentPingsView {
    [self.recentPingsViewController view]; // trigger loading of nib views
    [self.recentPingsViewController setupWithUsers:@[[PPSessionManager getCurrentUser]]];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.recentPingsViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)showRecentPingsForPoopalsView {
    [self.recentPingsViewController setupWithUsers:[[PPSessionManager getCurrentUser] friends]];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.recentPingsViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)resetPing {
    [self.pingResetTimer invalidate];
    self.pingResetTimer = nil;
    self.secondsSincePing = 0;
    self.pooPingButton.userInteractionEnabled = YES;
    self.pooPingButton.enabled = YES;
    self.addCommentButton.userInteractionEnabled = YES;
    self.addCommentButton.enabled = YES;
    self.poopComment = @"";
    [self.ratingViewController enableRating];
    [self.ratingViewController clearRating];
    [self.pooPingButton setTitle:@"PooPing!" forState:UIControlStateNormal];
    UIColor *pooPingBackgroundColor = [PPColors pooPingRandomButtonColor];
    [self.pooPingButton setBackgroundColor:pooPingBackgroundColor];
    [self.pooPingButton setTitleColor:[PPColors oppositeOfColor:pooPingBackgroundColor] forState:UIControlStateNormal];
}

#pragma mark - IBActions

- (IBAction)didTapAddCommentButton:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comment" message:@"Add a comment (160 character limit)" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView textFieldAtIndex:0].text = self.poopComment;
    [alertView show];
}

- (IBAction)didTapPooPingButton:(UIButton*)sender {
    [self.spinner startAnimating];
    
    PPPoopRating *rating = [self.injector getInstance:[PPPoopRating class]];
    [rating setupWithDifficulty:self.ratingViewController.difficulty smell:self.ratingViewController.smell relief:self.ratingViewController.relief size:self.ratingViewController.size overall:self.ratingViewController.overall];
    rating.comment = self.poopComment;
    
    KSPromise *promise = [self.networkClient postPooPingWithPoopRating:rating];
    [promise then:^id(NSDictionary *json) {
        [self.spinner stopAnimating];
        [self.pooPingButton setTitle:NSLocalizedString(@"Ping sent!", @"Ping button title after ping has been sent") forState:UIControlStateNormal];
        [self.pooPingButton setBackgroundColor:[PPColors pooPingButtonDisabled]];
        self.pooPingButton.enabled = NO;
        self.addCommentButton.userInteractionEnabled = NO;
        self.addCommentButton.enabled = NO;
        [self.ratingViewController disableRating];
        self.pingResetTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pingResetTimerFired:) userInfo:nil repeats:YES];
        return json;
    } error:^id(NSError *error) {
        [self.spinner stopAnimating];
        if([error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey]) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableContainers error:nil];
            NSString *errorString = [response objectForKey:@"error"];
            NSString *errorDescription = [response objectForKey:@"error_description"];
            [[[UIAlertView alloc] initWithTitle:errorString message:errorDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Something went wrong. Please try again later." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }
        return error;
    }];
}

- (IBAction)didTapFriendsButton:(UIBarButtonItem*)sender {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.friendsListViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)registerForRemoteNotifications {
    if (![[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    } else {
        // new registeration method
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationSettings * notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
}

- (void)pingResetTimerFired:(NSTimer*)timer {
    self.secondsSincePing++;
    if(self.secondsSincePing >= 10) {
        [self resetPing];
    } else {
        [UIView setAnimationsEnabled:NO];
        [self.pooPingButton setTitle:[NSString stringWithFormat:@"%@ (%lds)", NSLocalizedString(@"Ping sent!", @"Ping button title after ping has been sent"), 10 - (long)self.secondsSincePing] forState:UIControlStateNormal];
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
    }
}

#pragma mark - PPLoginViewControllerDelegate

- (void)userLoggedIn {
    [self resetPing];
    [self.loginViewController dismissViewControllerAnimated:YES completion:^{
        [self registerForRemoteNotifications];
    }];
}

#pragma mark - SlideNavigationControllerDelegate

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return NO;
}


@end
