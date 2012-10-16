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

static NSString *cellId = @"RoadtripMap";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // register collection view
    [self.collectionView registerClass:[RoadtripCollectionCell class] forCellWithReuseIdentifier:cellId];
    
    // set layout settings
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)[self.collectionView collectionViewLayout];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(40, 20, 40, 20);
    layout.minimumLineSpacing = 40;
    
    // TODO: Display loading animation
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    if ([PFUser currentUser]) {
        NSLog(@"there is a signed in user");
        //reloads the road trips into the main view
        [self reloadDataFromDB];
    } else {
        
        // Customize the Log In View Controller
        SignInViewController *logInViewController = [[SignInViewController alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
        [logInViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook |PFLogInFieldsPasswordForgotten |PFLogInFieldsSignUpButton ];
        
        // Customize the Sign Up View Controller
        //SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
        //[signUpViewController setDelegate:self];
        //[signUpViewController setFields:PFSignUpFieldsDefault | PFSignUpFieldsAdditional];
        //[logInViewController setSignUpController:signUpViewController];
        
        // Present Log In View Controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}

#pragma mark - PFLogInViewControllerDelegate
// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    return NO;
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
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
        
        // tell roadtrip to grab locations and routes before segue
        [roadtrip getAllLocationsAndRoutes];
        
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
