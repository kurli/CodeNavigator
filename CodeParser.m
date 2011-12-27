#import "CodeParser.h"
#import "HTMLConst.h"
#import "cscope.h"

@implementation CodeParser

-(void) setFile:(NSString*)name andProjectBase:(NSString *)base
{
    NSError *error;
    NSStringEncoding encoding = NSUTF8StringEncoding;
    fileContent = [NSString stringWithContentsOfFile: name usedEncoding:&encoding error: &error];
	htmlContent = [[NSMutableString alloc] init];
    projectBase = base;
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
		[self lineStart:i+1];
		NSString* lineString = [lineArray objectAtIndex: i];
		[self parseLine: lineString lineNum:i];
		[self lineEnd];
        //[lineString release];
    }
	//[lineArray release];
    [htmlContent appendString: HTML_END];
    [self addString:@"" addEnter:YES];
	return YES;
}

-(void) parseLine: (NSString*) line lineNum:(int)number
{
	
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

// ---------------- HTML Components ------------------- 
-(void) addHead
{
    NSError *error;
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString* jsPath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingPathComponent:@"lgz_javascript.js"];
    NSString* content = [NSString stringWithContentsOfFile:jsPath usedEncoding:&encoding error:&error];
    NSString* headContent = [NSString stringWithFormat:HTML_HEAD, content];
	[htmlContent appendString: headContent];
	[htmlContent appendString: HTML_STYLE];
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
    NSMutableString* mutableString = [content mutableCopy];
    content = [mutableString stringByReplacingOccurrencesOfString: @"<" withString:@"&lt;"];
    mutableString = [content mutableCopy];
    content = [mutableString stringByReplacingOccurrencesOfString: @">" withString:@"&gt;"];
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

-(void) otherWordStart
{
    [htmlContent appendString:HTML_OTHER_WORD];
}

-(void) lineStart: (int)line
{
    NSString* content = [NSString stringWithFormat:HTML_LINE_START, line, line, line];
	[htmlContent appendString: content];
}

-(void) lineEnd
{
	[htmlContent appendString: HTML_LINE_END];
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
        if ( temp == ' ' )
			break;
	}
	if ( index == [content length] )
		return -1;
	
	return index;
}

// ---------------- Common Components  END ------------------- 



@end
