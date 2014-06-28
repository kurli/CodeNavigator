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
#import "HTMLConst.h"
#import "MasterViewController.h"
#import "VirtualizeViewController.h"
#import "VirtualizeWrapper.h"
#import "VersionViewController.h"

#ifdef LITE_VERSION
#import "GADBannerView.h"
#endif

#import "FunctionListManager.h"
#import "DisplayController.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

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

@implementation SearchThreadData

@synthesize sourcePath;
@synthesize fromVir;
@synthesize dbFile;
@synthesize fileList;

@end

@implementation ResultFile

@synthesize fileName = _fileName;

@synthesize contents = _contents;

@end

@implementation Utils

static Utils *static_utils;

@synthesize detailViewController;
@synthesize analyzeThread;
@synthesize cscopeSearchThread;
@synthesize analyzePath;
@synthesize resultFileList = _resultFileList;
@synthesize searchKeyword = _searchKeyword;
@synthesize storedAnalyzePath;
@synthesize splitViewController;
@synthesize dropBoxViewController;
@synthesize masterViewController;
@synthesize functionListManager;
@synthesize gitPassword;
@synthesize gitUsername;
@synthesize cscopeIndicator;
@synthesize currentThemeSetting;

+(Utils*)getInstance
{
    if (nil == static_utils) {
        static_utils = [[Utils alloc] init];
    }
    return static_utils;
}

-(id) init
{
    self = [super init];
    cssVersion = 1;
#ifdef LITE_VERSION
    is_adMobON = YES; 
#endif
    return self;
}

-(void)dealloc
{
#ifdef LITE_VERSION
    _adModView.delegate = nil;
#endif
    _adModView = nil;
#ifdef LITE_VERSION
    _iAdView.delegate = nil;
#endif
    _iAdView = nil;
    [self setDropBoxViewController:nil];
    [self setDetailViewController:nil];
    [self setSplitViewController:nil];
    [self.resultFileList removeAllObjects];
}

-(BOOL) isAdModOn
{
    return is_adMobON;
}

