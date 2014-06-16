//
//  HistoryController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "HistoryController.h"
#import "DetailViewController.h"

@implementation HistoryController

@synthesize historyStack;

+(void) writeToFile
{
    NSError *error;
    // Currently there are two history list controller, Up and down
    NSString* upFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/upHistory.setting"];
    NSString* downFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/downHistory.setting"];
    NSString* upFileIndexPath = [upFilePath stringByAppendingString:@"_index"];
    NSString* downFileIndexPath = [downFilePath stringByAppendingString:@"_index"];

    HistoryController* historyController;
    DetailViewController* detailViewController = [Utils getInstance].detailViewController;
    
    historyController = detailViewController.upHistoryController;
    [historyController.historyStack writeToFile:upFilePath atomically:YES];
    NSString* intVaule = [NSString stringWithFormat:@"%ld", (unsigned long)[historyController getCurrentDisplayIndex]];
    [intVaule writeToFile:upFileIndexPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    historyController = detailViewController.downHistoryController;
    [historyController.historyStack writeToFile:downFilePath atomically:YES];
    intVaule = [NSString stringWithFormat:@"%ld", (unsigned long)[historyController getCurrentDisplayIndex]];
    [intVaule writeToFile:downFileIndexPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

-(void) readFromFile:(NSString*) filePath
{
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist) {
        NSError* error;
        historyStack = [NSMutableArray arrayWithContentsOfFile:filePath];
        NSString* indexPath = [filePath stringByAppendingString:@"_index"];
        NSString* content = [NSString stringWithContentsOfFile:indexPath encoding:NSUTF8StringEncoding error:&error];
        [self setIndex:[content intValue]];
    }
}

-(void) pushUrl:(NSString *)url
{
    if (historyStack == nil)
    {
        index = 0;
        historyStack = [[NSMutableArray alloc] init];
        [historyStack addObject:url];
    }
    else
    {
        while (index < [historyStack count]-1) {
            [historyStack removeLastObject];
        }
        
        NSString* currentUrl = [historyStack lastObject];
        if ([currentUrl compare:[url stringByAppendingString:@"::0"]] == NSOrderedSame) {
            return;
        }

        [historyStack addObject:url];
        if ([historyStack count] > MAX_HISTORY_STACK)
        {
            [historyStack removeObjectAtIndex:0];
            index = [historyStack count]-1;
            return;
        }
        index++;
    }
}

-(void) updateCurrentScrollLocation:(int)location
{
    if (historyStack == nil)
        return;
    NSString* currentUrl = [historyStack objectAtIndex:index];
    NSRange range = [currentUrl rangeOfString:@"::" options:NSBackwardsSearch];
    if (range.location != NSNotFound)
    {
        currentUrl = [currentUrl substringToIndex:range.location];
    }
    currentUrl = [currentUrl stringByAppendingFormat:@"::%d",location];
    [historyStack removeObjectAtIndex:index];
    [historyStack insertObject:currentUrl atIndex:index];
}

-(NSString*) popUrl
{
    if (historyStack == nil)
        return nil;
    NSString* returnValue = nil;
    if (index > 0)
    {
        index--;
        returnValue = [historyStack objectAtIndex:index];
    }
    return returnValue;
}

-(NSString*) getNextUrl
{
    if (historyStack == nil)
        return nil;
    NSString* returnValue = nil;
    if (index < [historyStack count] -1)
        returnValue = [historyStack objectAtIndex:++index];
    return returnValue;
}

-(NSString*) pickTopLevelUrl
{
    return [historyStack objectAtIndex:index];
}

-(int) getLocationFromHistoryFormat:(NSString *)content
{
    NSRange locationRange = [content rangeOfString:@"::" options:NSBackwardsSearch];
    if (locationRange.location == NSNotFound)
        return -1;
    NSString* tmp = [content substringFromIndex:locationRange.location+locationRange.length];
    if (tmp == nil || [tmp length] == 0)
        return -1;
    return [tmp intValue];
}

-(NSString*) getUrlFromHistoryFormat:(NSString *)content
{
    NSRange locationRange = [content rangeOfString:@"::" options:NSBackwardsSearch];
    if (locationRange.location == NSNotFound)
        return content;
    return [content substringToIndex:locationRange.location];
}

-(NSUInteger) getCount
{
    if (historyStack == nil)
        return 0;
    return [historyStack count];
}

-(NSUInteger) getCurrentDisplayIndex
{
    return index;
}

-(NSString*) getPathByIndex:(NSInteger)i
{
    if (i < 0)
        return nil;
    if (historyStack == nil)
        return nil;
    if (i >= [historyStack count])
        return nil;
    return [historyStack objectAtIndex:i];
}

-(void) setIndex:(NSInteger)i
{
    if (i < 0)
        return;
    if (historyStack == nil)
        return;
    if (i >= [historyStack count])
        return;
    index = i;
}

@end
