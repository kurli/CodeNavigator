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
#endif

@implementation MasterViewController
@synthesize fileSearchBar = _fileSearchBar;

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
@synthesize versionControllerPopOverController;
@synthesize commentManagerPopOverController;
@synthesize searchFileResultArray;
@synthesize fileInfoPopOverController;
#ifdef IPHONE_VERSION
@synthesize fileInfoControlleriPhone;
#endif
@synthesize deleteAlertView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Projects", @"Projects");
//        self clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        isProjectFolder = NO;
        // we do not show edit button from v1.8
//        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        isCurrentSearchFileMode = NO;
        deleteItemId = -1;
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
    //[self setCurrentLocation:nil];
    [self setCommentManagerPopOverController: nil];
//    [self.currentFiles removeAllObjects];
////    [self setCurrentProjectPath:nil];
//    [self.currentDirectories removeAllObjects];
    [self setCurrentDirectories:nil];
    [self setCurrentFiles: nil];
    [self setWebServiceController:nil];
    [self.webServicePopOverController dismissPopoverAnimated:NO];
    [self setWebServicePopOverController:nil];
    [self setTableView:nil];
    [self setAnalyzeButton:nil];
#ifdef LITE_VERSION
    [self setPurchaseButton:nil];
#endif
    [self setFileSearchBar:nil];
    [self.fileInfoPopOverController dismissPopoverAnimated:NO];
    [self setFileInfoPopOverController:nil];
#ifdef IPHONE_VERSION
    [self setFileInfoControlleriPhone:nil];
#endif
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [self setFileInfoPopOverController:nil];
    [self.searchFileResultArray removeAllObjects];
    [self setSearchFileResultArray:nil];
    [self setFileSearchBar:nil];
    [self setCommentManagerPopOverController: nil];
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
#ifdef IPHONE_VERSION
    [self setFileInfoControlleriPhone:nil];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isProjectFolder)
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

- (IBAction)fileInfoButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UIView *contentView = [button superview];
    UITableViewCell *cell = (UITableViewCell*)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if ([self.fileInfoPopOverController isPopoverVisible] == YES) {
        [self.fileInfoPopOverController dismissPopoverAnimated:NO];
    }
    
    if (indexPath.row < [self.currentDirectories count])
    {
        return;
    }
    
    NSString* fileName = [self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]];
    
    NSString* path = [self.currentLocation stringByAppendingPathComponent:fileName];
    
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

