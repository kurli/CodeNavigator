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
#import "VersionControlController.h"
#import "SecurityViewController.h"
#import "CommentManager.h"
#ifdef IPHONE_VERSION
#import "FileInfoControlleriPhone.h"
#else
#import "FileInfoViewController.h"
#import "HelpViewController.h"
#import "git2.h"
#endif
#ifdef LITE_VERSION
#import "GAI.h"
#endif
#import "GitCloneViewController.h"
#import "FileListBrowserController.h"

@implementation MasterViewController
@synthesize fileSearchBar = _fileSearchBar;

@synthesize tableView = _tableView;
@synthesize currentProjectPath = _currentProjectPath;
@synthesize webServiceController = _webServiceController;
@synthesize webServicePopOverController = _webServicePopOverController;
@synthesize analyzeButton = _analyzeButton;
#ifdef LITE_VERSION
@synthesize purchaseButton = _purchaseButton;
#endif
@synthesize versionControllerPopOverController;
@synthesize commentManagerPopOverController;
@synthesize fileInfoPopOverController;
#ifdef IPHONE_VERSION
@synthesize fileInfoControlleriPhone;
#endif
@synthesize fileListBrowserController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Projects", @"Projects");
//        self clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        fileListBrowserController = [[FileListBrowserController alloc]init];
        [fileListBrowserController setFileListBrowserDelegate:self];
        [fileListBrowserController set_tableView:self.tableView];
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
    if ([Utils getInstance].colorScheme == nil)
    {
        [[Utils getInstance] readColorScheme];
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
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:needSelectRowAfterReload inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
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
    [self setFileInfoPopOverController:nil];
    [self setFileSearchBar:nil];
    [self setCommentManagerPopOverController: nil];
    [self setCurrentProjectPath:nil];
    [self setWebServiceController:nil];
    [self setWebServicePopOverController:nil];
    [self setTableView:nil];
    [self setAnalyzeButton:nil];
    [self setFileListBrowserController:nil];
#ifdef LITE_VERSION
    [self setPurchaseButton:nil];
#endif
#ifdef IPHONE_VERSION
    [self setFileInfoControlleriPhone:nil];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Select table view
    if (needSelectRowAfterReload != -1) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:needSelectRowAfterReload inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        needSelectRowAfterReload = -1;
    }

    if ([fileListBrowserController getIsCurrentProjectFolder])
    {
        [self.fileSearchBar setHidden:YES];
        [self.analyzeButton setEnabled:NO];
        CGRect rect = self.tableView.frame;
        rect.size.height += (rect.origin.y - self.view.frame.origin.y);
        rect.origin.y = self.view.frame.origin.y;
        [self.tableView setFrame:rect];
    }
    else
    {
        [self.fileSearchBar setHidden:NO];
        [self.analyzeButton setEnabled:YES];
    }
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
    // Return YES for supported orientations
    return YES;
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

