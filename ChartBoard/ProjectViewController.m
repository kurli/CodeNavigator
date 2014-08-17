//
//  ProjectViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 8/17/14.
//
//

#import "ProjectViewController.h"
#import "Utils.h"

@interface ProjectViewController ()
@property (strong, nonatomic) NSArray* projectsArray;

@end

@implementation ProjectViewController

@synthesize viewController2;
@synthesize currentProject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.projectsArray = [[Utils getInstance].dbManager getAllProjects];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* project = nil;
    if (indexPath.row > 0 && indexPath.row - 1 < [self.projectsArray count]) {
        project = [self.projectsArray objectAtIndex:indexPath.row - 1];
    }
    [viewController2 projectSelectedDone:project];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"projectCell";
    UITableViewCell *cell;
    
    cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString* name;
    if (indexPath.row == 0) {
        name = @"All";
    } else {
        name = [self.projectsArray objectAtIndex:indexPath.row - 1];
    }
    
    cell.textLabel.text = name;
    
    if ([name compare:self.currentProject] == NSOrderedSame)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (currentProject == nil && [name compare:@"All"] == NSOrderedSame) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.projectsArray count] +1;
}

@end
