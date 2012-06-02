//
//  ManuallyParserViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/30/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManuallyParserViewController : UIViewController <UIPickerViewDelegate>

@property (nonatomic, strong) NSMutableArray* parserArray;

@property (nonatomic, strong) NSArray* manuallyParserArray;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *extentionsField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *singleLineCommentsField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *multiLineCommentsStartField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *multiLineCommentsEndField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *keyworldField;
@property (unsafe_unretained, nonatomic) IBOutlet UIPickerView *parserTypePicker;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *nameField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) NSString* filePath;

- (IBAction)deleteButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;
@end
