//
//  RoadtripRoute.h
//  Roadtrip
//
//  Created by David Zhang on 10/6/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface RoadtripRoute : NSObject

@property (copy, nonatomic) NSString* distance;
@property (copy, nonatomic) NSString* time;
@property (copy, nonatomic) NSString* cost;

// array of CLLocations that store points of route
@property (retain, nonatomic) NSArray* routePoints;

// array of MKPolyline that stores the actual route drawn
@property (retain, nonatomic) NSArray* routeOverlays;

// initialize with array of CLLocations
- (id)initWithPoints:(NSArray*)points;

// convert input points into overlays
- (NSArray*)getOverlaysFromPoints:(NSArray*)points;

@end
