//
//  MasterViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "WebServiceController.h"
#import "cscope.h"
#import "GitLogViewCongroller.h"
#import "DropBoxViewController.h"
#import "SecurityViewController.h"
#import "CommentManager.h"

#import "FileInfoViewController.h"
#import "HelpViewController.h"
#import "git2.h"
#import "GitCloneViewController.h"
#import "FileListBrowserController.h"
#import "UploadSelectionViewController.h"
#import "DisplayController.h"
#import "UploadFromITunesViewController.h"
#import "ChartBoardViewController.h"

@interface MasterViewController ()

#ifndef IPHONE_VERSION
@property (strong, nonatomic) FileBrowserTreeViewController* fileBrowserTreeViewController;
#endif

@end
@implementation MasterViewController {
}
@synthesize fileSearchBar = _fileSearchBar;

@synthesize tableView = _tableView;
@synthesize currentProjectPath = _currentProjectPath;
@synthesize webServiceController = _webServiceController;
@synthesize analyzeButton = _analyzeButton;
#ifdef LITE_VERSION
@synthesize purchaseButton = _purchaseButton;
#endif
@synthesize popOverController;
@synthesize fileListBrowserController;
@synthesize gitCloneViewController;
@synthesize toolBar;
#ifndef IPHONE_VERSION
@synthesize fileBrowserTreeViewController;
#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Projects", @"Projects");
//        self clearsSelectionOnViewWillAppear = NO;
//        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        fileListBrowserController = [[FileListBrowserController alloc]init];
        [fileListBrowserController setFileListBrowserDelegate:self];
        [fileListBrowserController setEnableFileInfoButton:YES];
        // we do not show edit button from v1.8
//        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        needSelectRowAfterReload = -1;
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([Utils getInstance].currentThemeSetting == nil)
    {
        [ThemeManager readColorScheme];
    }
    [self reloadData];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(reloadData:) name:MASTER_VIEW_RELOAD object:nil];
}

- (void) reloadData: (id)empty
{
    [self reloadData];
}

-(void) reloadData
{
    [fileListBrowserController reloadData];
    [self.tableView reloadData];
    if (needSelectRowAfterReload != -1) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:needSelectRowAfterReload inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        needSelectRowAfterReload = -1;
    }
}

- (void)viewDidUnload
{
//    //[self setCurrentLocation:nil];
//    [self setCommentManagerPopOverController: nil];
////    [self.currentFiles removeAllObjects];
//////    [self setCurrentProjectPath:nil];
////    [self.currentDirectories removeAllObjects];
//    [self setCurrentDirectories:nil];
//    [self setCurrentFiles: nil];
//    [self setWebServiceController:nil];
//    [self.webServicePopOverController dismissPopoverAnimated:NO];
//    [self setWebServicePopOverController:nil];
//    [self setTableView:nil];
//    [self setAnalyzeButton:nil];
//#ifdef LITE_VERSION
//    [self setPurchaseButton:nil];
//#endif
//    [self setFileSearchBar:nil];
//    [self.fileInfoPopOverController dismissPopoverAnimated:NO];
//    [self setFileInfoPopOverController:nil];
//#ifdef IPHONE_VERSION
//    [self setFileInfoControlleriPhone:nil];
//#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MASTER_VIEW_RELOAD object:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [self setFileSearchBar:nil];
    [self setPopOverController: nil];
    [self setCurrentProjectPath:nil];
    [self setWebServiceController:nil];
    [self setGitCloneViewController:nil];
    [self setTableView:nil];
    [self setAnalyzeButton:nil];
    [self setFileListBrowserController:nil];
#ifdef LITE_VERSION
    [self setPurchaseButton:nil];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [fileListBrowserController set_tableView:self.tableView];
    
    // Select table view
    if (needSelectRowAfterReload != -1) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:needSelectRowAfterReload inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        needSelectRowAfterReload = -1;
    }

    [self.fileSearchBar setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.fileSearchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self adjustViewContent];
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

