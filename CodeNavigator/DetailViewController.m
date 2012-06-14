//
//  DetailViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "Utils.h"
#import "FilePathInfoPopupController.h"
#import "BannerViewController.h"
#import "MGSplitViewController.h"
#import "HighLightWordController.h"
#import "HistoryListController.h"
#import "VirtualizeViewController.h"
#import "CommentViewController.h"
#import "CommentWrapper.h"

#define TOOLBAR_X_MASTER_SHOW 55
#define TOOLBAR_X_MASTER_HIDE 208

#ifdef IPHONE_VERSION
#define LINE_DELTA 4
#else
#define LINE_DELTA 8
#endif

@implementation DetailViewController
{
    int _bannerCounter;
}

@synthesize countTextField = _countTextField;
@synthesize resultBarButton = _resultBarButton;

@synthesize navigateBarButtonItem = _navigateBarButtonItem;
@synthesize webView = _webView;
@synthesize searchWord = _searchWord;
@synthesize titleTextField = _titleTextField;
@synthesize historyController = _historyController;
@synthesize historyBar = _historyBar;
@synthesize codeNavigationController = _codeNavigationController;
@synthesize codeNavigationPopover = _codeNavigationPopover;
@synthesize resultViewController = _resultViewController;
@synthesize resultPopover = _resultPopover;
@synthesize jsGotoLineKeyword = _jsGotoLineKeyword;
@synthesize analyzeInfoBarButton = _analyzeInfoBarButton;
@synthesize gotoHighlightBar = _gotoHighlightBar;
@synthesize topToolBar = _topToolBar;
@synthesize bottomToolBar = _bottomToolBar;
@synthesize webViewSegmentController = _webViewSegmentController;
@synthesize activeMark = _activeMark;
@synthesize virtualizeButton;
@synthesize hideMasterViewButton;
@synthesize splitWebViewButton;
@synthesize historySwipeImageView;
@synthesize scrollBackgroundView;
@synthesize scrollItem;
@synthesize gotoLineViewController = _gotoLineViewController;
@synthesize gotoLinePopover = _gotoLinePopover;
@synthesize filePathInfopopover;
@synthesize filePathInfoController;
@synthesize highlghtWordPopover;
@synthesize highlightWordController;
@synthesize displayModePopover;
@synthesize displayModeController;
@synthesize historyListController;
@synthesize historyListPopover;
@synthesize secondWebView;
@synthesize activeWebView;
@synthesize divider;
@synthesize upHistoryController;
@synthesize downHistoryController;
@synthesize virtualizeViewController;
@synthesize highlightLineArray;
@synthesize scrollBarTapRecognizer;

#pragma mark - Managing the detail item

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	//_navigationManagerPopover.delegate = self;
    jsState = JS_NONE;
    jsGotoLine = 0;
    jsHistoryModeScrollY = 0;
    shownToolBar = YES;
    self.activeWebView = self.webView;
    isFirstDisplay = YES;
    
    // show hide scrollbar
    scrollBarTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapInScrollView:)];
    scrollBarTapRecognizer.numberOfTapsRequired = 1;
    [self.scrollBackgroundView addGestureRecognizer:scrollBarTapRecognizer];
    
    // add drag listener
	[scrollItem addTarget:self action:@selector(wasDragged:withEvent:) 
     forControlEvents:UIControlEventTouchDragInside];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self.scrollBackgroundView removeGestureRecognizer:self.scrollBarTapRecognizer];
    [self setScrollBarTapRecognizer:nil];
    [self setScrollBackgroundView:nil];
    [self setScrollItem:nil];
    [self setHistorySwipeImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc
{
    [self.scrollBackgroundView removeGestureRecognizer:self.scrollBarTapRecognizer];
    [self setScrollBarTapRecognizer:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setVirtualizeViewController:nil];
    [self setUpHistoryController:nil];
    [self setDownHistoryController:nil];
    [self setActiveWebView:nil];
    [self setSecondWebView:nil];
    [self setHistoryListPopover:nil];
    [self setHistoryListController:nil];
    [self setWebView:nil];
    [self setCountTextField:nil];
    [self.historyController.historyStack removeAllObjects];
    [self.historyController setHistoryStack:nil];
    [self setHistoryController:nil];
    [self setSearchWord:nil];
    [self setHighlightLineArray:nil];
    [self setHistoryBar:nil];
    [self setCodeNavigationController:nil];
    [self setCodeNavigationPopover:nil];
    [self setResultViewController:nil];
    [self setResultPopover:nil];
    [self setResultBarButton:nil];
    [self setGotoLinePopover:nil];
    [self setGotoLineViewController:nil];
    [self setNavigateBarButtonItem:nil];
    [self setAnalyzeInfoBarButton:nil];
    [self setFilePathInfopopover:nil];
    [self setFilePathInfoController:nil];
    [self setJsGotoLineKeyword:nil];
    [self setTitleTextField:nil];
    [self setHighlghtWordPopover:nil];
    [self setHighlightWordController:nil];
    [self setGotoHighlightBar:nil];
    [self setDisplayModeController:nil];
    [self setDisplayModePopover:nil];
    [self setTopToolBar:nil];
    [self setBottomToolBar:nil];
    [self setWebViewSegmentController:nil];
    [self setActiveMark:nil];
    [self setVirtualizeButton:nil];
    [self setDivider:nil];
    [self setHideMasterViewButton:nil];
    [self setSplitWebViewButton:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Only show help html in the first time
    if (isFirstDisplay) {
        NSString* help = [NSHomeDirectory() stringByAppendingString:@"/Documents/Projects/Help.html"];
        NSError *error;
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSString* html = [NSString stringWithContentsOfFile: help usedEncoding:&encoding error: &error];
        [self setTitle:@"Help.html" andPath:help andContent:html andBaseUrl:nil];
        isFirstDisplay = NO;
    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    jsState = JS_HISTORY_MODE;
    jsHistoryModeScrollY = [self getCurrentScrollLocation];
//    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
//    {
//        [self.webView setScalesPageToFit:YES];
//        [self reloadCurrentPage];
//    }
//    else
    {
        [self.webView setScalesPageToFit:NO];
        [self.secondWebView setScalesPageToFit:NO];
        //[self reloadCurrentPage];
    }
    return YES;
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
#ifndef IPHONE_VERSION
    CGRect frameTop = self.topToolBar.frame;
    CGRect frameBottom = self.bottomToolBar.frame;
    if ([[Utils getInstance].splitViewController isShowingMaster] == YES)
    {
        frameTop.origin.x = TOOLBAR_X_MASTER_SHOW;
        frameBottom.origin.x = TOOLBAR_X_MASTER_SHOW;
    }
    else
    {
        UIDeviceOrientation  orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
            frameTop.origin.x = TOOLBAR_X_MASTER_SHOW;
            frameBottom.origin.x = TOOLBAR_X_MASTER_SHOW;
        }
        else {
            frameTop.origin.x = TOOLBAR_X_MASTER_HIDE;
            frameBottom.origin.x = TOOLBAR_X_MASTER_HIDE;
        }
    }
    [UIView beginAnimations:@"ToolBarPosX"context:nil];         
    [UIView setAnimationDuration:0.30];           
    [UIView setAnimationDelegate:self];          
    [self.topToolBar setFrame:frameTop];
    [self.bottomToolBar setFrame:frameBottom];
    [UIView commitAnimations];
    
    //for split view
    int height = self.secondWebView.frame.size.height;
    if ( height < 20 )
        [self singleWebView];
    else
        [self splitWebView];
    
    //for virtualize view
    if (isVirtualizeDisplayed)
    {
        [self showVirtualizeView];
    }
#ifdef LITE_VERSION
    [[[Utils getInstance] getBannerViewController] viewDidLayoutSubviews];
#endif
#endif
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    UILongPressGestureRecognizer *hold;
//    hold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    hold.minimumPressDuration = 2.0;
//    hold.numberOfTapsRequired = 1;
//    hold.delegate = self;
//    [self.view addGestureRecognizer:hold];
    if (self)
    {
#ifdef LITE_VERSION
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBeginBannerViewActionNotification:) name:BannerViewActionWillBegin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishBannerViewActionNotification:) name:BannerViewActionDidFinish object:nil];
        _bannerCounter = 0;
        isVirtualizeDisplayed = NO;
#endif
    }
    self.upHistoryController = [[HistoryController alloc] init];
    self.downHistoryController = [[HistoryController alloc] init];
    self.historyController = self.upHistoryController;
    return self;
}

