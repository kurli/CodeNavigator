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

#define PREDEF_PARSER @"C/C++", @"Objective-C", @"C#", @"Java", @"Delphi", @"Javascript", @"Pythone", @"Rubby", @"Bash"

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

- (int)checkManuallyParserIndex:(NSString*)extention
{
    for (int i=0; i<[manuallyParserArray count]; i++) {
        NSString* name = [manuallyParserArray objectAtIndex:i];
        NSDictionary* dictionary = [Parser getParserByName:name];
        NSString* extentioin = [dictionary objectForKey:EXTENTION];
        NSArray* array = [extentioin componentsSeparatedByString:@" "];
        for (int j=0; j<[array count]; j++) {
            NSString* ext = [array objectAtIndex:j];
            if ([ext compare:extention] == NSOrderedSame) {
                return i;
            }
        }
    }
    return -1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *extension = [filePath pathExtension];
    extension = [extension lowercaseString];
    ParserType type = UNKNOWN;
    int manuallyIndex = -1;
    
    if ([[[filePath lastPathComponent] lowercaseString] compare:@"makefile"] == NSOrderedSame) {
        type = BASH;
    }
    else if ([extension isEqualToString:@"c"])
    {
        type = CPLUSPLUS;
    }
    else if ([extension isEqualToString:@"cc"])
    {
        type = CPLUSPLUS;
    }
    else if ([extension isEqualToString:@"h"])
    {
        NSError *error;
        NSString* path = [filePath stringByDeletingLastPathComponent];
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
        for (int i =0; i<[contents count]; i++) {
            NSString* tmp = [contents objectAtIndex:i];
            NSString *ext = [tmp pathExtension];
            if ([ext compare:@"m"] == NSOrderedSame)
            {
                type = OBJECTIVE_C;
            }
            if ([ext compare:@"c"] == NSOrderedSame ||
                [ext compare:@"cpp"] == NSOrderedSame)
            {
                type = CPLUSPLUS;
            }
        }
        if (type == UNKNOWN) {
            type = CPLUSPLUS;
        }
    }
    else if ([extension isEqualToString:@"cpp"])
    {
        type = CPLUSPLUS;
    }
    else if ([extension isEqualToString:@"m"])
    {
        type = OBJECTIVE_C;
    }
    else if ([extension isEqualToString:@"cs"])
    {
        type = CSHARP;
    }
    else if ([extension isEqualToString:@"java"])
    {
        type = JAVA;
        return;
    }
    else if ([extension isEqualToString:@"delphi"])
    {
        type = DELPHI;
    }
    else if ([extension isEqualToString:@"pascal"])
    {
        type = DELPHI;
    }
    else if ([extension isEqualToString:@"pas"])
    {
        type = DELPHI;
    }
    else if ([extension isEqualToString:@"mm"])
    {
        type = CPLUSPLUS;
    }
    else if ([extension isEqualToString:@"hpp"])
    {
        type = CPLUSPLUS;
    }
    else if ([extension isEqualToString:@"js"] || [extension isEqualToString:@"jscript"] || [extension isEqualToString:@"javascript"])
    {
        type = JAVASCRIPT;
    }
    else if ([extension isEqualToString:@"py"] || [extension isEqualToString:@"python"])
    {
        type = PYTHONE;
    }
    else if ([extension isEqualToString:@"rails"] || [extension isEqualToString:@"ror"] || [extension isEqualToString:@"ruby"])
    {
        type = RUBBY;
    }
    else if ([extension isEqualToString:@"sh"] || [extension isEqualToString:@"shell"] || [extension isEqualToString:@"bash"])
    {
        type = BASH;
    }
    // s xml sql vb
    else
    {
        manuallyIndex = [self checkManuallyParserIndex:extension];
        if (manuallyIndex > -1) {
            type = -1;
        }
    }
    
    if ( CPLUSPLUS == type )
    {
        [self.parserTypePicker selectRow:0 inComponent:0 animated:YES];
        currentSelected = 0;
    }
    else if( UNKNOWN == type )
    {
        currentSelected = [parserArray count]+[manuallyParserArray count];
        [self.parserTypePicker selectRow:currentSelected inComponent:0 animated:YES];
    }
    else if (OBJECTIVE_C == type)
    {
        [self.parserTypePicker selectRow:1 inComponent:0 animated:YES];
        currentSelected = 1;
    }
    else if (CSHARP == type)
    {
        [self.parserTypePicker selectRow:2 inComponent:0 animated:YES];
        currentSelected = 2;
    }
    else if (JAVA == type)
    {
        [self.parserTypePicker selectRow:3 inComponent:0 animated:YES];
        currentSelected = 3;
    }
    else if (DELPHI == type)
    {
        [self.parserTypePicker selectRow:4 inComponent:0 animated:YES];
        currentSelected = 4;
    }
    else if (JAVASCRIPT == type)
    {
        [self.parserTypePicker selectRow:5 inComponent:0 animated:YES];
        currentSelected = 5;
    }
    else if (PYTHONE == type)
    {
        [self.parserTypePicker selectRow:6 inComponent:0 animated:YES];
        currentSelected = 6;
    }
    else if (RUBBY == type)
    {
        [self.parserTypePicker selectRow:7 inComponent:0 animated:YES];
        currentSelected = 7;
    }
    else if (BASH == type)
    {
        [self.parserTypePicker selectRow:8 inComponent:0 animated:YES];
        currentSelected = 8;
    }
    else {
        //it's a manually type
        currentSelected = [parserArray count] + manuallyIndex;
        [self.parserTypePicker selectRow:currentSelected inComponent:0 animated:YES];
    }

    [self predefParserSelected];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef IPHONE_VERSION
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
#endif
	return YES;
}

