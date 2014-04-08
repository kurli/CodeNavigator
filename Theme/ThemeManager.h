//
//  ThemeManager.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/30/14.
//
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


//For UI style, color scheme
@interface ThemeSchema : NSObject {
}
@property (nonatomic, strong) NSString* theme;
@property (nonatomic, strong) NSString* background;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSString* header;
@property (nonatomic, strong) NSString* string;
@property (nonatomic, strong) NSString* keyword;
@property (nonatomic, strong) NSString* definition;
@property (nonatomic, strong) NSString* font_size;
@property (nonatomic, strong) NSString* other;
@property (nonatomic, strong) NSString* max_line_count;
@property (nonatomic, strong) NSString* font_family;
@property (nonatomic, strong) NSString* lineNumber;
@property (nonatomic, strong) NSString* number;
@property (nonatomic, strong) NSString* variable;
@property (nonatomic, strong) NSString* variable_2;
@property (nonatomic, strong) NSString* variable_3;
@property (nonatomic, strong) NSString* version;
@end

@interface ThemeManager : NSObject {
    // we need to change css version for each theme change
    // add version can do this    
}

+(void) initThemes;

+(NSString*) getDisplayBackgroundColor;

+(void) changeUIViewStyle:(UIView*)view;


// for background syntex color define
+(void) readColorScheme;

+(void) writeColorScheme:(BOOL)dayType andDayBackground:(NSString*)dayBG andNightBackground:(NSString*)nightBG andDayComment:(NSString*)dayC andNightComment:(NSString*)nightC andDayString:(NSString*)ds  andNightString:(NSString*)ns andDayKeyword:(NSString*)dk andNightKeyword:(NSString*)nk andFontSize:(NSString*)fs andLineWrapper:(NSString*)lw;

+(NSDictionary*) getThemeByName:(NSString*)name;

+(void) readColorSchemeByThemeName:(NSString*)name andScheme:(ThemeSchema*)colorScheme;

+(void) generateCSSScheme:(NSString*)css andTheme:(ThemeSchema*) theme;

+(void) updateThemeByName:(NSString*)name;

@end
