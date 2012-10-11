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

- (void)resetLocationsAndRoutes;
- (void)updateSearchLocations;
- (void)centerMapOnLocation:(RoadtripLocation*)location;
- (void)removeDirectionLocations;
- (void)removeSearchLocations;
- (void)removeSearchLocation:(RoadtripLocation*)location;
- (void)deselectAnnotation;
- (void)displayNewLocationAtIndex:(NSInteger)index;

// routing methods
// draw input routes on map, input is an array of RoadtripRoute
- (void)drawRoutes:(NSArray*)routeArray;

// center map on one specific route, input is an array of CLLocations
- (void)centerMapOnRoute:(RoadtripRoute*)route;

@end
