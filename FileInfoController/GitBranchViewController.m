//
//  GitBranchViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 3/12/14.
//
//

#import "GitBranchViewController.h"
#import "GitBranchController.h"
#import "ObjectiveGit.h"
#import "GitBranchsManagerViewController.h"
#import "Utils.h"
#import "GitLogViewCongroller.h"

@interface GitBranchViewController ()

@end

@implementation GitBranchViewController

@synthesize gitBranchController;
@synthesize gitLogViewController;

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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.gitBranchController update];
    [self.tableView reloadData];
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

-(void) setNeedSwitchBranch:(BOOL)needSwitch {
    needSwitchBranch = needSwitch;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [gitBranchController.branches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SelectionCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row > [gitBranchController.branches count]) {
        return cell;
    }
    GTBranch* branch = [gitBranchController.branches objectAtIndex:indexPath.row];
    if ([branch.name compare:gitBranchController.currentBranch.name] == NSOrderedSame) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (branch.branchType == GTBranchTypeLocal) {
        cell.textLabel.text = branch.shortName;
        [cell.textLabel setTextColor:[UIColor blackColor]];
    } else {
        cell.textLabel.text = branch.name;
        [cell.textLabel setTextColor:[UIColor redColor]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > [self.gitBranchController.branches count]) {
        return;
    }
    GTBranch* selectedBranch = [self.gitBranchController.branches objectAtIndex:indexPath.row];
    GTBranch* currentBranch = self.gitBranchController.currentBranch;
    if ([selectedBranch.SHA compare:currentBranch.SHA] == NSOrderedSame) {
        return;
    }

    if (needSwitchBranch) {
//        UIView* parent = [Utils getInstance].splitViewController.view;
//        [self.gitBranchController setParentView:parent];
        [self.gitBranchController checkoutToBranch:selectedBranch andFinishBlock:^(){
            [self.tableView reloadData];
        }];
    } else {
        UINavigationController* navigationController = [self navigationController];
        GitBranchsManagerViewController* manager = [[GitBranchsManagerViewController alloc] init];
        [manager setGitBranchController:self.gitBranchController];
        [manager setSelectedBranch:selectedBranch];
        [manager initItems];
        [manager setGitLogViewController:self.gitLogViewController];
        [navigationController pushViewController:manager animated:YES];
    }
}

@end
