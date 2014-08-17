//
//  HourChartControllerHelper.h
//  CodeNavigator
//
//  Created by Guozhen Li on 8/17/14.
//
//

#import <Foundation/Foundation.h>
#import "JBBarChartView.h"

@interface HourChartControllerHelper : NSObject <JBBarChartViewDelegate, JBBarChartViewDataSource>

@property (nonatomic, strong) NSString* currentProject;

-(void) initView:(UIView*) parentView andToolHeight:(int)height;

-(void) setHidden:(BOOL)hidden;

-(UIImage*) screenshot;

-(void) reloadData:(NSString*)project;

@end
