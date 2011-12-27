//
//  Utils.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "cscope.h"
#import "DetailViewController.h"
#import "AnalyzeInfoController.h"

@implementation BuildThreadData

@synthesize path;

-(void)setForce:(BOOL)f
{
    force = f;
}

-(BOOL)getForce
{
    return force;
}

@end



@implementation Utils

static Utils *static_utils;

@synthesize detailViewController;
@synthesize analyzeInfoPopover;
@synthesize analyzeInfoController;
@synthesize analyzeThread;
@synthesize analyzePath;

+(Utils*)getInstance
{
    if (nil == static_utils) {
        static_utils = [[Utils alloc] init];
    }
    return static_utils;
}

-(NSString*)getProjectFolder:(NSString *)path
{
    NSArray* components;
    NSString* projectFolder = @"";
    
    if (path != nil)
    {
        int i = 0;
        components = [path pathComponents];
        for (i = 0; i<[components count]; i++)
        {
            projectFolder = [projectFolder stringByAppendingPathComponent:[components objectAtIndex:i]];
            if ([(NSString*)[components objectAtIndex:i] compare:@"Projects"] == NSOrderedSame)
                break;
        }
        if (i == [components count] - 1)
        {
            NSLog(@"Project folder analyze failed");
            return nil;
        }
        projectFolder = [projectFolder stringByAppendingPathComponent:[components objectAtIndex:i+1]];
        return projectFolder;
    }
    return nil;
}

-(void) alertWithTitle:(NSString *)title andMessage:(id)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

-(NSString*)getPathFromProject:(NSString *)path
{
    NSArray* components;
    NSString* returnPath = @"";
    
    if (path != nil)
    {
        components = [path pathComponents];
        int i = 0;
        for (; i< [components count]; i++)
        {
            if ( [(NSString*)[components objectAtIndex:i] compare:@"Projects"] == NSOrderedSame )
            {
                break;
            }
        }
        i++;
        for (; i<[components count]; i++)
        {
            returnPath = [returnPath stringByAppendingPathComponent:[components objectAtIndex:i]];
        }
    }
    return returnPath;
}

-(NSString*) getSourceFileByDisplayFile:(NSString *)displayFile
{
    if (displayFile == nil || [displayFile length] == 0)
        return nil;
    NSString* tmp = [displayFile copy];
    NSRange locationRange = [tmp rangeOfString:@".display" options:NSBackwardsSearch];
    if ( locationRange.location != NSNotFound)
    {
        tmp = [tmp substringToIndex:locationRange.location];
        locationRange = [tmp rangeOfString:@"_" options:NSBackwardsSearch];
        if ( locationRange.location != NSNotFound )
        {
            NSString* name = [tmp substringToIndex:locationRange.location];
            if (locationRange.location+locationRange.length == [tmp length])
            {
                //No extention found
                tmp = name;
            }
            else
            {
                NSString* extention = [tmp substringFromIndex:locationRange.location+1];
                tmp = [NSString stringWithFormat:@"%@.%@", name,extention];
            }
        }
    }
    return tmp;    
}

-(NSString*) getDisplayFileBySourceFile:(NSString *)source
{
    if (source == nil || [source length] == 0)
        return nil;
    NSString* tmp = [source copy];
    NSString* extention = [source pathExtension];
    if (extention == nil || [extention length] == 0)
    {
        tmp = [tmp stringByAppendingString:@"_.display"];
    }
    else
    {
        tmp = [tmp stringByDeletingPathExtension];
        tmp = [tmp stringByAppendingFormat:@"_%@.display", extention];
    }
    return tmp;
}

-(void)deleteDisplayFileForSource:(NSString *)source
{
    NSError *error;
    NSString* displayFilePath = [[Utils getInstance] getDisplayFileBySourceFile:source];
    if (displayFilePath == nil || [displayFilePath length] == 0 )
        return;
    [[NSFileManager defaultManager] removeItemAtPath:displayFilePath error:&error];
}

-(BOOL)isSupportedType:(NSString *)file
{
    NSString *extension = [file pathExtension];
    if (nil == extension)
        return NO;
    else if ([extension isEqualToString:@"c"] || [extension isEqualToString:@"C"])
        return YES;
    else if ([extension isEqualToString:@"cpp"] || [extension isEqualToString:@"CPP"])
        return YES;
    else if ([extension isEqualToString:@"h"] || [extension isEqualToString:@"H"])
        return YES;
    return NO;
}

