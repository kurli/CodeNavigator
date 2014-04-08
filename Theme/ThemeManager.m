//
//  ThemeManager.m
//  CodeNavigator
//
//  Created by Guozhen Li on 3/30/14.
//
//

#import "ThemeManager.h"
#import "Utils.h"
#import "HTMLConst.h"
#import "DetailViewController.h"

@implementation ThemeSchema

@synthesize theme;
@synthesize background;
@synthesize comment;
@synthesize definition;
@synthesize keyword;
@synthesize header;
@synthesize string;
@synthesize font_size;
@synthesize other;
@synthesize max_line_count;
@synthesize font_family;
@synthesize number;
@synthesize lineNumber;
@synthesize variable;
@synthesize variable_2;
@synthesize variable_3;
@synthesize version;

-(id)copy{
    ThemeSchema* other_obj = [[ThemeSchema alloc] init];
    other_obj.theme = [theme copy];
    other_obj.background = [background copy];
    other_obj.comment = [comment copy];
    other_obj.definition = [definition copy];
    other_obj.keyword = [keyword copy];
    other_obj.header = [header copy];
    other_obj.string = [string copy];
    other_obj.font_family = [font_family copy];
    other_obj.font_size = [font_size copy];
    other_obj.max_line_count = [max_line_count copy];
    other_obj.other = [other copy];
    other_obj.number = [number copy];
    other_obj.lineNumber = [lineNumber copy];
    other_obj.variable = [variable copy];
    other_obj.variable_2 = [variable_2 copy];
    other_obj.variable_3 = [variable_3 copy];
    other_obj.version = [version copy];
    return other_obj;
}

@end

@implementation ThemeManager

+(void) initThemes {
    NSString* themeRootPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.Themes"];
    NSString* themeBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Themes"];

    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:themeRootPath];
    if (isExist) {
        // Check version
        NSString* src = [themeBundlePath stringByAppendingPathComponent:@"theme.plist"];
        NSString* dest = [themeRootPath stringByAppendingPathComponent:@"theme.plist"];
        
        BOOL themeExist = [[NSFileManager defaultManager] fileExistsAtPath:dest];
        if (themeExist) {
            NSData* data = [[NSData alloc] initWithContentsOfFile:src];
            NSDictionary *documentDictionary = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
            int currentVersion = [[documentDictionary objectForKey:@"version"] intValue];
            
            data = [[NSData alloc] initWithContentsOfFile:dest];
            documentDictionary = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
            int bundleVersion = [[documentDictionary objectForKey:@"version"] intValue];
            if (bundleVersion == currentVersion) {
                return;
            }
        }
    }
    // Create theme path
    [[NSFileManager defaultManager] createDirectoryAtPath:themeRootPath withIntermediateDirectories:YES attributes:Nil error:nil];
    
    // Copy default theme
    NSString* src = [themeBundlePath stringByAppendingPathComponent:@"theme.plist"];
    NSString* dest = [themeRootPath stringByAppendingPathComponent:@"theme.plist"];
    [[NSFileManager defaultManager] copyItemAtPath:src toPath:dest error:nil];
}

+(NSString*) getDisplayBackgroundColor
{
    if ([Utils getInstance].currentThemeSetting == nil) {
        [ThemeManager readColorScheme];
    }
    return [Utils getInstance].currentThemeSetting.background;
}

+(void) changeUIViewStyle:(UIView *)view
{
    NSString*  bgcolor = [ThemeManager getDisplayBackgroundColor];
    if ([bgcolor length] != 7)
        return;
    bgcolor = [bgcolor substringFromIndex:1];
    unsigned int baseValue;
    if ([[NSScanner scannerWithString:bgcolor] scanHexInt:&baseValue])
    {
        [view setBackgroundColor:UIColorFromRGB(baseValue)];
    }
}

+(NSDictionary*) getThemeByName:(NSString*)name {
    NSString* themeBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Themes"];

    NSString* bundlePath = [themeBundlePath stringByAppendingPathComponent:name];
    bundlePath = [bundlePath stringByAppendingPathExtension:@"plist"];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:bundlePath];
    if (!isExist) {
        [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"ErrorCode = 4 \nPlease contact guangzhen@hotmail.com"];
        return nil;
    }
    NSData* data = [[NSData alloc] initWithContentsOfFile:bundlePath];

    NSDictionary* documentDictionary = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];

    return documentDictionary;
}

