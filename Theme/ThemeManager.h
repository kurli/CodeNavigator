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
@interface ColorSchema : NSObject {
}
@property (nonatomic, assign) BOOL dayType;
@property (nonatomic, strong) NSString* day_backgroundColor;
@property (nonatomic, strong) NSString* night_backgroundColor;
@property (nonatomic, strong) NSString* day_comment;
@property (nonatomic, strong) NSString* night_comment;
@property (nonatomic, strong) NSString* day_header;
@property (nonatomic, strong) NSString* night_header;
@property (nonatomic, strong) NSString* day_string;
@property (nonatomic, strong) NSString* night_string;
@property (nonatomic, strong) NSString* day_keyword;
@property (nonatomic, strong) NSString* night_keyword;
@property (nonatomic, strong) NSString* day_definition;
@property (nonatomic, strong) NSString* night_definition;
@property (nonatomic, strong) NSString* font_size;
@property (nonatomic, strong) NSString* day_other;
@property (nonatomic, strong) NSString* night_other;
@property (nonatomic, strong) NSString* max_line_count;
@end

@interface ThemeManager : NSObject {
    // we need to change css version for each theme change
    // add version can do this    
}

+(NSString*) getDisplayBackgroundColor;

+(BOOL) isDayTypeDisplayMode;

+(void) changeUIViewStyle:(UIView*)view;


// for background syntex color define
+(void) readColorScheme;

+(void) writeColorScheme:(BOOL)dayType andDayBackground:(NSString*)dayBG andNightBackground:(NSString*)nightBG andDayComment:(NSString*)dayC andNightComment:(NSString*)nightC andDayString:(NSString*)ds  andNightString:(NSString*)ns andDayKeyword:(NSString*)dk andNightKeyword:(NSString*)nk andFontSize:(NSString*)fs andLineWrapper:(NSString*)lw;

+(void) generateCSSScheme;

@end
