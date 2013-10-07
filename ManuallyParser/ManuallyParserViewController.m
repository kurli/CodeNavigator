//
//  ManuallyParserViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/30/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "ManuallyParserViewController.h"
#import "Parser.h"
#import "Utils.h"
#import "DetailViewController.h"

@interface ManuallyParserViewController ()
{
    int currentSelected;
    int currentEditItem;
    EditType editType;
}
@end

@implementation ManuallyParserViewController
@synthesize parserArray;
@synthesize extensionsField;
@synthesize singleLineCommentsField;
@synthesize multiLineCommentsStartField;
@synthesize multiLineCommentsEndField;
@synthesize keyworldField;
@synthesize parserTypePicker;
@synthesize nameField;
@synthesize deleteButton;
@synthesize filePath;
@synthesize manuallyParserArray;
@synthesize scrollView;
@synthesize buttonCopy;

@synthesize storedExtensions;
@synthesize storedMultiLineCommentsEnd;
@synthesize storedMultiLineCommentsStart;
@synthesize storedName;
@synthesize storedSingleLineComments;
@synthesize storedKeywords;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        editType = EDIT_NONE;
        currentEditItem = -1;
        currentSelected = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    parserArray = [[NSMutableArray alloc] initWithObjects:PREDEF_PARSER, nil];
    currentSelected = -1;
    manuallyParserArray = [Parser getManuallyParserNames];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self.parserArray removeAllObjects];
    [self setParserArray:nil];
    [self setManuallyParserArray:nil];
    [self setFilePath:nil];
    
    [self setExtensionsField:nil];
    [self setSingleLineCommentsField:nil];
    [self setMultiLineCommentsStartField:nil];
    [self setMultiLineCommentsEndField:nil];
    [self setKeyworldField:nil];
    [self setParserTypePicker:nil];
    [self setNameField:nil];
    [self setDeleteButton:nil];
    [self setScrollView:nil];
    [self setButtonCopy:nil];
    [self setEditButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [self.parserArray removeAllObjects];
    [self setParserArray:nil];
    [self setManuallyParserArray:nil];
    [self setFilePath:nil];
    [self setStoredExtensions:nil];
    [self setStoredName:nil];
    [self setStoredSingleLineComments:nil];
    [self setStoredMultiLineCommentsEnd:nil];
    [self setStoredMultiLineCommentsStart:nil];
    [self setStoredKeywords:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef IPHONE_VERSION
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
#endif
	return YES;
}

- (IBAction)editButtonClicked:(id)sender {
    currentEditItem = currentSelected;
    [self setFieldsEditable:YES];
    if (currentSelected == [parserArray count] + [manuallyParserArray count]) {
        editType = ADD_NEW_PARSER;
        [self switchToAddParserButtonMode];
    } else {
        editType = EDIT_PARSER;
        if (currentSelected < [parserArray count]) {
            [self switchToBuildInParserButtonMode];
        } else {
            [self switchToManuallyParserButtonMode];
        }
    }
}

- (IBAction)copyButtonClicked:(id)sender {
    int manuallyParserIndex = -1;
    NSString* name = @"";
    NSString* extension = @"";
    NSString* singleLine = @"";
    NSString* multiLineS = @"";
    NSString* multiLineE = @"";
    NSString* keywords = @"";
    CodeParser* codeParser = nil;
    
    if (currentSelected < HTML) {
        Parser* parser = [[Parser alloc] init];
        [parser setParserType:currentSelected];
        name = [parser.parser getParserName];
        codeParser = parser.parser;
        
        extension = [codeParser getExtentionsStr];
        singleLine = [codeParser getSingleLineCommentsStr];
        multiLineS = [codeParser getMultiLineCommentsStartStr];
        multiLineE = [codeParser getMultiLineCommentsEndStr];
        keywords = [codeParser getKeywordsStr];
    }
    else
    {
        manuallyParserIndex = currentSelected - [parserArray count];
        if (manuallyParserIndex > -1 && manuallyParserIndex < [manuallyParserArray count]) {
            name = [manuallyParserArray objectAtIndex:manuallyParserIndex];
            
            NSDictionary* dictionary = [Parser getManuallyParserByName:name];
            extension = [dictionary objectForKey:EXTENSION];
            singleLine = [dictionary objectForKey:SINGLE_LINE_COMMENTS];
            multiLineS = [dictionary objectForKey:MULTI_LINE_COMMENTS_START];
            multiLineE = [dictionary objectForKey:MULTI_LINE_COMMENTS_END];
            keywords = [dictionary objectForKey:KEYWORDS];
        }
        else {
            //NONE
        }
    }
    
    currentSelected = [parserArray count]+[manuallyParserArray count];
    [self.parserTypePicker selectRow:currentSelected inComponent:0 animated:YES];
    
    [self setField:nil andExtention:extension andSingleLine:singleLine andMultiLineS:multiLineS andMultLineE:multiLineE andKeywords:keywords];
    [nameField becomeFirstResponder];
    
    editType = ADD_NEW_PARSER;
    [self switchToAddParserButtonMode];
    [self setFieldsEditable:YES];
    currentEditItem = currentSelected;
}

- (IBAction)deleteButtonClicked:(id)sender {
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:[NSString stringWithFormat:@"Would you like to delete Parser: \"%@?\"",nameField.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    confirmAlert.tag = 1;
    [confirmAlert show];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL) checkFields
{
    NSString* name = @"";
    NSString* extension = @"";
    
    name = self.nameField.text;
    if ([name length] == 0) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please enter the Name"];
        return NO;
    }
    extension = self.extensionsField.text;
    if ([extension length] == 0) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please enter the Extensions"];
        return NO;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1 && alertView.tag == 0) {
        NSString* name = @"";
        NSString* extension = @"";
        NSString* singleLine = @"";
        NSString* multiLineS = @"";
        NSString* multiLineE = @"";
        NSString* keywords = @"";
        
        name = self.nameField.text;
        extension = self.extensionsField.text;
        extension = [extension lowercaseString];
        singleLine = self.singleLineCommentsField.text;
        multiLineS = self.multiLineCommentsStartField.text;
        multiLineE = self.multiLineCommentsEndField.text;
        keywords = self.keyworldField.text;
        
        NSString* parserPath;
        if (currentEditItem < [parserArray count]) {
            parserPath = [NSHomeDirectory() stringByAppendingFormat:BUILDIN_PARSER_PATH];
        } else {
            parserPath = [NSHomeDirectory() stringByAppendingFormat:MANUALLY_PARSER_PATH];
        }
        
        parserPath = [parserPath stringByAppendingPathComponent:self.nameField.text];
        parserPath = [parserPath stringByAppendingPathExtension:@"json"];
        
        [[NSFileManager defaultManager] removeItemAtPath:parserPath error:nil];
        
        [Parser saveParser:parserPath andExtention:extension andSingleLine:singleLine andMultiLineS:multiLineS andMultLineE:multiLineE andKeywords:keywords andType:currentEditItem];
        
        [self dismissModalViewControllerAnimated:YES];
        [self refreshCurrentFileWithNewParser];
        return;
    }
    
    //Delete confirmed
    if (buttonIndex == 1 && alertView.tag == 1) {
        NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:MANUALLY_PARSER_PATH];
        manuallyParserPath = [manuallyParserPath stringByAppendingPathComponent:self.nameField.text];
        manuallyParserPath = [manuallyParserPath stringByAppendingPathExtension:@"json"];
        [[NSFileManager defaultManager] removeItemAtPath:manuallyParserPath error:nil];
        
        [self dismissModalViewControllerAnimated:YES];
        [self refreshCurrentFileWithNewParser];
        return;
    }
}

