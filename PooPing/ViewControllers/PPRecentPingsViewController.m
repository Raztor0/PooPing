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

@property (nonatomic, strong) DatePlot *datePlot;
@property (nonatomic, assign) NSInteger currentSegmentIndex;
@property (nonatomic, strong) PPRecentPingsTableViewController *recentPingsTableViewController;
@property (nonatomic, strong) PPNetworkClient *networkClient;
@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation PPRecentPingsViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"datePlot", @"networkClient", nil];
    [properties bindProperty:@"datePlot" toKey:[DatePlot class]];
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
    [self.segmentedControl setTitle:NSLocalizedString(@"List", @"Segmented control list view title in the recent pings view") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"Graph", @"Segmented control graph view title in the recent pings view") forSegmentAtIndex:1];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.segmentedControl.userInteractionEnabled = YES;
    self.currentSegmentIndex = 0;
    self.segmentedControl.selectedSegmentIndex = self.currentSegmentIndex;
    [self configureViewsForSegmentIndex:self.currentSegmentIndex];
    if([PPSessionManager getAccessToken]) {
        [self.networkClient getCurrentUser];
    }
}

- (void)configureViewsForSegmentIndex:(NSInteger)segmentIndex {
    if(segmentIndex == 0) {
        self.graphViewLeadingSpaceConstraint.constant = self.view.frame.size.width;
        self.recentPingsTableViewController.view.frame = CGRectMake(0, self.recentPingsTableViewController.view.frame.origin.y, self.recentPingsTableViewController.view.frame.size.width, self.recentPingsTableViewController.view.frame.size.height);
    } else {
        self.graphViewLeadingSpaceConstraint.constant = 0;
        self.recentPingsTableViewController.view.frame = CGRectMake(-self.view.frame.size.width, self.recentPingsTableViewController.view.frame.origin.y, self.recentPingsTableViewController.view.frame.size.width, self.recentPingsTableViewController.view.frame.size.height);
    }
}

#pragma mark - Public

- (void)setupWithUsers:(NSArray *)users {
    [self.datePlot setupWithUsers:users];
    [self.datePlot renderInView:self.graphView withTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme] animated:YES];
    
    [self.recentPingsTableViewController setupWithUsers:users];
}

#pragma mark - IBActions

- (IBAction)didTapSegementedControl:(UISegmentedControl*)segmentedControl {
    [segmentedControl setUserInteractionEnabled:NO];
    [self.view layoutIfNeeded];
    if(self.currentSegmentIndex != segmentedControl.selectedSegmentIndex) {
        [UIView animateWithDuration:0.3 animations:^{
            [self configureViewsForSegmentIndex:segmentedControl.selectedSegmentIndex];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.currentSegmentIndex = segmentedControl.selectedSegmentIndex;
            [segmentedControl setUserInteractionEnabled:YES];
        }];
    }
}

- (IBAction)didTapCloseButton:(UIBarButtonItem*)closeBarButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
