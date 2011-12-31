//
//  BannerViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BannerViewController.h"
#import "Utils.h"

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@implementation BannerViewController
{
    ADBannerView *_bannerView;
    UIViewController *_contentController;
    BOOL showBanner;
}

- (id)initWithContentViewController:(UIViewController *)contentController
{
    self = [super init];
    if (self != nil) {
        _contentController = contentController;
    }
    return self;
}

- (void) loadView
{
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [contentView addSubview:_bannerView];
    [self addChildViewController:_contentController];
    [contentView addSubview:_contentController.view];
    [_contentController didMoveToParentViewController:self];
    self.view = contentView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [_contentController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)viewDidLayoutSubviews
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    CGRect contentFrame = self.view.bounds;
    CGRect bannerFrame = _bannerView.frame;
    if (_bannerView.bannerLoaded) {
        contentFrame.size.height -= _bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    _contentController.view.frame = contentFrame;
    _bannerView.frame = bannerFrame;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (showBanner == NO)
        return;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self hideBannerView];
}


- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
}

- (void) hideBannerView
{
    showBanner = NO;
    if (_bannerView != nil)
    {
        _bannerView.delegate = nil;
        _bannerView.frame = CGRectMake(0, 0, 0, 0);
        _bannerView = nil;
        [UIView animateWithDuration:0.25 animations:^{
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
    }
}

- (void) showBannerView
{
    showBanner = YES;
    if (_bannerView == nil)
    {
        _bannerView = [[Utils getInstance] getBannerView];
        _bannerView.delegate = self;
        [UIView animateWithDuration:0.25 animations:^{
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
    }
}

@end
