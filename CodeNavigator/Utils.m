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
#import "Parser.h"

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

@implementation ResultFile

@synthesize fileName = _fileName;

@synthesize contents = _contents;

@end

@implementation Utils

static Utils *static_utils;

@synthesize detailViewController;
@synthesize analyzeInfoPopover;
@synthesize analyzeInfoController;
@synthesize analyzeThread;
@synthesize analyzePath;
@synthesize resultFileList = _resultFileList;
@synthesize searchKeyword = _searchKeyword;
@synthesize storedAnalyzePath;

+(Utils*)getInstance
{
    if (nil == static_utils) {
        static_utils = [[Utils alloc] init];
    }
    return static_utils;
}

-(void) initBanner:(UISplitViewController *)view
{
    _bannerViewController = [[BannerViewController alloc] initWithContentViewController:view];
    _bannerView =  [[ADBannerView alloc] init];
    _bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects: ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
    [_bannerViewController showBannerView];
}

-(BannerViewController*) getBannerViewController
{
    return _bannerViewController;
}

-(ADBannerView*) getBannerView
{
    return _bannerView;
}

-(void) dealloc
{
    [self setDetailViewController:nil];
    [self setAnalyzeInfoController:nil];
    [self setAnalyzeInfoPopover:nil];
    [self setAnalyzeThread:nil];
    [self setAnalyzePath:nil];
    [self.resultFileList removeAllObjects];
    [self setResultFileList:nil];
    [self setSearchKeyword:nil];
    [self setStoredAnalyzePath:nil];
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
    extension = [extension lowercaseString];
    if (nil == extension)
        return NO;
    else if ([extension isEqualToString:@"h"])
        return YES;
    else if ([extension isEqualToString:@"c"])
        return YES;
    else if ([extension isEqualToString:@"s"])
        return YES;
    else if ([extension isEqualToString:@"cpp"])
        return YES;
    else if ([extension isEqualToString:@"m"])
        return YES;
    else if ([extension isEqualToString:@"java"])
        return YES;
    else if ([extension isEqualToString:@"mm"])
        return YES;
    else if ([extension isEqualToString:@"cs"])
        return YES;
    else if ([extension isEqualToString:@"hpp"])
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
    [((BuildThreadData*)data) setPath:nil];
    data = nil;
    
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
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                {
                    [self.analyzeInfoController finishAnalyze];
                    [self alertWithTitle:@"CodeNavigator" andMessage:@"No source file found, stop analyzing"];
                }
            });
            return;
        }
        
#ifdef LITE_VERSION
        // check whether Lite version permitted
        int fileCount = [[db_content componentsSeparatedByString:@"\n"] count];
        if ([[projectFolder lastPathComponent] compare:@"linux_0.1"] == NSOrderedSame)
        {
            if (fileCount != 84)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[Utils getInstance] showPurchaseAlert];
                    [self.analyzeInfoController finishAnalyze];
                });
                return;
            }
        }
        else
        {
            if (fileCount > 6)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[Utils getInstance] showPurchaseAlert];
                    [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Count of source files are larger than 5, Failed to analyze"];
                    [self.analyzeInfoController finishAnalyze];
                });
                return;
            }
        }
#endif
        
        
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

-(void) analyzeProjectConfirmed:(NSString *)path andForceCreate:(BOOL)forceCreate
{
    BuildThreadData* data = [[BuildThreadData alloc]init];
    [data setPath:path];
    [data setForce:forceCreate];
    self.analyzeThread = nil;
    self.analyzeThread = [[NSThread alloc] initWithTarget:self selector:@selector(analyzeThread:) object:data];
    [self.analyzeThread start];
    return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertConfirmMode == ALERT_ANALYZE)
    {
        if (buttonIndex == 1)
        {
            [self analyzeProjectConfirmed:storedAnalyzePath andForceCreate:storedForceAnalyze];
            storedForceAnalyze = NO;
            self.storedAnalyzePath = nil;
        }
        else
        {
            storedForceAnalyze = NO;
            self.storedAnalyzePath = nil;
        }
    }
    else if (alertConfirmMode == ALERT_PURCHASE)
    {
        if (buttonIndex == 1)
        {
            //Purchase
            [self openPurchaseURL];
        }
    }
    alertConfirmMode = ALERT_NONE;
}

-(void) openPurchaseURL
{
    NSString* url = @"http://itunes.apple.com/us/app/codenavigator/id492480832?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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
    NSString *databaseFile;
    BOOL isFolder;
    BOOL isExist;
    NSString* projectFolder = [[Utils getInstance] getProjectFolder:path];
    databaseFile = [projectFolder stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:databaseFile isDirectory:&isFolder];
    
    if (forceCreate || isExist == NO || (isExist == YES && isFolder == YES))
    {
        NSString* project = [projectFolder lastPathComponent];
        storedAnalyzePath = path;
        storedForceAnalyze = forceCreate;
        alertConfirmMode = ALERT_ANALYZE;
        UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:[NSString stringWithFormat:@"Would you like to analyze \"%@\" for code navigation?",project] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [confirmAlert show];
    }
}


