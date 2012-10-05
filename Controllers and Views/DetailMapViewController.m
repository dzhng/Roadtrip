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
        travelMode = UICGTravelModeDriving;
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
    
    routeOverlayView = [[UICRouteOverlayMapView alloc] initWithMapView:mapView];
    
    directions = [UICGDirections sharedDirections];
    directions.delegate = self;
    
    if (directions.isInitialized) {
		[self update];
	}
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
    
    UICGDirectionsOptions *options = [[UICGDirectionsOptions alloc] init];
	options.travelMode = travelMode;
	if ([wayPoints count] > 0) {
		NSArray *routePoints = [NSArray arrayWithObject:startPoint];
		routePoints = [routePoints arrayByAddingObjectsFromArray:wayPoints];
		routePoints = [routePoints arrayByAddingObject:endPoint];
		[directions loadFromWaypoints:routePoints options:options];
	} else {
		[directions loadWithStartPoint:startPoint endPoint:endPoint options:options];
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

#pragma mark UICGDirections Delegate Methods

- (void)directionsDidFinishInitialize:(UICGDirections *)directions {
	[self update];
}

- (void)directions:(UICGDirections *)directions didFailInitializeWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Directions" message:[error localizedFailureReason] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
}

- (void)directionsDidUpdateDirections:(UICGDirections *)dir {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// Overlay polylines
	UICGPolyline *polyline = [dir polyline];
	NSArray *routePoints = [polyline routePoints];
	[routeOverlayView setRoutes:routePoints];
	
	// Add annotations
	UICRouteAnnotation *startAnnotation = [[UICRouteAnnotation alloc]
                                           initWithCoordinate:[[routePoints objectAtIndex:0] coordinate]
                                                        title:startPoint
                                              annotationType:UICRouteAnnotationTypeStart];
    
	UICRouteAnnotation *endAnnotation = [[UICRouteAnnotation alloc]
                                         initWithCoordinate:[[routePoints lastObject] coordinate]
                                                      title:endPoint
                                            annotationType:UICRouteAnnotationTypeEnd];
    
	if ([wayPoints count] > 0) {
		NSInteger numberOfRoutes = [dir numberOfRoutes];
		for (NSInteger index = 0; index < numberOfRoutes; index++) {
			UICGRoute *route = [dir routeAtIndex:index];
			CLLocation *location = [route endLocation];
			UICRouteAnnotation *annotation = [[UICRouteAnnotation alloc]
                                              initWithCoordinate:[location coordinate]
                                                           title:[[route endGeocode] objectForKey:@"address"]
                                                 annotationType:UICRouteAnnotationTypeWayPoint];
            
			[mapView addAnnotation:annotation];
		}
	}
    
	[mapView addAnnotations:[NSArray arrayWithObjects:startAnnotation, endAnnotation, nil]];
}

- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Directions" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
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
    } else if ([annotation isKindOfClass:[UICRouteAnnotation class]]) {
		MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:routeId];
		if(!pinAnnotation) {
			pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:routeId];
		}
		
		if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeStart) {
			pinAnnotation.pinColor = MKPinAnnotationColorGreen;
		} else if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeEnd) {
			pinAnnotation.pinColor = MKPinAnnotationColorRed;
		} else {
			pinAnnotation.pinColor = MKPinAnnotationColorPurple;
		}
		
		pinAnnotation.animatesDrop = YES;
		pinAnnotation.enabled = YES;
		pinAnnotation.canShowCallout = YES;
		return pinAnnotation;
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
