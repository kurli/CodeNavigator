//
//  DayChartControllerHelper.m
//  DBTest
//
//  Created by Guozhen Li on 8/8/14.
//  Copyright (c) 2014 Guangzhen Li. All rights reserved.
//

#import "DayChartControllerHelper.h"

// Views
#import "JBLineChartView.h"
#import "JBChartHeaderView.h"
#import "JBLineChartFooterView.h"
#import "JBChartInformationView.h"
#import "JBColorConstants.h"
#import "JBConstants.h"
#import "SAVideoRangeSlider.h"
#import "Utils.h"

#define ARC4RANDOM_MAX 0x100000000

// Numerics
CGFloat const kJBLineChartViewControllerChartHeight = 250.0f;
CGFloat const kJBLineChartViewControllerChartPadding = 10.0f;
CGFloat const kJBLineChartViewControllerChartHeaderHeight = 75.0f;
CGFloat const kJBLineChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBLineChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kJBLineChartViewControllerChartSolidLineWidth = 6.0f;
CGFloat const kJBLineChartViewControllerChartDashedLineWidth = 2.0f;
NSInteger const kJBLineChartViewControllerMaxNumChartPoints = 7;

@interface DayChartControllerHelper () <JBLineChartViewDelegate, JBLineChartViewDataSource, SAVideoRangeSliderDelegate>

@property (nonatomic, strong) JBLineChartView *lineChartView;
@property (nonatomic, strong) JBChartInformationView *informationView;
@property (nonatomic, strong) SAVideoRangeSlider* rangeSlider;
@property (nonatomic, strong) NSArray *daysArray;
@property (nonatomic, strong) NSDictionary *dbData;
@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;
@property (nonatomic, strong) NSDate* earlistDate;
@property (nonatomic, strong) NSDate* minStartDate;
@property (nonatomic, strong) NSDate* maxEndDate;
@property (nonatomic, strong) UIView* parentView;

// Helpers
- (void)initData;

@end

@implementation DayChartControllerHelper

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initData];
    }
    return self;
}

-(NSDate*) dateToDay:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate* date2 = [dateFormatter dateFromString:strDate];
    return date2;
}

-(void) initData {
    DBManager* dbManager = [Utils getInstance].dbManager;

    self.endDate = [self dateToDay:[NSDate date]];
    self.startDate = [self.endDate dateByAddingTimeInterval:-6*24*60*60];
    
    self.earlistDate = [self dateToDay:[dbManager getFirstRecordDay]];
    
    if (self.startDate < self.earlistDate) {
        if (self.endDate == self.earlistDate) {
            self.startDate = [self.earlistDate dateByAddingTimeInterval:-24*60*60];
        } else {
            self.startDate = self.earlistDate;
        }
    }

    self.maxEndDate = self.endDate;
    self.minStartDate = self.startDate;

    [self refreshCharView];
//    NSArray* array = [self.dbData allKeys];
//    self.daysArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        NSData* date1 = obj1;
//        NSData* date2 = obj2;
//        return date1 > date2;
//    }];
}

-(void) refreshCharView {
    DBManager* dbManager = [Utils getInstance].dbManager;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSInteger interval = [self.endDate timeIntervalSinceReferenceDate] - [self.startDate timeIntervalSinceReferenceDate];
    interval = interval/60/60/24;
    for (int i=0; i<=interval; i++) {
        NSData* date = [self.startDate dateByAddingTimeInterval:24*60*60*i];
        [array addObject:date];
    }
    self.daysArray = array;
    
    self.dbData = [dbManager getUsageTimePerDay:self.startDate andEnd:[self.endDate dateByAddingTimeInterval:24*60*60] andProject:nil];
    [self.lineChartView reloadData];
}

-(NSString*) dateToString:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

#define MAX_DISTANCE 30*24*60*60

-(void) caculateMinMaxDates {
    NSDate* tmp = [self.startDate dateByAddingTimeInterval:-MAX_DISTANCE];
    int a = [self.earlistDate timeIntervalSinceReferenceDate];
    int b = [tmp timeIntervalSinceReferenceDate];
    if (a >= b) {
        if (self.endDate == self.earlistDate) {
            self.minStartDate = [self.earlistDate dateByAddingTimeInterval:-24*60*60];
        } else {
            self.minStartDate = self.earlistDate;
        }
    } else {
        self.minStartDate = tmp;
    }
    
    tmp = [self.endDate dateByAddingTimeInterval:MAX_DISTANCE];
    a = [[NSDate dateWithTimeIntervalSinceNow:24*60*60] timeIntervalSinceReferenceDate];
    b = [tmp timeIntervalSinceReferenceDate];
    if (a <= b) {
        self.maxEndDate = [self dateToDay:[NSDate date]];
    } else {
        self.maxEndDate = tmp;
    }
    
    NSInteger interval = [self.maxEndDate timeIntervalSinceDate:self.minStartDate];
    [self.rangeSlider setDurationSeconds:interval];
    interval = [self.startDate timeIntervalSinceDate:self.minStartDate];
    [self.rangeSlider setStartSecond:interval];
    interval = [self.endDate timeIntervalSinceDate:self.minStartDate];
    [self.rangeSlider setEndSecond:interval];
    [self.rangeSlider setStartDate:self.minStartDate];
    
//    [self debugLog];
}

