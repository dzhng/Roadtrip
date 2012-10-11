//
//  RoadtripViewController.m
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripViewController.h"

// minimum height for the size of table interaction space in pixels
#define TABLE_MIN_HEIGHT        200

@interface RoadtripViewController ()

@end

@implementation RoadtripViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Get rid of ugly gradient on search bar
    for (UIView *searchSubview in self.searchBarView.subviews) {
        if (![searchSubview isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            [searchSubview setHidden:YES];
            [searchSubview setOpaque:NO];
            [searchSubview setAlpha:0];
        }
    }
    
    // draw backgrounds for settings and add destination panels
    //self.settingsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"YourImage.png"]];
    //self.searchBackgoundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"YourImage.png"]];
    
    // pass location array to table and map view for display
    for(id vc in self.childViewControllers) {
        [vc setRoadtripModel:self.roadtripModel];
        if([vc isKindOfClass:[DetailMapViewController class]]) {
            mapController = vc;
        } else if([vc isKindOfClass:[LocationTableViewController class]]) {
            tableController = vc;
        }
    }
    
    // resize content table to fit
    [self resizeTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rearrangePressed:(id)sender
{
}

- (IBAction)startTripPressed:(id)sender
{
}

// resize the table container to fit cells
- (void)resizeTable
{
    // resize table view
    CGSize size = tableController.tableView.contentSize;
    NSLog(@"new height: %f", size.height);
    self.tableContainer.frame = CGRectMake(0, 0, size.width, size.height + TABLE_MIN_HEIGHT);
    
    // redraw background
    [tableController.tableView setNeedsDisplay];
}

#pragma mark Search Bar delegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // grab address text
    NSString* address = [self.searchBarView text];
    [self.roadtripModel geocodeWithAddress: address];
}

#pragma mark model delegate methods
- (void)searchDone:(NSMutableArray *)searchData
{
    // update map view
    [mapController updateSearchLocations];

    // hide the keyboard
    [self.searchBarView resignFirstResponder];
}

- (void)locationInserted:(RoadtripLocation*)location AtIndex:(NSInteger)index
{
    // deselect the map popover box
    [mapController deselectAnnotation];
    // remove this search location from annotation
    [mapController removeSearchLocation:location];
    
    // clear search bar
    self.searchBarView.text = @"";
    
    // add new annotation to map and table
    [mapController displayNewLocationAtIndex:index];
    [tableController displayNewLocationAtIndex:index];
   
    [self resizeTable];
}

- (void)handleSelectedFromTable:(id)selected
{
    // hide the keyboard
    [self.searchBarView resignFirstResponder];
    
    if ([selected isKindOfClass:[RoadtripLocation class]]) {
        // since we pressed on it from the table, we should center the map view to the pin
        [mapController centerMapOnLocation:selected];
    } else if([selected isKindOfClass:[RoadtripRoute class]]) {
        [mapController centerMapOnRoute:selected];
    }
}

- (void)handleSelectedFromMap:(id)selected
{
    // hide the keyboard
    [self.searchBarView resignFirstResponder];
    
    if ([selected isKindOfClass:[RoadtripLocation class]]) {
        // select row on table
        [tableController selectLocation:selected];
    }
}

- (void)handleDeselect
{
    // deselect from table row
    [tableController deselectAllRows];
}

- (void)displayRoutes:(NSArray *)routes
{
    // tell the map controller to display
    [mapController drawRoutes:routes];
}

@end
