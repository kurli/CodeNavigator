//
//  WebServiceController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"
#import "FileBrowserViewProtocol.h"
#import "FPPopoverController.h"

@class HTTPServer;
@protocol WebUploadResultDelegate;
@class MasterViewController;

@interface WebServiceController : UIViewController <WebUploadResultDelegate, UITableViewDelegate, UITableViewDataSource, FileBrowserViewDelegate>
{
    BOOL needStopZip;
}

- (IBAction)selectionChanged:(id)sender;

-(void) unzipThread;

-(void) startUploadingFile:(NSString *)file;

-(void) finishUploadingFile:(NSString *)file;

-(void) log:(NSString *)text;

-(void) setProgressViewValue: (NSNumber*)value;

-(void) analyzeProject:(NSString*)path;

-(NSString*) getUploadToPathRelative;

#ifdef IPHONE_VERSION
- (IBAction)doneButtonClicked:(id)sender;
#endif

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textView;

@property (unsafe_unretained, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) HTTPServer* httpServer;

@property (strong, nonatomic) NSDictionary *internetAddress;

@property (strong, nonatomic) NSThread* thread;

@property (strong, atomic) NSMutableArray* zipFiles;

@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *webServiceSwitcher;

@property (strong, nonatomic) MasterViewController* masterViewController;

@property (strong, atomic) NSString* uploadToPath;

#ifdef IPHONE_VERSION
@property (strong, nonatomic) FPPopoverController* popOverController;
#else
@property (strong, nonatomic) UIPopoverController* popOverController;
#endif

@property (unsafe_unretained, nonatomic) IBOutlet  UITableView *_tableView;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *stopButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (IBAction)onStopClicked:(id)sender;

- (void)fileBrowserViewDisappeared;

- (void)folderSelected:(NSString*)path;


@end
