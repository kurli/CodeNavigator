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

@implementation MasterViewController

@synthesize tableView = _tableView;
@synthesize masterViewController = _masterViewController;
@synthesize currentLocation = _currentLocation;
@synthesize currentDirectories = _currentDirectories;
@synthesize currentFiles = _currentFiles;
@synthesize currentProjectPath = _currentProjectPath;
@synthesize webServiceController = _webServiceController;
@synthesize webServicePopOverController = _webServicePopOverController;
@synthesize analyzeButton = _analyzeButton;
#ifdef LITE_VERSION
@synthesize purchaseButton = _purchaseButton;
#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Projects", @"Projects");
//        self clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        isProjectFolder = NO;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    NSString* projectFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    BOOL isFolder = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:projectFolder isDirectory:&isFolder];
    NSError *error;
    if (isExist == NO || (isExist == YES && isFolder == NO))
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:projectFolder withIntermediateDirectories:YES attributes:nil error:&error];
    }

    NSString* demoFolder = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Projects/linux_0.1/"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:demoFolder isDirectory:&isFolder];
    NSString* demoBundle = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/linux_0.1"];
    if (isExist == NO || (isExist == YES && isFolder == NO))
    {
        [[NSFileManager defaultManager] copyItemAtPath:demoBundle toPath:demoFolder error:&error];
    }
    
    [self reloadData];
}

-(void) reloadData
{
    //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    if (nil == self.currentDirectories)
    {
        self.currentDirectories = [NSMutableArray array];
    }
    else
    {
        [self.currentDirectories removeAllObjects];
    }
    
    if (nil == self.currentFiles)
    {
        self.currentFiles = [NSMutableArray array];
    }
    else
    {
        [self.currentFiles removeAllObjects];
    }
    
    //Search projects
    NSError *error;
    NSString *projectFolder;
    if (nil == self.currentLocation)
    {
        projectFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
        self.currentLocation = [NSString stringWithString:projectFolder];
    }
    else
    {
        projectFolder = [NSString stringWithString:self.currentLocation];
    }
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:projectFolder error:&error];
    for (int i=0; i<[contents count]; i++)
    {
        NSString *currentPath = [projectFolder stringByAppendingPathComponent:[contents objectAtIndex:i]];
        BOOL isFolder = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:currentPath isDirectory:&isFolder];
        if (YES == isFolder)
        {
            [self.currentDirectories addObject:[contents objectAtIndex:i]];
        }
        else
        {
            if ([[Utils getInstance] isProjectDatabaseFile:[contents objectAtIndex:i]] == YES)
                continue;
            [self.currentFiles addObject:[contents objectAtIndex:i]];
        }
    }
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [self setCurrentProjectPath:nil];
    [self setCurrentLocation:nil];
    [self.currentFiles removeAllObjects];
    [self setCurrentProjectPath:nil];
    [self.currentDirectories removeAllObjects];
    [self setCurrentDirectories:nil];
    [self setCurrentFiles: nil];
    [self setMasterViewController:nil];
    [self setWebServiceController:nil];
    [self setWebServicePopOverController:nil];
    [self setTableView:nil];
    [self setAnalyzeButton:nil];
#ifdef LITE_VERSION
    [self setPurchaseButton:nil];
