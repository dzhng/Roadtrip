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
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook-hover.png"] forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
    //remove the label for signup and facebook
    [self.logInView.signUpLabel setText:@""];
    [self.logInView.externalLogInLabel setText:@""];
    
    //Sign Up Button
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signin.png"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signin.png"] forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setTitle:@"Sign Up W/ Email" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:@"Waaaa Hoooo" forState:UIControlStateHighlighted];
    [self.logInView.signUpButton.titleLabel setShadowColor: [UIColor darkGrayColor]];
    [self.logInView.signUpButton.titleLabel setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    
    // Add login field background
    fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field-bg.png"]];
    [self.logInView addSubview:self.fieldsBackground];
    [self.logInView sendSubviewToBack:self.fieldsBackground];
    
    //username text changed to email
    [self.logInView.usernameField setPlaceholder:@"Email"];
    
    // Set field text color
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:1.0]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:1.0]];
    
    //TODO: forgot password
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"forgot-bg.png"] forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"forgot-bg.png"] forState:UIControlStateHighlighted];


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
    
    // Set frame position for elements
    [self.logInView.logo setFrame:CGRectMake(300.0f, 15.0f, 426.0f, 239.0f)];
    [self.fieldsBackground setFrame:CGRectMake(395.0f, 265.0f, 240.0f, 100.0f)];
    [self.logInView.usernameField setFrame:CGRectMake(420.0f, 270.0f, 190.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(420.0f, 310.0f, 190.0f, 50.0f)];
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(385.0f, 290.0f, 21.0f, 55.0f)];
    [self.logInView.facebookButton setFrame:CGRectMake(405.0, 365.0f, 221.0f, 50.0f)];
    [self.logInView.signUpButton setFrame:CGRectMake(408.0f, 405.0f, 216.0f, 40.0f)];
    
    
}

@end
