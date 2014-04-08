//
//  HtmlParser.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/17/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "HtmlParser.h"
#import "HTMLDefination.h"
#import "Parser.h"
#import "Utils.h"

@implementation HtmlParser
@synthesize lastTagName;
@synthesize jsParser;
@synthesize cssParser;

-(NSString*) getExtentionsStr
{
    return @"html htm";
}

-(NSString*) getSingleLineCommentsStr
{
    return @"NONE";
}

-(NSString*) getMultiLineCommentsStartStr
{
    return COMMENTS_MULTI;
}

-(NSString*) getMultiLineCommentsEndStr
{
    return COMMENTS_MULTI_END;
}

-(NSString*) getKeywordsStr
{
    return @"";
}

-(id) init
{
	if ( (self = [super init])!=nil )
	{
		isCommentsNotEnded = NO;
        isStringNotEnded = NO;
        isInTag = NO;
        isTagNameFound = NO;
        lastTagName = @"";
        isCodeInTagParseEnded = YES;
        
//        NSString* keywords = KEYWORD_PYTHON;
//        keywordsArray = [keywords componentsSeparatedByString:@" "];      
//        preprocessorArray = [NSArray arrayWithObjects: PREPROCESSOR];
	}
	return self;
}

-(BOOL) checkTag: (int)lineNumber
{
    unichar temp = [needParseLine characterAtIndex:0];
    if (temp == '<') {
        // TODO: This is just for standard parse
        // <script>  will be parsed correct
        // <
        //   script> will not be parsed correct
        NSRange range = [needParseLine rangeOfString:@">"];
        if (range.location != NSNotFound) {
            isInTag = YES;
            isTagNameFound = NO;
            return YES;
        } else {
            //TODO
        }
    }
    return NO;
}

-(BOOL) checkIsNameValidChar: (unichar) character
{
	if ( (int)character >='a' && (int)character <='z' )
		return YES;
	else if ( (int)character == '_' )
		return YES;
    else if ( (int)character == '-' )
		return YES;
	else if( (int)character >= '0' && (int)character <='9' )
		return YES;
	else if ( (int)character >='A' && (int)character <='Z' )
		return YES;
	return NO;
}

