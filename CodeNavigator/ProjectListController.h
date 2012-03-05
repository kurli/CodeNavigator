//
//  ProjectListController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 2/21/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VirtualizeViewController;

@interface ProjectListController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* projectList;
@property (assign, nonatomic) VirtualizeViewController* viewController;
@property (strong, nonatomic) NSString* currentProject;

@end