- (void)willBeginBannerViewActionNotification:(NSNotification *)notification
{
}

- (void)didFinishBannerViewActionNotification:(NSNotification *)notification
{
    [[[Utils getInstance] getBannerViewController] hideBannerView];
}

#pragma Gesture Recognizer
- (void)handleSingleTapInScrollView:(UIGestureRecognizer*)sender
{
    NSString* str = [self.activeWebView stringByEvaluatingJavaScriptFromString:@"bodyHeight()"];
    int bodyHeight = [str intValue];
    int height = 0;
    if (bodyHeight > activeWebView.frame.size.height)
        height = bodyHeight - activeWebView.frame.size.height;
    else
        height = bodyHeight;
    int currentLocation = [self getCurrentScrollLocation];
    if (currentLocation == 0)
        currentLocation = 1;
    if (height == 0)
        height = 1;
    float percent = (float)currentLocation/(float)(height);
    
    int center = scrollBackgroundView.frame.size.height - scrollItem.frame.size.height;
    center *= percent;
    center += scrollItem.frame.size.height/2;
    scrollItem.center = CGPointMake(scrollItem.center.x, center);
    
    [self.scrollBackgroundView setBackgroundColor:[UIColor grayColor]];
    [self.scrollItem setHidden:NO];
}

- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event
{    
	// get the touch
	UITouch *touch = [[event touchesForView:button] anyObject];
    
	// get delta
	CGPoint previousLocation = [touch previousLocationInView:button];
	CGPoint location = [touch locationInView:button];
	CGFloat delta_y = location.y - previousLocation.y;
    
    int finalPosY = button.frame.origin.y + delta_y;
    
    if (finalPosY < 0 ) {
        return;
    }
    if (finalPosY > scrollBackgroundView.frame.size.height - button.frame.size.height ) {
        return;
    }
    
    // move button
	button.center = CGPointMake(button.center.x,
                                button.center.y + delta_y);
    
        NSString* str = [self.activeWebView stringByEvaluatingJavaScriptFromString:@"bodyHeight()"];
        int bodyHeight = [str intValue];
        int height = 0;
        if (bodyHeight > activeWebView.frame.size.height)
            height = bodyHeight - activeWebView.frame.size.height;
        else
            height = bodyHeight;
        if (height == 0)
            height = 1;
        
//        int currentLocation = [self getCurrentScrollLocation];
//        if (currentLocation == 0)
//            currentLocation = 1;
        int buttonTop = button.center.y - button.frame.size.height/2;
        int scrollHeight = scrollBackgroundView.frame.size.height - button.frame.size.height;
        
        float percent = (float)buttonTop/(float)scrollHeight;
        
        int location2 = height*percent;
        NSString* str2 = [NSString stringWithFormat:@"scrollTo(0,%d)",location2];
        [self.activeWebView stringByEvaluatingJavaScriptFromString:str2];
}

#pragma detailviewcontroller interface for others
- (void)setTitle:(NSString *)title andPath:(NSString*)path andContent:(NSString *)content andBaseUrl:(NSString *)baseURL
{
    int location = [self getCurrentScrollLocation];
    [self.titleTextField setTitle:title];
    [self.historyController updateCurrentScrollLocation:location];
    [self.historyController pushUrl:path];
    [self displayHTMLString:content andBaseURL:baseURL];
    content = nil;
}

-(void) displayDocTypeFile:(NSString *)path
{
    int location = [self getCurrentScrollLocation];
    [self.titleTextField setTitle:[path lastPathComponent]];
    [self.historyController updateCurrentScrollLocation:location];
    [self.historyController pushUrl:path];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.activeWebView setScalesPageToFit:YES];
    [self.activeWebView loadRequest:request];
}

-(void) displayHTMLString:(NSString *)content andBaseURL:(NSString *)baseURL
{
    if (baseURL == nil) {
        baseURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"] isDirectory:YES];
    } else {
        baseURL = [NSURL fileURLWithPath:baseURL isDirectory:YES];
    }
    self.activeWebView.opaque = NO;
    self.activeWebView.backgroundColor = [UIColor clearColor];
    [[Utils getInstance] changeUIViewStyle:self.activeWebView];
    [self.activeWebView setScalesPageToFit:NO];
    [self.activeWebView loadHTMLString:content baseURL:[baseURL copy]];
}

