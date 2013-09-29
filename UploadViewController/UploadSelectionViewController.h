//
//  UploadSelectionViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 9/29/13.
//
//

#import <UIKit/UIKit.h>

@class MasterViewController;

@interface UploadSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) MasterViewController* masterViewController;

@end
