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
#import "FunctionListViewController.h"
#import "FileBrowserViewController.h"
#import "DisplayController.h"
#import "ThemeSelectorViewController.h"
#import <CommonCrypto/CommonDigest.h>

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

@synthesize resultBarButton = _resultBarButton;

@synthesize navigateBarButtonItem = _navigateBarButtonItem;
@synthesize webView = _webView;
@synthesize searchWordU;
@synthesize searchWordD;
@synthesize titleTextField = _titleTextField;
@synthesize historyController = _historyController;
@synthesize historyBar = _historyBar;
@synthesize jsGotoLineKeyword = _jsGotoLineKeyword;
@synthesize analyzeInfoBarButton = _analyzeInfoBarButton;
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
@synthesize historyListController;
@synthesize secondWebView;
@synthesize activeWebView;
@synthesize divider;
@synthesize upHistoryController;
@synthesize downHistoryController;
@synthesize virtualizeViewController;
@synthesize highlightLineArray;
@synthesize scrollBarTapRecognizer;
@synthesize showCommentsSegment;
@synthesize popoverController;

#pragma mark - Managing the detail item

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
#ifdef LITE_VERSION
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBeginBannerViewActionNotification:) name:BannerViewActionWillBegin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishBannerViewActionNotification:) name:BannerViewActionDidFinish object:nil];
    _bannerCounter = 0;
    isVirtualizeDisplayed = NO;
