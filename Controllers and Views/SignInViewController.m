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
@property (nonatomic, strong) UIImageView *fieldsBackground;

@end

@implementation SignInViewController
@synthesize fieldsBackground;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the login page background
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    // Set the login page logo
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
    
    //set facebook button
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
    //[self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"FacebookDown.png"] forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook-login.png"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
    //Sign Up Button
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"Signup.png"] forState:UIControlStateNormal];
    //[self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignupDown.png"] forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    
    //TODO: set the background for the username and password, forgot password, signup button turn to text
    
    //Signup field 
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

- (void)viewDidLayoutSubviews {
    // Set frame for elements
    [self.logInView.logo setFrame:CGRectMake(300.0f, 300.0f, 426.0f, 239.0f)];
    [self.logInView.facebookButton setFrame:CGRectMake(35.0f, 287.0f, 253.0f, 50.0f)];
    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
    [self.fieldsBackground setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 100.0f)];
    
    
    
    //UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 260, 260)];
    
    /* It's important to remember to pass CG structs like floats and CGColors */
    //[[self.logInView.facebookButton layer] setShadowOffset:CGSizeMake(0, 1)];
    //[[self.logInView.facebookButton layer] setShadowColor:[[UIColor darkGrayColor] CGColor]];
    //[[self.logInView.facebookButton layer] setShadowRadius:3.0];
    //[[self.logInView.facebookButton layer] setShadowOpacity:0.8];
}


@end
