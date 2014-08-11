//
//  JBChartView.m
//  Nudge
//
//  Created by Terry Worona on 9/4/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "JBChartView.h"

// Numerics
CGFloat const kJBChartViewDefaultAnimationDuration = 0.25f;

// Color (JBChartSelectionView)
static UIColor *kJBChartVerticalSelectionViewDefaultBgColor = nil;

@interface JBChartView ()

@property (nonatomic, assign) BOOL hasMaximumValue;
@property (nonatomic, assign) BOOL hasMinimumValue;

// Construction
- (void)constructChartView;

// Validation
- (void)validateHeaderAndFooterHeights;

@end

@implementation JBChartView

#pragma mark - Alloc/Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self constructChartView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self constructChartView];
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

#pragma mark - Construction

- (void)constructChartView
{
    self.clipsToBounds = YES;
}

#pragma mark - Public

- (void)reloadData
{
    // Override
}

#pragma mark - Validation

- (void)validateHeaderAndFooterHeights
{
    NSAssert((self.headerView.bounds.size.height + self.footerView.bounds.size.height) <= self.bounds.size.height, @"JBChartView // the combined height of the footer and header can not be greater than the total height of the chart.");
}

#pragma mark - Setters

- (void)setHeaderView:(UIView *)headerView
{
    if (_headerView)
    {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
    _headerView = headerView;
    _headerView.clipsToBounds = YES;
    
    [self validateHeaderAndFooterHeights];
    
    [self addSubview:_headerView];
    [self reloadData];
}

- (void)setFooterView:(UIView *)footerView
{
    if (_footerView)
    {
        [_footerView removeFromSuperview];
        _footerView = nil;
    }
    _footerView = footerView;
    _footerView.clipsToBounds = YES;
    
    [self validateHeaderAndFooterHeights];
    
    [self addSubview:_footerView];
    [self reloadData];
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
    return str;
}

- (void)showMaxValue:(NSInteger)normolizedHeight andValue:(NSInteger)value {
    if (self.maxValueLabel == nil) {
        self.maxValueLabel = [[UILabel alloc] init];
        self.maxValueLabel.adjustsFontSizeToFitWidth = YES;
        self.maxValueLabel.textAlignment = NSTextAlignmentLeft;
        self.maxValueLabel.shadowColor = [UIColor blackColor];
        self.maxValueLabel.shadowOffset = CGSizeMake(0, 1);
        self.maxValueLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.maxValueLabel];
        CGRect rect = self.frame;
        rect.size.height = self.footerView.frame.size.height;
        [self.maxValueLabel setFrame:rect];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        self.maxValueLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Test string"
                                                                 attributes:underlineAttribute];
        self.maxValueLabel.textColor = [UIColor whiteColor];
        self.separatorView = [[UIView alloc] init];
        self.separatorView.backgroundColor = [UIColor grayColor];
        [self addSubview:self.separatorView];
        rect = CGRectMake(0, 0, self.frame.size.width, 1);
        [self.separatorView setFrame:rect];
        [self.separatorView setHidden:YES];
    }
    if (value == 0) {
        [self.maxValueLabel setHidden:YES];
        [self.separatorView setHidden:YES];
    } else {
        NSString* valueStr = [self secondsToReadableStr:value];
        self.maxValueLabel.text = valueStr;
        [self.maxValueLabel setHidden:NO];
        CGRect rect = self.maxValueLabel.frame;
        rect.size.height = self.footerView.frame.size.height;
        rect.origin.y = self.footerView.frame.origin.y- normolizedHeight - rect.size.height;
        [self.maxValueLabel setFrame:rect];
        self.maxValueLabel.text = valueStr;
        [self.separatorView setHidden:NO];
        rect = self.separatorView.frame;
        rect.origin.y = self.maxValueLabel.frame.origin.y + self.maxValueLabel.frame.size.height;
        [self.separatorView setFrame:rect];
    }
}

- (void)setState:(JBChartViewState)state animated:(BOOL)animated callback:(void (^)())callback force:(BOOL)force
{
    if ((_state == state) && !force)
    {
        return;
    }
    
    _state = state;
    
    // Override
}

- (void)setState:(JBChartViewState)state animated:(BOOL)animated callback:(void (^)())callback
{
    [self setState:state animated:animated callback:callback force:NO];
}

- (void)setState:(JBChartViewState)state animated:(BOOL)animated
{
    [self setState:state animated:animated callback:nil];
}

- (void)setState:(JBChartViewState)state
{
    [self setState:state animated:NO];
}

- (void)setMinimumValue:(CGFloat)minimumValue
{
    NSAssert(minimumValue >= 0, @"JBChartView // the minimumValue must be >= 0.");
    _minimumValue = minimumValue;
    _hasMinimumValue = YES;
}

- (void)setMaximumValue:(CGFloat)maximumValue
{
    NSAssert(maximumValue >= 0, @"JBChartView // the maximumValue must be >= 0.");
    _maximumValue = maximumValue;
    _hasMaximumValue = YES;
}

- (void)resetMinimumValue
{
    _hasMinimumValue = NO; // clears min
}

- (void)resetMaximumValue
{
    _hasMaximumValue = NO; // clears max
}

@end

@implementation JBChartVerticalSelectionView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [JBChartVerticalSelectionView class])
	{
		kJBChartVerticalSelectionViewDefaultBgColor = [UIColor whiteColor];
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] set];
    CGContextFillRect(context, rect);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = nil;
    if (self.bgColor != nil)
    {
        colors = @[(__bridge id)self.bgColor.CGColor, (__bridge id)[self.bgColor colorWithAlphaComponent:0.0].CGColor];
    }
    else
    {
        colors = @[(__bridge id)kJBChartVerticalSelectionViewDefaultBgColor.CGColor, (__bridge id)[kJBChartVerticalSelectionViewDefaultBgColor colorWithAlphaComponent:0.0].CGColor];
    }
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    
    CGContextSaveGState(context);
    {
        CGContextAddRect(context, rect);
        CGContextClip(context);
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    }
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

#pragma mark - Setters

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    [self setNeedsDisplay];
}

@end
