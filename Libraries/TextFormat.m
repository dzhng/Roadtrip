//
//  TextFormat.m
//  Roadtrip
//
//  Created by David Zhang on 10/14/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "TextFormat.h"
#import "MapConstants.h"

@implementation TextFormat

+ (NSString*)formatDistanceFromMeters:(NSInteger)meters
{
    float miles = meters / METERS_PER_MILE;
    if(miles < 10) {
        return [NSString stringWithFormat:@"%0.1f miles", miles];
    } else {
        // if greater than 2 digits, dont bother showing the decimal
        return [NSString stringWithFormat:@"%0.0f miles", miles];
    }
}

+ (NSString*)formatTimeFromSeconds:(NSInteger)seconds
{
    NSInteger minutes = seconds / 60;
    
    // show minuets if it's under an hour
    if (minutes <= 60) {
        return [NSString stringWithFormat:@"%d minutes", minutes];
    } else {
        // get hours and leftover minuets
        NSInteger hours = minutes / 60;
        minutes = minutes % 60;
        return [NSString stringWithFormat:@"%d hours and %d minutes", hours, minutes];
    }
}

@end
