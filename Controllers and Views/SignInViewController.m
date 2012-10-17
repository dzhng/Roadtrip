//
//  SignInViewController.m
//  Roadtrip
//
//  Created by Zachary Zimbler on 10/14/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

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

@end
