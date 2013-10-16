//
//  HtmlParser.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/17/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeParser.h"

@class JavaScriptParser;

@interface HtmlParser : CodeParser
{
    BOOL isInTag;
    BOOL isTagNameFound;
    BOOL isCodeInTagParseEnded;
}

@property (strong, nonatomic) NSString* lastTagName;
@property (strong, nonatomic) JavaScriptParser* jsParser;

-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkChar;

-(BOOL) checkHeader:(NSRange) headerKeyword;

-(BOOL) checkIsNameValidChar: (unichar) character;

@end