-(void) adjustViewContent {
    if ([fileListBrowserController getIsCurrentProjectFolder]) {
        [self showFileSearchBar:NO];
    }
    else {
#ifndef IPHONE_VERSION
        if (fileBrowserTreeViewController != nil) {
            [self showFileSearchBar:NO];
        } else {
            [self showFileSearchBar:YES];
        }
#else
        [self showFileSearchBar:YES];
#endif
    }
    
    
    if (![self.fileListBrowserController getIsCurrentSearchFileMode]) {
#ifndef IPHONE_VERSION
        if (self.fileBrowserTreeViewController == nil) {
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                [self showRightNavigationBar:YES];
            } else {
                [self showRightNavigationBar:NO];
            }
        }
#endif
    }
}

-(void) showFileSearchBar:(BOOL)show {
    if (show) {
        if ([self.fileSearchBar isHidden] == NO) {
            return;
        }
        [self.fileSearchBar setHidden:NO];
        [self.analyzeButton setEnabled:YES];
        [self.commentButton setEnabled:YES];
        //iOS7 UI bug fix
        // In iOS 7 the status bar is transparent, so don't adjust for it.
//        if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            CGRect rect = self.tableView.frame;
            rect.origin.y = self.fileSearchBar.frame.origin.y + self.fileSearchBar.frame.size.height;
            rect.size.height -= rect.origin.y;
            [self.tableView setFrame:rect];
        }
    } else {
        if ([self.fileSearchBar isHidden] == YES) {
            return;
        }
        [self.fileSearchBar setHidden:YES];
        [self.analyzeButton setEnabled:NO];
        [self.commentButton setEnabled:NO];
        CGRect rect = self.tableView.frame;
        rect.size.height += rect.origin.y;
        rect.origin.y = 0;
        [self.tableView setFrame:rect];
    }
}

-(void) showRightNavigationBar:(BOOL)show {
    if (show) {
        UIImage *buttonImage = [UIImage imageNamed:@"treeView.png"];
//        UIButton *rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
//        [rightBar setImage:buttonImage forState:UIControlStateNormal];
//        rightBar.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        rightBar.frame = CGRectMake(0, 0, buttonImage.size.width*6, buttonImage.size.height);
//        [rightBar addTarget:self action:@selector(rightNavigationButtonClicked:)
//             forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(rightNavigationButtonClicked:)];

//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
//                                                 initWithCustomView:rightBar];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self showRightNavigationBar:YES];
    } else {
        [self showRightNavigationBar:NO];
    }
}

