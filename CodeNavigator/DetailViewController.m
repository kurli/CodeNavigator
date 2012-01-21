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
@synthesize gotoLineViewController = _gotoLineViewController;
@synthesize gotoLinePopover = _gotoLinePopover;
@synthesize filePathInfopopover;
@synthesize filePathInfoController;
@synthesize highlghtWordPopover;
@synthesize highlightWordController;
@synthesize displayModePopover;
@synthesize displayModeController;

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
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setCountTextField:nil];
    [self.historyController.historyStack removeAllObjects];
    [self.historyController setHistoryStack:nil];
    [self setHistoryController:nil];
    [self setSearchWord:nil];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
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
        //[self reloadCurrentPage];
    }
    return YES;
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect frameTop = self.topToolBar.frame;
    CGRect frameBottom = self.bottomToolBar.frame;
    if ([[Utils getInstance].splitViewController isShowingMaster] == YES)
    {
        frameTop.origin.x = 74;
        frameBottom.origin.x = 74;
    }
    else
    {
        UIDeviceOrientation  orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
            frameTop.origin.x = 74;
            frameBottom.origin.x = 74;
        }
        else {
            frameTop.origin.x = 212;
            frameBottom.origin.x = 212;
        }
    }
    [UIView beginAnimations:@"ToolBarPosX"context:nil];         
    [UIView setAnimationDuration:0.30];           
    [UIView setAnimationDelegate:self];          
    [self.topToolBar setFrame:frameTop];
    [self.bottomToolBar setFrame:frameBottom];
    [UIView commitAnimations];
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBeginBannerViewActionNotification:) name:BannerViewActionWillBegin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishBannerViewActionNotification:) name:BannerViewActionDidFinish object:nil];
        _bannerCounter = 0;
    }
    self.historyController = [[HistoryController alloc] init];
    return self;
}

- (void)willBeginBannerViewActionNotification:(NSNotification *)notification
{
}

- (void)didFinishBannerViewActionNotification:(NSNotification *)notification
{
    [[[Utils getInstance] getBannerViewController] hideBannerView];
}

#pragma detailviewcontroller interface for others
- (void)setTitle:(NSString *)title andPath:(NSString*)path andContent:(NSString *)content
{
    int location = [self getCurrentScrollLocation];
    [self.titleTextField setTitle:title];
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    NSURL *baseURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"] isDirectory:YES];
    [[Utils getInstance] changeUIViewStyle:self.webView];
    [self.webView loadHTMLString:content baseURL:baseURL];
    [self.historyController updateCurrentScrollLocation:location];
    [self.historyController pushUrl:path];
    content = nil;
//    jsState = JS_HISTORY_MODE;
//    jsHistoryModeScrollY = 0;
}

- (void) gotoFile:(NSString *)filePath andLine:(NSString *)line andKeyword:(NSString *)__keyword
{
    MasterViewController* masterViewController = nil;
    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
    
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
    
    if ([[Utils getInstance] isSupportedType:filePath] == YES)
    {
        html = [[Utils getInstance] getDisplayFile:filePath andProjectBase:nil];
        displayPath = [[Utils getInstance] getDisplayPath:filePath];
        int location = [self getCurrentScrollLocation];
        [self.titleTextField setTitle:title];        
        NSString* currentDisplayFile = [self getCurrentDisplayFile];
        [self.historyController updateCurrentScrollLocation:location];
        [self.historyController pushUrl:displayPath];
        if (currentDisplayFile == nil || !([currentDisplayFile compare:displayPath] == NSOrderedSame))
        {
            NSURL *baseURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"] isDirectory:YES];
            [[Utils getInstance] changeUIViewStyle:self.webView];
            [self.webView loadHTMLString:html baseURL:baseURL];
//            jsState = JS_HISTORY_MODE;
//            jsHistoryModeScrollY = 0;
            jsState = JS_GOTO_LINE_AND_FOCUS_KEYWORD;
            jsGotoLine = [line intValue];
            _jsGotoLineKeyword = __keyword;
            
            MasterViewController* masterViewController = nil;
            NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
            masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
            [masterViewController gotoFile:displayPath];
        }
        else
        {
            NSString* js = [NSString stringWithFormat:@"smoothScroll('L%d')", [line intValue]];
            [self.webView stringByEvaluatingJavaScriptFromString:js];
            //magic way to dis highlight current words
            js = @"highlight('liguangzhen+++++++++++++++++++++++++++++++++++++++++')";
            [self.webView stringByEvaluatingJavaScriptFromString:js];
            js = [NSString stringWithFormat:@"highlight_this_line_keyword('L%d', '%@')", [line intValue], __keyword];
            [self.webView stringByEvaluatingJavaScriptFromString:js];
        }
    }
 }

