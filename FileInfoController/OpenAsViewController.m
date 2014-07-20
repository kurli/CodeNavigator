//
//  OpenAsViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 10/6/13.
//
//

#import "OpenAsViewController.h"
#import "Parser.h"
#import "Utils.h"
#import "DetailViewController.h"
#import "MasterViewController.h"
#import "ManuallyParserViewController.h"

@interface OpenAsViewController ()
{
    NSInteger currentSelected;
}
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@end

@implementation OpenAsViewController

@synthesize parserTypePicker;
@synthesize filePath;
@synthesize parserArray;
@synthesize manuallyParserArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self setParserTypePicker:nil];
    [self setFilePath:nil];
    [self setParserArray:nil];
    [self setManuallyParserArray:nil];
}

- (void)viewDidLoad
{
    parserArray = [[NSMutableArray alloc] initWithObjects:PREDEF_PARSER, nil];
    currentSelected = -1;
    manuallyParserArray = [Parser getManuallyParserNames];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    [self setParserTypePicker:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
//    self.contentSizeForViewInPopover = self.view.frame.size;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self.navigationController setTitle:@"Open As"];
#ifdef IPHONE_VERSION
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
#ifdef IPHONE_VERSION
    [self.infoButton setHidden:YES];
    [self.infoLabel setHidden:YES];
    [self.infoLabel setEnabled:NO];
    [self.infoButton setEnabled:NO];
#endif
}

- (IBAction)doneButtonClicked:(id)sender
{
    ParserType type = UNKNOWN;
    if (currentSelected < HTML) {
        type = currentSelected;
    } else {
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
    [parser startParseAndWait];
    [parser startParse:^(){
        dispatch_async(dispatch_get_main_queue(), ^{
        NSString* html = [parser getHtml];
        NSError* error;
        //rc4Result = [self HloveyRC4:html key:@"lgz"];
        [html writeToFile:displayPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        [[Utils getInstance].detailViewController setTitle:[filePath lastPathComponent] andPath:filePath andContent:html andBaseUrl:nil];
        
        // Release popover controller
        MasterViewController* _masterViewController = nil;
        _masterViewController = [Utils getInstance].masterViewController;
        [_masterViewController releaseAllPopover];
        });
    }];
    
}

#pragma mark picker view
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row < [parserArray count]) {
        return [parserArray objectAtIndex:row];
    }
    NSInteger index = row - [parserArray count];
    if (index > -1 && index < [manuallyParserArray count]) {
        return [manuallyParserArray objectAtIndex:index];
    }
    return @"Unknown";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    currentSelected = row;
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [parserArray count] + [manuallyParserArray count] + 1;
}

- (IBAction)addButtonClicked:(id)sender {
    ManuallyParserViewController* viewController = [[ManuallyParserViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [viewController setFilePath:filePath];
    [[Utils getInstance].splitViewController presentViewController:viewController animated:YES completion:nil];
    
    // Release popover controller
    MasterViewController* _masterViewController = nil;
    _masterViewController = [Utils getInstance].masterViewController;
    [_masterViewController releaseAllPopover];
}
@end