-(void) parseLine: (NSString*) line lineNum:(int)lineNumber
{
	// if a blank line
	if ( [line length] == 0 )
    {
		[self addBlankLine];
		return;
    }
	
	needParseLine = [line mutableCopy];
	unichar charTemp;
	NSRange range;
	while( [needParseLine length] > 0 )
	{
		charTemp = [needParseLine characterAtIndex:0];
		if ( charTemp == ' ' )
		{
			[self addString: @" " addEnter:NO];
			range.location = 0;
			range.length = 1;
			[needParseLine deleteCharactersInRange:range];
		}
		else if( charTemp == '\t' )
		{
            [self addString: @"    " addEnter:NO];
			range.location = 0;
			range.length = 1;
			[needParseLine deleteCharactersInRange:range];
		}
		else {
            // If not in tag, check tag, and skip all tag content
            if (isInTag == NO) {
                // check comments
                if ( [self checkCommentsLine] == YES )
                {
                    continue;
                }
                else
                {
                    if ( [needParseLine length] == 0 )
                        break;
                }
                
                isInTag = [self checkTag:lineNumber];
                if (isInTag == NO || !isCodeInTagParseEnded) {
                    if (!isCodeInTagParseEnded) {
                        // The first char must be '<'
                        isInTag = NO;
                        [self addString:@"<" addEnter:NO];
                        [needParseLine deleteCharactersInRange:NSMakeRange(0, 1)];
                    }
                    NSRange range = [needParseLine rangeOfString:@"<"];
                    if (range.location != NSNotFound) {
                        NSString* subString = [needParseLine substringToIndex:range.location];
                        // Special case, '<' is not a tag start signal
                        if ([subString length] == 0) {
                            [self addString:@"<" addEnter:NO];
                            [needParseLine deleteCharactersInRange:NSMakeRange(0, 1)];
                            continue;
                        }

                        // Check whether style or script
                        if ([lastTagName isEqualToString:@"script"] ||
                            [lastTagName isEqualToString:@"style"]) {
                            [self parseCode:subString andLineNumber:lineNumber];
                        } else {
                            [self addString:subString addEnter:NO];
                        }

                        NSRange range2;
                        range2.location = 0;
                        range2.length = [subString length];
                        [needParseLine deleteCharactersInRange:range2];
                        continue;
                    }
                    else {
                        // Between tags: html content, should be script or style, or string
                        // Check whether style or script
                        if ([lastTagName isEqualToString:@"script"] ||
                            [lastTagName isEqualToString:@"style"]) {
                            [self parseCode:needParseLine andLineNumber:lineNumber];
                        } else {
                            [self addString:needParseLine addEnter:NO];
                        }

                        [needParseLine setString:@""];
                        break;
                    }
                }
                else {
                    [self systemStart];
                    [self addString:@"<" addEnter:NO];
                    [needParseLine deleteCharactersInRange:NSMakeRange(0, 1)];
                    continue;
                }
            }
            else
            {
                // we are in tag
                if (isTagNameFound == NO) {
                    int index = 0;
                    for (index = 0; index < [needParseLine length]; index++) {
                        unichar charTemp = [needParseLine characterAtIndex:index];
                        if ([self checkIsNameValidChar:charTemp] == YES) {
                            continue;
                        }
                        if (charTemp == '!' || charTemp == '/') {
                            continue;
                        }
                        break;
                    }
                    
                    NSString* subString = [needParseLine substringToIndex:index];
                    [self addString:subString addEnter:NO];
                    self.lastTagName = [subString lowercaseString];
                    self.jsParser = nil;
                    self.cssParser = nil;
                    [needParseLine deleteCharactersInRange:NSMakeRange(0, [subString length])];
                    [self addEnd];
                    isTagNameFound = YES;
                    continue;
                }
                
                // check string
                if ( [self checkString] == YES )
                    continue;
                else
                {
                    if ( [needParseLine length] == 0 )
                        break;
                }
                // check char
                if ( [self checkChar] == YES )
                    continue;
                else
                {
                    if ( [needParseLine length] == 0 )
                        break;
                }
                
                unichar charTemp = [needParseLine characterAtIndex:0];
                if (charTemp == '>') {
                    [self systemStart];
                    [self addString:@">" addEnter:NO];
                    [needParseLine deleteCharactersInRange:NSMakeRange(0, 1)];
                    [self addEnd];
                    isInTag = NO;
                    continue;
                } else {
                    if (charTemp == '/') {
                        if ([needParseLine length] >= 2) {
                            charTemp = [needParseLine characterAtIndex:1];
                            if (charTemp == '>') {
                                [self systemStart];
                                [self addString:@"/>" addEnter:NO];
                                [needParseLine deleteCharactersInRange:NSMakeRange(0, 2)];
                                [self addEnd];
                                isInTag = NO;
                                continue;
                            }
                        }
                    }
                }
                
                int index = 0;
                for (index = 0; index < [needParseLine length]; index++) {
                    unichar charTemp = [needParseLine characterAtIndex:index];
                    if ([self checkIsNameValidChar:charTemp] == YES) {
                        continue;
                    }
                    break;
                }
                if (index > 0) {
                    NSString* subString = [needParseLine substringToIndex:index];
                    [self headerStart];
                    [self addString:subString addEnter:NO];
                    [self addEnd];
                    [needParseLine deleteCharactersInRange:NSMakeRange(0, [subString length])];
                    continue;
                }
                NSString* subStr = [needParseLine substringToIndex:1];
                [self addString:subStr addEnter:NO];
                [needParseLine deleteCharactersInRange:NSMakeRange(0, 1)];
            }
		}
	}	
}

