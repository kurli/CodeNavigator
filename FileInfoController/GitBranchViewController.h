//
//  GitBranchViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/12/14.
//
//

#import <UIKit/UIKit.h>

@class GitBranchController;
@class GitLogViewCongroller;

@interface GitBranchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    BOOL needSwitchBranch;
}

@property (nonatomic, strong) GitBranchController* gitBranchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) GitLogViewCongroller* gitLogViewController;

-(void) setNeedSwitchBranch:(BOOL)needSwitch;

@end
