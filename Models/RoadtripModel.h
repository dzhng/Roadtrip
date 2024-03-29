//
//  RoadtripModel.h
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "RoadtripLocation.h"
#import "RoadtripRoute.h"
#import "ModelNotifications.h"
#import "TextFormat.h"

@protocol RoadtripModelDelegate <NSObject>

- (void)searchDone:(NSArray*)locationObjects;
- (void)locationInserted:(RoadtripLocation*)location atIndex:(NSInteger)index;
- (void)locationDeleted:(RoadtripLocation*)location withRoute:(RoadtripRoute*)route atIndex:(NSInteger)index;
- (void)updateStat;
- (void)handleSelectedFromTable:(id) selected;
- (void)handleSelectedFromMap:(id)selected;
- (void)handleDeselect;

// reload everything
- (void)reloadLocationsAndRoutes;

@end

@interface RoadtripModel : NSObject
{
    CLGeocoder* geocoder;        // stores geocoder used for location lookup
    
}

@property (assign, nonatomic) id <RoadtripModelDelegate> delegate;

// flag indicating if the current data has changed and should be synced with server
@property (assign, nonatomic) bool dirty;

// roadtrip settings
@property (copy, nonatomic) NSString* name;
@property (assign, nonatomic) NSInteger distance;
@property (assign, nonatomic) NSInteger stops;
@property (assign, nonatomic) NSInteger time;
@property (assign, nonatomic) NSInteger cost;
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

// get text representations for roadtrip settings
- (NSString*)distanceText;
- (NSString*)stopsText;
- (NSString*)timeText;
- (NSString*)costText;

// translate a search string into coordinates and address
- (void)geocodeWithAddress:(NSString*)address;

// get all locations and rotues for this roadtrip
- (void)getAllLocationsAndRoutes;

// update this roadtrip settings to db
- (void)sync;

// calculate all model statistics and store
- (void)calculateStat;

/*** Location and Route Functions ***/
- (void)locationAdded:(RoadtripLocation*)location;
- (void)locationSelected:(RoadtripLocation*)location fromSource:(NSString*)source;
- (void)locationDeselected:(RoadtripLocation*)location;
- (void)locationDeleted:(NSInteger)index;
- (void)routeSelected:(RoadtripRoute*)route fromSource:(NSString*)source;
- (void)routeUpdated:(RoadtripRoute*)route;

@end
