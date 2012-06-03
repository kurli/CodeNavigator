#import "CodeParser.h"
#import "HTMLConst.h"
#import "cscope.h"

@implementation CodeParser

-(void) setFile:(NSString*)name andProjectBase:(NSString *)base
{
    NSError *error;
    NSStringEncoding encoding = NSUTF8StringEncoding;
    fileContent = [NSString stringWithContentsOfFile: name usedEncoding:&encoding error: &error];
    if (error != nil || fileContent == nil)
    {
        // Chinese GB2312 support 
        error = nil;
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        fileContent  = [NSString stringWithContentsOfFile:name encoding:enc error:&error];
        
        if (fileContent == nil)
        {
            const NSStringEncoding *encodings = [NSString availableStringEncodings];  
            while ((encoding = *encodings++) != 0)  
            {
                fileContent = [NSString stringWithContentsOfFile: name encoding:encoding error:&error];
                if (fileContent != nil && error == nil)
                {
                    break;
                }
            }
        }
        
        if (fileContent == nil)
            fileContent = @"File Format not supported yet!";
    }
    htmlContent = [[NSMutableString alloc] init];
    projectBase = base;
    maxLineCount = MAX_CHAR_IN_LINE;
}

-(void) setContent:(NSString *)content andProjectBase:(NSString *)base
{
    fileContent = content;
    htmlContent = [[NSMutableString alloc] init];
    projectBase = base;
}

-(void) setMaxLineCount:(int)max
{
    maxLineCount = max;
}

-(NSString*) wrapLine:(NSString*)lineString
{
    if ([lineString length] <= maxLineCount)
        return lineString;
    int spaceCount = 0;
    int index = 0;
    while (true) {
        unichar c = [lineString characterAtIndex:index];
        index++;
        if (c == ' ')
            spaceCount++;
        else if (c == '\t')
            spaceCount+=4;
        else
        {
            break;
        }
    }
    if (spaceCount > maxLineCount/2) {
        spaceCount = 0;
    }
    NSMutableString *returnStr = [[NSMutableString alloc] initWithString:@""];
    index = maxLineCount-1;
    NSString *str2;
    while (true) {
        while (index>0) {
            char c = [lineString characterAtIndex:index];
            if ((c>='a' && c<='z') || (c>='A' && c<='Z') || c == '_' || (c>='0' && c<='9'))
            {
                index--;
                continue;
            }
            break;
        }
        if (index <= 0)
        {
            if ([lineString length] > maxLineCount) {
                index = maxLineCount;
            }
            else
                index = [lineString length];
        }
        
        NSString* str = [lineString substringToIndex:index];
        [returnStr appendString:str];
        [returnStr appendString:BREAK_STR];
        for (int i=0; i<spaceCount; i++) {
            [returnStr appendString:@" "];
        }
        [returnStr appendString:@"     "];
        str2 = [lineString substringFromIndex:index];
        if ([str2 length] + spaceCount + 5 > maxLineCount)
        {
            lineString = str2;
            index = maxLineCount - spaceCount - 5;
            continue;
        }else
        {
            [returnStr appendString:str2];
            break;
        }
        
    }
    return returnStr;
}

-(BOOL) startParse
{
	if ( nil == fileContent )
    {
		return NO;
    }
	[self addHead];

	NSArray* lineArray = [fileContent componentsSeparatedByString:@"\n"];
	int i = 0;
	for ( i=0; i<[lineArray count]; i++)
    {
        @autoreleasepool {
            int start = [htmlContent length];
            if (start != 0)
                start--;
            if (i == 61) {
                i = i;
            }
            [self lineStart:i+1 andContent:[lineArray objectAtIndex:i]];
            NSString* lineString = [lineArray objectAtIndex: i];
            lineString = [self wrapLine:lineString];
            currentParseLine = i;
            [self parseLine: lineString lineNum:i];
            [self lineEnd];
            NSRange range = {start, [htmlContent length]-start};
            [htmlContent replaceOccurrencesOfString:BREAK_STR withString:@"<br>" options:NSCaseInsensitiveSearch range:range];
        }
    }
    [htmlContent appendString: HTML_END];
    [self addString:@"" addEnter:YES];
	return YES;
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
			// check preprocessor
			if ( [self checkPreprocessor: lineNumber] == YES )
				continue;
			else{
				if ( [needParseLine length] == 0 )
					break;
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
            // check keywords
            if ( [self checkOthers: lineNumber] == YES )
				continue;
            else
			{
                if ( [needParseLine length] == 0 )
					break;
			}
		}
	}	
}