-(BOOL) setResultListAndAnalyze:(NSArray *)list andKeyword:(NSString *)keyword
{
    if (_resultFileList == nil)
        _resultFileList = [[NSMutableArray alloc] init];
    else
        [_resultFileList removeAllObjects];
    
    for (int i=0; i<[list count]; i++)
    {
        NSArray* array = [[list objectAtIndex:i] componentsSeparatedByString:@" "];
        if ([array count] < 2)
            continue;
        int index = [self fileExistInResultFileList:[array objectAtIndex:0]];
        if (index == -1)
        {
            ResultFile* element = [[ResultFile alloc] init];
            element.fileName = [array objectAtIndex:0];
            element.contents = [[NSMutableArray alloc] init];
            NSString* tmp = @"";
            tmp = [tmp stringByAppendingString:[array objectAtIndex:1]];
            for (int j = 2; j<[array count]; j++)
            {
                tmp = [tmp stringByAppendingFormat:@" %@", [array objectAtIndex:j]];
            }
            [element.contents addObject:tmp];
            [_resultFileList addObject:element];
        }
        else
        {
            if ([_resultFileList count] > 30)
                continue;
            ResultFile* element = [_resultFileList objectAtIndex:index];
            NSString* tmp = @"";
            tmp = [tmp stringByAppendingString:[array objectAtIndex:1]];
            for (int j = 2; j<[array count]; j++)
            {
                tmp = [tmp stringByAppendingFormat:@" %@", [array objectAtIndex:j]];
            }
            [element.contents addObject:tmp];
        }
    }
    _searchKeyword = keyword;
//    [self.tableView reloadData];
//    [self setTitle:[NSString stringWithFormat:@"Result files for \"%@\"", _keyword]];
//    [self.navigationController popViewControllerAnimated:NO];
    if ([list count] == 2)
    {
        NSString* content = [((ResultFile*)[_resultFileList objectAtIndex:0]).contents objectAtIndex:0];
        NSArray* components = [content componentsSeparatedByString:@" "];
        if ([components count] < 3)
            return NO;
        NSString* line = [components objectAtIndex:1];
        NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
        filePath = [filePath stringByAppendingPathComponent:((ResultFile*)[_resultFileList objectAtIndex:0]).fileName];
        [self.detailViewController gotoFile:filePath andLine:line andKeyword:keyword];
        return NO;
    }
    else if ([list count] == 1)
    {
        [[Utils getInstance] alertWithTitle:@"Result" andMessage:@"No Result Found"];
        return NO;
    }
    return YES;
}

