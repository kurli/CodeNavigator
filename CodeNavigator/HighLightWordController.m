//
//  HighLightWordController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 1/11/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "HighLightWordController.h"
#import "DetailViewController.h"

@implementation HighLightWordController

@synthesize detailViewController;
@synthesize searchBarUI;

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
    //[self setDetailViewController:nil];
    [self setSearchBarUI:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void) searchWrapper
{
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
        range = [item rangeOfString:self.detailViewController.searchWord options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [resultArray addObject:[NSString stringWithFormat:@"%d",index+1]];
        }
    }
    self.detailViewController.highlightLineArray = resultArray;
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
    [self.detailViewController.activeWebView stringByEvaluatingJavaScriptFromString:@"clearHighlight()"];
    NSString* highlightJS = [NSString stringWithFormat:@"highlight_keyword_by_lines('%@','%@')",str, self.detailViewController.searchWord];
    // HAKE way to scroll to position
    NSString* returnVal = [self.detailViewController.activeWebView stringByEvaluatingJavaScriptFromString:highlightJS];
    int currentHighlightLine = [returnVal intValue];
    if (currentHighlightLine > 0) {
        [self.detailViewController setCurrentSearchFocusLine:currentHighlightLine-1];
    }else {
        [self.detailViewController setCurrentSearchFocusLine:-1];
    }
    [self.detailViewController downSelectButton];
}

#pragma mark - SearchBar Delegate

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    if (nil == self.detailViewController.activeWebView)
//        return;
//        
//    NSString* returnValue;
//    NSString* highlightJS;
//    if ([searchText length] == 0)
//        highlightJS = [NSString stringWithFormat:@"clearHighlight();"];
//    else if ([searchText length] %5 == 0)
//    {
//        highlightJS = [NSString stringWithFormat:@"highlight('%@')",searchText];
//        returnValue = [self.detailViewController.activeWebView stringByEvaluatingJavaScriptFromString:highlightJS];
//        //NSString* countValue = [NSString stringWithFormat:@"0/%@",returnValue];
//        //[self.countTextField setText:countValue];
////        [self.detailViewController setCurrentSearchFocusLine:0 andTotal:[returnValue intValue]];
//        self.detailViewController.searchWord = searchText;
//        [self searchWrapper];
//    }
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    NSString* returnValue;
    NSString* highlightJS;
    NSString* searchText;
    searchText = searchBar.text;
    if ([searchText length] == 0)
        highlightJS = [NSString stringWithFormat:@"clearHighlight();"];
    else
    {
        highlightJS = [NSString stringWithFormat:@"highlight('%@')",searchText];
//    returnValue = [self.detailViewController.activeWebView    stringByEvaluatingJavaScriptFromString:highlightJS];
        //NSString* countValue = [NSString stringWithFormat:@"0/%@",returnValue];
        //[self.countTextField setText:countValue];
        self.detailViewController.searchWord = searchText;
        [searchBar setShowsCancelButton:NO animated:YES];
        [searchBar resignFirstResponder];
//        [self.detailViewController releaseAllPopOver];
        [self searchWrapper];
    }
#ifdef IPHONE_VERSION
    [self dismissViewControllerAnimated:NO completion:nil];
#endif
}

#ifdef IPHONE_VERSION
- (IBAction)searchButtonClicked:(id)sender {
    [self searchBarSearchButtonClicked:searchBarUI];
//    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
#endif
- (IBAction)gotoHighlight:(id)sender {
    [self.detailViewController gotoHighlight:sender];
}
@end
