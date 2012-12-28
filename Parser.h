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
#import "ManuallyParser.h"
#import "HtmlParser.h"

#define PARSER_PATH @"/Documents/.settings/ManuallyParser"
#define EXTENTION @"extention"
#define SINGLE_LINE_COMMENTS @"single_line_comments"
#define MULTI_LINE_COMMENTS_START @"multi_line_comments_start"
#define MULTI_LINE_COMMENTS_END @"multi_line_comments_end"
#define KEYWORDS @"keywords"

typedef enum _ParserType
{
	CPLUSPLUS = 0,
    IMAGE,
    OBJECTIVE_C,
    CSHARP,
    JAVA,
    DELPHI,
    JAVASCRIPT,
    PYTHONE,
    RUBY,
    BASH,
    HTML,
    PHP,
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

#pragma mark manually parser support
+(BOOL)saveManuallyParser:(NSString*)name andExtention:(NSString*)extention andSingleLine:(NSString*)singleLine andMultiLineS:(NSString*)multilineS andMultLineE:(NSString*)multilineE andKeywords:(NSString*)keywords;

+(NSArray*) getManuallyParserNames;

+(NSDictionary*) getParserByName:(NSString*)name;

+ (int)checkManuallyParserIndex:(NSString*)extention;
@end
