//
//  ResultViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "ResultViewController.h"

@implementation ResultFile

@synthesize fileName = _fileName;

@synthesize contents = _contents;

@end

@implementation ResultViewController

@synthesize detailViewController = _detailViewController;

@synthesize resultFileList = _resultFileList;

@synthesize lineModeViewController = _lineModeViewController;

@synthesize tableView = _tableView;

@synthesize keyword = _keyword;

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
    currentFileIndex = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setKeyword:nil];
    [self setDetailViewController:nil];
    [self setResultFileList:nil];
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
    CGSize size =  self.detailViewController.splitViewController.view.frame.size;
    size.height = size.height/3;
    size.width = size.width;
    self.contentSizeForViewInPopover = size;
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
        return [_resultFileList count];
    else
        return [((ResultFile*)[_resultFileList objectAtIndex:currentFileIndex]).contents count];
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
        cell.textLabel.text = ((ResultFile*)[_resultFileList objectAtIndex:indexPath.row]).fileName;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:elementCellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ResultTableCellView" owner:self options:nil] lastObject];
        }
        NSString* element = [((ResultFile*)[_resultFileList objectAtIndex:currentFileIndex]).contents objectAtIndex:indexPath.row];
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
            self.lineModeViewController = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
        [self.lineModeViewController setTableViewMode:TABLEVIEW_CONTENT];
        [self.lineModeViewController setDetailViewController:self.detailViewController];
        [self.lineModeViewController setResultFileList:self.resultFileList];
        [self.lineModeViewController setFileIndex:currentFileIndex];
        self.lineModeViewController.keyword = _keyword;
        [self.lineModeViewController.tableView reloadData];
        [self.lineModeViewController setTitle:((ResultFile*)[_resultFileList objectAtIndex:currentFileIndex]).fileName];
        [self.navigationController pushViewController:self.lineModeViewController animated:YES];
    }
    else
    {
        NSString* content = [((ResultFile*)[_resultFileList objectAtIndex:currentFileIndex]).contents objectAtIndex:indexPath.row];
        NSArray* components = [content componentsSeparatedByString:@" "];
        if ([components count] < 3)
            return;
        NSString* line = [components objectAtIndex:1];
        NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
        filePath = [filePath stringByAppendingPathComponent:((ResultFile*)[_resultFileList objectAtIndex:currentFileIndex]).fileName];
        [_detailViewController gotoFile:filePath andLine:line andKeyword:_keyword];
        //Inorder to dissmiss the Result popup dialoa
        [_detailViewController resultPopUp:nil];
    }
}

#pragma own function

-(int) fileExistInResultFileList:(NSString *)_file
{
    for (int i=0; i<[_resultFileList count]; i++)
    {
        ResultFile* file = [_resultFileList objectAtIndex:i];
        if ([file.fileName compare:_file] == NSOrderedSame)
            return i;
    }
    return -1;
}

-(BOOL) setResultListAndAnalyze:(NSArray *)list andKeyword:(NSString *)__keyword
{
    if (_resultFileList == nil)
        _resultFileList = [[NSMutableArray alloc] init];
    else
        [_resultFileList removeAllObjects];
    
    for (int i=0; i<[list count]; i++)
    {
        NSArray* array = [[list objectAtIndex:i] componentsSeparatedByString:@" "];
        if ([array count] < 2)
            continue;
        int index = [self fileExistInResultFileList:[array objectAtIndex:0]];
        if (index == -1)
        {
            ResultFile* element = [[ResultFile alloc] init];
            element.fileName = [array objectAtIndex:0];
            element.contents = [[NSMutableArray alloc] init];
            NSString* tmp = @"";
            tmp = [tmp stringByAppendingString:[array objectAtIndex:1]];
            for (int j = 2; j<[array count]; j++)
            {
                tmp = [tmp stringByAppendingFormat:@" %@", [array objectAtIndex:j]];
            }
            [element.contents addObject:tmp];
            [_resultFileList addObject:element];
        }
        else
        {
            if ([_resultFileList count] > 30)
                continue;
            ResultFile* element = [_resultFileList objectAtIndex:index];
            NSString* tmp = @"";
            tmp = [tmp stringByAppendingString:[array objectAtIndex:1]];
            for (int j = 2; j<[array count]; j++)
            {
                tmp = [tmp stringByAppendingFormat:@" %@", [array objectAtIndex:j]];
            }
            [element.contents addObject:tmp];
        }
    }
    _keyword = __keyword;
    [self.tableView reloadData];
    [self setTitle:[NSString stringWithFormat:@"Result files for \"%@\"", _keyword]];
    [self.navigationController popViewControllerAnimated:NO];
    if ([list count] == 2)
    {
        NSString* content = [((ResultFile*)[_resultFileList objectAtIndex:0]).contents objectAtIndex:0];
        NSArray* components = [content componentsSeparatedByString:@" "];
        if ([components count] < 3)
            return NO;
        NSString* line = [components objectAtIndex:1];
        NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
        filePath = [filePath stringByAppendingPathComponent:((ResultFile*)[_resultFileList objectAtIndex:0]).fileName];
        [_detailViewController gotoFile:filePath andLine:line andKeyword:_keyword];
        return NO;
    }
    else if ([list count] == 1)
    {
        [[Utils getInstance] alertWithTitle:@"Result" andMessage:@"No Result Found"];
        return NO;
    }
    return YES;
}

-(void) setTableViewMode:(TableViewMode)mode
{
    tableviewMode = mode;
}

-(void) setFileIndex:(int)index
{
    currentFileIndex = index;
}

@end
