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

- (void)postAddLocationsNotification;

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // custom initializations
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set coordinate and label text
    self.locationTitle.text = self.location.title;
    self.locationSubtitle.text = self.location.subtitle;
    [self.miniMap setRegion:MKCoordinateRegionMakeWithDistance([self.location coordinate],
                                                   MAP_POPOVER_ZOOM, MAP_POPOVER_ZOOM) animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// send out notification to add this location to current list of locations
- (void)postAddLocationsNotification
{
    NSString *notificationName = ADD_LOCATIONS_NOTIFICATION;
    NSString *key = NOTIFICATION_LOCATION_KEY;
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.location forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

- (IBAction)addDestinationPressed:(id)sender {
    // send a message to everyone that a location was added
    [self postAddLocationsNotification];
}

@end
