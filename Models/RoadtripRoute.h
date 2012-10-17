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

@class RoadtripModel;

@interface RoadtripRoute : NSObject
{
    // path for the route files
    NSString* routeFilePath;
    
    // file name
    NSString* fileName;
}

@property (assign, nonatomic) NSInteger order;  // display order of this item
@property (retain, nonatomic) RoadtripModel* model;

@property (assign, nonatomic) NSInteger distance;
@property (assign, nonatomic) NSInteger time;
@property (assign, nonatomic) NSInteger cost;

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
- (id)initWithStartLocation:(RoadtripLocation*)start endLocation:(RoadtripLocation*)end order:(NSInteger)order andRoadtrip:(RoadtripModel*)roadtrip;

// init from an existing database object
- (id)initFromDB:(NSDictionary*)dbObject withStart:(RoadtripLocation*)start andEnd:(RoadtripLocation*)end andRoadtrip:(RoadtripModel*)roadtrip;

// update the start and end destination and recalculate overlays, returns true if everything was recalculated
- (bool)updateStart:(RoadtripLocation*)start andEnd:(RoadtripLocation*)end;

// gets the overlay to draw on map from routePoints
- (MKPolyline*)routeOverlay;

// sets the order this item belongs to in db
- (void)setOrder:(NSInteger)idx;

// sync all data with database
- (void)sync;

// get serialized data from database
- (NSDictionary*)serialize;

// delete from database
- (void)remove;

// reset fields in database
- (void)resetDB;

// get text representations of route values
- (NSString*)distanceText;
- (NSString*)timeText;
- (NSString*)costText;

@end