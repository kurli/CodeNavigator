//
//  GitBranchsManagerViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/13/14.
//
//

#import <UIKit/UIKit.h>

@class GitBranchController;
@class GTBranch;
@class GitLogViewCongroller;

@interface GitBranchsManagerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) GitBranchController* gitBranchController;
@property (nonatomic, strong) GTBranch* selectedBranch;
@property (nonatomic, strong) NSArray* items;
@property (nonatomic, strong) GitLogViewCongroller* gitLogViewController;

-(void) initItems;

@end
