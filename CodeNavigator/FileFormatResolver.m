//
//  FileFormatResolver.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/29/13.
//
//

#import "FileFormatResolver.h"

@implementation FileFormatResolver

@synthesize filePath;

-(void) dealloc
{
    [self setFilePath:nil];
}

-(void) perform
{
}

-(void)downloadToPath:(NSString *)path
{
}

-(BOOL) isBusy
{
    return NO;
}

@end
