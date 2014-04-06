//
//  QCKBarChartView.h
//  Calculator
//
//  Created by Emil Marashliev on 4/1/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QCKBarChartView;
@class QCKBarView;

@protocol QCKBarChartDataSource <NSObject>

- (NSString *)barChartView:(QCKBarChartView *)barChartView titleForBarAtIndex:(NSInteger)index;
- (CGFloat)barChartView:(QCKBarChartView *)barChartView valueForBarAtIndex:(NSInteger)index;
- (NSInteger)numberOfBarsInBarChartView:(QCKBarChartView *)barChartView;
- (CGFloat)maximumValueForBarChartView:(QCKBarChartView *)barChartView;

@end

@protocol QCKBarChartDelegate <NSObject>

- (void)barChartView:(QCKBarChartView*)barChartView didSelectBarView:(QCKBarView *)barView;

@end

@interface QCKBarChartView : UIView

- (void)configureWithDataSource:(id<QCKBarChartDataSource>)dataSource delegate:(id<QCKBarChartDelegate>)delegate;
- (void)reloadDataAnimated:(BOOL)animated;

@end
