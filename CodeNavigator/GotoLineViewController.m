//
//  GotoLineViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GotoLineViewController.h"

@implementation GotoLineViewController

@synthesize detailViewController = _detailViewController;
@synthesize textField = _textField;

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
    [self setTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)goButtonClicked:(id)sender {
    NSString* text = [_textField text];
    int line = [text intValue];
    NSString* js = @"";
    js = [NSString stringWithFormat:@"smoothScroll('L%d')", line];
    [_detailViewController.webView stringByEvaluatingJavaScriptFromString:js];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int line = [textField.text intValue];
    if (line < 0)
        return NO;
    [self goButtonClicked:textField];
    return NO;
}
@end
