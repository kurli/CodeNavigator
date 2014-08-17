//
//  ProjectViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 8/17/14.
//
//

#import <UIKit/UIKit.h>
#import "ChartBoardViewController.h"

@interface ProjectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) ChartBoardViewController* viewController2;
@property (strong, nonatomic) NSString* currentProject;

@end
