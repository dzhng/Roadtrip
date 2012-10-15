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
#import "TextFormat.h"

@interface RoadtripRoute : NSObject

@property (assign, nonatomic) NSInteger distance;
@property (assign, nonatomic) NSInteger time;
@property (assign, nonatomic) NSInteger cost;

@property (retain, nonatomic) PFObject* dbObject;

// current overlay, stored here for easy removal
@property (retain, nonatomic) MKPolyline* currentRouteOverlay;
// array of CLLocation points that represents the overlay
@property (retain, nonatomic) NSArray* routePoints;

// center region of the route
@property (assign, nonatomic) MKCoordinateRegion centerRegion;

// store the 2 destinations this route is connected to
@property (retain, nonatomic) RoadtripLocation* start;
@property (retain, nonatomic) RoadtripLocation* end;

// initialize with array of CLLocations
- (id)initWithStartLocation:(RoadtripLocation*)start andEndLocation:(RoadtripLocation*)end;

// init from an existing PFObject
- (id)initFromDB:(PFObject*)dbObject withStart:(RoadtripLocation*)start andEnd:(RoadtripLocation*)end;

// update the start and end destination and recalculate overlays, returns true if everything was recalculated
- (bool)updateStart:(RoadtripLocation*)start andEnd:(RoadtripLocation*)end;

// gets the overlay to draw on map from routePoints
- (MKPolyline*)routeOverlay;

// sets the order this item belongs to in db
- (void)setOrder:(NSInteger)idx;

// sync all data with database
- (void)sync;

// delete from database
- (void)remove;

// reset fields in database
- (void)resetDB;

// get text representations of route values
- (NSString*)distanceText;
- (NSString*)timeText;
- (NSString*)costText;

@end