- (void) gotoFile:(NSString *)filePath andLine:(NSString *)line andKeyword:(NSString *)__keyword
{
#ifdef IPHONE_VERSION
    MasterViewController* masterViewController = (MasterViewController*)[Utils getInstance].masterViewController.topViewController;
#else
    MasterViewController* masterViewController = nil;
    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
#endif
    
    NSString* displayPath;
    BOOL isFolder = NO;
    NSString* html;
    NSString* title = [[filePath pathComponents] lastObject];
    
    //check whether file exist
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isFolder])
    {
        NSString* filePathFromProject = [[Utils getInstance] getPathFromProject:filePath];
        
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:[NSString stringWithFormat:@"%@\n File not found",filePathFromProject]];
        return;
    }
    
    //if ([[Utils getInstance] isSupportedType:filePath] == YES)
    {
        // save current display status to history stack
        int location = [self getCurrentScrollLocation];
        [self.titleTextField setTitle:title];        
        [self.historyController updateCurrentScrollLocation:location];
        
        NSString* currentDisplayFile = [self getCurrentDisplayFile];
        
        displayPath = [[Utils getInstance] getDisplayPath:filePath];
        [self.historyController pushUrl:displayPath];
        
        html = [[Utils getInstance] getDisplayFile:filePath andProjectBase:nil];

        if (currentDisplayFile == nil || !([currentDisplayFile compare:displayPath] == NSOrderedSame))
        {
            [self displayHTMLString:html andBaseURL:nil];

            jsState = JS_GOTO_LINE_AND_FOCUS_KEYWORD;
            jsGotoLine = [line intValue];
            _jsGotoLineKeyword = __keyword;
            
            [masterViewController gotoFile:displayPath];
        }
        else
        {
            int lll = [line intValue];
            lll -= LINE_DELTA;
            if (lll <= 0)
                lll = 1;
            NSString* js = [NSString stringWithFormat:@"smoothScroll('L%d')", lll];
            [self.activeWebView stringByEvaluatingJavaScriptFromString:js];
            //magic way to dis highlight current words
            js = @"clearHighlight();";
            [self.activeWebView stringByEvaluatingJavaScriptFromString:js];
            js = [NSString stringWithFormat:@"highlight_this_line_keyword('L%d', '%@')", [line intValue], __keyword];
            [self.activeWebView stringByEvaluatingJavaScriptFromString:js];
            
        }
    }
 }

- (void) restoreToHistory:(NSString *)history
{
    NSString* url = nil;
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError* error;
    
    int historyLocation = [self.historyController getLocationFromHistoryFormat:history];
    if( historyLocation != -1 )
    {
        url = [self.historyController getUrlFromHistoryFormat:history];
        jsState = JS_HISTORY_MODE;
        jsHistoryModeScrollY = historyLocation;
    }
    else
    {
        url = history;
        jsState = JS_HISTORY_MODE;
        jsHistoryModeScrollY = 0;
    }
    //check whether file exist
    BOOL isFolder;
    if (![[NSFileManager defaultManager] fileExistsAtPath:url isDirectory:&isFolder])
    {
        NSString* filePathFromProject = [[Utils getInstance] getPathFromProject:url];
        filePathFromProject = [[Utils getInstance] getSourceFileByDisplayFile:filePathFromProject];
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:[NSString stringWithFormat:@"%@\n File not found",filePathFromProject]];
        return;
    }
    
    NSString* extention = [url pathExtension];
    if (extention != nil && [extention compare:DISPLAY_FILE_EXTENTION] == NSOrderedSame)
    {
        NSString* content = [NSString stringWithContentsOfFile:url encoding:encoding error:&error];
        [self displayHTMLString:content andBaseURL:nil];
    }
    else
    {
        if ([[Utils getInstance] isDocType:url] == YES)
        {
            NSURL *nsurl = [NSURL fileURLWithPath:url];
            NSURLRequest *request = [NSURLRequest requestWithURL:nsurl];
            [self.activeWebView setScalesPageToFit:YES];
            [self.activeWebView loadRequest:request];
        }
        else if ([[Utils getInstance] isWebType:url] == YES)
        {
            NSString* proj = [[Utils getInstance] getProjectFolder:url];
            if ([proj length] == 0 || [proj compare:url] == NSOrderedSame) {
                NSError *error;
                NSStringEncoding encoding = NSUTF8StringEncoding;
                NSString* html = [NSString stringWithContentsOfFile: url usedEncoding:&encoding error: &error];
                [self displayHTMLString:html andBaseURL:nil];
            }
            else {
                NSString* content = [NSString stringWithContentsOfFile:url encoding:encoding error:&error];
                [self displayHTMLString:content andBaseURL:[url stringByDeletingLastPathComponent]];
            }
        }
    }

    NSArray* array = [url pathComponents];
    NSString* title = [array lastObject];
    title = [[Utils getInstance] getSourceFileByDisplayFile:title];
    [self.titleTextField setTitle:title];
    
#ifdef IPHONE_VERSION
    MasterViewController* masterViewController = (MasterViewController*)[Utils getInstance].masterViewController.topViewController;
#else
    MasterViewController* masterViewController = nil;
    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController; 
#endif
    [masterViewController gotoFile:url];
}

- (void)goBackHistory {
    int location = [self getCurrentScrollLocation];
    [self.historyController updateCurrentScrollLocation:location];
    NSString* history = [self.historyController popUrl];
    if (history == nil)
        return;
    [self restoreToHistory:history];
}

- (void)goForwardHistory {
    int location = [self getCurrentScrollLocation];
    [self.historyController updateCurrentScrollLocation:location];
    NSString* history = [self.historyController getNextUrl];
    if (history == nil)
        return;
    [self restoreToHistory:history];
}


-(void) dismissNavigationManager
{
    [_codeNavigationPopover dismissPopoverAnimated:YES];
}

-(NSString*) getCurrentDisplayFile
{
    NSString* path = [self.historyController pickTopLevelUrl];
    return [self.historyController getUrlFromHistoryFormat:path];
}

-(void) reloadCurrentPage
{
    NSError *error;
    NSString* html;
    NSString* currentDisplayFile = [self getCurrentDisplayFile];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    html = [NSString stringWithContentsOfFile: currentDisplayFile usedEncoding:&encoding error: &error];
    [self displayHTMLString:html andBaseURL:nil];
}

