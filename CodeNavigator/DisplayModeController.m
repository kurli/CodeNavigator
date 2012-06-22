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
@synthesize fontSizeDecraseButton;
@synthesize fontSizeIncreaseButton;
@synthesize keywordDemoLabel;
@synthesize commentDemoLabel;
@synthesize othersDemoLabel;
@synthesize stringDemoLabel;
@synthesize backgroundImageView;
@synthesize redSliderController;
@synthesize greenSliderController;
@synthesize blueSliderController;
@synthesize backgroundSelectButton;
@synthesize commentSelecteButton;
@synthesize stringSelectButton;
@synthesize keywordSelectButton;
#ifdef IPHONE_VERSION
@synthesize scrollView;
#endif

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

#pragma UI change method

-(void) changeBackgroundColor
{
    NSString*  bgcolor = backgroundTextField.text;
    if ([bgcolor length] != 7)
        return;
    bgcolor = [bgcolor substringFromIndex:1];
    unsigned int baseValue;
    if ([[NSScanner scannerWithString:bgcolor] scanHexInt:&baseValue])
    {
        [backgroundImageView setBackgroundColor:UIColorFromRGB(baseValue)];
    }
}

-(void) setDemoColor:(NSString*)bgcolor andLabel:(UILabel*)label
{
    if ([bgcolor length] != 7)
        return;
    bgcolor = [bgcolor substringFromIndex:1];
    unsigned int baseValue;
    if ([[NSScanner scannerWithString:bgcolor] scanHexInt:&baseValue])
    {
        [label setTextColor:UIColorFromRGB(baseValue)];
    }
}

-(void) setSliderValues:(NSString*)colorStr
{
    colorStr = [colorStr substringFromIndex:1];
    if ([colorStr length] != 6) {
        return;
    }
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString* red = [colorStr substringWithRange:range];
    range.location = 2;
    NSString* green = [colorStr substringWithRange:range];
    range.location = 4;
    NSString* blue = [colorStr substringWithRange:range];
    
    unsigned int redValue = 0;
    [[NSScanner scannerWithString:red] scanHexInt:&redValue];
    [redSliderController setValue:redValue];
    unsigned int greenValue = 0;
    [[NSScanner scannerWithString:green] scanHexInt:&greenValue];
    [greenSliderController setValue:greenValue];
    unsigned int blueValue = 0;
    [[NSScanner scannerWithString:blue] scanHexInt:&blueValue];
    [blueSliderController setValue:blueValue];
}

-(void)setFontSize
{
    int size = [textSizeTextField.text intValue];
    UIFont* font = [UIFont fontWithName:@"Arial" size: size];
    [self.commentDemoLabel setFont:font];
    [self.keywordDemoLabel setFont:font];
    [self.othersDemoLabel setFont:font];
    [self.stringDemoLabel setFont:font];
}

-(NSString*)intToHex:(unsigned int) value
{
    NSString* returnValue = nil;
    unsigned int power = value/16;
    unsigned int remain = value%16;
    if (power < 10) {
        returnValue = [NSString stringWithFormat:@"%d", power];
    } else {
        returnValue = [NSString stringWithFormat:@"%c", 'A'+power-10];
    }
    if (remain < 10) {
        returnValue = [returnValue stringByAppendingFormat:@"%d", remain];
    } else {
        returnValue = [returnValue stringByAppendingFormat:@"%c", 'A'+remain-10];
    }
    return returnValue;
}

-(void) getColorStringFromSlider
{
    NSString* result = @"#";
    unsigned int red = (unsigned int)(redSliderController.value);
    unsigned int green = (unsigned int)(greenSliderController.value);
    unsigned int blue = (unsigned int)(blueSliderController.value);
    result = [result stringByAppendingString:[self intToHex:red]];
    result = [result stringByAppendingString:[self intToHex:green]];
    result = [result stringByAppendingString:[self intToHex:blue]];
    switch (currentSelectedColorTextView) {
        case BACKGROUND_COLOR_TEXTVIEW:
            [self.backgroundTextField setText:result];
            [self changeBackgroundColor];
            break;
        case COMMENT_COLOR_TEXTVIEW:
            [self.commentTextField setText:result];
            [self setDemoColor:result andLabel:commentDemoLabel];
            break;
        case STRING_COLOR_TEXTVIEW:
            [self.stringTextField setText:result];
            [self setDemoColor:result andLabel:stringDemoLabel];
            break;
        case KEYWORD_COLOR_TEXTVIEW:
            [self.keywordTextField setText:result];
            [self setDemoColor:result andLabel:keywordDemoLabel];
            break;
        case COLOR_NONE:
        default:
            break;
    }
}

