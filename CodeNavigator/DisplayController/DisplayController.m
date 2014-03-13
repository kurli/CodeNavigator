//
//  DisplayController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 2/26/14.
//
//

#import "DisplayController.h"
#import "Utils.h"
#import "Parser.h"
#import <CommonCrypto/CommonDigest.h>

@implementation DisplayController

-(NSString*) getSourceFileByDisplayFile:(NSString *)displayFile
{
    if (displayFile == nil || [displayFile length] == 0)
        return nil;
    NSString* tmp = [displayFile copy];
    NSRange locationRange = [tmp rangeOfString:@".display" options:NSBackwardsSearch];
    if ( locationRange.location != NSNotFound)
    {
        tmp = [tmp substringToIndex:locationRange.location];
        locationRange = [tmp rangeOfString:@"_" options:NSBackwardsSearch];
        if ( locationRange.location != NSNotFound )
        {
            NSString* name = [tmp substringToIndex:locationRange.location];
            if (locationRange.location+locationRange.length == [tmp length])
            {
                //No extension found
                tmp = name;
            }
            else
            {
                NSString* extension = [tmp substringFromIndex:locationRange.location+1];
                tmp = [NSString stringWithFormat:@"%@.%@", name,extension];
            }
            // Change the folder
            tmp = [tmp stringByReplacingOccurrencesOfString:DISPLAY_FOLDER_PATH withString:@"Projects"];
        }
    }
    return tmp;
}

-(NSString*) getDisplayFileBySourceFile:(NSString *)source
{
    if (source == nil || [source length] == 0)
        return nil;
    NSString* tmp = [source copy];
    NSString* extension = [source pathExtension];
    if (extension == nil || [extension length] == 0)
    {
        tmp = [tmp stringByAppendingFormat:@"_.%@", DISPLAY_FILE_EXTENTION];
    }
    else
    {
        tmp = [tmp stringByDeletingPathExtension];
        tmp = [tmp stringByAppendingFormat:@"_%@.%@", extension, DISPLAY_FILE_EXTENTION];
    }
    // Change the folder
    NSRange range = [tmp rangeOfString:@"Projects"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"Projects" withString:DISPLAY_FOLDER_PATH options:NSLiteralSearch range:range];
    return tmp;
}

-(void)deleteDisplayFileForSource:(NSString *)source
{
    NSError *error;
    NSString* displayFilePath = [self getDisplayFileBySourceFile:source];
    if (displayFilePath == nil || [displayFilePath length] == 0 )
        return;
    [[NSFileManager defaultManager] removeItemAtPath:displayFilePath error:&error];
}

-(NSString*) getDisplayPath:(NSString*) path
{
    NSString* displayPath;
    if ([[Utils getInstance] isDocType:path])
    {
        return path;
    }
    //    if ([self isWebType:path])
    //        return path;
    
    displayPath = [self getDisplayFileBySourceFile:path];
    return displayPath;
}

-(NSString*) getDisplayFile:(NSString*) path andProjectBase:(NSString*)projectPath
{
    NSString* displayPath;
    BOOL isFolder;
    NSString* html;
    NSError *error;
    //NSString* rc4Result;
    
    displayPath = [self getDisplayPath:path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:displayPath isDirectory:&isFolder])
    {
        @autoreleasepool {
            html = [self parseFile:path andProjectBase:projectPath];
        }
    }
    else
    {
        if ([[Utils getInstance] isDocType:path])
        {
            return nil;
        }
        //        if ([self isWebType:path])
        //            return nil;
        displayPath = [self getDisplayPath:path];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSString* content = [NSString stringWithContentsOfFile: displayPath usedEncoding:&encoding error: &error];
        NSString* fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        NSString* source_md5 = [self getMd5_32Bit_String:fileContent];
        NSString* pre_md5 = [content substringToIndex:[source_md5 length]];
        if ([source_md5 compare:pre_md5] == NSOrderedSame) {
            html = [content substringFromIndex:[source_md5 length]];
        } else {
            html = [self parseFile:path andProjectBase:projectPath];
        }
    }
    return html;
}

-(NSString*) parseFile:(NSString*) path andProjectBase:(NSString*)projectPath {
    NSString* html;
    NSError *error;
    NSString* displayPath = [self getDisplayPath:path];

    Parser* parser = [[Parser alloc] init];
    if ([[Utils getInstance] isImageType:path] == YES)
        [parser setParserType:IMAGE];
    else
        [parser checkParseType:path];
    [parser setFile: path andProjectBase:projectPath];
    int maxLineCount = [[Utils getInstance].colorScheme.max_line_count intValue];
    if (maxLineCount > 0) {
        [parser setMaxLineCount:maxLineCount];
    }
    [parser startParse];
    html = [parser getHtml];
    NSString* fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSString* outputStr = [self getMd5_32Bit_String:fileContent];
    outputStr = [outputStr stringByAppendingString:html];
    //rc4Result = [self HloveyRC4:html key:@"lgz"];
    [outputStr writeToFile:displayPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSString* folder = [displayPath stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:Nil error:&error];
        [outputStr writeToFile:displayPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    return html;
}

- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}

-(void) removeDisplayFilesForProject:(NSString *)proj {
    NSString* path = proj;
    NSRange range = [path rangeOfString:@"Projects"];
    path = [path stringByReplacingOccurrencesOfString:@"Projects" withString:DISPLAY_FOLDER_PATH options:NSLiteralSearch range:range];
    BOOL isFolder = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

@end
