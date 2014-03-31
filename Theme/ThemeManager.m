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
@synthesize max_line_count;

@end

@implementation ThemeManager


+(BOOL) isDayTypeDisplayMode
{
    return [[Utils getInstance].currentColorScheme dayType];
}

+(NSString*) getDisplayBackgroundColor
{
    if ([ThemeManager isDayTypeDisplayMode])
        return [Utils getInstance].currentColorScheme.day_backgroundColor;
    return [Utils getInstance].currentColorScheme.night_backgroundColor;
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

+(void) readColorScheme
{
    BOOL isFolder = false;
    BOOL isExist = false;
    NSError *error;
    //for color scheme
    NSString* customizedColor = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/syntax_color.plist"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:customizedColor isDirectory:&isFolder];
#ifndef IPHONE_VERSION
    NSString* defaultColor = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/syntax_color.plist"];
#else
    NSString* defaultColor = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/syntax_color_iphone.plist"];
#endif
    if (isExist == NO || (isExist == YES && isFolder == YES))
    {
        [[NSFileManager defaultManager] copyItemAtPath:defaultColor toPath:customizedColor error:&error];
        
//        cssVersion = 1;
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
    
    ColorSchema* colorScheme = [Utils getInstance].currentColorScheme;
    
    if (colorScheme == nil)
    {
        colorScheme = [[ColorSchema alloc] init];
        [[Utils getInstance] setCurrentColorScheme:colorScheme];
    }
    BOOL dayType = [[documentDictionary objectForKey:@"day_type"] boolValue];
    [colorScheme setDayType:dayType];
    NSString* daybg = [documentDictionary objectForKey:@"day_background"];
    [colorScheme setDay_backgroundColor:daybg];
    NSString* nightbg = [documentDictionary objectForKey:@"night_background"];
    [colorScheme setNight_backgroundColor:nightbg];
    
    NSString* day_comment = [documentDictionary objectForKey:@"day_comment"];
    [colorScheme setDay_comment:day_comment];
    NSString* night_comment = [documentDictionary objectForKey:@"night_comment"];
    [colorScheme setNight_comment:night_comment];
    
    NSString* day_header = [documentDictionary objectForKey:@"day_header"];
    [colorScheme setDay_header:day_header];
    NSString* night_header = [documentDictionary objectForKey:@"night_header"];
    [colorScheme setNight_header:night_header];
    
    NSString* day_string = [documentDictionary objectForKey:@"day_string"];
    [colorScheme setDay_string:day_string];
    NSString* night_string = [documentDictionary objectForKey:@"night_string"];
    [colorScheme setNight_string:night_string];
    
    NSString* day_keyword = [documentDictionary objectForKey:@"day_keyword"];
    [colorScheme setDay_keyword:day_keyword];
    NSString* night_keyword = [documentDictionary objectForKey:@"night_keyword"];
    [colorScheme setNight_keyword:night_keyword];
    
    NSString* day_definition = [documentDictionary objectForKey:@"day_definition"];
    [colorScheme setDay_definition:day_definition];
    NSString* night_definition = [documentDictionary objectForKey:@"night_definition"];
    [colorScheme setNight_definition:night_definition];
    
    NSString* font_size = [documentDictionary objectForKey:@"font_size"];
    [colorScheme setFont_size:font_size];
    
    NSString* day_other = [documentDictionary objectForKey:@"day_other"];
    [colorScheme setDay_other:day_other];
    NSString* night_other = [documentDictionary objectForKey:@"night_other"];
    [colorScheme setNight_other:night_other];
    
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
    
    [ThemeManager generateCSSScheme];
}

+(void) generateCSSScheme
{
    NSError *error;
    NSString* css = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/theme.css"];
    [[NSFileManager defaultManager] removeItemAtPath:css error:&error];
    
    NSString* cssStr = HTML_STYLE;
    ColorSchema* colorScheme = [Utils getInstance].currentColorScheme;
    
    //Background
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"-BGCOL-" withString:[ThemeManager getDisplayBackgroundColor]];
    
    if ([ThemeManager isDayTypeDisplayMode])
    {
        //comment
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"COMENT" withString:colorScheme.day_comment];
        
        //header
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"HEADER" withString:colorScheme.day_header];
        
        //string
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"STRING" withString:colorScheme.day_string];
        
        //keyword
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"KEYWRD" withString:colorScheme.day_keyword];
        
        //definition
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"DEFINE" withString:colorScheme.day_definition];
        
        //other
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"-OTHER-" withString:colorScheme.day_other];
    }
    else
    {
        //comment
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"COMENT" withString:colorScheme.night_comment];
        
        //header
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"HEADER" withString:colorScheme.night_header];
        
        //string
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"STRING" withString:colorScheme.night_string];
        
        //keyword
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"KEYWRD" withString:colorScheme.night_keyword];
        
        //definition
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"DEFINE" withString:colorScheme.night_definition];
        
        //other
        cssStr = [cssStr stringByReplacingOccurrencesOfString:@"-OTHER-" withString:colorScheme.night_other];
    }
    cssStr = [cssStr stringByReplacingOccurrencesOfString:@"FONT_SIZE" withString:colorScheme.font_size];
    [cssStr writeToFile:css atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [ThemeManager changeUIViewStyle:[Utils getInstance].detailViewController.webView];
    [ThemeManager changeUIViewStyle:[Utils getInstance].detailViewController.secondWebView];
    [ThemeManager changeUIViewStyle:[Utils getInstance].detailViewController.view];
//    cssVersion++;
    [[Utils getInstance] incressCSSVersion];
}

-(void)writeColorScheme:(BOOL)dayType andDayBackground:(NSString *)dayBG andNightBackground:(NSString *)nightBG andDayComment:(NSString *)dayC andNightComment:(NSString *)nightC andDayString:(NSString *)ds andNightString:(NSString*)ns andDayKeyword:(NSString *)dk andNightKeyword:(NSString *)nk andFontSize:(NSString *)fs andLineWrapper:(NSString *)lw
{
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
}

@end
