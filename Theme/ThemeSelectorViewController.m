//
//  ThemeSelectorViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 4/2/14.
//
//

#import "ThemeSelectorViewController.h"
#import "Utils.h"
#import "Parser.h"
#import "DetailViewController.h"
#import "DisplayController.h"

#define LINE_WRAP_NA @"999999"
#define LINE_WRAP_SM @"80"
#define LINE_WRAP_BG @"140"

#define FONT_STANDARD @"monospace"
#define FONT_SOURCE_CODE_PRO @"Source Code Pro"

#define DEMO_SOURCE_CODE @"\
// CodeNavigator ★★★★★\n\
// 1. You can not have your cake and eat it too\n\
\n\
#include <CodeNavigator.h>\n\
#include \"BetterAndBetter.h\"\n\
\n\
void main() {\n\
	int action_ount = 1234567890;\n\
	\n\
	unsigned char *action = \"Rate me to make me better\";\n\
    \n\
	unsigned char *lineWrap = \"1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890\";\n\
\n\
	for (int i=0; i<365; i++) {\n\
		*action = \"Better work\";\n\
		*action = \"Better life\";\n\
		*action = \"Better Work-Life Balance.\";\n\
	}\n\
\n\
	printf(\"How to contact me:\");\n\
	printf(\"guangzhen@hotmail.com\");\n\
\n\
	printk(\"Do Not Forget To Rate Me On The AppStore.  :-)\");\n\
}\n\
"

@interface ThemeSelectorViewController () {
    int selectedTheme;
}
@property (weak, nonatomic) IBOutlet UITextField *lineWrapTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lineWrapSegmentController;
@property (weak, nonatomic) IBOutlet UITextField *fontSizeTextField;
@property (weak, nonatomic) IBOutlet UIStepper *fontSizeStepper;
@property (weak, nonatomic) IBOutlet JTListView *themeListView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSArray* themes;
@property (strong, nonatomic) ThemeSchema* colorScheme;
@property (strong, nonatomic) NSArray* fonts;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fontFamilySegmentController;
@end

@implementation ThemeSelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.colorScheme = [[Utils getInstance].currentThemeSetting copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.fonts = [UIFont familyNames];
//    NSArray* fonts = [UIFont fontNamesForFamilyName:@"Source Code Pro"];
//    NSLog(@"%d", [fonts count]);
    
    // Get theme list
    NSString* currentThemeName = self.colorScheme.theme;
    currentThemeName = [currentThemeName stringByAppendingPathExtension:@"plist"];
    
    NSString* themeBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Themes"];
    NSArray* thems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themeBundlePath error:nil];
    NSMutableArray* multiThemes = [[NSMutableArray alloc] init];
    for (int i=0; i<[thems count]; i++) {
        NSString* item = [thems objectAtIndex:i];
        if ([item isEqualToString:@"theme.plist"] == YES) {
            continue;
        } else if([item isEqualToString:currentThemeName]) {
            selectedTheme = i;
        }
        [multiThemes addObject:[item stringByDeletingPathExtension]];
    }
    self.themes = multiThemes;
    
    [self.webView setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)applyButtonClicked:(id)sender {
    ThemeSchema* currentScheme = [Utils getInstance].currentThemeSetting;
    if ([currentScheme.max_line_count isEqualToString:self.colorScheme.max_line_count] == NO) {
        DisplayController* displayController = [[DisplayController alloc] init];
        [displayController removeAllDisplayFiles];
    }
    
    [[Utils getInstance] setCurrentThemeSetting:self.colorScheme];
    NSString* css = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/theme.css"];
    [ThemeManager generateCSSScheme:css andTheme:self.colorScheme];
    [[Utils getInstance] incressCSSVersion];
    [[Utils getInstance].detailViewController reloadCurrentPage];
    
    if (selectedTheme < [self.themes count]) {
        [ThemeManager updateThemeByName:[self.themes objectAtIndex:selectedTheme]];
    }
    
    [ThemeManager changeUIViewStyle:[Utils getInstance].detailViewController.webView];
    [ThemeManager changeUIViewStyle:[Utils getInstance].detailViewController.secondWebView];
    [ThemeManager changeUIViewStyle:[Utils getInstance].detailViewController.view];

    [self dismissModalViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    self.listView = self.themeListView;
    self.listView.dataSource = self;
    self.listView.delegate = self;
    self.listView.gapBetweenItems = 5;
    [super viewWillAppear:animated];
    
    // Set UI by color scheme
    [self.lineWrapTextField setText:self.colorScheme.max_line_count];
    if ([LINE_WRAP_NA compare:self.colorScheme.max_line_count] == NSOrderedSame) {
        [self.lineWrapSegmentController setSelectedSegmentIndex:0];
    } else if ([LINE_WRAP_SM compare:self.colorScheme.max_line_count] == NSOrderedSame) {
        [self.lineWrapSegmentController setSelectedSegmentIndex:1];
    } else if ([LINE_WRAP_BG compare:self.colorScheme.max_line_count] == NSOrderedSame) {
        [self.lineWrapSegmentController setSelectedSegmentIndex:2];
    } else {
        [self.lineWrapSegmentController setSelectedSegmentIndex:3];
        [self showLineWrapTextField];
    }
    
    // fontSize
    [self.fontSizeTextField setText:self.colorScheme.font_size];
    [self.fontSizeStepper setValue:[self.colorScheme.font_size intValue]];
    
    // font
    if ([FONT_STANDARD compare:self.colorScheme.font_family] == NSOrderedSame) {
        [self.fontFamilySegmentController setSelectedSegmentIndex:0];
    } else if ([FONT_SOURCE_CODE_PRO compare:self.colorScheme.font_family] == NSOrderedSame) {
        [self.fontFamilySegmentController setSelectedSegmentIndex:1];
    }
}

- (void) displayDemo {
    NSString* css = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/theme_tmp.css"];
    [ThemeManager generateCSSScheme:css andTheme:self.colorScheme];
    
    Parser* parser = [[Parser alloc] init];
    [parser setParserType:CPLUSPLUS];
    [parser setContent:DEMO_SOURCE_CODE andProjectBase:nil];
    [parser setMaxLineCount:[self.colorScheme.max_line_count intValue]];
    [parser startParse];
    NSString* html = [parser getHtml];
    html = [html stringByReplacingOccurrencesOfString:@"theme.css" withString:@"theme_tmp.css"];
    
    NSURL *baseURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"] isDirectory:YES];
    [self.webView loadHTMLString:html baseURL:baseURL];
    NSString*  bgcolor = self.colorScheme.background;
    if ([bgcolor length] != 7)
        return;
    bgcolor = [bgcolor substringFromIndex:1];
    unsigned int baseValue;
    if ([[NSScanner scannerWithString:bgcolor] scanHexInt:&baseValue])
    {
        [self.webView setBackgroundColor:UIColorFromRGB(baseValue)];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.listView scrollToItemAtIndex:selectedTheme atScrollPosition:JTListViewScrollPositionCenter animated:YES];
    });
    [self displayDemo];
}

