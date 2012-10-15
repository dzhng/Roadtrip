//
//  MainViewController.m
//  Roadtrip
//
//  Created by Zachary Zimbler on 10/13/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

static NSString *cellId = @"RoadtripMap";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // register collection view
    [self.collectionView registerClass:[RoadtripCollectionCell class] forCellWithReuseIdentifier:cellId];
    
    // set layout settings
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)[self.collectionView collectionViewLayout];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(40, 20, 40, 20);
    layout.minimumLineSpacing = 40;
    
    // TODO: Display loading animation
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // do stuff with the user
        [self reloadDataFromDB];
    } else {
        // show the signup or login screen
        PFLogInViewController *login = [[PFLogInViewController alloc] init];
        [self presentModalViewController:login animated:NO];
    }
}

- (void)reloadDataFromDB
{
    NSLog(@"DB Data reloaded");
    // query for objects
    [[AppModel model] getAllRoadtrips];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOutPressed:(id)sender
{
    // first log them out
    [PFUser logOut];
    
    //login view displayed modally
    PFLogInViewController *login = [[PFLogInViewController alloc] init];
    [self presentModalViewController:login animated:YES];
}

#pragma mark Collection View Data Source functions

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    // add extra one for new roadtrip picture
    return [[[AppModel model] roadtrips] count] + 1;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (RoadtripCollectionCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RoadtripCollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if(cell == nil) {
        NSLog(@"Error: Cannot dequeue collection view cell");
    }
    NSInteger row = [indexPath row];
    
    // roadtrip icons
    if(row < [[[AppModel model] roadtrips] count]) {
        // set view settings
        [cell updateRoadtrip:[[[AppModel model] roadtrips] objectAtIndex:row]];
    } else {    // new roadtrip icons
        
    }
    
    return cell;
}

#pragma mark Collection View Delegate functions

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    // check if we're segueing into a new roadtrip or existing
    if(row < [[[AppModel model] roadtrips] count]) {
        // get roadtrip
        RoadtripModel* roadtrip = [[[AppModel model] roadtrips] objectAtIndex:row];
        
        // tell roadtrip to grab locations and routes before segue
        [roadtrip getAllLocationsAndRoutes];
        
        // set current roadtrip
        [[AppModel model] setCurrentRoadtrip:roadtrip];
    } else {    // new roadtrip
        // initialize new roadtrip model, it will be auto set to current roadtrip
        [[AppModel model] newRoadtrip];
    }
    
    // segue into roadtrip model
    [self performSegueWithIdentifier:@"RoadTripChosenSegue" sender:self];
    
}

#pragma mark Collection View Flow Layout functions

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(210, 260);
}

@end
