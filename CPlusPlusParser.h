#import <Foundation/Foundation.h>
#import "CodeParser.h"
#import "CPlusPlusDefination.h"

@interface CPlusPlusParser : CodeParser
{
}

-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkIsKeyword: (NSString*) word;

-(BOOL) checkChar;

-(BOOL) checkHeader:(NSRange) headerKeyword;

-(BOOL) checkIsNameValidChar: (unichar) character;

@end
