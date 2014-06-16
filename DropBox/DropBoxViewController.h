//
//  DropBoxViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 4/5/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBSession;
@class DBRestClient;
@class LocalFileControllerDelegate;
@class RemoteFileControllerDelegate;

@interface DropBoxViewController : UIViewController
{
    BOOL isCurrentAlertCancelType;
    NSInteger downloadFileCount;
}

@property (nonatomic, strong) NSString *relinkUserId;

@property (nonatomic, strong) DBSession* dbSession;

@property (nonatomic, strong) DBRestClient* restClient;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *loginButton;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *localFileTableView;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *remoteFileTableView;

@property (nonatomic, strong) LocalFileControllerDelegate* localFileControllerDelegate;

@property (nonatomic, strong) RemoteFileControllerDelegate* remoteFileControllerDelegate;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *localTitleLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *remoteTitleLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *localBackButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *remoteBackButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *remoteIndicator;

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *remoteSelectedTextField;

@property (atomic, strong) NSMutableArray* pendingDownloadArray;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *SyncInfoView;

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *syncingIndicator;

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *syncStatusTextView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *syncFinishedLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *syncErrorTextView;

@property (unsafe_unretained) BOOL isSyncInProgress;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *remoteSyncButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *localSyncButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *backgroundView;

@property (strong, nonatomic) NSString *currentLoadFile;

@property (unsafe_unretained, nonatomic) IBOutlet UIProgressView *loadProgressView;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *retryButton;

- (IBAction)retryButtonClicked:(id)sender;

- (IBAction)localSyncButtonClicked:(id)sender;

- (IBAction)remoteSyncButtonClicked:(id)sender;

- (IBAction)syncButtonClicked:(id)sender;

- (IBAction)syncOkButtonClicked:(id)sender;

- (IBAction)syncCancelButtonCkicked:(id)sender;

- (IBAction)localBackClicked:(id)sender;

- (IBAction)remoteBackClicked:(id)sender;

- (void) showModualView;

- (IBAction) loginClicked:(id)sender;

- (IBAction) doneClicked:(id)sender;

- (void) loginSucceed;
@end
