//
//  CommentManager.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/13/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "CommentManager.h"
#import "MasterViewController.h"
#import "CommentWrapper.h"
#import "Utils.h"
#import "DetailViewController.h"

@interface CommentManager ()

@end

@implementation CommentManager
@synthesize masterViewController;
@synthesize fileArray;
@synthesize commentManager;
@synthesize commentWrapper;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initWithMasterViewController:(MasterViewController *)controller
{
    currentMode = COMMENT_MANAGER_FILE;
    
    [self setMasterViewController:controller];
    NSError* error;
    NSString* projCommentPath = [masterViewController.currentProjectPath stringByAppendingPathComponent:@"lgz_projects.lgz_comment"];
    
    NSString* projCommentContent = [NSString stringWithContentsOfFile:projCommentPath encoding:NSUTF8StringEncoding error:&error];
    self.fileArray = [projCommentContent componentsSeparatedByString:@"\n"];
    NSMutableString* result = [[NSMutableString alloc] init];
    for (int i=0; i<[fileArray count]; i++) {
        if ([[self.fileArray objectAtIndex:i] length] == 0) {
            continue;
        }
        NSString* path = NSHomeDirectory();
        path = [path stringByAppendingPathComponent:@"Documents"];
        path = [path stringByAppendingPathComponent:@"Projects"];
        path = [path stringByAppendingPathComponent:[self.fileArray objectAtIndex:i]];
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (isExist) {
            [result appendFormat:@"%@\n", [self.fileArray objectAtIndex:i]];
        }
    }
    self.fileArray = [result componentsSeparatedByString:@"\n"];
    [result writeToFile:projCommentPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMasterViewController:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [self setMasterViewController:nil];
    [self setFileArray:nil];
    [self setCommentManager:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma TableView delegate

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(GLfloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentMode == COMMENT_MANAGER_FILE)
    {
        return 65;
    }
    else
        return 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (currentMode == COMMENT_MANAGER_FILE) {
        // last one is a \n, ignore it.
        return [fileArray count] -1;
    } else {
        return [self.commentWrapper.commentArray count];
    }    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *fileCellIdentifier = @"FileCell";
    UITableViewCell *cell;
    
    if (currentMode == COMMENT_MANAGER_FILE)
    {
        cell = [_tableView dequeueReusableCellWithIdentifier:fileCellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ResultTableCellView" owner:self options:nil] lastObject];
            [cell setValue:fileCellIdentifier forKey:@"reuseIdentifier"];
        }
        NSString* item = nil;
        if (indexPath.row < [fileArray count]) {
            item = [fileArray objectAtIndex:indexPath.row];
        }
        NSString* fileName = [item lastPathComponent];
        fileName = [fileName stringByDeletingPathExtension];
        NSRange locationRange = [fileName rangeOfString:@"_" options:NSBackwardsSearch];
        NSString* sourceName = [fileName substringToIndex:locationRange.location];
        NSString* extension = nil;
        if (locationRange.location + locationRange.length < [fileName length]) {
            extension =  [fileName substringFromIndex:locationRange.location+1];
        }
        NSString* sourceFullName;
        if (extension != nil)
            sourceFullName = [sourceName stringByAppendingPathExtension:extension];
        else
            sourceFullName = sourceName;
        [((UILabel *)[cell viewWithTag:101]) setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        [((UILabel *)[cell viewWithTag:101]) setText:sourceFullName];
        [((UILabel *)[cell viewWithTag:102]) setTextColor:[UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:1]];
        [((UILabel *)[cell viewWithTag:102]) setText:[[item stringByDeletingLastPathComponent] stringByAppendingPathComponent:sourceFullName]];
    }
    else
    {
        cell = [_tableView dequeueReusableCellWithIdentifier:fileCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileCellIdentifier];
        }
        CommentItem* item= (CommentItem*)([self.commentWrapper.commentArray objectAtIndex:indexPath.row]);
        cell.textLabel.text = [NSString stringWithFormat:@"%d: %@", item.line+1, item.comment];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentMode == COMMENT_MANAGER_FILE) {
        NSString* path = NSHomeDirectory();
        path = [path stringByAppendingPathComponent:@"Documents"];
        path = [path stringByAppendingPathComponent:@"Projects"];
        path = [path stringByAppendingPathComponent:[fileArray objectAtIndex:indexPath.row]];
#ifdef IPHONE_VERSION
        self.commentManager = [[CommentManager alloc] initWithNibName:@"CommentManager-iPhone" bundle:nil];
#else
        self.commentManager = [[CommentManager alloc] init];
#endif
        [self.commentManager setMasterViewController:self.masterViewController];
        [self.commentManager initWithCommentFile:path];
        [self.commentManager setCurrentModeComments];
        [self.commentManager.tableView reloadData];
        [self.navigationController pushViewController:self.commentManager animated:YES];
    } else {
        NSString* fileName = commentWrapper.filePath;
        fileName = [fileName stringByDeletingPathExtension];
        NSRange locationRange = [fileName rangeOfString:@"_" options:NSBackwardsSearch];
        NSString* sourceName = [fileName substringToIndex:locationRange.location];
        NSString* extension = nil;
        if (locationRange.location + locationRange.length < [fileName length]) {
            extension =  [fileName substringFromIndex:locationRange.location+1];
        }
        NSString* sourceFullPath;
        if (extension != NULL)
            sourceFullPath= [sourceName stringByAppendingPathExtension:extension];
        else
            sourceFullPath = sourceName;
        CommentItem* item= (CommentItem*)([self.commentWrapper.commentArray objectAtIndex:indexPath.row]);
        NSString* line = [NSString stringWithFormat:@"%d", item.line+1];
        
        [[Utils getInstance].detailViewController gotoFile:sourceFullPath andLine:line andKeyword:nil];
        
        // Change comment segment if it's hide currently
        if ([[Utils getInstance].detailViewController.showCommentsSegment selectedSegmentIndex] == 1) {
            [[Utils getInstance].detailViewController.showCommentsSegment setSelectedSegmentIndex:0];
            [[Utils getInstance].detailViewController showAllComments];
        }
        
#ifdef IPHONE_VERSION
        //[self dismissModalViewControllerAnimated:NO];
        [self presentModalViewController:[Utils getInstance].detailViewController animated:YES];
#endif
    }
}

- (void) setCurrentModeComments
{
    currentMode = COMMENT_MANAGER_COMMENTS;
}

- (void) initWithCommentFile:(NSString *)path
{
    self.commentWrapper = [[CommentWrapper alloc] init];
    [self.commentWrapper readFromFile:path];
}

#ifdef IPHONE_VERSION
- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
#endif

@end
