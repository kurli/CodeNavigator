//
//  FileBrowserTreeViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 7/1/14.
//
//

#import "FileBrowserTreeViewController.h"
#import "Utils.h"
#import "DetailViewController.h"
#import "FileListBrowserController.h"

@interface FileBrowserTreeViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView1;
@property (weak, nonatomic) IBOutlet UITableView *tableView2;
@property (weak, nonatomic) IBOutlet UITableView *tableView3;
@property (strong, nonatomic) NSMutableArray* fileListControllers;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleToolBarButton;
@end

@implementation FileBrowserTreeViewController

@synthesize currentPath;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonClicked:(id)sender {
    [[Utils getInstance].detailViewController showFileBrowserTreeView:NO];
    [self.parentDelegate onTreeViewDismissed];
    
    FileListBrowserController* fileListBrowserController1 = [self.fileListControllers objectAtIndex:0];
    FileListBrowserController* fileListBrowserController2 = [self.fileListControllers objectAtIndex:1];
    FileListBrowserController* fileListBrowserController3 = [self.fileListControllers objectAtIndex:2];
    
    if (fileListBrowserController3.currentLocation != nil) {
        [self.parentDelegate onParentNeedChangePath:fileListBrowserController3.currentLocation];
    } else if (fileListBrowserController2.currentLocation != nil) {
        [self.parentDelegate onParentNeedChangePath:fileListBrowserController2.currentLocation];
    } else if (fileListBrowserController1.currentLocation != nil) {
        [self.parentDelegate onParentNeedChangePath:fileListBrowserController1.currentLocation];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self adjustView];
    
    if ([self.fileListControllers count] != 3) {
        [self initFileListControllers];
    }
    FileListBrowserController* fileListBrowserController1 = [self.fileListControllers objectAtIndex:0];
    FileListBrowserController* fileListBrowserController2 = [self.fileListControllers objectAtIndex:1];
    FileListBrowserController* fileListBrowserController3 = [self.fileListControllers objectAtIndex:2];
    
    [fileListBrowserController1 set_tableView:self.tableView1];
    [fileListBrowserController2 set_tableView:self.tableView2];
    [fileListBrowserController3 set_tableView:self.tableView3];
    
    [self reloadTableViews];
    
    // Set title
    [self setTitlePath:currentPath];
    
//    self.tableView1.backgroundColor = [UIColor lightGrayColor];
//    self.tableView3.backgroundColor = [UIColor lightGrayColor];
}

-(void) adjustView {
    CGRect frame = self.view.frame;
    CGRect detailViewFrame = [Utils getInstance].detailViewController.view.frame;
    frame.size = detailViewFrame.size;
    [self.view setFrame:frame];
    
    int width = frame.size.width / 3;
    //FileBrowser 1
    CGRect fileBrowser1Frame = self.tableView1.frame;
    fileBrowser1Frame.size.width = width;
    fileBrowser1Frame.origin.x = 0;
    [self.tableView1 setFrame:fileBrowser1Frame];
    
    //FileBrowser 2
    CGRect fileBrowser2Frame = self.tableView2.frame;
    fileBrowser2Frame.size.width = width;
    fileBrowser2Frame.origin.x = width;
    [self.tableView2 setFrame:fileBrowser2Frame];
    
    //FileBrowser 3
    CGRect fileBrowser3Frame = self.tableView3.frame;
    fileBrowser3Frame.size.width = width;
    fileBrowser3Frame.origin.x = width*2;
    [self.tableView3 setFrame:fileBrowser3Frame];
}

