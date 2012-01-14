//
//  DisplayModeController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 1/13/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayModeController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *backgroundTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *modeSelection;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *commentTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *stringTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *keywordTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textSizeTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *defaultButton;

- (IBAction)modeValueChanged:(id)sender;

- (IBAction)donButtonClicked:(id)sender;

- (IBAction)defaultButtonClicked:(id)sender;

- (IBAction)reviewButtonClicked:(id)sender;
@end
