//
//  LocationTableView.m
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "LocationTableView.h"

@implementation LocationTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // draw a gradient as the background of this table
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef darkColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5].CGColor;
    CGColorRef lightColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3].CGColor;
    
    NSArray* colors = [NSArray arrayWithObjects:
                       (id)CFBridgingRelease(darkColor),
                       (id)CFBridgingRelease(lightColor),
                       nil];
    
    CGFloat locations[] = {0.0, 1.0};
    
    CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(),
                                                        CFBridgingRetain(colors), locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(CGColorSpaceCreateDeviceRGB());
    
    // add right edge stroke
    CGContextSaveGState(context);
    CGColorRef strokeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8].CGColor;
    CGContextSetStrokeColorWithColor(context, strokeColor);
    CGContextSetLineWidth(context, 3.0);
    CGPoint points[] = {CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect)),
        CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))};
    CGContextStrokeLineSegments(context, points, 2);
    CGContextRestoreGState(context);
    
    // draw the text on top
}

@end
