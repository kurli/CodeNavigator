//
//  DropBoxViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 4/5/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "DropBoxViewController.h"
#import "Utils.h"
#import <DropboxSDK/DropboxSDK.h>
#import "LocalFileControllerDelegate.h"
#import "RemoteFileControllerDelegate.h"
#import "MasterViewController.h"

@interface DropBoxViewController () <DBSessionDelegate, DBRestClientDelegate>

@end

@implementation DropBoxViewController

@synthesize relinkUserId;
@synthesize dbSession;
@synthesize restClient;
@synthesize loginButton;
@synthesize localFileTableView;
@synthesize remoteFileTableView;
@synthesize localFileControllerDelegate;
@synthesize remoteFileControllerDelegate;
@synthesize localTitleLabel;
@synthesize remoteTitleLabel;
@synthesize localBackButton;
@synthesize remoteBackButton;
@synthesize remoteIndicator;
@synthesize remoteSelectedTextField;
@synthesize pendingDownloadArray;
@synthesize SyncInfoView;
@synthesize syncingIndicator;
@synthesize syncStatusTextView;
@synthesize syncFinishedLabel;
@synthesize syncErrorTextView;
@synthesize isSyncInProgress;
@synthesize remoteSyncButton;
@synthesize localSyncButton;
@synthesize backgroundView;
@synthesize currentLoadFile;
@synthesize loadProgressView;
@synthesize retryButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        localFileControllerDelegate = [[LocalFileControllerDelegate alloc] init];
        remoteFileControllerDelegate = [[RemoteFileControllerDelegate alloc] init];
        isSyncInProgress = NO;
        isCurrentAlertCancelType = NO;
        downloadFileCount = 0;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void) setSyncFinishedText:(NSString*)text2
{
    [self.syncFinishedLabel setText:text2];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
//    if ([[DBSession sharedSession] isLinked]) {
//        [[DBSession sharedSession] unlinkAll];
//    }
//    [self setRelinkUserId:nil];
//    [self.pendingDownloadArray removeAllObjects];
//    [self setPendingDownloadArray:nil];
//    [self setDbSession:nil];
    [self setLoginButton:nil];
    [self setLocalFileTableView:nil];
    [self setRemoteFileTableView:nil];
    [self setLocalTitleLabel:nil];
    [self setRemoteTitleLabel:nil];
    [self setLocalBackButton:nil];
    [self setRemoteBackButton:nil];
    [self setRemoteIndicator:nil];
    [self setRemoteSelectedTextField:nil];
    [self setSyncInfoView:nil];
    [self setSyncingIndicator:nil];
    [self setSyncStatusTextView:nil];
    [self setSyncFinishedText:nil];
    [self setSyncErrorTextView:nil];
    [self setRemoteSyncButton:nil];
    [self setLocalSyncButton:nil];
    [self setBackgroundView:nil];
    [self setCurrentLoadFile:nil];
    [self setLoadProgressView:nil];
    [self setRetryButton:nil];
    //[self setLocalFileControllerDelegate:nil];
    //[self setRemoteFileControllerDelegate:nil];
    [self setSyncFinishedLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)dealloc
{
//    if ([[DBSession sharedSession] isLinked]) {
//        [[DBSession sharedSession] unlinkAll];
//    }
    [self setRelinkUserId:nil];
    [self.pendingDownloadArray removeAllObjects];
    [self setPendingDownloadArray:nil];
    [self setDbSession:nil];
    [self setLoginButton:nil];
    [self setLocalFileTableView:nil];
    [self setRemoteFileTableView:nil];
    [self setLocalTitleLabel:nil];
    [self setRemoteTitleLabel:nil];
    [self setLocalBackButton:nil];
    [self setRemoteBackButton:nil];
    [self setRemoteIndicator:nil];
    [self setRemoteSelectedTextField:nil];
    [self setSyncInfoView:nil];
    [self setSyncingIndicator:nil];
    [self setSyncStatusTextView:nil];
    [self setSyncFinishedText:nil];
    [self setSyncErrorTextView:nil];
    [self setRemoteSyncButton:nil];
    [self setLocalSyncButton:nil];
    [self setBackgroundView:nil];
    [self setCurrentLoadFile:nil];
    [self setLoadProgressView:nil];
    [self setRetryButton:nil];
    [self setLocalFileControllerDelegate:nil];
    [self setRemoteFileControllerDelegate:nil];
    [self setSyncFinishedLabel:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    }
	return NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[DBSession sharedSession] isLinked]) {
        [loginButton setTitle:@"Log out"];
        [self loginSucceed];
    }
    else {
        [loginButton setTitle:@"Log in"];
    }
    [self.localFileControllerDelegate setLocalTableView:self.localFileTableView];
    [self.localFileControllerDelegate setTitleLabel:self.localTitleLabel];
    [self.localFileControllerDelegate setBackButton:self.localBackButton];
    [self.localFileControllerDelegate setRefreshButton:self.localSyncButton];
    [self.localFileControllerDelegate reloadData];
    
    [self.remoteFileControllerDelegate setRemoteTableView:self.remoteFileTableView];
    [self.remoteFileControllerDelegate setTitleLabel:self.remoteTitleLabel];
    [self.remoteFileControllerDelegate setBackButton:self.remoteBackButton];
    [self.remoteFileControllerDelegate setRemoteIndicator:self.remoteIndicator];
    [self.remoteFileControllerDelegate setRefreshButton:self.remoteSyncButton];
    [self.remoteIndicator setHidden:YES];
    
    CGRect rect = self.SyncInfoView.frame;
    rect.origin.y = self.view.frame.size.height;
    [self.SyncInfoView setFrame:rect];
    [self.syncingIndicator stopAnimating];
    [self.syncingIndicator setHidden:YES];
    rect = self.backgroundView.frame;
    rect.origin.y = self.view.frame.size.height;
    [self.backgroundView setFrame:rect];
}