-(void) parseCode: (NSString*) parseSource andLineNumber:(int)lineNumber
{
    // For javascript
    if ([lastTagName isEqualToString:@"script"]) {
        if (jsParser == nil) {
            jsParser = [[JavaScriptParser alloc] init];
        }
        [jsParser setContent:parseSource andProjectBase:nil];
        [jsParser setWithHeaderAndEnder:NO];
        [jsParser setMaxLineCount:[[Utils getInstance].currentThemeSetting.max_line_count intValue]];
        [jsParser startParse];
        NSString* _htmlContent = [jsParser getHtml];
        [self addRawHtml:_htmlContent];
        isCodeInTagParseEnded = [jsParser isStringOrCommentsEnded];
    } else {
        if (cssParser == nil) {
            cssParser = [[CSSParser alloc] init];
        }
        [cssParser setContent:parseSource andProjectBase:nil];
        [cssParser setWithHeaderAndEnder:NO];
        [cssParser setMaxLineCount:[[Utils getInstance].currentThemeSetting.max_line_count intValue]];
        [cssParser startParse];
        NSString* _htmlContent = [cssParser getHtml];
        [self addRawHtml:_htmlContent];
        isCodeInTagParseEnded = [cssParser isStringOrCommentsEnded];    }
}

// return YES, if we need to restart parse
// return NO, we do not need to reparse, or no comment found
-(BOOL) checkCommentsLine
{
    // If we r in string, we dont need to parse comment
    if ( isStringNotEnded == YES )
		return NO;
	if ( YES == isCommentsNotEnded )
    {		
		// comments not ended we nned to find COMMENTS_MULTI_END
		// In this case we assume that we have met /* before
		NSRange commentEndRange = [needParseLine rangeOfString: COMMENTS_MULTI_END];
		// check whether */ exsist
		if ( commentEndRange.location != NSNotFound )
		{
            NSString* commentsRange = [needParseLine substringToIndex: commentEndRange.location + commentEndRange.length];
            [self commentStart];
			[self addString: commentsRange addEnter:NO];
			[self addEnd];
			isCommentsNotEnded = NO;
			NSRange range = {0, commentEndRange.location + commentEndRange.length};
			[needParseLine deleteCharactersInRange: range];
			[self bracesEnded:currentParseLine andToken:@"%l2"];
			return YES;
            return YES;
		}
		else 
		{
			// */ not exsist we also in comments line here
            [self commentStart];
            [self addString: needParseLine addEnter:NO];
            [self addEnd];
            [needParseLine setString:@""];
			return NO;
		}
    }
	else
    {
		// We need to check whether comments in the beginning
		// check //
		NSRange commentSingleRange;
        commentSingleRange.location = NSNotFound;//hack
		NSRange commentMultiStartRange = [needParseLine rangeOfString: COMMENTS_MULTI];
        NSRange commentEndRange = [needParseLine rangeOfString: COMMENTS_MULTI_END];
        //Python special
        if (commentMultiStartRange.location != NSNotFound) {
            NSRange range;
            range.location = commentMultiStartRange.location + commentMultiStartRange.length;
            range.length = [needParseLine length]-range.location;
            commentEndRange = [needParseLine rangeOfString:COMMENTS_MULTI_END options:NSLiteralSearch range:range];
        }
		if ( commentSingleRange.location == 0 )
        {
			// it's comment line
			[self commentStart];
			[self addString: needParseLine addEnter:NO];
			[self addEnd];
			[needParseLine setString:@""];
			return NO;
        }
		else if( commentMultiStartRange.location == 0 )
        {
            [self bracesStarted:currentParseLine andToken:@"%l2"];
			// it's comment multi line
			[self commentStart];
			// check whether comment line is only this line
			if ( commentEndRange.location == NSNotFound )
            {
				// multi line comment
				[self addString: needParseLine addEnter:NO];
                [self addEnd];
				isCommentsNotEnded = YES;
				[needParseLine setString:@""];
				return NO;
            }
			else
            {				
				// single line comment
				NSString* commentsRange = [needParseLine substringToIndex: commentEndRange.location + commentEndRange.length];
				[self addString: commentsRange addEnter:NO];
				[self addEnd];
				NSRange range = {0, commentEndRange.location + commentEndRange.length};
				[needParseLine deleteCharactersInRange: range];
                [self bracesEnded:currentParseLine andToken:@"%l2"];
				return YES;
            }
        }
		return NO;
    }
}

