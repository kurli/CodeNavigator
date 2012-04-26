//
//  AppDelegate.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Utils.h"
#import "MGSplitViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DropBoxViewController.h"

@implementation AppDelegate
{
}

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[Utils getInstance] initVersion];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    [masterNavigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [masterViewController setIsProjectFolder:YES];

    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    [[Utils getInstance] setDetailViewController:detailViewController];

    self.splitViewController = [[MGSplitViewController alloc] init];
    [[Utils getInstance] setSplitViewController:self.splitViewController];
    self.splitViewController.delegate = detailViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailViewController, nil];
    
    //Banner support
#ifdef LITE_VERSION
    [[Utils getInstance] initBanner:detailViewController];
//    [self.window addSubview:[[Utils getInstance] getBannerViewController].view];
#endif
    //end
    [self.window addSubview:self.splitViewController.view];
    [self.window makeKeyAndVisible];
    
    // do not display divider
//    MGSplitViewDividerStyle newStyle = ((self.splitViewController.dividerStyle == MGSplitViewDividerStyleThin) ? MGSplitViewDividerStylePaneSplitter : MGSplitViewDividerStyleThin);
//	[self.splitViewController setDividerStyle:newStyle animated:YES];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
#ifdef LITE_VERSION
    [[[Utils getInstance] getBannerViewController] showBannerView];
#endif
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark DropBox support

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            [[Utils getInstance].dropBoxViewController loginSucceed];
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

@end
