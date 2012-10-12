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

@property (retain, nonatomic) NSArray* roadtripModels;

// get shared singleton class
+ (id)model;

// get current roadtrip model
- (RoadtripModel*)currentRoadtrip;

@end
