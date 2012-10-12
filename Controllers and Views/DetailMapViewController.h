//
//  DetailMapViewController.h
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RoadtripLocation.h"
#import "RoadtripRoute.h"
#import "RoadtripModel.h"
#import "MapPopoverViewController.h"
#import "SelectedPopoverViewController.h"

@interface DetailMapViewController : UIViewController <UIPopoverControllerDelegate, MKMapViewDelegate>
{
    bool momentumScrolling;
    bool manualSelect;  // stores if we're manually selecting a location via table cell
    
    // mapview variables
    MKMapView *mapView;
}

// model object
@property (retain, nonatomic) RoadtripModel* roadtripModel;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) UIPopoverController *mapPopover;

// reset everything. use this when loading a roadtrip
- (void)resetLocationsAndRoutes;

// called when the model found some search locations
- (void)updateSearchLocations;

// move map to the input location and select the location to show popover
- (void)centerMapOnLocation:(RoadtripLocation*)location;

// remove all the destination locations on the map
- (void)removeDirectionLocations;

// remove all the search locations on the map
- (void)removeSearchLocations;

// remove the indicated search location on the map and disable popover
- (void)removeSearchLocation:(RoadtripLocation*)location;

// deselect all annotations on the map.
// Called when popover is dismissed, we just want to dismiss annotation with it
- (void)deselectAnnotation;

// called when a new location is added. make a new destination annotation
- (void)displayNewLocationAtIndex:(NSInteger)index;

// routing methods
// draw input routes on map, input is an array of RoadtripRoute
- (void)drawRoutes:(NSArray*)routeArray;

// center map on one specific route, input is an array of CLLocations
- (void)centerMapOnRoute:(RoadtripRoute*)route;

@end