#pragma mark tableView delegate
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [fileListBrowserController numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fileListBrowserController tableView:tableView numberOfRowsInSection:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [fileListBrowserController tableView:tableView cellForRowAtIndexPath:indexPath];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [fileListBrowserController tableView:tableView canEditRowAtIndexPath:indexPath];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [fileListBrowserController tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [fileListBrowserController tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void) setIsProjectFolder:(BOOL)_isProjectFolder
{
    [fileListBrowserController setIsCurrentProjectFolder:_isProjectFolder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [fileListBrowserController tableView:tableView didSelectRowAtIndexPath: indexPath];
    [self.fileSearchBar resignFirstResponder];
}

-(void) gotoFile:(NSString *)filePath andForce:(BOOL)force
{
    if (!force && [[Utils getInstance].splitViewController isShowingMaster] == NO) {
        return;
    }
    
    // If input is a display file, change to source file
    filePath = [[Utils getInstance] getSourceFileByDisplayFile:filePath];
    
    // If current table view is in search mode, just ignore it
    if ([fileListBrowserController getIsCurrentSearchFileMode]) {
        return;
    }
    
    if (filePath == nil)
    {
        NSLog(@"file path is nil");
        return;
    }
    
    [self setCurrentPath:filePath];
    return;
    
    
    /*
    MasterViewController* targetViewController = nil;
    NSArray* targetComponents = [filePath pathComponents];
    NSArray* currentComponents = [fileListBrowserController.currentLocation pathComponents];
    if ([targetComponents count] == 0 || [currentComponents count] == 0)
    {
        NSLog(@"path components is null");
        return;
    }
    NSString* target_component = nil;
    NSString* current_component = nil;
    NSInteger index = 0;
    while (1) {
        target_component = [targetComponents objectAtIndex:index];
        current_component = [currentComponents objectAtIndex:index];
        if ([target_component compare:current_component] != NSOrderedSame)
        {
            index--;
            break;
        }
        if (index == [targetComponents count]-2 || index == [currentComponents count]-1)
            break;
        index++;
    }
    // if target in pre directory
    if (index < [currentComponents count]-1)
    {
        NSArray* array = [self.navigationController viewControllers];
        NSInteger target = [array count] -[currentComponents count]+index;
        if (target < 0 || target > [array count]) {
            return;
        }
        targetViewController = (MasterViewController*)[array objectAtIndex:target];
        [self.navigationController popToViewController:targetViewController animated:NO];
    }
    else
        targetViewController = self;
    
    BOOL founded = NO;
    NSString* path = targetViewController.fileListBrowserController.currentLocation;
    // go to the target directory
    for (NSInteger i=index+1; i<[targetComponents count]-1; i++)
    {
        MasterViewController* masterViewController;
#ifdef IPHONE_VERSION
        masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController-iPhone" bundle:nil];
#else
        masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
#endif
        path = [path stringByAppendingPathComponent:[targetComponents objectAtIndex:i]];
        // If current is Project Folder
        if ([targetViewController.fileListBrowserController getIsCurrentProjectFolder])
            masterViewController.currentProjectPath = path;
        else
            masterViewController.currentProjectPath = targetViewController.currentProjectPath;
        
        masterViewController.fileListBrowserController.currentLocation = path;
        masterViewController.title = [targetComponents objectAtIndex:i];
        targetViewController.webServiceController = self.webServiceController;
        targetViewController.gitCloneViewController = self.gitCloneViewController;
        [masterViewController reloadData];
        // Select Folder
        int i = 0;
        for (i = 0; i<[targetViewController.fileListBrowserController.currentDirectories count]; i++)
        {
            if ([masterViewController.title compare:[targetViewController.fileListBrowserController.currentDirectories objectAtIndex:i]] == NSOrderedSame)
            {
                founded = YES;
                break;
            }
        }
        if (founded == YES) {
            [targetViewController setNeedSelectRowAfterReload:i];
        }
        // end

        [targetViewController.navigationController pushViewController:masterViewController animated:NO];
        targetViewController = masterViewController;
    }
    
    NSString* title = [targetComponents lastObject];
    title = [[Utils getInstance] getSourceFileByDisplayFile:title];
    
    founded = NO;
    index = [targetViewController.fileListBrowserController getCurrentDirectoriesCount];
    for (int i = 0; i<[targetViewController.fileListBrowserController.currentFiles count]; i++)
    {
        if ([title compare:[targetViewController.fileListBrowserController.currentFiles objectAtIndex:i]] == NSOrderedSame)
        {
            index += i;
            founded = YES;
            break;
        }
    }
    if (founded == YES) {
        if (targetViewController != self) {
            [targetViewController setNeedSelectRowAfterReload:index];
        } else {
            [targetViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
     */
}

-(void) setCurrentPath:(NSString*)path {
    if ([path length] == 0) {
        return;
    }
    path = [[Utils getInstance] getSourceFileByDisplayFile:path];
    
    // Set project path
    NSString* projPath = [[Utils getInstance] getProjectFolder:path];
    self.currentProjectPath = projPath;
    if (projPath == nil) {
        [self.fileListBrowserController setIsCurrentProjectFolder:YES];
    } else {
        [self .fileListBrowserController setIsCurrentProjectFolder:NO];
    }
    
    // Set path
    NSString* folderPath;
    BOOL isDirectory = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        NSLog(@"File not exist: %@", path);
        return;
    }
    if (isDirectory) {
        folderPath = path;
    } else {
        folderPath = [path stringByDeletingLastPathComponent];
    }

    self.fileListBrowserController.currentLocation = folderPath;
    NSString* title_ = [folderPath lastPathComponent];
    if ([title_ isEqualToString:@".Projects"] == YES) {
        self.title = @"Projects";
    } else {
        self.title = [folderPath lastPathComponent];
    }
    [self reloadData];
    
    // Select file
    if (!isDirectory) {
        BOOL founded = NO;
        NSInteger index = [fileListBrowserController getCurrentDirectoriesCount];
        NSString* title = [path lastPathComponent];
        for (int i = 0; i<[fileListBrowserController.currentFiles count]; i++)
        {
            if ([title compare:[fileListBrowserController.currentFiles objectAtIndex:i]] == NSOrderedSame)
            {
                index += i;
                founded = YES;
                break;
            }
        }
        if (founded == YES) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    
    // Set left bar button
    [[NSFileManager defaultManager] fileExistsAtPath:projPath isDirectory:&isDirectory];
    
    // Set Left navigation bar
    if (projPath != nil && isDirectory) {
        NSString* preFolder = [folderPath stringByDeletingLastPathComponent];
        preFolder = [preFolder lastPathComponent];
        if (self.navigationItem.leftBarButtonItem == nil) {
            UIImage *buttonImage = [UIImage imageNamed:@"back_arrow.png"];
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftButton setImage:buttonImage forState:UIControlStateNormal];
            leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [leftButton setTitle:preFolder forState:UIControlStateNormal];
            leftButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            [leftButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
            [leftButton setTitleColor:[UIColor colorWithRed:86/255.0 green:121/255.0 blue:183/255.0 alpha:1.0] forState:UIControlStateNormal];
            leftButton.frame = CGRectMake(0, 0, buttonImage.size.width*6, buttonImage.size.height);
            [leftButton addTarget:self action:@selector(leftNavigationButtonClicked:)
                    forControlEvents:UIControlEventTouchUpInside];
            
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithCustomView:leftButton];
        } else {
            UIView* customView = self.navigationItem.leftBarButtonItem.customView;
            if ([customView isKindOfClass:[UIButton class]]) {
                UIButton* button = (UIButton*)customView;
                [button setTitle:preFolder forState:UIControlStateNormal];
            }
        }
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }

    // Adjust view
    [self adjustViewContent];
}

- (IBAction)leftNavigationButtonClicked:(id)sender
{
    NSString* prePath = [self.fileListBrowserController.currentLocation stringByDeletingLastPathComponent];
    [self setCurrentPath:prePath];
    
#ifndef IPHONE_VERSION
    if (self.fileBrowserTreeViewController) {
        [self.fileBrowserTreeViewController pathBack];
    }
#endif
}

- (IBAction)rightNavigationButtonClicked:(id)sender
{
#ifndef IPHONE_VERSION
    if (self.navigationItem.rightBarButtonItem == nil) {
        return;
    }
    
    // Change MasterView size
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
	// Correct for orientation.
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
    } else {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            NSInteger tmp = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = tmp;
        }
    }
    CGSize size = bounds.size;
    size.width = size.width / 4;
    [[Utils getInstance].splitViewController setSplitPosition:size.width];
    
    [self.fileListBrowserController setEnableFileInfoButton:NO];
    
    // Show file browser tree
    fileBrowserTreeViewController = [[Utils getInstance].detailViewController showFileBrowserTreeView:YES];
    
    // Hide right navigation bar
    [self showRightNavigationBar:NO];
    
    // Hide search bar
    [self showFileSearchBar:NO];
    
    [self.toolBar setUserInteractionEnabled:NO];
#endif
}

