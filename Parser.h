#import <Foundation/NSObject.h>
#import "CPlusPlusParser.h"
#import "UnSupportedParser.h"
#import "ImageParser.h"
#import "ObjectiveCParser.h"
#import "CSharpParser.h"
#import "DelphiParser.h"
#import "PythonParser.h"
#import "RubbyParser.h"
#import "BashParser.h"

typedef enum _ParserType
{
	CPLUSPLUS,
    IMAGE,
    OBJECTIVE_C,
    CSHARP,
    JAVA,
    DELPHI,
    JAVASCRIPT,
    PYTHONE,
    RUBBY,
    BASH,
    UNKNOWN
} ParserType;

@interface Parser: NSObject
{
	ParserType parserType;
	CodeParser* parser;
}

@property (nonatomic, strong) CodeParser* parser;

-(void) setFile:(NSString*) name andProjectBase:(NSString*) base;

-(void) setContent:(NSString*) content andProjectBase:(NSString *)base;

-(void) setMaxLineCount:(int)max;

-(BOOL) startParse;

-(NSString*) getHtml;

-(void) setParserType: (ParserType) type;

-(void) checkParseType: (NSString*) file;
@end
