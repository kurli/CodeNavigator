//
//  VersionControlController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 4/18/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "VersionControlController.h"
#import "MasterViewController.h"

@interface VersionControlController ()

@end

@implementation VersionControlController

@synthesize masterViewController;

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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dropboxClicked:(id)sender {
    [masterViewController dropBoxClicked:nil];
}

- (IBAction)gitClicked:(id)sender {
    [masterViewController gitClicked:nil];
}
@end
