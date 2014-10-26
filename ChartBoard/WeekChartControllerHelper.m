//
//  WeekChartControllerHelper.m
//  DBTest
//
//  Created by Guozhen Li on 8/7/14.
//  Copyright (c) 2014 Guangzhen Li. All rights reserved.
//

#import "WeekChartControllerHelper.h"

#import "JBConstants.h"
#import "JBColorConstants.h"
#import "JBChartHeaderView.h"
#import "JBBarChartFooterView.h"
#import "JBChartInformationView.h"
#import "Utils.h"

#define TITLE_ALL @"Weekly Usage"

// Numerics
CGFloat const kHourControllerChartHeight = 250.0f;
CGFloat const kHourControllerChartPadding = 10.0f;
CGFloat const kHourControllerChartHeaderHeight = 80.0f;
CGFloat const kHourControllerChartHeaderPadding = 10.0f;
CGFloat const kHourControllerChartFooterHeight = 25.0f;
CGFloat const kHourControllerChartFooterPadding = 5.0f;

@interface WeekChartControllerHelper()

@property (nonatomic, strong) JBBarChartView *barChartView;
@property (nonatomic, strong) JBChartInformationView *informationView;
@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *weeklySymbols;
@property (nonatomic, strong) UIView* parentView;
@property (nonatomic, strong) JBChartHeaderView* headerView;

@end

@implementation WeekChartControllerHelper

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initData:nil];
    }
    return self;
}

-(void) initData:(NSString*)project {
    self.chartData = [[Utils getInstance].dbManager getUsageTimeForWeek:project];
    self.weeklySymbols = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
    self.currentProject = project;
}

-(void) reloadData:(NSString*)project {
    [self initData:project];
    if (project == nil) {
        self.headerView.titleLabel.text = TITLE_ALL;
    } else {
        self.headerView.titleLabel.text = project;
    }
    [self.barChartView reloadData];
    [self displayTotal];
}

-(void) initView:(UIView*) parentView andToolHeight:(int)height {
    self.parentView = parentView;
    
    parentView.backgroundColor = kJBColorBarChartControllerBackground;
    
    self.barChartView = [[JBBarChartView alloc] init];
    self.barChartView.frame = CGRectMake(kHourControllerChartPadding, height + kHourControllerChartPadding, parentView.bounds.size.width - (kHourControllerChartPadding * 2), kHourControllerChartHeight);
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    self.barChartView.headerPadding = kHourControllerChartHeaderPadding;
    self.barChartView.minimumValue = 0.0f;
    self.barChartView.backgroundColor = kJBColorBarChartBackground;
    
    self.headerView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kHourControllerChartPadding, ceil(parentView.bounds.size.height * 0.5) - ceil(kHourControllerChartHeaderHeight * 0.5) + height, parentView.bounds.size.width - (kHourControllerChartPadding * 2), kHourControllerChartHeaderHeight)];
//    headerView.titleLabel.text = [kJBStringLabelAverageMonthlyTemperature uppercaseString];
    self.headerView.titleLabel.text = TITLE_ALL;
    self.headerView.subtitleLabel.text = @"";
    self.headerView.separatorColor = kJBColorBarChartHeaderSeparatorColor;
    self.barChartView.headerView = self.headerView;
    
    JBBarChartFooterView *footerView = [[JBBarChartFooterView alloc] initWithFrame:CGRectMake(kHourControllerChartPadding, ceil(parentView.bounds.size.height * 0.5) - ceil(kHourControllerChartFooterHeight * 0.5) + height, parentView.bounds.size.width - (kHourControllerChartPadding * 2), kHourControllerChartFooterHeight)];
    footerView.padding = kHourControllerChartFooterPadding;
    footerView.leftLabel.text = [[self.weeklySymbols firstObject] uppercaseString];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [[self.weeklySymbols lastObject] uppercaseString];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    self.barChartView.footerView = footerView;
    
    self.informationView = [[JBChartInformationView alloc] initWithFrame:CGRectMake(parentView.bounds.origin.x, CGRectGetMaxY(self.barChartView.frame) , parentView.bounds.size.width, parentView.bounds.size.height - height - CGRectGetMaxY(self.barChartView.frame) - (80))];
    [parentView addSubview:self.informationView];
    
    [parentView addSubview:self.barChartView];
    
    UILabel* customLabel = [[UILabel alloc] init];
    UIFont *font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:15.0f];
    [customLabel setFont:font];
    customLabel.adjustsFontSizeToFitWidth = NO;
    customLabel.textAlignment = NSTextAlignmentLeft;
    customLabel.opaque = NO;
    customLabel.backgroundColor = [UIColor clearColor];
    customLabel.textColor = [UIColor lightGrayColor];
