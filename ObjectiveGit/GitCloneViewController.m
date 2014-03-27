//
//  GitCloneViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/24/13.
//
//

#import "GitCloneViewController.h"
#import "Utils.h"
#import "MasterViewController.h"
#import "GTCredential.h"

#define SEPERATOR @"--lgz_SePeRator--"
#define KEY @"CodeNavigator--lgz_SePeRator--"

@interface GitCloneViewController ()
@end

@implementation GitCloneViewController
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize repo;

- (IBAction)discardClicked:(id)sender {
    NSString* path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/git.config"];
    NSError* error;

    [[Utils getInstance] setGitUsername:nil];
    [[Utils getInstance] setGitPassword:nil];
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

- (IBAction)saveClicked:(id)sender {
    NSError* error;
    NSString* path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/git.config"];
    NSString* username = self.usernameTextField.text;
    NSString* password = self.passwordTextField.text;
    [[Utils getInstance] setGitUsername:username];
    [[Utils getInstance] setGitPassword:password];
    
    if (username.length == 0 || password.length == 0) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        return;
    }
    
    username = [Utils HloveyRC4:username key:KEY];
    password = [Utils HloveyRC4:password key:KEY];
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    NSString* content = [NSString stringWithFormat:@"%@%@%@", username, SEPERATOR, password];
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

- (void) viewWillAppear:(BOOL)animated
{
    NSError* error;
    // Get username and paaasword from file
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
    self.usernameTextField.text = [Utils getInstance].gitUsername;
    self.passwordTextField.text = [Utils getInstance].gitPassword;
}

- (void) gitClone
{
    NSString* projectName = self.needCloneProjectName;
    NSString* remoteUrl = self.needCloneRemoteUrl;
    NSError* error;
    
    BOOL isDir;
    NSString* projectFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    NSString* gitFolder = projectFolder;
    gitFolder = [gitFolder stringByAppendingPathComponent:projectName];
    //"http://github.com/WebKitNix/nix-scripts.git"
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:gitFolder isDirectory:&isDir]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* msg = [NSString stringWithFormat:@"Project \"%@\" exists, please change to use another project name.", projectName];
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:msg];
            [self.cloneButton setTitle:@"Clone" forState:UIControlStateNormal];
            [self.cloneButton setHidden:NO];
            [self.urlTextField setEnabled:YES];
            [self.projectNameTextField setEnabled:YES];
            [self.usernameTextField setEnabled:YES];
            [self.passwordTextField setEnabled:YES];
            [self.cloningIndicator stopAnimating];
            [[NSNotificationCenter defaultCenter] postNotificationName:MASTER_VIEW_RELOAD object:nil];
        });
        return;
    }
    
    GTCredentialProvider* provider = [GTCredentialProvider providerWithBlock:^GTCredential *(GTCredentialType type, NSString *URL, NSString *userName) {
        NSError* error;
        GTCredential* credental = [GTCredential credentialWithUserName:[Utils getInstance].gitUsername password:[Utils getInstance].gitPassword error:&error];
            return credental;
    }];

    NSDictionary *options = @{ GTRepositoryCloneOptionsCheckout: @YES , GTRepositoryCloneOptionsCredentialProvider: provider, GTRepositoryCloneOptionsTransportFlags : @YES};
    
    repo = (GTRepository*)[GTRepository cloneFromURL:[NSURL URLWithString:remoteUrl] toWorkingDirectory:[NSURL fileURLWithPath:gitFolder] options:options error:&error transferProgressBlock:^(const git_transfer_progress *progress) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSString* log = [NSString stringWithFormat:@"remote: Counting objects: %.0f%% (%d/%d).", 100*((float)(progress->received_objects)/(float)(progress->total_objects)), progress->received_objects, progress->total_objects];
                [self replaceLastLine:log];
            });
        } checkoutProgressBlock:^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSString* log = [NSString stringWithFormat:@"Checking out:[%d/%d] %@", completedSteps, totalSteps, path];
                [self addLog:log andNewLine:YES];
            });
        }];
    
    if (error != NULL) {
        const git_error *gitLastError = giterr_last();
        dispatch_async(dispatch_get_main_queue(), ^{
            // Wrong
//            [self setCloneButtonToClone];
            [self.cloneButton setTitle:@"Clone" forState:UIControlStateNormal];
            [self.cloneButton setHidden:NO];
            [self.urlTextField setEnabled:YES];
            [self.projectNameTextField setEnabled:YES];
            [self.usernameTextField setEnabled:YES];
            [self.passwordTextField setEnabled:YES];
            [self.cloningIndicator stopAnimating];
            [[NSNotificationCenter defaultCenter] postNotificationName:MASTER_VIEW_RELOAD object:nil];
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:[NSString stringWithFormat:@"Clone error\n%s", gitLastError->message]];
        });
        [self setRepo:nil];
        return;
	}
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self setCloneButtonToClone];
        [self.cloneButton setTitle:@"Clone" forState:UIControlStateNormal];
        [self.cloneButton setHidden:NO];
        [self.urlTextField setEnabled:YES];
        [self.projectNameTextField setEnabled:YES];
        [self.usernameTextField setEnabled:YES];
        [self.passwordTextField setEnabled:YES];
        [self.cloningIndicator stopAnimating];
        [[NSNotificationCenter defaultCenter] postNotificationName:MASTER_VIEW_RELOAD object:nil];
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Cloning finished"];
        [self setRepo:nil];
    });

    //    success = git_buf_joinpath(&path, git_repository_workdir(g_repo), "master.txt")
    
    //    success = git_reference_lookup(&head, g_repo, "HEAD");
    //    success = git_remote_load(&origin, g_repo, "origin");
}

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
    //for test
