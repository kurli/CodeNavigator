//
//  HistoryController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "HistoryController.h"

@implementation HistoryController

@synthesize historyStack;

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
        while (index != [historyStack count]-1) {
            [historyStack removeLastObject];
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

-(int) getCount
{
    if (historyStack == nil)
        return 0;
    return [historyStack count];
}

-(int) getCurrentDisplayIndex
{
    return index;
}

-(NSString*) getPathByIndex:(int)i
{
    if (i < 0)
        return nil;
    if (historyStack == nil)
        return nil;
    if (i >= [historyStack count])
        return nil;
    return [historyStack objectAtIndex:i];
}

-(void) setIndex:(int)i
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
