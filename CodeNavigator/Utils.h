//
//  Utils.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DetailViewController;
@class AnalyzeInfoController;

#define MAX_HISTORY_STACK 20

typedef enum _TableViewMode{
    TABLEVIEW_FILE,
    TABLEVIEW_CONTENT
} TableViewMode;

@interface BuildThreadData : NSObject {
    BOOL force;
}
@property (retain, nonatomic) NSString* path;

-(void)setForce: (BOOL)f;

-(BOOL)getForce;
@end

@interface ResultFile : NSObject {
}
@property (retain, nonatomic) NSString* fileName;

@property (retain, nonatomic) NSMutableArray* contents;
@end

@interface Utils : NSObject
{
    //for result view controller table contrel
    TableViewMode resultTableviewMode;
    int resultCurrentFileIndex;
}

@property (nonatomic, strong) DetailViewController* detailViewController;

@property (nonatomic, strong) AnalyzeInfoController* analyzeInfoController;

@property (nonatomic, strong) UIPopoverController* analyzeInfoPopover;

@property (nonatomic, strong) NSThread* analyzeThread;

@property (nonatomic, strong) NSString* analyzePath;

@property (retain, nonatomic) NSMutableArray* resultFileList;

@property (retain, nonatomic) NSString* searchKeyword;

+(Utils*)getInstance;

-(void) showAnalyzeInfoPopOver:(BOOL) show;

-(NSString*) getProjectFolder:(NSString*)path;

-(void) alertWithTitle:(NSString*)title andMessage:message;

-(NSString*) getPathFromProject:(NSString*)path;

-(NSString*) getSourceFileByDisplayFile:(NSString*)displayFile;

-(NSString*) getDisplayFileBySourceFile:(NSString*)source;

-(void) deleteDisplayFileForSource:(NSString*)source;

-(void) analyzeProject:(NSString*)path andForceCreate:(BOOL)forceCreate;

-(void) createFileList:(NSString*)projPath andWriteTo:(NSMutableString*) cache;

-(BOOL) isSupportedType:(NSString*)file;

-(BOOL) isProjectDatabaseFile:(NSString *)file;

-(UIAlertView*) showActivityIndicator:(NSString*)mas andDelegate:(id)dgt;

-(void) analyzeThread:(id)data;

-(void) pauseAnalyze;

-(void) cscopeSearch:(NSString*)keyword andPath:(NSString*)path andType:(int) type;

-(BOOL) setResultListAndAnalyze: (NSArray*) list andKeyword:keyword;

-(int) fileExistInResultFileList: (NSString*) file;

-(void) setResultViewTableViewMode:(TableViewMode) mode;

-(void) setResultViewFileIndex:(int)index;

-(TableViewMode) getResultViewTableViewMode;

-(int) getResultViewFileIndex;

-(NSString*)HloveyRC4:(NSString*)aInput key:(NSString*)aKey;

-(NSString*) getDisplayFile:(NSString*) path andProjectBase:(NSString*) projectPath;

-(NSString*) getDisplayPath:(NSString*) path;

@end