- (IBAction)analyzeButtonClicked:(id)sender {
    [[Utils getInstance] analyzeProject:self.currentProjectPath andForceCreate:YES];
}

- (void) showGitCloneView
{    
    [self releaseAllPopover];
    if (gitCloneViewController == NULL) {
#ifdef IPHONE_VERSION
        gitCloneViewController = [[GitCloneViewController alloc] initWithNibName:@"GitCloneViewController-iPhone" bundle:[NSBundle mainBundle]];
#else
        gitCloneViewController = [[GitCloneViewController alloc] init];
#endif
    }
    gitCloneViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    //[[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
#ifdef IPHONE_VERSION
    [self presentViewController:gitCloneViewController animated:YES completion:nil];
#else
    [[Utils getInstance].splitViewController presentViewController:gitCloneViewController animated:YES completion:nil];
#endif
}

- (IBAction)gitClicked:(id)sender {
//    [[Utils getInstance] addGAEvent:@"Git" andAction:@"From Toolbar" andLabel:nil andValue:nil];
//    
//    // If in project list mode, means git clone a project from remote
//    if ([self.currentProjectPath length] == 0) {
//        [self showGitCloneView];
//        return;
//    }
//    
//#ifdef IPHONE_VERSION
//    GitLogViewCongroller* gitlogView = [[GitLogViewCongroller alloc] initWithNibName:@"GitLogViewController-iPhone" bundle:[NSBundle mainBundle]];
//#else
//    GitLogViewCongroller* gitlogView = [[GitLogViewCongroller alloc] initWithNibName:@"GitLogViewController" bundle:[NSBundle mainBundle]];
//#endif
//    NSString* gitFolder = [[Utils getInstance] getGitFolder:self.currentProjectPath];
//    if ([gitFolder length] != 0) {
//        [gitlogView gitLogForProject: gitFolder];
//        [gitlogView showModualView];
//    } else {
//        [self showGitCloneView];
//    }
    ChartBoardViewController* viewController = [[ChartBoardViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [[Utils getInstance].splitViewController presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)dropBoxClicked:(id)sender {
#ifndef IPHONE_VERSION
    [self releaseAllPopover];
    DropBoxViewController* dropBoxViewController = [[DropBoxViewController alloc] initWithNibName:@"DropBoxViewController" bundle:[NSBundle mainBundle]];
    [[Utils getInstance] setDropBoxViewController:dropBoxViewController];
    [dropBoxViewController showModualView];
    dropBoxViewController = nil;
#endif
    [[Utils getInstance] addGAEvent:@"Dropbox" andAction:@"Clicked" andLabel:nil andValue:nil];
}

- (void) releaseAllPopover
{
    [popOverController dismissPopoverAnimated:YES];
    [self setPopOverController:nil];
}

- (IBAction)versionControlButtonClicked:(id)sender {
    if ([popOverController isPopoverVisible]) {
        [self releaseAllPopover];
        return;
    }
    
    [self releaseAllPopover];
    [self gitClicked:sender];
}

- (IBAction)lockButtonClicked:(id)sender {
    if ([popOverController isPopoverVisible]) {
        [self releaseAllPopover];
        return;
    }
    
    [self releaseAllPopover];
    [[Utils getInstance].detailViewController releaseAllPopOver];
    
    SecurityViewController* viewController = [[SecurityViewController alloc] init];
    [[Utils getInstance].splitViewController presentViewController:viewController animated:YES completion:nil];
    [[Utils getInstance] addGAEvent:@"Lock" andAction:@"Clicked" andLabel:nil andValue:nil];
}

- (IBAction)commentClicked:(id)sender {
    [[Utils getInstance] addGAEvent:@"Comment" andAction:@"Manage" andLabel:nil andValue:nil];
    
    if ([popOverController isPopoverVisible]) {
        [self releaseAllPopover];
        return;
    }
    
    [self releaseAllPopover];
    
    if ([fileListBrowserController getIsCurrentProjectFolder]) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    
#ifdef IPHONE_VERSION
    CommentManager* controller = [[CommentManager alloc] initWithNibName:@"CommentManager-iPhone" bundle:nil];
#else
    UIBarButtonItem *item = (UIBarButtonItem*)sender;
    CommentManager* controller = [[CommentManager alloc] init];
#endif
    [controller initWithMasterViewController:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];

    controller.title = @"Comments";
#ifdef IPHONE_VERSION
    [self presentViewController:navigationController animated:YES completion:nil];
#else
    popOverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    popOverController.popoverContentSize = controller.view.frame.size;
    [popOverController presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}


#ifdef LITE_VERSION
- (IBAction)purchaseClicked:(id)sender {
    [[Utils getInstance] openPurchaseURL];
}
#endif

- (void) showWebUploadService
{
    [self releaseAllPopover];
    
    if (_webServiceController == nil)
    {
#ifdef IPHONE_VERSION
        _webServiceController = [[WebServiceController alloc] initWithNibName:@"WebServiceControllerFormSheet-iPhone" bundle:nil];
#else
        _webServiceController = [[WebServiceController alloc]initWithNibName:@"WebServiceControllerFormSheet" bundle:nil];
#endif
    }
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:_webServiceController];
    _webServiceController.title = @"Web Upload Service";
    [_webServiceController setMasterViewController:self];
#ifndef IPHONE_VERSION
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [[Utils getInstance].splitViewController presentViewController:controller animated:YES completion:nil];
#endif
    
#ifdef IPHONE_VERSION
    [self presentViewController:controller animated:YES completion:nil];
#endif
}

- (IBAction)addFileToolBarClicked:(id)sender {
    if ([popOverController isPopoverVisible]) {
        [self releaseAllPopover];
        return;
    }
    [self releaseAllPopover];
    UIBarButtonItem* barButton = (UIBarButtonItem*)sender;
    
#ifdef LITE_VERSION
    [[Utils getInstance] showPurchaseAlert];
#endif

    
    UploadSelectionViewController* uploadSelection = [[UploadSelectionViewController alloc] initWithNibName:@"UploadSelectionViewController" bundle:nil];
    
    [uploadSelection setMasterViewController:self];
    
    CGSize size = uploadSelection.view.frame.size;
    size.height = size.height / 6 * 5;
    
#ifdef IPHONE_VERSION
    popOverController = [[FPPopoverController alloc] initWithContentViewController:uploadSelection];
#else
    popOverController = [[UIPopoverController alloc] initWithContentViewController:uploadSelection];
#endif

	popOverController.popoverContentSize = size;
#ifdef IPHONE_VERSION
    popOverController.arrowDirection = FPPopoverArrowDirectionDown;
    popOverController.border = NO;
    [popOverController presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES andToolBar:self.toolBar];
#else
    [popOverController presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}

#pragma mark SearchDelegate

- (IBAction)searchFileDoneButtonClicked:(id)sender
{
    [fileListBrowserController searchFileDoneButtonClicked:sender];
    
    [self.fileSearchBar setText:@""];
    [self.fileSearchBar resignFirstResponder];
    [self setCurrentPath:self.fileListBrowserController.currentLocation];
    [self showRightNavigationBar:YES];
//    [self.tableView reloadData];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    [fileListBrowserController searchBarTextDidBeginEditing:theSearchBar];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(searchFileDoneButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = nil;
    [_tableView reloadData];
}

- (void) searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    if ([self.currentProjectPath length] == 0) {
        return;
    }
    if ([searchText length] == 0) {
        return;
    }

    [fileListBrowserController searchBar:theSearchBar textDidChange:searchText andCurrentProjPath:self.currentProjectPath];
    
    [self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.fileSearchBar resignFirstResponder];
}

- (void) helpButtonClicked:(id)sender
{
    HelpViewController* viewController = [[HelpViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
#ifndef IPHONE_VERSION
    [[Utils getInstance].splitViewController presentViewController:viewController animated:YES completion:nil];
#else
    [self presentViewController:viewController animated:YES completion:nil];
#endif
}

- (NSString*)getCurrentLocation
{
    return fileListBrowserController.currentLocation;
}

#pragma mark FileListBrowserDelegate

- (IBAction)fileInfoButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UIView *contentView;
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        contentView = [button superview];
    } else if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        contentView = [[button superview] superview];
    } else {
        contentView = [button superview];
    }
    UITableViewCell *cell = (UITableViewCell*)[contentView superview];
    if ([cell isKindOfClass:[UITableViewCell class]] == false) {
        [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"Error code 1, please contact guangzhen@hotmail.com, Thanks"];
        return;
    }
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    if ([popOverController isPopoverVisible]) {
        [self releaseAllPopover];
        return;
    }
    
    [self releaseAllPopover];
    
    NSString* fileName;
    if (indexPath.row < [self.fileListBrowserController getCurrentDirectoriesCount])
    {
        if (indexPath.row < [self.fileListBrowserController getCurrentDirectoriesCount])
            fileName = [self.fileListBrowserController getDirectoryAtIndex:indexPath.row];
        else
            return;
    } else {
        fileName = [self.fileListBrowserController getFileNameAtIndex:indexPath.row-[self.fileListBrowserController getCurrentDirectoriesCount]];
    }
    
    NSString* path = [fileListBrowserController.currentLocation stringByAppendingPathComponent:fileName];
    FileInfoViewController* fileInfoViewController = [[FileInfoViewController alloc] init];
    [fileInfoViewController setSourceFile:path];
    [fileInfoViewController setMasterViewController:self];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:fileInfoViewController];
    fileInfoViewController.title = @"Action";
    // Setup the popover for use from the navigation bar.
#ifdef IPHONE_VERSION
    popOverController = [[FPPopoverController alloc] initWithViewController:controller];
#else
    popOverController = [[UIPopoverController alloc] initWithContentViewController:controller];
#endif
    popOverController.popoverContentSize = fileInfoViewController.view.frame.size;
#ifdef IPHONE_VERSION
    [popOverController setBorder:NO];
    [popOverController presentPopoverFromView:button];
#else
    [popOverController presentPopoverFromRect:button.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
#endif
}

- (void) folderClickedDelegate:(UITableView*) tableView andSelectedItem:(NSString*)selectedItem andPath:(NSString*)path
{
#ifndef IPHONE_VERSION
    if (self.fileBrowserTreeViewController) {
        [self.fileBrowserTreeViewController changeToPath:path];
        return;
    }
#endif
    
    // When git clone in progress, stop entering this folder
    if ([fileListBrowserController getIsCurrentProjectFolder] &&
        [[gitCloneViewController cloneThread] isExecuting] &&
        [[gitCloneViewController needCloneProjectName] isEqualToString:[path lastPathComponent]]) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Git clone in progress in this folder"];
        return;
    }
    
    if ([fileListBrowserController getIsCurrentProjectFolder])
        [[Utils getInstance] analyzeProject:path andForceCreate:NO];
    
    [self setCurrentPath:path];
    [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
//    MasterViewController* masterViewController;
//#ifdef IPHONE_VERSION
//    masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController-iPhone" bundle:nil];
//#else
//    masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
//#endif
//    
//    if ([fileListBrowserController getIsCurrentProjectFolder])
//        [[Utils getInstance] analyzeProject:path andForceCreate:NO];
//    
//    // If current is Project Folder
//    if ([fileListBrowserController getIsCurrentProjectFolder])
//        masterViewController.currentProjectPath = path;
//    else
//        masterViewController.currentProjectPath = self.currentProjectPath;
//    
//    [masterViewController.fileListBrowserController setCurrentLocation:path];
//    masterViewController.title = selectedItem;
//    masterViewController.webServiceController = self.webServiceController;
//    masterViewController.gitCloneViewController = self.gitCloneViewController;
//    //[masterViewController reloadData];
//    [self.navigationController pushViewController:masterViewController animated:NO];
}

- (void) fileClickedDelegate:(UITableView*) tableView andSelectedItem:(NSString*)selectedItem andPath:(NSString*)path
{
    NSString* html;
    
    DetailViewController* controller = [Utils getInstance].detailViewController;
    

#ifdef IPHONE_VERSION
    [self presentViewController:[Utils getInstance].detailViewController animated:YES completion:nil];
#endif
    
#ifndef IPHONE_VERSION
    // Close file browser tree view
    if (self.fileBrowserTreeViewController) {
        [[Utils getInstance].detailViewController showFileBrowserTreeView:NO];
        [self onTreeViewDismissed];
    }
#endif
    
    //Help.html special case
    if ([fileListBrowserController getIsCurrentProjectFolder] == YES && [selectedItem compare:@"Help.html"] == NSOrderedSame) {
        NSError *error;
        NSStringEncoding encoding = NSUTF8StringEncoding;
        html = [NSString stringWithContentsOfFile: path usedEncoding:&encoding error: &error];
        [controller setTitle:selectedItem andPath:path andContent:html andBaseUrl:nil];
        return;
    }
    
    if ([[Utils getInstance] isDocType:path])
    {
        [controller displayDocTypeFile:path];
        return;
    }
    
    [[Utils getInstance] getDisplayFile:path andProjectBase:self.currentProjectPath andFinishBlock:^(NSString* html) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* displayPath;

            displayPath = [[Utils getInstance] getDisplayPath:path];
            if (html != nil)
            {
                [controller setTitle:selectedItem andPath:displayPath andContent:html andBaseUrl:nil];
            }
        });
    }];
    
    //other case
    {
        //            if ([[Utils getInstance] isWebType:path])
        //            {
        //                NSError *error;
        //                NSStringEncoding encoding = NSUTF8StringEncoding;
        //                html = [NSString stringWithContentsOfFile: path usedEncoding:&encoding error: &error];
        //                [controller setTitle:selectedItem andPath:path andContent:html];
        //            }
        
        //            NSStringEncoding encoding = NSUTF8StringEncoding;
        //            html = [NSString stringWithContentsOfFile: path usedEncoding:&encoding error: &error];
        //            [controller setTitle:selectedItem andPath:path andContent:html];
    }
}

