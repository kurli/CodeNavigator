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
    int index;
}

@property (retain, nonatomic) NSMutableArray* historyStack;

-(void) pushUrl:(NSString*) url;

-(NSString*) popUrl;

-(NSString*) getNextUrl;

-(void) updateCurrentScrollLocation:(int)location;

-(NSString*) pickTopLevelUrl;

@end
