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
    }
    else if (JAVA == type)
    {
        parser = [[JavaParser alloc] init];
    }
    else if (PHP == type)
    {
        parser = [[PHPParser alloc] init];
    }
    else if (DELPHI == type)
    {
        parser = [[DelphiParser alloc] init];
    }
    else if (JAVASCRIPT == type)
    {
        parser = [[JavaScriptParser alloc] init];
    }
    else if (PYTHON == type)
    {
        parser = [[PythonParser alloc] init];
    }
    else if (RUBY == type)
    {
        parser = [[RubyParser alloc] init];
    }
    else if (BASH == type)
    {
        parser = [[BashParser alloc] init];
    }
    else if (HTML == type)
    {
        parser = [[HtmlParser alloc] init];
    }
    else if (CSS == type)
    {
        parser = [[CSSParser alloc] init];
    }
	else
    {
		parser = nil;
    }
}

+ (int)checkManuallyParserIndex:(NSString*)_extension
{
    NSArray* manuallyParserArray = [Parser getManuallyParserNames];
    for (int i=0; i<[manuallyParserArray count]; i++) {
        NSString* name = [manuallyParserArray objectAtIndex:i];
        NSDictionary* dictionary = [Parser getManuallyParserByName:name];
        NSString* extentioin = [dictionary objectForKey:EXTENSION];
        NSArray* array = [extentioin componentsSeparatedByString:@" "];
        for (int j=0; j<[array count]; j++) {
            NSString* ext = [array objectAtIndex:j];
            if ([ext compare:_extension] == NSOrderedSame) {
                return i;
            }
        }
    }
    return -1;
}

+(ParserType) checkBuildInParserType:(NSString*)_extension
{
    NSArray* buildInParserArray = [Parser getBuildInParserNames];
    for (int i=0; i<[buildInParserArray count]; i++) {
        NSString* name = [buildInParserArray objectAtIndex:i];
        NSDictionary* dictionary = [Parser getBuildInParserByName:name];
        NSString* extentioin = [dictionary objectForKey:EXTENSION];
        NSArray* array = [extentioin componentsSeparatedByString:@" "];
        for (int j=0; j<[array count]; j++) {
            NSString* ext = [array objectAtIndex:j];
            if ([ext compare:_extension] == NSOrderedSame) {
                NSString* type = [dictionary objectForKey:TYPE];
                return [type intValue];
            }
        }
    }
    return -1;
}

+(ParserType) getBuildInParserTypeByfilePath:(NSString*)filePath
{
    ParserType type = UNKNOWN;
    NSString *extension = [filePath pathExtension];
    extension = [extension lowercaseString];
    
    // For makefile specific case
    if ([[[filePath lastPathComponent] lowercaseString] compare:@"makefile"] == NSOrderedSame) {
        return BASH;
    }
    
    // Special case for h file
    if ([extension isEqualToString:@"h"])
    {
        NSError *error;
        NSString* path = [filePath stringByDeletingLastPathComponent];
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
        for (int i =0; i<[contents count]; i++) {
            NSString* tmp = [contents objectAtIndex:i];
            NSString *ext = [tmp pathExtension];
            if ([ext compare:@"m"] == NSOrderedSame)
            {
                return OBJECTIVE_C;
            }
            if ([ext compare:@"c"] == NSOrderedSame ||
                [ext compare:@"cpp"] == NSOrderedSame)
            {
                return CPLUSPLUS;
            }
        }
        return CPLUSPLUS;
    }
    
    if ([extension isEqualToString:@"html"] || [extension isEqualToString:@"htm"] ||
        [extension isEqualToString:@"xml"])
    {
        return HTML;
    }
    
    // Check Buildin parser first
    type = [Parser checkBuildInParserType:extension];
    if (type == -1) {
        return UNKNOWN;
    }
    return type;
}