- (void) showLineWrapTextField {
    CGRect textField = self.lineWrapTextField.frame;
    CGRect segment = self.lineWrapSegmentController.frame;
    
    if (![self.lineWrapTextField isHidden]) {
        return;
    }
    segment.origin.x = textField.origin.x - segment.size.width;
    [self.lineWrapTextField setHidden:NO];
    [self.lineWrapTextField becomeFirstResponder];
    [UIView beginAnimations:@"ShowTextField"context:nil];
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [self.lineWrapSegmentController setFrame:segment];
    [UIView commitAnimations];
}

- (void) showLineWrapSegmentController {
    CGRect textField = self.lineWrapTextField.frame;
    CGRect segment = self.lineWrapSegmentController.frame;
    
    if ([self.lineWrapTextField isHidden]) {
        return;
    }
    segment.origin.x = textField.origin.x + textField.size.width - segment.size.width;
    [self.lineWrapTextField resignFirstResponder];
    [self.view endEditing:YES];
    [self.lineWrapTextField setHidden:YES];
    [UIView beginAnimations:@"ShowSegment"context:nil];
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [self.lineWrapSegmentController setFrame:segment];
    [UIView commitAnimations];
}

- (IBAction)lineWrapSegmentValueChanged:(id)sender {
    UISegmentedControl* controller = (UISegmentedControl*) sender;
    if (controller.selectedSegmentIndex == 3) {
        [self showLineWrapTextField];
    } else {
        [self showLineWrapSegmentController];
    }
    
    switch (controller.selectedSegmentIndex) {
        case 0:
            self.colorScheme.max_line_count = LINE_WRAP_NA;
            [self displayDemo];
            break;
        case 1:
            self.colorScheme.max_line_count = LINE_WRAP_SM;
            [self displayDemo];
            [self.lineWrapTextField setText:LINE_WRAP_SM];
            break;
        case 2:
            self.colorScheme.max_line_count = LINE_WRAP_BG;
            [self displayDemo];
            [self.lineWrapTextField setText:LINE_WRAP_BG];
            break;
        default:
            break;
    }
}