-(void)changeColorSlider
{
    [self.backgroundSelectButton setImage:[UIImage imageNamed:@"checkbox_no.png"] forState:UIControlStateNormal]; 
    [self.commentSelecteButton setImage:[UIImage imageNamed:@"checkbox_no.png"] forState:UIControlStateNormal]; 
    [self.stringSelectButton setImage:[UIImage imageNamed:@"checkbox_no.png"] forState:UIControlStateNormal]; 
    [self.keywordSelectButton setImage:[UIImage imageNamed:@"checkbox_no.png"] forState:UIControlStateNormal]; 

    NSString* textColor;
    switch (currentSelectedColorTextView) {
        case BACKGROUND_COLOR_TEXTVIEW:
            textColor = backgroundTextField.text;
            [self.backgroundSelectButton setImage:[UIImage imageNamed:@"checkbox_yes.png"] forState:UIControlStateNormal]; 
            break;
        case COMMENT_COLOR_TEXTVIEW:
            textColor = commentTextField.text;
            [self.commentSelecteButton setImage:[UIImage imageNamed:@"checkbox_yes.png"] forState:UIControlStateNormal]; 
            break;
        case STRING_COLOR_TEXTVIEW:
            textColor = stringTextField.text;
            [self.stringSelectButton setImage:[UIImage imageNamed:@"checkbox_yes.png"] forState:UIControlStateNormal]; 
            break;
        case KEYWORD_COLOR_TEXTVIEW:
            textColor = keywordTextField.text;
            [self.keywordSelectButton setImage:[UIImage imageNamed:@"checkbox_yes.png"] forState:UIControlStateNormal]; 
            break;
        case COLOR_NONE:
        default:
            textColor = nil;
    }
    [self setSliderValues:textColor];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    currentSelectedColorTextView = BACKGROUND_COLOR_TEXTVIEW;
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
    [self setFontSizeDecraseButton:nil];
    [self setFontSizeIncreaseButton:nil];
    [self setBackgroundImageView:nil];
    [self setCommentDemoLabel:nil];
    [self setKeywordDemoLabel:nil];
    [self setOthersDemoLabel:nil];
    [self setStringDemoLabel:nil];
    [self setRedSliderController:nil];
    [self setGreenSliderController:nil];
    [self setBlueSliderController:nil];
    [self setBackgroundSelectButton:nil];
    [self setCommentSelecteButton:nil];
    [self setStringSelectButton:nil];
    [self setKeywordSelectButton:nil];
#ifdef IPHONE_VERSION
    [self setScrollView:nil];
#endif
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
        
        [self setDemoColor:[Utils getInstance].colorScheme.day_other andLabel:othersDemoLabel];
    }
    else
    {
        [self.modeSelection setSelectedSegmentIndex:1];
        self.commentTextField.text = [Utils getInstance].colorScheme.night_comment;
        self.stringTextField.text = [Utils getInstance].colorScheme.night_string;
        self.keywordTextField.text = [Utils getInstance].colorScheme.night_keyword;
        
        [self setDemoColor:[Utils getInstance].colorScheme.night_other andLabel:othersDemoLabel];
    }
    // UI related
    [self changeBackgroundColor];
    [self setDemoColor:commentTextField.text andLabel:commentDemoLabel];
    [self setDemoColor:stringTextField.text andLabel:stringDemoLabel];
    [self setDemoColor:keywordTextField.text andLabel:keywordDemoLabel];
    [self setSliderValues:backgroundTextField.text];
    [self setFontSize];
#ifdef IPHONE_VERSION
    [scrollView setContentSize:CGSizeMake(320, 620)];
#endif
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
        
        [self setDemoColor:[Utils getInstance].colorScheme.day_other andLabel:othersDemoLabel];
    }
    else
    {
        self.backgroundTextField.text = [Utils getInstance].colorScheme.night_backgroundColor;
        self.commentTextField.text = [Utils getInstance].colorScheme.night_comment;
        self.stringTextField.text = [Utils getInstance].colorScheme.night_string;
        self.keywordTextField.text = [Utils getInstance].colorScheme.night_keyword;
        
        [self setDemoColor:[Utils getInstance].colorScheme.night_other andLabel:othersDemoLabel];
    }
    // UI
    [self changeColorSlider];
    [self changeBackgroundColor];
    [self setDemoColor:commentTextField.text andLabel:commentDemoLabel];
    [self setDemoColor:stringTextField.text andLabel:stringDemoLabel];
    [self setDemoColor:keywordTextField.text andLabel:keywordDemoLabel];
    [self setFontSize];
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
    [[Utils getInstance].detailViewController displayModeClicked:nil];