+(void) readColorSchemeByThemeName:(NSString*)name andScheme:(ThemeSchema*)colorScheme {
    NSDictionary* documentDictionary = [ThemeManager getThemeByName:name];
    
    // Read theme
    NSString* background = [documentDictionary objectForKey:@"background"];
    [colorScheme setBackground:background];
    
    NSString* comment = [documentDictionary objectForKey:@"comment"];
    [colorScheme setComment:comment];
    
    NSString* header = [documentDictionary objectForKey:@"header"];
    [colorScheme setHeader:header];
    
    NSString* string = [documentDictionary objectForKey:@"string"];
    [colorScheme setString:string];
    
    NSString* keyword = [documentDictionary objectForKey:@"keyword"];
    [colorScheme setKeyword:keyword];
    
    NSString* definition = [documentDictionary objectForKey:@"definition"];
    [colorScheme setDefinition:definition];
    
    NSString* other = [documentDictionary objectForKey:@"other"];
    [colorScheme setOther:other];
    
    NSString* number = [documentDictionary objectForKey:@"number"];
    [colorScheme setNumber:number];
    
    NSString* linenumber = [documentDictionary objectForKey:@"linenumber"];
    [colorScheme setLineNumber:linenumber];
    
    NSString* variable = [documentDictionary objectForKey:@"variable"];
    [colorScheme setVariable:variable];
    
    NSString* variable_2 = [documentDictionary objectForKey:@"variable_2"];
    [colorScheme setVariable_2:variable_2];
    
    NSString* variable_3 = [documentDictionary objectForKey:@"variable_3"];
    [colorScheme setVariable_3:variable_3];
}

+(void) readColorScheme
{
    BOOL isExist = false;

    [ThemeManager initThemes];
    NSString* themePath= [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.Themes/theme.plist"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:themePath];
    if (!isExist) {
        [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"ErrorCode = 2 \nPlease contact guangzhen@hotmail.com"];
        return;
    }
    
    ThemeSchema* colorScheme = [[ThemeSchema alloc] init];
    NSData* data = [[NSData alloc] initWithContentsOfFile:themePath];
    NSDictionary *documentDictionary = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    
    NSString* font_size = [documentDictionary objectForKey:@"font_size"];
    [colorScheme setFont_size:font_size];
    
    NSString* max_line_count = [documentDictionary objectForKey:@"max_line_count"];
    if (max_line_count == nil || [max_line_count length] == 0) {
#ifdef IPHONE_VERSION
        [colorScheme setMax_line_count:@"45"];
#else
        [colorScheme setMax_line_count:@"80"];
#endif
    }
    else {
        [colorScheme setMax_line_count:max_line_count];
    }
    
    NSString* font_family = [documentDictionary objectForKey:@"font_family"];
    [colorScheme setFont_family:font_family];
    
    NSString* version = [documentDictionary objectForKey:@"version"];
    [colorScheme setVersion: version];
    
    // Get theme file bundle name
    NSString* themeName = [documentDictionary objectForKey:@"theme"];
    NSString* themeBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Themes"];
    NSString* bundlePath = [themeBundlePath stringByAppendingPathComponent:themeName];
    bundlePath = [bundlePath stringByAppendingPathExtension:@"plist"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:bundlePath];
    if (!isExist) {
        [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"ErrorCode = 3 \nPlease contact guangzhen@hotmail.com"];
        return;
    }
    [colorScheme setTheme:themeName];

    [ThemeManager readColorSchemeByThemeName:themeName andScheme:colorScheme];
    
    [[Utils getInstance] setCurrentThemeSetting:colorScheme];

//    [ThemeManager generateCSSScheme];
}

+(void) generateCSSScheme:(NSString*)css andTheme:(ThemeSchema*) colorScheme;
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:css error:&error];
    
    NSString* cssStr = HTML_STYLE;
    
    if (colorScheme == nil) {
        [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"ErrorCode = 4 \nPlease contact guangzhen@hotmail.com"];
        return;
    }
    //Background
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"-BGCOL-" withString:colorScheme.background];
    
    //comment
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"COMENT" withString:colorScheme.comment];
    
    //header
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"HEADER" withString:colorScheme.header];

    //string
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"STRING" withString:colorScheme.string];
        
    //keyword
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"KEYWRD" withString:colorScheme.keyword];
        
    //definition
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"DEFINE" withString:colorScheme.definition];
        
    //other
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"-OTHER-" withString:colorScheme.other];
    
    //font size
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"FONT_SIZE" withString:colorScheme.font_size];
    
    //font family
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"FONT_FAMILY" withString:colorScheme.font_family];
    
    //number
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"--NUMBER--" withString:colorScheme.number];
    
    //linenumber
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"--LINENUMBER--" withString:colorScheme.lineNumber];

    [cssStr writeToFile:css atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [ThemeManager changeUIViewStyle:[Utils getInstance].detailViewController.webView];
    [ThemeManager changeUIViewStyle:[Utils getInstance].detailViewController.secondWebView];
    [ThemeManager changeUIViewStyle:[Utils getInstance].detailViewController.view];
}

