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

@interface PPRecentPingsViewController ()

@property (nonatomic, strong) DatePlot *datePlot;
@property (nonatomic, assign) NSInteger currentSegmentIndex;
@property (nonatomic, strong) PPRecentPingsTableViewController *recentPingsTableViewController;
@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation PPRecentPingsViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"datePlot", nil];
    [properties bindProperty:@"datePlot" toKey:[DatePlot class]];
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
    self.segmentedControl.userInteractionEnabled = YES;
    self.currentSegmentIndex = 0;
    self.segmentedControl.selectedSegmentIndex = self.currentSegmentIndex;
    [self configureViewsForSegmentIndex:self.currentSegmentIndex];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.currentSegmentIndex = 0;
}

- (void)configureViewsForSegmentIndex:(NSInteger)segmentIndex {
    if(segmentIndex == 0) {
        self.graphView.frame = CGRectMake(0, self.graphView.frame.origin.y, self.graphView.frame.size.width, self.graphView.frame.size.height);
        self.recentPingsTableViewController.view.frame = CGRectMake(self.view.frame.size.width, self.recentPingsTableViewController.view.frame.origin.y, self.recentPingsTableViewController.view.frame.size.width, self.recentPingsTableViewController.view.frame.size.height);
    } else {
        self.graphView.frame = CGRectMake(-self.view.frame.size.width, self.graphView.frame.origin.y, self.graphView.frame.size.width, self.graphView.frame.size.height);
        self.recentPingsTableViewController.view.frame = CGRectMake(0, self.recentPingsTableViewController.view.frame.origin.y, self.recentPingsTableViewController.view.frame.size.width, self.recentPingsTableViewController.view.frame.size.height);
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
    if(segmentedControl.selectedSegmentIndex == 0) {
        if(self.currentSegmentIndex != segmentedControl.selectedSegmentIndex) {
            [UIView animateWithDuration:0.5 animations:^{
                [self configureViewsForSegmentIndex:segmentedControl.selectedSegmentIndex];
            } completion:^(BOOL finished) {
                self.currentSegmentIndex = segmentedControl.selectedSegmentIndex;
                [segmentedControl setUserInteractionEnabled:YES];
            }];
        }
    } else {
        if(self.currentSegmentIndex != segmentedControl.selectedSegmentIndex) {
            [UIView animateWithDuration:0.5 animations:^{
                [self configureViewsForSegmentIndex:segmentedControl.selectedSegmentIndex];
            } completion:^(BOOL finished) {
                self.currentSegmentIndex = segmentedControl.selectedSegmentIndex;
                [segmentedControl setUserInteractionEnabled:YES];
            }];
        }
    }
}

- (IBAction)didTapCloseButton:(UIBarButtonItem*)closeBarButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
