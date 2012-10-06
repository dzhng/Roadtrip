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
        self.routeOverlays = [self getOverlaysFromPoints:points];
    }
    return self;
}

// convert input points into overlays
- (NSArray*)getOverlaysFromPoints:(NSArray*)points
{
    int numPoints;
    if ((numPoints = [points count]) > 1)
    {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [points objectAtIndex:i];
            coords[i] = current.coordinate;
        }
        
        MKPolyline* polyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
        
        return [NSArray arrayWithObject:polyline];
    }
    return nil;
}

@end
