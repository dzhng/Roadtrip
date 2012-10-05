//
//  DetailMapViewController.m
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "DetailMapViewController.h"
#import "ModelNotifications.h"
#import "MapConstants.h"

@interface DetailMapViewController ()

- (void)postLocationSelectedNotificationWithLocation:(RoadtripLocation*)location;
- (void)postDeselectNotification;

@end

@implementation DetailMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // stores if we're currently momentum scrolling on the map
        momentumScrolling = false;
        startPoint = @"New York City";
        endPoint = @"Boston";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // initialize mapview
    mapView = [[MKMapView alloc] initWithFrame:self.contentView.frame];
    mapView.delegate = self;
    mapView.showsUserLocation = NO;
    [mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.contentView addSubview:mapView];
    
    // Origin Location.
    CLLocationCoordinate2D loc1;
    loc1.latitude = 29.0167;
    loc1.longitude = 77.3833;
    RoadtripLocation *origin = [[RoadtripLocation alloc] initWithTitle:@"loc1" subTitle:@"Home1" andCoordinate:loc1];
    [mapView addAnnotation:origin];
    
    // Destination Location.
    CLLocationCoordinate2D loc2;
    loc2.latitude = 19.076000;
    loc2.longitude = 72.877670;
    RoadtripLocation *destination = [[RoadtripLocation alloc] initWithTitle:@"loc2" subTitle:@"Home2" andCoordinate:loc2];
    [mapView addAnnotation:destination];
    
    routePoints = [self getRoutePointFrom:origin to:destination];
    [self drawRoute];
    [self centerMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update
{
    [self removeDirectionLocations];
    
    // update the map with all the current locations
    NSArray* locations = self.roadtripModel.locationArray;
    
    for(RoadtripLocation* loc in locations) {
        [loc setSearch:false];
        [mapView addAnnotation:loc];
    }
}

- (void)updateSearchLocations
{
    [self removeSearchLocations];
    
    // get locations
    NSArray* locations = self.roadtripModel.searchLocationArray;
    
    // center the map on the first search location,
    // we need to center first before adding annotations for the popover to show
    RoadtripLocation* center = [locations objectAtIndex:0];
    [center setSearch:true];
    [self centerMapOnLocation:center];
    self.roadtripModel.selectedLocation = center;
    
    // update map with annotations of search locations
    for(RoadtripLocation* loc in locations) {
        // set the locations as search locations
        [loc setSearch:true];
        [mapView addAnnotation:loc];
    }
}

- (void)centerMapOnLocation:(RoadtripLocation*)location
{
    MKCoordinateRegion newRegion =  MKCoordinateRegionMakeWithDistance([location coordinate], MAP_ZOOM, MAP_ZOOM);
    [mapView setRegion:newRegion animated:NO];
    [mapView selectAnnotation:location animated:YES];
    NSLog(@"%d", location.search);
}

- (void)removeDirectionLocations
{
    // first remove all original direction annotations
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if([annotation isKindOfClass:[RoadtripLocation class]] && ![(RoadtripLocation*)annotation search])
            [mapView removeAnnotation:annotation];
    }
}

- (void)removeSearchLocations
{
    // first remove all original search annotations
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if([annotation isKindOfClass:[RoadtripLocation class]] && [(RoadtripLocation*)annotation search])
            [mapView removeAnnotation:annotation];
    }
}

- (void)removeSearchLocation:(RoadtripLocation*)location
{
    // remove the pin
    [mapView removeAnnotation:location];
    // also remove popover box
    [self.mapPopover dismissPopoverAnimated:YES];
}

- (void)deselectAnnotation
{
    for(id<MKAnnotation> annotation in [mapView selectedAnnotations]) {
        [mapView deselectAnnotation:annotation animated:YES];
    }
}

// called when a new destination location was added
- (void)displayNewLocationAtIndex:(NSInteger)index
{
    RoadtripLocation* loc = [self.roadtripModel.locationArray objectAtIndex:index];
    [loc setSearch:false];
    [mapView addAnnotation:loc];
}

