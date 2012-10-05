//
//  RoadtripAppDelegate.h
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoadtripViewController.h"
#import "RoadtripLocation.h"
#import "RoadtripModel.h"

@interface RoadtripAppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController* navigationController;
}

@property (retain, nonatomic) RoadtripModel* model;

@property (strong, nonatomic) UIWindow *window;

@end
