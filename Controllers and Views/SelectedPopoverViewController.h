//
//  SelectedPopoverViewController.h
//  Roadtrip
//
//  Created by David Zhang on 10/5/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RoadtripLocation.h"

@interface SelectedPopoverViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *miniMap;
@property (weak, nonatomic) IBOutlet UILabel *locationTitle;
@property (weak, nonatomic) IBOutlet UILabel *locationSubtitle;

@property (retain, nonatomic) RoadtripLocation* location;

- (id)initWithLocation:(RoadtripLocation*)location;

- (IBAction)navigateButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;

@end