-(void) initBanner:(UIViewController *)view
{
#ifdef LITE_VERSION
    _bannerViewController = [[BannerViewController alloc] initWithContentViewController:view];

    if([[[NSTimeZone localTimeZone] name] rangeOfString:@"America/"].location== 0 
       || [[[NSTimeZone localTimeZone] name] rangeOfString:@"Pacific/"].location== 0 
       || [[[NSTimeZone localTimeZone] name] rangeOfString:@"Europe/"].location== 0 
       || [[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Tokyo"].location== 0) 
    {
        is_adMobON = NO;
    }
    // do not support iAd
    is_adMobON = YES;
    
    if (is_adMobON == NO) {
        _iAdView =  [[ADBannerView alloc] init];
        _iAdView.requiredContentSizeIdentifiers = [NSSet setWithObjects: ADBannerContentSizeIdentifier480x32, nil];
        [_iAdView setHidden:YES];
    } else {
        _adModView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        _adModView.adUnitID = @"a14f96b923910f9";
        _adModView.rootViewController = self.splitViewController;
    }
    [_bannerViewController showBannerView];
#endif
}

-(void) initVersion
{
    VersionViewController* controller = [[VersionViewController alloc] init];
    [controller checkVersion];
}

-(int) getCSSVersion
{
    return cssVersion;
}

-(void) incressCSSVersion {
    cssVersion ++;
}

-(BannerViewController*) getBannerViewController
{
    return _bannerViewController;
}

-(ADBannerView*) getIAdBannerView
{
    return _iAdView;
}

-(GADBannerView*) getAdModBannerView
{
    return _adModView;
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
            if ([(NSString*)[components objectAtIndex:i] compare:DISPLAY_FOLDER_PATH] == NSOrderedSame)
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

-(DisplayController*) getDisplayController {
    if (displayController == nil) {
        displayController = [[DisplayController alloc] init];
    }
    return displayController;
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
    return [[self getDisplayController] getSourceFileByDisplayFile:displayFile];
}

-(NSString*) getDisplayFileBySourceFile:(NSString *)source
{
    return [[self getDisplayController] getDisplayFileBySourceFile:source];
}

-(NSString*) getTagFileBySourceFile:(NSString *)source
{
    if (source == nil || [source length] == 0)
        return nil;
    NSString* tmp = [self getDisplayPath:source];
    NSString* extension = [source pathExtension];
    if (extension == nil || [extension length] == 0)
    {
        tmp = [tmp stringByAppendingFormat:@"_.%@", @"lgz_tags"];
    }
    else
    {
        tmp = [tmp stringByDeletingPathExtension];
        tmp = [tmp stringByAppendingFormat:@".%@", @"lgz_tags"];
    }
    return tmp;
}

-(void)deleteDisplayFileForSource:(NSString *)source
{
    [[self getDisplayController] deleteDisplayFileForSource:source];
}

-(BOOL)isSupportedType:(NSString *)file
{
    NSString *extension = [file pathExtension];
    extension = [extension lowercaseString];
    if (nil == extension || [extension length] == 0)
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
    else if ([extension isEqualToString:@"cc"])
        return YES;
    else if ([extension isEqualToString:@"delphi"])
        return YES;
    else if ([extension isEqualToString:@"pascal"])
        return YES;
    else if ([extension isEqualToString:@"pas"])
        return YES;
    else if ([extension isEqualToString:@"py"])
        return YES;
    else if ([extension isEqualToString:@"python"])
        return YES;
    else if ([extension isEqualToString:@"rails"])
        return YES;
    else if ([extension isEqualToString:@"ror"])
        return YES;
    else if ([extension isEqualToString:@"ruby"])
        return YES;
    else if ([extension isEqualToString:@"php"])
        return YES;
    else if ([extension isEqualToString:@"go"])
        return YES;
    int index = [Parser checkManuallyParserIndex:extension];
    if (index != -1) {
        return YES;
    }
    return NO;
}

-(BOOL) isImageType:(NSString*)file
{
    NSString* extension = [file pathExtension];
    extension = [extension lowercaseString];
    if (nil == extension || [extension length] == 0)
        return NO;
    else if ([extension isEqualToString:@"bmp"])
        return YES;
    else if ([extension isEqualToString:@"jpg"])
        return YES;
    else if ([extension isEqualToString:@"jpeg"])
        return YES;
    else if ([extension isEqualToString:@"tiff"])
        return YES;
    else if ([extension isEqualToString:@"gif"])
        return YES;
    else if ([extension isEqualToString:@"png"])
        return YES;
    return NO;
}

-(BOOL) isDocType:(NSString *)file
{
    NSString* extension = [file pathExtension];
    extension = [extension lowercaseString];
    if (nil == extension || [extension length] == 0)
        return NO;
    else if ([extension isEqualToString:@"xls"])
        return YES;
    else if ([extension isEqualToString:@"key.zip"])
        return YES;
    else if ([extension isEqualToString:@"numbers.zip"])
        return YES;
    else if ([extension isEqualToString:@"pages.zip"])
        return YES;
    else if ([extension isEqualToString:@"pdf"])
        return YES;
    else if ([extension isEqualToString:@"ppt"])
        return YES;
    else if ([extension isEqualToString:@"doc"])
        return YES;
    else if ([extension isEqualToString:@"rtf"])
        return YES;
    else if ([extension isEqualToString:@"rtfd.zip"])
        return YES;
    else if ([extension isEqualToString:@"key"])
        return YES;
    else if ([extension isEqualToString:@"numbers"])
        return YES;
    else if ([extension isEqualToString:@"pages"])
        return YES;
    return NO;
}

-(BOOL) isWebType:(NSString *)file
{
    NSString* extension = [file pathExtension];
    extension = [extension lowercaseString];
    if (nil == extension || [extension length] == 0)
        return NO;
    else if ([extension isEqualToString:@"html"])
        return YES;
    else if ([extension isEqualToString:@"htm"])
        return YES;
    else if ([extension isEqualToString:@"xml"])
        return YES;
    return NO;
}

-(void) createFileList:(NSString *)projPath andWriteTo:(NSMutableString*) cache andSearchDelta:(NSMutableString *)delta
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
            [[Utils getInstance] createFileList:fullPath andWriteTo:cache andSearchDelta:delta];
        else
        {
            if ([[Utils getInstance] isProjectDatabaseFile:fullPath]) {
                continue;
            }
//            [cache appendString:fullPath];
//            [cache appendString:@"\n"];
            
            if ([[Utils getInstance] isSupportedType:file] == YES)
            {
                [cache appendString:fullPath];
                [cache appendString:@"\n"];
            } else {
                if ([[Utils getInstance] isProjectDatabaseFile:fullPath]) {
                    continue;
                }
                [delta appendString:fullPath];
                [delta appendString:@"\n"];
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
    else if ([extension isEqualToString:@"display_1"])
        return YES;
    else if ([extension isEqualToString:@"lgz_virtualize"])
        return YES;
    else if ([extension isEqualToString:@"lgz_vir_img"])
        return YES;
    else if ([extension isEqualToString:@"lgz_comment"])
        return YES;
    else if ([extension isEqualToString:@"display_2"])
        return YES;
    else if ([extension isEqualToString:@"display_3"])
        return YES;
    else if ([extension isEqualToString:@"display_4"])
        return YES;
    else if ([extension isEqualToString:@"lgz_tags"])
        return YES;
    else if ([extension isEqualToString:DISPLAY_FILE_EXTENTION])
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

-(void) showAnalyzeIndicator:(BOOL)show
{
    if (show == YES)
    {
        if (self.cscopeIndicator == nil) {
            self.cscopeIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            self.cscopeIndicator.hidesWhenStopped = YES;
        }
        [self.cscopeIndicator startAnimating];
        
        [self.detailViewController.analyzeInfoBarButton setCustomView:self.cscopeIndicator];
    }
    else
    {
        [self.cscopeIndicator stopAnimating];
    }
}

-(void) pauseAnalyze
{
    //TODO
}

#pragma cscope-related

-(void) analyzeThread:(id)data
{
    @autoreleasepool {
    NSString* path = ((BuildThreadData*)data).path;
    BOOL forceCreate = [((BuildThreadData*)data) getForce];
    NSString *databaseFile;
    NSString *searchDeltaFile;
    BOOL isFolder;
    BOOL isExist;
    NSError *error;
    NSString *cscope_db_path;
    
    NSMutableString *db_content = [[NSMutableString alloc] init];
    NSMutableString *search_delta_content = [[NSMutableString alloc] init];
    NSString* projectFolder = [[Utils getInstance] getProjectFolder:path];
    [self setAnalyzePath:[projectFolder lastPathComponent]];
    [((BuildThreadData*)data) setPath:nil];
    data = nil;
    
    //check whether analyzed
    databaseFile = [projectFolder stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
    searchDeltaFile = [projectFolder stringByAppendingPathComponent:@"search_files.lgz_proj_files"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:databaseFile isDirectory:&isFolder];
    
    if (forceCreate || isExist == NO || (isExist == YES && isFolder == YES))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAnalyzeIndicator:YES];
            [[Utils getInstance].detailViewController.analyzeInfoBarButton setEnabled:YES];
        });
        [[Utils getInstance] createFileList:projectFolder andWriteTo:db_content andSearchDelta:search_delta_content];
        [search_delta_content insertString:db_content atIndex:0];
        [search_delta_content writeToFile:searchDeltaFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (db_content == nil || [db_content length] == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                {
                    [self showAnalyzeIndicator:NO];
                    [self alertWithTitle:@"CodeNavigator" andMessage:@"No source file found, stop analyzing"];
                }
            });
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
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
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                return;
            }
        }
        else
        {
            if (fileCount > 6)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[Utils getInstance] showPurchaseAlert];
                    [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Maximum number of source files exceeded for Lite Version., Failed to analyze"];
                    [self.analyzeInfoController finishAnalyze];
                });
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
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
                [self showAnalyzeIndicator:NO];
                [self alertWithTitle:@"CodeNavigator" andMessage:[NSString stringWithFormat:@"Analyze \"%@\" finished", [projectFolder lastPathComponent]]];
            }
        });
    }
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void) analyzeProjectConfirmed:(NSString *)path andForceCreate:(BOOL)forceCreate
{
    BuildThreadData* data = [[BuildThreadData alloc]init];
    [data setPath:path];
    [data setForce:forceCreate];
    self.analyzeThread = nil;
    self.analyzeThread = [[NSThread alloc] initWithTarget:self selector:@selector(analyzeThread:) object:data];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
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
            [self showAnalyzeIndicator:YES];
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


-(BOOL) setResultListAndAnalyze:(NSArray *)list andKeyword:(NSString *)keyword andSourcePath:(NSString *)sourcePath
{
    if (_resultFileList == nil)
        _resultFileList = [[NSMutableArray alloc] init];
    else
        [_resultFileList removeAllObjects];
    
    NSArray* array = nil;
    for (int i=0; i<[list count]; i++)
    {
        array = [[list objectAtIndex:i] componentsSeparatedByString:@" "];
        if ([array count] < 2)
            continue;
        //If we are in find_called_function type, we need to skip other files
        if (searchType == FIND_CALLED_FUNCTIONS || searchType == FIND_GLOBAL_DEFINITION)
        {
            NSString* str = [[Utils getInstance] getPathFromProject:sourcePath];
            if ([str length] == 0) {
                str = sourcePath;
            }
            if ([str compare:[array objectAtIndex:0]] != NSOrderedSame)
            {
                continue;
            }
        }
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
//    [self.tableView reloadData];
//    [self setTitle:[NSString stringWithFormat:@"Result files for \"%@\"", _keyword]];
//    [self.navigationController popViewControllerAnimated:NO];
    if ([list count] == 2)
    {
        if ([_resultFileList count] == 0)
        {
            [[Utils getInstance] alertWithTitle:@"Result" andMessage:@"No Result Found"];
            return NO;
        }
        NSString* content = [((ResultFile*)[_resultFileList objectAtIndex:0]).contents objectAtIndex:0];
        NSArray* components = [content componentsSeparatedByString:@" "];
        if ([components count] < 3)
            return NO;
        NSString* line = [components objectAtIndex:1];
        NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
        filePath = [filePath stringByAppendingPathComponent:((ResultFile*)[_resultFileList objectAtIndex:0]).fileName];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (searchType != FIND_CALLED_FUNCTIONS)
                [self.detailViewController gotoFile:filePath andLine:line andKeyword:keyword];
            else
                [self.detailViewController gotoFile:filePath andLine:line andKeyword:[components objectAtIndex:0]];
        });
        return NO;
    }
    else if ([list count] == 1)
    {
        [[Utils getInstance] alertWithTitle:@"Result" andMessage:@"No Result Found"];
        return NO;
    }
    return YES;
}

