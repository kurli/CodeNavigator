#import "Parser.h"

@implementation Parser

@synthesize parser;

-(void) setParserType: (ParserType) type
{
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

-(void) checkParseType:(NSString *)file
{
    NSString *extension = [file pathExtension];
    extension = [extension lowercaseString];

    if ([[[file lastPathComponent] lowercaseString] compare:@"makefile"] == NSOrderedSame) {
        [self setParserType:BASH];
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

@end

