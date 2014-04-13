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
#import "UIView+QCKView.h"
#import "UIColor+QCKColor.h"

const CGFloat minimumAmount = 500;

@interface QCKViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate, QCKBarChartDataSource, QCKBarChartDelegate>

@property (assign, nonatomic) NSInteger year;
@property (assign, nonatomic) CGFloat devident;

@property (strong, nonatomic) NSArray *values;

@property (weak, nonatomic) IBOutlet QCKBarChartView *barChartView;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UILabel *earningsLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearsLabel;
@property (weak, nonatomic) IBOutlet UILabel *devidentLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedBarValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *yearSlider;
@property (weak, nonatomic) IBOutlet UISlider *devidentSlider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlPanelHeightContraint;

- (IBAction)sliderValueChanged:(UISlider *)sender event:(id)event;

@end

@implementation QCKViewController

static CGFloat controlPanelDefaultHeight;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(dismissKeyboard)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];

    self.devident = self.devidentSlider.value;
    self.year = self.yearSlider.value;
    [self.barChartView configureWithDataSource:self delegate:self];
    
    self.selectedBarValueLabel.textColor = [UIColor purpleColor];
    [self doCalculation];
}

#pragma mark - Rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self dismissKeyboard];
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeRight ||
        toInterfaceOrientation == UIDeviceOrientationLandscapeLeft) {
        
        if (!controlPanelDefaultHeight) {
            controlPanelDefaultHeight = self.controlPanelHeightContraint.constant;
        }
        
        self.controlPanelHeightContraint.constant = 0.f;
    } else {
        self.controlPanelHeightContraint.constant = controlPanelDefaultHeight;
    }
}


#pragma mark - Actions
- (IBAction)sliderValueChanged:(UISlider *)sender event:(id)event
{
    if ([sender isEqual:self.yearSlider]) {
        self.year = (NSInteger)sender.value;
    }
    else if ([sender isEqual:self.devidentSlider]) {
        self.devident = sender.value;
    }
    UITouch *touchEvent = [[event allTouches] anyObject];
    if (touchEvent.phase == UITouchPhaseEnded) {
        [self doCalculation];
    }
}

#pragma mark - Setters
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

#pragma mark - Getters
- (CGFloat)initialAmount
{
    return [self.amountTextField.text floatValue];
}

- (CGFloat)maximumAmount
{
    return [[self.values valueForKeyPath:@"@max.floatValue"] floatValue];
}

#pragma mark - Validation
- (BOOL)validateAmoutValue
{
    if ([self  initialAmount] < minimumAmount ) {
        NSString *minimumAmountMessage = [NSString stringWithFormat:@"The minimum amount is %.0f.", minimumAmount];
        [[[UIAlertView alloc] initWithTitle:@"" message:minimumAmountMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

#pragma mark - Gesture recognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    [self dismissKeyboard];
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return self.amountTextField.isFirstResponder;
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
    return [self maximumAmount];
}

#pragma mark - Bar chart view delegate
- (void)barChartView:(QCKBarChartView *)barChartView didSelectBarView:(QCKBarView *)barView
{
    NSTimeInterval animationDuration = 0.5;
    
    [self.selectedBarValueLabel blinkViewWithShowBlock:^{
        [self.selectedBarValueLabel setText:[NSString stringWithFormat:@"%.2f", [self barChartView:barChartView valueForBarAtIndex:barView.index]]];
    } hideBlock:^{
        [self.selectedBarValueLabel setAlpha:0.0];
    } animationDuration:animationDuration];
    
    [barView blinkViewWithShowBlock:^{
        [barView setBackgroundColor:[barView.color lighterColor]];
    } hideBlock:^{
        [barView setBackgroundColor:barView.color];
    } animationDuration:animationDuration];
}

#pragma mark - UI uodtes
- (void)dismissKeyboard
{
    if (self.amountTextField.isFirstResponder) {
        [self doCalculation];
        [self.amountTextField resignFirstResponder];
    }
}

- (void)earningAmountPercentUpdated
{
    CGFloat earningAmountPercent =  (self.maximumAmount - self.initialAmount) / self.initialAmount * 100;
    [self.earningsLabel setText:[NSString stringWithFormat:@"%.2f%%",  earningAmountPercent]];
}

- (void)doCalculation
{
    if (![self validateAmoutValue]) {
        return;
    }
    
    NSMutableArray *values = [NSMutableArray array];
    
    for (NSInteger year = 0; year < self.year; year++) {
        CGFloat lastValue = year > 0 ? [values[year - 1] floatValue] : self.initialAmount;
        [values addObject:@(lastValue + lastValue * (self.devident / 100))];
    }
    self.values = values;
    
    [self earningAmountPercentUpdated];
    [self.barChartView reloadDataAnimated:YES];
}

@end
