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

@implementation ColorSchema

@synthesize dayType;
@synthesize day_backgroundColor;
@synthesize night_backgroundColor;
@synthesize day_comment;
@synthesize night_comment;
@synthesize day_definition;
@synthesize night_definition;
@synthesize day_keyword;
@synthesize night_keyword;
@synthesize day_header;
@synthesize night_header;
@synthesize day_string;
@synthesize night_string;
@synthesize font_size;
@synthesize day_other;
@synthesize night_other;

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
@synthesize splitViewController;
@synthesize colorScheme;
@synthesize masterViewController;

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
    return self;
}

-(void) initBanner:(UIViewController *)view
{
    _bannerViewController = [[BannerViewController alloc] initWithContentViewController:view];
    _bannerView =  [[ADBannerView alloc] init];
    _bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects: ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
    [_bannerViewController showBannerView];
}

-(void) readColorScheme
{
    BOOL isFolder = false;
    BOOL isExist = false;
    NSError *error;
    //for color scheme
    NSString* customizedColor = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/syntax_color.plist"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:customizedColor isDirectory:&isFolder];
    NSString* defaultColor = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/syntax_color.plist"];
    if (isExist == NO || (isExist == YES && isFolder == YES))
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"] withIntermediateDirectories:YES attributes:nil error:&error];
        [[NSFileManager defaultManager] copyItemAtPath:defaultColor toPath:customizedColor error:&error];

        //for javascript
        NSString* js = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/lgz_javascript.js"];
        isExist = [[NSFileManager defaultManager] fileExistsAtPath:js isDirectory:&isFolder];
        NSString* jsPath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingPathComponent:@"lgz_javascript.js"];
        if (isExist == NO || (isExist == YES && isFolder == YES))
        {
            [[NSFileManager defaultManager] copyItemAtPath:jsPath toPath:js error:&error];
        }
        cssVersion = 1;
    }
    
    NSData* data = [[NSData alloc] initWithContentsOfFile:customizedColor];
    NSDictionary *documentDictionary = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
            
    if (self.colorScheme == nil)
    {
        self.colorScheme = [[ColorSchema alloc] init];
    }
    BOOL dayType = [[documentDictionary objectForKey:@"day_type"] boolValue];
    [self.colorScheme setDayType:dayType];
    NSString* daybg = [documentDictionary objectForKey:@"day_background"];
    [self.colorScheme setDay_backgroundColor:daybg];
    NSString* nightbg = [documentDictionary objectForKey:@"night_background"];
    [self.colorScheme setNight_backgroundColor:nightbg];
    
    NSString* day_comment = [documentDictionary objectForKey:@"day_comment"];
    [self.colorScheme setDay_comment:day_comment];
    NSString* night_comment = [documentDictionary objectForKey:@"night_comment"];
    [self.colorScheme setNight_comment:night_comment];
    
    NSString* day_header = [documentDictionary objectForKey:@"day_header"];
    [self.colorScheme setDay_header:day_header];
    NSString* night_header = [documentDictionary objectForKey:@"night_header"];
    [self.colorScheme setNight_header:night_header];
    
    NSString* day_string = [documentDictionary objectForKey:@"day_string"];
    [self.colorScheme setDay_string:day_string];
    NSString* night_string = [documentDictionary objectForKey:@"night_string"];
    [self.colorScheme setNight_string:night_string];
    
    NSString* day_keyword = [documentDictionary objectForKey:@"day_keyword"];
    [self.colorScheme setDay_keyword:day_keyword];
    NSString* night_keyword = [documentDictionary objectForKey:@"night_keyword"];
    [self.colorScheme setNight_keyword:night_keyword];
    
    NSString* day_definition = [documentDictionary objectForKey:@"day_definition"];
    [self.colorScheme setDay_definition:day_definition];
    NSString* night_definition = [documentDictionary objectForKey:@"night_definition"];
    [self.colorScheme setNight_definition:night_definition];
    
    NSString* font_size = [documentDictionary objectForKey:@"font_size"];
    [self.colorScheme setFont_size:font_size];
    
    NSString* day_other = [documentDictionary objectForKey:@"day_other"];
    [self.colorScheme setDay_other:day_other];
    NSString* night_other = [documentDictionary objectForKey:@"night_other"];
    [self.colorScheme setNight_other:night_other];
    
    [self generateCSSScheme];
}

