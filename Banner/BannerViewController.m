//
//  BannerViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BannerViewController.h"
#import "Utils.h"
#import "DetailViewController.h"
#import "GADBannerView.h"

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@implementation BannerViewController
{
    ADBannerView* iAdBannerView;
    GADBannerView* adModBannerView;
    DetailViewController *detailViewController;
    BOOL showBanner;
    BOOL isAdModGot;
}

- (id)initWithContentViewController:(UIViewController *)contentController
{
    self = [super init];
    if (self != nil) {
        detailViewController = (DetailViewController*)contentController;
        isAdModGot = NO;
    }
    return self;
}

- (void) loadView
{
    [UIView animateWithDuration:0.25 animations:^{
        if ([[Utils getInstance] isAdModOn] == NO) {
            [detailViewController.view insertSubview:iAdBannerView aboveSubview:detailViewController.bottomToolBar];
        } else {
            [detailViewController.view insertSubview:adModBannerView aboveSubview:detailViewController.bottomToolBar];
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
        CGRect contentFrame = detailViewController.view.frame;
        CGRect bannerFrame;
        if ([[Utils getInstance] isAdModOn] == NO) {
            bannerFrame = iAdBannerView.frame;
        } else {
            bannerFrame = adModBannerView.frame;
        }

        if ([[Utils getInstance] isAdModOn] == NO) {
            if (iAdBannerView.bannerLoaded) {
                CGRect frame = detailViewController.bottomToolBar.frame;
                bannerFrame.origin.y = frame.origin.y - bannerFrame.size.height;
            } else {
                bannerFrame.origin.y = contentFrame.size.height;
            }
        } else {
            if (isAdModGot) {
                CGRect frame = detailViewController.bottomToolBar.frame;
                bannerFrame.origin.y = frame.origin.y - bannerFrame.size.height;
            } else {
                bannerFrame.origin.y = contentFrame.size.height;
            }
        }
        detailViewController.view.frame = contentFrame;
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
//            request.testing = YES;
            [adModBannerView loadRequest:request];
            isAdModGot = NO;
            [self loadView];
            //[self viewDidLayoutSubviews];
        }
    }

}

@end
