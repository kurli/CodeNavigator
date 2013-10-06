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
}
@end

@implementation ManuallyParserViewController
@synthesize parserArray;
@synthesize extentionsField;
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
    
    [self setExtentionsField:nil];
    [self setSingleLineCommentsField:nil];
    [self setMultiLineCommentsStartField:nil];
    [self setMultiLineCommentsEndField:nil];
    [self setKeyworldField:nil];
    [self setParserTypePicker:nil];
    [self setNameField:nil];
    [self setDeleteButton:nil];
    [self setScrollView:nil];
    [self setButtonCopy:nil];
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef IPHONE_VERSION
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
#endif
	return YES;
}

- (IBAction)copyButtonClicked:(id)sender {
}

- (IBAction)deleteButtonClicked:(id)sender {
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:MANUALLY_PARSER_PATH];
    manuallyParserPath = [manuallyParserPath stringByAppendingPathComponent:self.nameField.text];
    manuallyParserPath = [manuallyParserPath stringByAppendingPathExtension:@"json"];
    [[NSFileManager defaultManager] removeItemAtPath:manuallyParserPath error:nil];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL) saveParser
{
    NSString* name = @"";
    NSString* extention = @"";
    NSString* singleLine = @"";
    NSString* multiLineS = @"";
    NSString* multiLineE = @"";
    NSString* keywords = @"";
    
    name = self.nameField.text;
    if ([name length] == 0) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please specify the Name"];
        return NO;
    }
    extention = self.extentionsField.text;
    if ([extention length] == 0) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please specify the Extentions"];
        return NO;
    }
    extention = [extention lowercaseString];
    singleLine = self.singleLineCommentsField.text;
    multiLineS = self.multiLineCommentsStartField.text;
    multiLineE = self.multiLineCommentsEndField.text;
    keywords = self.keyworldField.text;
    
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:MANUALLY_PARSER_PATH];
    manuallyParserPath = [manuallyParserPath stringByAppendingPathComponent:name];
    manuallyParserPath = [manuallyParserPath stringByAppendingPathExtension:@"json"];
    [[NSFileManager defaultManager] removeItemAtPath:manuallyParserPath error:nil];
    
    [Parser saveManuallyParser:name andExtention:extention andSingleLine:singleLine andMultiLineS:multiLineS andMultLineE:multiLineE andKeywords:keywords];
    return YES;
}

- (IBAction)doneButtonClicked:(id)sender {
    ParserType type = UNKNOWN;
    BOOL succeed;
    if (currentSelected < HTML) {
        type = currentSelected;
    } else {
        succeed = [self saveParser];
        if (!succeed) {
            return;
        }
        type = -1;
    }

    Parser* parser = [[Parser alloc] init];
    [parser setParserType:type];
    if (type == -1) {
        [parser checkParseType:filePath];
    }

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
    [self dismissModalViewControllerAnimated:YES];
}

-(void)setField:(NSString*)name andExtention:(NSString*)extention andSingleLine:(NSString*)singleLine andMultiLineS:(NSString*)multilineS
andMultLineE:(NSString*)multilineE andKeywords:(NSString*)keywords andEnable:(BOOL)enable
{
    [self.nameField setText:name];
    [self.extentionsField setText:extention];
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
    
    [self.nameField setEnabled:enable];
    [self.extentionsField setEnabled:enable];
    [self.singleLineCommentsField setEnabled:enable];
    [self.multiLineCommentsStartField setEnabled:enable];
    [self.multiLineCommentsEndField setEnabled:enable];
    [self.keyworldField setEditable:enable];
    
    if (enable == NO) {
        //Disable fields
        [self.nameField setBorderStyle:UITextBorderStyleLine];
        [self.extentionsField setBorderStyle:UITextBorderStyleLine];
        [self.singleLineCommentsField setBorderStyle:UITextBorderStyleLine];
        [self.multiLineCommentsStartField setBorderStyle:UITextBorderStyleLine];
        [self.multiLineCommentsEndField setBorderStyle:UITextBorderStyleLine];
        
        [self.deleteButton setHidden:YES];
    } else {
        [self.nameField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.extentionsField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.singleLineCommentsField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.multiLineCommentsStartField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.multiLineCommentsEndField setBorderStyle:UITextBorderStyleRoundedRect];
        
        if (currentSelected == [parserArray count] + [manuallyParserArray count]) {
            [self.deleteButton setHidden:YES];
            return;
        }
        [self.deleteButton setHidden:NO];
    }
}

-(void)predefParserSelected
{
    int manuallyParserIndex = -1;
    NSString* name = @"";
    NSString* extention = @"";
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
            extention = [dictionary objectForKey:EXTENTION];
            singleLine = [dictionary objectForKey:SINGLE_LINE_COMMENTS];
            multiLineS = [dictionary objectForKey:MULTI_LINE_COMMENTS_START];
            multiLineE = [dictionary objectForKey:MULTI_LINE_COMMENTS_END];
            keywords = [dictionary objectForKey:KEYWORDS];
            [self setField:name andExtention:extention andSingleLine:singleLine andMultiLineS:multiLineS andMultLineE:multiLineE andKeywords:keywords andEnable:YES];
            return;
        }
        else {
            [self setField:@"" andExtention:@"" andSingleLine:@"" andMultiLineS:@"" andMultLineE:@"" andKeywords:@"" andEnable:YES];
            return;
        }
    }
    extention = [codeParser getExtentionsStr];
    singleLine = [codeParser getSingleLineCommentsStr];
    multiLineS = [codeParser getMultiLineCommentsStartStr];
    multiLineE = [codeParser getMultiLineCommentsEndStr];
    keywords = [codeParser getKeywordsStr];
    
    [self setField:name andExtention:extention andSingleLine:singleLine andMultiLineS:multiLineS andMultLineE:multiLineE andKeywords:keywords andEnable:NO];
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
    return @"Manually";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    currentSelected = row;
    if (row < [parserArray count]) {
        [self predefParserSelected];
        return;
    }
    int index = row - [parserArray count];
    if (index > -1 && index < [manuallyParserArray count]) {
        [self predefParserSelected];
        return;
    }
    else {        
        [self setField:@"" andExtention:@"" andSingleLine:@"" andMultiLineS:@"" andMultLineE:@"" andKeywords:@"" andEnable:YES];
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
    } else if (type == UNKNOWN) {
        currentSelected = [parserArray count]+[manuallyParserArray count];
    }
    else {
        //it's a manually type
        currentSelected = [parserArray count] + manuallyIndex;
    }
    [self.parserTypePicker selectRow:currentSelected inComponent:0 animated:YES];
    
    [self predefParserSelected];
}


@end
