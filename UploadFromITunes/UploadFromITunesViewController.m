//
//  UploadFromITunesViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 7/11/14.
//
//

#import "UploadFromITunesViewController.h"
#import "FileListBrowserController.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "MasterViewController.h"

@interface UploadFromITunesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *itunesTableView;
@property (weak, nonatomic) IBOutlet UITableView *iPadTableView;
@property (weak, nonatomic) IBOutlet UIButton *iTunesBackButton;
@property (weak, nonatomic) IBOutlet UIButton *iPadBackButton;

@property (strong, nonatomic) FileListBrowserController* iTunesFileListBroserController;
@property (strong, nonatomic) FileListBrowserController* iPadFileListBrowserController;

@property (strong, nonatomic) NSString* currentiTunesPath;
@property (strong, nonatomic) NSString* currentiPadPath;

@property (strong, nonatomic) NSString* currentiTunesSelectedFilePath;
@property (strong, nonatomic) NSString* currentiPadSelectedPath;

@property (strong, nonatomic) NSString* sourcePath;
@property (strong, nonatomic) NSString* destPath;

@property (weak, nonatomic) IBOutlet UILabel *sourcePathLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetPathLabel;

@end

@implementation UploadFromITunesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // init iTunes file list table view
        self.iTunesFileListBroserController = [[FileListBrowserController alloc] init];
        [self.iTunesFileListBroserController setFileListBrowserDelegate:self];
        [self.iTunesFileListBroserController setEnableFileInfoButton:NO];
        
        // init iPad file list table view
        self.iPadFileListBrowserController = [[FileListBrowserController alloc] init];
        [self.iPadFileListBrowserController setFileListBrowserDelegate:self];
        [self.iPadFileListBrowserController setEnableFileInfoButton:NO];
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.iTunesFileListBroserController set_tableView:self.itunesTableView];
    [self.iPadFileListBrowserController set_tableView:self.iPadTableView];
    
    NSString* documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    self.currentiPadPath = [documentPath stringByAppendingPathComponent:@".Projects"];
    self.currentiTunesPath = documentPath;
}

- (void) setCurrentiPadPath:(NSString *)currentiPadPath_ {
    NSString* documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentPath = [documentPath stringByAppendingPathComponent:@".Projects"];
    NSArray* array = [documentPath pathComponents];
    NSArray* pathCompo = [currentiPadPath_ pathComponents];
    
    if ([pathCompo count] < [array count]) {
        return;
    } else if ([pathCompo count] == [array count]) {
        [self.iPadBackButton setHidden:YES];
    } else {
        [self.iPadBackButton setHidden:NO];
        NSString* title = [NSString stringWithFormat:@"<%@", [pathCompo objectAtIndex:[pathCompo count] - 1]];
        [self.iPadBackButton setTitle:title forState:UIControlStateNormal];
    }
    _currentiPadPath = currentiPadPath_;
    self.iPadFileListBrowserController.currentLocation = self.currentiPadPath;
    [self.iPadFileListBrowserController reloadData];
    [self.iPadTableView reloadData];
}

- (void) setCurrentiTunesPath:(NSString *)currentiTunesPath_ {
    NSString* documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray* array = [documentPath pathComponents];
    NSArray* pathCompo = [currentiTunesPath_ pathComponents];

    if ([pathCompo count] < [array count]) {
        return;
    } else if ([pathCompo count] == [array count]) {
        [self.iTunesBackButton setHidden:YES];
    } else {
        [self.iTunesBackButton setHidden:NO];
        NSString* title = [NSString stringWithFormat:@"<%@", [pathCompo objectAtIndex:[pathCompo count] - 1]];
        [self.iTunesBackButton setTitle:title forState:UIControlStateNormal];
    }
    _currentiTunesPath = currentiTunesPath_;
    self.iTunesFileListBroserController.currentLocation = self.currentiTunesPath;
    [self.iTunesFileListBroserController reloadData];
    [self.itunesTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[NSFileManager defaultManager] removeItemAtPath:self.destPath error:nil];
        if (alertView.tag == 1) {
            MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            [hud showWhileExecuting:@selector(doiTunesToIPad) onTarget:self withObject:nil animated:YES];
        } else {
            MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            [hud showWhileExecuting:@selector(doiPadToITunes) onTarget:self withObject:nil animated:YES];
        }
    }
}

- (void) doiTunesToIPad {
    NSError* error;
    [[NSFileManager defaultManager] moveItemAtPath:self.sourcePath toPath:self.destPath error:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [[Utils getInstance] alertWithTitle:@"Error" andMessage:[error description]];
        } else {
            [self.iPadFileListBrowserController reloadData];
            [self.iPadTableView reloadData];
        }
    });
}

- (IBAction)iTunesToIPadClicked:(id)sender {
    if (self.currentiTunesSelectedFilePath == nil) {
        self.sourcePath = self.currentiTunesPath;
    } else {
        self.sourcePath = self.currentiTunesSelectedFilePath;
    }
    
    NSString* documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    if ([documentPath compare:self.sourcePath] == NSOrderedSame) {
        [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"Please select a Folder/File on iTunes."];
        return;
    }
    
    // Check whether dest contains file/folder
    NSString* finalPath = [self.currentiPadPath stringByAppendingPathComponent:[self.sourcePath lastPathComponent]];
    self.destPath = finalPath;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:finalPath];
    if (!isExist) {
        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud showWhileExecuting:@selector(doiTunesToIPad) onTarget:self withObject:nil animated:YES];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Fise exists, Would you like to override?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alert.tag = 1;
        [alert show];
    }
}

