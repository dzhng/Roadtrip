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
        // Custom initialization
        popoverNeedsDisplay = false;
        regionHasNotMovedSinceCentering = true;
        
        // stores if we're currently momentum scrolling on the map
        momentumScrolling = false;
        // if we want to jump to a location, we need to wait for momentum scrolling to finish first
        // this flag sets that we're waiting for momentum to finish
        waitForMomentumFinish = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update
{
    // update the map with all the current locations
    NSArray* locations = self.roadtripModel.locationArray;
    
    for(RoadtripLocation* loc in locations) {
        [loc setSearch:false];
        [self.mapView addAnnotation:loc];
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
        [self.mapView addAnnotation:loc];
    }
}

- (void)centerMapOnLocation:(RoadtripLocation*)location
{
    MKCoordinateRegion newRegion =  MKCoordinateRegionMakeWithDistance([location coordinate], MAP_ZOOM, MAP_ZOOM);
    [self.mapView setRegion:newRegion animated:NO];
    [self.mapView selectAnnotation:location animated:YES];
    NSLog(@"%d", location.search);
}

- (void)removeSearchLocations
{
    // first remove all original search annotations
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if([annotation isKindOfClass:[RoadtripLocation class]] && [(RoadtripLocation*)annotation search])
            [self.mapView removeAnnotation:annotation];
    }
}

- (void)removeSearchLocation:(RoadtripLocation*)location
{
    // remove the pin
    [self.mapView removeAnnotation:location];
    // also remove popover box
    [self.mapPopover dismissPopoverAnimated:YES];
}

- (void)deselectAnnotation
{
    for(id<MKAnnotation> annotation in [self.mapView selectedAnnotations]) {
        [self.mapView deselectAnnotation:annotation animated:YES];
    }
}

// called when a new destination location was added
- (void)displayNewLocationAtIndex:(NSInteger)index
{
    RoadtripLocation* loc = [self.roadtripModel.locationArray objectAtIndex:index];
    [loc setSearch:false];
    [self.mapView addAnnotation:loc];
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

#pragma mark Delegate Functions
- (void)mapView:(MKMapView*)mapView regionWillChangeAnimated:(BOOL)animated
{
    // we're going to move, so set the flag
    momentumScrolling = true;
}

- (void)mapView:(MKMapView*)mapView regionDidChangeAnimated:(BOOL)animated
{
    // we might want to center again, just incase
    momentumScrolling = false;
}

// show annotations on each placemarks
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier = @"MapViewAnnotation";
    if ([annotation isKindOfClass:[RoadtripLocation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
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
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
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

// popover delegate functions
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self deselectAnnotation];
    
    // we also want to deselect the currently selected location
    [self postDeselectNotification];
}

@end