// send out notification to add this location to current list of locations
- (void)postLocationSelectedNotificationWithLocation:(RoadtripLocation*)location
{
    NSString *notificationName = LOCATION_SELECTED_NOTIFICATION;
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:location, NOTIFICATION_LOCATION_KEY,
                                NOTIFICATION_MAP_SOURCE, NOTIFICATION_SELECTED_SOURCE, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

- (void)postDeselectNotification
{
    NSString *notificationName = LOCATION_DESELECTED_NOTIFICATION;
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                NOTIFICATION_MAP_SOURCE, NOTIFICATION_SELECTED_SOURCE, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

#pragma mark Routing functions
/* This will get the route coordinates from the google api. */
- (NSArray*)getRoutePointFrom:(RoadtripLocation *)origin to:(RoadtripLocation *)destination
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError *error;
    NSString* apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"points:\\\"([^\\\"]*)\\\"" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:apiResponse options:0 range:NSMakeRange(0, [apiResponse length])];
    NSString *encodedPoints = [apiResponse substringWithRange:[match rangeAtIndex:1]];
    
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

- (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedString
{
    [encodedString replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, [encodedString length])];
    NSInteger len = [encodedString length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
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
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        printf("\n[%f,", [latitude doubleValue]);
        printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

- (void)drawRoute
{
    int numPoints = [routePoints count];
    if (numPoints > 1)
    {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [routePoints objectAtIndex:i];
            coords[i] = current.coordinate;
        }
        
        objPolyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
        
        [mapView addOverlay:objPolyline];
        [mapView setNeedsDisplay];
    }
}

- (void)centerMap
{
    MKCoordinateRegion region;
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for(int idx = 0; idx < routePoints.count; idx++)
    {
        CLLocation* currentLocation = [routePoints objectAtIndex:idx];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat;
    region.span.longitudeDelta = maxLon - minLon;
    
    [mapView setRegion:region animated:YES];
}

#pragma mark Mapview delegate Functions
- (void)mapView:(MKMapView*)mv regionWillChangeAnimated:(BOOL)animated
{
	routeOverlayView.hidden = YES;
    // we're going to move, so set the flag
    momentumScrolling = true;
}

- (void)mapView:(MKMapView*)mv regionDidChangeAnimated:(BOOL)animated
{
    routeOverlayView.hidden = NO;
	[routeOverlayView setNeedsDisplay];
    // we might want to center again, just incase
    momentumScrolling = false;
}

/* MKMapViewDelegate Meth0d -- for viewForOverlay*/
- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *view = [[MKPolylineView alloc] initWithPolyline:objPolyline];
    view.fillColor = [UIColor blackColor];
    view.strokeColor = [UIColor blackColor];
    view.lineWidth = 4;
    return view;
}

// show annotations on each placemarks
- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *mapviewId = @"MapViewAnnotation";
    static NSString *routeId = @"RouteAnnotation";
    if ([annotation isKindOfClass:[RoadtripLocation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:mapviewId];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:mapviewId];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.canShowCallout = NO;
        
        // we want search annotation to be red, and regular destination annotation to be blue
        if(![(RoadtripLocation*)annotation search]) {
            annotationView.pinColor = MKPinAnnotationColorGreen;
            annotationView.animatesDrop = NO;
        } else {
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
        }
        
        return annotationView;
    }
    
    return nil;
}

// catch annotation view to make our own callout
-(void)mapView:(MKMapView *)mv didSelectAnnotationView:(MKAnnotationView *)view
{
    // if it's a search annotation, open popover by default
    RoadtripLocation* annotation = (RoadtripLocation*)(view.annotation);
    if([annotation search]) {
        // the annotation is actually just the roadtrip location class acting as delegate
        MapPopoverViewController *vc = [[MapPopoverViewController alloc] initWithLocation:view.annotation];
        
        
        self.mapPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
        self.mapPopover.delegate = self;    // we need to assign ourself as delegate to catch dismiss popover action

        //size as needed
        self.mapPopover.popoverContentSize = CGSizeMake(240, 250);

        //show the popover next to the annotation view (pin)
        [self.mapPopover presentPopoverFromRect:view.bounds inView:view
            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        // tell model that the user has selected something from the map
        [self postLocationSelectedNotificationWithLocation:annotation];
        
        // make the selected popover
        SelectedPopoverViewController *vc = [[SelectedPopoverViewController alloc] initWithLocation:view.annotation];
        
        
        self.mapPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
        self.mapPopover.delegate = self;    // we need to assign ourself as delegate to catch dismiss popover action

        //size as needed
        self.mapPopover.popoverContentSize = CGSizeMake(240, 300);

        //show the popover next to the annotation view (pin)
        [self.mapPopover presentPopoverFromRect:view.bounds inView:view
            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark Popover delegate functions
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self deselectAnnotation];
    
    // we also want to deselect the currently selected location
    [self postDeselectNotification];
}

@end
