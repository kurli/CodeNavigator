//
//  CSharpParser.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/23/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeParser.h"
#import "CPlusPlusDefination.h"
#import "Parser.h"

@interface CSharpParser : CodeParser
{
}

-(void) setType:(int)type;

-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkChar;

-(BOOL) checkHeader:(NSRange) headerKeyword;

-(BOOL) checkIsNameValidChar: (unichar) character;

@end
