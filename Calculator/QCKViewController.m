//
//  QCKViewController.m
//  Calculator
//
//  Created by Emil Marashliev on 3/28/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import "QCKViewController.h"
#import "QCKBarChartView.h"
#import "QCKBarView.h"

const CGFloat minimumAmount = 500;

@interface QCKViewController () <UITextFieldDelegate, QCKBarChartDataSource, QCKBarChartDelegate>

@property (assign, nonatomic) NSInteger year;
@property (assign, nonatomic) CGFloat devident;

@property (strong, nonatomic) NSArray *values;

@property (weak, nonatomic) IBOutlet QCKBarChartView *barChartView;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UILabel *earningsLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearsLabel;
@property (weak, nonatomic) IBOutlet UILabel *devidentLabel;
@property (weak, nonatomic) IBOutlet UISlider *yearSlider;
@property (weak, nonatomic) IBOutlet UISlider *devidentSlider;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *incomeParametersViewheight;

- (IBAction)yearsValueChanged:(id)sender;
- (IBAction)devidentValueChanged:(id)sender;

@end

@implementation QCKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.yearSlider addTarget:self
                        action:@selector(doCalculation)
              forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [self.devidentSlider addTarget:self
                            action:@selector(doCalculation)
                  forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    
    self.devident = self.devidentSlider.value;
    self.year = self.yearSlider.value;
    [self.barChartView configureWithDataSource:self delegate:self];
    
    [self doCalculation];
}

- (IBAction)yearsValueChanged:(UISlider *)sender
{
    self.year = (NSInteger)sender.value;
}

- (IBAction)devidentValueChanged:(UISlider *)sender
{
    self.devident = sender.value;
}

- (void)setDevident:(CGFloat)devident
{
    _devident = devident;
    self.devidentLabel.text = [NSString stringWithFormat:@"%.1f", devident];
}

- (void)setYear:(NSInteger)year
{
    _year = year;
    self.yearsLabel.text = [NSString stringWithFormat:@"%ld", (long)year];
}

- (void)doCalculation
{
    NSMutableArray *values = [NSMutableArray array];
    
    CGFloat startAmount = [self.amountTextField.text floatValue];
    
    for (NSInteger year = 0; year < self.year; year++) {
        CGFloat lastValue = year > 0 ? [values[year - 1] floatValue] : startAmount;
        [values addObject:@(lastValue + lastValue * (self.devident / 100))];
    }
    self.values = values;
    
    [self.barChartView reloadDataAnimated:YES];
}

#pragma mark - Text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.floatValue < minimumAmount ) {
        NSString *minimumAmountMessage = [NSString stringWithFormat:@"The minimum amount is %.0f.", minimumAmount];
        [[[UIAlertView alloc] initWithTitle:@"" message:minimumAmountMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    else {
        [textField resignFirstResponder];
        [self doCalculation];
        return YES;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeRight || toInterfaceOrientation == UIDeviceOrientationLandscapeLeft) {
        self.incomeParametersViewheight.constant = 0.f;
    }
}

#pragma mark - Bar chart view data source
- (NSInteger)numberOfBarsInBarChartView:(QCKBarChartView *)barChartView
{
    return self.year;
}

- (NSString *)barChartView:(QCKBarChartView *)barChartView titleForBarAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"%d", index + 1];
}

- (CGFloat)barChartView:(QCKBarChartView *)barChartView valueForBarAtIndex:(NSInteger)index
{
    return [self.values[index] floatValue];
}

- (CGFloat)maximumValueForBarChartView:(QCKBarChartView *)barChartView
{
    return [[self.values valueForKeyPath:@"@max.floatValue"] floatValue];
}

#pragma mark - Bar chart view delegate
- (void)barChartView:(QCKBarChartView *)barChartView didSelectBarView:(QCKBarView *)barView
{
    NSLog(@"Selected value is: %f", [self barChartView:barChartView valueForBarAtIndex:barView.index]);
}

- (void)barChartView:(QCKBarChartView *)barChartView didUpdateEarningAmountPercent:(CGFloat)earningAmountPercent
{
    [self.earningsLabel setText:[NSString stringWithFormat:@"%.2f%%",  earningAmountPercent]];
}

@end
