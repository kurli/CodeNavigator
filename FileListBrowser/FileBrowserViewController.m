//
//  FileBrowserViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 9/17/13.
//
//

#import "FileBrowserViewController.h"
#import "FileListBrowserController.h"
#import "DetailViewController.h"
#import "Utils.h"

@interface FileBrowserViewController ()

@end

@implementation FileBrowserViewController

@synthesize tableView;
@synthesize fileListBrowserController;
@synthesize fileSearchBar;
@synthesize currentProjectPath;
@synthesize initialPath;
@synthesize fileBrowserViewDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Projects", @"Projects");
        //        self clearsSelectionOnViewWillAppear = NO;
        fileListBrowserController = [[FileListBrowserController alloc]init];
        [fileListBrowserController setFileListBrowserDelegate:self];
        [fileListBrowserController set_tableView:self.tableView];
        [fileListBrowserController setEnableFileInfoButton:NO];
        needSelectRowAfterReload = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self reloadData];
    if ([self.initialPath length] != 0)
        [self gotoFile:self.initialPath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setFileListBrowserController:nil];
    [self setFileSearchBar:nil];
    [self setCurrentProjectPath:nil];
    [self setInitialPath:nil];
    [self setFileBrowserViewDelegate:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Select table view
    if (needSelectRowAfterReload != -1) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:needSelectRowAfterReload inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        needSelectRowAfterReload = -1;
    }

    if ([fileListBrowserController getIsCurrentProjectFolder])
    {
        CGRect rect = self.tableView.frame;
        rect.size.height += (rect.origin.y - self.view.frame.origin.y);
        rect.origin.y = self.view.frame.origin.y;
        [self.tableView setFrame:rect];
        [self.fileSearchBar setHidden:YES];
    }
    else
    {
        if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        [self.fileSearchBar setHidden:NO];
    }
    [self.fileSearchBar setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.fileSearchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [fileBrowserViewDelegate fileBrowserViewDisappeared];
}

- (void)dealloc {
    [self setTableView:nil];
    [self setFileListBrowserController:nil];
    [self setFileSearchBar:nil];
    [self setCurrentProjectPath:nil];
    [self setInitialPath:nil];
    [self setFileBrowserViewDelegate:nil];
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

#pragma mark tableView delegate
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    return [fileListBrowserController numberOfSectionsInTableView:_tableView];
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return [fileListBrowserController tableView:_tableView numberOfRowsInSection:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [fileListBrowserController tableView:_tableView cellForRowAtIndexPath:indexPath];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)_tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [fileListBrowserController tableView:_tableView canEditRowAtIndexPath:indexPath];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [fileListBrowserController tableView:_tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

-(CGFloat) tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [fileListBrowserController tableView:_tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [fileListBrowserController tableView:_tableView didSelectRowAtIndexPath: indexPath];
    [self.fileSearchBar resignFirstResponder];
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
    [self.tableView reloadData];
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

#pragma mark FileListBrowserDelegate

- (IBAction)fileInfoButtonClicked:(id)sender
{
}

-(void) folderClickedDelegate:(NSString*)selectedItem andPath:(NSString*)path
{
    FileBrowserViewController* fileBrowserViewController;
    fileBrowserViewController = [[FileBrowserViewController alloc] initWithNibName:@"FileBrowserViewController" bundle:nil];
    
    if ([fileListBrowserController getIsCurrentProjectFolder])
        [[Utils getInstance] analyzeProject:path andForceCreate:NO];
    
    // If current is Project Folder
    if ([fileListBrowserController getIsCurrentProjectFolder])
        fileBrowserViewController.currentProjectPath = path;
    else
        fileBrowserViewController.currentProjectPath = self.currentProjectPath;
    
    [fileBrowserViewController.fileListBrowserController setCurrentLocation:path];
    fileBrowserViewController.title = selectedItem;
    fileBrowserViewController.fileBrowserViewDelegate = fileBrowserViewDelegate;
    //[fileBrowserViewController reloadData];
    [self.navigationController pushViewController:fileBrowserViewController animated:NO];
    
    [fileBrowserViewDelegate folderSelected:[fileBrowserViewController.fileListBrowserController currentLocation]];
}

-(void) fileClickedDelegate:(NSString*)selectedItem andPath:(NSString*)path
{
    NSString* html;
    
    DetailViewController* controller = [Utils getInstance].detailViewController;
    
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
            //other case
            if (html != nil)
            {
                [controller setTitle:selectedItem andPath:displayPath andContent:html andBaseUrl:nil];
            }
        });
    }];
}

- (NSString*) getCurrentProjectPath
{
    return self.currentProjectPath;
}

- (void) setIsProjectFolder:(BOOL)_isProjectFolder
{
    [fileListBrowserController setIsCurrentProjectFolder:_isProjectFolder];
}

-(void) gotoFile:(NSString *)filePath
{
    // If current table view is in search mode, just ignore it
    if ([fileListBrowserController getIsCurrentSearchFileMode]) {
        return;
    }
    
    FileBrowserViewController* targetViewController = nil;
    if (filePath == nil)
    {
        NSLog(@"file path is nil");
        return;
    }
    filePath = [[Utils getInstance] getSourceFileByDisplayFile:filePath];
    
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
        targetViewController = (FileBrowserViewController*)[array objectAtIndex:target];
        [self.navigationController popToViewController:targetViewController animated:NO];
    }
    else
        targetViewController = self;
    
    BOOL founded = NO;
    NSString* path = targetViewController.fileListBrowserController.currentLocation;
    // go to the target directory
    for (NSInteger i=index+1; i<[targetComponents count]-1; i++)
    {
        FileBrowserViewController* fileBrowserViewController;

        fileBrowserViewController = [[FileBrowserViewController alloc] initWithNibName:@"FileBrowserViewController" bundle:nil];

        path = [path stringByAppendingPathComponent:[targetComponents objectAtIndex:i]];
        // If current is Project Folder
        if ([fileListBrowserController getIsCurrentProjectFolder])
            fileBrowserViewController.currentProjectPath = path;
        else
            fileBrowserViewController.currentProjectPath = targetViewController.currentProjectPath;
        
        fileBrowserViewController.fileListBrowserController.currentLocation = path;
        fileBrowserViewController.title = [targetComponents objectAtIndex:i];
        fileBrowserViewController.fileBrowserViewDelegate = fileBrowserViewDelegate;
        [fileBrowserViewController reloadData];
        // Select Folder
        int i = 0;
        for (i = 0; i<[targetViewController.fileListBrowserController.currentDirectories count]; i++)
        {
            if ([fileBrowserViewController.title compare:[targetViewController.fileListBrowserController.currentDirectories objectAtIndex:i]] == NSOrderedSame)
            {
                founded = YES;
                break;
            }
        }
        if (founded == YES) {
            [targetViewController setNeedSelectRowAfterReload:i];
        }
        // end
        [targetViewController.navigationController pushViewController:fileBrowserViewController animated:NO];
        targetViewController = fileBrowserViewController;
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
}

-(void) setNeedSelectRowAfterReload:(NSInteger)index {
    needSelectRowAfterReload = index;
}

@end
