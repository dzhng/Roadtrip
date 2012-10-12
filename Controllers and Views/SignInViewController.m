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
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg2.png"]];
            NSLog(@"Retina");
        } else {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg2-nonretina.png"]];
            NSLog(@"Not Retina");
        }
        
        
    }
    //landscape
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        NSLog(@"view is landscape");
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2.0) {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg1.png"]];
            NSLog(@"Retina");
        } else {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg1-nonretina.png"]];
            NSLog(@"Not Retina");
        }
        
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if ((fromInterfaceOrientation == UIInterfaceOrientationPortrait) || (fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2.0) {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg2.png"]];
            // Retina
        } else {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg2-nonretina.png"]];
            // Not Retina
        }
        
        
    }
    if ((fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) || (fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2.0) {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg1.png"]];
            // Retina
        } else {
            self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg1-nonretina.png"]];
            // Not Retina
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
    RoadtripModel* roadtripModel = [[RoadtripModel alloc] init];
    
    // set model delegate is this
    roadtripModel.delegate = rvc;
    
    [rvc setRoadtripModel:roadtripModel];
}

@end
