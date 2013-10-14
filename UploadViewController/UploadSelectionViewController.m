//
//  UploadSelectionViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 9/29/13.
//
//

#import "UploadSelectionViewController.h"
#import "MasterViewController.h"

@interface UploadSelectionViewController ()

@end

@implementation UploadSelectionViewController

@synthesize masterViewController;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setMasterViewController:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.contentSizeForViewInPopover = self.view.frame.size;
}

- (void) dealloc
{
    [self setMasterViewController:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [masterViewController showWebUploadService];
            break;
        case 1:
            [masterViewController showGitCloneView];
            break;
        case 2:
            [masterViewController dropBoxClicked:nil];
            break;
        case 3:
            [masterViewController downloadZipFromGitHub];
            break;
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *itemIdentifier = @"UploadSelectionViewCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:itemIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemIdentifier];
    }
    //Twitter
    if (indexPath.row == 0) {
        //cell.imageView.image = [UIImage imageNamed:@"twitter.png"];
        cell.textLabel.text = @"Web Upload Service";
    } else if (indexPath.row == 1) {
        //cell.imageView.image = [UIImage imageNamed:@"share.png"];
        cell.textLabel.text = @"Git";
    } else if (indexPath.row == 2) {
        //cell.imageView.image = [UIImage imageNamed:@"share.png"];
        cell.textLabel.text = @"Dropbox";
    } else {
        cell.textLabel.text = @"Download ZIP from GitHub";
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Sync your source code with";
}


@end