-(int) getCurrentScrollLocation
{
    NSString* location = [self.webView stringByEvaluatingJavaScriptFromString:@"currentYPosition()"];
    return [location intValue];
}

- (void)goBackHistory {
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError* error;
    NSString* url = nil;
    int location = [self getCurrentScrollLocation];
    [self.historyController updateCurrentScrollLocation:location];
    NSString* history = [self.historyController popUrl];
    if (history == nil)
        return;
    NSRange locationRange = [history rangeOfString:@"::" options:NSBackwardsSearch];
    if( locationRange.location != NSNotFound )
    {
        url = [history substringToIndex:locationRange.location];
        NSString* tmp = [history substringFromIndex:locationRange.location+locationRange.length];
        jsState = JS_HISTORY_MODE;
        jsHistoryModeScrollY = [tmp intValue];
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
    
    NSString* content = [NSString stringWithContentsOfFile:url encoding:encoding error:&error];
    NSArray* array = [url pathComponents];
    NSString* title = [array lastObject];
    locationRange = [title rangeOfString:@".display" options:NSBackwardsSearch];
    if ( locationRange.location != NSNotFound)
    {
        title = [title substringToIndex:locationRange.location];
        locationRange = [title rangeOfString:@"_" options:NSBackwardsSearch];
        if ( locationRange.location != NSNotFound )
        {
            NSString* name = [title substringToIndex:locationRange.location];
            NSString* extention = [title substringFromIndex:locationRange.location+1];
            title = [NSString stringWithFormat:@"%@.%@", name,extention];
        }
    }
    [self.titleTextField setTitle:title];        
    NSURL *baseURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"] isDirectory:YES];
    [[Utils getInstance] changeUIViewStyle:self.webView];
    [self.webView loadHTMLString:content baseURL:baseURL];
    MasterViewController* masterViewController = nil;
    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
    [masterViewController gotoFile:url];
}

- (void)goForwardHistory {
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSError* error;
    NSString* url = nil;
    int location = [self getCurrentScrollLocation];
    [self.historyController updateCurrentScrollLocation:location];
    NSString* history = [self.historyController getNextUrl];
    if (history == nil)
        return;
    NSRange locationRange = [history rangeOfString:@"::" options:NSBackwardsSearch];
    if( locationRange.location != NSNotFound )
    {
        url = [history substringToIndex:locationRange.location];
        NSString* tmp = [history substringFromIndex:locationRange.location+locationRange.length];
        jsState = JS_HISTORY_MODE;
        jsHistoryModeScrollY = [tmp intValue];
    }
    else
    {
        url = history;
        jsState = JS_HISTORY_MODE;
        jsHistoryModeScrollY = 0;
    }
    BOOL isFolder;
    if (![[NSFileManager defaultManager] fileExistsAtPath:url isDirectory:&isFolder])
    {
        NSString* filePathFromProject = [[Utils getInstance] getPathFromProject:url];
        filePathFromProject = [[Utils getInstance] getSourceFileByDisplayFile:filePathFromProject];
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:[NSString stringWithFormat:@"%@\n File not found",filePathFromProject]];
        return;
    }
    NSString* content = [NSString stringWithContentsOfFile:url encoding:encoding error:&error];
    NSArray* array = [url pathComponents];
    NSString* title = [array lastObject];
    locationRange = [title rangeOfString:@".display" options:NSBackwardsSearch];
    if ( locationRange.location != NSNotFound)
    {
        title = [title substringToIndex:locationRange.location];
        locationRange = [title rangeOfString:@"_" options:NSBackwardsSearch];
        if ( locationRange.location != NSNotFound )
        {
            NSString* name = [title substringToIndex:locationRange.location];
            NSString* extention = [title substringFromIndex:locationRange.location+1];
            title = [NSString stringWithFormat:@"%@.%@", name,extention];
        }
    }
    [self.titleTextField setTitle:title];        
    NSURL *baseURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"] isDirectory:YES];
    [[Utils getInstance] changeUIViewStyle:self.webView];
    [self.webView loadHTMLString:content baseURL:baseURL];
    MasterViewController* masterViewController = nil;
    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
    [masterViewController gotoFile:url];
}


