//
//  SelectGroupViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 4/26/14.
//
//

#import <UIKit/UIKit.h>
#import "CommentViewController.h"

@interface SelectGroupViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* groups;
@property (nonatomic, strong) NSString* currentGroup;
@property (nonatomic, strong) CommentViewController* commentViewController;

@end
