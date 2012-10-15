//
//  RoadtripCollectionCell.m
//  Roadtrip
//
//  Created by David Zhang on 10/14/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripCollectionCell.h"

@implementation RoadtripCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) updateRoadtrip:(RoadtripModel*)roadtrip
{
    self.roadtrip = roadtrip;
    // set display labels
    self.title.text = @"Roadtrip";
    self.subTitle.text = [NSString stringWithFormat:@"%@, %@", roadtrip.stopsText, roadtrip.distanceText];
}

- (void)drawRect:(CGRect)rect
{
    // make background white
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    self.backgroundView = bgView;
}

@end
