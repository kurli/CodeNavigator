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


@interface DisplayController : NSObject

-(NSString*) getSourceFileByDisplayFile:(NSString *)displayFile;

-(NSString*) getDisplayFileBySourceFile:(NSString *)source;

-(void)deleteDisplayFileForSource:(NSString *)source;

-(NSString*) getDisplayPath:(NSString*) path;

-(NSString*) getDisplayFile:(NSString*) path andProjectBase:(NSString*)projectPath;

-(void) removeDisplayFilesForProject:(NSString *)proj;

@end