#ifdef IPHONE_VERSION
    [self dismissViewControllerAnimated:NO completion:nil];
#endif
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
        
        [self setDemoColor:[Utils getInstance].colorScheme.day_other andLabel:othersDemoLabel];
    }
    else
    {
        [self.modeSelection setSelectedSegmentIndex:1];
        self.commentTextField.text = [Utils getInstance].colorScheme.night_comment;
        self.stringTextField.text = [Utils getInstance].colorScheme.night_string;
        self.keywordTextField.text = [Utils getInstance].colorScheme.night_keyword;
        
        [self setDemoColor:[Utils getInstance].colorScheme.night_other andLabel:othersDemoLabel];
    }
    // UI
    [self changeColorSlider];
    [self changeBackgroundColor];
    [self setDemoColor:commentTextField.text andLabel:commentDemoLabel];
    [self setDemoColor:stringTextField.text andLabel:stringDemoLabel];
    [self setDemoColor:keywordTextField.text andLabel:keywordDemoLabel];
    [self setFontSize];
    [[Utils getInstance].detailViewController reloadCurrentPage];
}

- (IBAction)reviewButtonClicked:(id)sender {
    NSString* url = @"http://itunes.apple.com/us/app/codenavigator/id492480832?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction)redSliderChanged:(id)sender {
    [self getColorStringFromSlider];
}

- (IBAction)greenSliderChanged:(id)sender {
    [self getColorStringFromSlider];
}

- (IBAction)blueSliderChanged:(id)sender {
    [self getColorStringFromSlider];
}

- (IBAction)backgroundSelected:(id)sender {
    if (currentSelectedColorTextView == BACKGROUND_COLOR_TEXTVIEW) {
        return;
    }
    currentSelectedColorTextView = BACKGROUND_COLOR_TEXTVIEW;
    [self changeColorSlider];
}

- (IBAction)commentSelected:(id)sender {
    if (currentSelectedColorTextView == COMMENT_COLOR_TEXTVIEW) {
        return;
    }
    currentSelectedColorTextView = COMMENT_COLOR_TEXTVIEW;
    [self changeColorSlider];
}

- (IBAction)stringSelected:(id)sender {
    if (currentSelectedColorTextView == STRING_COLOR_TEXTVIEW) {
        return;
    }
    currentSelectedColorTextView = STRING_COLOR_TEXTVIEW;
    [self changeColorSlider];
}

- (IBAction)keywordSelected:(id)sender {
    if (currentSelectedColorTextView == KEYWORD_COLOR_TEXTVIEW) {
        return;
    }
    currentSelectedColorTextView = KEYWORD_COLOR_TEXTVIEW;
    [self changeColorSlider];
}

- (IBAction)backgroundTextViewChanged:(id)sender {
    currentSelectedColorTextView = BACKGROUND_COLOR_TEXTVIEW;
    [self changeColorSlider];
}

- (IBAction)commentTextViewChanged:(id)sender {
    currentSelectedColorTextView = COMMENT_COLOR_TEXTVIEW;
    [self changeColorSlider];
}

- (IBAction)stringTextViewChanged:(id)sender {
    currentSelectedColorTextView = STRING_COLOR_TEXTVIEW;
    [self changeColorSlider];
}

- (IBAction)keywordTextViewChanged:(id)sender {
    currentSelectedColorTextView = KEYWORD_COLOR_TEXTVIEW;
    [self changeColorSlider];
}

- (IBAction)decreaseFSButtonClicked:(id)sender {
    int value = [textSizeTextField.text intValue];
    value--;
    [textSizeTextField setText:[NSString stringWithFormat:@"%d", value]];
    [self setFontSize];
}

- (IBAction)increaseFSButtonClicked:(id)sender {
    int value = [textSizeTextField.text intValue];
    value++;
    [textSizeTextField setText:[NSString stringWithFormat:@"%d", value]];
    [self setFontSize];
}

- (IBAction)fontSizeTextViewChanged:(id)sender {
    [self setFontSize];
}
@end
