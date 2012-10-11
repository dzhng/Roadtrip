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
#import "RoadtripLocation.h"
#import "JSONKit.h"

@interface RoadtripRoute : NSObject

@property (copy, nonatomic) NSString* distanceText;
@property (copy, nonatomic) NSString* timeText;
@property (copy, nonatomic) NSString* costText;

@property (assign, nonatomic) NSInteger distance;
@property (assign, nonatomic) NSInteger time;
@property (assign, nonatomic) NSInteger cost;

// array of CLLocations that store points of route
@property (retain, nonatomic) NSArray* routePoints;

// array of MKPolyline that stores the actual route drawn
@property (retain, nonatomic) NSArray* routeOverlays;

// store the 2 destinations this route is connected to
@property (retain, nonatomic) RoadtripLocation* start;
@property (retain, nonatomic) RoadtripLocation* end;

// initialize with array of CLLocations
- (id)initWithStartLocation:(RoadtripLocation*)start andEndLocation:(RoadtripLocation*)end;

// update the start and end destination and recalculate overlays
- (void)updateStart:(RoadtripLocation*)start andEnd:(RoadtripLocation*)end;

@end