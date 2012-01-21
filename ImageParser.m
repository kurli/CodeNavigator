//
//  ImageParser.m
//  CodeNavigator
//
//  Created by Guozhen Li on 1/21/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "ImageParser.h"
#import "HTMLConst.h"

@implementation ImageParser

-(id) init
{
	if ( (self = [super init])!=nil )
	{
	}
	return self;
}

-(void) setFile:(NSString*)name andProjectBase:(NSString *)base
{
    fileContent = [name copy];
    htmlContent = [[NSMutableString alloc] init];
    projectBase = base;
}

-(BOOL) startParse
{
	if ( nil == fileContent )
    {
		return NO;
    }
	[self addHead];
    [self addImage:fileContent];
    [htmlContent appendString: HTML_END];
    [self addString:@"" addEnter:YES];
	return YES;
}
@end
