//
//  DayChartControllerHelper.h
//  DBTest
//
//  Created by Guozhen Li on 8/8/14.
//  Copyright (c) 2014 Guangzhen Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DayChartControllerHelper : NSObject

@property (nonatomic, strong) NSString* currentProject;

-(void) initView:(UIView*) parentView andToolHeight:(int)height andLabel:(UILabel*)codeNavigatorLabel;

-(void) setHidden:(BOOL)hidden;

-(UIImage*) screenshot;

-(void) reloadData:(NSString*)project;

@end
