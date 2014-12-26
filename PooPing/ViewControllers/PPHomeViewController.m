//
//  PPHomeViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-19.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPHomeViewController.h"
#import "PPNetworking.h"
#import "KSPromise.h"
#import "PPStoryboardNames.h"
#import <AFNetworking/AFNetworking.h>
#import "PPColors.h"
#import "PPFriendsListViewController.h"
#import "PPSessionManager.h"
#import "PPSpinner.h"

@interface PPHomeViewController ()

@property (nonatomic, strong) PPLoginViewController *loginViewController;
@property (nonatomic, strong) PPFriendsListViewController *friendsListViewController;
@property (nonatomic, strong) PPSpinner *spinner;

@end

@implementation PPHomeViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"loginViewController", @"friendsListViewController", @"spinner", nil];
    [properties bindProperty:@"loginViewController" toKey:[PPLoginViewController class]];
    [properties bindProperty:@"friendsListViewController" toKey:[PPFriendsListViewController class]];
    [properties bindProperty:@"spinner" toKey:[PPSpinner class]];
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
    self.loginViewController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidTokenNotification:) name:PPNetworkingInvalidTokenNotification object:nil];
    
    if([PPSessionManager getCurrentUser]) {
        [self registerForRemoteNotifications];
    }
    self.view.backgroundColor = [PPColors pooPingAppColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.pooPingButton.enabled) {
        [self.pooPingButton setBackgroundColor:[PPColors pooPingRandomButtonColor]];
        [self.pooPingButton setTitleColor:[PPColors oppositeOfColor:self.pooPingButton.backgroundColor] forState:UIControlStateNormal];
    }
}

- (void)invalidTokenNotification:(NSNotification*)notification {
    [self showLoginViewAnimated:YES];
}

- (void)showLoginViewAnimated:(BOOL)animated {
    [self presentViewController:self.loginViewController animated:animated completion:^{
        self.view.hidden = NO;
    }];
}

- (IBAction)didTapPooPingButton:(UIButton*)sender {
    [self.spinner startAnimating];
    KSPromise *promise = [PPNetworking postPooPing];
    [promise then:^id(NSDictionary *json) {
        [self.spinner stopAnimating];
        [self.pooPingButton setTitle:@"Ping sent!" forState:UIControlStateNormal];
        [self.pooPingButton setBackgroundColor:[PPColors pooPingButtonDisabled]];
        self.pooPingButton.enabled = NO;
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

- (IBAction)didTapLogoutBarButtonItem:(UIBarButtonItem*)sender {
    [PPSessionManager deleteAllInfo];
    [self showLoginViewAnimated:YES];
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

#pragma mark - PPLoginViewControllerDelegate

- (void)userLoggedIn {
    self.pooPingButton.enabled = YES;
    [self.pooPingButton setTitle:@"PooPing!" forState:UIControlStateNormal];
    [self.loginViewController dismissViewControllerAnimated:YES completion:^{
        [self registerForRemoteNotifications];
    }];
}


@end
