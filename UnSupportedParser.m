//
//  UnSupportedParser.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UnSupportedParser.h"

@implementation UnSupportedParser

-(id) init
{
	if ( (self = [super init])!=nil )
	{
	}
	return self;
}

-(void) parseLine: (NSString*) line lineNum:(int)lineNumber
{
	// if a blank line
	if ( [line length] == 0 )
    {
		[self addBlankLine];
		return;
    }
    [self addUnknownLine:line];
}

@end
