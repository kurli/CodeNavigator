//
//  CSSParser.m
//  CodeNavigator
//
//  Created by Guozhen Li on 6/3/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "CSSParser.h"

@implementation CSSParser

-(id) init
{
    [self setParserConfigName:@"CSS"];
	if ( (self = [super init])!=nil )
	{
	}
	return self;
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
		// comments not ended we nned to find "*/"
		// In this case we assume that we have met /* before
		NSRange commentEndRange = [needParseLine rangeOfString: [self getMultiLineCommentsEndStr]];
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
            
            [self bracesEnded:currentParseLine andToken:[self getMultiLineCommentsStartStr]];
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
		NSRange commentSingleRange = [needParseLine rangeOfString: [self getSingleLineCommentsStr]];
		NSRange commentMultiStartRange = [needParseLine rangeOfString: [self getMultiLineCommentsStartStr]];
		NSRange commentEndRange = [needParseLine rangeOfString: [self getMultiLineCommentsEndStr]];
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
            [self bracesStarted:currentParseLine andToken:[self getMultiLineCommentsStartStr]];
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
                [self bracesEnded:currentParseLine andToken:[self getMultiLineCommentsStartStr]];
                
				return YES;
            }
        }
		return NO;
    }
}

-(BOOL) checkHeader:(NSRange) headerKeyword
{
  	if ( headerKeyword.location == NSNotFound )
    {
		return NO;
    }
	// header started
	[self headerStart];
	NSString* keyword = [needParseLine substringToIndex: headerKeyword.location + headerKeyword.length];
	[self addString: keyword addEnter: NO];
	[self addEnd];
	NSRange range = {0, headerKeyword.location + headerKeyword.length};
	[needParseLine deleteCharactersInRange: range];
    
	unichar charTemp;
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
		else
        {
			if ( charTemp == '"' )
            {
				[self stringStart];
				[self addString:@"\"" addEnter:NO];
				range.location = 0;
				range.length = 1;
				[needParseLine deleteCharactersInRange:range];
				range = [needParseLine rangeOfString: @"\""];
                if ( range.location == NSNotFound )
				{
					// parse error
                    [self addString:needParseLine addEnter:NO];
                    [needParseLine setString: @""];
                    return YES;
				}
				NSString* content = [needParseLine substringToIndex: range.location + range.length];
				// add to code analyzer
				[self addString:content addEnter:NO];
				[self addEnd];
				NSRange deleteRange;
				deleteRange.location = 0;
				deleteRange.length = range.location + range.length;
				[needParseLine deleteCharactersInRange: deleteRange];
				return YES;
            }
			else if ( charTemp == '<' )
            {
				[self stringStart];
				[self addString:@"&lt;" addEnter:NO];
				range.location = 0;
				range.length = 1;
				[needParseLine deleteCharactersInRange:range];
				range = [needParseLine rangeOfString: @">"];
                if ( range.location == NSNotFound )
				{
                    [self addString:needParseLine addEnter:NO];
                    [needParseLine setString: @""];
                    return YES;
				}
				NSString* content = [needParseLine substringToIndex: range.location + range.length-1];
				[self addString:content addEnter:NO];
                [self addString:@"&gt" addEnter:NO];
				[self addEnd];
				NSRange deleteRange;
				deleteRange.location = 0;
				deleteRange.length = range.location + range.length;
				[needParseLine deleteCharactersInRange: deleteRange];
				return YES;
            }
			else
            {
				return YES;
            }
        }
	}
    return YES;
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

-(BOOL) checkIsNameValidChar: (unichar) character
{
	if ( (int)character >='a' && (int)character <='z' )
        return YES;
	else if ( (int)character == '_' || (int)character == '-')
        return YES;
	else if( (int)character >= '0' && (int)character <='9' )
        return YES;
	else if ( (int)character >='A' && (int)character <='Z' )
        return YES;
	return NO;
}

// return YES, if we need to restart parse
// return NO, we do not need to reparse, or no header found
-(BOOL) checkOthers: (int) lineNumber
{
	// Get string before space
	NSRange range = [needParseLine rangeOfString: @" "];
	NSString* word;
	if ( range.location == NSNotFound )
    {
		word = [needParseLine substringToIndex:[needParseLine length]];
		range.location = [needParseLine length];
    }
	else
        word = [needParseLine substringToIndex: range.location];
	
	// get word index
	int index;
	unichar temp;
	for (index=0; index<[word length]; index++)
    {
		temp = [word characterAtIndex: index];
		if ([self checkIsNameValidChar: temp] == NO)
        {
			break;
        }
    }
	
	// If first letter is not name valid char
    // It's a operator
	if ( index == 0 )
    {
		// it should be a operator
		word = [needParseLine substringToIndex: 1];
		[self addString: word addEnter:NO];
		[needParseLine deleteCharactersInRange: NSMakeRange(0, 1)];
        
        //fold support
        if ([word compare:@"{"] == NSOrderedSame) {
            [self bracesStarted:lineNumber andToken:@"{"];
        }
        else if ([word compare:@"}"] == NSOrderedSame)
        {
            [self bracesEnded:lineNumber andToken:@"}"];
        }
		return YES;
    }
	
	// if other syntax after keyword, delete these
	word = [needParseLine substringToIndex:index];
	
	// check whether keyword
	if ( [self checkIsKeyword:word] == YES )
    {
		[self keywordStart];
		[self addString:word addEnter:NO];
		[self addEnd];
		[needParseLine deleteCharactersInRange: NSMakeRange(0, index)];
		return YES;
    }
    else
    {
        // check whether is a number
        if ([word rangeOfString:@"0x"].location == 0) {
            for (index=2; index<[word length]; index++)
            {
                temp = [word characterAtIndex: index];
                if ((temp >='0' && temp <='9') ||
                    (temp >='A' && temp <= 'Z') ||
                    (temp >= 'a' && temp <= 'z'))
                {
                    continue;
                }
                break;
            }
            word = [word substringToIndex:index];
            [self numberStart];
            [self addString:word addEnter:NO];
            [self addEnd];
            [needParseLine deleteCharactersInRange: NSMakeRange(0, index)];
            return YES;
        }
        BOOL foundNumber = NO;
        int index2=0;
        for (index2=0; index2<[word length]; index2++)
        {
            temp = [word characterAtIndex: index2];
            if ((temp >='0' && temp <='9'))
            {
                foundNumber = YES;
                continue;
            }
            break;
        }
        if ( foundNumber == YES ) {
            word = [word substringToIndex:index2];
            [self numberStart];
            [self addString:word addEnter:NO];
            [self addEnd];
            [needParseLine deleteCharactersInRange: NSMakeRange(0, index2)];
            return YES;
        }
        //end
        
        [self otherWordStart];
        [self addString:word addEnter:NO];
        [self addEnd];
        [needParseLine deleteCharactersInRange: NSMakeRange(0, index)];
        return YES;
    }
	return YES;
}
@end
