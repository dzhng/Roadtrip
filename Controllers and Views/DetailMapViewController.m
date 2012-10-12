//
//  DetailMapViewController.m
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "DetailMapViewController.h"
#import "RoadtripViewController.h"
#import "ModelNotifications.h"
#import "MapConstants.h"

@interface DetailMapViewController ()

- (void)postLocationSelectedNotificationWithLocation:(RoadtripLocation*)location;
- (void)postDeselectNotification;
- (void)routeUpdatedNotification:(NSNotification*)notification;

@end

@implementation DetailMapViewController


- (void)viewWillAppear:(BOOL)animated
{
    // stores if we're currently momentum scrolling on the map
    momentumScrolling = false;
    // stores if we manually selected a location via table cell
    manualSelect = false;
    
    // initialize mapview
    mapView = [[MKMapView alloc] initWithFrame:self.contentView.frame];
    mapView.delegate = self;
    mapView.showsUserLocation = NO;
    [mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.contentView addSubview:mapView];
        
    // watch route updated notification
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(routeUpdatedNotification:)
        name:ROUTE_UPDATED_NOTIFICATION
        object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Detail map received memory warning");
}

// redraw everything, use this when loading up the map
- (void)resetLocationsAndRoutes
{
    [self removeDirectionLocations];
    
    // update the map with all the current locations
    NSArray* locations = self.roadtripModel.locationArray;
    
    for(RoadtripLocation* loc in locations) {
        [loc setSearch:false];
        [mapView addAnnotation:loc];
    }
    
    NSArray* routes = self.roadtripModel.routeArray;
    if(routes) {
        // draw all routes
        [self drawRoutes:routes];
        
        // just center on the first route for now
        [self centerMapOnRoute:[routes objectAtIndex:0]];
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
    self.roadtripModel.selected = center;
    
    // update map with annotations of search locations
    for(RoadtripLocation* loc in locations) {
        // set the locations as search locations
        [loc setSearch:true];
        [mapView addAnnotation:loc];
    }
}

- (void)centerMapOnLocation:(RoadtripLocation*)location
{
    MKCoordinateRegion newRegion =  MKCoordinateRegionMakeWithDistance(location.coordinate, MAP_ZOOM, MAP_ZOOM);
    [mapView setRegion:newRegion animated:NO];
    
    // set the flag that this is a manual select, so we don't send any notifications
    manualSelect = true;
    [mapView selectAnnotation:location animated:YES];
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

- (void)centerMapOnRoute:(RoadtripRoute*)route
{
    NSArray* routePoints = route.routePoints;
    
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
    
    region.span.latitudeDelta  = ROUTE_ZOOM*(maxLat - minLat);
    region.span.longitudeDelta = ROUTE_ZOOM*(maxLon - minLon);
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = ((maxLon + minLon) / 2) - 0.3*(maxLon - minLon);
    
    [mapView setRegion:region animated:YES];
}

// reset all the routes on the map
- (void)drawRoutes:(NSArray*)routeArray
{
    // just blanket remove all overlays
    [mapView removeOverlays:mapView.overlays];
    
    // get all overlays
    NSMutableArray* overlays = [[NSMutableArray alloc] init];
    for(RoadtripRoute* route in routeArray) {
        [overlays addObjectsFromArray:[route routeOverlays]];
    }
    [mapView addOverlays:overlays];
    [mapView setNeedsDisplay];
}

- (void)routeUpdatedNotification:(NSNotification *)notification
{
    // grab the the route
    NSDictionary *dictionary = [notification userInfo];
    RoadtripRoute* route = [dictionary valueForKey:NOTIFICATION_ROUTE_KEY];
    
    // remove old overlays from map
    [mapView removeOverlays:route.oldRouteOverlays];
    
    // add new overlays to map
    [mapView addOverlays:route.routeOverlays];
    [mapView setNeedsDisplay];
}

#pragma mark Mapview delegate Functions
- (void)mapView:(MKMapView*)mv regionWillChangeAnimated:(BOOL)animated
{
    // we're going to move, so set the flag
    momentumScrolling = true;
}

- (void)mapView:(MKMapView*)mv regionDidChangeAnimated:(BOOL)animated
{
    // we might want to center again, just incase
    momentumScrolling = false;
}

// show navigation overlay
- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *view = [[MKPolylineView alloc] initWithOverlay:overlay];
    view.fillColor = [UIColor blueColor];
    view.strokeColor = [UIColor blueColor];
    view.lineWidth = 6;
    view.alpha = 0.5;
    return view;
}

// show annotations on each placemarks
- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *mapviewId = @"MapViewAnnotation";
    //static NSString *routeId = @"RouteAnnotation";
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
        if(!manualSelect) {
            // tell model that the user has selected something from the map
            [self postLocationSelectedNotificationWithLocation:annotation];
        }
        manualSelect = false;
        
        // make the selected popover
        SelectedPopoverViewController *vc = [[SelectedPopoverViewController alloc] initWithLocation:view.annotation];
        
        self.mapPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
        self.mapPopover.delegate = self;    // we need to assign ourself as delegate to catch dismiss popover action

        // tableviews should ignore popover dismiss actions
        RoadtripViewController* parent = (RoadtripViewController*)self.parentViewController;
        self.mapPopover.passthroughViews = [[NSArray alloc] initWithObjects:parent.tableContainer, nil];

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
