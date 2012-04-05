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

@implementation MasterViewController

@synthesize tableView = _tableView;
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
    if ([Utils getInstance].colorScheme == nil)
    {
        [[Utils getInstance] readColorScheme];
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
        //Hide hidden files such as .git .DS_Store
        if ([[[contents objectAtIndex:i] substringToIndex:1] compare:@"."] == NSOrderedSame) {
            continue;
        }
        
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
    [self setCurrentLocation:nil];
    [self.currentFiles removeAllObjects];
    [self setCurrentProjectPath:nil];
    [self.currentDirectories removeAllObjects];
    [self setCurrentDirectories:nil];
    [self setCurrentFiles: nil];
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

- (void)dealloc
{
    [self setCurrentLocation:nil];
    [self.currentFiles removeAllObjects];
    [self setCurrentProjectPath:nil];
    [self.currentDirectories removeAllObjects];
    [self setCurrentDirectories:nil];
    [self setCurrentFiles: nil];
    [self setWebServiceController:nil];
    [self setWebServicePopOverController:nil];
    [self setTableView:nil];
    [self setAnalyzeButton:nil];
#ifdef LITE_VERSION
    [self setPurchaseButton:nil];
#endif
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
    static NSString *itemIdentifier = @"ProjectCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:itemIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemIdentifier];
    }
    
    if (indexPath.row < [self.currentDirectories count])
    {
        if (isProjectFolder == YES)
        {
            cell.imageView.image = [UIImage imageNamed:@"project.png"];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"folder.png"];
        }
        cell.textLabel.text = [self.currentDirectories objectAtIndex:indexPath.row];
    }
    else
    {
        NSString* fileName = [self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]];
        NSString* extention = [fileName pathExtension];
        extention = [extention lowercaseString];
        if ([extention compare:@"cc"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"ccFile.png"];
        }
        else if ([extention compare:@"c"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"cFile.png"];
        }
        else if ([extention compare:@"cpp"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"cppFile.png"];
        }
        else if ([extention compare:@"cs"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"csFile.png"];
        }
        else if ([extention compare:@"h"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"hFile.png"];
        }
        else if ([extention compare:@"hpp"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"hppFile.png"];
        }
        else if ([extention compare:@"java"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"javaFile.png"];
        }
        else if ([extention compare:@"m"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"mFile.png"];
        }
        else if ([extention compare:@"s"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"sFile.png"];
        }
        else if ([extention compare:@"mm"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"mmFile.png"];
        }
        else {
            NSString* name = [[fileName pathComponents] lastObject];
            name = [name lowercaseString];
            if ([name compare:@"makefile"] == NSOrderedSame)
                cell.imageView.image = [UIImage imageNamed:@"mkFile.png"];
            else
                cell.imageView.image = [UIImage imageNamed:@"File.png"];
        }

        cell.textLabel.text = fileName;
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
    NSString* html;
        
    // For directories
    if (indexPath.row < [self.currentDirectories count])
    {
        MasterViewController* masterViewController;
        masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
        selectedItem = [self.currentDirectories objectAtIndex:indexPath.row];
        path = [self.currentLocation stringByAppendingPathComponent:selectedItem];
        
        if (isProjectFolder)
            [[Utils getInstance] analyzeProject:path andForceCreate:NO];
        
        // If current is Project Folder
        if (isProjectFolder == YES)
            masterViewController.currentProjectPath = path;
        else
            masterViewController.currentProjectPath = self.currentProjectPath;
        
        masterViewController.currentLocation = path;
        masterViewController.title = selectedItem;
        masterViewController.webServiceController = self.webServiceController;
        masterViewController.webServicePopOverController = self.webServicePopOverController;
        [masterViewController reloadData];
        [self.navigationController pushViewController:masterViewController animated:YES];
    }
    else
    {
        selectedItem = [self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]];
        path = [self.currentLocation stringByAppendingPathComponent:selectedItem];
        html = [[Utils getInstance] getDisplayFile:path andProjectBase:self.currentProjectPath];
        displayPath = [[Utils getInstance] getDisplayPath:path];
        if (html != nil)
        {
            DetailViewController* controller = [Utils getInstance].detailViewController;
            [controller setTitle:selectedItem andPath:displayPath andContent:html];
        }
        else
        {
            DetailViewController* controller = [Utils getInstance].detailViewController;
            
            if ([[Utils getInstance] isDocType:path])
            {
                [controller displayDocTypeFile:path];
                return;
            }
            if ([[Utils getInstance] isWebType:path])
            {
                NSError *error;
                NSStringEncoding encoding = NSUTF8StringEncoding;
                html = [NSString stringWithContentsOfFile: path usedEncoding:&encoding error: &error];
                [controller setTitle:selectedItem andPath:path andContent:html];
            }

//            NSStringEncoding encoding = NSUTF8StringEncoding;
//            html = [NSString stringWithContentsOfFile: path usedEncoding:&encoding error: &error];
//            [controller setTitle:selectedItem andPath:path andContent:html];
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
        MasterViewController* masterViewController;
        masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
        path = [path stringByAppendingPathComponent:[targetComponents objectAtIndex:i]];
        // If current is Project Folder
        if (isProjectFolder == YES)
            masterViewController.currentProjectPath = path;
        else
            masterViewController.currentProjectPath = targetViewController.currentProjectPath;
        
        masterViewController.currentLocation = path;
        masterViewController.title = [targetComponents objectAtIndex:i];
        targetViewController.webServiceController = self.webServiceController;
        targetViewController.webServicePopOverController = self.webServicePopOverController;
        [masterViewController reloadData];
        [targetViewController.navigationController pushViewController:masterViewController animated:NO];
        targetViewController = masterViewController;
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

- (IBAction)gitClicked:(id)sender {    
    GitLogViewCongroller* gitlogView = [[GitLogViewCongroller alloc] initWithNibName:@"GitLogViewCongroller" bundle:[NSBundle mainBundle]];
    [gitlogView gitLogForProject: self.currentProjectPath];
    [gitlogView showModualView];
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





















