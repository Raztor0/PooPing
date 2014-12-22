//
//  PPMainViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2014-12-22.
//  Copyright (c) 2014 Raz. All rights reserved.
//

#import "PPMainViewController.h"
#import "PPStoryboardNames.h"
#import "PPHomeViewController.h"
#import "PPFriendsListViewController.h"
#import "UIView+ConstraintHelpers.h"

@interface PPMainViewController ()

@property (nonatomic, strong) PPHomeViewController *homeViewController;
@property (nonatomic, strong) PPFriendsListViewController *friendsListViewController;

@end

@implementation PPMainViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"homeViewController", @"friendsListViewController", nil];
    [properties bindProperty:@"homeViewController" toKey:[PPHomeViewController class]];
    [properties bindProperty:@"friendsListViewController" toKey:[PPFriendsListViewController class]];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentScrollView.pagingEnabled = YES;
    
    self.homeViewController.view.frame = self.view.bounds;
    self.friendsListViewController.view.frame = CGRectMake(self.view.bounds.size.width, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [self.contentScrollView addSubview:self.homeViewController.view];
    [self.contentScrollView addSubview:self.friendsListViewController.view];
    
    [self.homeViewController.view addConstraints:[self.homeViewController.view constrainHorizontallyToFitSuperview:self.contentScrollView]];
    [self.homeViewController.view addConstraints:[self.homeViewController.view constrainVerticallyToFitSuperview:self.contentScrollView]];
    
    [self.friendsListViewController.view addConstraint:[self.friendsListViewController.view constrainRightOfView:self.homeViewController.view toLeftOfView:self.friendsListViewController.view]];
    [self.friendsListViewController.view addConstraint:[self.friendsListViewController.view constrainView:self.friendsListViewController.view toView:self.contentScrollView withEqual:NSLayoutAttributeWidth]];
    
    [self addChildViewController:self.homeViewController];
    [self addChildViewController:self.friendsListViewController];
    [self.homeViewController didMoveToParentViewController:self];
    [self.friendsListViewController didMoveToParentViewController:self];
}

@end
