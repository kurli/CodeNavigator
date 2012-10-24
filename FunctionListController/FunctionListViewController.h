//
//  FileListViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 10/21/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FunctionListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) NSString* currentFilePath;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSArray* tagsArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