- (IBAction)deleteButtonClicked:(id)sender {
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:PARSER_PATH];
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
    
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:PARSER_PATH];
    manuallyParserPath = [manuallyParserPath stringByAppendingPathComponent:name];
    manuallyParserPath = [manuallyParserPath stringByAppendingPathExtension:@"json"];
    [[NSFileManager defaultManager] removeItemAtPath:manuallyParserPath error:nil];
    
    [Parser saveManuallyParser:name andExtention:extention andSingleLine:singleLine andMultiLineS:multiLineS andMultLineE:multiLineE andKeywords:keywords];
    return YES;
}

- (IBAction)doneButtonClicked:(id)sender {
    ParserType type = UNKNOWN;
    BOOL succeed;
    switch (currentSelected) {
        case 0://CPLUSPLUS:
            type = CPLUSPLUS;
            break;
        case 1://OBJECTIVE_C:
            type = OBJECTIVE_C;
            break;
        case 2://CSHARP:
            type = CSHARP;
            break;
        case 3://JAVA:
            type = JAVA;
            break;
        case 4://DELPHI:
            type = DELPHI;
            break;
        case 5://JAVASCRIPT:
            type = JAVASCRIPT;
            break;
        case 6://PYTHONE:
            type = PYTHONE;
            break;
        case 7://RUBBY:
            type = RUBBY;
            break;
        case 8://BASH:
            type = BASH;
            break;
        default:
            succeed = [self saveParser];
            if (!succeed) {
                return;
            }
            type = -1;
            break;
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
    switch (currentSelected) {
        case 0://CPLUSPLUS:
            name = @"C/C++";
            extention = [CPlusPlusParser getExtentionsStr];
            singleLine = [CPlusPlusParser getSingleLineCommentsStr];
            multiLineS = [CPlusPlusParser getMultiLineCommentsStartStr];
            multiLineE = [CPlusPlusParser getMultiLineCommentsEndStr];
            keywords = [CPlusPlusParser getKeywordsStr];
            break;
        case 1://OBJECTIVE_C:
            name = @"Objective-c";
            extention = [ObjectiveCParser getExtentionsStr];
            singleLine = [ObjectiveCParser getSingleLineCommentsStr];
            multiLineS = [ObjectiveCParser getMultiLineCommentsStartStr];
            multiLineE = [ObjectiveCParser getMultiLineCommentsEndStr];
            keywords = [ObjectiveCParser getKeywordsStr];
            break;
        case 2://CSHARP:
            name = @"C#";
            extention = [CSharpParser getExtentionsStr:CSHARP];
            singleLine = [CSharpParser getSingleLineCommentsStr];
            multiLineS = [CSharpParser getMultiLineCommentsStartStr];
            multiLineE = [CSharpParser getMultiLineCommentsEndStr];
            keywords = [CSharpParser getKeywordsStr:CSHARP];
            break;
        case 3://JAVA:
            name = @"Java";
            extention = [CSharpParser getExtentionsStr:JAVA];
            singleLine = [CSharpParser getSingleLineCommentsStr];
            multiLineS = [CSharpParser getMultiLineCommentsStartStr];
            multiLineE = [CSharpParser getMultiLineCommentsEndStr];
            keywords = [CSharpParser getKeywordsStr:JAVA];
            break;
        case 4://DELPHI:
            name = @"Delphi";
            extention = [DelphiParser getExtentionsStr];
            singleLine = [DelphiParser getSingleLineCommentsStr];
            multiLineS = [DelphiParser getMultiLineCommentsStartStr];
            multiLineE = [DelphiParser getMultiLineCommentsEndStr];
            keywords = [DelphiParser getKeywordsStr];
            break;
        case 5://JAVASCRIPT:
            name = @"Javascript";
            extention = [CSharpParser getExtentionsStr:JAVASCRIPT];
            singleLine = [CSharpParser getSingleLineCommentsStr];
            multiLineS = [CSharpParser getMultiLineCommentsStartStr];
            multiLineE = [CSharpParser getMultiLineCommentsEndStr];
            keywords = [CSharpParser getKeywordsStr:JAVASCRIPT];
            break;
        case 6://PYTHONE:
            name = @"Pythone";
            extention = [PythonParser getExtentionsStr];
            singleLine = [PythonParser getSingleLineCommentsStr];
            multiLineS = [PythonParser getMultiLineCommentsStartStr];
            multiLineE = [PythonParser getMultiLineCommentsEndStr];
            keywords = [PythonParser getKeywordsStr];
            break;
        case 7://RUBBY:
            name = @"Rubby";
            extention = [RubbyParser getExtentionsStr];
            singleLine = [RubbyParser getSingleLineCommentsStr];
            multiLineS = [RubbyParser getMultiLineCommentsStartStr];
            multiLineE = [RubbyParser getMultiLineCommentsEndStr];
            keywords = [RubbyParser getKeywordsStr];
            break;
        case 8://BASH:
            name = @"Bash";
            extention = [BashParser getExtentionsStr];
            singleLine = [BashParser getSingleLineCommentsStr];
            multiLineS = [BashParser getMultiLineCommentsStartStr];
            multiLineE = [BashParser getMultiLineCommentsEndStr];
            keywords = [BashParser getKeywordsStr];
            break;
        default:
            manuallyParserIndex = currentSelected - [parserArray count];
            if (manuallyParserIndex > -1 && manuallyParserIndex < [manuallyParserArray count]) {
                name = [manuallyParserArray objectAtIndex:manuallyParserIndex];
                
                NSDictionary* dictionary = [Parser getParserByName:name];
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
            break;
    }
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

@end
