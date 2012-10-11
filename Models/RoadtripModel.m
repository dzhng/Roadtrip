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
- (void)routeSelectedNotification:(NSNotification*)notification;

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
        
        // initialize route array
        self.routeArray = [[NSMutableArray alloc] init];
        
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
        
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(routeSelectedNotification:)
            name:ROUTE_SELECTED_NOTIFICATION
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

#pragma mark Notification Handlers

- (void)locationSelectedNotification:(NSNotification*)notification
{
    // grab the new location
    NSDictionary *dictionary = [notification userInfo];
    RoadtripLocation* location = [dictionary valueForKey:NOTIFICATION_LOCATION_KEY];
    NSString* source = [dictionary valueForKey:NOTIFICATION_SELECTED_SOURCE];
    
    // set selected data
    [self setSelected:location];
    
    if(source == NOTIFICATION_TABLE_SOURCE) {
        [self.delegate handleSelectedFromTable:location];
    } else if(source == NOTIFICATION_MAP_SOURCE) {
        [self.delegate handleSelectedFromMap:location];
    }
}

- (void)locationDeselectedNotification:(NSNotification*)notification
{
    // deselect data
    [self setSelected:nil];
    [self.delegate handleDeselect];
}

- (void)locationAddedNotification:(NSNotification*)notification
{
    // grab the new location
    NSDictionary *dictionary = [notification userInfo];
    RoadtripLocation* location = [dictionary valueForKey:NOTIFICATION_LOCATION_KEY];
    
    // if this isn't the first location, we should add a new route
    if([self.locationArray count] > 0) {
        [self.routeArray addObject:[[RoadtripRoute alloc] initWithStartLocation:[self.locationArray lastObject] andEndLocation:location]];
    }
    
    // add to location array
    [self.locationArray addObject:location];
    
    // tell our delegate to update their views
    [self.delegate locationInserted:location AtIndex:[self.locationArray count]-1];
    
    // tell our delegate to display routes
    [self.delegate displayRoutes:self.routeArray];
}

- (void)routeSelectedNotification:(NSNotification *)notification
{
    // grab the new route
    NSDictionary *dictionary = [notification userInfo];
    RoadtripRoute* route = [dictionary valueForKey:NOTIFICATION_ROUTE_KEY];
    NSString* source = [dictionary valueForKey:NOTIFICATION_SELECTED_SOURCE];
    
    // set selected data
    [self setSelected:route];
    
    // can only select route from table
    if(source == NOTIFICATION_TABLE_SOURCE) {
        [self.delegate handleSelectedFromTable:route];
    }
}

@end
