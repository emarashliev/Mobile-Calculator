//
//  UIView+QCKView.m
//  Calculator
//
//  Created by Emil Marashliev on 4/6/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import "UIView+QCKView.h"

@implementation UIView (QCKView)

- (void)blinkViewWithShowBlock:(AnimationBlock)showBlock
                     hideBlock:(AnimationBlock)hideBlock
             animationDuration:(NSTimeInterval)duration
{
    self.alpha = 1.0;
    CATransition *animation = [CATransition animation];
    animation.duration = duration;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:@"blinkAnimation"];
    
    // Change the text
    showBlock();
    
    //Hide label
    [UIView animateWithDuration:duration
                          delay:1.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         hideBlock();
                     }
                     completion:nil];

}

@end
