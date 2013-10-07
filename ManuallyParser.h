//
//  ManuallyParser.h
//  CodeNavigator
//
//  Created by Guozhen Li on 6/3/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "CodeParser.h"

@interface ManuallyParser : CodeParser

@property (nonatomic, strong) NSString* extensions;
@property (nonatomic, strong) NSString* singleLineComments;
@property (nonatomic, strong) NSString* multilineCommentsS;
@property (nonatomic, strong) NSString* multilineCommentsE;
@property (nonatomic, strong) NSString* keywords;
@property (nonatomic, strong) NSString* name;

-(BOOL) checkCommentsLine;

-(BOOL) checkPreprocessor:(int) lineNumber;

-(BOOL) checkString;

-(BOOL) checkOthers: (int)lineNumber;

-(BOOL) checkChar;

-(BOOL) checkIsNameValidChar: (unichar) character;

@end
