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

@interface RoadtripLocation : NSObject <MKAnnotation>
{
    MKCoordinateRegion region;  // stores region to be used for map placements
    
    // if the object still need to be synced to DB after creation
    bool dirty;
}

@property (retain, nonatomic) NSDictionary* addressDictionary;  // dictionary form of address
@property (assign, nonatomic) bool search;      // stores if this is a search location
@property (assign, nonatomic) NSInteger order;  // display order of this item

@property (retain, nonatomic) PFObject* dbObject;

// MKAnnotation properties
@property (copy) NSString* title;
@property (copy) NSString* subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

// just initialize with the raw data needed for display
- (id)initWithTitle:(NSString*)title subTitle:(NSString*)subtitle coordinate:(CLLocationCoordinate2D)loc order:(NSInteger)order andRoadtrip:(PFObject*)roadtrip;

// save coordinate and perform reverse Geocoding to convert to streetname
- (id)initWithLatitude:(float)latitude longitude:(float)longitude order:(NSInteger)order andRoadtrip:(PFObject*)roadtrip;

// extract data from input placemark,
// this is used for search locations, so db object is NOT created
- (id)initWithPlacemark:(CLPlacemark*)placemark;

// init from an existing PFObject
- (id)initFromDB:(PFObject*)dbObject;

// sync with database
- (void)sync;

// delete from database
- (void)remove;

@end