-(GLfloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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

-(void) gotoFile:(NSString *)filePath
{
    // If current table view is in search mode, just ignore it
    if ([fileListBrowserController getIsCurrentSearchFileMode]) {
        return;
    }
    
    MasterViewController* targetViewController = nil;
    if (filePath == nil)
    {
        NSLog(@"file path is nil");
        return;
    }
    NSArray* targetComponents = [filePath pathComponents];
    NSArray* currentComponents = [fileListBrowserController.currentLocation pathComponents];
    if ([targetComponents count] == 0 || [currentComponents count] == 0)
    {
        NSLog(@"path components is null");
        return;
    }
    NSString* target_component = nil;
    NSString* current_component = nil;
    int index = 0;
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
        int target = [array count] -[currentComponents count]+index;
        targetViewController = (MasterViewController*)[array objectAtIndex:target];
        [self.navigationController popToViewController:targetViewController animated:NO];
    }
    else
        targetViewController = self;
    
    BOOL founded = NO;
    NSString* path = targetViewController.fileListBrowserController.currentLocation;
    // go to the target directory
    for (int i=index+1; i<[targetComponents count]-1; i++)
    {
        MasterViewController* masterViewController;
#ifdef IPHONE_VERSION
        masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController-iPhone" bundle:nil];
#else
        masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
#endif
        path = [path stringByAppendingPathComponent:[targetComponents objectAtIndex:i]];
        // If current is Project Folder
        if ([fileListBrowserController getIsCurrentProjectFolder])
            masterViewController.currentProjectPath = path;
        else
            masterViewController.currentProjectPath = targetViewController.currentProjectPath;
        
        masterViewController.fileListBrowserController.currentLocation = path;
        masterViewController.title = [targetComponents objectAtIndex:i];
        targetViewController.webServiceController = self.webServiceController;
        targetViewController.webServicePopOverController = self.webServicePopOverController;
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
            [targetViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
    }
}

- (IBAction)analyzeButtonClicked:(id)sender {
    [[Utils getInstance] analyzeProject:self.currentProjectPath andForceCreate:YES];
}

- (void) showGitCloneView
{
    [_webServicePopOverController dismissPopoverAnimated:YES];
    GitCloneViewController* viewController = [[GitCloneViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    //[[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)gitClicked:(id)sender {
#ifndef IPHONE_VERSION
    // If in project list mode, means git clone a project from remote
    if ([self.currentProjectPath length] == 0) {
        [self showGitCloneView];
        return;
    }
    NSError* error;
    GitLogViewCongroller* gitlogView = [[GitLogViewCongroller alloc] initWithNibName:@"GitLogViewCongroller" bundle:[NSBundle mainBundle]];
    NSString* gitFolder = self.currentProjectPath;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[gitFolder stringByAppendingPathComponent:@".git"]]) {
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:gitFolder error:&error];
        for (int i=0; i<[contents count]; i++) {
            NSString* path = [contents objectAtIndex:i];
            path = [self.currentProjectPath stringByAppendingPathComponent:path];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@".git"]]){
                gitFolder = path;
                break;
            }
        }
    }
    [gitlogView gitLogForProject: gitFolder];
    [gitlogView showModualView];
#endif
#ifdef LITE_VERSION
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"ToolBar"
                                                    withAction:nil
                                                     withLabel:@"git clicked"
                                                     withValue:nil];
#endif
}

- (IBAction)dropBoxClicked:(id)sender {
#ifndef IPHONE_VERSION
    DropBoxViewController* dropBoxViewController = [[DropBoxViewController alloc] initWithNibName:@"DropBoxViewController" bundle:[NSBundle mainBundle]];
    [[Utils getInstance] setDropBoxViewController:dropBoxViewController];
    [dropBoxViewController showModualView];
    dropBoxViewController = nil;
#endif
#ifdef LITE_VERSION
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"ToolBar"
                                                    withAction:nil
                                                     withLabel:@"Dropbox clicked"
                                                     withValue:nil];
#endif
}

