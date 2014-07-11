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
    
    NSError* error;
    NSString* path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/git.config"];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    // Parse content
    NSArray* array = [content componentsSeparatedByString:SEPERATOR];
    if ([array count] == 2) {
        [[Utils getInstance] setGitUsername:[Utils HloveyRC4:[array objectAtIndex:0] key:KEY]];
        [[Utils getInstance] setGitPassword:[Utils HloveyRC4:[array objectAtIndex:1] key:KEY]];
    } else {
        [[Utils getInstance] setGitUsername:@""];
        [[Utils getInstance] setGitPassword:@""];
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
    
    self.username.text = [Utils getInstance].gitUsername;
    self.password.text = [Utils getInstance].gitPassword;
    if ([currentBranch.shortName length] == 0) {
        self.currentBranch.text = currentBranch.name;
    } else {
        self.currentBranch.text = currentBranch.shortName;
    }
    self.remoteBranch.text = trackingBranch.name;

    [self.username setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.password setAutocorrectionType:UITextAutocorrectionTypeNo];
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
