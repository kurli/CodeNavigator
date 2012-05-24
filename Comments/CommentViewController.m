//
//  CommentViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/8/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentWrapper.h"
#import "Utils.h"
#import "DetailViewController.h"

#define HTML_STYLE @" \
.defination { color: #66D9EF; font-style: italic; }\
.comment { color: #008424; font-style: italic; }\
.header { color: #7A482F; }\
.string { color: #E6DB74; }\
.float { color: #996600; }\
.int { color: #999900; }\
.bool { color: #000000; font-weight: bold; }\
.type { color: #FF6633; }\
.flow { color: #FF0000; }\
.keyword { color: #BF40A1; }\
.other { color: #BCBCBC; }\
.operator { color: #663300; font-weight: bold; }\
.system { color: #774499; }\
.number { color: #aa5555; }\
body {\
background:#303040;\
}\
table.code {\
border-spacing: 0;\
border-top: 0;\
border-collapse: collapse; \
empty-cells: show;\
font-size: 20px;\
line-height: 130%;\
padding: 0;\
table-layout: fixed;\
}\
.highlight{background:green;font-weight:bold;color:white;} \
table.code tbody th {\
background: ##303040;\
color: #886;\
font-weight: normal;\
padding: 0 .2em;\
text-align: right;\
vertical-align: top;\
}\
table.code tbody th :link, table.code tbody th :visited {\
border: none;\
color: #886;\
text-decoration: none;\
}\
table.code tbody th :link:hover, table.code tbody th :visited:hover {\
color: #000;\
}\
table.code td {\
font: bold 20px monospace;\
overflow: none;\
padding: 1px 2px;\
vertical-align: top;\
background: #303040;\
font-weight: bold;\
color: #808080;\
-webkit-user-select: text;\
padding-right: 20px;\
}\
"

@interface CommentViewController ()

@end

@implementation CommentViewController

@synthesize line;
@synthesize fileName;
@synthesize upperSource;
@synthesize downSource;
@synthesize upperTextView;
@synthesize commentTextView;
@synthesize downTextView;
@synthesize commentWrapper;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setUpperTextView:nil];
    [self setCommentTextView:nil];
    [self setDownTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [upperTextView setText:upperSource];
    NSRange range;
	range.location= upperSource.length;
	range.length= 60;
	[upperTextView scrollRangeToVisible:range];
    [downTextView setText:downSource];
    [self.commentTextView setText:[self.commentWrapper getCommentByLine:line]];
    [commentTextView becomeFirstResponder];
}

- (void)dealloc
{
    [self setFileName:nil];
    [self setUpperSource:nil];
    [self setDownSource:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)closeClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveButtonClicked:(id)sender {
    [self.commentWrapper addComment:line andComment:commentTextView.text];
    [self.commentWrapper saveToFile];
    [[Utils getInstance].detailViewController showCommentInWebView:line andComment:commentTextView.text];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma eMail related

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
        
//    // Set up recipients
//    NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
//    NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
//    
//    [picker setToRecipients:toRecipients];
//    [picker setCcRecipients:ccRecipients];  
//    [picker setBccRecipients:bccRecipients];
//    
    // Attach an image to the email
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
//    NSData *myData = [NSData dataWithContentsOfFile:path];
//    [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
    
    // Fill out the email body text
//    NSError* error;
//    NSString* displayFilePath = [[Utils getInstance] getDisplayFileBySourceFile:fileName];
//    NSString* displayContent = [NSString stringWithContentsOfFile:displayFilePath encoding:NSUTF8StringEncoding error:&error];
//    NSArray* array = [displayContent componentsSeparatedByString:@"<tr id="];
//    
//    int upperStart;
//    if (line >= 5) {
//        upperStart = line - 5;
//    } else {
//        upperStart = 0;
//    }
//    int downEnd;
//    if ([array count] - line > 5) {
//        downEnd = line + 5;
//    } else {
//        downEnd = [array count] - 1;
//    }
//    
//    NSMutableString *emailBody = [[NSMutableString alloc] init];
//    [emailBody appendFormat:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\"><head><meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" /><style>%@</style></head><body><pre><table class=\"code\"><tbody>", HTML_STYLE];
//    for (int i=upperStart; i<=line; i++) {
//        if (i >= [array count]) {
//            break;
//        }
//        [emailBody appendString:@"<tr id="];
//        [emailBody appendString:[array objectAtIndex:i]];
//    }
//    for (int i = line+1; i<=downEnd; i++) {
//        if (i >= [array count]) {
//            break;
//        }
//        [emailBody appendString:@"<tr id="];
//        [emailBody appendString:[array objectAtIndex:i]];
//    }
//    [emailBody appendString:@"</tbody></table></pre></body></html>"];
    NSArray* array;
    NSMutableString* emailBody = [[NSMutableString alloc] init];
    
    NSString* path = [[Utils getInstance] getPathFromProject:fileName];
    
    [picker setSubject:[NSString stringWithFormat:@"%@--Comment L%d", path, line+1]];
    
    [emailBody appendString:@"<html><body>"];
    //File path
    [emailBody appendFormat:@"<div style= \"background-color:#aaaaaa \">%@<br></div>", path];
    //upper source
    NSString* str;
    str = [upperTextView.text stringByReplacingOccurrencesOfString: @"<" withString:@"&lt;"];
    str = [str stringByReplacingOccurrencesOfString: @">" withString:@"&gt;"];
    array = [str componentsSeparatedByString:@"\n"];
    for (int i=0; i<[array count]; i++) {
        [emailBody appendFormat:@"<div>%@</div>", [array objectAtIndex:i]];
    }
    //comment source
    str = [commentTextView.text stringByReplacingOccurrencesOfString: @"<" withString:@"&lt;"];
    str = [str stringByReplacingOccurrencesOfString: @">" withString:@"&gt;"];
    array = [str componentsSeparatedByString:@"\n"];
    [emailBody appendString:@"<div style= \"background-color:yellow \" >"];
    for (int i=0; i<[array count]; i++) {
        if ([[array objectAtIndex:i] length] ==0) {
            [emailBody appendFormat:@"<div><br></div>"];
        }
        else {
            [emailBody appendFormat:@"<div>%@</div>", [array objectAtIndex:i]];
        }
    }
    [emailBody appendString:@"</div>"];
    //down source
    str = [downTextView.text stringByReplacingOccurrencesOfString: @"<" withString:@"&lt;"];
    str = [str stringByReplacingOccurrencesOfString: @">" withString:@"&gt;"];
    array = [str componentsSeparatedByString:@"\n"];
    for (int i=0; i<[array count]; i++) {
        [emailBody appendFormat:@"<div>%@</div>", [array objectAtIndex:i]];
    }
    //Add signature
    [emailBody appendString:@"<div><br><br>Sent from my iPad <a href=\"http://itunes.apple.com/us/app/codenavigator/id492480832?mt=8\">CodeNavigator</div>"];
    
    [emailBody appendFormat:@"</body></html>"];
    
    [picker setMessageBody:emailBody isHTML:YES];
    
    [self presentModalViewController:picker animated:YES];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Email send complete."];
            break;
        case MFMailComposeResultFailed:
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Email send failed, Please check your Email settings."];
            break;
        default:
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
    NSString *body = @"&body=It is raining in sunny California!";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (IBAction)sendButtonClicked:(id)sender {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
    
    
//    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
//    controller.mailComposeDelegate = nil;
//    [controller setSubject:@"My Subject"];
//    [controller setMessageBody:@"Hello there." isHTML:NO]; 
//    if (controller) [self presentModalViewController:controller animated:YES];
}

- (void) initWithFileName:(NSString *)_fileName
{
    if (line < 0) {
        return;
    }
    line--;
    self.fileName = _fileName;
    
    NSError *error;
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString* fileContent = [NSString stringWithContentsOfFile: fileName usedEncoding:&encoding error: &error];
    if (error != nil || fileContent == nil)
    {
        // Chinese GB2312 support 
        error = nil;
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        fileContent  = [NSString stringWithContentsOfFile:fileName encoding:enc error:&error];
        
        if (fileContent == nil)
        {
            const NSStringEncoding *encodings = [NSString availableStringEncodings];  
            while ((encoding = *encodings++) != 0)  
            {
                fileContent = [NSString stringWithContentsOfFile: fileName encoding:encoding error:&error];
                if (fileContent != nil && error == nil)
                {
                    break;
                }
            }
        }
        
        if (fileContent == nil)
        {
            //TODO
        }
    }
    NSMutableString* str = [[NSMutableString alloc] init];
    NSArray* array = [fileContent componentsSeparatedByString:@"\n"];
    if (line>=[array count]) {
        line = [array count] -1;
    }
    int upperStart;
    if (line >= 5) {
        upperStart = line - 5;
    } else {
        upperStart = 0;
    }
    for (int i=upperStart; i<=line; i++) {
        [str appendFormat:@"%4d: %@", i+1, [array objectAtIndex:i]];
        if (i != line) {
            [str appendString:@"\n"];
        }
    }
    [self setUpperSource:str];
    
    NSMutableString* str2 = [[NSMutableString alloc] init];
    int downEnd;
    if ([array count] - line > 5) {
        downEnd = line + 5;
    } else {
        downEnd = [array count] - 1;
    }
    for (int i = line+1; i<=downEnd; i++) {
        [str2 appendFormat:@"%4d %@", i+1, [array objectAtIndex:i]];
        if (i != downEnd) {
            [str2 appendString:@"\n"];
        }
    }
    [self setDownSource:str2];
    
    //Comment wrapper
    self.commentWrapper = [[CommentWrapper alloc] init];
    NSString* extention = [fileName pathExtension];
    NSString* commentFile = [fileName stringByDeletingPathExtension];
    commentFile = [commentFile stringByAppendingFormat:@"_%@", extention];
    commentFile = [commentFile stringByAppendingPathExtension:@"lgz_comment"];
    [commentWrapper readFromFile:commentFile];
}
@end
