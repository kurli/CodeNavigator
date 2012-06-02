//
//  FileInfoViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/25/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FILEINFO_WEB,
    FILEINFO_SOURCE,
    FILEINFO_OTHER
} FileInfoType;

@class MasterViewController;

@interface FileInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    FileInfoType fileInfoType;
}

@property (strong, nonatomic) NSMutableArray* selectionList;

@property (strong, nonatomic) NSString* sourceFilePath;

@property (nonatomic, unsafe_unretained) MasterViewController* masterViewController;

-(void) setSourceFile:(NSString*)path;

@end
