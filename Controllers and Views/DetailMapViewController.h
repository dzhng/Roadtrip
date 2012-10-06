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
#import "RoadtripModel.h"
#import "MapPopoverViewController.h"
#import "SelectedPopoverViewController.h"

@interface DetailMapViewController : UIViewController <UIPopoverControllerDelegate, MKMapViewDelegate>
{
    bool momentumScrolling;
    
    // mapview variables
    MKMapView *mapView;
    
    // array of MKPolyline storing all the overlays used for routing
    NSArray* routeOverlays;
}

// model object
@property (retain, nonatomic) RoadtripModel* roadtripModel;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) UIPopoverController *mapPopover;

- (void)update;
- (void)updateSearchLocations;
- (void)centerMapOnLocation:(RoadtripLocation*)location;
- (void)removeDirectionLocations;
- (void)removeSearchLocations;
- (void)removeSearchLocation:(RoadtripLocation*)location;
- (void)deselectAnnotation;
- (void)displayNewLocationAtIndex:(NSInteger)index;

// routing methods
- (void)drawRoute:(NSArray*)routePoints;
- (void)centerMapOnRoute:(NSArray*)routePoints;

@end
