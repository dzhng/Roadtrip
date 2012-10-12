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
#import "AppModel.h"

@interface RoadtripAppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController* navigationController;
    AppModel* model;
}

@property (strong, nonatomic) UIWindow *window;

@end
