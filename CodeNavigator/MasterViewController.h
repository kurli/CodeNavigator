//
//  MasterViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileListBrowserProtocol.h"

@class DetailViewController;
@class WebServiceController;
@class GitCloneViewController;
#ifdef IPHONE_VERSION
@class FileInfoControlleriPhone;
#endif
@class FileListBrowserController;

#define MASTER_VIEW_RELOAD @"CodeNavigator_master_view_reload"

@interface MasterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FileListBrowserDelegate>
{
    int needSelectRowAfterReload;
}

@property (strong, nonatomic) NSString *currentProjectPath;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) WebServiceController *webServiceController;

@property (strong, nonatomic) GitCloneViewController *gitCloneViewController;

@property (strong, nonatomic) UIPopoverController* popOverController;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *analyzeButton;

#ifdef LITE_VERSION
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *purchaseButton;

- (IBAction)purchaseClicked:(id)sender;
#endif

@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *fileSearchBar;

#ifdef IPHONE_VERSION
@property (strong, nonatomic) FileInfoControlleriPhone* fileInfoControlleriPhone;
#endif

@property (strong, nonatomic) FileListBrowserController* fileListBrowserController;

- (IBAction)addFileToolBarClicked:(id)sender;

- (void) reloadData;

- (void) setIsProjectFolder:(BOOL) _isProjectFolder;

- (void) gotoFile:(NSString*) filePath andForce:(BOOL)force;

- (IBAction)analyzeButtonClicked:(id)sender;

- (IBAction)gitClicked:(id)sender;

- (IBAction)dropBoxClicked:(id)sender;

- (IBAction)versionControlButtonClicked:(id)sender;

- (IBAction)lockButtonClicked:(id)sender;

- (IBAction)commentClicked:(id)sender;

- (IBAction)helpButtonClicked:(id)sender;

- (void) showGitCloneView;

- (NSString*) getCurrentLocation;

- (void) setNeedSelectRowAfterReload:(int)index;

- (void) showWebUploadService;

- (void) releaseAllPopover;

- (void) downloadZipFromGitHub;

@end

