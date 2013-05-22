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

#ifdef LITE_VERSION
#import "GAI.h"
#endif

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
@class VirtualizeViewController;
@class FunctionListViewController;

#ifdef LITE_VERSION
@interface DetailViewController : GAITrackedViewController <UIWebViewDelegate, UIGestureRecognizerDelegate, UIPopoverControllerDelegate, MGSplitViewControllerDelegate>
#else
@interface DetailViewController : UIViewController <UIWebViewDelegate, UIGestureRecognizerDelegate, UIPopoverControllerDelegate, MGSplitViewControllerDelegate>
#endif
{
    int currentSearchFocusLine;
    BOOL shownToolBar;
    
    //JSState related
    JSState jsState;
    int jsGotoLine;
    int jsHistoryModeScrollY;
    //end
    
    BOOL isVirtualizeDisplayed;
    BOOL isFirstDisplay;
}
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *navigateBarButtonItem;

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *titleTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *countTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *resultBarButton;

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *historyBar;

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *showCommentsSegment;

// search support
@property (strong, nonatomic) NSString *searchWord;

@property (strong, nonatomic) NSArray* highlightLineArray;

@property (unsafe_unretained, nonatomic) HistoryController* historyController;

@property (strong, nonatomic) HistoryController* upHistoryController;

@property (strong, nonatomic) HistoryController* downHistoryController;

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

@property (strong, nonatomic) FunctionListViewController* functionListViewController;

@property (strong, nonatomic) UIPopoverController* functionListPopover;

@property (strong, nonatomic) VirtualizeViewController *virtualizeViewController;

@property (strong, nonatomic) NSString* jsGotoLineKeyword;

@property (strong, nonatomic) IBOutlet UIWebView* secondWebView;

@property (unsafe_unretained, nonatomic) UIWebView* activeWebView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *divider;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *analyzeInfoBarButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *topToolBar;

@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *bottomToolBar;

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *webViewSegmentController;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *activeMark;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *virtualizeButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *hideMasterViewButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *splitWebViewButton;

// Scroll support
@property (unsafe_unretained, nonatomic) IBOutlet UIView *scrollBackgroundView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *scrollItem;
@property (strong, nonatomic) UITapGestureRecognizer* scrollBarTapRecognizer;
- (void)handleSingleTapInScrollView:(UIGestureRecognizer*)sender;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *historySwipeImageView;

- (IBAction)webViewSegmentChanged:(id)sender;

- (void) setCurrentSearchFocusLine:(int)line;

- (void) setTitle: (NSString*) title andPath:(NSString*)path andContent:(NSString*) content andBaseUrl:(NSString*)baseURL;

- (void) displayDocTypeFile: (NSString*) path;

- (void) displayHTMLString: (NSString*)content andBaseURL:(NSString*)baseURL;

- (int) getCurrentScrollLocation;

- (void) upSelectButton;

- (void) downSelectButton;

- (IBAction)infoButtonClicked:(id)sender;

- (IBAction)hideMasterViewClicked:(id)sender;

- (IBAction)highlightWordButtonClicked:(id)sender;

- (IBAction)gotoHighlight:(id)sender;

- (IBAction)displayModeClicked:(id)sender;

- (IBAction)historyListClicked:(id)sender;

- (IBAction)sourceSplitClicked:(id)sender;

- (void)goBackHistory;

- (void)goForwardHistory;

- (void)restoreToHistory:(NSString*)history;

- (IBAction)historyClicked:(id)sender;

- (IBAction)titleTouched:(id)sender;

- (IBAction)navigationButtonClicked:(id)sender;

- (IBAction)virtualizeButtonClicked:(id)sender;

- (void)navigationManagerPopUpWithKeyword:(NSString*)keyword andSourcePath:(NSString*)path;

- (IBAction)resultPopUp:(id)sender;

- (IBAction)gotoLinePopUp:(id)sender;

- (IBAction)showHideTopToolBarClicked:(id)sender;

- (IBAction)showCommentsClicked:(id)sender;

- (void)dismissNavigationManager;

- (void)forceResultPopUp:(id)button;

- (NSString*) getCurrentDisplayFile;

- (void) gotoFile: (NSString*)filePath andLine:(NSString*)line andKeyword:(NSString*) __keyword;

- (void) reloadCurrentPage;

- (void) releaseAllPopOver;

- (void) splitWebView;

- (void) singleWebView;

- (void) showVirtualizeView;

- (void) hideVirtualizeView;

- (void) showCommentInWebView:(int)_line andComment:(NSString*)_comment;

- (void) showAllComments;

#ifdef IPHONE_VERSION
- (IBAction)filesButtonClicked:(id)sender;
#endif

- (IBAction)functionListClicked:(id)sender;

@end
