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
        // Custom initialization
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

- (void)selectLocation:(RoadtripLocation*)location
{
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
    return 2*[self.roadtripModel.locationArray count]-1;
}

- (UITableViewCell *)tableView:(LocationTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *locationId = @"LocationCell";
    static NSString *routeId = @"RouteCell";
    int row = [indexPath row];
    
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
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    // location cell
    if(row == 0 || row % 2 == 0) {
        return 100;
    } else {
        return 40;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
