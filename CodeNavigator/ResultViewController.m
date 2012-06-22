//
//  ResultViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "ResultViewController.h"
#import "VirtualizeViewController.h"

@implementation ResultViewController

@synthesize detailViewController = _detailViewController;

@synthesize lineModeViewController = _lineModeViewController;

@synthesize tableView = _tableView;

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
    if (tableviewMode == TABLEVIEW_FILE) 
        [self setTitle:[NSString stringWithFormat:@"Result files for \"%@\"", [Utils getInstance].searchKeyword]];
    // Do any additional setup after loading the view from its nib.
    if ([[Utils getInstance] getResultViewTableViewMode] != tableviewMode)
    {
        currentFileIndex = [[Utils getInstance] getResultViewFileIndex];
        if (self.lineModeViewController == nil)
#ifdef IPHONE_VERSION
            self.lineModeViewController = [[ResultViewController alloc] initWithNibName:@"ResultViewController-iPhone" bundle:nil];
#else
            self.lineModeViewController = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
#endif        
        [self.lineModeViewController setTableViewMode:TABLEVIEW_CONTENT];
        [self.lineModeViewController setDetailViewController:self.detailViewController];
        [self.lineModeViewController setFileIndex:currentFileIndex];
        [self.lineModeViewController.tableView reloadData];
        [self.lineModeViewController setTitle:((ResultFile*)[[Utils getInstance].resultFileList objectAtIndex:currentFileIndex]).fileName];
        [self.navigationController pushViewController:self.lineModeViewController animated:NO];
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setDetailViewController:nil];
    [self setLineModeViewController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGSize size =  self.detailViewController.view.frame.size;
    size.height = size.height/3;
    size.width = size.width;
    self.contentSizeForViewInPopover = size;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[Utils getInstance] setResultViewTableViewMode:tableviewMode];
}

#pragma TableView delegate

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableviewMode == TABLEVIEW_FILE)
        return [[Utils getInstance].resultFileList count];
    else
        return [((ResultFile*)[[Utils getInstance].resultFileList objectAtIndex:currentFileIndex]).contents count];
}

- (IBAction)addButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UIView *contentView = [button superview];
    UITableViewCell *cell = (UITableViewCell*)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString* element = [((ResultFile*)[[Utils getInstance].resultFileList objectAtIndex:currentFileIndex]).contents objectAtIndex:indexPath.row];
    NSArray* components = [element componentsSeparatedByString:@" "];
    if ([components count] < 3)
    {
        NSLog(@"ResultViewController:addButtonClicked add Failed");
        return;
    }
    int line = [[components objectAtIndex:1] intValue];

    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    filePath = [filePath stringByAppendingPathComponent:((ResultFile*)[[Utils getInstance].resultFileList objectAtIndex:currentFileIndex]).fileName];
    NSString* proj = [[Utils getInstance] getProjectFolder:filePath];
    
    if ([[Utils getInstance] getSearchType] != 2 && [[Utils getInstance] getSearchType] != 3)
    {
        [[Utils getInstance].detailViewController.virtualizeViewController addEntry:[Utils getInstance].searchKeyword andFile:filePath andLine:line andProject:proj];
    }
    else
    {
        [[Utils getInstance].detailViewController.virtualizeViewController addEntry:[components objectAtIndex:0] andFile:filePath andLine:line andProject:proj];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *fileCellIdentifier = @"FileCell";
    static NSString *elementCellIdentifier = @"ElementCell";
    UITableViewCell *cell;
    
    if (tableviewMode == TABLEVIEW_FILE)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:fileCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileCellIdentifier];
        }
        cell.textLabel.text = ((ResultFile*)[[Utils getInstance].resultFileList objectAtIndex:indexPath.row]).fileName;
    }
    else
    {
        UIButton* addButton = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:elementCellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ResultTableCellView" owner:self options:nil] lastObject];
            [cell setValue:elementCellIdentifier forKey:@"reuseIdentifier"];
            addButton = (UIButton*)[cell viewWithTag:123];
            [addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }

        NSString* element = [((ResultFile*)[[Utils getInstance].resultFileList objectAtIndex:currentFileIndex]).contents objectAtIndex:indexPath.row];
        NSArray* components = [element componentsSeparatedByString:@" "];
        if ([components count] < 3)
        {
            [((UILabel *)[cell viewWithTag:101]) setText:@"Scope: <unknown> line: <unknown>"];
            [((UILabel *)[cell viewWithTag:102]) setText:element];
            return cell;
        }
        NSString* scope = [components objectAtIndex:0];
        int line = [[components objectAtIndex:1] intValue];
        NSString* content = [components objectAtIndex:2];
        for (int i = 3; i<[components count]; i++)
        {
            content = [content stringByAppendingFormat:@" %@",[components objectAtIndex:i]];
        }
        NSString* line1 = @"";
        NSString* line2 = @"";
        line1 = [line1 stringByAppendingFormat:@"Scope: %@ \t\t Line: %d", scope, line];
        line2 = [line2 stringByAppendingFormat:@"%@", content];
        [((UILabel *)[cell viewWithTag:101]) setText:line1];
        [((UILabel *)[cell viewWithTag:102]) setText:line2];
        
        if ([[Utils getInstance].detailViewController.virtualizeViewController isNeedGetResultFromCscope] == YES)
        {
            // 2 called, 3 calling
            if ([[Utils getInstance] getSearchType] != 2 && [[Utils getInstance] getSearchType] != 3)
            {
                if ([[Utils getInstance].detailViewController.virtualizeViewController checkWhetherExistInCurrentEntry:[Utils getInstance].searchKeyword andLine:[components objectAtIndex:1]] == NO )
                    [addButton setHidden:NO];
            }
            else
            {
                NSString* word;
                //For find called function
                if ([[Utils getInstance] getSearchType] == 2)
                    word = scope;
                else
                    word = [Utils getInstance].searchKeyword;

                if ([[Utils getInstance].detailViewController.virtualizeViewController checkWhetherExistInCurrentEntry:word andLine:[components objectAtIndex:1]] == NO )
                    [addButton setHidden:NO];
            }
        }
        else
            [addButton setHidden:YES];
    }
    return cell;
}