#pragma mark tableView delegate
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isCurrentSearchFileMode == YES) {
        return [self.searchFileResultArray count];
    }
    
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
    if (isCurrentSearchFileMode == YES) {
        static NSString *fileCellIdentifier = @"FileCell";
        UITableViewCell *cell;
        
        cell = [_tableView dequeueReusableCellWithIdentifier:fileCellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ResultTableCellView" owner:self options:nil] lastObject];
            [cell setValue:fileCellIdentifier forKey:@"reuseIdentifier"];
        }
        NSString* item = nil;
        if (indexPath.row < [self.searchFileResultArray count]) {
            item = [self.searchFileResultArray objectAtIndex:indexPath.row];
        }
        NSString* fileName = [item lastPathComponent];
//        [((UILabel *)[cell viewWithTag:101]) setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        [((UILabel *)[cell viewWithTag:101]) setText:fileName];
//        [((UILabel *)[cell viewWithTag:102]) setTextColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:1]];
        [((UILabel *)[cell viewWithTag:102]) setText:[[Utils getInstance] getPathFromProject:item]];
        
        return cell;
    }
    
    static NSString *itemIdentifier = @"ProjectCell";
    static NSString *fileIdentifier = @"FileCellIdentifier";
    UITableViewCell *cell;
    
    if (indexPath.row < [self.currentDirectories count])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:itemIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemIdentifier];
        }
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
        UIImageView* imageView;
        cell = [_tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FileTableViewCell" owner:self options:nil] lastObject];
            [cell setValue:fileIdentifier forKey:@"reuseIdentifier"];
        }
        imageView = (UIImageView*)[cell viewWithTag:101];
        
        NSString* fileName = [self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]];
        NSString* extention = [fileName pathExtension];
        extention = [extention lowercaseString];
        if ([extention compare:@"cc"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"ccFile.png"];
        }
        else if ([extention compare:@"c"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"cFile.png"];
        }
        else if ([extention compare:@"cpp"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"cppFile.png"];
        }
        else if ([extention compare:@"cs"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"csFile.png"];
        }
        else if ([extention compare:@"h"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"hFile.png"];
        }
        else if ([extention compare:@"hpp"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"hppFile.png"];
        }
        else if ([extention compare:@"java"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"javaFile.png"];
        }
        else if ([extention compare:@"m"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"mFile.png"];
        }
        else if ([extention compare:@"s"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"sFile.png"];
        }
        else if ([extention compare:@"mm"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"mmFile.png"];
        }
        else {
            NSString* name = [[fileName pathComponents] lastObject];
            name = [name lowercaseString];
            if ([name compare:@"makefile"] == NSOrderedSame)
                imageView.image = [UIImage imageNamed:@"mkFile.png"];
            else
                imageView.image = [UIImage imageNamed:@"File.png"];
        }

        ((UILabel*)[cell viewWithTag:102]).text = fileName;
        
        NSError* error;
        NSString* filePath = self.currentLocation;
        filePath = [filePath stringByAppendingPathComponent:fileName];
        NSDictionary *attributes = [[NSFileManager defaultManager] 
                                    attributesOfItemAtPath:filePath error:&error];
        float theSize = [(NSNumber*)[attributes valueForKey:NSFileSize] floatValue];
        NSString* sizeStr;
        if (theSize<1023)
            sizeStr = ([NSString stringWithFormat:@"%1.f bytes",theSize]);
        else {
            theSize = theSize / 1024;
            sizeStr = ([NSString stringWithFormat:@"%1.1f KB",theSize]);
        }
        
        NSDate* date = [attributes valueForKey:NSFileModificationDate];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
        [dateFormatter setDateFormat:@"yy/MM/dd HH:mm"];

        ((UILabel*)[cell viewWithTag:103]).text = sizeStr;
        ((UILabel*)[cell viewWithTag:104]).text = [dateFormatter stringFromDate:date];
        UIButton* infoButton = (UIButton*)[cell viewWithTag:110];
        [infoButton addTarget:self action:@selector(fileInfoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isCurrentSearchFileMode == YES) {
        return NO;
    }
//    // Return NO if you do not want the specified item to be editable.
//    if (self.editing)
//        return YES;
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.deleteAlertView) {
        [self setDeleteAlertView:nil];
        if (deleteItemId == -1)
            return;
        if (buttonIndex != 1) {
            return;
        }
        NSError *error;
        NSString* path = @"";
        path = [path stringByAppendingString:self.currentLocation];
        // Delete the row from the data source.
        if (deleteItemId < [self.currentDirectories count])
        {
            path = [path stringByAppendingPathComponent:[self.currentDirectories objectAtIndex:deleteItemId]];
            [self.currentDirectories removeObjectAtIndex:deleteItemId];
        }
        else
        {
            path = [path stringByAppendingPathComponent:[self.currentFiles objectAtIndex:deleteItemId-[self.currentDirectories count]]];
            [self.currentFiles removeObjectAtIndex:deleteItemId - [self.currentDirectories count]];
            NSString* displayPath = [[Utils getInstance] getDisplayFileBySourceFile:path];
            [[NSFileManager defaultManager] removeItemAtPath:displayPath error:&error];
            //remove comments file
            NSString* extention = [path pathExtension];
            NSString* commentFile = [path stringByDeletingPathExtension];
            commentFile = [commentFile stringByAppendingFormat:@"_%@", extention];
            commentFile = [commentFile stringByAppendingPathExtension:@"lgz_comment"];
            [[NSFileManager defaultManager] removeItemAtPath:commentFile error:&error];
        }
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];

        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deleteItemId inSection:0] ] withRowAnimation:UITableViewRowAnimationFade];
        if (!isProjectFolder)
            [[Utils getInstance] analyzeProject:path andForceCreate:YES];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        deleteItemId = indexPath.row;
        self.deleteAlertView = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:@"Would you like to delete this file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [self.deleteAlertView show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}

