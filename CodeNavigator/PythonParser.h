//
//  PythonParser.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/23/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PythonDefinition.h"
#import "CodeParser.h"

@interface PythonParser : CodeParser
{
}

-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkChar;

-(BOOL) checkHeader:(NSRange) headerKeyword;

-(BOOL) checkIsNameValidChar: (unichar) character;

+(NSString*) getExtentionsStr;

+(NSString*) getSingleLineCommentsStr;

+(NSString*) getMultiLineCommentsStartStr;

+(NSString*) getMultiLineCommentsEndStr;

+(NSString*) getKeywordsStr;

@end
