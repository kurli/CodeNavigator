//
//  DetailViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HistoryController.h"
#import "MasterViewController.h"
#import "NavigationController.h"
#import "ResultViewController.h"
#import "GotoLineViewController.h"
#import "MGSplitViewController.h"
#import "DisplayModeController.h"

typedef enum _JSState {
    JS_NONE,
    JS_GOTO_LINE_AND_FOCUS_KEYWORD,
    JS_HISTORY_MODE,
} JSState;

@class NavigationController;
@class ResultViewController;
@class GotoLineViewController;
@class FilePathInfoPopupController;
@class HighLightWordController;
@class HistoryListController;
@class PercentViewController;

@interface DetailViewController : UIViewController <UIWebViewDelegate, UIGestureRecognizerDelegate, UIPopoverControllerDelegate, MGSplitViewControllerDelegate>
{
    int currentSearchFocusLine;
    int searchLineTotal;
    BOOL shownToolBar;
    
    //JSState related
    JSState jsState;
    int jsGotoLine;
    int jsHistoryModeScrollY;
    //end
}
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *navigateBarButtonItem;

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *titleTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *countTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *resultBarButton;

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *historyBar;

@property (strong, nonatomic) NSString *searchWord;

@property (strong, nonatomic) HistoryController* historyController;

@property (strong, nonatomic) NavigationController* codeNavigationController;

@property (strong, nonatomic) UIPopoverController *codeNavigationPopover;

@property (strong, nonatomic) ResultViewController *resultViewController;

@property (strong, nonatomic) UIPopoverController *resultPopover;

@property (strong, nonatomic) GotoLineViewController *gotoLineViewController;

@property (strong, nonatomic) UIPopoverController *gotoLinePopover;

@property (strong, nonatomic) FilePathInfoPopupController* filePathInfoController;

@property (strong, nonatomic) UIPopoverController* filePathInfopopover;

@property (strong, nonatomic) HighLightWordController* highlightWordController;

@property (strong, nonatomic) UIPopoverController* highlghtWordPopover;

@property (strong, nonatomic) DisplayModeController* displayModeController;

@property (strong, nonatomic) UIPopoverController* displayModePopover;

@property (strong, nonatomic) HistoryListController* historyListController;

@property (strong, nonatomic) UIPopoverController* historyListPopover;

@property (strong, nonatomic) PercentViewController* percentViewController;

@property (strong, nonatomic) UIPopoverController* percentPopover;

@property (strong, nonatomic) NSString* jsGotoLineKeyword;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *analyzeInfoBarButton;

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *gotoHighlightBar;

@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *topToolBar;

@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *bottomToolBar;

- (void) setCurrentSearchFocusLine:(int)line andTotal:(int)total;

- (void) setTitle: (NSString*) title andPath:(NSString*)path andContent:(NSString*) content;

- (void) displayDocTypeFile: (NSString*) path;

- (void) displayHTMLString: (NSString*)content;

- (int) getCurrentScrollLocation;

- (void) upSelectButton;

- (void) downSelectButton;

- (IBAction)infoButtonClicked:(id)sender;

- (IBAction)hideMasterViewClicked:(id)sender;

- (IBAction)highlightWordButtonClicked:(id)sender;

- (IBAction)gotoHighlight:(id)sender;

- (IBAction)displayModeClicked:(id)sender;

- (IBAction)historyListClicked:(id)sender;

- (IBAction)percentClicked:(id)sender;

- (void)goBackHistory;

- (void)goForwardHistory;

- (void)restoreToHistory:(NSString*)history;

- (IBAction)historyClicked:(id)sender;

- (IBAction)titleTouched:(id)sender;

- (IBAction)navigationButtonClicked:(id)sender;

- (void)navigationManagerPopUpWithKeyword:(NSString*)keyword andProject:(NSString*)path;
- (IBAction)resultPopUp:(id)sender;

- (IBAction)gotoLinePopUp:(id)sender;

- (IBAction)showHideTopToolBarClicked:(id)sender;

- (void)dismissNavigationManager;

- (NSString*) getCurrentDisplayFile;

- (void) gotoFile: (NSString*)filePath andLine:(NSString*)line andKeyword:(NSString*) __keyword;

- (void) reloadCurrentPage;

- (void) releaseAllPopOver;
@end
