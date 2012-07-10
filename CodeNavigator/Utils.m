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

#ifdef LITE_VERSION
#import "GADBannerView.h"
#endif

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
@synthesize cscopeSearchThread;
@synthesize analyzePath;
@synthesize resultFileList = _resultFileList;
@synthesize searchKeyword = _searchKeyword;
@synthesize storedAnalyzePath;
@synthesize splitViewController;
@synthesize colorScheme;
@synthesize cscopeSearchAlertView;
@synthesize dropBoxViewController;
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
    NSError* error;
    BOOL isExist = false;
    BOOL isFolder = NO;
    NSString* versionFile = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/1_7.version"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:versionFile];
    if (isExist == YES)
    {
        return;
    }
    // add version file
    [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"] withIntermediateDirectories:YES attributes:nil error:&error];
    NSString* tmp = @"";
    [tmp writeToFile:versionFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    // delete lgz_software.js and theme.css
    NSString* js = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.settings/lgz_javascript.js"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:js isDirectory:&isFolder];
    if (isExist == YES)
    {
        [[NSFileManager defaultManager] removeItemAtPath:js error:&error];
    }
    
    NSString* css = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.settings/theme.css"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:css isDirectory:&isFolder];
    if (isExist == YES)
    {
        [[NSFileManager defaultManager] removeItemAtPath:css error:&error];
    }
    
    //for version 1_3 we need to delete all project files
    NSString* projectsFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:projectsFolder error:&error];
    for (int i=0; i<[contents count]; i++)
    {
        NSString *projPath = [projectsFolder stringByAppendingPathComponent:[contents objectAtIndex:i]];
        [[NSFileManager defaultManager] fileExistsAtPath:projPath isDirectory:&isFolder];
        if (YES == isFolder)
        {
            NSString* db = [projPath stringByAppendingPathComponent:@"project.lgz_db"];
            [[NSFileManager defaultManager] removeItemAtPath:db error:&error];
            NSString* fl = [projPath stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
            [[NSFileManager defaultManager] removeItemAtPath:fl error:&error];
            fl = [projPath stringByAppendingPathComponent:@"search_files.lgz_proj_files"];
            [[NSFileManager defaultManager] removeItemAtPath:fl error:&error];
        }
    }
    
    {
        NSString* projectFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
        BOOL isFolder = NO;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:projectFolder isDirectory:&isFolder];
        NSError *error;
        if (isExist == NO || (isExist == YES && isFolder == NO))
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:projectFolder withIntermediateDirectories:YES attributes:nil error:&error];
        }
    
        // copy demo
        NSString* demoFolder = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Projects/linux_0.1/"];
        isExist = [[NSFileManager defaultManager] fileExistsAtPath:demoFolder isDirectory:&isFolder];
        NSString* demoBundle = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/linux_0.1"];
        if (isExist == NO || (isExist == YES && isFolder == NO))
        {
            [[NSFileManager defaultManager] copyItemAtPath:demoBundle toPath:demoFolder error:&error];
        }
        
        // copy help files
        NSString* settings = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/"];
        NSString* helpHtml = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/Help.html"];
        [[NSFileManager defaultManager] copyItemAtPath:helpHtml toPath:[projectFolder stringByAppendingPathComponent:@"Help.html"] error:&error];
        NSString* jpg0 = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/1.jpeg"];
        [[NSFileManager defaultManager] copyItemAtPath:jpg0 toPath:[settings stringByAppendingPathComponent:@"1.jpeg"] error:&error];
        NSString* jpg1 = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/2.jpeg"];
        [[NSFileManager defaultManager] copyItemAtPath:jpg1 toPath:[settings stringByAppendingPathComponent:@"2.jpeg"] error:&error];
        NSString* jpg2 = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/3.jpeg"];
        [[NSFileManager defaultManager] copyItemAtPath:jpg2 toPath:[settings stringByAppendingPathComponent:@"3.jpeg"] error:&error];
        NSString* jpg3 = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/4.jpeg"];
        [[NSFileManager defaultManager] copyItemAtPath:jpg3 toPath:[settings stringByAppendingPathComponent:@"4.jpeg"] error:&error];
        NSString* jpg4 = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/5.jpeg"];
        [[NSFileManager defaultManager] copyItemAtPath:jpg4 toPath:[settings stringByAppendingPathComponent:@"5.jpeg"] error:&error];
    }
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
        [[NSFileManager defaultManager] copyItemAtPath:defaultColor toPath:customizedColor error:&error];

        cssVersion = 1;
    }
    
    //for javascript
    NSString* js = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/lgz_javascript.js"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:js isDirectory:&isFolder];
    NSString* jsPath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingPathComponent:@"lgz_javascript.js"];
    if (isExist == NO || (isExist == YES && isFolder == YES))
    {
        [[NSFileManager defaultManager] copyItemAtPath:jsPath toPath:js error:&error];
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
    [self changeUIViewStyle:self.detailViewController.view];
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
        tmp = [tmp stringByAppendingFormat:@"_.%@", DISPLAY_FILE_EXTENTION];
    }
    else
    {
        tmp = [tmp stringByDeletingPathExtension];
        tmp = [tmp stringByAppendingFormat:@"_%@.%@", extention, DISPLAY_FILE_EXTENTION];
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

-(void) showAnalyzeInfoPopOver:(BOOL)show
{
    if (show == YES)
    {
        if (self.analyzeInfoPopover == nil)
        {
#ifndef IPHONE_VERSION
            self.analyzeInfoController = [[AnalyzeInfoController alloc] init];
            self.analyzeInfoPopover = [[UIPopoverController alloc] initWithContentViewController:self.analyzeInfoController];
            self.analyzeInfoPopover.popoverContentSize = CGSizeMake(320, 130);
#endif
        }
        if (self.analyzeInfoPopover.popoverVisible == NO)
        {
            MasterViewController* _masterViewController = nil;
            NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
            _masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
            [_masterViewController.webServicePopOverController dismissPopoverAnimated:YES];
            
            [self.analyzeInfoPopover presentPopoverFromBarButtonItem:self.detailViewController.analyzeInfoBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else
    {
#ifndef IPHONE_VERSION
        [self.analyzeInfoPopover dismissPopoverAnimated:YES];
#endif
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
            [self showAnalyzeInfoPopOver:YES];
            [[Utils getInstance].detailViewController.analyzeInfoBarButton setEnabled:YES];
        });
        [[Utils getInstance] createFileList:projectFolder andWriteTo:db_content andSearchDelta:search_delta_content];
        [search_delta_content insertString:db_content atIndex:0];
        [search_delta_content writeToFile:searchDeltaFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (db_content == nil || [db_content length] == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                {
                    [self.analyzeInfoController finishAnalyze];
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
                [self.analyzeInfoController finishAnalyze];
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
        if (searchType == 2 || searchType == 1)
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
            if (searchType != 2)
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

-(void) cscopeSearch:(NSString *)keyword andPath:(NSString *)sourcePath andProject:(NSString *)project andType:(int)type andFromVir:(BOOL)fromVir
{
    if (fromVir == NO)
    {
        // Because result has been changed and not from Virtualization
        // So reset to NO
        [[Utils getInstance].detailViewController.virtualizeViewController setIsNeedGetResultFromCscope:NO];
    }
    
    if ([Utils getInstance].analyzeThread.isExecuting == YES)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Project Analyzing is in progress, Please wait untile analyze finished"];
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
    
    self.cscopeSearchAlertView = [[UIAlertView alloc]   
                           initWithTitle:@"CodeNavigator\nSearch in progress"   
                           message:nil delegate:nil cancelButtonTitle:nil  
                           otherButtonTitles: nil];  
    
    [self.cscopeSearchAlertView show];  
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]  
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];  
    
    indicator.center = CGPointMake(self.cscopeSearchAlertView.bounds.size.width / 2,   
                                   self.cscopeSearchAlertView.bounds.size.height - 50);  
    [indicator startAnimating];  
    [self.cscopeSearchAlertView addSubview:indicator]; 
    
    cscope_set_base_dir([project UTF8String]);
    searchType = type;
    _searchKeyword = keyword;
    
    SearchThreadData* data = [[SearchThreadData alloc]init];
    [data setDbFile:dbFile];
    [data setFileList:fileList];
    [data setFromVir:fromVir];
    [data setSourcePath:sourcePath];

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
        
        // for other language other than c
//        if (fromVir == YES)
        {
            if ([result length] == 0) {
                switch (searchType) {
                    case 1:
                    case 3:
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
                    [self.detailViewController.resultViewController.tableView reloadData];
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
                    goto FINAL;
                }
                NSString* content = [((ResultFile*)[_resultFileList objectAtIndex:0]).contents objectAtIndex:0];
                NSArray* components = [content componentsSeparatedByString:@" "];
                if ([components count] < 3)
                    goto FINAL;
                NSString* line = [components objectAtIndex:1];
                NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
                filePath = [filePath stringByAppendingPathComponent:((ResultFile*)[_resultFileList objectAtIndex:0]).fileName];
                NSString *proj = [self getProjectFolder:filePath];
                if (searchType != 2 && searchType != 3)
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
                    if (searchType == 2)
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
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Low Memorry!"];
    }
FINAL:
    [[Utils getInstance].cscopeSearchAlertView dismissWithClickedButtonIndex:0 animated:YES];
    [[Utils getInstance] setCscopeSearchAlertView:nil];
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
//    if ([self isWebType:path])
//        return path;
    
    displayPath = [path stringByDeletingPathExtension];
    displayPath = [displayPath stringByAppendingFormat:@"_%@",[path pathExtension]];
    displayPath = [displayPath stringByAppendingPathExtension:DISPLAY_FILE_EXTENTION];
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
        @autoreleasepool {        
            Parser* parser = [[Parser alloc] init];
            if ([self isImageType:path] == YES)
                [parser setParserType:IMAGE];
            else
                [parser checkParseType:path];
            [parser setFile: path andProjectBase:projectPath];
            [parser startParse];
            html = [parser getHtml];
            //rc4Result = [self HloveyRC4:html key:@"lgz"];
            [html writeToFile:displayPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
    }
    else
    {
        if ([self isDocType:path])
        {
            return nil;
        }
//        if ([self isWebType:path])
//            return nil;
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

@end
