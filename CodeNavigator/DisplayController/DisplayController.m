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
    return tmp;
}

-(void)deleteDisplayFileForSource:(NSString *)source
{
    NSError *error;
    NSString* displayFilePath = [[Utils getInstance] getDisplayFileBySourceFile:source];
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
    
    displayPath = [path stringByDeletingPathExtension];
    displayPath = [displayPath stringByAppendingFormat:@"_%@",[path pathExtension]];
    displayPath = [displayPath stringByAppendingPathExtension:DISPLAY_FILE_EXTENTION];
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
            //rc4Result = [self HloveyRC4:html key:@"lgz"];
            [html writeToFile:displayPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
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
        NSStringEncoding encoding = NSUTF8StringEncoding;
        html = [NSString stringWithContentsOfFile: displayPath usedEncoding:&encoding error: &error];
        //html = [self HloveyRC4:rc4Result key:@"lgz"];
    }
    return html;
}

@end
