//
//  BannerViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BannerViewController.h"
#import "Utils.h"
#import "MasterViewController.h"
#import "GADBannerView.h"

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@implementation BannerViewController
{
    ADBannerView* iAdBannerView;
    GADBannerView* adModBannerView;
    MasterViewController *masterViewController;
    BOOL showBanner;
    BOOL isAdModGot;
    BOOL isTableViewSizeChanged;
}

- (id)initWithContentViewController:(UIViewController *)contentController
{
    self = [super init];
    if (self != nil) {
        masterViewController = (MasterViewController*)contentController;
        isAdModGot = NO;
        isTableViewSizeChanged = NO;
    }
    return self;
}

- (void) loadView
{
    [UIView animateWithDuration:0.25 animations:^{
        if ([[Utils getInstance] isAdModOn] == NO) {
            [masterViewController.view insertSubview:iAdBannerView aboveSubview:masterViewController.toolBar];
        } else {
            [masterViewController.view insertSubview:adModBannerView aboveSubview:masterViewController.toolBar];
        }
    }];
//    UIView *contentView = [[UIView alloc] initWithFrame:_contentController.view.frame];
//    [contentView addSubview:_bannerView];
//    [self addChildViewController:_contentController];
//    [contentView addSubview:_contentController.view];
//    [_contentController didMoveToParentViewController:self];
//    self.view = contentView;
}

- (void)viewDidLayoutSubviews
{
    if (isAdModGot == NO && iAdBannerView.bannerLoaded == NO) {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        if ([[Utils getInstance] isAdModOn] == NO) {
            iAdBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
        }
        //    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        //        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        //    } else {
        //        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
        //    }
        CGRect contentFrame = masterViewController.view.frame;
        CGRect tableViewFrame = masterViewController.tableView.frame;
        CGRect bannerFrame;
        if ([[Utils getInstance] isAdModOn] == NO) {
            bannerFrame = iAdBannerView.frame;
        } else {
            bannerFrame = adModBannerView.frame;
        }

        if ([[Utils getInstance] isAdModOn] == NO) {
            if (iAdBannerView.bannerLoaded) {
                CGRect frame = masterViewController.toolBar.frame;
                bannerFrame.origin.y = frame.origin.y - bannerFrame.size.height;
            } else {
                bannerFrame.origin.y = contentFrame.size.height;
            }
        } else {
            if (isAdModGot) {
                CGRect frame = masterViewController.toolBar.frame;
                bannerFrame.origin.y = frame.origin.y - bannerFrame.size.height;
            } else {
                bannerFrame.origin.y = contentFrame.size.height;
            }
        }
        if (isTableViewSizeChanged == NO) {
            tableViewFrame.size.height -= bannerFrame.size.height;
            [masterViewController.tableView setFrame:tableViewFrame];
            isTableViewSizeChanged = YES;
        }

        if ([[Utils getInstance] isAdModOn] == YES) {
            adModBannerView.frame = bannerFrame;
            [adModBannerView setHidden:NO];
        } else {
            iAdBannerView.frame = bannerFrame;
            [iAdBannerView setHidden:NO];
        }
    }];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [iAdBannerView setHidden:NO];
    if (showBanner == NO)
        return;
    [self viewDidLayoutSubviews];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    [adModBannerView setHidden:NO];
    isAdModGot = YES;
    if (showBanner == NO)
        return;
    [self viewDidLayoutSubviews];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self hideBannerView];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    isAdModGot = NO;
    [self hideBannerView];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
    return YES;
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
    if (isTableViewSizeChanged) {
        CGRect tableViewFrame = masterViewController.tableView.frame;
        tableViewFrame.size.height += bannerView.frame.size.height;
        [masterViewController.tableView setFrame:tableViewFrame];
        isTableViewSizeChanged = NO;
    }
}

- (void) hideBannerView
{
    [iAdBannerView setHidden:YES];
    [adModBannerView setHidden:YES];
    [iAdBannerView removeFromSuperview];
    [adModBannerView removeFromSuperview];
    adModBannerView = nil;
    iAdBannerView = nil;
}

- (void) showBannerView
{
    showBanner = YES;
    if ([[Utils getInstance] isAdModOn] == NO) {
        if (iAdBannerView == nil) {
            iAdBannerView = [[Utils getInstance] getIAdBannerView];
            iAdBannerView.delegate = self;
            [self loadView];
//            [self viewDidLayoutSubviews];
        }
    } else {
        if (adModBannerView == nil) {
            adModBannerView = [[Utils getInstance] getAdModBannerView];
            adModBannerView.delegate = self;
            [adModBannerView setHidden:YES];
            GADRequest *request = [GADRequest request];
            //request.testing = YES;
            [adModBannerView loadRequest:request];
            isAdModGot = NO;
            [self loadView];
            //[self viewDidLayoutSubviews];
        }
    }

}

@end
