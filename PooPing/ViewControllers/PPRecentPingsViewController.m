//
//  PPRecentPingsViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-30.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPRecentPingsViewController.h"
#import "PPStoryboardNames.h"
#import "DatePlot.h"
#import "PPRecentPingsTableViewController.h"
#import "PPNetworkClient.h"
#import "PPSessionManager.h"

@interface PPRecentPingsViewController ()

@property (nonatomic, strong) PPRecentPingsTableViewController *recentPingsTableViewController;
@property (nonatomic, strong) PPNetworkClient *networkClient;
@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation PPRecentPingsViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"networkClient", nil];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"PPRecentPingsTableViewControllerSegue"]) {
        PPRecentPingsTableViewController *viewController = segue.destinationViewController;
        [self.injector injectProperties:viewController];
        self.recentPingsTableViewController = viewController;
    }
}

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"Poops", @"Title of the recent poops view");
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([PPSessionManager getAccessToken]) {
        [self.networkClient getCurrentUser];
    }
}

#pragma mark - Public

- (void)setupWithUsers:(NSArray *)users {
    [self.recentPingsTableViewController setupWithUsers:users];
}

#pragma mark - IBActions

- (IBAction)didTapCloseButton:(UIBarButtonItem*)closeBarButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
