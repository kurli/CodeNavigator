//
//  ResultViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h"

typedef enum _TableViewMode{
    TABLEVIEW_FILE,
    TABLEVIEW_CONTENT
} TableViewMode;

@interface ResultFile : NSObject {
}
@property (retain, nonatomic) NSString* fileName;

@property (retain, nonatomic) NSMutableArray* contents;
@end

@interface ResultViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    TableViewMode tableviewMode;
    int currentFileIndex;
}

@property (retain, nonatomic) DetailViewController* detailViewController;

@property (retain, nonatomic) NSMutableArray* resultFileList;

@property (retain, nonatomic) ResultViewController* lineModeViewController;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) NSString* keyword;

-(BOOL) setResultListAndAnalyze: (NSArray*) list andKeyword:keyword;

-(int) fileExistInResultFileList: (NSString*) file;

-(void) setTableViewMode:(TableViewMode) mode;

-(void) setFileIndex: (int)index;

@end
