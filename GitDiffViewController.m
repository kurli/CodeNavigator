//
//  GitDiffViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 4/2/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "GitDiffViewController.h"
#import "DiffFileListController.h"
#import "GTObject.h"
#import "GitLogViewCongroller.h"
#import "GTBlob.h"
#import "Parser.h"
#import "DiffInfoListViewController.h"

#import "diff.h"

typedef enum _changeType
{
    CHANGE_TYPE_MODIFIED,
    CHANGE_TYPE_DELETED,
    CHANGE_TYPE_ADDED
} CHANGE_TYPE;

@implementation GitDiffViewController
@synthesize diffFileArray;
@synthesize webView;
@synthesize popOverController;
@synthesize diffAnalyzeArray;
@synthesize toolBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentDisplayIndex = 0;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setCurrentDisplayIndex:0];
}

- (void)dealloc
{
    //[self.diffFileArray removeAllObjects];
    [self setDiffFileArray:nil];
    [self.diffAnalyzeArray removeAllObjects];
    [self setDiffAnalyzeArray:nil];
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self setWebView:nil];
    [self setPopOverController:nil];
}

- (void)viewDidUnload
{
    //[self.diffFileArray removeAllObjects];
    //[self setDiffFileArray:nil];
    //[self.diffAnalyzeArray removeAllObjects];
    //[self setDiffAnalyzeArray:nil];
    [self setWebView:nil];
    [self.popOverController dismissPopoverAnimated:YES];
    [self setPopOverController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)backbuttonClicked:(id)sender {
    [popOverController dismissPopoverAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)diffFileListClicked:(id)sender {
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
    
    if ([popOverController isPopoverVisible] == YES) {
        [popOverController dismissPopoverAnimated:YES];
        return;
    }
    
    DiffFileListController* diffFileListController = [[DiffFileListController alloc] init];
    [diffFileListController setGitDiffViewController:self];
    
    [diffFileListController setDiffFileArray:diffFileArray];
    
#ifdef IPHONE_VERSION
    self.popOverController = [[FPPopoverController alloc] initWithContentViewController:diffFileListController];
#else
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:diffFileListController];
#endif
    CGSize size = diffFileListController.view.frame.size;
    size.width = size.width / 2;
    size.height = size.height /2;
    popOverController.popoverContentSize = size;
#ifdef IPHONE_VERSION
    [popOverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES andToolBar:self.toolBar];
#else
    [popOverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
#endif
}

- (void) generateDiffItem:(NSString*)diffContent andNewHtml:(NSMutableArray*)newHtml andOldHtml:(NSMutableArray*)oldHtml
{
    NSArray* infoArray = [diffContent componentsSeparatedByString:@"\n"];
    if ([infoArray count] == 0) {
        return;
    }
    
    int start1 = 0;
    int end1 = 0;
    int start2 = 0;
    int end2 = 0;
    CHANGE_TYPE type;
    
    // get line info
    NSString* lineInfo = [infoArray objectAtIndex:0];
    NSMutableString* temp = [[NSMutableString alloc] init];
    int index = 0;
    while (true) {
        if (index >= [lineInfo length]) {
            return;
        }
        unichar c = [lineInfo characterAtIndex:index];
        if (c >= '0' && c <= '9') {
            index++;
            [temp appendFormat:@"%c", c];
            continue;
        }
        break;
    }
    start1 = [temp intValue];
    end1 = start1;
    NSRange range;
    range.location = 0;
    range.length = [temp length];
    [temp deleteCharactersInRange:range];
    
    //check whether end1 is exist
    if (index < [lineInfo length] && [lineInfo characterAtIndex:index] == ',') {
        index++;
        while (true) {
            if (index >= [lineInfo length]) {
                return;
            }
            unichar c = [lineInfo characterAtIndex:index];
            if (c >= '0' && c <= '9') {
                index++;
                [temp appendFormat:@"%c", c];
                continue;
            }
            break;
        }
        end1 = [temp intValue];
        range.location = 0;
        range.length = [temp length];
        [temp deleteCharactersInRange:range];
    }
    else
        end1 = start1;
    
    if (index >= [lineInfo length]) {
        return;
    }
    
    NSString* bgColor;
    switch (colorStep % 5) {
        case 0:
            bgColor = @"<td style=\"background:#450000\">";
            break;
        case 1:
            bgColor = @"<td style=\"background:#450033\">";
            break;
        case 2:
            bgColor = @"<td style=\"background:#453300\">";
            break;
        case 3:
            bgColor = @"<td style=\"background:#453333\">";
            break;
        case 4:
            bgColor = @"<td style=\"background:#334500\">";
            break;
        default:
            break;
    }
    // get change type
    switch ([lineInfo characterAtIndex:index]) {
        case 'c':
            type = CHANGE_TYPE_MODIFIED;
            //bgColor = [NSString stringWithFormat:@"<td style=\"background:#%d\">", colorStep];
            break;
        case 'a':
            type = CHANGE_TYPE_ADDED;
            //bgColor = [NSString stringWithFormat:@"<td style=\"background:#%d\">", colorStep];
            break;
        case 'd':
            type = CHANGE_TYPE_DELETED;
            //bgColor = [NSString stringWithFormat:@"<td style=\"background:#%d\">", colorStep];
            break;
        default:
            break;
    }
    index++;
    
    // get start2
    while (true) {
        if (index >= [lineInfo length]) {
            break;
        }
        unichar c = [lineInfo characterAtIndex:index];
        if (c >= '0' && c <= '9') {
            index++;
            [temp appendFormat:@"%c", c];
            continue;
        }
        break;
    }
    start2 = [temp intValue];
    end2 = start2;
    range.location = 0;
    range.length = [temp length];
    [temp deleteCharactersInRange:range];
    
    //check whether end2 is exist
    if (index < [lineInfo length] && [lineInfo characterAtIndex:index] == ',') {
        index++;
        while (true) {
            if (index >= [lineInfo length]) {
                break;
            }
            unichar c = [lineInfo characterAtIndex:index];
            if (c >= '0' && c <= '9') {
                index++;
                [temp appendFormat:@"%c", c];
                continue;
            }
            break;
        }
        end2 = [temp intValue];
    }
    else
        end2 = start2;
    
    // get <br> count also
    int newBRCount = 0;
    int oldBRCount = 0;
    // newObj html generator
    if (end2 >= [newHtml count]) {
        return;
    }
    for (int i = start2; i<=end2; i++) {
        NSString* newCurrentLine = [newHtml objectAtIndex:i];
        //check <br> count
        range.location = 0;
        range.length = newCurrentLine.length;
        while (range.location != NSNotFound) {
            range = [newCurrentLine rangeOfString:@"<br>" options:0 range:range];
            if (range.location != NSNotFound) {
                range = NSMakeRange(range.location + range.length, [newCurrentLine length] - (range.location + range.length));
                newBRCount++;
            }
        }
        newBRCount++;
        //<br> check end
        newCurrentLine = [newCurrentLine stringByReplacingOccurrencesOfString:@"<td>" withString:bgColor];
        [newHtml replaceObjectAtIndex:i withObject:newCurrentLine];
    }
    
    // oldObj html generator
    if (end1 >= [oldHtml count]) {
        return;
    }
    for (int i = start1; i<=end1; i++) {
        NSString* newCurrentLine = [oldHtml objectAtIndex:i];
        newCurrentLine = [newCurrentLine stringByReplacingOccurrencesOfString:@"<td>" withString:bgColor];
        //check <br> count
        range.location = 0;
        range.length = newCurrentLine.length;
        while (range.location != NSNotFound) {
            range = [newCurrentLine rangeOfString:@"<br>" options:0 range:range];
            if (range.location != NSNotFound) {
                range = NSMakeRange(range.location + range.length, [newCurrentLine length] - (range.location + range.length));
                oldBRCount++;
            }
        }
        oldBRCount++;
        //<br> check end
        [oldHtml replaceObjectAtIndex:i withObject:newCurrentLine];
    }
    
    if (type == CHANGE_TYPE_MODIFIED) {
        //Make height same
        if (newBRCount > oldBRCount) {
            NSMutableString* brStr = [[NSMutableString alloc] initWithString:@"<br>"];
            for (int i=oldBRCount; i<newBRCount; i++) {
                [brStr appendString:@"· <br>"];
            }
            [brStr appendString:@"</td>"];
            NSString* oldEndLine = [oldHtml objectAtIndex:end1];
            oldEndLine = [oldEndLine stringByReplacingOccurrencesOfString:@"</td>" withString:brStr];
            [oldHtml replaceObjectAtIndex:end1 withObject:oldEndLine];
        }
        else if (newBRCount < oldBRCount)
        {
            NSMutableString* brStr = [[NSMutableString alloc] initWithString:@"<br>"];
            for (int i=newBRCount; i<oldBRCount; i++) {
                [brStr appendString:@"· <br>"];
            }
            [brStr appendString:@"</td>"];
            NSString* newEndLine = [newHtml objectAtIndex:end2];
            newEndLine = [newEndLine stringByReplacingOccurrencesOfString:@"</td>" withString:brStr];
            [newHtml replaceObjectAtIndex:end2 withObject:newEndLine];
        }
    }
    else if (type == CHANGE_TYPE_DELETED)
    {
        NSMutableString* brStr = [[NSMutableString alloc] initWithString:@"<br>"];
        for (int i=0; i<oldBRCount; i++) {
            [brStr appendString:@"· <br>"];
        }
        [brStr appendString:@"</td>"];
        NSString* newEndLine = [newHtml objectAtIndex:end2];
        newEndLine = [newEndLine stringByReplacingOccurrencesOfString:@"</td>" withString:brStr];
        [newHtml replaceObjectAtIndex:end2 withObject:newEndLine];
    }
    else if (type == CHANGE_TYPE_ADDED)
    {
        NSMutableString* brStr = [[NSMutableString alloc] initWithString:@"<br>"];
        for (int i=0; i<newBRCount; i++) {
            [brStr appendString:@"· <br>"];
        }
        [brStr appendString:@"</td>"];
        NSString* oldEndLine = [oldHtml objectAtIndex:end1];
        oldEndLine = [oldEndLine stringByReplacingOccurrencesOfString:@"</td>" withString:brStr];
        [oldHtml replaceObjectAtIndex:end1 withObject:oldEndLine];
    }
    //NSLog([NSString stringWithFormat:@"%d,%d:%d:%d,%d", start2, end2, type, start1, end1]);
}

- (void) generateDiff:(NSString*)diffContent andNewHtml:(NSMutableArray*)newHtml andOldHtml:(NSMutableArray*)oldHtml
{
    NSArray* contents = [diffContent componentsSeparatedByString:@"\n"];
    NSMutableString* diffLines = nil;
    self.diffAnalyzeArray = [[NSMutableArray alloc] init];
    
    //Analyze diff content
    for (int i=0; i<[contents count]; i++) {
        NSString* lineContent = [contents objectAtIndex:i];
        if ([lineContent length] == 0) {
            continue;
        }
        unichar firstChar = [lineContent characterAtIndex:0];
        if (firstChar >='0' && firstChar<='9') {
            if (diffLines != nil) {
                [diffAnalyzeArray addObject:diffLines];
            }
            diffLines = [[NSMutableString alloc]initWithString:lineContent];
            [diffLines appendString:@"\n"];
            continue;
        }
        [diffLines appendString:lineContent];
        [diffLines appendString:@"\n"];
    }
    // store the last one
    if (diffLines != nil) {
        [diffAnalyzeArray addObject:diffLines];
    }
    
    //generate diff html
    for (int i=0; i<[diffAnalyzeArray count]; i++) {
        NSString* analyzeItem = [diffAnalyzeArray objectAtIndex:i];
        [self generateDiffItem:analyzeItem andNewHtml:newHtml andOldHtml:oldHtml];
        colorStep++;
    }
}

- (void) setCurrentDisplayIndex:(NSInteger)index
{
    colorStep = 0;
    currentDisplayIndex = index;
    [popOverController dismissPopoverAnimated:YES];
    
    //change webview to the diff content
    if (index >= [diffFileArray count]) {
        NSLog(@"diffFileArray out of range in setCurrentDisplayIndex");
        return;
    }
    PendingData* data = [diffFileArray objectAtIndex:index];
    GTObject* newObj = data.neObj;
    GTObject* oldObj = data.oldObj;
    
    if ([newObj.type compare:@"blob"] != NSOrderedSame ||
        [oldObj.type compare:@"blob"] != NSOrderedSame) 
    {
        return;
    }
    
    GTBlob* newBolb = (GTBlob*)newObj;
    GTBlob* oldBolb = (GTBlob*)oldObj;
    
    NSError* error;
    NSString *tempPath = NSTemporaryDirectory();
    NSString* diff1FilePath = [tempPath stringByAppendingPathComponent:@"diff1.tmp"];
    NSString* diff2FilePath = [tempPath stringByAppendingPathComponent:@"diff2.tmp"];
    [newBolb.content writeToFile:diff1FilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [oldBolb.content writeToFile:diff2FilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSString* diffFilePath = [tempPath stringByAppendingPathComponent:@"diff.tmp"];
    
    const char *cmd[3];
    cmd[0] = [diff2FilePath cStringUsingEncoding:NSUTF8StringEncoding];
    cmd[1] = [diff1FilePath cStringUsingEncoding:NSUTF8StringEncoding];
    cmd[2] = [diffFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (newBolb.content != nil && oldBolb.content != nil) {
        _diff(cmd);
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:diffFilePath error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:diff1FilePath error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:diff2FilePath error:&error];
    }
    
    NSString* diffContent = [NSString stringWithContentsOfFile:diffFilePath encoding:NSUTF8StringEncoding error:&error];
    //NSLog(diffContent);
//    if ([diffContent length] == 0) {
//        return;
//    }
    
    // get html file for new obj
    NSString* newHtml;
    NSString* oldHtml;
    Parser* parser = [[Parser alloc] init];
    [parser checkParseType:data.path];
    [parser setContent:newBolb.content andProjectBase:nil];
    [parser setMaxLineCount:35];
    [parser startParse];
    newHtml = [parser getHtml];
    
    // get html file for old obj
    parser = [[Parser alloc] init];
    [parser checkParseType:data.path];
    [parser setContent:oldBolb.content andProjectBase:nil];
    [parser setMaxLineCount:35];
    [parser startParse];
    oldHtml = [parser getHtml];
    
    NSMutableArray* oldHtmlArray = [[NSMutableArray alloc] initWithArray:[oldHtml componentsSeparatedByString:@"<tr id="]];
    NSMutableArray* newHtmlArray = [[NSMutableArray alloc] initWithArray:[newHtml componentsSeparatedByString:@"<tr id="]];
    
    [self generateDiff:diffContent andNewHtml:newHtmlArray andOldHtml:oldHtmlArray];
    
    NSMutableString* outNewHtml = [[NSMutableString alloc] init];
    [outNewHtml appendString:[newHtmlArray objectAtIndex:0]];
    for (int i=1; i<[newHtmlArray count]; i++) {
        [outNewHtml appendFormat:@"<tr id=%@", [newHtmlArray objectAtIndex:i]];
    }
    NSMutableString* outOldHtml = [[NSMutableString alloc] init];
    [outOldHtml appendString:[oldHtmlArray objectAtIndex:0]];
    for (int i=1; i<[oldHtmlArray count]; i++) {
        [outOldHtml appendFormat:@"<tr id=%@", [oldHtmlArray objectAtIndex:i]];
    }
    
    NSURL *baseURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"] isDirectory:YES];
    [outNewHtml writeToFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/1.html"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [outOldHtml writeToFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/2.html"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSString* html = [NSString stringWithFormat:DIFF_HTML, @"./1.html", @"./2.html"];
    
    [self.webView loadHTMLString:html baseURL:baseURL];
}

- (NSInteger) getCurrentDisplayIndex
{
    return currentDisplayIndex;
}

- (IBAction)diffInfoClicked:(id)sender {
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
    
    if ([popOverController isPopoverVisible] == YES) {
        [popOverController dismissPopoverAnimated:YES];
        return;
    }
    
    DiffInfoListViewController* diffFileListController = [[DiffInfoListViewController alloc] init];
    [diffFileListController setGitDiffViewController:self];
    
    [diffFileListController setDiffAnalyzeList:diffAnalyzeArray];
    
#ifdef IPHONE_VERSION
    self.popOverController = [[FPPopoverController alloc] initWithContentViewController:diffFileListController];
#else
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:diffFileListController];
#endif
    CGSize size = diffFileListController.view.frame.size;
    size.width = size.width / 2;
    size.height = size.height / 2;
    popOverController.popoverContentSize = size;
#ifdef IPHONE_VERSION
    [popOverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES andToolBar:self.toolBar];
#else
    [popOverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
#endif
}

-(void) showDiffInfo:(NSInteger)index
{
    if (index >= [diffAnalyzeArray count]) {
        return;
    }
    NSString* info = [diffAnalyzeArray objectAtIndex:index];
    NSArray* array = [info componentsSeparatedByString:@"\n"];
    if (array <= 0) {
        return;
    }
    NSString* diff = [array objectAtIndex:0];
    NSInteger i = 0;
    while (true) {
        if (i >= [diff length]) {
            return;
        }
        unichar c = [diff characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            i++;
            continue;
        }
        break;
    }
    
    NSInteger linePos = [[diff substringToIndex:i] intValue];
    if (linePos > 5) {
        linePos -= 5;
    }
    
    NSString* js = [NSString stringWithFormat:@"var elm = top.window.frames['oldFile'].document.getElementById('L%ld');\
                    var y = elm.offsetTop;\
                    var node = elm;\
                    while (node.offsetParent && node.offsetParent != document.body) {\
                    node = node.offsetParent;\
                    y += node.offsetTop;\
                    } scrollTo(0, y);", linePos];
    //NSString* js = @"alert(top.window.frames['newFile'].document.getElementById('L51'))";
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}
@end
