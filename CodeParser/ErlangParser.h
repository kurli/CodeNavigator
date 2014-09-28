#import <Foundation/Foundation.h>
#import "CodeParser.h"
#import "ErlangDefination.h"

@interface ErlangParser : CodeParser
{
}

-(BOOL) checkCommentsLine;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkChar;

-(BOOL) checkIsNameValidChar: (unichar) character;

@end
