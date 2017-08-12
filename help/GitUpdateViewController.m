//
//  GitUpdateViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 3/15/14.
//
//

#import "GitUpdateViewController.h"
#import "Utils.h"
#import "ObjectiveGit.h"
#import "MBProgressHUD.h"

#define SEPERATOR @"--lgz_SePeRator--"
#define KEY @"CodeNavigator--lgz_SePeRator--"

@interface GitUpdateViewController ()

@end

@implementation GitUpdateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.gitBranchController = [[GitBranchController alloc] init];
    BOOL isValid = [self.gitBranchController initWithProjectPath:self.gitFolder];
    isValid = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    GTBranch* currentBranch = [self.gitBranchController currentBranch];
    GTBranch* trackingBranch = [self.gitBranchController getCurrentTrackingBranch];
    
    NSString* str = [[self.gitBranchController.projectPath lastPathComponent] stringByDeletingPathExtension];
    
    self.username.text = [[Utils getInstance] getGitUserName:str];
    self.password.text = [[Utils getInstance] getGitUserPwd:str];
    if ([currentBranch.shortName length] == 0) {
        self.currentBranch.text = currentBranch.name;
    } else {
        self.currentBranch.text = currentBranch.shortName;
    }
    self.remoteBranch.text = trackingBranch.name;

    [self.username setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.password setAutocorrectionType:UITextAutocorrectionTypeNo];
}

- (BOOL) shouldAutorotate {
#ifdef IPHONE_VERSION
    return NO;
#else
    return YES;
#endif
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
#ifdef IPHONE_VERSION
    return UIInterfaceOrientationMaskPortrait;
#else
    return UIInterfaceOrientationMaskAll;
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateTask {
    [self.gitBranchController updateRepo:self.log andUsername:self.username.text andPassword:self.password.text];
}

- (IBAction)updateButtonClicked:(id)sender {
    self.log.text = @"";
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud showWhileExecuting:@selector(updateTask) onTarget:self withObject:nil animated:YES];
}
@end
