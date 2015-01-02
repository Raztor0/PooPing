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

@interface PPRecentPingsViewController ()

@property (nonatomic, strong) DatePlot *datePlot;

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

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"Poops", @"Title of the recent poops view");
    [super viewDidLoad];
    
    
    [self.datePlot renderInView:self.view withTheme:[CPTTheme themeNamed:@"Dark Gradients"] animated:YES];
}

#pragma mark - Public

- (void)setupWithUsers:(NSArray *)users {
    [self.datePlot setupWithUsers:users];
    [self.datePlot generateData];
}

#pragma mark - IBActions

- (IBAction)didTapCloseButton:(UIBarButtonItem*)closeBarButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
