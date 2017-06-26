//
//  SelectGroupViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 4/26/14.
//
//

#import "SelectGroupViewController.h"
#import "Utils.h"

@interface SelectGroupViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SelectGroupViewController

@synthesize groups;
@synthesize currentGroup;
@synthesize commentViewController;

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

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groups count] + 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SelectionCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"+ Add a new group";
    } else {
        cell.textLabel.text = [groups objectAtIndex:indexPath.row - 1];
    }
    if ([cell.textLabel.text isEqualToString:currentGroup]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Please enter a group name!" message:@"\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [myAlertView show];
        } else {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Please enter a group name!" message:@"\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 60.0, 260.0, 25.0)];
            [myTextField setBackgroundColor:[UIColor whiteColor]];
            [myTextField setTag:123];
            [myAlertView addSubview:myTextField];
            [myAlertView show];
        }
        [self.commentViewController dismissGroupView];
    } else {
        currentGroup = [groups objectAtIndex:indexPath.row - 1];
        [commentViewController groupSelected:currentGroup];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        UITextField* textField;
        if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            textField = [alertView textFieldAtIndex:0];
        } else {
            textField = (UITextField*)[alertView viewWithTag:123];
        }
        NSString* str = textField.text;
        if ([str length] == 0) {
            return;
        }
        [commentViewController groupSelected:str];
        self.currentGroup = str;
    }
}

@end