// Not used currently
- (void) refreshCurrentFileWithNewParser
{
    Parser* parser = [[Parser alloc] init];
    [parser checkParseType:filePath];
    
    NSError* error;
    NSString* projPath = [[Utils getInstance] getProjectFolder:filePath];
    NSString* displayPath = [[Utils getInstance] getDisplayPath:filePath];
    [[NSFileManager defaultManager] removeItemAtPath:displayPath error:&error];
    
    [parser setFile: filePath andProjectBase:projPath];
    [parser startParse];
    NSString* html = [parser getHtml];
    //rc4Result = [self HloveyRC4:html key:@"lgz"];
    [html writeToFile:displayPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [[Utils getInstance].detailViewController setTitle:[filePath lastPathComponent] andPath:filePath andContent:html andBaseUrl:nil];
}

- (void) saveForEditParser
{
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:[NSString stringWithFormat:@"Would you like to save the changes for \"%@?\"",nameField.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    confirmAlert.tag = 0;
    [confirmAlert show];
}

- (void) saveForAddParser
{
    NSString* name = @"";
    name = self.nameField.text;
    
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:MANUALLY_PARSER_PATH];
    manuallyParserPath = [manuallyParserPath stringByAppendingPathComponent:name];
    manuallyParserPath = [manuallyParserPath stringByAppendingPathExtension:@"json"];
    
    BOOL isDirectory;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:manuallyParserPath isDirectory:&isDirectory];
    if (exist) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:[NSString stringWithFormat:@"\"%@\" already exist, please change new Name",name]];
        return;
    }
    
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:[NSString stringWithFormat:@"Would you like to add new Parser: \"%@?\"",nameField.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    confirmAlert.tag = 0;
    [confirmAlert show];
}

