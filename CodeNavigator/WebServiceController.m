//
//  WebServiceController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "WebServiceController.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "localhostAddresses.h"
#import "MasterViewController.h"
#import "FileBrowserViewController.h"
#import "FileListBrowserController.h"

#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"
#import "cscope.h"

@implementation WebServiceController
@synthesize textView;
@synthesize progressView;
@synthesize thread;
@synthesize zipFiles;
@synthesize webServiceSwitcher;
@synthesize masterViewController;
@synthesize httpServer = _httpServer;
@synthesize internetAddress = _internetAddress;
@synthesize uploadToPath;
@synthesize popOverController;
@synthesize _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        needStopZip = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setInternetAddress:nil];
    [self setHttpServer:nil];
//    [self setTextView:nil];
    [self setWebServiceSwitcher:nil];
//    [self setProgressView:nil];
//    [self.zipFiles removeAllObjects];
//    [self setZipFiles:nil];
    [self setMasterViewController:nil];
//    [self setUploadToPath:nil];
//    [popOverController dismissPopoverAnimated:NO];
//    [self setPopOverController:nil];
//    [self set_tableView:nil];
//    [self setStopButton:nil];
//    [self setIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc
{
    [self setThread:nil];
    [self setInternetAddress:nil];
    [self setHttpServer:nil];
    [self setTextView:nil];
    [self setWebServiceSwitcher:nil];
    [self setProgressView:nil];
    [self.zipFiles removeAllObjects];
    [self setZipFiles:nil];
    [self setMasterViewController:nil];
    [self setUploadToPath:nil];
    [popOverController dismissPopoverAnimated:NO];
    [self setPopOverController:nil];
    [self set_tableView:nil];
}

-(void) DoneButtonClickediPad:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(DoneButtonClickediPad:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    if (![self.webServiceSwitcher isOn])
    {
        // Set upload path
        [self setUploadToPath:[masterViewController getCurrentLocation]];

        NSString* relativePath = [[Utils getInstance] getPathFromProject:uploadToPath];
        NSString* info = @"";
        
        if (relativePath == nil || [relativePath length] == 0) {
            [self.textView setText:@"Current upload as a Project\n\nPlease turn on \"Web Upload Service\""];
            return;
        } else {
            info = [info stringByAppendingFormat:@"Current upload to location:  %@\n\nPlease turn on \"Web Upload Service\"", relativePath];
            
            [self.textView setText:info];
        }
    }
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
#ifdef IPHONE_VERSION
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    }
    [_tableView reloadData];
}

-(NSString*) getUploadToPathRelative {
    NSString* str = [[Utils getInstance] getPathFromProject:self.uploadToPath];
    return str;
}

- (IBAction)selectionChanged:(id)sender {
    NSError* error;
	
    if ([sender isOn]){
        //NSString *root = [masterViewController getCurrentLocation];
        //self.uploadToPath = [[masterViewController getCurrentLocation] stringByAppendingString:@""];
        if (_httpServer != nil)
        {
            return;
        }
        _httpServer = [[HTTPServer alloc] init];
        [_httpServer setType:@"_http._tcp."];
        [_httpServer setConnectionClass:[MyHTTPConnection class]];
        [_httpServer setWebUploadResultDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInfoUpdate:) name:@"LocalhostAdressesResolved" object:nil];
        [_httpServer setDocumentRoot:[NSURL fileURLWithPath:uploadToPath]];
        [textView setText:@"Please Wait..."];
        [localhostAddresses performSelectorInBackground:@selector(list) withObject:nil];
        [_httpServer start:&error];
        [[[Utils getInstance] getBannerViewController] showBannerView];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocalhostAdressesResolved" object:nil];
        [_httpServer stop];
        _httpServer = nil;
        [textView setText:@"Please turn on \"Web Upload Service\" to upload files"];
    }
}

