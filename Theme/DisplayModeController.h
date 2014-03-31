//
//  DisplayModeController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 1/13/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeManager.h"

typedef enum _ColorTextView
{
    BACKGROUND_COLOR_TEXTVIEW,
    COMMENT_COLOR_TEXTVIEW,
    STRING_COLOR_TEXTVIEW,
    KEYWORD_COLOR_TEXTVIEW,
    COLOR_NONE
}ColorTextView;

@interface DisplayModeController : UIViewController
{
    ColorTextView currentSelectedColorTextView;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *backgroundTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *modeSelection;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *commentTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *stringTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *keywordTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textSizeTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *defaultButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *fontSizeDecraseButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *fontSizeIncreaseButton;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *keywordDemoLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *commentDemoLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *othersDemoLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *stringDemoLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (unsafe_unretained, nonatomic) IBOutlet UISlider *redSliderController;

@property (unsafe_unretained, nonatomic) IBOutlet UISlider *greenSliderController;

@property (unsafe_unretained, nonatomic) IBOutlet UISlider *blueSliderController;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *backgroundSelectButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *commentSelecteButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *stringSelectButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *keywordSelectButton;
#ifdef IPHONE_VERSION
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
#endif

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *lineWrapperTextField;

- (IBAction)modeValueChanged:(id)sender;

- (IBAction)donButtonClicked:(id)sender;

- (IBAction)defaultButtonClicked:(id)sender;

- (IBAction)reviewButtonClicked:(id)sender;

- (IBAction)redSliderChanged:(id)sender;

- (IBAction)greenSliderChanged:(id)sender;

- (IBAction)blueSliderChanged:(id)sender;

- (IBAction)backgroundSelected:(id)sender;

- (IBAction)commentSelected:(id)sender;

- (IBAction)stringSelected:(id)sender;

- (IBAction)keywordSelected:(id)sender;

- (IBAction)backgroundTextViewChanged:(id)sender;

- (IBAction)commentTextViewChanged:(id)sender;

- (IBAction)stringTextViewChanged:(id)sender;

- (IBAction)keywordTextViewChanged:(id)sender;

- (IBAction)decreaseFSButtonClicked:(id)sender;

- (IBAction)increaseFSButtonClicked:(id)sender;

- (IBAction)fontSizeTextViewChanged:(id)sender;

- (IBAction)lineWrapperTextViewChanged:(id)sender;

@end
