//
//  HandleURLController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/29/13.
//
//

#import "HandleURLController.h"
#import "ZipFileResolver.h"
#import "OtherFormatResolver.h"

@implementation HandleURLController

@synthesize fileFormatResolver;
@synthesize filePath;

- (void) dealloc
{
    [self setFileFormatResolver:nil];
    [self setFilePath:nil];
}

- (BOOL) checkWhetherSupported:(NSURL *)url
{
    NSString* urlStr = [url absoluteString];
    NSString* extension = [urlStr pathExtension];
    if ([extension compare:@"zip"] == NSOrderedSame) {
        fileFormatResolver = [[ZipFileResolver alloc] init];
        return YES;
    }
    else {
        fileFormatResolver = [[OtherFormatResolver alloc]init];
        return YES;
    }
    return NO;
}

- (BOOL) isBusy
{
    return [self.fileFormatResolver isBusy];
}

- (BOOL) handleFile:(NSString *)path
{
    if (fileFormatResolver == nil) {
        NSLog(@"HandleURLController error: resolver nil");
        return NO;
    }
    [fileFormatResolver setFilePath:filePath];
    [fileFormatResolver perform];
    return YES;
}

@end