-(GLfloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isCurrentSearchFileMode == YES)
    {
        return 65;
    }
    else
    {
        if (indexPath.row < [self.currentDirectories count])
            return 50;
        else {
            return 60;
        }
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
    if (isCurrentSearchFileMode == YES) {
        if (indexPath.row >= [self.searchFileResultArray count]) {
            return;
        }
        NSString* item = [self.searchFileResultArray objectAtIndex:indexPath.row];
        NSString* html = [[Utils getInstance] getDisplayFile:item andProjectBase:self.currentProjectPath];
        NSString* displayPath = [[Utils getInstance] getDisplayPath:item];
#ifdef IPHONE_VERSION
        [self presentModalViewController:[Utils getInstance].detailViewController animated:YES];
#endif
        if (html != nil)
        {
            DetailViewController* controller = [Utils getInstance].detailViewController;
            [controller setTitle:[item lastPathComponent] andPath:displayPath andContent:html andBaseUrl:nil];
        }
        else
        {
            DetailViewController* controller = [Utils getInstance].detailViewController;
            
            if ([[Utils getInstance] isDocType:item])
            {
                [controller displayDocTypeFile:item];
                return;
            }
//            if ([[Utils getInstance] isWebType:item])
//            {
//                NSError *error;
//                NSStringEncoding encoding = NSUTF8StringEncoding;
//                html = [NSString stringWithContentsOfFile: item usedEncoding:&encoding error: &error];
//                [controller setTitle:[item lastPathComponent] andPath:item andContent:html];
//            }
        }
        [self.fileSearchBar resignFirstResponder];
        return;
    }
    
    NSString *selectedItem;
    NSString *path;
    NSString *displayPath;
    NSString* html;

    // For directories
    if (indexPath.row < [self.currentDirectories count])
    {
        MasterViewController* masterViewController;
#ifdef IPHONE_VERSION
        masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController-iPhone" bundle:nil];
#else
        masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
#endif
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
        DetailViewController* controller = [Utils getInstance].detailViewController;

        selectedItem = [self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]];
        path = [self.currentLocation stringByAppendingPathComponent:selectedItem];
        html = [[Utils getInstance] getDisplayFile:path andProjectBase:self.currentProjectPath];
        displayPath = [[Utils getInstance] getDisplayPath:path];
        
#ifdef IPHONE_VERSION
        [self presentModalViewController:[Utils getInstance].detailViewController animated:YES];
#endif
        
        //Help.html special case
        if (isProjectFolder == YES && [selectedItem compare:@"Help.html"] == NSOrderedSame) {
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
}

-(void) gotoFile:(NSString *)filePath
{
    // If current table view is in search mode, just ignore it
    if (isCurrentSearchFileMode == YES) {
        return;
    }
    
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
#ifdef IPHONE_VERSION
        masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController-iPhone" bundle:nil];
#else
        masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
#endif
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
}

- (IBAction)dropBoxClicked:(id)sender {
    DropBoxViewController* dropBoxViewController = [[DropBoxViewController alloc] initWithNibName:@"DropBoxViewController" bundle:[NSBundle mainBundle]];
    [[Utils getInstance] setDropBoxViewController:dropBoxViewController];
    [dropBoxViewController showModualView];
    dropBoxViewController = nil;
}

- (IBAction)versionControlButtonClicked:(id)sender {
    // Ignore Dropbox
    UIBarButtonItem *item = (UIBarButtonItem*)sender;

    if ([versionControllerPopOverController isPopoverVisible] == YES) {
        [versionControllerPopOverController dismissPopoverAnimated:YES];
    }
    
    VersionControlController* controller = [[VersionControlController alloc] init];
    [controller setMasterViewController:self];
    
    versionControllerPopOverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    versionControllerPopOverController.popoverContentSize = controller.view.frame.size;
    
    [versionControllerPopOverController presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    [self gitClicked:sender];
}

- (IBAction)lockButtonClicked:(id)sender {
    [self.webServicePopOverController dismissPopoverAnimated:YES];
    [[Utils getInstance].detailViewController releaseAllPopOver];
    [[Utils getInstance].analyzeInfoPopover dismissPopoverAnimated:YES];
    
    SecurityViewController* viewController = [[SecurityViewController alloc] init];
    [[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
}

- (IBAction)commentClicked:(id)sender {
    UIBarButtonItem *item = (UIBarButtonItem*)sender;
    
    if ([commentManagerPopOverController isPopoverVisible] == YES) {
        [commentManagerPopOverController dismissPopoverAnimated:YES];
        return;
    }
    
    if (isProjectFolder == YES) {
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

- (IBAction)addFileToolBarClicked:(id)sender {
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
    if (_webServicePopOverController.popoverVisible == YES)
        [_webServicePopOverController dismissPopoverAnimated:YES];
    else
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
}

#pragma mark SearchDelegate

- (IBAction)searchFileDoneButtonClicked:(id)sender
{
    isCurrentSearchFileMode = NO;
    [self.searchFileResultArray removeAllObjects];
    [self setSearchFileResultArray:nil];
    // ignore it after v1.8
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    [self.fileSearchBar setText:@""];
    [self.fileSearchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    if (isCurrentSearchFileMode == YES) {
        return;
    }
    isCurrentSearchFileMode = YES;
    [self.searchFileResultArray removeAllObjects];
    [self setSearchFileResultArray:nil];
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
    NSString* fileList = [self.currentProjectPath stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
    
    BOOL isExist;
    BOOL isFolder;
    NSError* error;
    
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileList isDirectory:&isFolder];
    if (isExist == NO) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please analyze this project first"];
        return;
    }
    NSString* fileListContent = [NSString stringWithContentsOfFile:fileList encoding:NSUTF8StringEncoding error:&error];
    self.searchFileResultArray = [[NSMutableArray alloc] init];
    NSArray* array = [fileListContent componentsSeparatedByString:@"\n"];
    for (int i=0; i<[array count]; i++) {
        NSString* fileName = [[array objectAtIndex:i] lastPathComponent];
        if ([fileName rangeOfString:searchText].location != NSNotFound)
        {
            [self.searchFileResultArray addObject:[array objectAtIndex:i]];
        }
    }
    [self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.fileSearchBar resignFirstResponder];
}

@end
