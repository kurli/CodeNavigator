//
//  CommentManager.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/13/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _CommentManagerMode{
    COMMENT_MANAGER_GROUP,
    COMMENT_MANAGER_FILE,
    COMMENT_MANAGER_COMMENTS
} CommentManagerMode;

@class MasterViewController;
@class CommentWrapper;

@interface CommentManager : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    CommentManagerMode currentMode;
}

@property (nonatomic, strong) MasterViewController* masterViewController;
@property (nonatomic, strong) NSMutableArray* fileArray;
@property (nonatomic, strong) NSMutableArray* commentsArray;
@property (nonatomic, strong) NSMutableArray* groupsArray;
@property (nonatomic, strong) CommentManager* commentManager;
@property (nonatomic, strong) NSString* currentGroup;
@property (nonatomic, strong) NSString* currentFile;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

- (void) initWithMasterViewController:(MasterViewController*)controller;
- (void) setCurrentModeComments;
- (void) initWithCommentFile:(NSString*)path;

+ (NSArray*)parseGroups:(NSString*)groupsStr;

#ifdef IPHONE_VERSION
- (IBAction)doneButtonClicked:(id)sender;
#endif
@end
