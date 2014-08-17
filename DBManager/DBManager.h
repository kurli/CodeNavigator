//
//  DBManager.h
//  DBTest
//
//  Created by Guozhen Li on 7/31/14.
//  Copyright (c) 2014 Guangzhen Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

-(void) appStarted:(NSDate*) date;
-(void) appEnded:(NSDate*) date;
-(void) startRecord:(NSString*)project andTime:(NSDate*)date;


-(NSArray*) getUsageTimeForWeek:(NSString*)project;
-(NSDictionary*) getUsageTimePerDay:(NSDate*)from andEnd:(NSDate*)end andProject:(NSString*)project;
-(NSDate*) getFirstRecordDay;
-(NSArray*) getAllProjects;
-(NSArray*) getUsageTimePerHour:(NSString*)project;

@end