#pragma mark tableView delegate
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    FileListBrowserController* fileListBrowserController;
    if (tableView.tag < [self.fileListControllers count]) {
        fileListBrowserController = [self.fileListControllers objectAtIndex:tableView.tag];
    }
    return [fileListBrowserController numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FileListBrowserController* fileListBrowserController;
    if (tableView.tag < [self.fileListControllers count]) {
        fileListBrowserController = [self.fileListControllers objectAtIndex:tableView.tag];
    }
    return [fileListBrowserController tableView:tableView numberOfRowsInSection:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListBrowserController* fileListBrowserController;
    if (tableView.tag < [self.fileListControllers count]) {
        fileListBrowserController = [self.fileListControllers objectAtIndex:tableView.tag];
    }
    UITableViewCell *cell = [fileListBrowserController tableView:tableView cellForRowAtIndexPath:indexPath];
//    if (tableView.tag == 0 || tableView.tag == 2) {
//        cell.backgroundColor = [UIColor lightGrayColor];
//    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListBrowserController* fileListBrowserController;
    if (tableView.tag < [self.fileListControllers count]) {
        fileListBrowserController = [self.fileListControllers objectAtIndex:tableView.tag];
    }
    [fileListBrowserController tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListBrowserController* fileListBrowserController;
    if (tableView.tag < [self.fileListControllers count]) {
        fileListBrowserController = [self.fileListControllers objectAtIndex:tableView.tag];
    }
    return [fileListBrowserController tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListBrowserController* fileListBrowserController;
    if (tableView.tag < [self.fileListControllers count]) {
        fileListBrowserController = [self.fileListControllers objectAtIndex:tableView.tag];
    }
    [fileListBrowserController tableView:tableView didSelectRowAtIndexPath: indexPath];
}

#pragma FileListBrowserController
- (IBAction) fileInfoButtonClicked:(id)sender {
    
}

- (void) folderClickedDelegate:(UITableView*) tableView andSelectedItem:(NSString*)selectedItem andPath:(NSString*)path {
    FileListBrowserController* fileListBrowserController1 = [self.fileListControllers objectAtIndex:0];
    FileListBrowserController* fileListBrowserController2 = [self.fileListControllers objectAtIndex:1];
    FileListBrowserController* fileListBrowserController3 = [self.fileListControllers objectAtIndex:2];
    
    [self setTitlePath:path];
    
    if (tableView.tag == 0) {
        [fileListBrowserController2 setCurrentLocation:path];
        [fileListBrowserController2 reloadData];
        
        [fileListBrowserController3 setCurrentLocation:nil];
        [fileListBrowserController3 clearData];
    } else if (tableView.tag == 1) {
        [fileListBrowserController3 setCurrentLocation:path];
        [fileListBrowserController3 reloadData];
    } else if (tableView.tag == 2) {
        [fileListBrowserController3 setCurrentLocation:path];
        [fileListBrowserController3 reloadData];
        
        path = [path stringByDeletingLastPathComponent];
        [fileListBrowserController2 setCurrentLocation:path];
        [fileListBrowserController2 reloadData];
        
        path = [path stringByDeletingLastPathComponent];
        [fileListBrowserController1 setCurrentLocation:path];
        [fileListBrowserController1 reloadData];
        
        path = [path stringByDeletingLastPathComponent];
        [self.parentDelegate onParentNeedChangePath:path];
    }
    
    [self reloadTableViews];
}

- (void) fileClickedDelegate:(UITableView*) tableView andSelectedItem:(NSString*)selectedItem andPath:(NSString*)path {
    [self doneButtonClicked:nil];
    [self.parentDelegate onFileClickedFromTreeView:selectedItem andPath:path];
}

- (NSString*) getCurrentProjectPath {
    return nil;
}

-(void) reloadTableViews {
    [self.tableView1 reloadData];
    [self.tableView2 reloadData];
    [self.tableView3 reloadData];
    
    FileListBrowserController* fileListBrowserController1 = [self.fileListControllers objectAtIndex:0];
    FileListBrowserController* fileListBrowserController2 = [self.fileListControllers objectAtIndex:1];
    FileListBrowserController* fileListBrowserController3 = [self.fileListControllers objectAtIndex:2];
    
    if (fileListBrowserController1.currentLocation != nil) {
        [self.parentDelegate setFocusItem:fileListBrowserController1.currentLocation];
    } else {
        return;
    }
    
    if (fileListBrowserController2.currentLocation != nil) {
        [fileListBrowserController1 setFocusItem:fileListBrowserController2.currentLocation];
    } else {
        return;
    }
    
    if (fileListBrowserController3.currentLocation != nil) {
        [fileListBrowserController2 setFocusItem:fileListBrowserController3.currentLocation];
    } else {
        return;
    }
}

-(void) initFileListControllers {
    self.fileListControllers = [[NSMutableArray alloc] init];
    
    FileListBrowserController* fileListBrowserController1 = [[FileListBrowserController alloc]init];
    [fileListBrowserController1 setFileListBrowserDelegate:self];
    [fileListBrowserController1 setEnableFileInfoButton:NO];
    [self.fileListControllers addObject:fileListBrowserController1];
    
    FileListBrowserController* fileListBrowserController2 = [[FileListBrowserController alloc]init];
    [fileListBrowserController2 setFileListBrowserDelegate:self];
    [fileListBrowserController2 setEnableFileInfoButton:NO];
    [self.fileListControllers addObject:fileListBrowserController2];
    
    FileListBrowserController* fileListBrowserController3 = [[FileListBrowserController alloc]init];
    [fileListBrowserController3 setFileListBrowserDelegate:self];
    [fileListBrowserController3 setEnableFileInfoButton:NO];
    [self.fileListControllers addObject:fileListBrowserController3];
}

-(void) setCurrentPath:(NSString *)_currentPath {
    if ([self.fileListControllers count] != 3) {
        [self initFileListControllers];
    }
    FileListBrowserController* fileListBrowserController1 = [self.fileListControllers objectAtIndex:0];
    FileListBrowserController* fileListBrowserController2 = [self.fileListControllers objectAtIndex:1];
    FileListBrowserController* fileListBrowserController3 = [self.fileListControllers objectAtIndex:2];
    
    currentPath = _currentPath;
    
    // Parse path
    NSString* parentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    parentPath = [parentPath stringByAppendingPathComponent:@".Projects"];
    NSString* pathFromProject = [[Utils getInstance] getPathFromProject:currentPath];
    NSArray* array = [pathFromProject pathComponents];
    if ([array count] == 0) {
        return;
    } else if ([array count] == 1) {
        NSString* path = [parentPath stringByAppendingPathComponent:[array objectAtIndex:0]];
        [fileListBrowserController1 setCurrentLocation:path];
        [fileListBrowserController1 reloadData];
    } else if ([array count] == 2) {
        NSString* path = [parentPath stringByAppendingPathComponent:[array objectAtIndex:0]];
        [fileListBrowserController1 setCurrentLocation:path];
        [fileListBrowserController1 reloadData];
        
        path = [path stringByAppendingPathComponent:[array objectAtIndex:1]];
        [fileListBrowserController2 setCurrentLocation:path];
        [fileListBrowserController2 reloadData];
    } else {
        NSInteger index = [array count] - 3;
        
        for (int i=0; i<[array count] - 3; i++) {
            parentPath = [parentPath stringByAppendingPathComponent:[array objectAtIndex:i]];
        }
        
        NSString* path = [parentPath stringByAppendingPathComponent:[array objectAtIndex:index]];
        [fileListBrowserController1 setCurrentLocation:path];
        [fileListBrowserController1 reloadData];
        
        index++;
        path = [path stringByAppendingPathComponent:[array objectAtIndex:index]];
        [fileListBrowserController2 setCurrentLocation:path];
        [fileListBrowserController2 reloadData];
        
        index++;
        path = [path stringByAppendingPathComponent:[array objectAtIndex:index]];
        [fileListBrowserController3 setCurrentLocation:path];
        [fileListBrowserController3 reloadData];
    }
    [self.parentDelegate onParentNeedChangePath:parentPath];
    
    [self reloadTableViews];
    
    // Set title
    [self setTitlePath:currentPath];
}

-(void) setTitlePath:(NSString*)path {
    NSString* _path = [[Utils getInstance] getPathFromProject:path];
    self.titleToolBarButton.title = _path;
}

-(void)changeToPath:(NSString*)path {
    if ([self.fileListControllers count] != 3) {
        [self initFileListControllers];
    }
    FileListBrowserController* fileListBrowserController1 = [self.fileListControllers objectAtIndex:0];
    FileListBrowserController* fileListBrowserController2 = [self.fileListControllers objectAtIndex:1];
    FileListBrowserController* fileListBrowserController3 = [self.fileListControllers objectAtIndex:2];
    
    [fileListBrowserController1 setCurrentLocation:path];
    [fileListBrowserController1 reloadData];
    
    [fileListBrowserController2 setCurrentLocation:nil];
    [fileListBrowserController2 clearData];
    
    [fileListBrowserController3 setCurrentLocation:nil];
    [fileListBrowserController3 clearData];
    
    [self setTitlePath:path];
    [self reloadTableViews];
}

-(void) pathBack {
    FileListBrowserController* fileListBrowserController1 = [self.fileListControllers objectAtIndex:0];
    FileListBrowserController* fileListBrowserController2 = [self.fileListControllers objectAtIndex:1];
    FileListBrowserController* fileListBrowserController3 = [self.fileListControllers objectAtIndex:2];
    
    NSString* path;
    path = [fileListBrowserController1.currentLocation stringByDeletingLastPathComponent];
    [fileListBrowserController1 setCurrentLocation:path];
    [fileListBrowserController1 reloadData];
    
    path = [fileListBrowserController2.currentLocation stringByDeletingLastPathComponent];
    if (path != nil) {
        [fileListBrowserController2 setCurrentLocation:path];
        [fileListBrowserController2 reloadData];
        [self setTitlePath:path];
    }
    
    path = [fileListBrowserController3.currentLocation stringByDeletingLastPathComponent];
    if (path != nil) {
        [fileListBrowserController3 setCurrentLocation:path];
        [fileListBrowserController3 reloadData];
        [self setTitlePath:path];
    }
    
    [self reloadTableViews];
}

@end
