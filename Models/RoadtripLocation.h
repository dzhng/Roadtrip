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
}

@property (retain, nonatomic) NSDictionary* addressDictionary;  // dictionary form of address
@property (assign, nonatomic) bool search;      // stores if this is a search location

@property (retain, nonatomic) PFObject* dbObject;

// MKAnnotation properties
@property (copy) NSString* title;
@property (copy) NSString* subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

// just initialize with the raw data needed for display
- (id)initWithTitle:(NSString*)title subTitle:(NSString*)subtitle andCoordinate:(CLLocationCoordinate2D)loc;

// save coordinate and perform reverse Geocoding to convert to streetname
- (id)initWithLatitude:(float)latitude andLongitude:(float)longitude;

// extract data from input placemark,
// this is used for search locations, so db object is NOT created
- (id)initWithPlacemark:(CLPlacemark*)placemark;

// init from an existing PFObject
- (id)initFromDB:(PFObject*)dbObject;

// sync with database
- (void)sync;

@end
