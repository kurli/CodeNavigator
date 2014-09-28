#import <Foundation/Foundation.h>
#import "CodeParser.h"
#import "ErlangDefination.h"

@interface ErlangParser : CodeParser
{
}

-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkChar;

-(BOOL) checkHeader:(NSRange) headerKeyword;

-(BOOL) checkIsNameValidChar: (unichar) character;

@end
