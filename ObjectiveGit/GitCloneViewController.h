//
//  GitCloneViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/24/13.
//
//

#import <UIKit/UIKit.h>
#import "git2.h"

@interface GitCloneViewController : UIViewController

- (IBAction)doneClicked:(id)sender;

- (IBAction)gitCloneClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

@property (weak, nonatomic) IBOutlet UITextField *projectNameTextField;

@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property (strong, nonatomic) NSThread* cloneThread;

@property (strong, nonatomic) NSString* needCloneRemoteUrl;

@property (strong, nonatomic) NSString* needCloneProjectName;

@property (weak, nonatomic) IBOutlet UIButton *cloneButton;

@property (unsafe_unretained, nonatomic) git_repository *g_repo;

@property (unsafe_unretained, nonatomic) git_remote *g_remote;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *cloningIndicator;
@end
