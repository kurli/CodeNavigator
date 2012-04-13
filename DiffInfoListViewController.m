//
//  DiffInfoListViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 4/4/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "DiffInfoListViewController.h"
#import "GitDiffViewController.h"

@implementation DiffInfoListViewController
@synthesize diffAnalyzeList;
@synthesize gitDiffViewController;

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

- (void)dealloc
{
    [self setDiffAnalyzeList:nil];
    [self setGitDiffViewController:nil];
}

- (void)viewDidUnload
{
    //[self setDiffAnalyzeList:nil];
    //[self setGitDiffViewController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma TableView

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [diffAnalyzeList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"GitDiffInfoCellIdentifier";
    UITableViewCell *cell;
    
    cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GidDiffTableCell" owner:self options:nil] lastObject];
        [cell setValue:identifier forKey:@"reuseIdentifier"];
    }
    if (indexPath.row >= [diffAnalyzeList count]) {
        return cell;
    }
    NSString* diffInfo = [diffAnalyzeList objectAtIndex:indexPath.row];
    NSArray* array = [diffInfo componentsSeparatedByString:@"\n"];
    if ([array count] <= 0) {
        return cell;
    }
    
    UILabel* newLinesLabel = (UILabel*)[cell viewWithTag:101];
    UILabel* typeLabel = (UILabel*)[cell viewWithTag:102];
    UILabel* oldLinesLabel = (UILabel*)[cell viewWithTag:103];
    
    NSString* diff = [array objectAtIndex:0];
    unichar type = -1;
    int index = 0;
    while (true) {
        if (index >= [diff length]) {
            return cell;
        }
        unichar c = [diff characterAtIndex:index];
        if (c == 'a' || c == 'c' || c == 'd') {
            type = c;
            break;
        }
        index++;
    }
    if (index+1 >= [diff length]) {
        return cell;
    }
    NSString* startLines = [diff substringToIndex:index];
    NSString* endLines = [diff substringFromIndex:index+1];
    newLinesLabel.text = startLines;
    oldLinesLabel.text = endLines;
    if (type == 'c') {
        typeLabel.text = @"Changed";
        [typeLabel setTextColor:[UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1]];
    }
    else if (type == 'a')
    {
        typeLabel.text = @"Added";
        [typeLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:1]];
    }
    else if (type == 'd')
    {
        typeLabel.text = @"Deleted";
        [typeLabel setTextColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.gitDiffViewController showDiffInfo:indexPath.row];
}

@end