-(void) cscopeSearch:(NSString *)keyword andPath:(NSString *)sourcePath andProject:(NSString *)project andType:(NSInteger)type andFromVir:(BOOL)fromVir
{
    [[Utils getInstance] addGAEvent:@"Cscope" andAction:[NSString stringWithFormat:@"Type=%ld", type] andLabel:nil andValue:nil];
    if (fromVir == NO)
    {
        // Because result has been changed and not from Virtualization
        // So reset to NO
        [[Utils getInstance].detailViewController.virtualizeViewController setIsNeedGetResultFromCscope:NO];
    }
    
    if (self.analyzeThread.isExecuting == YES)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Project Analyzing is in progress, Please wait untile analyze finished"];
        return;
    }
    
    if (self.cscopeSearchThread.isExecuting == YES)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Searching in progress, Please wait untile search finished"];
        return;
    }
    
    NSString* fileList = nil;
    NSString* dbFile = nil;
    BOOL isExist = NO;
    
    if ([project length] == 0)
    {
        [self alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    
    fileList = [project stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
    dbFile = [project stringByAppendingPathComponent:@"project.lgz_db"];
    
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileList];
    if (isExist == NO)
    {
        [self analyzeProject:project andForceCreate:YES];
//        isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileList];
//        if (isExist == NO)
//            [self alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:dbFile];
    if (isExist == NO)
    {
        [self analyzeProject:project andForceCreate:YES];
//        isExist = [[NSFileManager defaultManager] fileExistsAtPath:dbFile];
//        if (isExist == NO)
//            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    
//    self.cscopeSearchAlertView = [[UIAlertView alloc]   
//                           initWithTitle:@"CodeNavigator\nSearch in progress"   
//                           message:nil delegate:nil cancelButtonTitle:nil  
//                           otherButtonTitles: nil];  
//    
//    [self.cscopeSearchAlertView show];  
//    
//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]  
//                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];  
//    
//    indicator.center = CGPointMake(self.cscopeSearchAlertView.bounds.size.width / 2,   
//                                   self.cscopeSearchAlertView.bounds.size.height - 50);  
//    [indicator startAnimating];  
//    [self.cscopeSearchAlertView addSubview:indicator]; 
    
    cscope_set_base_dir([project UTF8String]);
    searchType = type;
    _searchKeyword = keyword;
    
    SearchThreadData* data = [[SearchThreadData alloc]init];
    [data setDbFile:dbFile];
    [data setFileList:fileList];
    [data setFromVir:fromVir];
    [data setSourcePath:sourcePath];
    
    [self showAnalyzeIndicator:YES];

    self.cscopeSearchThread = nil;
    self.cscopeSearchThread = [[NSThread alloc] initWithTarget:self selector:@selector(cscopeSearchMethod:) object:data];
    [self.cscopeSearchThread setThreadPriority:1];
    [self.cscopeSearchThread start];
}

- (void) cscopeSearchMethod:(id)data
{
    @autoreleasepool {
    char* _result = 0;
    NSString* result;
    NSString* keyword = [Utils getInstance].searchKeyword;
    BOOL fromVir = [(SearchThreadData*)data fromVir];
    NSString* dbFile = [(SearchThreadData*)data dbFile];
    NSString* fileList = [(SearchThreadData*)data fileList];
    NSString* sourcePath = [(SearchThreadData*)data sourcePath];

    switch (searchType) {
        case FIND_THIS_SYMBOL:
            _result = cscope_find_this_symble([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case FIND_GLOBAL_DEFINITION:
            _result = cscope_find_global([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case FIND_CALLED_FUNCTIONS:
            _result = cscope_find_called_functions([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case FIND_F_CALL_THIS_F:
            _result = cscope_find_functions_calling_a_function([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case FIND_TEXT_STRING:
            _result = cscope_find_text_string([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
//        case 5:
//            _result = cscope_find_a_file([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
//            break;
//        case 6:
//            _result = cscope_find_files_including_a_file([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
//            break;
            
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAnalyzeIndicator:NO];
    });
    if (_result != 0)
    {
        result = [NSString stringWithCString:_result encoding:NSUTF8StringEncoding];
        
        // for other language other than c
//        if (fromVir == YES)
        {
            if ([result length] == 0) {
                switch (searchType) {
                    case FIND_GLOBAL_DEFINITION:
                    case FIND_F_CALL_THIS_F:
                        free(_result);
                        _result = 0;
                        _result = cscope_find_this_symble([keyword UTF8String], [dbFile UTF8String], [fileList UTF8String]);
                    default:
                        break;
                }
                result = [NSString stringWithCString:_result encoding:NSUTF8StringEncoding];
            }
        }
        //end
        
        free(_result);
        _result = 0;
        NSArray* lines = [result componentsSeparatedByString:@"\n"];
        
        BOOL pop = NO;
        pop = [self setResultListAndAnalyze:lines andKeyword:keyword andSourcePath:sourcePath];
        //TODO when poped up already, what to do?
        resultTableviewMode = TABLEVIEW_FILE;
        resultCurrentFileIndex = 0;
        if (pop)
        {
            if (fromVir == YES)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.detailViewController forceResultPopUp:self.detailViewController.resultBarButton];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.detailViewController resultPopUp:self.detailViewController.resultBarButton];
                });
            }
        }
        else
        {
            if (fromVir == YES)
            {
                if (_resultFileList.lastObject == nil )
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[Utils getInstance].detailViewController.virtualizeViewController.virtualizeWrapper setIsNeedGetDefinition:NO];
                    });
                    return;
                }
                NSString* content = [((ResultFile*)[_resultFileList objectAtIndex:0]).contents objectAtIndex:0];
                NSArray* components = [content componentsSeparatedByString:@" "];
                if ([components count] < 3)
                    return;
                NSString* line = [components objectAtIndex:1];
                NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
                filePath = [filePath stringByAppendingPathComponent:((ResultFile*)[_resultFileList objectAtIndex:0]).fileName];
                NSString *proj = [self getProjectFolder:filePath];
                if (searchType != FIND_CALLED_FUNCTIONS && searchType != FIND_F_CALL_THIS_F)
                {
                    if ([[Utils getInstance].detailViewController.virtualizeViewController checkWhetherExistInCurrentEntry:keyword andLine:line] == NO )
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.detailViewController.virtualizeViewController addEntry:keyword andFile:filePath andLine:[line intValue] andProject:proj];
                        });
                    }
                }
                else
                {
                    NSString* word;
                    //For find called function
                    if (searchType == FIND_CALLED_FUNCTIONS)
                    {
                        word = [components objectAtIndex:0];
                    }
                    else
                        word = keyword;
                    
                    if ([[Utils getInstance].detailViewController.virtualizeViewController checkWhetherExistInCurrentEntry:word andLine:line] == NO )
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.detailViewController.virtualizeViewController addEntry:[components objectAtIndex:0] andFile:filePath andLine:[line intValue] andProject:proj];
                        });
                    }
                }
            }
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Low Memorry!"];
        });
    }
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

