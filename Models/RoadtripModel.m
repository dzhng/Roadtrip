//
//  RoadtripModel.m
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripModel.h"
#import "Database.h"
#import "MapConstants.h"

@interface RoadtripModel ()

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
    }
    return self;
}

- (id)initNewObject
{
    // set database object
    PFObject* roadtripObject = [PFObject objectWithClassName:ROADTRIP_CLASS];
    self.dbObject = roadtripObject;
    
    // set user and save
    [roadtripObject setObject:[PFUser currentUser] forKey:@"user"];
    [roadtripObject saveEventually];
    
    return [self init];
}

- (id)initFromDB:(PFObject*)dbObject
{
    self.dbObject = dbObject;
    // grab data from db
    self.name = [dbObject objectForKey:@"name"];
    self.distance = [[dbObject objectForKey:@"distance"] integerValue];
    self.stops = [[dbObject objectForKey:@"stops"] integerValue];
    self.time = [[dbObject objectForKey:@"time"] integerValue];
    self.cost = [[dbObject objectForKey:@"cost"] integerValue];
    
    return [self init];
}

- (void)dealloc
{
    // make sure to cleanup the notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString*)distanceText
{
    return [TextFormat formatDistanceFromMeters:self.distance];
}

- (NSString*)stopsText
{
    return [NSString stringWithFormat:@"%d stops", self.stops];
}

- (NSString*)timeText
{
    return [TextFormat formatTimeFromSeconds:self.time];
}

- (NSString*)costText
{
    return [NSString stringWithFormat:@"$%d", self.cost];
}

// run geocoding with given input address
- (void)geocodeWithAddress:(NSString*)address
{
    // start geocoding process
    [geocoder geocodeAddressString:address completionHandler:
     ^(NSArray *placemarks, NSError *error) {
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

- (void)getAllLocationsAndRoutes
{
    // get locations and routes
    NSMutableArray* locations = [[self.dbObject objectForKey:@"locations"] mutableCopy];
    NSMutableArray* routes = [[self.dbObject objectForKey:@"routes"] mutableCopy];
    int numLocations = [locations count];
    int numRoutes = [routes count];
    
    // check for array consistency
    if(numLocations || numRoutes) {
        if(numLocations > numRoutes + 1) {
            NSLog(@"ERROR: locations and routes out of sync, locations too high");
            // kill locations until it's the correct number
            while([locations count] > numRoutes + 1 && [locations count] != 0) {
                [locations removeLastObject];
            }
        } else if(numLocations < numRoutes + 1) {
            NSLog(@"ERROR: locations and routes out of sync, routes too high");
            // kill routes until it's the correct number
            while([routes count] + 1 > numLocations && [routes count] != 0) {
                [routes removeLastObject];
            }
        }
    }
    
    // iterate through the objects and make models
    for (NSDictionary* locationData in locations) {
        RoadtripLocation* location = [[RoadtripLocation alloc] initFromDB:locationData andModel:self];
        [self.locationArray addObject:location];
    }
    
    // make new route models and set locations
    // we need to use [routes count] here, since we may remove routes above, so numRoutes will be outdated
    for(int i = 0; i < [routes count]; i++) {
        RoadtripRoute* route = [[RoadtripRoute alloc] initFromDB:[routes objectAtIndex:i]
                               withStart:[self.locationArray objectAtIndex:i]
                              andEnd:[self.locationArray objectAtIndex:i+1] andRoadtrip:self];
        [self.routeArray addObject:route];
    }
    
    // tell our delegate to reset everything
    [self.delegate reloadLocationsAndRoutes];
}

- (void)setOrder:(NSInteger)idx
{
    [self.dbObject setObject:[NSNumber numberWithInteger:idx] forKey:@"order"];
    [self.dbObject saveEventually];
}

- (void)sync
{
    PFObject* db = self.dbObject;
    
    // serialize locations and routes
    NSMutableArray* locations = [[NSMutableArray alloc] init];
    for (RoadtripLocation* location in self.locationArray) {
        NSDictionary* locationData = [location serialize];
        [locations addObject:locationData];
    }
    NSMutableArray* routes = [[NSMutableArray alloc] init];
    for (RoadtripRoute* route in self.routeArray) {
        NSDictionary* routeData = [route serialize];
        [routes addObject:routeData];
    }

    // set class properties
    [db setObject:self.name forKey:@"name"];
    [db setObject:[NSNumber numberWithInteger:self.distance] forKey:@"distance"];
    [db setObject:[NSNumber numberWithInteger:self.time] forKey:@"time"];
    [db setObject:[NSNumber numberWithInteger:self.stops] forKey:@"stops"];
    [db setObject:[NSNumber numberWithInteger:self.cost] forKey:@"cost"];
    [db setObject:locations forKey:@"locations"];
    [db setObject:routes forKey:@"routes"];
    [db saveEventually];
}

- (void)calculateStat
{
    self.stops = [self.locationArray count];
    self.time = 0;
    self.distance = 0;
    if(self.stops > 1) {
        // sum up all stats for routes
        for(RoadtripRoute* r in self.routeArray) {
            self.time += r.time;
            self.distance += r.distance;
        }
        self.name = [NSString stringWithFormat:@"From %@ to %@",
                     [[self.locationArray objectAtIndex:0] title], [[self.locationArray lastObject] title]];
    } else if(self.stops <= 0) {
        self.name = @"Roadtrip in planning";
    } else {    // 1 stop
        self.name = [NSString stringWithFormat:@"From %@ to ?", [[self.locationArray objectAtIndex:0] title]];
    }
    self.cost = 0;
}

- (void)routeUpdated:(RoadtripRoute *)route
{
    [self calculateStat];
    [self.delegate updateStat];
    [self sync];
}

#pragma mark Notification Handlers

- (void)locationSelected:(RoadtripLocation*)location fromSource:(NSString*)source
{
    // set selected data
    [self setSelected:location];
    
    if(source == NOTIFICATION_TABLE_SOURCE) {
        [self.delegate handleSelectedFromTable:location];
    } else if(source == NOTIFICATION_MAP_SOURCE) {
        [self.delegate handleSelectedFromMap:location];
    }
}

- (void)locationDeselected:(RoadtripLocation*)location
{
    // deselect data
    [self setSelected:nil];
    [self.delegate handleDeselect];
}

- (void)locationAdded:(RoadtripLocation*)newlocation
{
    // copy the location data and make a new location object
    RoadtripLocation* location = [[RoadtripLocation alloc] initWithTitle:newlocation.title
                           subTitle:newlocation.subtitle coordinate:newlocation.coordinate
                               order:[self.locationArray count] andRoadtrip:self];
    
    // if this isn't the first location, we should add a new route
    if([self.locationArray count] > 0) {
        RoadtripRoute* newRoute = [[RoadtripRoute alloc] initWithStartLocation:[self.locationArray lastObject] endLocation:location order:[self.routeArray count] andRoadtrip:self];
        
        [self.routeArray addObject:newRoute];
    }
    
    // add to location array
    [self.locationArray addObject:location];
    
    // sync updates with db
    [self calculateStat];
    [self sync];
    
    // tell our delegate to update their views
    [self.delegate locationInserted:location atIndex:[self.locationArray count]-1];
    [self.delegate updateStat];
}

- (void)locationDeleted:(NSInteger)index
{
    if(index >= [self.locationArray count]) {
        return;
    }
    
    // get object to be removed and unsync from db
    RoadtripLocation* location = [self.locationArray objectAtIndex:index];
    [location remove];
    
    // remove from location array
    [self.locationArray removeObjectAtIndex:index];
    
    // we might need to remove route too
    RoadtripRoute* route = nil;
    if([self.locationArray count] > 0) {
        NSInteger rmIdx = 0;
        if(index < [self.locationArray count] - 1) {
            rmIdx = index;
        } else {
            rmIdx = index-1;
        }
        
        route = [self.routeArray objectAtIndex:rmIdx];
        [route remove];
        [self.routeArray removeObjectAtIndex:rmIdx];
    }
    
    // sync updates with db
    [self calculateStat];
    [self sync];
    
    // tell our delegate to update their views
    [self.delegate locationDeleted:location withRoute:route atIndex:index];
    [self.delegate updateStat];
}

- (void)routeSelected:(RoadtripRoute*)route fromSource:(NSString*)source
{
    // set selected data
    [self setSelected:route];
    
    // can only select route from table
    if(source == NOTIFICATION_TABLE_SOURCE) {
        [self.delegate handleSelectedFromTable:route];
    }
}

@end
