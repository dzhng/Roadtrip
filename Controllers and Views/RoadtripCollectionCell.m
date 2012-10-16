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
    self.title.text = roadtrip.name;
    self.subTitle.text = [NSString stringWithFormat:@"%@, %@", roadtrip.stopsText, roadtrip.distanceText];
}

@end
