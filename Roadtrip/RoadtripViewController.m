//
//  RoadtripViewController.m
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RoadtripViewController.h"
#import "MapConstants.h"

// minimum height for the size of table interaction space in pixels
#define TABLE_MIN_HEIGHT        40
// extra height to leave off of table height on bottom
#define TABLE_HEIGHT_PADDING    100

@interface RoadtripViewController ()

@end

@implementation RoadtripViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set model
    model = [[AppModel model] currentRoadtrip];
    model.delegate = self;
    
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
        if([vc isKindOfClass:[DetailMapViewController class]]) {
            mapController = vc;
        } else if([vc isKindOfClass:[LocationTableViewController class]]) {
            tableController = vc;
        }
    }
    
    // dont start in table edit mode
    editMode = false;
    // change edit button
    [self.editButton setTitle:@"Done" forState:UIControlStateSelected];
    
    [self resizeTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rearrangePressed:(id)sender
{
    if(editMode) {
        editMode = false;
        
        // tell table view to show routing cells again
        [tableController doneLocationRearrange];
        
        // set button
        [self.editButton setSelected:NO];
    } else {
        editMode = true;
        
        // tell table view to hide all route cells
        [tableController enableLocationRearrange];
        
        // set button
        [self.editButton setSelected:YES];
    }
}

- (IBAction)startTripPressed:(id)sender
{
    RoadtripLocation* location = [model.locationArray objectAtIndex:0];
    // start the maps app navigating to next location
    MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:
                          [[MKPlacemark alloc] initWithCoordinate:[location coordinate]
                                                addressDictionary:[location addressDictionary]]];
    NSDictionary* launchKeys = [NSDictionary dictionaryWithObjectsAndKeys:
                                MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey,
                                nil];
    [mapItem openInMapsWithLaunchOptions:launchKeys];
}

- (IBAction)backPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// resize the table container to fit cells
- (void)resizeTable
{
    // resize table view
    CGRect windowSize = [[UIScreen mainScreen] bounds];
    CGFloat windowHeight = windowSize.size.height;
    // calculate table height
    CGFloat height = 100*[model.locationArray count] + 40*[model.routeArray count];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation ==  UIInterfaceOrientationLandscapeLeft){
        windowHeight = windowSize.size.width;
    }

    windowHeight -= TABLE_HEIGHT_PADDING;
    self.tableContainer.frame = CGRectMake(0, 0, 300,
           ((height + TABLE_MIN_HEIGHT > windowHeight) ? windowHeight : height + TABLE_MIN_HEIGHT));
    
    // redraw background
    [tableController.tableView setNeedsDisplay];
}

#pragma mark Search Bar delegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // grab address text
    NSString* address = [self.searchBarView text];
    [model geocodeWithAddress: address];
}

#pragma mark model delegate methods
- (void)searchDone:(NSMutableArray *)searchData
{
    // update map view
    [mapController updateSearchLocations];

    // hide the keyboard
    [self.searchBarView resignFirstResponder];
}

- (void)locationInserted:(RoadtripLocation*)location atIndex:(NSInteger)index
{
    // deselect the map popover box
    [mapController deselectAnnotation];
    // remove this search location from annotation
    [mapController removeLocation:location];
    
    // clear search bar
    self.searchBarView.text = @"";
    
    // add new annotation to map and table
    [mapController displayNewLocationAtIndex:index];
    [tableController displayNewLocationAtIndex:index];
   
    [self resizeTable];
}

- (void)locationDeleted:(RoadtripLocation *)location withRoute:(RoadtripRoute *)route atIndex:(NSInteger)index
{
    // remove annotation
    [mapController removeLocation:location];
    // remove route
    if(route != nil) {
        [mapController removeRoute:route];
    }
    
    [self resizeTable];
}

- (void)handleSelectedFromTable:(id)selected
{
    // hide the keyboard
    [self.searchBarView resignFirstResponder];
    
    // dismiss popover
    [mapController.mapPopover dismissPopoverAnimated:true];
    
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

- (void)reloadLocationsAndRoutes
{
    // deselect any popovers
    [mapController deselectAnnotation];
    
    // call reset functions
    [mapController resetLocationsAndRoutes];
    [tableController resetLocationsAndRoutes];
    
    // resize table view to fit
    [self resizeTable];
}

@end