-(void) initView:(UIView*) parentView andToolHeight:(int)height andLabel:(UILabel*)codeNavigatorLabel {
    self.parentView = parentView;
    parentView.backgroundColor = kJBColorBarChartControllerBackground;
    
    self.lineChartView = [[JBLineChartView alloc] init];
    self.lineChartView.frame = CGRectMake(kJBLineChartViewControllerChartPadding, kJBLineChartViewControllerChartPadding + height, parentView.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartHeight);
    self.lineChartView.delegate = self;
    self.lineChartView.dataSource = self;
    self.lineChartView.headerPadding = kJBLineChartViewControllerChartHeaderPadding;
    self.lineChartView.backgroundColor = kJBColorBarChartBackground;
    
    JBChartHeaderView *headerView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, ceil(parentView.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartHeaderHeight * 0.5) + height, parentView.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartHeaderHeight)];
    headerView.titleLabel.text = @"Usage per days";
//    headerView.titleLabel.textColor = kJBColorBarChartHeaderSeparatorColor;
//    headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
//    headerView.titleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.subtitleLabel.text = @"";
//    headerView.subtitleLabel.textColor = kJBColorBarChartHeaderSeparatorColor;
//    headerView.subtitleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
//    headerView.subtitleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.separatorColor = kJBColorBarChartHeaderSeparatorColor;
    self.lineChartView.headerView = headerView;
    
    JBLineChartFooterView *footerView = [[JBLineChartFooterView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, ceil(parentView.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5) + height, parentView.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartFooterHeight)];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.leftLabel.text = [self dateToString:[self.daysArray firstObject]];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [self dateToString:[self.daysArray lastObject]];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    footerView.sectionCount = [self.daysArray count];
    self.lineChartView.footerView = footerView;
    
    [parentView addSubview:self.lineChartView];
    
    
    CGRect rect = self.lineChartView.frame;
    rect.origin.y = rect.origin.y + rect.size.height + 10;
    rect.size.height = 30;
    self.rangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:rect videoUrl:nil ];
    [self caculateMinMaxDates];
    
    
    [self.rangeSlider setPopoverBubbleSize:rect.size.width/3 height:80];
    self.rangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.945 green: 0.945 blue: 0.945 alpha: 1];
    self.rangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.806 green: 0.806 blue: 0.806 alpha: 1];
    self.rangeSlider.delegate = self;
    
    [parentView addSubview:self.rangeSlider];
    
    
    self.informationView = [[JBChartInformationView alloc] initWithFrame:CGRectMake(parentView.bounds.origin.x, CGRectGetMaxY(self.rangeSlider.frame), parentView.bounds.size.width, parentView.bounds.size.height - height - CGRectGetMaxY(self.lineChartView.frame) - (20))];
    [self.informationView setValueAndUnitTextColor:[UIColor colorWithWhite:1.0 alpha:0.75]];
//    [self.informationView setTitleTextColor:kJBColorBarChartHeaderSeparatorColor];
    [self.informationView setTextShadowColor:nil];
    [self.informationView setSeparatorColor:kJBColorBarChartHeaderSeparatorColor];
    [parentView addSubview:self.informationView];
    
    rect = codeNavigatorLabel.frame;
    rect.origin.x = 10;
    rect.origin.y = parentView.frame.size.height - rect.size.height - 10;
    [codeNavigatorLabel setFrame:rect];
    [parentView addSubview:codeNavigatorLabel];
    
    [self.lineChartView reloadData];
    
    [self displayTotal];
}

-(void) displayTotal {
    NSInteger start = [self.startDate timeIntervalSinceReferenceDate];
    NSInteger end = [self.endDate timeIntervalSinceReferenceDate];
    NSInteger total = 0;
    for (NSInteger i=start; i<=end; i+=24*60*60) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceReferenceDate:i];
        NSNumber* number = [self.dbData objectForKey:date];
        total += [number intValue];
    }
    
    NSString* str = [self secondsToReadableStr:total];
    [self.informationView setValueText:str unitText:@""];
    [self.informationView setTitleText:[NSString stringWithFormat:@"%@--%@", [self dateToString:self.startDate], [self dateToString:self.endDate]]];
    [self.informationView setHidden:NO animated:YES];
}

