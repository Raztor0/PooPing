//
//  PPPrivacyPolicyViewController.m
//  PooPing
//
//  Created by Razvan Bangu on 2015-01-25.
//  Copyright (c) 2015 Raz. All rights reserved.
//

#import "PPPrivacyPolicyViewController.h"
#import "PPStoryboardNames.h"

@interface PPPrivacyPolicyViewController ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation PPPrivacyPolicyViewController

//+ (BSPropertySet *)bsProperties {
//    BSPropertySet *properties = [BSPropertySet propertySetWithClass:self propertyNames:@"webView", nil];
//    [properties bindProperty:@"webView" toKey:[UIWebView class]];
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
    UIStoryboard *storyboard = [injector getInstance:[UIStoryboard class] withArgs:PPPrivacyPolicyStoryboard, nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"Privacy Policy", @"Title of the privacy policy page");
    [super viewDidLoad];
    self.webView = [UIWebView new];
    [self.view addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://get.pooping.co/privacy-policy/"]];
    [self.webView loadRequest:request];
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapCloseBarButtonItem:)];
    self.navigationItem.leftBarButtonItem = closeBarButtonItem;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.frame;
}

#pragma mark - UIBarButtonItems

- (void)didTapCloseBarButtonItem:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