-(void) dismissNavigationManager
{
    [_codeNavigationPopover dismissPopoverAnimated:YES];
}

-(NSString*) getCurrentDisplayFile
{
    NSString* path = [self.historyController pickTopLevelUrl];
    NSArray* array = [path componentsSeparatedByString:@"::"];
    if ([array count] > 1)
        return [array objectAtIndex:0];
    return path;
}

-(void) reloadCurrentPage
{
    NSError *error;
    NSString* html;
    NSString* currentDisplayFile = [self getCurrentDisplayFile];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    html = [NSString stringWithContentsOfFile: currentDisplayFile usedEncoding:&encoding error: &error];
    NSURL *baseURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"] isDirectory:YES];
    [[Utils getInstance] changeUIViewStyle:self.webView];
    [self.webView loadHTMLString:html baseURL:baseURL];
}

- (void)navigationManagerPopUpWithKeyword:(NSString*)keyword andProject:(NSString*)path {
    if (_codeNavigationPopover.isPopoverVisible == YES)
    {
        [_codeNavigationPopover dismissPopoverAnimated:YES];
        [self releaseAllPopOver];
        return;
    }
    [self releaseAllPopOver];
    
    _codeNavigationController= [[NavigationController alloc] init];
    [_codeNavigationController setSearchKeyword:keyword];
    [_codeNavigationController setCurrentSearchProject:path];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:_codeNavigationController];
    _codeNavigationController.title = @"Code Navigator";
    // Setup the popover for use from the navigation bar.
	_codeNavigationPopover = [[UIPopoverController alloc] initWithContentViewController:controller];
	_codeNavigationPopover.popoverContentSize = CGSizeMake(320., 320.);
    
    [_codeNavigationPopover presentPopoverFromBarButtonItem:self.navigateBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _bannerCounter++;
    if (_bannerCounter == 10)
    {
        [[[Utils getInstance] getBannerViewController] showBannerView];
        _bannerCounter = 0;
    }
}

