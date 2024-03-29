//
//  RoadtripRoute.m
//  Roadtrip
//
//  Created by David Zhang on 10/6/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripRoute.h"
#import "RoadtripModel.h"
#import "ModelNotifications.h"
#import "MapConstants.h"
#import "Database.h"

@interface RoadtripRoute()

// get route coordinates from google API for the begin and ending locations
- (void)calculateRoutesWithOrigin:(CLLocationCoordinate2D)origin
                          destination:(CLLocationCoordinate2D)destination withWaypoints:(NSArray*)waypoints;

// decode the polyline binary data from GMaps API into an array of CLLocations
- (NSMutableArray *)decodePolyLine:(NSString *)encodedString;

// get the region to zoom the map to display the entire route
- (MKCoordinateRegion)getCenterRegionFromPoints:(NSArray*)points;

// send notification to other controllers informing that the route data and overlays has been updated.
// Old overlays also attached so they can also be removed
- (void)postRouteUpdateNotificationWithRoute:(RoadtripRoute*)route;

@end

@implementation RoadtripRoute

// initialize with array of CLLocations
- (id)initWithStartLocation:(RoadtripLocation*)start endLocation:(RoadtripLocation*)end order:(NSInteger)order andRoadtrip:(RoadtripModel*)roadtrip
{
    self = [super init];
    if(self) {
        //get the documents directory
        fileName = [NSString stringWithFormat:@"%d", arc4random()];
        NSString* doc = [NSString stringWithFormat:@"Documents/%@", fileName];
        routeFilePath = [NSHomeDirectory() stringByAppendingPathComponent:doc];
        
        self.model = roadtrip;
        self.start = nil;
        self.end = nil;
        self.order = order;
        
        [self updateStart:start andEnd:end];
    }
    return self;
}

- (id)initFromDB:(NSDictionary *)db withStart:(RoadtripLocation*)start andEnd:(RoadtripLocation*)end andRoadtrip:(RoadtripModel*)roadtrip
{
    self = [super init];
    if(self) {
        fileName = [db objectForKey:@"filename"];
        
        //get the documents directory
        NSString* doc = [NSString stringWithFormat:@"Documents/%@", fileName];
        routeFilePath = [NSHomeDirectory() stringByAppendingPathComponent:doc];
        
        self.model = roadtrip;
        self.start = start;
        self.end = end;
        
        //NSLog(@"Getting route from: %@", filePath);
        NSMutableArray* p = [NSKeyedUnarchiver unarchiveObjectWithFile:routeFilePath];
        if(p == nil) {
            NSLog(@"Error: DB data invalid, recalculating routes");
            [self calculateRoutesWithOrigin:start.coordinate destination:end.coordinate withWaypoints:nil];
        } else {
            NSMutableArray* points = [[NSMutableArray alloc] init];
            for(int i = 0; i < [p count]; i++) {
                NSDictionary* pt = [p objectAtIndex:i];
                double latitude = [[pt objectForKey:@"latitude"] doubleValue];
                double longitude = [[pt objectForKey:@"longitude"] doubleValue];
                CLLocation* point = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                [points addObject:point];
            }
            self.routePoints = points;

            // get center region
            self.centerRegion = [self getCenterRegionFromPoints:self.routePoints];
            
            self.distance = [[db objectForKey:@"distance"] integerValue];
            self.time = [[db objectForKey:@"time"] integerValue];
            self.cost = [[db objectForKey:@"cost"] integerValue];
            self.order = [[db objectForKey:@"order"] integerValue];
            
            // tell views that our route was updated
            [self postRouteUpdateNotificationWithRoute:self];
        }
    }
    return self;
}

- (bool)updateStart:(RoadtripLocation*)start andEnd:(RoadtripLocation*)end
{
    // if the start and end destinations have changed, calculate route and overlay
    if(self.start != start || self.end != end) {
        self.start = start;
        self.end = end;
        
        // clear the DB on restart
        [self resetDB];
        
        // calculate route and polyline, this function will also update the db when it's done
        [self calculateRoutesWithOrigin:start.coordinate destination:end.coordinate withWaypoints:nil];
        
        return true;
    }
    return false;
}

- (void)sync
{
    // code up route points
    NSMutableArray* points = [[NSMutableArray alloc] init];
    for(int i = 0; i < [self.routePoints count]; i++) {
        CLLocation* point = [self.routePoints objectAtIndex:i];
        NSDictionary* p = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithDouble:point.coordinate.latitude], @"latitude",
                           [NSNumber numberWithDouble:point.coordinate.longitude], @"longitude", nil];
        [points addObject:p];
    }
    
    //NSLog(@"Route saved to: %@", filePath);
    if(![NSKeyedArchiver archiveRootObject:points toFile:routeFilePath]) {
        NSLog(@"Error saving route file");
    }
    
    [self.model setDirty:true];
}

- (NSDictionary*)serialize
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithInteger: self.time], @"time",
                [NSNumber numberWithInteger: self.cost], @"cost",
                [NSNumber numberWithInteger: self.distance], @"distance",
                [NSNumber numberWithInteger: self.order], @"order",
                fileName, @"filename",
                nil];
}

