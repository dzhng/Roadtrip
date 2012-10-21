//
//  BezelSwipe.m
//  Roadtrip
//
//  Created by David Zhang on 10/19/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "BezelSwipe.h"

#define BEGIN_BOUND     50
#define TRIGGER_BOUND   70

@implementation BezelSwipe

-(id)initWithTarget:(id)target action:(SEL)action{
    if ((self = [super initWithTarget:target action:action])){
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    if ([touches count] > 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if ([touch locationInView:self.view].x > BEGIN_BOUND) {
        self.state = UIGestureRecognizerStateFailed;
    } else {
        self.right = true;
        self.state = UIGestureRecognizerStateBegan;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    if ([touches count] > 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    } else if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if (self.state == UIGestureRecognizerStateBegan && [touch locationInView:self.view].x > TRIGGER_BOUND) {
        self.state = UIGestureRecognizerStateEnded;
    } else if(self.state == UIGestureRecognizerStateBegan && [touch locationInView:self.view].x > BEGIN_BOUND) {
        self.state = UIGestureRecognizerStateChanged;
    } else if ([touch locationInView:self.view].x < BEGIN_BOUND) {
        self.state = UIGestureRecognizerStateFailed;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    if ([touches count] > 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if (self.state == UIGestureRecognizerStateBegan && [touch locationInView:self.view].x > TRIGGER_BOUND) {
        self.state = UIGestureRecognizerStateEnded;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (self.state == UIGestureRecognizerStateBegan && [touch locationInView:self.view].x > TRIGGER_BOUND) {
        self.state = UIGestureRecognizerStateEnded;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

-(void)reset{
    [super reset];
}

@end
