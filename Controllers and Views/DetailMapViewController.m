//
//  DetailMapViewController.m
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "DetailMapViewController.h"
#import "RoadtripViewController.h"  // this import should stay here to avoid circular imports
#import "ModelNotifications.h"
#import "MapConstants.h"

@interface DetailMapViewController ()

- (void)routeUpdatedNotification:(NSNotification*)notification;

@end

@implementation DetailMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    // set model
    model = [[AppModel model] currentRoadtrip];
    
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
    [self removeSearchLocations];
    
    // update the map with all the current locations
    NSArray* locations = model.locationArray;
    
    for(RoadtripLocation* loc in locations) {
        [loc setSearch:false];
        [mapView addAnnotation:loc];
    }
    
    NSArray* routes = model.routeArray;
    if(routes) {
        // draw all routes
        [self drawRoutes:routes];
    }
}

- (void)updateSearchLocations
{
    [self removeSearchLocations];
    
    // get locations
    NSArray* locations = model.searchLocationArray;
    
    // center the map on the first search location,
    // we need to center first before adding annotations for the popover to show
    RoadtripLocation* center = [locations objectAtIndex:0];
    [center setSearch:true];
    [self centerMapOnLocation:center];
    model.selected = center;
    
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

- (void)removeLocation:(RoadtripLocation*)location
{
    // remove the pin
    [mapView removeAnnotation:location];
    // also remove popover box
    [self.mapPopover dismissPopoverAnimated:YES];
}

- (void)removeRoute:(RoadtripRoute*)route
{
    // remove overlay
    [mapView removeOverlay:route.currentRouteOverlay];
    [mapView setNeedsDisplay];
}

- (void)deselectAnnotation
{
    for(id<MKAnnotation> annotation in [mapView selectedAnnotations]) {
        [mapView deselectAnnotation:annotation animated:YES];
    }
}

// called when a new destination location was added
- (void)displayNewLocation:(RoadtripLocation*)location
{
    // change annotation type
    [location setSearch:false];
    [self removeSearchLocations];
    
    // add new annotation
    [mapView addAnnotation:location];
}

- (void)centerMapOnRoute:(RoadtripRoute*)route
{
    [mapView setRegion:[route centerRegion] animated:YES];
}

// reset all the routes on the map
- (void)drawRoutes:(NSArray*)routeArray
{
    // just blanket remove all overlays
    [mapView removeOverlays:mapView.overlays];
    
    // get all overlays
    NSMutableArray* overlays = [[NSMutableArray alloc] init];
    for(RoadtripRoute* route in routeArray) {
        MKPolyline* overlay = [route routeOverlay];
        if(overlay) {
            [overlays addObject:overlay];
        }
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
    [mapView removeOverlay:route.currentRouteOverlay];
    
    // add new overlays to map
    if([route routeOverlay]) {
        [mapView addOverlay:[route routeOverlay]];
        [mapView setNeedsDisplay];
    } else {
        NSLog(@"Error: Route overlay does not exist");
    }
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
        self.mapPopover.popoverContentSize = CGSizeMake(240, 336);

        //show the popover next to the annotation view (pin)
        [self.mapPopover presentPopoverFromRect:view.bounds inView:view
            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        if(!manualSelect) {
            // tell model that the user has selected something from the map
            [[[AppModel model] currentRoadtrip] locationSelected:annotation
                                                      fromSource:NOTIFICATION_MAP_SOURCE];
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
        self.mapPopover.popoverContentSize = CGSizeMake(240, 250);

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
    [[[AppModel model] currentRoadtrip] locationDeselected:nil];
}

@end
