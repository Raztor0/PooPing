//
//  PPRecentPingsTableViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2015-01-04.
//  Copyright (c) 2015 Raz. All rights reserved.
//

#import "PPRecentPingsTableViewController.h"
#import "PPStoryboardNames.h"
#import "PPUser.h"
#import "PPPing.h"
#import "PPRecentPingsTableViewCell.h"
#import "PPSpinner.h"
#import "PPNetworkClient.h"
#import "KSPromise.h"
#import "PPSessionManager.h"

@interface PPRecentPingsTableViewController ()

@property (nonatomic, strong) NSArray *pings;
@property (nonatomic, strong) NSMutableDictionary *pingUsernameMap;
@property (nonatomic, strong) PPSpinner *spinner;
@property (nonatomic, strong) PPNetworkClient *networkClient;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation PPRecentPingsTableViewController

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
    UIStoryboard *storyboard = [injector getInstance:[UIStoryboard class] withArgs:PPRecentPingsStoryboard, nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *recentPingsCell = [UINib nibWithNibName:NSStringFromClass([PPRecentPingsTableViewCell class]) bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:recentPingsCell forCellReuseIdentifier:@"cell"];
    
    self.pingUsernameMap = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRefreshNotification:) name:PPNetworkClientUserRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRefreshFailNotification:) name:PPNetworkClientUserRefreshFailNotification object:nil];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshUser:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull to refresh", @"Refresh control title on the recent pings table view")];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupWithUsers:(NSArray *)users {
    self.pingUsernameMap = [NSMutableDictionary dictionary];
    NSMutableArray *poops = [NSMutableArray array];
    for(PPUser *user in users) {
        [poops addObjectsFromArray:user.recentPings];
        for(PPPing *ping in user.recentPings) {
            [self.pingUsernameMap setObject:user.username forKey:@(ping.pingId)];
        }
    }
    
    poops = [[poops sortedArrayUsingComparator:^NSComparisonResult(PPPing *ping1, PPPing *ping2) {
        return [ping1.dateSent timeIntervalSince1970] <= [ping2.dateSent timeIntervalSince1970];
    }] mutableCopy];
    
    self.pings = [NSArray arrayWithArray:poops];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PPRecentPingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    PPPing *ping = [self.pings objectAtIndex:indexPath.row];
    NSString *username =  [self.pingUsernameMap objectForKey:@(ping.pingId)];
    [cell setupWithPing:ping username:username forSizing:NO];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static PPRecentPingsTableViewCell *sizingCell;
    static CGFloat lastTableViewWidth = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    });
    
    if (lastTableViewWidth != tableView.frame.size.width) {
        sizingCell.frame = CGRectMake(0, 0, tableView.frame.size.width, sizingCell.frame.size.height);
        [sizingCell setNeedsLayout];
        [sizingCell layoutIfNeeded];
        lastTableViewWidth = tableView.frame.size.width;
    }
    
    PPPing *ping = [self.pings objectAtIndex:indexPath.row];
    NSString *username =  [self.pingUsernameMap objectForKey:@(ping.pingId)];
    [sizingCell setupWithPing:ping username:username forSizing:YES];
    return [sizingCell height];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pings count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.pings count] == 0) {
        return NO;
    } else {
        PPPing *ping = [self.pings objectAtIndex:indexPath.row];
        NSString *username =  [self.pingUsernameMap objectForKey:@(ping.pingId)];
        PPUser *currentUser = [PPSessionManager getCurrentUser];
        return [currentUser.username isEqualToString:username];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        PPPing *pingToDelete = [self.pings objectAtIndex:indexPath.row];
        [self.spinner startAnimating];
        [[self.networkClient deletePooPingWithId:pingToDelete.pingId] then:nil error:^id(NSError *error) {
            [self.spinner stopAnimating];
            return error;
        }];
    }
}

- (void)refreshUser:(UIRefreshControl*)refreshControl {
    [[self.networkClient getCurrentUser] then:^id(id value) {
        [self.refreshControl endRefreshing];
        return value;
    } error:^id(NSError *error) {
        [self.refreshControl endRefreshing];
        return error;
    }];
}

#pragma mark - NSNotifications

- (void)userRefreshNotification:(NSNotification*)notification {
    NSMutableSet *allUsernames = [NSMutableSet setWithArray:[self.pingUsernameMap allValues]];
    NSMutableArray *allUsers = [NSMutableArray array];
    PPUser *currentUser = [PPSessionManager getCurrentUser];
    if([allUsernames containsObject:currentUser.username]) {
        [allUsers addObject:currentUser];
        [allUsernames removeObject:currentUser.username];
    }
    
    for (PPUser *friend in currentUser.friends) {
        if([allUsernames containsObject:friend.username]) {
            [allUsers addObject:friend];
            [allUsernames removeObject:friend.username];
        }
    }
    
    [self setupWithUsers:allUsers];
    [self.spinner stopAnimating];
}

- (void)userRefreshFailNotification:(NSNotification*)notification {
    [self.spinner stopAnimating];
}

@end
