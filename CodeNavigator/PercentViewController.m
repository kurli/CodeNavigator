//
//  PercentViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 1/29/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "PercentViewController.h"
#import "DetailViewController.h"

@implementation PercentViewController
@synthesize percentLable;
@synthesize percentProgressBar;
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
    [self setPercentLable:nil];
    [self setPercentProgressBar:nil];
    [self setPercentProgressBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated
{
    NSString* str = [self.detailViewController.activeWebView stringByEvaluatingJavaScriptFromString:@"bodyHeight()"];
    bodyHeight = [str intValue];
    int height = 0;
    if (bodyHeight > detailViewController.activeWebView.frame.size.height)
        height = bodyHeight - detailViewController.activeWebView.frame.size.height;
    else
        height = bodyHeight;
    int currentLocation = [self.detailViewController getCurrentScrollLocation];
    if (currentLocation == 0)
        currentLocation = 1;
    float percent = (float)currentLocation/(float)(height);
    str = [NSString stringWithFormat:@"%.02f%%", percent*100];
    [percentLable setText:str];
    [percentProgressBar setValue:percent];
}

- (IBAction)sliderChanged:(id)sender {
    UISlider* slider = (UISlider*)sender;
    int height = 0;
    if (bodyHeight > detailViewController.activeWebView.frame.size.height)
        height = bodyHeight - detailViewController.activeWebView.frame.size.height;
    else
        height = bodyHeight;
    int location = height*slider.value;
    NSString* str = [NSString stringWithFormat:@"scrollTo(0,%d)",location];
    [self.detailViewController.activeWebView stringByEvaluatingJavaScriptFromString:str];
    str = [NSString stringWithFormat:@"%.02f%%",100*((float)location/(float)height)];
    [percentLable setText:str];
}
@end
