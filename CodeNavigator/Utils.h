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

@interface BuildThreadData : NSObject {
    BOOL force;
}
@property (retain, nonatomic) NSString* path;

-(void)setForce: (BOOL)f;

-(BOOL)getForce;
@end



@interface Utils : NSObject
{
}

@property (nonatomic, strong) DetailViewController* detailViewController;

@property (nonatomic, strong) AnalyzeInfoController* analyzeInfoController;

@property (nonatomic, strong) UIPopoverController* analyzeInfoPopover;

@property (nonatomic, strong) NSThread* analyzeThread;

@property (nonatomic, strong) NSString* analyzePath;

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

@end
