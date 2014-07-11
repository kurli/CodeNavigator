//
//  OtherFormatResolver.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/29/13.
//
//

#import "OtherFormatResolver.h"
#import "Utils.h"
#import "DetailViewController.h"

@implementation OtherFormatResolver

-(void)perform
{
    if ([self.filePath length] == 0) {
        return;
    }
    NSURL* url = [[NSURL alloc] initWithString:self.filePath];
    NSData* data = [[NSData alloc] initWithContentsOfURL:url];
    
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.Projects"];
    path = [path stringByAppendingPathComponent:@"MyProject"];
    
    NSError* error;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    
    path = [path stringByAppendingPathComponent:[self.filePath lastPathComponent]];
    
    [data writeToFile:path atomically:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MASTER_VIEW_RELOAD object:nil];
    
    [[Utils getInstance].detailViewController gotoFile:path andLine:0 andKeyword:@"--lgz--zz--unknown--"];
    
    path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

@end
