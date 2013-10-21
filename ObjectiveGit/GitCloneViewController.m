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

#define FETCH_PROGRESS @"CodeNavigator_fetch_progress"
#define CHECKOUT_PROGRESS @"CodeNavigator_checkout_progress"

#define SEPERATOR @"--lgz_SePeRator--"
#define KEY @"CodeNavigator--lgz_SePeRator--"

@interface TransferProgress : NSObject
@property (nonatomic, unsafe_unretained) unsigned int total_objects;
@property (nonatomic, unsafe_unretained) unsigned int indexed_objects;
@property (nonatomic, unsafe_unretained) unsigned int received_bytes;
@property (nonatomic, unsafe_unretained) size_t received_objects;
@end
@implementation TransferProgress
@synthesize total_objects;
@synthesize indexed_objects;
@synthesize received_bytes;
@synthesize received_objects;
@end

@interface CheckoutProgress : NSObject
@property (nonatomic, strong) NSString* path;
@property (nonatomic, unsafe_unretained) unsigned int current;
@property (nonatomic, unsafe_unretained) unsigned int total;
@end
@implementation CheckoutProgress
@synthesize path;
@synthesize current;
@synthesize total;
@end

@interface GitCloneViewController ()
@end

static void checkout_progress(const char *path, size_t cur, size_t tot, void *payload)
{
	bool *was_called = (bool*)payload;
	(*was_called) = true;
    if (path == NULL)
        return;
    CheckoutProgress* cp = [[CheckoutProgress alloc] init];
    [cp setPath:[NSString stringWithCString:path encoding:NSUTF8StringEncoding]];
    [cp setCurrent:cur];
    [cp setTotal:tot];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHECKOUT_PROGRESS object:cp];
   // printf("checkout_progress %s %9d %9d\n", path, cur, tot);
}

static void fetch_progress(const git_transfer_progress *stats, void *payload)
{
	bool *was_called = (bool*)payload;
	(*was_called) = true;
    //printf("\rfetch %9d %9d %9d %9d\n", stats->total_objects, stats->indexed_objects, stats->received_objects, stats->received_bytes);
    
    TransferProgress* tp = [[TransferProgress alloc]init];
    [tp setTotal_objects:stats->total_objects];
    [tp setIndexed_objects:stats->indexed_objects];
    [tp setReceived_bytes:stats->received_bytes];
    [tp setReceived_objects:stats->received_objects];
    [[NSNotificationCenter defaultCenter] postNotificationName:FETCH_PROGRESS object:tp];
}

static int cred_acquire(git_cred **cred,
                        const char *url,
                        unsigned int allowed_types,
                        void *payload)
{
    const char* username = [[Utils getInstance].gitUsername cStringUsingEncoding:NSUTF8StringEncoding];
	const char* password = [[Utils getInstance].gitPassword cStringUsingEncoding:NSUTF8StringEncoding];

	return git_cred_userpass_plaintext_new(cred, username, password);
}

@implementation GitCloneViewController
@synthesize usernameTextField;
@synthesize passwordTextField;

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

- (void) fetch_progress:(NSNotification*) gtp
{
    TransferProgress *tp = [gtp object];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* log = [NSString stringWithFormat:@"remote: Counting objects: %zd/%d.", tp.received_objects, tp.total_objects];
        [self replaceLastLine:log];
    });
}

- (void) checkout_progress:(NSNotification*) cp
{
    CheckoutProgress *tp = [cp object];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* log = [NSString stringWithFormat:@"Checking out:[%d/%d]%@", tp.current, tp.total, tp.path];
        [self addLog:log andNewLine:YES];
    });
}