-(void) createFileList:(NSString *)projPath andWriteTo:(NSMutableString*) cache
{
    NSError *error;
    BOOL isFolder;
    NSString* fullPath;
    NSString* file;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:projPath error:&error];
    
    for (int i=0; i<[contents count]; i++)
    {
        file = [contents objectAtIndex:i];
        fullPath = [projPath stringByAppendingPathComponent:file];
        
        [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isFolder];
        if (isFolder == YES)
            [[Utils getInstance] createFileList:fullPath andWriteTo:cache];
        else
        {
            if ([[Utils getInstance] isSupportedType:file] == YES)
            {
                [cache appendString:fullPath];
                [cache appendString:@"\n"];
            }
        }
    }
}

-(BOOL) isProjectDatabaseFile:(NSString *)file
{
    NSString* extension = [file pathExtension];
    if (nil == extension)
        return NO;
    else if ([extension isEqualToString:@"lgz_proj_files"])
        return YES;
    else if ([extension isEqualToString:@"lgz_db"])
        return YES;
    else if ([extension isEqualToString:@"display"])
        return YES;
    else if ([extension isEqualToString:@"zip"])
        return YES;
    return NO;
}

-(UIAlertView*) showActivityIndicator:(NSString*)msg andDelegate:(id)dgt
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:msg delegate:dgt cancelButtonTitle:nil otherButtonTitles:nil];
    UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 80, 30, 30)];
    progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [alert addSubview:progress];
    [progress startAnimating];
    
    return alert;
}

-(void) showAnalyzeInfoPopOver:(BOOL)show
{
    if (show == YES)
    {
        if (self.analyzeInfoPopover == nil)
        {
            self.analyzeInfoController = [[AnalyzeInfoController alloc] init];
            self.analyzeInfoPopover = [[UIPopoverController alloc] initWithContentViewController:self.analyzeInfoController];
            self.analyzeInfoPopover.popoverContentSize = CGSizeMake(320, 130);
        }
        if (self.analyzeInfoPopover.popoverVisible == NO)
        {
            [self.analyzeInfoPopover presentPopoverFromBarButtonItem:self.detailViewController.analyzeInfoBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else
    {
        [self.analyzeInfoPopover dismissPopoverAnimated:YES];
    }
}

-(void) pauseAnalyze
{
    //TODO
}

#pragma cscope-related

-(void) analyzeThread:(id)data
{
    NSString* path = ((BuildThreadData*)data).path;
    BOOL forceCreate = [((BuildThreadData*)data) getForce];
    NSString *databaseFile;
    BOOL isFolder;
    BOOL isExist;
    NSError *error;
    NSString *cscope_db_path;
    
    NSMutableString *db_content = [[NSMutableString alloc] init];
    NSString* projectFolder = [[Utils getInstance] getProjectFolder:path];
    [self setAnalyzePath:[projectFolder lastPathComponent]];
    
    //check whether analyzed
    databaseFile = [projectFolder stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:databaseFile isDirectory:&isFolder];
    
    if (forceCreate || isExist == NO || (isExist == YES && isFolder == YES))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAnalyzeInfoPopOver:YES];
            [[Utils getInstance].detailViewController.analyzeInfoBarButton setEnabled:YES];
        });
        [[Utils getInstance] createFileList:projectFolder andWriteTo:db_content];
        if (db_content == nil || [db_content length] == 0)
            return;
        [db_content writeToFile:databaseFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        //build cscope files
        cscope_db_path = [projectFolder stringByAppendingPathComponent:@"project.lgz_db"];
        cscope_set_base_dir([projectFolder UTF8String]);
        cscope_build([cscope_db_path UTF8String], [databaseFile UTF8String]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //if (self.analyzeInfoPopover.isPopoverVisible)
            {
                [self.analyzeInfoController finishAnalyze];
                [self alertWithTitle:@"CodeNavigator" andMessage:[NSString stringWithFormat:@"Analyze \"%@\" finished", [projectFolder lastPathComponent]]];
            }
        });
    }
}

-(void) analyzeProject:(NSString *)path andForceCreate:(BOOL)forceCreate
{
    if (self.analyzeThread.isExecuting == YES)
    {
        if (forceCreate == YES)
        {
            NSString* info = [NSString stringWithFormat:@"Project \"%@\" is Analyzing in progress, Please  manually try again later.", [self.analyzePath lastPathComponent]];
            [self alertWithTitle:@"CodeNavigator" andMessage:info];
            [self showAnalyzeInfoPopOver:YES];
            return;
        }
        else
            return;
    }
    BuildThreadData* data = [[BuildThreadData alloc]init];
    [data setPath:path];
    [data setForce:forceCreate];
    self.analyzeThread = nil;
    self.analyzeThread = [[NSThread alloc] initWithTarget:self selector:@selector(analyzeThread:) object:data];
    [self.analyzeThread start];
    return;
}


@end
