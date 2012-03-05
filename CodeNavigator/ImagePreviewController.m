//
//  ImagePreviewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 2/26/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "ImagePreviewController.h"
#import "VirtualizeViewController.h"

@implementation ImagePreviewController
@synthesize scrollView;
@synthesize imageView;
@synthesize viewController;

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

- (void) viewWillAppear:(BOOL)animated
{
    UIImage* image = self.viewController.imageView.image;
    CGRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size = image.size;
    [imageView setFrame:rect];
    [scrollView setContentSize:rect.size];
    
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    [image drawInRect:rect];
    
    // get a UIImage from the image context- enjoy!!!
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    [imageView setImage:outputImage];
    // clean up drawing environment
    UIGraphicsEndImageContext();

    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
//    [self.imageView setImage:nil];
    [super viewWillDisappear:animated];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)closeButtonClicked:(id)sender {
    [viewController cloceImgPreview];
}
@end