-(void) releaseAllPopOver
{
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

-(void) setCurrentSearchFocusLine:(int)line andTotal:(int)total
{
    currentSearchFocusLine = line;
    searchLineTotal = total;
}

- (void)upSelectButton {
    
    if (currentSearchFocusLine == 0)
        return;
    currentSearchFocusLine--;
    NSString* js = [NSString stringWithFormat:@"gotoLine(%d)", currentSearchFocusLine];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    NSString* show = [NSString stringWithFormat:@"%d/%d", currentSearchFocusLine, searchLineTotal];
    [self.countTextField setText:show];
}

- (void)downSelectButton {
    if (currentSearchFocusLine == searchLineTotal-1)
        return;
    currentSearchFocusLine++;
    NSString* js = [NSString stringWithFormat:@"gotoLine(%d)", currentSearchFocusLine];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    NSString* show = [NSString stringWithFormat:@"%d/%d", currentSearchFocusLine, searchLineTotal];
    [self.countTextField setText:show];
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
    self.filePathInfopopover = [[UIPopoverController alloc] initWithContentViewController:self.filePathInfoController];
    NSString* realSourceFile = [[Utils getInstance] getPathFromProject:currentFile];
    realSourceFile = [realSourceFile stringByDeletingLastPathComponent];
    realSourceFile = [realSourceFile stringByAppendingPathComponent:self.titleTextField.title];
    self.filePathInfoController.label.text = realSourceFile;
    self.filePathInfopopover.popoverContentSize = CGSizeMake(640., 45);
    [self.filePathInfopopover presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    
    MasterViewController* masterViewController = nil;
    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
    NSString* projectPath = [[Utils getInstance] getProjectFolder:masterViewController.currentLocation];
    
    if (projectPath == nil)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    
    _codeNavigationController= [[NavigationController alloc] init];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:_codeNavigationController];
    _codeNavigationController.title = @"Code Navigator";
    // Setup the popover for use from the navigation bar.
	_codeNavigationPopover = [[UIPopoverController alloc] initWithContentViewController:controller];
	_codeNavigationPopover.popoverContentSize = CGSizeMake(320., 320.);
    
    [_codeNavigationController setCurrentSearchProject:projectPath];
    [_codeNavigationController setSearchKeyword:@""];
    [_codeNavigationPopover presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    
    self.resultViewController = [[ResultViewController alloc] init];
    self.resultViewController.detailViewController = self;
    UINavigationController *result_controller = [[UINavigationController alloc] initWithRootViewController:self.resultViewController];
    self.resultViewController.title = @"Result";
    _resultPopover = [[UIPopoverController alloc] initWithContentViewController:result_controller];
    CGSize size = self.view.frame.size;
    size.height = size.height/3+39;
    size.width = size.width;
	_resultPopover.popoverContentSize = size;
    
    [_resultPopover presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    _gotoLinePopover = [[UIPopoverController alloc] initWithContentViewController:_gotoLineViewController];
    _gotoLinePopover.popoverContentSize = CGSizeMake(250., 45.);

    [_gotoLinePopover presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    CGRect frameTop = self.topToolBar.frame;
    CGRect frameBottom = self.bottomToolBar.frame;
    [[Utils getInstance].splitViewController toggleMasterView:nil];
    if ([[Utils getInstance].splitViewController isShowingMaster] == YES)
    {
        frameTop.origin.x = 74;
        frameBottom.origin.x = 74;
    }
    else
    {
        UIDeviceOrientation  orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
            frameTop.origin.x = 74;
            frameBottom.origin.x = 74;
        }
        else {
            frameTop.origin.x = 212;
            frameBottom.origin.x = 212;
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
    self.highlightWordController = [[HighLightWordController alloc] init];
    self.highlightWordController.detailViewController = self;
    self.highlghtWordPopover = [[UIPopoverController alloc] initWithContentViewController:self.highlightWordController];
    self.highlghtWordPopover.popoverContentSize = CGSizeMake(198, 46);
    
    [self.highlghtWordPopover presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    self.displayModeController = [[DisplayModeController alloc] init];
    self.displayModePopover = [[UIPopoverController alloc] initWithContentViewController:self.displayModeController];
    self.displayModePopover.popoverContentSize = self.displayModeController.view.frame.size;
    
    [self.displayModePopover presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Project", @"Project");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

#pragma mark - WebView Delegate

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString* js = @"";
    switch (jsState) {
        case JS_HISTORY_MODE:
            js = [js stringByAppendingString:@"scrollTo"];
            js = [js stringByAppendingFormat:@"(0,%d)",jsHistoryModeScrollY];
            [webView stringByEvaluatingJavaScriptFromString:js];
            jsHistoryModeScrollY = 0;
            break;
        case JS_GOTO_LINE_AND_FOCUS_KEYWORD:
            js = [NSString stringWithFormat:@"smoothScroll('L%d')", jsGotoLine];
            [self.webView stringByEvaluatingJavaScriptFromString:js];
            js = [NSString stringWithFormat:@"highlight_this_line_keyword('L%d', '%@')", jsGotoLine, _jsGotoLineKeyword];
            [self.webView stringByEvaluatingJavaScriptFromString:js];
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
    [self.webView stringByEvaluatingJavaScriptFromString:finalJS];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* tmp = [request.URL absoluteString];
    NSArray* array = [tmp componentsSeparatedByString:@"lgz_redirect:"];
    if ([array count] == 2)
    {
        NSString* projectFolder = [[Utils getInstance] getProjectFolder:[self getCurrentDisplayFile]];

        [self navigationManagerPopUpWithKeyword:[array objectAtIndex:1] andProject:projectFolder];
        return NO;
    }
    return YES;
}

@end