-(void) cscopeSearch:(NSString*)keyword andPath:(NSString*)path andType:(int) type
{
    if ([Utils getInstance].analyzeThread.isExecuting == YES)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Project Analyzing is in progress, Please wait untile analyze finished"];
        return;
    }
    
    NSString* fileList = nil;
    NSString* dbFile = nil;
    BOOL isExist = NO;
    
    if ([path length] == 0)
    {
        [self alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    
    fileList = [path stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
    dbFile = [path stringByAppendingPathComponent:@"project.lgz_db"];
    
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileList];
    if (isExist == NO)
    {
        [self analyzeProject:path andForceCreate:YES];
//        isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileList];
//        if (isExist == NO)
//            [self alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:dbFile];
    if (isExist == NO)
    {
        [self analyzeProject:path andForceCreate:YES];
//        isExist = [[NSFileManager defaultManager] fileExistsAtPath:dbFile];
//        if (isExist == NO)
//            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    char* _result = 0;
    NSString* result = @"";
    cscope_set_base_dir([path UTF8String]);
    switch (type) {
        case 0:
            _result = cscope_find_this_symble([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 1:
            _result = cscope_find_global([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 2:
            _result = cscope_find_called_functions([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 3:
            _result = cscope_find_functions_calling_a_function([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 4:
            _result = cscope_find_text_string([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 5:
            _result = cscope_find_a_file([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 6:
            _result = cscope_find_files_including_a_file([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
            
        default:
            break;
    }
    if (_result != 0)
    {
        result = [NSString stringWithCString:_result encoding:NSUTF8StringEncoding];
        free(_result);
        _result = 0;
        NSArray* lines = [result componentsSeparatedByString:@"\n"];

        BOOL pop = NO;
        pop = [self setResultListAndAnalyze:lines andKeyword:keyword];
        //TODO when poped up already, what to do?
        resultTableviewMode = TABLEVIEW_FILE;
        resultCurrentFileIndex = 0;
        if (pop)
           [self.detailViewController resultPopUp:self.detailViewController.resultBarButton];
    }
    else
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Low Memorry!"];
    }
}

-(int) fileExistInResultFileList:(NSString *)_file
{
    for (int i=0; i<[_resultFileList count]; i++)
    {
        ResultFile* file = [_resultFileList objectAtIndex:i];
        if ([file.fileName compare:_file] == NSOrderedSame)
            return i;
    }
    return -1;
}

#pragma ResultViewController storage

-(void) setResultViewFileIndex:(int)index
{
    resultCurrentFileIndex = index;
}

-(void) setResultViewTableViewMode:(TableViewMode)mode
{
    resultTableviewMode = mode;
}

-(TableViewMode) getResultViewTableViewMode
{
    return resultTableviewMode;
}

-(int) getResultViewFileIndex
{
    return resultCurrentFileIndex;
}

#pragma RC4
-(NSString*)HloveyRC4:(NSString*)aInput key:(NSString*)aKey
{
    
    NSMutableArray *iS = [[NSMutableArray alloc] initWithCapacity:256];
    NSMutableArray *iK = [[NSMutableArray alloc] initWithCapacity:256];
    
    for (int i= 0; i<256; i++) {
        [iS addObject:[NSNumber numberWithInt:i]];
    }
    
    int j=1;
    
    for (short i=0; i<256; i++) {
        
        UniChar c = [aKey characterAtIndex:i%aKey.length];
        
        [iK addObject:[NSNumber numberWithChar:c]];
    }
    
    j=0;
    
    for (int i=0; i<255; i++) {
        int is = [[iS objectAtIndex:i] intValue];
        UniChar ik = (UniChar)[[iK objectAtIndex:i] charValue];
        
        j = (j + is + ik)%256;
        NSNumber *temp = [iS objectAtIndex:i];
        [iS replaceObjectAtIndex:i withObject:[iS objectAtIndex:j]];
        [iS replaceObjectAtIndex:j withObject:temp];
        
    }
    
    int i=0;
    j=0;
    
    NSString *result = aInput;
    
    for (short x=0; x<[aInput length]; x++) {
        i = (i+1)%256;
        
        int is = [[iS objectAtIndex:i] intValue];
        j = (j+is)%256;
        
        int is_i = [[iS objectAtIndex:i] intValue];
        int is_j = [[iS objectAtIndex:j] intValue]; 
        
        int t = (is_i+is_j) % 256;
        int iY = [[iS objectAtIndex:t] intValue];
        
        UniChar ch = (UniChar)[aInput characterAtIndex:x];
        UniChar ch_y = ch^iY;
        
        result = [result stringByReplacingCharactersInRange:NSMakeRange(x, 1) withString:[NSString stringWithCharacters:&ch_y length:1]];
    }
    
    return result;
}

-(NSString*) getDisplayPath:(NSString*) path
{
    NSString* displayPath;
    displayPath = [path stringByDeletingPathExtension];
    displayPath = [displayPath stringByAppendingFormat:@"_%@",[path pathExtension]];
    displayPath = [displayPath stringByAppendingPathExtension:@"display"];
    return displayPath;
}

-(NSString*) getDisplayFile:(NSString*) path andProjectBase:(NSString*)projectPath
{
    NSString* displayPath;
    BOOL isFolder;
    NSString* html;
    NSError *error;
    //NSString* rc4Result;

    displayPath = [self getDisplayPath:path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:displayPath isDirectory:&isFolder])
    {
        Parser* parser = [[Parser alloc] init];
        if ([[Utils getInstance] isSupportedType:path] == YES)
            [parser setParserType:CPLUSPLUS];
        else
            [parser setParserType:UNKNOWN];
        [parser setFile: path andProjectBase:projectPath];
        [parser startParse];
        html = [parser getHtml];
        //rc4Result = [self HloveyRC4:html key:@"lgz"];
        [html writeToFile:displayPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    else
    {
        NSStringEncoding encoding = NSUTF8StringEncoding;
        html = [NSString stringWithContentsOfFile: displayPath usedEncoding:&encoding error: &error];
        //html = [self HloveyRC4:rc4Result key:@"lgz"];
    }
    return html;
    return nil;
}

-(void) showPurchaseAlert
{
    alertConfirmMode = ALERT_PURCHASE;
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:[NSString stringWithFormat:@"It can only support 5 source files in one Project for Lite Version, Do you want to get Unlimited Full version?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Purchase", nil];
    [confirmAlert show];
}

@end
