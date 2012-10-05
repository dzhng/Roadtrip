//
//  LocationTableViewController.h
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTableView.h"
#import "LocationTableCell.h"
#import "RoadtripLocation.h"
#import "RoadtripModel.h"

@interface LocationTableViewController : UITableViewController

// model object
@property (retain, nonatomic) RoadtripModel* roadtripModel;

@property (strong, nonatomic) IBOutlet LocationTableView *tableView;

- (void)update;
- (void)displayNewLocationAtIndex:(NSInteger)index;
- (void)selectLocation:(RoadtripLocation*)location;
- (void)deselectAllRows;

@end
