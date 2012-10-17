//
//  LocationTableViewController.m
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "LocationTableViewController.h"
#import "ModelNotifications.h"

@interface LocationTableViewController ()

@end

@implementation LocationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // dont go into edit mode by default
    editMode = false;
    
    // we're not manually selecting
    manualSelect = false;
    
    // hide the table by default, we only want to see the cells
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    
    // set model
    model = [[AppModel model] currentRoadtrip];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Location table received memory warning");
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
    // scroll to last view
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2*index inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// called by the map view to manually select table cells
// this class shouldn't need to call this, since when the user touches cell, they're auto selected
- (void)selectLocation:(RoadtripLocation*)location
{
    // should only be able to select in editmode
    for(int i = 0; i < [model.locationArray count]; i++) {
        RoadtripLocation* loc = [model.locationArray objectAtIndex:i];
        if(loc == location) {
            manualSelect = true;
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i*2 inSection:0]
                                        animated:YES scrollPosition:UITableViewScrollPositionBottom];
            break;
        }
    }
}

- (void)deselectAllRows
{
    for(int i = 0; i < [model.locationArray count] + [model.routeArray count]; i++) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
    }
}

- (void)enableLocationRearrange
{
    // first set flag to only show location cells
    editMode = true;
    
    if([model.locationArray count] > 1) {
        // then delete the routing cells
        NSMutableArray* indexPath = [[NSMutableArray alloc] init];
        for (int i = 0; i < [model.routeArray count]; i++) {
            [indexPath addObject:[NSIndexPath indexPathForRow:2*i+1 inSection:0]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPath withRowAnimation:YES];
        
        // TODO: gray out map view so there's no interactions there
    }
    
    // set table to edit mode
    [self.tableView setEditing:true animated:true];
}

- (void)doneLocationRearrange
{
    // unset edit mode flag
    editMode = false;
    
    // set table to non-edit mode
    [self.tableView setEditing:false animated:true];
    
    // set order in db
    for (int i = 0; i < [model.locationArray count]; i++) {
        RoadtripLocation* location = [model.locationArray objectAtIndex:i];
        [location setOrder:i];
        [location sync];
    }
    
    // set routing cells
    if([model.locationArray count] > 1) {
        // add routing cells back in
        NSMutableArray* indexPath = [[NSMutableArray alloc] init];
        NSArray* routes = model.routeArray;
        NSArray* locations = model.locationArray;
        for(int i = 0; i < [routes count]; i++) {
            [indexPath addObject:[NSIndexPath indexPathForRow:2*i+1 inSection:0]];
            
            // reset route start and destinations and recalculate route
            RoadtripRoute* route = [routes objectAtIndex:i];
            [route updateStart:[locations objectAtIndex:i] andEnd:[locations objectAtIndex:i+1]];
            
            // also set order in db
            [route setOrder:i];
            [route sync];
        }
        [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:YES];
    }
}

- (void)resetLocationsAndRoutes
{
    // build index paths
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    NSArray* routes = model.routeArray;
    NSArray* locations = model.locationArray;
    for(int i = 0; i < [routes count] + [locations count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
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
        return [model.locationArray count];
    } else {
        return 2*[model.locationArray count]-1;
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
        RoadtripLocation* loc = [model.locationArray objectAtIndex:row];
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
            RoadtripLocation* loc = [model.locationArray objectAtIndex:modelRow];
            [cell updateLocation:loc];
            return cell;
            
        } else {    // route cell
            RouteTableCell *cell = [tableView dequeueReusableCellWithIdentifier:routeId];
            if (cell == nil) {
                cell = [[RouteTableCell alloc]
                        initWithStyle:UITableViewCellStyleDefault reuseIdentifier:routeId];
            }
            int modelRow = (row-1) / 2;
            RoadtripRoute* loc = [model.routeArray objectAtIndex:modelRow];
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

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int rrow = (row-1)/2;
    if(!(row == 0 || row % 2 == 0)) {
        // make it so we can't select route cell
        if ([model.routeArray objectAtIndex:rrow] != model.selected) {
            // send notification out to model so it knows location has been selected
            [[[AppModel model] currentRoadtrip] routeSelected:[model.routeArray objectAtIndex:rrow]
                                                      fromSource:NOTIFICATION_TABLE_SOURCE];
        }
        // deselect any other cells
        [self deselectAllRows];
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    if(!manualSelect) {
        // location cell
        if(row == 0 || row % 2 == 0) {
            int lrow = row/2;
            if ([model.locationArray objectAtIndex:lrow] != model.selected) {
                // send notification out to model so it knows location has been selected
                [[[AppModel model] currentRoadtrip] locationSelected:[model.locationArray objectAtIndex:lrow]
                                                          fromSource:NOTIFICATION_TABLE_SOURCE];
            }
        } else {    // route cell
            int rrow = (row-1)/2;
            if ([model.routeArray objectAtIndex:rrow] != model.selected) {
                // send notification out to model so it knows location has been selected
                [[[AppModel model] currentRoadtrip] routeSelected:[model.routeArray objectAtIndex:rrow]
                                                          fromSource:NOTIFICATION_TABLE_SOURCE];
            }
        }
    }
    manualSelect = false;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    int from = [fromIndexPath row];
    int to = [toIndexPath row];
    
    // rearrange the location array
    NSMutableArray* ar = model.locationArray;
    
    id obj = [ar objectAtIndex:from];
    [ar removeObjectAtIndex:from];
    if (to >= [ar count]) {
        [ar addObject:obj];
    } else {
        [ar insertObject:obj atIndex:to];
    }
}

// handle table delete cells
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = [indexPath row];
    
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        // tell everyone else to update their views
        [[[AppModel model] currentRoadtrip] locationDeleted:row];
        // remove row
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}

// we only want to delete in edit mode
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (editMode) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

@end
