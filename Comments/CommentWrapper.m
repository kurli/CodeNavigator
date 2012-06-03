//
//  CommentWrapper.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/9/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "CommentWrapper.h"
#import "Utils.h"
#import "SBJson.h"

#define COMMENT_USER_NAME @"username"
#define COMMENT_TIME @"time"
#define COMMENT_LINE @"line"
#define COMMENT_COMMENT @"comment"

@implementation CommentItem

@synthesize line;
@synthesize comment;
@synthesize userName;
@synthesize time;

@end

@implementation CommentWrapper

@synthesize commentArray;
@synthesize filePath;

- (void)dealloc
{
    [self.commentArray removeAllObjects];
    [self setCommentArray:nil];
    [self setFilePath:nil];
}

-(void) readFromFile:(NSString *)path
{
    BOOL isFolder;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder];
    
    [commentArray removeAllObjects];
    commentArray = [[NSMutableArray alloc] init];
    self.filePath = path;
    
    NSString* totalComment;
    NSError* error;
    if (isExist) {
        totalComment = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        SBJsonParser* parser = [[SBJsonParser alloc] init];
        NSArray* commentList = [parser objectWithString:totalComment];
        for (int i=0; i<[commentList count]; i++) {
            NSDictionary* dictionary = [commentList objectAtIndex:i];
            if ([dictionary count] == 0) {
                return;
            }
            CommentItem* item = [[CommentItem alloc] init];
            NSString* tmp = [dictionary objectForKey:COMMENT_USER_NAME];
            if (tmp == nil) {
                continue;
            }
            [item setUserName:tmp];
            tmp = [dictionary objectForKey:COMMENT_TIME];
            if (tmp == nil) {
                continue;
            }
            [item setTime:[tmp intValue]];
            tmp = [dictionary objectForKey:COMMENT_COMMENT];
            if (tmp == nil) {
                continue;
            }
            [item setComment:tmp];
            tmp = [dictionary objectForKey:COMMENT_LINE];
            if (tmp == nil) {
                continue;
            }
            [item setLine:[tmp intValue]];
            
            [commentArray addObject:item];
        }
    }
}

-(void)addComment:(int)line andComment:(NSString *)comment
{
    CommentItem* newItem = [[CommentItem alloc] init];
    newItem.line = line;
    newItem.comment = comment;
    newItem.userName = @"";
    newItem.time = 0;
    
    if ([commentArray count] == 0) {
        [commentArray addObject:newItem];
        return;
    }
    
    int insertBeforeIndex = 0;
    int i=0;
    for (i=0; i<[commentArray count]; i++) {
        CommentItem* item = [commentArray objectAtIndex:i];
        if (item.line == line) {
            item.comment = comment;
            insertBeforeIndex = -1;
            if ([comment length] == 0) {
                [commentArray removeObjectAtIndex:i];
                return;
            }
            break;
        }
        else if (item.line > line) {
            insertBeforeIndex = i;
            break;
        }
        insertBeforeIndex = i;
    }
    if (i == [commentArray count]) {
        [commentArray addObject:newItem];
        return;
    }
    if (insertBeforeIndex != -1) {
        [commentArray insertObject:newItem atIndex:insertBeforeIndex];
    }
}

-(void)saveToFile
{
    NSError* error;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
    NSString* projCommentPath = [[Utils getInstance] getProjectFolder:filePath];
    projCommentPath = [projCommentPath stringByAppendingPathComponent:@"lgz_projects.lgz_comment"];
    NSString* projCommentContent = [NSString stringWithContentsOfFile:projCommentPath encoding:NSUTF8StringEncoding error:&error];
    if (projCommentContent == nil) {
        projCommentContent = @"";
    }
    NSArray* array = [projCommentContent componentsSeparatedByString:@"\n"];
    int foundIndex = -1;
    NSString* needStorePath = [[Utils getInstance] getPathFromProject:filePath];
    for (int i = 0; i<[array count]; i++) {
        if ([needStorePath compare:[array objectAtIndex:i]] == NSOrderedSame) {
            foundIndex = i;
            break;
        }
    }
    // need delete current filePath, but it's in the proj file
    if ([commentArray count] == 0 && foundIndex != -1) {
        NSMutableString* tmp = [[NSMutableString alloc] init];
        for (int i=0; i<[array count]; i++) {
            if (i == foundIndex) {
                continue;
            }
            [tmp appendFormat:@"%@\n", [array objectAtIndex:i]];
        }
        [[NSFileManager defaultManager] removeItemAtPath:projCommentPath error:&error];
        [tmp writeToFile:projCommentPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    // need add current filePath, but it's not in the proj file
    else if (foundIndex == -1 && [commentArray count] > 0) {
        projCommentContent = [projCommentContent stringByAppendingFormat:@"%@\n", needStorePath];
        [[NSFileManager defaultManager] removeItemAtPath:projCommentPath error:&error];
        [projCommentContent writeToFile:projCommentPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    
    if ([commentArray count] == 0) {
        return;
    }
    
    NSMutableArray* mutableArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[commentArray count]; i++) {
        CommentItem* item = [commentArray objectAtIndex:i];
        if ([item.comment length] == 0) {
            continue;
        }
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:item.userName forKey:COMMENT_USER_NAME];
        [dictionary setObject:[NSString stringWithFormat:@"%d", item.time] forKey:COMMENT_TIME];
        [dictionary setObject:item.comment forKey:COMMENT_COMMENT];
        [dictionary setObject:[NSString stringWithFormat:@"%d", item.line] forKey:COMMENT_LINE];
        [mutableArray addObject:dictionary];
    }
    NSString* str = [mutableArray JSONRepresentation];
    
    if ([str length] > 0) {
        [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}

-(NSString*) getCommentByLine:(int)line
{
    for (int i=0; i<[commentArray count]; i++) {
        CommentItem* item = [commentArray objectAtIndex:i];
        if (item.line == line) {
            return item.comment;
        }
        else if (item.line > line) {
            return nil;
        }
    }
    return nil;
}

@end
