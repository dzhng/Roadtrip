//
//  AppModel.h
//  Roadtrip
//
//  Created by David Zhang on 10/12/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoadtripModel.h"

// singleton class for the app model
@interface AppModel : NSObject

// list of all roadtrip models
@property (retain, nonatomic) NSMutableArray* roadtripModels;

// store the current ongoing roadtrip
@property (retain, nonatomic) RoadtripModel* currentRoadtrip;

// get shared singleton class
+ (id)model;

// get list of all roadtrips belonging to user and store in roadtripModels array
- (void)getAllRoadtrips;

// insert a new roadtrip model
- (RoadtripModel*)newRoadtrip;

@end