#endif
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isProjectFolder)
        [self.analyzeButton setEnabled:NO];
    else
        [self.analyzeButton setEnabled:YES];    
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

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (nil != self.currentDirectories)
        count += [self.currentDirectories count];
    if (nil != self.currentFiles)
        count += [self.currentFiles count];
    return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *projectIdentifier = @"ProjectCell";
    static NSString *folderIdentifier = @"FolderCell";
    static NSString *fileIdentifier = @"FileCell";
    UITableViewCell *cell;
    
    if (indexPath.row < [self.currentDirectories count])
    {
        if (isProjectFolder == YES)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:projectIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:projectIdentifier];
                cell.imageView.image = [UIImage imageNamed:@"project.png"];
            }
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:folderIdentifier];
                cell.imageView.image = [UIImage imageNamed:@"folder.png"];
            }
        }
        cell.textLabel.text = [self.currentDirectories objectAtIndex:indexPath.row];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:projectIdentifier];
        }
        cell.textLabel.text = [self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]];
    }

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (self.editing)
        return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError *error;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString* path = @"";
        path = [path stringByAppendingString:self.currentLocation];
        // Delete the row from the data source.
        if (indexPath.row < [self.currentDirectories count])
        {
            path = [path stringByAppendingPathComponent:[self.currentDirectories objectAtIndex:indexPath.row]];
            [self.currentDirectories removeObjectAtIndex:indexPath.row];
        }
        else
        {
            path = [path stringByAppendingPathComponent:[self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]]];
            [self.currentFiles removeObjectAtIndex:indexPath.row - [self.currentDirectories count]];
            NSString* displayPath = [[Utils getInstance] getDisplayFileBySourceFile:path];
            [[NSFileManager defaultManager] removeItemAtPath:displayPath error:&error];
        }
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (!isProjectFolder)
            [[Utils getInstance] analyzeProject:path andForceCreate:YES];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void) setIsProjectFolder:(BOOL)_isProjectFolder
{
    isProjectFolder = _isProjectFolder;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedItem;
    NSString *path;
    NSString *displayPath;
    NSError *error;
    NSString* html;
        
    // For directories
    if (indexPath.row < [self.currentDirectories count])
    {
        if (!self.masterViewController) {
            self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
        }
        selectedItem = [self.currentDirectories objectAtIndex:indexPath.row];
        path = [self.currentLocation stringByAppendingPathComponent:selectedItem];
        
        if (isProjectFolder)
            [[Utils getInstance] analyzeProject:path andForceCreate:NO];
        
        // If current is Project Folder
        if (isProjectFolder == YES)
            self.masterViewController.currentProjectPath = path;
        else
            self.masterViewController.currentProjectPath = self.currentProjectPath;
        
        self.masterViewController.currentLocation = path;
        self.masterViewController.title = selectedItem;
        self.masterViewController.webServiceController = self.webServiceController;
        self.masterViewController.webServicePopOverController = self.webServicePopOverController;
        [self.masterViewController reloadData];
        [self.navigationController pushViewController:self.masterViewController animated:YES];
    }
    else
    {
        selectedItem = [self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]];
        path = [self.currentLocation stringByAppendingPathComponent:selectedItem];
        html = [[Utils getInstance] getDisplayFile:path andProjectBase:self.currentProjectPath];
        displayPath = [[Utils getInstance] getDisplayPath:path];
        if (html != nil)
        {
            NSArray* controllerArray = [[Utils getInstance].splitViewController viewControllers];
            DetailViewController* controller = [controllerArray objectAtIndex:1];
            [controller setTitle:selectedItem andPath:displayPath andContent:html];
        }
        else
        {
            NSArray* controllerArray = [[Utils getInstance].splitViewController viewControllers];
            DetailViewController* controller = [controllerArray objectAtIndex:1];

            NSStringEncoding encoding = NSUTF8StringEncoding;
            html = [NSString stringWithContentsOfFile: path usedEncoding:&encoding error: &error];
            [controller setTitle:selectedItem andPath:path andContent:html];
        }
    }
}

-(void) gotoFile:(NSString *)filePath
{
    MasterViewController* targetViewController = nil;
    if (filePath == nil)
    {
        NSLog(@"file path is nil");
        return;
    }
    NSArray* targetComponents = [filePath pathComponents];
    NSArray* currentComponents = [self.currentLocation pathComponents];
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

    NSString* path = targetViewController.currentLocation;
    // go to the target directory
    for (int i=index+1; i<[targetComponents count]-1; i++)
    {
        if (!targetViewController.masterViewController) {
            targetViewController.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
        }
        path = [path stringByAppendingPathComponent:[targetComponents objectAtIndex:i]];
        // If current is Project Folder
        if (isProjectFolder == YES)
            targetViewController.masterViewController.currentProjectPath = path;
        else
            targetViewController.masterViewController.currentProjectPath = targetViewController.currentProjectPath;
        
        targetViewController.masterViewController.currentLocation = path;
        targetViewController.masterViewController.title = [targetComponents objectAtIndex:i];
        targetViewController.webServiceController = self.webServiceController;
        targetViewController.webServicePopOverController = self.webServicePopOverController;
        [targetViewController.masterViewController reloadData];
        [targetViewController.navigationController pushViewController:targetViewController.masterViewController animated:NO];
        targetViewController = targetViewController.masterViewController;
    }
    
    NSString* title = [targetComponents lastObject];
    title = [[Utils getInstance] getSourceFileByDisplayFile:title];
    
    BOOL founded = NO;
    index = [targetViewController.currentDirectories count];
    for (int i = 0; i<[targetViewController.currentFiles count]; i++)
    {
        if ([title compare:[targetViewController.currentFiles objectAtIndex:i]] == NSOrderedSame)
        {
            index += i;
            founded = YES;
            break;
        }
    }
    if (founded == YES)
        [targetViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

- (IBAction)analyzeButtonClicked:(id)sender {
    [[Utils getInstance] analyzeProject:self.currentProjectPath andForceCreate:YES];
}

#ifdef LITE_VERSION
- (IBAction)purchaseClicked:(id)sender {
    [[Utils getInstance] openPurchaseURL];
}
#endif

- (IBAction)addFileToolBarClicked:(id)sender {
    UIBarButtonItem *item = (UIBarButtonItem*)sender;
    if (_webServiceController == nil)
    {
        _webServiceController = [[WebServiceController alloc]init];
        _webServicePopOverController = [[UIPopoverController alloc] initWithContentViewController:_webServiceController];
        _webServicePopOverController.popoverContentSize = _webServiceController.view.frame.size;
    }
    if (_webServicePopOverController.popoverVisible == YES)
        [_webServicePopOverController dismissPopoverAnimated:YES];
    else
    {
#ifdef LITE_VERSION
        [[Utils getInstance] showPurchaseAlert];
#endif
        [_webServiceController setMasterViewController:self];
        [_webServicePopOverController presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

@end
