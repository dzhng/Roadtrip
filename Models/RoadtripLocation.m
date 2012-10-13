//
//  Location.m
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripLocation.h"
#import "Database.h"

@interface RoadtripLocation()

// get text form of coordinate
- (NSString*)coordinateTextWithLatitude:(float)latitude andLongitude:(float)longitude;

@end

@implementation RoadtripLocation

- (id)initWithTitle:(NSString*)title subTitle:(NSString*)subtitle andCoordinate:(CLLocationCoordinate2D)loc
{
    if (self = [super init]) {
        // set database object
        PFObject* locationObject = [PFObject objectWithClassName:LOCATION_CLASS];
        self.dbObject = locationObject;
        
        // set user and save
        [locationObject setObject:[PFUser currentUser] forKey:@"user"];
        [locationObject saveEventually];
        
        [self setTitle:title];
        [self setSubtitle:subtitle];
        [self setCoordinate:loc];
    }
    return self;
}

- (id)initWithLatitude:(float)latitude andLongitude:(float)longitude
{
    return [self initWithTitle:[self coordinateTextWithLatitude:latitude andLongitude:longitude]
                      subTitle:nil andCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
}

- (id)initWithPlacemark:(CLPlacemark*)placemark
{
    // initialize
    self.addressDictionary = placemark.addressDictionary;
    NSString* name = placemark.name;
    NSArray* addr = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
    NSArray* formattedAddress = addr;
    
    NSString* title;
    NSString* subtitle;
    CLLocationCoordinate2D coordinate;
    
    // if this location have a name, return the name, else return street address
    if(name) {
        title = name;
        subtitle = [formattedAddress objectAtIndex:0];
    } else {
        title = [formattedAddress objectAtIndex:0];
        if([formattedAddress count] > 1) {
            subtitle = [formattedAddress objectAtIndex:1];
        } else {
            subtitle = nil;
        }
    }
    
    // extract full coordinates
    coordinate = [[placemark location] coordinate];
    
    // initialize
    return [self initWithTitle:title subTitle:subtitle andCoordinate:coordinate];
}

- (id)initFromDB:(PFObject*)dbObject
{
    self = [super init];
    if(self) {
        self.dbObject = dbObject;
        // grab data from db
    }
    return self;
}

- (NSString*)coordinateTextWithLatitude:(float)latitude andLongitude:(float)longitude
{
    NSString* text = [[NSString alloc] initWithFormat:@"%.6f, %.6f",
                      latitude, longitude];
    return text;
}

@end
