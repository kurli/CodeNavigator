//
//  ProjectListController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 2/21/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "ProjectListController.h"
#import "VirtualizeViewController.h"

@implementation ProjectListController
@synthesize tableView;
@synthesize projectList;
@synthesize viewController;
@synthesize currentProject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSError *error;
        NSString* projectFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.Projects"];
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:projectFolder error:&error];
        self.projectList = [[NSMutableArray alloc] init ];
        for (int i=0; i<[contents count]; i++)
        {
            NSString *currentPath = [projectFolder stringByAppendingPathComponent:[contents objectAtIndex:i]];
            BOOL isFolder = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:currentPath isDirectory:&isFolder];
            if (YES == isFolder)
            {
                [self.projectList addObject:[contents objectAtIndex:i]];
            }
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setCurrentProject:nil];
    [self.projectList removeAllObjects];
    [self setProjectList:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma tableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [viewController displayVirtualizeFilesInProject:[self.projectList objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"projectCell";
    UITableViewCell *cell;
    
    cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [self.projectList objectAtIndex:indexPath.row];
    
    if ([(NSString*)[self.projectList objectAtIndex:indexPath.row] compare:self.currentProject] == NSOrderedSame)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.projectList count];
}

@end
