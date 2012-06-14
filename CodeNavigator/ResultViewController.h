//
//  ResultViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h"
#import "Utils.h"

@interface ResultViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    TableViewMode tableviewMode;
    int currentFileIndex;
}

@property (strong, nonatomic) DetailViewController* detailViewController;

@property (strong, nonatomic) ResultViewController* lineModeViewController;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

-(IBAction)addButtonClicked:(id)sender;

-(void) setTableViewMode:(TableViewMode) mode;

-(void) setFileIndex: (int)index;
#ifdef IPHONE_VERSION
- (IBAction)doneButtonClicked:(id)sender;
#endif

@end
