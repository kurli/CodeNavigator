//
//  CSSParser.h
//  CodeNavigator
//
//  Created by Guozhen Li on 6/3/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "CodeParser.h"

@interface CSSParser : CodeParser

-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkChar;

-(BOOL) checkIsNameValidChar: (unichar) character;

@end