#endif
    NSString* upFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/upHistory.setting"];
    NSString* downFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/downHistory.setting"];

    self.upHistoryController = [[HistoryController alloc] init];
    [self.upHistoryController readFromFile:upFilePath];
    self.downHistoryController = [[HistoryController alloc] init];
    [self.downHistoryController readFromFile:downFilePath];
    self.historyController = self.upHistoryController;

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
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
    [self setScrollBarTapRecognizer:nil];
    [self setVirtualizeViewController:nil];
    [self setUpHistoryController:nil];
    [self setDownHistoryController:nil];
    [self setActiveWebView:nil];
    [self setSecondWebView:nil];
    [self setHistoryListController:nil];
    [self setWebView:nil];
    [self setHistoryController:nil];
    [self setSearchWordU:nil];
    [self setSearchWordD:nil];
    [self setHighlightLineArray:nil];
    [self setHistoryBar:nil];
    [self setResultBarButton:nil];
    [self setNavigateBarButtonItem:nil];
    [self setAnalyzeInfoBarButton:nil];
    [self setJsGotoLineKeyword:nil];
    [self setTitleTextField:nil];
    [self setTopToolBar:nil];
    [self setBottomToolBar:nil];
    [self setWebViewSegmentController:nil];
    [self setActiveMark:nil];
    [self setVirtualizeButton:nil];
    [self setDivider:nil];
    [self setHideMasterViewButton:nil];
    [self setSplitWebViewButton:nil];
    [self setPopoverController:nil];
    [self setFileBrowserButton:nil];
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
    [self setHistoryListController:nil];
    [self setWebView:nil];
    [self.historyController.historyStack removeAllObjects];
    [self.historyController setHistoryStack:nil];
    [self setHistoryController:nil];
    [self setSearchWordU:nil];
    [self setSearchWordD:nil];
    [self setHighlightLineArray:nil];
    [self setHistoryBar:nil];
    [self setResultBarButton:nil];
    [self setNavigateBarButtonItem:nil];
    [self setAnalyzeInfoBarButton:nil];
    [self setJsGotoLineKeyword:nil];
    [self setTitleTextField:nil];
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
    [super viewWillAppear:animated];
    if (isFirstDisplay) {
        self.activeWebView.opaque = NO;
        self.activeWebView.backgroundColor = [UIColor clearColor];
        [ThemeManager changeUIViewStyle:self.activeWebView];
        [self.activeWebView setScalesPageToFit:NO];

        // Fix iOS 7 bug
        CGRect rect = self.secondWebView.frame;
        rect.size.height = 10;
        [self.secondWebView setFrame:rect];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Only show help html in the first time
    if (isFirstDisplay) {
        NSString* prevHistory = [upHistoryController pickTopLevelUrl];
        NSString* help = [NSHomeDirectory() stringByAppendingString:@"/Documents/Projects/Help.html"];
        NSError *error;
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSString* html = [NSString stringWithContentsOfFile: help usedEncoding:&encoding error: &error];
        if ([prevHistory length] != 0) {
            [self restoreToHistory:prevHistory];
        } else {
            [self setTitle:@"Help.html" andPath:help andContent:html andBaseUrl:nil];
        }
        
        // Set second webview
        self.activeWebView = secondWebView;
        int location = [self getCurrentScrollLocation];
        [self.downHistoryController updateCurrentScrollLocation:location];
        [self.downHistoryController pushUrl:help];
        [self displayHTMLString:html andBaseURL:nil];
        html = nil;
        self.activeWebView = _webView;
        isFirstDisplay = NO;
    }
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
//    jsState = JS_HISTORY_MODE;
//    jsHistoryModeScrollY = [self getCurrentScrollLocation];
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

- (BOOL)shouldAutorotate {
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
//    NSString *js1 = @"document.getElementsByTagName('link')[0].setAttribute('href','";
//    NSString* css = [NSString stringWithFormat:@"theme.css?v=%d",[[Utils getInstance] getCSSVersion]];
//    NSString *js2 = [js1 stringByAppendingString:css];
//    NSString *finalJS = [js2 stringByAppendingString:@"');"];
//    [activeWebView stringByEvaluatingJavaScriptFromString:finalJS];
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
    [ThemeManager changeUIViewStyle:self.activeWebView];
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
            
            [masterViewController gotoFile:displayPath andForce:NO];
        }
        else
        {
            int lll = [line intValue];
            lll -= LINE_DELTA;
            if (lll <= 0)
                lll = 1;
            NSString* js = [NSString stringWithFormat:@"smoothScroll('L%d')", lll];
            [self.activeWebView stringByEvaluatingJavaScriptFromString:js];
            int tmp = [line intValue];
            js = [NSString stringWithFormat:@"FocusLine('L%d')",tmp];
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
        // Fix version error.
        url = [[Utils getInstance] getSourceFileByDisplayFile:url];
        [[Utils getInstance] getDisplayFile:url andProjectBase:nil];
        url = [[Utils getInstance] getDisplayFileBySourceFile:url];
        if (![[NSFileManager defaultManager] fileExistsAtPath:url isDirectory:&isFolder]){
            url = [[Utils getInstance] getSourceFileByDisplayFile:url];
            NSString* filePathFromProject = [[Utils getInstance] getPathFromProject:url];
            filePathFromProject = [[Utils getInstance] getSourceFileByDisplayFile:filePathFromProject];
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:[NSString stringWithFormat:@"%@\n File not found",filePathFromProject]];
            return;
        }
    }
    
    NSString* extension = [url pathExtension];
    if (extension != nil && [extension compare:DISPLAY_FILE_EXTENTION] == NSOrderedSame)
    {
        NSString* content = [NSString stringWithContentsOfFile:url encoding:encoding error:&error];
        content = [content substringFromIndex:CC_MD5_DIGEST_LENGTH * 2];

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
    [masterViewController gotoFile:url andForce:NO];
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


-(void) dismissPopovers
{
    [popoverController dismissPopoverAnimated:YES];
}

-(NSString*) getCurrentDisplayFile
{
    NSString* path = [self.historyController pickTopLevelUrl];
    return [self.historyController getUrlFromHistoryFormat:path];
}

-(void) reloadCurrentPage
{
    NSString* html;
    NSString* currentDisplayFile = [self getCurrentDisplayFile];
    NSString* sourceFilePath = [[Utils getInstance] getSourceFileByDisplayFile:currentDisplayFile];
    NSString* filePath = [[Utils getInstance] getPathFromProject:sourceFilePath];
    if ([filePath compare:@"Help.html"] == NSOrderedSame) {
        NSError *error;
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSString* html = [NSString stringWithContentsOfFile: sourceFilePath usedEncoding:&encoding error: &error];
        [self setTitle:[sourceFilePath lastPathComponent] andPath:sourceFilePath andContent:html andBaseUrl:nil];
    } else {
        html = [[Utils getInstance] getDisplayFile:sourceFilePath andProjectBase:nil];
        [self displayHTMLString:html andBaseURL:nil];
    }
}

- (void)navigationManagerPopUpWithKeyword:(NSString*)keyword andSourcePath:(NSString*)path {
    if ([popoverController isPopoverVisible]) {
        [self releaseAllPopOver];
        return;
    }

    [self releaseAllPopOver];
    
    NavigationController* codeNavigationController= [[NavigationController alloc] init];
    [codeNavigationController setSearchKeyword:keyword];
    [codeNavigationController setCurrentSourcePath:path];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:codeNavigationController];
    codeNavigationController.title = @"CodeNavigator";
#ifdef IPHONE_VERSION
    // Setup the popover for use from the navigation bar.
	popoverController = [[FPPopoverController alloc] initWithContentViewController:controller];
	popoverController.popoverContentSize = codeNavigationController.view.frame.size;
    popoverController.border = NO;
    
    [popoverController presentPopoverFromBarButtonItem:self.navigateBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES andToolBar:self.bottomToolBar];
#else
    // Setup the popover for use from the navigation bar.
	popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
	popoverController.popoverContentSize = codeNavigationController.view.frame.size;
    
    [popoverController presentPopoverFromBarButtonItem:self.navigateBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    [self.popoverController dismissPopoverAnimated:YES];
    
    [self setPopoverController:nil];
    
    [self setHistoryListController:nil];
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

- (IBAction)historyClicked:(id)sender {
    UISegmentedControl* controller = sender;
    int index = [controller selectedSegmentIndex];
    if (index == 0)
        [self goBackHistory];
    else
        [self goForwardHistory];
}

//Copy from showAllComments
-(void) hideAllComments
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
    NSString* extension = [currentDisplayFile pathExtension];
    NSString* commentFile = [currentDisplayFile stringByDeletingPathExtension];
    commentFile = [commentFile stringByAppendingFormat:@"_%@", extension];
    commentFile = [commentFile stringByAppendingPathExtension:@"lgz_comment"];
    
    CommentWrapper* commentWrapper = [[CommentWrapper alloc] init];
    [commentWrapper readFromFile:commentFile];
    for (int i=0; i<[commentWrapper.commentArray count]; i++) {
        CommentItem* item = [commentWrapper.commentArray objectAtIndex:i];
        [self showCommentInWebView:item.line andComment:@""];
    }
}

- (IBAction)showCommentsClicked:(id)sender {
    UISegmentedControl* controller = sender;
    int index = [controller selectedSegmentIndex];
    if (index == 0) {
        [self showAllComments];
    }
    else {
        [self hideAllComments];
    }
}

- (IBAction)titleTouched:(id)sender {
    if ([popoverController isPopoverVisible]) {
        [self releaseAllPopOver];
        return;
    }
    
    [self releaseAllPopOver];
    
    NSString* currentFile = [self getCurrentDisplayFile];
    currentFile = [[Utils getInstance] getSourceFileByDisplayFile:currentFile];
    if (currentFile == nil)
        return;
//    MasterViewController* masterViewController = nil;
//    NSArray* controllers = [self.splitViewController viewControllers];
//    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
//    [masterViewController gotoFile:currentFile];
    FilePathInfoPopupController* filePathInfoController;
    filePathInfoController = [[FilePathInfoPopupController alloc] init];
#ifdef IPHONE_VERSION
#else
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:filePathInfoController];
    NSString* realSourceFile = [[Utils getInstance] getPathFromProject:currentFile];
    filePathInfoController.label.text = realSourceFile;
    self.popoverController.popoverContentSize = CGSizeMake(640., filePathInfoController.view.frame.size.height);
    [self.popoverController presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    [self releaseAllPopOver];
    
#ifndef IPHONE_VERSION
    MasterViewController* masterViewController = nil;
    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
#else
    MasterViewController* masterViewController = (MasterViewController*)[Utils getInstance].masterViewController.topViewController;
#endif
    NSString* projectPath = [[Utils getInstance] getProjectFolder:[masterViewController getCurrentLocation]];
    
    if (projectPath == nil)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    
    NavigationController* codeNavigationController= [[NavigationController alloc] init];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:codeNavigationController];
    codeNavigationController.title = @"Code Navigator";
#ifdef IPHONE_VERSION
    popoverController = [[FPPopoverController alloc] initWithContentViewController:controller];
	popoverController.popoverContentSize = CGSizeMake(320., 320.);
    popoverController.border = NO;
    
    [codeNavigationController setCurrentSourcePath:projectPath];
    [codeNavigationController setSearchKeyword:@""];
    [popoverController presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES andToolBar:self.bottomToolBar];
#else
    // Setup the popover for use from the navigation bar.
	popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
	popoverController.popoverContentSize = CGSizeMake(320., 320.);
    
    [codeNavigationController setCurrentSourcePath:projectPath];
    [codeNavigationController setSearchKeyword:@""];
    [popoverController presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

-(void) forceResultPopUp:(id)button
{
    if ([popoverController isPopoverVisible] == YES)
    {
        [popoverController dismissPopoverAnimated:YES];
    }
    if ([[Utils getInstance].resultFileList count] == 0)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"No result"];
        return;
    }
    
    ResultViewController* resultViewController;
    
#ifdef IPHONE_VERSION
    resultViewController = [[ResultViewController alloc] initWithNibName:@"ResultViewController-iPhone" bundle:nil];
#else
    UIBarButtonItem* barButton = (UIBarButtonItem*)button;
    resultViewController = [[ResultViewController alloc] init];
#endif
    resultViewController.detailViewController = self;
    UINavigationController *result_controller = [[UINavigationController alloc] initWithRootViewController:resultViewController];
    resultViewController.title = @"Result";
#ifdef IPHONE_VERSION
    [self presentViewController:result_controller animated:YES completion:nil];
#else
    popoverController = [[UIPopoverController alloc] initWithContentViewController:result_controller];
    CGSize size = self.view.frame.size;
    size.height = size.height/3+39+44;
    size.width = size.width;
	popoverController.popoverContentSize = size;
    
    [popoverController presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

-(void) resultPopUp:(id)sender
{
    if ([popoverController isPopoverVisible]) {
        [self releaseAllPopOver];
        return;
    }
    
    [self releaseAllPopOver];
    if ([[Utils getInstance].resultFileList count] == 0)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"No result"];
        return;
    }
    
    ResultViewController* resultViewController;
    
#ifdef IPHONE_VERSION
    resultViewController = [[ResultViewController alloc] initWithNibName:@"ResultViewController-iPhone" bundle:nil];
#else
    UIBarButtonItem* barButton = (UIBarButtonItem*)sender;
    resultViewController = [[ResultViewController alloc] init];
#endif
    resultViewController.detailViewController = self;
    UINavigationController *result_controller = [[UINavigationController alloc] initWithRootViewController:resultViewController];
    resultViewController.title = @"Result";
#ifdef IPHONE_VERSION
    [self presentViewController:result_controller animated:NO completion:nil];
#else
    popoverController = [[UIPopoverController alloc] initWithContentViewController:result_controller];
    CGSize size = self.view.frame.size;
    size.height = size.height/3+39+44;
    size.width = size.width;
	popoverController.popoverContentSize = size;
    
    [popoverController presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

-(void) gotoLinePopUp:(id)sender
{
    if ([popoverController isPopoverVisible]) {
        [self releaseAllPopOver];
        return;
    }
    
    [self releaseAllPopOver];
    
    GotoLineViewController* gotoLineViewController = [[GotoLineViewController alloc] init];
    gotoLineViewController.detailViewController = self;
#ifdef IPHONE_VERSION
    [self presentViewController:gotoLineViewController animated:YES completion:nil];
#else
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
    popoverController = [[UIPopoverController alloc] initWithContentViewController:gotoLineViewController];
    popoverController.popoverContentSize = CGSizeMake(250., 45.);
    
    [popoverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    if (shownToolBar) {
        NSString *str =[NSString stringWithFormat:@"addTablePadding('%fpx')", self.topToolBar.frame.size.height];
        [self.webView stringByEvaluatingJavaScriptFromString:str];
        [self.secondWebView stringByEvaluatingJavaScriptFromString:str];
    } else {
        [self.webView stringByEvaluatingJavaScriptFromString:@"removeTablePadding()"];
        [self.secondWebView stringByEvaluatingJavaScriptFromString:@"removeTablePadding()"];
    }
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
    if ([popoverController isPopoverVisible]) {
        [self releaseAllPopOver];
        return;
    }
    
    [self releaseAllPopOver];
    HighLightWordController * highlightWordController;
    highlightWordController = [[HighLightWordController alloc] init];
    highlightWordController.detailViewController = self;
    
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;

#ifdef IPHONE_VERSION
    self.popoverController = [[FPPopoverController alloc] initWithContentViewController:highlightWordController];
    self.popoverController.border = NO;
    CGSize size = highlightWordController.view.frame.size;
    size.height*=(1.5);
    self.popoverController.popoverContentSize = size;
    self.popoverController.arrowDirection = FPPopoverArrowDirectionUp;
    [self.popoverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES andToolBar:self.topToolBar];
#else
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:highlightWordController];
    self.popoverController.popoverContentSize = highlightWordController.view.frame.size;
    
    [self.popoverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

- (void)upSelectButton {
    
    if (currentSearchFocusLine == 0)
    {
        currentSearchFocusLine = [highlightLineArray count];
        return;
    }
    if (currentSearchFocusLine == -1) {
        currentSearchFocusLine = [highlightLineArray count];
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
    int tmp = [[highlightLineArray objectAtIndex:currentSearchFocusLine] intValue];
    js = [NSString stringWithFormat:@"FocusLine('L%d')",tmp];
    [self.activeWebView stringByEvaluatingJavaScriptFromString:js];
//    NSString* show = [NSString stringWithFormat:@"%d/%d", currentSearchFocusLine, searchLineTotal];
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
    int tmp = [[highlightLineArray objectAtIndex:currentSearchFocusLine] intValue];
    js = [NSString stringWithFormat:@"FocusLine('L%d')",tmp];
    [self.activeWebView stringByEvaluatingJavaScriptFromString:js];
//    NSString* show = [NSString stringWithFormat:@"%d/%d", currentSearchFocusLine, searchLineTotal];
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
    if ([popoverController isPopoverVisible]) {
        [self releaseAllPopOver];
        return;
    }
    
    [self releaseAllPopOver];
//    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
#ifdef IPHONE_VERSION
    ThemeSelectorViewController* viewController = [[ThemeSelectorViewController alloc] initWithNibName:@"ThemeSelectorViewController-iPhone" bundle:[NSBundle mainBundle]];
#else
    ThemeSelectorViewController* viewController = [[ThemeSelectorViewController alloc] init];
#endif
#ifdef IPHONE_VERSION
    [self presentViewController:viewController animated:YES completion:nil];
#else
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [[Utils getInstance].splitViewController presentViewController:viewController animated:YES completion:nil];
#endif
    
//    DisplayModeController* displayModeController;
//#ifdef IPHONE_VERSION
//    displayModeController = [[DisplayModeController alloc] initWithNibName:@"DisplayModeController-iPhone" bundle:nil];
//    [self presentModalViewController:displayModeController animated:YES];
//#else
//    displayModeController = [[DisplayModeController alloc] init];
//    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:displayModeController];
//    self.popoverController.popoverContentSize = displayModeController.view.frame.size;
//    
//    if (sender == nil) {
//        [popoverController dismissPopoverAnimated:YES];
//    } else {
//        [self.popoverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    }
//#endif
    [[Utils getInstance] addGAEvent:@"Settings" andAction:@"DisplayMode" andLabel:nil andValue:nil];
}

- (IBAction)historyListClicked:(id)sender {
    if ([popoverController isPopoverVisible]) {
        [self releaseAllPopOver];
        return;
    }
    
    [self releaseAllPopOver];
    self.historyListController = [[HistoryListController alloc] init];
#ifdef IPHONE_VERSION
    [self presentViewController:self.historyListController animated:YES completion:nil];
#else
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.historyListController];
    self.popoverController.popoverContentSize = self.historyListController.view.frame.size;
    
    [self.popoverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    //[self.splitWebViewButton setTitle:@"日"];
    [self.splitWebViewButton setImage:[UIImage imageNamed:@"seperate.png"]];
    self.virtualizeViewController = [[VirtualizeViewController alloc] init];
    [self showVirtualizeView];
    isVirtualizeDisplayed = YES;
    [[Utils getInstance] addGAEvent:@"Display" andAction:@"Visualize" andLabel:nil andValue:nil];
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
        //[self.splitWebViewButton setTitle:@"口"];
        [self.splitWebViewButton setImage:[UIImage imageNamed:@"screen.png"]];
    }
    else {
        //[self.splitWebViewButton setTitle:@"日"];
        [self.splitWebViewButton setImage:[UIImage imageNamed:@"seperate.png"]];
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

    [[Utils getInstance] addGAEvent:@"Display" andAction:@"MultiView" andLabel:nil andValue:nil];
}

- (IBAction)functionListClicked:(id)sender {
    if ([popoverController isPopoverVisible]) {
        [self releaseAllPopOver];
        return;
    }
    
    [self releaseAllPopOver];
    FunctionListViewController* functionListViewController;
    functionListViewController = [[FunctionListViewController alloc] initWithNibName:@"FunctionListViewController" bundle:nil];
    NSString* currentFilePath = [self getCurrentDisplayFile];
    currentFilePath = [[Utils getInstance] getSourceFileByDisplayFile:currentFilePath];
    [functionListViewController setCurrentFilePath:currentFilePath];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:functionListViewController];
    functionListViewController.title = @"Tag List";

#ifdef IPHONE_VERSION
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
    self.popoverController = [[FPPopoverController alloc] initWithContentViewController:controller];
    //    self.functionListPopover.popoverContentSize = self.historyListController.view.frame.size;
    self.popoverController.border = NO;
    self.popoverController.popoverContentSize = controller.view.frame.size;
    
    [self.popoverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES andToolBar:self.topToolBar];
#else
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
//    self.functionListPopover.popoverContentSize = self.historyListController.view.frame.size;
    
    [self.popoverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif

    [[Utils getInstance] addGAEvent:@"Display" andAction:@"FunctionList" andLabel:nil andValue:nil];
}

- (IBAction)fileBrowserButtonClicked:(id)sender {
    if ([self.popoverController isPopoverVisible] == YES)
    {
        [self.popoverController dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        return;
    }
    [self releaseAllPopOver];
    FileBrowserViewController* fileBrowserViewController;
    fileBrowserViewController = [[FileBrowserViewController alloc] initWithNibName:@"FileBrowserViewController" bundle:nil];
    [fileBrowserViewController setFileBrowserViewDelegate:self];
    [fileBrowserViewController setIsProjectFolder:YES];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:fileBrowserViewController];
    
    NSString* currentFilePath = [self getCurrentDisplayFile];
    [fileBrowserViewController setInitialPath:currentFilePath];
    
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    //    self.functionListPopover.popoverContentSize = self.historyListController.view.frame.size;
    
    [self.popoverController presentPopoverFromRect:CGRectMake(1, 1, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    [self.fileBrowserButton setHidden:NO];
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
    [self.fileBrowserButton setHidden:YES];
    [popoverController dismissPopoverAnimated:YES];
    
    // We need always update MasterView Tableview
    // Because when masterview hidden, gotoFile will be blocked in MasterView
    MasterViewController* masterViewController = nil;
    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
    [masterViewController gotoFile:[self getCurrentDisplayFile] andForce:YES];
}

- (void) showCommentInWebView:(int)_line andComment:(NSString*)_comment
{
    NSString* comment = _comment;
    comment = [comment stringByReplacingOccurrencesOfString:@"\n" withString:@"lgz_br_lgz"];
    comment = [comment stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    comment = [comment stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    comment = [comment stringByReplacingOccurrencesOfString:@"\\" withString:@"\\"];
    
    NSString* js = [NSString stringWithFormat:@"showComment('%d','%@');",_line+1, comment];
    [activeWebView stringByEvaluatingJavaScriptFromString:js];
}

#ifdef IPHONE_VERSION
- (IBAction)filesButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
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
    NSString* extension = [currentDisplayFile pathExtension];
    NSString* commentFile = [currentDisplayFile stringByDeletingPathExtension];
    commentFile = [commentFile stringByAppendingFormat:@"_%@", extension];
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
            js = [NSString stringWithFormat:@"FocusLine('L%d')",jsGotoLine];
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
    
//    NSString *js1 = @"document.getElementsByTagName('link')[0].setAttribute('href','";
//    NSString* css = [NSString stringWithFormat:@"theme.css?v=%d",[[Utils getInstance] getCSSVersion]];
//    NSString *js2 = [js1 stringByAppendingString:css];
//    NSString *finalJS = [js2 stringByAppendingString:@"');"];
//    [webView stringByEvaluatingJavaScriptFromString:finalJS];
//    
//    // Disable long click on the link
//    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
//    
    // For virtualize controller, highlight all children keyword
    if ([self.virtualizeViewController isNeedHighlightChildKeyword] == YES )
    {
        [self.virtualizeViewController highlightAllChildrenKeyword];
    }
    
    if ([showCommentsSegment selectedSegmentIndex] == 0) {
        [self showAllComments];
    }
    if (shownToolBar) {
        NSString *str =[NSString stringWithFormat:@"addTablePadding('%fpx')", self.topToolBar.frame.size.height];
        [webView stringByEvaluatingJavaScriptFromString:str];
    } else {
        [webView stringByEvaluatingJavaScriptFromString:@"removeTablePadding()"];
    }
    
    if ([Utils getInstance].currentThemeSetting.auto_fold_comments) {
        [webView stringByEvaluatingJavaScriptFromString:@"autoFold()"];
    }
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
//        if (self.secondWebView.frame.size.height > 10){
//            if (self.webView == webView) {
//                [self setUpWebViewAsActive];
//                [self.webViewSegmentController setSelectedSegmentIndex:0];
//            } else if (self.secondWebView == webView){
//                [self setDownWebViewAsActive];
//                [self.webViewSegmentController setSelectedSegmentIndex:1];
//            }
//        }
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
        currentDisplayFile = [[Utils getInstance] getSourceFileByDisplayFile:currentDisplayFile];
        NSString* projectFolder = [[Utils getInstance] getProjectFolder:currentDisplayFile];
        // if just get entry for virtualization
        if ([self.virtualizeViewController isGetEntryFromWebView] == YES)
        {
            currentDisplayFile = [[Utils getInstance] getSourceFileByDisplayFile:currentDisplayFile];
            currentDisplayFile = [[Utils getInstance] getPathFromProject:currentDisplayFile];
            
            // Set here before actually call cscope
            [self.virtualizeViewController setIsNeedGetResultFromCscope:YES];
            [[Utils getInstance] cscopeSearch:[array objectAtIndex:1] andPath:currentDisplayFile andProject:projectFolder andType:FIND_GLOBAL_DEFINITION andFromVir:YES];
        }
        else
        {
            NSString* searchWord;
            if (webView == self.webView) {
                searchWord = searchWordU;
            } else {
                searchWord = searchWordD;
            }
            if ([searchWord isEqualToString:[array objectAtIndex:1]]) {
                [self navigationManagerPopUpWithKeyword:[array objectAtIndex:1] andSourcePath:currentDisplayFile];
                return NO;
            }
            // Highlight this keyword
            if (webView == self.webView) {
                [self setSearchWordU:[array objectAtIndex:1]];
            } else {
                [self setSearchWordD:[array objectAtIndex:1]];
            }
            HighLightWordController* highlightTmp = [[HighLightWordController alloc] init];
            [highlightTmp setDetailViewController:self];
            [highlightTmp doSearch:NO andWebView:webView];
            // end
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
        [self presentViewController:viewController animated:YES completion:nil];
#else
        [[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
#endif
        return NO;
    }
    return YES;
}

- (void)fileBrowserViewDisappeared {
}

- (void)folderSelected:(NSString*)path {
}


@end
