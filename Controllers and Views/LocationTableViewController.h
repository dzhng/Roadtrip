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
#import "RouteTableCell.h"
#import "RoadtripLocation.h"
#import "RoadtripModel.h"
#import "AppModel.h"

@interface LocationTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    bool editMode;
    RoadtripModel* model;
}

@property (strong, nonatomic) IBOutlet LocationTableView *tableView;

- (void)displayNewLocationAtIndex:(NSInteger)index;
- (void)selectLocation:(RoadtripLocation*)location;
- (void)deselectAllRows;
- (void)enableLocationRearrange;
- (void)doneLocationRearrange;

// reload everything from model
- (void)resetLocationsAndRoutes;

@end