-(void) checkParseType:(NSString *)file
{
    ParserType type = [Parser getBuildInParserTypeByfilePath:file];
    
    if (type != UNKNOWN)
        [self setParserType:type];
    else {
        int manuType = [Parser checkManuallyParserIndex:[file pathExtension]];
        if (manuType != -1) {
            ManuallyParser* mParser = [[ManuallyParser alloc] init];
            NSArray* manuallyParserArray = [Parser getManuallyParserNames];
            NSString* name = [manuallyParserArray objectAtIndex:manuType];
            NSDictionary* dictionary = [Parser getManuallyParserByName:name];
            [mParser setName:name];
            [mParser setExtensions:[dictionary objectForKey:EXTENSION]];
            [mParser setSingleLineComments:[dictionary objectForKey:SINGLE_LINE_COMMENTS]];
            [mParser setMultilineCommentsS:[dictionary objectForKey:MULTI_LINE_COMMENTS_START]];
            [mParser setMultilineCommentsE:[dictionary objectForKey:MULTI_LINE_COMMENTS_END]];
            [mParser setKeywords:[dictionary objectForKey:KEYWORDS]];
            parser = mParser;
            return;
        }
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

+(BOOL) saveParser:(NSString *)path andExtention:(NSString *)extension andSingleLine:(NSString *)singleLine andMultiLineS:(NSString *)multilineS andMultLineE:(NSString *)multilineE andKeywords:(NSString *)keywords andType:(int)type
{
    if (path == nil)
        return NO;
    if (extension == nil)
        extension = @"";
    if (singleLine == nil)
        singleLine = @"";
    if (multilineE == nil)
        multilineE = @"";
    if (multilineS == nil)
        multilineS = @"";
    if (keywords == nil)
        keywords = @"";
    
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:MANUALLY_PARSER_PATH];
    BOOL isDirectory;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:manuallyParserPath isDirectory:&isDirectory];
    if (exist == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:manuallyParserPath withIntermediateDirectories:YES attributes:nil error:nil];
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
    
    NSString* tmp = [NSString stringWithFormat:@"%d", type];
    
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:extension forKey:EXTENSION];
    [dictionary setObject:singleLine forKey:SINGLE_LINE_COMMENTS];
    [dictionary setObject:multilineS forKey:MULTI_LINE_COMMENTS_START];
    [dictionary setObject:multilineE forKey:MULTI_LINE_COMMENTS_END];
    [dictionary setObject:str forKey:KEYWORDS];
    [dictionary setObject:tmp forKey:TYPE];

    NSString* jsonContent = [dictionary JSONRepresentation];
    [jsonContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

+(NSArray*) getManuallyParserNames
{
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:MANUALLY_PARSER_PATH];
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

+(NSArray*) getBuildInParserNames
{
    NSString* buildInParserPath = [NSHomeDirectory() stringByAppendingFormat:BUILDIN_PARSER_PATH];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:buildInParserPath error:nil];
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (int i=0; i<[contents count]; i++) {
        NSString* item = [contents objectAtIndex:i];
        if ([[item pathExtension] compare:@"json"] == NSOrderedSame) {
            [array addObject:[item stringByDeletingPathExtension]];
        }
    }
    return array;
}

+(NSDictionary*) getManuallyParserByName:(NSString *)name
{
    NSString* manuallyParserPath = [NSHomeDirectory() stringByAppendingFormat:MANUALLY_PARSER_PATH];
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

+(NSDictionary*) getBuildInParserByName:(NSString *)name
{
    NSString* buildInParserPath = [NSHomeDirectory() stringByAppendingFormat:BUILDIN_PARSER_PATH];
    buildInParserPath = [buildInParserPath stringByAppendingPathComponent:name];
    buildInParserPath = [buildInParserPath stringByAppendingPathExtension:@"json"];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:buildInParserPath];
    if (exist == NO) {
        return nil;
    }
    NSString* str = [NSString stringWithContentsOfFile:buildInParserPath encoding:NSUTF8StringEncoding error:nil];
    if ([str length] == 0) {
        return nil;
    }
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* dictionary = [parser objectWithString:str];
    return dictionary;
}

@end

