#import <Foundation/NSObject.h>
#import "CPlusPlusParser.h"

typedef enum _ParserType
{
	CPLUSPLUS
} ParserType;

@interface Parser: NSObject
{
	ParserType parserType;
	CodeParser* codeParser;
	CodeParser* parser;
}

-(void) setFile:(NSString*) name andProjectBase:(NSString*) base;

-(BOOL) startParse;

-(NSString*) getHtml;

-(void) setParserType: (ParserType) type;
@end
