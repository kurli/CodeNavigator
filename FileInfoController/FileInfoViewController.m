//
//  FileInfoViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/25/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "FileInfoViewController.h"
#import "Utils.h"
#import "DetailViewController.h"
#import "MasterViewController.h"
#import "ManuallyParserViewController.h"

//source wrapper
#define RE_OPEN 0
#define OPEN_AS 1
#define SOURCE_DELETE 2

//web wrapper
#define OPEN_AS_SOURCE 0
#define PREVIEW 1
#define WEB_DELETE 2

@interface FileInfoViewController ()

@end

@implementation FileInfoViewController

@synthesize masterViewController;
@synthesize selectionList;
@synthesize sourceFilePath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self.selectionList removeAllObjects];
    [self setSelectionList:nil];
    [self setSourceFilePath:nil];
    [self setMasterViewController:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setMasterViewController:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma TableView

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [selectionList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SelectionCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [selectionList objectAtIndex:indexPath.row];

    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString* proj = [[Utils getInstance] getProjectFolder:sourceFilePath];
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath:sourceFilePath error:&error];
        NSString* displayPath = [[Utils getInstance] getDisplayFileBySourceFile:sourceFilePath];
        [[NSFileManager defaultManager] removeItemAtPath:displayPath error:&error];
        [masterViewController reloadData];
        NSString* tagPath = [[Utils getInstance] getTagFileBySourceFile:sourceFilePath];
        [[NSFileManager defaultManager] removeItemAtPath:tagPath error:&error];
        [[Utils getInstance] analyzeProject:proj andForceCreate:YES];
        //remove comments file
        NSString* extention = [sourceFilePath pathExtension];
        NSString* commentFile = [sourceFilePath stringByDeletingPathExtension];
        commentFile = [commentFile stringByAppendingFormat:@"_%@", extention];
        commentFile = [commentFile stringByAppendingPathExtension:@"lgz_comment"];
        [[NSFileManager defaultManager] removeItemAtPath:commentFile error:&error];
    }
}

-(void) deleteFile
{
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:@"Would you like to delete this file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
     [confirmAlert show];
}

-(void) presentOpenAsView
{
    ManuallyParserViewController* viewController = [[ManuallyParserViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [viewController setFilePath:sourceFilePath];
    [[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController* controller = [Utils getInstance].detailViewController;
    [masterViewController.popOverController dismissPopoverAnimated:YES];
    
    switch (fileInfoType) {
        case FILEINFO_SOURCE:
            if (indexPath.row == RE_OPEN) {
                NSError* error;
                NSString* displayFile = [[Utils getInstance] getDisplayPath:sourceFilePath];
                [[NSFileManager defaultManager] removeItemAtPath:displayFile error:&error];
                NSString* projPath = [[Utils getInstance] getProjectFolder:sourceFilePath];
                NSString* html = [[Utils getInstance] getDisplayFile:sourceFilePath andProjectBase:projPath];
                if (html != nil)
                {
                    [controller setTitle:[sourceFilePath lastPathComponent] andPath:displayFile andContent:html andBaseUrl:nil];
                }
                else
                {            
                    if ([[Utils getInstance] isDocType:sourceFilePath])
                    {
                        [controller displayDocTypeFile:sourceFilePath];
                        return;
                    }
                }
            }
            else if (indexPath.row == OPEN_AS) {
                [self presentOpenAsView];
            }
            else if (indexPath.row == SOURCE_DELETE) {
                [self deleteFile];
            }
            break;
            
        case FILEINFO_WEB:
            if (indexPath.row == OPEN_AS_SOURCE) {
                if ([[Utils getInstance] isWebType:sourceFilePath])
                {
                    NSString* projPath = [[Utils getInstance] getProjectFolder:sourceFilePath];
                    NSString* html = [[Utils getInstance] getDisplayFile:sourceFilePath andProjectBase:projPath];
                    NSString* displayPath = [[Utils getInstance] getDisplayPath:sourceFilePath];
                    if (html != nil)
                    {
                        DetailViewController* controller = [Utils getInstance].detailViewController;
                        [controller setTitle:[sourceFilePath lastPathComponent] andPath:displayPath andContent:html andBaseUrl:nil];
                    }
                }
            }
            else if (indexPath.row == PREVIEW) {
                NSError *error;
                NSStringEncoding encoding = NSUTF8StringEncoding;
                NSString* html = [NSString stringWithContentsOfFile: sourceFilePath usedEncoding:&encoding error: &error];
                [controller setTitle:[sourceFilePath lastPathComponent] andPath:sourceFilePath andContent:html andBaseUrl:[sourceFilePath stringByDeletingLastPathComponent]];
            }
            else if (indexPath.row == WEB_DELETE) {
                [self deleteFile];
            }
            break;
        case FILEINFO_OTHER:
            [self deleteFile];
            break;
        default:
            break;
    }
}

-(void)setSourceFile:(NSString *)path
{
    [self setSourceFilePath:path];
    NSString* extention = [path pathExtension];
    extention = [extention lowercaseString];
    NSString* proj = [[Utils getInstance] getProjectFolder:path];
    if ([proj length] == 0 || [proj compare:path] == NSOrderedSame) {
        self.selectionList = nil;
        return;
    }
    if ([extention compare:@"html"] == NSOrderedSame) {
        fileInfoType = FILEINFO_WEB;
        //Do not change the order
        selectionList = [[NSMutableArray alloc] initWithObjects:@"Open as Source File", @"Preview", @"Delete", nil];
    } else {
        if ([[Utils getInstance] isDocType:path] == YES ||
            [[Utils getInstance] isImageType:path]) {
            fileInfoType = FILEINFO_OTHER;
            selectionList = [[NSMutableArray alloc] initWithObjects:@"Delete", nil];
            return;
        }
        
        fileInfoType = FILEINFO_SOURCE;
        //Do not change the order
        selectionList = [[NSMutableArray alloc] initWithObjects:@"Refresh", @"Open As", @"Delete", nil];
    }
}

@end