-(void) setResultViewFileIndex:(NSInteger)index
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

-(NSInteger) getResultViewFileIndex
{
    return resultCurrentFileIndex;
}

#pragma RC4
+ (NSString*)HloveyRC4:(NSString*)aInput key:(NSString*)aKey
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
    return [[self getDisplayController] getDisplayPath:path];
}

-(void) getDisplayFile:(NSString*) path andProjectBase:(NSString*) projectPath andFinishBlock:(ParseFileFinishedCallback)callback
{
    [[self getDisplayController] getDisplayFile:path andProjectBase:projectPath andFinishBlock:callback];
}

-(void) showPurchaseAlert
{
    alertConfirmMode = ALERT_PURCHASE;
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:[NSString stringWithFormat:@"It can only support 5 source files in one Project for Lite Version, Do you want to get Unlimited Full version?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Purchase", nil];
    [confirmAlert show];
}

-(void) setSearchType:(int)type
{
    searchType = type;
}

-(int) getSearchType
{
    return searchType;
}

-(NSString*) isPasswardSet
{
    NSError* error;
    BOOL isExist = NO;
    NSString* pasFile = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/Password"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:pasFile];
    if (isExist == NO)
    {
        return nil;
    }
    NSString* pasContent = [NSString stringWithContentsOfFile:pasFile encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        return nil;
    }
    return pasContent;
}