- (BOOL) checkWhetherInt:(NSString*)str {
    NSScanner* scan = [NSScanner scannerWithString:str];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (IBAction)lineWrapTextFieldFinishEditing:(id)sender {
    UITextField* textField = (UITextField*)sender;
    if (![self checkWhetherInt:textField.text]) {
        if ([textField.text length] != 0) {
            [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"Invalid value."];
        }
        NSString* maxLine = self.colorScheme.max_line_count;
        if ([maxLine isEqualToString:LINE_WRAP_NA]) {
            self.lineWrapSegmentController.selectedSegmentIndex = 0;
        } else if ([maxLine isEqualToString:LINE_WRAP_SM]) {
            self.lineWrapSegmentController.selectedSegmentIndex = 1;
        } else if ([maxLine isEqualToString:LINE_WRAP_BG]) {
            self.lineWrapSegmentController.selectedSegmentIndex = 2;
        }
        [self showLineWrapSegmentController];
        return;
    }
    int intValue = [textField.text intValue];
    if (intValue < 10) {
        if ([textField.text length] != 0) {
            [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"Invalid value."];
        }
        [self showLineWrapSegmentController];
        return;
    }
    self.colorScheme.max_line_count = textField.text;
    [self displayDemo];
}

- (IBAction)fontSizeTextFieldBeginEdit:(id)sender {
    [self.fontSizeStepper setHidden:YES];
}

- (IBAction)fontSizeTextFieldEndEdit:(id)sender {
    UITextField* textField = (UITextField*)sender;
    
    if ([self checkWhetherInt:textField.text] == NO) {
        [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"Invalid value."];
        return;
    }

    int value = [textField.text intValue];
    
    if (value <= 0) {
        [[Utils getInstance] alertWithTitle:@"Error" andMessage:@"Invalid value."];
        return;
    }
    
    [self.fontSizeStepper setValue:value];
    self.colorScheme.font_size = textField.text;
    [self.fontSizeStepper setHidden:NO];
    
    [self.fontSizeTextField resignFirstResponder];
    [self.view endEditing:YES];
    
    [self displayDemo];
}

- (IBAction)fontSizeStepperValueChanged:(id)sender {
    UIStepper* stepper = (UIStepper*) sender;
    NSString* str = [[NSString alloc] initWithFormat:@"%d", (int)stepper.value];
    [self.fontSizeTextField setText:str];
    [self.colorScheme setFont_size:str];
    [self displayDemo];
}

- (IBAction)fontFamilyValueChanged:(id)sender {
    UISegmentedControl* controller = (UISegmentedControl*)sender;
    switch (controller.selectedSegmentIndex) {
        case 0:
            [self.colorScheme setFont_family:@"monospace"];
            break;
        case 1:
            [self.colorScheme setFont_family:@"Source Code Pro"];
            break;
        default:
            break;
    }
    [self displayDemo];
}
#pragma Theme ListView
- (NSUInteger)numberOfItemsInListView:(JTListView *)listView
{
    return [self.themes count];
}

-(void)themeSelectedAction:(id)obj
{
    UIButton* button = (UIButton*)obj;
    int i = 0;
    selectedTheme = -1;
    for (i=0; i<[self.themes count]; i++) {
        if ([[self.themes objectAtIndex:i] isEqualToString:button.titleLabel.text]) {
            selectedTheme = i;
            [self.listView reloadData];
            [self.listView scrollToItemAtIndex:i atScrollPosition:JTListViewScrollPositionCenter animated:YES];
            [self.colorScheme setTheme:button.titleLabel.text];
            break;
        }
    }
    
    if (selectedTheme < 0 || selectedTheme > [self.themes count] || [self.themes count] == 0) {
        return;
    }
    [ThemeManager readColorSchemeByThemeName:[self.themes objectAtIndex:selectedTheme] andScheme:self.colorScheme];
    
    [self displayDemo];
}

- (UIColor*) getColorFromHex:(NSString*) hex {
    UIColor* color = UIColorFromRGB(0);
    if ([hex length] == 7) {
        hex = [hex substringFromIndex:1];
        unsigned int baseValue;
        if ([[NSScanner scannerWithString:hex] scanHexInt:&baseValue])
        {
            color = UIColorFromRGB(baseValue);
        }
    }
    return color;
}

- (UIView *)listView:(JTListView *)listView viewForItemAtIndex:(NSUInteger)index
{
    UIView *view = [listView dequeueReusableView];
    
    if (!view) {
        view = [[UIView alloc] init];

        UIButton *button = [[UIButton alloc] initWithFrame:view.bounds];
        button.center = view.center;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [button setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]
                     forState:UIControlStateNormal];
        button.tag = 1;
        [button addTarget:self action:@selector(themeSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:button];
    }
    
//    view.backgroundColor = [UIColor colorWithHue:(float)(index % 7) / 7.0 saturation:0.75 brightness:1.0 alpha:1.0];
    NSDictionary* dictionary = [ThemeManager getThemeByName:[self.themes objectAtIndex:index]];
    
    NSString* background = [dictionary objectForKey:@"background"];
    
    [(UIButton *)[view viewWithTag:1] setTitle:[self.themes objectAtIndex:index] forState:UIControlStateNormal];

    NSString* colorStr = [dictionary objectForKey:@"other"];
    UIColor* color = [self getColorFromHex:colorStr];
    
    if (index == selectedTheme) {
        UIFont* font = [UIFont systemFontOfSize:25];
        [((UIButton *)[view viewWithTag:1]).titleLabel setFont:font];
        [(UIButton *)[view viewWithTag:1]  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [view setBackgroundColor:[UIColor blueColor]];
    } else {
        [view setBackgroundColor:[self getColorFromHex:background]];
        
        UIFont* font = [UIFont systemFontOfSize:15];
        [((UIButton *)[view viewWithTag:1]).titleLabel setFont:font];
        [(UIButton *)[view viewWithTag:1]  setTitleColor:color forState:UIControlStateNormal];
    }

    return view;
}

- (CGFloat)listView:(JTListView *)listView widthForItemAtIndex:(NSUInteger)index
{
    return 120;
}

- (CGFloat)listView:(JTListView *)listView heightForItemAtIndex:(NSUInteger)index
{
    return self.themeListView.frame.size.height;
}

@end
