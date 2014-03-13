//
//  GitBranchsManagerViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 3/13/14.
//
//

#import "GitBranchsManagerViewController.h"
#import "ObjectiveGit.h"
#import "GitBranchController.h"
#import "GitLogViewCongroller.h"

@interface GitBranchsManagerViewController ()

@end

@implementation GitBranchsManagerViewController

@synthesize selectedBranch;
@synthesize items;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initItems {
    NSString* str = [NSString stringWithFormat:@"Switch to %@", self.selectedBranch.shortName];
    self.items = [[NSArray alloc] initWithObjects:str, @"Delete", nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSError* error;
        [self.selectedBranch deleteWithError:&error];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SelectionCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row > [self.items count]) {
        return cell;
    }
    cell.textLabel.text = [self.items objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.items count] -1) {
        // Delete branch
        UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:@"Would you like to delete this branch?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [confirmAlert show];
    } else {
        // Switch to branch
//        [self.gitBranchController setParentView:self.gitLogViewController.view];
        [self.gitBranchController checkoutToBranch:self.selectedBranch andFinishBlock:^(){
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}


@end