-(BOOL)isScreenLocked
{
    return isScreenLocked;
}

-(void) setIsScreenLocked:(BOOL)locked
{
    isScreenLocked = locked;
}

-(void) getFunctionListForFile:(NSString *)path andCallback:(GetFunctionListCallback)callback
{
    if (functionListManager == nil) {
        self.functionListManager = [[FunctionListManager alloc] init];
    }
    [self.functionListManager getFunctionListForFile:path andCallback:callback];
}

-(NSString*) getGitFolder:(NSString *)_path {
    NSString* projPath = [self getProjectFolder:_path];
    NSString* gitFolder = nil;
    NSError* error;
    BOOL isGitFolder = NO;
    
    if ([_path length] == 0) {
        return nil;
    }

    // Look inside when there is project folder passed
    if ([projPath compare:_path] == NSOrderedSame) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[_path stringByAppendingPathComponent:@".git"]]) {
            NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:&error];
            for (int i=0; i<[contents count]; i++) {
                NSString* path = [contents objectAtIndex:i];
                path = [projPath stringByAppendingPathComponent:path];
                if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@".git"]]){
                    gitFolder = path;
                    isGitFolder = YES;
                    break;
                }
            }
        } else {
            return _path;
        }
        if (isGitFolder) {
            return gitFolder;
        } else {
            return nil;
        }
    } else {
        // Look outside
        while (1) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[_path stringByAppendingPathComponent:@".git"] isDirectory:nil]) {
                return _path;
            }
            _path = [_path stringByDeletingLastPathComponent];
            if ([_path compare:projPath] == NSOrderedSame) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:[_path stringByAppendingPathComponent:@".git"] isDirectory:nil]) {
                    return _path;
                } else {
                    return nil;
                }
            }
        }
    }

}