- (void) gitClone
{
    NSString* projectName = self.needCloneProjectName;
    NSString* remoteUrl = self.needCloneRemoteUrl;
    int success;
    
    git_clone_options g_options = GIT_CLONE_OPTIONS_INIT;
    //    git_buf path = GIT_BUF_INIT;
//    git_reference *head;
//    git_remote *origin;
    git_checkout_opts dummy_opts = GIT_CHECKOUT_OPTS_INIT;
    
    bool checkout_progress_cb_was_called = false,
    fetch_progress_cb_was_called = false;
	g_options.version = GIT_CLONE_OPTIONS_VERSION;
    g_options.transport = 0;
	g_options.checkout_opts = dummy_opts;    
    g_options.checkout_opts.checkout_strategy = GIT_CHECKOUT_SAFE_CREATE;
	g_options.checkout_opts.progress_cb = &checkout_progress;
	g_options.checkout_opts.progress_payload = &checkout_progress_cb_was_called;
	g_options.fetch_progress_cb = &fetch_progress;
	g_options.fetch_progress_payload = &fetch_progress_cb_was_called;
    g_options.cred_acquire_cb = &cred_acquire;
    
    NSString* projectFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    NSString* gitFolder = projectFolder;
    gitFolder = [gitFolder stringByAppendingPathComponent:projectName];
    
    //"http://github.com/WebKitNix/nix-scripts.git"
    success = git_clone(&_g_repo, [remoteUrl cStringUsingEncoding:NSUTF8StringEncoding], [gitFolder cStringUsingEncoding:NSUTF8StringEncoding], &g_options, &_g_remote);
    if (success < GIT_OK) {
        const git_error *gitLastError = giterr_last();
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setCloneButtonToClone];
            [self.urlTextField setEnabled:YES];
            [self.projectNameTextField setEnabled:YES];
            [self.usernameTextField setEnabled:YES];
            [self.passwordTextField setEnabled:YES];
            [self.cloningIndicator stopAnimating];
            [[NSNotificationCenter defaultCenter] postNotificationName:MASTER_VIEW_RELOAD object:nil];
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:[NSString stringWithFormat:@"Clone error(%d)\n%s", success, gitLastError->message]];
        });
        return;
	}
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setCloneButtonToClone];
        [self.urlTextField setEnabled:YES];
        [self.projectNameTextField setEnabled:YES];
        [self.usernameTextField setEnabled:YES];
        [self.passwordTextField setEnabled:YES];
        [self.cloningIndicator stopAnimating];
        [[NSNotificationCenter defaultCenter] postNotificationName:MASTER_VIEW_RELOAD object:nil];
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Cloning finished"];
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
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(fetch_progress:) name:FETCH_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(checkout_progress:) name:CHECKOUT_PROGRESS object:nil];
    
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
    if (self.cloneThread.isExecuting) {
        [self checkWhetherCancelClone];
        return;
    }
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

- (void) switchCloneButton
{
    if ([self.cloneThread isExecuting]) {
        [self.cloneButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }
    else {
        [self.cloneButton setTitle:@"Clone" forState:UIControlStateNormal];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (_g_repo == 0 || _g_remote == 0) {
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please wait a monent and Cancel Again!"];
            return;
        }
        
        git_remote_stop(_g_remote);
    }
}

- (void) checkWhetherCancelClone
{
    if ([self.cloneThread isExecuting]) {
        UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:@"Clone is in progress\n Would you like to Cancel anyway?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmAlert show];
        return;
    }
}

- (IBAction)gitCloneClicked:(id)sender {
    [self checkWhetherCancelClone];
    NSString* remoteURL = self.urlTextField.text;
    if ([remoteURL length] == 0) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please enter remote url"];
        return;
    }
    NSRange range = [remoteURL rangeOfString:@"https://"];
    if (range.location != NSNotFound && range.location == 0)
    {
        if ([self.usernameTextField.text length] == 0 ||
            [self.passwordTextField.text length] == 0) {
            [[Utils getInstance] alertWithTitle:@"CodeNavigator"andMessage:@"You must provide Username & Password for this clone" ];
            return;
        }
    }
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
    [self switchCloneButton];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FETCH_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHECKOUT_PROGRESS object:nil];
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [[Utils getInstance] setGitUsername:nil];
    [[Utils getInstance] setGitPassword:nil];
    [self setCloningIndicator:nil];
    [super viewDidUnload];
}
@end
