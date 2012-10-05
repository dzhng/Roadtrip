//
//  RoadtripViewController.m
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripViewController.h"

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
        [vc update];
        if([vc isKindOfClass:[DetailMapViewController class]]) {
            mapController = vc;
        } else if([vc isKindOfClass:[LocationTableViewController class]]) {
            tableController = vc;
        }
    }
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
    
    // add new annotation to map and table
    [mapController displayNewLocationAtIndex:index];
    [tableController displayNewLocationAtIndex:index];
    
}

- (void)handleSelectedFromTable:(RoadtripLocation *)location
{
    // since we pressed on it from the table, we should center the map view to the pin
    [mapController centerMapOnLocation:location];
}

- (void)handleSelectedFromMap:(RoadtripLocation *)location
{
    // select row on table
    [tableController selectLocation:location];
}

- (void)handleDeselect
{
    // deselect from table row
    [tableController deselectAllRows];
}

@end
