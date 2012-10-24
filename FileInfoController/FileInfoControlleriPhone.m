//
//  FileInfoControlleriPhone.m
//  CodeNavigator
//
//  Created by Guozhen Li on 6/14/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "FileInfoControlleriPhone.h"
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

@implementation FileInfoControlleriPhone

@synthesize masterViewController;
@synthesize sourceFilePath;

-(void)dealloc
{
    [self setSourceFilePath:nil];
    [self setMasterViewController:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString* proj = [[Utils getInstance] getProjectFolder:sourceFilePath];
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath:sourceFilePath error:&error];
        NSString* displayPath = [[Utils getInstance] getDisplayFileBySourceFile:sourceFilePath];
        [[NSFileManager defaultManager] removeItemAtPath:displayPath error:&error];
        NSString* tagPath = [[Utils getInstance] getTagFileBySourceFile:sourceFilePath];
        [[NSFileManager defaultManager] removeItemAtPath:tagPath error:&error];
        [masterViewController reloadData];
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
#ifdef IPHONE_VERSION
    ManuallyParserViewController* viewController = [[ManuallyParserViewController alloc] initWithNibName:@"ManuallyParserViewController-iPhone" bundle:nil];
    [viewController setFilePath:sourceFilePath];
    [masterViewController presentModalViewController:viewController animated:YES];
#else
    ManuallyParserViewController* viewController = [[ManuallyParserViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [viewController setFilePath:sourceFilePath];
    [[Utils getInstance].splitViewController presentModalViewController:viewController animated:YES];
#endif
}

-(void)setSourceFile:(NSString *)path
{
    UIActionSheet* alert;
    [self setSourceFilePath:path];
    NSString* extention = [path pathExtension];
    extention = [extention lowercaseString];
    NSString* proj = [[Utils getInstance] getProjectFolder:path];
    if ([proj length] == 0 || [proj compare:path] == NSOrderedSame) {
        return;
    }
    if ([extention compare:@"html"] == NSOrderedSame) {
        fileInfoType = FILEINFO_WEB;
        //Do not change the order
        alert = [[UIActionSheet alloc] initWithTitle:@"" 
                                            delegate:self
                                   cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"Open as Source File", @"Preview", @"Delete", nil];
    } else {
        if ([[Utils getInstance] isDocType:path] == YES ||
            [[Utils getInstance] isImageType:path]) {
            fileInfoType = FILEINFO_OTHER;
            alert = [[UIActionSheet alloc] initWithTitle:@"" 
                                                delegate:self 
                                       cancelButtonTitle:@"Cancel" 
                                  destructiveButtonTitle:nil 
                                       otherButtonTitles:@"Delete", nil];
            return;
        }
        
        fileInfoType = FILEINFO_SOURCE;
        //Do not change the order
        alert = [[UIActionSheet alloc] initWithTitle:@"" 
                                            delegate:self 
                                   cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:nil 
                                   otherButtonTitles:@"Refresh", @"Open As", @"Delete", nil];
    }
    [alert showInView:masterViewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DetailViewController* controller = [Utils getInstance].detailViewController;
    
    switch (fileInfoType) {
        case FILEINFO_SOURCE:
            if (buttonIndex == RE_OPEN) {
                NSError* error;
                NSString* displayFile = [[Utils getInstance] getDisplayPath:sourceFilePath];
                [[NSFileManager defaultManager] removeItemAtPath:displayFile error:&error];
                NSString* projPath = [[Utils getInstance] getProjectFolder:sourceFilePath];
                NSString* html = [[Utils getInstance] getDisplayFile:sourceFilePath andProjectBase:projPath];
                if (html != nil)
                {
                    [controller setTitle:[sourceFilePath lastPathComponent] andPath:displayFile andContent:html andBaseUrl:nil];
                    [masterViewController presentModalViewController:[Utils getInstance].detailViewController animated:NO];
                }
                else
                {            
                    if ([[Utils getInstance] isDocType:sourceFilePath])
                    {
                        [controller displayDocTypeFile:sourceFilePath];
                        [masterViewController presentModalViewController:[Utils getInstance].detailViewController animated:NO];
                        return;
                    }
                }
            }
            else if (buttonIndex == OPEN_AS) {
                [self presentOpenAsView];
            }
            else if (buttonIndex == SOURCE_DELETE) {
                [self deleteFile];
            }
            break;
            
        case FILEINFO_WEB:
            if (buttonIndex == OPEN_AS_SOURCE) {
                if ([[Utils getInstance] isWebType:sourceFilePath])
                {
                    NSString* projPath = [[Utils getInstance] getProjectFolder:sourceFilePath];
                    NSString* html = [[Utils getInstance] getDisplayFile:sourceFilePath andProjectBase:projPath];
                    NSString* displayPath = [[Utils getInstance] getDisplayPath:sourceFilePath];
                    if (html != nil)
                    {
                        DetailViewController* controller = [Utils getInstance].detailViewController;
                        [controller setTitle:[sourceFilePath lastPathComponent] andPath:displayPath andContent:html andBaseUrl:nil];
                        [masterViewController presentModalViewController:[Utils getInstance].detailViewController animated:NO];
                    }
                }
            }
            else if (buttonIndex == PREVIEW) {
                NSError *error;
                NSStringEncoding encoding = NSUTF8StringEncoding;
                NSString* html = [NSString stringWithContentsOfFile: sourceFilePath usedEncoding:&encoding error: &error];
                [controller setTitle:[sourceFilePath lastPathComponent] andPath:sourceFilePath andContent:html andBaseUrl:[sourceFilePath stringByDeletingLastPathComponent]];
                [masterViewController presentModalViewController:[Utils getInstance].detailViewController animated:NO];
            }
            else if (buttonIndex == WEB_DELETE) {
                [self deleteFile];
            }
        case FILEINFO_OTHER:
            [self deleteFile];
            break;
        default:
            break;
    }

}

@end
