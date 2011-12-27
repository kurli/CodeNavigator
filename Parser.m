#import "Parser.h"

@implementation Parser

-(void) setParserType: (ParserType) type
{
	parserType = type;
	if ( CPLUSPLUS == type )
    {
		parser = [[CPlusPlusParser alloc] init];
    }
	else
    {
		parser = nil;
    }
}

-(void) setFile: (NSString*) name andProjectBase:(NSString *)base
{
	[parser setFile: name andProjectBase:base];
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