#ifdef IPHONE_VERSION
    customLabel.frame = CGRectMake(10, parentView.frame.size.height - 20, 300, 20);
    customLabel.text = @"By CodeNavigator on iPhone";
#else
    customLabel.frame = CGRectMake(10, parentView.frame.size.height - 30, 300, 30);
    customLabel.text = @"By CodeNavigator on iPad";
#endif
    [parentView addSubview:customLabel];

    [self.barChartView reloadData];
    
    [self.barChartView setState:JBChartViewStateExpanded];
    [self displayTotal];
}

-(void) displayTotal {
    NSInteger total = 0;
    for (NSInteger i=0; i<[self.chartData count]; i++) {
        NSNumber* number = [self.chartData objectAtIndex:i];
        total += [number intValue];
    }
    
    NSString* str = [self secondsToReadableStr:total];
    [self.informationView setValueText:str unitText:@""];
    [self.informationView setTitleText:@"Total:"];
    [self.informationView setHidden:NO animated:YES];
}


#pragma mark - JBBarChartViewDelegate

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index
{
    return [[self.chartData objectAtIndex:index] floatValue];
}

#pragma mark - JBBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return 7;
}

- (NSUInteger)barPaddingForBarChartView:(JBBarChartView *)barChartView
{
    return 1;
}

- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    return (index % 2 == 0) ? kJBColorBarChartBarBlue : kJBColorBarChartBarGreen;
}

- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [UIColor whiteColor];
}

- (NSString*) secondsToReadableStr:(NSInteger)seconds {
    NSInteger hour = seconds / 60 / 60;
    seconds = seconds - hour * 3600;
    NSInteger minute = seconds / 60;
    seconds = seconds - minute * 60;
    NSInteger second = seconds;
    NSMutableString* str = [[NSMutableString alloc] init];
    if (hour > 0) {
        [str appendFormat:@"%dh ", hour];
    }
    if (minute > 0) {
        [str appendFormat:@"%dm ", minute];
    }
    if (second > 0) {
        [str appendFormat:@"%ds", second];
    }
    if ([str length] == 0) {
        return @"0";
    }
    return str;
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    NSNumber *valueNumber = [self.chartData objectAtIndex:index];
    NSString* str = [self secondsToReadableStr:[valueNumber intValue]];
    [self.informationView setValueText:str unitText:nil];
    NSArray* weekArray = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
    if (index <=6) {
        [self.informationView setTitleText:[weekArray objectAtIndex:index]];
        [self.informationView setHidden:NO animated:YES];
    }

//    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
//    [self.tooltipView setText:[[self.monthlySymbols objectAtIndex:index] uppercaseString]];
}

- (void)didUnselectBarChartView:(JBBarChartView *)barChartView
{
//    [self.informationView setHidden:YES animated:YES];
//    [self setTooltipVisible:NO animated:YES];
    [self displayTotal];
}

-(void) setHidden:(BOOL)hidden {
    [self.informationView setHidden:hidden animated:YES];
    if (hidden) {
        [self.barChartView setState:JBChartViewStateCollapsed animated:NO];
    } else {
        [self.barChartView setState:JBChartViewStateExpanded animated:YES];
    }
}

-(UIImage*) screenshot {
//    NSString  *pngPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
    UIImage* image = [self getImageFromView:self.parentView];
//    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    return image;
}

-(UIImage *)getImageFromView:(UIView *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
