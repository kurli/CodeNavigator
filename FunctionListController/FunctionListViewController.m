//
//  FileListViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 10/21/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "FunctionListViewController.h"
#import "Utils.h"
#import "FunctionListManager.h"
#import "DetailViewController.h"

@interface FunctionListViewController ()

@end

@implementation FunctionListViewController

@synthesize currentFilePath;
@synthesize activityIndicator;
@synthesize tagsArray;
@synthesize tableView;
@synthesize tagsArrayCopy;

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

- (void)viewDidUnload
{
    [self setActivityIndicator:nil];
    [self setTableView:nil];
    [self setSearchField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)refreshButtonClicked:(id)sender
{
    if (activityIndicator.hidden == NO) {
        return;
    }
    NSError* error;
    NSString* tagFile = [[Utils getInstance] getTagFileBySourceFile:self.currentFilePath];
    [[NSFileManager defaultManager] removeItemAtPath:tagFile error:&error];
    [[Utils getInstance] getFunctionListForFile:self.currentFilePath andCallback:^(NSArray* array){
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
        self.tagsArray = array;
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    [[Utils getInstance] getFunctionListForFile:self.currentFilePath andCallback:^(NSArray* array){
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
        self.tagsArray = array;
        [self.tableView reloadData];
        });
    }];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButtonClicked:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    [self.searchField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.searchField setAutocorrectionType:UITextAutocorrectionTypeNo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    return [tagsArray count];
}

-(void) addRoundedRectToPath:(CGContextRef) context andRect: (CGRect) rect andWidth:(float) ovalWidth andHeight:(float) ovalHeight
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) { // 1
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context); // 2
    CGContextTranslateCTM (context, CGRectGetMinX(rect), // 3
                           CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight); // 4
    fw = CGRectGetWidth (rect) / ovalWidth; // 5
    fh = CGRectGetHeight (rect) / ovalHeight; // 6
    CGContextMoveToPoint(context, fw, fh/2); // 7
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1); // 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // 9
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // 11
    CGContextClosePath(context); // 12
    CGContextRestoreGState(context); // 13
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SelectionCell";
    UITableViewCell *cell;
    
    cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TagItemCell" owner:self options:nil] lastObject];
        [cell setValue:identifier forKey:@"reuseIdentifier"];
    }
    FunctionItem* item = [tagsArray objectAtIndex:indexPath.row];
    [((UILabel *)[cell viewWithTag:101]) setText:item.name];
    //Draw icon
    UIImageView* imageView = (UIImageView*)[cell viewWithTag:100];
    UIGraphicsBeginImageContext(imageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.55 green:0.56 blue:0.81 alpha:1] CGColor]);
    CGRect rect = imageView.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    [self addRoundedRectToPath:context andRect:rect andWidth:7.0f andHeight:7.0f];
    CGContextFillPath(context);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);

    rect.origin.y = 5;
    [item.type drawInRect:rect withFont:[UIFont boldSystemFontOfSize:20] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    selectedItem = indexPath.row;
//    [tableView reloadData];
    int line = [(FunctionItem*)[tagsArray objectAtIndex:indexPath.row] line];
    NSString* js = @"";
    int lll = line;
    lll -= 8;
    if (lll <= 0)
        lll = 1;
    js = [NSString stringWithFormat:@"smoothScroll('L%d')", lll];
    [[Utils getInstance].detailViewController.activeWebView stringByEvaluatingJavaScriptFromString:js];
    js = [NSString stringWithFormat:@"FocusLine('L%d')",line];
    [[Utils getInstance].detailViewController.activeWebView  stringByEvaluatingJavaScriptFromString:js];
    [self dismissModalViewControllerAnimated:YES];
    [self.searchField resignFirstResponder];
}

-(GLfloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


#pragma mark SearchDelegate
- (IBAction)searchFileDoneButtonClicked:(id)sender
{
    if ([self.searchField.text length] == 0) {
        tagsArray = tagsArrayCopy;
        [tableView reloadData];
    }
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    tagsArrayCopy = tagsArray;
    tagsArray = nil;
}

- (void) searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        tagsArray = tagsArrayCopy;
        [tableView reloadData];
        return;
    }
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    NSString* searchLow = [searchText lowercaseString];
    NSString* itemLow;
    
    for (int i =0; i<[tagsArrayCopy count]; i++) {
        FunctionItem* item = [tagsArrayCopy objectAtIndex:i];
        itemLow = [item.name lowercaseString];

        if ([itemLow rangeOfString:searchLow].location != NSNotFound) {
            [result addObject:item];
        }
    }
    tagsArray = result;
    [tableView reloadData];
}


@end
