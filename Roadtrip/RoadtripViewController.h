//
//  RoadtripViewController.h
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTableViewController.h"
#import "DetailMapViewController.h"
#import "RoadtripModel.h"
#import "RoadtripLocation.h"

@interface RoadtripViewController : UIViewController <RoadtripModelDelegate>
{
    // store controllers
    DetailMapViewController* mapController;
    LocationTableViewController* tableController;
    
    // model object for this roadtrip
    RoadtripModel* model;
    
    // store if we're currently in table rearrange mode
    bool editMode;
}

// view data
@property (weak, nonatomic) IBOutlet UIView *tableContainer;
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarView;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIView *searchBackgoundView;

// footer data
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *stopsLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;

- (IBAction)rearrangePressed:(id)sender;
- (IBAction)startTripPressed:(id)sender;
- (IBAction)backPressed:(id)sender;
- (IBAction)mapSwiped:(id)sender;

@end
