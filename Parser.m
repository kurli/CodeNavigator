#import "Parser.h"
#import "SBJson.h"

@implementation Parser

@synthesize parser;

-(void) setParserType: (ParserType) type
{
    if (type == -1) {
        //For manually use, Parse has alloced
        return;
    }
    
	parserType = type;
	if ( CPLUSPLUS == type )
    {
		parser = [[CPlusPlusParser alloc] init];
    }
    else if( UNKNOWN == type )
    {
        parser = [[UnSupportedParser alloc] init];
    }
    else if ( IMAGE == type )
    {
        parser = [[ImageParser alloc] init];
    }
    else if (OBJECTIVE_C == type)
    {
        parser = [[ObjectiveCParser alloc] init];
    }
    else if (CSHARP == type)
    {
        parser = [[CSharpParser alloc] init];
        [(CSharpParser*)parser setType:CSHARP];
    }
    else if (JAVA == type)
    {
        parser = [[CSharpParser alloc] init];
        [(CSharpParser*)parser setType:JAVA];
    }
    else if (DELPHI == type)
    {
        parser = [[DelphiParser alloc] init];
    }
    else if (JAVASCRIPT == type)
    {
        parser = [[CSharpParser alloc] init];
        [(CSharpParser*)parser setType:JAVASCRIPT];
    }
    else if (PYTHONE == type)
    {
        parser = [[PythonParser alloc] init];
    }
    else if (RUBBY == type)
    {
        parser = [[RubbyParser alloc] init];
    }
    else if (BASH == type)
    {
        parser = [[BashParser alloc] init];
    }
	else
    {
		parser = nil;
    }
}

+ (int)checkManuallyParserIndex:(NSString*)_extention
{
    NSArray* manuallyParserArray = [Parser getManuallyParserNames];
    for (int i=0; i<[manuallyParserArray count]; i++) {
        NSString* name = [manuallyParserArray objectAtIndex:i];
        NSDictionary* dictionary = [Parser getParserByName:name];
        NSString* extentioin = [dictionary objectForKey:EXTENTION];
        NSArray* array = [extentioin componentsSeparatedByString:@" "];
        for (int j=0; j<[array count]; j++) {
            NSString* ext = [array objectAtIndex:j];
            if ([ext compare:_extention] == NSOrderedSame) {
                return i;
            }
        }
    }
    return -1;
}

-(void) checkParseType:(NSString *)file
{
    NSString *extension = [file pathExtension];
    extension = [extension lowercaseString];

    if ([[[file lastPathComponent] lowercaseString] compare:@"makefile"] == NSOrderedSame) {
        [self setParserType:BASH];
        return;
    }
    
    //Check manually parser type first
    int manuType = [Parser checkManuallyParserIndex:extension];
    if (manuType != -1) {
        ManuallyParser* mParser = [[ManuallyParser alloc] init];
        NSArray* manuallyParserArray = [Parser getManuallyParserNames];
        NSString* name = [manuallyParserArray objectAtIndex:manuType];
        NSDictionary* dictionary = [Parser getParserByName:name];
        [mParser setName:name];
        [mParser setExtentions:[dictionary objectForKey:EXTENTION]];
        [mParser setSingleLineComments:[dictionary objectForKey:SINGLE_LINE_COMMENTS]];
        [mParser setMultilineCommentsS:[dictionary objectForKey:MULTI_LINE_COMMENTS_START]];
        [mParser setMultilineCommentsE:[dictionary objectForKey:MULTI_LINE_COMMENTS_END]];
        [mParser setKeywords:[dictionary objectForKey:KEYWORDS]];
        parser = mParser;
        return;
    }
    
    if ([extension isEqualToString:@"c"])
    {
        [self setParserType:CPLUSPLUS];
        return;
    }
    else if ([extension isEqualToString:@"cc"])
    {
        [self setParserType:CPLUSPLUS];
        return;
    }
    else if ([extension isEqualToString:@"h"])
    {
        NSError *error;
        NSString* path = [file stringByDeletingLastPathComponent];
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
        for (int i =0; i<[contents count]; i++) {
            NSString* tmp = [contents objectAtIndex:i];
            NSString *ext = [tmp pathExtension];
            if ([ext compare:@"m"] == NSOrderedSame)
            {
                [self setParserType:OBJECTIVE_C];
                return;
            }
            if ([ext compare:@"c"] == NSOrderedSame ||
                [ext compare:@"cpp"] == NSOrderedSame)
            {
                [self setParserType:CPLUSPLUS];
                return;
            }
        }
        [self setParserType:CPLUSPLUS];
        return;
    }
    else if ([extension isEqualToString:@"cpp"])
    {
        [self setParserType:CPLUSPLUS];
        return;
    }
    else if ([extension isEqualToString:@"m"])
    {
        [self setParserType:OBJECTIVE_C];
        return;
    }
    else if ([extension isEqualToString:@"cs"])
    {
        [self setParserType:CSHARP];
        return;
    }
    else if ([extension isEqualToString:@"java"])
    {
        [self setParserType:JAVA];
        return;
    }
    else if ([extension isEqualToString:@"delphi"])
    {
        [self setParserType:DELPHI];
        return;
    }
    else if ([extension isEqualToString:@"pascal"])
    {
        [self setParserType:DELPHI];
        return;
    }
    else if ([extension isEqualToString:@"pas"])
    {
        [self setParserType:DELPHI];
        return;
    }
    else if ([extension isEqualToString:@"mm"])
    {
        [self setParserType:CPLUSPLUS];
        return;
    }
    else if ([extension isEqualToString:@"hpp"])
    {
        [self setParserType:CPLUSPLUS];
        return;
    }
    else if ([extension isEqualToString:@"js"] || [extension isEqualToString:@"jscript"] || [extension isEqualToString:@"javascript"])
    {
        [self setParserType:JAVASCRIPT];
        return;
    }
    else if ([extension isEqualToString:@"py"] || [extension isEqualToString:@"python"])
    {
        [self setParserType:PYTHONE];
        return;
    }
    else if ([extension isEqualToString:@"rails"] || [extension isEqualToString:@"ror"] || [extension isEqualToString:@"ruby"])
    {
        [self setParserType:RUBBY];
        return;
    }
    else if ([extension isEqualToString:@"sh"] || [extension isEqualToString:@"shell"] || [extension isEqualToString:@"bash"])
    {
        [self setParserType:BASH];
        return;
    }
    // s xml sql vb
    else
    {
        [self setParserType:UNKNOWN];
    }
}