-(void) generateCSSScheme
{
    NSError *error;
    NSString* css = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/theme.css"];
    [[NSFileManager defaultManager] removeItemAtPath:css error:&error];
    
    NSString* cssStr = [NSString stringWithString:HTML_STYLE];
    
    //Background
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"-BGCOL-" withString:[self getDisplayBackgroundColor]];
    
    if ([self isDayTypeDisplayMode])
    {
        //comment
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"COMENT" withString:self.colorScheme.day_comment];
        
        //header
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"HEADER" withString:self.colorScheme.day_header];
        
        //string
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"STRING" withString:self.colorScheme.day_string];
        
        //keyword
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"KEYWRD" withString:self.colorScheme.day_keyword];
        
        //definition
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"DEFINE" withString:self.colorScheme.day_definition];
        
        //other
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"-OTHER-" withString:self.colorScheme.day_other];
    }
    else
    {
        //comment
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"COMENT" withString:self.colorScheme.night_comment];
        
        //header
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"HEADER" withString:self.colorScheme.night_header];
        
        //string
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"STRING" withString:self.colorScheme.night_string];
        
        //keyword
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"KEYWRD" withString:self.colorScheme.night_keyword];
        
        //definition
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"DEFINE" withString:self.colorScheme.night_definition];
        
        //other
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"-OTHER-" withString:self.colorScheme.night_other];
    }
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"FONT_SIZE" withString:self.colorScheme.font_size];
    [cssStr writeToFile:css atomically:YES encoding:NSUTF8StringEncoding error:&error];

    [self changeUIViewStyle:self.detailViewController.webView];
    [self changeUIViewStyle:self.detailViewController.secondWebView];
    cssVersion++;
}

-(void) changeUIViewStyle:(UIView *)view
{
    NSString*  bgcolor = [self getDisplayBackgroundColor];
    if ([bgcolor length] != 7)
        return;
    bgcolor = [bgcolor substringFromIndex:1];
    unsigned int baseValue;
    if ([[NSScanner scannerWithString:bgcolor] scanHexInt:&baseValue])
    {
        [view setBackgroundColor:UIColorFromRGB(baseValue)];
    }
}

-(int) getCSSVersion
{
    return cssVersion;
}

