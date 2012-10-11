//
//  Location.m
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripLocation.h"

@implementation RoadtripLocation

- (id)initWithAddress: (NSString*) address
{
    if (self = [super init]) {
        // initialize
        [self setAddress: address];
        [self setTitle:address];
        [self setSubtitle:self.coordinateText];
        [self setSearch:false]; // not search location by default
    }
    return self;
}

- (id)initWithTitle:(NSString*)title subTitle:(NSString*)subtitle andCoordinate:(CLLocation*)loc
{
    if (self = [super init]) {
        [self setTitle:title];
        [self setSubtitle:subtitle];
        [self setCoordinate:loc.coordinate];
    }
    return self;
}

- (id)initWithLatitude:(float)latitude andLongitude:(float)longitude
{
    if (self = [super init]) {
        // initialize
    }
    return self;
}

- (id)initWithPlacemark:(CLPlacemark*)placemark
{
    if (self = [super init]) {
        // initialize
        self.addressDictionary = placemark.addressDictionary;
        self.name = placemark.name;
        NSArray* addr = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
        NSMutableString* fullAddr = [[NSMutableString alloc] init];
        for(NSString* a in addr) {
            [fullAddr appendFormat:@"%@, ", a];
        }
        self.address = (NSString*)fullAddr;
        self.formattedAddress = addr;
        
        // if this location have a name, return the name, else return street address
        if(self.name) {
            self.title = self.name;
            self.subtitle = [self.formattedAddress objectAtIndex:0];
        } else {
            self.title = [self.formattedAddress objectAtIndex:0];
            if([self.formattedAddress count] > 1) {
                self.subtitle = [self.formattedAddress objectAtIndex:1];
            } else {
                self.subtitle = nil;
            }
        }
        
        // extract full coordinates
        self.coordinate = [[placemark location] coordinate];
    }
    return self;
}

- (NSString*)coordinateText
{
    NSString* text = [[NSString alloc] initWithFormat:@"%.6f, %.6f",
                      self.coordinate.latitude, self.coordinate.longitude];
    return text;
}

@end
