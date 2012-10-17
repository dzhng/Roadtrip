//
//  Location.m
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripLocation.h"
#import "RoadtripModel.h"
#import "Database.h"

@interface RoadtripLocation()

// get text form of coordinate
- (NSString*)coordinateTextWithLatitude:(float)latitude andLongitude:(float)longitude;

@end

@implementation RoadtripLocation

- (id)initWithTitle:(NSString*)title subTitle:(NSString*)subtitle coordinate:(CLLocationCoordinate2D)loc order:(NSInteger)order andRoadtrip:(RoadtripModel*)model
{
    if (self = [super init]) {
        self.order = order;
        
        [self setTitle:title];
        [self setSubtitle:subtitle];
        [self setCoordinate:loc];
        [self setModel:model];
        
        [self sync];
    }
    return self;
}

- (id)initWithLatitude:(float)latitude longitude:(float)longitude order:(NSInteger)order andRoadtrip:(RoadtripModel*)roadtrip
{
    return [self initWithTitle:[self coordinateTextWithLatitude:latitude andLongitude:longitude]
                      subTitle:nil coordinate:CLLocationCoordinate2DMake(latitude, longitude)
                         order:order andRoadtrip:roadtrip];
}

- (id)initWithPlacemark:(CLPlacemark*)placemark
{
    // initialize
    self = [super init];
    if(self) {
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
        
        // initialize data
        [self setTitle:title];
        [self setSubtitle:subtitle];
        [self setCoordinate:coordinate];
    }
    return self;
}

- (id)initFromDB:(NSDictionary*)db andModel:(RoadtripModel*)model
{
    self = [super init];
    if(self) {
        [self setModel:model];
        
        // grab data from db
        self.title = [db objectForKey:@"title"];
        self.subtitle = [db objectForKey:@"subtitle"];
        NSNumber* latitude = [db objectForKey:@"latitude"];
        NSNumber* longitude = [db objectForKey:@"longitude"];
        self.coordinate = CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
        self.order = [[db objectForKey:@"order"] integerValue];
    }
    return self;
}

- (void)sync
{
    // set model as dirty
    [self.model setDirty:true];
}

- (NSDictionary*)serialize
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
                self.title, @"title",
                self.subtitle, @"subtitle",
                [NSNumber numberWithDouble:self.coordinate.latitude], @"latitude",
                [NSNumber numberWithDouble:self.coordinate.longitude], @"longitude",
                [NSNumber numberWithInteger:self.order], @"order",
                nil];
}

- (void)remove
{
    // we dont need to clean up anything here.. yet
}

- (NSString*)coordinateTextWithLatitude:(float)latitude andLongitude:(float)longitude
{
    NSString* text = [[NSString alloc] initWithFormat:@"%.6f, %.6f",
                      latitude, longitude];
    return text;
}

@end
