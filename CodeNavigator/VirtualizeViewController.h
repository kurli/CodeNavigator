//
//  VirtualizeViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 2/4/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VirtualizeWrapper;
@class FileManagerController;
@class ProjectListController;
@class ImagePreviewController;

typedef enum _ALERT_TYPE
{
    ALERT_NEW_FILE,
    ALERT_SAVE,
    ALERT_DELETE
} ALERT_TYPE;

@interface VirtualizeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    // For this flag, when click keyword in webview, it will automatically 
    // search global definition
    // Use Case: When need to get entry manually
    BOOL getEntryFromWebView;
    BOOL viewInitedForEdit;
    BOOL isCurrentFileManager;
    ALERT_TYPE alertType;
    
    CGPoint panPoint;// used to connect child/parent manually
}

@property (strong, nonatomic) NSString* fileName;

@property (strong, nonatomic) VirtualizeWrapper* virtualizeWrapper;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *entryFindChildButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *entryFindParentButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *entryDeleteButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *entryConnectButton;

@property (strong, nonatomic) UITapGestureRecognizer *singleFingerTap;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;

@property (strong, nonatomic) FileManagerController* fileManagerController;

@property (strong, nonatomic) NSString* currentProjectFolder;

@property (strong, nonatomic) NSString* currentSelectedVirImg;

// Need get entry info from ResultView by cscope
@property (unsafe_unretained, nonatomic) BOOL isNeedGetResultFromCscope;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *showSelectedVirButton;

@property (strong, nonatomic) ImagePreviewController* imagePreviewController;

@property (strong, nonatomic) UIPopoverController* popOverController;

@property (strong, nonatomic) UIPopoverController* projectListPopoverController; 

@property (retain, nonatomic) IBOutlet UIBarButtonItem *nToolBarButton;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *xToolBarButton;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *projectListToolBarButton;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *saveToolBarButton;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *trashToolBarButton;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *fullScreenToolBarButton;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *nEntryToolBarButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) NSArray* fileManagerToolBarsArray;

@property (strong, nonatomic) NSArray* fsViewToolBarsArray;

- (IBAction)projectListClicked:(id)sender;

- (IBAction)deleteButtonClicked:(id)sender;

- (IBAction)newButtonClicked:(id)sender;

- (IBAction)maxButtonClicked:(id)sender;

- (IBAction)closeButtonClicked:(id)sender;

- (IBAction)showSelectedVirImgClicked:(id)sender;

- (IBAction)newEntryButtonClicked:(id)sender;

- (BOOL) isGetEntryFromWebView;

- (void) addEntry:(NSString*)entry andFile:(NSString*)file andLine:(int)line andProject:(NSString*)project;

- (void)handleSingleTapInImageView:(UIGestureRecognizer*)sender;

- (void)handleLongPressInImageView:(UIGestureRecognizer*)sender;

- (IBAction)entryFindChildClicked:(id)sender;

- (IBAction)entryFindParentClicked:(id)sender;

- (IBAction)entryDeleteButtonClicked:(id)sender;

- (IBAction)entryConnectClicked:(id)sender;

- (IBAction)childDragStart:(id)sender;

- (IBAction)childDragEnd:(id)sender;

- (IBAction)saveButtonClicked:(id)sender;

- (void) showEntryButtons:(CGPoint)point;

- (void) hideEntryButtons;

- (void) setNeedhighlightChildKeyword:(BOOL)b;

- (BOOL) isNeedHighlightChildKeyword;

- (void) highlightAllChildrenKeyword;

- (void) initVirShowView;

- (BOOL) checkWhetherExistInCurrentEntry:(NSString*)name andLine:(NSString*)line;

- (void) displayVirtualizeFilesInProject:(NSString*)project;

- (void) hideFileManagerAndShowEditView;

- (void) hideFileManagerAnimationFinished:(id)sender;

- (void) hideEditViewAndshowFileManager;

- (void) hideEditViewAnimationFinished:(id)sender;

- (void) saveCurrentFileConfirm;

- (void) cloceImgPreview;

@end
