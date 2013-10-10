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
    selectionList = [[NSArray alloc] initWithObjects:@"Highlight in current file", @"Find global definition", @"Find this symbol", @"Find called functions", @"Find f() calling this f()", @"Find text string", nil];
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        for (UIView *subview in [searchBar subviews]) {
            for (UIView* subview2 in [subview subviews]) {
                if ([subview2 isKindOfClass:[UIButton class]]) {
                    [(UIButton *)subview setTitle:@"Search" forState:UIControlStateNormal];
                    [(UIButton *)subview setEnabled:YES];
                }
            }
        }
    } else {
        for (UIView *subview in [searchBar subviews]) {
            if ([subview isKindOfClass:[UIButton class]]) {
                [(UIButton *)subview setTitle:@"Search" forState:UIControlStateNormal];
                [(UIButton *)subview setEnabled:YES];
            }
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

-(void) highlightInCurrentFile:(NSString*)searchText
{
    DetailViewController* detailViewController = [Utils getInstance].detailViewController;
    [detailViewController setSearchWord:searchText];
    NSError* error;
    NSString* currentDisplayFile = [[Utils getInstance].detailViewController getCurrentDisplayFile];
    currentDisplayFile =  [[Utils getInstance] getSourceFileByDisplayFile:currentDisplayFile];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString* fileContent = [NSString stringWithContentsOfFile: currentDisplayFile usedEncoding:&encoding error: &error];
    if (error != nil || fileContent == nil)
    {
        // Chinese GB2312 support 
        error = nil;
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        fileContent  = [NSString stringWithContentsOfFile:currentDisplayFile encoding:enc error:&error];
        
        if (fileContent == nil)
        {
            const NSStringEncoding *encodings = [NSString availableStringEncodings];  
            while ((encoding = *encodings++) != 0)  
            {
                fileContent = [NSString stringWithContentsOfFile: currentDisplayFile encoding:encoding error:&error];
                if (fileContent != nil && error == nil)
                {
                    break;
                }
            }
        }
    }
    if (fileContent == nil || [fileContent length] == 0) {
        return;
    }
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    NSArray* array =[fileContent componentsSeparatedByString:@"\n"];
    int index;
    for (index = 0; index<[array count]; index++) {
        NSString* item = [array objectAtIndex:index];
        NSRange range;
        range = [item rangeOfString:detailViewController.searchWord options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [resultArray addObject:[NSString stringWithFormat:@"%d",index+1]];
        }
    }
    detailViewController.highlightLineArray = resultArray;
    //highlight all
    if ([resultArray count] == 0) {
        return;
    }
    NSMutableString *str = [[NSMutableString alloc] init];
    for (int i=0; i<[resultArray count]-1; i++) {
        [str appendFormat:@"L%@,",[resultArray objectAtIndex:i]];
    }
    [str appendString:@"L"];
    [str appendString:[resultArray objectAtIndex:[resultArray count]-1]];
    //clear highlight
    [detailViewController.activeWebView stringByEvaluatingJavaScriptFromString:@"clearHighlight()"];
    NSString* highlightJS = [NSString stringWithFormat:@"highlight_keyword_by_lines('%@','%@')",str, detailViewController.searchWord];
    // HAKE way to scroll to position
    NSString* returnVal = [detailViewController.activeWebView stringByEvaluatingJavaScriptFromString:highlightJS];
    int currentHighlightLine = [returnVal intValue];
    if (currentHighlightLine > 0) {
        [detailViewController setCurrentSearchFocusLine:currentHighlightLine-1];
    }else {
        [detailViewController setCurrentSearchFocusLine:-1];
    }
    [detailViewController downSelectButton];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
    [[Utils getInstance].detailViewController dismissPopovers];
    [[Utils getInstance].detailViewController releaseAllPopOver];
    
#ifdef IPHONE_VERSION
    [self dismissViewControllerAnimated:NO completion:nil];
#endif
    
    NSString* searchText = _searchBar.text;
    if ([searchText length] <= 0)
        return;
    
    if (selectedItem == 0) {
        [[Utils getInstance].detailViewController dismissPopovers];
        [self highlightInCurrentFile:searchText];
        return;
    }
    selectedItem = selectedItem -1;
    if (selectedItem == 0) {
        selectedItem = 1;
    } else if (selectedItem == 1)
    {
        selectedItem = 0;
    }
    
    NSString* projectPath = [[Utils getInstance] getProjectFolder:self.currentSourcePath];
    //NSString* sourcePath = [[Utils getInstance] getPathFromProject:self.currentSourcePath];
    [[Utils getInstance] cscopeSearch:searchText andPath:nil andProject:projectPath andType:selectedItem andFromVir:NO];
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    [[Utils getInstance].detailViewController dismissPopovers];
    [[Utils getInstance].detailViewController releaseAllPopOver];
    
#ifdef IPHONE_VERSION
    [self dismissViewControllerAnimated:NO completion:nil];
#endif
    
    NSString* searchText = _searchBar.text;
    if ([searchText length] <= 0)
        return;
    
    if (selectedItem == 0) {
        [[Utils getInstance].detailViewController dismissPopovers];
        [self highlightInCurrentFile:searchText];
        return;
    }
    selectedItem = selectedItem -1;
    if (selectedItem == 0) {
        selectedItem = 1;
    } else if (selectedItem == 1)
    {
        selectedItem = 0;
    }
    
    NSString* projectPath = [[Utils getInstance] getProjectFolder:self.currentSourcePath];
    //NSString* sourcePath = [[Utils getInstance] getPathFromProject:self.currentSourcePath];
    [[Utils getInstance] cscopeSearch:searchText andPath:nil andProject:projectPath andType:selectedItem andFromVir:NO];
}

-(void)setSearchItemText:(NSString *)keyword
{
    [searchBar setText:keyword];
    
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        for (UIView *subview in [searchBar subviews]) {
            for (UIView* subview2 in [subview subviews]) {
                if ([subview2 isKindOfClass:[UIButton class]]) {
                    [(UIButton *)subview2 setTitle:@"Search" forState:UIControlStateNormal];
                    if ([keyword length] > 0)
                        [(UIButton *)subview2 setEnabled:YES];
                    else
                        [(UIButton *)subview2 setEnabled:NO];
                    return;
                }
            }
        }
    } else {
        for (UIView *subview in [searchBar subviews]) {
            if ([subview isKindOfClass:[UIButton class]]) {
                [(UIButton *)subview setTitle:@"Search" forState:UIControlStateNormal];
                if ([keyword length] > 0)
                    [(UIButton *)subview setEnabled:YES];
                else
                    [(UIButton *)subview setEnabled:NO];
                return;
            }
        }
    }
}

@end