- (void)remove
{
    [self resetDB];
}

- (void)resetDB
{
    //NSLog(@"Reset database %@", filePath);
    [[NSFileManager defaultManager] removeItemAtPath:routeFilePath error:nil];
}

// convert input points into overlays
- (MKPolyline*)routeOverlay
{
    NSArray* points = self.routePoints;
    self.currentRouteOverlay = nil;
    
    int numPoints;
    if ((numPoints = [points count]) > 1)
    {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [points objectAtIndex:i];
            coords[i] = current.coordinate;
        }
        
        MKPolyline* polyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
        
        self.currentRouteOverlay = polyline;
        return polyline;
    }
    return nil;
}

- (NSString*)distanceText
{
    return [TextFormat formatDistanceFromMeters:self.distance];
}

- (NSString*)timeText
{
    return [TextFormat formatTimeFromSeconds:self.time];
}

- (NSString*)costText
{
    return [NSString stringWithFormat:@"5 dollars"];
}

- (void)postRouteUpdateNotificationWithRoute:(RoadtripRoute *)route
{
    NSString *notificationName = ROUTE_UPDATED_NOTIFICATION;
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:route, NOTIFICATION_ROUTE_KEY, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

#pragma mark Routing functions

// get route coordinates from google API for the begin and ending locations
- (void)calculateRoutesWithOrigin:(CLLocationCoordinate2D)origin
                          destination:(CLLocationCoordinate2D)destination withWaypoints:(NSArray*)waypoints
{
    // get points
    NSString* oaddr = [NSString stringWithFormat:@"%f,%f",
                       origin.latitude, origin.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f",
                       destination.latitude, destination.longitude];
    
    // build base query URL
    NSMutableString* apiUrlStr = [NSMutableString
                           stringWithFormat:@"http://maps.googleapis.com/maps"
                           "/api/directions/json?"
                           "origin=%@"
                           "&destination=%@"
                           "&sensor=false", oaddr, daddr];
    // append waypoint sections
    int numWaypoints = [waypoints count];
    if(numWaypoints > 2) {
        [apiUrlStr appendString:@"&waypoints="];
        for (int i = 0; i < numWaypoints; i++) {
            CLLocation* waypoint = [waypoints objectAtIndex:i];
            [apiUrlStr appendFormat:@"%f,%f",
                 waypoint.coordinate.latitude, waypoint.coordinate.longitude];
            if(i < numWaypoints - 1) {
                [apiUrlStr appendString:@"|"];
            }
        }
    }
    NSURL* apiUrl = [NSURL URLWithString:
                 [apiUrlStr stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    // make the URL request
    NSURLRequest *req = [NSURLRequest requestWithURL:apiUrl];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSDictionary* parsed = [result objectFromJSONString];
        NSArray* routes = [parsed objectForKey:@"routes"];
        if ([routes count] <= 0) {
            NSLog(@"Error: No roadtrip routes found");
            return;
        }
        
        // we only want the first route, for now.. maybe enable different route planning later
        NSDictionary* route = [routes objectAtIndex:0];
        NSArray* warnings = [route objectForKey:@"warnings"];
        if ([warnings count] > 0) {
            NSLog(@"Routing warnings: %@", [warnings objectAtIndex:0]);
        }
        
        NSMutableArray* routePoints = [[NSMutableArray alloc] init];
        NSArray* legs = [route objectForKey:@"legs"];
        
        // we're only interested in the first leg, since we don't do waypoints
        NSDictionary* leg = [legs objectAtIndex:0];
        NSArray* steps = [leg objectForKey:@"steps"];
        for(NSDictionary* step in steps) {
            NSDictionary* polyline = [step objectForKey:@"polyline"];
            NSString* points = [polyline objectForKey:@"points"];
            [routePoints addObjectsFromArray:[self decodePolyLine:points]];
        }
        
        // grab leg values
        NSDictionary* dist = [leg objectForKey:@"distance"];
        self.distance = [[dist objectForKey:@"value"] integerValue];
       
        NSDictionary* dur = [leg objectForKey:@"duration"];
        self.time = [[dur objectForKey:@"value"] integerValue];
        
        // set points
        self.routePoints = routePoints;
        
        // get center region
        self.centerRegion = [self getCenterRegionFromPoints:routePoints];
         
        // update model
        [self.model routeUpdated:self];
        
        // tell views that our route was updated
        [self postRouteUpdateNotificationWithRoute:self];
        
        // sync with database
        [self sync];
    }];
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

- (MKCoordinateRegion) getCenterRegionFromPoints:(NSArray*)points
{
    MKCoordinateRegion region;
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for(int idx = 0; idx < points.count; idx++)
    {
        CLLocation* currentLocation = [points objectAtIndex:idx];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    
    region.span.latitudeDelta  = ROUTE_ZOOM*(maxLat - minLat);
    region.span.longitudeDelta = ROUTE_ZOOM*(maxLon - minLon);
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = ((maxLon + minLon) / 2) - 0.3*(maxLon - minLon);
    
    return region;
}

@end
