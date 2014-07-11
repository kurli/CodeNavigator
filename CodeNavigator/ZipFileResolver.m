//
//  ZipFileResolver.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/29/13.
//
//

#import "ZipFileResolver.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"

#import "Utils.h"
#import "MasterViewController.h"

@implementation ZipFileResolver

@synthesize worker;
@synthesize alertView;

-(void) dealloc
{
    [self setWorker:nil];
    [self setAlertView:nil];
}

-(void) dismissWaitingDialog
{
    [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Unzip Finished"];
}

-(void) unzipThread
{
    @autoreleasepool {

            NSString* projectFolder = @"";
            NSURL* url = [[NSURL alloc] initWithString:self.filePath];
            NSData* data = [[NSData alloc] initWithContentsOfURL:url];
            NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.Projects"];
            path = [path stringByAppendingPathComponent:[self.filePath lastPathComponent]];
            [data writeToFile:path atomically:YES];
            @try
            {
                ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:path mode:ZipFileModeUnzip];
                                
                NSArray *infos= [unzipFile listFileInZipInfos];
                NSString* fileWritePath;
                NSMutableData *buffer= [[NSMutableData alloc] initWithLength:10240];
                ZipReadStream *read;
                NSError* error;
                
                //Create Project Folder
                projectFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.Projects"];

                NSString* _tmp = [path lastPathComponent];
                _tmp = [_tmp stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                projectFolder = [projectFolder stringByAppendingPathComponent:_tmp];
                projectFolder = [projectFolder stringByDeletingPathExtension];
                
                int addTmpNum = 0;
                while([[NSFileManager defaultManager] fileExistsAtPath:projectFolder])
                {
                   // [self performSelectorOnMainThread:@selector(dismissWaitingDialog:) withObject:nil waitUntilDone:YES];
                    addTmpNum++;
                    projectFolder = [projectFolder stringByAppendingFormat:@"_%d", addTmpNum];
                }
                [[NSFileManager defaultManager] createDirectoryAtPath:projectFolder withIntermediateDirectories:YES attributes:nil error:&error];
                
#ifdef LITE_VERSION
                int liteLimitCount = 0;
#endif
                //                NSString* skipPath = nil;
                for (FileInZipInfo *info in infos) {
                    @autoreleasepool {
                        if ([info.name rangeOfString:@"__MACOSX"].location != NSNotFound)
                            continue;
                        NSString* _nameWrapper = [info.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                        if ([_nameWrapper characterAtIndex:[_nameWrapper length]-1] == '/')
                        {
                            fileWritePath = [NSString stringWithFormat:@"%@/%@", projectFolder, _nameWrapper];
                            [[NSFileManager defaultManager] createDirectoryAtPath:fileWritePath withIntermediateDirectories:YES attributes:nil error:&error];
                            continue;
                        }
#ifdef LITE_VERSION
                        liteLimitCount++;
                        if ([_nameWrapper rangeOfString:@"/.git/"].location != NSOrderedSame) {
                            liteLimitCount--;
                        }
                        if (liteLimitCount > 5)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[Utils getInstance] showPurchaseAlert];
                                [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Maximum number of source files exceeded for Lite Version."];
                            });
                            //TODO remove file
                            return;
                        }
#endif
                        
                        fileWritePath = [NSString stringWithFormat:@"%@/%@", projectFolder, _nameWrapper];
                        NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:fileWritePath];
                        if(file == nil) {
                            BOOL res = [[NSFileManager defaultManager] createFileAtPath:fileWritePath contents:nil attributes:nil];
                            if (res == NO)
                            {
                                NSString* folder = [fileWritePath stringByDeletingLastPathComponent];
                                [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
                                [[NSFileManager defaultManager] createFileAtPath:fileWritePath contents:nil attributes:nil];
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
                            NSInteger bytesRead= [read readDataWithBuffer:buffer];
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
                NSLog(@"ZipException caught: %ld - %@", (long)ze.error, [ze reason]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:MASTER_VIEW_RELOAD object:nil];
                });
            } @catch (id e) {
                NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:MASTER_VIEW_RELOAD object:nil];
                });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:MASTER_VIEW_RELOAD object:nil];
            });
        
            NSError* error;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"];
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];

            [self performSelectorOnMainThread:@selector(dismissWaitingDialog) withObject:nil waitUntilDone:YES];
    }
}

- (void) perform
{
    if ([worker isExecuting]) {
        NSLog(@"Zip file resolver working");
        return;
    }
    
    [self setWorker:nil];
    worker = [[NSThread alloc] initWithTarget:self selector:@selector(unzipThread) object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [worker start];
    
    //Show dialog in UI thread
    self.alertView = [[UIAlertView alloc]
                                  initWithTitle:@"CodeNavigator\nUnzip in progress"
                                  message:nil delegate:nil cancelButtonTitle:nil
                                  otherButtonTitles: nil];
    
    [self.alertView show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    indicator.center = CGPointMake(self.alertView.bounds.size.width / 2,
                                   self.alertView.bounds.size.height - 50);
    [indicator startAnimating];
    [self.alertView addSubview:indicator];
    
}

-(BOOL) isBusy
{
    if ([worker isExecuting]) {
        YES;
    }
    return NO;
}

@end
