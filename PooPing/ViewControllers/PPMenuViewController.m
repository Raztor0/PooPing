//
//  PPMenuViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-30.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPMenuViewController.h"
#import "PPStoryboardNames.h"

@interface PPMenuViewController()

@property (nonatomic, weak) id<PPMenuViewControllerDelegate> delegate;

@end

@implementation PPMenuViewController

//+ (BSPropertySet *)bsProperties {
//    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"loginViewController", @"friendsListViewController", @"spinner", @"networkClient", nil];
//    [properties bindProperty:@"loginViewController" toKey:[PPLoginViewController class]];
//    [properties bindProperty:@"friendsListViewController" toKey:[PPFriendsListViewController class]];
//    [properties bindProperty:@"spinner" toKey:[PPSpinner class]];
//    [properties bindProperty:@"networkClient" toKey:[PPNetworkClient class]];
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
    UIStoryboard *storyboard = [injector getInstance:[UIStoryboard class] withArgs:PPMenuStoryboard, nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)setupWithDelegate:(id<PPMenuViewControllerDelegate>)delegate {
    self.delegate = delegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView reloadData];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if(indexPath.row == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = @"Logout";
    } else  {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = @"Recent pings";
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    [header setBackgroundColor:[UIColor whiteColor]];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
    //    [footer setBackgroundColor:[UIColor blackColor]];
    return footer;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        [self.delegate didTapLogout];
    } else if(indexPath.row == 1) {
        [self.delegate didTapRecentPings];
    }
}

@end
