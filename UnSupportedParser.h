//
//  UnSupportedParser.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeParser.h"
#import "CPlusPlusDefination.h"

@interface UnSupportedParser : CodeParser
{
	NSMutableString* needParseLine;
}

-(void) parseLine: (NSString*) line lineNum:(int)lineNumber;

@end
