//
//  MasterViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class WebServiceController;

@interface MasterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    BOOL isProjectFolder;
}
@property (strong, nonatomic) NSString *currentLocation;

@property (strong, nonatomic) NSMutableArray *currentDirectories;

@property (strong, nonatomic) NSMutableArray *currentFiles;

@property (strong, nonatomic) NSString *currentProjectPath;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) WebServiceController *webServiceController;

@property (strong, nonatomic) UIPopoverController *webServicePopOverController;

@property (strong, nonatomic) UIPopoverController* versionControllerPopOverController; 

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *analyzeButton;

#ifdef LITE_VERSION
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *purchaseButton;

- (IBAction)purchaseClicked:(id)sender;
#endif

- (IBAction)addFileToolBarClicked:(id)sender;

- (void) reloadData;

- (void) setIsProjectFolder:(BOOL) _isProjectFolder;

- (void) gotoFile:(NSString*) filePath;

- (IBAction)analyzeButtonClicked:(id)sender;

- (IBAction)gitClicked:(id)sender;

- (IBAction)dropBoxClicked:(id)sender;

- (IBAction)versionControlButtonClicked:(id)sender;

- (IBAction)lockButtonClicked:(id)sender;

@end