-(BOOL) isProjectDefinedWord:(NSString*) word
{
    if (nil == projectBase)
    {
        return NO;
    }
    else
    {
        NSString* fileListPath = [projectBase stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
        NSString* dbPath = [projectBase stringByAppendingPathComponent:@"project.lgz_db"];
        cscope_set_base_dir([projectBase UTF8String]);
        char* _out = cscope_find_global([word UTF8String], [fileListPath UTF8String], [dbPath UTF8String]);
        NSString* outStr = [NSString stringWithCString:_out encoding:NSUTF8StringEncoding];
        if ([outStr length] == 0)
            return NO;
        return YES;
    }
}

// ---------------- Parser related interface  -------------------
-(BOOL) checkCommentsLine
{
    return YES;
}

-(BOOL) checkPreprocessor:(int) lineNumber
{
    return YES;
}

-(BOOL) checkString
{
    return YES;
}

-(BOOL) checkChar
{
    return YES;
}

-(BOOL) checkOthers: (int)lineNumber
{
    return YES;
}

-(void) bracesStarted:(int)lineNumber andToken:(NSString *)token
{
    if (bracesArray == nil) {
        bracesArray = [[NSMutableArray alloc] init];
    }
    NSString* str = [NSString stringWithFormat:@"%@:%d:%d", token, lineNumber+1, [htmlContent length]];
    //skip when pre fold in this line
    for (int i=0; i<[bracesArray count]; i++) {
        NSString* tmp = [bracesArray objectAtIndex:i];
        NSArray* array = [tmp componentsSeparatedByString:@":"];
        if ([array count] != 3) {
            continue;
        }
        NSString* l = [array objectAtIndex:1];
        if ([l intValue] == lineNumber+1) {
            return;
        }
    }
    [bracesArray addObject:str];
}

-(void) bracesEnded:(int)lineNumber andToken:(NSString *)token
{
    if (bracesArray == nil) {
        return;
    }
    if ([bracesArray count] == 0)
        return;
    lineNumber = lineNumber+1;
    int index = [bracesArray count]-1;
    for (; index>=0; index--) {
        NSString* str = [bracesArray objectAtIndex:index];
        NSArray* array = [str componentsSeparatedByString:@":"];
        if ([array count] != 3) {
            continue;
        }
        NSString* t = [array objectAtIndex:0];
        if ([t compare:token] != NSOrderedSame) {
            continue;
        }
        break;
    }
    if (index == -1) {
        return;
    }
    NSString* str = [bracesArray objectAtIndex:index];
    // lineNumber:token position
    NSArray* array = [str componentsSeparatedByString:@":"];
    int startLine = [[array objectAtIndex:1] intValue];
    int startPosition = [[array objectAtIndex:2] intValue];
    str = [NSString stringWithFormat:@"%@:%d:%d", token, startLine, lineNumber];
    //change htmlContent
    //first get the range of token 'str
    NSRange range;
    range.location = 0;
    range.length = startPosition;
    //get <tr id position
    range = [htmlContent rangeOfString:@"<tr id" options:NSBackwardsSearch range:range];
    range.length = (startPosition-range.location);
    NSString* tmp;
    tmp = [htmlContent stringByReplacingOccurrencesOfString:@"_*&^" withString:str options:NSLiteralSearch range:range];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"▓" withString:@"-" options:NSLiteralSearch range:range];
    htmlContent = [NSMutableString stringWithString:tmp];
    
    [bracesArray removeObjectAtIndex:index];
}

