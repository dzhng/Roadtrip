//
//  RoadtripRoute.h
//  Roadtrip
//
//  Created by David Zhang on 10/6/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoadtripRoute : NSObject

@property (copy, nonatomic) NSString* distance;
@property (copy, nonatomic) NSString* time;
@property (copy, nonatomic) NSString* cost;

// array of CLLocations that store points of route
@property (retain, nonatomic) NSArray *routePoints;

@end
