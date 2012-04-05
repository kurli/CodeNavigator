//
//  ObjectiveCParser.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/22/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeParser.h"
#import "ObjectiveCDefinition.h"

@interface ObjectiveCParser : CodeParser
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

-(BOOL) checkATBeginner:(int) lineNumber;

@end
