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
 printbuf	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	/^static char printbuf[1024];$/;"	v	line:36	file:
 printf	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	/^static int printf(const char *fmt, ...)$/;"	f	line:106	file:
 time_init	/Users/lgz_software/Library/Application Support/iPhone Simulator/5.1/Applications/4346DB17-91B5-4775-8A5C-D3C6AA0AE2E4/Documents/Projects/linux_0.1/init/main.c	/^static void time_init(void)$/;"	f	line:58	file:
 */

-(void) analyzeCtagFile:(GetFunctionListCallback)cb
{
    int srcEndIndex = 0;
    NSError* error;
    NSString* ctagFile = [[Utils getInstance] getTagFileBySourceFile:self.path];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString* content = [NSString stringWithContentsOfFile:ctagFile usedEncoding:&encoding error:&error];
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
        
        // Find src end index
        for (srcEndIndex = 2; srcEndIndex<[detailArray count]; srcEndIndex++) {
            NSString* testString = [detailArray objectAtIndex:srcEndIndex];
            if ([testString rangeOfString:@";\"" options:NSBackwardsSearch].location == [testString length]-2) {
                break;
            }
        }
        
        FunctionItem* item = [[FunctionItem alloc] init];
        [item setType:[detailArray objectAtIndex:srcEndIndex+1]];
        [item setKeyword:[detailArray objectAtIndex:0]];
        NSString* name;
        if ([item.type compare:@"v"] == NSOrderedSame || [item.type compare:@"f"] == NSOrderedSame) {
            name = [detailArray objectAtIndex:2];
            if ([name length] <= 7) {
                [item setName:[detailArray objectAtIndex:0]];
            }
            else {
                for (int k=2; k<srcEndIndex; k++) {
                    name = [name stringByAppendingString:[detailArray objectAtIndex:k]];
                }
                name = [name substringFromIndex:2];
                name = [name substringToIndex:[name length]-4];
                NSRange range = [name rangeOfString:[detailArray objectAtIndex:0]];
                if (range.location != NSNotFound) {
                    [item setName:[name substringFromIndex:range.location]];
                }
            }
        }
        else {
            [item setName:[detailArray objectAtIndex:0]];
        }
        //Tream leading
//        int k = 0;
//        for (; k<item.name.length; k++) {
//            if ([item.name characterAtIndex:k] != ' ' &&
//                [item.name characterAtIndex:k] != '\t') {
//                break;
//            }
//        }
//        if (k != 0) {
//            item.name = [item.name substringFromIndex:k];
//        }
        
        NSArray* lineArray = [[detailArray objectAtIndex:srcEndIndex+2] componentsSeparatedByString:@":"];
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

int ctags_main (int argc, char **argv, const char* fn);

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

    ctags_main(1, (char**)argv, [ctagFile cStringUsingEncoding:NSUTF8StringEncoding]);
    [self analyzeCtagFile:cb];
}

-(void) getFunctionListForFile:(NSString*)p andCallback:(GetFunctionListCallback)cb
{
    self.callback = cb;
    self.path = p;

    while (ctagsThread.isExecuting) {
        sleep(1);
    }
    ctagsThread = [[NSThread alloc] initWithTarget:self selector:@selector(ctagsThread:) object:callback];

    [ctagsThread start];
}

@end
