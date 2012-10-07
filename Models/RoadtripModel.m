//
//  RoadtripModel.m
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripModel.h"

@interface RoadtripModel ()

- (void)locationAddedNotification:(NSNotification*)notification;
- (void)locationSelectedNotification:(NSNotification*)notification;
- (void)locationDeselectedNotification:(NSNotification*)notification;

@end

@implementation RoadtripModel

- (id)init
{
    self = [super init];
    if(self) {
        // initialize the geocoder
        geocoder = [[CLGeocoder alloc] init];
        
        // initialize the current location array
        self.locationArray = [[NSMutableArray alloc] init];
        
        // setup model to receive notifications
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(locationAddedNotification:)
            name:ADD_LOCATIONS_NOTIFICATION
            object:nil];
        
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(locationSelectedNotification:)
            name:LOCATION_SELECTED_NOTIFICATION
            object:nil];
        
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(locationDeselectedNotification:)
            name:LOCATION_DESELECTED_NOTIFICATION
            object:nil];
    }
    return self;
}

- (void)dealloc
{
    // make sure to cleanup the notifications
    [[NSNotificationCenter defaultCenter] removeObject:self];
}

// run geocoding with given input address
- (void)geocodeWithAddress:address
{
    // start geocoding process
    [geocoder geocodeAddressString:address
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                    if(!error) {   // no errors!
                        // make a new search location array
                        self.searchLocationArray = [[NSMutableArray alloc] init];
                        
                        // build an array of RoadtripLocation objects based on placemerks
                        for(CLPlacemark* placemark in placemarks) {
                            [self.searchLocationArray addObject:[[RoadtripLocation alloc] initWithPlacemark:placemark]];
                        }
     
                        // tell our delegate that we're good to go
                        [self.delegate searchDone:self.searchLocationArray];
                    } else {
                        NSLog(@"Error getting geocoding location %@", address);
                        // show a popup alert
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Address not found"
                                                        message:@"Please modify your search and try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
                        [alert show];
                    }
                 }];
}

#pragma mark Routing functions

// get route coordinates from google API, should return array of RoadtripRoute
- (NSArray*)calculateRoutes
{
    if ([self.locationArray count] > 1) {
        // get points
        RoadtripLocation* origin = [self.locationArray objectAtIndex:0];
        RoadtripLocation* destination = [self.locationArray lastObject];
        
        NSString* saddr = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
        NSString* daddr = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
        
        NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false", saddr, daddr];
        NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
        
        NSError *error;
        NSString* apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
        NSDictionary* parsed = [apiResponse objectFromJSONString];
        NSArray* routes = [parsed objectForKey:@"routes"];
        if ([routes count] <= 0) {
            NSLog(@"No roadtrip routes found");
            return nil;
        }
        
        // we only want the first route, for now.. maybe enable different route planning later
        NSDictionary* route = [routes objectAtIndex:0];
        NSArray* warnings = [route objectForKey:@"warnings"];
        if ([warnings count] > 0) {
            NSLog(@"Warnings: %@", [warnings objectAtIndex:0]);
        }
        
        NSMutableArray* roadtripRoutes = [[NSMutableArray alloc] init];
        NSArray* legs = [route objectForKey:@"legs"];
        for(NSDictionary* leg in legs) {
            NSMutableArray* routePoints = [[NSMutableArray alloc] init];
            NSArray* steps = [leg objectForKey:@"steps"];
            for(NSDictionary* step in steps) {
                NSDictionary* polyline = [step objectForKey:@"polyline"];
                NSString* points = [polyline objectForKey:@"points"];
                [routePoints addObjectsFromArray:[self decodePolyLine:points]];
            }
            
            RoadtripRoute* roadtripRoute = [[RoadtripRoute alloc] initWithPoints:routePoints];
            
            // grab leg values
            NSDictionary* dist = [leg objectForKey:@"distance"];
            NSString* distanceText = [dist objectForKey:@"text"];
            NSInteger distance = [[dist objectForKey:@"value"] integerValue];
           
            NSDictionary* dur = [leg objectForKey:@"duration"];
            NSString* durationText = [dur objectForKey:@"text"];
            NSInteger duration = [[dur objectForKey:@"value"] integerValue];
            
            roadtripRoute.timeText = durationText;
            roadtripRoute.time = duration;
            roadtripRoute.distanceText = distanceText;
            roadtripRoute.distance = distance;
            
            [roadtripRoutes addObject:roadtripRoute];
        }
        
        // check if correct amount of routes is inserted, insert blank routes to fill up space
        while ([roadtripRoutes count] < [self.locationArray count] -1) {
            [roadtripRoutes addObject: [[RoadtripRoute alloc] init]];
        }
        
        return roadtripRoutes;
    } else {
        return nil;
    }
}
                 
// decode the polyline binary data from GMaps API into an array of CLLocations
- (NSMutableArray *)decodePolyLine:(NSString *)encodedString
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger len = [encodedString length];
    NSInteger index = 0;
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        lat += ((result & 1) ? ~(result >> 1) : (result >> 1));
        
        shift = 0;
        result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        lng += ((result & 1) ? ~(result >> 1) : (result >> 1));
        
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}
                 
#pragma mark Notification Handlers
- (void)locationSelectedNotification:(NSNotification*)notification
{
    // grab the new location
    NSDictionary *dictionary = [notification userInfo];
    RoadtripLocation* location = [dictionary valueForKey:NOTIFICATION_LOCATION_KEY];
    NSString* source = [dictionary valueForKey:NOTIFICATION_SELECTED_SOURCE];
    
    // set selected data
    [self setSelectedLocation:location];
    
    if(source == NOTIFICATION_TABLE_SOURCE) {
        [self.delegate handleSelectedFromTable:location];
    } else if(source == NOTIFICATION_MAP_SOURCE) {
        [self.delegate handleSelectedFromMap:location];
    }
}

- (void)locationDeselectedNotification:(NSNotification*)notification
{
    // deselect data
    [self setSelectedLocation:nil];
    [self.delegate handleDeselect];
}

- (void)locationAddedNotification:(NSNotification*)notification
{
    // grab the new location
    NSDictionary *dictionary = [notification userInfo];
    RoadtripLocation* location = [dictionary valueForKey:NOTIFICATION_LOCATION_KEY];
    // add to location array
    [self.locationArray addObject:location];
    
    // after adding location, we should recalculate all routes
    NSArray* routes = [self calculateRoutes];
    [self setRouteArray:[routes mutableCopy]];
    
    // tell our delegate to update their views
    [self.delegate locationInserted:location AtIndex:[self.locationArray count]-1];
    
    // tell our delegate to display routes
    [self.delegate displayRoutes:routes];
    
}

@end
