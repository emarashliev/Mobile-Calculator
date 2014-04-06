//
//  QCKBarView.m
//  Calculator
//
//  Created by Emil Marashliev on 4/4/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import "QCKBarView.h"

@interface QCKBarView ()

@end
@implementation QCKBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    [self setBackgroundColor:color];
}

- (instancetype)initWithIndex:(NSInteger)index color:(UIColor *)color;
{
    self = [super init];
    if (self) {
        _index = index;
        _color = color;
        [self setBackgroundColor:color];
    }
    return self;
}

@end
