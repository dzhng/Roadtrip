//
//  RoadtripModel.h
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RoadtripLocation.h"
#import "RoadtripRoute.h"
#import "ModelNotifications.h"

@protocol RoadtripModelDelegate <NSObject>

- (void)searchDone:(NSArray*)locationObjects;
- (void)locationInserted:(RoadtripLocation*)location AtIndex:(NSInteger)index;
- (void)handleSelectedFromTable:(id) selected;
- (void)handleSelectedFromMap:(id)selected;
- (void)handleDeselect;

@end

@interface RoadtripModel : NSObject
{
    CLGeocoder* geocoder;        // stores geocoder used for location lookup
}

@property (assign, nonatomic) id <RoadtripModelDelegate> delegate;

// roadtrip settings
@property (copy, nonatomic) NSString* name;
@property (copy, nonatomic) NSNumber* distance;
@property (copy, nonatomic) NSNumber* stops;
@property (copy, nonatomic) NSNumber* time;
@property (copy, nonatomic) NSNumber* cost;
@property (retain, nonatomic) PFObject* dbObject;

// data model of locations
@property (retain, nonatomic) NSMutableArray* locationArray;
@property (retain, nonatomic) NSMutableArray* searchLocationArray;

// data model of routes
@property (retain, nonatomic) NSMutableArray* routeArray;

// currently selected location
@property (retain, nonatomic) id selected;

// standard init
- (id)init;
// init and create a new entry in database
- (id)initNewObject;
// init from an existing PFObject
- (id)initFromDB:(PFObject*)dbObject;

// translate a search string into coordinates and address
- (void)geocodeWithAddress:(NSString*)address;

// get all locations and rotues for this roadtrip
- (void)getAllLocationsAndRoutes;

// save a new location and route
- (RoadtripLocation*)newLocationFromLocation:(RoadtripLocation*)location;
- (void)newRoute;

// update this roadtrip settings to db
- (void)sync;

@end
