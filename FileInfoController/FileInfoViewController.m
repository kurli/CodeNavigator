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
#import "OpenAsViewController.h"
#import "GitLogViewCongroller.h"
#import "GitBranchController.h"
#import "GitBranchViewController.h"
#import "GitUpdateViewController.h"

//source wrapper
#define RE_OPEN 0
#define OPEN_AS 1
#define SOURCE_DELETE 2
#define SOURCE_GIT_LOG 3

//folder wrapper
#define FOLDER_DELETE 0
#define FOLDER_GIT_LOG 1

//project wrapper
#define PROJECT_DELETE 0
#define PROJECT_GIT_LOG 1
#define PROJECT_GIT_BRANCH 2
#define PROJECT_GIT_UPDATE 3

//web wrapper
#define OPEN_AS_SOURCE 0
#define PREVIEW 1
#define WEB_DELETE 2
#define WEB_GIT_LOG 3

@interface FileInfoViewController ()

@end

@implementation FileInfoViewController

@synthesize masterViewController;
@synthesize selectionList;
@synthesize sourceFilePath;
@synthesize openAsViewController;

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
    [self setOpenAsViewController:nil];
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
    [self setOpenAsViewController:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.contentSizeForViewInPopover = self.view.frame.size;
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
        BOOL isFolder = false;
        [[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath isDirectory:&isFolder];
        NSString* proj = [[Utils getInstance] getProjectFolder:sourceFilePath];
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath:sourceFilePath error:&error];
        if (!isFolder) {
            NSString* displayPath = [[Utils getInstance] getDisplayFileBySourceFile:sourceFilePath];
            [[NSFileManager defaultManager] removeItemAtPath:displayPath error:&error];
            NSString* tagPath = [[Utils getInstance] getTagFileBySourceFile:sourceFilePath];
            [[NSFileManager defaultManager] removeItemAtPath:tagPath error:&error];
            //remove comments file
            NSString* extension = [sourceFilePath pathExtension];
            NSString* commentFile = [sourceFilePath stringByDeletingPathExtension];
            commentFile = [commentFile stringByAppendingFormat:@"_%@", extension];
            commentFile = [commentFile stringByAppendingPathExtension:@"lgz_comment"];
            [[NSFileManager defaultManager] removeItemAtPath:commentFile error:&error];
        }
        [masterViewController reloadData];
        if ([sourceFilePath compare:proj] != NSOrderedSame) {
            [[Utils getInstance] analyzeProject:proj andForceCreate:YES];
        }
    }
}

-(void) deleteFile
{
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:@"Would you like to delete this?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
     [confirmAlert show];
}

-(void) presentOpenAsView
{
    UINavigationController* navigationController = [self navigationController];
    openAsViewController = [[OpenAsViewController alloc] init];
    [openAsViewController setFilePath:sourceFilePath];
    [navigationController pushViewController:openAsViewController animated:YES];
}

-(void) presentGitLog {
    NSString* gitFolder = [[Utils getInstance] getGitFolder:sourceFilePath];
    if ([gitFolder length] == 0) {
        return;
    }
    // If it's project folder
    NSString* proj = [[Utils getInstance] getProjectFolder:sourceFilePath];
#ifdef IPHONE_VERSION
    GitLogViewCongroller* gitlogView = [[GitLogViewCongroller alloc] initWithNibName:@"GitLogViewController-iPhone" bundle:[NSBundle mainBundle]];
#else
    GitLogViewCongroller* gitlogView = [[GitLogViewCongroller alloc] initWithNibName:@"GitLogViewController" bundle:[NSBundle mainBundle]];
#endif
    [gitlogView setCompareContainsPath:sourceFilePath];
    [gitlogView gitLogForProject: proj];
    [gitlogView showModualView];
    [[Utils getInstance] addGAEvent:@"FileInfo" andAction:@"GitLog" andLabel:nil andValue:nil];
}