-(BOOL) checkIsKeyword: (NSString*) word
{
	int i=0;
	for (; i<[keywordsArray count]; i++)
    {
		//TODO performance need to be more improved
		NSString* key = [keywordsArray objectAtIndex:i];
        NSComparisonResult result = [key compare:word];
		if ( result == NSOrderedSame )
			return YES;
        if ( result > 0) {
            return NO;
        }
    }
	return NO;
}

// end

// ---------------- HTML Components ------------------- 
-(void) addHead
{
//    NSError *error;
//    NSStringEncoding encoding = NSUTF8StringEncoding;
//    NSString* jsPath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingPathComponent:@"lgz_javascript.js"];
//    NSString* content = [NSString stringWithContentsOfFile:jsPath usedEncoding:&encoding error:&error];
//    NSString* headContent = [NSString stringWithFormat:HTML_HEAD, content];
	[htmlContent appendString: HTML_HEAD];
    [htmlContent appendString: HTML_JS_LINK];
	[htmlContent appendString: HTML_STYLE_LINK];
	[htmlContent appendString: HTML_HEAD_END];
	[htmlContent appendString: HTML_BODY_START];
}

-(void) addBlankLine
{
	[htmlContent appendString: HTML_BLANK];
}

-(void) addString:(NSString *)content addEnter: (BOOL)addEnter
{
    // replace < and >
//    NSMutableString* mutableString = [content mutableCopy];
    content = [content stringByReplacingOccurrencesOfString: @"<" withString:@"&lt;"];
//    mutableString = [content mutableCopy];
    content = [content stringByReplacingOccurrencesOfString: @">" withString:@"&gt;"];
	[htmlContent appendString: content];
	if( YES == addEnter )
		[htmlContent appendString: HTML_BLANK];
}

-(void) addLink:(NSString*)name type:(NSString*)type
{
  NSString* content = [NSString stringWithFormat:HTML_LINK, type, name, type];
  [htmlContent appendString: content];
}

-(void) addLinkEnd
{
  [htmlContent appendString: HTML_LINK_END];
}

-(void) addEnd
{
	[htmlContent appendString: HTML_SPAN_END];
}

-(void) commentStart
{
  [htmlContent appendString: HTML_COMMENT_START];
}

-(NSString*) getHtml
{
	return htmlContent;
}

-(void) headerStart
{
  [htmlContent appendString: HTML_HEADER_START];
}

-(void) stringStart
{
  [htmlContent appendString:HTML_STRING_START];
}

-(void) keywordStart
{
  [htmlContent appendString:HTML_KEYWORD_START];
}

-(void) systemStart
{
  [htmlContent appendFormat:HTML_SYSTEM_START];
}

-(void) otherWordStart
{
    [htmlContent appendString:HTML_OTHER_WORD];
}

-(void) addUnknownLine:(NSString *)content
{
//    NSMutableString* mutableString = [content mutableCopy];
    content = [content stringByReplacingOccurrencesOfString: @"<" withString:@"&lt;"];
//    mutableString = [content mutableCopy];
    content = [content stringByReplacingOccurrencesOfString: @">" withString:@"&gt;"];

    [htmlContent appendFormat:HTML_UNKNOWN_LINE, content];
}

-(void) lineStart: (int)line andContent:(NSString *)lineContent
{
    NSString* content = [NSString stringWithFormat:HTML_LINE_START, line, line, line];
    [htmlContent appendString: content];    
}

-(void) lineEnd
{
	[htmlContent appendString: HTML_LINE_END];
}

-(void) addImage:(NSString *)imgPath
{
    [htmlContent appendFormat: HTML_IMAGE, imgPath];
}

-(void) numberStart
{
    [htmlContent appendString: HTML_NUMBER_START];
}

// ---------------- HTML Components End ------------------- 

// ---------------- Common Components ------------------- 

// -1 no space found, >=0 space found
-(int) getNextSpaceIndex:(NSMutableString*) content
{
	int index = 0;
    unichar temp;
    for (; index<[content length]; index++)
	{
        temp = [content characterAtIndex:index];
        if ( temp == ' ' || temp == '\t'  || temp == 13 || temp == 10)
			break;
	}
	if ( index == [content length] )
		return -1;
	
	return index;
}

// ---------------- Common Components  END ------------------- 



@end
