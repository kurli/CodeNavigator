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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.detailViewController.activeWebView == self.detailViewController.webView) {
        searchBarUI.text = self.detailViewController.searchWordU;
    } else {
        searchBarUI.text = self.detailViewController.searchWordD;
    }
    [self.searchBarUI setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.searchBarUI setAutocorrectionType:UITextAutocorrectionTypeNo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void) doSearch: (BOOL)doScroll andWebView:(UIWebView *)webView andStrict:(BOOL)isStrick
{
    NSString* currentDisplayFile;
    if (webView == detailViewController.webView) {
        NSString* path = [detailViewController.upHistoryController pickTopLevelUrl];
        currentDisplayFile = [detailViewController.upHistoryController getUrlFromHistoryFormat:path];
    } else {
        NSString* path = [detailViewController.downHistoryController pickTopLevelUrl];
        currentDisplayFile = [detailViewController.downHistoryController getUrlFromHistoryFormat:path];
    }
    currentDisplayFile =  [[Utils getInstance] getSourceFileByDisplayFile:currentDisplayFile];
    NSString* fileContent = [[Utils getInstance] getFileContent:currentDisplayFile];
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    NSArray* array =[fileContent componentsSeparatedByString:@"\n"];
    int index;
    NSString* searchWord;
    if (webView == self.detailViewController.webView) {
        searchWord = self.detailViewController.searchWordU;
    } else {
        searchWord = self.detailViewController.searchWordD;
    }
    for (index = 0; index<[array count]; index++) {
        NSString* item = [array objectAtIndex:index];
        NSRange range;
        
        if (isStrick) {
            while ([item length] > 0) {
                range = [item rangeOfString:searchWord options:NSCaseInsensitiveSearch];
                if (range.location != NSNotFound) {
                    char tmp;
                    // Check left
                    if (range.location > 0) {
                        tmp = [item characterAtIndex:range.location-1];
                        if ((tmp>'a'&&tmp<'z') || (tmp>'A'&&tmp<'Z') || tmp == '_') {
                            // Check failed, check remaining str
                            if (range.location + range.length < [item length]) {
                                item = [item substringFromIndex:range.location + range.length];
                                continue;
                            } else {
                                item = nil;
                                break;
                            }
                        }
                    }
                    // Check right
                    if (range.location + range.length < [item length]) {
                        tmp = [item characterAtIndex:range.location + range.length];
                        if ((tmp>'a'&&tmp<'z') || (tmp>'A'&&tmp<'Z') || tmp == '_') {
                            // Check failed, check remaining str
                            if (range.location +range.length < [item length]) {
                                item = [item substringFromIndex:range.location + range.length];
                                continue;
                            } else {
                                item = nil;
                                break;
                            }
                        }
                    }
                    //Check succeed
                    break;
                } else {
                    item = nil;
                }
            }
            if ([item length] > 0) {
                [resultArray addObject:[NSString stringWithFormat:@"%d",index+1]];
            }
        } else {
            range = [item rangeOfString:searchWord options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [resultArray addObject:[NSString stringWithFormat:@"%d",index+1]];
            }
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
    //[webView stringByEvaluatingJavaScriptFromString:@"clearHighlight()"];
    NSString* highlightJS = [NSString stringWithFormat:@"highlight_keyword_by_lines('%@','%@')",str, searchWord];
    // HAKE way to scroll to position
    NSString* returnVal = [webView stringByEvaluatingJavaScriptFromString:highlightJS];
    int currentHighlightLine = [returnVal intValue];
    if (currentHighlightLine > 0) {
        [self.detailViewController setCurrentSearchFocusLine:currentHighlightLine-1];
    }else {
        [self.detailViewController setCurrentSearchFocusLine:-1];
    }
    if (doScroll) {
        [self.detailViewController downSelectButton];
    }
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
        if (self.detailViewController.activeWebView == self.detailViewController.webView) {
            self.detailViewController.searchWordU = searchText;
        } else {
            self.detailViewController.searchWordD = searchText;
        }
        [searchBar setShowsCancelButton:NO animated:YES];
        [searchBar resignFirstResponder];
//        [self.detailViewController releaseAllPopOver];
        [self doSearch:TRUE andWebView:self.detailViewController.activeWebView andStrict:NO];
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
