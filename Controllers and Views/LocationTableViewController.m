//
//  LocationTableViewController.m
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "LocationTableViewController.h"

@interface LocationTableViewController ()

@end

@implementation LocationTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // dont go into edit mode by default
        editMode = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // hide the table by default, we only want to see the cells
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayNewLocationAtIndex:(NSInteger)index
{
    // if it's not the first location, we need another row for the route
    if(index > 0) {
        [self.tableView insertRowsAtIndexPaths:
             [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2*index-1 inSection:0],
                    [NSIndexPath indexPathForRow:2*index inSection:0], nil]
                    withRowAnimation:UITableViewRowAnimationTop];
    } else {    // first locaiton, just insert one row
        [self.tableView insertRowsAtIndexPaths:
             [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                   withRowAnimation:UITableViewRowAnimationTop];
    }
}

// called by the map view to manually select table cells
// this class shouldn't need to call this, since when the user touches cell, they're auto selected
- (void)selectLocation:(RoadtripLocation*)location
{
    // should only be able to select in editmode
    for(int i = 0; i < [self.roadtripModel.locationArray count]; i++) {
        RoadtripLocation* loc = [self.roadtripModel.locationArray objectAtIndex:i];
        if(loc == location) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i*2 inSection:0]
                                        animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            break;
        }
    }
}

- (void)deselectAllRows
{
    for(int i = 0; i < [self.roadtripModel.locationArray count] + [self.roadtripModel.routeArray count]; i++) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
    }
}

- (void)enableLocationRearrange
{
    if([self.roadtripModel.locationArray count] > 1) {
        // first set flag to only show location cells
        editMode = true;
        // then delete the routing cells
        NSMutableArray* indexPath = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.roadtripModel.routeArray count]; i++) {
            [indexPath addObject:[NSIndexPath indexPathForRow:2*i+1 inSection:0]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPath withRowAnimation:YES];
        
        // set table to edit mode
        [self.tableView setEditing:true animated:true];
        
        // TODO: gray out map view so there's no interactions there
    }
}

- (void)doneLocationRearrange
{
    // unset edit mode flag
    editMode = false;
    
    // set table to non-edit mode
    [self.tableView setEditing:false animated:true];
    
    // add routing cells back in
    NSMutableArray* indexPath = [[NSMutableArray alloc] init];
    for(int i = 0; i < [self.roadtripModel.routeArray count]; i++) {
        [indexPath addObject:[NSIndexPath indexPathForRow:2*i+1 inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(LocationTableView *)tableView
{
    // Return the number of sections.
    return 1;   // just one section, which is all the destinations
}

- (NSInteger)tableView:(LocationTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // the table is both location and route arrays
    if(editMode) {
        return [self.roadtripModel.locationArray count];
    } else {
        return 2*[self.roadtripModel.locationArray count]-1;
    }
}

- (UITableViewCell *)tableView:(LocationTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *locationId = @"LocationCell";
    static NSString *routeId = @"RouteCell";
    int row = [indexPath row];
    
    if(editMode) {
        LocationTableCell *cell = [tableView dequeueReusableCellWithIdentifier:locationId];
        if (cell == nil) {
            cell = [[LocationTableCell alloc]
                    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:locationId];
        }
        RoadtripLocation* loc = [self.roadtripModel.locationArray objectAtIndex:row];
        [cell updateLocation:loc];
        return cell;
    } else {
        // location cell
        if(row == 0 || row % 2 == 0) {
            LocationTableCell *cell = [tableView dequeueReusableCellWithIdentifier:locationId];
            if (cell == nil) {
                cell = [[LocationTableCell alloc]
                        initWithStyle:UITableViewCellStyleDefault reuseIdentifier:locationId];
            }
            int modelRow = row / 2;
            RoadtripLocation* loc = [self.roadtripModel.locationArray objectAtIndex:modelRow];
            [cell updateLocation:loc];
            return cell;
            
        } else {    // route cell
            RouteTableCell *cell = [tableView dequeueReusableCellWithIdentifier:routeId];
            if (cell == nil) {
                cell = [[RouteTableCell alloc]
                        initWithStyle:UITableViewCellStyleDefault reuseIdentifier:routeId];
            }
            int modelRow = (row-1) / 2;
            RoadtripRoute* loc = [self.roadtripModel.routeArray objectAtIndex:modelRow];
            [cell updateRoute:loc];
            return cell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    if (editMode) {
        return 100;
    } else {
        // location cell
        if(row == 0 || row % 2 == 0) {
            return 100;
        } else {
            return 40;
        }
    }
}

// we only want to rearrange, not delete
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    int from = [fromIndexPath row];
    int to = [toIndexPath row];
    
    // rearrange the location array
    NSMutableArray* ar = self.roadtripModel.locationArray;
    
    id obj = [ar objectAtIndex:from];
    [ar removeObjectAtIndex:from];
    if (to >= [ar count]) {
        [ar addObject:obj];
    } else {
        [ar insertObject:obj atIndex:to];
    }
}

@end