#pragma mark - DropBoxAPI

- (void) setSyncStatusText:(NSString*)text2
{
    NSString* text = self.syncStatusTextView.text;
    text = [text stringByAppendingString:text2];
    [syncStatusTextView setText:text];
    NSRange range;
	range.location= [syncStatusTextView.text length] -6;
	range.length= 5;
	[syncStatusTextView scrollRangeToVisible:range];
}

- (void) setSyncErrorText:(NSString*)text2
{
    NSString* text = self.syncErrorTextView.text;
    text = [text stringByAppendingString:text2];
    [syncErrorTextView setText:text];
    NSRange range;
	range.location= [syncErrorTextView.text length] -6;
	range.length= 5;
	[syncErrorTextView scrollRangeToVisible:range];
}

- (void) authentication
{
    self.dbSession =
    [[DBSession alloc]
      initWithAppKey:@"bqhgzckmfs89awp"
      appSecret:@"6q6tkdm67izc7dm"
      root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];
    [self.dbSession setDelegate:self];
}

-(void) downloadFinished
{
    [self.syncingIndicator stopAnimating];
    [self.syncingIndicator setHidden:YES];
    [self.syncFinishedLabel setText:@""];
    if ([self.syncErrorTextView.text length] == 0) {
        [[Utils getInstance] alertWithTitle:@"Dropbox Sync" andMessage:@"Sync complete"];
        return;
    }else {
        [[Utils getInstance] alertWithTitle:@"Dropbox Sync" andMessage:@"Some of the files synced failed\nPlease press Retry to sync again."];
    }
    [retryButton setHidden:NO];
}

