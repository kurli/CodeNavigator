//
//  DisplayController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 2/26/14.
//
//

#import <Foundation/Foundation.h>

#define DISPLAY_FILE_EXTENTION @"display_5"
#define DISPLAY_FOLDER_PATH @"._DisplayCache_"

typedef void (^ParseFileFinishedCallback)(NSString* html);

@interface DisplayController : NSObject

-(NSString*) getSourceFileByDisplayFile:(NSString *)displayFile;

-(NSString*) getDisplayFileBySourceFile:(NSString *)source;

-(void)deleteDisplayFileForSource:(NSString *)source;

-(NSString*) getDisplayPath:(NSString*) path;

-(void) getDisplayFile:(NSString*) path andProjectBase:(NSString*)projectPath andFinishBlock:(ParseFileFinishedCallback)finishCallback;

-(void) removeDisplayFilesForProject:(NSString *)proj;

-(void) removeAllDisplayFiles;

@end