- (void)displayInfoUpdate:(NSNotification *) notification
{    
	if(notification)
	{
		_internetAddress = [[notification object] copy];
	}
    
	if(_internetAddress == nil)
	{
        NSLog(@"internet Address nil");
		return;
	}
	
	NSString *info;
	UInt16 port = [_httpServer port];
	
	NSString *localIP = nil;
	
	localIP = [_internetAddress objectForKey:@"en0"];
	
	if (!localIP)
	{
		localIP = [_internetAddress objectForKey:@"en1"];
	}
    
	if (!localIP)
    {
		info = @"No WiFi connection\n Please turn on wifi and try again later\n";
        dispatch_async(dispatch_get_main_queue(), ^{
            //Issue occurred
            //[self.webServiceSwitcher setOn:NO animated:YES];
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:info];
        });
    }
	else
    {
        NSArray* components = [self.uploadToPath pathComponents];
        NSString* path = @"";
        int index = 0;
        for (; index < [components count]; index++)
        {
            if ([((NSString*)[components objectAtIndex:index]) compare:@".Projects"] == NSOrderedSame )
            {
                break;
            }
        }
        if (index == [components count] -1)
        {
            path = @"  Project\n\n Please ZIP your project folder and upload it.";
        }
        else
        {
            path = [components objectAtIndex:++index];
            for (index = index + 1; index<[components count]; index++)
            {
                path = [path stringByAppendingFormat:@"/%@",[components objectAtIndex:index]];
            }
        }
		info = [NSString stringWithFormat:@" Current Upload For: %@ \n\nVisit below website to upload files\n\n http://%@:%d\n", path, localIP, port];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:[NSString stringWithFormat:@"Web Upload Service Address:\n http://%@:%d", localIP, port]];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [textView  setText:@""];
        [self log:info];
    });}

-(void) startUploadingFile:(NSString *)file{
    NSString* info = [textView text];
    if (!info)
    {
        NSLog(@"ERROR in WebServiceController");
        return;
    }
    info = [info stringByAppendingFormat:@"\nStart upload %@",file];
    dispatch_async(dispatch_get_main_queue(), ^{
        [textView  setText:info];
    });
}

-(void) finishUploadingFile:(NSString *)file
{
    NSString* info = [textView text];
    if (!info)
    {
        NSLog(@"ERROR in WebServiceController");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"ERROR in WebServiceController"];
        });
        return;
    }
    
    NSArray* components = [self.uploadToPath pathComponents];
    int index = 0;
    for (; index < [components count]; index++)
    {
        if ([((NSString*)[components objectAtIndex:index]) compare:@".Projects"] == NSOrderedSame )
        {
            break;
        }
    }
    if (index == [components count] -1)
    {
        NSString* extension = [file pathExtension];
        if (extension == nil || [extension compare:@"zip"] != NSOrderedSame)
        {
            NSError *error;
            NSString* myProjectPath = [self.uploadToPath stringByAppendingPathComponent:@"MyProject"];
            //If upload file directly to Project Folder, Help to generate a project folder.
            [[NSFileManager defaultManager] createDirectoryAtPath:myProjectPath withIntermediateDirectories:YES attributes:nil error:&error];
            [[NSFileManager defaultManager] copyItemAtPath:[self.uploadToPath stringByAppendingPathComponent:file] toPath:[myProjectPath stringByAppendingPathComponent:file] error:&error];
            [[NSFileManager defaultManager] removeItemAtPath:[self.uploadToPath stringByAppendingPathComponent:file] error:&error];
            info = [info stringByAppendingFormat:@"\nFinish upload %@ to MyProject",file];
            [self performSelectorOnMainThread:@selector(analyzeProject:) withObject:myProjectPath waitUntilDone:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [textView  setText:info];
                NSRange range;
                range.location= [textView.text length] -6;
                range.length= 5;
                [textView scrollRangeToVisible:range];
                [self.masterViewController reloadData];
            });
            return;
        }
    }

    //if a project file uploaded (zip extension)
    NSString* extension = [file pathExtension];
    if (extension != nil && [extension compare:@"zip"] == NSOrderedSame)
    {
        info = [info stringByAppendingFormat:@"\nFinish upload %@", file];
        dispatch_async(dispatch_get_main_queue(), ^{
            [textView  setText:info];
            NSRange range;
            range.location= [textView.text length] -6;
            range.length= 5;
            [textView scrollRangeToVisible:range];
            [self.masterViewController reloadData];
        });
        if (self.zipFiles == 0)
            self.zipFiles = [[NSMutableArray alloc] init];
        file = [self.uploadToPath stringByAppendingPathComponent:file];
        [self.zipFiles addObject:file];
        if (![thread isExecuting])
        {
            needStopZip = NO;
            [self setThread:nil];
            thread = [[NSThread alloc] initWithTarget:self selector:@selector(unzipThread) object:nil];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [thread start];
            [self.indicator setHidden:NO];
            [self.indicator startAnimating];
            [self.stopButton setHidden:NO];
        }
    }
    else
    {
        info = [info stringByAppendingFormat:@"\nFinish upload %@",file];
        [self performSelectorOnMainThread:@selector(analyzeProject:) withObject:uploadToPath waitUntilDone:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [textView  setText:info];
            NSRange range;
            range.location= [textView.text length] -6;
            range.length= 5;
            [textView scrollRangeToVisible:range];
            [self.masterViewController reloadData];
        });
    }
}

