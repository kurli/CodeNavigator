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
#import "ThemeManager.h"
#import "DisplayController.h"
#import "DBManager.h"

#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

typedef void (^GetFunctionListCallback)(NSArray* array);

@class DetailViewController;
@class DropBoxViewController;
@class GADBannerView;
@class FunctionListManager;
@class DisplayController;
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

typedef enum _SearchType{
    FIND_GLOBAL_DEFINITION,
    FIND_THIS_SYMBOL,
    FIND_CALLED_FUNCTIONS,
    FIND_F_CALL_THIS_F,
    FIND_TEXT_STRING,
} SearchType;

//For Cscope analyze thread
@interface BuildThreadData : NSObject <UIAlertViewDelegate> {
    BOOL force;
}
@property (strong, nonatomic) NSString* path;

-(void)setForce: (BOOL)f;

-(BOOL)getForce;
@end

@interface SearchThreadData : NSObject <UIAlertViewDelegate> {
    
}
@property (strong, nonatomic) NSString* sourcePath;
@property (unsafe_unretained, nonatomic) BOOL fromVir;
@property (strong, nonatomic) NSString* dbFile;
@property (strong, nonatomic) NSString* fileList;
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
    NSInteger resultCurrentFileIndex;
    BOOL storedForceAnalyze;
    BannerViewController *_bannerViewController;
    ADBannerView* _iAdView;
    GADBannerView* _adModView;
    AlertConfirmMode alertConfirmMode;
    SearchType searchType;
    DisplayController* displayController;

    // we need to change css version for each theme change
    // add version can do this
    int cssVersion;

    BOOL is_adMobON;
    
    BOOL isScreenLocked;
}

@property (nonatomic, unsafe_unretained) DetailViewController* detailViewController;

@property (nonatomic, unsafe_unretained) MGSplitViewController *splitViewController;

@property (strong, nonatomic) ThemeSchema* currentThemeSetting;

@property (nonatomic, unsafe_unretained) MasterViewController* masterViewController;

@property (nonatomic, strong) NSThread* analyzeThread;

@property (nonatomic, strong) NSThread* cscopeSearchThread;

@property (nonatomic, strong) NSString* analyzePath;

@property (strong, nonatomic) NSMutableArray* resultFileList;

@property (strong, nonatomic) NSString* searchKeyword;

@property (strong, nonatomic) NSString* storedAnalyzePath;

@property (strong, nonatomic) DropBoxViewController* dropBoxViewController;
@property (strong, nonatomic) FunctionListManager* functionListManager;

@property (strong, nonatomic) NSString* gitUsername;

@property (strong, nonatomic) NSString* gitPassword;

@property (strong, nonatomic) UIActivityIndicatorView* cscopeIndicator;

@property (strong, nonatomic) DBManager* dbManager;

+(Utils*)getInstance;

-(BOOL) isAdModOn;

-(void) initVersion;

-(int) getCSSVersion;

-(void) incressCSSVersion;

-(void) initBanner:(UIViewController*)view;

-(ADBannerView*) getIAdBannerView;

-(GADBannerView*) getAdModBannerView;

-(BannerViewController*) getBannerViewController;

-(void) showAnalyzeIndicator:(BOOL) show;

-(NSString*) getProjectFolder:(NSString*)path;

-(void) alertWithTitle:(NSString*)title andMessage:message;

-(NSString*) getPathFromProject:(NSString*)path;

-(NSString*) getSourceFileByDisplayFile:(NSString*)displayFile;

-(NSString*) getDisplayFileBySourceFile:(NSString*)source;

-(NSString*) getTagFileBySourceFile:(NSString*)sourcd;

-(void) deleteDisplayFileForSource:(NSString*)source;

-(void) analyzeProject:(NSString*)path andForceCreate:(BOOL)forceCreate;

-(void) analyzeProjectConfirmed:(NSString*)path andForceCreate:(BOOL)forceCreate;

-(void) createFileList:(NSString*)projPath andWriteTo:(NSMutableString*) cache andSearchDelta:(NSMutableString*)delta;

-(BOOL) isSupportedType:(NSString*)file;

-(BOOL) isImageType:(NSString*)file;

-(BOOL) isDocType:(NSString*)file;

-(BOOL) isWebType:(NSString*)file;

-(BOOL) isProjectDatabaseFile:(NSString *)file;

-(UIAlertView*) showActivityIndicator:(NSString*)mas andDelegate:(id)dgt;

-(void) analyzeThread:(id)data;

-(void) cscopeSearchMethod:(id)data;

-(void) pauseAnalyze;

-(void) cscopeSearch:(NSString*)keyword andPath:(NSString*)path andProject:(NSString*)project andType:(NSInteger) type andFromVir:(BOOL)fromVir;

-(BOOL) setResultListAndAnalyze: (NSArray*) list andKeyword:keyword andSourcePath:(NSString*)sourcePath;

-(int) fileExistInResultFileList: (NSString*) file;

-(void) setResultViewTableViewMode:(TableViewMode) mode;

-(void) setResultViewFileIndex:(NSInteger)index;

-(TableViewMode) getResultViewTableViewMode;

-(NSInteger) getResultViewFileIndex;

+ (NSString*)HloveyRC4:(NSString*)aInput key:(NSString*)aKey;

-(void) getDisplayFile:(NSString*) sourcePath andProjectBase:(NSString*) projectPath andFinishBlock:(ParseFileFinishedCallback)callback;

-(NSString*) getDisplayPath:(NSString*) path;

-(void) showPurchaseAlert;

-(void) openPurchaseURL;

-(void) setSearchType:(int)type;

-(int) getSearchType;

-(NSString*) isPasswardSet;

-(BOOL) isScreenLocked;

-(void) setIsScreenLocked:(BOOL)locked;

-(void) getFunctionListForFile:(NSString*)path andCallback:(GetFunctionListCallback)callback;

-(NSString*) getGitFolder:(NSString*)path;

-(void) removeDisplayFilesForProject:(NSString*)proj;

-(void) addGAEvent:(NSString*) category andAction:(NSString*) action andLabel:(NSString*)label andValue:(NSNumber*)number;

-(NSString*) getFileContent:(NSString*)path;

@end
