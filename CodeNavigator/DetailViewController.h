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

typedef enum _JSState {
    JS_NONE,
    JS_GOTO_LINE_AND_FOCUS_KEYWORD,
    JS_HISTORY_MODE,
} JSState;

@class NavigationController;
@class ResultViewController;
@class GotoLineViewController;
@class FilePathInfoPopupController;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, UIPopoverControllerDelegate>
{
    int currentSearchFocusLine;
    int searchLineTotal;
    
    //JSState related
    JSState jsState;
    int jsGotoLine;
    int jsHistoryModeScrollY;
    //end
}
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *navigateBarButtonItem;

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *titleTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *countTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *resultBarButton;

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *historyBar;

@property (retain, nonatomic) NSString *searchWord;

@property (retain, nonatomic) HistoryController* historyController;

@property (retain, nonatomic) NavigationController* codeNavigationController;

@property (retain, nonatomic) UIPopoverController *codeNavigationPopover;

@property (retain, nonatomic) ResultViewController *resultViewController;

@property (retain, nonatomic) UIPopoverController *resultPopover;

@property (retain, nonatomic) GotoLineViewController *gotoLineViewController;

@property (retain, nonatomic) UIPopoverController *gotoLinePopover;

@property (retain, nonatomic) FilePathInfoPopupController* filePathInfoController;

@property (retain, nonatomic) UIPopoverController* filePathInfopopover;

@property (retain, nonatomic) NSString* jsGotoLineKeyword;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *analyzeInfoBarButton;

- (void) setTitle: (NSString*) title andPath:(NSString*)path andContent:(NSString*) content;

- (int) getCurrentScrollLocation;

- (IBAction) upSelectButton:(id)sender;

- (IBAction) downSelectButton:(id)sender;

- (IBAction)infoButtonClicked:(id)sender;

- (void)goBackHistory;

- (void)goForwardHistory;

- (IBAction)historyClicked:(id)sender;

- (IBAction)titleTouched:(id)sender;

- (IBAction)navigationButtonClicked:(id)sender;

- (void)navigationManagerPopUp:(id)sender;

- (IBAction)resultPopUp:(id)sender;

- (IBAction)gotoLinePopUp:(id)sender;

- (void)dismissNavigationManager;

- (NSString*) getCurrentDisplayFile;

- (void) setResultListAndAnalyze: (NSArray*) lines andKeyword:(NSString*)keyword;

- (void) gotoFile: (NSString*)filePath andLine:(NSString*)line andKeyword:(NSString*) __keyword;

- (void) reloadCurrentPage;
@end