- (void) log:(NSString *)text {	
	textView.text= [textView.text stringByAppendingString:text];
	textView.text= [textView.text stringByAppendingString:@"\n"];
	
	NSRange range;
	range.location= [textView.text length] -6;
	range.length= 5;
	[textView scrollRangeToVisible:range];
}

-(void) setProgressViewValue:(NSNumber*)value
{
    // For iPhone 5.0
    //[self.progressView setProgress:[value floatValue] animated:YES];
    [self.progressView setProgress:[value floatValue]];
}

-(void) hideIndicatorAndButtons {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicator stopAnimating];
        [self.indicator setHidden:YES];
        [self.stopButton setHidden:YES];
        [self.progressView setProgress:0.0f];
    });
}

-(void) unzipThread
{
    NSString* filePath;
    if (zipFiles == nil){
        [self hideIndicatorAndButtons];
        return;
    }
    @autoreleasepool {
        while (1) {
            if (zipFiles.count == 0)
                break;
            if (needStopZip) {
                break;
            }
            filePath = [zipFiles objectAtIndex:0];
            
            NSString* projectFolder = @"";
            
            @try
            {
                ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
                
                [self performSelectorOnMainThread:@selector(log:) withObject:@"\nUnzip...\n" waitUntilDone:YES];
                
                NSArray *infos= [unzipFile listFileInZipInfos];
                NSString* fileWritePath;
                NSMutableData *buffer= [[NSMutableData alloc] initWithLength:10240];
                ZipReadStream *read;
                NSError* error;
                
                //Create Project Folder
                NSString* _tmp = [filePath lastPathComponent];
                _tmp = [_tmp stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                NSString* _tmp2 = [filePath stringByDeletingLastPathComponent];
                _tmp2 = [_tmp2 stringByAppendingPathComponent:_tmp];
                projectFolder = [_tmp2 stringByDeletingPathExtension];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:projectFolder])
                {
                    NSString* info = @"";
                    info = [info stringByAppendingFormat:@"%@ already exist, please change the zip file name", projectFolder];
                    [self performSelectorOnMainThread:@selector(log:) withObject:info waitUntilDone:YES];
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                    [zipFiles removeObjectAtIndex:0];
                    continue;
                }
                [[NSFileManager defaultManager] createDirectoryAtPath:projectFolder withIntermediateDirectories:YES attributes:nil error:&error];

                int count = 0;
#ifdef LITE_VERSION
                int liteLimitCount = 0;
#endif
//                NSString* skipPath = nil;
                NSNumber* number;
                number = [NSNumber numberWithFloat:0];
                [self performSelectorOnMainThread:@selector(setProgressViewValue:) withObject:number waitUntilDone:YES];
                for (FileInZipInfo *info in infos) {
                    if (needStopZip) {
                        break;
                    }
                    @autoreleasepool {
                    count++;
                    number = [NSNumber numberWithFloat:(float)((float)count/(float)[infos count])];
                    [self performSelectorOnMainThread:@selector(setProgressViewValue:) withObject: number waitUntilDone:YES];
                    if ([info.name rangeOfString:@"__MACOSX"].location != NSNotFound)
                        continue;
//                    if (skipPath == nil)
//                    {
//                        NSString* tmp = [info.name lastPathComponent];
//                        if ([[tmp substringToIndex:1] compare:@"."] == NSOrderedSame)
//                        {
//                            skipPath = [info.name copy];
//                            continue;
//                        }
//                    }
//                    else
//                    {
//                        NSRange range;
//                        range = [info.name rangeOfString:skipPath];
//                        if (range.location != NSNotFound && range.location == 0)
//                        {
//                            continue;
//                        }
//                        else
//                        {
//                            NSString* tmp = [info.name lastPathComponent];
//                            if ([[tmp substringToIndex:1] compare:@"."] == NSOrderedSame)
//                            {
//                                skipPath = [info.name copy];
//                                continue;
//                            }
//                            else
//                                skipPath = nil;
//                        }
//                    }
                    NSString* _nameWrapper = [info.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                    if ([_nameWrapper characterAtIndex:[_nameWrapper length]-1] == '/')
                    {
                        fileWritePath = [NSString stringWithFormat:@"%@/%@", projectFolder, _nameWrapper];
                        [[NSFileManager defaultManager] createDirectoryAtPath:fileWritePath withIntermediateDirectories:YES attributes:nil error:&error];
                        [self performSelectorOnMainThread:@selector(log:) withObject:[NSString stringWithFormat:@"Unzip: %@", _nameWrapper] waitUntilDone:YES];
                        continue;
                    }
#ifdef LITE_VERSION
                    liteLimitCount++;
                    if ([_nameWrapper rangeOfString:@"/.git/"].location != NSOrderedSame) {
                        liteLimitCount--;
                    }
                    if (liteLimitCount > LITE_LIMIT)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[Utils getInstance] showPurchaseAlert];
                            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Maximum number of source files exceeded for Lite Version."];
                        });
                        [zipFiles removeAllObjects];
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                        [self performSelectorOnMainThread:@selector(log:) withObject:@"\nMaximum number of source files exceeded for Lite Version.\n" waitUntilDone:YES];
                        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                        [self hideIndicatorAndButtons];
                        return;
                    }
#endif

                    // Upload all kinds of files
//                    if (![[Utils getInstance] isSupportedType:info.name])
//                         continue;
                    
                    fileWritePath = [NSString stringWithFormat:@"%@/%@", projectFolder, _nameWrapper];
                    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:fileWritePath];
                    if(file == nil) {
                        BOOL res = [[NSFileManager defaultManager] createFileAtPath:fileWritePath contents:nil attributes:nil];
                        if (res == NO)
                        {
                            NSString* folder = [fileWritePath stringByDeletingLastPathComponent];
                            [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
                            [[NSFileManager defaultManager] createFileAtPath:fileWritePath contents:nil attributes:nil];
                            [self performSelectorOnMainThread:@selector(log:) withObject:[NSString stringWithFormat:@"Unzip: %@", [_nameWrapper stringByDeletingLastPathComponent]] waitUntilDone:YES];
                        }
                        file = [NSFileHandle fileHandleForWritingAtPath:fileWritePath];
                        if (file == nil)
                        {
                            NSLog(@"error: %@", _nameWrapper);
                            continue;
                        }
                    }
                    [unzipFile locateFileInZip:info.name];
                    read= [unzipFile readCurrentFileInZip];
                    // Read-then-write buffered loop
                    do {
                        
                        // Reset buffer length
                        [buffer setLength:10240];
                        
                        // Expand next chunk of bytes
                        NSUInteger bytesRead= [read readDataWithBuffer:buffer];
                        if (bytesRead > 0) {
                            
                            // Write what we have read
                            [buffer setLength:bytesRead];
                            [file writeData:buffer];
                            
                        } else
                            break;
                        
                    } while (!needStopZip);
                    
                    // Clean up
                    [file closeFile];
                    [read finishedReading];     
                    }
                }
            } @catch (ZipException *ze) {
                [self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a ZipException (see logs), terminating..." waitUntilDone:YES];
                
                NSLog(@"ZipException caught: %ld - %@", ze.error, [ze reason]);
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.masterViewController reloadData];
                });
                [zipFiles removeObjectAtIndex:0];
                continue;
            } @catch (id e) {
                [self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a generic exception (see logs), terminating..." waitUntilDone:YES];
                
                NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.masterViewController reloadData];
                });
                [zipFiles removeObjectAtIndex:0];
                continue;
            }
            
            [zipFiles removeObjectAtIndex:0];
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            [self performSelectorOnMainThread:@selector(analyzeProject:) withObject:projectFolder waitUntilDone:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.masterViewController reloadData];
            });
            [self performSelectorOnMainThread:@selector(log:) withObject:@"\nFinish" waitUntilDone:YES];
        }
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self hideIndicatorAndButtons];
}

