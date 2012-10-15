//
//  MapPopoverViewController.m
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "MapPopoverViewController.h"
#import "ModelNotifications.h"
#import "MapConstants.h"

@interface MapPopoverViewController ()

@end

@implementation MapPopoverViewController

- (id)initWithLocation:(RoadtripLocation*)location
{
    self = [super init];
    if(self) {
        [self setLocation:location];
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

- (IBAction)addDestinationPressed:(id)sender {
    // send a message to everyone that a location was added
    [[[AppModel model] currentRoadtrip] locationAdded:self.location];
}

@end
