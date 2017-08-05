//
//  MasterViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileListBrowserProtocol.h"
#ifdef IPHONE_VERSION
#import "FPPopoverController.h"
#else
#import "FileBrowserTreeViewController.h"
#endif

@class DetailViewController;
@class WebServiceController;
#ifndef LITE_VERSION
@class GitCloneViewController;
#endif
#ifdef IPHONE_VERSION
@class FileInfoControlleriPhone;
#endif
@class FileListBrowserController;
#ifdef IPHONE_VERSION
@class FPPopoverController;
#endif

#define MASTER_VIEW_RELOAD @"CodeNavigator_master_view_reload"

#ifdef IPHONE_VERSION
@interface MasterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FileListBrowserDelegate>
{
    NSInteger needSelectRowAfterReload;
}

#else
@interface MasterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FileListBrowserDelegate, FileBrowserTreeDelegate>
{
    NSInteger needSelectRowAfterReload;
}
#endif

@property (strong, nonatomic) NSString *currentProjectPath;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) WebServiceController *webServiceController;
#ifndef LITE_VERSION
@property (strong, nonatomic) GitCloneViewController *gitCloneViewController;
#endif
#ifdef IPHONE_VERSION
@property (strong, nonatomic) FPPopoverController* popOverController;
#else
@property (strong, nonatomic) UIPopoverController* popOverController;
#endif

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *analyzeButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *commentButton;

#ifdef LITE_VERSION
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *purchaseButton;

- (IBAction)purchaseClicked:(id)sender;
#endif

@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *fileSearchBar;

@property (strong, nonatomic) FileListBrowserController* fileListBrowserController;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

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

- (void) setNeedSelectRowAfterReload:(NSInteger)index;

- (void) showWebUploadService;

- (void) releaseAllPopover;

- (void) downloadZipFromGitHub;

- (void) uploadFromITunes;

- (void) showGitCloneViewWithUrl:(NSString*) url;

- (IBAction)openGrokButtonClicked:(NSString*)url andTitle:(NSString*)title;

@end

