//
//  QCKBarView.h
//  Calculator
//
//  Created by Emil Marashliev on 4/4/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QCKBarView : UIButton

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) UIColor *color;

- (instancetype)initWithIndex:(NSInteger)index color:(UIColor *)color;

@end