- (NSString*) getCurrentProjectPath
{
    return self.currentProjectPath;
}

- (void) setNeedSelectRowAfterReload:(NSInteger)index {
    needSelectRowAfterReload = index;
}

-(void) downloadZipFromGitHub {
    [self releaseAllPopover];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.github.com"]];
}

-(void) uploadFromITunes {
    [self.popOverController dismissPopoverAnimated:YES];
    
#ifdef IPHONE_VERSION
    UploadFromITunesViewController* controller = [[UploadFromITunesViewController alloc] initWithNibName:@"UploadFromITunesViewController-iPhone" bundle:nil];
#else
    UploadFromITunesViewController* controller = [[UploadFromITunesViewController alloc] init];
#endif
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
#ifdef IPHONE_VERSION
    [self presentViewController:controller animated:YES completion:nil];
#else
    [[Utils getInstance].splitViewController presentViewController:controller animated:YES completion:nil];
#endif
}

#pragma FileBrowserTreeViewDelegate

-(void) onParentNeedChangePath:(NSString *)path {
    [self setCurrentPath:path];
}

-(void) onTreeViewDismissed {
#ifndef IPHONE_VERSION
    self.fileBrowserTreeViewController = nil;
    [self adjustViewContent];
    [self showRightNavigationBar:YES];
    [self.fileListBrowserController setEnableFileInfoButton:YES];
    
    [self.toolBar setUserInteractionEnabled:YES];
    
    CGSize size = [Utils getInstance].splitViewController.view.frame.size;
    size.width = size.width / 4;
    [[Utils getInstance].splitViewController setSplitPosition:320];
#endif
}

- (void) setFocusItem:(NSString*)path {
    [self.fileListBrowserController setFocusItem:path];
}

- (void) onFileClickedFromTreeView:(NSString*)selectedItem andPath:(NSString*)path {
    [self gotoFile:path andForce:YES];
    [self fileClickedDelegate:self.tableView andSelectedItem:selectedItem andPath:path];
}

@end