-(BOOL) syncNextFile
{
    if ([self.pendingDownloadArray count] == 0) {
        [self downloadFinished];
        return NO;
    }
    SelectionItem* item = [pendingDownloadArray lastObject];
    if (item.fileName == nil) {
        NSLog(@"error");
        return NO;
    }
    
#ifdef LITE_VERSION
    int limitCount = 0;
    for (int i=0; i<[pendingDownloadArray count]; i++) {
        SelectionItem* obj = [pendingDownloadArray objectAtIndex:i];
        if ([obj.path rangeOfString:@"/.git/"].location != NSOrderedSame) {
            limitCount++;
        }
    }
    
    if (limitCount > 5) {
        [[Utils getInstance] showPurchaseAlert];
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Maximum number of source files exceeded for Lite Version."];
        [pendingDownloadArray removeAllObjects];
        [self.syncingIndicator setHidden:YES];
        [self.syncingIndicator stopAnimating];
        [restClient cancelFileLoad:currentLoadFile];
        return NO;
    }
#endif

    NSString* localPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    localPath = [localPath stringByAppendingPathComponent:item.path];
    localPath = [localPath stringByAppendingPathComponent:item.fileName];
    NSString* remotePath = [item.path stringByAppendingPathComponent:item.fileName];
    [pendingDownloadArray removeLastObject];
    NSString* text = [NSString stringWithFormat:@"----Load File:\n%@\n", remotePath];
    [self setSyncStatusText:text];
    NSError* error;
    [[NSFileManager defaultManager] createDirectoryAtPath:[localPath stringByDeletingLastPathComponent]     withIntermediateDirectories:YES attributes:nil error:&error];
    [self.restClient loadFile:remotePath intoPath:localPath];
    self.currentLoadFile = remotePath;
    
//    SelectionItem* item2 = [pendingDownloadArray lastObject];
//    if (item2 == nil) {
//        return YES;
//    }
//    if (item2.fileName == nil) {
//        return YES;
//    }
//    NSString* localPath2 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
//    localPath2 = [localPath2 stringByAppendingPathComponent:item2.path];
//    localPath2 = [localPath2 stringByAppendingPathComponent:item2.fileName];
//    NSString* remotePath2 = [item2.path stringByAppendingPathComponent:item2.fileName];
//    [pendingDownloadArray removeLastObject];
//    NSString* text2 = [NSString stringWithFormat:@"----Load File:\n%@\n", remotePath2];
//    [self setSyncStatusText:text2];
//    NSError* error2;
//    [[NSFileManager defaultManager] createDirectoryAtPath:[localPath2 stringByDeletingLastPathComponent]     withIntermediateDirectories:YES attributes:nil error:&error2];
//    [self.restClient loadFile:remotePath2 intoPath:localPath2];
//    self.currentLoadFile = remotePath2;
    return YES;
}

-(BOOL) syncNextPath
{
    if ([self.pendingDownloadArray count] == 0) {
        return NO;
    }
    SelectionItem* item = [pendingDownloadArray objectAtIndex:0];
    if (item.fileName != nil) {
        downloadFileCount = [pendingDownloadArray count];
        [self syncNextFile];
        return NO;
    }
    NSString* text = [NSString stringWithFormat:@"----Generate Path:\n%@\n", item.path];
    [self setSyncStatusText:text];
    [pendingDownloadArray removeObjectAtIndex:0];
    [self.restClient loadMetadata:item.path];
    NSString *path;
    if ([item.path characterAtIndex:[item.path length] - 1] != '/') {
        path = [NSString stringWithFormat:@"%@/", item.path];
    }
    else {
        path = item.path;
    }
    self.currentLoadFile = path;
    return YES;
}

#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    if (self.isSyncInProgress) {
        if (metadata.isDirectory == YES) {
            for (DBMetadata* child in metadata.contents) {
                SelectionItem* item = [[SelectionItem alloc] init];
                item.path = child.path;
                if (child.isDirectory) {
                    item.fileName = nil;
                    [self.pendingDownloadArray insertObject:item atIndex:0];
                }
                else {
                    item.path = [item.path stringByDeletingLastPathComponent];
                    item.fileName = child.filename;
                    [self.pendingDownloadArray addObject:item];
                }
            }
        } else {
            // it's a file
            SelectionItem* item = [[SelectionItem alloc] init];
            item.path = metadata.path;
            item.path = [item.path stringByDeletingLastPathComponent];
            item.fileName = metadata.filename;
            [self.pendingDownloadArray addObject:item];
        }
        [self syncNextPath];
    }else {
        [self.remoteFileControllerDelegate reloadWithMetaData:metadata];
        [self.remoteSyncButton setHidden:NO];
    }
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
    NSLog(@"metadataUnchangedAtPath : %@", path);
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    if (isSyncInProgress) {
        NSString* text = [NSString stringWithFormat:@"%@\n", currentLoadFile];
        [self setSyncErrorText:text];
        [self syncNextPath];
    }
    else {
        [self.remoteFileControllerDelegate reloadWithMetaData:nil];
    }
}