-(BOOL) checkHeader:(NSRange) headerKeyword
{
    return NO;
}

// return YES, if we need to restart parse
// return NO, we do not need to reparse, or no header found
-(BOOL) checkPreprocessor: (int) lineNumber
{
    return NO;
}

// return YES, if we need to restart parse
// return NO, we do not need to reparse, or no header found
-(BOOL) checkChar
{
	unichar charTemp = [needParseLine characterAtIndex:0];
	if ( charTemp != '\'' )
    {
		return NO;
    }
	// We need to parse char
	int index = 1;
	
	// find char end
	for (; index<[needParseLine length]; index++)
    {
		charTemp = [needParseLine characterAtIndex:index];
		if ( charTemp == '\'' )
        {
			if (index > 0 && [needParseLine characterAtIndex:index-1] == '\\')
            {
                // Check whether this situation "\\"
                if (index-2 >= 0 && [needParseLine characterAtIndex:index-2] == '\\') {
                    break;
                }
				continue;
            }
			else
				break;
        }
    }
	
	// we have go through the line and no string end found
	if ( index == [needParseLine length] )
    {
		[self stringStart];
		[self addString:needParseLine addEnter:NO];
		[self addEnd];
		
		[needParseLine setString:@""];
		// We need to get new line
		return NO;
    }
	
	NSString* content = [needParseLine substringToIndex: index+1];
	[self stringStart];
	[self addString: content addEnter:NO];
	[self addEnd];
	NSRange range;
	range.location = 0;
	range.length = index+1;
	[needParseLine deleteCharactersInRange: range];
	return YES;
}

// return YES, if we need to restart parse
// return NO, we do not need to reparse, or no header found
-(BOOL) checkString
{  
	unichar charTemp = [needParseLine characterAtIndex:0];
	if ( charTemp != '\"' && isStringNotEnded == NO )
    {
		return NO;
    }
	// We need to parse string
	int index;
	if ( isStringNotEnded == YES )
    {
		// we need to check from beginning
		index = 0;
    }
	else
    {
		// we need to check from second char, because first is"
		index = 1;
    }
	
	// find string end
	for (; index<[needParseLine length]; index++)
    {
		charTemp = [needParseLine characterAtIndex:index];
		if ( charTemp == '\"' )
        {
			if (index > 0 && [needParseLine characterAtIndex:index-1] == '\\')
            {
                // Check whether this situation "\\"
                if (index-2 >= 0 && [needParseLine characterAtIndex:index-2] == '\\') {
                    break;
                }
				continue;
            }
			else
				break;
        }      
    }
	
	// we have go through the line and no string end found
	if ( index == [needParseLine length] )
    {
		//if ( isStringNotEnded == NO )
        {
			[self stringStart];
			[self addString:needParseLine addEnter:NO];
			[self addEnd];
        }
		
		if ( [needParseLine characterAtIndex:[needParseLine length]-1] != '\\' )
        {
			[needParseLine setString:@""];
			return NO;
        }
		isStringNotEnded = YES;
		[needParseLine setString:@""];
		// We need to get new line
		return NO;
    }
	
	isStringNotEnded = NO;
	NSString* content = [needParseLine substringToIndex: index+1];
	[self stringStart];
	[self addString: content addEnter:NO];
	[self addEnd];
	NSRange range;
	range.location = 0;
	range.length = index+1;
	[needParseLine deleteCharactersInRange: range];
	return YES;
}

-(BOOL) checkOthers: (int)lineNumber
{
    return YES;
}

@end