-(void)writeColorScheme:(BOOL)dayType andDayBackground:(NSString *)dayBG andNightBackground:(NSString *)nightBG andDayComment:(NSString *)dayC andNightComment:(NSString *)nightC andDayString:(NSString *)ds andNightString:(NSString*)ns andDayKeyword:(NSString *)dk andNightKeyword:(NSString *)nk andFontSize:(NSString *)fs
{
    NSString* customizedColor = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/syntax_color.plist"];
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] init];
    
    [plist setValue:[NSNumber numberWithBool:dayType] forKey:@"day_type"];    
    self.colorScheme.dayType = dayType;
    
    [plist setValue:self.colorScheme.day_header forKey:@"day_header"];
    [plist setValue:self.colorScheme.night_header forKey:@"night_header"];
    
    [plist setValue:self.colorScheme.day_definition forKey:@"day_definition"];
    [plist setValue:self.colorScheme.night_definition forKey:@"night_definition"];
    
    [plist setValue:self.colorScheme.day_other forKey:@"day_other"];
    [plist setValue:self.colorScheme.night_other forKey:@"night_other"];

    //font size
    if (fs == nil)
        [plist setValue:self.colorScheme.font_size forKey:@"font_size"];
    else
    {
        [plist setValue:fs forKey:@"font_size"];
        [self.colorScheme setFont_size:fs];
    }
    
    //background
    if (dayBG == nil)
        [plist setValue:self.colorScheme.day_backgroundColor forKey:@"day_background"];
    else
    {
        [plist setValue:dayBG forKey:@"day_background"];
        [self.colorScheme setDay_backgroundColor:dayBG];
    }
    
    if (nightBG == nil)
        [plist setValue:self.colorScheme.night_backgroundColor forKey:@"night_background"];
    else
    {
        [plist setValue:nightBG forKey:@"night_background"];
        [self.colorScheme setNight_backgroundColor:nightBG];
    }
    
    //comment
    if (dayC == nil)
        [plist setValue:self.colorScheme.day_comment forKey:@"day_comment"];
    else
    {
        [plist setValue:dayC forKey:@"day_comment"];
        [self.colorScheme setDay_comment:dayC];
    }
    
    if (nightC == nil)
        [plist setValue:self.colorScheme.night_comment forKey:@"night_comment"];
    else
    {
        [plist setValue:nightC forKey:@"night_comment"];
        [self.colorScheme setNight_comment:nightC];
    }
    
    //string
    if (ds == nil)
        [plist setValue:self.colorScheme.day_string forKey:@"day_string"];
    else
    {
        [plist setValue:ds forKey:@"day_string"];
        [self.colorScheme setDay_string:ds];
    }
    
    if (ns == nil)
        [plist setValue:self.colorScheme.night_string forKey:@"night_string"];
    else
    {
        [plist setValue:ns forKey:@"night_string"];
        [self.colorScheme setNight_string:ns];
    }
    
    //keyword
    if (dk == nil)
        [plist setValue:self.colorScheme.day_keyword forKey:@"day_keyword"];
    else
    {
        [plist setValue:dk forKey:@"day_keyword"];
        [self.colorScheme setDay_keyword:dk];
    }
    
    if (nk == nil)
        [plist setValue:self.colorScheme.night_keyword forKey:@"night_keyword"];
    else
    {
        [plist setValue:nk forKey:@"night_keyword"];
        [self.colorScheme setNight_keyword:nk];
    }
    
    [plist writeToFile:customizedColor atomically:YES];
    [self generateCSSScheme];
}

-(BOOL) isDayTypeDisplayMode
{
    return [self.colorScheme dayType];
}

-(NSString*) getDisplayBackgroundColor
{
    if ([self isDayTypeDisplayMode])
        return self.colorScheme.day_backgroundColor;
    return self.colorScheme.night_backgroundColor;
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
    [self setSplitViewController:nil];
    [self setMasterViewController:nil];
    [self.resultFileList removeAllObjects];
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
    else if ([extension isEqualToString:@"display_1"])
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
                    [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Maximum number of source files exceeded for Lite Version., Failed to analyze"];
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
    if ([self isDocType:path])
    {
        return path;
    }
    
    displayPath = [path stringByDeletingPathExtension];
    displayPath = [displayPath stringByAppendingFormat:@"_%@",[path pathExtension]];
    displayPath = [displayPath stringByAppendingPathExtension:@"display_1"];
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
        if ([self isSupportedType:path] == YES)
            [parser setParserType:CPLUSPLUS];
        else if ([self isImageType:path] == YES)
            [parser setParserType:IMAGE];
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
        if ([self isDocType:path])
        {
            return nil;
        }
        NSStringEncoding encoding = NSUTF8StringEncoding;
        html = [NSString stringWithContentsOfFile: displayPath usedEncoding:&encoding error: &error];
        //html = [self HloveyRC4:rc4Result key:@"lgz"];
    }
    return html;
}

-(void) showPurchaseAlert
{
    alertConfirmMode = ALERT_PURCHASE;
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:[NSString stringWithFormat:@"It can only support 5 source files in one Project for Lite Version, Do you want to get Unlimited Full version?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Purchase", nil];
    [confirmAlert show];
}

@end
