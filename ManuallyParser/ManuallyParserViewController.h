//
//  ManuallyParserViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 5/30/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _EditType
{
    ADD_NEW_PARSER = 0,
    EDIT_PARSER,
    EDIT_NONE
} EditType;

@interface ManuallyParserViewController : UIViewController <UIPickerViewDelegate, UITextViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray* parserArray;

@property (nonatomic, strong) NSArray* manuallyParserArray;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *extensionsField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *singleLineCommentsField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *multiLineCommentsStartField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *multiLineCommentsEndField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *keyworldField;
@property (unsafe_unretained, nonatomic) IBOutlet UIPickerView *parserTypePicker;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *nameField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *deleteButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonCopy;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (strong, nonatomic) NSString* storedName;
@property (strong, nonatomic) NSString* storedExtensions;
@property (strong, nonatomic) NSString* storedSingleLineComments;
@property (strong, nonatomic) NSString* storedMultiLineCommentsStart;
@property (strong, nonatomic) NSString* storedMultiLineCommentsEnd;
@property (strong, nonatomic) NSString* storedKeywords;

@property (strong, nonatomic) NSString* filePath;

- (IBAction)editButtonClicked:(id)sender;
- (IBAction)copyButtonClicked:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;
@end