-(void) doiPadToITunes {
    NSError* error;
    [[NSFileManager defaultManager] copyItemAtPath:self.sourcePath toPath:self.destPath error:&error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [[Utils getInstance] alertWithTitle:@"Error" andMessage:[error description]];
        } else {
            [self.iTunesFileListBroserController reloadData];
            [self.itunesTableView reloadData];
        }
    });
}

- (IBAction)iPadToITunesClicked:(id)sender {
    if (self.currentiPadSelectedPath == nil) {
        self.sourcePath = self.currentiPadPath;
    } else {
        self.sourcePath = self.currentiPadSelectedPath;
    }
    
    NSString* proj = [[Utils getInstance] getPathFromProject:self.sourcePath];
    if ([proj length] == 0) {
        [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"Please select a Project/Folder/File on iPad."];
        return;
    }
    
    // Check whether dest contains file/folder
    NSString* finalPath = [self.currentiTunesPath stringByAppendingPathComponent:[self.sourcePath lastPathComponent]];
    self.destPath = finalPath;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:finalPath];
    if (!isExist) {
        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud showWhileExecuting:@selector(doiPadToITunes) onTarget:self withObject:nil animated:YES];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Fise exists, Would you like to override?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alert.tag = 0;
        [alert show];
    }
}

- (IBAction)iTunesBackClicked:(id)sender {
    self.currentiTunesPath = [self.currentiTunesPath stringByDeletingLastPathComponent];
    [self setSourceLabel:self.currentiTunesPath];
}

- (IBAction)iPadBackClicked:(id)sender {
    self.currentiPadPath = [self.currentiPadPath stringByDeletingLastPathComponent];
    [self setTargetLabel:self.currentiPadPath];
}

#pragma mark TableView related

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.iPadTableView) {
        return [self.iPadFileListBrowserController numberOfSectionsInTableView:tableView];
    } else {
        return [self.iTunesFileListBroserController numberOfSectionsInTableView:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.iPadTableView) {
        return [self.iPadFileListBrowserController tableView:tableView numberOfRowsInSection:section];
    } else {
        return [self.iTunesFileListBroserController tableView:tableView numberOfRowsInSection:section];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.iPadTableView) {
        return [self.iPadFileListBrowserController tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        return [self.iTunesFileListBroserController tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.iPadTableView) {
        return [self.iPadFileListBrowserController tableView:tableView canEditRowAtIndexPath:indexPath];
    } else {
        return [self.iTunesFileListBroserController tableView:tableView canEditRowAtIndexPath:indexPath];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.iPadTableView) {
        [self.iPadFileListBrowserController tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    } else {
        [self.iTunesFileListBroserController tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.iPadTableView) {
        return [self.iPadFileListBrowserController tableView:tableView heightForRowAtIndexPath:indexPath];

    } else {
        return [self.iTunesFileListBroserController tableView:tableView heightForRowAtIndexPath:indexPath];

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.iPadTableView) {
        [self.iPadFileListBrowserController tableView:tableView didSelectRowAtIndexPath: indexPath];
    } else {
        [self.iTunesFileListBroserController tableView:tableView didSelectRowAtIndexPath: indexPath];
    }
}

- (IBAction) fileInfoButtonClicked:(id)sender {
    
}

-(void) setSourceLabel:(NSString*)path {
    NSString* documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSInteger length = [[documentPath pathComponents] count];
    NSArray* array = [path pathComponents];
    if (length == [array count]) {
        self.sourcePathLabel.text = @"Please select File or Folder";
        return;
    }
    if (length > [array count]) {
        self.sourcePathLabel.text = @"Path Error";
        return;
    }
    NSString* finalPath = @"";
    for (NSInteger i=length; i<[array count]; i++) {
        finalPath = [finalPath stringByAppendingPathComponent:[array objectAtIndex:i]];
    }
    self.sourcePathLabel.text = finalPath;
}

-(void) setTargetLabel:(NSString*)path {
    NSString* documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentPath = [documentPath stringByAppendingPathComponent:@".Projects"];
    NSInteger length = [[documentPath pathComponents] count];
    NSArray* array = [path pathComponents];
    if (length == [array count]) {
        self.targetPathLabel.text = @"Projects";
        return;
    }
    if (length > [array count]) {
        self.targetPathLabel.text = @"Path Error";
        return;
    }
    NSString* finalPath = @"Projects";
    for (NSInteger i=length; i<[array count]; i++) {
        finalPath = [finalPath stringByAppendingPathComponent:[array objectAtIndex:i]];
    }
    self.targetPathLabel.text = finalPath;
}

- (void) folderClickedDelegate:(UITableView*) tableView andSelectedItem:(NSString*)selectedItem andPath:(NSString*)path {
    if (tableView == self.iPadTableView) {
        self.currentiPadPath = path;
        self.currentiPadSelectedPath = nil;
        [self setTargetLabel:path];
    } else {
        self.currentiTunesPath = path;
        self.currentiTunesSelectedFilePath = nil;
        [self setSourceLabel:path];
    }
}

- (void) fileClickedDelegate:(UITableView*) tableView andSelectedItem:(NSString*)selectedItem andPath:(NSString*)path {
    if (tableView == self.iPadTableView) {
        self.currentiPadSelectedPath = path;
    } else {
        self.currentiTunesSelectedFilePath = path;
        [self setSourceLabel:path];
    }
}

- (NSString*) getCurrentProjectPath {
    return nil;
}

- (IBAction)doneButtonClicked:(id)sender {
    [[Utils getInstance].masterViewController reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refreshClicked:(id)sender {
    [self.iTunesFileListBroserController reloadData];
    [self.itunesTableView reloadData];
}
- (IBAction)infoButtonClicked:(id)sender {
    [[Utils getInstance] alertWithTitle:@"iTunes Transfer" andMessage:@"Connect your device with iTunes, Use Apps->File Sharing to share files/folders."];
}
@end