-(void) setFile: (NSString*) name andProjectBase:(NSString *)base
{
	[parser setFile: name andProjectBase:base];
}

-(void) setContent:(NSString *)content andProjectBase:(NSString *)base
{
    [parser setContent:content andProjectBase:base];
}

-(void) setMaxLineCount:(int)max
{
    [parser setMaxLineCount:max];
}

-(BOOL) startParse
{
	BOOL result = [parser startParse];
	return result;
}

-(NSString*) getHtml
{
  return [parser getHtml];
}

+(BOOL) saveManuallyParser:(NSString *)name andExtention:(NSString *)extention andSingleLine:(NSString *)singleLine andMultiLineS:(NSString *)multilineS andMultLineE:(NSString *)multilineE andKeywords:(NSString *)keywords
{
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:PARSER_PATH];
    BOOL isDirectory;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:manuallyParserPath isDirectory:&isDirectory];
    if (exist == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:manuallyParserPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    manuallyParserPath = [manuallyParserPath stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"json"]];
    exist= [[NSFileManager defaultManager] fileExistsAtPath:manuallyParserPath];
    if (exist) {
        return NO;
    }
    
    NSArray* keywordsArray = [keywords componentsSeparatedByString:@" "];
    keywordsArray = [keywordsArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSComparisonResult result = [a compare:b];
            return result;
        }];
    NSMutableString* str = [[NSMutableString alloc] init];
    for (int i=0; i<[keywordsArray count]-1; i++) {
        if ([[keywordsArray objectAtIndex:i] length] == 0) {
            continue;
        }
        [str appendFormat:@"%@ ",[keywordsArray objectAtIndex:i]];
    }
    if ([[keywordsArray lastObject] length] != 0) {
        [str appendString:[keywordsArray lastObject]];
    }
    
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:extention forKey:EXTENTION];
    [dictionary setObject:singleLine forKey:SINGLE_LINE_COMMENTS];
    [dictionary setObject:multilineS forKey:MULTI_LINE_COMMENTS_START];
    [dictionary setObject:multilineE forKey:MULTI_LINE_COMMENTS_END];
    [dictionary setObject:str forKey:KEYWORDS];
    
    NSString* jsonContent = [dictionary JSONRepresentation];
    [jsonContent writeToFile:manuallyParserPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

+(NSArray*) getManuallyParserNames
{
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:PARSER_PATH];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:manuallyParserPath error:nil];
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (int i=0; i<[contents count]; i++) {
        NSString* item = [contents objectAtIndex:i];
        if ([[item pathExtension] compare:@"json"] == NSOrderedSame) {
            [array addObject:[item stringByDeletingPathExtension]];
        }
    }
    return array;
}

+(NSDictionary*) getParserByName:(NSString *)name
{
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:PARSER_PATH];
    manuallyParserPath = [manuallyParserPath stringByAppendingPathComponent:name];
    manuallyParserPath = [manuallyParserPath stringByAppendingPathExtension:@"json"];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:manuallyParserPath];
    if (exist == NO) {
        return nil;
    }
    NSString* str = [NSString stringWithContentsOfFile:manuallyParserPath encoding:NSUTF8StringEncoding error:nil];
    if ([str length] == 0) {
        return nil;
    }
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* dictionary = [parser objectWithString:str];
    return dictionary;
}

@end

