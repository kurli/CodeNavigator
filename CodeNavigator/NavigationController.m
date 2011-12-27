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

@synthesize detailViewController = _detailViewController;
@synthesize searchBar;
@synthesize currentSearchProject;

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
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    selectionList = nil;
    self.detailViewController = nil;
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
    [self.detailViewController dismissNavigationManager];
    
    NSString* searchText = _searchBar.text;
    if ([searchText length] <= 0)
        return;
    
    [self cscopeSearch:searchText];
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    [self.detailViewController dismissNavigationManager];
    
    NSString* searchText = _searchBar.text;
    if ([searchText length] <= 0)
        return;
    
    [self cscopeSearch:searchText];
}

#pragma cscope

-(void) cscopeSearch:(NSString *)text
{
    if ([Utils getInstance].analyzeThread.isExecuting == YES)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Project Analyzing is in progress, Please wait untile analyze finished"];
        return;
    }
    
    NSString* fileList = nil;
    NSString* dbFile = nil;
    BOOL isExist = NO;

    if ([currentSearchProject length] == 0)
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    
    fileList = [currentSearchProject stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
    dbFile = [currentSearchProject stringByAppendingPathComponent:@"project.lgz_db"];
    
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileList];
    if (isExist == NO)
    {
        [[Utils getInstance] analyzeProject:currentSearchProject andForceCreate:YES];
        isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileList];
        if (isExist == NO)
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:dbFile];
    if (isExist == NO)
    {
        [[Utils getInstance] analyzeProject:currentSearchProject andForceCreate:YES];
        isExist = [[NSFileManager defaultManager] fileExistsAtPath:dbFile];
        if (isExist == NO)
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a project"];
        return;
    }
    char* _result = 0;
    NSString* result = @"";
    cscope_set_base_dir([currentSearchProject UTF8String]);
    switch (selectedItem) {
        case 0:
            _result = cscope_find_this_symble([text UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 1:
            _result = cscope_find_global([text UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 2:
            _result = cscope_find_called_functions([text UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 3:
            _result = cscope_find_functions_calling_a_function([text UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 4:
            _result = cscope_find_text_string([text UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 5:
            _result = cscope_find_a_file([text UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
        case 6:
            _result = cscope_find_files_including_a_file([text UTF8String], [dbFile UTF8String], [fileList UTF8String]);
            break;
            
        default:
            break;
    }
    if (_result != 0)
    {
        result = [NSString stringWithCString:_result encoding:NSUTF8StringEncoding];
        free(_result);
        _result = 0;
        NSArray* lines = [result componentsSeparatedByString:@"\n"];
        [self.detailViewController setResultListAndAnalyze:lines andKeyword:text];
    }
    else
    {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Low Memorry!"];
    }
}

-(void)setSearchKeyword:(NSString *)keyword
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
