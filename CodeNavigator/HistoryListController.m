//
//  HistoryListController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 1/26/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "HistoryListController.h"
#import "Utils.h"
#import "HistoryController.h"
#import "DetailViewController.h"

@implementation HistoryListController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void) viewWillAppear:(BOOL)animated
{
    if ([[Utils getInstance].detailViewController.historyController getCount] == 0)
        return;
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[[Utils getInstance].detailViewController.historyController getCurrentDisplayIndex] inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma TableView

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[Utils getInstance].detailViewController.historyController getCount];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SelectionCell";
    UITableViewCell *cell;
    
    cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString* str = [[Utils getInstance].detailViewController.historyController getPathByIndex:indexPath.row];
    str = [[Utils getInstance].detailViewController.historyController getUrlFromHistoryFormat:str];
    str = [[str pathComponents] lastObject];
    str = [[Utils getInstance] getSourceFileByDisplayFile:str];
    cell.textLabel.text = str;
    if (indexPath.row == [[Utils getInstance].detailViewController.historyController getCurrentDisplayIndex]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController* detailViewController = [Utils getInstance].detailViewController;
    NSString* historyStr = [detailViewController.historyController getPathByIndex:indexPath.row];
    
    int location = [detailViewController getCurrentScrollLocation];
    [detailViewController.historyController updateCurrentScrollLocation:location];
    if (historyStr == nil)
        return;
    [detailViewController.historyController setIndex:indexPath.row];
    [detailViewController restoreToHistory:historyStr];
}

@end