-(void) switchBranch {
    NSString* gitFolder = [[Utils getInstance] getGitFolder:sourceFilePath];
    GitBranchController* gitBranchController = [[GitBranchController alloc] init];
    BOOL isGitValid = [gitBranchController initWithProjectPath:gitFolder];
    if (isGitValid == NO) {
        return;
    }
    UINavigationController* navigationController = [self navigationController];
    GitBranchViewController* viewController = [[GitBranchViewController alloc] init];
    [viewController setGitBranchController:gitBranchController];
    viewController.contentSizeForViewInPopover = self.view.frame.size;
    [viewController setNeedSwitchBranch:YES];
    [navigationController pushViewController:viewController animated:YES];
}

-(void) updateRepo {
//    [[[Utils getInstance].splitViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
#ifdef IPHONE_VERSION
    GitUpdateViewController* updateController = [[GitUpdateViewController alloc] initWithNibName:@"GitUpdateViewController-iPhone" bundle:[NSBundle mainBundle]];
#else
    GitUpdateViewController* updateController = [[GitUpdateViewController alloc] init];
#endif
    updateController.modalPresentationStyle = UIModalPresentationFormSheet;
    NSString* gitFolder = [[Utils getInstance] getGitFolder:sourceFilePath];
    [updateController setGitFolder:gitFolder];
#ifdef IPHONE_VERSION
    [[Utils getInstance].masterViewController presentViewController:updateController animated:YES completion:nil];
#else
    [[Utils getInstance].splitViewController presentViewController:updateController animated:YES completion:nil];
#endif
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController* controller = [Utils getInstance].detailViewController;
    switch (fileInfoType) {
        case FILEINFO_SOURCE:
            if (indexPath.row == RE_OPEN) {
                [masterViewController.popOverController dismissPopoverAnimated:YES];
                NSError* error;
                NSString* displayFile = [[Utils getInstance] getDisplayPath:sourceFilePath];
                [[NSFileManager defaultManager] removeItemAtPath:displayFile error:&error];
                NSString* projPath = [[Utils getInstance] getProjectFolder:sourceFilePath];
                [[Utils getInstance] getDisplayFile:sourceFilePath andProjectBase:projPath andFinishBlock:^(NSString* html) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (html != nil)
                        {
                            [controller setTitle:[sourceFilePath lastPathComponent] andPath:displayFile andContent:html andBaseUrl:nil];
                        }
                        else {
                            if ([[Utils getInstance] isDocType:sourceFilePath])
                            {
                                [controller displayDocTypeFile:sourceFilePath];
                                return;
                            }
                        }
                    });
                }];

                [[Utils getInstance] addGAEvent:@"FileInfo" andAction:@"Refresh" andLabel:nil andValue:nil];
            }
            else if (indexPath.row == OPEN_AS) {
                [self presentOpenAsView];
                [[Utils getInstance] addGAEvent:@"FileInfo" andAction:@"OpenAs" andLabel:nil andValue:nil];
            }
            else if (indexPath.row == SOURCE_DELETE) {
                [masterViewController.popOverController dismissPopoverAnimated:YES];
                [self deleteFile];
            } else if (indexPath.row == SOURCE_GIT_LOG) {
                [masterViewController.popOverController dismissPopoverAnimated:YES];
                [self presentGitLog];
            }
            break;
            
        case FILEINFO_WEB:
            [masterViewController.popOverController dismissPopoverAnimated:YES];
            if (indexPath.row == OPEN_AS_SOURCE) {
                if ([[Utils getInstance] isWebType:sourceFilePath])
                {
                    NSString* projPath = [[Utils getInstance] getProjectFolder:sourceFilePath];
                    [[Utils getInstance] getDisplayFile:sourceFilePath andProjectBase:projPath andFinishBlock:^(NSString* html) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString* displayPath = [[Utils getInstance] getDisplayPath:sourceFilePath];
                            if (html != nil)
                            {
                                DetailViewController* controller = [Utils getInstance].detailViewController;
                                [controller setTitle:[sourceFilePath lastPathComponent] andPath:displayPath andContent:html andBaseUrl:nil];
                            }
                        });
                    }];
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
            } else if (indexPath.row == WEB_GIT_LOG) {
                [self presentGitLog];
            }
            break;
        case FILEINFO_OTHER:
            [masterViewController.popOverController dismissPopoverAnimated:YES];
            if (indexPath.row == 0) {
                [self deleteFile];
            } else if (indexPath.row == 1) {
                [self presentGitLog];
            }
            break;
        case FILEINFO_FOLDER:
            [masterViewController.popOverController dismissPopoverAnimated:YES];
            if (indexPath.row == FOLDER_DELETE) {
                [self deleteFile];
            } else if (indexPath.row == FOLDER_GIT_LOG) {
                [self presentGitLog];
            }
            break;
        case FILEINFO_PROJECT:
            if (indexPath.row == PROJECT_DELETE) {
                [masterViewController.popOverController dismissPopoverAnimated:YES];
                [self deleteFile];
            } else if (indexPath.row == PROJECT_GIT_LOG) {
                [masterViewController.popOverController dismissPopoverAnimated:YES];
                [self presentGitLog];
            } else if (indexPath.row == PROJECT_GIT_BRANCH) {
                [self switchBranch];
                [[Utils getInstance] addGAEvent:@"FileInfo" andAction:@"GitBranch" andLabel:nil andValue:nil];
            } else if (indexPath.row == PROJECT_GIT_UPDATE) {
                [self updateRepo];
                [[Utils getInstance] addGAEvent:@"FileInfo" andAction:@"UpdateGit" andLabel:nil andValue:nil];
            }
            break;
        default:
            break;
    }
}

