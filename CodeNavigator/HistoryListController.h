//
//  HistoryListController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 1/26/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryListController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@end