-(void) removeDisplayFilesForProject:(NSString *)proj {
    if ([proj length] == 0) {
        return;
    }
    [[self getDisplayController] removeDisplayFilesForProject:proj];
}

-(void) addGAEvent:(NSString*) category andAction:(NSString*) action andLabel:(NSString*)label andValue:(NSNumber*)number {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:number] build]];
}

-(NSString*) getFileContent:(NSString*)path {
    NSError *error;
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString* fileContent = [NSString stringWithContentsOfFile: path usedEncoding:&encoding error: &error];
    if (error != nil || fileContent == nil)
    {
        // Chinese GB2312 support
        error = nil;
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        fileContent  = [NSString stringWithContentsOfFile:path encoding:enc error:&error];
        
        if (fileContent == nil)
        {
            const NSStringEncoding *encodings = [NSString availableStringEncodings];
            while ((encoding = *encodings++) != 0)
            {
                fileContent = [NSString stringWithContentsOfFile:path encoding:encoding error:&error];
                if (fileContent != nil && error == nil)
                {
                    break;
                }
            }
        }
        
        // find a default recognizeable encoding
        if (error != nil)
        {
            const NSStringEncoding *encodings = [NSString availableStringEncodings];
            while ((encoding = *encodings++) != 0)
            {
                fileContent = [NSString stringWithContentsOfFile:path encoding:encoding error:&error];
                if (fileContent != nil)
                {
                    break;
                }
            }
            
        }
        
        if (fileContent == nil)
            fileContent = @"File Format not supported yet!";
    }
    return fileContent;
}

@end
