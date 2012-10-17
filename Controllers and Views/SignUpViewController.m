//
//  SignUpViewController.m
//  Roadtrip
//
//  Created by Zachary Zimbler on 10/14/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation SignUpViewController
@synthesize fieldsBackground;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the login page background & Logo
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signin.png"]]];
    //background of fields set
    [self setFieldsBackground:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field-bg.png"]]];
    [self.signUpView insertSubview:fieldsBackground atIndex:1];
    //set the signup text to email instead of username
    [self.signUpView.usernameField setPlaceholder:@"Email"];
    
}

- (void)viewDidLayoutSubviews {
    // Set frame for elements
    [self.signUpView.signUpButton setFrame:CGRectMake(407.0f, 270.0f, 216.0f, 40.0f)];
    [self.fieldsBackground setFrame:CGRectMake(395.0f, 165.0f, 240.0f, 100.0f)];
    [self.signUpView.usernameField setFrame:CGRectMake(420.0f, 170.0f, 190.0f, 50.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(420.0f, 210.0f, 190.0f, 50.0f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
