#import <Foundation/Foundation.h>
#import "CodeParser.h"
#import "CPlusPlusDefination.h"

@interface CPlusPlusParser : CodeParser
{
	BOOL isCommentsNotEnded;
	NSMutableString* needParseLine;
    BOOL isStringNotEnded;
    NSArray* keywordsArray;
    NSArray* preprocessorArray;
}

-(void) parseLine: (NSString*) line lineNum:(int)lineNumber;

-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkIsKeyword: (NSString*) word;

-(BOOL) checkChar;

-(BOOL) checkHeader:(NSRange) headerKeyword;

-(BOOL) checkIsNameValidChar: (unichar) character;

@end
