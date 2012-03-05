//
//  NavigationController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "NavigationController.h"
#import "cscope.h"

@implementation NavigationController

@synthesize searchBar;
@synthesize currentSourcePath;
@synthesize selectionList;
@synthesize searchKeyword;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    selectionList = [[NSArray alloc] initWithObjects:@"Find this symbol", @"Find global definition", @"Find called functions", @"Find f() calling this f()", @"Find text string", nil];
    for (UIView *subview in [searchBar subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [(UIButton *)subview setTitle:@"Search" forState:UIControlStateNormal];
            [(UIButton *)subview setEnabled:YES];
        }
    }
    selectedItem = 0;
}

- (void)viewDidUnload
{
    [self setSearchKeyword:nil];
    [self setSearchBar:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setSelectionList:nil];
    [self setCurrentSourcePath:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([searchKeyword length] != 0)
        [self setSearchItemText:searchKeyword];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma TableView

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [selectionList count];
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
    cell.textLabel.text = [selectionList objectAtIndex:indexPath.row];
    if (indexPath.row == selectedItem)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedItem = indexPath.row;
    [tableView reloadData];
}

#pragma mark - SearBar Delegate

-(void) searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
    [[Utils getInstance].detailViewController dismissNavigationManager];
    [[Utils getInstance].detailViewController releaseAllPopOver];
    
    NSString* searchText = _searchBar.text;
    if ([searchText length] <= 0)
        return;
    
    NSString* projectPath = [[Utils getInstance] getProjectFolder:self.currentSourcePath];
    NSString* sourcePath = [[Utils getInstance] getPathFromProject:self.currentSourcePath];
    [[Utils getInstance] cscopeSearch:searchText andPath:sourcePath andProject:projectPath andType:selectedItem andFromVir:NO];
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    [[Utils getInstance].detailViewController dismissNavigationManager];
    [[Utils getInstance].detailViewController releaseAllPopOver];
    
    NSString* searchText = _searchBar.text;
    if ([searchText length] <= 0)
        return;
    
    NSString* projectPath = [[Utils getInstance] getProjectFolder:self.currentSourcePath];
    NSString* sourcePath = [[Utils getInstance] getPathFromProject:self.currentSourcePath];
    [[Utils getInstance] cscopeSearch:searchText andPath:sourcePath andProject:projectPath andType:selectedItem andFromVir:NO];
}

-(void)setSearchItemText:(NSString *)keyword
{
    [searchBar setText:keyword];
    for (UIView *subview in [searchBar subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [(UIButton *)subview setTitle:@"Search" forState:UIControlStateNormal];
            if ([keyword length] > 0)
                [(UIButton *)subview setEnabled:YES];
            else
                [(UIButton *)subview setEnabled:NO];
        }
    }
}

@end