- (void)navigationManagerPopUpWithKeyword:(NSString*)keyword andSourcePath:(NSString*)path {
    if (_codeNavigationPopover.isPopoverVisible == YES)
    {
        [_codeNavigationPopover dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        return;
    }
    [self releaseAllPopOver];
    
    _codeNavigationController= [[NavigationController alloc] init];
    [_codeNavigationController setSearchKeyword:keyword];
    [_codeNavigationController setCurrentSourcePath:path];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:_codeNavigationController];
    _codeNavigationController.title = @"CodeNavigator";
#ifdef IPHONE_VERSION
    [self presentModalViewController:controller animated:YES];
#else
    // Setup the popover for use from the navigation bar.
	_codeNavigationPopover = [[UIPopoverController alloc] initWithContentViewController:controller];
	_codeNavigationPopover.popoverContentSize = _codeNavigationController.view.frame.size;
    
    [_codeNavigationPopover presentPopoverFromBarButtonItem:self.navigateBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
    _bannerCounter++;
    if (_bannerCounter == 10)
    {
        [[[Utils getInstance] getBannerViewController] showBannerView];
        _bannerCounter = 0;
    }
}

-(void) releaseAllPopOver
{
    [self.historyListPopover dismissPopoverAnimated:YES];
    [self setHistoryListPopover:nil];
    [self setHistoryListController:nil];
    
    [self.codeNavigationPopover dismissPopoverAnimated:YES];
    [self setCodeNavigationPopover:nil];
    [self setCodeNavigationController:nil];
    
    [self.resultPopover dismissPopoverAnimated:YES];
    [self setResultPopover:nil];
    [self setResultViewController:nil];
    
    [self.gotoLinePopover dismissPopoverAnimated:YES];
    [self setGotoLinePopover:nil];
    [self setGotoLineViewController:nil];
    
    [self.filePathInfopopover dismissPopoverAnimated:YES];
    [self setFilePathInfopopover:nil];
    [self setFilePathInfoController:nil];
    
    [self.highlghtWordPopover dismissPopoverAnimated:YES];
    [self setHighlightWordController:nil];
    [self setHighlghtWordPopover:nil];
    
    [self.displayModePopover dismissPopoverAnimated:YES];
    [self setDisplayModePopover:nil];
    [self setDisplayModeController:nil];
}

- (void) setUpWebViewAsActive
{
    self.activeWebView = self.webView;
    self.historyController = self.upHistoryController;
    NSString* path = [self.upHistoryController pickTopLevelUrl];
    NSString* currentDisplayFile = [self.upHistoryController getUrlFromHistoryFormat:path];
    NSString* title = [currentDisplayFile lastPathComponent];
    title = [[Utils getInstance] getSourceFileByDisplayFile:title];
    self.titleTextField.title = title;
    
    CGRect rect = self.activeMark.frame;
    rect.origin.x = 5;
    rect.origin.y = self.webView.frame.size.height-rect.size.height;
    [self.activeMark setFrame:rect];
    [self.activeMark setHidden:NO];  
}

- (void) setDownWebViewAsActive
{
    self.activeWebView = self.secondWebView;
    self.historyController = self.downHistoryController;
    NSString* path = [self.downHistoryController pickTopLevelUrl];
    NSString* currentDisplayFile = [self.upHistoryController getUrlFromHistoryFormat:path];
    NSString* title = [currentDisplayFile lastPathComponent];
    title = [[Utils getInstance] getSourceFileByDisplayFile:title];
    self.titleTextField.title = title;
    
    CGRect rect = self.activeMark.frame;
    rect.origin.x = 5;
    rect.origin.y = self.secondWebView.frame.origin.y;
    [self.activeMark setFrame:rect];
    [self.activeMark setHidden:NO];  
}

- (IBAction)webViewSegmentChanged:(id)sender {
    UISegmentedControl* segmentController = sender;
    if ([segmentController selectedSegmentIndex] == 0)
    {
        [self setUpWebViewAsActive];
    }
    else
    {
        [self setDownWebViewAsActive];
    }
}

-(void) setCurrentSearchFocusLine:(int)line
{
    currentSearchFocusLine = line;
}

-(int) getCurrentScrollLocation
{
    NSString* location = [self.activeWebView stringByEvaluatingJavaScriptFromString:@"currentYPosition()"];
    return [location intValue];
}

#pragma Bar Button action

- (IBAction)infoButtonClicked:(id)sender {
    if ([Utils getInstance].analyzeInfoPopover.isPopoverVisible == YES)
        [[Utils getInstance] showAnalyzeInfoPopOver:NO];
    else
        [[Utils getInstance] showAnalyzeInfoPopOver:YES];
}

- (IBAction)historyClicked:(id)sender {
    UISegmentedControl* controller = sender;
    int index = [controller selectedSegmentIndex];
    if (index == 0)
        [self goBackHistory];
    else
        [self goForwardHistory];
}

- (IBAction)titleTouched:(id)sender {
    if ([self.filePathInfopopover isPopoverVisible] == YES)
    {
        [self.filePathInfopopover dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        return;
    }
    [self releaseAllPopOver];
    
    NSString* currentFile = [self getCurrentDisplayFile];
    if (currentFile == nil)
        return;
//    MasterViewController* masterViewController = nil;
//    NSArray* controllers = [self.splitViewController viewControllers];
//    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
//    [masterViewController gotoFile:currentFile];
    
    self.filePathInfoController = [[FilePathInfoPopupController alloc] init];
#ifdef IPHONE_VERSION
#else
    self.filePathInfopopover = [[UIPopoverController alloc] initWithContentViewController:self.filePathInfoController];
    NSString* realSourceFile = [[Utils getInstance] getPathFromProject:currentFile];
    realSourceFile = [realSourceFile stringByDeletingLastPathComponent];
    realSourceFile = [realSourceFile stringByAppendingPathComponent:self.titleTextField.title];
    self.filePathInfoController.label.text = realSourceFile;
    self.filePathInfopopover.popoverContentSize = CGSizeMake(640., 45);
    [self.filePathInfopopover presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

- (IBAction)navigationButtonClicked:(id)sender
{
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//    NSString *pastedText = pasteboard.string;
    _bannerCounter++;
    if (_bannerCounter == 10)
    {
        [[[Utils getInstance] getBannerViewController] showBannerView];
        _bannerCounter = 0;
    }
    if ([_codeNavigationPopover isPopoverVisible] == YES)
    {
        [_codeNavigationPopover dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        return;
    }
    [self releaseAllPopOver];
    
#ifndef IPHONE_VERSION
    MasterViewController* masterViewController = nil;
    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
#else
    MasterViewController* masterViewController = (MasterViewController*)[Utils getInstance].masterViewController.topViewController;
#endif
    NSString* projectPath = [[Utils getInstance] getProjectFolder:masterViewController.currentLocation];
    
    if (projectPath == nil)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    
    _codeNavigationController= [[NavigationController alloc] init];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:_codeNavigationController];
    _codeNavigationController.title = @"Code Navigator";
#ifdef IPHONE_VERSION
    [self presentModalViewController:controller animated:YES];
    [_codeNavigationController setCurrentSourcePath:projectPath];
    [_codeNavigationController setSearchKeyword:@""];
#else
    // Setup the popover for use from the navigation bar.
	_codeNavigationPopover = [[UIPopoverController alloc] initWithContentViewController:controller];
	_codeNavigationPopover.popoverContentSize = CGSizeMake(320., 320.);
    
    [_codeNavigationController setCurrentSourcePath:projectPath];
    [_codeNavigationController setSearchKeyword:@""];
    [_codeNavigationPopover presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

-(void) forceResultPopUp:(id)button
{
    if ([_resultPopover isPopoverVisible] == YES)
    {
        [_resultPopover dismissPopoverAnimated:YES];
    }
    if ([[Utils getInstance].resultFileList count] == 0)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"No result"];
        return;
    }
    UIBarButtonItem* barButton = (UIBarButtonItem*)button;
    
#ifdef IPHONE_VERSION
    self.resultViewController = [[ResultViewController alloc] initWithNibName:@"ResultViewController-iPhone" bundle:nil];
#else
    self.resultViewController = [[ResultViewController alloc] init];
#endif
    self.resultViewController.detailViewController = self;
    UINavigationController *result_controller = [[UINavigationController alloc] initWithRootViewController:self.resultViewController];
    self.resultViewController.title = @"Result";
#ifdef IPHONE_VERSION
    [self presentModalViewController:result_controller animated:YES];
#else
    _resultPopover = [[UIPopoverController alloc] initWithContentViewController:result_controller];
    CGSize size = self.view.frame.size;
    size.height = size.height/3+39;
    size.width = size.width;
	_resultPopover.popoverContentSize = size;
    
    [_resultPopover presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

-(void) resultPopUp:(id)sender
{
    if ([_resultPopover isPopoverVisible] == YES)
    {
        [_resultPopover dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        return;
    }
    [self releaseAllPopOver];
    if ([[Utils getInstance].resultFileList count] == 0)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"No result"];
        return;
    }
    UIBarButtonItem* barButton = (UIBarButtonItem*)sender;
    
#ifdef IPHONE_VERSION
    self.resultViewController = [[ResultViewController alloc] initWithNibName:@"ResultViewController-iPhone" bundle:nil];
#else
    self.resultViewController = [[ResultViewController alloc] init];
#endif
    self.resultViewController.detailViewController = self;
    UINavigationController *result_controller = [[UINavigationController alloc] initWithRootViewController:self.resultViewController];
    self.resultViewController.title = @"Result";
#ifdef IPHONE_VERSION
    [self presentModalViewController:result_controller animated:NO];
#else
    _resultPopover = [[UIPopoverController alloc] initWithContentViewController:result_controller];
    CGSize size = self.view.frame.size;
    size.height = size.height/3+39;
    size.width = size.width;
	_resultPopover.popoverContentSize = size;
    
    [_resultPopover presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

-(void) gotoLinePopUp:(id)sender
{
    if ([_gotoLinePopover isPopoverVisible] == YES)
    {
        [_gotoLinePopover dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        return;
    }
    [self releaseAllPopOver];
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
    
    _gotoLineViewController = [[GotoLineViewController alloc] init];
    _gotoLineViewController.detailViewController = self;
#ifdef IPHONE_VERSION
    [self presentModalViewController:_gotoLineViewController animated:YES];
#else
    _gotoLinePopover = [[UIPopoverController alloc] initWithContentViewController:_gotoLineViewController];
    _gotoLinePopover.popoverContentSize = CGSizeMake(250., 45.);
    
    [_gotoLinePopover presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

- (IBAction)showHideTopToolBarClicked:(id)sender {
    CGRect frameTop = self.topToolBar.frame;
    CGRect frameBottom = self.bottomToolBar.frame;
    UIButton* button = (UIButton*)sender;
    if (shownToolBar == YES)
    {
        frameTop.origin.y = -frameTop.size.height;
        frameBottom.origin.y = frameBottom.origin.y+frameBottom.size.height;
        [button setTitle:@"⬇" forState:UIControlStateNormal];
    }
    else
    {
        frameTop.origin.y = 0;
        frameBottom.origin.y = frameBottom.origin.y-frameBottom.size.height;
        [button setTitle:@"⬆" forState:UIControlStateNormal];
    }
    [UIView beginAnimations:@"ToolBarShowHide"context:nil];         
    [UIView setAnimationDuration:0.30];           
    [UIView setAnimationDelegate:self];          
    [self.topToolBar setFrame:frameTop];
    [self.bottomToolBar setFrame:frameBottom];
    [UIView commitAnimations];
    shownToolBar = !shownToolBar;
}

- (IBAction)hideMasterViewClicked:(id)sender {
    UIBarButtonItem* toolBar = (UIBarButtonItem*)sender;
    CGRect frameTop = self.topToolBar.frame;
    CGRect frameBottom = self.bottomToolBar.frame;
    [[Utils getInstance].splitViewController toggleMasterView:nil];
    if ([[Utils getInstance].splitViewController isShowingMaster] == YES)
    {
        frameTop.origin.x = TOOLBAR_X_MASTER_SHOW;
        frameBottom.origin.x = TOOLBAR_X_MASTER_SHOW;
        [toolBar setImage:[UIImage imageNamed:@"hide_masterview.png"]];
    }
    else
    {
        [toolBar setImage:[UIImage imageNamed:@"show_masterview.png"]];
        UIDeviceOrientation  orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
            frameTop.origin.x = TOOLBAR_X_MASTER_SHOW;
            frameBottom.origin.x = TOOLBAR_X_MASTER_SHOW;
        }
        else {
            frameTop.origin.x = TOOLBAR_X_MASTER_HIDE;
            frameBottom.origin.x = TOOLBAR_X_MASTER_HIDE;
        }
    }
    [UIView beginAnimations:@"ToolBarPosX"context:nil];         
    [UIView setAnimationDuration:0.30];           
    [UIView setAnimationDelegate:self];          
    [self.topToolBar setFrame:frameTop];
    [self.bottomToolBar setFrame:frameBottom];
    [UIView commitAnimations];
}

- (IBAction)highlightWordButtonClicked:(id)sender {
    if ([self.highlghtWordPopover isPopoverVisible] == YES)
    {
        [self.highlghtWordPopover dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        return;
    }
    [self releaseAllPopOver];
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
#ifdef IPHONE_VERSION
    self.highlightWordController = [[HighLightWordController alloc] initWithNibName:@"HighLightWordController-iPhone" bundle:nil];
#else
    self.highlightWordController = [[HighLightWordController alloc] init];
#endif
    self.highlightWordController.detailViewController = self;
#ifdef IPHONE_VERSION
    [self presentModalViewController:self.highlightWordController animated:YES];
#else
    self.highlghtWordPopover = [[UIPopoverController alloc] initWithContentViewController:self.highlightWordController];
    self.highlghtWordPopover.popoverContentSize = CGSizeMake(198, 46);
    
    [self.highlghtWordPopover presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

- (void)upSelectButton {
    
    if (currentSearchFocusLine == 0)
    {
        currentSearchFocusLine = [highlightLineArray count];
        return;
    }
    currentSearchFocusLine--;
    if (currentSearchFocusLine >= [highlightLineArray count]) {
        return;
    }
    int line = [[highlightLineArray objectAtIndex:currentSearchFocusLine] intValue];
    line -= LINE_DELTA;
    if (line <= 0) {
        line = 1;
    }
    NSString* js = [NSString stringWithFormat:@"smoothScroll('L%d')", line];
    [self.activeWebView stringByEvaluatingJavaScriptFromString:js];
//    NSString* show = [NSString stringWithFormat:@"%d/%d", currentSearchFocusLine, searchLineTotal];
//    [self.countTextField setText:show];
}

- (void)downSelectButton {
    currentSearchFocusLine++;
    if (currentSearchFocusLine >= [highlightLineArray count]) {
        //currentSearchFocusLine-- ;
        currentSearchFocusLine = -1;
        return;
    }
    int line = [[highlightLineArray objectAtIndex:currentSearchFocusLine] intValue];
    line -= LINE_DELTA;
    if (line <= 0) {
        line = 1;
    }
    NSString* js = [NSString stringWithFormat:@"smoothScroll('L%d')", line];
    [self.activeWebView stringByEvaluatingJavaScriptFromString:js];
//    NSString* show = [NSString stringWithFormat:@"%d/%d", currentSearchFocusLine, searchLineTotal];
//    [self.countTextField setText:show];
}

- (IBAction)gotoHighlight:(id)sender {
    UISegmentedControl* controller = sender;
    int index = [controller selectedSegmentIndex];
    if (index == 0)
        [self upSelectButton];
    else
        [self downSelectButton];
}

- (IBAction)displayModeClicked:(id)sender {
    if ([self.displayModePopover isPopoverVisible] == YES)
    {
        [self.displayModePopover dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        return;
    }
    [self releaseAllPopOver];
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
#ifdef IPHONE_VERSION
    self.displayModeController = [[DisplayModeController alloc] initWithNibName:@"DisplayModeController-iPhone" bundle:nil];
    [self presentModalViewController:self.displayModeController animated:YES];
#else
    self.displayModeController = [[DisplayModeController alloc] init];
    self.displayModePopover = [[UIPopoverController alloc] initWithContentViewController:self.displayModeController];
    self.displayModePopover.popoverContentSize = self.displayModeController.view.frame.size;
    
    [self.displayModePopover presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

- (IBAction)historyListClicked:(id)sender {
    if ([self.historyListPopover isPopoverVisible] == YES)
    {
        [self.historyListPopover dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        return;
    }
    [self releaseAllPopOver];
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
    self.historyListController = [[HistoryListController alloc] init];
#ifdef IPHONE_VERSION
    [self presentModalViewController:self.historyListController animated:YES];
#else
    self.historyListPopover = [[UIPopoverController alloc] initWithContentViewController:self.historyListController];
    self.historyListPopover.popoverContentSize = self.historyListController.view.frame.size;
    
    [self.historyListPopover presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

- (IBAction)virtualizeButtonClicked:(id)sender {
    if (isVirtualizeDisplayed == YES)
        return;
    
    // if we are in split webview, we need to hide it

    if (self.secondWebView.frame.size.height != 10)
    {
        [UIView beginAnimations:@"WebViewAnimate"context:nil];
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:self];
        // Only one webview
        [self singleWebView];
        [self.webViewSegmentController setSelectedSegmentIndex:0];
        self.activeWebView = self.webView;
        self.historyController = self.upHistoryController;
        [self.activeMark setHidden:YES];
        [UIView commitAnimations];
    }
    [self.splitWebViewButton setTitle:@"日"];
    self.virtualizeViewController = [[VirtualizeViewController alloc] init];
    [self showVirtualizeView];
    isVirtualizeDisplayed = YES;
}

- (void) showVirtualizeView
{
    [self.view insertSubview:self.virtualizeViewController.view belowSubview:_bottomToolBar];
    [UIView beginAnimations:@"WebViewAnimate"context:nil];
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    CGRect rect = self.webView.frame;
    rect.size.height = self.view.frame.size.height/2;
    [self.webView setFrame:rect];
    
    CGRect rect2 = self.virtualizeViewController.view.frame;
    rect2.origin.y = self.view.frame.size.height/2;
    rect2.size.height = self.view.frame.size.height/2;
    rect2.size.width = self.webView.frame.size.width;
    [self.virtualizeViewController.view setFrame:rect2];
    [UIView commitAnimations];
}

- (void) hideVirtualizeView
{
    [self.virtualizeViewController.view removeFromSuperview];
    [self setVirtualizeViewController:nil];

    [UIView beginAnimations:@"WebViewAnimate"context:nil];
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [self singleWebView];
    [UIView commitAnimations];
    isVirtualizeDisplayed = NO;
}

- (void) splitWebView
{
    CGRect rect = self.webView.frame;
    rect.size.height = self.view.frame.size.height/2;
    rect.size.height -= self.webViewSegmentController.frame.size.height/2;
    [self.webView setFrame:rect];
    CGRect sRect = self.webViewSegmentController.frame;
    sRect.origin.x = 10;
    sRect.origin.y = rect.origin.y + rect.size.height;
    [self.webViewSegmentController setFrame:sRect];
    rect.origin.y = rect.size.height + self.webViewSegmentController.frame.size.height;
    [self.secondWebView setFrame:rect];
    rect = self.divider.frame;
    rect.origin.y = self.webViewSegmentController.frame.origin.y;
    rect.origin.x = self.webViewSegmentController.frame.origin.x+self.webViewSegmentController.frame.size.width;
    [self.divider setFrame:rect];
    
    if ([self.webViewSegmentController selectedSegmentIndex] == 0)
    {
        rect = self.activeMark.frame;
        rect.origin.x = 5;
        rect.origin.y = self.webView.frame.size.height-rect.size.height;
        [self.activeMark setFrame:rect];
        [self.activeMark setHidden:NO];
    }
    else
    {
        rect = self.activeMark.frame;
        rect.origin.x = 5;
        rect.origin.y = self.secondWebView.frame.origin.y;
        [self.activeMark setFrame:rect];
        [self.activeMark setHidden:NO];
    }
}

- (void) singleWebView
{
    CGRect rect = self.webView.frame;
    rect.size.height = self.view.frame.size.height;
    [self.webView setFrame:rect];
    rect.origin.y = self.view.frame.size.height - 10;
    rect.size.height = 10;
    [self.secondWebView setFrame:rect];
}

- (IBAction)sourceSplitClicked:(id)sender {
    if (isVirtualizeDisplayed == YES)
        return;
    // change bar button item
    if (self.secondWebView.frame.size.height == 10)
    {
        [self.splitWebViewButton setTitle:@"口"];
    }
    else {
        [self.splitWebViewButton setTitle:@"日"];
    }
    
    [UIView beginAnimations:@"WebViewAnimate"context:nil];
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    if (self.secondWebView.frame.size.height == 10)
    {
        // Split webview
        [self splitWebView];
    }
    else
    {
        // Only one webview
        [self singleWebView];
        [self.webViewSegmentController setSelectedSegmentIndex:0];
        self.activeWebView = self.webView;
        self.historyController = self.upHistoryController;
        [self.activeMark setHidden:YES];
    }
    [UIView commitAnimations];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    //barButtonItem.title = NSLocalizedString(@"Project", @"Project");
    //[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    [hideMasterViewButton setImage:[UIImage imageNamed:@"show_masterview.png"]];
#ifdef LITE_VERSION
    [[[Utils getInstance] getBannerViewController] viewDidLayoutSubviews];
#endif
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    //[self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [hideMasterViewButton setImage:[UIImage imageNamed:@"hide_masterview.png"]];
#ifdef LITE_VERSION
//    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
//    if (UIInterfaceOrientationIsPortrait(orientation)) {
//        [[[Utils getInstance] getBannerViewController] hideBannerView];
//    }
    [[[Utils getInstance] getBannerViewController] viewDidLayoutSubviews];
#endif
}

- (void) showCommentInWebView:(int)_line andComment:(NSString*)_comment
{
    NSString* comment = _comment;
    comment = [comment stringByReplacingOccurrencesOfString:@"\n" withString:@"lgz_br_lgz"];
    
    NSString* js = [NSString stringWithFormat:@"showComment('%d','%@');",_line+1, comment];
    [activeWebView stringByEvaluatingJavaScriptFromString:js];
}

#ifdef IPHONE_VERSION
- (IBAction)filesButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:NO];
}
#endif

-(void) showAllComments
{
    // Show comments
    NSString* currentDisplayFile;
    if (activeWebView == self.webView)
    {
        NSString* path = [self.upHistoryController pickTopLevelUrl];
        currentDisplayFile = [self.upHistoryController getUrlFromHistoryFormat:path];
    }
    else
    {
        NSString* path = [self.downHistoryController pickTopLevelUrl];
        currentDisplayFile = [self.downHistoryController getUrlFromHistoryFormat:path];
    }
    currentDisplayFile = [[Utils getInstance] getSourceFileByDisplayFile:currentDisplayFile];
    NSString* extention = [currentDisplayFile pathExtension];
    NSString* commentFile = [currentDisplayFile stringByDeletingPathExtension];
    commentFile = [commentFile stringByAppendingFormat:@"_%@", extention];
    commentFile = [commentFile stringByAppendingPathExtension:@"lgz_comment"];
    
    CommentWrapper* commentWrapper = [[CommentWrapper alloc] init];
    [commentWrapper readFromFile:commentFile];
    for (int i=0; i<[commentWrapper.commentArray count]; i++) {
        CommentItem* item = [commentWrapper.commentArray objectAtIndex:i];
        [self showCommentInWebView:item.line andComment:item.comment];
    }
}

#pragma mark - WebView Delegate

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString* js = @"";
    int lll;
    switch (jsState) {
        case JS_HISTORY_MODE:
            js = [js stringByAppendingString:@"scrollTo"];
            js = [js stringByAppendingFormat:@"(0,%d)",jsHistoryModeScrollY];
            [webView stringByEvaluatingJavaScriptFromString:js];
            jsHistoryModeScrollY = 0;
            break;
        case JS_GOTO_LINE_AND_FOCUS_KEYWORD:
            lll = jsGotoLine;
            lll -= LINE_DELTA;
            if (lll <= 0)
                lll = 1;
            js = [NSString stringWithFormat:@"smoothScroll('L%d')", lll];
            [webView stringByEvaluatingJavaScriptFromString:js];
            js = [NSString stringWithFormat:@"highlight_this_line_keyword('L%d', '%@')", jsGotoLine, _jsGotoLineKeyword];
            [webView stringByEvaluatingJavaScriptFromString:js];
            jsGotoLine = 0;
            _jsGotoLineKeyword = nil;
            break;
        default:
            break;
    }
    //js = @"document.body.style.zoom = 1.5;";
    //[self.webView stringByEvaluatingJavaScriptFromString:js];
    jsState = JS_NONE;
    js = nil;
    
    NSString *js1 = @"document.getElementsByTagName('link')[0].setAttribute('href','";
    NSString* css = [NSString stringWithFormat:@"theme.css?v=%d",[[Utils getInstance] getCSSVersion]];
    NSString *js2 = [js1 stringByAppendingString:css];
    NSString *finalJS = [js2 stringByAppendingString:@"');"];
    [webView stringByEvaluatingJavaScriptFromString:finalJS];
    
    // For virtualize controller, highlight all children keyword
    if ([self.virtualizeViewController isNeedHighlightChildKeyword] == YES )
    {
        [self.virtualizeViewController highlightAllChildrenKeyword];
    }
    
    [self showAllComments];
}

#define SWIPE_STEP 350

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    static int multiTouchStarted = 0;
    static int multiTouchState = 0;//0:not defined 1: forward 2: backward
    NSString* tmp = [request.URL absoluteString];
    
    //multi touch start
    if ([tmp rangeOfString:@"lgz_multi_touch_start"].location != NSNotFound) {
        tmp = [tmp lastPathComponent];
        //TODO
        NSArray* array = [tmp componentsSeparatedByString:@":"];
        if ([array count] != 2) {
            return NO;
        }
        int value = [[array objectAtIndex:1]intValue];
        if (multiTouchStarted == 0) {
            multiTouchStarted = value;
        }
        else {
            CGRect rect = historySwipeImageView.frame;
            int delta = value - multiTouchStarted;
            if (multiTouchState == 0) {
                if (delta > 10) {
                    //backward
                    if (value > self.view.frame.size.width/2) {
                        multiTouchStarted = 0;
                        return NO;
                    }
                    rect.origin.x = 0;
                    multiTouchState = 2;
                    [historySwipeImageView setImage:[UIImage imageNamed:@"backward_history.png"]];
                    [historySwipeImageView setFrame:rect];
                    [historySwipeImageView setHidden:NO];
                } else if (delta < -10) {
                    //forward
                    if (value < self.view.frame.size.width/2) {
                        multiTouchStarted = 0;
                        return NO;
                    }
                    rect.origin.x = self.view.frame.size.width;
                    multiTouchState = 1;
                    [historySwipeImageView setImage:[UIImage imageNamed:@"forward_history.png"]];
                    [historySwipeImageView setFrame:rect];
                    [historySwipeImageView setHidden:NO];
                }
                return NO;
            }
            
            int detailViewWidth = self.view.frame.size.width;
            //change img position
            if (multiTouchState == 2) {
                //backward
                rect.origin.x = (detailViewWidth - rect.size.width) * ((float)delta/(float)SWIPE_STEP);
                [historySwipeImageView setFrame:rect];
            } else {
                //forward
                rect.origin.x = detailViewWidth + detailViewWidth * ((float)delta/(float)SWIPE_STEP);
                [historySwipeImageView setFrame:rect];
            }
            
            //perform forward/backward
            if (delta >= SWIPE_STEP) {
                //NSLog(@"Touc Move Back %d :%d", value, delta);
                multiTouchStarted = 0;
                multiTouchState = 0;
                [historySwipeImageView setHidden:YES];
                [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(goBackHistory) userInfo:nil repeats:NO];      
            }
            else if(delta <= -(SWIPE_STEP)) {
                //NSLog(@"Touc Move Forward %d :%d", value, delta);
                multiTouchStarted = 0;
                multiTouchState = 0;
                [historySwipeImageView setHidden:YES];
                [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(goForwardHistory) userInfo:nil repeats:NO];      
            }
        }
        return NO;
    }
    
//    //multi touch end
//    if ([tmp rangeOfString:@"lgz_touch_end"].location == 0) {
//        if (multiTouchStarted == 0) {
//            return NO;
//        }
//        NSArray* array = [tmp componentsSeparatedByString:@":"];
//        if ([array count] != 2) {
//            multiTouchStarted = 0;
//            return NO;
//        }
//        int value = [[array objectAtIndex:1]intValue];
//        
//        NSLog(@"Ended %d %d", value, value - multiTouchStarted);
//        if (value > 80) {
//            [self goBackHistory];
//        }
//        else if (value < -80) {
//            [self goForwardHistory];
//        }
//        multiTouchStarted = 0;
//        return NO;
//    }
    
    //touch start
    if ([[tmp lastPathComponent] compare:@"lgz_touch_start"] == NSOrderedSame) {
        multiTouchStarted = 0;
        multiTouchState = 0;
        [historySwipeImageView setHidden:YES];
        [scrollItem setHidden:YES];
        [scrollBackgroundView setBackgroundColor:[UIColor clearColor]];
        
        // set activeview
        if (self.secondWebView.frame.size.height > 10){
            if (self.webView == webView) {
                [self setUpWebViewAsActive];
                [self.webViewSegmentController setSelectedSegmentIndex:0];
            } else if (self.secondWebView == webView){
                [self setDownWebViewAsActive];
                [self.webViewSegmentController setSelectedSegmentIndex:1];
            }
        }
        return NO;
    }
    
    NSArray* array = [tmp componentsSeparatedByString:@"lgz_redirect:"];
    if ([array count] == 2)
    {
        NSString* currentDisplayFile;
        if (webView == self.webView)
        {
            NSString* path = [self.upHistoryController pickTopLevelUrl];
            currentDisplayFile = [self.upHistoryController getUrlFromHistoryFormat:path];
        }
        else
        {
            NSString* path = [self.downHistoryController pickTopLevelUrl];
            currentDisplayFile = [self.downHistoryController getUrlFromHistoryFormat:path];
        }
        NSString* projectFolder = [[Utils getInstance] getProjectFolder:currentDisplayFile];
        
        // if just get entry for virtualization
        if ([self.virtualizeViewController isGetEntryFromWebView] == YES)
        {
            currentDisplayFile = [[Utils getInstance] getSourceFileByDisplayFile:currentDisplayFile];
            currentDisplayFile = [[Utils getInstance] getPathFromProject:currentDisplayFile];
            
            // Set here before actually call cscope
            [self.virtualizeViewController setIsNeedGetResultFromCscope:YES];
            [[Utils getInstance] cscopeSearch:[array objectAtIndex:1] andPath:currentDisplayFile andProject:projectFolder andType:1 andFromVir:YES];
        }
        else
        {
            currentDisplayFile = [[Utils getInstance] getSourceFileByDisplayFile:currentDisplayFile];
            [self navigationManagerPopUpWithKeyword:[array objectAtIndex:1] andSourcePath:currentDisplayFile];
        }
        return NO;
    }
    array = [tmp componentsSeparatedByString:@"lgz_fold_"];
    if ([array count] == 2)
    {
        NSString* lineStr = [array objectAtIndex:1];
        NSArray* array = [lineStr componentsSeparatedByString:@":"];
        if ([array count] != 3) {
            return NO;
        }
        //MAGIC
        NSString* tmp = [array objectAtIndex:0];
        if ([tmp compare:@"%7B"] == NSOrderedSame) {
            tmp = @"{";
        } else if ([tmp compare:@"%l2"] == NSOrderedSame) {
            tmp = @"\"\"\"";
        }
        NSString* token = [NSString stringWithFormat:@"'%@'", tmp];
        NSString* js = [NSString stringWithFormat:@"hideLines(%@, %@, %@);", token, [array objectAtIndex:1], [array objectAtIndex:2]];
        [webView stringByEvaluatingJavaScriptFromString:js];
        return NO;
    }
    //comment support
    array = [tmp componentsSeparatedByString:@"lgz_comment:"];
    if ([array count] == 2) {
        NSString* lineStr = [array objectAtIndex:1];
        int line = [lineStr intValue];
        //TODO
//        [[Utils getInstance].webServicePopOverController dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        [[Utils getInstance].analyzeInfoPopover dismissPopoverAnimated:YES];
        
#ifdef IPHONE_VERSION
        CommentViewController* viewController = [[CommentViewController alloc] initWithNibName:@"CommentViewController-iPhone" bundle:nil];
#else
        CommentViewController* viewController = [[CommentViewController alloc] init];
#endif
        [viewController setLine:line];
        NSString* currentDisplayFile;
        if (webView == self.webView)
        {
            NSString* path = [self.upHistoryController pickTopLevelUrl];
            currentDisplayFile = [self.upHistoryController getUrlFromHistoryFormat:path];
        }
        else
        {
            NSString* path = [self.downHistoryController pickTopLevelUrl];
            currentDisplayFile = [self.downHistoryController getUrlFromHistoryFormat:path];
        }
        currentDisplayFile = [[Utils getInstance] getSourceFileByDisplayFile:currentDisplayFile];
        [viewController initWithFileName:currentDisplayFile];
        viewController.modalPresentationStyle = UIModalPresentationFormSheet;
#ifdef IPHONE_VERSION
        [self presentModalViewController:viewController animated:YES];
#else
        [[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
#endif
        return NO;
    }
    return YES;
}

@end
