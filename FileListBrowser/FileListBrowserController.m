//
//  FileListBrowserController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 9/12/13.
//
//

#import "FileListBrowserController.h"
#import "Utils.h"

@implementation FileListBrowserController

@synthesize currentDirectories;
@synthesize currentFiles;
@synthesize currentLocation;
@synthesize deleteAlertView;
@synthesize _tableView;
@synthesize fileListBrowserDelegate;
@synthesize searchFileResultArray;

- (id) init
{
    self = [super init];
    isCurrentProjectFolder = NO;
    deleteItemId = -1;
    fileListBrowserDelegate = nil;
    enableFileInfoButton = NO;
    isCurrentSearchFileMode = NO;
    return self;
}

- (void)dealloc
{
    [self.currentDirectories removeAllObjects];
    [self setCurrentDirectories:nil];
    [self.currentFiles removeAllObjects];
    [self setCurrentFiles:nil];
    [self setCurrentLocation:nil];
    [self setDeleteAlertView:nil];
    [self set_tableView:nil];
    [self setFileListBrowserDelegate:nil];
    [self.searchFileResultArray removeAllObjects];
    [self setSearchFileResultArray:nil];
}

- (void)reloadData
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
        if (isCurrentProjectFolder == YES)
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
        cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FileTableViewCell" owner:self options:nil] lastObject];
            [cell setValue:fileIdentifier forKey:@"reuseIdentifier"];
        }
        imageView = (UIImageView*)[cell viewWithTag:101];
        
        NSString* fileName = [self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]];
        NSString* extension = [fileName pathExtension];
        extension = [extension lowercaseString];
        if ([extension compare:@"cc"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"ccFile.png"];
        }
        else if ([extension compare:@"c"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"cFile.png"];
        }
        else if ([extension compare:@"cpp"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"cppFile.png"];
        }
        else if ([extension compare:@"cs"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"csFile.png"];
        }
        else if ([extension compare:@"h"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"hFile.png"];
        }
        else if ([extension compare:@"hpp"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"hppFile.png"];
        }
        else if ([extension compare:@"java"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"javaFile.png"];
        }
        else if ([extension compare:@"m"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"mFile.png"];
        }
        else if ([extension compare:@"s"] == NSOrderedSame) {
            imageView.image = [UIImage imageNamed:@"sFile.png"];
        }
        else if ([extension compare:@"mm"] == NSOrderedSame) {
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
        if (enableFileInfoButton)
            [infoButton addTarget:self action:@selector(fileInfoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        else
        {
            [infoButton setHidden:YES];
            [infoButton setEnabled:NO];
        }
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

    if (indexPath.row < [self.currentDirectories count])
        return 50;
    else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isCurrentSearchFileMode == YES) {        
        if (indexPath.row >= [self.searchFileResultArray count]) {
            return;
        }
        
        NSString* item = [self.searchFileResultArray objectAtIndex:indexPath.row];
        
        [fileListBrowserDelegate fileClickedDelegate:[item lastPathComponent] andPath:item];
        return;
    }

    NSString *selectedItem;
    NSString *path;
    
    // For directories
    if (indexPath.row < [self getCurrentDirectoriesCount])
    {
        selectedItem = [self getDirectoryAtIndex:indexPath.row];
        path = [currentLocation stringByAppendingPathComponent:selectedItem];
        
        [fileListBrowserDelegate folderClickedDelegate:selectedItem andPath:path];
    }
    else
    {
        selectedItem = [self getFileNameAtIndex:indexPath.row-[self getCurrentDirectoriesCount]];
        path = [currentLocation stringByAppendingPathComponent:selectedItem];

        [fileListBrowserDelegate fileClickedDelegate: selectedItem andPath:path];
    }
}

- (void) setIsCurrentProjectFolder:(BOOL)_isProjectFolder
{
    isCurrentProjectFolder = _isProjectFolder;
}

- (BOOL) getIsCurrentProjectFolder
{
    return isCurrentProjectFolder;
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
            NSString* tagPath = [[Utils getInstance] getTagFileBySourceFile:path];
            [[NSFileManager defaultManager] removeItemAtPath:tagPath error:&error];
            //remove comments file
            NSString* extension = [path pathExtension];
            NSString* commentFile = [path stringByDeletingPathExtension];
            commentFile = [commentFile stringByAppendingFormat:@"_%@", extension];
            commentFile = [commentFile stringByAppendingPathExtension:@"lgz_comment"];
            [[NSFileManager defaultManager] removeItemAtPath:commentFile error:&error];
        }
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deleteItemId inSection:0] ] withRowAnimation:UITableViewRowAnimationFade];
        if (!isCurrentProjectFolder)
            [[Utils getInstance] analyzeProject:path andForceCreate:YES];
        [_tableView reloadData];
    }
}

- (int)getCurrentDirectoriesCount
{
    return [self.currentDirectories count];
}

- (NSString*) getFileNameAtIndex:(int)index
{
    return [currentFiles objectAtIndex:index];
}

- (NSString*) getDirectoryAtIndex:(int)index
{
    return [currentDirectories objectAtIndex:index];
}

- (void) setEnableFileInfoButton:(BOOL)enable
{
    enableFileInfoButton = enable;
}

- (IBAction)fileInfoButtonClicked:(id)sender
{
    [fileListBrowserDelegate fileInfoButtonClicked:sender];
}

-(BOOL) getIsCurrentSearchFileMode
{
    return isCurrentSearchFileMode;
}

- (IBAction)searchFileDoneButtonClicked:(id)sender
{
    isCurrentSearchFileMode = NO;
    [self.searchFileResultArray removeAllObjects];
    [self setSearchFileResultArray:nil];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    if (isCurrentSearchFileMode == YES) {
        return;
    }
    isCurrentSearchFileMode = YES;
    [self.searchFileResultArray removeAllObjects];
    [self setSearchFileResultArray:nil];
}

- (void) searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText andCurrentProjPath:(NSString*)currentProjectPath {
    NSString* fileList = [currentProjectPath stringByAppendingPathComponent:@"search_files.lgz_proj_files"];
    
    BOOL isExist;
    BOOL isFolder;
    NSError* error;
    
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileList isDirectory:&isFolder];
    if (isExist == NO) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please analyze this project first"];
        return;
    }
    searchText = [searchText lowercaseString];
    NSString* fileListContent = [NSString stringWithContentsOfFile:fileList encoding:NSUTF8StringEncoding error:&error];
    self.searchFileResultArray = [[NSMutableArray alloc] init];
    NSArray* array = [fileListContent componentsSeparatedByString:@"\n"];
    for (int i=0; i<[array count]; i++) {
        NSString* fileName = [[array objectAtIndex:i] lastPathComponent];
        fileName = [fileName lowercaseString];
        if ([fileName rangeOfString:searchText].location != NSNotFound)
        {
            [self.searchFileResultArray addObject:[array objectAtIndex:i]];
        }
    }
}

@end
