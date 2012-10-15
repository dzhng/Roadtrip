//
//  MapPopoverViewController.h
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailMapViewController.h"
#import "AppModel.h"

@interface MapPopoverViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *miniMap;
@property (weak, nonatomic) IBOutlet UILabel *locationTitle;
@property (weak, nonatomic) IBOutlet UILabel *locationSubtitle;

@property (retain, nonatomic) RoadtripLocation* location;

- (id)initWithLocation:(RoadtripLocation*)location;

- (IBAction)addDestinationPressed:(id)sender;

@end
