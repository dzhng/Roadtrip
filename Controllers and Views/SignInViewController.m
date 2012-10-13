//
//  SignInViewController.m
//  Roadtrip
//
//  Created by Zachary Zimbler on 10/11/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view did load function");
    
    //get the device orientation
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    //portrait
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog(@"view is portrait");
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2.0) {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg1.png"]];
            NSLog(@"Retina - background bg1.png");
        } else {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg1-nonretina.png"]];
            NSLog(@"Not Retina - background bg1-nonretina.png");
        }
        
        
    }
    
    //landscape
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        NSLog(@"view is landscape");
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2.0) {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg2.png"]];
            NSLog(@"Retina - background bg2.png");
        } else {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg2-nonretina.png"]];
            NSLog(@"Not Retina - background bg2-nonretina.png");
        }
        
    }
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    NSLog(@"view didRotateFromInterfaceOrientation called");
    //get the device orientation
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    //portrait
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        NSLog(@"view is portrait");
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2.0) {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg1.png"]];
            NSLog(@"Retina - background bg1.png");
        } else {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg1-nonretina.png"]];
            NSLog(@"Not Retina - background bg1-nonretina.png");
        }
        
        
    }
    
    //landscape
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        NSLog(@"view is landscape");
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2.0) {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg2.png"]];
            NSLog(@"Retina - background bg2.png");
        } else {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg2-nonretina.png"]];
            NSLog(@"Not Retina - background bg2-nonretina.png");
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// prepare for segue to roadtrip view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RoadtripViewController* rvc = (RoadtripViewController*)segue.destinationViewController;
    
    // initialize model
    //RoadtripModel* roadtripModel = [[AppModel model] newRoadtrip];
    
    // get first roadtrip for user
    NSArray* roadtrips = [[AppModel model] getAllRoadtrips];
    // set current roadtrip as first one
    RoadtripModel* roadtrip = [[RoadtripModel alloc] initFromDB:[roadtrips objectAtIndex:0]];
    
    // set model delegate is this
    roadtrip.delegate = rvc;
    
    // set this new roadtrip as the current roadtrip in model
    [[AppModel model] setCurrentRoadtrip:roadtrip];
}

@end
