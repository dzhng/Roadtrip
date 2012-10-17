//
//  MainViewController.m
//  Roadtrip
//
//  Created by Zachary Zimbler on 10/13/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "MainViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set layout settings
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)[self.collectionView collectionViewLayout];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(40, 20, 40, 20);
    layout.minimumLineSpacing = 40;
    
    // TODO: Display loading animation
}

- (void)viewWillAppear:(BOOL)animated
{
    
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
        login.fields = PFLogInFieldsFacebook | PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton ;
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

- (IBAction)newRoadtripPressed:(id)sender
{
    // make a new model
    [[AppModel model] newRoadtrip];
    
    // segue into map view
    [self performSegueWithIdentifier:@"RoadTripChosenSegue" sender:self];
}

#pragma mark Collection View Data Source functions

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    // add extra one for new roadtrip picture
    return [[[AppModel model] roadtrips] count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (RoadtripCollectionCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"RoadtripMap";

    RoadtripCollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if(cell == nil) {
        NSLog(@"Error: Cannot dequeue collection view cell");
    }
    NSInteger row = [indexPath row];
    
    // run sanity checks
    if(row < [[[AppModel model] roadtrips] count]) {
        // set view settings
        [cell updateRoadtrip:[[[AppModel model] roadtrips] objectAtIndex:row]];
    }
    
    return cell;
}

#pragma mark Collection View Delegate functions

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    // run sanity check first
    if(row < [[[AppModel model] roadtrips] count]) {
        // get roadtrip
        RoadtripModel* roadtrip = [[[AppModel model] roadtrips] objectAtIndex:row];
        // set current roadtrip
        [[AppModel model] setCurrentRoadtrip:roadtrip];
        
        // segue into roadtrip model
        [self performSegueWithIdentifier:@"RoadTripChosenSegue" sender:self];
    }
}

#pragma mark Collection View Flow Layout functions

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(500, 400);
}

@end
