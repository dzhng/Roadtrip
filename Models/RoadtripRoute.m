//
//  RoadtripRoute.m
//  Roadtrip
//
//  Created by David Zhang on 10/6/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripRoute.h"

@implementation RoadtripRoute

// initialize with array of CLLocations
- (id)initWithPoints:(NSArray*)points
{
    self = [super init];
    if(self) {
        self.routePoints = points;
    }
    return self;
}

@end
