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

- (id)initWithTitle:(NSString*)title subTitle:(NSString*)subtitle coordinate:(CLLocationCoordinate2D)loc order:(NSInteger)order andRoadtrip:(PFObject *)roadtrip
{
    if (self = [super init]) {
        self.order = order;
        
        // set database object
        self.dbObject = [PFObject objectWithClassName:LOCATION_CLASS];
        
        dirty = true;
        
        [self setTitle:title];
        [self setSubtitle:subtitle];
        [self setCoordinate:loc];
        
        // set user and save this object to make sure the DB got it
        [self.dbObject setObject:[PFUser currentUser] forKey:@"user"];
        [self.dbObject setObject:[NSNumber numberWithInteger:order] forKey:@"order"];
        [self.dbObject setObject:roadtrip forKey:@"roadtrip"];
        [self.dbObject saveEventually:^(BOOL succeeded, NSError *error) {
            if(succeeded && !error) {
                [self sync];
                dirty = false;
                NSLog(@"New location successfully created");
            } else {
                NSLog(@"Error saving new location");
            }
        }];
    }
    return self;
}

- (id)initWithLatitude:(float)latitude longitude:(float)longitude order:(NSInteger)order andRoadtrip:(PFObject*)roadtrip
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

- (id)initFromDB:(PFObject*)dbObject
{
    self = [super init];
    if(self) {
        dirty = false;
        self.dbObject = dbObject;
        // grab data from db
        self.title = [dbObject objectForKey:@"title"];
        self.subtitle = [dbObject objectForKey:@"subtitle"];
        NSNumber* latitude = [dbObject objectForKey:@"latitude"];
        NSNumber* longitude = [dbObject objectForKey:@"longitude"];
        self.coordinate = CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
        self.order = [[dbObject objectForKey:@"order"] integerValue];
    }
    return self;
}

- (void)sync
{
    PFObject* db = self.dbObject;
    [db setObject:self.title forKey:@"title"];
    [db setObject:self.subtitle forKey:@"subtitle"];
    [db setObject:[NSNumber numberWithDouble:self.coordinate.latitude] forKey:@"latitude"];
    [db setObject:[NSNumber numberWithDouble:self.coordinate.longitude] forKey:@"longitude"];
    [db setObject:[NSNumber numberWithInteger:self.order] forKey:@"order"];
    [db saveEventually];
}

- (void)remove
{
    [self.dbObject deleteEventually];
}

- (NSString*)coordinateTextWithLatitude:(float)latitude andLongitude:(float)longitude
{
    NSString* text = [[NSString alloc] initWithFormat:@"%.6f, %.6f",
                      latitude, longitude];
    return text;
}

@end
