//
//  CommentManager.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/13/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _CommentManagerMode{
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
@property (nonatomic, strong) NSArray* fileArray;
@property (nonatomic, strong) CommentManager* commentManager;
@property (nonatomic, strong) CommentWrapper* commentWrapper;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

- (void) initWithMasterViewController:(MasterViewController*)controller;
- (void) setCurrentModeComments;
- (void) initWithCommentFile:(NSString*)path;

#ifdef IPHONE_VERSION
- (IBAction)doneButtonClicked:(id)sender;
#endif
@end
