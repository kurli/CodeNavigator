//
//  BannerViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

extern NSString * const BannerViewActionWillBegin;
extern NSString * const BannerViewActionDidFinish;

@interface BannerViewController : UIViewController <ADBannerViewDelegate>

- (id)initWithContentViewController:(UIViewController *)contentController;

- (void) hideBannerView;

- (void) showBannerView;

@end
