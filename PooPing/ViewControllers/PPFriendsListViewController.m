//
//  PPFriendsListViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-21.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPFriendsListViewController.h"
#import "PPSessionManager.h"
#import "PPUser.h"
#import "PPStoryboardNames.h"
#import "PPNetworkClient.h"
#import "KSPromise.h"
#import "PPSpinner.h"
#import <AFNetworking/AFNetworking.h>
#import "PPColors.h"
#import "PPRecentPingsViewController.h"

@interface PPFriendsListViewController ()

@property (nonatomic, strong) PPSpinner *spinner;
@property (nonatomic, strong) PPNetworkClient *networkClient;
@property (nonatomic, strong) PPRecentPingsViewController *recentPingsViewController;

@end

@implementation PPFriendsListViewController

+ (BSPropertySet *)bsProperties {
BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"spinner", @"networkClient", @"recentPingsViewController", nil];
    [properties bindProperty:@"spinner" toKey:[PPSpinner class]];
    [properties bindProperty:@"networkClient" toKey:[PPNetworkClient class]];
    [properties bindProperty:@"recentPingsViewController" toKey:[PPRecentPingsViewController class]];
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
    UIStoryboard *storyboard = [injector getInstance:[UIStoryboard class] withArgs:PPFriendsListStoryboard, nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"PooPals", @"PooPals screen title");
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapCloseBarButtonItem:)];
    UIBarButtonItem *addFriendBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAddFriendBarButtonItem:)];
    
    self.navigationItem.leftBarButtonItem = closeBarButtonItem;
    self.navigationItem.rightBarButtonItem = addFriendBarButtonItem;
    
    self.addFriendAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add a friend", @"Text shown in the title of the alert view for adding a friend") message:NSLocalizedString(@"Enter a username", @"Text shown in the message of the alert view for adding a friend") delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    self.addFriendAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.addFriendAlertView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRefreshed:) name:PPNetworkClientUserRefreshNotification object:nil];
    
    self.tableView.backgroundColor = [PPColors pooPingAppColor];
    
    [self.recentPingsViewController view]; // trigger loading nibs
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.networkClient getCurrentUser];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[PPSessionManager getCurrentUser] friends] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *friends = [[PPSessionManager getCurrentUser] friends];
    NSString *username = [[friends objectAtIndex:indexPath.row] username];
    cell.textLabel.text = username;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PPUser *friend = [[[PPSessionManager getCurrentUser] friends] objectAtIndex:indexPath.row];
    [self.recentPingsViewController setupWithUsers:@[friend]];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.recentPingsViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *friendToDeleteUsername = [[[[PPSessionManager getCurrentUser] friends] objectAtIndex:indexPath.row] username];
        [self.spinner startAnimating];
        [[self.networkClient deleteFriend:friendToDeleteUsername] then:nil error:^id(NSError *error) {
            [self.spinner stopAnimating];
            return error;
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
}

#pragma mark - NSNotificationCenter

- (void)userRefreshed:(NSNotification*)notification {
    [self.tableView reloadData];
    [self.spinner stopAnimating];
}

#pragma mark - UIBarButtonItems

- (void)didTapCloseBarButtonItem:(UIBarButtonItem*)barButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapAddFriendBarButtonItem:(UIBarButtonItem*)barButtonItem {
    [self.addFriendAlertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == self.addFriendAlertView && buttonIndex == 1) {
        [self.spinner startAnimating];
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == self.addFriendAlertView && buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *friendName = textField.text;
        textField.text = @"";
        [[self.networkClient postFriendRequestForUser:friendName] then:^id(NSDictionary *json) {
            if([json objectForKey:@"error"] != nil && [json objectForKey:@"error_description"] != nil) {
                NSString *errorDescription = [json objectForKey:@"error_description"];
                [[[UIAlertView alloc] initWithTitle:@"Oops" message:errorDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            }
            return json;
        } error:^id(NSError *error) {
            [self.spinner stopAnimating];
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableContainers error:nil];
            NSString *errorString = [response objectForKey:@"error"];
            NSString *errorDescription = [response objectForKey:@"error_description"];
            [[[UIAlertView alloc] initWithTitle:errorString message:errorDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return error;
        }];
    }
}

@end
