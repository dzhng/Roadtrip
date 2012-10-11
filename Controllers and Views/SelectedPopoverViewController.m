//
//  SelectedPopoverViewController.m
//  Roadtrip
//
//  Created by David Zhang on 10/5/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "SelectedPopoverViewController.h"
#import "MapConstants.h"

@interface SelectedPopoverViewController ()

@end

@implementation SelectedPopoverViewController

- (id)initWithLocation:(RoadtripLocation*)location
{
    self = [super init];
    if(self) {
        [self setLocation:location];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set coordinate and label text
    self.locationTitle.text = self.location.title;
    self.locationSubtitle.text = self.location.subtitle;
    [self.miniMap setRegion:MKCoordinateRegionMakeWithDistance(self.location.coordinate,
                                                               MAP_POPOVER_ZOOM, MAP_POPOVER_ZOOM) animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)navigateButtonPressed:(id)sender
{
    // start the maps app navigating to this location
    MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:
                          [[MKPlacemark alloc] initWithCoordinate:self.location.coordinate
                                                addressDictionary:self.location.addressDictionary]];
    NSDictionary* launchKeys = [NSDictionary dictionaryWithObjectsAndKeys:
                                    MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey,
                                    nil];
    [mapItem openInMapsWithLaunchOptions:launchKeys];
}

- (IBAction)searchButtonPressed:(id)sender
{
}

@end