+(void) updateThemeByName:(NSString*)name {
    NSString* themePath= [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.Themes/theme.plist"];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:themePath];
    if (!isExist) {
        [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"ErrorCode = 2-1 \nPlease contact guangzhen@hotmail.com"];
        return;
    }
    
    
    ThemeSchema* colorScheme = [Utils getInstance].currentThemeSetting;
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] init];
    [plist setValue:colorScheme.font_family forKey:@"font_family"];
    [plist setValue:colorScheme.version forKey:@"version"];
    [plist setValue:colorScheme.font_size forKey:@"font_size"];
    [plist setValue:colorScheme.max_line_count forKey:@"max_line_count"];
    [plist setValue:name forKey:@"theme"];
    [plist writeToFile:themePath atomically:YES];
}

+(void)writeColorScheme:(BOOL)dayType andDayBackground:(NSString *)dayBG andNightBackground:(NSString *)nightBG andDayComment:(NSString *)dayC andNightComment:(NSString *)nightC andDayString:(NSString *)ds andNightString:(NSString*)ns andDayKeyword:(NSString *)dk andNightKeyword:(NSString *)nk andFontSize:(NSString *)fs andLineWrapper:(NSString *)lw
{
    /*
    NSString* customizedColor = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/syntax_color.plist"];
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] init];
    
    [plist setValue:[NSNumber numberWithBool:dayType] forKey:@"day_type"];
    ColorSchema* colorScheme = [Utils getInstance].currentColorScheme;
    colorScheme.dayType = dayType;
    
    [plist setValue:colorScheme.day_header forKey:@"day_header"];
    [plist setValue:colorScheme.night_header forKey:@"night_header"];
    
    [plist setValue:colorScheme.day_definition forKey:@"day_definition"];
    [plist setValue:colorScheme.night_definition forKey:@"night_definition"];
    
    [plist setValue:colorScheme.day_other forKey:@"day_other"];
    [plist setValue:colorScheme.night_other forKey:@"night_other"];
    
    //font size
    if (fs == nil)
        [plist setValue:colorScheme.font_size forKey:@"font_size"];
    else
    {
        [plist setValue:fs forKey:@"font_size"];
        [colorScheme setFont_size:fs];
    }
    
    //background
    if (dayBG == nil)
        [plist setValue:colorScheme.day_backgroundColor forKey:@"day_background"];
    else
    {
        [plist setValue:dayBG forKey:@"day_background"];
        [colorScheme setDay_backgroundColor:dayBG];
    }
    
    if (nightBG == nil)
        [plist setValue:colorScheme.night_backgroundColor forKey:@"night_background"];
    else
    {
        [plist setValue:nightBG forKey:@"night_background"];
        [colorScheme setNight_backgroundColor:nightBG];
    }
    
    //comment
    if (dayC == nil)
        [plist setValue:colorScheme.day_comment forKey:@"day_comment"];
    else
    {
        [plist setValue:dayC forKey:@"day_comment"];
        [colorScheme setDay_comment:dayC];
    }
    
    if (nightC == nil)
        [plist setValue:colorScheme.night_comment forKey:@"night_comment"];
    else
    {
        [plist setValue:nightC forKey:@"night_comment"];
        [colorScheme setNight_comment:nightC];
    }
    
    //string
    if (ds == nil)
        [plist setValue:colorScheme.day_string forKey:@"day_string"];
    else
    {
        [plist setValue:ds forKey:@"day_string"];
        [colorScheme setDay_string:ds];
    }
    
    if (ns == nil)
        [plist setValue:colorScheme.night_string forKey:@"night_string"];
    else
    {
        [plist setValue:ns forKey:@"night_string"];
        [colorScheme setNight_string:ns];
    }
    
    //keyword
    if (dk == nil)
        [plist setValue:colorScheme.day_keyword forKey:@"day_keyword"];
    else
    {
        [plist setValue:dk forKey:@"day_keyword"];
        [colorScheme setDay_keyword:dk];
    }
    
    if (nk == nil)
        [plist setValue:colorScheme.night_keyword forKey:@"night_keyword"];
    else
    {
        [plist setValue:nk forKey:@"night_keyword"];
        [colorScheme setNight_keyword:nk];
    }
    
    if (lw == nil) {
        [plist setValue:colorScheme.max_line_count forKey:@"max_line_count"];
    }
    else {
        [plist setValue:lw forKey:@"max_line_count"];
        [colorScheme setMax_line_count:lw];
    }
    
    [plist writeToFile:customizedColor atomically:YES];
    [ThemeManager generateCSSScheme];
     */
}

@end