-(GLfloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableviewMode == TABLEVIEW_FILE)
    {
        return 50;
    }
    else
        return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableviewMode == TABLEVIEW_FILE)
    {
        currentFileIndex = indexPath.row;
        if (self.lineModeViewController == nil)
#ifdef IPHONE_VERSION
            self.lineModeViewController = [[ResultViewController alloc] initWithNibName:@"ResultViewController-iPhone" bundle:nil];
#else
            self.lineModeViewController = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
#endif        
        [self.lineModeViewController setTableViewMode:TABLEVIEW_CONTENT];
        [self.lineModeViewController setDetailViewController:self.detailViewController];
        [self.lineModeViewController setFileIndex:currentFileIndex];
        [self.lineModeViewController.tableView reloadData];
        [self.lineModeViewController setTitle:((ResultFile*)[[Utils getInstance].resultFileList objectAtIndex:currentFileIndex]).fileName];
        [self.navigationController pushViewController:self.lineModeViewController animated:YES];
    }
    else
    {
#ifdef IPHONE_VERSION
        [self dismissViewControllerAnimated:NO completion:nil];
#endif
        
        NSString* content = [((ResultFile*)[[Utils getInstance].resultFileList objectAtIndex:currentFileIndex]).contents objectAtIndex:indexPath.row];
        NSArray* components = [content componentsSeparatedByString:@" "];
        if ([components count] < 3)
            return;
        NSString* line = [components objectAtIndex:1];
        NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
        filePath = [filePath stringByAppendingPathComponent:((ResultFile*)[[Utils getInstance].resultFileList objectAtIndex:currentFileIndex]).fileName];
        if ([[Utils getInstance] getSearchType] != 2)
        [[Utils getInstance].detailViewController gotoFile:filePath andLine:line andKeyword:[Utils getInstance].searchKeyword];
        else
        {
            [[Utils getInstance].detailViewController gotoFile:filePath andLine:line andKeyword:[components objectAtIndex:0]];
        }
        //[_detailViewController resultPopUp:nil];
    }
}

#pragma own function

-(void) setTableViewMode:(TableViewMode)mode
{
    tableviewMode = mode;
    [[Utils getInstance] setResultViewTableViewMode:mode];
}

-(void) setFileIndex:(int)index
{
    currentFileIndex = index;
    [[Utils getInstance] setResultViewFileIndex:index];
}

#ifdef IPHONE_VERSION
- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
#endif

@end
