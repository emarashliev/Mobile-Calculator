//
//  UIColor+QCKColor.m
//  Calculator
//
//  Created by Emil Marashliev on 4/6/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import "UIColor+QCKColor.h"

@implementation UIColor (QCKColor)

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.75, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
}

@end