-(void)setSourceFile:(NSString *)path
{
    [self setSourceFilePath:path];
    NSString* extension = [path pathExtension];
    extension = [extension lowercaseString];
    NSString* proj = [[Utils getInstance] getProjectFolder:path];
    NSString* gitFolder = [[Utils getInstance] getGitFolder:path];
    BOOL isFolder = false;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder];
    if ([proj length] == 0) {
        self.selectionList = nil;
        return;
    }
    if ([extension compare:@"html"] == NSOrderedSame) {
        fileInfoType = FILEINFO_WEB;
        //Do not change the order
        if ([gitFolder length] == 0) {
            selectionList = [[NSMutableArray alloc] initWithObjects:@"Open as Source File", @"Preview", @"Delete", nil];
        } else {
            selectionList = [[NSMutableArray alloc] initWithObjects:@"Open as Source File", @"Preview", @"Delete", @"Git Log", nil];
        }
    } else {
        if ([[Utils getInstance] isDocType:path] == YES ||
            [[Utils getInstance] isImageType:path]) {
            fileInfoType = FILEINFO_OTHER;
            if ([gitFolder length] == 0) {
                selectionList = [[NSMutableArray alloc] initWithObjects:@"Delete", nil];
            } else {
                selectionList = [[NSMutableArray alloc] initWithObjects:@"Delete", @"Git Log", nil];
            }
            return;
        }
        
        // Project folder
        if (isFolder && [path compare:proj] == NSOrderedSame) {
            fileInfoType = FILEINFO_PROJECT;
            if ([gitFolder length] == 0) {
                selectionList = [[NSMutableArray alloc] initWithObjects:@"Delete", nil];
            } else {
                selectionList = [[NSMutableArray alloc] initWithObjects:@"Delete", @"Git Log & Manage", @"Switch to Branch", @"Update", nil];
            }
            return;
        } else if (isFolder) {
            fileInfoType = FILEINFO_FOLDER;
            if ([gitFolder length] == 0) {
                selectionList = [[NSMutableArray alloc] initWithObjects:@"Delete", nil];
            } else {
                selectionList = [[NSMutableArray alloc] initWithObjects: @"Delete", @"Git Log", nil];
            }
            return;
        } else {
            fileInfoType = FILEINFO_SOURCE;
            if ([gitFolder length] == 0) {
                selectionList = [[NSMutableArray alloc] initWithObjects:@"Refresh", @"Open As", @"Delete", nil];
            } else {
                selectionList = [[NSMutableArray alloc] initWithObjects:@"Refresh", @"Open As", @"Delete", @"Git Log", nil];
            }
        }
    }
}

@end
