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

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, atomic) NSArray* tagsArray;

@property (strong, atomic) NSArray* tagsArrayCopy;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *searchField;

@end
