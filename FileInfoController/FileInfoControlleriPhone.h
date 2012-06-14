//
//  FileInfoControlleriPhone.h
//  CodeNavigator
//
//  Created by Guozhen Li on 6/14/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FILEINFO_WEB,
    FILEINFO_SOURCE,
    FILEINFO_OTHER
} FileInfoType;

@class MasterViewController;

@interface FileInfoControlleriPhone : NSObject <UIActionSheetDelegate>
{
    FileInfoType fileInfoType;
}

@property (strong, nonatomic) NSString* sourceFilePath;

@property (nonatomic, unsafe_unretained) MasterViewController* masterViewController;

-(void) setSourceFile:(NSString*)path;

@end