#pragma mark - JBLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    NSDate* date = [self.daysArray objectAtIndex:horizontalIndex];
    NSNumber* number = (NSNumber*)[self.dbData objectForKey:date];
    return [number floatValue];
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

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    NSDate* date = [self.daysArray objectAtIndex:horizontalIndex];
    NSNumber* valueNumber = (NSNumber*)[self.dbData objectForKey:date];
    NSString* str = [self secondsToReadableStr:[valueNumber intValue]];
    [self.informationView setValueText:str unitText:@""];
//    [self.informationView setTitleText:lineIndex == JBLineChartLineSolid ? kJBStringLabelMetropolitanAverage : kJBStringLabelNationalAverage];
    [self.informationView setTitleText:[self dateToString:date]];
    [self.informationView setHidden:NO animated:YES];
//    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
//    [self.tooltipView setText:[[self.daysOfWeek objectAtIndex:horizontalIndex] uppercaseString]];
}

- (void)didUnselectLineInLineChartView:(JBLineChartView *)lineChartView
{
//    [self.informationView setHidden:YES animated:YES];
//    [self setTooltipVisible:NO animated:YES];
    [self displayTotal];
}

#pragma mark - JBLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 1;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [self.daysArray count];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
//    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidLineColor: kJBColorLineChartDefaultDashedLineColor;
    return kJBColorLineChartDefaultSolidLineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
//    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidLineColor: kJBColorLineChartDefaultDashedLineColor;
    return kJBColorLineChartDefaultSolidLineColor;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
//    return (lineIndex == JBLineChartLineSolid) ? kJBLineChartViewControllerChartSolidLineWidth: kJBLineChartViewControllerChartDashedLineWidth;
    return kJBLineChartViewControllerChartDashedLineWidth;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex
{
//    return (lineIndex == JBLineChartLineSolid) ? 0.0: (kJBLineChartViewControllerChartDashedLineWidth * 4);
    return 0;
}

- (UIColor *)verticalSelectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor whiteColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
//    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidSelectedLineColor: kJBColorLineChartDefaultDashedSelectedLineColor;
    return kJBColorLineChartDefaultSolidSelectedLineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
//    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidSelectedLineColor: kJBColorLineChartDefaultDashedSelectedLineColor;
    return kJBColorLineChartDefaultSolidSelectedLineColor;
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
//    return (lineIndex == JBLineChartLineSolid) ? JBLineChartViewLineStyleSolid : JBLineChartViewLineStyleDashed;
    return JBLineChartViewLineStyleSolid;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == JBLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == JBLineChartViewLineStyleSolid;
}

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(int)leftPosition rightPosition:(int)rightPosition {
}

- (void)videoRange:(SAVideoRangeSlider *)videoRange didGestureStateEndedLeftPosition:(int)leftPosition rightPosition:(int)rightPosition {
    JBLineChartFooterView *footerView = (JBLineChartFooterView*)self.lineChartView.footerView;
    self.startDate = [self dateToDay:[self.minStartDate dateByAddingTimeInterval:leftPosition]];
    self.endDate = [self dateToDay:[self.minStartDate dateByAddingTimeInterval:rightPosition]];
    
    if (self.startDate == self.endDate) {
        if (self.startDate == self.minStartDate) {
            self.endDate = [self.endDate dateByAddingTimeInterval:24*60*60];
        } else if (self.startDate == self.maxEndDate) {
            self.startDate = [self.startDate dateByAddingTimeInterval:-24*60*60];
        } else {
            self.endDate = [self.startDate dateByAddingTimeInterval:24*60*60];
        }
    }
    
    [self refreshCharView];
    footerView.leftLabel.text = [self dateToString:self.startDate];
    footerView.rightLabel.text = [self dateToString:self.endDate];
    footerView.sectionCount = [self.daysArray count];
    
    [self caculateMinMaxDates];

    [self.rangeSlider setNeedsLayout];
    [self displayTotal];
}

//-(void) debugLog {
//    NSLog(@"\nminStart\t%@\nstartDate\t%@\nendDate\t\t%@\nmaxEnd\t\t%@", self.minStartDate, self.startDate, self.endDate, self.maxEndDate);
//    NSLog(@"-------");
//}

-(void) setHidden:(BOOL)hidden {
    [self.informationView setHidden:hidden animated:YES];
    if (hidden) {
        [self.lineChartView setState:JBChartViewStateCollapsed animated:NO];
    } else {
        [self.lineChartView setState:JBChartViewStateExpanded animated:YES];
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
