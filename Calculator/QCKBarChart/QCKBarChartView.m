//
//  QCKBarChartView.m
//  Calculator
//
//  Created by Emil Marashliev on 4/1/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import "QCKBarChartView.h"
#import "QCKBarView.h"

const CGFloat padding = 5.0f;
const CGFloat lineHeight = 4;
const CGFloat barWidthPersentage = 0.7;

@interface QCKBarChartView ()

@property (weak, nonatomic) id<QCKBarChartDataSource> dataSource;
@property (weak, nonatomic) id<QCKBarChartDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *barViews;

@end

@implementation QCKBarChartView

static CGFloat axisStartY;
static CGFloat sectionWidth;
static CGFloat barWidth;
static CGFloat valuePerUnit;

#pragma mark - Configuration

- (void)configureWithDataSource:(id<QCKBarChartDataSource>)dataSource delegate:(id<QCKBarChartDelegate>)delegate
{
    self.dataSource = dataSource;
    self.delegate = delegate;
    
    [self clearReusableViews];
}

- (NSMutableArray *)barViews
{
    if (!_barViews) {
        _barViews = [NSMutableArray array];
    }
    return _barViews;
}

- (void)calculateSizes
{
    axisStartY = self.frame.size.height - 2 * padding - lineHeight;
    sectionWidth = (self.frame.size.width - 3 * padding) / [self.dataSource numberOfBarsInBarChartView:self];
    barWidth = sectionWidth * barWidthPersentage;
    if ((int)(sectionWidth - barWidth) % 2 == 1) {
        barWidth++;
    }
    CGFloat maxValue = [self.dataSource maximumValueForBarChartView:self];
    valuePerUnit = (axisStartY - 3 * padding) / maxValue;
}

- (void)reloadDataAnimated:(BOOL)animated
{
    [self calculateSizes];
    [self placeBarViewsAnimated:animated];
}

#pragma mark - Bar views
- (void)placeBarViewsAnimated:(BOOL)animated
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger i = 0; i < [self.dataSource numberOfBarsInBarChartView:self]; i++) {
        [self addSubview:[self barViewForIndex:i]];
        CGFloat animationDuration = animated ? 0.8f : 0.0f;
        [UIView animateWithDuration:animationDuration animations:^{
            [self.barViews[i] setFrame:[self frameForBarAtIndex:i]];
        }];
    }
}

- (CGRect)frameForBarAtIndex:(NSUInteger)index
{
    CGFloat barHeight = [self heightForBarAtIndex:index];
    CGRect barRect = [self.barViews[index] frame];
    barRect.origin.y -= barHeight;
    barRect.size.height = barHeight;
    
    return barRect;
}

- (CGFloat)heightForBarAtIndex:(NSUInteger)index
{
    return [self.dataSource barChartView:self valueForBarAtIndex:index] * valuePerUnit;
}

- (UIView *)barViewForIndex:(NSUInteger)index
{
    QCKBarView *barView = nil;
    if (index >= self.barViews.count) {
        barView = [[QCKBarView alloc] initWithIndex:index color:[UIColor purpleColor]];
        [barView addTarget:self action:@selector(didTapOnBar:) forControlEvents:UIControlEventTouchDown];
        [self.barViews addObject:barView];
    }
    
    barView = self.barViews[index];
    barView.frame = CGRectMake((sectionWidth - barWidth) / 2 + index * sectionWidth + padding, axisStartY - 1, barWidth, 0);
    
    return barView;
}

- (void)didTapOnBar:(QCKBarView *)bar
{
    [self.delegate barChartView:self didSelectBarView:bar];
}

- (void)clearReusableViews
{
    while (self.barViews.count > [self.dataSource numberOfBarsInBarChartView:self]) {
        [self.barViews removeLastObject];
    }
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawCoordinateAxisInRect:CGRectMake(padding, padding, rect.size.width - 2 * padding, rect.size.height - 2 * padding) withContext:context];
    [self drawVerticalArrowInRect:CGRectMake(padding / 2, padding, padding, padding) toTop:YES withContext:context];
    [self drawHorizontalArrowInRect:CGRectMake(self.frame.size.width - 2*padding, axisStartY - padding / 2, padding, padding) toLeft:YES withContext:context];
}

- (void)drawCoordinateAxisInRect:(CGRect)rect withContext:(CGContextRef)context
{
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x, axisStartY);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, axisStartY);
    
    NSInteger valuesCount = [self.dataSource numberOfBarsInBarChartView:self];
    for (NSInteger i = 1; i <= valuesCount; i++) {
        if (i != valuesCount) {
            CGContextMoveToPoint(context, rect.origin.x + i * sectionWidth, axisStartY - (lineHeight / 2));
            CGContextAddLineToPoint(context, rect.origin.x + i * sectionWidth, axisStartY + lineHeight);
        }
        
        id title = [self.dataSource barChartView:self titleForBarAtIndex:i - 1];
        [title drawInRect:CGRectMake(rect.origin.x + (i - 1) * sectionWidth, axisStartY, sectionWidth, padding) withFont:[UIFont fontWithName:@"Helvetica-Light" size:10.f] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
    
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    CGContextStrokePath(context);
}

- (void)drawVerticalArrowInRect:(CGRect)rect toTop:(BOOL)toTop withContext:(CGContextRef)context
{
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + toTop * rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x + (rect.size.width / 2), rect.origin.y + !toTop * rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + toTop * rect.size.height);
    
    CGContextStrokePath(context);
}

- (void)drawHorizontalArrowInRect:(CGRect)rect toLeft:(BOOL)toLeft withContext:(CGContextRef)context
{
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, rect.origin.x + !toLeft * rect.size.width, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + toLeft *rect.size.width, rect.origin.y + (rect.size.height / 2));
    CGContextAddLineToPoint(context, rect.origin.x + !toLeft * rect.size.width, rect.origin.y + rect.size.height);
    
    CGContextStrokePath(context);
}

- (void)layoutSubviews
{
    [self reloadDataAnimated:YES];
    [super layoutSubviews];
    [self setNeedsDisplay];
}

@end
