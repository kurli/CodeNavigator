#import <Foundation/NSObject.h>
#import "CPlusPlusParser.h"
#import "UnSupportedParser.h"

typedef enum _ParserType
{
	CPLUSPLUS,
    UNKNOWN
} ParserType;

@interface Parser: NSObject
{
	ParserType parserType;
	CodeParser* parser;
}

@property (nonatomic, strong) CodeParser* parser;

-(void) setFile:(NSString*) name andProjectBase:(NSString*) base;

-(BOOL) startParse;

-(NSString*) getHtml;

-(void) setParserType: (ParserType) type;
@end
