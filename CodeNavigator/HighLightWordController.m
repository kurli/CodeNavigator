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
    [self setDetailViewController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - SearchBar Delegate

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (nil == self.detailViewController.webView)
        return;
    
    NSString* returnValue;
    NSString* highlightJS;
    if ([searchText length] == 0)
        highlightJS = [NSString stringWithFormat:@"highlight('liguangzhen+++++++++++++++++++++++++++++++++++++++++')"];
    else if ([searchText length] %5 == 0)
    {
        highlightJS = [NSString stringWithFormat:@"highlight('%@')",searchText];
        returnValue = [self.detailViewController.webView stringByEvaluatingJavaScriptFromString:highlightJS];
        //NSString* countValue = [NSString stringWithFormat:@"0/%@",returnValue];
        //[self.countTextField setText:countValue];
        [self.detailViewController setCurrentSearchFocusLine:0 andTotal:[returnValue intValue]];
        self.detailViewController.searchWord = searchText;
    }
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString* returnValue;
    NSString* highlightJS;
    NSString* searchText;
    searchText = searchBar.text;
    if ([searchText length] == 0)
        highlightJS = [NSString stringWithFormat:@"highlight('liguangzhen+++++++++++++++++++++++++++++++++++++++++')"];
    else
        highlightJS = [NSString stringWithFormat:@"highlight('%@')",searchText];
    returnValue = [self.detailViewController.webView stringByEvaluatingJavaScriptFromString:highlightJS];
    //NSString* countValue = [NSString stringWithFormat:@"0/%@",returnValue];
    //[self.countTextField setText:countValue];
    [self.detailViewController setCurrentSearchFocusLine:0 andTotal:[returnValue intValue]];
    self.detailViewController.searchWord = searchText;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.detailViewController releaseAllPopOver];
}

@end
