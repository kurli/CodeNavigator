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
#import "SecurityViewController.h"
#import "HandleURLController.h"
#import "iRate.h"

#import "GAI.h"

@implementation AppDelegate
{
}

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;
@synthesize handleURLController;
#ifdef IPHONE_VERSION
@synthesize masterNavigationController = _masterNavigationController;
@synthesize detailViewController;
#endif

//void uncaughtExceptionHandler(NSException*exception){
//    NSLog(@"CRASH: %@", exception);
//    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);
//    // Internal error reporting
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    [[Utils getInstance] initVersion];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

#ifndef IPHONE_VERSION
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
#else
    MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController-iPhone" bundle:nil];
    self.masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    [self.masterNavigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [masterViewController setIsProjectFolder:YES];
    [[Utils getInstance] setMasterViewController:self.masterNavigationController];
    
    self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController-iPhone" bundle:nil];
    [[Utils getInstance] setDetailViewController:self.detailViewController];
#endif
    
    //Banner support
#ifdef LITE_VERSION
    [[Utils getInstance] initBanner:detailViewController];
//    [self.window addSubview:[[Utils getInstance] getBannerViewController].view];
#endif
    //end
#ifndef IPHONE_VERSION
    //[self.window addSubview:self.splitViewController.view];
    [self.window setRootViewController:self.splitViewController];
    //self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
#else
    self.window.rootViewController = self.masterNavigationController;
    [self.window makeKeyAndVisible];
#endif
    
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([[Utils getInstance] isScreenLocked] == NO && [[Utils getInstance] isPasswardSet] != nil) {
            SecurityViewController* viewController = [[SecurityViewController alloc] init];
            [[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
        }
    });
    
    // Google Analytics// Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 120;
    // Optional: set debug to YES for extra debugging information.
    // Create tracker instance.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];

#ifdef LITE_VERSION
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-39030094-1"];
#else
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-39030094-2"];
#endif
    
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
    if ([[Utils getInstance] isScreenLocked] == NO && [[Utils getInstance] isPasswardSet] != nil) {
        SecurityViewController* viewController = [[SecurityViewController alloc] init];
        [[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
    }
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
    // Write history controller data to file
    // FIXME: If current active view is down, the location will be failed to updated
    DetailViewController* detailViewController = [Utils getInstance].detailViewController;
    int location = [detailViewController getCurrentScrollLocation];
    [detailViewController.historyController updateCurrentScrollLocation:location];
    
    [HistoryController writeToFile];
    
    // Download background.
//    UIApplication  *app = [UIApplication sharedApplication];
//    UIBackgroundTaskIdentifier bgTask;
//    
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:bgTask];
//    }];
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

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [self setHandleURLController:nil];
}

#pragma mark DropBox support

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
#ifndef IPHONE_VERSION
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            [[Utils getInstance].dropBoxViewController loginSucceed];
            // At this point you can start making API calls
        }
        return YES;
    }
#endif
    if (handleURLController == nil) {
        handleURLController = [[HandleURLController alloc] init];
    }
    else {
        if ([handleURLController isBusy]) {
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"CodeNavigator is busy now, Please wait for a while"];
            return NO;
        }
    }

    BOOL isSupported = [handleURLController checkWhetherSupported:url];
    if (!isSupported) {
        return NO;
    }
    [handleURLController setFilePath:[url absoluteString]];
    BOOL handled = [handleURLController handleFile:[url absoluteString]];
    // Add whatever other url handling code your app requires here
    return handled;
}

@end
