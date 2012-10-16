  //
//  SignInViewController.m
//  Roadtrip
//
//  Created by Zachary Zimbler on 10/14/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "SignInViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SignInViewController ()

@end

@implementation SignInViewController

<<<<<<< HEAD
- (void)viewDidLoad
=======
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
>>>>>>> bfc5cdd5a0756d4eb9131c94e9c2ccd4c6cc04f3
{
    [super viewDidLoad];
    
    // Set the login page background
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
<<<<<<< HEAD
    // Set the login page logo
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo.png"]]];
=======
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
>>>>>>> bfc5cdd5a0756d4eb9131c94e9c2ccd4c6cc04f3
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //silence is golden
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

<<<<<<< HEAD
@end
=======
@end
>>>>>>> bfc5cdd5a0756d4eb9131c94e9c2ccd4c6cc04f3
