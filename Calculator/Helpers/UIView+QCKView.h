//
//  UIView+QCKView.h
//  Calculator
//
//  Created by Emil Marashliev on 4/6/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (QCKView)

typedef void (^AnimationBlock)();

- (void)blinkViewWithShowBlock:(AnimationBlock)showBlock
                     hideBlock:(AnimationBlock)hideBlock
             animationDuration:(NSTimeInterval)duration;

@end