- (void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath
{
    if (isSyncInProgress) {
        if (progress == 1) {
            //delete local display file
            NSError* error;
            NSString* displayFile = [[Utils getInstance] getDisplayPath:destPath];
            [[NSFileManager defaultManager] removeItemAtPath:displayFile error:&error];
            
            destPath = [[Utils getInstance] getPathFromProject:destPath];
            NSString* text = [NSString stringWithFormat:@"%@", destPath];
            [self setSyncFinishedText:text];
            float a = downloadFileCount;
            float b = downloadFileCount-[pendingDownloadArray count];
            float percent = b/a;
            [self.loadProgressView setProgress:percent];
            [self syncNextFile];
        }
    }
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
// [error userInfo] contains the destinationPath
{
    if (isSyncInProgress) {
        NSString* text = [NSString stringWithFormat:@"%@\n", currentLoadFile];
        [self setSyncErrorText:text];
        float a = downloadFileCount;
        float b = downloadFileCount-[pendingDownloadArray count];
        float percent = b/a;
        [self.loadProgressView setProgress:percent];
        [self syncNextFile];
    }
    else {
        NSLog(@"dsjflkasjflkaj");
    }
}

#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
	self.relinkUserId = userId;
    isCurrentAlertCancelType = NO;
	[[[UIAlertView alloc] 
	   initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self 
	   cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil]
	 show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
    if (isCurrentAlertCancelType == YES) {
        if (index != alertView.cancelButtonIndex) {
            for (int i=0; i<[pendingDownloadArray count]; i++) {
                SelectionItem* item = [pendingDownloadArray objectAtIndex:i];
                if (item.fileName == nil) {
                    NSString* path = [item.path stringByAppendingString:@"/\n"];
                    [self setSyncErrorText:path];
                } else {
                    NSString* path = [item.path stringByAppendingFormat:@"/%@\n", item.fileName];
                    [self setSyncErrorText:path];
                }
            }
            [self.pendingDownloadArray removeAllObjects];
            NSString* text = [NSString stringWithFormat:@"----Sync Canceled...\n"];
            [self setSyncStatusText:text];
            [restClient cancelAllRequests];
        }
        return;
    }
	if (index != alertView.cancelButtonIndex) {
        [[DBSession sharedSession] linkUserId:relinkUserId fromController:self];
//		[[DBSession sharedSession] linkUserId:relinkUserId];
	}
	self.relinkUserId = nil;
}

#pragma mark - Exported API

- (void) loginSucceed
{
    restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = self;
    [loginButton setTitle:@"Log out"];
    [self.remoteFileControllerDelegate setRestClient: restClient];
    [self.remoteIndicator setHidden:NO];
    [self.remoteIndicator startAnimating];
    [self.restClient loadMetadata:@"/"];
    [self.remoteFileControllerDelegate setCurrentLocation:@"/"];
}

- (IBAction)retryButtonClicked:(id)sender {
    NSArray* array = [self.syncErrorTextView.text componentsSeparatedByString:@"\n"];
    [pendingDownloadArray removeAllObjects];
    for (int i=0; i<[array count]; i++) {
        NSString* item = [array objectAtIndex:i];
        if ([item length] == 0) {
            continue;
        }
        SelectionItem* selectedItem = [[SelectionItem alloc] init];
        if ([item characterAtIndex:[item length]-1] == '/') {
            selectedItem.path = item;
            selectedItem.fileName = 0;
            [pendingDownloadArray insertObject:selectedItem atIndex:0];
        } else {
            selectedItem.path = [item stringByDeletingLastPathComponent];
            selectedItem.fileName = [item lastPathComponent];
            [pendingDownloadArray addObject:selectedItem];
        }
    }
    [self.loadProgressView setProgress:0];
    [retryButton setHidden:YES];
    [self.syncErrorTextView setText:@""];
    [self.syncingIndicator startAnimating];
    [self.syncingIndicator setHidden:NO];
    [self syncNextPath];
}

- (IBAction)localSyncButtonClicked:(id)sender {
    [self.localFileControllerDelegate reloadData];
}

- (IBAction)remoteSyncButtonClicked:(id)sender {
    [self.restClient loadMetadata:self.remoteFileControllerDelegate.currentLocation];
    [self.remoteSyncButton setHidden:YES];
    [self.remoteIndicator setHidden:NO];
    [self.remoteIndicator startAnimating];
}

- (IBAction)syncButtonClicked:(id)sender {
    NSMutableArray* selectedArray = self.remoteFileControllerDelegate.selectedArray;
    [self.pendingDownloadArray removeAllObjects];
    self.pendingDownloadArray = [[NSMutableArray alloc] init];
    NSMutableString* str = [[NSMutableString alloc] init];
    
    // First get all folder's
    for (int i=0; i<[selectedArray count]; i++) {
        SelectionItem* item = [selectedArray objectAtIndex:i];
        if (item.fileName != nil) {
            continue;
        }
        BOOL founded = NO;
        for (int j=0; j<[self.pendingDownloadArray count]; j++) {
            SelectionItem* pendingItem = [self.pendingDownloadArray objectAtIndex:j];
            NSRange range = [item.path rangeOfString:pendingItem.path];
            if (range.location == 0) {
                if (range.length == [item.path length] || [item.path characterAtIndex:range.length] == '/') {
                    founded = YES;
                    break;
                }
            }
        }
        if (founded) {
            continue;
        }
        [self.pendingDownloadArray addObject:item];
        [str appendFormat:@"%@/*\n", item.path];
    }
    // check all files
    for (int i=0; i<[selectedArray count]; i++) {
        SelectionItem* item = [selectedArray objectAtIndex:i];
        NSLog(@"%@ %@",item.path, item.fileName);
        if (item.fileName == nil) {
            continue;
        }
        BOOL founded = NO;
        for (int j=0; j<[self.pendingDownloadArray count]; j++) {
            SelectionItem* pendingItem = [self.pendingDownloadArray objectAtIndex:j];
            if (pendingItem.fileName != nil) {
                break;
            }
            NSRange range = [item.path rangeOfString:pendingItem.path];
            if (range.location == 0) {
                if (range.length == [item.path length] || [item.path characterAtIndex:range.length] == '/') {
                    founded = YES;
                    NSLog(@"Founded %@", pendingItem.path);
                    break;
                }
            }
        }
        if (founded) {
            continue;
        }
        [self.pendingDownloadArray addObject:item];
        [str appendFormat:@"%@/%@\n", item.path, item.fileName];
    }
    [self.remoteSelectedTextField setText:str];

    if ([self.pendingDownloadArray count] == 0) {
        // No need to sync, no file selected
        [[Utils getInstance] alertWithTitle:@"Dropbox Sync" andMessage:@"Please select files to sync"];
        return;
    }
    
    isSyncInProgress = YES;
    // Show sync view
    [UIView beginAnimations:@"WebViewAnimate"context:nil];
    [UIView setAnimationDuration:0.30];
    CGRect rect = self.SyncInfoView.frame;
    rect.origin.y = 0;
    [self.SyncInfoView setFrame:rect];
    [UIView commitAnimations];
    rect = self.backgroundView.frame;
    rect.origin.y = 0;
    [self.backgroundView setFrame:rect];
}

- (IBAction)syncOkButtonClicked:(id)sender {
    [self.syncErrorTextView setText:@""];
    if ([pendingDownloadArray count] == 0) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Sync has completed, please select files to sync"];
        [self.syncingIndicator setHidden:YES];
        [self.syncingIndicator stopAnimating];
        [self syncCancelButtonCkicked:nil];
        return;
    }
    [self.loadProgressView setProgress:0];
    [self.syncingIndicator setHidden:NO];
    [self.syncingIndicator startAnimating];
    
    //delete file list
    SelectionItem* item = [pendingDownloadArray objectAtIndex:0];
    NSArray* array = [item.path componentsSeparatedByString:@"/"];
    if ([array count] < 2) {
        return;
    }
    
    NSString* localPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    localPath = [localPath stringByAppendingFormat:@"/%@", [array objectAtIndex:1]];

    NSString* databaseFile = [localPath stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
    NSError* error;
    [[NSFileManager defaultManager] removeItemAtPath:databaseFile error:&error];
    databaseFile = [localPath stringByAppendingPathComponent:@"search_files.lgz_proj_files"];
    [[NSFileManager defaultManager] removeItemAtPath:databaseFile error:&error];
    [self syncNextPath];
}

- (IBAction)syncCancelButtonCkicked:(id)sender {
    if ([self.syncingIndicator isAnimating] == YES) {
        isCurrentAlertCancelType = YES;
        [[[UIAlertView alloc] 
          initWithTitle:@"Dropbox Sync" message:@"Sync in progress, do you want to cancel it?" delegate:self 
          cancelButtonTitle:@"Continue sync" otherButtonTitles:@"Stop sync", nil]
         show];
        return;
    }
    [UIView beginAnimations:@"WebViewAnimate"context:nil];
    [UIView setAnimationDuration:0.30];
    CGRect rect = self.SyncInfoView.frame;
    rect.origin.y = self.view.frame.size.height;
    [self.SyncInfoView setFrame:rect];
    [UIView commitAnimations];
    [self.syncingIndicator stopAnimating];
    [self.syncingIndicator setHidden:YES];
    rect = self.backgroundView.frame;
    rect.origin.y = self.view.frame.size.height;
    [self.backgroundView setFrame:rect];
    isSyncInProgress = NO;
}

- (IBAction)localBackClicked:(id)sender {
    [self.localFileControllerDelegate backButtonClicked];
}

- (IBAction)remoteBackClicked:(id)sender {
    [self.remoteFileControllerDelegate backButtonClicked];
}

- (void) showModualView
{
    [[Utils getInstance].splitViewController presentModalViewController:self animated:YES];
    [self authentication];
}

- (IBAction)loginClicked:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
//        [[DBSession sharedSession] link];
        [[DBSession sharedSession] linkFromController:self];
    }
    else {
        [restClient cancelFileLoad:currentLoadFile];
        [[DBSession sharedSession] unlinkAll];
        [self setRestClient:nil];
        self.relinkUserId = nil;
        [[Utils getInstance].splitViewController dismissModalViewControllerAnimated:YES];
        
        MasterViewController* masterViewController = nil;
        NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
        masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
        [masterViewController reloadData];
    }
}

- (IBAction)doneClicked:(id)sender {
//    if ([[DBSession sharedSession] isLinked]) {
//        [[DBSession sharedSession] unlinkAll];
//        self.relinkUserId = nil;
//    }
    [[Utils getInstance].splitViewController dismissModalViewControllerAnimated:YES];
    MasterViewController* masterViewController = nil;
    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
    [masterViewController reloadData];
    [[Utils getInstance] setDropBoxViewController:nil];
}

#pragma tableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.localFileTableView) {
        [localFileControllerDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else if(tableView == self.remoteFileTableView) {
        [remoteFileControllerDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableView == self.localFileTableView) {
        return [localFileControllerDelegate tableView:_tableView cellForRowAtIndexPath:indexPath];
    } else if(_tableView == self.remoteFileTableView) {
        return [remoteFileControllerDelegate tableView:_tableView cellForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.localFileTableView) {
        return [localFileControllerDelegate tableView:tableView numberOfRowsInSection:section];
    } else if(tableView == self.remoteFileTableView) {
        return [remoteFileControllerDelegate tableView:tableView numberOfRowsInSection:section];
    }
    return 0;
}

@end
