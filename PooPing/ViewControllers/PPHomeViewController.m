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

@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation PPHomeViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"loginViewController", @"friendsListViewController", @"recentPingsViewController", @"ratingViewController", @"spinner", @"networkClient", nil];
    [properties bindProperty:@"loginViewController" toKey:[PPLoginViewController class]];
    [properties bindProperty:@"friendsListViewController" toKey:[PPFriendsListViewController class]];
    [properties bindProperty:@"recentPingsViewController" toKey:[PPRecentPingsViewController class]];
    [properties bindProperty:@"ratingViewController" toKey:[PPRatingViewController class]];
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
    self.loginViewController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidTokenNotification:) name:PPNetworkClientInvalidTokenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRefreshNotification:) name:PPNetworkClientUserRefreshNotification object:nil];
    if([PPSessionManager getCurrentUser]) {
        [self registerForRemoteNotifications];
    }
    self.view.backgroundColor = [PPColors pooPingAppColor];
    
    [self addChildViewController:self.recentPingsViewController];
    [self.recentPingsViewController didMoveToParentViewController:self];
    [self.view addSubview:self.recentPingsViewController.view];
    
    [self.recentPingsViewController setupWithUsers:[[PPSessionManager getCurrentUser] friends]];
}

#pragma mark - NSNotifications

- (void)invalidTokenNotification:(NSNotification*)notification {
    [self showLoginViewAnimated:YES];
}

- (void)userRefreshNotification:(NSNotification*)notification {
    [self.recentPingsViewController setupWithUsers:[[PPSessionManager getCurrentUser] friends]];
}

- (void)showLoginViewAnimated:(BOOL)animated {
    if(self.presentedViewController != self.loginViewController) {
        [self presentViewController:self.loginViewController animated:animated completion:^{
            self.view.hidden = NO;
        }];
    }
}

- (void)showRecentPingsView {
    [self showRecentPingsWithUsers:@[[PPSessionManager getCurrentUser]]];
}

- (void)showRecentPingsWithUsers:(NSArray*)users {
    [self.recentPingsViewController view]; // trigger loading of nib views
    [self.recentPingsViewController setupWithUsers:users];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.recentPingsViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)showPooPalsView {
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

#pragma mark - IBActions

- (IBAction)didTapPooPingBarButtonItem:(UIBarButtonItem *)sender {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.ratingViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - PPLoginViewControllerDelegate

- (void)userLoggedIn {
    [self.ratingViewController enableRating];
    [self.ratingViewController resetPing];
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
