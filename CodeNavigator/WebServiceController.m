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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [self setTextView:nil];
    [self setWebServiceSwitcher:nil];
    [self setProgressView:nil];
//    [self.zipFiles removeAllObjects];
//    [self setZipFiles:nil];
    [self setMasterViewController:nil];
//    [self setUploadToPath:nil];
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.webServiceSwitcher isOn])
    {
        NSArray* components = [masterViewController.currentLocation pathComponents];
        NSString* path = @"";
        int index = 0;
        for (; index < [components count]; index++)
        {
            if ([((NSString*)[components objectAtIndex:index]) compare:@"Projects"] == NSOrderedSame )
            {
                break;
            }
        }
        if (index == [components count] -1)
        {
            [self.textView setText:@"Current upload as Project\n\nPlease turn on \"Web Upload Service\" to upload Projects"];
            return;
        }
        else
        {
            path = [components objectAtIndex:++index];
            for (index = index + 1; index<[components count]; index++)
            {
                path = [path stringByAppendingFormat:@"/%@",[components objectAtIndex:index]];
            }
        }
        NSString* info = @"";
        
        info = [info stringByAppendingFormat:@"Current upload to location:  %@\n\nPlease turn on \"Web Upload Service\" to upload files", path];
        
        [self.textView setText:info];
    }
}

- (IBAction)selectionChanged:(id)sender {
    NSError* error;
	
    if ([sender isOn]){
        NSString *root = masterViewController.currentLocation;
        self.uploadToPath = [masterViewController.currentLocation stringByAppendingString:@""];
        if (_httpServer == nil)
        {
            _httpServer = [[HTTPServer alloc] init];
            [_httpServer setType:@"_http._tcp."];
            [_httpServer setConnectionClass:[MyHTTPConnection class]];
            [_httpServer setWebUploadResultDelegate:self];
        
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInfoUpdate:) name:@"LocalhostAdressesResolved" object:nil];
        }
        
        [_httpServer setDocumentRoot:[NSURL fileURLWithPath:root]];
        [_httpServer start:&error];
        [textView setText:@"Please Wait..."];
        [localhostAddresses performSelectorInBackground:@selector(list) withObject:nil];
        [[[Utils getInstance] getBannerViewController] showBannerView];
    } else {
        [_httpServer stop];
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
            if ([((NSString*)[components objectAtIndex:index]) compare:@"Projects"] == NSOrderedSame )
            {
                break;
            }
        }
        if (index == [components count] -1)
        {
            path = @"  Project\n\n Please ZIP your project and upload it.";
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
        [textView  setText:info];
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
        if ([((NSString*)[components objectAtIndex:index]) compare:@"Projects"] == NSOrderedSame )
        {
            break;
        }
    }
    if (index == [components count] -1)
    {
        NSString* extention = [file pathExtension];
        if (extention == nil || [extention compare:@"zip"] != NSOrderedSame)
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

    //if a project file uploaded (zip extention)
    NSString* extention = [file pathExtension];
    if (extention != nil && [extention compare:@"zip"] == NSOrderedSame)
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
            [self setThread:nil];
            thread = [[NSThread alloc] initWithTarget:self selector:@selector(unzipThread) object:nil];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [thread start];
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

-(void) unzipThread
{
    NSString* filePath;
    if (zipFiles == nil)
        return;
    @autoreleasepool {
        while (1) {
            if (zipFiles.count == 0)
                break;
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
                
                projectFolder = [filePath stringByDeletingPathExtension];
                
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
                int liteLimitCount = 0;
//                NSString* skipPath = nil;
                NSNumber* number;
                number = [NSNumber numberWithFloat:0];
                [self performSelectorOnMainThread:@selector(setProgressViewValue:) withObject:number waitUntilDone:YES];
                for (FileInZipInfo *info in infos) {
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
                    if ([info.name characterAtIndex:[info.name length]-1] == '/')
                    {
                        fileWritePath = [NSString stringWithFormat:@"%@/%@", projectFolder, info.name];
                        [[NSFileManager defaultManager] createDirectoryAtPath:fileWritePath withIntermediateDirectories:YES attributes:nil error:&error];
                        [self performSelectorOnMainThread:@selector(log:) withObject:[NSString stringWithFormat:@"Unzip: %@", info.name] waitUntilDone:YES];
                        continue;
                    }
#ifdef LITE_VERSION
                    liteLimitCount++;
                    if ([info.name rangeOfString:@"/.git/"].location != NSOrderedSame) {
                        liteLimitCount--;
                    }
                    if (liteLimitCount > 5)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[Utils getInstance] showPurchaseAlert];
                            [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Maximum number of source files exceeded for Lite Version."];
                        });
                        [zipFiles removeAllObjects];
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                        [self performSelectorOnMainThread:@selector(log:) withObject:@"\nMaximum number of source files exceeded for Lite Version.\n" waitUntilDone:YES];
                        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                        return;
                    }
#endif

                    // Upload all kinds of files
//                    if (![[Utils getInstance] isSupportedType:info.name])
//                         continue;
                    
                    fileWritePath = [NSString stringWithFormat:@"%@/%@", projectFolder, info.name];
                    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:fileWritePath];
                    if(file == nil) {
                        BOOL res = [[NSFileManager defaultManager] createFileAtPath:fileWritePath contents:nil attributes:nil];
                        if (res == NO)
                        {
                            NSString* folder = [fileWritePath stringByDeletingLastPathComponent];
                            [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
                            [[NSFileManager defaultManager] createFileAtPath:fileWritePath contents:nil attributes:nil];
                            [self performSelectorOnMainThread:@selector(log:) withObject:[NSString stringWithFormat:@"Unzip: %@", [info.name stringByDeletingLastPathComponent]] waitUntilDone:YES];
                        }
                        file = [NSFileHandle fileHandleForWritingAtPath:fileWritePath];
                        if (file == nil)
                        {
                            NSLog(@"error: %@", info.name);
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
                        int bytesRead= [read readDataWithBuffer:buffer];
                        if (bytesRead > 0) {
                            
                            // Write what we have read
                            [buffer setLength:bytesRead];
                            [file writeData:buffer];
                            
                        } else
                            break;
                        
                    } while (YES);
                    
                    // Clean up
                    [file closeFile];
                    [read finishedReading];     
                    }
                }
            } @catch (ZipException *ze) {
                [self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a ZipException (see logs), terminating..." waitUntilDone:YES];
                
                NSLog(@"ZipException caught: %d - %@", ze.error, [ze reason]);
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

@end
