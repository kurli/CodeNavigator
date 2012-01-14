//
//  DisplayModeController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 1/13/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "DisplayModeController.h"
#import "Utils.h"
#import "DetailViewController.h"

@implementation DisplayModeController
@synthesize backgroundTextField;
@synthesize modeSelection;
@synthesize commentTextField;
@synthesize stringTextField;
@synthesize keywordTextField;
@synthesize textSizeTextField;
@synthesize defaultButton;

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
    [self setBackgroundTextField:nil];
    [self setModeSelection:nil];
    [self setCommentTextField:nil];
    [self setStringTextField:nil];
    [self setKeywordTextField:nil];
    [self setTextSizeTextField:nil];
    [self setDefaultButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.backgroundTextField.text = [[Utils getInstance] getDisplayBackgroundColor];
    self.textSizeTextField.text = [Utils getInstance].colorScheme.font_size;
    if ([[Utils getInstance] isDayTypeDisplayMode] == YES)
    {
        [self.modeSelection setSelectedSegmentIndex:0];
        self.commentTextField.text = [Utils getInstance].colorScheme.day_comment;
        self.stringTextField.text = [Utils getInstance].colorScheme.day_string;
        self.keywordTextField.text = [Utils getInstance].colorScheme.day_keyword;
    }
    else
    {
        [self.modeSelection setSelectedSegmentIndex:1];
        self.commentTextField.text = [Utils getInstance].colorScheme.night_comment;
        self.stringTextField.text = [Utils getInstance].colorScheme.night_string;
        self.keywordTextField.text = [Utils getInstance].colorScheme.night_keyword;
    }    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)modeValueChanged:(id)sender {
    self.textSizeTextField.text = [Utils getInstance].colorScheme.font_size;
    if (self.modeSelection.selectedSegmentIndex == 0)
    {
        self.backgroundTextField.text = [Utils getInstance].colorScheme.day_backgroundColor;
        self.commentTextField.text = [Utils getInstance].colorScheme.day_comment;
        self.stringTextField.text = [Utils getInstance].colorScheme.day_string;
        self.keywordTextField.text = [Utils getInstance].colorScheme.day_keyword;
    }
    else
    {
        self.backgroundTextField.text = [Utils getInstance].colorScheme.night_backgroundColor;
        self.commentTextField.text = [Utils getInstance].colorScheme.night_comment;
        self.stringTextField.text = [Utils getInstance].colorScheme.night_string;
        self.keywordTextField.text = [Utils getInstance].colorScheme.night_keyword;
    }    
}

- (IBAction)donButtonClicked:(id)sender {
    if (self.modeSelection.selectedSegmentIndex == 0)
    {
        [[Utils getInstance]writeColorScheme:YES andDayBackground:self.backgroundTextField.text andNightBackground:nil andDayComment:self.commentTextField.text andNightComment:nil andDayString:self.stringTextField.text andNightString:nil andDayKeyword:self.keywordTextField.text andNightKeyword:nil andFontSize:self.textSizeTextField.text];
    }
    else
    {
        [[Utils getInstance] writeColorScheme:NO andDayBackground:nil andNightBackground:self.backgroundTextField.text andDayComment:nil andNightComment:self.commentTextField.text andDayString:nil andNightString:self.stringTextField.text andDayKeyword:nil andNightKeyword:self.keywordTextField.text andFontSize:self.textSizeTextField.text];
    }
    [[Utils getInstance].detailViewController reloadCurrentPage];
}

- (IBAction)defaultButtonClicked:(id)sender {
    NSError *error;
    NSString* customizedColor = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/syntax_color.plist"];
    [[NSFileManager defaultManager] removeItemAtPath:customizedColor error:&error];
    
    [[Utils getInstance] readColorScheme];
    self.backgroundTextField.text = [[Utils getInstance] getDisplayBackgroundColor];
    self.textSizeTextField.text = [Utils getInstance].colorScheme.font_size;
    if ([[Utils getInstance] isDayTypeDisplayMode] == YES)
    {
        [self.modeSelection setSelectedSegmentIndex:0];
        self.commentTextField.text = [Utils getInstance].colorScheme.day_comment;
        self.stringTextField.text = [Utils getInstance].colorScheme.day_string;
        self.keywordTextField.text = [Utils getInstance].colorScheme.day_keyword;
    }
    else
    {
        [self.modeSelection setSelectedSegmentIndex:1];
        self.commentTextField.text = [Utils getInstance].colorScheme.night_comment;
        self.stringTextField.text = [Utils getInstance].colorScheme.night_string;
        self.keywordTextField.text = [Utils getInstance].colorScheme.night_keyword;
    }
    [[Utils getInstance].detailViewController reloadCurrentPage];
}

- (IBAction)reviewButtonClicked:(id)sender {
    NSString* url = @"http://itunes.apple.com/us/app/codenavigator/id492480832?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
@end
