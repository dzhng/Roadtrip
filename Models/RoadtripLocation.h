//
//  Location.h
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class RoadtripModel;

@interface RoadtripLocation : NSObject <MKAnnotation>
{
    MKCoordinateRegion region;  // stores region to be used for map placements
}

@property (retain, nonatomic) NSDictionary* addressDictionary;  // dictionary form of address
@property (assign, nonatomic) bool search;      // stores if this is a search location
@property (assign, nonatomic) NSInteger order;  // display order of this item
@property (retain, nonatomic) RoadtripModel* model;

// MKAnnotation properties
@property (copy) NSString* title;
@property (copy) NSString* subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

// just initialize with the raw data needed for display
- (id)initWithTitle:(NSString*)title subTitle:(NSString*)subtitle coordinate:(CLLocationCoordinate2D)loc order:(NSInteger)order andRoadtrip:(RoadtripModel*)roadtrip;

// save coordinate and perform reverse Geocoding to convert to streetname
- (id)initWithLatitude:(float)latitude longitude:(float)longitude order:(NSInteger)order andRoadtrip:(RoadtripModel*)roadtrip;

// extract data from input placemark,
// this is used for search locations, so db object is NOT created
- (id)initWithPlacemark:(CLPlacemark*)placemark;

// init from an existing model dictionary
- (id)initFromDB:(NSDictionary*)db andModel:(RoadtripModel*)model;

// sync with database
- (void)sync;

// get serialized data for database
- (NSDictionary*)serialize;

// delete from database
- (void)remove;

@end
