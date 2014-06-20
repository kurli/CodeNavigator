#import <Foundation/Foundation.h>
#import "CodeParser.h"

#define BRACE_START @"{"

#define BRACE_END @"}"

@interface GoParser : CodeParser
{
}

-(BOOL) checkCommentsLine;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkChar;

-(BOOL) checkIsNameValidChar: (unichar) character;

@end
