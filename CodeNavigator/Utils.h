//
//  Utils.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BannerViewController.h"
#import "MGSplitViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@class DetailViewController;
@class AnalyzeInfoController;
@class MasterViewController;

#define MAX_HISTORY_STACK 20

typedef enum _TableViewMode{
    TABLEVIEW_FILE,
    TABLEVIEW_CONTENT
} TableViewMode;

typedef enum _AlertConfirmMode{
    ALERT_ANALYZE,
    ALERT_PURCHASE,
    ALERT_NONE
} AlertConfirmMode;

//For Cscope analyze thread
@interface BuildThreadData : NSObject <UIAlertViewDelegate> {
    BOOL force;
}
@property (strong, nonatomic) NSString* path;

-(void)setForce: (BOOL)f;

-(BOOL)getForce;
@end

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
@end

@interface ResultFile : NSObject {
}
@property (strong, nonatomic) NSString* fileName;

@property (strong, nonatomic) NSMutableArray* contents;
@end

@interface Utils : NSObject
{
    //for result view controller table contrel
    TableViewMode resultTableviewMode;
    int resultCurrentFileIndex;
    BOOL storedForceAnalyze;
    BannerViewController *_bannerViewController;
    ADBannerView* _bannerView;
    AlertConfirmMode alertConfirmMode;
    int searchType;
    
    // we need to change css version for each theme change
    // add version can do this
    int cssVersion;
}

@property (nonatomic, unsafe_unretained) DetailViewController* detailViewController;

@property (nonatomic, unsafe_unretained) MGSplitViewController *splitViewController;

@property (nonatomic, unsafe_unretained) MasterViewController * masterViewController;

@property (nonatomic, strong) AnalyzeInfoController* analyzeInfoController;

@property (nonatomic, strong) UIPopoverController* analyzeInfoPopover;

@property (nonatomic, strong) NSThread* analyzeThread;

@property (nonatomic, strong) NSString* analyzePath;

@property (strong, nonatomic) NSMutableArray* resultFileList;

@property (strong, nonatomic) NSString* searchKeyword;

@property (strong, nonatomic) NSString* storedAnalyzePath;

@property (strong, nonatomic) ColorSchema* colorScheme;

+(Utils*)getInstance;

// for background syntex color define
-(void) readColorScheme;

-(void) writeColorScheme:(BOOL)dayType andDayBackground:(NSString*)dayBG andNightBackground:(NSString*)nightBG andDayComment:(NSString*)dayC andNightComment:(NSString*)nightC andDayString:(NSString*)ds  andNightString:(NSString*)ns andDayKeyword:(NSString*)dk andNightKeyword:(NSString*)nk andFontSize:(NSString*)fs;

-(void) generateCSSScheme;

-(void) changeUIViewStyle:(UIView*)view;

-(int) getCSSVersion;

-(BOOL) isDayTypeDisplayMode;

-(NSString*) getDisplayBackgroundColor;

-(void) initBanner:(UIViewController*)view;

-(ADBannerView*) getBannerView;

-(BannerViewController*) getBannerViewController;

-(void) showAnalyzeInfoPopOver:(BOOL) show;

-(NSString*) getProjectFolder:(NSString*)path;

-(void) alertWithTitle:(NSString*)title andMessage:message;

-(NSString*) getPathFromProject:(NSString*)path;

-(NSString*) getSourceFileByDisplayFile:(NSString*)displayFile;

-(NSString*) getDisplayFileBySourceFile:(NSString*)source;

-(void) deleteDisplayFileForSource:(NSString*)source;

-(void) analyzeProject:(NSString*)path andForceCreate:(BOOL)forceCreate;

-(void) analyzeProjectConfirmed:(NSString*)path andForceCreate:(BOOL)forceCreate;

-(void) createFileList:(NSString*)projPath andWriteTo:(NSMutableString*) cache;

-(BOOL) isSupportedType:(NSString*)file;

-(BOOL) isImageType:(NSString*)file;

-(BOOL) isDocType:(NSString*)file;

-(BOOL) isProjectDatabaseFile:(NSString *)file;

-(UIAlertView*) showActivityIndicator:(NSString*)mas andDelegate:(id)dgt;

-(void) analyzeThread:(id)data;

-(void) pauseAnalyze;

-(void) cscopeSearch:(NSString*)keyword andPath:(NSString*)path andProject:(NSString*)project andType:(int) type andFromVir:(BOOL)fromVir;

-(BOOL) setResultListAndAnalyze: (NSArray*) list andKeyword:keyword andSourcePath:(NSString*)sourcePath;

-(int) fileExistInResultFileList: (NSString*) file;

-(void) setResultViewTableViewMode:(TableViewMode) mode;

-(void) setResultViewFileIndex:(int)index;

-(TableViewMode) getResultViewTableViewMode;

-(int) getResultViewFileIndex;

-(NSString*)HloveyRC4:(NSString*)aInput key:(NSString*)aKey;

-(NSString*) getDisplayFile:(NSString*) sourcePath andProjectBase:(NSString*) projectPath;

-(NSString*) getDisplayPath:(NSString*) path;

-(void) showPurchaseAlert;

-(void) openPurchaseURL;

-(void) setSearchType:(int)type;

-(int) getSearchType;

@end
