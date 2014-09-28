#import <Foundation/Foundation.h>
#import "CodeParser.h"
#import "LuaDefination.h"

@interface LuaParser : CodeParser
{
}

-(BOOL) checkCommentsLine;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkChar;

-(BOOL) checkIsNameValidChar: (unichar) character;

@end
