//
//  CommentWrapper.m
//  CodeNavigator
//
//  Created by Guozhen Li on 5/9/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "CommentWrapper.h"
#import "Utils.h"

#define COMMENT_SEPRATER @"----lgz----comment----\n"
#define COMMENT_LINE_SEP @"----lgz--line----\n"

@implementation CommentItem

@synthesize line;
@synthesize comment;

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
        NSArray* array = [totalComment componentsSeparatedByString:COMMENT_SEPRATER];
        for (int i=0; i<[array count]; i++) {
            NSArray* array2 = [[array objectAtIndex:i] componentsSeparatedByString:COMMENT_LINE_SEP];
            if ([array2 count] == 2) {
                CommentItem *item = [[CommentItem alloc] init];
                [item setLine:[[array2 objectAtIndex:0] intValue]];
                [item setComment:[array2 objectAtIndex:1]];
                [commentArray addObject:item];
            }
        }
    }
}

-(void)addComment:(int)line andComment:(NSString *)comment
{
    CommentItem* newItem = [[CommentItem alloc] init];
    newItem.line = line;
    newItem.comment = comment;
    
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
    
    NSMutableString* str = [[NSMutableString alloc] init];
    for (int i=0; i<[commentArray count]; i++) {
        CommentItem* item = [commentArray objectAtIndex:i];
        if ([item.comment length] == 0) {
            continue;
        }
        [str appendFormat:@"%d\n%@%@%@", item.line, COMMENT_LINE_SEP, item.comment, COMMENT_SEPRATER];
    }
    
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
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