- (IBAction)doneButtonClicked:(id)sender {
    // Do nothing, just dismiss
    if (editType == EDIT_NONE) {
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    
    // Switch to current edit item.
    currentSelected = currentEditItem;
    [self.parserTypePicker selectRow:currentSelected inComponent:0 animated:YES];
    
    // Check fields
    if (![self checkFields]) {
        return;
    }
    
    if (editType == EDIT_PARSER) {
        // Save for edit mode
        [self saveForEditParser];
    } else {
        // Save for add mode
        [self saveForAddParser];
    }
}

-(void)switchToBuildInParserButtonMode
{
    [self.deleteButton setHidden:YES];
    if (editType == EDIT_PARSER) {
        [self.buttonCopy setHidden:YES];
    } else {
        [self.buttonCopy setHidden:NO];
    }
    if (editType != EDIT_NONE) {
        [self.editButton setHidden:YES];
    } else {
        [self.editButton setHidden:NO];
    }
}

-(void)switchToAddParserButtonMode
{
    [self.deleteButton setHidden:YES];
    [self.buttonCopy setHidden:YES];
    if (editType != EDIT_NONE) {
        [self.editButton setHidden:YES];
    } else {
        [self.editButton setHidden:NO];
    }}

-(void)switchToManuallyParserButtonMode
{
    [self.deleteButton setHidden:NO];
    if (editType == EDIT_PARSER) {
        [self.buttonCopy setHidden:YES];
    } else {
        [self.buttonCopy setHidden:NO];
    }    if (editType != EDIT_NONE) {
        [self.editButton setHidden:YES];
    } else {
        [self.editButton setHidden:NO];
    }
}

-(void)setFieldsEditable:(BOOL)editable
{
    // Build in parser name can not be changed
    if (currentEditItem < HTML) {
        [self.nameField setEnabled:NO];
    } else {
        [self.nameField setEnabled:editable];
    }
    [self.extensionsField setEnabled:editable];
    [self.singleLineCommentsField setEnabled:editable];
    [self.multiLineCommentsStartField setEnabled:editable];
    [self.multiLineCommentsEndField setEnabled:editable];
    [self.keyworldField setEditable:editable];
    
    if (editable == NO) {
        //Disable fields
        [self.nameField setBorderStyle:UITextBorderStyleLine];
        [self.extensionsField setBorderStyle:UITextBorderStyleLine];
        [self.singleLineCommentsField setBorderStyle:UITextBorderStyleLine];
        [self.multiLineCommentsStartField setBorderStyle:UITextBorderStyleLine];
        [self.multiLineCommentsEndField setBorderStyle:UITextBorderStyleLine];
    } else {
        [self.nameField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.extensionsField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.singleLineCommentsField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.multiLineCommentsStartField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.multiLineCommentsEndField setBorderStyle:UITextBorderStyleRoundedRect];
        
        if (currentSelected == [parserArray count] + [manuallyParserArray count]) {
            return;
        }
    }
}

-(void)setField:(NSString*)name andExtention:(NSString*)extension andSingleLine:(NSString*)singleLine andMultiLineS:(NSString*)multilineS
andMultLineE:(NSString*)multilineE andKeywords:(NSString*)keywords
{
    [self.nameField setText:name];
    [self.extensionsField setText:extension];
    [self.singleLineCommentsField setText:singleLine];
    [self.multiLineCommentsStartField setText:multilineS];
    [self.multiLineCommentsEndField setText:multilineE];
    [self.keyworldField setText:keywords];
    
    CGSize size = CGSizeMake(self.scrollView.frame.size.width, self.keyworldField.frame.origin.y + self.keyworldField.contentSize.height);
    if ([keywords length] == 0) {
        size.height -= self.keyworldField.contentSize.height;
        size.height += 150;
    }
    [self.scrollView setContentSize:size];
    CGRect rect = self.keyworldField.frame;
    if (rect.size.height < self.keyworldField.contentSize.height) {
        rect.size = self.keyworldField.contentSize;
    }
    if ([keywords length] == 0) {
        rect.size.height = 150;
    }
    [self.keyworldField setFrame:rect];
}

-(void)predefParserSelected
{
    int manuallyParserIndex = -1;
    NSString* name = @"";
    NSString* extension = @"";
    NSString* singleLine = @"";
    NSString* multiLineS = @"";
    NSString* multiLineE = @"";
    NSString* keywords = @"";
    CodeParser* codeParser;
    
    if (currentSelected < HTML) {
        Parser* parser = [[Parser alloc] init];
        [parser setParserType:currentSelected];
        name = [parser.parser getParserName];
        codeParser = parser.parser;
    }
    else
    {
        manuallyParserIndex = currentSelected - [parserArray count];
        if (manuallyParserIndex > -1 && manuallyParserIndex < [manuallyParserArray count]) {
            name = [manuallyParserArray objectAtIndex:manuallyParserIndex];
    
            NSDictionary* dictionary = [Parser getManuallyParserByName:name];
            extension = [dictionary objectForKey:EXTENSION];
            singleLine = [dictionary objectForKey:SINGLE_LINE_COMMENTS];
            multiLineS = [dictionary objectForKey:MULTI_LINE_COMMENTS_START];
            multiLineE = [dictionary objectForKey:MULTI_LINE_COMMENTS_END];
            keywords = [dictionary objectForKey:KEYWORDS];
            [self setField:name andExtention:extension andSingleLine:singleLine andMultiLineS:multiLineS andMultLineE:multiLineE andKeywords:keywords];
            return;
        }
        else {
            [self setField:@"" andExtention:@"" andSingleLine:@"" andMultiLineS:@"" andMultLineE:@"" andKeywords:@""];
            return;
        }
    }
    extension = [codeParser getExtentionsStr];
    singleLine = [codeParser getSingleLineCommentsStr];
    multiLineS = [codeParser getMultiLineCommentsStartStr];
    multiLineE = [codeParser getMultiLineCommentsEndStr];
    keywords = [codeParser getKeywordsStr];
    
    [self setField:name andExtention:extension andSingleLine:singleLine andMultiLineS:multiLineS andMultLineE:multiLineE andKeywords:keywords];
}

#pragma mark picker view
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row < [parserArray count]) {
        return [parserArray objectAtIndex:row];
    }
    int index = row - [parserArray count];
    if (index > -1 && index < [manuallyParserArray count]) {
        return [manuallyParserArray objectAtIndex:index];
    }
    return @"Add New Parser";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Store fields when previous Manually
    if (currentSelected == [parserArray count] + [manuallyParserArray count]) {
        [self setStoredName:nameField.text];
        [self setStoredExtensions:extensionsField.text];
        [self setStoredSingleLineComments:singleLineCommentsField.text];
        [self setStoredMultiLineCommentsEnd:multiLineCommentsEndField.text];
        [self setStoredMultiLineCommentsStart:multiLineCommentsStartField.text];
        [self setStoredKeywords:keyworldField.text];
    }
    
    currentSelected = row;
    
    // This item is currently editable
    if (currentSelected == currentEditItem) {
        [self setFieldsEditable:YES];
    } else {
        [self setFieldsEditable:NO];
    }
    
    //BuildIn parser
    if (row < [parserArray count]) {
        [self switchToBuildInParserButtonMode];
        [self predefParserSelected];
        return;
    }
    //Manually parser
    int index = row - [parserArray count];
    if (index > -1 && index < [manuallyParserArray count]) {
        [self switchToManuallyParserButtonMode];
        [self predefParserSelected];
        return;
    }
    //Add parser
    else {
        [self switchToAddParserButtonMode];
        [self setField:storedName andExtention:storedExtensions andSingleLine:storedSingleLineComments andMultiLineS:storedMultiLineCommentsStart andMultLineE:storedMultiLineCommentsEnd andKeywords:storedKeywords];
        return;
    }
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [parserArray count] + [manuallyParserArray count]+1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *extension = [filePath pathExtension];
    extension = [extension lowercaseString];
    ParserType type = UNKNOWN;
    int manuallyIndex = -1;
    
    type = [Parser getBuildInParserTypeByfilePath:filePath];
    
    if (type == UNKNOWN) {
        manuallyIndex = [Parser checkManuallyParserIndex:extension];
        if (manuallyIndex > -1) {
            type = -1;
        }
    }
    
    if (type < HTML) {
        currentSelected = type;
        [self switchToBuildInParserButtonMode];
    } else if (type == UNKNOWN) {
        currentSelected = [parserArray count]+[manuallyParserArray count];
        [self switchToAddParserButtonMode];
    }
    else {
        //it's a manually type
        currentSelected = [parserArray count] + manuallyIndex;
        [self switchToManuallyParserButtonMode];
    }
    
    [self.parserTypePicker selectRow:currentSelected inComponent:0 animated:YES];
    
    [self predefParserSelected];
    [self setFieldsEditable:NO];    
}