-(void) analyzeProject:(NSString *)path
{
    [[Utils getInstance] analyzeProject:path andForceCreate:YES];
    [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Upload Finished"];
}

#ifdef IPHONE_VERSION
- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
#endif

- (BOOL)shouldAutorotate
{
#ifdef IPHONE_VERSION
    return NO;
#else
    return YES;
#endif
}

- (NSUInteger)supportedInterfaceOrientations
{
#ifdef IPHONE_VERSION
    return UIInterfaceOrientationMaskPortrait;
#else
    return UIInterfaceOrientationMaskAll;
#endif
}

- (IBAction)onStopClicked:(id)sender {
    needStopZip = YES;
}

#pragma mark TableView

- (void) navigateToFileBrowser {
    if ([self.webServiceSwitcher isOn]) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please switch off 'Web Upload Service."];
        return;
    }
    
    if ([thread isExecuting]) {
        [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Zip on progress"];
        return;
    }

    if ([self.popOverController isPopoverVisible] == YES)
    {
        [self.popOverController dismissPopoverAnimated:YES];
        return;
    }
    FileBrowserViewController* fileBrowserViewController = [[FileBrowserViewController alloc] initWithNibName:@"FileBrowserViewController" bundle:nil];
    [fileBrowserViewController setFileBrowserViewDelegate:self];
    [fileBrowserViewController setIsProjectFolder:YES];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:fileBrowserViewController];
    
    NSString* fakeFile = [uploadToPath stringByAppendingPathComponent:@"zzzlgzzzz_fake.zzz"];
    [fileBrowserViewController setInitialPath:fakeFile];
    
#ifdef IPHONE_VERSION
    self.popOverController = [[FPPopoverController alloc] initWithContentViewController:controller];
    self.popOverController.border = NO;
    CGSize size = self.view.frame.size;
    size.width = size.width / 5 * 4;
    size.height = size.height /8 * 7;
    self.popOverController.arrowDirection = FPPopoverArrowDirectionAny;
    self.popOverController.popoverContentSize = size;
#else
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:controller];
#endif
    
    [self.popOverController presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
            break;
        case 0:
            [self navigateToFileBrowser];
            break;
            
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *switcherItemIdentifier = @"SwitcherWebServiceViewCell";
    static NSString *uploadToItemIdentifier = @"UploadToWebServiceViewCell";
    
    UITableViewCell *cell;
    UISwitch *switchview;
    NSString* path;
    switch (indexPath.section) {
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:switcherItemIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:switcherItemIdentifier];
            }
            cell.textLabel.text = @"Web Upload Service";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (webServiceSwitcher == nil) {
                switchview = [[UISwitch alloc] init];
                [self setWebServiceSwitcher:switchview];
                [webServiceSwitcher addTarget:self action:@selector(selectionChanged:) forControlEvents:UIControlEventValueChanged];
            }
            cell.accessoryView = webServiceSwitcher;
            [cell.contentView  addSubview :switchview];
            break;
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:uploadToItemIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:uploadToItemIdentifier];
            }
            path = [self getUploadToPathRelative];
            if (path == nil || [path length] == 0)
                cell.textLabel.text = @"Upload as a New Project";
            else
                cell.textLabel.text = [self getUploadToPathRelative];
            break;
        default:
            break;
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (section == 0) {
            return 95;
        } else {
            return 65; // header height
        }
    } else {
        if (section == 0) {
            return 170;
        } else {
            return 170; // header height
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *header = @"customHeader";
    
    UITableViewHeaderFooterView *vHeader;
    
    vHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    
    if (!vHeader) {
        vHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
        vHeader.textLabel.numberOfLines = 12;
    }
    
    switch (section) {
        case 0:
            vHeader.textLabel.text = @"Click below to select upload location:\n1) Upload as a new project, please choose project folder.\n2) Upload into an existing project, please choose the folder you want to upload to.";
            break;
        case 1:
            vHeader.textLabel.text = @"1) Click below to start 'Web Uplaod Service'\n2)You can now visit the url on your computer.\n3)You can now upload a single source file or a Zip file as a project.";
            break;
        default:
            vHeader.textLabel.text = @"";
        
    }
    return vHeader;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    return @"";
//}

- (void) updateInfoWhenPathChanged {
    NSString* relative = [self getUploadToPathRelative];
    if (relative == nil || [relative length] == 0) {
        [self.textView setText:@"Current upload as a Project"];
    } else {
        NSString* str = [NSString stringWithFormat:@"Current upload to:\n %@", relative];
        [self.textView setText:str];
    }
}

- (void)fileBrowserViewDisappeared {
    if ([self.webServiceSwitcher isOn] || [thread isExecuting]) {
        return;
    }
    UINavigationController* controller = (UINavigationController*)[popOverController contentViewController];
    FileBrowserViewController* curController = [[controller viewControllers] lastObject];
    
    
    [self setUploadToPath:[curController.fileListBrowserController currentLocation]];
    [_tableView reloadData];
    
    [self updateInfoWhenPathChanged];
}

- (void)folderSelected:(NSString*)path {
    if ([self.webServiceSwitcher isOn] || [thread isExecuting]) {
        return;
    }
    [self setUploadToPath:path];
    [_tableView reloadData];
    
    [self updateInfoWhenPathChanged];
}


@end
