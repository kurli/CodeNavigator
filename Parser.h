#import <Foundation/NSObject.h>
#import "CPlusPlusParser.h"
#import "UnSupportedParser.h"
#import "ImageParser.h"
#import "ObjectiveCParser.h"
#import "CSharpParser.h"
#import "DelphiParser.h"
#import "PythonParser.h"
#import "RubyParser.h"
#import "BashParser.h"
#import "ManuallyParser.h"
#import "HtmlParser.h"
#import "JavaParser.h"
#import "JavaScriptParser.h"
#import "PHPParser.h"

#define MANUALLY_PARSER_PATH @"/Documents/.settings/ManuallyParser"
#define EXTENSION @"extension"
#define SINGLE_LINE_COMMENTS @"single_line_comments"
#define MULTI_LINE_COMMENTS_START @"multi_line_comments_start"
#define MULTI_LINE_COMMENTS_END @"multi_line_comments_end"
#define TYPE @"type"
#define KEYWORDS @"keywords"

#define PREDEF_PARSER @"C/C++", @"Objective-C", @"C#", @"Java", @"Delphi", @"Javascript", @"Python", @"Ruby", @"Bash", @"PHP"

typedef enum _ParserType
{
	CPLUSPLUS = 0,
    OBJECTIVE_C,
    CSHARP,
    JAVA,
    DELPHI,
    JAVASCRIPT,
    PYTHON,
    RUBY,
    BASH,
    PHP,//End
    HTML,
    IMAGE,
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

+(ParserType) getBuildInParserTypeByfilePath:(NSString*)filePath;

#pragma mark manually parser support
+(BOOL)saveParser:(NSString*)path andExtention:(NSString*)extension andSingleLine:(NSString*)singleLine andMultiLineS:(NSString*)multilineS andMultLineE:(NSString*)multilineE andKeywords:(NSString*)keywords andType:(int)type;

+(NSArray*) getManuallyParserNames;

+(NSDictionary*) getManuallyParserByName:(NSString*)name;

+ (int)checkManuallyParserIndex:(NSString*)extension;
@end
