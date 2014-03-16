//
//  GitUpdateViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/15/14.
//
//

#import <UIKit/UIKit.h>
#import "GitBranchController.h"

@interface GitUpdateViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *currentBranch;
@property (weak, nonatomic) IBOutlet UITextField *remoteBranch;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextView *log;

@property (strong, nonatomic) NSString* gitFolder;
@property (strong, nonatomic) GitBranchController* gitBranchController;
@end