//    [self.urlTextField setText:@"http://github.com/libgit2/objective-git.git"];
}

- (void) replaceLastLine:(NSString*)log
{
    NSString* info = self.infoTextView.text;
    NSArray* array = [info componentsSeparatedByString:@"\n"];
    info = @"";
    for (int i=0; i<[array count] - 1; i++) {
        info = [info stringByAppendingFormat:@"%@\n",[array objectAtIndex:i]];
    }
    info = [info stringByAppendingString:log];
    
    [self.infoTextView setText:info];
    
	NSRange range;
	range.location= [self.infoTextView.text length] -6;
	range.length= 5;
	[self.infoTextView scrollRangeToVisible:range];
}

- (void) addLog:(NSString*)log andNewLine: (BOOL)newLine
{
    if (newLine)
        self.infoTextView.text= [self.infoTextView.text stringByAppendingString:@"\n"];

    self.infoTextView.text= [self.infoTextView.text stringByAppendingString:log];
    	
	NSRange range;
	range.location= [self.infoTextView.text length] -6;
	range.length= 5;
	[self.infoTextView scrollRangeToVisible:range];
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

- (IBAction)doneClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
//    MasterViewController* masterViewController = nil;
//    NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
//    masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;
//    [masterViewController reloadData];
}

- (void) setCloneButtonToClone
{
    [self.cloneButton setTitle:@"Clone" forState:UIControlStateNormal];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (buttonIndex == 1) {
//        if (_g_repo == 0 || _g_remote == 0) {
//            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please wait a monent and Cancel Again!"];
//            return;
//        }
//        
//        git_remote_stop(_g_remote);
//    }
}

- (IBAction)gitCloneClicked:(id)sender {
    if ([self.cloneThread isExecuting]) {
//        UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:@"Clone is in progress\n Would you like to Cancel anyway?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//        [confirmAlert show];
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Clone is in progress, Please wait until clone finished"];
        return;
    }
    
    NSString* remoteURL = self.urlTextField.text;
    if ([remoteURL length] == 0) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please enter remote url"];
        return;
    }
    [[Utils getInstance] addGAEvent:@"GitClone" andAction:remoteURL andLabel:nil andValue:nil];
//    NSRange range = [remoteURL rangeOfString:@"https://"];
//    if (range.location != NSNotFound && range.location == 0)
//    {
//        if ([self.usernameTextField.text length] == 0 ||
//            [self.passwordTextField.text length] == 0) {
//            [[Utils getInstance] alertWithTitle:@"CodeNavigator"andMessage:@"You must provide Username & Password for this clone" ];
//            return;
//        }
//    }
    
//    range = [remoteURL rangeOfString:@"ssh://"];
//    if (range.location != NSNotFound && range.location == 0)
//    {
//        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"SSH connection is not supported"];
//        return;
//    }
    [[Utils getInstance] setGitUsername:self.usernameTextField.text];
    [[Utils getInstance] setGitPassword:self.passwordTextField.text];
    
    NSString* projectName = [remoteURL lastPathComponent];
    projectName = [projectName stringByDeletingPathExtension];
    
    // set default project name
    if ([self.projectNameTextField.text length] == 0)
        [self.projectNameTextField setText:projectName];
    else
        projectName = self.projectNameTextField.text;
    
    // clear info
    [self.infoTextView setText:@""];
    
    NSString* log = @"Cloning into ";
    
    log = [log stringByAppendingString: projectName];
    [self addLog:log andNewLine:NO];
    [self addLog:@"" andNewLine:YES];
    
    //start clone
    [self setNeedCloneProjectName:projectName];
    [self setNeedCloneRemoteUrl:remoteURL];
    //Indicator start
    [self.cloningIndicator setHidden:NO];
    [self.cloningIndicator startAnimating];
    
    if (![self.cloneThread isExecuting])
    {
        [self setCloneThread:nil];
        self.cloneThread = [[NSThread alloc] initWithTarget:self selector:@selector(gitClone) object:nil];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [self.cloneThread start];
    }
    [self.cloneButton setHidden:YES];
    [self.urlTextField setEnabled:NO];
    
    [self.projectNameTextField setEnabled:NO];
    [self.usernameTextField setEnabled:NO];
    [self.passwordTextField setEnabled:NO];
    //[self gitClone:remoteURL andProjectName:projectName];
}

- (void)viewDidUnload {
    [self setUrlTextField:nil];
    [self setInfoTextView:nil];
    [self setProjectNameTextField:nil];
    [self setCloneThread:nil];
    [self setCloneButton:nil];
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [[Utils getInstance] setGitUsername:nil];
    [[Utils getInstance] setGitPassword:nil];
    [self setCloningIndicator:nil];
    [super viewDidUnload];
}
@end
