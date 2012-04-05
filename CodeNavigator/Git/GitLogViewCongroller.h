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
    GTObject* newObj;
    GTObject* oldObj;
}
@property (nonatomic, strong) GTRepository* repo;
@property (nonatomic, strong) NSArray* commitsArray;
@property (nonatomic, strong) NSMutableArray* pendingDiffTree;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* diffFileArray;

-(void) gitLogForProject:(NSString*)project;

-(void) showModualView;

- (IBAction)backButtonClicked:(id)sender;

-(IBAction)detailButtonClicked:(id)sender;

@end
