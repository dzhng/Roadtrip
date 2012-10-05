//
//  RoadtripViewController.h
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailMapViewController.h"
#import "LocationTableViewController.h"
#import "RoadtripModel.h"

@interface RoadtripViewController : UIViewController <RoadtripModelDelegate>
{
    // store controllers
    DetailMapViewController* mapController;
    LocationTableViewController* tableController;
}

// model
@property (retain, nonatomic) RoadtripModel *roadtripModel;

// view data
@property (weak, nonatomic) IBOutlet UIView *tableContainer;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarView;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIView *searchBackgoundView;

- (IBAction)rearrangePressed:(id)sender;
- (IBAction)startTripPressed:(id)sender;

@end
