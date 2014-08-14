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

// Numerics
CGFloat const kJBBarChartViewControllerChartHeight = 250.0f;
CGFloat const kJBBarChartViewControllerChartPadding = 10.0f;
CGFloat const kJBBarChartViewControllerChartHeaderHeight = 80.0f;
CGFloat const kJBBarChartViewControllerChartHeaderPadding = 10.0f;
CGFloat const kJBBarChartViewControllerChartFooterHeight = 25.0f;
CGFloat const kJBBarChartViewControllerChartFooterPadding = 5.0f;
NSUInteger kJBBarChartViewControllerBarPadding = 1;
NSInteger const kJBBarChartViewControllerNumBars = 7;
NSInteger const kJBBarChartViewControllerMaxBarHeight = 10;
NSInteger const kJBBarChartViewControllerMinBarHeight = 5;

@interface WeekChartControllerHelper()

@property (nonatomic, strong) JBBarChartView *barChartView;
@property (nonatomic, strong) JBChartInformationView *informationView;
@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *weeklySymbols;
@property (nonatomic, strong) UIView* parentView;

@end

@implementation WeekChartControllerHelper

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initData];
    }
    return self;
}

-(void) initData {
    self.chartData = [[Utils getInstance].dbManager getUsageTimeForWeek:nil];
    self.weeklySymbols = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
}

-(void) initView:(UIView*) parentView andToolHeight:(int)height andLabel:(UILabel*)codeNavigatorLabel {
    self.parentView = parentView;
    
    parentView.backgroundColor = kJBColorBarChartControllerBackground;
    
    self.barChartView = [[JBBarChartView alloc] init];
    self.barChartView.frame = CGRectMake(kJBBarChartViewControllerChartPadding, height + kJBBarChartViewControllerChartPadding, parentView.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2), kJBBarChartViewControllerChartHeight);
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    self.barChartView.headerPadding = kJBBarChartViewControllerChartHeaderPadding;
    self.barChartView.minimumValue = 0.0f;
    self.barChartView.backgroundColor = kJBColorBarChartBackground;
    
    JBChartHeaderView *headerView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kJBBarChartViewControllerChartPadding, ceil(parentView.bounds.size.height * 0.5) - ceil(kJBBarChartViewControllerChartHeaderHeight * 0.5) + height, parentView.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2), kJBBarChartViewControllerChartHeaderHeight)];
//    headerView.titleLabel.text = [kJBStringLabelAverageMonthlyTemperature uppercaseString];
    headerView.titleLabel.text = @"Weekly Usage";
    headerView.subtitleLabel.text = @"";
    headerView.separatorColor = kJBColorBarChartHeaderSeparatorColor;
    self.barChartView.headerView = headerView;
    
    JBBarChartFooterView *footerView = [[JBBarChartFooterView alloc] initWithFrame:CGRectMake(kJBBarChartViewControllerChartPadding, ceil(parentView.bounds.size.height * 0.5) - ceil(kJBBarChartViewControllerChartFooterHeight * 0.5) + height, parentView.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2), kJBBarChartViewControllerChartFooterHeight)];
    footerView.padding = kJBBarChartViewControllerChartFooterPadding;
    footerView.leftLabel.text = [[self.weeklySymbols firstObject] uppercaseString];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [[self.weeklySymbols lastObject] uppercaseString];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    self.barChartView.footerView = footerView;
    
    self.informationView = [[JBChartInformationView alloc] initWithFrame:CGRectMake(parentView.bounds.origin.x, CGRectGetMaxY(self.barChartView.frame) , parentView.bounds.size.width, parentView.bounds.size.height - height - CGRectGetMaxY(self.barChartView.frame) - (80))];
    [parentView addSubview:self.informationView];
    
    CGRect rect = codeNavigatorLabel.frame;
    rect.origin.x = 10;
    rect.origin.y = parentView.frame.size.height - rect.size.height - 10;
    [codeNavigatorLabel setFrame:rect];
    [parentView addSubview:codeNavigatorLabel];
    
    [parentView addSubview:self.barChartView];
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
    return kJBBarChartViewControllerNumBars;
}

- (NSUInteger)barPaddingForBarChartView:(JBBarChartView *)barChartView
{
    return kJBBarChartViewControllerBarPadding;
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
        [str appendFormat:@"%ldh ", hour];
    }
    if (minute > 0) {
        [str appendFormat:@"%ldm ", minute];
    }
    if (second > 0) {
        [str appendFormat:@"%lds", second];
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