- (IBAction)versionControlButtonClicked:(id)sender {
#ifndef LITE_VERSION
    // Ignore Dropbox
    UIBarButtonItem *item = (UIBarButtonItem*)sender;

    if ([versionControllerPopOverController isPopoverVisible] == YES) {
        [versionControllerPopOverController dismissPopoverAnimated:YES];
        return;
    }
    if ([commentManagerPopOverController isPopoverVisible] == YES) {
        [commentManagerPopOverController dismissPopoverAnimated:YES];
    }
    
    VersionControlController* controller = [[VersionControlController alloc] init];
    [controller setMasterViewController:self];
    
    versionControllerPopOverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    versionControllerPopOverController.popoverContentSize = controller.view.frame.size;
    
    [versionControllerPopOverController presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#else
    [self gitClicked:sender];
#endif
}

- (IBAction)lockButtonClicked:(id)sender {
    if ([commentManagerPopOverController isPopoverVisible] == YES) {
        [commentManagerPopOverController dismissPopoverAnimated:YES];
    }
    
    if ([versionControllerPopOverController isPopoverVisible] == YES) {
        [versionControllerPopOverController dismissPopoverAnimated:YES];
    }
    [self.webServicePopOverController dismissPopoverAnimated:YES];
    [[Utils getInstance].detailViewController releaseAllPopOver];
    [[Utils getInstance].analyzeInfoPopover dismissPopoverAnimated:YES];
    
    SecurityViewController* viewController = [[SecurityViewController alloc] init];
    [[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
#ifdef LITE_VERSION
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"ToolBar"
                                                    withAction:nil
                                                     withLabel:@"Lock button clicked"
                                                     withValue:nil];
#endif
}

- (IBAction)commentClicked:(id)sender {
#ifdef LITE_VERSION
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"ToolBar"
                                                    withAction:nil
                                                     withLabel:@"Comments clicked"
                                                     withValue:nil];
#endif
    UIBarButtonItem *item = (UIBarButtonItem*)sender;
    
    if ([commentManagerPopOverController isPopoverVisible] == YES) {
        [commentManagerPopOverController dismissPopoverAnimated:YES];
        return;
    }
    
    if ([versionControllerPopOverController isPopoverVisible] == YES) {
        [versionControllerPopOverController dismissPopoverAnimated:YES];
    }
    
    if ([fileListBrowserController getIsCurrentProjectFolder]) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    
#ifdef IPHONE_VERSION
    CommentManager* controller = [[CommentManager alloc] initWithNibName:@"CommentManager-iPhone" bundle:nil];
#else
    CommentManager* controller = [[CommentManager alloc] init];
#endif
    [controller initWithMasterViewController:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];

    controller.title = @"Comments";
#ifdef IPHONE_VERSION
    [self presentModalViewController:navigationController animated:YES];
#else
    commentManagerPopOverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    commentManagerPopOverController.popoverContentSize = controller.view.frame.size;
    [commentManagerPopOverController presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
}


#ifdef LITE_VERSION
- (IBAction)purchaseClicked:(id)sender {
    [[Utils getInstance] openPurchaseURL];
}
#endif

- (void) hideWebUploadService
{
    [_webServicePopOverController dismissPopoverAnimated:YES];
}

- (void) showWebUploadService:(id)sender
{
    UIBarButtonItem *item = (UIBarButtonItem*)sender;
    if (_webServiceController == nil)
    {
#ifdef IPHONE_VERSION
        _webServiceController = [[WebServiceController alloc] initWithNibName:@"WebServiceController-iPhone" bundle:nil];
#else
        _webServiceController = [[WebServiceController alloc]init];
        _webServicePopOverController = [[UIPopoverController alloc] initWithContentViewController:_webServiceController];
        _webServicePopOverController.popoverContentSize = _webServiceController.view.frame.size;
#endif
    }
//    if (_webServicePopOverController.popoverVisible == YES)
//        [_webServicePopOverController dismissPopoverAnimated:YES];
//    else
    {
#ifdef LITE_VERSION
        [[Utils getInstance] showPurchaseAlert];
#endif
        [_webServiceController setMasterViewController:self];
#ifdef IPHONE_VERSION
        [self presentModalViewController:_webServiceController animated:YES];
#else
        [_webServicePopOverController presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
#endif
    }
#ifdef LITE_VERSION
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"ToolBar"
                                                    withAction:nil
                                                     withLabel:@"Web Upload Service"
                                                     withValue:nil];
#endif
}

- (IBAction)addFileToolBarClicked:(id)sender {
    if (!_webServicePopOverController || _webServicePopOverController.popoverVisible == NO) {
        [self showWebUploadService:sender];
        return;
    }
    if (_webServicePopOverController.popoverVisible == YES)
        [_webServicePopOverController dismissPopoverAnimated:YES];
}

#pragma mark SearchDelegate

- (IBAction)searchFileDoneButtonClicked:(id)sender
{
    [fileListBrowserController searchFileDoneButtonClicked:sender];
    
    // ignore it after v1.8
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    [self.fileSearchBar setText:@""];
    [self.fileSearchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    [fileListBrowserController searchBarTextDidBeginEditing:theSearchBar];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(searchFileDoneButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneButton;
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
#ifndef IPHONE_VERSION
    HelpViewController* viewController = [[HelpViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
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
    UIView *contentView = [button superview];
    UITableViewCell *cell = (UITableViewCell*)[contentView superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    if ([self.fileInfoPopOverController isPopoverVisible] == YES) {
        [self.fileInfoPopOverController dismissPopoverAnimated:NO];
    }
    
    if (indexPath.row < [self.fileListBrowserController getCurrentDirectoriesCount])
    {
        return;
    }
    
    NSString* fileName = [self.fileListBrowserController getFileNameAtIndex:indexPath.row-[self.fileListBrowserController getCurrentDirectoriesCount]];
    
    NSString* path = [fileListBrowserController.currentLocation stringByAppendingPathComponent:fileName];
    
#ifdef IPHONE_VERSION
    self.fileInfoControlleriPhone = [[FileInfoControlleriPhone alloc] init];
    [fileInfoControlleriPhone setMasterViewController:self];
    [fileInfoControlleriPhone setSourceFile:path];
#else
    FileInfoViewController* fileInfoViewController = [[FileInfoViewController alloc] init];
    [fileInfoViewController setSourceFile:path];
    [fileInfoViewController setMasterViewController:self];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:fileInfoViewController];
    fileInfoViewController.title = @"Action";
    // Setup the popover for use from the navigation bar.
	fileInfoPopOverController = [[UIPopoverController alloc] initWithContentViewController:controller];
	fileInfoPopOverController.popoverContentSize = fileInfoViewController.view.frame.size;
    
    [fileInfoPopOverController presentPopoverFromRect:button.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
#endif
}

-(void) folderClickedDelegate:(NSString*)selectedItem andPath:(NSString*)path
{
    MasterViewController* masterViewController;
#ifdef IPHONE_VERSION
    masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController-iPhone" bundle:nil];
#else
    masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
#endif
    
    if ([fileListBrowserController getIsCurrentProjectFolder])
        [[Utils getInstance] analyzeProject:path andForceCreate:NO];
    
    // If current is Project Folder
    if ([fileListBrowserController getIsCurrentProjectFolder])
        masterViewController.currentProjectPath = path;
    else
        masterViewController.currentProjectPath = self.currentProjectPath;
    
    [masterViewController.fileListBrowserController setCurrentLocation:path];
    masterViewController.title = selectedItem;
    masterViewController.webServiceController = self.webServiceController;
    masterViewController.webServicePopOverController = self.webServicePopOverController;
    //[masterViewController reloadData];
    [self.navigationController pushViewController:masterViewController animated:YES];
}

-(void) fileClickedDelegate:(NSString*)selectedItem andPath:(NSString*)path
{
    NSString* html;
    NSString* displayPath;
    
    DetailViewController* controller = [Utils getInstance].detailViewController;
    
    html = [[Utils getInstance] getDisplayFile:path andProjectBase:self.currentProjectPath];
    displayPath = [[Utils getInstance] getDisplayPath:path];
    
#ifdef IPHONE_VERSION
    [self presentModalViewController:[Utils getInstance].detailViewController animated:YES];
#endif
    
    //Help.html special case
    if ([fileListBrowserController getIsCurrentProjectFolder] == YES && [selectedItem compare:@"Help.html"] == NSOrderedSame) {
        NSError *error;
        NSStringEncoding encoding = NSUTF8StringEncoding;
        html = [NSString stringWithContentsOfFile: path usedEncoding:&encoding error: &error];
        [controller setTitle:selectedItem andPath:path andContent:html andBaseUrl:nil];
        return;
    }
    //other case
    if (html != nil)
    {
        [controller setTitle:selectedItem andPath:displayPath andContent:html andBaseUrl:nil];
    }
    else
    {
        if ([[Utils getInstance] isDocType:path])
        {
            [controller displayDocTypeFile:path];
            return;
        }
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

- (void) setNeedSelectRowAfterReload:(int)index {
    needSelectRowAfterReload = index;
}

@end
