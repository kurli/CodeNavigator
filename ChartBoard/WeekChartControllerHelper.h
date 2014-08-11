//
//  WeekChartControllerHelper.h
//  DBTest
//
//  Created by Guozhen Li on 8/7/14.
//  Copyright (c) 2014 Guangzhen Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBBarChartView.h"

@interface WeekChartControllerHelper : NSObject <JBBarChartViewDelegate, JBBarChartViewDataSource>

-(void) initView:(UIView*) parentView andToolHeight:(int)height;

-(void) setHidden:(BOOL)hidden;

@end
