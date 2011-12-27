//
//  AnalyzeInfoController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AnalyzeInfoController.h"
#import "Utils.h"
#import "DetailViewController.h"

@implementation AnalyzeInfoController
@synthesize activityIndicator;
@synthesize infoLabel;

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
    analyzeFinished = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setActivityIndicator:nil];
    [self setInfoLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (analyzeFinished ==NO)
    {
        [self.infoLabel setText:[NSString stringWithFormat:@"Analyzing \"%@\" in progress",[Utils getInstance].analyzePath]];
        [self.activityIndicator startAnimating];
    }
    else
    {
        [self.infoLabel setText:[NSString stringWithFormat:@"Analyze \"%@\" Finished",[Utils getInstance].analyzePath]];
        [self.activityIndicator stopAnimating];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    if (analyzeFinished == YES)
    {
        [[Utils getInstance].detailViewController.analyzeInfoBarButton setEnabled:NO];
        analyzeFinished = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) finishAnalyze
{
    analyzeFinished = YES;
    [self.infoLabel setText:[NSString stringWithFormat:@"Analyze \"%@\" Finished",[Utils getInstance].analyzePath]];
    [self.activityIndicator stopAnimating];
}

@end
