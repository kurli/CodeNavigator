//
//  AppDelegate.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGSplitViewController;
@class DetailViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MGSplitViewController *splitViewController;

#ifdef IPHONE_VERSION
@property (strong, nonatomic) UINavigationController *masterNavigationController;

@property (strong, nonatomic) DetailViewController* detailViewController;
#endif

@end
