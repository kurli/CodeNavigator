//
//  FunctionListManager.m
//  CodeNavigator
//
//  Created by Guozhen Li on 10/21/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "FunctionListManager.h"

#import "ctags.h"
#import "readtags.h"

@implementation FunctionItem

@synthesize type;
@synthesize name;
@synthesize line;

@end

@implementation FunctionListManager

@synthesize callback;
@synthesize ctagsThread;
@synthesize path;

/*
 BCD_TO_BIN	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	56;"	d	line:56	file:
 CMOS_READ	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	51;"	d	line:51	file:
 __LIBRARY__	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	1;"	d	line:1	file:
 argv	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	/^static char * argv[] = { "-",NULL };$/;"	v	line:117	file:
 envp	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	/^static char * envp[] = { "HOME=\/usr\/root", NULL };$/;"	v	line:118	file:
 init	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	/^void init(void)$/;"	f	line:120
 main	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	/^void main(void)		\/* This really IS void, no error here. *\/$/;"	f	line:79
 printbuf	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	/^static char printbuf[1024];$/;"	v	line:36	file:
 printf	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	/^static int printf(const char *fmt, ...)$/;"	f	line:106	file:
 time_init	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	/^static void time_init(void)$/;"	f	line:58	file:
 */

-(void) analyzeCtagFile:(GetFunctionListCallback)cb
{
    NSError* error;
    NSString* ctagFile = [[Utils getInstance] getTagFileBySourceFile:self.path];
    NSString* content = [NSString stringWithContentsOfFile:ctagFile encoding:NSUTF8StringEncoding error:&error];
    NSArray* array = [content componentsSeparatedByString:@"\n"];
    if ([array count] <= 6)
    {
        cb(nil);
        return;
    }
//    NSLog(content);
    NSMutableArray* ctagList = [[NSMutableArray alloc] init];
    for (int i = 6; i<[array count]; i++) {
        NSArray* detailArray = [[array objectAtIndex:i] componentsSeparatedByString:@"\t"];
        if ([detailArray count] <5) {
            continue;
        }
        
        FunctionItem* item = [[FunctionItem alloc] init];
        [item setType:[detailArray objectAtIndex:3]];
        NSString* name;
        if ([item.type compare:@"v"] == NSOrderedSame) {
            name = [detailArray objectAtIndex:2];
            name = [name substringFromIndex:2];
            name = [name substringToIndex:[name length]-4];
            [item setName:name];
        }
        else if([item.type compare:@"f"] == NSOrderedSame) {
            name = [detailArray objectAtIndex:2];
            name = [name substringFromIndex:2];
            name = [name substringToIndex:[name length]-4];
            [item setName:name];        }
        else {
            [item setName:[detailArray objectAtIndex:0]];
        }
        NSArray* lineArray = [[detailArray objectAtIndex:4] componentsSeparatedByString:@":"];
        if ([lineArray count] != 2) {
            continue;
        }
        [item setLine:[[lineArray objectAtIndex:1] intValue]];
        item.type = [item.type uppercaseString];
        [ctagList addObject:item];
    }
    cb(ctagList);
}

-(BOOL) checkWhetherCtagFileValid:(NSString*)ctagFile
{
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:ctagFile];
    if (isExist == NO) {
        return NO;
    }
    return YES;
}

-(void) ctagsThread:(id)data
{
    GetFunctionListCallback cb = (GetFunctionListCallback)data;
    
    NSString* ctagFile = [[Utils getInstance] getTagFileBySourceFile:self.path];
    BOOL isValid = [self checkWhetherCtagFileValid:ctagFile];
    if (isValid == YES) {
        [self analyzeCtagFile:cb];
        return;
    }

    const char *argv[4];
    argv[0] = "ctags";
    argv[1] = [self.path cStringUsingEncoding:NSUTF8StringEncoding];
    argv[2] = '\0';

    ctags_main(1, argv, [ctagFile cStringUsingEncoding:NSUTF8StringEncoding]);
    [self analyzeCtagFile:cb];
}

-(void) getFunctionListForFile:(NSString*)p andCallback:(GetFunctionListCallback)cb
{
    self.callback = cb;
    self.path = p;

    if (ctagsThread.isExecuting) {
//        [ctagsThread cancel];
        return;
    }
    ctagsThread = [[NSThread alloc] initWithTarget:self selector:@selector(ctagsThread:) object:callback];

    [ctagsThread start];
}

@end
