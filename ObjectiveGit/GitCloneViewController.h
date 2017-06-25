//
//  GitCloneViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/24/13.
//
//

#import <UIKit/UIKit.h>
#import "ObjectiveGit.h"

@interface GitCloneViewController : UIViewController

- (IBAction)doneClicked:(id)sender;

- (IBAction)gitCloneClicked:(id)sender;

- (IBAction)saveClicked:(id)sender;

- (IBAction)discardClicked:(id)sender;

- (void) setCloneUrl:url;

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

@property (weak, nonatomic) IBOutlet UITextField *projectNameTextField;

@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property (strong, nonatomic) NSThread* cloneThread;

@property (strong, nonatomic) NSString* needCloneRemoteUrl;

@property (strong, nonatomic) NSString* needCloneProjectName;

@property (strong, nonatomic) NSString* lastPath;

@property (weak, nonatomic) IBOutlet UIButton *cloneButton;

@property (unsafe_unretained, nonatomic) GTRepository* repo;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *cloningIndicator;
@end