#pragma mark text View related

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView beginAnimations:@"showKeyboardAnimation" context:nil];
    [UIView setAnimationDuration:0.30];

    CGSize size = CGSizeMake(self.scrollView.frame.size.width, self.keyworldField.frame.origin.y + self.keyworldField.contentSize.height+200);
    if ([textView.text length] == 0) {
        size.height -= self.keyworldField.contentSize.height;
        size.height += 150;
    }
    [self.scrollView setContentSize:size];    
#ifdef IPHONE_VERSION

    [self.scrollView scrollRectToVisible:textView.frame animated:YES];
#endif
    
    [UIView commitAnimations];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGSize size = CGSizeMake(self.scrollView.frame.size.width, self.keyworldField.frame.origin.y + self.keyworldField.contentSize.height+200);
    size.height += 30;
    [self.scrollView setContentSize:size];
    
    CGRect rect = self.keyworldField.frame;
    if (rect.size.height < self.keyworldField.contentSize.height) {
        rect.size = self.keyworldField.contentSize;
    }

    [self.keyworldField setFrame:rect];
    
//    CGPoint bottomOffset = CGPointMake(0, [self.scrollView contentSize].height - self.scrollView.frame.size.height);
//    if (bottomOffset.y > 0) {
//        [scrollView setContentOffset:bottomOffset animated:YES];
//    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.30];
    CGSize size = CGSizeMake(self.scrollView.frame.size.width, self.keyworldField.frame.origin.y + self.keyworldField.contentSize.height);
    [self.scrollView setContentSize:size];
    
    CGRect rect = self.keyworldField.frame;
    if (rect.size.height < self.keyworldField.contentSize.height) {
        rect.size = self.keyworldField.contentSize;
    }
    [self.keyworldField setFrame:rect];

    [UIView commitAnimations];
}
@end
