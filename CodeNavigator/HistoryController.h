//
//  HistoryController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryController : NSObject
{
    NSMutableArray *historyStack;
    NSUInteger index;
}

@property (strong, nonatomic) NSMutableArray* historyStack;

-(void) pushUrl:(NSString*) url;

-(NSString*) popUrl;

-(NSString*) getNextUrl;

-(void) updateCurrentScrollLocation:(int)location;

-(NSString*) pickTopLevelUrl;

-(int) getLocationFromHistoryFormat:(NSString*)content;

-(NSString*) getUrlFromHistoryFormat:(NSString*)content;

-(NSUInteger) getCount;

-(NSUInteger) getCurrentDisplayIndex;

-(NSString*) getPathByIndex:(NSInteger)i;

-(void) setIndex:(NSInteger)i;

+(void) writeToFile;

-(void) readFromFile:(NSString*) filePath;

@end
