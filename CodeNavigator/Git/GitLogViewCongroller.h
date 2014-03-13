//
//  GitLogViewCongroller.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/18/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTRepository;
@class GTObject;

@interface PendingData : NSObject {
}
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) GTObject* neObj;
@property (nonatomic, strong) GTObject* oldObj;
@end

@interface GitLogViewCongroller : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    int selected;
    BOOL isLogForProject;
}
@property (nonatomic, strong) GTRepository* repo;
@property (atomic, strong) NSArray* commitsArray;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *branchesBarButton;
@property (nonatomic, strong) NSMutableArray* diffFileArray;
@property (nonatomic, strong) NSString* compareContainsPath;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showMergesBarButton;
@property (nonatomic, strong) UIPopoverController* popOverController;
@property (nonatomic, strong) NSString* currentGitFolder;

- (IBAction)showMergesClicked:(id)sender;

-(void) gitLogForProject:(NSString*)project;

-(void) showModualView;

- (IBAction)backButtonClicked:(id)sender;

-(IBAction)detailButtonClicked:(id)sender;

- (IBAction)manageBranches:(id)sender;

-(void) update;
@end
